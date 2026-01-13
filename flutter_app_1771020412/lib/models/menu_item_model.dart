import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;
  final int preparationTime;
  final double rating;
  final List<String> ingredients;
  final bool isAvailable;
  // --- 2 TRƯỜNG MỚI ---
  final bool isVegetarian; // Món chay
  final bool isSpicy; // Món cay

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    required this.preparationTime,
    this.rating = 4.5,
    this.ingredients = const [],
    this.isAvailable = true,
    this.isVegetarian = false,
    this.isSpicy = false,
  });

  // Chuyển từ Firestore Document sang Object
  factory MenuItemModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Main Course',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      preparationTime: data['preparationTime'] ?? 15,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      isVegetarian: data['isVegetarian'] ?? false,
      isSpicy: data['isSpicy'] ?? false,
    );
  }

  // Chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'preparationTime': preparationTime,
      'rating': rating,
      'ingredients': ingredients,
      'isAvailable': isAvailable,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
    };
  }
}
