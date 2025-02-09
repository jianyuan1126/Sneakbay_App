class CreditCard {
  final String cardNumber; 
  final String expiryMonth;
  final String expiryYear;
  final String cvv; 

  CreditCard({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      cardNumber: map['cardNumber'] ?? '',
      expiryMonth: map['expiryMonth'] ?? '',
      expiryYear: map['expiryYear'] ?? '',
      cvv: map['cvv'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber, 
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv, 
    };
  }
}
