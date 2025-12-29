import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/dependency_injection.dart';
import 'package:mescat/features/spaces/widgets/public_space_card.dart';

class ExploreSpacePage extends StatefulWidget {
  const ExploreSpacePage({super.key});

  @override
  State<ExploreSpacePage> createState() => _ExploreSpacePageState();
}

class _ExploreSpacePageState extends State<ExploreSpacePage> {
  Client get client => getIt<Client>();
  final List<PublishedRoomsChunk> _displayedSpaces = [];

  String? nextBatchToken;
  String? prevBatchToken;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _firstLoadSpaces();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Load more spaces when reaching the bottom
        if (nextBatchToken != null) {
          _loadSpaces(since: nextBatchToken);
        }
        //
      }
    });
  }

  @override
  void didUpdateWidget(covariant ExploreSpacePage oldWidget) {
    _loadSpaces();
    super.didUpdateWidget(oldWidget);
  }

  bool loading = true;

  void _firstLoadSpaces() async {
    await _loadSpaces();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadSpaces({String? since}) async {
    final publicSpaces = await client.getPublicRooms(limit: 20, since: since);
    final allSpaces = publicSpaces.chunk;

    if (mounted) {
      setState(() {
        nextBatchToken = publicSpaces.nextBatch;
        prevBatchToken = publicSpaces.prevBatch;
      });
    }

    setState(() {
      if (since == null) {
        _displayedSpaces.clear();
      }
      _displayedSpaces.addAll(allSpaces);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Public Spaces'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_displayedSpaces.length} ${_displayedSpaces.length == 1 ? 'space' : 'spaces'} loaded',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
          if (loading)
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              backgroundColor: theme.colorScheme.onSurface.withAlpha(30),
            )
          else
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
            color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
          ),
          const SizedBox(height: 16),
          Text(
            'No spaces found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacesGrid(bool isDesktop) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop
            ? 3
            : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _displayedSpaces.length,
      itemBuilder: (context, index) {
        return PublicSpaceCard(space: _displayedSpaces[index]);
      },
    );
  }
}
