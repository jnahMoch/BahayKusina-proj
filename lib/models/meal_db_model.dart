class MealDbModel {
  final int? id;
  final String title;
  final String type;
  final String vendor;
  final String desc;
  final int price;
  final int left;
  final String imageUrl;

  MealDbModel({
    this.id,
    required this.title,
    required this.type,
    required this.vendor,
    required this.desc,
    required this.price,
    required this.left,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'vendor': vendor,
      'desc': desc,
      'price': price,
      'left': left,
      'imageUrl': imageUrl,
    };
  }

  factory MealDbModel.fromMap(Map<String, dynamic> map) {
    return MealDbModel(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      vendor: map['vendor'],
      desc: map['desc'],
      price: map['price'],
      left: map['left'],
      imageUrl: map['imageUrl'],
    );
  }
}
