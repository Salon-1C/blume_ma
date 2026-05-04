import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/shell/presentation/screens/main_shell.dart';
import 'features/shell/presentation/screens/profile_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/explore/presentation/screens/channel_detail_screen.dart';
import 'features/courses/presentation/screens/courses_screen.dart';
import 'features/streams/presentation/screens/live_player_screen.dart';
import 'features/recordings/presentation/screens/recordings_screen.dart';
import 'features/recordings/presentation/screens/recording_player_screen.dart';
import 'shared/theme/app_theme.dart';

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

// Notifies GoRouter when auth state changes so redirects re-evaluate
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoading = authState.isLoading;
      final user = authState.valueOrNull;
      final loc = state.matchedLocation;

      if (isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      final onPublicPage =
          loc == '/splash' || loc == '/login' || loc == '/registro' || loc == '/recuperar';

      if (user == null && !onPublicPage) return '/login';
      if (user != null && (loc == '/login' || loc == '/registro')) {
        return '/explorar';
      }
      if (user != null && loc == '/splash') return '/explorar';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/registro', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/recuperar', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/clase/:id/live',
        parentNavigatorKey: _rootNavKey,
        builder: (_, s) => LivePlayerScreen(streamId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/grabacion/:id',
        parentNavigatorKey: _rootNavKey,
        builder: (_, s) =>
            RecordingPlayerScreen(recordingId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/canal/:id',
        parentNavigatorKey: _rootNavKey,
        builder: (_, s) =>
            ChannelDetailScreen(channelId: s.pathParameters['id']!),
      ),
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/explorar', builder: (_, __) => const ExploreScreen()),
          GoRoute(path: '/cursos', builder: (_, __) => const CoursesScreen()),
          GoRoute(
              path: '/grabaciones', builder: (_, __) => const RecordingsScreen()),
          GoRoute(path: '/perfil', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

class BlumeApp extends ConsumerWidget {
  const BlumeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Blume',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
