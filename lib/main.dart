import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_email_sender/flutter_email_sender.dart';

void main() => runApp(MyApp()); //

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlowRateMonitor(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlowRateMonitor extends StatefulWidget {
  @override
  _FlowRateMonitorState createState() => _FlowRateMonitorState();
}

class _FlowRateMonitorState extends State<FlowRateMonitor> {
  double flowRate1 = 0.0;
  double flowRate2 = 0.0;
  bool leakDetected = false;
  final String serverIp = 'http://192.168.229.107/flowrates';

  @override
  void initState() {
    super.initState();
    fetchFlowRates();
  }

  Future<void> fetchFlowRates() async {
    try {
      final response = await http.get(Uri.parse(serverIp));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded JSON: $data');
        setState(() {
          flowRate1 = data['flowRate1'];
          flowRate2 = data['flowRate2'];
          leakDetected = data['leakDetected'] == true;
        });
        if (leakDetected) {
          sendEmail();
        }
      } else {
        throw Exception('Failed to load flow rates');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendEmail() async {
    final Email email = Email(
      body:
          'Leak detected!\nFlow Rate 1: $flowRate1 L/min\nFlow Rate 2: $flowRate2 L/min',
      subject: 'Water Leak Detection Alert',
      recipients: ['user@example.com'], // Replace with your email
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flow Rate Monitor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Flow Rate Sensor 1: $flowRate1 L/min'),
            SizedBox(height: 20),
            AnimatedRadialGauge(
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              radius: 100,
              value: flowRate1,
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
            Text('Flow Rate Sensor 2: $flowRate2 L/min'),
            SizedBox(height: 20),
            AnimatedRadialGauge(
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              radius: 100,
              value: flowRate2,
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
            leakDetected
                ? Text('Potential Leak Detected!',
                    style: TextStyle(color: Colors.red, fontSize: 20))
                : Text('No Leak Detected',
                    style: TextStyle(color: Colors.green, fontSize: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchFlowRates,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
