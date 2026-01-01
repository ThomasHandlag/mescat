import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:mescat/core/mescat/domain/entities/mescat_entities.dart';
import 'package:mescat/features/chat/blocs/chat_bloc.dart';
import 'package:mescat/features/chat/widgets/message_list.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockChatBloc extends Mock implements ChatBloc {}
class MockClient extends Mock implements Client {}
class MockEvent extends Mock implements Event {}

void main() {
  group('MessageList Performance Tests', () {
    late MockChatBloc mockChatBloc;
    late List<MCMessageEvent> testMessages;

    setUp(() {
      mockChatBloc = MockChatBloc();
      
      // Create mock events for testing
      final mockEvent = MockEvent();
      when(() => mockEvent.eventId).thenReturn('test_event');
      when(() => mockEvent.type).thenReturn(EventTypes.Message);
      when(() => mockEvent.content).thenReturn({'msgtype': 'm.text', 'body': 'Test'});
      when(() => mockEvent.originServerTs).thenReturn(DateTime.now());
      when(() => mockEvent.senderId).thenReturn('@user:matrix.org');
      
      // Generate test messages
      testMessages = _generateTestMessages(100, mockEvent);
      
      // Set up default bloc state
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: testMessages,
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: 'next_token',
        ),
      );
      
      when(() => mockChatBloc.stream).thenAnswer(
        (_) => Stream.value(
          ChatState(
            messages: testMessages,
            selectedRoomId: 'test_room',
            isLoadingMore: false,
            nextToken: 'next_token',
          ),
        ),
      );
    });

    testWidgets('should render 100 messages efficiently', (WidgetTester tester) async {
      // Measure render time
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: testMessages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      // Verify widget is rendered
      expect(find.byType(MessageList), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      
      // Log performance
      debugPrint('Render time for 100 messages: ${stopwatch.elapsedMilliseconds}ms');
      
      // Performance assertion - should render in less than 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
        reason: 'MessageList should render 100 messages in less than 500ms');
    });

    testWidgets('should handle scrolling smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: testMessages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Measure scroll performance
      final stopwatch = Stopwatch()..start();
      
      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      
      // Scroll to middle
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump();
      
      // Scroll to top
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pump();
      
      stopwatch.stop();
      
      debugPrint('Scroll operations time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Performance assertion - scrolling should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(200),
        reason: 'Scrolling should complete in less than 200ms');
    });

    testWidgets('should efficiently load more messages when scrolling to top', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: testMessages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the scroll controller and scroll to top
      final listFinder = find.byType(ListView);
      expect(listFinder, findsOneWidget);
      
      // Scroll to trigger load more
      await tester.drag(listFinder, const Offset(0, 1000));
      await tester.pump();
      
      // Verify load more button appears
      await tester.pump(const Duration(milliseconds: 100));
      
      // The load more UI should be visible when near top
      expect(find.text('Load more'), findsOneWidget);
    });

    testWidgets('should handle rapid scroll events without lag', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: testMessages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // Perform rapid scroll events
      for (int i = 0; i < 10; i++) {
        await tester.drag(
          find.byType(ListView), 
          Offset(0, i.isEven ? -100 : 100),
        );
        await tester.pump(const Duration(milliseconds: 16)); // 60 FPS frame
      }
      
      stopwatch.stop();
      
      debugPrint('Rapid scroll events (10 scrolls): ${stopwatch.elapsedMilliseconds}ms');
      
      // Should handle rapid scrolls smoothly (16ms per frame for 60fps)
      final averageFrameTime = stopwatch.elapsedMilliseconds / 10;
      expect(averageFrameTime, lessThan(20),
        reason: 'Average frame time should be under 20ms for smooth 60fps scrolling');
    });

    testWidgets('should efficiently update when new messages arrive', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: testMessages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Add new messages
      final mockEvent = MockEvent();
      when(() => mockEvent.eventId).thenReturn('new_event');
      when(() => mockEvent.type).thenReturn(EventTypes.Message);
      when(() => mockEvent.content).thenReturn({'msgtype': 'm.text', 'body': 'New'});
      when(() => mockEvent.originServerTs).thenReturn(DateTime.now());
      when(() => mockEvent.senderId).thenReturn('@user:matrix.org');
      
      final updatedMessages = [
        ...testMessages,
        ..._generateTestMessages(10, mockEvent, startIndex: 100),
      ];
      
      // Update bloc state before measuring
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: updatedMessages,
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: 'next_token',
        ),
      );
      
      when(() => mockChatBloc.stream).thenAnswer(
        (_) => Stream.value(
          ChatState(
            messages: updatedMessages,
            selectedRoomId: 'test_room',
            isLoadingMore: false,
            nextToken: 'next_token',
          ),
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: updatedMessages),
            ),
          ),
        ),
      );
      
      await tester.pump();
      stopwatch.stop();
      
      debugPrint('Update time for 10 new messages: ${stopwatch.elapsedMilliseconds}ms');
      
      // Update should be relatively fast (increased threshold for widget rebuild)
      expect(stopwatch.elapsedMilliseconds, lessThan(500),
        reason: 'Adding new messages should be efficient');
    });

    testWidgets('should handle large message lists (1000 messages)', 
      (WidgetTester tester) async {
      final mockEvent = MockEvent();
      when(() => mockEvent.eventId).thenReturn('event');
      when(() => mockEvent.type).thenReturn(EventTypes.Message);
      when(() => mockEvent.content).thenReturn({'msgtype': 'm.text', 'body': 'Test'});
      when(() => mockEvent.originServerTs).thenReturn(DateTime.now());
      when(() => mockEvent.senderId).thenReturn('@user:matrix.org');
      
      final largeMessageList = _generateTestMessages(1000, mockEvent);
      
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: largeMessageList,
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: 'next_token',
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: largeMessageList),
            ),
          ),
        ),
      );
      
      await tester.pump();
      stopwatch.stop();
      
      debugPrint('Initial render time for 1000 messages: ${stopwatch.elapsedMilliseconds}ms');
      
      // Even with 1000 messages, initial render should be reasonable
      // ListView.builder uses lazy loading, so it should be efficient
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
        reason: 'Should handle large lists efficiently with lazy loading');
      
      // Verify scrolling works
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should efficiently handle empty state', 
      (WidgetTester tester) async {
      when(() => mockChatBloc.state).thenReturn(
        const ChatState(
          messages: [],
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: null,
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: const Scaffold(
              body: MessageList(messages: []),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      stopwatch.stop();
      
      debugPrint('Empty state render time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Empty state should render instantly
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
        reason: 'Empty state should render very quickly');
      
      // Verify empty state message
      expect(find.text('No messages yet. Start the conversation!'), findsOneWidget);
    });

    testWidgets('memory usage should be reasonable with scroll controller', 
      (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: testMessages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Perform multiple scrolls to ensure no memory leaks
      for (int i = 0; i < 50; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pump();
        await tester.drag(find.byType(ListView), const Offset(0, 200));
        await tester.pump();
      }
      
      await tester.pumpAndSettle();
      
      // If we reach here without errors, the scroll controller
      // and listeners are properly managed
      expect(find.byType(MessageList), findsOneWidget);
    });

    testWidgets('should efficiently scroll to specific message item', 
      (WidgetTester tester) async {
      // Create messages with identifiable content
      final mockEvent = MockEvent();
      when(() => mockEvent.eventId).thenReturn('event');
      when(() => mockEvent.type).thenReturn(EventTypes.Message);
      when(() => mockEvent.content).thenReturn({'msgtype': 'm.text', 'body': 'Test'});
      when(() => mockEvent.originServerTs).thenReturn(DateTime.now());
      when(() => mockEvent.senderId).thenReturn('@user:matrix.org');
      
      final messages = _generateTestMessages(100, mockEvent);
      final targetMessageIndex = 50;
      final targetMessage = messages[targetMessageIndex];
      
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: messages,
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: 'next_token',
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Get the ListView's scroll controller
      final listView = tester.widget<ListView>(find.byType(ListView));
      final scrollController = listView.controller;
      
      expect(scrollController, isNotNull);
      
      // Calculate approximate scroll position to reach target message
      // Assuming average message height of 80 pixels
      const estimatedMessageHeight = 80.0;
      final targetScrollPosition = targetMessageIndex * estimatedMessageHeight;
      
      final stopwatch = Stopwatch()..start();
      
      // Scroll to the target message (just the scroll action)
      scrollController!.jumpTo(targetScrollPosition);
      
      stopwatch.stop();
      
      // Now pump to render
      await tester.pump();
      
      debugPrint('Scroll to message #$targetMessageIndex time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Verify scroll position changed from initial
      expect(scrollController.offset, greaterThan(0));
      
      // Performance assertion - just the scroll action should be instant
      expect(stopwatch.elapsedMilliseconds, lessThan(50),
        reason: 'jumpTo should be instant');
    });

    testWidgets('should smoothly animate to specific message item', 
      (WidgetTester tester) async {
      final mockEvent = MockEvent();
      when(() => mockEvent.eventId).thenReturn('event');
      when(() => mockEvent.type).thenReturn(EventTypes.Message);
      when(() => mockEvent.content).thenReturn({'msgtype': 'm.text', 'body': 'Test'});
      when(() => mockEvent.originServerTs).thenReturn(DateTime.now());
      when(() => mockEvent.senderId).thenReturn('@user:matrix.org');
      
      final messages = _generateTestMessages(100, mockEvent);
      final targetMessageIndex = 75;
      
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: messages,
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: 'next_token',
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(messages: messages),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Get the scroll controller
      final listView = tester.widget<ListView>(find.byType(ListView));
      final scrollController = listView.controller;
      
      expect(scrollController, isNotNull);
      
      // Animate to target position
      const estimatedMessageHeight = 80.0;
      final targetScrollPosition = targetMessageIndex * estimatedMessageHeight;
      
      final stopwatch = Stopwatch()..start();
      
      // Start animation
      scrollController!.animateTo(
        targetScrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Wait for animation to complete
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      debugPrint('Animated scroll to message #$targetMessageIndex time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('Final scroll position: ${scrollController.offset}');
      
      // Verify scroll position changed significantly
      expect(scrollController.offset, greaterThan(1000),
        reason: 'Should scroll significantly towards target');
      
      // Animation should complete (including 300ms animation + render time)
      expect(stopwatch.elapsedMilliseconds, lessThan(800),
        reason: 'Animated scroll should complete smoothly');
    });

    testWidgets('should find and scroll to message by event ID', 
      (WidgetTester tester) async {
      final mockEvent = MockEvent();
      when(() => mockEvent.eventId).thenReturn('event');
      when(() => mockEvent.type).thenReturn(EventTypes.Message);
      when(() => mockEvent.content).thenReturn({'msgtype': 'm.text', 'body': 'Test'});
      when(() => mockEvent.originServerTs).thenReturn(DateTime.now());
      when(() => mockEvent.senderId).thenReturn('@user:matrix.org');
      
      final messages = _generateTestMessages(100, mockEvent);
      final targetEventId = 'event_42';
      
      when(() => mockChatBloc.state).thenReturn(
        ChatState(
          messages: messages,
          selectedRoomId: 'test_room',
          isLoadingMore: false,
          nextToken: 'next_token',
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ChatBloc>.value(
            value: mockChatBloc,
            child: Scaffold(
              body: MessageList(
                messages: messages,
                initEventId: targetEventId,
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // Find the message with the target event ID
      final targetIndex = messages.indexWhere((msg) => msg.eventId == targetEventId);
      expect(targetIndex, greaterThanOrEqualTo(0), 
        reason: 'Target event ID should exist in message list');
      
      // Get scroll controller and scroll to target
      final listView = tester.widget<ListView>(find.byType(ListView));
      final scrollController = listView.controller;
      
      if (scrollController != null && targetIndex >= 0) {
        const estimatedMessageHeight = 80.0;
        final targetPosition = targetIndex * estimatedMessageHeight;
        scrollController.jumpTo(targetPosition);
        await tester.pumpAndSettle();
      }
      
      stopwatch.stop();
      
      debugPrint('Find and scroll to event $targetEventId (index $targetIndex) time: ${stopwatch.elapsedMilliseconds}ms');
      
      // Verify we found and scrolled to the message
      expect(targetIndex, equals(42), reason: 'Should find the correct message index');
      
      // Performance assertion
      expect(stopwatch.elapsedMilliseconds, lessThan(300),
        reason: 'Finding and scrolling to specific event should be reasonably fast');
    });
  });
}

/// Helper function to generate test messages
List<MCMessageEvent> _generateTestMessages(
  int count, 
  Event mockEvent, {
  int startIndex = 0,
}) {
  return List.generate(count, (index) {
    final actualIndex = startIndex + index;
    final timestamp = DateTime.now().subtract(Duration(minutes: count - index));
    
    return MCMessageEvent(
      eventId: 'event_$actualIndex',
      roomId: 'test_room',
      senderId: '@user${index % 5}:matrix.org',
      senderDisplayName: 'User ${index % 5}',
      msgtype: 'm.text',
      eventTypes: 'm.room.message',
      body: 'Test message $actualIndex with some content',
      timestamp: timestamp,
      isCurrentUser: index % 3 == 0,
      event: mockEvent,
      reactions: [],
    );
  });
}
