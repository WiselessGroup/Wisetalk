// Video grid: every tile the same size, as large as the stage allows. The
// same rule as the web client's lib/layout.ts.

/// Tries every column count and keeps the one with the largest tiles that
/// still fit [width]×[height], tiles [ratio] wide per unit of height and
/// [gap] pixels apart. The tile width comes back rounded down.
({int columns, double tileWidth}) bestGrid(
  int count,
  double width,
  double height, {
  double gap = 8,
  double ratio = 16 / 9,
}) {
  var best = (columns: 1, tileWidth: 0.0);
  if (count < 1 || width <= 0 || height <= 0) return best;
  for (var columns = 1; columns <= count; columns++) {
    final rows = (count / columns).ceil();
    final byWidth = (width - gap * (columns - 1)) / columns;
    final byHeight = (height - gap * (rows - 1)) / rows * ratio;
    final tile = (byWidth < byHeight ? byWidth : byHeight).floorToDouble();
    if (tile > best.tileWidth) best = (columns: columns, tileWidth: tile);
  }
  return best;
}
