import 'dart:developer';
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

      log('ProfileServices.fetchUserProfile: $raw');

      return Profile.fromJson(raw.first);
    } on PostgrestException catch (e) {
      log('Error fetching user profile: ${e.message}');
      rethrow;
    } catch (e) {
      log('Error fetching user profile: $e');
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
    } on PostgrestException catch (e) {
      log('Error fetching user profile: ${e.message}');
      rethrow;
    } catch (e) {
      log('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<RecruiterProfile?> fetchRecruiterProfile(String id) async {
    try {
      if (id.isEmpty) return null;

      final response = await _supabaseClient.from('recruiters').select().eq('user_id', id).maybeSingle(); // Use maybeSingle to handle cases where no rows are returned

      if (response == null) return null; // Handle null response gracefully

      return RecruiterProfile.fromJson(response);
    } on PostgrestException catch (e) {
      log('Error fetching recruiter profile: ${e.message}');
      rethrow;
    } catch (e) {
      log('Error fetching recruiter profile: $e');
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
    } on PostgrestException catch (e) {
      log('Error setting flags completed: ${e.message}');
      rethrow;
    } catch (e) {
      log('Error setting flags completed: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String id,
    String? bio,
    String? username,
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
          fileName: id,
        );
      }

      final ProfileEntity profileEntity = ProfileEntity(
        id: id,
        username: username,
        bio: bio,
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
            fileName: id,
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
    } on PostgrestException catch (e) {
      log('Error updating profile: ${e.message}');
      rethrow;
    } on StorageException catch (e) {
      log('Error uploading file: ${e.message}');
      rethrow;
    } on PathNotFoundException {
      log('Error: Path not found');
      rethrow;
    } on FileSystemException catch (e) {
      log('Error: File system exception - ${e.message}');
      rethrow;
    } catch (e) {
      log('Error updating profile: $e');
      rethrow;
    }
  }

  // Future<UserInteractions> getUserInteractions(String id) async {
  //   try {
  //     final response = await _supabaseClient.rpc(
  //       'get_user_social_stats',
  //       params: {
  //         'params_user_id': id,
  //       },
  //     );

  //     if (response == null || response is! List<dynamic>) {
  //       return const UserInteractions(
  //         followers: [],
  //         following: [],
  //         glazes: [],
  //       );
  //     }

  //     // Parse the response as a List<dynamic> and extract the first map
  //     final raw = response.first as Map<String, dynamic>;

  //     // Parse followers
  //     final followers = (raw['followers'] as List<dynamic>?)?.map((e) => UserInteract.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  //     // Parse following
  //     final following = (raw['following'] as List<dynamic>?)?.map((e) => UserInteract.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  //     // Parse glazes
  //     final glazes = (raw['glazes'] as List<dynamic>?)?.map((e) => Glaze.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  //     final userInteractions = UserInteractions(
  //       followers: followers,
  //       following: following,
  //       glazes: glazes,
  //     );

  //     return userInteractions;
  //   } catch (e, stackTrace) {
  //     log('get user interactions error: $e', stackTrace: stackTrace);
  //     rethrow;
  //   }
  // }
}
