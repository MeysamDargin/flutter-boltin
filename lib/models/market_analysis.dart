class MarketAnalysis {
  final int id;
  final String? title;
  final String analysisText;
  final String? aiModel;
  final DateTime createdAt;

  const MarketAnalysis({
    required this.id,
    required this.title,
    required this.analysisText,
    required this.aiModel,
    required this.createdAt,
  });

  factory MarketAnalysis.fromJson(Map<String, dynamic> json) {
    return MarketAnalysis(
      id: json['id'] as int,
      title: json['title'] as String?,
      analysisText: json['analysis_text'] as String? ?? '',
      aiModel: json['ai_model'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
