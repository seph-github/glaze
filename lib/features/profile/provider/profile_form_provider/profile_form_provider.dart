import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/profile/provider/profile_provider/profile_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_form_provider.freezed.dart';
part 'profile_form_provider.g.dart';

@freezed
abstract class ProfileFormState with _$ProfileFormState {
  const factory ProfileFormState({
    @Default(null) String? fullname,
    @Default(null) String? email,
    @Default(null) String? code,
    @Default(null) String? phone,
    @Default(null) String? organization,
    @Default([]) List<String> interestList,
    @Default(null) File? profileImage,
    @Default(null) File? identificationImage,
  }) = _ProfileFormState;

  const ProfileFormState._();
}

@Riverpod(keepAlive: true)
class ProfileFormNotifier extends _$ProfileFormNotifier {
  TextEditingController fullnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  List<String>? interestList = [];
  File? profileImage;
  File? identificationImage;

  @override
  ProfileFormState build() {
    ref.listen(profileNotifierProvider, (prev, next) {
      if (next.profile != null && next.profile != prev?.profile) {
        fullnameController.text = next.profile?.fullName ?? '';
        emailController.text = next.profile?.email ?? '';
        codeController.text = next.profile?.countryCode ?? '';
        phoneController.text = next.profile?.phoneNumber ?? '';

        state = state.copyWith(
          fullname: fullnameController.text.trim(),
          email: emailController.text.trim(),
          code: codeController.text.trim(),
          phone: phoneController.text.trim(),
        );
      }
    });

    return const ProfileFormState(
      fullname: '',
      email: '',
      code: '',
      phone: '',
      organization: '',
      interestList: [],
      profileImage: null,
      identificationImage: null,
    );
  }

  void syncControllerToState() {
    state = state.copyWith(
      fullname: fullnameController.text.trim(),
      email: emailController.text.trim(),
      code: codeController.text.trim(),
      phone: phoneController.text.trim(),
      organization: organizationController.text.trim(),
      interestList: interestList ?? [],
      profileImage: profileImage,
      identificationImage: identificationImage,
    );
  }

  void clearForm() {
    fullnameController.clear();
    emailController.clear();
    codeController.clear();
    phoneController.clear();
    organizationController.clear();
    interestList = [];
    profileImage = null;
    identificationImage = null;
    syncControllerToState();
  }

  void setProfileImage(File? file) {
    profileImage = file;
    syncControllerToState();
  }

  void setIdentificationFile(File? file) {
    identificationImage = file;
    syncControllerToState();
  }

  void clearProfileImage() {
    profileImage = null;
    syncControllerToState();
  }

  void clearIdenticationImage() {
    identificationImage = null;
    syncControllerToState();
  }

  bool get hasChanges {
    return fullnameController.text.isNotEmpty || emailController.text.isNotEmpty || codeController.text.isNotEmpty || phoneController.text.isNotEmpty || interestList != null || profileImage != null || identificationImage != null;
  }
}
