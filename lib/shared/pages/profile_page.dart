import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mescat/features/authentication/blocs/auth_bloc.dart';
import 'package:mescat/shared/widgets/mc_image.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<MescatBloc, MescatStatus>(
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;
          final isCurrentUser = user.userId == userId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 64,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 64)
                      : McImage(uri: user.avatarUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  isCurrentUser && user.displayName != null
                      ? user.displayName!
                      : 'User Profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  userId,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                if (isCurrentUser) ...[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Security'),
                    onTap: () {
                      // TODO: Navigate to security settings
                    },
                  ),
                ],
                if (!isCurrentUser) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Send message
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Send Message'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Block user
                    },
                    icon: const Icon(Icons.block),
                    label: const Text('Block User'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
