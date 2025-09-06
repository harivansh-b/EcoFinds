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

class ProductListingScreen extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;
  final Function(Product) onProductTap;

  const ProductListingScreen({
    super.key,
    required this.products,
    required this.onAddToCart,
    required this.onProductTap,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen>
    with TickerProviderStateMixin {
  String searchQuery = '';
  String selectedCategory = 'All';
  bool isGridView = true;
  bool showAdvancedFilters = false;
  
  // Advanced filter variables
  RangeValues priceRange = const RangeValues(0, 1000);
  double maxPrice = 1000;
  String sortBy = 'relevance'; // relevance, price_low, price_high, date_new, date_old, distance
  double maxDistance = 50; // in km
  double selectedDistance = 50;
  String dateFilter = 'all'; // all, today, week, month, year
  
  late AnimationController _animationController;
  late AnimationController _searchController;
  late AnimationController _filterController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _filterSlideAnimation;

  List<String> categories = [
    'All', 
    'Electronics', 
    'Fashion', 
    'Furniture',
    'Home & Garden',
    'Books',
    'Sports'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _filterSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeInOut,
    ));

    // Calculate max price from products
    if (widget.products.isNotEmpty) {
      maxPrice = widget.products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
      priceRange = RangeValues(0, maxPrice);
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _toggleAdvancedFilters() {
    setState(() {
      showAdvancedFilters = !showAdvancedFilters;
    });
    if (showAdvancedFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
  }

  bool _matchesDateFilter(Product product) {
    if (dateFilter == 'all') return true;
    
    // Mock date logic - replace with actual product date
    final now = DateTime.now();
    final productDate = now.subtract(Duration(days: product.id % 365)); // Mock date based on ID
    
    switch (dateFilter) {
      case 'today':
        return productDate.isAfter(now.subtract(const Duration(days: 1)));
      case 'week':
        return productDate.isAfter(now.subtract(const Duration(days: 7)));
      case 'month':
        return productDate.isAfter(now.subtract(const Duration(days: 30)));
      case 'year':
        return productDate.isAfter(now.subtract(const Duration(days: 365)));
      default:
        return true;
    }
  }

  bool _matchesDistanceFilter(Product product) {
    // Mock distance logic - replace with actual geolocation calculation
    double productDistance = (product.id % 100).toDouble(); // Mock distance based on ID
    return productDistance <= selectedDistance;
  }

  List<Product> _sortProducts(List<Product> products) {
    switch (sortBy) {
      case 'price_low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'date_new':
        // Mock date sorting - replace with actual date comparison
        products.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'date_old':
        // Mock date sorting - replace with actual date comparison
        products.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'distance':
        // Mock distance sorting - replace with actual distance calculation
        products.sort((a, b) => (a.id % 100).compareTo(b.id % 100));
        break;
      default: // relevance
        // Keep original order or implement relevance logic
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = widget.products.where((product) {
      bool matchesSearch = product.title.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
      bool matchesPrice = product.price >= priceRange.start && product.price <= priceRange.end;
      bool matchesDate = _matchesDateFilter(product);
      bool matchesDistance = _matchesDistanceFilter(product);
      
      return matchesSearch && matchesCategory && matchesPrice && matchesDate && matchesDistance;
    }).toList();

    // Apply sorting
    filteredProducts = _sortProducts(filteredProducts);

    return Theme(
      data: _buildEcoTheme(),
      child: Scaffold(
        backgroundColor: EcoColors.backgroundWhite,
        body: CustomScrollView(
          slivers: [
            _buildEcoAppBar(),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildSearchSection(),
                      _buildCategoryFilter(),
                      _buildViewToggle(),
                      _buildAdvancedFilters(),
                      _buildStatsRow(filteredProducts.length),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildProductGrid(filteredProducts),
              ),
            ),
          ],
        ),
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
      floating: true,
      snap: true,
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
              Icons.eco,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EcoFinds',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Sustainable Marketplace',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: EcoColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search eco-friendly products...',
          hintStyle: const TextStyle(color: EcoColors.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: EcoColors.primaryGreen, size: 20),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear, color: EcoColors.textLight, size: 18),
                )
              : IconButton(
                  onPressed: _toggleAdvancedFilters,
                  icon: Icon(
                    showAdvancedFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: showAdvancedFilters ? EcoColors.primaryGreen : EcoColors.leafGreen,
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: showAdvancedFilters ? null : 0,
      child: showAdvancedFilters
          ? FadeTransition(
              opacity: _filterSlideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: EcoColors.primaryGreen.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune, color: EcoColors.primaryGreen, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Advanced Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: EcoColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              priceRange = RangeValues(0, maxPrice);
                              selectedDistance = maxDistance;
                              dateFilter = 'all';
                              sortBy = 'relevance';
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: EcoColors.primaryGreen,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Price Range Filter
                    _buildFilterSection(
                      'Price Range',
                      Icons.attach_money,
                      Column(
                        children: [
                          RangeSlider(
                            values: priceRange,
                            max: maxPrice,
                            divisions: 20,
                            activeColor: EcoColors.secondaryGreen,
                            inactiveColor: EcoColors.accentGreen.withOpacity(0.3),
                            labels: RangeLabels(
                              '\$${priceRange.start.round()}',
                              '\$${priceRange.end.round()}',
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${priceRange.start.round()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EcoColors.textLight,
                                ),
                              ),
                              Text(
                                '\$${priceRange.end.round()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EcoColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Distance Filter
                    _buildFilterSection(
                      'Distance',
                      Icons.location_on,
                      Column(
                        children: [
                          Slider(
                            value: selectedDistance,
                            max: maxDistance,
                            divisions: 10,
                            activeColor: EcoColors.secondaryGreen,
                            inactiveColor: EcoColors.accentGreen.withOpacity(0.3),
                            label: '${selectedDistance.round()} km',
                            onChanged: (double value) {
                              setState(() {
                                selectedDistance = value;
                              });
                            },
                          ),
                          Text(
                            'Within ${selectedDistance.round()} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: EcoColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Date Filter
                    _buildFilterSection(
                      'Date Added',
                      Icons.calendar_today,
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildDateChip('All', 'all'),
                          _buildDateChip('Today', 'today'),
                          _buildDateChip('This Week', 'week'),
                          _buildDateChip('This Month', 'month'),
                          _buildDateChip('This Year', 'year'),
                        ],
                      ),
                    ),
                    
                    // Sort By
                    _buildFilterSection(
                      'Sort By',
                      Icons.sort,
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSortChip('Relevance', 'relevance'),
                          _buildSortChip('Price: Low to High', 'price_low'),
                          _buildSortChip('Price: High to Low', 'price_high'),
                          _buildSortChip('Newest First', 'date_new'),
                          _buildSortChip('Oldest First', 'date_old'),
                          _buildSortChip('Distance', 'distance'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: EcoColors.primaryGreen, size: 14),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: EcoColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateChip(String label, String value) {
    bool isSelected = dateFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          dateFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? EcoColors.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? EcoColors.primaryGreen : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : EcoColors.textDark,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    bool isSelected = sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          sortBy = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? EcoColors.leafGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? EcoColors.leafGreen : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : EcoColors.textDark,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 45,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          bool isSelected = category == selectedCategory;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? EcoColors.secondaryGreen.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 6 : 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: isSelected ? Colors.white : EcoColors.primaryGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : EcoColors.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildViewToggleButton(Icons.grid_view, true),
                _buildViewToggleButton(Icons.view_list, false),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EcoColors.leafGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, color: EcoColors.leafGreen, size: 12),
                SizedBox(width: 3),
                Text(
                  'Verified Eco',
                  style: TextStyle(
                    color: EcoColors.leafGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isGrid) {
    bool isSelected = isGridView == isGrid;
    return GestureDetector(
      onTap: () {
        setState(() {
          isGridView = isGrid;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? EcoColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : EcoColors.textLight,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildStatsRow(int productCount) {
    String sortLabel = _getSortLabel();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '$productCount items',
            style: const TextStyle(
              color: EcoColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sortBy != 'relevance') ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: EcoColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sorted by $sortLabel',
                style: const TextStyle(
                  color: EcoColors.primaryGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: EcoColors.accentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: EcoColors.primaryGreen, size: 10),
                SizedBox(width: 2),
                Text(
                  'Trending',
                  style: TextStyle(
                    color: EcoColors.primaryGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (sortBy) {
      case 'price_low': return 'Price ↑';
      case 'price_high': return 'Price ↓';
      case 'date_new': return 'Newest';
      case 'date_old': return 'Oldest';
      case 'distance': return 'Distance';
      default: return 'Relevance';
    }
  }

  Widget _buildProductGrid(List<Product> filteredProducts) {
    if (filteredProducts.isEmpty) {
      return Container(
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: EcoColors.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No eco-friendly products found',
              style: TextStyle(
                fontSize: 16,
                color: EcoColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your filters or search criteria',
              style: TextStyle(
                fontSize: 12,
                color: EcoColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isGridView ? 2 : 1,
          childAspectRatio: isGridView ? 0.85 : 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          Product product = filteredProducts[index];
          return _buildProductCard(product, index);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    // Mock images for carousel - replace with product.images when available
    List<String> mockImages = [
      'https://via.placeholder.com/300x200/81C784/FFFFFF?text=Eco+Product+1',
      'https://via.placeholder.com/300x200/66BB6A/FFFFFF?text=Eco+Product+2',
      'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Eco+Product+3',
      'https://via.placeholder.com/300x200/2E7D32/FFFFFF?text=Eco+Product+4',
      'https://via.placeholder.com/300x200/1B5E20/FFFFFF?text=Eco+Product+5',
    ];

    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 30)),
      child: GestureDetector(
        onTap: () => widget.onProductTap(product),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: EcoColors.primaryGreen.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isGridView ? _buildGridCard(product, mockImages) : _buildListCard(product, mockImages),
        ),
      ),
    );
  }

  Widget _buildGridCard(Product product, List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildImageCarousel(images, isCompact: true),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoColors.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          color: EcoColors.primaryGreen,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Distance badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: EcoColors.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 8, color: EcoColors.skyBlue),
                          Text(
                            '${(product.id % 100)} km',
                            style: const TextStyle(
                              fontSize: 7,
                              color: EcoColors.skyBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: EcoColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: EcoColors.secondaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${DateTime.now().subtract(Duration(days: product.id % 30)).day}d ago',
                          style: const TextStyle(
                            fontSize: 8,
                            color: EcoColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!product.isOwned)
                      GestureDetector(
                        onTap: () => widget.onAddToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: EcoColors.secondaryGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(Product product, List<String> images) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: double.infinity,
          child: _buildImageCarousel(images, isCompact: false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoColors.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          color: EcoColors.primaryGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoColors.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 10, color: EcoColors.skyBlue),
                          const SizedBox(width: 2),
                          Text(
                            '${(product.id % 100)} km away',
                            style: const TextStyle(
                              fontSize: 8,
                              color: EcoColors.skyBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (product.isOwned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: EcoColors.earthBrown,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OWNED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
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
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: EcoColors.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: EcoColors.secondaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Added ${DateTime.now().subtract(Duration(days: product.id % 30)).day} days ago',
                          style: const TextStyle(
                            fontSize: 9,
                            color: EcoColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!product.isOwned)
                      GestureDetector(
                        onTap: () => widget.onAddToCart(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel(List<String> images, {required bool isCompact}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 14 : 12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EcoColors.accentGreen.withOpacity(0.1),
            EcoColors.leafGreen.withOpacity(0.1),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 14 : 12),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco,
                          size: isCompact ? 24 : 32,
                          color: EcoColors.accentGreen,
                        ),
                        if (!isCompact)
                          Text(
                            '${index + 1}/${images.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: EcoColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Verified eco badge
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: EcoColors.leafGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: isCompact ? 10 : 12,
                ),
              ),
            ),
            // Image indicator dots
            if (images.length > 1)
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return Container(
                      width: isCompact ? 4 : 6,
                      height: isCompact ? 4 : 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.eco;
      case 'electronics':
        return Icons.devices;
      case 'fashion':
        return Icons.checkroom;
      case 'furniture':
        return Icons.chair;
      case 'home & garden':
        return Icons.home_outlined;
      case 'books':
        return Icons.menu_book;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.category;
    }
  }
}