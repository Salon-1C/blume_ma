import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/demo/demo_data.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // Skip real API call if demo mode is already active
    if (ref.read(demoModeProvider)) return DemoData.user;
    try {
      return await ref.read(authRepositoryProvider).getMe();
    } catch (_) {
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).login(email, password);
    });
  }

  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).register(fullName, email, password);
    });
  }

  Future<void> loginAsDemo() async {
    ref.read(demoModeProvider.notifier).state = true;
    state = AsyncData(DemoData.user);
  }

  Future<void> logout() async {
    ref.read(demoModeProvider.notifier).state = false;
    if (!ref.read(demoModeProvider)) {
      await ref.read(authRepositoryProvider).logout();
    }
    state = const AsyncData(null);
  }

  Future<void> completeOnboarding(String username, String role) async {
    await ref.read(authRepositoryProvider).completeOnboarding(username, role);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).getMe();
    });
  }

  UserModel? get currentUser => state.valueOrNull;

  String? get errorMessage {
    return state.error != null ? extractError(state.error!).message : null;
  }
}
