import 'package:flutter/material.dart';
import 'package:simda_mobile/models/inventarisSearch.dart';
import 'package:simda_mobile/screens/inventaris/inventaris_detail_screen.dart';
import 'package:simda_mobile/theme/app_colors.dart';

class InventarisCardScreen extends StatelessWidget {
  final InventarisSearch item;
  const InventarisCardScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InventarisDetailScreen(id: item.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.jenisBarang,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(item.ruangan),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _ChipLabel({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

Widget _buildImage(String? url) {
  if (url == null) {
    return Image.asset(
      'assets/images/no_images.jpg',
      fit: BoxFit.cover,
    );
  }

  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Image.asset(
        'assets/images/no_images.jpg',
        fit: BoxFit.cover,
      );
    },
  );
}

Color _keadaanColor(String keadaan) {
  switch (keadaan.toLowerCase()) {
    case 'baik':
      return Colors.green;
    case 'rusak':
      return Colors.red;
    case 'rusak ringan':
      return Colors.orange;
    case 'hilang':
      return Colors.grey;
    default:
      return AppColors.blue600;
  }
}
