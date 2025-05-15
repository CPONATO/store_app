import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/user.dart';

class UserProvider extends StateNotifier<User?> {
  UserProvider() : super(null); // Bắt đầu với trạng thái null

  User? get user => state;

  void setUser(String userJson) {
    print("userJson được truyền vào setUser: $userJson");

    try {
      final parsedUser = User.fromJson(userJson);
      print("ID sau khi parse: ${parsedUser.id}");
      state = parsedUser;
    } catch (e) {
      print("Lỗi khi phân tích dữ liệu người dùng: $e");
      state = null;
    }
  }

  void signOut() {
    print("Xóa trạng thái người dùng");
    state = null;
  }

  void recreateUserState({
    required String state,
    required String city,
    required String locality,
  }) {
    if (this.state != null) {
      this.state = User(
        id: this.state!.id,
        fullName: this.state!.fullName,
        email: this.state!.email,
        state: state,
        city: city,
        locality: locality,
        password: this.state!.password,
        token: this.state!.token,
      );
    }
  }
}

final userProvider = StateNotifierProvider<UserProvider, User?>(
  (ref) => UserProvider(),
);
