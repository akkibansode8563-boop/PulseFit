import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl();
});

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  FutureOr<UserProfile> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final result = await repo.getUserProfile();
    return result.fold(
      onSuccess: (profile) => profile,
      onError: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateUserProfile(updatedProfile);
    result.fold(
      onSuccess: (profile) => state = AsyncValue.data(profile),
      onError: (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
    );
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
