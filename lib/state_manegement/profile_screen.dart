import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final savedProducts = provider.savedBooks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D0D1A) : const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(200, 192, 214, 1),
            title: const Text('My Profile'),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 192, 88, 9),
                      Color.fromARGB(255, 167, 121, 29),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(height: 40),
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person,
                          size: 50, color: Colors.white),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'PHOM REA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'phomrea892@gmail.com',
                      style: TextStyle(
                          fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.bookmark,
                        label: 'Saved',
                        value: '${savedProducts.length}',
                        color: const Color(0xFF6B4EFF),
                      ),
                      const SizedBox(width: 12),
                      const _StatCard(
                        icon: Icons.local_mall,
                        label: 'Ordered',
                        value: '3',
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      const _StatCard(
                        icon: Icons.check_circle,
                        label: 'Reviewed',
                        value: '12',
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle(title: 'Saved Products', isDark: isDark),
                  const SizedBox(height: 12),

                  if (savedProducts.isEmpty)
                    const _EmptyState(
                      icon: Icons.bookmark_border,
                      message: 'No saved products yet.',
                    )
                  else
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: savedProducts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            _SavedProductCard(product: savedProducts[i]),
                      ),
                    ),

                  const SizedBox(height: 24),

                  _SectionTitle(title: 'My Orders', isDark: isDark),
                  const SizedBox(height: 12),

                  const _OrderCard(
                    title: 'Premium Membership',
                    subtitle: 'Active · Renews Jan 2026',
                    icon: Icons.workspace_premium,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 10),
                  const _OrderCard(
                    title: 'Makeup Bundle Pack',
                    subtitle: 'Delivered · Dec 12, 2024',
                    icon: Icons.local_shipping,
                    color: Color(0xFF10B981),
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle(title: 'Settings', isDark: isDark),
                  const SizedBox(height: 12),

                  _SettingsTile(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () {}),
                  _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {}),
                  _SettingsTile(
                      icon: Icons.lock_outline,
                      label: 'Privacy & Security',
                      onTap: () {}),
                  _SettingsTile(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () {}),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout,
                          color: Color(0xFFEF4444)),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF111827),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }
}

class _SavedProductCard extends StatelessWidget {
  final Product product;
  const _SavedProductCard({required this.product});

  Widget _buildCachedImage(String? url) {
    final imageUrl = (url ?? '').toString().trim();
    if (imageUrl.isEmpty) return const _ProductPlaceholder();

    return CachedNetworkImage(
      imageUrl: imageUrl.startsWith('http')
          ? imageUrl
          : 'https://$imageUrl',
      height: 110,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        height: 110,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => const _ProductPlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildCachedImage(product.imageLink),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductPlaceholder extends StatelessWidget {
  const _ProductPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      color: const Color(0xFFE5E7EB),
      child: const Icon(Icons.face_retouching_natural,
          color: Color(0xFF9CA3AF), size: 36),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _OrderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B4EFF), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}