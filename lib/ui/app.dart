import 'dart:math';

import 'package:differential_equations/model/Strings.dart';
import 'package:differential_equations/model/equation.dart';
import 'package:differential_equations/model/input_data.dart';
import 'package:differential_equations/model/points_bundle.dart';
import 'package:differential_equations/solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Solver _solver = Solver(Equation(
      (x, y) => x != 0 ? y / x + x * cos(x) : 0,
      (x0, y0, x) => x != 0 ? x * (y0 / x0 - sin(x0) + sin(x)) : 0));

  final _colors = {
    Strings.ANALYTICAL_METHOD: Colors.red,
    Strings.EULER_METHOD: Colors.blue,
    Strings.IMPROVED_EULER_METHOD: Colors.purple,
    Strings.RUNGE_KUTTA_METHOD: Colors.green
  };

  final TextEditingController _x0Controller =
          TextEditingController(text: pi.toString()),
      _y0Controller = TextEditingController(text: "1"),
      _nController = TextEditingController(text: "15"),
      _XController = TextEditingController(text: (4 * pi).toString()),
      _nMinController = TextEditingController(text: "10"),
      _nMaxController = TextEditingController(text: "100");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SolutionPointsBundle? _pointsBundle;
  TotalErrorsBundle? _totalErrorsBundle;

  bool _isWaiting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text("Solution"),
                Expanded(
                  child: _pointsBundle == null
                      ? Container()
                      : SfCartesianChart(
                          legend: Legend(isVisible: true),
                          primaryXAxis: CategoryAxis(
                            labelPlacement: LabelPlacement.onTicks,
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: _pointsBundle?.solutionYPoints.entries
                              .map(
                                (entry) => LineSeries(
                                  dataSource: entry.value,
                                  xValueMapper: (datum, index) =>
                                      _pointsBundle?.xPoints[index],
                                  yValueMapper: (double datum, index) => datum,
                                  color: _colors[entry.key],
                                  legendItemText: entry.key,
                                  name: entry.key,
                                  xAxisName: "x",
                                  yAxisName: "y",
                                ),
                              )
                              .toList(),
                        ),
                ),
                Text("Local Error"),
                Expanded(
                  child: _pointsBundle == null
                      ? Container()
                      : SfCartesianChart(
                          legend: Legend(isVisible: true),
                          primaryXAxis: CategoryAxis(
                            labelPlacement: LabelPlacement.onTicks,
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: _pointsBundle?.errorYPoints.entries
                              .map(
                                (entry) => LineSeries(
                                  dataSource: entry.value,
                                  xValueMapper: (datum, index) =>
                                      _pointsBundle?.xPoints[index],
                                  yValueMapper: (double datum, index) => datum,
                                  color: _colors[entry.key],
                                  xAxisName: "x",
                                  yAxisName: "Error",
                                  legendItemText: entry.key,
                                  name: entry.key,
                                ),
                              )
                              .toList(),
                        ),
                ),
                Text("Total Error"),
                Expanded(
                  child: _totalErrorsBundle == null
                      ? Container()
                      : SfCartesianChart(
                          legend: Legend(isVisible: true),
                          primaryXAxis: CategoryAxis(
                            labelPlacement: LabelPlacement.onTicks,
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: _totalErrorsBundle?.errorPoints.entries
                              .map((entry) => LineSeries(
                                    dataSource: entry.value,
                                    xValueMapper: (datum, index) =>
                                        _totalErrorsBundle?.xPoints[index],
                                    yValueMapper: (double datum, index) =>
                                        datum,
                                    color: _colors[entry.key],
                                    legendItemText: entry.key,
                                    xAxisName: "N",
                                    yAxisName: "Total Error",
                                    name: entry.key,
                                  ))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
          Form(
            key: _formKey,
            child: SizedBox(
              width: 200,
              child: Column(
                children: [
                  TextFormField(
                      enabled: !_isWaiting,
                      controller: _x0Controller,
                      validator: (value) {
                        if (value != null) {
                          try {
                            double.parse(value);
                            return null;
                          } on FormatException {
                            return "It`s not a number";
                          }
                        }
                        return "It`s not a number";
                      },
                      decoration: const InputDecoration(labelText: "x0")),
                  TextFormField(
                      enabled: !_isWaiting,
                      validator: (value) {
                        if (value != null) {
                          try {
                            double.parse(value);
                            return null;
                          } on FormatException {
                            return "It`s not a number";
                          }
                        }
                        return "It`s not a number";
                      },
                      controller: _y0Controller,
                      decoration: const InputDecoration(labelText: "y0")),
                  TextFormField(
                      enabled: !_isWaiting,
                      validator: (value) {
                        if (value != null) {
                          try {
                            var num = int.parse(value);
                            return num > 0
                                ? null
                                : "Number should be bigger than 0";
                          } on FormatException {
                            return "It`s not an integer";
                          }
                        }
                        return "It`s not an integer";
                      },
                      controller: _nController,
                      decoration: const InputDecoration(labelText: "N")),
                  TextFormField(
                      enabled: !_isWaiting,
                      validator: (value) {
                        if (value != null) {
                          try {
                            var num = double.parse(value);
                            if (num <= 0)
                              return "Number should be bigger than 0";
                            try {
                              var x = double.parse(_x0Controller.value.text);
                              if (x >= num)
                                return "Value should be bigger than x0";
                            } on FormatException {
                              return null;
                            }
                            return null;
                          } on FormatException {
                            return "It`s not a number";
                          }
                        }
                        return "It`s not a number";
                      },
                      controller: _XController,
                      decoration: const InputDecoration(labelText: "X")),
                  TextFormField(
                      enabled: !_isWaiting,
                      validator: (value) {
                        if (value != null) {
                          try {
                            var num = int.parse(value);
                            return num > 0
                                ? null
                                : "Number should be bigger than 0";
                          } on FormatException {
                            return "It`s not an integer";
                          }
                        }
                        return "It`s not an integer";
                      },
                      controller: _nMinController,
                      decoration: const InputDecoration(labelText: "nMin")),
                  TextFormField(
                      enabled: !_isWaiting,
                      validator: (value) {
                        if (value != null) {
                          try {
                            var num = int.parse(value);
                            if (num <= 0)
                              return "Number should be bigger than 0";
                            try {
                              var nMin =
                                  double.parse(_nMinController.value.text);
                              if (nMin >= num)
                                return "Value should be bigger than nMin";
                            } on FormatException {
                              return null;
                            }
                            return null;
                          } on FormatException {
                            return "It`s not a number";
                          }
                        }
                        return "It`s not a number";
                      },
                      controller: _nMaxController,
                      decoration: const InputDecoration(labelText: "nMax")),
                  TextButton(
                      onPressed: _isWaiting
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                _recalculateGraphs(
                                    InputData(
                                        double.parse(_x0Controller.value.text),
                                        double.parse(_y0Controller.value.text),
                                        int.parse(_nController.value.text),
                                        double.parse(_XController.value.text)),
                                    int.parse(_nMinController.value.text),
                                    int.parse(_nMaxController.value.text));
                              }
                            },
                      child: Text(_isWaiting ? "Plotting" : "Plot"))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _recalculateGraphs(
      InputData inputData, int nMin, int nMax) async {
    _lockInput(true);
    Future.wait([
      _solver.calculateGraphs(inputData).then(_updateSolutionGraphs),
      _solver
          .calculateTotalErrors(nMin, nMax, inputData)
          .then(_updateTotalErrorGraph)
    ]).then((_) => _lockInput(false));
  }

  void _updateSolutionGraphs(SolutionPointsBundle pointsBundle) {
    setState(() {
      this._pointsBundle = pointsBundle;
    });
  }

  void _updateTotalErrorGraph(TotalErrorsBundle pointsBundle) {
    setState(() {
      _totalErrorsBundle = pointsBundle;
    });
  }

  void _lockInput(bool lock) {
    setState(() {
      _isWaiting = lock;
    });
  }
}
