import 'dart:io';
import 'package:managing_staff_g2t3/domain/services/staff_service.dart';
import 'package:managing_staff_g2t3/data/staff_repository.dart';
import 'package:managing_staff_g2t3/ui/console_ui.dart';

void main() async {
  final staffService = StaffService();
  final repository = StaffRepository('staff_data.json');
  final ui = ConsoleUI(staffService, repository);

  await ui.start();
}
