class BackupRecord {
  const BackupRecord({
    required this.id,
    required this.at,
    required this.label,
    required this.data,
  });

  final String id;
  final String at;
  final String label;
  final String data;

  Map<String, Object?> toJson() {
    return {'id': id, 'at': at, 'label': label, 'data': data};
  }
}
