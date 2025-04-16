import 'dart:io';

import 'package:glaze/feature/profile/entity/profile_entity.dart';
import 'package:glaze/feature/profile/models/recruiter_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/enum/profile_type.dart';
import '../../../core/services/storage_services.dart';
import '../entity/recruiter_profile_entity.dart';
import '../models/profile.dart';

class ProfileServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final StorageServices _storageService = StorageServices();

  Future<Profile?> fetchUserProfile(String id) async {
    try {
      if (id.isEmpty) return null;

      final response = await _supabaseClient.rpc(
        'find_user_by_id',
        params: {
          'params_user_id': id
        },
      );

      final raw = response as List<dynamic>;

      // log('ProfileServices.fetchUserProfile: $raw');

      return Profile.fromJson(raw.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<Profile?> viewUserProfile(String id) async {
    try {
      if (id.isEmpty) return null;

      final response = await _supabaseClient.rpc(
        'find_user_by_id',
        params: {
          'params_user_id': id
        },
      );

      final raw = response as List<dynamic>;

      // log('ProfileServices.fetchUserProfile: $raw');

      return Profile.fromJson(raw.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<RecruiterProfile?> fetchRecruiterProfile(String id) async {
    try {
      if (id.isEmpty) return null;

      final response = await _supabaseClient.from('recruiters').select().eq('user_id', id).maybeSingle(); // Use maybeSingle to handle cases where no rows are returned

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

  Future<void> updateProfile({
    required String id,
    String? email,
    String? fullName,
    String? phoneNumber,
    List<String>? interestList,
    String? organization,
    File? profileImage,
    File? identification,
    ProfileType? role,
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

      final ProfileEntity profileEntity = ProfileEntity(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
        isCompletedProfile: true,
        interests: interestList,
      );

      final RecruiterProfileEntity recruiterProfileEntity = RecruiterProfileEntity(
        id: id,
        organization: organization,
        identificationUrl: identificationUrl,
        updatedAt: DateTime.now(),
      );

      if (role == ProfileType.recruiter) {
        if (identification != null) {
          identificationUrl = await _storageService.upload(
            id: id,
            bucketName: 'recruiter-identification-images',
            file: identification,
          );
        }

        await _supabaseClient
            .from('recruiters')
            .update(
              recruiterProfileEntity.toMap(),
            )
            .eq('user_id', id);
      }

      await _supabaseClient
          .from('profiles')
          .update(
            profileEntity.toMap(),
          )
          .eq('id', id);
    } catch (e) {
      rethrow;
    }
  }
}
