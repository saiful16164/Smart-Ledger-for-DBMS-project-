import 'package:smart_ledger/features/settings/data/supabase_profile_repository.dart';
import 'package:smart_ledger/features/settings/domain/models/profile_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_controller.g.dart';

@riverpod
SupabaseProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return SupabaseProfileRepository(Supabase.instance.client);
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<ProfileModel?> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return ref.watch(profileRepositoryProvider).getProfile(user.id);
  }

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Don't set state to loading to avoid UI flicker
    state = await AsyncValue.guard(() async {
      // Update Database Profile (primary source of truth)
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(userId: user.id, fullName: fullName, phone: phone);

      // Note: We intentionally don't update auth user metadata here
      // because it triggers auth state changes that cause UI flicker.
      // The profiles table is the source of truth for user info.

      return ref.refresh(profileRepositoryProvider).getProfile(user.id);
    });
  }
}
