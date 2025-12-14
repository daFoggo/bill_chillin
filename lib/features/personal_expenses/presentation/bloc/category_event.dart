import 'package:bill_chillin/features/personal_expenses/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {
  final String userId;
  const LoadCategoriesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  const AddCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String userId;
  const DeleteCategoryEvent(this.categoryId, this.userId);

  @override
  List<Object> get props => [categoryId, userId];
}
