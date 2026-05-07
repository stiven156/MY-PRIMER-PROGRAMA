import 'package:gym_app/core/models/nutrition_model.dart';

class FoodDatabase {
  static List<FoodItem> get all => [
    ..._proteins, ..._carbs, ..._fats, ..._dairy, ..._fruits, ..._vegetables, ..._snacks, ..._drinks,
  ];

  // ---------------------------------------------------------------------------
  // Proteins
  // ---------------------------------------------------------------------------
  static final _proteins = <FoodItem>[
    FoodItem(id: 'f001', name: 'Pechuga de Pollo', category: 'Proteínas',
        calories: 165, protein: 31, carbs: 0, fat: 3.6, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f002', name: 'Atún en Agua', category: 'Proteínas',
        calories: 116, protein: 25.5, carbs: 0, fat: 1.0, servingUnit: 'g', defaultServing: 90),
    FoodItem(id: 'f003', name: 'Claras de Huevo', category: 'Proteínas',
        calories: 52, protein: 10.9, carbs: 0.7, fat: 0.2, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f004', name: 'Huevo Entero', category: 'Proteínas',
        calories: 155, protein: 13, carbs: 1.1, fat: 11, servingUnit: 'g', defaultServing: 60),
    FoodItem(id: 'f005', name: 'Carne de Res Magra', category: 'Proteínas',
        calories: 217, protein: 26, carbs: 0, fat: 12, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f006', name: 'Salmón', category: 'Proteínas',
        calories: 208, protein: 20, carbs: 0, fat: 13, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f007', name: 'Tilapia', category: 'Proteínas',
        calories: 128, protein: 26, carbs: 0, fat: 2.7, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f008', name: 'Proteína Whey', category: 'Proteínas',
        calories: 380, protein: 75, carbs: 8, fat: 5, servingUnit: 'g', defaultServing: 30),
    FoodItem(id: 'f009', name: 'Pavo en Pechuga', category: 'Proteínas',
        calories: 135, protein: 29, carbs: 0, fat: 2, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f010', name: 'Carne de Cerdo Magra', category: 'Proteínas',
        calories: 143, protein: 22, carbs: 0, fat: 5.4, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f011', name: 'Camarones', category: 'Proteínas',
        calories: 99, protein: 20, carbs: 0.2, fat: 1.1, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f012', name: 'Tempeh', category: 'Proteínas',
        calories: 193, protein: 19, carbs: 9, fat: 11, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f013', name: 'Tofu Firme', category: 'Proteínas',
        calories: 76, protein: 8, carbs: 1.9, fat: 4.8, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f014', name: 'Sardinas en Agua', category: 'Proteínas',
        calories: 208, protein: 25, carbs: 0, fat: 11, servingUnit: 'g', defaultServing: 90),
  ];

  // ---------------------------------------------------------------------------
  // Carbs
  // ---------------------------------------------------------------------------
  static final _carbs = <FoodItem>[
    FoodItem(id: 'f021', name: 'Arroz Blanco (cocido)', category: 'Carbohidratos',
        calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f022', name: 'Arroz Integral (cocido)', category: 'Carbohidratos',
        calories: 123, protein: 2.6, carbs: 26, fat: 0.9, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f023', name: 'Avena en Hojuelas', category: 'Carbohidratos',
        calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10, servingUnit: 'g', defaultServing: 50),
    FoodItem(id: 'f024', name: 'Papa Cocida', category: 'Carbohidratos',
        calories: 87, protein: 1.9, carbs: 20, fat: 0.1, servingUnit: 'g', defaultServing: 200),
    FoodItem(id: 'f025', name: 'Camote/Batata', category: 'Carbohidratos',
        calories: 86, protein: 1.6, carbs: 20, fat: 0.1, fiber: 3, servingUnit: 'g', defaultServing: 200),
    FoodItem(id: 'f026', name: 'Pan Integral', category: 'Carbohidratos',
        calories: 247, protein: 9, carbs: 41, fat: 3.4, fiber: 7, servingUnit: 'g', defaultServing: 50),
    FoodItem(id: 'f027', name: 'Pasta Integral (cocida)', category: 'Carbohidratos',
        calories: 149, protein: 5.3, carbs: 29, fat: 1.1, fiber: 4, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f028', name: 'Quinoa (cocida)', category: 'Carbohidratos',
        calories: 120, protein: 4.4, carbs: 21.3, fat: 1.9, fiber: 2.8, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f029', name: 'Frijoles Negros (cocidos)', category: 'Carbohidratos',
        calories: 132, protein: 8.9, carbs: 24, fat: 0.5, fiber: 8.7, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f030', name: 'Lentejas (cocidas)', category: 'Carbohidratos',
        calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 7.9, servingUnit: 'g', defaultServing: 150),
    FoodItem(id: 'f031', name: 'Tortilla de Maíz', category: 'Carbohidratos',
        calories: 218, protein: 5.7, carbs: 44, fat: 2.5, servingUnit: 'g', defaultServing: 60),
    FoodItem(id: 'f032', name: 'Maíz Cocido', category: 'Carbohidratos',
        calories: 96, protein: 3.4, carbs: 21, fat: 1.5, fiber: 2, servingUnit: 'g', defaultServing: 100),
  ];

  // ---------------------------------------------------------------------------
  // Fats
  // ---------------------------------------------------------------------------
  static final _fats = <FoodItem>[
    FoodItem(id: 'f041', name: 'Aguacate', category: 'Grasas',
        calories: 160, protein: 2, carbs: 9, fat: 15, fiber: 7, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f042', name: 'Aceite de Oliva', category: 'Grasas',
        calories: 884, protein: 0, carbs: 0, fat: 100, servingUnit: 'ml', defaultServing: 14),
    FoodItem(id: 'f043', name: 'Almendras', category: 'Grasas',
        calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 12.5, servingUnit: 'g', defaultServing: 30),
    FoodItem(id: 'f044', name: 'Nueces', category: 'Grasas',
        calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 6.7, servingUnit: 'g', defaultServing: 30),
    FoodItem(id: 'f045', name: 'Mantequilla de Maní', category: 'Grasas',
        calories: 588, protein: 25, carbs: 20, fat: 50, fiber: 6, servingUnit: 'g', defaultServing: 32),
    FoodItem(id: 'f046', name: 'Semillas de Chía', category: 'Grasas',
        calories: 486, protein: 17, carbs: 42, fat: 31, fiber: 34, servingUnit: 'g', defaultServing: 28),
    FoodItem(id: 'f047', name: 'Semillas de Lino', category: 'Grasas',
        calories: 534, protein: 18, carbs: 29, fat: 42, fiber: 27, servingUnit: 'g', defaultServing: 15),
    FoodItem(id: 'f048', name: 'Aceite de Coco', category: 'Grasas',
        calories: 862, protein: 0, carbs: 0, fat: 100, servingUnit: 'ml', defaultServing: 14),
  ];

  // ---------------------------------------------------------------------------
  // Dairy
  // ---------------------------------------------------------------------------
  static final _dairy = <FoodItem>[
    FoodItem(id: 'f051', name: 'Yogur Griego (0% grasa)', category: 'Lácteos',
        calories: 59, protein: 10, carbs: 3.6, fat: 0.4, servingUnit: 'g', defaultServing: 170),
    FoodItem(id: 'f052', name: 'Leche Entera', category: 'Lácteos',
        calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, servingUnit: 'ml', defaultServing: 240),
    FoodItem(id: 'f053', name: 'Leche Descremada', category: 'Lácteos',
        calories: 35, protein: 3.4, carbs: 5, fat: 0.2, servingUnit: 'ml', defaultServing: 240),
    FoodItem(id: 'f054', name: 'Queso Cottage', category: 'Lácteos',
        calories: 98, protein: 11, carbs: 3.4, fat: 4.3, servingUnit: 'g', defaultServing: 130),
    FoodItem(id: 'f055', name: 'Queso Mozzarella', category: 'Lácteos',
        calories: 280, protein: 28, carbs: 3.1, fat: 17, servingUnit: 'g', defaultServing: 30),
    FoodItem(id: 'f056', name: 'Requesón Bajo en Grasa', category: 'Lácteos',
        calories: 72, protein: 12.4, carbs: 3.4, fat: 1.0, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f057', name: 'Leche de Almendras sin Azúcar', category: 'Lácteos',
        calories: 15, protein: 0.6, carbs: 0.6, fat: 1.2, servingUnit: 'ml', defaultServing: 240),
  ];

  // ---------------------------------------------------------------------------
  // Fruits
  // ---------------------------------------------------------------------------
  static final _fruits = <FoodItem>[
    FoodItem(id: 'f061', name: 'Plátano/Banano', category: 'Frutas',
        calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6, sugar: 12, servingUnit: 'g', defaultServing: 118),
    FoodItem(id: 'f062', name: 'Manzana', category: 'Frutas',
        calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4, sugar: 10, servingUnit: 'g', defaultServing: 182),
    FoodItem(id: 'f063', name: 'Naranja', category: 'Frutas',
        calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4, servingUnit: 'g', defaultServing: 130),
    FoodItem(id: 'f064', name: 'Fresa', category: 'Frutas',
        calories: 32, protein: 0.7, carbs: 7.7, fat: 0.3, fiber: 2, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f065', name: 'Arándanos', category: 'Frutas',
        calories: 57, protein: 0.7, carbs: 14, fat: 0.3, fiber: 2.4, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f066', name: 'Mango', category: 'Frutas',
        calories: 60, protein: 0.8, carbs: 15, fat: 0.4, fiber: 1.6, servingUnit: 'g', defaultServing: 165),
    FoodItem(id: 'f067', name: 'Sandía', category: 'Frutas',
        calories: 30, protein: 0.6, carbs: 7.6, fat: 0.2, servingUnit: 'g', defaultServing: 286),
    FoodItem(id: 'f068', name: 'Kiwi', category: 'Frutas',
        calories: 61, protein: 1.1, carbs: 15, fat: 0.5, fiber: 3, servingUnit: 'g', defaultServing: 76),
    FoodItem(id: 'f069', name: 'Piña', category: 'Frutas',
        calories: 50, protein: 0.5, carbs: 13, fat: 0.1, fiber: 1.4, servingUnit: 'g', defaultServing: 165),
  ];

  // ---------------------------------------------------------------------------
  // Vegetables
  // ---------------------------------------------------------------------------
  static final _vegetables = <FoodItem>[
    FoodItem(id: 'f071', name: 'Brócoli', category: 'Verduras',
        calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f072', name: 'Espinaca', category: 'Verduras',
        calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f073', name: 'Pepino', category: 'Verduras',
        calories: 16, protein: 0.7, carbs: 3.6, fat: 0.1, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f074', name: 'Tomate', category: 'Verduras',
        calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2, servingUnit: 'g', defaultServing: 123),
    FoodItem(id: 'f075', name: 'Lechuga Romana', category: 'Verduras',
        calories: 17, protein: 1.2, carbs: 3.3, fat: 0.3, fiber: 2.1, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f076', name: 'Zanahoria', category: 'Verduras',
        calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f077', name: 'Pimiento Rojo', category: 'Verduras',
        calories: 31, protein: 1, carbs: 7.3, fat: 0.3, fiber: 2.1, servingUnit: 'g', defaultServing: 120),
    FoodItem(id: 'f078', name: 'Apio', category: 'Verduras',
        calories: 16, protein: 0.7, carbs: 3, fat: 0.2, fiber: 1.6, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f079', name: 'Coliflor', category: 'Verduras',
        calories: 25, protein: 1.9, carbs: 5, fat: 0.3, fiber: 2, servingUnit: 'g', defaultServing: 100),
    FoodItem(id: 'f080', name: 'Cebolla', category: 'Verduras',
        calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, fiber: 1.7, servingUnit: 'g', defaultServing: 100),
  ];

  // ---------------------------------------------------------------------------
  // Snacks
  // ---------------------------------------------------------------------------
  static final _snacks = <FoodItem>[
    FoodItem(id: 'f081', name: 'Barra de Proteína', category: 'Snacks',
        calories: 350, protein: 30, carbs: 40, fat: 8, servingUnit: 'g', defaultServing: 60),
    FoodItem(id: 'f082', name: 'Galletas de Arroz', category: 'Snacks',
        calories: 387, protein: 7.3, carbs: 82, fat: 3, servingUnit: 'g', defaultServing: 30),
    FoodItem(id: 'f083', name: 'Maní Tostado sin Sal', category: 'Snacks',
        calories: 587, protein: 24, carbs: 21, fat: 50, fiber: 8, servingUnit: 'g', defaultServing: 28),
    FoodItem(id: 'f084', name: 'Chocolate Negro 85%', category: 'Snacks',
        calories: 598, protein: 9, carbs: 26, fat: 48, servingUnit: 'g', defaultServing: 20),
    FoodItem(id: 'f085', name: 'Granola sin Azúcar', category: 'Snacks',
        calories: 471, protein: 10, carbs: 64, fat: 20, fiber: 7, servingUnit: 'g', defaultServing: 50),
    FoodItem(id: 'f086', name: 'Edamame', category: 'Snacks',
        calories: 122, protein: 11, carbs: 10, fat: 5.2, fiber: 5.2, servingUnit: 'g', defaultServing: 100),
  ];

  // ---------------------------------------------------------------------------
  // Drinks
  // ---------------------------------------------------------------------------
  static final _drinks = <FoodItem>[
    FoodItem(id: 'f091', name: 'Agua', category: 'Bebidas',
        calories: 0, protein: 0, carbs: 0, fat: 0, servingUnit: 'ml', defaultServing: 250),
    FoodItem(id: 'f092', name: 'Batido Proteico', category: 'Bebidas',
        calories: 40, protein: 6, carbs: 3, fat: 0.5, servingUnit: 'ml', defaultServing: 350),
    FoodItem(id: 'f093', name: 'Jugo de Naranja Natural', category: 'Bebidas',
        calories: 45, protein: 0.7, carbs: 10, fat: 0.2, servingUnit: 'ml', defaultServing: 240),
    FoodItem(id: 'f094', name: 'Café Negro', category: 'Bebidas',
        calories: 2, protein: 0.3, carbs: 0, fat: 0, servingUnit: 'ml', defaultServing: 240),
    FoodItem(id: 'f095', name: 'Té Verde', category: 'Bebidas',
        calories: 1, protein: 0, carbs: 0.2, fat: 0, servingUnit: 'ml', defaultServing: 240),
    FoodItem(id: 'f096', name: 'Bebida Deportiva', category: 'Bebidas',
        calories: 21, protein: 0, carbs: 5.4, fat: 0, sodium: 110, servingUnit: 'ml', defaultServing: 500),
  ];

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static List<String> get categories => [
    'Proteínas', 'Carbohidratos', 'Grasas', 'Lácteos', 'Frutas', 'Verduras', 'Snacks', 'Bebidas',
  ];

  static List<FoodItem> byCategory(String category) =>
      all.where((f) => f.category == category).toList();

  static List<FoodItem> search(String query) {
    final q = query.toLowerCase();
    return all.where((f) => f.name.toLowerCase().contains(q) || f.category.toLowerCase().contains(q)).toList();
  }
}
