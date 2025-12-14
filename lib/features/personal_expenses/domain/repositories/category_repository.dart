import 'package:bill_chillin/features/personal_expenses/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories(String userId);
  Future<void> addCategory(CategoryEntity category);
  Future<void> deleteCategory(String categoryId, String userId);
}
