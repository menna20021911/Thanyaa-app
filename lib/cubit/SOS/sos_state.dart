part of 'sos_cubit.dart';

abstract class SosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SosLoading extends SosState {}

class SosLoaded extends SosState {
  final List<Map<String, dynamic>> contacts;
  SosLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class SosError extends SosState {
  final String message;
  SosError(this.message);

  @override
  List<Object?> get props => [message];
}
