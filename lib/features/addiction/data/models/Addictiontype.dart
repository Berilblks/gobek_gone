enum AddictionType {
  smoking(1),
  alcohol(2);

  final int value;
  const AddictionType(this.value);

  factory AddictionType.fromValue(int value) {
    return AddictionType.values.firstWhere((e) => e.value == value, orElse: () => AddictionType.smoking);
  }
}




