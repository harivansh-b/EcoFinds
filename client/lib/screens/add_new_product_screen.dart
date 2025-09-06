import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';

// EcoFinds Color Palette (reuse from MainScreen)
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
  static const Color successGreen = Color(0xFF43A047);
  static const Color orangeWarning = Color(0xFFFF9800);
  static const Color blueInfo = Color(0xFF2196F3);
}

class AddNewProductScreen extends StatefulWidget {
  final Function(Product) onProductAdded;
  final Product? product; // For editing existing product

  const AddNewProductScreen({
    super.key,
    required this.onProductAdded,
    this.product,
  });

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedCategory = 'Electronics';
  String _selectedStatus = 'Available';
  bool _isSubmitting = false;
  
  // Expanded eco-friendly categories
  final List<Map<String, dynamic>> categories = [
    {'name': 'Electronics', 'icon': Icons.devices, 'color': EcoColors.skyBlue},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': EcoColors.accentGreen},
    {'name': 'Furniture', 'icon': Icons.weekend, 'color': EcoColors.earthBrown},
    {'name': 'Books', 'icon': Icons.menu_book, 'color': EcoColors.leafGreen},
    {'name': 'Sports & Outdoors', 'icon': Icons.sports_soccer, 'color': EcoColors.secondaryGreen},
    {'name': 'Home & Garden', 'icon': Icons.home, 'color': EcoColors.primaryGreen},
  ];

  // Product status options
  final List<Map<String, dynamic>> statusOptions = [
    {'name': 'Available', 'icon': Icons.check_circle, 'color': EcoColors.successGreen, 'description': 'Ready for sale'},
    {'name': 'Reserved', 'icon': Icons.schedule, 'color': EcoColors.orangeWarning, 'description': 'Hold for buyer'},
    {'name': 'Sold', 'icon': Icons.sell, 'color': EcoColors.textLight, 'description': 'No longer available'},
    {'name': 'Draft', 'icon': Icons.edit_note, 'color': EcoColors.blueInfo, 'description': 'Not yet published'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
      // Assuming the Product model will have a status field
      _selectedStatus = widget.product!.status ?? 'Available';
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.product != null;
    
    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isEditing),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildForm(isEditing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isEditing) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: EcoColors.primaryGreen,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          isEditing ? 'Edit Your Item' : 'Add New Item',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EcoColors.primaryGreen,
                EcoColors.secondaryGreen,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 80,
                right: 20,
                child: Icon(
                  isEditing ? Icons.edit : Icons.add_circle_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.eco, color: Colors.white, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      isEditing ? 'Update your eco-listing' : 'Share something sustainable',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Product Title Section
            _buildSectionHeader('Item Details', Icons.info_outline),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _titleController,
              label: 'Product Title',
              hint: 'What are you sharing?',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product title';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Category Section
            _buildSectionHeader('Category', Icons.category_outlined),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 20),

            // Status Section
            _buildSectionHeader('Status', Icons.flag_outlined),
            const SizedBox(height: 16),
            _buildStatusSelector(),
            const SizedBox(height: 20),
            
            // Description
            _buildCustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Tell us about this item...',
              icon: Icons.description_outlined,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // Price Section
            _buildSectionHeader('Pricing', Icons.attach_money),
            const SizedBox(height: 16),
            _buildPriceField(),
            const SizedBox(height: 20),
            
            // Image Section
            _buildSectionHeader('Photos', Icons.photo_camera_outlined),
            const SizedBox(height: 16),
            _buildImageUploadCard(),
            const SizedBox(height: 40),
            
            // Submit Button
            _buildSubmitButton(isEditing),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: EcoColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: EcoColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: EcoColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: EcoColors.primaryGreen),
          labelStyle: const TextStyle(color: EcoColors.primaryGreen),
          hintStyle: TextStyle(color: EcoColors.textLight.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: EcoColors.primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: EcoColors.errorRed),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['name'];
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? category['color'] : EcoColors.warmBeige,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? category['color'] : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : EcoColors.textDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : EcoColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: statusOptions.map((status) {
          final isSelected = _selectedStatus == status['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status['name'];
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? status['color'].withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? status['color'] 
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: status['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      status['icon'],
                      size: 20,
                      color: status['color'],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status['name'],
                          style: TextStyle(
                            color: isSelected 
                                ? status['color'] 
                                : EcoColors.textDark,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status['description'],
                          style: TextStyle(
                            color: EcoColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: status['color'],
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: EcoColors.textDark, fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: 'Price',
          hintText: '0.00',
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '\$',
              style: TextStyle(
                color: EcoColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          labelStyle: const TextStyle(color: EcoColors.primaryGreen),
          hintStyle: TextStyle(color: EcoColors.textLight.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: EcoColors.primaryGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a price';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid price';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EcoColors.primaryGreen.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Image picker will be implemented soon!'),
                  ],
                ),
                backgroundColor: EcoColors.skyBlue,
              ),
            );
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 40,
                color: EcoColors.primaryGreen,
              ),
              SizedBox(height: 8),
              Text(
                'Add Photos',
                style: TextStyle(
                  color: EcoColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap to add up to 5 photos',
                style: TextStyle(
                  color: EcoColors.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: EcoColors.secondaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: EcoColors.secondaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...', style: TextStyle(fontSize: 16)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEditing ? Icons.update : Icons.eco,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Update Listing' : 'List Item',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));

      Product newProduct = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        image: "https://via.placeholder.com/200",
        isOwned: true,
        status: _selectedStatus, // Add status to the product
      );
      
      widget.onProductAdded(newProduct);
      
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.eco, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.product != null 
                        ? 'Item updated successfully!' 
                        : 'Item listed successfully!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: EcoColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}