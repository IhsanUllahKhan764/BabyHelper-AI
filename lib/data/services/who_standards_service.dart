import 'dart:math';
import 'package:baby_helper_ai/data/models/baby_model.dart';
import 'package:baby_helper_ai/data/models/growth_measurement_model.dart';

/// WHO Child Growth Standards z-score calculations
/// Simplified LMS method for weight-for-age, length-for-age, head-for-age
class WhoStandardsService {
  /// Calculate z-scores for a measurement given baby's age and gender
  GrowthMeasurementModel calculateZScores(
    GrowthMeasurementModel measurement,
    BabyModel baby,
  ) {
    final ageMonths = _ageInMonthsAtDate(baby.dateOfBirth, measurement.date);
    final isMale = baby.gender == BabyGender.male;

    return measurement.copyWith(
      weightZScore: _calcWeightForAgeZScore(measurement.weight, ageMonths, isMale),
      heightZScore: _calcLengthForAgeZScore(measurement.height, ageMonths, isMale),
      headZScore: _calcHeadForAgeZScore(measurement.headCircumference, ageMonths, isMale),
    );
  }

  int _ageInMonthsAtDate(DateTime dob, DateTime date) {
    final differenceInDays = date.difference(dob).inDays;
    return (differenceInDays / 30.4375).round();
  }

  // WHO Weight-for-age (simplified LMS parameters)
  double _calcWeightForAgeZScore(double weight, int ageMonths, bool isMale) {
    final params = isMale ? _maleWeightForAge : _femaleWeightForAge;
    if (ageMonths < 0 || ageMonths >= params.length) return 0;
    final lms = params[ageMonths];
    return _lmsToZScore(weight, lms[0], lms[1], lms[2]);
  }

  // WHO Length-for-age (simplified LMS parameters)
  double _calcLengthForAgeZScore(double length, int ageMonths, bool isMale) {
    final params = isMale ? _maleLengthForAge : _femaleLengthForAge;
    if (ageMonths < 0 || ageMonths >= params.length) return 0;
    final lms = params[ageMonths];
    return _lmsToZScore(length, lms[0], lms[1], lms[2]);
  }

  // WHO Head circumference-for-age
  double _calcHeadForAgeZScore(double headCirc, int ageMonths, bool isMale) {
    final params = isMale ? _maleHeadForAge : _femaleHeadForAge;
    if (ageMonths < 0 || ageMonths >= params.length) return 0;
    final lms = params[ageMonths];
    return _lmsToZScore(headCirc, lms[0], lms[1], lms[2]);
  }

  /// LMS method: z = ((value/M)^L - 1) / (L * S)
  double _lmsToZScore(double value, double l, double m, double s) {
    if (m == 0 || s == 0) return 0;
    if (l == 0) {
      return log(value / m) / s;
    }
    return (pow(value / m, l) - 1) / (l * s);
  }

  /// Get status text based on z-score
  static String getWeightStatus(double? zScore) {
    if (zScore == null) return 'Unknown';
    if (zScore < -3) return 'Severely Underweight';
    if (zScore < -2) return 'Underweight';
    if (zScore <= 2) return 'Normal';
    if (zScore <= 3) return 'Overweight';
    return 'Obese';
  }

  static String getHeightStatus(double? zScore) {
    if (zScore == null) return 'Unknown';
    if (zScore < -3) return 'Severely Stunted';
    if (zScore < -2) return 'Stunted';
    if (zScore <= 2) return 'Normal';
    return 'Tall';
  }

  static String getHeadStatus(double? zScore) {
    if (zScore == null) return 'Unknown';
    if (zScore < -2) return 'Below Normal';
    if (zScore <= 2) return 'Normal';
    return 'Above Normal';
  }

  static bool hasWarning(double? zScore) {
    if (zScore == null) return false;
    return zScore < -2 || zScore > 2;
  }

  // WHO LMS Tables (L, M, S) for months 0-24
  // Boys Weight-for-age
  static const _maleWeightForAge = [
    [0.3487, 3.3464, 0.14602], // 0 months
    [0.2297, 4.4709, 0.13395],
    [0.1970, 5.5675, 0.12385],
    [0.1738, 6.3762, 0.11727],
    [0.1553, 7.0023, 0.11316],
    [0.1395, 7.5105, 0.11080],
    [0.1257, 7.9340, 0.10958],
    [0.1134, 8.2970, 0.10902],
    [0.1021, 8.6151, 0.10882],
    [0.0917, 8.9014, 0.10881],
    [0.0822, 9.1649, 0.10891],
    [0.0731, 9.4122, 0.10906],
    [0.0644, 9.6479, 0.10925], // 12 months
    [0.0561, 9.8749, 0.10949],
    [0.0482, 10.0953, 0.10976],
    [0.0406, 10.3108, 0.11007],
    [0.0334, 10.5228, 0.11041],
    [0.0261, 10.7319, 0.11079],
    [0.0192, 10.9385, 0.11119],
    [0.0124, 11.1430, 0.11164],
    [0.0059, 11.3462, 0.11211],
    [-0.0003, 11.5486, 0.11261],
    [-0.0065, 11.7504, 0.11314],
    [-0.0125, 11.9514, 0.11369],
    [-0.0183, 12.1515, 0.11426], // 24 months
  ];

  // Girls Weight-for-age
  static const _femaleWeightForAge = [
    [0.3809, 3.2322, 0.14171],
    [0.1714, 4.1873, 0.13724],
    [0.0962, 5.1282, 0.12921],
    [0.0402, 5.8458, 0.12374],
    [-0.0050, 6.4237, 0.11987],
    [-0.0430, 6.8985, 0.11725],
    [-0.0756, 7.2970, 0.11557],
    [-0.1039, 7.6422, 0.11454],
    [-0.1287, 7.9487, 0.11398],
    [-0.1507, 8.2254, 0.11374],
    [-0.1700, 8.4800, 0.11371],
    [-0.1872, 8.7192, 0.11382],
    [-0.2024, 8.9481, 0.11401],
    [-0.2158, 9.1699, 0.11426],
    [-0.2278, 9.3870, 0.11454],
    [-0.2384, 9.6008, 0.11485],
    [-0.2478, 9.8124, 0.11519],
    [-0.2562, 10.0226, 0.11555],
    [-0.2637, 10.2315, 0.11594],
    [-0.2703, 10.4393, 0.11635],
    [-0.2762, 10.6464, 0.11679],
    [-0.2815, 10.8534, 0.11726],
    [-0.2862, 11.0608, 0.11775],
    [-0.2903, 11.2688, 0.11827],
    [-0.2941, 11.4775, 0.11882],
  ];

  // Boys Length-for-age
  static const _maleLengthForAge = [
    [1.0, 49.8842, 0.03795],
    [1.0, 54.7244, 0.03557],
    [1.0, 58.4249, 0.03424],
    [1.0, 61.4292, 0.03328],
    [1.0, 63.8860, 0.03257],
    [1.0, 65.9026, 0.03204],
    [1.0, 67.6236, 0.03165],
    [1.0, 69.1645, 0.03139],
    [1.0, 70.5994, 0.03124],
    [1.0, 71.9687, 0.03117],
    [1.0, 73.2812, 0.03118],
    [1.0, 74.5388, 0.03125],
    [1.0, 75.7488, 0.03137],
    [1.0, 76.9186, 0.03154],
    [1.0, 78.0497, 0.03174],
    [1.0, 79.1458, 0.03197],
    [1.0, 80.2113, 0.03222],
    [1.0, 81.2487, 0.03248],
    [1.0, 82.2587, 0.03277],
    [1.0, 83.2418, 0.03307],
    [1.0, 84.1996, 0.03337],
    [1.0, 85.1348, 0.03369],
    [1.0, 86.0477, 0.03401],
    [1.0, 86.9410, 0.03435],
    [1.0, 87.8161, 0.03468],
  ];

  // Girls Length-for-age
  static const _femaleLengthForAge = [
    [1.0, 49.1477, 0.03790],
    [1.0, 53.6872, 0.03614],
    [1.0, 57.0673, 0.03568],
    [1.0, 59.8029, 0.03518],
    [1.0, 62.0899, 0.03486],
    [1.0, 64.0301, 0.03463],
    [1.0, 65.7311, 0.03448],
    [1.0, 67.2873, 0.03441],
    [1.0, 68.7498, 0.03440],
    [1.0, 70.1435, 0.03444],
    [1.0, 71.4818, 0.03452],
    [1.0, 72.7710, 0.03464],
    [1.0, 74.0153, 0.03479],
    [1.0, 75.2176, 0.03496],
    [1.0, 76.3817, 0.03514],
    [1.0, 77.5110, 0.03534],
    [1.0, 78.6070, 0.03555],
    [1.0, 79.6715, 0.03577],
    [1.0, 80.7055, 0.03600],
    [1.0, 81.7108, 0.03623],
    [1.0, 82.6881, 0.03647],
    [1.0, 83.6394, 0.03672],
    [1.0, 84.5672, 0.03697],
    [1.0, 85.4742, 0.03723],
    [1.0, 86.3617, 0.03749],
  ];

  // Boys Head circumference-for-age
  static const _maleHeadForAge = [
    [1.0, 34.46, 0.03686],
    [1.0, 37.19, 0.03133],
    [1.0, 39.13, 0.02997],
    [1.0, 40.51, 0.02918],
    [1.0, 41.58, 0.02868],
    [1.0, 42.37, 0.02837],
    [1.0, 43.10, 0.02817],
    [1.0, 43.69, 0.02803],
    [1.0, 44.20, 0.02792],
    [1.0, 44.64, 0.02783],
    [1.0, 45.01, 0.02776],
    [1.0, 45.33, 0.02770],
    [1.0, 45.60, 0.02766],
    [1.0, 45.83, 0.02762],
    [1.0, 46.03, 0.02760],
    [1.0, 46.20, 0.02758],
    [1.0, 46.35, 0.02757],
    [1.0, 46.49, 0.02757],
    [1.0, 46.61, 0.02757],
    [1.0, 46.72, 0.02758],
    [1.0, 46.83, 0.02760],
    [1.0, 46.93, 0.02762],
    [1.0, 47.02, 0.02764],
    [1.0, 47.11, 0.02767],
    [1.0, 47.19, 0.02770],
  ];

  // Girls Head circumference-for-age
  static const _femaleHeadForAge = [
    [1.0, 33.90, 0.03568],
    [1.0, 36.55, 0.03210],
    [1.0, 38.27, 0.03072],
    [1.0, 39.53, 0.02997],
    [1.0, 40.58, 0.02948],
    [1.0, 41.45, 0.02913],
    [1.0, 42.15, 0.02887],
    [1.0, 42.74, 0.02867],
    [1.0, 43.22, 0.02849],
    [1.0, 43.62, 0.02835],
    [1.0, 43.96, 0.02824],
    [1.0, 44.25, 0.02815],
    [1.0, 44.49, 0.02807],
    [1.0, 44.70, 0.02801],
    [1.0, 44.89, 0.02796],
    [1.0, 45.05, 0.02792],
    [1.0, 45.19, 0.02790],
    [1.0, 45.32, 0.02788],
    [1.0, 45.43, 0.02786],
    [1.0, 45.53, 0.02786],
    [1.0, 45.63, 0.02786],
    [1.0, 45.71, 0.02786],
    [1.0, 45.79, 0.02787],
    [1.0, 45.87, 0.02789],
    [1.0, 45.94, 0.02791],
  ];
}
