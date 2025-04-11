import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/core/services/supabase_services.dart';

import 'package:glaze/data/models/profile/recruiter_profile_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/result_handler/results.dart';
import '../../../feature/auth/services/auth_services.dart';
import '../../models/profile/user_model.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return UserRepository(supabaseService: supabaseService);
}

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<UserModel?> build() async {
    return fetchUser();
  }

  FutureOr<UserModel?> fetchUser() async {
    try {
      state = const AsyncLoading();

      state = await AsyncValue.guard(
        () async {
          final user = AuthServices().currentUser;

          final UserModel? userModel = await ref.watch(userRepositoryProvider).fetchUser(
                id: user?.id,
              );

          return userModel;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }

    return state.value;
  }
}

@riverpod
class GetUserProfileNotifier extends _$GetUserProfileNotifier {
  @override
  FutureOr<UserModel?> build(String id) async => fetchUsersProfile(id: id);

  FutureOr<UserModel?> fetchUsersProfile({required String id}) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          final userModel = await ref.watch(userRepositoryProvider).fetchUsersProfile(
                id: id,
              );

          return userModel;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
      );
    }
    return state.value;
  }
}

@riverpod
class ProfileCompletionNotifier extends _$ProfileCompletionNotifier {
  @override
  FutureOr<Result<String, Exception>> build() async => const Success<String, Exception>('');

  Future<Result<String, Exception>> updateRecruiterProfile({
    required String userId,
    required String fullName,
    String? email,
    String? phoneNumber,
    String? organization,
    List<String>? interests,
    File? identificationUrl,
    File? profileImage,
  }) async {
    try {
      state = const AsyncLoading();

      final RecruiterProfileModel? recruiterProfile = await ref.read(userRepositoryProvider).fetchRecruiterProfile(id: userId);

      if (recruiterProfile == null) {
        return Failure<String, Exception>(
          Exception('Recruiter profile not found'),
        );
      }

      state = await AsyncValue.guard(
        () => ref.watch(userRepositoryProvider).profileCompletion(
              userId: userId,
              fullName: fullName,
              email: email,
              phoneNumber: phoneNumber,
              organization: organization,
              interests: interests,
              identificationUrl: identificationUrl,
              profileImage: profileImage,
            ),
      );

      if (state.value is Failure<String, Exception>) {
        final error = state.value as Failure<String, Exception>;
        return Failure<String, Exception>(error.error);
      }

      return const Success<String, Exception>('');
    } on Exception catch (e) {
      return Failure<String, Exception>(e);
    }
  }
}

@riverpod
class RecruiterProfileNotifier extends _$RecruiterProfileNotifier {
  @override
  FutureOr<RecruiterProfileModel?> build(String id) => fetchRecruiterProfile(id: id);

  Future<RecruiterProfileModel> fetchRecruiterProfile({required String id}) async {
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(
        () async {
          return ref.watch(userRepositoryProvider).fetchRecruiterProfile(
                id: id,
              );
        },
      );
      return Future.value(state.value);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return Future.error(e, stackTrace);
    }
  }
}

class UserRepository {
  const UserRepository({required this.supabaseService});

  final SupabaseService supabaseService;

  FutureOr<UserModel?> fetchUser({String? id}) async {
    try {
      if (id == null) return null;

      final response = await supabaseService.withReturnValuesRpc(
        fn: 'find_user_by_id',
        params: {
          'params_user_id': id
        },
      );

      return UserModel.fromJson(response.first);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  Future<UserModel?> fetchUsersProfile({String? id}) async {
    try {
      final response = await supabaseService.withReturnValuesRpc(fn: 'find_user_by_id', params: {
        'params_user_id': id
      });

      return UserModel.fromJson(response.first);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  Future<RecruiterProfileModel?> fetchRecruiterProfile({String? id}) async {
    try {
      final response = await supabaseService.select(
        table: 'recruiters',
        filterColumn: 'user_id',
        filterValue: id,
      );

      final Map<String, dynamic> recruiterProfile = response.singleWhere(
        (element) => element['user_id'] == id,
        orElse: () => {},
      );

      return RecruiterProfileModel.fromJson(recruiterProfile);
    } catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }

  Future<void> setFlagsCompleted({
    required String id,
    required Map<String, dynamic> data,
    required String table,
  }) async {
    try {
      await supabaseService.update(
        table: table,
        id: id,
        data: data,
      );
    } catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }

  Future<Result<String, Exception>> profileCompletion({
    required String userId,
    required String fullName,
    String? email,
    String? phoneNumber,
    String? organization,
    List<String>? interests,
    File? identificationUrl,
    File? profileImage,
  }) async {
    try {
      String recruiterIdUrl = '';

      if (identificationUrl != null) {
        final identificationUrlResult = await supabaseService.upload(
          file: identificationUrl,
          userId: userId,
          bucketName: 'recruiter-identification-images',
        );

        if (identificationUrlResult is Success<String, Exception>) {
          recruiterIdUrl = identificationUrlResult.value;
        } else {
          final exception = identificationUrlResult as Failure<String, Exception>;
          return Failure<String, Exception>(exception.error);
        }
      }

      if (profileImage == null) {
        return Failure<String, Exception>(Exception('User ID is null'));
      } else {
        final profileImageUrl = await supabaseService.upload(
          file: profileImage,
          userId: userId,
          bucketName: 'profile-images',
        );

        if (profileImageUrl is Failure<String, Exception>) {
          final exception = profileImageUrl.error;
          return Failure<String, Exception>(exception);
        } else {
          if (profileImageUrl is Success<String, Exception>) {
            final paramsProfileImageUrl = profileImageUrl.value;

            final Map<String, dynamic> profileParams = {
              'full_name': fullName,
              'phone_number': phoneNumber,
              'interests': interests,
              'profile_image_url': paramsProfileImageUrl,
            };

            await supabaseService.update(
              table: 'profiles',
              id: userId,
              data: profileParams,
            );
          }
        }
      }
      return const Success<String, Exception>('Profile Created Successfully');
    } catch (e) {
      print('Exception: $e');
      return Failure<String, Exception>(e as Exception);
    }
  }
}
