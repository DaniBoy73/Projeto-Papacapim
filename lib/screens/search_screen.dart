import 'dart:async';
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
/// Implementa debouncing e controle de sequência de requisições assíncronas para evitar
/// condições de corrida (race conditions) na digitação rápida.
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
  bool _isInitialLoading = true;
  bool _isSearching = false;
  bool _hasInitialData = false;
  Timer? _debounceTimer;
  int _searchSequence = 0;

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
      _executeSearch('', state, isInitial: true);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Filtro local imediato (0ms) para dar feedback instantâneo enquanto a requisição remota é aguardada
  void _filterLocally(String query, AppState state) {
    final term = query.toLowerCase().replaceAll('@', '').trim();
    if (term.isEmpty) return;

    final localPosts = state.posts
        .where((p) =>
            p.content.toLowerCase().contains(term) ||
            p.authorName.toLowerCase().contains(term) ||
            p.authorLogin.toLowerCase().contains(term))
        .toList();

    final localUsers = state.users
        .where((u) =>
            u.name.toLowerCase().contains(term) ||
            u.login.toLowerCase().contains(term))
        .toList();

    setState(() {
      _postsResults = localPosts;
      _usersResults = localUsers;
      _isSearching = true;
    });
  }

  /// Executa a busca remota com validação de sequência para descartar respostas obsoletas
  Future<void> _executeSearch(String query, AppState state, {bool isInitial = false}) async {
    final currentSeq = ++_searchSequence;

    if (isInitial) {
      setState(() => _isInitialLoading = true);
    } else {
      setState(() => _isSearching = true);
    }

    try {
      final postsFuture = state.searchPosts(query);
      final usersFuture = state.searchUsers(query);
      final results = await Future.wait([postsFuture, usersFuture]);

      // Se outra pesquisa foi disparada ou o widget foi desmontado, descarta esta resposta defasada
      if (!mounted || currentSeq != _searchSequence) {
        return;
      }

      setState(() {
        _postsResults = results[0] as List<PostModel>;
        _usersResults = results[1] as List<UserModel>;
        _isInitialLoading = false;
        _isSearching = false;
      });
    } catch (_) {
      if (mounted && currentSeq == _searchSequence) {
        setState(() {
          _isInitialLoading = false;
          _isSearching = false;
        });
      }
    }
  }

  /// Manipula alterações no campo de busca com cancelamento de timer anterior (Debounce de 300ms)
  void _onSearchChanged(String value, AppState state) {
    _debounceTimer?.cancel();
    _searchQuery = value;

    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      _executeSearch('', state);
      return;
    }

    // Feedback visual imediato na memória local
    _filterLocally(trimmed, state);

    // Aguarda o término da digitação (300ms) antes de acionar as requisições na API
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _executeSearch(trimmed, state);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchBarWidget(
                  controller: _searchController,
                  hintText: 'Buscar por termos, #tags ou @usuarios...',
                  onChanged: (value) => _onSearchChanged(value, state),
                  onSubmitted: (value) {
                    _debounceTimer?.cancel();
                    _executeSearch(value.trim(), state);
                  },
                  onClear: () {
                    _debounceTimer?.cancel();
                    _searchController.clear();
                    _onSearchChanged('', state);
                  },
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
              if (_isSearching)
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.transparent,
                )
              else
                const SizedBox(height: 2),
            ],
          ),
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: Resultado de Postagens
                RefreshIndicator(
                  onRefresh: () => _executeSearch(_searchQuery, state),
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
                  onRefresh: () => _executeSearch(_searchQuery, state),
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
