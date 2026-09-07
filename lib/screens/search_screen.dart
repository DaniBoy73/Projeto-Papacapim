import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../controllers/app_state.dart';
import '../controllers/app_state_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/post_card.dart';
import '../widgets/user_tile.dart';
import '../widgets/empty_state_widget.dart';

/// TELA DE BUSCA E PESQUISA (TELA PESQUISA)
/// Interface com abas para filtrar postagens por conteúdo e usuários pelo login.

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  List<PostModel> _postsResults = [];
  List<UserModel> _usersResults = [];
  bool _isSearching = false;
  bool _hasInitialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialData) {
      final state = AppStateProvider.of(context);
      _postsResults = state.posts;
      _usersResults = state.users;
      _hasInitialData = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String value, AppState state) async {
    setState(() {
      _searchQuery = value;
      _isSearching = true;
    });

    try {
      final posts = await state.searchPosts(value);
      final users = await state.searchUsers(value);
      if (mounted) {
        setState(() {
          _postsResults = posts;
          _usersResults = users;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Buscar por termos, #tags ou @usuarios...',
                  onChanged: (value) => _onSearchChanged(value, state),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textMutedColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: [
                  Tab(text: 'Postagens (${_postsResults.length})'),
                  Tab(text: 'Usuários (${_usersResults.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: Resultado de Postagens
                _postsResults.isEmpty
                    ? EmptyStateWidget(
                        title: 'Nenhuma postagem encontrada',
                        message: 'Tente buscar por outras palavras-chave ou termos em "$_searchQuery".',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        itemCount: _postsResults.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: _postsResults[index]);
                        },
                      ),

                // ABA 2: Resultado de Usuários
                _usersResults.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.person_search_rounded,
                        title: 'Nenhum usuário encontrado',
                        message: 'Não encontramos ninguém com o nome ou handle "$_searchQuery".',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        itemCount: _usersResults.length,
                        itemBuilder: (context, index) {
                          return UserTile(user: _usersResults[index]);
                        },
                      ),
              ],
            ),
    );
  }
}
