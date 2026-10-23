package com.example.appdiemdanh

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.appdiemdanh.ekyc.NativeCameraViewFactory
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.appdiemdanh/notification"
    private val CHANNEL_ID = "high_importance_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Đăng ký Native Face Engine View sử dụng Dart Executor Binary Messenger
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.example.app/native_face_view",
            NativeCameraViewFactory(flutterEngine.dartExecutor.binaryMessenger, this)
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "showSystemNotification") {
                val title = call.argument<String>("title") ?: "Thông báo mới"
                val body = call.argument<String>("body") ?: ""
                val id = call.argument<Int>("id") ?: System.currentTimeMillis().toInt()
                
                showNotification(title, body, id)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showNotification(title: String, body: String, id: Int) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Thông báo hệ thống",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Kênh thông báo của ứng dụng"
                enableVibration(true)
                enableLights(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)

        notificationManager.notify(id, builder.build())
    }
}
