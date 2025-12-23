import 'package:flutter/material.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key, required this.count});
  final int count;


  @override
  Widget build(BuildContext context) {
    const borderRadius= BorderRadius.all(Radius.circular(10));
    return  Container(
      width: 50,
      height:50,
      padding:EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: borderRadius, color:Colors.lightGreen),
      child: Stack(
        children:[const Center(
          child:Icon(Icons.shopping_cart, size:30, color: Colors.black,)
          ),


          Positioned(
            child:Container(padding:const EdgeInsets.all(2),
            decoration: BoxDecoration(color:Colors.pink,
            borderRadius: borderRadius,
            ),
            constraints: const BoxConstraints(minHeight: 15, minWidth: 15),
            child:Text('$count',
            style: TextStyle(color:Colors.white, fontSize: 10),
            textAlign: TextAlign.center,
            
            )
            ),
            )
          ]
      )
    );
  }
}