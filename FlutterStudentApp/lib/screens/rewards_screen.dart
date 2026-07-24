import 'package:flutter/material.dart';

import '../core/mewtionary_theme.dart';
import '../services/gamification_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({
    required this.gamification,
    super.key,
  });

  final GamificationService gamification;

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    widget.gamification.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards & Badges')),
      body: AnimatedBuilder(
        animation: widget.gamification,
        builder: (context, _) {
          final wallet = widget.gamification.wallet;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: const Color(0xFFFFF1C7),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        size: 62,
                        color: MewtionaryTheme.amber,
                      ),
                      Text(
                        'Level ${wallet.level}',
                        style: const TextStyle(
                          fontSize: 28,
                          color: MewtionaryTheme.navy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: wallet.levelProgress,
                        minHeight: 11,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${wallet.xpInsideLevel}/100 XP to next level',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _WalletCard(
                      icon: '⭐',
                      label: 'Total XP',
                      value: '${wallet.xp}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _WalletCard(
                      icon: '🪙',
                      label: 'Coins',
                      value: '${wallet.coins}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _WalletCard(
                      icon: '🔥',
                      label: 'Streak',
                      value: '${wallet.streak}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Badge Cabinet',
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: MewtionaryTheme.navy,
                          fontWeight: FontWeight.w900,
                        ),
              ),
              for (final badge in widget.gamification.badges)
                Card(
                  color: badge.unlocked
                      ? const Color(0xFFDFF4E2)
                      : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: badge.unlocked
                          ? MewtionaryTheme.amber.withValues(alpha: .25)
                          : Colors.grey.shade200,
                      child: Text(
                        badge.unlocked ? badge.definition.icon : '🔒',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    title: Text(
                      badge.definition.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: badge.unlocked
                            ? MewtionaryTheme.navy
                            : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      '${badge.definition.banglaTitle}\n'
                      '${badge.definition.description}',
                    ),
                    isThreeLine: true,
                    trailing: badge.unlocked
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          )
                        : null,
                  ),
                ),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Coins বর্তমানে achievement currency। '
                    'কোনো real-money purchase বা gambling feature নেই।',
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 14,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                color: MewtionaryTheme.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
