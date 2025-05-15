import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/user.dart';

class UserProvider extends StateNotifier<User?> {
  //constuctore initalizing with default user onject
  //purpose: manage state of the user object allowing updates
  UserProvider()
    : super(
        User(
          id: '',
          fullName: '',
          email: '',
          state: '',
          city: '',
          locality: '',
          password: '',
          token: '',
        ),
      );

  //getter method to extract value from object

  User? get user => state;
  //mothod to set user state from json\
  //purpose update the user state base on json String respresentation of use onject
  void setUser(String userJson) {
    print("userJson được truyền vào setUser: $userJson");
    final parsedUser = User.fromJson(userJson);
    print("ID sau khi parse: ${parsedUser.id}");
    state = parsedUser;
  }

  //mothod to clear user state
  void signOut() {
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
