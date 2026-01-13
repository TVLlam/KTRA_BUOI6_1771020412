import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';
import '../repositories/reservation_repository.dart';
import '../services/cart_service.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _repository = ReservationRepository();
  final _cart = CartService();

  // Thông tin đặt bàn
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _guests = 2; // Mặc định 2 khách
  bool _isLoading = false;

  String get _totalString => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
  ).format(_cart.totalPrice);

  // Hàm chọn ngày
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)), // Cho đặt trước 30 ngày
    );
    if (newDate != null) setState(() => _selectedDate = newDate);
  }

  // Hàm chọn giờ
  Future<void> _pickTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (newTime != null) setState(() => _selectedTime = newTime);
  }

  // Xử lý Gửi đơn
  Future<void> _submitReservation() async {
    if (_cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bạn chưa chọn món nào!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kết hợp ngày và giờ thành 1 biến DateTime
      final fullDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final user = FirebaseAuth.instance.currentUser;

      // Tạo object đơn đặt bàn
      final reservation = ReservationModel(
        id: '', // Firebase tự sinh
        userId: user?.uid ?? '',
        customerName: user?.displayName ?? user?.email ?? 'Khách',
        date: fullDateTime,
        guests: _guests,
        items: _cart.items,
        totalPrice: _cart.totalPrice,
        status: 'pending',
      );

      // Gửi lên Firebase
      await _repository.createReservation(reservation);

      // Xóa giỏ hàng và báo thành công
      _cart.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đặt bàn thành công!")));
        Navigator.pop(context); // Thoát ra màn hình chính
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác Nhận Đặt Bàn")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CHỌN THÔNG TIN BÀN
            const Text(
              "Thông tin đặt chỗ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Dòng 1: Ngày & Giờ
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Ngày",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Giờ",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text(_selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dòng 2: Số khách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Số lượng khách:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    setState(() => _guests > 1 ? _guests-- : 1),
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                "$_guests",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _guests++),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. DANH SÁCH MÓN ĐÃ CHỌN
            const Text(
              "Món đã gọi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
            ),
            const SizedBox(height: 10),
            if (_cart.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Chưa có món nào. Hãy quay lại menu!"),
                ),
              )
            else
              ..._cart.items.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.fastfood),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.price)} x ${item.quantity}",
                    ),
                    trailing: Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'đ',
                      ).format(item.price * item.quantity),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // 3. TỔNG TIỀN & NÚT ĐẶT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TỔNG CỘNG:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _totalString,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "XÁC NHẬN ĐẶT BÀN",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
