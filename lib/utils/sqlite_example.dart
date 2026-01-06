import '../models/meal_db_model.dart';
import '../services/database_service.dart';

Future<void> sqliteExample() async {
  // Insert a meal
  final meal = MealDbModel(
    title: 'Family Dinner Feast',
    type: 'Dinner',
    vendor: "Ate's Specialties",
    desc: 'A satisfying meal for four, ready to serve',
    price: 499,
    left: 12,
    imageUrl: 'assets/images/food_package_1.jpg',
  );
  await DatabaseService.insertMeal(meal.toMap());

  // Get all meals
  final meals = await DatabaseService.getMeals();

  // Update a meal
  if (meals.isNotEmpty) {
    final firstMeal = meals.first;
    await DatabaseService.updateMeal(firstMeal['id'], {
      ...firstMeal,
      'left': 10,
    });
  }

  // Delete a meal
  if (meals.isNotEmpty) {
    final firstMeal = meals.first;
    await DatabaseService.deleteMeal(firstMeal['id']);
  }
}
