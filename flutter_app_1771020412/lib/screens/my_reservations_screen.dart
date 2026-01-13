import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../repositories/reservation_repository.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'seated':
        return Colors.purple; // Đang ăn
      case 'completed':
        return Colors.green; // Đã xong
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Đang chờ duyệt';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'seated':
        return 'Đang dùng bữa';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ReservationRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch Sử Đặt Bàn"),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: repo.getMyReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bạn chưa có đơn đặt bàn nào"));
          }

          final list = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Ngày & Trạng thái
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy - HH:mm').format(item.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                item.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(item.status),
                              ),
                            ),
                            child: Text(
                              _getStatusText(item.status),
                              style: TextStyle(
                                color: _getStatusColor(item.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Thông tin chi tiết
                      Text("Khách: ${item.guests} người"),
                      const SizedBox(height: 5),
                      Text(
                        "Món: ${item.items.map((e) => "${e.quantity}x ${e.name}").join(', ')}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 10),

                      // Footer: Tổng tiền & Nút Hành động
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: 'đ',
                            ).format(item.totalPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00695C),
                            ),
                          ),

                          // --- NÚT THANH TOÁN THÔNG MINH (Chỉ hiện khi seated) ---
                          if (item.status == 'seated')
                            ElevatedButton.icon(
                              onPressed: () async {
                                // 1. Lấy điểm hiện tại của user để tính toán hiển thị
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('customers')
                                    .doc(item.userId)
                                    .get();
                                final int currentPoints =
                                    userDoc.data()?['loyaltyPoints'] ?? 0;

                                // Tính toán sơ bộ để hiện lên Dialog
                                double maxDiscount =
                                    item.totalPrice * 0.5; // Giảm tối đa 50%
                                double potentialDiscount =
                                    currentPoints * 1000.0; // 1 điểm = 1000đ
                                double actualDiscount =
                                    (potentialDiscount > maxDiscount)
                                    ? maxDiscount
                                    : potentialDiscount;
                                int pointsNeed = (actualDiscount / 1000).ceil();

                                if (!context.mounted) return;

                                // 2. Hiện Dialog hỏi ý kiến
                                final usePoints = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Thanh toán hóa đơn"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(item.totalPrice)}",
                                        ),
                                        const SizedBox(height: 10),
                                        if (currentPoints > 0) ...[
                                          const Divider(),
                                          Text(
                                            "Bạn đang có: $currentPoints điểm",
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Có thể giảm: -${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(actualDiscount)}",
                                          ),
                                          Text(
                                            "(Dùng $pointsNeed điểm)",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ] else
                                          const Text(
                                            "Bạn chưa có điểm tích lũy.",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          ctx,
                                          false,
                                        ), // Không dùng điểm
                                        child: const Text("Thanh toán thường"),
                                      ),
                                      if (currentPoints > 0)
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(
                                            ctx,
                                            true,
                                          ), // Có dùng điểm
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF00695C,
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Dùng điểm & Trả"),
                                        ),
                                    ],
                                  ),
                                );

                                if (usePoints != null) {
                                  // Gọi hàm xử lý thanh toán mới
                                  await repo.processPayment(
                                    item,
                                    usePoints: usePoints,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Thanh toán thành công! Đã cập nhật điểm.",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.payment, size: 18),
                              label: const Text("Thanh toán"),
                            )
                          // Nút Hủy (Chỉ hiện khi pending)
                          else if (item.status == 'pending')
                            OutlinedButton(
                              onPressed: () async {
                                await repo.cancelReservation(item.id);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text("Hủy đơn"),
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
