part of 'push_up_bloc.dart';

sealed class PushUpState extends Equatable {
  const PushUpState();
  
  @override
  List<Object> get props => [];
}

final class PushUpInitial extends PushUpState {}
