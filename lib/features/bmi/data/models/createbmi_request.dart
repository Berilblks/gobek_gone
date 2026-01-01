class CreateBmiRequest {
  final double height;
  final double weight;
  final int age;
  final String gender;

  CreateBmiRequest({required this.height, required this.weight, required this.age, required this.gender});

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
    };
  }
}