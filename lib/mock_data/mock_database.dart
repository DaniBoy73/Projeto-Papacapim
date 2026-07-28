import '../models/user_model.dart';
import '../models/post_model.dart';


/// CAMADA DE DADOS MOCKADOS (MOCK DATABASE):
/// Fornece dados mockados de 4 usuários e 8 postagens pré-cadastradas para
/// simulação sem necessidade de conexão com o backend por enquanto.


class MockDatabase {
  // Usuário padrão logado no sistema
  static UserModel loggedUser = UserModel(
    id: 'usr_1',
    name: 'Carlos Silva',
    login: 'carlos_papacapim',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    followersCount: 142,
    followingCount: 58,
    isCurrentUser: true,
  );

  // Lista inicial de Usuários Mockados
  static List<UserModel> getInitialUsers() {
    return [
      loggedUser,
      UserModel(
        id: 'usr_2',
        name: 'Ana Dev',
        login: 'ana_dev',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        followersCount: 890,
        followingCount: 120,
        isFollowedByCurrentUser: true,
      ),
      UserModel(
        id: 'usr_3',
        name: 'Marcos Flutter',
        login: 'marcos_flutter',
        avatarUrl: 'https://i.pravatar.cc/150?img=13',
        followersCount: 340,
        followingCount: 95,
        isFollowedByCurrentUser: true,
      ),
      UserModel(
        id: 'usr_4',
        name: 'Juliana Tech',
        login: 'juliana_tech',
        avatarUrl: 'https://i.pravatar.cc/150?img=9',
        followersCount: 1250,
        followingCount: 430,
        isFollowedByCurrentUser: false,
      ),
    ];
  }

  // Lista inicial de Postagens Mockadas
  static List<PostModel> getInitialPosts() {
    final now = DateTime.now();
    return [
      PostModel(
        id: 'post_1',
        authorId: 'usr_2',
        authorName: 'Ana Dev',
        authorLogin: 'ana_dev',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=5',
        content: 'Bem-vindos ao Papacapim! A nova rede social construída com Flutter e Clean Architecture. O que estão achando da interface? 🚀🐥',
        createdAt: now.subtract(const Duration(minutes: 10)),
        likesCount: 15,
        commentsCount: 3,
        isLikedByCurrentUser: true,
      ),
      PostModel(
        id: 'post_2',
        authorId: 'usr_1',
        authorName: 'Carlos Silva',
        authorLogin: 'carlos_papacapim',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=11',
        content: 'Finalizando os componentes visuais da Parte 1 do projeto! Layout super fluido com Material 3. #Flutter #CleanArch',
        createdAt: now.subtract(const Duration(hours: 1)),
        likesCount: 28,
        commentsCount: 5,
        isLikedByCurrentUser: false,
      ),
      PostModel(
        id: 'post_3',
        authorId: 'usr_3',
        authorName: 'Marcos Flutter',
        authorLogin: 'marcos_flutter',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=13',
        content: 'Dica do dia: Use ValueNotifier ou StateNotifier para manter o código limpo em sabatinas acadêmicas sem poluir o projeto! 🔥',
        createdAt: now.subtract(const Duration(hours: 3)),
        likesCount: 42,
        commentsCount: 8,
        isLikedByCurrentUser: true,
      ),
      PostModel(
        id: 'post_4',
        authorId: 'usr_1',
        authorName: 'Carlos Silva',
        authorLogin: 'carlos_papacapim',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=11',
        content: 'Concordo totalmente com o Marcos! Separar o estado da UI torna o aplicativo testável e pronto para integrar APIs REST.',
        createdAt: now.subtract(const Duration(hours: 2)),
        likesCount: 12,
        commentsCount: 1,
        isLikedByCurrentUser: false,
        parentPostId: 'post_3',
        parentAuthorLogin: 'marcos_flutter',
        parentContentPreview: 'Dica do dia: Use ValueNotifier ou StateNotifier...',
      ),
      PostModel(
        id: 'post_5',
        authorId: 'usr_4',
        authorName: 'Juliana Tech',
        authorLogin: 'juliana_tech',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=9',
        content: 'Alguém mais ansioso para a Parte 2 com a integração da API backend do Papacapim? Vai ser sensacional! 💻✨',
        createdAt: now.subtract(const Duration(hours: 5)),
        likesCount: 87,
        commentsCount: 14,
        isLikedByCurrentUser: false,
      ),
      PostModel(
        id: 'post_6',
        authorId: 'usr_2',
        authorName: 'Ana Dev',
        authorLogin: 'ana_dev',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=5',
        content: 'Testando a troca de fotos de perfil com o simulador de Câmera e Galeria local. Ficou excelente!',
        createdAt: now.subtract(const Duration(hours: 8)),
        likesCount: 19,
        commentsCount: 2,
        isLikedByCurrentUser: false,
      ),
      PostModel(
        id: 'post_7',
        authorId: 'usr_3',
        authorName: 'Marcos Flutter',
        authorLogin: 'marcos_flutter',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=13',
        content: 'Respondendo à postagem da Juliana: A integração com HTTP e Dio na Parte 2 vai conectar tudo perfeitamente!',
        createdAt: now.subtract(const Duration(hours: 4)),
        likesCount: 34,
        commentsCount: 4,
        isLikedByCurrentUser: true,
        parentPostId: 'post_5',
        parentAuthorLogin: 'juliana_tech',
        parentContentPreview: 'Alguém mais ansioso para a Parte 2 com a integração...',
      ),
      PostModel(
        id: 'post_8',
        authorId: 'usr_4',
        authorName: 'Juliana Tech',
        authorLogin: 'juliana_tech',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=9',
        content: 'Não esqueçam de estrelar o repositório e testar os filtros de pesquisa de posts e usuários! 🌟',
        createdAt: now.subtract(const Duration(days: 1)),
        likesCount: 104,
        commentsCount: 9,
        isLikedByCurrentUser: false,
      ),
    ];
  }
}
