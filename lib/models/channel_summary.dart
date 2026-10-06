enum SummaryCategory {
  geopolitics,
  technology;

  static SummaryCategory fromApi(String value) {
    switch (value) {
      case 'geopolitics':
        return SummaryCategory.geopolitics;
      case 'technology':
        return SummaryCategory.technology;
      default:
        throw ArgumentError('Unknown summary category: $value');
    }
  }

  String get apiValue {
    switch (this) {
      case SummaryCategory.geopolitics:
        return 'geopolitics';
      case SummaryCategory.technology:
        return 'technology';
    }
  }
}

class ChannelSummary {
  final SummaryCategory category;
  final String categoryLabel;
  final String channelUsername;
  final int channelId;
  final int summaryId;
  final int fromMessageId;
  final int toMessageId;
  final int postCount;
  final String aiModel;
  final String summaryText;
  final DateTime createdAt;

  const ChannelSummary({
    required this.category,
    required this.categoryLabel,
    required this.channelUsername,
    required this.channelId,
    required this.summaryId,
    required this.fromMessageId,
    required this.toMessageId,
    required this.postCount,
    required this.aiModel,
    required this.summaryText,
    required this.createdAt,
  });

  factory ChannelSummary.fromJson(Map<String, dynamic> json) {
    return ChannelSummary(
      category: SummaryCategory.fromApi(json['category'] as String),
      categoryLabel: json['category_label'] as String,
      channelUsername: json['channel_username'] as String,
      channelId: json['channel_id'] as int,
      summaryId: json['summary_id'] as int,
      fromMessageId: json['from_message_id'] as int,
      toMessageId: json['to_message_id'] as int,
      postCount: json['post_count'] as int,
      aiModel: json['ai_model'] as String,
      summaryText: json['summary_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.apiValue,
      'category_label': categoryLabel,
      'channel_username': channelUsername,
      'channel_id': channelId,
      'summary_id': summaryId,
      'from_message_id': fromMessageId,
      'to_message_id': toMessageId,
      'post_count': postCount,
      'ai_model': aiModel,
      'summary_text': summaryText,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
