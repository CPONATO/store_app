import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/views/screens/authentication_screens/login_screen.dart';
import 'package:shop_app/views/screens/main_screen.dart';

void main() {
  // Bỏ qua xác minh chứng chỉ SSL (CHỈ DÙNG CHO MÔI TRƯỜNG PHÁT TRIỂN)
  HttpOverrides.global = MyHttpOverrides();

  runApp(const ProviderScope(child: MyApp()));
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
    String? token = preferences.getString('auth_token');
    String? userJson = preferences.getString('user');

    print("Token từ SharedPreferences: $token");
    print("userJson từ SharedPreferences: $userJson");

    // Kiểm tra cả token và userJson đều tồn tại
    if (token != null && userJson != null) {
      try {
        // Phân tích dữ liệu người dùng
        final userData = jsonDecode(userJson);
        print("ID người dùng từ SharedPreferences: ${userData['_id']}");

        // Xác minh token và ID người dùng khớp nhau (nếu có thể)
        // Đây là một kiểm tra đơn giản, bạn có thể cần phương pháp khác tùy thuộc vào cấu trúc token

        // Cập nhật provider
        ref.read(userProvider.notifier).setUser(userJson);
      } catch (e) {
        print("Lỗi khi phân tích dữ liệu người dùng: $e");
        // Xóa dữ liệu không hợp lệ
        await preferences.remove('auth_token');
        await preferences.remove('user');
        ref.read(userProvider.notifier).signOut();
      }
    } else {
      // Nếu một trong hai thiếu, xóa cả hai để tránh trạng thái không nhất quán
      if (token != null || userJson != null) {
        await preferences.remove('auth_token');
        await preferences.remove('user');
      }
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
