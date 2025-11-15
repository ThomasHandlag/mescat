import 'package:flutter/material.dart';
import 'package:mescat/features/spaces/models/public_space_model.dart';
import 'package:mescat/features/spaces/widgets/public_space_card.dart';
import 'package:mescat/features/spaces/widgets/space_search_bar.dart';
import 'package:mescat/features/spaces/widgets/space_tag_chip.dart';

class ExploreSpacePage extends StatefulWidget {
  const ExploreSpacePage({super.key});

  @override
  State<ExploreSpacePage> createState() => _ExploreSpacePageState();
}

class _ExploreSpacePageState extends State<ExploreSpacePage> {
  List<PublicSpaceModel> _displayedSpaces = MockPublicSpaces.spaces;
  String _searchQuery = '';
  String? _selectedTag;

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _updateDisplayedSpaces();
    });
  }

  void _handleTagFilter(String? tag) {
    setState(() {
      _selectedTag = tag;
      _updateDisplayedSpaces();
    });
  }

  void _updateDisplayedSpaces() {
    List<PublicSpaceModel> spaces = MockPublicSpaces.spaces;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      spaces = MockPublicSpaces.searchSpaces(_searchQuery);
    }

    // Apply tag filter
    if (_selectedTag != null) {
      spaces = spaces.where((space) => space.tags.contains(_selectedTag)).toList();
    }

    _displayedSpaces = spaces;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedTag: _selectedTag,
        onTagSelected: (tag) {
          Navigator.pop(context);
          _handleTagFilter(tag);
        },
      ),
    );
  }

  void _handleSpaceTap(PublicSpaceModel space) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining ${space.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Public Spaces'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          SpaceSearchBar(
            onSearchChanged: _handleSearch,
            onFilterTap: _showFilterDialog,
          ),

          // Active filter chip
          if (_selectedTag != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filtered by:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SpaceTagChip(
                    tag: _selectedTag!,
                    onTap: () => _handleTagFilter(null),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _handleTagFilter(null),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_displayedSpaces.length} ${_displayedSpaces.length == 1 ? 'space' : 'spaces'} found',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Spaces grid
          Expanded(
            child: _displayedSpaces.isEmpty
                ? _buildEmptyState()
                : _buildSpacesGrid(isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No spaces found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacesGrid(bool isDesktop) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _displayedSpaces.length,
      itemBuilder: (context, index) {
        return PublicSpaceCard(
          space: _displayedSpaces[index],
          onTap: () => _handleSpaceTap(_displayedSpaces[index]),
        );
      },
    );
  }
}

/// Filter dialog for selecting tags
class _FilterDialog extends StatelessWidget {
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;

  const _FilterDialog({
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allTags = MockPublicSpaces.getAllTags();
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Filter by Category'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Clear filter option
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('All Categories'),
              trailing: selectedTag == null
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => onTagSelected(null),
            ),
            const Divider(),
            // Tag options
            ...allTags.map((tag) {
              final isSelected = selectedTag == tag;
              return ListTile(
                leading: Icon(
                  _getTagIcon(tag),
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
                title: Text(tag),
                trailing: isSelected
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () => onTagSelected(tag),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getTagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'gaming':
        return Icons.sports_esports;
      case 'technology':
      case 'programming':
        return Icons.code;
      case 'art':
      case 'creative':
      case 'design':
        return Icons.palette;
      case 'music':
      case 'audio':
        return Icons.music_note;
      case 'anime':
      case 'manga':
        return Icons.movie;
      case 'education':
      case 'study':
      case 'academic':
        return Icons.school;
      case 'fitness':
      case 'health':
      case 'wellness':
        return Icons.fitness_center;
      case 'cooking':
      case 'food':
      case 'recipes':
        return Icons.restaurant;
      case 'movies':
      case 'tv shows':
      case 'entertainment':
        return Icons.movie_creation;
      case 'photography':
      case 'visual':
        return Icons.camera_alt;
      case 'science':
      case 'research':
        return Icons.science;
      case 'books':
      case 'reading':
      case 'literature':
        return Icons.menu_book;
      default:
        return Icons.tag;
    }
  }
}

