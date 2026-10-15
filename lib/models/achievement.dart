class Achievement {
  final String id;
  final String title;
  final String description;
  final int target;
  final int rewardCoins;
  final String iconName;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.rewardCoins,
    required this.iconName,
  });

  static const List<Achievement> defaults = [
    Achievement(
      id: 'first_clear',
      title: 'First Step',
      description: 'Clear your first puzzle level',
      target: 1,
      rewardCoins: 50,
      iconName: 'flag',
    ),
    Achievement(
      id: 'ten_levels',
      title: 'Pathfinder',
      description: 'Clear 10 puzzle levels',
      target: 10,
      rewardCoins: 100,
      iconName: 'explore',
    ),
    Achievement(
      id: 'flawless_five',
      title: 'Untouchable',
      description: 'Complete 5 levels without losing a single heart',
      target: 5,
      rewardCoins: 150,
      iconName: 'favorite',
    ),
    Achievement(
      id: 'fifty_levels',
      title: 'Puzzle Master',
      description: 'Clear 50 puzzle levels',
      target: 50,
      rewardCoins: 300,
      iconName: 'military_tech',
    ),
    Achievement(
      id: 'hundred_arrows',
      title: 'Arrow Sweeper',
      description: 'Successfully slide off 100 arrows',
      target: 100,
      rewardCoins: 100,
      iconName: 'navigation',
    ),
    Achievement(
      id: 'hint_saver',
      title: 'Intuitive Mind',
      description: 'Clear 10 levels without using hints',
      target: 10,
      rewardCoins: 200,
      iconName: 'lightbulb',
    ),
  ];
}
