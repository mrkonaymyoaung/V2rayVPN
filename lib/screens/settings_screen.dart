import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final serverProvider = context.watch<ServerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account section
          _sectionTitle('Account'),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: Icons.fingerprint,
            title: 'HWID',
            value: auth.hwid,
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF8B95A5)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: auth.hwid));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('HWID copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: auth.isPremium ? Icons.star : Icons.star_border,
            title: 'Account Type',
            value: auth.isPremium ? 'Premium' : 'Free',
            iconColor: auth.isPremium ? const Color(0xFFFFD700) : const Color(0xFF8B95A5),
          ),
          if (!auth.isPremium) ...[
            const SizedBox(height: 8),
            _infoCard(
              context,
              icon: Icons.info_outline,
              title: 'How to get Premium',
              value: 'Contact admin with your HWID to be added to the premium list',
            ),
          ],

          const SizedBox(height: 24),

          // Server section
          _sectionTitle('Servers'),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: Icons.dns_outlined,
            title: 'Total Servers',
            value: '${serverProvider.servers.length}',
          ),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: Icons.cloud_outlined,
            title: 'Last Updated',
            value: serverProvider.updatedAt.isNotEmpty
                ? serverProvider.updatedAt
                : 'Unknown',
          ),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: Icons.tag,
            title: 'Config Version',
            value: 'v${serverProvider.version}',
          ),

          const SizedBox(height: 24),

          // Refresh button
          ElevatedButton.icon(
            onPressed: () async {
              await auth.refreshPremium();
              await serverProvider.fetchServers();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshed successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
          ),

          const SizedBox(height: 24),

          // About section
          _sectionTitle('About'),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: Icons.shield_outlined,
            title: 'App Version',
            value: '1.0.0',
          ),
          const SizedBox(height: 8),
          _infoCard(
            context,
            icon: Icons.code,
            title: 'VPN Engine',
            value: 'Xray Core 25.3.6',
          ),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'V2Ray VPN\nPowered by flutter_v2ray',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8B95A5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D333B)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFF6C5CE7), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B95A5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
