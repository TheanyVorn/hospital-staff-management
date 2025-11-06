// ============================================
// DOMAIN LAYER - lib/domain/services/staff_service.dart
// ============================================

import '../models/staff.dart';

class StaffService {
  final List<Staff> _staffList = [];
  int _nextId = 1;

  List<Staff> get allStaff => List.unmodifiable(_staffList);

  int get nextId => _nextId;

  String addStaff(Staff staff) {
    _staffList.add(staff);
    return staff.id;
  }

  Staff? findById(String id) {
    try {
      return _staffList.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Staff> findByName(String name) {
    return _staffList
        .where((s) => s.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  List<Staff> findByRole(String role) {
    return _staffList
        .where((s) => s.role.toLowerCase() == role.toLowerCase())
        .toList();
  }

  List<Staff> getActiveStaff() {
    return _staffList.where((s) => s.isActive).toList();
  }

  List<Staff> getInactiveStaff() {
    return _staffList.where((s) => !s.isActive).toList();
  }

  bool updateStaff(String id, Staff updatedStaff) {
    int index = _staffList.indexWhere((s) => s.id == id);
    if (index != -1) {
      _staffList[index] = updatedStaff;
      return true;
    }
    return false;
  }

  bool deactivateStaff(String id) {
    Staff? staff = findById(id);
    if (staff != null && staff.isActive) {
      staff.isActive = false;
      return true;
    }
    return false;
  }

  bool activateStaff(String id) {
    Staff? staff = findById(id);
    if (staff != null && !staff.isActive) {
      staff.isActive = true;
      return true;
    }
    return false;
  }

  bool deleteStaff(String id) {
    final initialLength = _staffList.length;
    _staffList.removeWhere((s) => s.id == id);
    return _staffList.length < initialLength; // True if item(s) were removed
  }

  String generateId() {
    return 'S${_nextId.toString().padLeft(4, '0')}';
  }

  void incrementId() {
    _nextId++;
  }

  Map<String, int> getStatistics() {
    return {
      'total': _staffList.length,
      'active': getActiveStaff().length,
      'inactive': getInactiveStaff().length,
      'admins': findByRole('Admin').length,
      'doctors': findByRole('Doctor').length,
      'nurses': findByRole('Nurse').length,
    };
  }

  void loadStaffList(List<Staff> staffList, int nextId) {
    _staffList.clear();
    _staffList.addAll(staffList);
    _nextId = nextId;
  }
}
