import 'package:flutter/material.dart';

class FoodItemCard extends StatelessWidget {
  final String itemName;
  final String category;
  final String timing;
  final String location;
  final VoidCallback onAddToCart; // Callback for add to cart action

  const FoodItemCard({
    super.key,
    required this.itemName,
    required this.category,
    required this.timing,
    required this.location,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.fastfood, size: 40), // Replace with relevant icon
        title: Text(
          itemName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: $category'),
            Text('Timing: $timing'),
            Text('Location: $location'),
          ],
        ),
      ),
    );
  }
}