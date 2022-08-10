import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:enercle_proj/sizes.dart';
import 'package:enercle_proj/const/colors.dart';
import 'package:enercle_proj/provider/platform_provider.dart';
import './mitigation_monitoring/mitigation_status_view.dart';
import './mitigation_monitoring/mitigation_footprint_view.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class MitigationMonitoringView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MitigationMonitoringView();
}

class _MitigationMonitoringView extends State<MitigationMonitoringView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkBadgeCount();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkBadgeCount() {
    if (Provider.of<Platform>(context, listen: false).mitigationBadgeCount >
        0) {
      Provider.of<Platform>(context, listen: false).resetMitigationBadgeCount();
      FlutterAppBadger.updateBadgeCount(
          Provider.of<Platform>(context, listen: false).totalBadgeCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: context.pHeight * 0.03),
        child: SafeArea(
            maintainBottomViewPadding: true,
            child: Column(children: [
              Container(
                  padding: EdgeInsets.only(
                      left: context.pWidth * 0.03,
                      right: context.pWidth * 0.03),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('감축 이행 현황',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.pHeight * 0.04,
                              fontWeight: FontWeight.bold)))),
              Padding(padding: EdgeInsets.all(context.pHeight * 0.01)),
              Padding(
                  padding: EdgeInsets.only(
                      left: context.pWidth * 0.01,
                      right: context.pWidth * 0.01,
                      bottom: context.pHeight * 0.01),
                  child: Container(
                      height: context.pHeight * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey[100],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: DefaultTabController(
                          length: 2,
                          child: TabBar(
                              unselectedLabelColor: Colors.grey,
                              labelColor: Colors.white,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: MyColors.mainColor),
                              tabs: [
                                Tab(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text('실시간 감축 상태',
                                            style: TextStyle(
                                                fontSize:
                                                    context.pHeight * 0.02,
                                                fontWeight: FontWeight.w600)))),
                                Tab(
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: Text('감축 이행 이력',
                                            style: TextStyle(
                                                fontSize:
                                                    context.pHeight * 0.02,
                                                fontWeight: FontWeight.bold)))),
                              ],
                              controller: _tabController)))),
              Expanded(
                  child: SizedBox(
                      height: context.pHeight,
                      child: TabBarView(controller: _tabController, children: [
                        MitigationStatusView(),
                        MitigationFootprintView(),
                      ]))),
            ])));
  }
}
