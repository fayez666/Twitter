import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter/common/common.dart';
import 'package:twitter/constants/constants.dart';
import 'package:twitter/features/user_profile/controller/user_profile_controller.dart';
import 'package:twitter/models/user_model.dart';

import '../widgits/user_profile.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(
        builder: (context) => UserProfileView(
          userModel: userModel,
        ),
      );
  final UserModel userModel;
  const UserProfileView({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel copyOfUser = userModel;
    return Scaffold(
      body: ref.watch(getLatestUserProfileDataProvider).when(
            data: (data) {
              if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.usersCollection}.documents.${userModel.uId}.update')) {
                copyOfUser = UserModel.fromMap(data.payload);
              }
              return UserProfile(
                user: copyOfUser,
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () {
              return UserProfile(
                user: copyOfUser,
              );
            },
          ),
    );
  }
}
