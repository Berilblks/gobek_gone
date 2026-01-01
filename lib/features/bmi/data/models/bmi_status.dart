enum BmiStatus {
  underweight(1),
  normalWeight(2),
  overweight(3),
  obese(4);

  final int value;
  const BmiStatus(this.value);

  factory BmiStatus.fromValue(int value) {
    return BmiStatus.values.firstWhere((e) => e.value == value, orElse: () => BmiStatus.normalWeight);
  }
}