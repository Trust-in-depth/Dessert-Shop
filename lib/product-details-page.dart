import 'package:ders7flutterproject/product-list-item.dart';
import 'package:flutter/material.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.product, required this.onAddToCart});

  final ProductListItem product;
  final Function(ProductListItem) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text(product.name),
    ),

    body: Stack(
      fit:StackFit.expand,
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(
              width: double.infinity,
              child: Hero(
                tag:product.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.asset((product.image)),
                ),
                ),
            ),
            Padding(
              padding:EdgeInsetsGeometry.fromLTRB(20, 20, 20, 20),
              child: Text(
                product.name,
                style:TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding:EdgeInsetsGeometry.fromLTRB(20, 20, 20, 20),
              child: Text(
                '${product.price}£',
                style:TextStyle(fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding:EdgeInsetsGeometry.fromLTRB(20, 20, 20, 20),
              child: Text(
                product.description,
                style:TextStyle(fontSize: 20,
                ),
              ),
            ),
            ],
          ),
        ),

        Positioned(
          left:0,
          right:0,
          bottom:0,
          child: Padding(
            padding: EdgeInsetsGeometry.fromLTRB(20, 20, 20, 20),
            child: ElevatedButton(onPressed: ()=>onAddToCart(product),
              style:ElevatedButton.styleFrom(
                padding:EdgeInsets.symmetric(horizontal: 30, vertical:15),
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: Text(
              'Add to Cart', 
              style:TextStyle(fontSize: 20)
              ),
              ),
            ),
        ),
      ],

    ),

    );
  }
}