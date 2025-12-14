import 'package:bill_chillin/features/personal_expenses/data/models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String userId);
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId, String userId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoryRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await firestore
        .collection('users')
        .doc(category.userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toJson());
  }

  @override
  Future<void> deleteCategory(String categoryId, String userId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }
}
