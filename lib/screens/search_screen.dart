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
/// Interface com abas para filtrar postagens por conteúdo e usuários reais do sistema.
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
  bool _isLoading = false;
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
      _hasInitialData = true;
      final state = AppStateProvider.of(context);
      _loadData(state);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData(AppState state) async {
    setState(() => _isLoading = true);

    try {
      final postsFuture = state.searchPosts(_searchQuery);
      final usersFuture = state.searchUsers(_searchQuery);
      final results = await Future.wait([postsFuture, usersFuture]);

      if (mounted) {
        setState(() {
          _postsResults = results[0] as List<PostModel>;
          _usersResults = results[1] as List<UserModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSearchChanged(String value, AppState state) async {
    _searchQuery = value;
    await _loadData(state);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: Resultado de Postagens
                RefreshIndicator(
                  onRefresh: () => _loadData(state),
                  child: _postsResults.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            EmptyStateWidget(
                              title: 'Nenhuma postagem encontrada',
                              message: _searchQuery.isEmpty
                                  ? 'Não há publicações recentes no feed.'
                                  : 'Tente buscar por outras palavras-chave ou termos em "$_searchQuery".',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          itemCount: _postsResults.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: _postsResults[index]);
                          },
                        ),
                ),

                // ABA 2: Resultado de Usuários Reais do Sistema
                RefreshIndicator(
                  onRefresh: () => _loadData(state),
                  child: _usersResults.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            EmptyStateWidget(
                              icon: Icons.person_search_rounded,
                              title: 'Nenhum usuário encontrado',
                              message: _searchQuery.isEmpty
                                  ? 'Nenhum usuário cadastrado no sistema foi retornado.'
                                  : 'Não encontramos ninguém com o nome ou handle "$_searchQuery".',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          itemCount: _usersResults.length,
                          itemBuilder: (context, index) {
                            return UserTile(user: _usersResults[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
