import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/friend_service.dart';
import '../data/models/friend_response.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendsEvent extends FriendsEvent {
  final String query;
  const LoadFriendsEvent({this.query = ""});
  
  @override
  List<Object?> get props => [query];
}

class SearchFriendsEvent extends FriendsEvent {
  final String query;
  const SearchFriendsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SendFriendRequestEvent extends FriendsEvent {
  final int userId;
  const SendFriendRequestEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AcceptFriendRequestEvent extends FriendsEvent {
  final int senderId;
  const AcceptFriendRequestEvent(this.senderId);

  @override
  List<Object?> get props => [senderId];
}

abstract class FriendsState extends Equatable {
  const FriendsState();
  
  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<FriendResponse> allUsers;
  final List<FriendResponse> searchResults;
  final String currentQuery;
  final String? actionMessage;

  const FriendsLoaded({
    this.allUsers = const [],
    this.searchResults = const [],
    this.currentQuery = "",
    this.actionMessage,
  });

  FriendsLoaded copyWith({
    List<FriendResponse>? allUsers,
    List<FriendResponse>? searchResults,
    String? currentQuery,
    String? actionMessage,
  }) {
    return FriendsLoaded(
      allUsers: allUsers ?? this.allUsers,
      searchResults: searchResults ?? this.searchResults,
      currentQuery: currentQuery ?? this.currentQuery,
      actionMessage: actionMessage, 
    );
  }

  @override
  List<Object?> get props => [allUsers, searchResults, currentQuery, actionMessage];
}

class FriendsError extends FriendsState {
  final String message;
  const FriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendService _friendService;

  FriendsBloc({required FriendService friendService}) : _friendService = friendService, super(FriendsInitial()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<SearchFriendsEvent>(_onSearchFriends);
    on<SendFriendRequestEvent>(_onSendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptRequest);
  }

  Future<void> _onLoadFriends(LoadFriendsEvent event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    try {
      final results = await _friendService.searchUsers("");
      results.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      final initialFiltered = _filterUsers(results, event.query);
      
      emit(FriendsLoaded(
        allUsers: results, 
        searchResults: initialFiltered,
        currentQuery: event.query
      ));
    } catch (e) {
      emit(FriendsError("Failed to load users: $e"));
    }
  }

  void _onSearchFriends(SearchFriendsEvent event, Emitter<FriendsState> emit) {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      final filtered = _filterUsers(currentState.allUsers, event.query);
      emit(currentState.copyWith(
        searchResults: filtered,
        currentQuery: event.query,
        actionMessage: null
      ));
    }
  }

  Future<void> _onSendRequest(SendFriendRequestEvent event, Emitter<FriendsState> emit) async {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      
      final success = await _friendService.sendFriendRequest(event.userId);
      
      if (success) {
        final updatedList = currentState.allUsers.map((user) {
          if (user.id == event.userId) {
            return FriendResponse(
               id: user.id,
               name: user.name,
               username: user.username,
               photoUrl: user.photoUrl,
               level: user.level,
               steps: user.steps,
               status: "Pending"
            );
          }
          return user;
        }).toList();

        final updatedSearch = _filterUsers(updatedList, currentState.currentQuery);
        
        emit(currentState.copyWith(
           allUsers: updatedList,
           searchResults: updatedSearch,
           actionMessage: "Request sent!"
        ));
      }
    }
  }

  Future<void> _onAcceptRequest(AcceptFriendRequestEvent event, Emitter<FriendsState> emit) async {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;

      final success = await _friendService.acceptRequest(event.senderId);
      
      if (success) {
        final updatedList = currentState.allUsers.map((user) {
           if (user.id == event.senderId) {
             return FriendResponse(
                id: user.id,
                name: user.name,
                username: user.username,
                photoUrl: user.photoUrl,
                level: user.level,
                steps: user.steps,
                status: "Accepted"
             );
           }
           return user;
        }).toList();
        
        final updatedSearch = _filterUsers(updatedList, currentState.currentQuery);

        emit(currentState.copyWith(
           allUsers: updatedList,
           searchResults: updatedSearch,
           actionMessage: "Friend request accepted!"
        ));
      }
    }
  }

  List<FriendResponse> _filterUsers(List<FriendResponse> users, String query) {
     if (query.isEmpty) return users; 
     
    final lowerQuery = query.toLowerCase();
    return users.where((user) {
      if (user.status == "Accepted") return false; 
      if (query.isEmpty) return true; 

      final nameMatches = user.name.toLowerCase().contains(lowerQuery);
      final usernameMatches = user.username?.toLowerCase().contains(lowerQuery) ?? false;
      return nameMatches || usernameMatches;
    }).toList();
  }
}
