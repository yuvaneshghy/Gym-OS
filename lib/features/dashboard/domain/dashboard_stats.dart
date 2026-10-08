class DashboardStats {
  const DashboardStats({
    required this.totalMembers,
    required this.activeMembers,
    required this.presentToday,
    required this.monthlyRevenue,
  });

  final int totalMembers;
  final int activeMembers;
  final int presentToday;
  final double monthlyRevenue;
}
