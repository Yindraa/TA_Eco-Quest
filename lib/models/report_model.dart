class ReportModel {
  final String? reportId;
  final String userId;
  final double latitude;
  final double longitude;
  final String wasteSize;
  final String imageUrl;
  final String? description;
  final String status;
  final DateTime createdAt;

  const ReportModel({
    this.reportId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.wasteSize,
    required this.imageUrl,
    this.description,
    this.status = 'pending',
    required this.createdAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['report_id'] as String?,
      userId: map['user_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      wasteSize: map['waste_size'] as String,
      imageUrl: map['image_url'] as String,
      description: map['description'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static String statusLabel(String status) {
    return switch (status) {
      'pending'  => 'Menunggu',
      'claimed'  => 'Diklaim',
      'resolved' => 'Diselesaikan',
      'valid'    => 'Tervalidasi',
      'rejected' => 'Ditolak',
      _          => 'Tidak Diketahui',
    };
  }
}
