double average(List<int> numbers) {
  if (numbers.isEmpty) {
    return 0;
  }
  BigInt sum = numbers.fold(BigInt.zero, (BigInt a, int b) => a + BigInt.from(b));
  BigInt count = BigInt.from(numbers.length);
  double average = sum / count;
  return average;
}
