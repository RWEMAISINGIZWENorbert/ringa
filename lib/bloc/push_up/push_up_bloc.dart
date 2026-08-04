import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'push_up_event.dart';
part 'push_up_state.dart';

class PushUpBloc extends Bloc<PushUpEvent, PushUpState> {
  PushUpBloc() : super(PushUpInitial()) {
    on<PushUpEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
