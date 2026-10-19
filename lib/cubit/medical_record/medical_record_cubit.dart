import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'medical_record_state.dart';

class MedicalRecordCubit extends Cubit<MedicalRecordState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  MedicalRecordCubit() : super(MedicalRecordInitial());

  Future<void> loadMedicalRecord() async {
    emit(MedicalRecordLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const MedicalRecordError("User is not logged in"));
        return;
      }

      final uid = user.uid;
      final doc = await _firestore.collection('medical_records').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        emit(MedicalRecordLoaded(doc.data()!));
      } else {
        emit(const MedicalRecordLoaded({}));
      }
    } catch (e) {
      emit(MedicalRecordError("Failed to load data: $e"));
    }
  }

  Future<void> updateField(String field, dynamic value) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const MedicalRecordError("User is not logged in"));
        return;
      }

      final uid = user.uid;

      // Merge new value with existing document
      await _firestore.collection('medical_records').doc(uid).set({
        field: value,
      }, SetOptions(merge: true));

      await loadMedicalRecord();
    } catch (e) {
      emit(MedicalRecordError("Failed to update field: $e"));
    }
  }

  Future<void> uploadFile(File file, String field) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const MedicalRecordError("User is not logged in"));
        return;
      }

      final uid = user.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = file.path.split('/').last;
      final storageRef = _storage.ref().child(
        'medical_records/$uid/$field/${timestamp}_$fileName',
      );

      final uploadTask = await storageRef.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      // Get existing list from Firestore
      final doc = await _firestore.collection('medical_records').doc(uid).get();
      final data = doc.data() ?? {};
      final List<String> existing = List<String>.from(data[field] ?? []);
      existing.add(url);
      await _firestore.collection('medical_records').doc(uid).set({
        field: existing,
      }, SetOptions(merge: true));

      await loadMedicalRecord();
    } catch (e) {
      emit(MedicalRecordError("Failed to upload file: $e"));
    }
  }
}
