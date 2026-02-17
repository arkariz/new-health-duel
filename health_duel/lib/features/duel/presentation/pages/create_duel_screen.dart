import 'package:flutter/material.dart';

/// Create Duel Screen - Challenge a friend to a duel
///
/// Features:
/// - Friend selection from list
/// - Preview duel details
/// - Confirm and send challenge
///
/// Flow:
/// 1. User selects friend from list
/// 2. Preview shows duel details (24-hour competition)
/// 3. User confirms to create duel
/// 4. Navigates back on success
class CreateDuelScreen extends StatefulWidget {
  final String currentUserId;

  const CreateDuelScreen({
    required this.currentUserId,
    super.key,
  });

  @override
  State<CreateDuelScreen> createState() => _CreateDuelScreenState();
}

class _CreateDuelScreenState extends State<CreateDuelScreen> {
  String? _selectedFriendId;

  void _createDuel() {
    if (_selectedFriendId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a friend to challenge'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Implement duel creation via BLoC
    /*
    context.read<CreateDuelBloc>().add(
      CreateDuelRequested(
        challengerId: widget.currentUserId,
        challengedId: _selectedFriendId!,
      ),
    );
    */

    // Temporary success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duel challenge sent!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Duel Challenge'),
      ),
      body: Column(
        children: [
          // Instructions card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'How Duels Work',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Challenge a friend to a 24-hour step competition\n'
                    '• Once accepted, the duel starts immediately\n'
                    '• Both participants compete to walk the most steps\n'
                    '• The winner is determined after 24 hours',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Friend selection section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Friend to Challenge',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Friend list
          Expanded(
            child: _buildFriendList(),
          ),

          // Create button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedFriendId != null ? _createDuel : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Challenge'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendList() {
    // TODO: Replace with BlocBuilder for real friend data
    // This is a placeholder implementation
    final mockFriends = [
      _Friend(id: 'friend1', name: 'John Doe', photoUrl: null),
      _Friend(id: 'friend2', name: 'Jane Smith', photoUrl: null),
      _Friend(id: 'friend3', name: 'Bob Johnson', photoUrl: null),
      _Friend(id: 'friend4', name: 'Alice Williams', photoUrl: null),
    ];

    if (mockFriends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Friends Yet',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Add friends to challenge them to duels!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: mockFriends.length,
      itemBuilder: (context, index) {
        final friend = mockFriends[index];
        final isSelected = _selectedFriendId == friend.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                friend.name.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            title: Text(friend.name),
            subtitle: const Text('Tap to challenge'),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : const Icon(Icons.radio_button_unchecked),
            selected: isSelected,
            onTap: () {
              setState(() {
                _selectedFriendId = friend.id;
              });
            },
          ),
        );
      },
    );

    // Real implementation would be:
    /*
    return BlocBuilder<FriendListBloc, FriendListState>(
      builder: (context, state) {
        if (state is FriendListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FriendListError) {
          return Center(
            child: Text(
              'Error loading friends: ${state.message}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state is FriendListLoaded) {
          final friends = state.friends;

          if (friends.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary.with(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Friends Yet',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add friends to challenge them to duels!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final isSelected = _selectedFriendId == friend.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.photoUrl != null
                        ? NetworkImage(friend.photoUrl!)
                        : null,
                    child: friend.photoUrl == null
                        ? Text(
                            friend.name.substring(0, 1).toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        : null,
                  ),
                  title: Text(friend.name),
                  subtitle: Text('Tap to challenge'),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.radio_button_unchecked),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedFriendId = friend.id;
                    });
                  },
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
    */
  }
}

/// Mock friend model for placeholder
class _Friend {
  final String id;
  final String name;
  final String? photoUrl;

  _Friend({
    required this.id,
    required this.name,
    this.photoUrl,
  });
}
