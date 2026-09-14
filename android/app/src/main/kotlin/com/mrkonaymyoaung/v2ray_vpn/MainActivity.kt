package com.mrkonaymyoaung.v2ray_vpn

import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.mrkonaymyoaung.v2ray_vpn/hwid"
    private val TAG = "V2RayVPN_HWID"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHwid" -> {
                    val hwid = getHwid()
                    Log.d(TAG, "Returning HWID: $hwid")
                    result.success(hwid)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getHwid(): String {
        // Try Android ID first (Settings.Secure.ANDROID_ID)
        var androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)

        // If Android ID is null or empty, try fallback methods
        if (androidId.isNullOrEmpty()) {
            Log.w(TAG, "ANDROID_ID is null/empty, using fallback")
            // Use Build fingerprint hash as fallback
            val fallbackSource = Build.FINGERPRINT + Build.MODEL + Build.MANUFACTURER + Build.SERIAL
            androidId = Integer.toHexString(fallbackSource.hashCode()).padStart(16, '0').take(16)
        }

        // Ensure exactly 16 hex characters, pad if shorter, hash if longer
        val sanitized = when {
            androidId.length >= 16 -> androidId.take(16).uppercase()
            androidId.isNotEmpty() -> androidId.padEnd(16, '0').uppercase()
            else -> "0000000000000000"
        }

        // Format as XXXX-XXXX-XXXX-XXXX
        val formatted = "${sanitized.substring(0, 4)}-${sanitized.substring(4, 8)}-${sanitized.substring(8, 12)}-${sanitized.substring(12, 16)}"
        Log.d(TAG, "Android ID raw: $androidId, formatted: $formatted")
        return formatted
    }
}
