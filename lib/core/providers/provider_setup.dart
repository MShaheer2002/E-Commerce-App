import 'package:e_commerce_app/presentation/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AppProvider {
  static List<ChangeNotifierProvider> all = [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    // ChangeNotifierProvider(create: (_) => AuthProvider()),
    // ChangeNotifierProvider(create: (_) => UserProvider()),
  ];
}
