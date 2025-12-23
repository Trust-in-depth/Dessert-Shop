import 'package:ders7flutterproject/prodect-list-item-display.dart';
import 'package:ders7flutterproject/product-list-item.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key,  required this.onAddToCart,});
  final Function(ProductListItem) onAddToCart;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {

  List<ProductListItem> items = [

ProductListItem(id: '1', name: 'Cupcake', description: 'A delicios cupcake', price: 23, image: 'images/cupcake.png'),
ProductListItem(id: '2', name: 'Donut', description: 'A delicios donut', price: 23, image: 'images/donut.png'),
ProductListItem(id: '3', name: 'eclair', description: 'A delicios eclair', price: 23, image: 'images/eclair.png'),
ProductListItem(id: '4', name: 'Gingerbread', description: 'A delicios Gingerbread', price: 23, image: 'images/gingerbread.png'),
ProductListItem(id: '5', name: 'Froyo', description: 'A delicios Froyo', price: 23, image: 'images/froyo.png')

  ];
  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      itemBuilder: (context,index){
      
      final item = items[index];


      return ProductListItemDisplay(item: item, onAddToCart: widget.onAddToCart,);
    });
  }
}