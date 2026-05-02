import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class DeviceModel {
  final String id;
  final String? deviceName;   // istemci UUID'si
  final String? displayName;  // okunabilir isim
  final String? deviceType;   // android, ios, windows...
  final String status;        // active | revoked | banned
  final DateTime? lastActiveAt;
  final DateTime? createdAt;

  const DeviceModel({
    required this.id,
    this.deviceName,
    this.displayName,
    this.deviceType,
    required this.status,
    this.lastActiveAt,
    this.createdAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      deviceName: json['device_name'] as String?,
      displayName: json['display_name'] as String?,
      deviceType: json['device_type'] as String?,
      status: json['status'] as String? ?? 'active',
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.tryParse(json['last_active_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  String get label => displayName ?? deviceType ?? 'Bilinmeyen Cihaz';
}

class DeviceRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<DeviceModel>> getDevices() async {
    final response = await _dio.get(ApiConstants.devices);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> revokeDevice(String deviceId) async {
    await _dio.delete(ApiConstants.deviceRevoke(deviceId));
  }

  Future<void> banDevice(String deviceId) async {
    await _dio.patch(ApiConstants.deviceBan(deviceId));
  }
}
