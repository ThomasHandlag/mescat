import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/shared/util/mc_dialog.dart';
import 'package:mescat/shared/widgets/input_field.dart';

class ManageGeneral extends StatefulWidget {
  final Room room;

  const ManageGeneral({super.key, required this.room});

  @override
  State<ManageGeneral> createState() => _ManageGeneralState();
}

class _ManageGeneralState extends State<ManageGeneral> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _topicController;

  // Store original values for change comparison
  late final String _originalName;
  late final String _originalTopic;
  late final bool _originalEncrypted;

  // Current state values
  late bool _isEncrypted;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    // Initialize original values from room
    _originalName = widget.room.name;
    _originalTopic = widget.room.topic;
    _originalEncrypted = widget.room.encrypted;

    // Initialize controllers with original values
    _nameController = TextEditingController(text: _originalName);
    _topicController = TextEditingController(text: _originalTopic);

    // Initialize current state
    _isEncrypted = _originalEncrypted;

    // Add listeners for automatic change detection
    _nameController.addListener(_onFormChanged);
    _topicController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    // Check if any field has changed from original
    final hasChanges = _detectChanges();

    // Only update state if the change status is different
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  bool _detectChanges() {
    return _nameController.text.trim() != _originalName ||
        _topicController.text.trim() != _originalTopic ||
        _isEncrypted != _originalEncrypted;
  }

  String? _validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room name is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Room name must be at least 3 characters';
    }

    if (trimmed.length > 50) {
      return 'Room name must not exceed 50 characters';
    }

    return null;
  }

  String? _validateTopic(String? value) {
    if (value != null && value.length > 500) {
      return 'Topic must not exceed 500 characters';
    }
    return null;
  }

  Future<void> _saveChanges() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus to dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
      final changes = <String, dynamic>{};

      // Collect changes
      final newName = _nameController.text.trim();
      if (newName != _originalName) {
        changes['name'] = newName;
        // await widget.room.setName(newName);
      }

      final newTopic = _topicController.text.trim();
      if (newTopic != _originalTopic) {
        changes['topic'] = newTopic;
        // await widget.room.setTopic(newTopic);
      }

      if (_isEncrypted != _originalEncrypted && !_originalEncrypted) {
        changes['encryption'] = _isEncrypted;
        // await widget.room.enableEncryption();
      }

      // TODO: Implement actual save logic here
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // If we reach here, save was successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved ${changes.length} change(s) successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form state by reinitializing with new values
        _updateOriginalValues(newName, newTopic, _isEncrypted);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(label: 'Retry', onPressed: _saveChanges),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _updateOriginalValues(String name, String topic, bool encrypted) {
    // Update internal tracking without modifying late finals
    // This simulates the values being updated in the backend
    setState(() {
      _hasChanges = false;
    });
  }

  Future<bool> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'Are you sure you want to discard all unsaved changes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  Future<void> _resetChanges() async {
    // Ask for confirmation if there are significant changes
    if (_hasChanges) {
      final shouldReset = await _confirmReset();
      if (!shouldReset) return;
    }

    setState(() {
      // Reset text controllers to original values
      _nameController.text = _originalName;
      _topicController.text = _originalTopic;

      // Reset state values
      _isEncrypted = _originalEncrypted;
      _hasChanges = false;
    });

    // Clear any validation errors
    _formKey.currentState?.reset();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes discarded'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _setGuestAccess(GuestAccess? guestAccess) async {
    if (guestAccess == null) return;
    try {
      await widget.room.setGuestAccess(guestAccess);
    } catch (e, s) {
      Logs().w('Unable to change guest access', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to change guest access: $e')),
        );
      }
    }
  }

  void _setHistoryVisibility(HistoryVisibility? historyVisibility) async {
    if (historyVisibility == null) return;

    try {
      await widget.room.setHistoryVisibility(historyVisibility);
    } catch (e, s) {
      Logs().w('Unable to change history visibility', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to change history visibility')),
        );
      }
    }
  }

  Set<Room> get knownSpaceParents => {
    ...widget.room.client.rooms.where(
      (space) =>
          space.isSpace &&
          space.spaceChildren.any((child) => child.roomId == widget.room.id),
    ),
    ...widget.room.spaceParents
        .map((parent) => widget.room.client.getRoomById(parent.roomId ?? ''))
        .whereType<Room>(),
  };

  void _setJoinRules(JoinRules? newJoinRules) async {
    if (newJoinRules == null) return;
    try {
      await widget.room.setJoinRules(
        newJoinRules,
        allowConditionRoomIds:
            {
              JoinRules.restricted,
              JoinRules.knockRestricted,
            }.contains(newJoinRules)
            ? knownSpaceParents.map((parent) => parent.id).toList()
            : null,
      );
    } catch (e, s) {
      Logs().w('Unable to change join rules', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to change join rules')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _nameController.removeListener(_onFormChanged);
    _topicController.removeListener(_onFormChanged);

    // Dispose controllers
    _nameController.dispose();
    _topicController.dispose();

    super.dispose();
  }

  void _onSubEncryptedChanged(_) async {
    if (widget.room.joinRules == JoinRules.public) {
      showOkAlertDialog(context: context, title: 'Can not Enable Encryption');
      return;
    }

    if (!widget.room.canChangeStateEvent(EventTypes.Encryption)) {
      showOkAlertDialog(
        context: context,
        title: 'Can not Enable Encryption',
        message:
            'You do not have permission to change encryption settings in this room.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enable Encryption?'),
          content: const Text(
            'Enabling end-to-end encryption cannot be undone. '
            'Are you sure you want to enable encryption for this room?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.room.enableEncryption();
      setState(() {
        _isEncrypted = true;
        _onFormChanged();
      });
    }
  }

  void _leaveRoom() async {
    final result = await showOkAlertDialog(
      context: context,
      title: 'Leave Room',
      message: 'Are you sure you want to leave this room?',
      okLabel: 'Leave',
    );

    if (result == OkCancelResult.ok) {
      await widget.room.leave();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final altAliases =
        widget.room
            .getState(EventTypes.RoomCanonicalAlias)
            ?.content
            .tryGetList<String>('alt_aliases') ??
        [];
    return Form(
      key: _formKey,
      onChanged: _onFormChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SizedBox(
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputField(
                    padding: const EdgeInsets.all(4),
                    controller: _nameController,
                    enabled: !_isSaving,
                    maxLength: 50,
                    validator: _validateRoomName,
                    decoration: InputDecoration(
                      labelText: 'Room Name',
                      hintText: 'Enter room name',
                      border: const OutlineInputBorder(),
                      suffixIcon: _nameController.text != _originalName
                          ? const Icon(Icons.edit, size: 16)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(4.0),
                  child: InputField(
                    padding: const EdgeInsets.all(4.0),
                    controller: _topicController,
                    enabled: !_isSaving,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    maxLength: 500,
                    textAlignVertical: TextAlignVertical.top,
                    textAlign: TextAlign.start,
                    validator: _validateTopic,
                    decoration: InputDecoration(
                      labelText: 'Topic',
                      hintText: 'Enter room topic or description',
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                      suffixIcon: _topicController.text != _originalTopic
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 80),
                              child: Icon(Icons.edit, size: 16),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: const Text('End-to-End Encryption'),
                    subtitle: Text(
                      _originalEncrypted
                          ? 'Encryption is enabled and cannot be disabled'
                          : _isEncrypted
                          ? 'Messages will be encrypted (cannot be undone)'
                          : 'Enable encryption for secure messaging',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isEncrypted != _originalEncrypted
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    secondary: Icon(
                      _isEncrypted ? Icons.lock : Icons.lock_open,
                      color: _isEncrypted
                          ? Colors.green
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    value: _isEncrypted,
                    onChanged: _originalEncrypted || _isSaving
                        ? null
                        : _onSubEncryptedChanged,
                  ),
                ),
                const SizedBox(height: 8),
                if (_hasChanges)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'You have unsaved changes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _isSaving ? null : _resetChanges,
                                icon: const Icon(Icons.undo, size: 18),
                                label: const Text('Discard'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: _isSaving ? null : _saveChanges,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.save, size: 18),
                                label: Text(
                                  _isSaving ? 'Saving...' : 'Save Changes',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const ListTile(title: Text('Chats Visibility')),
                RadioGroup(
                  groupValue: widget.room.historyVisibility,
                  onChanged: _setHistoryVisibility,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final historyVisibility in HistoryVisibility.values)
                        RadioListTile<HistoryVisibility>.adaptive(
                          title: Text(historyVisibility.name),
                          value: historyVisibility,
                        ),
                      const RadioListTile.adaptive(
                        value: null,
                        title: Text('Any one can see'),
                      ),
                    ],
                  ),
                ),
                const ListTile(title: Text('Who can join this room?')),
                RadioGroup(
                  groupValue: widget.room.joinRules,
                  onChanged: _setJoinRules,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final joinRule in JoinRules.values)
                        if (joinRule != JoinRules.private)
                          RadioListTile<JoinRules>.adaptive(
                            enabled: widget.room.canChangeJoinRules,
                            title: Text(
                              joinRule == JoinRules.public
                                  ? 'Anyone can join'
                                  : joinRule.name,
                            ),
                            value: joinRule,
                          ),
                    ],
                  ),
                ),
                if ({
                  JoinRules.public,
                  JoinRules.knock,
                }.contains(widget.room.joinRules)) ...[
                  const ListTile(
                    title: Text(
                      'Guest Access',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  RadioGroup(
                    groupValue: widget.room.guestAccess,
                    onChanged: _setGuestAccess,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final guestAccess in GuestAccess.values)
                          RadioListTile<GuestAccess>.adaptive(
                            enabled: widget.room.canChangeGuestAccess,
                            title: Text(
                              guestAccess == GuestAccess.canJoin
                                  ? 'Guests can join'
                                  : 'Guests cannot join',
                            ),
                            value: guestAccess,
                          ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Public addresses',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_outlined),
                      tooltip: 'Add Public Address',
                      onPressed: () {},
                    ),
                  ),
                  if (widget.room.canonicalAlias.isNotEmpty)
                    _AliasListTile(
                      alias: widget.room.canonicalAlias,
                      onDelete:
                          widget.room.canChangeStateEvent(
                            EventTypes.RoomCanonicalAlias,
                          )
                          ? () => () {}
                          : null,
                      isCanonicalAlias: true,
                    ),
                  for (final alias in altAliases)
                    _AliasListTile(
                      alias: alias,
                      onDelete:
                          widget.room.canChangeStateEvent(
                            EventTypes.RoomCanonicalAlias,
                          )
                          ? () => () {}
                          : null,
                    ),
                  FutureBuilder(
                    future: widget.room.client.getLocalAliases(widget.room.id),
                    builder: (context, snapshot) {
                      final localAddresses = snapshot.data;
                      if (localAddresses == null) {
                        return const SizedBox.shrink();
                      }
                      localAddresses.remove(widget.room.canonicalAlias);
                      localAddresses.removeWhere(
                        (alias) => altAliases.contains(alias),
                      );
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: localAddresses
                            .map(
                              (alias) => _AliasListTile(
                                alias: alias,
                                published: false,
                                onDelete: () => () {},
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  FutureBuilder(
                    future: widget.room.client.getRoomVisibilityOnDirectory(
                      widget.room.id,
                    ),
                    builder: (context, snapshot) => SwitchListTile.adaptive(
                      value: snapshot.data == Visibility.public,
                      title: Text(
                        'Chat can be discovered via search on ${widget.room.client.userID!.domain!}',
                      ),
                      onChanged: (value) {},
                    ),
                  ),
                ],
                ListTile(
                  title: const Text('Global Room ID'),
                  subtitle: SelectableText(widget.room.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.room.id));
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Room Version'),
                  subtitle: SelectableText(
                    widget.room
                            .getState(EventTypes.RoomCreate)!
                            .content
                            .tryGet<String>('room_version') ??
                        'Unknown',
                  ),
                  trailing: widget.room.canSendEvent(EventTypes.RoomTombstone)
                      ? IconButton(
                          icon: const Icon(Icons.upgrade_outlined),
                          onPressed: () {},
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text(
                    'Leave Room',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.logout, color: Colors.red),
                  onTap: () {
                    _leaveRoom();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AliasListTile extends StatelessWidget {
  const _AliasListTile({
    required this.alias,
    required this.onDelete,
    this.isCanonicalAlias = false,
    this.published = true,
  });

  final String alias;
  final void Function()? onDelete;
  final bool isCanonicalAlias;
  final bool published;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: isCanonicalAlias
          ? const Icon(Icons.star)
          : const Icon(Icons.link_outlined),
      title: InkWell(
        onTap: () {},
        child: SelectableText(
          alias,
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.primary,
            color: theme.colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ),
      trailing: onDelete != null
          ? IconButton(
              color: theme.colorScheme.error,
              icon: const Icon(Icons.delete_outlined),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
