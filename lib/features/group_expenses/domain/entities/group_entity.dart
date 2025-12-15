import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final List<String> members;
  final String currency;
  final String createdBy;
  final DateTime createdAt;
  final String? imageUrl;
  final List<String> searchKeywords;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.members,
    this.currency = 'VND',
    required this.createdBy,
    required this.createdAt,
    this.imageUrl,
    this.searchKeywords = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    members,
    currency,
    createdBy,
    createdAt,
    imageUrl,
    searchKeywords,
  ];

  GroupEntity copyWith({
    String? id,
    String? name,
    List<String>? members,
    String? currency,
    String? createdBy,
    DateTime? createdAt,
    String? imageUrl,
    List<String>? searchKeywords,
  }) {
    return GroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      currency: currency ?? this.currency,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      searchKeywords: searchKeywords ?? this.searchKeywords,
    );
  }
}
