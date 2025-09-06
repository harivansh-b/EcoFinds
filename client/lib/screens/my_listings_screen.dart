import 'package:flutter/material.dart';
import '../models/product.dart';

// EcoFinds Color Palette
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

class MyListingsScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onEdit;
  final Function(Product) onDelete;
  final VoidCallback onAddNew;

  const MyListingsScreen({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onAddNew,
  });

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  String sortBy = 'recent'; // recent, price_low, price_high, name
  bool isListView = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Product> sortedProducts = _getSortedProducts();

    return Theme(
      data: _buildEcoTheme(),
      child: Scaffold(
        backgroundColor: EcoColors.backgroundWhite,
        body: CustomScrollView(
          slivers: [
            _buildEcoAppBar(),
            if (widget.products.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeaderSection(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildProductsList(sortedProducts),
                ),
              ),
            ] else
              SliverFillRemaining(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildEmptyState(),
                ),
              ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabScaleAnimation,
          child: _buildEcoFAB(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
    );
  }

  Widget _buildEcoAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: EcoColors.primaryGreen,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              EcoColors.primaryGreen,
              EcoColors.secondaryGreen,
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'My EcoListings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showSortOptions,
          icon: const Icon(Icons.sort, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              isListView = !isListView;
            });
          },
          icon: Icon(
            isListView ? Icons.grid_view : Icons.view_list,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          color: EcoColors.accentGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EcoColors.leafGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.products.length} Eco Items',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: EcoColors.textDark,
                      ),
                    ),
                    const Text(
                      'Making a difference, one item at a time',
                      style: TextStyle(
                        fontSize: 14,
                        color: EcoColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Total Value',
                '\$${_getTotalValue().toStringAsFixed(0)}',
                Icons.attach_money,
                EcoColors.secondaryGreen,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Categories',
                '${_getUniqueCategories()}',
                Icons.category,
                EcoColors.leafGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: EcoColors.textLight,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: EcoColors.accentGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              size: 80,
              color: EcoColors.accentGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start Your Eco Journey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: EcoColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No eco-listings yet!\nShare your sustainable items and help build a greener community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: EcoColors.textLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: EcoColors.secondaryGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onAddNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'Add First Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> products) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: isListView ? _buildListView(products) : _buildGridView(products),
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          child: _buildProductListTile(products[index], index),
        );
      },
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          child: _buildProductGridTile(products[index]),
        );
      },
    );
  }

  Widget _buildProductListTile(Product product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showProductDetails(product),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            EcoColors.accentGreen.withOpacity(0.2),
                            EcoColors.leafGreen.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.eco,
                              color: EcoColors.accentGreen,
                              size: 30,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              Icons.verified,
                              color: EcoColors.leafGreen,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: EcoColors.accentGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              color: EcoColors.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: EcoColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: EcoColors.secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildActionButton(
                        Icons.edit_outlined,
                        EcoColors.leafGreen,
                        () => widget.onEdit(product),
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        Icons.delete_outline,
                        EcoColors.errorRed,
                        () => _showDeleteConfirmation(context, product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGridTile(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showProductDetails(product),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          EcoColors.accentGreen.withOpacity(0.2),
                          EcoColors.leafGreen.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: const Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.eco,
                            color: EcoColors.accentGreen,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.verified,
                            color: EcoColors.leafGreen,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: EcoColors.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: EcoColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: EcoColors.secondaryGreen,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _buildSmallActionButton(
                                  Icons.edit_outlined,
                                  EcoColors.leafGreen,
                                  () => widget.onEdit(product),
                                ),
                                const SizedBox(width: 4),
                                _buildSmallActionButton(
                                  Icons.delete_outline,
                                  EcoColors.errorRed,
                                  () => _showDeleteConfirmation(context, product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildSmallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildEcoFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: EcoColors.secondaryGreen.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: widget.onAddNew,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Eco Item',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: EcoColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: EcoColors.secondaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: EcoColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EcoColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: EcoColors.errorRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Eco Item',
                style: TextStyle(
                  color: EcoColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${product.title}"? This action cannot be undone.',
            style: const TextStyle(
              color: EcoColors.textLight,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: EcoColors.textLight),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: EcoColors.errorRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDelete(product);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
              ),
            ),
            _buildSortOption('Recent', 'recent', Icons.schedule),
            _buildSortOption('Price: Low to High', 'price_low', Icons.trending_up),
            _buildSortOption('Price: High to Low', 'price_high', Icons.trending_down),
            _buildSortOption('Name', 'name', Icons.sort_by_alpha),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    bool isSelected = sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? EcoColors.primaryGreen : EcoColors.textLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? EcoColors.primaryGreen : EcoColors.textDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: EcoColors.primaryGreen)
          : null,
      onTap: () {
        setState(() {
          sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  List<Product> _getSortedProducts() {
    List<Product> sorted = List.from(widget.products);
    
    switch (sortBy) {
      case 'price_low':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'recent':
      default:
        sorted.sort((a, b) => b.id.compareTo(a.id)); // Assuming higher ID = more recent
        break;
    }
    
    return sorted;
  }

  double _getTotalValue() {
    return widget.products.fold(0.0, (sum, product) => sum + product.price);
  }

  int _getUniqueCategories() {
    return widget.products.map((p) => p.category).toSet().length;
  }
}