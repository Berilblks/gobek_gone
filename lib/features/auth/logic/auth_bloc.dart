import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/login_request.dart';
import '../data/models/register_request.dart';
import '../data/models/forgot_password_request.dart';
import '../data/models/reset_password_request.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/update_profile_request.dart';
import '../data/models/change_password_request.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoadUserRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String fullname;
  final String username; // Added username
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final double targetWeight; // Added
  final String gender;
  final String? profilePhoto;

  const UpdateProfileRequested({
    required this.fullname,
    required this.username,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.targetWeight, // Added
    required this.gender,
    this.profilePhoto,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String fullname;
  final String username;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  final double height;
  final double weight;
  final String gender;
  final String email;
  final String password;

  const RegisterRequested({
    required this.fullname,
    required this.username,
    required this.birthDay,
    required this.birthMonth,
    required this.birthYear,
    required this.height,
    required this.weight,
    required this.gender,
    required this.email,
    required this.password
  });
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, code, newPassword];
}

class ChangePasswordRequested extends AuthEvent {
  final String email;
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, oldPassword, newPassword];
}

class DeleteAccountRequested extends AuthEvent {}

class ConfirmDeleteAccountRequested extends AuthEvent {
  final String code;

  const ConfirmDeleteAccountRequested({required this.code});

  @override
  List<Object> get props => [code];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User? user;
  
  const AuthAuthenticated({this.user});

  @override
  List<Object> get props => user != null ? [user!] : [];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class RegisterSuccess extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class ResetPasswordSuccess extends AuthState {}

class ChangePasswordSuccess extends AuthState {}

class DeleteAccountCodeSent extends AuthState {}

class DeleteAccountSuccess extends AuthState {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LoadUserRequested>(_onLoadUserRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<ConfirmDeleteAccountRequested>(_onConfirmDeleteAccountRequested);
  }

  Future<void> _onDeleteAccountRequested(DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.requestDeleteAccount();
      emit(DeleteAccountCodeSent());
      // Re-emit authenticated to keep UI usable behind dialog, or handle via listener
      // Better: Emit CodeSent, UI shows dialog, then we wait for Confirm
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onConfirmDeleteAccountRequested(ConfirmDeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.confirmDeleteAccount(event.code);
      await authRepository.logout(); // Clean up token
      emit(DeleteAccountSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onChangePasswordRequested(ChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.changePassword(ChangePasswordRequest(
        email: event.email,
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ));
      emit(ChangePasswordSuccess());
      // Revert to authenticated or handle logic
      add(LoadUserRequested()); // Reload user or just stay on success then pop
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final updatedUser = await authRepository.updateProfile(UpdateProfileRequest(
        fullname: event.fullname,
        username: event.username,
        birthDay: event.birthDay,
        birthMonth: event.birthMonth,
        birthYear: event.birthYear,
        height: event.height,
        weight: event.weight, 
        targetWeight: event.targetWeight, 
        gender: event.gender,
        profilePhoto: event.profilePhoto,
      ));
      // Backend response might be incomplete (missing targetWeight), so reload full profile
      add(LoadUserRequested());
    } catch (e) {
      emit(AuthFailure(error: "Failed to update profile: $e"));
      // After failure, we might want to reload original user or re-emit authenticated with old user if possible
      // But for now, failure state shows error snackbar usually
    }
  }

  Future<void> _onLoadUserRequested(LoadUserRequested event, Emitter<AuthState> emit) async {
    // If already authenticated but no user data, or reloading
    try {
      final user = await authRepository.getUserInfo();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      // If loading profile fails, we still want to stay authenticated
      print("Failed to load user profile: $e");
      emit(const AuthAuthenticated(user: null)); 
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.forgotPassword(ForgotPasswordRequest(email: event.email));
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.resetPassword(ResetPasswordRequest(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      ));
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.login(LoginRequest(
        email: event.email,
        password: event.password,
      ));
      emit(AuthAuthenticated()); // Emit success immediately
      add(LoadUserRequested()); // Then try to load user info
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(RegisterRequest(
        fullname: event.fullname,
        username: event.username,
        birthDay: event.birthDay,
        birthMonth: event.birthMonth,
        birthYear: event.birthYear,
        height: event.height,
        weight: event.weight,
        gender: event.gender,
        email: event.email,
        password: event.password,
      ));
      // Optionally login immediately or wait for manual login
      emit(RegisterSuccess());
      // If backend returns token on register, we could:
      // await TokenStorage.saveToken(response.token);
      // add(LoadUserRequested());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthInitial());
  }
}
