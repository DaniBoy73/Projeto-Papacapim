import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/empty_state_widget.dart';
import '../routes/app_routes.dart';

/// TELA DE FEED DE POSTAGENS:
/// Exibe a lista de postagens dividida em duas abas visuais:
/// 1. "Seguindo": exibe apenas posts do próprio usuário e de usuários seguidos.
/// 2. "Recomendados": exibe todas as postagens publicadas no Papacapim.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    final followedPosts = state.followedUsersPosts;
    final allPosts = state.posts;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flutter_dash, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 8),
            const Text('Papacapim'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nenhuma notificação pendente.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
            tooltip: 'Sair da Conta',
            onPressed: () {
              state.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.landing,
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMutedColor,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Seguindo'),
            Tab(text: 'Recomendados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA 1: Perfis Seguidos
          RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: followedPosts.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'Seu feed de seguidos está vazio',
                    message: 'Siga outros usuários na tela de Busca para ver as postagens deles aqui!',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: followedPosts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: followedPosts[index]);
                    },
                  ),
          ),

          // ABA 2: Recomendados / Geral
          RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: allPosts.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.dynamic_feed_rounded,
                    title: 'Nenhuma postagem no momento',
                    message: 'Seja o primeiro a publicar algo no Papacapim!',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: allPosts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: allPosts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
