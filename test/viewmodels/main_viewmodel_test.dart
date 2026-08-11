import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lsp/modules/patient/models/patient_models.dart';
import 'package:lsp/modules/doctor/models/doctor_models.dart';
import 'package:lsp/viewmodels/main_viewmodel.dart';

class MockLocalStorage extends LocalStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => _storage['access_token'];

  @override
  Future<bool> hasAccessToken() async => _storage.containsKey('access_token');

  @override
  Future<void> removePersistedSession() async {
    _storage.clear();
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    _storage['access_token'] = persistSessionString;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock Channel SharedPreferences
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });

    await Supabase.initialize(
      url: 'https://obtsgtsjbnpzgldzwzvz.supabase.co',
      publishableKey: 'sb_publishable_fcgYZH_yGoyB81rNXoe2Tw_-6A8enHN',
      authOptions: FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
      ),
    );
  });

  group('MainViewModel State & Logic Unit Tests', () {
    late MainViewModel viewModel;

    setUp(() {
      viewModel = MainViewModel();
    });

    test('Initial State Test', () {
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('findReservationByBarcode return null if barcode not found', () {
      final res = viewModel.findReservationByBarcode('NON-EXISTENT-BARCODE');
      expect(res, isNull);
    });
  });
}
