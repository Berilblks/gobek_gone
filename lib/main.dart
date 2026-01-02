import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';
import 'package:gobek_gone/core/network/api_client.dart';
import 'package:gobek_gone/core/constants/app_constants.dart';
import 'package:gobek_gone/features/auth/data/repositories/auth_repository.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/features/bmi/data/services/bmi_service.dart';
import 'package:gobek_gone/features/bmi/logic/bmi_bloc.dart';
import 'package:gobek_gone/features/tasks/data/services/task_service.dart';
import 'package:gobek_gone/features/tasks/logic/tasks_bloc.dart';
import 'package:gobek_gone/features/addiction/data/services/addiction_service.dart';
import 'package:gobek_gone/features/addiction/logic/addiction_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final apiClient = ApiClient(baseUrl: AppConstants.apiBaseUrl); 
    final authRepository = AuthRepository(apiClient: apiClient);
    final bmiService = BmiService(apiClient: apiClient);
    final taskService = TaskService(apiClient: apiClient);
    final addictionService = AddictionService(apiClient: apiClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<BmiBloc>(
          create: (context) => BmiBloc(bmiService: bmiService),
        ),
        BlocProvider<TasksBloc>(
          create: (context) => TasksBloc(taskService: taskService),
        ),
        BlocProvider<AddictionBloc>(
          create: (context) => AddictionBloc(service: addictionService),
        ),
      ],
      child: MaterialApp(
        title: 'Göbek Gone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const Onboardingscreen(),
      ),
    );
  }
}