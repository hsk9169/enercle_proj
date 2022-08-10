import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:enercle_proj/sizes.dart';

class CircularLoading extends StatelessWidget {
  final double size;
  const CircularLoading({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(context.pHeight * size),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(3, 3), // changes position of shadow
              ),
            ]),
        child: CupertinoActivityIndicator(
          animating: true,
          radius: MediaQuery.of(context).size.height * size * 3,
        ));
  }
}
