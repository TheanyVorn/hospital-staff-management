enum NurseShift {
  morning('Morning'),
  afternoon('Afternoon'),
  night('Night');

  final String displayName;

  const NurseShift(this.displayName);

  @override
  String toString() => displayName;
}
