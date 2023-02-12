import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:twitter/constants/constants.dart';
import 'package:twitter/features/auth/controller/auth_controller.dart';
import 'package:twitter/features/tweet/widgets/tweet_card.dart';
import 'package:twitter/features/user_profile/widgits/follow_count.dart';
import 'package:twitter/models/user_model.dart';
import 'package:twitter/theme/pallete.dart';

import '../../../common/common.dart';
import '../controller/user_profile_controller.dart';
import '../view/edit_profile_view.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                          child: user.bannerPic.isEmpty
                              ? Container(
                                  color: Pallete.blueColor,
                                )
                              : Image.network(
                                  user.bannerPic,
                                  fit: BoxFit.fitWidth,
                                )),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (currentUser.uId == user.uId) {
                              Navigator.push(context, EditProfileView.route());
                            } else {
                              ref
                                  .read(userProfileControllerProvider.notifier)
                                  .followUser(
                                    user: user,
                                    context: context,
                                    currentUser: currentUser,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                    color: Pallete.whiteColor, width: 1.5),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25)),
                          child: Text(
                            currentUser.uId == user.uId
                                ? "Edit Profile"
                                : currentUser.following.contains(user.uId)
                                    ? "Unfollow"
                                    : "Follow",
                            style: const TextStyle(color: Pallete.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            if (user.isTwitterBlue)
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: SvgPicture.asset(
                                    AssetsConstants.verifiedIcon),
                              ),
                          ],
                        ),
                        Text(
                          "@${user.name}",
                          style: const TextStyle(
                              fontSize: 17, color: Pallete.greyColor),
                        ),
                        Text(
                          user.bio,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            FollowCount(
                              count: user.following.length,
                              text: 'Following',
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            FollowCount(
                              count: user.followers.length,
                              text: 'Followers',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const Divider(
                          color: Pallete.whiteColor,
                        )
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: ref.watch(gerUsertweetsProvider(user.uId)).when(
                  data: (tweets) {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return TweetCard(tweet: tweet);
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return ErrorText(error: error.toString());
                  },
                  loading: () => const Loader(),
                ),
          );
  }
}
