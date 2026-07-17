// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/feed_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/post_card.dart';
import '../../widgets/user_avatar.dart';
import '../../models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Buscar',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Campo de busca
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(
                      fontSize: 15, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar postagens...',
                    hintStyle: GoogleFonts.inter(
                        color: AppColors.textHint, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Postagens'),
                  Tab(text: 'Usuários'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Postagens
          _buildPostResults(feed),
          // Tab Usuários
          _buildUserResults(feed),
        ],
      ),
    );
  }

  Widget _buildPostResults(FeedProvider feed) {
    final posts = feed.searchPosts(_query);

    if (posts.isEmpty) {
      return _EmptyState(
        icon: '🔍',
        message: _query.isEmpty
            ? 'Digite algo para buscar postagens'
            : 'Nenhum post encontrado para "$_query"',
      );
    }

    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => PostCard(post: posts[i]),
    );
  }

  Widget _buildUserResults(FeedProvider feed) {
    final users = feed.searchUsers(_query);

    if (users.isEmpty) {
      return _EmptyState(
        icon: '👤',
        message: 'Nenhum usuário encontrado para "$_query"',
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => _UserTile(user: users[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile de usuário na busca
// ---------------------------------------------------------------------------
class _UserTile extends StatelessWidget {
  final UserModel user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.profile, arguments: user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: user.avatarUrl,
              localPath: user.localAvatarPath,
              name: user.name,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '@${user.login}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        user.bio!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (user.isFollowing)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Seguindo',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
