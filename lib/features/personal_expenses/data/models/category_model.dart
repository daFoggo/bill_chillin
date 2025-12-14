import 'package:bill_chillin/features/personal_expenses/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.userId,
    super.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String? ?? 'expense',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'userId': userId,
      'type': type,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      userId: entity.userId,
      type: entity.type,
    );
  }
}
