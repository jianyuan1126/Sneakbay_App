import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/common_enums.dart';

class ShoeModel {
  String id;
  String name;
  double retailPrice;
  String imgAddress;
  String sku;
  String releaseDate;
  String colorway;
  String brand;
  List<ShoeCategory> categories;
  String description;
  String modelColour;
  ShoeSizeCategory sizeCategory;
  String? userId; 

  ShoeModel({
    required this.id,
    required this.name,
    required this.retailPrice,
    required this.imgAddress,
    required this.sku,
    required this.releaseDate,
    required this.colorway,
    required this.brand,
    required this.categories,
    required this.description,
    required this.modelColour,
    required this.sizeCategory,
    this.userId, 
  });

  factory ShoeModel.fromFirestore(Map<String, dynamic> json, String id) {
    return ShoeModel(
      id: id,
      name: json['name'],
      retailPrice: (json['retailPrice'] as num).toDouble(),
      imgAddress: json['imgAddress'],
      sku: json['sku'],
      releaseDate: json['releaseDate'],
      colorway: json['colorway'],
      brand: json['brand'],
      categories: (json['categories'] as List)
          .map((e) => ShoeCategory.values
              .firstWhere((element) => describeEnum(element) == e))
          .toList(),
      description: json['description'],
      modelColour: json['modelColour'],
      sizeCategory: ShoeSizeCategory.values.firstWhere(
          (element) => describeEnum(element) == json['sizeCategory']),
      userId: json['userId'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'retailPrice': retailPrice,
      'imgAddress': imgAddress,
      'sku': sku,
      'releaseDate': releaseDate,
      'colorway': colorway,
      'brand': brand,
      'categories': categories.map((c) => describeEnum(c)).toList(),
      'description': description,
      'modelColour': modelColour,
      'sizeCategory': describeEnum(sizeCategory),
      'userId': userId, 
    };
  }
}
