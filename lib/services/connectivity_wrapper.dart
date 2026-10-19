import 'package:flutter/material.dart';
import 'package:thanya/screens/offline_screen.dart';
import 'connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().connectionStream,
      initialData: true,
      builder: (context, snapshot) {
        final connected = snapshot.data ?? true;

        return Stack(
          children: [widget.child, if (!connected) const OfflineScreen()],
        );
      },
    );
  }
}
