import 'package:flutter_vision/importer.dart';
import 'scan.dart';

class MainTab extends StatelessWidget {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'SCAN'),
    Tab(text: 'WORDS'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0), // here the desired height
            child: AppBar(
              bottom: TabBar(
                tabs: myTabs,
              ),
            )),
        body: TabBarView(
          children: [
            Scan(
              cameras: cameras,
            ),
            Center(
              child: Text('ワードリストです。'),
            )
          ],
        ),
      ),
    );
  }
}
