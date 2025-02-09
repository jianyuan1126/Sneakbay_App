import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';
import 'creditcard_model.dart';

class UserModel {
  final String email;
  final String name;
  final String uid;
  final DateTime? birthday;
  final int phoneNumber;
  final Address? address;
  final CreditCard? creditCard;
  int points;
  double availableCurrency; 
  final double lifetimeSales; 
  final BankAccountDetails? bankAccountDetails; 
  String status; 

  UserModel({
    required this.email,
    required this.name,
    required this.uid,
    this.birthday,
    required this.phoneNumber,
    this.address,
    this.creditCard,
    this.points = 90,
    this.availableCurrency = 0.0, 
    this.lifetimeSales = 0.0, 
    this.bankAccountDetails, 
    this.status = 'active', 
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      uid: data['uid'] ?? '',
      birthday:
          data['birthday'] != null ? DateTime.parse(data['birthday']) : null,
      phoneNumber: int.tryParse(data['phoneNumber'].toString()) ?? 0,
      address:
          data['address'] != null ? Address.fromMap(data['address']) : null,
      creditCard: data['creditCard'] != null
          ? CreditCard.fromMap(data['creditCard'])
          : null,
      points: data['points'] ?? 90,
      availableCurrency: (data['availableCurrency'] ?? 0.0).toDouble(),
      lifetimeSales: (data['lifetimeSales'] ?? 0.0).toDouble(),
      bankAccountDetails: data['bankAccountDetails'] != null
          ? BankAccountDetails.fromMap(data['bankAccountDetails'])
          : null,
      status: data['status'] ?? 'active', 
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    var map = {
      'email': email,
      'name': name,
      'uid': uid,
      'phoneNumber': phoneNumber,
      'points': points,
      'availableCurrency': availableCurrency,
      'lifetimeSales': lifetimeSales,
      'status': status, 
    };

    if (birthday != null) {
      map['birthday'] = birthday!.toIso8601String();
    }
    if (address != null) {
      map['address'] = address!.toMap();
    }
    if (creditCard != null) {
      map['creditCard'] = creditCard!.toMap();
    }
    if (bankAccountDetails != null) {
      map['bankAccountDetails'] = bankAccountDetails!.toMap();
    }

    return map;
  }
}

class BankAccountDetails {
  final String bankName;
  final String accountNumber;
  final String accountHolderName;

  BankAccountDetails({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
  });

  factory BankAccountDetails.fromMap(Map<String, dynamic> data) {
    return BankAccountDetails(
      bankName: data['bankName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountHolderName: data['accountHolderName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
    };
  }
}
