import 'package:flutter/material.dart';
import 'package:pos/utilities/my_palette.dart';

class ProductFilter extends StatelessWidget {
  const ProductFilter({required this.onFilterChanged, super.key});

  final Function(String) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: primary.shade50,
      onSelected: onFilterChanged,
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'all',
            child: Text('Show All'),
          ),
          const PopupMenuItem<String>(
            value: 'available',
            child: Text('Available Products'),
          ),
          const PopupMenuItem<String>(
            value: 'Not Available',
            child: Text('Not Available Products'),
          ),
        ];
      },
    );
  }
}
