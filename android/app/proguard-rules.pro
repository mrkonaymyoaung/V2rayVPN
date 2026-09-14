# Keep MainActivity and its methods (platform channel for HWID)
-keep class com.mrkonaymyoaung.v2ray_vpn.MainActivity { *; }

# Keep Flutter engine and platform channel classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Keep flutter_v2ray native classes
-keep class io.github.fougner.** { *; }
-keep class dev.flutter.plugins.** { *; }
