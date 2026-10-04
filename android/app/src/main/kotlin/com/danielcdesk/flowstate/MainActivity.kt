package com.danielcdesk.flowstate

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.danielcdesk.flowstate/local_notifications"
    private val permissionRequestCode = 921

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            requestPermissions(
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                permissionRequestCode,
                            )
                        }
                        result.success(null)
                    }
                    "schedule" -> {
                        val id = call.argument<String>("id")
                        val timestamp = call.argument<Long>("timestampMillis")
                        val title = call.argument<String>("title")
                        val body = call.argument<String>("body")
                        if (id == null || timestamp == null || title == null || body == null) {
                            result.error("INVALID_ARGUMENT", "Notification data is incomplete.", null)
                        } else {
                            schedule(id, timestamp, title, body)
                            result.success(null)
                        }
                    }
                    "cancel" -> {
                        val id = call.argument<String>("id")
                        if (id == null) {
                            result.error("INVALID_ARGUMENT", "Notification id is missing.", null)
                        } else {
                            cancel(id)
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun schedule(id: String, timestamp: Long, title: String, body: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, ReminderReceiver::class.java).apply {
            putExtra(ReminderReceiver.EXTRA_ID, id)
            putExtra(ReminderReceiver.EXTRA_TITLE, title)
            putExtra(ReminderReceiver.EXTRA_BODY, body)
        }
        val pending = PendingIntent.getBroadcast(
            this,
            id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timestamp, pending)
    }

    private fun cancel(id: String) {
        val intent = Intent(this, ReminderReceiver::class.java)
        val pending = PendingIntent.getBroadcast(
            this,
            id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        (getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
        pending.cancel()
    }
}
