import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {

  final String title;

  const CategoryChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 6),

      child: Chip(

        label: Text(title),

        backgroundColor: Colors.grey.shade200,

      ),
    );
  }
}