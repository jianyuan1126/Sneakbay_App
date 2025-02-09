class Address {
  final String streetAddress1;
  final String? streetAddress2;
  final String city;
  final String state;
  final int postalCode;

  Address({
    required this.streetAddress1,
    this.streetAddress2,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      streetAddress1: map['streetAddress1'] ?? '',
      streetAddress2: map['streetAddress2'],
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: int.tryParse(map['postalCode'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streetAddress1': streetAddress1,
      'streetAddress2': streetAddress2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
    };
  }
}
