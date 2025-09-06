import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
// Update this with your actual API URL
  static String baseUrl = "http://127.0.0.1:8000";
  static String apiKey = "auth_api@12!_23";
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'x-api-key': apiKey,
  };

  // Create a new product
  static Future<Product> createProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/product/createproduct'),
        headers: headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to create product: ${error['detail']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update an existing product
  static Future<Product> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/product/updateproduct/$productId'),
        headers: headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to update product: ${error['detail']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete a product
  static Future<bool> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/product/deleteproduct/$productId'),
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to delete product: ${error['detail']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get products for a user
  static Future<List<Product>> getUserProducts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/getproducts/$userId'),
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List;
        return products.map((json) => Product.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to get products: ${error['detail']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get a single product
  static Future<Product> getProduct(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/getproduct/$productId'),
        headers: {
          'x-api-key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to get product: ${error['detail']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Placeholder methods for web compatibility
  static Future<String> uploadImage(dynamic imageFile) async {
    // For web, you'll need to implement this differently
    // This is a placeholder that returns a mock image ID
    await Future.delayed(Duration(milliseconds: 500));
    return 'mock_image_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String getImageUrl(String fileId) {
    return 'https://via.placeholder.com/200?text=Image';
  }

  static Future<bool> deleteImage(String fileId) async {
    await Future.delayed(Duration(milliseconds: 200));
    return true;
  }
}