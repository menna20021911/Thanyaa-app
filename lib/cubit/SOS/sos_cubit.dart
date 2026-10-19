import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sos_state.dart';

class SosCubit extends Cubit<SosState> {
  SosCubit() : super(SosLoading());

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _contactsCollection =>
      firestore.collection('users').doc(user!.uid).collection('sosContacts');

  Future<void> loadContacts() async {
    emit(SosLoading());
    try {
      final snapshot = await _contactsCollection.get();
      final contacts = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '',
          'relationship': doc['relationship'] ?? '',
          'phone': doc['phone'] ?? '',
        };
      }).toList();
      emit(SosLoaded(contacts));
    } catch (e) {
      emit(SosError(e.toString()));
    }
  }

  Future<void> addContact(
    String name,
    String relationship,
    String phone,
  ) async {
    try {
      await _contactsCollection.add({
        'name': name,
        'relationship': relationship,
        'phone': phone,
      });
      await loadContacts();
    } catch (e) {
      emit(SosError(e.toString()));
    }
  }

  Future<void> updateContact(
    int index,
    String name,
    String relationship,
    String phone,
  ) async {
    if (state is SosLoaded) {
      final contacts = (state as SosLoaded).contacts;
      final contactId = contacts[index]['id'];
      try {
        await _contactsCollection.doc(contactId).update({
          'name': name,
          'relationship': relationship,
          'phone': phone,
        });
        await loadContacts();
      } catch (e) {
        emit(SosError(e.toString()));
      }
    }
  }

  Future<void> deleteContact(int index) async {
    if (state is SosLoaded) {
      final contacts = (state as SosLoaded).contacts;
      final contactId = contacts[index]['id'];
      try {
        await _contactsCollection.doc(contactId).delete();
        await loadContacts();
      } catch (e) {
        emit(SosError(e.toString()));
      }
    }
  }
}
