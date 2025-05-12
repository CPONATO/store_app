import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/views/screens/authentication_screens/login_screen.dart';
import 'package:shop_app/views/screens/main_screen.dart';

void main() {
  //run flutter app wrapped in providerscrope to manage state
  runApp(const ProviderScope(child: MyApp()));
}

//root widget of application a consumerWidget to consume state chage
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  //method to check the token and set the user data if available
  Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
    //obtain and istance if sharedpreferebce for local data storage
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //retrive the auth token and user data stored locally
    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');

    //if both token and user data are avaible then updater user state

    if (token != null && userJson != null) {
      ref.read(userProvider.notifier).setUser(userJson);
    } else {
      ref.read(userProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        future: _checkTokenAndSetUser(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final user = ref.watch(userProvider);
          return user != null ? MainScreen() : LoginScreen();
        },
      ),
    );
  }
}
