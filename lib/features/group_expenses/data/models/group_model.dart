import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/util/string_utils.dart';
import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    required super.members,
    required super.currency,
    required super.createdBy,
    required super.createdAt,
    super.imageUrl,
    super.searchKeywords,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      currency: data['currency'] ?? 'VND',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toDocument() {
    List<String> keywords = StringUtils.generateKeywords(name);
    return {
      'name': name,
      'members': members,
      'currency': currency,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'searchKeywords': keywords,
    };
  }
}
