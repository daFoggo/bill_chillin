import 'package:bill_chillin/features/personal_expenses/domain/repositories/category_repository.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_event.dart';
import 'package:bill_chillin/features/personal_expenses/presentation/bloc/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.getCategories(event.userId);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    // Keep current loaded state if possible, or just loading
    // Ideally we want to show loading indicator then reload or just append
    // For simplicity: Loading -> OperationSuccess -> Reload in UI or here
    emit(CategoryLoading());
    try {
      await repository.addCategory(event.category);
      emit(const CategoryOperationSuccess("Category added successfully"));
      // Reload categories
      add(LoadCategoriesEvent(event.category.userId));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await repository.deleteCategory(event.categoryId, event.userId);
      emit(const CategoryOperationSuccess("Category deleted successfully"));
      add(LoadCategoriesEvent(event.userId));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
