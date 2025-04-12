import 'dart:io';

import 'package:glaze/feature/profile/models/recruiter_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/enum/profile_type.dart';
import '../../../core/services/storage_services.dart';
import '../models/profile.dart';

class ProfileServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final StorageServices _storageService = StorageServices();

  Future<Profile?> fetchUserProfile(String id) async {
    try {
      if (id.isEmpty) return null;

      final response = await _supabaseClient.rpc(
        'find_user_by_id',
        params: {'params_user_id': id},
      );

      final raw = response as List<dynamic>;

      return Profile.fromJson(raw.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<RecruiterProfile?> fetchRecruiterProfile(String id) async {
    try {
      if (id.isEmpty) return null;

      final response = await _supabaseClient
          .from('recruiters')
          .select()
          .eq('user_id', id)
          .maybeSingle(); // Use maybeSingle to handle cases where no rows are returned

      if (response == null) return null; // Handle null response gracefully

      return RecruiterProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setFlagsCompleted(
    String id, {
    required String table,
    Map<String, dynamic>? data,
    required String column,
  }) async {
    try {
      await _supabaseClient
          .from(table)
          .update(
            data ?? {},
          )
          .eq(column, id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(
    String id, {
    required String fullName,
    required String phoneNumber,
    required List<String> interestList,
    required String organization,
    required File? profileImage,
    required File? identification,
    required ProfileType role,
  }) async {
    try {
      String? identificationUrl;
      String? profileImageUrl;

      if (profileImage != null) {
        profileImageUrl = await _storageService.upload(
          id: id,
          bucketName: 'profile-images',
          file: profileImage,
        );
      }

      final profileEntity = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'interests': interestList,
        'profile_image_url': profileImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
        'is_completed_profile': true,
      }..removeWhere((key, value) => value == null);

      final recruiterEntity = {
        'organization': organization,
        'identification_url': identificationUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }..removeWhere((key, value) => value == null);

      if (role == ProfileType.recruiter) {
        if (identification != null) {
          identificationUrl = await _storageService.upload(
            id: id,
            bucketName: 'recruiter-identification-images',
            file: identification,
          );
        }

        await _supabaseClient
            .from('reqruiters')
            .update(recruiterEntity)
            .eq('user_id', id);
      }

      await _supabaseClient.from('profiles').update(profileEntity).eq('id', id);
    } catch (e) {
      print('ProfileServices.updateProfile: $e');
      rethrow;
    }
  }
}
