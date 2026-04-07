# My Stocks - Setup Guide

A comprehensive Flutter stock tracking application implementing Clean Architecture with Bloc state management.

## 🚀 Features

- **Clean Architecture** - Scalable, testable, and maintainable code structure
- **Bloc State Management** - Predictable state management with flutter_bloc
- **Real-time Stock Data** - Live stock prices via Yahoo Finance API
- **Watchlist Management** - Add, remove, and track your favorite stocks
- **Stock Details** - Detailed stock information with interactive charts
- **Offline-first** - Local data persistence with Hive database
- **Unit Tests** - Comprehensive test coverage across all layers

## 📋 Prerequisites

- Flutter SDK (>=3.9.0)
- Dart SDK
- RapidAPI Account (for Yahoo Finance API)

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Smit35/my_stocks.git
cd my_stocks
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

```bash
flutter packages pub run build_runner build
```

### 4. API Configuration

1. Sign up for a free account at [RapidAPI](https://rapidapi.com/)
2. Subscribe to the [Yahoo Finance API](https://rapidapi.com/apidojo/api/yahoo-finance1/)
3. Get your API key from the RapidAPI dashboard
4. Update the API key in the following files:

**File: `lib/core/network/api_client.dart`**
```dart
headers: {
  'X-RapidAPI-Host': 'yh-finance.p.rapidapi.com',
  'X-RapidAPI-Key': 'YOUR_ACTUAL_RAPIDAPI_KEY_HERE', // Replace this
},
```

**File: `lib/core/constants/app_constants.dart`**
```dart
static const String rapidApiKey = 'YOUR_ACTUAL_RAPIDAPI_KEY_HERE'; // Replace this
```

### 5. Run the Application

```bash
flutter run
```

## 🧪 Running Tests

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## 🏗️ Architecture Overview

```
lib/
├── core/                      # Core utilities and shared code
│   ├── error/                # Error handling (failures, exceptions)
│   ├── network/              # API client and network utilities
│   ├── utils/                # Formatters, colors, constants
│   └── constants/            # App-wide constants
├── features/                  # Feature-based modules
│   ├── auth/                 # User authentication & storage
│   │   ├── data/            # Data sources, models, repositories
│   │   ├── domain/          # Entities, repositories, use cases
│   │   └── presentation/    # UI, blocs, pages, widgets
│   ├── watchlist/           # Stock watchlist feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── stock_detail/        # Stock details feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart   # Dependency injection setup
└── main.dart                 # App entry point
```

## 🎯 Key Implementation Details

### Clean Architecture Layers

1. **Presentation Layer** - UI widgets, Bloc state management
2. **Domain Layer** - Business logic, entities, use cases
3. **Data Layer** - Repository implementations, data sources (API/Local)

### State Management

- **Bloc Pattern** - Event-driven state management
- **Auto-refresh** - Real-time price updates every 10 seconds
- **Error Handling** - Graceful error states with retry functionality

### Data Persistence

- **Hive Database** - Fast, lightweight local storage
- **User Management** - Automatic user creation and persistence
- **Watchlist Storage** - Local storage with cloud sync capability

### API Integration

- **Yahoo Finance API** - Real-time stock data via RapidAPI
- **Error Handling** - Network timeouts, server errors, offline fallback
- **Caching Strategy** - Local cache with API refresh

## 📱 App Flow

1. **App Launch** → User initialization → Watchlist screen
2. **Add Stock** → API validation → Local storage → UI update
3. **Remove Stock** → Local removal → UI update
4. **Stock Details** → API fetch → Chart display → Holdings info
5. **Auto-refresh** → Background API calls → Price updates

## 🔧 Configuration Options

### API Endpoints
- Stock quotes: `/v6/finance/quote`
- Stock details: `/v8/finance/quoteSummary/{symbol}`
- Chart data: `/v8/finance/chart/{symbol}`

### Refresh Intervals
- Auto-refresh: 10 seconds (configurable in `app_constants.dart`)
- Chart data: Real-time based on time range

### Local Storage
- User data: `user_box` (Hive)
- Watchlist: `watchlist_box` (Hive)

## 🐛 Troubleshooting

### Common Issues

1. **API Key Error**
   - Ensure you've replaced the placeholder API key
   - Verify your RapidAPI subscription is active

2. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Regenerate code: `flutter packages pub run build_runner build --delete-conflicting-outputs`

3. **Network Issues**
   - Check internet connectivity
   - Verify API endpoints are accessible

### Debug Mode

Enable debug logging by setting in `api_client.dart`:
```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

## 📚 Testing Strategy

- **Unit Tests** - Domain layer (use cases, entities)
- **Bloc Tests** - State management logic
- **Integration Tests** - Repository implementations
- **Widget Tests** - UI components (coming soon)

## 🚀 Future Enhancements

- [ ] Real-time WebSocket connections
- [ ] Portfolio management
- [ ] Technical analysis indicators
- [ ] Push notifications for price alerts
- [ ] Social features (sharing, discussions)
- [ ] Advanced charting (candlestick, volume)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Note**: This is a demonstration project showcasing Clean Architecture principles in Flutter. For production use, consider additional security measures, error handling, and performance optimizations.