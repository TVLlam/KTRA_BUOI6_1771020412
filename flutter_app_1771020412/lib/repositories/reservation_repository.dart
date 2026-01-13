import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';

class ReservationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Tạo đơn đặt bàn mới
  Future<void> createReservation(ReservationModel reservation) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception("Chưa đăng nhập");

      // Lưu vào collection 'reservations'
      await _db.collection('reservations').add(reservation.toMap());
    } catch (e) {
      print("Lỗi tạo đặt bàn: $e");
      rethrow;
    }
  }

  // 2. Lấy danh sách đặt bàn của tôi
  Stream<List<ReservationModel>> getMyReservations() {
    final User? user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReservationModel.fromFirestore(doc))
              .toList();
        });
  }

  // 3. Hủy đặt bàn
  Future<void> cancelReservation(String id) async {
    await _db.collection('reservations').doc(id).update({
      'status': 'cancelled',
    });
  }

  // 4. THANH TOÁN (XỬ LÝ LOGIC ĐIỂM THƯỞNG & GIẢM GIÁ)
  Future<void> processPayment(
    ReservationModel reservation, {
    bool usePoints = false,
  }) async {
    try {
      final userRef = _db.collection('customers').doc(reservation.userId);
      final resRef = _db.collection('reservations').doc(reservation.id);

      await _db.runTransaction((transaction) async {
        // B1: Lấy thông tin khách hàng hiện tại để check điểm
        final userSnapshot = await transaction.get(userRef);

        // Nếu user chưa có trong bảng customers (lỗi dữ liệu cũ), tạo tạm data để không crash
        int currentPoints = 0;
        if (userSnapshot.exists) {
          currentPoints = userSnapshot.data()?['loyaltyPoints'] ?? 0;
        }

        // B2: Tính toán tiền & giảm giá
        double finalTotal = reservation.totalPrice;
        int pointsUsed = 0;
        double discountAmount = 0;

        if (usePoints && currentPoints > 0) {
          double maxDiscount =
              reservation.totalPrice * 0.5; // Luật: Giảm tối đa 50%
          double potentialDiscount =
              currentPoints * 1000.0; // Quy đổi: 1 điểm = 1000đ

          if (potentialDiscount > maxDiscount) {
            // Điểm dư thừa -> Chỉ trừ đúng mức trần 50%
            discountAmount = maxDiscount;
            pointsUsed = (maxDiscount / 1000).ceil();
          } else {
            // Điểm ít hơn 50% -> Dùng hết sạch điểm
            discountAmount = potentialDiscount;
            pointsUsed = currentPoints;
          }
          // Chốt số tiền cuối cùng khách phải trả
          finalTotal = reservation.totalPrice - discountAmount;
        }

        // B3: Tính điểm thưởng mới (1% trên số tiền thực trả sau khi đã giảm)
        int pointsEarned = (finalTotal * 0.01).toInt();

        // Tính tổng điểm mới của khách (Điểm cũ - Điểm dùng + Điểm mới)
        int newPointBalance = currentPoints - pointsUsed + pointsEarned;

        // B4: Cập nhật trạng thái đơn hàng
        transaction.update(resRef, {
          'status': 'completed', // Hoàn thành
          'paymentStatus': 'paid', // Đã trả tiền
          'discount': discountAmount, // Lưu số tiền đã giảm
          'total': finalTotal, // Lưu số tiền thực thu
          'pointsUsed': pointsUsed, // Lưu số điểm đã dùng
          'pointsEarned': pointsEarned, // Lưu số điểm tích được
        });

        // B5: Cập nhật ví điểm của khách hàng
        if (userSnapshot.exists) {
          transaction.update(userRef, {'loyaltyPoints': newPointBalance});
        } else {
          // Trường hợp user cũ chưa có doc trong customers, tạo mới luôn
          transaction.set(userRef, {
            'email': _auth.currentUser?.email,
            'loyaltyPoints': pointsEarned, // Chỉ cộng điểm mới
          });
        }
      });
    } catch (e) {
      print("Lỗi thanh toán: $e");
      rethrow;
    }
  }
}
