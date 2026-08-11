import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentAuthUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;

  // --- AUTH SERVICES ---
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password, String name) async {
    return await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name},
    );
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

  Future<void> deleteUnit(String id) async {
    await _supabase.from('units').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final res = await _supabase.from('doctors').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> createDoctor({
    required String name,
    required String specialistId,
    required String unitId,
    required String schedule,
    required String imageUrl,
  }) async {
    return await _supabase.from('doctors').insert({
      'name': name,
      'specialist_id': specialistId,
      'unit_id': unitId,
      'schedule': schedule,
      'image_url': imageUrl,
    }).select().single();
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
