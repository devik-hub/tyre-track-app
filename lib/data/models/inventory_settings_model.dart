class InventorySettingsModel {
  final int tyreLowStockThreshold;
  final int casingLowStockThreshold;

  InventorySettingsModel({
    this.tyreLowStockThreshold   = 3,
    this.casingLowStockThreshold = 2,
  });

  factory InventorySettingsModel.fromMap(Map<String, dynamic> data) {
    return InventorySettingsModel(
      tyreLowStockThreshold:   data['tyreLowStockThreshold']   as int? ?? 3,
      casingLowStockThreshold: data['casingLowStockThreshold'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toMap() => {
    'tyreLowStockThreshold':   tyreLowStockThreshold,
    'casingLowStockThreshold': casingLowStockThreshold,
  };
}
