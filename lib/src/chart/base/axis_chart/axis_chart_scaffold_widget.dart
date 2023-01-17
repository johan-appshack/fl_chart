import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/axis_chart/side_titles/side_titles_widget.dart';
import 'package:fl_chart/src/extensions/fl_titles_data_extension.dart';
import 'package:flutter/material.dart';

/// A scaffold to show an axis-based chart
///
/// It contains some placeholders to represent an axis-based chart.
///
/// It's something like the below graph:
/// |----------------------|
/// |      |  top  |       |
/// |------|-------|-------|
/// | left | chart | right |
/// |------|-------|-------|
/// |      | bottom|       |
/// |----------------------|
///
/// `left`, `top`, `right`, `bottom` are some place holders to show titles
/// provided by [AxisChartData.titlesData] around the chart
/// `chart` is a centered place holder to show a raw chart.
class AxisChartScaffoldWidget extends StatefulWidget {
  const AxisChartScaffoldWidget({
    super.key,
    required this.chart,
    required this.data,
    this.didSelectPage,
    required this.charts,
    this.dataList,
  });
  final Widget chart;
  final List<Widget> charts;
  final AxisChartData data;
  final List<AxisChartData>? dataList;

  final Function(int)? didSelectPage;

  @override
  State<AxisChartScaffoldWidget> createState() =>
      _AxisChartScaffoldWidgetState();
}

class _AxisChartScaffoldWidgetState extends State<AxisChartScaffoldWidget> {
  int currentPage = 0;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  bool get showLeftTitles {
    if (!widget.data.titlesData.show) {
      return false;
    }
    final showAxisTitles = widget.data.titlesData.leftTitles.showAxisTitles;
    final showSideTitles = widget.data.titlesData.leftTitles.showSideTitles;
    return showAxisTitles || showSideTitles;
  }

  bool get showRightTitles {
    if (!widget.data.titlesData.show) {
      return false;
    }
    final showAxisTitles = widget.data.titlesData.rightTitles.showAxisTitles;
    final showSideTitles = widget.data.titlesData.rightTitles.showSideTitles;
    return showAxisTitles || showSideTitles;
  }

  bool get showTopTitles {
    if (!widget.data.titlesData.show) {
      return false;
    }
    final showAxisTitles = widget.data.titlesData.topTitles.showAxisTitles;
    final showSideTitles = widget.data.titlesData.topTitles.showSideTitles;
    return showAxisTitles || showSideTitles;
  }

  bool get showBottomTitles {
    if (!widget.data.titlesData.show) {
      return false;
    }
    final showAxisTitles = widget.data.titlesData.bottomTitles.showAxisTitles;
    final showSideTitles = widget.data.titlesData.bottomTitles.showSideTitles;
    return showAxisTitles || showSideTitles;
  }

  Clip pageViewClip = Clip.hardEdge;

  List<Widget> stackWidgets(BoxConstraints constraints) {
    pageController = PageController(initialPage: widget.charts.length);
    final widgets = <Widget>[
      Container(
        margin: widget.data.titlesData.allSidesPadding,
        decoration: BoxDecoration(
          border: widget.data.borderData.isVisible()
              ? widget.data.borderData.border
              : null,
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              if (mounted) {
                pageViewClip = Clip.hardEdge;
              }
            }
            if (notification is ScrollEndNotification) {
              if (mounted) {
                pageViewClip = Clip.none;
              }
            }
            return true;
          },
          child: widget.charts.isEmpty
              ? Container()
              : PageView(
                  clipBehavior: pageViewClip,
                  controller: pageController,
                  onPageChanged: (value) {
                    widget.didSelectPage?.call(value);
                    setState(() {
                      currentPage = value;
                    });
                  },
                  children: widget.charts,
                ),
        ),
      )
    ];

    int insertIndex(bool drawBelow) => drawBelow ? 0 : widgets.length;

    if (showLeftTitles) {
      widgets.insert(
        insertIndex(widget.data.titlesData.leftTitles.drawBelowEverything),
        SideTitlesWidget(
          side: AxisSide.left,
          axisChartData: widget.data,
          parentSize: constraints.biggest,
        ),
      );
    }

    if (showTopTitles) {
      widgets.insert(
        insertIndex(widget.data.titlesData.topTitles.drawBelowEverything),
        SideTitlesWidget(
          side: AxisSide.top,
          axisChartData: widget.data,
          parentSize: constraints.biggest,
        ),
      );
    }

    if (showRightTitles) {
      final axisData = widget.dataList != null && widget.dataList!.isNotEmpty
          ? widget.dataList![currentPage]
          : widget.data;
      widgets.insert(
        insertIndex(axisData.titlesData.rightTitles.drawBelowEverything),
        SideTitlesWidget(
          side: AxisSide.right,
          axisChartData: axisData,
          parentSize: constraints.biggest,
        ),
      );
    }

    if (showBottomTitles) {
      final axisData = widget.dataList != null && widget.dataList!.isNotEmpty
          ? widget.dataList![currentPage]
          : widget.data;
      widgets.insert(
        insertIndex(axisData.titlesData.bottomTitles.drawBelowEverything),
        SideTitlesWidget(
          side: AxisSide.bottom,
          axisChartData: axisData,
          parentSize: constraints.biggest,
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: stackWidgets(constraints),
        );
      },
    );
  }
}
