import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  //define the initial state of the timer bloc

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);
  }

//start the timer off with 60s
//and defining the dependency on the ticker object after creqting instant of ticker

  final Ticker _ticker;
  static const int _duration = 60;

//creates an instance to check if a ticker subsription was created or not

  StreamSubscription<int>? _tickerSubscription;

//if the bloc is ever closed, we cancel the subsription so there isnt mult streams
//overridden
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  //if the timerstarted event is received
  //  the timer in progress state will run
  //  if there was a previous subcription to ticker, it will be canelled
  //  it then uses an instance of the ticker to tick and listen to the duration

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

//the timerpaused event is triggered
//  if the state is currently run in progress, then pause the ticker
//  then emit the state that it is paused w the duration
  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

//if the timer resumed event is triggered
//  if the state is currently paused, then resume the ticker
//   emit state as timerrunin progress

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

//when timer reset event is triggered
//cancel the subscription and emit that state as timer initial aka started
  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(_duration));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 0
          ? TimerRunInProgress(event.duration)
          : const TimerRunComplete(),
    );
  }
}
