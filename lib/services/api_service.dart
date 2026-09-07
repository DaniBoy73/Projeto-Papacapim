import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/post_model.dart';

/// CAMADA DE SERVIÇO / BACK-END EM DART (API SERVICE):
/// Responsável por toda a comunicação HTTP RESTful com a API oficial do Papacapim:
/// https://api.papacapim.just.pro.br
///
/// Implementa autenticação por cabeçalho `x-session-token`, serialização e
/// desserialização JSON, tratamento de erros e suporte aos endpoints de:
/// - Sessões (login / logout)
/// - Usuários (cadastro, alteração, consulta, exclusão)
/// - Seguidores (seguir, deixar de seguir, listagem)
/// - Postagens (feed de seguidos, recomendados, respostas, criação, exclusão)
/// - Curtidas (curtir, descurtir)

class ApiService {
  static const String baseUrl = 'https://api.papacapim.just.pro.br';

  final http.Client _client;
  String? _sessionToken;
  String? _currentUserLogin;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Token da sessão ativa atual
  String? get sessionToken => _sessionToken;

  /// Login do usuário autenticado no momento
  String? get currentUserLogin => _currentUserLogin;

  /// Informa se há uma sessão autenticada ativa
  bool get isAuthenticated => _sessionToken != null && _sessionToken!.isNotEmpty;

  /// Define manualmente o token de sessão (útil para testes ou restauração)
  void setSessionToken(String? token, {String? userLogin}) {
    _sessionToken = token;
    _currentUserLogin = userLogin;
  }

  /// Gera os cabeçalhos padrão das requisições HTTP
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    if (_sessionToken != null && _sessionToken!.isNotEmpty) {
      headers['x-session-token'] = _sessionToken!;
    }
    return headers;
  }

  /// Trata a resposta HTTP e lança exceções formatadas em caso de erro
  dynamic _handleResponse(http.Response response) {
    // 204 No Content (ex: exclusão com sucesso)
    if (response.statusCode == 204) {
      return null;
    }

    dynamic decodedBody;
    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    // Tratamento específico de erros comuns da API
    String errorMessage = 'Erro na requisição (${response.statusCode})';
    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody.containsKey('error')) {
        errorMessage = decodedBody['error'].toString();
      } else if (decodedBody.containsKey('message')) {
        errorMessage = decodedBody['message'].toString();
      } else if (decodedBody.containsKey('errors')) {
        errorMessage = decodedBody['errors'].toString();
      }
    } else if (response.statusCode == 401) {
      errorMessage = 'Sessão expirada ou não autorizada. Faça login novamente.';
    } else if (response.statusCode == 404) {
      errorMessage = 'Recurso não encontrado.';
    }

    throw ApiException(statusCode: response.statusCode, message: errorMessage);
  }

  // ==========================================================================
  // 1. SESSÕES E AUTENTICAÇÃO
  // ==========================================================================

  /// Efetua login no Papacapim: POST /sessions
  /// Retorna o mapa contendo token e user_login
  Future<Map<String, dynamic>> login(String loginInput, String password) async {
    final url = Uri.parse('$baseUrl/sessions');
    final cleanLogin = loginInput.trim().replaceAll('@', '');

    final response = await _client.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        'login': cleanLogin,
        'password': password,
      }),
    );

    final data = _handleResponse(response) as Map<String, dynamic>;
    _sessionToken = data['token']?.toString();
    _currentUserLogin = data['user_login']?.toString() ?? cleanLogin;

    return data;
  }

  /// Encerra a sessão atual: DELETE /sessions/1
  Future<void> logout() async {
    try {
      if (isAuthenticated) {
        final url = Uri.parse('$baseUrl/sessions/1');
        await _client.delete(url, headers: _getHeaders());
      }
    } catch (_) {
      // Ignora erro de rede no logout para garantir limpeza local
    } finally {
      _sessionToken = null;
      _currentUserLogin = null;
    }
  }

  // ==========================================================================
  // 2. USUÁRIOS (CADASTRO, PERFIL, ATUALIZAÇÃO, EXCLUSÃO)
  // ==========================================================================

  /// Cadastra um novo usuário: POST /users (não requer token)
  Future<UserModel> register({
    required String name,
    required String login,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/users');
    final cleanLogin = login.trim().replaceAll('@', '');

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json'},
      body: jsonEncode({
        'user': {
          'name': name.trim(),
          'login': cleanLogin,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }
      }),
    );

    final data = _handleResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data, isCurrentUser: true);
  }

  /// Obtém os dados do perfil do próprio usuário logado: GET /users/me
  Future<UserModel> getMyProfile() async {
    return getUser('me');
  }

  /// Obtém os dados de um usuário pelo seu login: GET /users/{login}
  Future<UserModel> getUser(String userLogin) async {
    final clean = userLogin.trim().replaceAll('@', '');
    final url = Uri.parse('$baseUrl/users/$clean');

    final response = await _client.get(url, headers: _getHeaders());
    final data = _handleResponse(response) as Map<String, dynamic>;

    final isMe = clean.toLowerCase() == 'me' ||
        (clean.toLowerCase() == _currentUserLogin?.toLowerCase());

    return UserModel.fromJson(data, isCurrentUser: isMe);
  }

  /// Altera os dados do usuário autenticado: PATCH /users/1
  Future<UserModel> updateProfile({
    String? name,
    String? password,
    String? passwordConfirmation,
    String? imageData,
  }) async {
    final url = Uri.parse('$baseUrl/users/1');

    final userPayload = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) {
      userPayload['name'] = name.trim();
    }
    if (password != null && password.isNotEmpty) {
      userPayload['password'] = password;
      userPayload['password_confirmation'] = passwordConfirmation ?? password;
    }
    if (imageData != null && imageData.isNotEmpty) {
      userPayload['image_data'] = imageData;
    }

    final response = await _client.patch(
      url,
      headers: _getHeaders(),
      body: jsonEncode({'user': userPayload}),
    );

    final data = _handleResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data, isCurrentUser: true);
  }

  /// Exclui permanentemente a conta do usuário logado: DELETE /users/me
  Future<void> deleteAccount() async {
    final url = Uri.parse('$baseUrl/users/me');
    final response = await _client.delete(url, headers: _getHeaders());
    _handleResponse(response);

    _sessionToken = null;
    _currentUserLogin = null;
  }

  /// Lista ou pesquisa usuários: GET /users?search={query}&page={page}
  Future<List<UserModel>> searchUsers(String query, {int? page}) async {
    final queryParams = <String, String>{};
    if (query.trim().isNotEmpty) {
      queryParams['search'] = query.trim();
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }

    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await _client.get(uri, headers: _getHeaders());
    final data = _handleResponse(response) as List<dynamic>;

    return data.map((item) {
      final map = item as Map<String, dynamic>;
      final isMe = map['login']?.toString().toLowerCase() == _currentUserLogin?.toLowerCase();
      return UserModel.fromJson(map, isCurrentUser: isMe);
    }).toList();
  }

  // ==========================================================================
  // 3. SEGUIDORES
  // ==========================================================================

  /// Seguir um usuário: POST /users/{login}/followers
  Future<void> followUser(String userLogin) async {
    final clean = userLogin.trim().replaceAll('@', '');
    final url = Uri.parse('$baseUrl/users/$clean/followers');

    final response = await _client.post(url, headers: _getHeaders());
    _handleResponse(response);
  }

  /// Deixar de seguir um usuário: DELETE /users/{login}/followers/me
  Future<void> unfollowUser(String userLogin) async {
    final clean = userLogin.trim().replaceAll('@', '');
    final url = Uri.parse('$baseUrl/users/$clean/followers/me');

    final response = await _client.delete(url, headers: _getHeaders());
    _handleResponse(response);
  }

  // ==========================================================================
  // 4. POSTAGENS E FEED
  // ==========================================================================

  /// Listar postagens: GET /posts
  /// - Se `feedOnly: true`, passa `feed=1` para listar apenas perfis seguidos
  /// - Se `search: 'termo'`, filtra posts pelo termo
  Future<List<PostModel>> getPosts({bool feedOnly = false, String? search, int? page}) async {
    final queryParams = <String, String>{};
    if (feedOnly) {
      queryParams['feed'] = '1';
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }

    final uri = Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await _client.get(uri, headers: _getHeaders());
    final data = _handleResponse(response) as List<dynamic>;

    return data.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Listar postagens de um usuário específico: GET /users/{login}/posts
  Future<List<PostModel>> getUserPosts(String userLogin, {int? page}) async {
    final clean = userLogin.trim().replaceAll('@', '');
    final queryParams = <String, String>{};
    if (page != null) {
      queryParams['page'] = page.toString();
    }

    final uri = Uri.parse('$baseUrl/users/$clean/posts').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    final response = await _client.get(uri, headers: _getHeaders());
    final data = _handleResponse(response) as List<dynamic>;

    return data.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Criar uma nova postagem no feed: POST /posts
  Future<PostModel> createPost(String message) async {
    final url = Uri.parse('$baseUrl/posts');

    final response = await _client.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        'post': {'message': message.trim()}
      }),
    );

    final data = _handleResponse(response) as Map<String, dynamic>;
    return PostModel.fromJson(data);
  }

  /// Responder a uma postagem existente: POST /posts/{id}/replies
  Future<PostModel> replyPost(int parentPostId, String message) async {
    final url = Uri.parse('$baseUrl/posts/$parentPostId/replies');

    final response = await _client.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        'reply': {'message': message.trim()}
      }),
    );

    final data = _handleResponse(response) as Map<String, dynamic>;
    return PostModel.fromJson(data);
  }

  /// Excluir uma postagem: DELETE /posts/{id}
  Future<void> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    final response = await _client.delete(url, headers: _getHeaders());
    _handleResponse(response);
  }

  // ==========================================================================
  // 5. CURTIDAS
  // ==========================================================================

  /// Curtir postagem: POST /posts/{id}/likes
  Future<void> likePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/likes');
    final response = await _client.post(url, headers: _getHeaders());
    _handleResponse(response);
  }

  /// Descurtir postagem: DELETE /posts/{id}/likes/me
  Future<void> unlikePost(int postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId/likes/me');
    final response = await _client.delete(url, headers: _getHeaders());
    _handleResponse(response);
  }
}

/// Classe de Exceção personalizada da API para tratamento de erros
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}
