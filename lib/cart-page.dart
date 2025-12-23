import 'package:ders7flutterproject/cart-list-item-view.dart';
import 'package:flutter/material.dart';
import 'package:ders7flutterproject/cart-list-item.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
    required this.items,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  final List<CartListItem> items;

  final Function(CartListItem) onRemoveFromCart;
  final Function(CartListItem) onAddToCart;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartListItem> _items = [];
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();

    _items = List.from(widget.items);
    _calculateTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(bottom: 50),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 3),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CartListItemView(
                  item: item,
                  onAddToCart: _addToCart,
                  onRemoveFromCart: _removeFromCart,
                );
              },
            ),
          ),
          Positioned(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Row(
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '$_totalPrice £',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(CartListItem item) {
    setState(() {
      final index = _items.indexWhere((i) => i.product.id == item.product.id);
      if (index != -1) {
        final existingItem = _items[index];
        _items[index] = CartListItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        );
      }
      _calculateTotalPrice();
    });
    widget.onAddToCart(item);
  }

  void _removeFromCart(CartListItem item) {
    setState(() {
      final index = _items.indexWhere((i) => i.product.id == item.product.id);
      if (index != -1) {
        final existingItem = _items[index];
        final newQuantity = existingItem.quantity - 1;
        if (newQuantity > 0) {
          _items[index] = CartListItem(
            product: existingItem.product,
            quantity: newQuantity,
          );
        } else {
          _items.removeAt(index);
        }
      }
      _calculateTotalPrice();
    });
    widget.onRemoveFromCart(item);
  }

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = _items.fold(
        0,
        (previousValue, element) =>
            previousValue + element.product.price * element.quantity,
      );
    });
  }
}
