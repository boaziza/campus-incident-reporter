import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';
import '../models/status_update.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';

// Single source of truth for incident reports. Every screen reads from
// here, so when staff change a status it updates on all screens at once.
class IncidentProvider extends ChangeNotifier {
  final IncidentService _incidentService = IncidentService.instance;
  final StorageService _storageService = StorageService.instance;

  StreamSubscription<List<Incident>>? _subscription;
  AppUser? _user;

  List<Incident> _incidents = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Browse filters
  String _searchQuery = '';
  IncidentCategory? _categoryFilter;
  IncidentStatus? _statusFilter;

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  IncidentCategory? get categoryFilter => _categoryFilter;
  IncidentStatus? get statusFilter => _statusFilter;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _categoryFilter != null || _statusFilter != null;

  // Called by ChangeNotifierProxyProvider every time AuthProvider changes
  void updateUser(AppUser? user) {
    if (user?.uid == _user?.uid) {
      _user = user; // role may have changed, keep the same stream
      return;
    }
    _user = user;
    _subscription?.cancel();
    _incidents = [];
    clearFilters(notify: false);

    if (user != null) {
      _listenToIncidents();
    }
  }

  void _listenToIncidents() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription = _incidentService.streamIncidents().listen(
      (incidents) {
        _incidents = incidents;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object e) {
        _isLoading = false;
        _errorMessage = 'Could not load reports. Check your connection.';
        notifyListeners();
      },
    );
  }

  // ---------- Derived lists ----------

  List<Incident> get myIncidents =>
      _incidents.where((i) => i.reporterId == _user?.uid).toList();

  List<Incident> myIncidentsByStatus(IncidentStatus? status) {
    if (status == null) return myIncidents;
    return myIncidents.where((i) => i.status == status).toList();
  }

  // Search + category + status filters for the browse screen
  List<Incident> get filteredIncidents {
    final query = _searchQuery.toLowerCase();
    return _incidents.where((incident) {
      final matchesQuery = query.isEmpty ||
          incident.title.toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query) ||
          incident.location.toLowerCase().contains(query);
      final matchesCategory =
          _categoryFilter == null || incident.category == _categoryFilter;
      final matchesStatus =
          _statusFilter == null || incident.status == _statusFilter;
      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();
  }

  int countByStatus(List<Incident> list, IncidentStatus status) =>
      list.where((i) => i.status == status).length;

  Incident? getById(String id) {
    for (final incident in _incidents) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  bool canEdit(Incident incident) =>
      incident.reporterId == _user?.uid &&
      incident.status == IncidentStatus.submitted;

  bool canDelete(Incident incident) =>
      (_user?.isStaff ?? false) || canEdit(incident);

  bool hasUpvoted(Incident incident) =>
      _user != null && incident.upvotes.contains(_user!.uid);

  // ---------- Filters ----------

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters({bool notify = true}) {
    _searchQuery = '';
    _categoryFilter = null;
    _statusFilter = null;
    if (notify) notifyListeners();
  }

  // ---------- CRUD ----------

  Future<bool> submitIncident({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool isAnonymous,
    File? image,
  }) async {
    final user = _user;
    if (user == null) return false;

    return _runSubmitting(() async {
      UploadResult? upload;
      if (image != null) {
        upload = await _storageService.uploadIncidentImage(
          file: image,
          uid: user.uid,
        );
      }

      final now = DateTime.now();
      final incident = Incident(
        id: '',
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location,
        imageUrl: upload?.url,
        imagePath: upload?.path,
        status: IncidentStatus.submitted,
        reporterId: user.uid,
        reporterName: user.name,
        isAnonymous: isAnonymous,
        createdAt: now,
        updatedAt: now,
        statusHistory: [
          StatusUpdate(
            status: IncidentStatus.submitted,
            note: 'Report submitted',
            changedBy: user.uid,
            changedByName: user.name,
            changedAt: now,
          ),
        ],
      );
      await _incidentService.createIncident(incident);
    });
  }

  Future<bool> editIncident({
    required Incident incident,
    required String title,
    required String description,
    required String location,
  }) {
    return _runSubmitting(() => _incidentService.updateIncidentDetails(
          id: incident.id,
          title: title.trim(),
          description: description.trim(),
          location: location,
        ));
  }

  Future<bool> updateStatus({
    required Incident incident,
    required IncidentStatus newStatus,
    String note = '',
  }) async {
    final user = _user;
    if (user == null || !user.isStaff) {
      _errorMessage = 'Only campus staff can update a status.';
      notifyListeners();
      return false;
    }

    return _runSubmitting(() => _incidentService.updateStatus(
          id: incident.id,
          status: newStatus,
          update: StatusUpdate(
            status: newStatus,
            note: note.trim(),
            changedBy: user.uid,
            changedByName: user.name,
            changedAt: DateTime.now(),
          ),
        ));
  }

  Future<bool> deleteIncident(Incident incident) {
    return _runSubmitting(() async {
      await _incidentService.deleteIncident(incident.id);
      if (incident.imagePath != null) {
        await _storageService.deleteImage(incident.imagePath!);
      }
    });
  }

  Future<void> toggleUpvote(Incident incident) async {
    final user = _user;
    if (user == null || incident.reporterId == user.uid) return;
    try {
      await _incidentService.toggleUpvote(
        id: incident.id,
        uid: user.uid,
        add: !hasUpvoted(incident),
      );
    } catch (e) {
      _errorMessage = 'Could not save your confirmation.';
      notifyListeners();
    }
  }

  Future<bool> _runSubmitting(Future<void> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      debugPrint('IncidentProvider error: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
