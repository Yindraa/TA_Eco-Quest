class RewardModel {
  final String rewardId;
  final String name;
  final String description;
  final String category;
  final int costCoins;
  final int? rewardValue;
  final String? imageUrl;
  final int? stock;

  const RewardModel({
    required this.rewardId,
    required this.name,
    required this.description,
    required this.category,
    required this.costCoins,
    this.rewardValue,
    this.imageUrl,
    this.stock,
  });

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      rewardId: map['reward_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String,
      costCoins: (map['cost_coins'] as num).toInt(),
      rewardValue: (map['reward_value'] as num?)?.toInt(),
      imageUrl: map['image_url'] as String?,
      stock: (map['stock'] as num?)?.toInt(),
    );
  }

  bool get isTreeBoost   => category == 'tree_boost';
  bool get isExtraQuota  => category == 'extra_quota';
  bool get isMerchandise => category == 'merchandise';
  bool get isOutOfStock  => stock != null && stock! <= 0;

  String get categoryLabel => switch (category) {
    'tree_boost'  => 'Boost Pohon',
    'extra_quota' => 'Kuota Ekstra',
    _             => 'Merchandise',
  };

  String get emoji => switch (category) {
    'tree_boost'  => '🌱',
    'extra_quota' => '📋',
    _             => '🎁',
  };
}

class RedemptionModel {
  final String redemptionId;
  final String rewardName;
  final String rewardCategory;
  final String status;
  final DateTime redeemedAt;

  const RedemptionModel({
    required this.redemptionId,
    required this.rewardName,
    required this.rewardCategory,
    required this.status,
    required this.redeemedAt,
  });

  factory RedemptionModel.fromMap(Map<String, dynamic> map) {
    final reward = map['rewards'] as Map<String, dynamic>? ?? {};
    return RedemptionModel(
      redemptionId: map['redemption_id'] as String,
      rewardName: reward['name'] as String? ?? '-',
      rewardCategory: reward['category'] as String? ?? 'merchandise',
      status: map['status'] as String? ?? 'pending',
      redeemedAt: DateTime.tryParse(
            map['redeemed_at'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  bool get isMerchandise => rewardCategory == 'merchandise';
}
