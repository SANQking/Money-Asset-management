enum AssetStatus {
  active('active', '使用中'),
  idle('idle', '闲置'),
  sold('sold', '已出售'),
  retired('retired', '已报废');

  const AssetStatus(this.code, this.zhLabel);

  final String code;
  final String zhLabel;

  static AssetStatus fromValue(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return AssetStatus.active;
    for (final status in values) {
      if (status.code == raw || status.zhLabel == raw) return status;
    }
    return AssetStatus.active;
  }
}
