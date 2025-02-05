import 'package:agentic_placeholder_attester/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../controllers/navigation_controller.dart';
import '../controllers/service_controller.dart';
import '../utils/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ServiceController serviceController;
  late NavigationController navigationController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    serviceController = getIt<ServiceController>();
    navigationController = getIt<NavigationController>();
    if (!serviceController.initialized) {
      serviceController.initializeService(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (serviceController.pageDatas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<Widget> navRail = [];
        if (MediaQuery.of(context).size.width >= Constants.smallScreen) {
          navRail.add(_buildNavigationRail());
        }
        navRail.add(
          Expanded(
            child: serviceController.pageDatas[navigationController.selectedIndex].page,
          ),
        );
        return Scaffold(
          body: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Constants.smallScreen.toDouble(),
              ),
              child: Row(
                children: navRail,
              ),
            ),
          ),
          bottomNavigationBar: MediaQuery.of(context).size.width < Constants.smallScreen
              ? _buildBottomNavBar()
              : null,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Observer(
      builder: (_) => BottomNavigationBar(
        currentIndex: navigationController.selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.indigoAccent,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => navigationController.setSelectedIndex(index),
        items: serviceController.pageDatas
            .map(
              (e) => BottomNavigationBarItem(
            icon: Icon(e.icon),
            label: e.title,
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Observer(
      builder: (_) => NavigationRail(
        selectedIndex: navigationController.selectedIndex,
        onDestinationSelected: (index) => navigationController.setSelectedIndex(index),
        labelType: NavigationRailLabelType.selected,
        destinations: serviceController.pageDatas
            .map(
              (e) => NavigationRailDestination(
            icon: Icon(e.icon),
            label: Text(e.title),
          ),
        )
            .toList(),
      ),
    );
  }
}