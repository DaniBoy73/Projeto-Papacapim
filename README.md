# 🐦 Papacapim - Rede Social em Flutter

Seja bem-vindo ao projeto **Papacapim**! Este é um aplicativo de rede social moderno desenvolvido em **Flutter** e **Dart**, com arquitetura limpa, navegação reativa e gerenciamento de estado nativo.

Este documento foi preparado para apresentar a estrutura e a organização do projeto para quem está tendo o primeiro contato com a codebase.

---

## 🚀 Arquivos de Configuração e Compilação (Raiz do Projeto)

Fora da pasta principal de código (`lib/`), o projeto possui arquivos e diretórios cruciais para a configuração, gerenciamento de dependências e compilação nativa:

* **`pubspec.yaml`**: Arquivo principal de configuração do Flutter. Define o nome do projeto, versão, dependências de pacotes, fontes e ativos de imagem (assets).
* **`pubspec.lock`**: Registra as versões exatas de cada biblioteca e sub-dependência instaladas no projeto, garantindo que o app seja compilado de forma idêntica em qualquer ambiente.
* **`analysis_options.yaml`**: Define os padrões de código, regras de qualidade e configurações do analisador estático do Dart (Linter).
* **`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`**: Pastas que contêm o código nativo e arquivos de build necessários para gerar os executáveis do aplicativo em cada plataforma.

---

## 📂 Estrutura da Pasta `lib/`

A pasta `lib/` é o coração do projeto Flutter. A estrutura foi organizada em camadas bem delimitadas para facilitar a manutenção e legibilidade:

```text
lib/
├── controllers/          # Gerenciamento de estado da aplicação
├── mock_data/            # Dados simulados (Mock Database)
├── models/               # Modelos de dados (User, Post)
├── routes/               # Sistema centralizado de navegação e rotas
├── screens/              # Telas e interfaces completas do app
├── theme/                # Tema visual e Design System
├── widgets/              # Componentes reutilizáveis de interface
└── main.dart             # Ponto de entrada do aplicativo
```

---

### 🟢 Arquivo de Entrada

* **[`main.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/main.dart)**: É o ponto de entrada da aplicação. Inicializa os bindings do Flutter, instancia o controlador de estado global (`AppState`), conecta o provedor de estado (`AppStateProvider`) e carrega o tema e as rotas.

---

### 🎮 `lib/controllers/` (Gerenciamento de Estado)

Gerencia a regra de negócio local e a reatividade do aplicativo sem depender de bibliotecas externas complexas:

* **[`app_state.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/controllers/app_state.dart)**: Controlador principal da aplicação estendendo `ChangeNotifier`. Mantém em memória a lista de usuários, postagens, curtidas, seguidores e perfil logado, disparando atualizações reativas (`notifyListeners()`).
* **[`app_state_provider.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/controllers/app_state_provider.dart)**: Provê a instância de `AppState` para toda a árvore de widgets usando o mecanismo nativo `InheritedNotifier`.

---

### 🗄️ `lib/mock_data/` (Dados Simulados)

* **[`mock_database.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/mock_data/mock_database.dart)**: Banco de dados simulado em memória com dados pré-cadastrados (usuários e postagens com curtidas e comentários) para testes e navegação sem dependência de API.

---

### 📦 `lib/models/` (Modelos de Dados)

Define a estrutura de dados imutável do sistema:

* **[`user_model.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/models/user_model.dart)**: Representa um usuário (ID, nome, login/handle, foto de avatar, seguidores e estado de seguimento).
* **[`post_model.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/models/post_model.dart)**: Representa uma postagem (autor, conteúdo, data de criação, contagem de curtidas e respostas, além de vinculação a postagens pai quando for resposta).

---

### 🛣️ `lib/routes/` (Sistema de Rotas)

* **[`app_routes.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/routes/app_routes.dart)**: Mapeia e centraliza o gerador de rotas nomeadas (`onGenerateRoute`), permitindo a transição organizada entre todas as telas da aplicação.

---

### 🎨 `lib/theme/` (Design System)

* **[`app_theme.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/theme/app_theme.dart)**: Concentra a paleta de cores (Verde Esmeralda e Dourado), tipografia, sombras e estilização global dos componentes Material 3 do app.

---

### 📱 `lib/screens/` (Telas da Aplicação)

Cada arquivo nesta pasta representa uma tela interativa do Papacapim:

* **[`landing_page.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/landing_page.dart)**: Tela inicial de boas-vindas com botões de chamada para ação para Entrar ou Cadastrar-se.
* **[`login_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/login_screen.dart)**: Formulário de autenticação simulada de usuário.
* **[`register_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/register_screen.dart)**: Formulário de cadastro de novos usuários.
* **[`main_navigation_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/main_navigation_screen.dart)**: Container principal que gerencia as abas da barra inferior (`BottomNavigationBar`) e o botão flutuante para criar postagens.
* **[`feed_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/feed_screen.dart)**: Exibe a linha do tempo de postagens dividida em abas ("Seguindo" e "Recomendados").
* **[`search_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/search_screen.dart)**: Interface de busca e filtragem em tempo real de usuários e postagens.
* **[`profile_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/profile_screen.dart)**: Exibe o perfil do usuário (estatísticas, foto e postagens), permitindo visualizar o próprio perfil ou perfis terceiros.
* **[`edit_profile_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/edit_profile_screen.dart)**: Tela de alteração de dados do perfil (nome, senha, foto e zona de perigo para exclusão da conta).
* **[`create_post_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/create_post_screen.dart)**: Interface para digitação e publicação de novas postagens ou respostas a posts existentes.
* **[`camera_mock_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/camera_mock_screen.dart)**: Interface que simula a Câmera do smartphone para tirar foto de perfil.
* **[`gallery_mock_screen.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/screens/gallery_mock_screen.dart)**: Interface que simula a Galeria de imagens do dispositivo para seleção de avatar.

---

### 🧩 `lib/widgets/` (Componentes Reutilizáveis)

Componentes modulares de interface utilizados em várias telas:

* **[`custom_text_field.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/custom_text_field.dart)**: Campo de formulário padronizado com suporte a ícones, mensagens de erro e oculta/exibe senha.
* **[`empty_state_widget.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/empty_state_widget.dart)**: Componente visual de lista vazia quando nenhuma busca ou postagem for encontrada.
* **[`photo_source_bottom_sheet.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/photo_source_bottom_sheet.dart)**: Modal inferior para escolha entre Câmera ou Galeria para a foto de perfil.
* **[`post_card.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/post_card.dart)**: Cartão interativo que exibe a postagem com botões de curtir, responder e excluir.
* **[`primary_button.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/primary_button.dart)**: Botão de ação padronizado com suporte a indicador de carregamento (spinner).
* **[`profile_header.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/profile_header.dart)**: Cabeçalho do perfil contendo foto, contador de seguidores/seguindo e botões de seguir/editar.
* **[`search_bar_widget.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/search_bar_widget.dart)**: Barra de pesquisa reutilizável com botão de limpar filtro.
* **[`user_tile.dart`](file:///c:/Users/Pichau/projeto_papacapim/lib/widgets/user_tile.dart)**: Item de lista de usuário exibido nos resultados de busca com botão rápido de seguir/deixar de seguir.

---

## 🛠️ Como Executar o Projeto

1. Certifique-se de ter o **Flutter SDK** instalado na sua máquina (`flutter --version`).
2. Clone o repositório e navegue até a pasta do projeto.
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o aplicativo:
   ```bash
   flutter run
   ```
