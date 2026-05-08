class Category {
  final String id;
  final String name;
  final String description;

  /// Hex color string representing the category's display color.
  /// Accepted formats: '#RRGGBB', '#AARRGGBB', or bare hex without the hash.
  /// Example: '#FF5733'
  final String color;

  /// Icon identifier used to look up the icon in the Flutter icon set.
  /// Example: 'shopping_cart', 'local_drink'
  final String iconName;

  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.iconName,
    required this.isActive,
  });

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? iconName,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'iconName': iconName,
      'isActive': isActive,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: json['color'] as String,
      iconName: json['iconName'] as String,
      isActive: json['isActive'] as bool,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.iconName == iconName &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, color, iconName, isActive);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, '
        'color: $color, iconName: $iconName, isActive: $isActive)';
  }
}
