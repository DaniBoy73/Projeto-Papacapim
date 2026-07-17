// lib/data/mock_data.dart
import '../models/user_model.dart';
import '../models/post_model.dart';

// ---------------------------------------------------------------------------
// Usuários mockados
// ---------------------------------------------------------------------------
final List<UserModel> mockUsers = [
  UserModel(
    id: '1',
    name: 'Carlos Henrique',
    login: 'carloshenrique',
    password: '123456',
    bio: 'Dev apaixonado por café ☕ e código limpo.',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    followersCount: 142,
    followingCount: 89,
  ),
  UserModel(
    id: '2',
    name: 'Ana Lima',
    login: 'analima',
    password: '123456',
    bio: 'Amante da natureza 🌿 e de bons livros.',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    followersCount: 210,
    followingCount: 130,
    isFollowing: true, // Carlos (usuário logado) segue Ana
  ),
  UserModel(
    id: '3',
    name: 'Roberto Farias',
    login: 'robertofarias',
    password: '123456',
    bio: 'Nordestino de coração 🌵',
    avatarUrl: 'https://i.pravatar.cc/150?img=15',
    followersCount: 98,
    followingCount: 54,
    isFollowing: true, // Carlos segue Roberto
  ),
  UserModel(
    id: '4',
    name: 'Juliana Costa',
    login: 'julicosta',
    password: '123456',
    bio: 'Full stack dev 👩‍💻🔥',
    avatarUrl: 'https://i.pravatar.cc/150?img=44',
    followersCount: 375,
    followingCount: 200,
  ),
  UserModel(
    id: '5',
    name: 'Patricia Mendes',
    login: 'patriciamendes',
    password: '123456',
    bio: 'Fotógrafa e viajante 📸🏔️',
    avatarUrl: 'https://i.pravatar.cc/150?img=25',
    followersCount: 512,
    followingCount: 300,
  ),
  UserModel(
    id: '6',
    name: 'Felipe Torres',
    login: 'felipetorres',
    password: '123456',
    bio: 'Open source enthusiast 🚀',
    avatarUrl: 'https://i.pravatar.cc/150?img=8',
    followersCount: 88,
    followingCount: 60,
    isFollowing: true, // Carlos segue Felipe
  ),
];

// Usuário logado padrão (Carlos Henrique, id=1)
final UserModel mockLoggedUser = mockUsers[0];

// ---------------------------------------------------------------------------
// Posts mockados
// ---------------------------------------------------------------------------
List<PostModel> buildMockPosts() {
  final replies1 = [
    PostModel(
      id: 'r1',
      userId: '3',
      content: 'Eu também vi um no quintal ontem! 🐦',
      authorName: 'Roberto Farias',
      authorLogin: 'robertofarias',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=15',
      likesCount: 5,
      createdAt: DateTime.now().subtract(const Duration(minutes: 90)),
      replyToId: 'p2',
    ),
    PostModel(
      id: 'r2',
      userId: '4',
      content: 'Que lindo! A natureza é incrível 🌿',
      authorName: 'Juliana Costa',
      authorLogin: 'julicosta',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=44',
      likesCount: 3,
      createdAt: DateTime.now().subtract(const Duration(minutes: 80)),
      replyToId: 'p2',
    ),
  ];

  final replies2 = [
    PostModel(
      id: 'r3',
      userId: '2',
      content: 'Haha, perguntando por um amigo né 😂',
      authorName: 'Ana Lima',
      authorLogin: 'analima',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=47',
      likesCount: 22,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      replyToId: 'p1',
    ),
  ];

  return [
    // Posts de usuários que Carlos (logado) segue — tab "Seguindo"
    PostModel(
      id: 'p1',
      userId: '1', // Carlos (logado)
      content:
          'Alguém mais viciado em café do que devia? Perguntando por um amigo ☕',
      authorName: 'Carlos Henrique',
      authorLogin: 'carloshenrique',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=12',
      likesCount: 112,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      replies: replies2,
    ),
    PostModel(
      id: 'p2',
      userId: '2', // Ana Lima — seguido
      content:
          'Acabei de ver um papacapim na janela do escritório! Que dia lindo pra começar bem a semana 🌿',
      authorName: 'Ana Lima',
      authorLogin: 'analima',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=47',
      likesCount: 47,
      isLiked: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      replies: replies1,
    ),
    PostModel(
      id: 'p3',
      userId: '3', // Roberto Farias — seguido
      content:
          'O Nordeste tem uma energia inexplicável. Cada vez que volto, o coração fica quentinho 🌵',
      authorName: 'Roberto Farias',
      authorLogin: 'robertofarias',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=15',
      likesCount: 88,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      replies: [],
    ),
    PostModel(
      id: 'p4',
      userId: '6', // Felipe Torres — seguido
      content:
          'Contribuí para meu primeiro projeto open source hoje! Sensação incrível 🚀 #openSource',
      authorName: 'Felipe Torres',
      authorLogin: 'felipetorres',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=8',
      likesCount: 63,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      replies: [],
    ),
    // Posts de outros usuários — tab "Todos" (recomendações)
    PostModel(
      id: 'p5',
      userId: '4', // Juliana Costa — não seguido
      content:
          'Hoje é dia de código, café e mais código. Quem mais tá no modo dev total? 💻🔥',
      authorName: 'Juliana Costa',
      authorLogin: 'julicosta',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=44',
      likesCount: 34,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      replies: [],
    ),
    PostModel(
      id: 'p6',
      userId: '5', // Patricia Mendes — não seguido
      content:
          'A natureza é a melhor terapia. Fim de semana na Serra Gaúcha foi incrível 🏔️',
      authorName: 'Patricia Mendes',
      authorLogin: 'patriciamendes',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=25',
      likesCount: 201,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      replies: [],
    ),
    PostModel(
      id: 'p7',
      userId: '5',
      content:
          'Vocês já testaram fotografar pássaros ao amanhecer? A luz é mágica! 📸🌅',
      authorName: 'Patricia Mendes',
      authorLogin: 'patriciamendes',
      authorAvatarUrl: 'https://i.pravatar.cc/150?img=25',
      likesCount: 145,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      replies: [],
    ),
  ];
}
