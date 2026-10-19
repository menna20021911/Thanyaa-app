import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanya/cubit/SOS/sos_cubit.dart';
import 'package:thanya/cubit/auth/auth_cubit.dart';
import 'package:thanya/cubit/profile/profile_cubit.dart';
import 'package:thanya/firebase_options.dart';
import 'package:thanya/repositories/auth_repository.dart';
import 'package:thanya/screens/splash.dart';
import 'package:thanya/services/connectivity_service.dart';
import 'package:thanya/services/connectivity_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConnectivityService().initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<SosCubit>(create: (_) => SosCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
        },
        home: const SplashScreen(),
      ),
    );
  }
}
