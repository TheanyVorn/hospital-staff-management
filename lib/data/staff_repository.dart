// ============================================
// DATA LAYER - lib/data/staff_repository.dart
// ============================================

import 'dart:io';
import 'dart:convert';
import 'package:managing_staff_g2t3/domain/models/staff.dart'; // Updated to your package name
import 'package:managing_staff_g2t3/domain/models/admin.dart';
import 'package:managing_staff_g2t3/domain/models/doctor.dart';
import 'package:managing_staff_g2t3/domain/models/nurse.dart';

class StaffRepository {
  final String _filePath;

  StaffRepository(this._filePath);

  Future<Map<String, dynamic>> loadData() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        return {'staffList': <Staff>[], 'nextId': 1}; // Explicit <Staff>[] type
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return {'staffList': <Staff>[], 'nextId': 1}; // Explicit <Staff>[] type
      }

      final data = jsonDecode(contents);
      final staffList = <Staff>[];

      for (var item in data['staffList']) {
        switch (item['type']) {
          case 'Admin':
            staffList.add(Admin.fromJson(item));
            break;
          case 'Doctor':
            staffList.add(Doctor.fromJson(item));
            break;
          case 'Nurse':
            staffList.add(Nurse.fromJson(item));
            break;
        }
      }

      return {'staffList': staffList, 'nextId': data['nextId'] ?? 1};
    } catch (e) {
      print('Error loading data: $e');
      return {'staffList': <Staff>[], 'nextId': 1}; // Explicit <Staff>[] type
    }
  }

  Future<bool> saveData(List<Staff> staffList, int nextId) async {
    try {
      final file = File(_filePath);
      final data = {
        'staffList': staffList.map((s) => s.toJson()).toList(),
        'nextId': nextId,
      };

      await file.writeAsString(jsonEncode(data));
      return true;
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }

  Future<bool> backupData() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) return false;

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = '${_filePath}.backup.$timestamp';
      await file.copy(backupPath);
      return true;
    } catch (e) {
      print('Error creating backup: $e');
      return false;
    }
  }
}
