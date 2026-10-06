class SnapshotMeta {
  final int snapshotId;
  final DateTime fetchedAt;
  final String siteUpdateText;
  final String sourceUrl;

  const SnapshotMeta({
    required this.snapshotId,
    required this.fetchedAt,
    required this.siteUpdateText,
    required this.sourceUrl,
  });

  factory SnapshotMeta.fromJson(Map<String, dynamic> json) {
    return SnapshotMeta(
      snapshotId: json['snapshot_id'] as int,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      siteUpdateText: json['site_update_text'] as String,
      sourceUrl: json['source_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'snapshot_id': snapshotId,
      'fetched_at': fetchedAt.toIso8601String(),
      'site_update_text': siteUpdateText,
      'source_url': sourceUrl,
    };
  }
}
