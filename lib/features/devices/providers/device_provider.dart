import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/device_repository.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (_) => DeviceRepository(),
);

final devicesProvider = FutureProvider<List<DeviceModel>>((ref) async {
  return ref.read(deviceRepositoryProvider).getDevices();
});
