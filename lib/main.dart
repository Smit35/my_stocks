import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/light_theme.dart';
import 'data/datasources/local_storage.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/stock_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/watchlist/watchlist_bloc.dart';
import 'presentation/bloc/watchlist/watchlist_event.dart';
import 'presentation/bloc/stock_search/stock_search_bloc.dart';
import 'presentation/bloc/stock_detail/stock_detail_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/watchlist/new_watchlist_screen.dart';
import 'presentation/screens/stock_detail/stock_detail_screen.dart';
import 'data/models/stock_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  await LocalStorage.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => StockRepository()),
        RepositoryProvider(create: (context) => WatchlistRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              userRepository: context.read<UserRepository>(),
            )..add(CheckAuthStatus()),
          ),
          BlocProvider(
            create: (context) => WatchlistBloc(
              watchlistRepository: context.read<WatchlistRepository>(),
              stockRepository: context.read<StockRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StockSearchBloc(
              stockRepository: context.read<StockRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StockDetailBloc(
              stockRepository: context.read<StockRepository>(),
            ),
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            title: 'Stock Watchlist',
            theme: LightTheme.lightTheme,
            home: const AppNavigator(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/stock-detail':
                  if (settings.arguments is StockModel) {
                    return MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<StockDetailBloc>(),
                        child: StockDetailScreen(stock: settings.arguments as StockModel),
                      ),
                    );
                  }
                  return null;
                default:
                  return null;
              }
            },
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Load user's watchlists when authenticated
          context.read<WatchlistBloc>().add(LoadWatchlists(state.user.id));
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              backgroundColor: LightTheme.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(color: LightTheme.primaryColor),
              ),
            );
          }

          if (state is AuthAuthenticated) {
            return const NewWatchlistScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}