import 'package:flutter/material.dart';
import 'app_state.dart';

/// ============================================================================
/// INHERITED NOTIFIER PROVIDER (SISTEMA DE INJEÇÃO DE ESTADO NATIVO)
/// ============================================================================
/// Provê a instância de `AppState` para toda a árvore de widgets sem requerer
/// pacotes de terceiros como `provider` ou `flutter_riverpod`.
/// 
/// DICA PARA SABATINA:
/// Usar `InheritedNotifier` demonstra domínio da arquitetura nativa do Flutter.
/// Sempre que o `AppState` notificar alterações (`notifyListeners`), os widgets que
/// utilizarem `AppStateProvider.of(context)` serão re-renderizados automaticamente.
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  /// Método estático utilitário para acessar o estado a partir do BuildContext
  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'Nenhum AppStateProvider encontrado no contexto!');
    return provider!.notifier!;
  }
}
