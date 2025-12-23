import 'package:ders7flutterproject/cart-list-item.dart';
import 'package:flutter/material.dart';

class CartListItemView extends StatelessWidget {
  const CartListItemView({
    super.key,
    required this.item,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });
  final CartListItem item;

  final Function(CartListItem) onRemoveFromCart;
  final Function(CartListItem) onAddToCart;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              width: 70,
              height: 70,
              child: Image.asset(product.image),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => onRemoveFromCart(item),
                          icon: Icon(Icons.remove, color: Colors.black),
                        ),
                        Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => onAddToCart(item),
                          icon: Icon(Icons.add, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '${product.price * item.quantity}£',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
