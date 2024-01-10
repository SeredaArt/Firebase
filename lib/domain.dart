const kName = 'name';
const kPurchased = 'purchased';

class Item {
  final String name;
  late bool purchased;

  Item({required this.name, required this.purchased});

  factory Item.fromJson(Map<String, Object?> json) => Item(
        name: json[kName]! as String,
        purchased: json[kPurchased] as bool,
      );

  Map<String, Object?> toJson() => {kName:name, kPurchased:purchased};
}
