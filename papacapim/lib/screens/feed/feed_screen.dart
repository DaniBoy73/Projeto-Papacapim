// lib/screens/feed/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/post_card.dart';
import '../../widgets/papacapim_logo.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: const PapacapimLogo(light: false, fontSize: 22),
        actions: [
          // Botão de logout discreto
          Consumer<AuthProvider>(
            builder: (_, auth, __) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textSecondary),
              onSelected: (v) {
                if (v == 'logout') {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Sair',
                          style: GoogleFonts.inter(
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Seguindo'),
          ],
        ),
      ),
      body: Consumer2<AuthProvider, FeedProvider>(
        builder: (_, auth, feed, __) {
          final currentUser = auth.currentUser!;

          return TabBarView(
            controller: _tabController,
            children: [
              // Aba Todos
              _PostList(posts: feed.allPosts, emptyMessage: 'Nenhum post ainda.'),
              // Aba Seguindo
              _PostList(
                posts: feed.followingPosts(currentUser.id),
                emptyMessage: 'Siga usuários para ver posts aqui.',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPost),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  final List posts;
  final String emptyMessage;

  const _PostList({required this.posts, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🐦', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => PostCard(post: posts[i]),
      ),
    );
  }
}
