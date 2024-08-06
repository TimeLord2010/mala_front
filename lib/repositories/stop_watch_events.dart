/// Used the calculate the elapsed time on multiple call of the given functions.
class StopWatchEvents {
  List<Duration> durations = [];

  Future<T> add<T>(Future<T> Function() func) async {
    var begin = DateTime.now();
    var result = await func();
    var end = DateTime.now();
    durations.add(end.difference(begin));
    return result;
  }

  List<int> get inMilli {
    return durations.map((x) => x.inMilliseconds).toList();
  }
}
