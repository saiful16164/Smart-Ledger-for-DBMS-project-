import 'package:smart_ledger/core/constants/supabase_constants.dart';
import 'package:smart_ledger/features/settings/domain/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from(SupabaseConstants.tableProfiles)
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      // If profile doesn't exist, return null or throw.
      // Often profiles are created via trigger. If not found, return null.
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
  }) async {
    final updates = <String, dynamic>{'id': userId};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;

    await _supabase.from(SupabaseConstants.tableProfiles).upsert(updates);
  }
}
