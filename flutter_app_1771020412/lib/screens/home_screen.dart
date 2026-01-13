import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_item_model.dart';
import '../repositories/menu_repository.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'reservation_screen.dart';
import 'my_reservations_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuRepository _menuRepo = MenuRepository();

  final List<String> categories = [
    "All",
    "Main Course",
    "Appetizer",
    "Dessert",
    "Drinks",
  ];

  String _selectedCategory = "All";
  String _searchQuery = "";

  // --- TRẠNG THÁI BỘ LỌC ---
  bool _onlyVegetarian = false;
  bool _onlySpicy = false;

  String formatCurrency(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn thoát phiên làm việc?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // --- MENU BÊN TRÁI (DRAWER) ---
      drawer: _buildDrawer(user),

      // --- NÚT GIỎ HÀNG (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReservationScreen()),
          );
        },
        backgroundColor: const Color(0xFFFFA000),
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text(
          "Giỏ hàng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // --- NỘI DUNG CHÍNH ---
      body: CustomScrollView(
        slivers: [
          // 1. Header (AppBar)
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF00695C),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Restaurant App - 1771020412", // Thay Mã SV của bạn vào đây
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
              background: Image.network(
                "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1974&auto=format&fit=crop",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            actions: [
              // Nút cập nhật dữ liệu (Fix lỗi lọc không ra kết quả)
              IconButton(
                icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                tooltip: "Cập nhật thuộc tính Chay/Cay cho Menu",
                onPressed: () async {
                  await _menuRepo.updateRandomAttributes();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Đã cập nhật dữ liệu Chay/Cay thành công!",
                        ),
                      ),
                    );
                    setState(() {}); // Refresh lại giao diện
                  }
                },
              ),
            ],
          ),

          // 2. Khu vực Tìm kiếm & Bộ lọc
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hôm nay bạn muốn ăn gì?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ô tìm kiếm
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm món ngon...",
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF00695C)),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 12),

                  // --- BỘ LỌC CHAY / CAY ---
                  Row(
                    children: [
                      FilterChip(
                        label: const Text("🥬 Ăn chay"),
                        selected: _onlyVegetarian,
                        selectedColor: Colors.green[100],
                        checkmarkColor: Colors.green,
                        labelStyle: TextStyle(
                          color: _onlyVegetarian
                              ? Colors.green[800]
                              : Colors.black,
                        ),
                        onSelected: (val) =>
                            setState(() => _onlyVegetarian = val),
                      ),
                      const SizedBox(width: 10),
                      FilterChip(
                        label: const Text("🌶️ Ăn cay"),
                        selected: _onlySpicy,
                        selectedColor: Colors.red[100],
                        checkmarkColor: Colors.red,
                        labelStyle: TextStyle(
                          color: _onlySpicy ? Colors.red[800] : Colors.black,
                        ),
                        onSelected: (val) => setState(() => _onlySpicy = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Danh sách danh mục (Horizontal List)
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00695C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.grey.shade300),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00695C,
                                        ).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Lưới hiển thị món ăn (Grid)
          StreamBuilder<List<MenuItemModel>>(
            stream: _menuRepo.searchMenuItems(_searchQuery, _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text("Lỗi: ${snapshot.error}")),
                );
              }

              var items = snapshot.data ?? [];

              // --- LOGIC LỌC CLIENT-SIDE ---
              if (_onlyVegetarian) {
                items = items.where((item) => item.isVegetarian).toList();
              }
              if (_onlySpicy) {
                items = items.where((item) => item.isSpicy).toList();
              }

              if (items.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text("Không tìm thấy món nào phù hợp."),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Tỷ lệ khung hình thẻ món ăn
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildModernItemCard(items[index]),
                    childCount: items.length,
                  ),
                ),
              );
            },
          ),

          // Khoảng trắng dưới cùng để nút FAB không che nội dung
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // --- HÀM TẠO DRAWER (MENU) ---
  Widget _buildDrawer(User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header tùy chỉnh bằng Container (Fix lỗi Overflow)
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(color: Color(0xFF00695C)),
            child: StreamBuilder<DocumentSnapshot>(
              stream: user != null
                  ? FirebaseFirestore.instance
                        .collection('customers')
                        .doc(user.uid)
                        .snapshots()
                  : null,
              builder: (context, snapshot) {
                int points = 0;
                String fullName = user?.displayName ?? "Xin chào!";
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    points = data['loyaltyPoints'] ?? 0;
                    if (data['fullName'] != null && data['fullName'].isNotEmpty)
                      fullName = data['fullName'];
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 35,
                      child: Icon(
                        Icons.person,
                        size: 45,
                        color: Color(0xFF00695C),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hiển thị điểm
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Điểm: $points",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF00695C)),
            title: const Text("Lịch sử đặt bàn"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
              );
            },
          ),
          const Divider(),
          // Chỉ hiện Admin nếu đúng email
          if (user?.email == 'lam@gmail.com' ||
              user?.email == 'admin@gmail.com') ...[
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.redAccent,
              ),
              title: const Text(
                "Quản trị viên (Admin)",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  // --- HÀM TẠO THẺ MÓN ĂN (CÓ ICON CAY/CHAY) ---
  Widget _buildModernItemCard(MenuItemModel item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(item: item)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần ảnh
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formatCurrency(item.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF00695C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Phần thông tin
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Hiển thị icon
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${item.preparationTime}p",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (item.isSpicy) ...[
                              const Icon(
                                Icons.whatshot,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (item.isVegetarian)
                              const Icon(
                                Icons.eco,
                                size: 16,
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFFFA000),
                        radius: 14,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
