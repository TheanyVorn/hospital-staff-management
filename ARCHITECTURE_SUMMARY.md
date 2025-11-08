# Layered Architecture Summary

## Overview
Your Hospital Staff Management System follows a **3-Layer Architecture Pattern**, separating concerns across Data, Domain, and UI layers for maintainability and scalability.

---

## 1. **UI Layer** (User Interface)
**File:** `lib/ui/console_ui.dart`

### Purpose
Handles all user interaction and menu-driven interface.

### Key Components
- **10 Interactive Menus:**
  1. Add New Staff
  2. View All Staff (with statistics)
  3. Search Staff (by ID, Name, Role)
  4. Update Staff Information (role-specific)
  5. Manage Staff Status (Activate/Deactivate)
  6. Manage Staff Shifts (Nurse-only)
  7. Leave Request Management
  8. Manage Salary
  9. View Overall Statistics
  10. Save Data

### Responsibilities
- Input validation and error handling
- Menu navigation and user guidance
- Data display formatting
- User feedback (success/error messages)
- Calls StaffService for business logic

### Key Methods
- `_addStaffMenu()` - Staff creation with role-specific inputs
- `_viewAllStaffMenu()` - Display all staff with statistics
- `_searchStaffMenu()` - Search by ID/Name/Role
- `_updateStaffMenu()` / `_updateDoctorMenu()` / `_updateGeneralStaffMenu()` - Update staff info
- `_manageStaffStatusMenu()` - Activate/Deactivate staff
- `_manageShiftsMenu()` - Nurse shift management
- `_leaveRequestMenu()` - Leave application and viewing
- `_manageSalaryMenu()` - Salary and bonus management

---

## 2. **Domain Layer** (Business Logic)
**Files:** `lib/domain/models/` and `lib/domain/services/`

### Purpose
Contains core business logic, models, and service operations.

### A. Models (Data Structures)
```
lib/domain/models/
├── staff.dart (abstract base class)
├── doctor.dart (inherits Staff)
├── nurse.dart (inherits Staff)
├── admin.dart (inherits Staff)
├── leave.dart (leave records)
├── leave_status.dart (enum)
└── nurse_shift.dart (enum)
```

**Staff.dart** (Abstract Base)
- Properties: id, name, email, phone, hireDate, isActive, baseSalary, bonus, leaves
- Methods: applyLeave(), getLeaves(), calculateTotalSalary(), updateSalary(), updateBonus()
- Subclasses override: role property, getStatusSummary(), toJson/fromJson()

**Doctor.dart**
- Additional Properties: specialization, licenseNumber, yearsOfExperience, certifications, isAvailable, maxPatients, currentPatients
- Methods: isAvailableForAppointments(), canAcceptNewPatient(), addPatient(), removePatient(), setAvailability()

**Nurse.dart**
- Additional Properties: ward, shift (NurseShift enum), nursingLevel, patientsUnderCare
- Methods: transferWard(), changeShift(), updatePatientCare(), removePatientCare(), getPatientsUnderCare()

**Admin.dart**
- Additional Properties: department, adminRole, permissions
- Methods: hasPermission(), grantPermission(), revokePermission(), manageStaffRecords(), processLeaveRequest()

**Leave.dart**
- Properties: leaveId, employeeId, startDate, endDate, status (LeaveStatus enum)
- Methods: getDuration(), isValid(), getLeaveDetails()

**Enums**
- LeaveStatus: pending, approved, cancelled, onLeave
- NurseShift: morning, afternoon, night

### B. Services
**StaffService.dart**

Manages business operations on staff:

**Core Methods (UML-specified):**
- `addStaff(staff)` - Add new staff member
- `findById(id)` - Retrieve staff by ID
- `updateStaff(id, updatedStaff)` - Update staff details
- `deleteStaff(id)` - Remove staff
- `getAllStaff()` - Get all staff members

**Additional Methods (Enhanced):**
- `findByName(name)` - Search by name
- `findByRole(role)` - Filter by role
- `getActiveStaff()` - Get active employees
- `getInactiveStaff()` - Get inactive employees
- `activateStaff(id)` / `deactivateStaff(id)` - Manage status
- `generateId()` - Auto-generate sequential IDs (S0001, S0002...)
- `getStatistics()` - Get staff statistics (total, active, inactive, by role)
- `loadStaffList()` - Load from persistence

### Responsibilities
- CRUD operations on Staff
- Business rule enforcement
- Data filtering and searching
- Statistics calculation
- No direct UI or data file access

---

## 3. **Data Layer** (Persistence)
**File:** `lib/data/staff_repository.dart`

### Purpose
Handles data persistence and retrieval from JSON storage.

### Key Components
- **Main File:** `staff_data.json` (project root)
- **Backup:** `staff_data_backup_[timestamp].json`

### Key Methods
- `loadData()` - Load staff from JSON file with error handling
- `saveData()` - Save staff to JSON file
- `backupData()` - Create timestamped backup before saving

### Responsibilities
- JSON file I/O operations
- Data serialization (Object → JSON)
- Data deserialization (JSON → Object)
- Error handling and recovery
- Backup management
- No business logic, pure data access

### Data Structure (JSON)
```json
{
  "staff": [
    {
      "type": "Doctor",
      "id": "S0001",
      "name": "Dr. Smith",
      "email": "smith@hospital.com",
      "phone": "555-0001",
      "hireDate": "2023-01-15T00:00:00.000",
      "isActive": true,
      "assignedShifts": [],
      "specialization": "Cardiology",
      "licenseNumber": "MD-12345",
      "yearsOfExperience": 10,
      "certifications": [],
      "baseSalary": 120000.0,
      "bonus": 5000.0,
      "isAvailable": true,
      "maxPatients": 20,
      "currentPatients": 5,
      "leaves": []
    }
  ],
  "nextId": 2
}
```

---

## 4. **Dependency Flow (Data → Domain → UI)**

```
┌─────────────────────────────────────┐
│       UI Layer (ConsoleUI)          │  ← User interacts here
│  (Menus, Input, Display)            │
└──────────────────┬──────────────────┘
                   │ calls
                   ↓
┌─────────────────────────────────────┐
│    Domain Layer (Business Logic)    │  ← Processes business rules
│  - StaffService (operations)        │
│  - Models (Staff, Doctor, etc.)     │
│  - Enums (LeaveStatus, NurseShift)  │
└──────────────────┬──────────────────┘
                   │ calls
                   ↓
┌─────────────────────────────────────┐
│   Data Layer (Persistence)          │  ← Stores/retrieves data
│  - StaffRepository (JSON I/O)       │
│  - staff_data.json (file storage)   │
└─────────────────────────────────────┘
```

---

## 5. **Key Architecture Principles**

### ✅ **Separation of Concerns**
- **UI:** Only handles user interface
- **Domain:** Only handles business logic
- **Data:** Only handles storage/retrieval

### ✅ **Single Responsibility**
- Each class has one reason to change
- Each layer has one purpose

### ✅ **Dependency Injection**
- UI depends on Domain (StaffService)
- Domain depends on Data (StaffRepository)
- No circular dependencies

### ✅ **Abstraction**
- Staff is abstract (subclassed by Doctor, Nurse, Admin)
- Repository abstracts JSON file operations
- Service abstracts business logic

### ✅ **Reusability**
- Domain layer can be used by different UIs (console, web, mobile)
- Data layer can be replaced with database without changing UI/Domain

---

## 6. **Data Flow Example: Add New Staff**

```
1. UI Layer → User enters staff details
   └─> _addStaffMenu() validates input

2. Domain Layer → Create Staff object
   └─> StaffService.addStaff(doctor)
   └─> Generates ID (S0001)
   └─> Adds to internal list

3. Data Layer → Save to disk
   └─> StaffRepository.saveData()
   └─> Serializes to JSON
   └─> Writes to staff_data.json
   └─> Creates backup

4. UI Layer → Show success message
   └─> "✓ Staff added successfully!"
```

---

## 7. **Benefits of This Architecture**

| Benefit | Impact |
|---------|--------|
| **Testability** | Each layer can be tested independently |
| **Maintainability** | Changes in one layer don't affect others |
| **Scalability** | Easy to add new features or layers |
| **Reusability** | Domain logic can be used in different contexts |
| **Clarity** | Clear responsibility for each component |
| **Flexibility** | Can swap data storage (JSON → Database) easily |

---

## 8. **Summary**

Your 3-layer architecture provides a professional, scalable foundation:

- **UI Layer:** Beautiful console interface with 10 interactive menus
- **Domain Layer:** Robust business logic with 7 model classes and 1 service
- **Data Layer:** Reliable JSON persistence with backup and error handling

This structure ensures your application is maintainable, testable, and ready for future enhancements.

