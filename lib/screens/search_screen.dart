import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    final filteredPosts = state.searchPosts(_searchQuery);
    final filteredUsers = state.searchUsers(_searchQuery);

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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textMutedColor,
                indicatorColor: AppTheme.primaryColor,
                tabs: [
                  Tab(text: 'Postagens (${filteredPosts.length})'),
                  Tab(text: 'Usuários (${filteredUsers.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ABA 1: Resultado de Postagens
          filteredPosts.isEmpty
              ? EmptyStateWidget(
                  title: 'Nenhuma postagem encontrada',
                  message: 'Tente buscar por outras palavras-chave ou termos em "$_searchQuery".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: filteredPosts[index]);
                  },
                ),

          // ABA 2: Resultado de Usuários
          filteredUsers.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.person_search_rounded,
                  title: 'Nenhum usuário encontrado',
                  message: 'Não encontramos ninguém com o nome ou handle "$_searchQuery".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return UserTile(user: filteredUsers[index]);
                  },
                ),
        ],
      ),
    );
  }
}
