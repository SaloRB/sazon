import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';

class RecipesRepository {
  final ApiClient _apiClient;

  RecipesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /recipes?mine=true|false
  Future<List<Recipe>> getRecipes({
    bool mine = false,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};

    if (mine) {
      queryParams['mine'] = 'true';
    }
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _apiClient.dio.get(
      '/recipes',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final body = response.data as Map<String, dynamic>;

    // data should be: { recipes: [ ... ] }
    final recipesJson = (body['recipes'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return recipesJson.map((item) => Recipe.fromJson(item)).toList();
  }

  /// GET /recipes/:id
  Future<RecipeDetail> getRecipeDetail(int id) async {
    final data = await _apiClient.dio.get('/recipes/$id');
    return RecipeDetail.fromJson(data as Map<String, dynamic>);
  }

  /// POST /recipes
  Future<RecipeDetail> createRecipe(CreateRecipeInput input) async {
    final data = await _apiClient.dio.post('/recipes', data: input.toJson());

    return RecipeDetail.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /recipes/:id
  Future<RecipeDetail> updateRecipe(int id, UpdateRecipeInput input) async {
    final response = await _apiClient.dio.put(
      '/recipes/$id',
      data: input.toJson(),
    );

    final body = response.data as Map<String, dynamic>;
    return RecipeDetail.fromJson(body);
  }

  /// DELETE /recipes/:id
  Future<void> deleteRecipe(int id) async {
    await _apiClient.dio.delete('/recipes/$id');
  }
}
