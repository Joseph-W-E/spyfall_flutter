import 'package:spyfall/utils/data_structures.dart';
import 'package:test/test.dart';

void main() {
  group('RefreshableSet', () {
    RefreshableSet set;

    group('refreshing enabled', () {
      setUp(() {
        set = new RefreshableSet(true, refreshAfter: 3);
      });

      test('set refresh after', () {
        int count = 10;
        set.refreshAfter = count;
        expect(set.refreshAfter, equals(count));
      });

      test('adding', () {
        expect(set.add("one"), isTrue);
        expect(set.add("one"), isFalse);
        expect(set.add("two"), isTrue);
        expect(set.all, unorderedEquals(["one", "two"]));
      });

      test('taking', () {
        var items = ["one", "two", "three"];
        items.forEach(set.add);

        for (int i = 0; i < items.length * 2; i++) {
          expect(items.contains(set.take), isTrue);
        }
      });
    });

    group('refreshing disabled', () {
      setUp(() {
        set = new RefreshableSet(false);
      });

      test('adding', () {
        expect(set.add("one"), isTrue);
        expect(set.add("one"), isFalse);
        expect(set.add("two"), isTrue);
        expect(set.all, unorderedEquals(["one", "two"]));
      });

      test('taking', () {
        var items = ["one", "two", "three"];
        items.forEach(set.add);

        for (int i = 0; i < items.length; i++) {
          expect(items.contains(set.take), isTrue);
        }

        expect(set.take, isNull);
      });
    });
  });
}