class AppUpdateInfo {
  final bool updateAvailable;
  final bool forceUpdate;
  final String currentVersion;
  final String latestVersion;
  final String minRequiredVersion;
  final String updateUrl;
  final String? releaseNotes;
  final bool isCritical;

  const AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.updateUrl,
    required this.releaseNotes,
    required this.isCritical,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      updateAvailable: json['update_available'] as bool? ?? false,
      forceUpdate: json['force_update'] as bool? ?? false,
      currentVersion: json['current_version'] as String? ?? '',
      latestVersion: json['latest_version'] as String? ?? '',
      minRequiredVersion: json['min_required_version'] as String? ?? '',
      updateUrl: json['update_url'] as String? ?? '',
      releaseNotes: json['release_notes'] as String?,
      isCritical: json['is_critical'] as bool? ?? false,
    );
  }
}
