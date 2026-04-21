class ServiceAvailabilityModel {
  final String date;
  final Map<String, bool> services;

  ServiceAvailabilityModel({
    required this.date,
    required this.services,
  });

  factory ServiceAvailabilityModel.fromMap(Map<String, dynamic> data, String documentId) {
    final Map<String, bool> serviceMap = {};
    data.forEach((key, value) {
      if (value is bool) {
        serviceMap[key] = value;
      }
    });
    return ServiceAvailabilityModel(
      date: documentId,
      services: serviceMap,
    );
  }

  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.from(services);
  }

  /// Returns default availability (all services enabled)
  static ServiceAvailabilityModel defaultAvailability(String date) {
    return ServiceAvailabilityModel(
      date: date,
      services: {
        'retreading': true,
        'remoulding': true,
        'inspection': true,
        'new_fitment': true,
      },
    );
  }
}
