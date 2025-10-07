# Mescat - Discord-like Chat Application

# Mescat - Discord-like Matrix Chat Application

A modern, Discord-inspired chat application built with Flutter using the Matrix protocol for decentralized, secure messaging.

## 🏗️ Architecture Overview

This application follows **Clean Architecture** principles with a feature-based folder structure, implementing the Matrix protocol for real-time communication.

### 📁 Project Structure

```
lib/
├── main.dart                          # App entry point with BLoC providers
├── dependency_injection.dart          # Dependency injection setup
├── chat_box_demo_page.dart           # Demo/testing page
│
├── core/                             # Core application utilities
│   ├── constants/
│   │   └── matrix_constants.dart    # Matrix protocol constants
│   ├── errors/
│   │   └── matrix_failures.dart     # Error handling classes
│   ├── matrix/
│   │   └── matrix_client.dart       # Matrix client singleton
│   ├── network/                     # Network utilities
│   ├── routes/                      # App routing
│   ├── themes/                      # App theming
│   └── utils/                       # General utilities
│
├── features/                        # Feature modules
│   ├── authentication/             # User authentication
│   ├── chat/                       # Chat functionality
│   ├── file_sharing/              # File upload/download
│   ├── matrix/                    # Core Matrix implementation
│   │   ├── data/
│   │   │   ├── datasources/       # Matrix API data sources
│   │   │   ├── models/           # Data models
│   │   │   └── repositories/     # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/         # Business entities
│   │   │   │   └── matrix_entities.dart
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   │   └── matrix_repository.dart
│   │   │   └── usecases/         # Business logic
│   │   │       └── matrix_usecases.dart
│   │   └── presentation/
│   │       ├── bloc/             # State management
│   │       │   ├── auth_bloc.dart
│   │       │   ├── room_bloc.dart
│   │       │   └── space_bloc.dart
│   │       ├── pages/            # UI screens
│   │       │   ├── auth_page.dart
│   │       │   └── home_page.dart
│   │       └── widgets/          # Reusable UI components
│   │           ├── chat_view.dart
│   │           ├── login_form.dart
│   │           ├── message_input.dart
│   │           ├── message_list.dart
│   │           ├── register_form.dart
│   │           ├── room_list.dart
│   │           └── space_sidebar.dart
│   ├── notifications/             # Push notifications
│   ├── rooms/                    # Room management
│   ├── servers/                  # Server management
│   ├── settings/                 # App settings
│   ├── spaces/                   # Matrix Spaces (Discord servers)
│   ├── user_profile/            # User profiles
│   └── voice_channels/          # Voice/video calls
│
└── shared/                      # Shared components
    ├── models/                  # Shared data models
    └── widgets/                 # Shared UI widgets
```

## 🚀 Key Features

### Discord-like Experience
- **Spaces**: Matrix Spaces function as Discord servers
- **Channels**: Rooms organized by type (text, voice, categories)
- **Direct Messages**: Private conversations
- **Rich Messaging**: Text, images, files, reactions, replies
- **Real-time Updates**: Live message synchronization

### Matrix Protocol Integration
- **Decentralized**: Connect to any Matrix homeserver
- **End-to-End Encryption**: Secure by default
- **Federation**: Communicate across different servers
- **Open Standard**: Built on the Matrix protocol

### Modern Flutter Architecture
- **Clean Architecture**: Domain, Data, Presentation layers
- **BLoC Pattern**: Reactive state management
- **Dependency Injection**: GetIt for service location
- **Repository Pattern**: Data abstraction layer

## 🛠️ Technical Implementation

### Core Classes

#### MatrixUser Entity
```dart
class MatrixUser extends Equatable {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final bool isOnline;
  final UserPresence presence;
  // ... more properties
}
```

#### MatrixRoom Entity  
```dart
class MatrixRoom extends Equatable {
  final String roomId;
  final String? name;
  final RoomType type; // textChannel, voiceChannel, directMessage, etc.
  final bool isEncrypted;
  final int unreadCount;
  final String? parentSpaceId;
  // ... more properties
}
```

#### MatrixSpace Entity
```dart
class MatrixSpace extends Equatable {
  final String spaceId;
  final String name;
  final List<String> childRoomIds;
  final Map<String, dynamic> permissions;
  // ... more properties
}
```

### State Management with BLoC

#### AuthBloc
- Handles user authentication (login, register, logout)
- Manages authentication state across the app
- Integrates with Matrix authentication flow

#### RoomBloc  
- Manages room list and selected room state
- Handles message loading and sending
- Room creation and management

#### SpaceBloc
- Manages Matrix Spaces (Discord servers equivalent)
- Space selection and creation
- Child room organization

### Key Use Cases

#### Authentication
- `LoginUseCase`: User login with Matrix credentials
- `RegisterUseCase`: New user registration
- `LogoutUseCase`: Secure logout

#### Messaging
- `SendMessageUseCase`: Send messages to rooms
- `GetMessagesUseCase`: Load message history
- `AddReactionUseCase`: React to messages

#### Room Management
- `CreateRoomUseCase`: Create new channels/rooms
- `JoinRoomUseCase`: Join existing rooms
- `GetRoomsUseCase`: Load user's rooms

## 🎨 UI Components

### Main Interface
- **SpaceSidebar**: Left sidebar showing servers/spaces (like Discord)
- **RoomList**: Channel list for selected space
- **ChatView**: Main message area with header
- **MessageInput**: Rich message composition area

### Authentication
- **AuthPage**: Login/Register with tab interface
- **LoginForm**: Username/password authentication
- **RegisterForm**: New user registration

### Messaging
- **MessageList**: Scrollable message history
- **MessageBubble**: Individual message display
- **MessageInput**: Text input with attachment options

## 📦 Dependencies

### Core Flutter Packages
```yaml
dependencies:
  flutter_bloc: ^8.1.6          # State management
  equatable: ^2.0.5             # Value equality
  get_it: ^7.7.0                # Dependency injection
  dartz: ^0.10.1                # Functional programming
  
  # Matrix Protocol
  matrix: ^0.27.1               # Matrix SDK
  matrix_api_lite: ^1.7.0       # Lightweight Matrix API
  
  # Networking & Storage
  dio: ^5.4.3+1                 # HTTP client
  hive: ^2.2.3                  # Local database
  shared_preferences: ^2.2.3     # Simple storage
  
  # UI & Media
  cached_network_image: ^3.3.1   # Image caching
  image_picker: ^1.1.2          # Image selection
  file_picker: ^8.0.5           # File selection
  
  # Utilities
  intl: ^0.19.0                 # Internationalization
  uuid: ^4.4.0                  # UUID generation
  logger: ^2.0.2+1              # Logging
```

## 🚦 Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Dart 3.0+
- Matrix homeserver account (or create one at matrix.org)

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Configure Matrix homeserver URL in `lib/core/constants/matrix_constants.dart`
4. Run `flutter run`

### Matrix Configuration
```dart
// lib/core/constants/matrix_constants.dart
class MatrixConfig {
  static const String defaultHomeserver = 'https://matrix.org';
  static const String defaultClientName = 'MescatApp';
  // ... other configuration
}
```

## 🔐 Security Features

- **End-to-End Encryption**: Messages encrypted by default
- **Device Verification**: Cross-signing for device trust
- **Secure Storage**: Encrypted local data storage
- **Matrix Security**: Built on proven Matrix security model

## 🔄 Real-time Features

- **Live Sync**: Real-time message delivery
- **Typing Indicators**: Show when users are typing
- **Presence Updates**: Online/offline status
- **Push Notifications**: Background message alerts

## 🎯 Roadmap

### Phase 1 (Current)
- [x] Basic Matrix authentication
- [x] Room/channel management
- [x] Text messaging
- [x] Space (server) support
- [ ] Message reactions and replies

### Phase 2
- [ ] File sharing and media messages
- [ ] Voice and video calls
- [ ] Push notifications
- [ ] Message search

### Phase 3
- [ ] Custom emoji and stickers
- [ ] Message threading
- [ ] User roles and permissions
- [ ] Bot integrations

## 🤝 Contributing

1. Fork the project
2. Create a feature branch
3. Follow the established architecture patterns
4. Write tests for new features
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Matrix.org for the decentralized communication protocol
- Flutter team for the amazing framework
- Discord for UI/UX inspiration
- Open source community for various packages used

---

**Mescat** - Bringing Discord-like experience to the decentralized Matrix protocol! 🚀

## 🏗️ Project Structure

This project follows Clean Architecture principles with a feature-based organization:

```
lib/
├── core/                           # Core functionality shared across features
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart
│   ├── errors/                     # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                    # Network layer
│   │   └── network_service.dart
│   ├── routes/                     # App routing
│   │   └── app_routes.dart
│   ├── themes/                     # App theming
│   │   └── app_themes.dart
│   └── utils/                      # Utility functions
│
├── features/                       # Feature modules
│   ├── authentication/             # User authentication
│   │   ├── data/
│   │   │   ├── datasources/       # Remote & local data sources
│   │   │   ├── models/            # Data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business objects
│   │   │   ├── repositories/      # Repository abstractions
│   │   │   └── usecases/          # Business logic
│   │   └── presentation/
│   │       ├── bloc/              # State management
│   │       ├── pages/             # UI screens
│   │       └── widgets/           # Reusable UI components
│   │
│   ├── chat/                      # Chat functionality
│   ├── servers/                   # Server management
│   └── user_profile/              # User profile management
│
├── shared/                        # Shared widgets and models
│   ├── models/                    # Shared data models
│   └── widgets/                   # Reusable widgets
│
├── dependency_injection.dart      # Dependency injection setup
└── main.dart                     # App entry point

assets/
├── fonts/                        # Custom fonts
├── icons/                        # App icons
└── images/                       # Static images
```

## 🚀 Features

- **Authentication**: User login, registration, and session management
- **Real-time Chat**: WebSocket-based messaging system
- **Server Management**: Create and join Discord-like servers
- **User Profiles**: Customizable user profiles with avatars
- **Dark/Light Theme**: System-based theme switching
- **File Sharing**: Image and file upload capabilities
- **Voice Support**: Audio messaging and playback

## 📱 Tech Stack

### Core
- **Flutter SDK**: ^3.9.2
- **Dart**: Latest stable version

### State Management
- **flutter_bloc**: ^8.1.6 - BLoC pattern for state management
- **equatable**: ^2.0.5 - Value equality for Dart objects

### Networking
- **dio**: ^5.4.3+1 - HTTP client
- **retrofit**: ^4.1.0 - Type-safe API client
- **socket_io_client**: ^2.0.3+1 - Real-time communication

### Local Storage
- **hive**: ^2.2.3 - Fast NoSQL database
- **shared_preferences**: ^2.2.3 - Simple key-value storage

### UI & UX
- **google_fonts**: ^6.2.1 - Custom fonts
- **flutter_svg**: ^2.0.10+1 - SVG support
- **cached_network_image**: ^3.3.1 - Image caching
- **go_router**: ^14.2.0 - Declarative routing

### Media & Files
- **image_picker**: ^1.1.2 - Image selection
- **file_picker**: ^8.0.5 - File selection
- **just_audio**: ^0.9.38 - Audio playback
- **audioplayers**: ^6.0.0 - Audio functionality

### Development Tools
- **build_runner**: ^2.4.12 - Code generation
- **json_serializable**: ^6.8.0 - JSON serialization
- **flutter_lints**: ^5.0.0 - Linting rules

### Testing
- **bloc_test**: ^9.1.7 - BLoC testing utilities
- **mocktail**: ^1.0.4 - Mocking framework

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/mescat.git
   cd mescat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏛️ Architecture Overview

This project implements **Clean Architecture** with the following layers:

### 1. Presentation Layer
- **Pages**: UI screens
- **Widgets**: Reusable UI components  
- **BLoC**: State management using the BLoC pattern

### 2. Domain Layer
- **Entities**: Core business objects
- **Repositories**: Abstract contracts for data access
- **Use Cases**: Business logic implementation

### 3. Data Layer
- **Models**: Data transfer objects
- **Data Sources**: Remote (API) and local (database) data sources
- **Repository Implementations**: Concrete implementations of domain repositories

### Benefits
- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Easy to unit test business logic
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features and modify existing ones

## 🔧 Configuration

### Environment Setup
The app uses different configurations for different environments. Update the following files:

- `lib/core/constants/app_constants.dart` - API endpoints and constants
- `lib/core/network/network_service.dart` - Network configuration

### Theme Customization
Modify `lib/core/themes/app_themes.dart` to customize:
- Colors
- Typography
- Component themes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Discord's UI/UX design
- Built with Flutter's amazing ecosystem
- Clean Architecture principles by Robert C. Martin
