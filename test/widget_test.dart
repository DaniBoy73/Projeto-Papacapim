import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_papacapim/main.dart';
import 'package:projeto_papacapim/controllers/app_state.dart';
import 'package:projeto_papacapim/controllers/app_state_provider.dart';
import 'package:projeto_papacapim/models/user_model.dart';
import 'package:projeto_papacapim/models/post_model.dart';
import 'package:projeto_papacapim/screens/profile_screen.dart';
import 'package:projeto_papacapim/widgets/user_tile.dart';
import 'package:projeto_papacapim/widgets/avatar/app_avatar.dart';
import 'package:projeto_papacapim/widgets/photo_source_bottom_sheet.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final List<int> _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Papacapim App smoke test', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(PapacapimApp(appState: appState));

    // Verifica se a tela inicial exibe a marca Papacapim
    expect(find.text('Papacapim'), findsOneWidget);
  });

  testWidgets('Follow button changes instantly between Seguir and Seguindo on profile', (WidgetTester tester) async {
    final appState = AppState();
    final targetUser = appState.getUserByLogin('juliana_tech');

    // Suprime exceções de imagem de rede no ambiente de teste
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) return;
      FlutterError.presentError(details);
    };

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateProvider(
          state: appState,
          child: ProfileScreen(targetUser: targetUser),
        ),
      ),
    );

    // Inicialmente não segue a Juliana Tech, botão de elevação deve mostrar 'Seguir'
    final followButtonFinder = find.widgetWithText(ElevatedButton, 'Seguir');
    final followingButtonFinder = find.widgetWithText(ElevatedButton, 'Seguindo');

    expect(followButtonFinder, findsOneWidget);
    expect(followingButtonFinder, findsNothing);

    // Clica no botão de Seguir
    await tester.tap(followButtonFinder);
    await tester.pump();

    // Deve mudar imediatamente para 'Seguindo' no botão
    expect(find.widgetWithText(ElevatedButton, 'Seguindo'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Seguir'), findsNothing);
  });

  test('UserModel.fromJson maps Papacapim API format correctly', () {
    final apiJson = {
      'login': 'frankson',
      'name': 'Frankson Barreto',
      'profile_image': 'https://api.papacapim.just.pro.br/image/profile/test.webp',
      'followers_number': 120,
      'following_number': 230,
      'you_follow': true,
      'follows_you': false,
    };

    final user = UserModel.fromJson(apiJson);
    expect(user.login, 'frankson');
    expect(user.name, 'Frankson Barreto');
    expect(user.avatarUrl, 'https://api.papacapim.just.pro.br/image/profile/test.webp');
    expect(user.followersCount, 120);
    expect(user.followingCount, 230);
    expect(user.isFollowedByCurrentUser, isTrue);
  });

  test('PostModel.fromJson maps Papacapim API format with nested user correctly', () {
    final apiJson = {
      'id': 42,
      'post_id': 10,
      'message': 'Mensagem de teste no Papacapim!',
      'created_at': '2024-08-03T13:36:56.977Z',
      'likes_number': 5,
      'replies_number': 2,
      'you_liked': true,
      'user': {
        'login': 'just',
        'name': 'J. P. Just',
        'profile_image': 'https://api.papacapim.just.pro.br/image/profile/just.webp',
      },
    };

    final post = PostModel.fromJson(apiJson);
    expect(post.id, '42');
    expect(post.parentPostId, '10');
    expect(post.content, 'Mensagem de teste no Papacapim!');
    expect(post.authorLogin, 'just');
    expect(post.authorName, 'J. P. Just');
    expect(post.likesCount, 5);
    expect(post.commentsCount, 2);
    expect(post.isLikedByCurrentUser, isTrue);
  });

  test('AppState handles local post creation and like toggling', () async {
    final appState = AppState();
    final initialCount = appState.posts.length;

    await appState.addPost('Post de teste via AppState');
    expect(appState.posts.length, initialCount + 1);
    expect(appState.posts.first.content, 'Post de teste via AppState');

    final createdPostId = appState.posts.first.id;
    expect(appState.posts.first.isLikedByCurrentUser, isFalse);

    await appState.toggleLike(createdPostId);
    expect(appState.posts.first.isLikedByCurrentUser, isTrue);
    expect(appState.posts.first.likesCount, 1);

    await appState.toggleLike(createdPostId);
    expect(appState.posts.first.isLikedByCurrentUser, isFalse);
    expect(appState.posts.first.likesCount, 0);
  });

  testWidgets('UserTile displays real user data and toggles follow state', (WidgetTester tester) async {
    final appState = AppState();
    final realUser = UserModel(
      id: 'usr_real_1',
      name: 'Carlos Just',
      login: 'carlos_just',
      avatarUrl: 'https://i.pravatar.cc/150?u=carlos_just',
      followersCount: 5,
      followingCount: 2,
      isFollowedByCurrentUser: false,
    );
    appState.cacheUser(realUser);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStateProvider(
            state: appState,
            child: UserTile(user: realUser),
          ),
        ),
      ),
    );

    expect(find.text('Carlos Just'), findsOneWidget);
    expect(find.text('@carlos_just'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Seguir'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Seguir'));
    await tester.pump();

    expect(find.widgetWithText(ElevatedButton, 'Seguindo'), findsOneWidget);
  });

  testWidgets('UserTile displays Voce button for current logged user', (WidgetTester tester) async {
    final appState = AppState();
    final me = appState.currentUser;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppStateProvider(
            state: appState,
            child: UserTile(user: me),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(OutlinedButton, 'Você'), findsOneWidget);
  });

  testWidgets('AppAvatar renders initial letter only when user has no photo', (WidgetTester tester) async {
    // Usuário sem foto de perfil: deve exibir a letra inicial 'C'
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAvatar(
            imageUrl: '',
            radius: 30,
            name: 'Caio C',
          ),
        ),
      ),
    );
    expect(find.text('C'), findsOneWidget);

    // Usuário COM foto de perfil: NÃO deve sobrepor a letra inicial 'C' na foto
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppAvatar(
            imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            radius: 30,
            name: 'Caio C',
          ),
        ),
      ),
    );
    expect(find.text('C'), findsNothing);
  });

  testWidgets('PhotoSourceBottomSheet displays real gallery and file options', (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateProvider(
          state: appState,
          child: const Scaffold(
            body: PhotoSourceBottomSheet(),
          ),
        ),
      ),
    );

    expect(find.text('Alterar Foto do Perfil'), findsOneWidget);
    expect(find.text('Escolher da Galeria / Arquivos'), findsOneWidget);
    expect(find.text('Tirar foto com a Câmera'), findsOneWidget);
    expect(find.text('Galeria Simulada (Mock Parte 1)'), findsNothing);
    expect(find.text('Câmera Simulada (Mock Parte 1)'), findsNothing);
  });

  test('AppState.updateAvatar updates current user avatar and post author avatars', () async {
    final appState = AppState();
    final newAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';

    final success = await appState.updateAvatar(newAvatar);
    expect(success, isTrue);
    expect(appState.currentUser.avatarUrl, newAvatar);
  });
}
