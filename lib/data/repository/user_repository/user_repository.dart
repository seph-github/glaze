import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:glaze/core/services/supabase_services.dart';
import 'package:glaze/data/entities/recruiter_profile_entity.dart';

import 'package:glaze/data/models/profile/recruiter_profile_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/result_handler/results.dart';
import '../../models/profile/user_model.dart';
import '../auth_repository/auth_repository_provider.dart';

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
          final user = await ref.watch(authServiceProvider).getCurrentUser();

          final UserModel? userModel =
              await ref.watch(userRepositoryProvider).fetchUser(
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
          final userModel =
              await ref.watch(userRepositoryProvider).fetchUsersProfile(
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
class UpdateRecruiterProfileNotifier extends _$UpdateRecruiterProfileNotifier {
  @override
  FutureOr<Result<String, Exception>> build() async =>
      const Success<String, Exception>('');

  Future<Result<String, Exception>> updateRecruiterProfile({
    required String userId,
    required String fullName,
    String? email,
    String? phoneNumber,
    String? organization,
    List<String>? interests,
    File? identificationUrl,
  }) async {
    try {
      state = const AsyncLoading();

      final RecruiterProfileModel recruiterProfile = await ref
          .read(userRepositoryProvider)
          .fetchRecruiterProfile(id: userId);

      state = await AsyncValue.guard(
        () => ref.watch(userRepositoryProvider).updateRecruiterProfile(
              userId: userId,
              fullName: fullName,
              email: email,
              phoneNumber: phoneNumber,
              organization: organization,
              interests: interests,
              identificationUrl: identificationUrl,
              recruiterProfileEntity: recruiterProfile,
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
  FutureOr<RecruiterProfileModel?> build(String id) =>
      fetchRecruiterProfile(id: id);

  Future<RecruiterProfileModel> fetchRecruiterProfile(
      {required String id}) async {
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

  FutureOr<UserModel?> fetchUser({required String? id}) async {
    try {
      if (id == null) return null;

      final response = await supabaseService.withReturnValuesRpc(
        fn: 'find_user_by_id',
        params: {'params_user_id': id},
      );

      return UserModel.fromJson(response.first);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  Future<UserModel?> fetchUsersProfile({required String id}) async {
    try {
      final response = await supabaseService.withReturnValuesRpc(
          fn: 'find_user_by_id', params: {'params_user_id': id});

      return UserModel.fromJson(response.first);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    return null;
  }

  Future<RecruiterProfileModel> fetchRecruiterProfile(
      {required String? id}) async {
    try {
      final response = await supabaseService.select(
        table: 'recruiters',
        filterColumn: 'user_id',
        filterValue: id,
      );

      final recruiterProfile = response.singleWhere(
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

  Future<Result<String, Exception>> updateRecruiterProfile({
    required String userId,
    required String fullName,
    String? email,
    String? phoneNumber,
    String? organization,
    List<String>? interests,
    File? identificationUrl,
    required RecruiterProfileModel recruiterProfileEntity,
  }) async {
    try {
      final urlResult = await supabaseService.upload(
        file: identificationUrl!,
        userId: userId,
        bucketName: 'recruiter-identification-images',
      );

      if (urlResult is Failure<String, Exception>) {
        final exception = urlResult.error; // Extract the actual exception
        return Failure<String, Exception>(exception);
      }

      if (urlResult is Success<String, Exception>) {
        final identificationUrl = urlResult.value;

        final RecruiterProfileEntity body = RecruiterProfileEntity(
          fullName: fullName,
          username: recruiterProfileEntity.username,
          email: email,
          phoneNumber: phoneNumber,
          organization: organization,
          interests: interests,
          identificationUrl: identificationUrl,
          isVerified: recruiterProfileEntity.isVerified,
          subscriptionStatus: recruiterProfileEntity.subscriptionStatus,
          subscriptionStartedAt: recruiterProfileEntity.subscriptionStartedAt,
          subscriptionExpiresAt: recruiterProfileEntity.subscriptionExpiresAt,
          updatedAt: DateTime.now(),
          createdAt: recruiterProfileEntity.createdAt,
        );

        await supabaseService.update(
          table: 'recruiters',
          data: body.toMap(),
          id: recruiterProfileEntity.id,
        );

        return const Success<String, Exception>(
            'Profile Successfully Created!');
      }

      return Failure<String, Exception>(urlResult as Exception);
    } catch (e) {
      return Failure<String, Exception>(e as Exception);
    }
  }
}
