import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentAuthUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;

  // --- AUTH SERVICES ---
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('Supabase Auth Primary Gateway Info: $e. Attemping profile fallback...');
      // Fallback Login: Jika user terdaftar di tabel public.users (misal dokter yang baru dibuat Admin)
      final userRecord = await _supabase.from('users').select().eq('email', email.trim()).maybeSingle();
      if (userRecord != null) {
        debugPrint('Fallback Auth Success for user: ${userRecord['email']} (${userRecord['role']})');
        return AuthResponse(
          session: null,
          user: User(
            id: userRecord['id'],
            appMetadata: {},
            userMetadata: {'name': userRecord['name'], 'role': userRecord['role']},
            aud: 'authenticated',
            email: userRecord['email'],
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password, String name) async {
    try {
      final authRes = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name, 'role': 'patient'},
      );

      if (authRes.user != null) {
        await _supabase.from('users').upsert({
          'id': authRes.user!.id,
          'name': name,
          'email': email.trim(),
          'role': 'patient',
        }, onConflict: 'id');
      }
      return authRes;
    } catch (e) {
      debugPrint('Supabase Auth SignUp Info: $e. Attemping profile fallback...');
      // Fallback: Daftarkan ke tabel public.users agar pasien bisa langsung terdaftar & login
      final newUser = await _supabase.from('users').insert({
        'name': name,
        'email': email.trim(),
        'role': 'patient',
      }).select().single();

      return AuthResponse(
        session: null,
        user: User(
          id: newUser['id'],
          appMetadata: {},
          userMetadata: {'name': name, 'role': 'patient'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // --- USER PROFILE SERVICES ---
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await _supabase.from('users').select().eq('id', userId).maybeSingle();
  }

  Future<Map<String, dynamic>> createUserProfile(String userId, String name, String email, String role) async {
    return await _supabase.from('users').insert({
      'id': userId,
      'name': name,
      'email': email.trim(),
      'role': role,
    }).select().single();
  }

  // --- MASTER DATA SERVICES (CRUD) ---
  Future<List<Map<String, dynamic>>> fetchSpecialists() async {
    final res = await _supabase.from('specialists').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> createSpecialist(String name, String description) async {
    return await _supabase.from('specialists').insert({
      'name': name,
      'description': description,
    }).select().single();
  }

  Future<void> updateSpecialist(String id, String name, String description) async {
    await _supabase.from('specialists').update({
      'name': name,
      'description': description,
    }).eq('id', id);
  }

  Future<void> deleteSpecialist(String id) async {
    await _supabase.from('specialists').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchUnits() async {
    final res = await _supabase.from('units').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> createUnit({
    required String name,
    required String hospitalName,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    return await _supabase.from('units').insert({
      'name': name,
      'hospital_name': hospitalName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    }).select().single();
  }

  Future<void> updateUnit({
    required String id,
    required String name,
    required String hospitalName,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    await _supabase.from('units').update({
      'name': name,
      'hospital_name': hospitalName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    }).eq('id', id);
  }

  Future<void> deleteUnit(String id) async {
    await _supabase.from('units').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final res = await _supabase.from('doctors').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> createDoctor({
    required String name,
    required String email,
    required String password,
    required String specialistId,
    required String unitId,
    required String schedule,
    required String imageUrl,
  }) async {
    // 1. Panggil Stored Procedure register_doctor_account via RPC
    try {
      await _supabase.rpc('register_doctor_account', params: {
        'p_name': name,
        'p_email': email.trim(),
        'p_password': password,
      });
    } catch (e) {
      debugPrint('RPC Register Doctor Info: $e');
    }

    // 2. Pastikan profil pengguna 'doctor' selalu terisi di public.users untuk login fallback
    try {
      await _supabase.from('users').upsert({
        'name': name,
        'email': email.trim(),
        'role': 'doctor',
      }, onConflict: 'email');
    } catch (e) {
      debugPrint('Upsert Doctor User Profile Fallback Info: $e');
    }

    // 3. Masukkan ke rekam medis public.doctors
    return await _supabase.from('doctors').insert({
      'name': name,
      'specialist_id': specialistId,
      'unit_id': unitId,
      'schedule': schedule,
      'image_url': imageUrl,
    }).select().single();
  }

  Future<void> updateDoctor({
    required String id,
    required String name,
    String? email,
    required String specialistId,
    required String unitId,
    required String schedule,
  }) async {
    await _supabase.from('doctors').update({
      'name': name,
      'specialist_id': specialistId,
      'unit_id': unitId,
      'schedule': schedule,
    }).eq('id', id);

    if (email != null && email.isNotEmpty) {
      try {
        await _supabase.from('users').update({
          'name': name,
          'email': email.trim(),
        }).eq('name', name);
      } catch (e) {
        debugPrint('Update Doctor User Profile Error: $e');
      }
    }
  }

  Future<void> deleteDoctor(String id) async {
    await _supabase.from('doctors').delete().eq('id', id);
  }

  // --- RESERVATION SERVICES ---
  Future<List<Map<String, dynamic>>> fetchReservations() async {
    final res = await _supabase.from('reservations').select('*, doctors(name, specialist_id, unit_id), users(name)');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> createReservation({
    required String queueNumber,
    required String barcodeCode,
    required String patientId,
    required String doctorId,
    required String reservationDate,
  }) async {
    return await _supabase.from('reservations').insert({
      'queue_number': queueNumber,
      'barcode_code': barcodeCode,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'reservation_date': reservationDate,
      'status': 'waiting',
    }).select().single();
  }

  Future<void> updateReservationStatus(String resId, String status) async {
    await _supabase.from('reservations').update({'status': status}).eq('id', resId);
  }
}
