import 'package:go_router/go_router.dart';
import 'package:seminari_flutter/screens/auth/login_screen.dart';
import 'package:seminari_flutter/screens/borrar_screen.dart';
import 'package:seminari_flutter/screens/details_screen.dart';
import 'package:seminari_flutter/screens/editar_screen.dart';
import 'package:seminari_flutter/screens/imprimir_screen.dart';
import 'package:seminari_flutter/screens/home_screen.dart';
import 'package:seminari_flutter/screens/perfil_screen.dart';
import 'package:seminari_flutter/services/auth_service.dart';
import '../models/user.dart'; //importar el modelo User
final GoRouter appRouter = GoRouter(
   initialLocation: AuthService().getCurrentUser() != null ? '/' : '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details',
          builder: (context, state) => const DetailsScreen(),
          routes: [
            GoRoute(
              path: 'imprimir',
              builder: (context, state) => const ImprimirScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'editar',
            builder: (context, state) {
              final user = state.extra as User; // Recibir el usuario desde el argumento
              return EditarScreen(user: user); // Pasar el usuario a EditarScreen
            },

        ),
        GoRoute(
          path: 'borrar',
          builder: (context, state) => const BorrarScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            final authService = AuthService();
            final user = authService.getCurrentUser(); // Obtener el usuario logueado
            print("Usuario actual: $user"); // Depuración
            if (user == null) {
              return LoginPage(); // Redirigir a la página de login si no hay usuario
            }
            return PerfilScreen(user: user); // Pasar el usuario a la pantalla de perfil
          }
          
        ),
      ],
    ),
  ],
);
