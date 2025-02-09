import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';

enum OrderStatus {
  Pending,
  Confirmed,
  DroppedOff,
  IssueDetectedandReturning,
  InTransit,
  ArrivedandLegitChecking,
  Canceled,
  Closed,
  Purchased
}

class OrderModel {
  String id;
  String orderId;
  String userId;
  String userName;
  String shoeName;
  String size;
  String condition;
  String packaging;
  double price;
  double earnings; 
  OrderStatus status;
  DateTime orderCreatedTimestamp;
  DateTime? orderConfirmedTimestamp;
  String imgAddress;
  Address? userAddress;
  String userEmail;
  String sku;
  String trackingId;
  String? fulfillmentMethod; 
  String? issueDescription;
  String? returnTrackingId;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.shoeName,
    required this.size,
    required this.condition,
    required this.packaging,
    required this.price,
    required this.earnings, 
    required this.status,
    required this.orderCreatedTimestamp,
    this.orderConfirmedTimestamp,
    required this.imgAddress,
    required this.userAddress,
    required this.userEmail,
    required this.sku,
    required this.trackingId,
    this.fulfillmentMethod, 
    this.issueDescription, 
    this.returnTrackingId, 
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> json, String id) {
    final orderId = json['orderId'] ?? '';
    final userId = json['userId'] ?? '';
    final userName = json['userName'] ?? '';
    final shoeName = json['shoeName'] ?? '';
    final size = json['size'] ?? '';
    final condition = json['condition'] ?? '';
    final packaging = json['packaging'] ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final earnings =
        (json['earnings'] as num?)?.toDouble() ?? 0.0; 
    final status = OrderStatus.values.firstWhere(
      (e) => e.toString() == 'OrderStatus.${json['status']}',
      orElse: () => OrderStatus.Pending,
    );
    final orderCreatedTimestamp =
        (json['orderCreatedTimestamp'] as Timestamp?)?.toDate() ??
            DateTime.now();
    final orderConfirmedTimestamp = json['orderConfirmedTimestamp'] != null
        ? (json['orderConfirmedTimestamp'] as Timestamp).toDate()
        : null;
    final imgAddress = json['imgAddress'] ?? '';
    final userAddress = json['userAddress'] != null
        ? Address.fromMap(json['userAddress'])
        : Address(streetAddress1: '', city: '', state: '', postalCode: 0);
    final userEmail = json['userEmail'] ?? '';
    final sku = json['sku'] ?? '';
    final trackingId = json['trackingId'] ?? '';
    final fulfillmentMethod = json['fulfillmentMethod']; 
    final issueDescription = json['issueDescription']; 
    final returnTrackingId = json['returnTrackingId'];

    return OrderModel(
      id: id,
      orderId: orderId,
      userId: userId,
      userName: userName,
      shoeName: shoeName,
      size: size,
      condition: condition,
      packaging: packaging,
      price: price,
      earnings: earnings, 
      status: status,
      orderCreatedTimestamp: orderCreatedTimestamp,
      orderConfirmedTimestamp: orderConfirmedTimestamp,
      imgAddress: imgAddress,
      userAddress: userAddress,
      userEmail: userEmail,
      sku: sku,
      trackingId: trackingId,
      fulfillmentMethod: fulfillmentMethod, 
      issueDescription: issueDescription, 
      returnTrackingId: returnTrackingId, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'shoeName': shoeName,
      'size': size,
      'condition': condition,
      'packaging': packaging,
      'price': price,
      'earnings': earnings, 
      'status': status.toString().split('.').last,
      'orderCreatedTimestamp': Timestamp.fromDate(orderCreatedTimestamp),
      'orderConfirmedTimestamp': orderConfirmedTimestamp != null
          ? Timestamp.fromDate(orderConfirmedTimestamp!)
          : null,
      'imgAddress': imgAddress,
      'userAddress': userAddress?.toMap(),
      'userEmail': userEmail,
      'sku': sku,
      'trackingId': trackingId,
      'fulfillmentMethod': fulfillmentMethod, 
      'issueDescription': issueDescription, 
      'returnTrackingId': returnTrackingId, 
    };
  }
}
