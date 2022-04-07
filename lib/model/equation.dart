class Equation {
  final double Function(double x,double y) derivative;

  final double Function(double x0, double y0, double x) analyticalSolution;

  Equation( this.derivative, this.analyticalSolution);
}
