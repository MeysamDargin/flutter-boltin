import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  static const _boxName = 'app_storage';
  static const _deviceIdKey = 'device_uuid';

  const DeviceIdentityService();

  Future<String> getOrCreateDeviceId() async {
    final box = await Hive.openBox<dynamic>(_boxName);
    final existing = box.get(_deviceIdKey);

    if (existing is String && existing.trim().isNotEmpty) {
      return existing;
    }

    final deviceId = const Uuid().v4();
    await box.put(_deviceIdKey, deviceId);
    return deviceId;
  }
}
