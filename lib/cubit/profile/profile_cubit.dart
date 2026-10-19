import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  ProfileCubit() : super(ProfileInitial());

  User? get user => _auth.currentUser;

  Future<void> loadProfile() async {
    final u = user;
    if (u == null) {
      emit(
        ProfileLoaded(userData: {}, errorMessage: 'User not authenticated.'),
      );
      return;
    }

    final previousData = state is ProfileLoaded
        ? Map<String, dynamic>.from((state as ProfileLoaded).userData)
        : <String, dynamic>{};

    // only emit loading if we have no data yet
    if (state is! ProfileLoaded) {
      emit(ProfileLoading());
    }

    try {
      final doc = await _firestore.collection('users').doc(u.uid).get();
      if (doc.exists) {
        emit(ProfileLoaded(userData: doc.data()!));
      } else {
        emit(ProfileLoaded(userData: previousData));
      }
    } catch (e) {
      emit(ProfileLoaded(userData: previousData, errorMessage: e.toString()));
    }
  }

  Future<void> uploadProfileImage() async {
    final u = user;
    if (u == null) {
      _emitError('User not authenticated.');
      return;
    }

    final previousData = state is ProfileLoaded
        ? Map<String, dynamic>.from((state as ProfileLoaded).userData)
        : <String, dynamic>{};

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      if (!file.existsSync()) {
        _emitError('Selected image file does not exist.');
        return;
      }

      emit(ProfileUploading(userData: previousData));

      final ref = _storage.ref().child('profile_images/${u.uid}.jpg');
      final uploadTask = await ref.putFile(file);
      final snapshot = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(u.uid).set({
        'imageUrl': snapshot,
      }, SetOptions(merge: true));

      final updatedData = Map<String, dynamic>.from(previousData);
      updatedData['imageUrl'] = snapshot;

      emit(ProfileLoaded(userData: updatedData));
    } on FirebaseException catch (e) {
      _emitError('Firebase error (${e.code}): ${e.message}');
    } catch (e) {
      _emitError(e.toString());
    }
  }

  Future<void> updateProfileField(String field, dynamic value) async {
    final u = user;
    if (u == null) {
      _emitError('User not authenticated.');
      return;
    }

    final previousData = state is ProfileLoaded
        ? Map<String, dynamic>.from((state as ProfileLoaded).userData)
        : <String, dynamic>{};

    try {
      await _firestore.collection('users').doc(u.uid).set({
        field: value,
      }, SetOptions(merge: true));

      final updatedData = Map<String, dynamic>.from(previousData);
      updatedData[field] = value;

      emit(ProfileLoaded(userData: updatedData));
    } catch (e) {
      _emitError(e.toString());
    }
  }

  void _emitError(String message) {
    final currentData = state is ProfileLoaded
        ? Map<String, dynamic>.from((state as ProfileLoaded).userData)
        : <String, dynamic>{};

    emit(ProfileLoaded(userData: currentData, errorMessage: message));
  }
}
