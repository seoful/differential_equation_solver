import 'dart:math';

import 'package:differential_equations/algorythms/solving_algorythm.dart';
import 'package:differential_equations/model/equation.dart';
import 'package:differential_equations/model/input_data.dart';
import 'package:differential_equations/model/points_bundle.dart';

class Solver {
  final Equation equation;
  final SolvingAlgorithm _analyticAlgorithm = AnalyticalMethod();
  final List<SolvingAlgorithm> _algorithms = [
    EulerMethod(),
    ImprovedEulerMethod(),
    RungeKuttaMethod()
  ];

  Solver(this.equation);

  Future<SolutionPointsBundle> calculateGraphs(InputData inputData) async {
    List<double> xPoints = List.generate(inputData.N + 1,
        (index) => inputData.x0 + index * inputData.gridCellSize);

    List<double> exactSolution =
        _analyticAlgorithm.calculate(equation, xPoints, inputData);

    Map<String, List<double>> solutionYPoints = {
      for (var algorithm in _algorithms)
        algorithm.getName(): algorithm.calculate(equation, xPoints, inputData)
    };

    Map<String, List<double>> errorYPoints = {
      for (var algorithm in _algorithms)
        algorithm.getName(): _calculateErrors(
            exactSolution, solutionYPoints[algorithm.getName()] ?? [])
    };
    solutionYPoints[_analyticAlgorithm.getName()] = exactSolution;

    return SolutionPointsBundle(xPoints, solutionYPoints, errorYPoints);
  }

  List<double> _calculateErrors(
      List<double> exactSolution, List<double> approximateSolution) {
    return List<double>.generate(exactSolution.length,
        (index) => (exactSolution[index] - approximateSolution[index]).abs());
  }

  Future<TotalErrorsBundle> calculateTotalErrors(
      int n0, int N, InputData inputData) async {
    var map = <String, List<double>>{
      for (var algo in _algorithms) algo.getName(): []
    };
    var xPoints = List.generate(N - n0 + 1, (index) => n0 + index);
    for (var i in xPoints) {
      var pointsBundle = await calculateGraphs(inputData.copyWith(N: i));
      for (var errorPoints in pointsBundle.errorYPoints.entries) {
        var maxError = 0.0;
        errorPoints.value.asMap().forEach((index, value) {
          maxError = max(value, maxError);
        });
        map[errorPoints.key]!.add(maxError);
      }
    }
    return TotalErrorsBundle(xPoints, map);
  }
}
