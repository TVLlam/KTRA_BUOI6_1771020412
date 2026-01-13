import 'package:cloud_firestore/cloud_firestore.dart';

// Class phụ để lưu món ăn trong đơn đặt bàn
class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'],
    );
  }
}

// Class chính: Đơn đặt bàn
class ReservationModel {
  final String id;
  final String userId; // ID người đặt
  final String customerName; // Tên người đặt
  final DateTime date; // Ngày giờ ăn
  final int guests; // Số lượng khách
  final String status; // pending, confirmed, seated, cancelled, completed
  final List<OrderItem> items; // Danh sách món gọi trước
  final double totalPrice; // Tổng tiền dự kiến

  ReservationModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.date,
    required this.guests,
    this.status = 'pending',
    this.items = const [],
    this.totalPrice = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'date': Timestamp.fromDate(date),
      'guests': guests,
      'status': status,
      'items': items.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
    };
  }

  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReservationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? 'Khách hàng',
      date: (data['date'] as Timestamp).toDate(),
      guests: data['guests'] ?? 1,
      status: data['status'] ?? 'pending',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }
}
