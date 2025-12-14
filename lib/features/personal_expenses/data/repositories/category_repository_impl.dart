import 'package:bill_chillin/features/personal_expenses/data/datasources/category_remote_data_source.dart';
import 'package:bill_chillin/features/personal_expenses/data/models/category_model.dart';
import 'package:bill_chillin/features/personal_expenses/domain/entities/category_entity.dart';
import 'package:bill_chillin/features/personal_expenses/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories(String userId) async {
    return await remoteDataSource.getCategories(userId);
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await remoteDataSource.addCategory(model);
  }

  @override
  Future<void> deleteCategory(String categoryId, String userId) async {
    await remoteDataSource.deleteCategory(categoryId, userId);
  }
}
