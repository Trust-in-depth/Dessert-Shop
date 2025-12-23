import 'package:ders7flutterproject/cart-button.dart';
import 'package:ders7flutterproject/cart-list-item.dart';
import 'package:ders7flutterproject/products-page.dart';
import 'package:ders7flutterproject/product-list-item.dart';
import 'package:ders7flutterproject/cart-page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, CartListItem> cartItemsMap = {};
  @override
  Widget build(BuildContext context) {
    final totalCount = cartItemsMap.values.fold<int>(
      0,
      (previousValue, element) => previousValue + element.quantity,
    );
    return Stack(
      children: [
        ProductsPage(onAddToCart: addToCart),
        Positioned(
          right: 15,
          bottom: 15,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    items: cartItemsMap.values.toList(),
                    onAddToCart: (cartItem) {
                      addToCart(cartItem.product);
                    },
                    onRemoveFromCart: (cartItem) {
                      _removeFromCart(cartItem);
                    },
                  ),
                ),
              ).then((_) {
                setState(() {});
              });
            },
            child: CartButton(count: totalCount),
          ),
        ),
      ],
    );
  }

  void addToCart(ProductListItem item) {
    CartListItem? existingItem = cartItemsMap[item.id];
    setState(() {
      if (existingItem != null) {
        existingItem = CartListItem(
          product: existingItem!.product,
          quantity: existingItem!.quantity + 1,
        );

        cartItemsMap[item.id] = existingItem!;
      } else {
        cartItemsMap[item.id] = CartListItem(product: item, quantity: 1);
      }
    });
    _addToFirebaseitem(item);
  }

  void _removeFromCart(CartListItem item) {
    CartListItem? existingItem = cartItemsMap[item.product.id];
    setState(() {
      if (existingItem != null) {
        if (existingItem!.quantity > 1) {
          existingItem = CartListItem(
            product: existingItem!.product,
            quantity: existingItem!.quantity - 1,
          );
          cartItemsMap[item.product.id] = existingItem!;
        } else {
          cartItemsMap.remove(item.product.id);
        }
      }
    });
    _removeFromFirebase(item.product.id);
  }

  Future<void> _addToFirebaseitem(ProductListItem item) async {
    try {
      await _firestore.collection('sepet').add({
        'urunAdi': item.name,
        'fiyat': item.price,
        'eklenmeTarihi': FieldValue.serverTimestamp(),
        'urunId': item.id,
      });
      print("${item.name} Firebase sepetine eklendi!");
    } catch (e) {
      print("Firebase Hatası: $e");
    }
  }

  Future<void> _removeFromFirebase(String urunId) async {
    var sorgu = await _firestore
        .collection('sepet')
        .where('urunId', isEqualTo: urunId)
        .get();
    if (sorgu.docs.isNotEmpty) {
      await sorgu.docs.first.reference.delete();
      print("Üründen 1 adet silindi.");
    } else {
      print("Ürün Firebase sepetinden silindi!");
    }
  }
}
