class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final String description;
  final String image;
  final bool isOwned;
  final String? status;
  final DateTime? createdAt;
  final DateTime? lastUpdated;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    required this.isOwned,
    this.status,
    this.createdAt,
    this.lastUpdated,
  });

  Product copyWith({
    int? id,
    String? title,
    String? category,
    double? price,
    String? description,
    String? image,
    bool? isOwned,
    String? status,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      isOwned: isOwned ?? this.isOwned,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // JSON serialization (useful for API calls and local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'description': description,
      'image': image,
      'isOwned': isOwned,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // JSON deserialization
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      image: json['image'] as String,
      isOwned: json['isOwned'] as bool,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : null,
    );
  }

  // Equality and hashCode for better object comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ToString for debugging
  @override
  String toString() {
    return 'Product(id: $id, title: $title, category: $category, price: $price, isOwned: $isOwned)';
  }

  // Useful getters
  bool get isNew => createdAt != null && 
      DateTime.now().difference(createdAt!).inDays <= 7;

  bool get isRecentlyUpdated => lastUpdated != null && 
      DateTime.now().difference(lastUpdated!).inHours <= 24;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get capitalizedCategory => 
      category.isNotEmpty 
          ? '${category[0].toUpperCase()}${category.substring(1).toLowerCase()}'
          : category;
}

// Optional: Enum for product status for better type safety
enum ProductStatus {
  active('Active'),
  sold('Sold'),
  pending('Pending'),
  inactive('Inactive');

  const ProductStatus(this.displayName);
  final String displayName;
}