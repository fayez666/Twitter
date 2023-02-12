import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter/apis/storage_api.dart';
import 'package:twitter/apis/tweet_api.dart';
import 'package:twitter/apis/user_api.dart';
import 'package:twitter/features/notificaions/controller/notification_controller.dart';
import 'package:twitter/models/user_model.dart';

import '../../../core/enums/notification_type_enum.dart';
import '../../../core/utils.dart';
import '../../../models/tweet_model.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageProvider),
      userAPI: ref.watch(userAPIProvider),
      notificationController:
          ref.watch(notificationControllerProvider.notifier));
});
final gerUsertweetsProvider = FutureProvider.family((ref, String uid) {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);

  return userAPI.getLastestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  UserProfileController(
      {required TweetAPI tweetAPI,
      required StorageAPI storageAPI,
      required NotificationController notificationController,
      required UserAPI userAPI})
      : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);

  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;

  Future<List<Tweet>> getUserTweets(String uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImage([bannerFile]);
      userModel = userModel.copyWith(bannerPic: bannerUrl[0]);
    }

    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImage([profileFile]);
      userModel = userModel.copyWith(profilePic: profileUrl[0]);
    }

    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
        (l) => showSnackBar(context, l.message), (r) => Navigator.pop(context));
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    if (currentUser.following.contains(user.uId)) {
      user.followers.remove(currentUser.uId);
      currentUser.following.remove(user.uId);
    } else {
      user.followers.add(currentUser.uId);
      currentUser.following.add(user.uId);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);

    final res = await _userAPI.followUser(user);
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      final res2 = await _userAPI.followUser(user);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
          text: '${currentUser.name} followed you !',
          postId: '',
          notificationType: NotificationType.follow,
          uid: user.uId,
        );
      });
    });
  }
}
