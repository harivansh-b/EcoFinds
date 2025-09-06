import 'package:flutter/material.dart';

// EcoFinds Color Palette - Enhanced with additional colors
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
  
  // New colors for enhanced design
  static const Color softGreen = Color(0xFFE8F5E8);         // Very light green
  static const Color mintGreen = Color(0xFFB9F6CA);         // Mint accent
  static const Color shadowGreen = Color(0xFF1B5E20);       // Shadow color
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@email.com');
  final _phoneController = TextEditingController(text: '+1 234 567 8900');
  final _addressController = TextEditingController(text: '123 Main St, City, State');

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessSnackBar('Profile updated successfully! 🌱');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: EcoColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 10,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EcoColors.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EcoColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: EcoColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
              style: TextStyle(
                color: EcoColors.textLight,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: EcoColors.textLight.withOpacity(0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Cancel', style: TextStyle(color: EcoColors.textLight)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessSnackBar('Account deleted successfully');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: EcoColors.errorRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 2,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcoColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EcoColors.primaryGreen, EcoColors.secondaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 60,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Enhanced Profile Section
                        _buildProfileSection(),
                        const SizedBox(height: 32),
                        
                        // Personal Information Card
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 24),
                        
                        // Account Actions Card
                        _buildAccountActionsCard(),
                        const SizedBox(height: 32),
                        
                        // Footer
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, EcoColors.softGreen.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [EcoColors.primaryGreen, EcoColors.leafGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: EcoColors.primaryGreen.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 55, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showSuccessSnackBar('Camera feature coming soon! 📷'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [EcoColors.skyBlue, EcoColors.mintGreen],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: EcoColors.skyBlue.withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: EcoColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [EcoColors.mintGreen.withOpacity(0.3), EcoColors.accentGreen.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, color: EcoColors.secondaryGreen, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Eco Enthusiast',
                  style: TextStyle(
                    fontSize: 14,
                    color: EcoColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EcoColors.shadowGreen.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EcoColors.secondaryGreen.withOpacity(0.2), EcoColors.accentGreen.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_outline, color: EcoColors.secondaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildEnhancedTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) => value?.isEmpty == true ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 20),
          
          _buildEnhancedTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Please enter your email';
              if (!(value?.contains('@') ?? false)) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          _buildEnhancedTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Please enter your phone number' : null,
          ),
          const SizedBox(height: 20),
          
          _buildEnhancedTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (value) => value?.isEmpty == true ? 'Please enter your address' : null,
          ),
          const SizedBox(height: 28),
          
          // Enhanced Update Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [EcoColors.primaryGreen, EcoColors.secondaryGreen],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: EcoColors.primaryGreen.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Update Profile',
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
        ],
      ),
    );
  }

  Widget _buildAccountActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EcoColors.shadowGreen.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EcoColors.skyBlue.withOpacity(0.2), EcoColors.mintGreen.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.settings_outlined, color: EcoColors.skyBlue, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Account Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: EcoColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildActionButton(
            label: 'Change Password',
            icon: Icons.lock_outline,
            color: EcoColors.secondaryGreen,
            onPressed: () => _showSuccessSnackBar('Navigating to Change Password... 🔐'),
          ),
          const SizedBox(height: 16),
          
          _buildActionButton(
            label: 'Delete Account',
            icon: Icons.delete_outline,
            color: EcoColors.errorRed,
            onPressed: _showDeleteAccountDialog,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        color: isDestructive ? color.withOpacity(0.05) : color.withOpacity(0.08),
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          foregroundColor: color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: EcoColors.primaryGreen.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EcoColors.secondaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: EcoColors.secondaryGreen, size: 20),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(Icons.edit, color: EcoColors.textLight, size: 18),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: EcoColors.accentGreen.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: EcoColors.secondaryGreen, width: 2),
          ),
          filled: true,
          fillColor: EcoColors.softGreen.withOpacity(0.3),
          labelStyle: TextStyle(color: EcoColors.textLight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(color: EcoColors.textDark, fontWeight: FontWeight.w500),
        validator: validator,
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('Privacy Policy'),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: 1,
              height: 16,
              color: EcoColors.textLight.withOpacity(0.5),
            ),
            _buildFooterLink('Terms of Service'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, color: EcoColors.secondaryGreen, size: 16),
            const SizedBox(width: 6),
            Text(
              'EcoFinds v1.0.0',
              style: TextStyle(
                color: EcoColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () => _showSuccessSnackBar('Opening $text... 📄'),
      child: Text(
        text,
        style: const TextStyle(
          color: EcoColors.secondaryGreen,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}