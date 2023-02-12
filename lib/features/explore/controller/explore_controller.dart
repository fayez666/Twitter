import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter/apis/user_api.dart';
import 'package:twitter/models/user_model.dart';

final exploreControllerProvider = StateNotifierProvider((ref) {
  return ExploreController(
    userAPI: ref.watch(userAPIProvider),
  );
});

final searchUserProvider = FutureProviderFamily((ref, String name) {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.searchUser(name);
});

class ExploreController extends StateNotifier<bool> {
  ExploreController({required UserAPI userAPI})
      : _userAPI = userAPI,
        super(false);

  final UserAPI _userAPI;

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
