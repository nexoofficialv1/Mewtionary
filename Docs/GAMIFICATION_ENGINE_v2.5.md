# Mewtionary Gamification Engine v2.5

## Reward model

Learning activities can award:
- XP
- offline achievement coins
- consecutive-day streak progress
- badges

Every reward source uses a unique `(source_type, source_id)` key. Replaying the same activity remains possible, but the same reward cannot be collected repeatedly.

## Levels

A learner gains one level for each 100 XP:

```text
level = 1 + total_xp / 100
```

The rewards are educational progress markers. Coins have no real-money value, cannot be purchased and are not used for gambling.

## Badge rules

The bundled badge engine supports thresholds for:
- XP
- coins
- streak
- successful games
- successful listening exercises
- completed story adventures
