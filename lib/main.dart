import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Ensure importing if needed, or just let service handle it.
import 'features/notifications/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/MainPages/SplashScreen.dart';
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
import 'package:gobek_gone/features/ai/logic/chat_bloc.dart';
import 'package:gobek_gone/features/ai/data/repositories/ai_repository.dart';
import 'package:gobek_gone/features/diet/data/services/diet_service.dart';
import 'package:gobek_gone/features/diet/logic/diet_bloc.dart';
import 'package:gobek_gone/features/badges/data/services/badge_service.dart';
import 'package:gobek_gone/features/gamification/data/services/gamification_service.dart';
import 'package:gobek_gone/features/gamification/logic/gamification_bloc.dart';
import 'package:gobek_gone/features/friends/data/services/friend_service.dart';
import 'package:gobek_gone/features/friends/logic/friends_bloc.dart';
import 'package:gobek_gone/features/workout/data/services/workout_service.dart';
import 'package:gobek_gone/features/progress/data/services/progress_service.dart';
import 'package:gobek_gone/features/exercise/data/services/exercise_service.dart';
import 'package:gobek_gone/features/workout/logic/workout_bloc.dart';
import 'package:gobek_gone/features/progress/logic/progress_bloc.dart';
import 'package:gobek_gone/features/exercise/logic/exercise_bloc.dart';


import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await initializeDateFormatting('tr_TR', null);
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
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(
            aiRepository: AiRepository(apiClient: apiClient),
            authRepository: authRepository,
            dietService: DietService(apiClient: apiClient),
            workoutService: WorkoutService(apiClient: apiClient),
          ),
        ),
        BlocProvider<DietBloc>(
          create: (context) => DietBloc(dietService: DietService(apiClient: apiClient)),
        ),
        BlocProvider<FriendsBloc>(
          create: (context) => FriendsBloc(friendService: FriendService(apiClient)),
        ),
        BlocProvider<GamificationBloc>(
          create: (context) => GamificationBloc(
            gamificationService: GamificationService(apiClient),
            badgeService: BadgeService(apiClient: apiClient),
          ),
        ),
        BlocProvider<WorkoutBloc>(
          create: (context) => WorkoutBloc(workoutService: WorkoutService(apiClient: apiClient)),
        ),
        BlocProvider<ProgressBloc>(
          create: (context) => ProgressBloc(
            progressService: ProgressService(apiClient),
            authRepository: AuthRepository(apiClient: apiClient),
          ),
        ),
        BlocProvider<ExerciseBloc>(
          create: (context) => ExerciseBloc(exerciseService: ExerciseService(apiClient: apiClient)),
        ),
      ],
      child: MaterialApp(
        title: 'Göbek Gone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const SplashScreen(),
      ),
    );
  }
}