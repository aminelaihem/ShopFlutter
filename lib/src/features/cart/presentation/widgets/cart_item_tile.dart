// lib/src/features/cart/presentation/widgets/cart_item_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/cart_item.dart';
import '../../../../core/formatters/money.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onQtyChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(imageUrl: item.thumbnail, width: 56, height: 56, fit: BoxFit.cover),
      ),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatPrice(item.price)),
      trailing: SizedBox(
        width: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(onPressed: () => onQtyChanged(item.qty - 1), icon: const Icon(Icons.remove)),
            Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w600)),
            IconButton(onPressed: () => onQtyChanged(item.qty + 1), icon: const Icon(Icons.add)),
            IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
