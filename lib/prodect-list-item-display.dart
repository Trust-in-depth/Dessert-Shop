import 'package:ders7flutterproject/product-details-page.dart';
import 'package:ders7flutterproject/product-list-item.dart';
import 'package:flutter/material.dart';

class ProductListItemDisplay extends StatelessWidget {
  const ProductListItemDisplay({super.key, required this.item, required this.onAddToCart});

  

  final ProductListItem item;
  final Function(ProductListItem) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetails(
            product:item,
            onAddToCart: onAddToCart,

          ),
          )
        );

      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical:12, horizontal: 16),
        child:Row(

          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(item.image),
              )
              ),

              Expanded(child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                  
                    fontWeight: FontWeight.bold,
                    ),
                    ),
                    Padding(padding: EdgeInsets.only(top:4),
                    child: Text(
                      item.description,
                      style:TextStyle(
                        fontSize: 14
                        ),
                        maxLines: 2,
                    )
                    )
                ],
                ),
              ),
              ),
              Row(
                children: [
                  Text(
                    '${item.price}\$',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),



                  ),
                                      
                    SizedBox(width:10),
                    GestureDetector(
                      onTap: () => onAddToCart(item),
                      child: Icon(Icons.add, size:24, color:Theme.of(context).colorScheme.secondary,
                      ),
                    )

                ],
              )

            
          ],



        ),
      ),

    );
  }
}