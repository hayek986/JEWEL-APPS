import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final String imageUrl;

  const BackgroundWidget({
    super.key,
    required this.child,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
    }
  }
}
