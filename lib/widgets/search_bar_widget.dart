import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {

  final Function(String) onChanged;

  const SearchBarWidget({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10),

      child: TextField(

        onChanged: onChanged,

        decoration: InputDecoration(

          hintText: "Search watches",

          prefixIcon: const Icon(Icons.search),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),

        ),
      ),
    );
  }
}