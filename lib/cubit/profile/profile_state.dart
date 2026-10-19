part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUploading extends ProfileState {
  final Map<String, dynamic> userData;
  ProfileUploading({required this.userData});
}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  final String? errorMessage;

  ProfileLoaded({required this.userData, this.errorMessage});
}
