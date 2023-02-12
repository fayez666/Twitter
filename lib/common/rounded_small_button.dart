import 'package:flutter/material.dart';
import 'package:twitter/theme/theme.dart';

class RoundedSmallButton extends StatelessWidget {
  const RoundedSmallButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textColor = Pallete.backgroundColor,
    this.backgroundColor = Pallete.whiteColor,
  });

  final Color backgroundColor;
  final VoidCallback onTap;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        backgroundColor: backgroundColor,
        labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      ),
    );
  }
}
