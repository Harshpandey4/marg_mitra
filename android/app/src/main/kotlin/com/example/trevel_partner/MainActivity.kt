package com.example.trevel_partner

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.margmitra.app/sos"
    private val SMS_PERMISSION_REQUEST_CODE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendEmergencySMS" -> {
                    val location = call.argument<String>("location") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    val priority = call.argument<Boolean>("priority") ?: false

                    sendEmergencySMS(location, message, priority, result)
                }
                "triggerWeatherEmergency" -> {
                    val location = call.argument<String>("location") ?: ""
                    val weatherCondition = call.argument<String>("weatherCondition") ?: ""
                    val temperature = call.argument<Double>("temperature") ?: 0.0

                    triggerWeatherEmergency(location, weatherCondition, temperature, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendEmergencySMS(location: String, message: String, priority: Boolean, result: MethodChannel.Result) {
        if (checkSMSPermission()) {
            try {
                // Emergency contacts - Replace with actual emergency contacts
                val emergencyContacts = listOf(
                    "112",                // Emergency services
                    "+919876543210",      // Family member
                    "+919876543211",      // Friend
                    "+911234567890"       // Another contact
                )

                val smsManager = SmsManager.getDefault()
                val fullMessage = "$message\nLocation: $location\nTime: ${System.currentTimeMillis()}"

                var sentCount = 0
                var failCount = 0

                for (contact in emergencyContacts) {
                    try {
                        smsManager.sendTextMessage(contact, null, fullMessage, null, null)
                        sentCount++

                        // Add small delay to avoid overwhelming the system
                        Thread.sleep(100)
                    } catch (e: Exception) {
                        failCount++
                        println("Failed to send SMS to $contact: ${e.message}")
                    }
                }

                runOnUiThread {
                    if (sentCount > 0) {
                        Toast.makeText(this, "Emergency SMS sent to $sentCount contacts", Toast.LENGTH_LONG).show()
                        result.success(mapOf(
                            "sent" to sentCount,
                            "failed" to failCount,
                            "message" to "SMS sent successfully"
                        ))
                    } else {
                        Toast.makeText(this, "Failed to send emergency SMS", Toast.LENGTH_LONG).show()
                        result.error("SMS_FAILED", "Failed to send emergency SMS", null)
                    }
                }

            } catch (e: Exception) {
                runOnUiThread {
                    Toast.makeText(this, "SMS Error: ${e.message}", Toast.LENGTH_LONG).show()
                }
                result.error("SMS_ERROR", e.message, null)
            }
        } else {
            requestSMSPermission()
            result.error("PERMISSION_DENIED", "SMS permission not granted", null)
        }
    }

    private fun triggerWeatherEmergency(location: String, weatherCondition: String, temperature: Double, result: MethodChannel.Result) {
        try {
            // Enhanced emergency protocol for weather conditions
            val weatherMessage = "WEATHER EMERGENCY ALERT!\n" +
                    "Severe weather conditions detected.\n" +
                    "Condition: $weatherCondition\n" +
                    "Temperature: ${temperature}°C\n" +
                    "Location: $location\n" +
                    "Immediate assistance required!\n" +
                    "Time: ${System.currentTimeMillis()}"

            if (checkSMSPermission()) {
                val smsManager = SmsManager.getDefault()

                // Priority contacts for weather emergencies
                val priorityContacts = listOf(
                    "112",  // Emergency services
                    "1070", // Weather emergency helpline (if available)
                    // Add priority contacts here
                )

                var sentCount = 0
                for (contact in priorityContacts) {
                    try {
                        smsManager.sendTextMessage(contact, null, weatherMessage, null, null)
                        sentCount++
                        Thread.sleep(100)
                    } catch (e: Exception) {
                        println("Failed to send weather emergency SMS to $contact: ${e.message}")
                    }
                }

                runOnUiThread {
                    if (sentCount > 0) {
                        Toast.makeText(this, "Weather emergency alert sent!", Toast.LENGTH_LONG).show()
                    }
                }

                result.success(mapOf(
                    "sent" to sentCount,
                    "message" to "Weather emergency alert sent"
                ))
            } else {
                result.error("PERMISSION_DENIED", "SMS permission required for weather alerts", null)
            }

        } catch (e: Exception) {
            result.error("WEATHER_EMERGENCY_ERROR", e.message, null)
        }
    }

    private fun checkSMSPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestSMSPermission() {
        if (!checkSMSPermission()) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.SEND_SMS),
                SMS_PERMISSION_REQUEST_CODE
            )
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            SMS_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(this, "SMS permission granted", Toast.LENGTH_SHORT).show()
                } else {
                    Toast.makeText(this, "SMS permission denied. Emergency features may not work.", Toast.LENGTH_LONG).show()
                }
            }
        }
    }
}