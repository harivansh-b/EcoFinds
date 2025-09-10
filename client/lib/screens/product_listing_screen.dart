import 'package:flutter/material.dart';
import '../models/product.dart';

import 'package:eco_finds/env.dart';

final String myurl = ApiConfig.baseUrl;

// EcoFinds Color Palette
class EcoColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);
  static const Color earthBrown = Color(0xFF5D4037);
  static const Color warmBeige = Color(0xFFF1F8E9);
  static const Color leafGreen = Color(0xFF66BB6A);
  static const Color skyBlue = Color(0xFF03DAC6);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF1B5E20);
  static const Color textLight = Color(0xFF757575);
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
  String sortBy = 'relevance';
  double maxDistance = 50;
  double selectedDistance = 50;
  String dateFilter = 'all';
  
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
    
    final now = DateTime.now();
    final productDate = now.subtract(Duration(days: product.id % 365));
    
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
    double productDistance = (product.id % 100).toDouble();
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
        products.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'date_old':
        products.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'distance':
        products.sort((a, b) => (a.id % 100).compareTo(b.id % 100));
        break;
      default:
        break;
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    List<Product> filteredProducts = widget.products.where((product) {
      bool matchesSearch = product.title.toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = selectedCategory == 'All' || product.category == selectedCategory;
      bool matchesPrice = product.price >= priceRange.start && product.price <= priceRange.end;
      bool matchesDate = _matchesDateFilter(product);
      bool matchesDistance = _matchesDistanceFilter(product);
      
      return matchesSearch && matchesCategory && matchesPrice && matchesDate && matchesDistance;
    }).toList();

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
                child: _buildProductGrid(filteredProducts, isSmallScreen),
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
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoFinds',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Sustainable Marketplace',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
                        const Flexible(
                          child: Text(
                            'Advanced Filters',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: EcoColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                              '₹${priceRange.start.round()}',
                              '₹${priceRange.end.round()}',
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
                                '₹${priceRange.start.round()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EcoColors.textLight,
                                ),
                              ),
                              Text(
                                '₹${priceRange.end.round()}',
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildDateChip('All', 'all'),
                            const SizedBox(width: 8),
                            _buildDateChip('Today', 'today'),
                            const SizedBox(width: 8),
                            _buildDateChip('This Week', 'week'),
                            const SizedBox(width: 8),
                            _buildDateChip('This Month', 'month'),
                            const SizedBox(width: 8),
                            _buildDateChip('This Year', 'year'),
                          ],
                        ),
                      ),
                    ),
                    
                    // Sort By
                    _buildFilterSection(
                      'Sort By',
                      Icons.sort,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortChip('Relevance', 'relevance'),
                            const SizedBox(width: 8),
                            _buildSortChip('Price: Low ↑', 'price_low'),
                            const SizedBox(width: 8),
                            _buildSortChip('Price: High ↓', 'price_high'),
                            const SizedBox(width: 8),
                            _buildSortChip('Newest', 'date_new'),
                            const SizedBox(width: 8),
                            _buildSortChip('Oldest', 'date_old'),
                            const SizedBox(width: 8),
                            _buildSortChip('Distance', 'distance'),
                          ],
                        ),
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
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: EcoColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
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
          overflow: TextOverflow.ellipsis,
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
          overflow: TextOverflow.ellipsis,
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
                        Flexible(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : EcoColors.textDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
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
          Flexible(
            child: Container(
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
                  Flexible(
                    child: Text(
                      'Verified Eco',
                      style: TextStyle(
                        color: EcoColors.leafGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
            const SizedBox(width: 8),
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

  Widget _buildProductGrid(List<Product> filteredProducts, bool isSmallScreen) {
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
              textAlign: TextAlign.center,
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
          crossAxisCount: isGridView ? (isSmallScreen ? 1 : 2) : 1,
          childAspectRatio: isGridView 
              ? (isSmallScreen ? 1.2 : 0.85) 
              : (isSmallScreen ? 3.5 : 2.5),
          crossAxisSpacing: isSmallScreen ? 8 : 12,
          mainAxisSpacing: isSmallScreen ? 8 : 12,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          Product product = filteredProducts[index];
          return _buildProductCard(product, index, isSmallScreen);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, int index, bool isSmallScreen) {
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
          child: isGridView 
              ? _buildGridCard(product, mockImages, isSmallScreen) 
              : _buildListCard(product, mockImages, isSmallScreen),
        ),
      ),
    );
  }

Widget _buildGridCard(Product product, List<String> images, bool isSmallScreen) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,
        child: _buildImageCarousel(images, product, isCompact: true),
      ),
      // Changed to Container with fixed constraints instead of Expanded
      Container(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: EcoColors.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: EcoColors.primaryGreen,
                        fontSize: isSmallScreen ? 7 : 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: EcoColors.skyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: isSmallScreen ? 6 : 8, color: EcoColors.skyBlue),
                      Text(
                        '${(product.id % 100)} km',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 6 : 7,
                          color: EcoColors.skyBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            // Product Title - Now with guaranteed space
            Text(
              product.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 13,
                color: EcoColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: EcoColors.secondaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${DateTime.now().subtract(Duration(days: product.id % 30)).day}d ago',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 7 : 8,
                          color: EcoColors.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!product.isOwned)
                  GestureDetector(
                    onTap: () => widget.onAddToCart(product),
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                      decoration: BoxDecoration(
                        color: EcoColors.secondaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildListCard(Product product, List<String> images, bool isSmallScreen) {
  return Row(
    children: [
      SizedBox(
        width: isSmallScreen ? 80 : 120,
        height: double.infinity,
        child: _buildImageCarousel(images, product, isCompact: false),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoColors.accentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          color: EcoColors.primaryGreen,
                          fontSize: isSmallScreen ? 7 : 9,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoColors.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: isSmallScreen ? 8 : 10, color: EcoColors.skyBlue),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${(product.id % 100)} km away',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 6 : 8,
                                color: EcoColors.skyBlue,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (product.isOwned) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: EcoColors.earthBrown,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'OWNED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 6 : 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Product Title - This was already present but ensuring it's visible
              Text(
                product.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
                  color: EcoColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isSmallScreen) ...[
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
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: EcoColors.secondaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Added ${DateTime.now().subtract(Duration(days: product.id % 30)).day} days ago',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 7 : 9,
                            color: EcoColors.textLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!product.isOwned)
                    GestureDetector(
                      onTap: () => widget.onAddToCart(product),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12, 
                          vertical: isSmallScreen ? 4 : 6
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [EcoColors.secondaryGreen, EcoColors.leafGreen],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 9 : 11,
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

// Also update the image carousel to remove the title overlay since it should be in the card
Widget _buildImageCarousel(List<String> images, Product product, {required bool isCompact}) {
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
          Container(
            width: double.infinity,
            height: double.infinity,
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
                  const SizedBox(height: 4),
                  Text(
                    'Eco Product',
                    style: TextStyle(
                      fontSize: isCompact ? 8 : 10,
                      color: EcoColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
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