import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Container(
      decoration: kAppBackground,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 26, 20, bottomPadding),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '설정',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '편안하게 읽을 수 있도록 맞춰보세요.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _SettingsSection(
              icon: Icons.text_fields,
              title: '글씨 크기',
              child: Column(
                children: [
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
                          label: '${settings.fontSize.round()}',
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .setFontSize(v),
                        ),
                      ),
                      const Text('가',
                          style: TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      '미리보기 — 너희가 자유롭게 되리라',
                      style: AppTheme.scriptureText(
                        size: settings.fontSize,
                        color: AppConstants.textPrimary,
                        height: 1.9,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _SettingsSection(
              icon: Icons.auto_stories,
              title: '읽기 진행률',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: settings.readingProgress,
                      minHeight: 7,
                      backgroundColor: AppConstants.bgCardLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppConstants.accent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${settings.readChapters.length} / 1,189장  '
                    '(${(settings.readingProgress * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _SettingsSection(
              icon: Icons.volume_up,
              title: '음성',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('엔진', 'Google Cloud TTS (Wavenet)'),
                  const SizedBox(height: 4),
                  _kv('음성', '한국어 · ko-KR-Wavenet-A'),
                  const SizedBox(height: 4),
                  _kv('캐시', '같은 구절 두 번째부터 오프라인'),
                  const SizedBox(height: 10),
                  Text(
                    '오프라인에서는 기기 기본 음성으로 자동 전환돼요.',
                    style: TextStyle(
                      color: AppConstants.textDim.withOpacity(0.85),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 앱 정보 카드
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: softShadow(opacity: 0.25),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: AppConstants.bgCard.withOpacity(0.85),
                  border: Border.all(
                    color: AppConstants.border,
                    width: 0.6,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x1FF2A88F),
                      Color(0x14B5A8E6),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppConstants.accent,
                            AppConstants.accentDeep,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.accent.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '✦',
                          style: TextStyle(
                            color: AppConstants.onAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AI가 마음에 맞는 말씀을 찾아드려요',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppConstants.textDim.withOpacity(0.95),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConstants.copyright,
                      style: TextStyle(
                        color: AppConstants.textDim.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 링크들
            _LinkTile(
              icon: Icons.description_outlined,
              title: '이용약관',
              onTap: () => _launchUrl('https://lightonplus.com/terms'),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보처리방침',
              onTap: () => _launchUrl('https://lightonplus.com/privacy'),
            ),
            const SizedBox(height: 8),
            _LinkTile(
              icon: Icons.mail_outline,
              title: '문의하기',
              onTap: () => _launchUrl('mailto:support@lightonplus.com'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _kv(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            key,
            style: const TextStyle(
              color: AppConstants.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppConstants.bgCard.withOpacity(0.78),
        border: Border.all(
          color: AppConstants.border,
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.accent.withOpacity(0.15),
                ),
                child: Icon(icon,
                    color: AppConstants.accentBright, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppConstants.bgCard.withOpacity(0.65),
          border: Border.all(
            color: AppConstants.border,
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.textSecondary, size: 17),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppConstants.textDim,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
