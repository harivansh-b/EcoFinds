class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final String description;
  final String image;
  final bool isOwned;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    required this.isOwned,
  });

  Product copyWith({
    int? id,
    String? title,
    String? category,
    double? price,
    String? description,
    String? image,
    bool? isOwned,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      isOwned: isOwned ?? this.isOwned,
    );
  }
}