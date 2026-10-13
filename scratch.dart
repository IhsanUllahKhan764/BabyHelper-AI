import 'dart:math';

void main() {
  final lms = [0.1257, 7.9340, 0.10958]; // 6 months, male
  final weight = 7.5;
  final l = lms[0];
  final m = lms[1];
  final s = lms[2];
  
  double zScore;
  if (m == 0 || s == 0) zScore = 0;
  else if (l == 0) zScore = log(weight / m) / s;
  else zScore = (pow(weight / m, l) - 1) / (l * s);
  
  print('Weight: $weight, M: $m, Z-score: $zScore');
}
