import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant App',

      // --- CẤU HÌNH GIAO DIỆN HIỆN ĐẠI (THEME) ---
      theme: ThemeData(
        useMaterial3: true,

        // 1. Màu chủ đạo: Xanh Teal Đậm (Sang trọng)
        primaryColor: const Color(0xFF00695C),

        // 2. Bảng màu chi tiết
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C), // Màu hạt giống
          primary: const Color(0xFF00695C), // Màu chính
          secondary: const Color(
            0xFFFFA000,
          ), // Màu phụ (Vàng cam) để làm điểm nhấn
        ),

        // 3. Cấu hình mặc định cho các ô nhập liệu (Input)
        // Giúp bạn không phải chỉnh từng cái ô nhập text một
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100], // Màu nền xám nhẹ
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Không viền đen xấu xí
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
          ),
        ),

        // 4. Cấu hình mặc định cho các nút bấm
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00695C),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),

      // Màn hình bắt đầu
      home: const LoginScreen(),
    );
  }
}
