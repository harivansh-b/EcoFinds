import 'package:flutter/material.dart';
import '../models/product.dart';

// EcoFinds Color Palette (matching MainScreen)
class EcoColors {
  static const Color primaryGreen = Color(0xFF2E7D32);      // Deep forest green
  static const Color secondaryGreen = Color(0xFF4CAF50);    // Fresh green
  static const Color accentGreen = Color(0xFF81C784);       // Light green
  static const Color earthBrown = Color(0xFF5D4037);        // Earth brown
  static const Color warmBeige = Color(0xFFF1F8E9);         // Warm beige
  static const Color leafGreen = Color(0xFF66BB6A);         // Leaf green
  static const Color skyBlue = Color(0xFF03DAC6);           // Eco teal
  static const Color backgroundWhite = Color(0xFFFAFAFA);   // Soft white
  static const Color textDark = Color(0xFF1B5E20);          // Dark green text
  static const Color textLight = Color(0xFF757575);         // Light grey text
  static const Color cardBackground = Colors.white;
  static const Color errorRed = Color(0xFFE53935);
}

class PreviousPurchasesScreen extends StatelessWidget {
  final List<Product> purchases;

  const PreviousPurchasesScreen({
    super.key,
    required this.purchases,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Purchase History',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: EcoColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: purchases.isEmpty
          ? _buildEmptyState()
          : _buildPurchasesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: EcoColors.warmBeige,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_outlined,
              size: 64,
              color: EcoColors.primaryGreen.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Purchase History Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: EcoColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Start exploring eco-friendly products and your purchases will appear here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: EcoColors.textLight,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate back to explore tab
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.eco, size: 20),
            label: const Text('Start Exploring'),
            style: ElevatedButton.styleFrom(
              backgroundColor: EcoColors.secondaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesList() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EcoColors.primaryGreen.withOpacity(0.1),
                  EcoColors.warmBeige,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: EcoColors.primaryGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EcoColors.secondaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: EcoColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${purchases.length} Eco-Friendly Purchase${purchases.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: EcoColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thank you for choosing sustainable options!',
                        style: TextStyle(
                          fontSize: 14,
                          color: EcoColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.eco,
                  color: EcoColors.leafGreen,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              Product product = purchases[index];
              return _buildPurchaseCard(product, index);
            },
            childCount: purchases.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildPurchaseCard(Product product, int index) {
    final purchaseDate = DateTime.now().subtract(Duration(days: index * 5));
    final daysSince = DateTime.now().difference(purchaseDate).inDays;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 3,
        shadowColor: EcoColors.primaryGreen.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                EcoColors.cardBackground,
                EcoColors.warmBeige.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: EcoColors.warmBeige,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: EcoColors.primaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.image.isNotEmpty
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.eco_outlined,
                                color: EcoColors.primaryGreen.withOpacity(0.7),
                                size: 32,
                              );
                            },
                          )
                        : Icon(
                            Icons.eco_outlined,
                            color: EcoColors.primaryGreen.withOpacity(0.7),
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: EcoColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: EcoColors.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: EcoColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 16,
                            color: EcoColors.earthBrown,
                          ),
                          Text(
                            '${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: EcoColors.earthBrown,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: EcoColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatPurchaseDate(purchaseDate, daysSince),
                            style: TextStyle(
                              fontSize: 12,
                              color: EcoColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EcoColors.leafGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: EcoColors.leafGreen,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPurchaseDate(DateTime date, int daysSince) {
    if (daysSince == 0) {
      return 'Today';
    } else if (daysSince == 1) {
      return 'Yesterday';
    } else if (daysSince < 7) {
      return '$daysSince days ago';
    } else if (daysSince < 30) {
      final weeks = (daysSince / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}