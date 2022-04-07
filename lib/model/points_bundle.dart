class SolutionPointsBundle{
final List<double> xPoints;
final Map<String, List<double>> solutionYPoints;
final Map<String, List<double>> errorYPoints;

  SolutionPointsBundle(this.xPoints, this.solutionYPoints,this.errorYPoints);

}

class TotalErrorsBundle{
  final List<int> xPoints;
  final Map<String, List<double>> errorPoints;

  TotalErrorsBundle(this.xPoints, this.errorPoints);
}