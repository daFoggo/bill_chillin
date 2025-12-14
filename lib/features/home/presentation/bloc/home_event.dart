import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  final String userId;
  const LoadHomeDataEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
