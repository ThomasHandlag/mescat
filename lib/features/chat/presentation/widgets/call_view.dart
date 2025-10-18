import 'package:flutter/material.dart';

class CallView extends StatefulWidget {
  const CallView({super.key});

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() => _isHovered = true);
      },
      onExit: (event) {
        setState(() => _isHovered = false);
      },
      child: Container(
        child: Stack(
          children: [
            _buildVideoCallView(),
            if (_isHovered) _buildCallControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCallView() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: 4, // Example: 4 participants
        itemBuilder: (context, index) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Text(
                'Participant ${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 0.1,
            offset: Offset(0, 0.1),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up),
                    Text('Call chat', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chat_bubble),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
                IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
                IconButton(icon: const Icon(Icons.call_end), onPressed: () {}),
                IconButton(icon: const Icon(Icons.screen_share), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
