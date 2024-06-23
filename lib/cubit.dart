import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:leakooo/cache_helper.dart';
import 'package:leakooo/navigator_service.dart';
import 'package:leakooo/states.dart';
import 'package:http/http.dart' as http;

class MainCubit extends Cubit<MainStates> {
  MainCubit() : super(MainInitialStates()) {
    Timer.periodic(Duration(seconds: 5), (timer) {
      fetchFlowRates();
    });
  }

  static MainCubit get(context) => BlocProvider.of(context);

  double flowRate1 = 0.0;
  double flowRate2 = 0.0;
  bool leakDetected = false;
  String serverIp = 'http://192.168.11.107/flowrates';
  Future<void> fetchFlowRates() async {
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
        emit(LeakDetectedSuccessfulState(
            flowRate1: flowRate1, flowRate2: flowRate2));
        if (leakDetected) {
          CacheHelper.saveDate(key: 'flowRate1', value: flowRate1.toString());
          CacheHelper.saveDate(key: 'flowRate2', value: flowRate2.toString());
          await AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 1,
                  channelKey: 'leak',
                  displayOnBackground: false,
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
      print('Error Cubit: $e');
    }
  }

  Future<void> sendEmail() async {
    final Email email = Email(
      body:
          'Leak detected!\nFlow Rate 1: $flowRate1 L/min\nFlow Rate 2: $flowRate2 L/min',
      subject: 'Water Leak Detection Alert',
      recipients: ['user@example.com'], // email
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Error sending email: $error');
    }
  }
}
