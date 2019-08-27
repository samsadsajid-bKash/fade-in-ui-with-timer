class Ticker {
  Stream<int> tick({int ticks}) {
    print("Log... ticks are $ticks");
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}