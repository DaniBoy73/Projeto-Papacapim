import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../routes/app_routes.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

/// ============================================================================
/// CONTAINER PRINCIPAL E NAVEGAÇÃO POR ABAS (BOTTOM NAVIGATION BAR)
/// ============================================================================
/// Gerencia a navegação entre as telas principais: Feed, Pesquisa e Perfil, além
/// de oferecer o FloatingActionButton central para criar novas postagens.
class MainNavigationScreen extends StatefulWidget {
  final int initialTab;

  const MainNavigationScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    // Telas associadas a cada aba da BottomNavigationBar
    final List<Widget> screens = [
      const FeedScreen(),
      const SearchScreen(),
      ProfileScreen(targetUser: state.currentUser),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundColor: AppTheme.primaryLight,
              backgroundImage: NetworkImage(state.currentUser.avatarUrl),
            ),
            activeIcon: CircleAvatar(
              radius: 13,
              backgroundColor: AppTheme.primaryColor,
              child: CircleAvatar(
                radius: 11,
                backgroundImage: NetworkImage(state.currentUser.avatarUrl),
              ),
            ),
            label: 'Perfil',
          ),
        ],
      ),

      // Botão Flutuante Rápido para Criar Postagem
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createPost);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Criar Postagem',
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }
}
