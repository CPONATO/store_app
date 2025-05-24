import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/user.dart';
import 'package:shop_app/provider/cart_provider.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/views/screens/authentication_screens/login_screen.dart';
import 'package:shop_app/views/screens/main_screen.dart';

final providerContainer = ProviderContainer();

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey =
  //     "pk_test_51RR5nO4eQ60dTGCr6FvVWrZSAYXpJOswHXmTCHBK1r8qJo5yRzSoXjOKXlWtqT7WAIUhVi10U3lwgdQQFZjoFW4T001Ne1UZkB";
  // await Stripe.instance.applySettings();
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

//root widget of application a consumerWidget to consume state chage
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  //method to check the token and set the user data if available
  Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    // Xóa bất kỳ trạng thái người dùng cũ nào có thể tồn tại
    ref.read(userProvider.notifier).signOut();

    // **SỬA LẠI:** Chỉ reset cart state, KHÔNG xóa cart data khỏi SharedPreferences
    ref.read(cartProvider.notifier).resetCartState();

    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');

    print("Token từ SharedPreferences: $token");
    print("userJson từ SharedPreferences: $userJson");

    if (token != null && userJson != null) {
      try {
        // Thiết lập trạng thái người dùng mới
        ref.read(userProvider.notifier).setUser(userJson);

        // **QUAN TRỌNG:** Load cart của user từ SharedPreferences (cart được bảo toàn)
        final user = User.fromJson(userJson);
        await ref.read(cartProvider.notifier).loadCartItemsForUser(user.id);
      } catch (e) {
        print("Lỗi khi phân tích dữ liệu người dùng: $e");

        // Nếu có lỗi, xóa hết dữ liệu
        await preferences.remove('auth_token');
        await preferences.remove('user');
        ref.read(userProvider.notifier).signOut();
        ref.read(cartProvider.notifier).resetCartState();
      }
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
