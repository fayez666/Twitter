import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter/apis/storage_api.dart';
import 'package:twitter/apis/tweet_api.dart';
import 'package:twitter/core/enums/notification_type_enum.dart';
import 'package:twitter/core/enums/tweet_type_enum.dart';
import 'package:twitter/core/utils.dart';
import 'package:twitter/features/auth/controller/auth_controller.dart';
import 'package:twitter/features/notificaions/controller/notification_controller.dart';
import 'package:twitter/models/tweet_model.dart';
import 'package:twitter/models/user_model.dart';

final tweetControllerProvider =
    StateNotifierProvider<TweetController, bool>((ref) {
  return TweetController(
      ref: ref,
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageProvider),
      notificationController:
          ref.watch(notificationControllerProvider.notifier));
});

final getTweetsProvider = FutureProvider((ref) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getTweets();
});

final getRepliedToTweetsProvider = FutureProvider.family((ref, Tweet tweet) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getRepliesToTweet(tweet);
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

final getTweetByIdProvider = FutureProvider.family((ref, String id) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getTweetById(id);
});
final getTweetsByHashtahProvider = FutureProvider.family((ref, String hashtag) {
  final tweetController = ref.watch(tweetControllerProvider.notifier);

  return tweetController.getTweetsByHashtag(hashtag);
});

class TweetController extends StateNotifier<bool> {
  final Ref _ref;
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;

  TweetController(
      {required Ref ref,
      required TweetAPI tweetAPI,
      required StorageAPI storageAPI,
      required NotificationController notificationController})
      : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);
  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  void likeTweet(Tweet tweet, UserModel user) async {
    List<String> likes = tweet.likes;
    if (tweet.likes.contains(user.uId)) {
      likes.remove(user.uId);
    } else {
      likes.add(user.uId);
    }
    tweet = tweet.copyWith(likes: likes);
    final res = await _tweetAPI.likeTweet(tweet);
    res.fold((l) => null, (r) {
      _notificationController.createNotification(
        text: '${user.name} liked your tweet',
        postId: tweet.id,
        notificationType: NotificationType.like,
        uid: tweet.uid,
      );
    });
  }

  void reshareTweet(
      Tweet tweet, UserModel currentUser, BuildContext context) async {
    tweet = tweet.copyWith(
      retweetedBy: currentUser.name,
      likes: [],
      commentIds: [],
      reshareCount: tweet.reshareCount + 1,
    );
    final res = await _tweetAPI.updateReshareCount(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      tweet.copyWith(
          id: ID.unique(), reshareCount: 0, tweetedAt: DateTime.now());
      final res2 = await _tweetAPI.shareTweet(tweet);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
          text: '${currentUser.name} reshare your tweet',
          postId: tweet.id,
          notificationType: NotificationType.retweet,
          uid: tweet.uid,
        );
        showSnackBar(context, "Retweeted");
      });
    });
  }

  void shareTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, "Please enter text");
      return;
    }
    if (images.isNotEmpty) {
      _shareImageTweet(
          images: images,
          text: text,
          context: context,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    } else {
      _shareTextTweet(
          text: text,
          context: context,
          repliedTo: repliedTo,
          repliedToUserId: repliedToUserId);
    }
  }

  void _shareImageTweet({
    required List<File> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImage(images);
    Tweet tweet = Tweet(
        text: text,
        hashtags: hashtags,
        link: link,
        imageLinks: imageLinks,
        uid: user.uId,
        tweetType: TweetType.image,
        tweetedAt: DateTime.now(),
        likes: const [],
        commentIds: const [],
        id: '',
        reshareCount: 0,
        retweetedBy: '',
        repliedTo: repliedTo);

    final res = await _tweetAPI.shareTweet(tweet);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
          text: '${user.name} replied to your tweet',
          postId: r.$id,
          notificationType: NotificationType.reply,
          uid: repliedToUserId,
        );
      }
    });
    state = false;
  }

  Future<List<Tweet>> getRepliesToTweet(Tweet tweet) async {
    final documents = await _tweetAPI.getRepliesToTweet(tweet);
    return documents.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<List<Tweet>> getTweetsByHashtag(String hashtag) async {
    final documents = await _tweetAPI.getTweetsByHashtag(hashtag);
    return documents.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromText(text);
    String link = _getLinkFromText(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    Tweet tweet = Tweet(
        text: text,
        hashtags: hashtags,
        link: link,
        imageLinks: const [],
        uid: user.uId,
        tweetType: TweetType.text,
        tweetedAt: DateTime.now(),
        likes: const [],
        commentIds: const [],
        id: '',
        reshareCount: 0,
        retweetedBy: '',
        repliedTo: repliedTo);

    final res = await _tweetAPI.shareTweet(tweet);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
          text: '${user.name} replied to your tweet',
          postId: r.$id,
          notificationType: NotificationType.reply,
          uid: repliedToUserId,
        );
      }
    });
    state = false;
  }

  String _getLinkFromText(String text) {
    String link = "";
    List<String> wordInSentence = text.split(' ');
    for (String word in wordInSentence) {
      if (word.startsWith("https://") || word.startsWith("www.")) {
        link = word;
      }
    }
    return link;
  }

  List<String> _getHashtagsFromText(String text) {
    List<String> hashTags = [];
    List<String> wordInSentence = text.split(' ');
    for (String word in wordInSentence) {
      if (word.startsWith("#")) {
        hashTags.add(word);
      }
    }
    return hashTags;
  }

  Future<Tweet> getTweetById(String id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return Tweet.fromMap(tweet.data);
  }
}
