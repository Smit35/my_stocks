import '../datasources/local_storage.dart';
import '../models/user_model.dart';

class UserRepository {
  Future<UserModel> createUser(String name, String email) async {
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    await LocalStorage.saveUser(user);
    await LocalStorage.setCurrentUser(user.id);
    
    return user;
  }

  Future<UserModel?> loginUser(String email) async {
    // Simple login - find user by email
    final allUsers = LocalStorage.users.values;
    
    for (final user in allUsers) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        await LocalStorage.setCurrentUser(user.id);
        return user;
      }
    }
    
    return null;
  }

  Future<UserModel?> getCurrentUser() async {
    final userId = LocalStorage.getCurrentUserId();
    if (userId == null) return null;
    
    return LocalStorage.getUser(userId);
  }

  Future<void> logout() async {
    await LocalStorage.removeCurrentUser();
  }

  Future<bool> isEmailExists(String email) async {
    final allUsers = LocalStorage.users.values;
    
    for (final user in allUsers) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return true;
      }
    }
    
    return false;
  }

  Future<void> updateUser(UserModel user) async {
    await LocalStorage.saveUser(user);
  }

  Future<void> deleteUser(String userId) async {
    await LocalStorage.users.delete(userId);
    
    // Remove user's watchlists
    final userWatchlists = LocalStorage.getUserWatchlists(userId);
    for (final watchlist in userWatchlists) {
      await LocalStorage.deleteWatchlist(watchlist.id);
    }
  }
}