import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Ornamen Batik Mega Mendung menggunakan gambar asli yang sudah dihapus
/// background hitamnya (hanya tersisa garis putih transparan).
class MegaMendung extends StatelessWidget {
  final double width;
  final Color color;
  final bool flip;

  const MegaMendung({
    super.key,
    required this.width,
    this.color = const Color(0x3DFFFFFF),
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Skeleton.ignore(
        child: Transform.flip(
          flipX: flip,
          child: Image.asset(
            'assets/images/mega_mendung.png',
            width: width,
            fit: BoxFit.contain,
            color: color,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
      ),
    );
  }
}
