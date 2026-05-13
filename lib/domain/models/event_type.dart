enum AssetEventKind {
  purchase('购买'),
  repair('维修'),
  maintenance('保养'),
  valuation('估值'),
  use('使用'),
  sell('出售'),
  retire('报废'),
  note('备注');

  const AssetEventKind(this.label);

  final String label;

  static const labels = <String>[
    '购买',
    '维修',
    '保养',
    '估值',
    '使用',
    '出售',
    '报废',
    '备注',
  ];
}
