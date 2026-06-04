import 'package:flutter/material.dart';
import 'package:memora_mobile/services/user_service.dart';

import 'core/api_client.dart';
import 'core/token_storage.dart';
import 'models/app_user.dart';
import 'pages/home_page.dart';
import 'pages/splash_page.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/entry_service.dart';
import 'services/graph_service.dart';
import 'services/user_service.dart';

void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);

  runApp(
    AppDependencies(
      tokenStorage: tokenStorage,
      authService: AuthService(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      ),
      entryService: EntryService(apiClient: apiClient),
      chatService: ChatService(apiClient: apiClient),
      graphService: GraphService(apiClient: apiClient),
      userService: UserService(apiClient: apiClient),
      child: const MemoraApp(),
    ),
  );
}

class AppDependencies extends InheritedWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final EntryService entryService;
  final ChatService chatService;
  final GraphService graphService;
  final UserService userService;

  const AppDependencies({
    super.key,
    required this.tokenStorage,
    required this.authService,
    required this.entryService,
    required this.chatService,
    required this.graphService,
    required this.userService,
    required super.child,
  });

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(scope != null, 'AppDependencies not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) => false;
}

class MemoraApp extends StatelessWidget {
  const MemoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memora Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final args = settings.arguments;

          if (args is! AppUser) {
            return MaterialPageRoute(
              builder: (_) => const SplashPage(),
            );
          }

          return MaterialPageRoute(
            builder: (_) => HomePage(user: args),
          );
        }

        return null;
      },
    );
  }
}
