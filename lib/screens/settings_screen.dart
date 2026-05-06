import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0640), AppConstants.bgPrimary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
          children: [
            Text(
              '⚙️ 설정',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // 글씨 크기
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.text_fields,
                          color: AppConstants.accentBright, size: 20),
                      SizedBox(width: 10),
                      Text(
                        '글씨 크기',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('가',
                          style: TextStyle(
                              color: AppConstants.textDim, fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 12,
                          max: 28,
                          divisions: 16,
                          activeColor: AppConstants.accent,
                          inactiveColor: AppConstants.accentSoft,
                          label: '${settings.fontSize.round()}',
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setFontSize(v),
                        ),
                      ),
                      const Text('가',
                          style: TextStyle(
                              color: AppConstants.textPrimary, fontSize: 24)),
                    ],
                  ),
                  Center(
                    child: Text(
                      '미리보기 텍스트',
                      style: TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: settings.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 읽기 진행률
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories,
                          color: AppConstants.accentBright, size: 20),
                      SizedBox(width: 10),
                      Text(
                        '읽기 진행률',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: settings.readingProgress,
                      minHeight: 8,
                      backgroundColor: AppConstants.bgCardLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppConstants.accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${settings.readChapters.length} / 1,189장 '
                    '(${(settings.readingProgress * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // TTS 설정
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volume_up,
                          color: AppConstants.accentBright, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'TTS 설정',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '음성: Google Cloud TTS (Chirp 3 HD)',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '언어: 한국어 (ko-KR-Chirp3-HD-Leda)',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⚡ 오프라인 시 기본 TTS 엔진으로 자동 전환됩니다',
                    style: TextStyle(
                      color: AppConstants.textDim.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 앱 정보
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '✨',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI 기반 성경 말씀 검색',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: AppConstants.textDim,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppConstants.copyright,
                    style: TextStyle(
                      color: AppConstants.textDim,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 링크들
            _buildLinkTile(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: () => _launchUrl('https://lightonplus.com/terms'),
            ),
            const SizedBox(height: 8),
            _buildLinkTile(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보처리방침',
              onTap: () => _launchUrl('https://lightonplus.com/privacy'),
            ),
            const SizedBox(height: 8),
            _buildLinkTile(
              icon: Icons.mail_outline,
              title: '문의하기',
              onTap: () => _launchUrl('mailto:support@lightonplus.com'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.textDim, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppConstants.textDim,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
