import 'package:campus_incident_reporter/models/incident_category.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email validation', () {
    test('accepts ALU student and staff emails', () {
      expect(Validators.email('amina@alustudent.com'), isNull);
      expect(Validators.email('j.doe@alueducation.com'), isNull);
      expect(Validators.email('Amina@ALUSTUDENT.com'), isNull);
    });

    test('rejects non ALU emails', () {
      expect(Validators.email('amina@gmail.com'), isNotNull);
      expect(Validators.email('amina@alustudent.com.fake.io'), isNotNull);
    });

    test('rejects empty or malformed emails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });
  });

  group('Report form validation', () {
    test('title must be at least 5 characters', () {
      expect(Validators.title('Leak'), isNotNull);
      expect(Validators.title('Water leak'), isNull);
    });

    test('description needs enough detail', () {
      expect(Validators.description('Broken'), isNotNull);
      expect(Validators.description('The tap in room 204 is leaking.'), isNull);
    });

    test('passwords must match', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });

  group('Enums from Firestore strings', () {
    test('status parses and falls back to submitted', () {
      expect(IncidentStatus.fromString('inProgress'), IncidentStatus.inProgress);
      expect(IncidentStatus.fromString('unknown'), IncidentStatus.submitted);
      expect(IncidentStatus.resolved.isClosed, isTrue);
      expect(IncidentStatus.inProgress.isClosed, isFalse);
    });

    test('category parses and falls back to facilities', () {
      expect(IncidentCategory.fromString('water'), IncidentCategory.water);
      expect(IncidentCategory.fromString(null), IncidentCategory.facilities);
    });
  });
}
