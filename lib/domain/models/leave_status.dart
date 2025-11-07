enum LeaveStatus {
  pending('Pending'),
  approved('Approved'),
  cancelled('Cancelled'),
  onLeave('On Leave');

  final String displayName;

  const LeaveStatus(this.displayName);

  @override
  String toString() => displayName;
}
