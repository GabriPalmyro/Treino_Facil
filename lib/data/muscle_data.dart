import 'package:cloud_firestore/cloud_firestore.dart';

class MuscleData {
  String muscle;

  String id;
  String title;
  String description;

  MuscleData.fromDocument(DocumentSnapshot snapshot) {
    id = snapshot.id;
    title = snapshot.get("title");
    description = snapshot.get("description");
  }

  Map<String, dynamic> toResumeMap() {
    return {
      "title": title,
      "description": description,
    };
  }
}
