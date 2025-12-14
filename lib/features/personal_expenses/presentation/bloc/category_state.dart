import 'package:bill_chillin/features/personal_expenses/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  const CategoryOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
