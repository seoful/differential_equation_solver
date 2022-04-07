class InputData {
  final double x0, y0, X;
  final int N;
  final double gridCellSize;


  InputData(this.x0, this.y0, this.N, this.X)
      : gridCellSize = (x0 - X).abs() / N;

  InputData copyWith({x0, y0, N, X}) {
    return InputData(x0 ?? this.x0, y0 ?? this.y0, N ?? this.N, X ?? this.X);
  }
}
