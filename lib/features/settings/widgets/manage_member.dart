import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ManageMember extends StatefulWidget {
  const ManageMember({super.key, required this.room});

  final Room room;

  @override
  State<ManageMember> createState() => _MangeMemberState();
}

class _MangeMemberState extends State<ManageMember> {
  final List<String> _selectedUsers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _kickUsers() async {
    if (_selectedUsers.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Members'),
        content: Text(
          'Are you sure you want to remove ${_selectedUsers.length} member(s) from this room?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      for (final userId in _selectedUsers) {
        await widget.room.kick(userId);
      }
      setState(() {
        _selectedUsers.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Members removed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing members: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _banUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ban Member'),
        content: Text(
          'Are you sure you want to ban ${user.displayName ?? user.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Ban'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.room.ban(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.displayName} has been banned')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error banning user: $e')));
      }
    }
  }

  Future<void> _changeUserRole(User user) async {
    final currentPowerLevel = user.powerLevel;
    final newPowerLevel = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change role for ${user.displayName ?? user.id}'),
        content: RadioGroup(
          onChanged: (value) => Navigator.of(context).pop(value),
          groupValue: currentPowerLevel,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(title: Text('User'), value: 0),
              RadioListTile<int>(title: Text('Moderator'), value: 50),
              RadioListTile<int>(title: Text('Admin'), value: 100),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newPowerLevel == null || newPowerLevel == currentPowerLevel) return;

    try {
      await widget.room.setPower(user.id, newPowerLevel);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User role updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating role: $e')));
      }
    }
  }

  void _toggleSelectAll(List<User> participants) {
    setState(() {
      if (_selectedUsers.length == participants.length) {
        _selectedUsers.clear();
      } else {
        _selectedUsers.clear();
        _selectedUsers.addAll(participants.map((p) => p.id));
      }
    });
  }

  List<User> _filterParticipants(List<User> participants) {
    if (_searchQuery.isEmpty) return participants;

    return participants.where((user) {
      final displayName = user.displayName?.toLowerCase() ?? '';
      final userId = user.id.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return displayName.contains(query) || userId.contains(query);
    }).toList();
  }

  String _getRoleText(int powerLevel) {
    if (powerLevel >= 100) return 'Admin';
    if (powerLevel >= 50) return 'Moderator';
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Selection Actions Bar
        if (_selectedUsers.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Text(
                  '${_selectedUsers.length} selected',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isLoading ? null : _kickUsers,
                  tooltip: 'Remove selected',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedUsers.clear();
                    });
                  },
                  tooltip: 'Clear selection',
                ),
              ],
            ),
          ),

        // Members List
        Expanded(
          child: FutureBuilder<List<User>>(
            future: widget.room.requestParticipants(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text('Error loading members: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final participants = snapshot.data ?? [];
              final filteredParticipants = _filterParticipants(participants);

              if (filteredParticipants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No members found'
                            : 'No members match your search',
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Select All Checkbox
                  if (filteredParticipants.length > 1)
                    CheckboxListTile(
                      title: const Text('Select All'),
                      value:
                          _selectedUsers.length == filteredParticipants.length,
                      onChanged: (value) =>
                          _toggleSelectAll(filteredParticipants),
                      tristate:
                          _selectedUsers.isNotEmpty &&
                          _selectedUsers.length < filteredParticipants.length,
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredParticipants.length,
                      itemBuilder: (context, index) {
                        final participant = filteredParticipants[index];
                        final isSelected = _selectedUsers.contains(
                          participant.id,
                        );
                        final isAdmin = participant.powerLevel >= 100;
                        final canManage = widget.room.canKick && !isAdmin;

                        return ListTile(
                          leading: canManage
                              ? Checkbox.adaptive(
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedUsers.add(participant.id);
                                      } else {
                                        _selectedUsers.remove(participant.id);
                                      }
                                    });
                                  },
                                )
                              : null,
                          title: Text(
                            participant.displayName ?? participant.id,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                          subtitle: Text(
                            '${participant.id} • ${_getRoleText(participant.powerLevel)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: canManage
                              ? PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    switch (value) {
                                      case 'role':
                                        await _changeUserRole(participant);
                                        setState(() {});
                                        break;
                                      case 'ban':
                                        await _banUser(participant);
                                        setState(() {});
                                        break;
                                      case 'kick':
                                        await widget.room.kick(participant.id);
                                        setState(() {});
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'role',
                                      child: Row(
                                        children: [
                                          Icon(Icons.admin_panel_settings),
                                          SizedBox(width: 8),
                                          Text('Change Role'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'kick',
                                      child: Row(
                                        children: [
                                          Icon(Icons.remove_circle_outline),
                                          SizedBox(width: 8),
                                          Text('Remove'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'ban',
                                      child: Row(
                                        children: [
                                          Icon(Icons.block, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text(
                                            'Ban',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : isAdmin
                              ? const Chip(
                                  label: Text('Admin'),
                                  avatar: Icon(
                                    Icons.admin_panel_settings,
                                    size: 16,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                )
                              : null,
                          selected: isSelected,
                          onTap: canManage
                              ? () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedUsers.remove(participant.id);
                                    } else {
                                      _selectedUsers.add(participant.id);
                                    }
                                  });
                                }
                              : null,
                          onLongPress: canManage
                              ? () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedUsers.remove(participant.id);
                                    } else {
                                      _selectedUsers.add(participant.id);
                                    }
                                  });
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
