class AssetEvent {
  const AssetEvent({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.notes,
  });

  final String id;
  final String type;
  final String date;
  final double amount;
  final String notes;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date,
      'amount': amount,
      'notes': notes,
    };
  }
}
