import 'package:differential_equations/model/Strings.dart';
import 'package:differential_equations/model/equation.dart';
import 'package:differential_equations/model/input_data.dart';

abstract class SolvingAlgorithm {
  List<double> calculate(
      Equation equation, List<double> xPoints, InputData inputData);

  String getName();
}

class EulerMethod extends SolvingAlgorithm {
  @override
  List<double> calculate(
      Equation equation, List<double> xPoints, InputData inputData) {
    List<double> yPoints = [];
    xPoints.asMap().forEach((index, x) {
      if (index == 0) {
        yPoints.add(inputData.y0);
      } else {
        yPoints.add(yPoints[index - 1] +
            inputData.gridCellSize *
                equation.derivative(xPoints[index - 1], yPoints[index - 1]));
      }
    });
    return yPoints;
  }

  @override
  String getName() => Strings.EULER_METHOD;
}

class ImprovedEulerMethod extends SolvingAlgorithm {
  @override
  List<double> calculate(
      Equation equation, List<double> xPoints, InputData inputData) {
    List<double> yPoints = [];

    xPoints.asMap().forEach((index, x) {
      if (index == 0) {
        yPoints.add(inputData.y0);
      } else {
        var k1 = equation.derivative(xPoints[index - 1], yPoints[index - 1]);
        var k2 = equation.derivative(
            xPoints[index], yPoints[index - 1] + inputData.gridCellSize * k1);
        yPoints
            .add(yPoints[index - 1] + inputData.gridCellSize * (k1 + k2) / 2);
      }
    });

    return yPoints;
  }

  @override
  String getName() => Strings.IMPROVED_EULER_METHOD;
}

class RungeKuttaMethod extends SolvingAlgorithm {
  @override
  List<double> calculate(
      Equation equation, List<double> xPoints, InputData inputData) {
    List<double> yPoints = [];

    xPoints.asMap().forEach((index, x) {
      if (index == 0) {
        yPoints.add(inputData.y0);
      } else {
        var k1 = equation.derivative(xPoints[index - 1], yPoints[index - 1]);
        var k2 = equation.derivative(
            xPoints[index - 1] + inputData.gridCellSize / 2,
            yPoints[index - 1] + inputData.gridCellSize * k1 / 2);
        var k3 = equation.derivative(
            xPoints[index - 1] + inputData.gridCellSize / 2,
            yPoints[index - 1] + inputData.gridCellSize * k2 / 2);
        var k4 = equation.derivative(
            xPoints[index], yPoints[index - 1] + inputData.gridCellSize * k3);
        yPoints.add(yPoints[index - 1] +
            inputData.gridCellSize * (k1 + 2 * k2 + 2 * k3 + k4) / 6);
      }
    });

    return yPoints;
  }

  @override
  String getName() => Strings.RUNGE_KUTTA_METHOD;
}

class AnalyticalMethod extends SolvingAlgorithm {
  @override
  List<double> calculate(
      Equation equation, List<double> xPoints, InputData inputData) {
    return List.generate(
        xPoints.length,
        (index) => equation.analyticalSolution(
            inputData.x0, inputData.y0, xPoints[index]));
  }

  @override
  String getName() => Strings.ANALYTICAL_METHOD;
}
