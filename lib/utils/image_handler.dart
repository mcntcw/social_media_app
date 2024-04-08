// ignore_for_file: use_build_context_synchronously

import 'package:social_media_app/blocs/edit_user_data/edit_user_data_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageHandler {
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadProfilePicture(
    BuildContext context,
    String userId,
  ) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
      imageQuality: 100,
    );

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Profile picture',
            toolbarColor: Theme.of(context).colorScheme.background,
            toolbarWidgetColor: Theme.of(context).colorScheme.onBackground,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Profile picture',
          ),
        ],
      );

      if (croppedFile != null) {
        context.read<EditUserDataBloc>().add(ChangeProfilePicture(croppedFile.path, userId));
      }
    }
  }

  Future<String?> uploadPostPicture(BuildContext context) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    String? imagePath = image?.path;
    return imagePath;
  }
}
