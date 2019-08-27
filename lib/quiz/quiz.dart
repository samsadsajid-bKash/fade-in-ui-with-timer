import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';
import 'package:simple_animations/simple_animations/multi_track_tween.dart';
import 'timer_bloc/bloc.dart';
import 'ticker/ticker.dart';

class Quiz extends StatefulWidget{
  _StatefulWidgetState createState() => _StatefulWidgetState();
}

class _StatefulWidgetState extends State<Quiz> {
  TimerBloc _timerBloc;
  String _innerCircleText;
  Color cardColor = Colors.white;
  bool showTimerAnimation = false;

  void initState(){
    super.initState();
    _timerBloc = TimerBloc(ticker: Ticker());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ami hotash"),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0.0, 3.0),
              blurRadius: 5.0,
              color: Colors.grey,
            ),
          ],
        ),
        child: _generateBody(),
      ),
    );
  }

  Widget _generateBody(){
    return BlocListenerTree(
      blocListeners: [
        BlocListener<TimerEvent, TimerState>(
          bloc: _timerBloc,
          listener: (context, state) {
            if (state is LoadQuizAnswers) {
              _innerCircleText = state.duration.toString();
              Future.delayed(const Duration(milliseconds: 1000), (){
                _timerBloc.dispatch(ReadyTimer(duration: 0));
              });
            }
            else if (state is Ready) {
              showTimerAnimation = true;
              _innerCircleText = state.duration.toString();
              _timerBloc.dispatch(Start(duration: state.duration));
            }
            else if (state is Running) {
              print(state.duration);
              setState(() {
                _innerCircleText = state.duration.toString();
              });
            }
            else if(state is Finished) {
              print("finished timer");
            }
          },
        ),
//        BlocListener<QuizEvent, QuizState>(
//          bloc: _quizBloc,
//          listener: (context, state) {
//            if(state is WrongAnswerState){
//              print("debug");
//              _navigateToNextPage(1);
//            }
//          },
//        )
      ],

      child: BlocBuilder(
        bloc: _timerBloc,
        condition: (previousState, currentState) {
          return currentState is LoadQuizAnswers || currentState is Ready || currentState is Running;
        },
        builder: (context, state) {
          return _getWidgets();
//          return BlocBuilder(
//            bloc: _quizBloc,
//            builder: (context, state){
//              return _getWidgets();
//            },
//          );
        },
      ),
    );
  }

  Widget _getWidgets(){
    return Column(
        children: <Widget>[
          _getCircularLoader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  _getQuestionNumber(),
                  SizedBox(
                    height: 10,
                  ),
                  _getQuestion(),
                  SizedBox(
                    height: 20,
                  ),
                  _getOptions(),
                ],
              ),
            ),
          ),
        ],
    );
  }

  Widget _getCircularLoader(){
    print("no..?");
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0.0, 1.0),
            blurRadius: 2.0,
            color: Colors.grey,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: CircularPercentIndicator(
              radius: 70.0,
              lineWidth: 5.0,
              percent: 1.0,
              animation: showTimerAnimation ? true : false,
              animationDuration: showTimerAnimation ? 6000 : 2500,
              addAutomaticKeepAlive: false,
              center: Text(
                showTimerAnimation ? _innerCircleText : "6",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold
                ),
              ),
              progressColor: Colors.pink,
              circularStrokeCap: CircularStrokeCap.round
          ),
        ),
      ),
    );
  }

  Widget _getQuestionNumber() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        "১",
        style: TextStyle(
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _getQuestion() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Text(
        "Last time Barcelona faced Manchester United at UCL final in which stadium?",
        style: TextStyle(
          color: Colors.pinkAccent,
        ),
      ),
    );
  }

  Widget _getOptions(){
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
//            FadeIn(1.0, HeaderPlaceholder()),
//            WhitespaceSeparator(),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                FadeIn(2, CirclePlaceholder()),
//                FadeIn(2.33, CirclePlaceholder()),
//                FadeIn(2.66, CirclePlaceholder())
//              ],
//            ),
//            WhitespaceSeparator(),
            _getOptionsCard(1, "A", "Camp Nou"),
            _getOptionsCard(1.2, "B", "Istambul"),
            _getOptionsCard(1.4, "C", "Wembley"),
            _getOptionsCard(1.6, "D", "Milan"),
          ],
        ),
    );
  }

  Widget _getOptionsCard(double delay, String index, String msg) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(
          Duration(milliseconds: 500), Tween(begin: 130.0, end: 0.0),
          curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: _buildCard(index, msg),
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }

  Widget _buildCard(String index, String msg){
    return GestureDetector(
      onTap: (){
        setState(() {
          cardColor = Colors.grey;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: Container(
                    color: Colors.grey.shade300,
                    width: 30,
                    height: 30,
                    child: Center(
                      child: Text(
                        index,
                        style: TextStyle(
                            color: Colors.pink
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
//                      color: Colors.grey,
//                      height: 10,
                          child: Text(
                            msg,
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        ),
                      )
//                    Container(
//                      margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
//                      color: Colors.grey.shade300,
//                      height: 7,
//                    ),
//                    Container(
//                      margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
//                      color: Colors.grey.shade300,
//                      height: 7,
//                    ),
//                    Container(
//                      margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
//                      color: Colors.grey.shade300,
//                      height: 7,
//                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dispose(){
    super.dispose();
  }
}

class FadeIn extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeIn(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(
          Duration(milliseconds: 500), Tween(begin: 130.0, end: 0.0),
          curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }
}

class WhitespaceSeparator extends StatelessWidget {
  const WhitespaceSeparator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
    );
  }
}

class HeaderPlaceholder extends StatelessWidget {
  const HeaderPlaceholder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  }
}

class CirclePlaceholder extends StatelessWidget {
  const CirclePlaceholder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 50,
        height: 50,
        color: Colors.grey.shade300,
      ),
    );
  }
}

class CardPlaceholder extends StatelessWidget {
  String index;
  String msg;

  CardPlaceholder(
    this.index,
    this.msg
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){

      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: Container(
                    color: Colors.grey.shade300,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Text(
                        index,
                        style: TextStyle(
                            color: Colors.pink
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
//                      color: Colors.grey,
//                      height: 10,
                          child: Text(
                            msg,
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                        ),
                      )
//                    Container(
//                      margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
//                      color: Colors.grey.shade300,
//                      height: 7,
//                    ),
//                    Container(
//                      margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
//                      color: Colors.grey.shade300,
//                      height: 7,
//                    ),
//                    Container(
//                      margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
//                      color: Colors.grey.shade300,
//                      height: 7,
//                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
