import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/ui/grid.dart';

// The same cases as the web client's layout.spec.ts.
void main() {
  test('puts three tiles in one row on a wide, low stage', () {
    // 2000×600: one row gives 661 px tiles, a 2×2 grid only 526.
    expect(bestGrid(3, 2000, 600), (columns: 3, tileWidth: 661.0));
  });

  test('prefers a 2×2 grid for three tiles when that is larger', () {
    // 1700×1000: two columns give 846 px tiles, one row only 561.
    expect(bestGrid(3, 1700, 1000), (columns: 2, tileWidth: 846.0));
  });

  test('stacks tiles on a tall phone screen', () {
    expect(bestGrid(2, 375, 700).columns, 1);
  });

  test('fills the stage with a single tile', () {
    // Height-limited: 900 px tall at 16:9 is 1600 px wide.
    expect(bestGrid(1, 2000, 900), (columns: 1, tileWidth: 1600.0));
  });

  test('handles nothing to show', () {
    expect(bestGrid(0, 800, 600).tileWidth, 0);
  });
}
