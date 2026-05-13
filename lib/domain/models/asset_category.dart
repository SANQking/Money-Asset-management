class AssetCategory {
  const AssetCategory({required this.name, required this.color});

  final String name;
  final String color;

  Map<String, Object?> toJson() => {'name': name, 'color': color};
}
