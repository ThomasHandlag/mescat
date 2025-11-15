/// Mock data model for public spaces exploration
class PublicSpaceModel {
  final String spaceId;
  final String name;
  final String description;
  final String? avatarUrl;
  final int memberCount;
  final int onlineCount;
  final List<String> tags;
  final bool isVerified;
  final bool isPartnered;

  const PublicSpaceModel({
    required this.spaceId,
    required this.name,
    required this.description,
    this.avatarUrl,
    required this.memberCount,
    required this.onlineCount,
    this.tags = const [],
    this.isVerified = false,
    this.isPartnered = false,
  });
}

/// Mock data for public spaces
class MockPublicSpaces {
  static final List<PublicSpaceModel> spaces = [
    const PublicSpaceModel(
      spaceId: '!gaming001:matrix.org',
      name: 'Gaming Community',
      description: 'A friendly community for gamers of all types. Discuss your favorite games, find teammates, and share your gaming moments!',
      memberCount: 12453,
      onlineCount: 2341,
      tags: ['Gaming', 'Community', 'Social'],
      isVerified: true,
    ),
    const PublicSpaceModel(
      spaceId: '!tech002:matrix.org',
      name: 'Tech Enthusiasts',
      description: 'Join us to discuss the latest in technology, programming, AI, and more. Share your projects and get help from the community.',
      memberCount: 8921,
      onlineCount: 1523,
      tags: ['Technology', 'Programming', 'AI'],
      isVerified: true,
      isPartnered: true,
    ),
    const PublicSpaceModel(
      spaceId: '!art003:matrix.org',
      name: 'Digital Artists Hub',
      description: 'A creative space for digital artists to showcase their work, get feedback, and collaborate on projects.',
      memberCount: 6789,
      onlineCount: 892,
      tags: ['Art', 'Creative', 'Design'],
    ),
    const PublicSpaceModel(
      spaceId: '!music004:matrix.org',
      name: 'Music Producers',
      description: 'Connect with other music producers, share your tracks, get feedback, and collaborate on new music.',
      memberCount: 5432,
      onlineCount: 745,
      tags: ['Music', 'Production', 'Audio'],
      isVerified: true,
    ),
    const PublicSpaceModel(
      spaceId: '!anime005:matrix.org',
      name: 'Anime & Manga',
      description: 'Discuss your favorite anime and manga series, share fan art, and connect with fellow otakus!',
      memberCount: 15678,
      onlineCount: 3421,
      tags: ['Anime', 'Manga', 'Entertainment'],
      isPartnered: true,
    ),
    const PublicSpaceModel(
      spaceId: '!study006:matrix.org',
      name: 'Study Together',
      description: 'A productive community for students. Study together, share resources, and help each other succeed.',
      memberCount: 4321,
      onlineCount: 678,
      tags: ['Education', 'Study', 'Academic'],
    ),
    const PublicSpaceModel(
      spaceId: '!fitness007:matrix.org',
      name: 'Fitness & Health',
      description: 'Stay motivated and achieve your fitness goals! Share workouts, nutrition tips, and progress updates.',
      memberCount: 7890,
      onlineCount: 1234,
      tags: ['Fitness', 'Health', 'Wellness'],
      isVerified: true,
    ),
    const PublicSpaceModel(
      spaceId: '!cooking008:matrix.org',
      name: 'Cooking & Recipes',
      description: 'Share your favorite recipes, cooking tips, and food photos. Learn from experienced cooks and chefs.',
      memberCount: 3456,
      onlineCount: 567,
      tags: ['Cooking', 'Food', 'Recipes'],
    ),
    const PublicSpaceModel(
      spaceId: '!movie009:matrix.org',
      name: 'Movie Buffs',
      description: 'Discuss movies, TV shows, and streaming content. Share recommendations and reviews with fellow cinephiles.',
      memberCount: 9876,
      onlineCount: 1876,
      tags: ['Movies', 'TV Shows', 'Entertainment'],
      isVerified: true,
    ),
    const PublicSpaceModel(
      spaceId: '!photography010:matrix.org',
      name: 'Photography Club',
      description: 'A community for photographers of all skill levels. Share your photos, learn new techniques, and get inspired.',
      memberCount: 5678,
      onlineCount: 891,
      tags: ['Photography', 'Art', 'Visual'],
    ),
    const PublicSpaceModel(
      spaceId: '!science011:matrix.org',
      name: 'Science & Research',
      description: 'Explore the wonders of science! Discuss discoveries, share research, and engage in scientific debates.',
      memberCount: 4567,
      onlineCount: 723,
      tags: ['Science', 'Research', 'Education'],
      isPartnered: true,
    ),
    const PublicSpaceModel(
      spaceId: '!books012:matrix.org',
      name: 'Book Club',
      description: 'A cozy space for book lovers. Discuss your current reads, share recommendations, and join reading challenges.',
      memberCount: 3890,
      onlineCount: 456,
      tags: ['Books', 'Reading', 'Literature'],
    ),
  ];

  /// Get spaces filtered by search query
  static List<PublicSpaceModel> searchSpaces(String query) {
    if (query.isEmpty) return spaces;
    
    final lowercaseQuery = query.toLowerCase();
    return spaces.where((space) {
      return space.name.toLowerCase().contains(lowercaseQuery) ||
          space.description.toLowerCase().contains(lowercaseQuery) ||
          space.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get spaces filtered by tag
  static List<PublicSpaceModel> getSpacesByTag(String tag) {
    return spaces.where((space) => space.tags.contains(tag)).toList();
  }

  /// Get all unique tags
  static List<String> getAllTags() {
    final Set<String> allTags = {};
    for (var space in spaces) {
      allTags.addAll(space.tags);
    }
    return allTags.toList()..sort();
  }
}
