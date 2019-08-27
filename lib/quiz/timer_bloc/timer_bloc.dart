import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'bloc.dart';
import '../ticker/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 6;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => LoadQuizAnswers(_duration);

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<TimerState> mapEventToState(
      TimerEvent event,
      ) async* {
    if (event is ReadyTimer){
      yield* _mapReadyTimerToState(event);
    }else if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }

  Stream<TimerState> _mapReadyTimerToState(ReadyTimer readyTimer) async* {
    yield Ready(6);
  }

    Stream<TimerState> _mapStartToState(Start start) async* {
    yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: start.duration).listen(
          (duration) {
        dispatch(Tick(duration: duration));
      },
    );
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }
}