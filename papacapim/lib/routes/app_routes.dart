// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/post/create_post_screen.dart';
import '../screens/post/post_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

/// Centraliza todas as rotas nomeadas do app.
/// Na Parte 2, basta adaptar os guards de autenticação aqui.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        createPost: (_) => const CreatePostScreen(),
        postDetail: (ctx) {
          final post =
              ModalRoute.of(ctx)!.settings.arguments as PostModel;
          return PostDetailScreen(post: post);
        },
        profile: (ctx) {
          final user =
              ModalRoute.of(ctx)!.settings.arguments as UserModel;
          return ProfileScreen(user: user);
        },
        editProfile: (_) => const EditProfileScreen(),
      };
}
