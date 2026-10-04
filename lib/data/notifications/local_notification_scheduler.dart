import 'package:flutter/services.dart';

import 'package:flowstate/domain/notifications/reminder.dart';

final class LocalNotificationScheduler {
  LocalNotificationScheduler({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName =
      'com.danielcdesk.flowstate/local_notifications';
  final MethodChannel _channel;

  Future<void> requestPermission() async {
    await _channel.invokeMethod<void>('requestPermission');
  }

  Future<void> schedule({
    required ReminderOccurrence occurrence,
    required String title,
    required String body,
  }) async {
    final DateTime local = DateTime(
      occurrence.date.year,
      occurrence.date.month,
      occurrence.date.day,
      occurrence.minute ~/ 60,
      occurrence.minute % 60,
    );
    await _channel.invokeMethod<void>('schedule', <String, Object>{
      'id': occurrence.sourceId,
      'timestampMillis': local.toUtc().millisecondsSinceEpoch,
      'title': title,
      'body': body,
    });
  }

  Future<void> cancel(String sourceId) async {
    await _channel.invokeMethod<void>('cancel', <String, Object>{
      'id': sourceId,
    });
  }
}
