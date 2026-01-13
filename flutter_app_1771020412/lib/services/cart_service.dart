import '../models/menu_item_model.dart';
import '../models/reservation_model.dart'; // Để dùng class OrderItem

class CartService {
  // Tạo Singleton (Chỉ có 1 giỏ hàng duy nhất trong app)
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<OrderItem> _items = [];

  // Lấy danh sách món trong giỏ
  List<OrderItem> get items => _items;

  // Tính tổng tiền
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // Thêm món vào giỏ
  void addToCart(MenuItemModel product, int quantity) {
    // Kiểm tra xem món này đã có trong giỏ chưa
    final index = _items.indexWhere((i) => i.id == product.id);

    if (index >= 0) {
      // Nếu có rồi thì cộng dồn số lượng
      var oldItem = _items[index];
      _items[index] = OrderItem(
        id: oldItem.id,
        name: oldItem.name,
        price: oldItem.price,
        quantity: oldItem.quantity + quantity,
        imageUrl: oldItem.imageUrl,
      );
    } else {
      // Nếu chưa có thì thêm mới
      _items.add(
        OrderItem(
          id: product.id, // Dùng ID của món ăn
          name: product.name,
          price: product.price,
          quantity: quantity,
          imageUrl: product.imageUrl,
        ),
      );
    }
  }

  // Xóa giỏ hàng (Sau khi đặt xong)
  void clear() {
    _items.clear();
  }
}
