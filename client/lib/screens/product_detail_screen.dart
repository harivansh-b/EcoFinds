import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart'; // Ensure this path is correct

import 'package:eco_finds/env.dart';

final String myurl = ApiConfig.baseUrl;

// EcoFinds Color Palette
class EcoColors {
  static const Color primaryGreen = Color(0xFF2E7D32); // Deep forest green
  static const Color secondaryGreen = Color(0xFF4CAF50); // Fresh green
  static const Color accentGreen = Color(0xFF81C784); // Light green
  static const Color earthBrown = Color(0xFF5D4037); // Earth brown
  static const Color warmBeige = Color(0xFFF1F8E9); // Warm beige
  static const Color leafGreen = Color(0xFF66BB6A); // Leaf green
  static const Color skyBlue = Color(0xFF03DAC6); // Eco teal (unused in this screen, but good to keep)
  static const Color backgroundWhite = Color(0xFFFAFAFA); // Soft white
  static const Color textDark = Color(0xFF1B5E20); // Dark green text
  static const Color textLight = Color(0xFF757575); // Light grey text
  static const Color cardBackground = Colors.white;
  static const Color errorRed = Color(0xFFE53935);
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildEcoTheme(),
      child: Scaffold(
        backgroundColor: EcoColors.backgroundWhite,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildProductContent(),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  ThemeData _buildEcoTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: EcoColors.primaryGreen,
      scaffoldBackgroundColor: EcoColors.backgroundWhite,
      colorScheme: const ColorScheme.light(
        primary: EcoColors.primaryGreen,
        secondary: EcoColors.secondaryGreen,
        surface: EcoColors.cardBackground,
        background: EcoColors.backgroundWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: EcoColors.textDark,
        onBackground: EcoColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: EcoColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: EcoColors.backgroundWhite,
      foregroundColor: EcoColors.textDark,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: EcoColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? EcoColors.errorRed : EcoColors.textDark,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                EcoColors.warmBeige.withOpacity(0.8),
                EcoColors.backgroundWhite,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                child: Hero(
                  tag: 'product-${widget.product.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: EcoColors.primaryGreen.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: EcoColors.primaryGreen,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                EcoColors.accentGreen.withOpacity(0.1),
                                EcoColors.leafGreen.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: EcoColors.accentGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Eco badge if applicable
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: EcoColors.leafGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ECO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product title and category
          _buildProductHeader(),
          const SizedBox(height: 20),

          // Price section
          _buildPriceSection(),
          const SizedBox(height: 24),

          // All Product Properties Section
          _buildAllProductProperties(),
          const SizedBox(height: 24),

          // Features section
          _buildFeaturesSection(),
          const SizedBox(height: 24),

          // Description section
          _buildDescriptionSection(),
          const SizedBox(height: 24),

          // Sustainability info
          _buildSustainabilitySection(),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: EcoColors.accentGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.product.category.toUpperCase(),
            style: const TextStyle(
              color: EcoColors.primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: EcoColors.textDark,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EcoColors.secondaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.attach_money,
              color: EcoColors.secondaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Price',
                style: TextStyle(
                  color: EcoColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.product.formattedPrice,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.secondaryGreen,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (widget.product.category.toLowerCase() == 'fair trade')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: EcoColors.leafGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Fair Trade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Complete Product Properties Display
  Widget _buildAllProductProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Information Card
        _buildInfoCard(
          title: 'Product Information',
          icon: Icons.info_outline,
          children: [
            _buildInfoRow('Product ID', widget.product.id.toString()),
            _buildInfoRow('Title', widget.product.title),
            _buildInfoRow('Category', widget.product.capitalizedCategory),
            _buildInfoRow('Raw Price', '\$${widget.product.price}'),
            _buildInfoRow('Formatted Price', widget.product.formattedPrice),
            _buildInfoRow('Ownership Status', widget.product.isOwned ? 'Owned' : 'Not Owned'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Status and Timeline Card
        _buildInfoCard(
          title: 'Status & Timeline',
          icon: Icons.schedule,
          children: [
            if (widget.product.status != null)
              _buildInfoRow('Status', widget.product.status!)
            else
              _buildInfoRow('Status', 'Not Set', isNull: true),
              
            if (widget.product.createdAt != null)
              _buildInfoRow('Created At', _formatDateTime(widget.product.createdAt!))
            else
              _buildInfoRow('Created At', 'Not Set', isNull: true),
              
            if (widget.product.lastUpdated != null)
              _buildInfoRow('Last Updated', _formatDateTime(widget.product.lastUpdated!))
            else
              _buildInfoRow('Last Updated', 'Not Set', isNull: true),
              
            // Computed Properties
            _buildInfoRow('Is New Product', widget.product.isNew ? 'Yes (≤7 days)' : 'No'),
            _buildInfoRow('Recently Updated', widget.product.isRecentlyUpdated ? 'Yes (≤24 hrs)' : 'No'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Technical Details Card
        _buildInfoCard(
          title: 'Technical Details',
          icon: Icons.settings,
          children: [
            _buildInfoRow('Hash Code', widget.product.hashCode.toString()),
            _buildInfoRow('Image URL', widget.product.image, isUrl: true),
            _buildInfoRow('Object String', widget.product.toString(), isCode: true),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: EcoColors.accentGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EcoColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: EcoColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUrl = false, bool isCode = false, bool isNull = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: EcoColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isUrl || isCode ? () => _copyToClipboard(value) : null,
              child: Container(
                padding: isUrl || isCode ? const EdgeInsets.all(8) : EdgeInsets.zero,
                decoration: isUrl || isCode
                    ? BoxDecoration(
                        color: EcoColors.warmBeige.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isNull 
                        ? EcoColors.textLight 
                        : isUrl || isCode 
                            ? EcoColors.primaryGreen 
                            : EcoColors.textLight,
                    fontStyle: isNull ? FontStyle.italic : FontStyle.normal,
                    fontFamily: isCode ? 'monospace' : null,
                  ),
                  softWrap: true,
                ),
              ),
            ),
          ),
          if (isUrl || isCode)
            const Icon(
              Icons.copy,
              size: 16,
              color: EcoColors.accentGreen,
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: EcoColors.primaryGreen,
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {'icon': Icons.verified, 'text': 'Verified Quality'},
      {'icon': Icons.local_shipping, 'text': 'Free Eco Shipping'},
      {'icon': Icons.replay, 'text': '30-Day Returns'},
      {'icon': Icons.support_agent, 'text': '24/7 Support'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: EcoColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EcoColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: EcoColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feature['text'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: EcoColors.textDark,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EcoColors.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description,
                color: EcoColors.primaryGreen,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: const TextStyle(
              fontSize: 16,
              color: EcoColors.textLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EcoColors.leafGreen.withOpacity(0.1),
            EcoColors.accentGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EcoColors.leafGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco,
                color: EcoColors.leafGreen,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Sustainability Impact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.nature, color: EcoColors.leafGreen, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reduces waste by extending product life',
                  style: TextStyle(fontSize: 14, color: EcoColors.textLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.recycling, color: EcoColors.leafGreen, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Promotes circular economy',
                  style: TextStyle(fontSize: 14, color: EcoColors.textLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.energy_savings_leaf, color: EcoColors.leafGreen, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Carbon footprint reduction',
                  style: TextStyle(fontSize: 14, color: EcoColors.textLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (widget.product.isOwned) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: EcoColors.earthBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: EcoColors.earthBrown.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    color: EcoColors.earthBrown,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'You own this item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: EcoColors.earthBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: EcoColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: EcoColors.primaryGreen.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  _showShareBottomSheet(context);
                },
                icon: const Icon(
                  Icons.share_outlined,
                  color: EcoColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: EcoColors.secondaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onAddToCart(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.title} added to cart!'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: EcoColors.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: EcoColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Share ${widget.product.title}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Share options
              Wrap(
                spacing: 24,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildShareOption(Icons.facebook, 'Facebook', () {
                    Navigator.pop(context);
                    _shareToSocialMedia('facebook');
                  }),
                  _buildShareOption(Icons.message, 'WhatsApp', () {
                    Navigator.pop(context);
                    _shareToSocialMedia('whatsapp');
                  }),
                  _buildShareOption(Icons.copy, 'Copy Link', () {
                    _copyToClipboard('https://ecofinds.com/product/${widget.product.id}');
                    Navigator.pop(context);
                  }),
                  _buildShareOption(Icons.email, 'Email', () {
                    Navigator.pop(context);
                    _shareViaEmail();
                  }),
                  _buildShareOption(Icons.share, 'More', () {
                    Navigator.pop(context);
                    _shareGeneric();
                  }),
                ],
              ),
              const SizedBox(height: 20),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: EcoColors.textLight,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Safe area padding
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: EcoColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: EcoColors.primaryGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon, 
              color: EcoColors.primaryGreen, 
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, 
            color: EcoColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _shareToSocialMedia(String platform) {
    final productUrl = 'https://ecofinds.com/product/${widget.product.id}';
    final shareText = 'Check out this eco-friendly product: ${widget.product.title} - ${widget.product.formattedPrice}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $platform to share product...'),
        duration: const Duration(seconds: 2),
        backgroundColor: EcoColors.primaryGreen,
      ),
    );
    
    // Here you would implement actual social media sharing
    // using packages like share_plus or url_launcher
    _copyToClipboard('$shareText\n$productUrl');
  }

  void _shareViaEmail() {
    final subject = 'Check out this eco-friendly product: ${widget.product.title}';
    final body = '''
Hi there!

I found this amazing eco-friendly product that I thought you might be interested in:

${widget.product.title}
Category: ${widget.product.capitalizedCategory}
Price: ${widget.product.formattedPrice}

${widget.product.description}

Check it out here: https://ecofinds.com/product/${widget.product.id}

Best regards!
    ''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email content copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: EcoColors.primaryGreen,
      ),
    );
    
    _copyToClipboard('Subject: $subject\n\n$body');
  }

  void _shareGeneric() {
    final shareText = '''
Check out this eco-friendly product: ${widget.product.title}

${widget.product.description}

Price: ${widget.product.formattedPrice}
Category: ${widget.product.capitalizedCategory}

View more: https://ecofinds.com/product/${widget.product.id}

#EcoFriendly #Sustainable #GreenLiving
    ''';
    
    _copyToClipboard(shareText);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product details copied to clipboard!'),
        duration: Duration(seconds: 2),
        backgroundColor: EcoColors.primaryGreen,
      ),
    );
  }
}