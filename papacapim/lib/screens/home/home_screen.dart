// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../feed/feed_screen.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Shell principal do app com BottomNavigationBar.
/// Mantém o estado de cada aba com IndexedStack para não recriar as telas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    _ProfileShell(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shell do perfil (carrega o usuário logado)
// ---------------------------------------------------------------------------
class _ProfileShell extends StatelessWidget {
  const _ProfileShell();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();
    return ProfileScreen(user: user, isOwnProfile: true);
  }
}

// ---------------------------------------------------------------------------
// Bottom Navigation Bar
// ---------------------------------------------------------------------------
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                iconOutlined: Icons.home_outlined,
                label: 'Início',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                iconOutlined: Icons.search_rounded,
                label: 'Buscar',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                iconOutlined: Icons.person_outline_rounded,
                label: 'Perfil',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? icon : iconOutlined,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
