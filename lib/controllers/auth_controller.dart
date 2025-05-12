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

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode({
          "email": email,
          "password": password,
        }), // Create a map here
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Access sharedPreferences for token and user data storage
          SharedPreferences preferences = await SharedPreferences.getInstance();

          //Extract the authentication token from the response body
          String token = jsonDecode(response.body)['token'];

          //STORE the authentication token securely in sharedPreferences

          preferences.setString('auth_token', token);

          //Encode the user data recived from the backend as json
          final userJson = jsonEncode(jsonDecode(response.body)['user']);

          //update the application state with the user data using Riverpod
          providerContainer.read(userProvider.notifier).setUser(userJson);

          //store the data in sharePreference  for future use

          await preferences.setString('user', userJson);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainScreen();
              },
            ),
            (route) => false,
          );
          showSnackBar(context, 'Logged in');
        },
      );
    } catch (e) {}
  }

  //Signout

  Future<void> signOutUSer({required BuildContext context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPreferenace
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      providerContainer.read(userProvider.notifier).signOut();

      //navigate the user back to the login screen

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
        (route) => false,
      );

      showSnackBar(context, 'signout successfully');
    } catch (e) {
      showSnackBar(context, "error signing out");
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
      //Make an HTTP PUT request to update user's state, city and locality
      final http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        //set the header for the request to specify   that the content  is Json
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        //Encode the update data(state, city and locality) AS  Json object
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //Decode the updated user data from the response body
          //this converts the json String response into Dart Map
          final updatedUser = jsonDecode(response.body);
          //Access Shared preference for local data storage
          //shared preferences allow us to store data persisitently on the the device
          SharedPreferences preferences = await SharedPreferences.getInstance();
          //Encode the update user data as json String
          //this prepares the data for storage in shared preference
          final userJson = jsonEncode(updatedUser);

          //update the application state with the updated user data  using Riverpod
          //this ensures the app reflects the most recent user data
          providerContainer.read(userProvider.notifier).setUser(userJson);

          //store the updated user data in shared preference  for future user
          //this allows the app to retrive the user data  even after the app restarts
          await preferences.setString('user', userJson);
        },
      );
    } catch (e) {
      //catch any error that occure during the proccess
      //show an error message to the user if the update fails
      showSnackBar(context, 'Error updating location');
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
