import 'package:e_agritech_app/utils/funtions.dart';
import 'package:flutter/material.dart';


class ProblemImageWidget extends StatelessWidget {
  final String problemId;

  const ProblemImageWidget({super.key, required this.problemId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getImageUrl(problemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); 
        } else if (snapshot.hasError) {
          return Text("Error loading image"); 
        } else if (snapshot.hasData && snapshot.data != null) {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.broken_image, size: 100);
            },
          );
        } else {
          return Icon(Icons.image_not_supported, size: 100); 
        }
      },
    );
  }
}
