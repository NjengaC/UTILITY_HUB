class BmiResult {
  final double bmi;
  final String category;
  final String description;

  const BmiResult({
    required this.bmi,
    required this.category,
    required this.description,
  });
}

class BmiCalculatorService {
  static BmiResult calculate({
    required double heightCm,
    required double weightKg,
  }) {
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    String category;
    String description;

    if (bmi < 16) {
      category = 'Severely Underweight';
      description = 'Your BMI indicates you are severely underweight. Please consult a healthcare provider.';
    } else if (bmi < 18.5) {
      category = 'Underweight';
      description = 'Your BMI indicates you are underweight. Consider a balanced diet to reach a healthy weight.';
    } else if (bmi < 25) {
      category = 'Normal';
      description = 'Great! Your BMI is within the healthy range. Keep up your balanced lifestyle.';
    } else if (bmi < 30) {
      category = 'Overweight';
      description = 'Your BMI indicates you are slightly overweight. Regular exercise and a balanced diet can help.';
    } else if (bmi < 35) {
      category = 'Obese (Class I)';
      description = 'Your BMI indicates obesity. Consider consulting a healthcare provider for guidance.';
    } else {
      category = 'Obese (Class II+)';
      description = 'Your BMI indicates significant obesity. Professional medical advice is recommended.';
    }

    return BmiResult(bmi: bmi, category: category, description: description);
  }
}
