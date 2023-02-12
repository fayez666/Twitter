import 'package:flutter/material.dart';
import 'package:twitter/theme/pallete.dart';

class FollowCount extends StatelessWidget {
  final int count;
  final String text;
  const FollowCount({super.key, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    double fontSize = 18;
    return Row(
      children: [
        Text(
          "$count",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          text,
          style: TextStyle(
            color: Pallete.greyColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
