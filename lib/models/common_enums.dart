// common_enum.dart
enum ShoeCategory { trending, justDropped, upcoming, }

enum ShoeSizeCategory { Mens, Womens, Kids,}

const Map<ShoeSizeCategory, List<double>> predefinedSizes = {
  ShoeSizeCategory.Mens: [
    6,
    6.5,
    7,
    7.5,
    8,
    8.5,
    9,
    9.5,
    10,
    10.5,
    11,
    11.5,
    12,
    12.5,
    13,
    14
  ],
  ShoeSizeCategory.Womens: [
    5,
    5.5,
    6,
    6.5,
    7,
    7.5,
    8,
    8.5,
    9,
    9.5,
    10,
    10.5,
    11,
    11.5,
    12
  ],
  ShoeSizeCategory.Kids: [3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7],
};

const List<String> predefinedConditions = ['New', 'Used', 'Brand New Defects'];

const List<String> predefinedPackaging = [
  'Good Box',
  'Missing Lid',
  'Damaged Box',
  'No Box'
];
