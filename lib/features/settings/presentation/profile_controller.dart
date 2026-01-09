import 'package:dbms_project/features/settings/data/supabase_profile_repository.dart';
import 'package:dbms_project/features/settings/domain/models/profile_model.dart';
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

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(userId: user.id, fullName: fullName, phone: phone);
      return ref.refresh(profileRepositoryProvider).getProfile(user.id);
    });
  }
}
