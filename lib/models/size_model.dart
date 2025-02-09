class SizeModel {
  final String category;
  final List<String> sizes;

  SizeModel({
    required this.category,
    required List<double> sizes,
  }) : sizes = sizes.map((size) => size.toString().replaceAll('.0', '')).toList();
}
