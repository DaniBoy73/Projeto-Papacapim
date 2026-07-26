import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../screens/landing_page.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/camera_mock_screen.dart';
import '../screens/gallery_mock_screen.dart';

/// ============================================================================
/// SISTEMA DE ROTAS NOMEADAS DO PAPACAPIM
/// ============================================================================
/// Gerencia a navegação entre todas as telas do aplicativo de forma organizada.
/// 
/// DICA PARA SABATINA:
/// A centralização de rotas evita telas soltas ou 'spaghetti code' no Navigator.
/// Na Parte 2, esta estrutura é ideal para integração com rotas profundas (Deep Links)
/// ou bibliotecas como `go_router`.
class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String createPost = '/create-post';
  static const String cameraMock = '/camera-mock';
  static const String galleryMock = '/gallery-mock';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        final initialTab = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => MainNavigationScreen(initialTab: initialTab),
        );

      case profile:
        final user = settings.arguments as UserModel?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(targetUser: user),
        );

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case createPost:
        final replyToPost = settings.arguments as PostModel?;
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(replyToPost: replyToPost),
        );

      case cameraMock:
        return MaterialPageRoute(builder: (_) => const CameraMockScreen());

      case galleryMock:
        return MaterialPageRoute(builder: (_) => const GalleryMockScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
