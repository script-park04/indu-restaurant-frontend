import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/glass_navigation_bar.dart';

import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  UserProfile? _profile;
  final ScrollController _scrollController = ScrollController();
  bool _isNavbarVisible = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _authService.getUserProfile();
      final isAdmin = await _authService.isAdmin();
      setState(() {
        _profile = profile;
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      if (_isNavbarVisible) setState(() => _isNavbarVisible = false);
      return;
    }

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavbarVisible) setState(() => _isNavbarVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavbarVisible) setState(() => _isNavbarVisible = true);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        context.go('/signin');
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    final name = _profile?.fullName ?? user?.userMetadata?['full_name'] ?? 'Guest User';
    final email = user?.email ?? 'No Email';
    final phone = _profile?.phone ?? 'No Phone';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile Header
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.1),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Account details section
                    _buildSectionHeader('Account Details'),
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: 'Full Name',
                      subtitle: name,
                    ),
                    _buildListTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: email,
                    ),
                    _buildListTile(
                      icon: Icons.phone_android,
                      title: 'Phone',
                      subtitle: phone,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Settings'),
                    _buildListTile(
                      icon: Icons.location_on_outlined,
                      title: 'Manage Addresses',
                      onTap: () => context.push('/location-selection'),
                      showArrow: true,
                    ),
                    _buildListTile(
                      icon: Icons.reviews_outlined,
                      title: 'My Orders',
                      onTap: () => context.push('/orders'),
                      showArrow: true,
                    ),
                    if (_isAdmin)
                      _buildListTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Admin Panel',
                        onTap: () => context.push('/admin'),
                        showArrow: true,
                      ),
                    
                    const SizedBox(height: 32),
                    GlassButton(
                      color: AppTheme.error,
                      onPressed: _isLoading ? null : _signOut,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.logout, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('Log Out'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: GlassNavigationBar(
        currentIndex: 3, // Profile tab
        isVisible: _isNavbarVisible,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/menu');
              break;
            case 2:
              context.go('/orders');
              break;
            case 3:
              // already on Profile
              break;
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: 16,
        padding: EdgeInsets.zero,
        blur: 10,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryRed, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: showArrow ? const Icon(Icons.chevron_right, size: 20) : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
