import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/global_variables.dart';
import 'package:shop_app/models/user.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/services/manage_http_response.dart';
import 'package:shop_app/views/screens/authentication_screens/login_screen.dart';
import 'package:shop_app/views/screens/main_screen.dart';

final providerContainer = ProviderContainer();

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

  // Trong auth_controller.dart, phương thức signInUsers
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
          SharedPreferences preferences = await SharedPreferences.getInstance();

          // Lấy dữ liệu từ phản hồi
          final userData = jsonDecode(response.body)['user'];
          final token = jsonDecode(response.body)['token'];
          final userJson = jsonEncode(userData);

          try {
            // Xóa dữ liệu cũ trước khi lưu dữ liệu mới
            await preferences.remove('auth_token');
            await preferences.remove('user');

            // Lưu dữ liệu mới
            await preferences.setString('auth_token', token);
            await preferences.setString('user', userJson);

            // Kiểm tra xem dữ liệu đã được lưu chính xác chưa
            print("Đã lưu token: ${preferences.getString('auth_token')}");
            print("Đã lưu user: ${preferences.getString('user')}");

            // Cập nhật provider
            providerContainer.read(userProvider.notifier).setUser(userJson);

            // Điều hướng
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (route) => false,
            );

            showSnackBar(context, 'Đã đăng nhập');
          } catch (e) {
            print("Lỗi khi lưu dữ liệu đăng nhập: $e");
            showSnackBar(
              context,
              'Đăng nhập thành công nhưng có lỗi khi lưu thông tin đăng nhập',
            );
          }
        },
      );
    } catch (e) {}
  }

  //Signout

  Future<void> signOutUSer({required BuildContext context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      // Check and print information before deletion (for debugging)
      final token = preferences.getString('auth_token');
      final userJson = preferences.getString('user');
      print("Token before sign out: $token");
      print("User before sign out: $userJson");

      // Remove all user data from SharedPreferences
      await preferences.remove('auth_token');
      await preferences.remove('user');

      // Verify the deletion was successful
      final checkToken = preferences.getString('auth_token');
      final checkUser = preferences.getString('user');
      print("Token after sign out: $checkToken");
      print("User after sign out: $checkUser");

      // Clear user data from provider
      providerContainer.read(userProvider.notifier).signOut();

      // Navigate user back to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
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
