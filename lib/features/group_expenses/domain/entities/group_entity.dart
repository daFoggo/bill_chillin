import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final List<String> members;
  final String currency;
  final String createdBy;
  final DateTime createdAt;
  final String? imageUrl;

  const GroupEntity({
    required this.id,
    required this.name,
    required this.members,
    this.currency = 'VND',
    required this.createdBy,
    required this.createdAt,
    this.imageUrl,
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
  ];
}
