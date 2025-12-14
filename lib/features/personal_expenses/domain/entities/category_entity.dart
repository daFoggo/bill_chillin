import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String userId;
  final String type; // 'income' or 'expense'

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.userId,
    this.type = 'expense',
  });

  @override
  List<Object?> get props => [id, name, icon, userId, type];
}
