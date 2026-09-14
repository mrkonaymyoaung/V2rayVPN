# V2Ray VPN

A modern Android VPN client built with Flutter, supporting V2Ray/Xray protocols (VLESS, VMess, Trojan, Shadowsocks) with HWID-based premium authentication.

## Features

- **Modern UI** - Material 3 design with dark theme, gradient accents, and smooth animations
- **HWID Authentication** - Device-based premium verification using Android ID
- **Free & Premium Servers** - Tiered server system with premium lock for free users
- **Multi-Protocol Support** - VLESS, VMess, Trojan, Shadowsocks via Xray Core 25.3.6
- **Real-time Status** - Connection state, ping/delay display, upload/download speeds
- **Server Management** - Browse, select, and switch between servers with country flags

## Architecture

```
lib/
├── main.dart                 # App entry point with Provider setup
├── app.dart                   # MaterialApp configuration
├── theme/
│   └── app_theme.dart         # Material 3 dark theme with custom colors
├── models/
│   └── server_model.dart      # Server data model (from servers.json)
├── services/
│   ├── hwid_service.dart      # HWID generation & premium list checking
│   ├── server_service.dart     # Server config fetching from backend
│   └── vpn_service.dart        # V2Ray/Xray VPN connection management
├── providers/
│   ├── auth_provider.dart     # Premium status state
│   ├── server_provider.dart   # Server list state
│   └── vpn_provider.dart      # VPN connection state
├── screens/
│   ├── splash_screen.dart     # Loading & initialization
│   ├── home_screen.dart       # Main screen with connect button
│   ├── servers_screen.dart    # Server selection (Free/Premium tabs)
│   └── settings_screen.dart   # HWID display, account info
└── widgets/
    ├── connect_button.dart    # Animated circular connect button
    └── server_tile.dart       # Server list item with tier badges
```

## Backend Configuration

### HWID Premium List
- **URL**: `https://raw.githubusercontent.com/mrkonaymyoaung/backup/refs/heads/main/premium.txt`
- **Format**: One HWID per line (e.g., `34A1-D96A-E51F-4DE0`)
- HWID is derived from Android's `Settings.Secure.ANDROID_ID`, formatted as `XXXX-XXXX-XXXX-XXXX`

### Server Configuration
- **URL**: `https://raw.githubusercontent.com/mrkonaymyoaung/backup/refs/heads/main/servers.json`
- **Format**:
```json
{
  "version": 1,
  "updatedAt": "2026-09-08",
  "servers": [
    {
      "id": "jp-free-01",
      "name": "Japan Free 01",
      "country": "🇯🇵",
      "protocol": "vless",
      "tier": "free",
      "uri": "vless://..."
    }
  ]
}
```

## Building

```bash
# Install dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Tech Stack

- **Framework**: Flutter 3.44.4 / Dart 3.12.2
- **VPN Engine**: [flutter_v2ray](https://pub.dev/packages/flutter_v2ray) (Xray Core 25.3.6)
- **State Management**: Provider 6.1.2
- **HTTP Client**: http 1.6.0
- **Fonts**: Google Fonts (Poppins)

## License

This project is for educational purposes. The flutter_v2ray package uses MIT license.
