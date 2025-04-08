import 'package:flutter/material.dart';

class BookPage extends StatelessWidget {
  final String imagePath;
  final List<Map<String, dynamic>> textData;
  final VoidCallback onTap;

  const BookPage({
    Key? key,
    required this.imagePath,
    required this.textData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
          ...textData.map((data) => Positioned(
                left: data['X1'],
                top: data['Y1'],
                width: data['X2'] - data['X1'],
                height: data['Y2'] - data['Y1'],
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}