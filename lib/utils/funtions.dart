import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getImageUrl(String problemId) async {
  try {
    // Reference to the 'problems' collection and specific document
    final docSnapshot = await FirebaseFirestore.instance
        .collection('problems')
        .doc(problemId)
        .get();

    if (docSnapshot.exists) {
      // Retrieve the 'imageUrl' field
      final imageUrl = docSnapshot.data()?['imageUrl'];
      return imageUrl; // Returns the image URL
    } else {
      print("Document does not exist!");
      return null;
    }
  } catch (e) {
    print("Error getting image URL: $e");
    return null;
  }
}
