import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/global_variables.dart';
import 'package:shop_app/models/user.dart';
import 'package:shop_app/provider/cart_provider.dart';
import 'package:shop_app/provider/delivered_order_count_provider.dart';
import 'package:shop_app/provider/favorite_provider.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/services/manage_http_response.dart';
import 'package:shop_app/views/screens/authentication_screens/login_screen.dart';
import 'package:shop_app/main.dart' show providerContainer;

import 'package:shop_app/views/screens/main_screen.dart';

class AuthController {
  Future<void> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      User user = User(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        password: password,
        token: '',
      );

      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoginScreen();
              },
            ),
            (route) => false,
          );
          showSnackBar(context, 'Account has been created for you');
        },
      );
    } catch (e) {}
  }

  // Trong phần signInUsers method:

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          // Đảm bảo xóa dữ liệu auth cũ trước
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('auth_token');
          await preferences.remove('user');

          // **SỬA LẠI:** Reset cả cart và favorite state, KHÔNG xóa data trong SharedPreferences
          providerContainer.read(cartProvider.notifier).resetCartState();
          providerContainer
              .read(favoriteProvider.notifier)
              .resetFavoriteState(); // THÊM DÒNG NÀY

          // Đặt lại trạng thái người dùng trong provider
          providerContainer.read(userProvider.notifier).signOut();

          // Reset delivered order count cho user mới
          providerContainer
              .read(deliveredOrderCountProvider.notifier)
              .resetCount();

          // Lấy dữ liệu người dùng mới
          final userData = jsonDecode(response.body)['user'];
          final token = jsonDecode(response.body)['token'];
          final userJson = jsonEncode(userData);

          // Lưu dữ liệu mới
          await preferences.setString('auth_token', token);
          await preferences.setString('user', userJson);

          // Thiết lập trạng thái người dùng mới
          providerContainer.read(userProvider.notifier).setUser(userJson);

          // **QUAN TRỌNG:** Load cả cart và favorites CỦA USER MỚI từ SharedPreferences
          final newUser = User.fromJson(userJson);
          await providerContainer
              .read(cartProvider.notifier)
              .loadCartItemsForUser(newUser.id);
          await providerContainer
              .read(favoriteProvider.notifier)
              .loadFavoritesForUser(newUser.id); // THÊM DÒNG NÀY

          // Điều hướng
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          );

          showSnackBar(context, 'Logged in');
        },
      );
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      showSnackBar(context, "Login Failed");
    }
  }
  // Trong phần signOutUSer method:

  Future<void> signOutUSer({required BuildContext context}) async {
    try {
      // **SỬA LẠI:** KHÔNG xóa cart và favorite data, chỉ reset state
      // Cart và favorite của user được GIỮ LẠI trong SharedPreferences để lần sau đăng nhập vẫn có
      providerContainer.read(cartProvider.notifier).resetCartState();
      providerContainer
          .read(favoriteProvider.notifier)
          .resetFavoriteState(); // THÊM DÒNG NÀY

      // Xóa dữ liệu auth từ SharedPreferences
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('auth_token');
      await preferences.remove('user');

      // Xóa dữ liệu từ provider - Đảm bảo phải gọi trước khi điều hướng
      providerContainer.read(userProvider.notifier).signOut();
      providerContainer.read(deliveredOrderCountProvider.notifier).resetCount();

      // Kiểm tra xóa thành công
      print("Token sau khi đăng xuất: ${preferences.getString('auth_token')}");
      print("User sau khi đăng xuất: ${preferences.getString('user')}");

      // Điều hướng đến màn hình đăng nhập sau khi đã xóa hết dữ liệu
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      showSnackBar(context, 'Signed out successfully');
    } catch (e) {
      print("Error signing out: $e");
      showSnackBar(context, "Error signing out, please try again");
    }
  }

  //Update user's state, city and locality
  Future<void> updateUserLocation({
    required BuildContext context,
    required String id,
    required String state,
    required String city,
    required String locality,
  }) async {
    try {
      print("Đang cập nhật địa chỉ cho ID: $id");

      final http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final updatedUser = jsonDecode(response.body);
          print("Dữ liệu người dùng đã cập nhật: $updatedUser");

          SharedPreferences preferences = await SharedPreferences.getInstance();
          final userJson = jsonEncode(updatedUser);

          // Kiểm tra trước khi cập nhật
          final oldUserJson = preferences.getString('user');
          print("User cũ: $oldUserJson");
          print("User mới: $userJson");

          // Lưu dữ liệu mới
          await preferences.setString('user', userJson);

          // Cập nhật provider
          providerContainer.read(userProvider.notifier).setUser(userJson);

          // Kiểm tra sau khi cập nhật
          final verifyJson = preferences.getString('user');
          print("Đã lưu user: $verifyJson");
        },
      );
    } catch (e) {
      print("Lỗi cập nhật địa chỉ: $e");
      showSnackBar(context, 'Lỗi cập nhật địa chỉ');
    }
  }

  Future<void> deleteAccoumt({
    required BuildContext context,
    required String id,
    required WidgetRef ref,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      if (token == null) {
        showSnackBar(context, "You need to login to perform this action");
        return;
      }

      http.Response response = await http.delete(
        Uri.parse('$uri/api/user/delete-account/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          await preferences.remove(('auth_token'));

          await preferences.remove('user');

          ref.read(userProvider.notifier).signOut();

          showSnackBar(context, 'Account deleted');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error deleting account: $e');
    }
  }
}
// class AuthController {
//   Future<void> signUpUser({
//     required context,
//     required String email,
//     required String fullName,
//     required String password,
//   }) async {
//     try {
//       User user = User(
//         id: ' ',
//         fullName: fullName,
//         email: email,
//         state: ' ',
//         city: ' ',
//         locality: ' ',
//         password: password,
//         token: ' ',
//       );
//       http.Response response = await http.post(
//         Uri.parse('$uri/api/signup'),
//         body:
//             user.toJson(), // convert the user object to json for the request body
//         headers: <String, String>{
//           //set the headers for the request
//           "Content-Type":
//               'application/json; charset=UTF-8', //soecify the context type as json
//         },
//       );

//       manageHttpResponse(
//         response: response,
//         context: context,
//         onSuccess: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginScreen()),
//           );
//           showSnackBar(context, 'Account has been created for you');
//         },
//       );
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   //signin user funtion

//   Future<void> signInUsers({
//     required context,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       http.Response response = await http.post(
//         Uri.parse("$uri/api/signin"),
//         body: jsonEncode({'email': email, 'password': password}),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//       );

//       manageHttpResponse(
//         response: response,
//         context: context,
//         onSuccess: () async {
//           //access SharedPreferences for token and user data storage
//           SharedPreferences preferences = await SharedPreferences.getInstance();
//           //extracat the authentication token from reposnse body
//           String token = json.decode(response.body)['token'];
//           //store the auth token securely in SharedPreferences

//           await preferences.setString('auth_token', token);

//           //encode the user data recived from the backed as json

//           final userJson = jsonDecode(jsonDecode(response.body)['user']);
//           //update application state with user data using reiverpod
//           providerContainer.read(userProvider.notifier).setUser(userJson);
//           //store data in SharedPreferences for future use
//           await preferences.setString('user', userJson);

//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => MainScreen()),
//             (route) => false,
//           );
//           showSnackBar(context, 'Logged In');
//         },
//       );
//     } catch (e) {
//       print("Error: $e");
//     }
//   }

//   //sign out
//   Future<void> signOutUSer({required context}) async {
//     try {
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       //clear token and user from SharedPreferences
//       await preferences.remove('auth_token');
//       await preferences.remove('user');
//       //clear user state
//       providerContainer.read(userProvider.notifier).signOut();
//       //navigate user back to login screen
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (context) {
//             return LoginScreen();
//           },
//         ),
//         (route) => false,
//       );
//       showSnackBar(context, 'Signout successfully');
//     } catch (e) {
//       showSnackBar(context, 'Error signin out');
//     }
//   }
// }
