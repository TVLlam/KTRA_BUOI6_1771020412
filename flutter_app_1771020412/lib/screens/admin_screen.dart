import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // Hàm cập nhật trạng thái
  Future<void> _updateStatus(String id, String newStatus) async {
    await FirebaseFirestore.instance.collection('reservations').doc(id).update({
      'status': newStatus,
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'seated':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADMIN - Quản Lý Đặt Bàn"),
        backgroundColor: Colors.red[900], // Màu đỏ để phân biệt với khách
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lấy TOÀN BỘ đơn đặt bàn, không lọc theo userId
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có đơn đặt bàn nào"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final reservation = ReservationModel.fromFirestore(docs[index]);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin khách hàng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            reservation.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(reservation.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              reservation.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Ngày: ${DateFormat('dd/MM - HH:mm').format(reservation.date)}",
                      ),
                      Text(
                        "Khách: ${reservation.guests} | Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(reservation.totalPrice)}",
                      ),

                      const Divider(),

                      // CÁC NÚT XỬ LÝ TRẠNG THÁI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Nếu đang Chờ -> Cho phép Duyệt hoặc Hủy
                          if (reservation.status == 'pending') ...[
                            TextButton(
                              onPressed: () =>
                                  _updateStatus(reservation.id, 'cancelled'),
                              child: const Text(
                                "Hủy",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  _updateStatus(reservation.id, 'confirmed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Duyệt đơn"),
                            ),
                          ],

                          // Nếu Đã duyệt -> Cho phép Xếp bàn (Check-in)
                          if (reservation.status == 'confirmed')
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _updateStatus(reservation.id, 'seated'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.table_restaurant,
                                size: 16,
                              ),
                              label: const Text("Khách vào bàn"),
                            ),

                          // Nếu Đang ăn -> Chờ khách thanh toán (Admin có thể xác nhận xong thay khách)
                          if (reservation.status == 'seated')
                            const Text(
                              "Đang phục vụ...",
                              style: TextStyle(
                                color: Colors.purple,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                          if (reservation.status == 'completed')
                            const Text(
                              "Đã xong",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
