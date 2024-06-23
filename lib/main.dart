import 'dart:async';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'dart:convert';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:leakooo/cache_helper.dart';
import 'package:leakooo/cubit.dart';
import 'package:leakooo/navigator_service.dart';
import 'package:leakooo/states.dart';
import 'package:http/http.dart' as http;

Future<void> initalizeNotification() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelGroupKey: "basic_channel_group",
        ledColor: Colors.yellow,
        defaultColor: Colors.deepPurple,
        channelKey: "leak",
        channelName: 'leakChannel',
        channelDescription: 'Leak Notifications',
        importance: NotificationImportance.High,
        enableLights: true,
        enableVibration: true,
        playSound: true),
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "basic_channel_group",
        channelGroupName: "Basic group"),
  ]);
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();

  if (!isAllowedToSendNotification) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  navigatorKey.currentState?.popUntil((route) => route.isFirst);
}

var currentContext = NavigationService.navigatorKey.currentContext;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Future.wait([initalizeNotification(), CacheHelper.init()]);

  Timer.periodic(Duration(seconds: 5), (timer) async {
    double flowRate1 = 0.0;
    double flowRate2 = 0.0;
    bool leakDetected = false;
    String serverIp = 'http://192.168.11.107/flowrates';
    try {
      final response = await http.get(Uri.parse(serverIp));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded JSON: $data');
        flowRate1 = data['flowRate1'];
        flowRate2 = data['flowRate2'];
        leakDetected = data['leakDetected'] == true;
        if (leakDetected) {
          CacheHelper.saveDate(key: 'flowRate1', value: flowRate1.toString());
          CacheHelper.saveDate(key: 'flowRate2', value: flowRate2.toString());
          await AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 1,
                  channelKey: 'leak',
                  displayOnBackground: true,
                  displayOnForeground: true,
                  backgroundColor: Colors.white,
                  color: Colors.yellow,
                  title: "Potential water leak detected",
                  body: "Sensor1: " +
                      CacheHelper.getActualData(key: 'flowRate1') +
                      " Sensor2: " +
                      CacheHelper.getActualData(key: 'flowRate2'),
                  notificationLayout: NotificationLayout.Default,
                  autoDismissible: false),
              actionButtons: []);
        }
      } else {
        throw Exception('Failed to load flow rates');
      }
    } catch (e) {
      print('Error Main: $e');
    }
  });

  runApp(MyApp());
} //

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: BlocBuilder<MainCubit, MainStates>(builder: (context, state) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          home: FlowRateMonitor(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}

class FlowRateMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: BlocBuilder<MainCubit, MainStates>(builder: (context, state) {
        final cubit = MainCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: Text('Flow Rate Monitor'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Flow Rate Sensor 1: ${cubit.flowRate1} L/min'),
                SizedBox(height: 20),
                AnimatedRadialGauge(
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  radius: 100,
                  value: state is LeakDetectedSuccessfulState
                      ? state.flowRate1
                      : cubit.flowRate1,
                  axis: GaugeAxis(
                    min: 0,
                    max: 10, // Adjust based on expected flow rates
                    degrees: 180,
                    style: const GaugeAxisStyle(
                      thickness: 20,
                      background: Color(0xFFDFE2EC),
                      segmentSpacing: 4,
                    ),
                    pointer: GaugePointer.needle(
                      width: 16,
                      height: 100,
                      color: Color(0xFF193663),
                      borderRadius: 16,
                    ),
                    progressBar: const GaugeProgressBar.rounded(
                      color: Color(0xFFB4C2F8),
                    ),
                    segments: [
                      const GaugeSegment(
                        from: 0,
                        to: 3.3,
                        color: Color(0xFFD9DEEB),
                        cornerRadius: Radius.zero,
                      ),
                      const GaugeSegment(
                        from: 3.3,
                        to: 6.6,
                        color: Color(0xFFD9DEEB),
                        cornerRadius: Radius.zero,
                      ),
                      const GaugeSegment(
                        from: 6.6,
                        to: 10,
                        color: Color(0xFFD9DEEB),
                        cornerRadius: Radius.zero,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text('Flow Rate Sensor 2: ${cubit.flowRate2} L/min'),
                SizedBox(height: 20),
                AnimatedRadialGauge(
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  radius: 100,
                  value: state is LeakDetectedSuccessfulState
                      ? state.flowRate2
                      : cubit.flowRate2,
                  axis: GaugeAxis(
                    min: 0,
                    max: 10, // Adjust based on expected flow rates
                    degrees: 180,
                    style: const GaugeAxisStyle(
                      thickness: 20,
                      background: Color(0xFFDFE2EC),
                      segmentSpacing: 4,
                    ),
                    pointer: GaugePointer.needle(
                      width: 16,
                      height: 100,
                      color: Color(0xFF193663),
                      borderRadius: 16,
                    ),
                    progressBar: const GaugeProgressBar.rounded(
                      color: Color(0xFFB4C2F8),
                    ),
                    segments: [
                      const GaugeSegment(
                        from: 0,
                        to: 3.3,
                        color: Color(0xFFD9DEEB),
                        cornerRadius: Radius.zero,
                      ),
                      const GaugeSegment(
                        from: 3.3,
                        to: 6.6,
                        color: Color(0xFFD9DEEB),
                        cornerRadius: Radius.zero,
                      ),
                      const GaugeSegment(
                        from: 6.6,
                        to: 10,
                        color: Color(0xFFD9DEEB),
                        cornerRadius: Radius.zero,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                cubit.leakDetected
                    ? Text('Potential Leak Detected!',
                        style: TextStyle(color: Colors.red, fontSize: 20))
                    : Text('No Leak Detected',
                        style: TextStyle(color: Colors.green, fontSize: 20)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: cubit.fetchFlowRates,
            tooltip: 'Refresh',
            child: Icon(Icons.refresh),
          ),
        );
      }),
    );
  }
}
