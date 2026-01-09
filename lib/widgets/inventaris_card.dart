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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON KIRI
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.blue600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildImage(item.imageUrl),
            ),

            const SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.jenisBarang,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.ruangan,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // CHIP
                  Row(
                    children: [
                      _ChipLabel(
                        text: item.keadaan,
                        color: _keadaanColor(item.keadaan),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
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
