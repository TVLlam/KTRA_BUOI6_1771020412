import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Lấy danh sách món ăn (Real-time)
  Stream<List<MenuItemModel>> getMenuItems() {
    return _db.collection('menu_items').orderBy('name').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // 2. Tìm kiếm và Lọc
  Stream<List<MenuItemModel>> searchMenuItems(String query, String category) {
    Query collection = _db.collection('menu_items');

    // Lọc theo danh mục (Firestore Query)
    if (category != "All") {
      collection = collection.where('category', isEqualTo: category);
    }

    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).where(
        (item) {
          // Tìm kiếm theo tên (Local filtering vì Firestore search text kém)
          return item.name.toLowerCase().contains(query.toLowerCase());
        },
      ).toList();
    });
  }

  // 3. Nạp dữ liệu mẫu (Đã cập nhật đầy đủ thông tin Cay/Chay)
  Future<void> addSampleData() async {
    final List<MenuItemModel> sampleItems = [
      MenuItemModel(
        id: '',
        name: 'Phở Bò Đặc Biệt',
        description: 'Phở bò tái nạm gầu, nước dùng hầm xương 24h',
        category: 'Main Course',
        price: 65000,
        imageUrl:
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=800&q=80',
        rating: 4.8,
        ingredients: ['Bánh phở', 'Thịt bò', 'Hành tây', 'Thảo mộc'],
        preparationTime: 15,
        isSpicy: false,
        isVegetarian: false,
      ),
      MenuItemModel(
        id: '',
        name: 'Bún Chả Hà Nội',
        description: 'Chả nướng than hoa thơm lừng kèm nem rán',
        category: 'Main Course',
        price: 60000,
        imageUrl:
            'https://images.unsplash.com/photo-1511690656952-34342d5c71df?auto=format&fit=crop&w=800&q=80',
        rating: 4.5,
        ingredients: ['Thịt lợn', 'Bún', 'Nước mắm', 'Đu đủ'],
        preparationTime: 20,
        isSpicy: false,
        isVegetarian: false,
      ),
      MenuItemModel(
        id: '',
        name: 'Gỏi Cuốn Tôm Thịt',
        description: 'Món khai vị thanh mát, chấm sốt tương đen',
        category: 'Appetizer',
        price: 35000,
        imageUrl:
            'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=800&q=80',
        rating: 4.2,
        ingredients: ['Bánh tráng', 'Tôm', 'Thịt ba chỉ', 'Rau sống'],
        preparationTime: 10,
        isSpicy: false,
        isVegetarian: false,
      ),
      MenuItemModel(
        id: '',
        name: 'Trà Đào Cam Sả',
        description: 'Thức uống giải nhiệt mùa hè',
        category: 'Drinks',
        price: 45000,
        imageUrl:
            'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=800&q=80',
        ingredients: ['Trà đen', 'Đào ngâm', 'Cam vàng', 'Sả'],
        preparationTime: 5,
        isSpicy: false,
        isVegetarian: true,
      ),
      MenuItemModel(
        id: '',
        name: 'Bánh Mousse Xoài',
        description: 'Bánh tráng miệng mềm mịn vị xoài',
        category: 'Dessert',
        price: 40000,
        imageUrl:
            'https://images.unsplash.com/photo-1541783245831-57d6fb0926d3?auto=format&fit=crop&w=800&q=80',
        ingredients: ['Xoài', 'Kem tươi', 'Gelatin', 'Đường'],
        preparationTime: 0,
        isSpicy: false,
        isVegetarian: true,
      ),
      MenuItemModel(
        id: '',
        name: 'Mì Cay Hàn Quốc 7 Cấp Độ',
        description: 'Mì cay hải sản với nước dùng đậm đà, cay nồng',
        category: 'Main Course',
        price: 55000,
        imageUrl:
            'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&w=800&q=80',
        ingredients: ['Mì', 'Tôm', 'Mực', 'Ớt bột', 'Kim chi'],
        preparationTime: 15,
        isSpicy: true, // Món này cay
        isVegetarian: false,
      ),
      MenuItemModel(
        id: '',
        name: 'Salad Rau Củ',
        description: 'Salad tươi ngon với sốt mè rang',
        category: 'Appetizer',
        price: 30000,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
        ingredients: ['Xà lách', 'Cà chua', 'Dưa leo', 'Sốt mè'],
        preparationTime: 5,
        isSpicy: false,
        isVegetarian: true, // Món này chay
      ),
    ];

    final batch = _db.batch();
    for (var item in sampleItems) {
      var docRef = _db.collection('menu_items').doc();
      batch.set(docRef, item.toMap());
    }
    await batch.commit();
  }

  // 4. [QUAN TRỌNG] Hàm cập nhật dữ liệu cũ thiếu trường Cay/Chay
  Future<void> updateRandomAttributes() async {
    final docs = await _db.collection('menu_items').get();

    final batch = _db.batch();

    for (var doc in docs.docs) {
      // Random thuộc tính để test bộ lọc
      bool isVeg =
          DateTime.now().microsecondsSinceEpoch % 3 == 0; // 33% là chay
      bool isSpicy =
          DateTime.now().microsecondsSinceEpoch % 2 == 0; // 50% là cay

      // Logic nhỏ: Đồ uống và Tráng miệng thì không cay
      String cat = doc.data()['category'] ?? "";
      if (cat == "Drinks" || cat == "Dessert") isSpicy = false;

      batch.update(doc.reference, {
        'isVegetarian': isVeg,
        'isSpicy': isSpicy,
        'isAvailable': true,
      });
    }

    await batch.commit();
    print("Đã cập nhật xong dữ liệu Cay/Chay cho toàn bộ Menu!");
  }
}
