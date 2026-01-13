import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/menu_item_model.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final MenuItemModel item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  String formatCurrency(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái còn hàng hay không
    bool isAvailable = widget.item.isAvailable;

    return Scaffold(
      body: Stack(
        children: [
          // 1. ẢNH NỀN
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child:
                widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty
                ? Image.network(
                    widget.item.imageUrl!,
                    fit: BoxFit.cover,
                    // Nếu hết hàng thì làm ảnh tối đi một chút
                    color: isAvailable ? null : Colors.black.withOpacity(0.6),
                    colorBlendMode: isAvailable ? null : BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.fastfood,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
          ),

          // Badge "HẾT HÀNG" trên ảnh
          if (!isAvailable)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "TẠM HẾT HÀNG",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),

          // Nút Back & Yêu thích
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite_border, color: Colors.red),
                ),
              ],
            ),
          ),

          // 2. NỘI DUNG CHI TIẾT
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Text(
                        formatCurrency(widget.item.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.item.preparationTime} phút",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.item.rating} (50 đánh giá)",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (widget.item.ingredients.isNotEmpty) ...[
                    const Text(
                      "Nguyên liệu chính",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: widget.item.ingredients
                          .map(
                            (ing) => Chip(
                              label: Text(ing),
                              backgroundColor: const Color(0xFFE0F2F1),
                              labelStyle: const TextStyle(
                                color: Color(0xFF00695C),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    "Mô tả",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.item.description,
                        style: TextStyle(color: Colors.grey[600], height: 1.5),
                      ),
                    ),
                  ),

                  // 3. THANH ĐẶT HÀNG (Logic Quan Trọng)
                  Row(
                    children: [
                      // Nút Tăng/Giảm (Vô hiệu hóa nếu hết hàng)
                      Opacity(
                        opacity: isAvailable ? 1.0 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: isAvailable
                                    ? () => setState(
                                        () => _quantity > 1 ? _quantity-- : 1,
                                      )
                                    : null,
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  "$_quantity",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: isAvailable
                                    ? () => setState(() => _quantity++)
                                    : null,
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFF00695C),
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Nút Thêm vào giỏ
                      Expanded(
                        child: ElevatedButton(
                          // NẾU HẾT HÀNG -> NÚT KHÔNG BẤM ĐƯỢC (null)
                          onPressed: isAvailable
                              ? () {
                                  CartService().addToCart(
                                    widget.item,
                                    _quantity,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Đã thêm $_quantity x ${widget.item.name} vào giỏ!",
                                      ),
                                      backgroundColor: const Color(0xFF00695C),
                                    ),
                                  );
                                }
                              : null, // Disable nút

                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? const Color(0xFF00695C)
                                : Colors.grey, // Đổi màu xám
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: isAvailable ? 5 : 0,
                          ),
                          child: Text(
                            isAvailable ? "THÊM VÀO ĐƠN" : "HẾT HÀNG",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
