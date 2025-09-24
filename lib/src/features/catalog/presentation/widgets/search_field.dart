// lib/src/features/catalog/presentation/widgets/search_field.dart
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Rechercher un produit…',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
