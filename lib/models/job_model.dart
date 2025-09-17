class JobOffer {
  final String id;
  final String title;
  final String company;
  final String companyLogo;
  final String location;
  final String jobType; // full-time, part-time, remote, etc.
  final String experience; // junior, mid, senior
  final String salary;
  final List<String> skills;
  final String description;
  final DateTime postedDate;
  final bool isUrgent;
  final String contactEmail;

  JobOffer({
    required this.id,
    required this.title,
    required this.company,
    required this.companyLogo,
    required this.location,
    required this.jobType,
    required this.experience,
    required this.salary,
    required this.skills,
    required this.description,
    required this.postedDate,
    this.isUrgent = false,
    required this.contactEmail,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      experience: json['experience'] ?? '',
      salary: json['salary'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      description: json['description'] ?? '',
      postedDate: DateTime.parse(json['postedDate'] ?? DateTime.now().toIso8601String()),
      isUrgent: json['isUrgent'] ?? false,
      contactEmail: json['contactEmail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyLogo': companyLogo,
      'location': location,
      'jobType': jobType,
      'experience': experience,
      'salary': salary,
      'skills': skills,
      'description': description,
      'postedDate': postedDate.toIso8601String(),
      'isUrgent': isUrgent,
      'contactEmail': contactEmail,
    };
  }
}