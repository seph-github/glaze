import 'dart:math' as math;

int createRandomNumber() {
  final random = math.Random();
  return random.nextInt(90000000) + 10000000;
}
