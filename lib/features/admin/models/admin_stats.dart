class AdminStats {
  final int totalUsers;
  final int totalCourses;
  final int totalEnrollments;
  final double totalRevenue;
  final int newUsersToday;
  final int newEnrollmentsToday;
  final double revenueToday;
  final double averageRating;

  AdminStats({
    required this.totalUsers,
    required this.totalCourses,
    required this.totalEnrollments,
    required this.totalRevenue,
    required this.newUsersToday,
    required this.newEnrollmentsToday,
    required this.revenueToday,
    required this.averageRating,
  });

  factory AdminStats.fromMap(Map<String, dynamic> map) {
    return AdminStats(
      totalUsers: map['totalUsers'] ?? 0,
      totalCourses: map['totalCourses'] ?? 0,
      totalEnrollments: map['totalEnrollments'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      newUsersToday: map['newUsersToday'] ?? 0,
      newEnrollmentsToday: map['newEnrollmentsToday'] ?? 0,
      revenueToday: (map['revenueToday'] ?? 0).toDouble(),
      averageRating: (map['averageRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalCourses': totalCourses,
      'totalEnrollments': totalEnrollments,
      'totalRevenue': totalRevenue,
      'newUsersToday': newUsersToday,
      'newEnrollmentsToday': newEnrollmentsToday,
      'revenueToday': revenueToday,
      'averageRating': averageRating,
    };
  }
}