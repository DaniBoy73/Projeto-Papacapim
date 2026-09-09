import '../models/user_model.dart';
import '../models/post_model.dart';

/// DADOS INICIAIS LOCAIS:
/// Os dados mockados da Parte 1 foram removidos.
/// Agora o aplicativo consome exclusivamente os usuários e postagens reais
/// da API Papacapim (https://api.papacapim.just.pro.br).

class MockDatabase {
  // Usuário padrão inicial (substituído ao realizar login ou cadastro real na API)
  static UserModel loggedUser = UserModel(
    id: 'user_default',
    name: 'Usuário',
    login: 'usuario',
    avatarUrl: '',
    followersCount: 0,
    followingCount: 0,
    isCurrentUser: true,
  );

  // Lista de Usuários: vazia (carregados via GET /users na API)
  static List<UserModel> getInitialUsers() {
    return <UserModel>[];
  }

  // Lista de Postagens: vazia (carregadas via GET /posts na API)
  static List<PostModel> getInitialPosts() {
    return <PostModel>[];
  }
}
