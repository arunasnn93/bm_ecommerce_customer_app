# Beena Mart - Customer Mobile Application

A modern Flutter mobile application for Beena Mart, an e-commerce platform. This application follows clean architecture principles and SOLID design patterns to ensure maintainable and scalable code.

## Features

### Authentication
- **Mobile Number OTP Authentication**: Secure login using mobile number and OTP verification
- **Token-based Session Management**: Automatic token refresh and session handling
- **Local Data Caching**: Offline support with local storage

### Home Dashboard
- **Virtual Tour**: Explore the store virtually (coming soon)
- **Place Orders**: Easy ordering interface (coming soon)
- **Previous Orders**: View order history (coming soon)
- **Special Offers**: Browse current promotions (coming soon)
- **Notifications**: Real-time notifications (coming soon)

## Architecture

This project follows **Clean Architecture** principles with the following layers:

### Domain Layer
- **Entities**: Core business objects (User, AuthResult)
- **Use Cases**: Business logic implementation
- **Repositories**: Abstract interfaces for data access

### Data Layer
- **Data Sources**: Remote and local data providers
- **Models**: Data transfer objects with JSON serialization
- **Repository Implementations**: Concrete implementations of repositories

### Presentation Layer
- **BLoC Pattern**: State management using flutter_bloc
- **Pages**: UI screens
- **Widgets**: Reusable UI components

### Core Layer
- **Network**: HTTP client with interceptors
- **Constants**: App-wide constants and configurations
- **Errors**: Failure handling
- **Utils**: Utility functions

## Project Structure

```
lib/
├── core/
│   ├── config/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   └── app_text_styles.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   ├── notifications/
│   └── orders/
├── shared/
│   ├── models/
│   ├── services/
│   │   └── dependency_injection.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_text_field.dart
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bm_ecommerce_customer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Dependencies

### State Management
- `flutter_bloc`: BLoC pattern implementation
- `equatable`: Value equality for objects

### Network & API
- `dio`: HTTP client
- `retrofit`: Type-safe HTTP client
- `json_annotation`: JSON serialization

### Local Storage
- `shared_preferences`: Local data persistence

### UI Components
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching

### Code Generation
- `build_runner`: Code generation
- `freezed`: Immutable data classes
- `json_serializable`: JSON serialization

## Design Patterns

### SOLID Principles
- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes are substitutable
- **Interface Segregation**: Clients depend on specific interfaces
- **Dependency Inversion**: High-level modules don't depend on low-level modules

### Clean Architecture
- **Independence of Frameworks**: Business logic independent of UI
- **Testability**: Easy to test business logic
- **Independence of UI**: UI can change without affecting business logic
- **Independence of Database**: Business rules don't depend on data access
- **Independence of External Agency**: Business rules don't know about external interfaces

## Demo Features

For demonstration purposes, the app includes:
- **Mock API Responses**: Simulated authentication flow
- **Demo OTP**: Any 6-digit OTP will work for verification
- **Placeholder Screens**: "Coming soon" messages for future features

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or support, please contact the development team.

---

**Note**: This is a demo application. In production, replace mock implementations with actual API calls and add proper error handling, validation, and security measures.
