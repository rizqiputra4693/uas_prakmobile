import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  const CategoryButton({
    Key? key,
    required this.label,
    this.isActive = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.red : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

