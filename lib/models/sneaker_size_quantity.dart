class SneakerSizeQuantity {
  String size;
  int quantity;
  double? price;
  double? earnings;
  String condition;
  String packaging;

  SneakerSizeQuantity({
    required this.size,
    this.quantity = 0,
    this.price,
    this.earnings,
    this.condition = 'New',
    this.packaging = 'Good Box',
  });
}
