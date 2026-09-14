package com.mrkonaymyoaung.v2ray_vpn

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.mrkonaymyoaung.v2ray_vpn/hwid"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getHwid") {
                val hwid = getHwid()
                result.success(hwid)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getHwid(): String {
        val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
        // Pad or trim to 16 hex chars, then format as XXXX-XXXX-XXXX-XXXX
        val sanitized = (androidId ?: "0000000000000000").padEnd(16, '0').take(16).uppercase()
        return "${sanitized.substring(0, 4)}-${sanitized.substring(4, 8)}-${sanitized.substring(8, 12)}-${sanitized.substring(12, 16)}"
    }
}
