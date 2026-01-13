import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller cho các ô nhập liệu
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Danh sách sở thích mẫu
  final List<String> _allPreferences = [
    "Thích ăn cay 🌶️",
    "Ăn chay 🥬",
    "Hải sản 🦀",
    "Không hành 🚫",
    "Đồ ngọt 🍰",
    "Ít đường 🍬",
  ];

  // Danh sách sở thích đã chọn
  final List<String> _selectedPreferences = [];

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Tạo tài khoản Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      // 2. Cập nhật Display Name (Tên hiển thị)
      await userCredential.user!.updateDisplayName(_nameController.text.trim());

      // 3. Lưu thông tin chi tiết vào Firestore (Bao gồm Sở thích)
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(userCredential.user!.uid)
          .set({
            'customerId': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'fullName': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'loyaltyPoints': 0, // Điểm tích lũy ban đầu
            'preferences': _selectedPreferences, // <--- LƯU DANH SÁCH SỞ THÍCH
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

      if (mounted) {
        // Đăng ký xong -> Vào thẳng trang chủ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Chào mừng bạn.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng Ký Tài Khoản"),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Thông tin cá nhân",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 10),

              // Họ tên
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val!.isEmpty ? "Cần nhập họ tên" : null,
              ),
              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) =>
                    !val!.contains("@") ? "Email không hợp lệ" : null,
              ),
              const SizedBox(height: 15),

              // Mật khẩu
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (val) =>
                    val!.length < 6 ? "Mật khẩu phải > 6 ký tự" : null,
              ),
              const SizedBox(height: 15),

              // Số điện thoại
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Cần nhập số điện thoại" : null,
              ),
              const SizedBox(height: 15),

              // Địa chỉ
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Địa chỉ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (val) => val!.isEmpty ? "Cần nhập địa chỉ" : null,
              ),

              const SizedBox(height: 25),
              const Text(
                "Sở thích ăn uống (Chọn nhiều)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 10),

              // --- PHẦN CHỌN SỞ THÍCH (MULTI-SELECT) ---
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _allPreferences.map((pref) {
                  final isSelected = _selectedPreferences.contains(pref);
                  return FilterChip(
                    label: Text(pref),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00695C).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF00695C),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00695C)
                          : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedPreferences.add(pref);
                        } else {
                          _selectedPreferences.remove(pref);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ĐĂNG KÝ NGAY",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
