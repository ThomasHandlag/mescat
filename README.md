# Mescat - Discord-like Chat Application

A Flutter application built with Clean Architecture principles, inspired by Discord's functionality.

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
