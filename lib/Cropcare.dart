import 'dart:ui';
import 'package:flutter/material.dart';

class CropCareScreen extends StatelessWidget {
  final Map<String, dynamic> crop;

  const CropCareScreen({required this.crop, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(crop["detailImage"]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Crop Care",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(1, 1),
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  ...crop["stages"].map<Widget>((stage) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: ExpansionTile(
                                              leading: const Icon(Icons.eco, color: Colors.green),
                                              title: Text(
                                                stage["title"],
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    stage["description"],
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
