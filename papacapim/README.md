# Papacapim 🐦

> Rede social Flutter — Parte 1: Design da Interface e Navegação

---

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Flutter | 3.19+ |
| Dart | 3.3+ |
| Android SDK | API 21+ |

---

## Como executar

```bash
# 1. Entre na pasta do projeto
cd papacapim

# 2. Instale as dependências
flutter pub get

# 3. Rode no dispositivo/emulador
flutter run
```

### Login de acesso rápido (modo demo)

| Login | Senha | Observação |
|---|---|---|
| `carloshenrique` | `123456` | Usuário logado padrão |
| `analima` | `123456` | Seguida por Carlos |
| `robertofarias` | `123456` | Seguido por Carlos |
| `julicosta` | `123456` | Não seguida |
| `patriciamendes` | `123456` | Não seguida |
| `felipetorres` | `123456` | Seguido por Carlos |

---

## Funcionalidades implementadas

### Autenticação
- [x] Login com validação de campos
- [x] Cadastro com validação (nome, login, senha, confirmar senha)
- [x] Logout pelo menu ou pelo perfil

### Feed
- [x] Tab **Todos** — todos os posts
- [x] Tab **Seguindo** — posts de usuários seguidos + próprios
- [x] Curtir / descurtir posts (estado local)
- [x] Excluir post próprio com confirmação
- [x] Botão excluir visível somente no post do usuário logado
- [x] Navegar para perfil clicando no nome/avatar
- [x] Pull-to-refresh (simulado)
- [x] FAB para criar novo post

### Busca
- [x] Tab **Postagens** — busca textual em conteúdo e autor
- [x] Tab **Usuários** — busca por nome e login
- [x] Campo com botão de limpar

### Perfil
- [x] Perfil próprio: botão **Editar perfil**
- [x] Perfil alheio: botão **Seguir / Seguindo**
- [x] Exibe posts do usuário
- [x] Contadores de seguidores e seguindo

### Editar Perfil
- [x] Edição de nome e bio
- [x] Seleção de foto pela galeria (`image_picker`)
- [x] Captura de foto pela câmera (`image_picker`)
- [x] Bottom sheet de seleção de fonte de imagem
- [x] Sincroniza avatar nos posts após salvar

### Criar Post
- [x] Campo de texto livre
- [x] Contador circular de caracteres (limite 280)
- [x] Indicador visual quando perto do limite

### Detalhe do Post
- [x] Visualização expandida do post
- [x] Lista de respostas
- [x] Campo de resposta fixo no fundo
- [x] Excluir post próprio na tela de detalhe

---

## Estrutura de pastas

```
lib/
├── main.dart                       # Entrada do app
├── app.dart                        # MaterialApp + Providers + Rotas
├── routes/
│   └── app_routes.dart             # Rotas nomeadas centralizadas
├── theme/
│   └── app_theme.dart              # Tema global (cores, fontes, componentes)
├── models/
│   ├── user_model.dart             # Model de usuário (fromJson/toJson)
│   └── post_model.dart             # Model de post (fromJson/toJson)
├── data/
│   └── mock_data.dart              # Dados mockados (usuários e posts)
├── providers/
│   ├── auth_provider.dart          # Estado de autenticação
│   └── feed_provider.dart          # Estado do feed, posts, usuários
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart        # Shell com BottomNavBar
│   ├── feed/
│   │   └── feed_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   └── post/
│       ├── create_post_screen.dart
│       └── post_detail_screen.dart
└── widgets/
    ├── post_card.dart              # Card de post reutilizável
    ├── user_avatar.dart            # Avatar com fallback de iniciais
    ├── custom_text_field.dart      # Campo de texto padronizado
    ├── follow_button.dart          # Botão Seguir/Seguindo animado
    └── papacapim_logo.dart         # Logo do app
```

---

## Dependências

| Pacote | Função |
|---|---|
| `provider` | Gerência de estado reativo |
| `image_picker` | Galeria e câmera |
| `google_fonts` | Tipografia Inter |
| `cached_network_image` | Cache de imagens de rede |
| `timeago` | Formatação de tempo relativo |

---

## Preparação para Parte 2 (API)

Os providers estão preparados para substituição simples:

| Método atual | Substituir por |
|---|---|
| `auth.login(...)` mock | `POST /sessions` |
| `auth.register(...)` mock | `POST /users` |
| `feed.createPost(...)` mock | `POST /tweets` |
| `feed.toggleLike(...)` mock | `POST/DELETE /tweets/:id/likes` |
| `feed.deletePost(...)` mock | `DELETE /tweets/:id` |
| `feed.replyToPost(...)` mock | `POST /tweets/:id/replies` |
| `feed.toggleFollow(...)` mock | `POST/DELETE /users/:login/followers` |

Os models já possuem `fromJson` e `toJson` implementados.
