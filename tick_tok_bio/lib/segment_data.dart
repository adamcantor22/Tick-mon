class SegmentData {
  Map<String, int> ticks;
  String name;

  SegmentData() {
    ticks = new Map<String, int>();
  }

  void addTickData({
    String type,
    int n,
    String title,
    Map<String, int> map,
  }) {
    if (title != null) {
      name = title;
    }

    if (map != null) {
      ticks.addAll(map);
    } else {
      ticks[type] = n;
    }
  }

  String getName() {
    return name;
  }

  Map<String, int> getData() {
    return ticks;
  }

  bool isEmpty() {
    return ticks.isEmpty;
  }
}
