import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('About Luxora')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _AboutHero(),
                SizedBox(height: 22),
                _SectionHeading(
                  label: 'Who we are',
                  title: 'A refined watch store built for confident buying.',
                  subtitle:
                      'Luxora brings together authentic timepieces, clean product guidance, and dependable after-sales care for people who value detail, craft, and trust.',
                ),
                SizedBox(height: 16),
                _TrustGrid(),
                SizedBox(height: 24),
                _StoryPanel(),
                SizedBox(height: 24),
                _ProcessSection(),
                SizedBox(height: 24),
                _ValuesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  children: const [
                    Expanded(flex: 5, child: _HeroCopy()),
                    Expanded(flex: 4, child: _HeroImage()),
                  ],
                )
              : Column(children: const [_HeroImage(), _HeroCopy()]),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LUXORA WATCH HOUSE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Luxury that feels precise, personal, and trustworthy.',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 32,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We curate watches for real ownership: style that fits your life, authenticity you can trust, and support that stays available after checkout.',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(icon: Icons.verified_outlined, text: 'Authenticated'),
              _MetricPill(
                icon: Icons.workspace_premium_outlined,
                text: 'Curated',
              ),
              _MetricPill(
                icon: Icons.support_agent_outlined,
                text: 'Supported',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1.08,
        child: Image.network(
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=1100&q=85',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.surface,
              child: const Icon(
                Icons.watch_outlined,
                color: AppColors.textLight,
                size: 76,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 24,
            height: 1.18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textLight,
            height: 1.55,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TrustGrid extends StatelessWidget {
  const _TrustGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _TrustItem(
        icon: Icons.verified_user_outlined,
        title: 'Authenticity First',
        text:
            'Clear sourcing, brand-led warranty details, and honest product information.',
      ),
      _TrustItem(
        icon: Icons.tune_outlined,
        title: 'Practical Guidance',
        text:
            'Dial size, strap, use case, and style advice for easier decisions.',
      ),
      _TrustItem(
        icon: Icons.local_shipping_outlined,
        title: 'Careful Delivery',
        text:
            'Secure packaging, tracking, and support when your order is moving.',
      ),
      _TrustItem(
        icon: Icons.handshake_outlined,
        title: 'Long-Term Support',
        text:
            'Help with orders, service, warranty, returns, and ownership questions.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final width = (constraints.maxWidth - (12 * (columns - 1))) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: _TrustCard(item: item),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TrustCard extends StatelessWidget {
  final _TrustItem item;

  const _TrustCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(height: 13),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            item.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 740;
          const story = _StoryCopy();
          const stats = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DarkStat(value: '24m', label: 'Warranty support'),
              _DarkStat(value: '3-5d', label: 'Delivery guidance'),
              _DarkStat(value: '100%', label: 'Original focus'),
              _DarkStat(value: '1:1', label: 'Personal help'),
            ],
          );

          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Expanded(child: story),
                    SizedBox(width: 18),
                    Expanded(child: stats),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [story, SizedBox(height: 16), stats],
                );
        },
      ),
    );
  }
}

class _StoryCopy extends StatelessWidget {
  const _StoryCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our standard',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Every watch should feel considered before it reaches your wrist.',
          style: TextStyle(
            color: AppColors.textInverse,
            fontSize: 22,
            height: 1.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'From product discovery to post-purchase support, Luxora keeps the experience calm, transparent, and premium.',
          style: TextStyle(
            color: Color(0xFFD1D5DB),
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _ProcessStep(
        icon: Icons.search_outlined,
        title: 'Discover',
        text:
            'Explore collections by lifestyle, occasion, and watch personality.',
      ),
      _ProcessStep(
        icon: Icons.compare_arrows_outlined,
        title: 'Decide',
        text:
            'Compare fit, features, dial presence, warranty, and delivery expectations.',
      ),
      _ProcessStep(
        icon: Icons.watch_outlined,
        title: 'Own',
        text:
            'Receive your watch with clear order support and after-sales assistance.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          label: 'Experience',
          title: 'Simple, premium, and guided.',
          subtitle:
              'Luxora is designed so users can choose a watch without confusion and get support whenever they need it.',
        ),
        const SizedBox(height: 14),
        ...steps.map((step) => _ProcessTile(step: step)),
      ],
    );
  }
}

class _ProcessTile extends StatelessWidget {
  final _ProcessStep step;

  const _ProcessTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(step.icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.text,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            label: 'Values',
            title: 'The details we protect.',
            subtitle:
                'Trust, taste, clarity, and long-term care guide every product and support interaction at Luxora.',
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricPill(icon: Icons.shield_outlined, text: 'Trust'),
              _MetricPill(icon: Icons.diamond_outlined, text: 'Taste'),
              _MetricPill(icon: Icons.fact_check_outlined, text: 'Clarity'),
              _MetricPill(icon: Icons.support_outlined, text: 'Care'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetricPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 17),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  final String value;
  final String label;

  const _DarkStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.card.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem {
  final IconData icon;
  final String title;
  final String text;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.text,
  });
}

class _ProcessStep {
  final IconData icon;
  final String title;
  final String text;

  const _ProcessStep({
    required this.icon,
    required this.title,
    required this.text,
  });
}
