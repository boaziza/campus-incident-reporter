import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../components/category_selector.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../models/incident.dart';
import '../models/incident_category.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/report_incident_arguments.dart';
import '../utils/validators.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  IncidentCategory? _category;
  String? _location;
  File? _image;
  bool _isAnonymous = false;
  bool _showCategoryError = false;

  Incident? _editing; // not null when editing an existing report
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ReportIncidentArguments) {
      _editing = args.incidentToEdit;
      _titleController.text = _editing!.title;
      _descriptionController.text = _editing!.description;
      _category = _editing!.category;
      _location = _editing!.location;
      _isAnonymous = _editing!.isAnonymous;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => _editing != null;

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close the bottom sheet
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 70, // smaller uploads, faster on campus wifi
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
      }
    } catch (e) {
      _showMessage('Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    setState(() => _showCategoryError = _category == null);
    if (!formValid || _category == null) {
      _showMessage('Please fix the highlighted fields.');
      return;
    }

    final provider = context.read<IncidentProvider>();
    final bool success;

    if (_isEditing) {
      success = await provider.editIncident(
        incident: _editing!,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _location!,
      );
    } else {
      success = await provider.submitIncident(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category!,
        location: _location!,
        isAnonymous: _isAnonymous,
        image: _image,
      );
    }

    if (!mounted) return;
    if (success) {
      _showMessage(_isEditing
          ? 'Report updated.'
          : 'Report submitted! Staff have been notified.');
      Navigator.pop(context);
    } else {
      _showMessage(provider.errorMessage ?? 'Could not submit report.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<IncidentProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Report' : 'Report an Incident'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _Label('Select a category'),
              CategorySelector(
                selected: _category,
                // category is locked after submitting so stats stay accurate
                enabled: !_isEditing,
                onSelected: (category) => setState(() {
                  _category = category;
                  _showCategoryError = false;
                }),
              ),
              if (_showCategoryError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Please choose a category',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Briefly describe the issue...',
                maxLength: AppConstants.maxTitleLength,
                textInputAction: TextInputAction.next,
                validator: Validators.title,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint:
                    'Provide more details about the issue, e.g. what happened, when, impact, etc.',
                maxLines: 5,
                maxLength: AppConstants.maxDescriptionLength,
                validator: Validators.description,
              ),
              const SizedBox(height: 8),
              const _Label('Location'),
              DropdownButtonFormField<String>(
                initialValue: _location,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Where is the issue?',
                  prefixIcon:
                      Icon(Icons.location_on_outlined, color: AppColors.textGrey),
                ),
                items: _locationOptions()
                    .map((loc) =>
                        DropdownMenuItem(value: loc, child: Text(loc)))
                    .toList(),
                onChanged: (value) => setState(() => _location = value),
                validator: (value) => Validators.required(value, 'location'),
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 20),
                const _Label('Add a photo (optional)'),
                _PhotoPicker(
                  image: _image,
                  onTap: _showImageSourceSheet,
                  onRemove: () => setState(() => _image = null),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isAnonymous,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => setState(() => _isAnonymous = value),
                  title: const Text(
                    'Hide my name from other students',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Campus staff can still see who reported it.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: _isEditing ? 'Save Changes' : 'Submit Report',
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep an old custom location visible when editing
  List<String> _locationOptions() {
    final options = [...AppConstants.campusLocations];
    if (_location != null && !options.contains(_location)) {
      options.insert(0, _location!);
    }
    return options;
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              image!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Remove photo',
                onPressed: onRemove,
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.textGrey, size: 30),
            SizedBox(height: 6),
            Text('Tap to add photos',
                style: TextStyle(color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}
