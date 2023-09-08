import 'package:flutter_test/flutter_test.dart';
import 'package:mala_front/usecase/array/chunck_array.dart';

void main() {
  test('chunck array ...', () {
    var original = [1, 2, 3, 4, 5, 6, 7];
    var chuncks = chunckArray(original, 3);
    expect(chuncks.length, 3);
    expect(chuncks[0], [1, 2, 3]);
    expect(chuncks[1], [4, 5, 6]);
    expect(chuncks[2], [7]);
  });
}
