part of 'weekly_cubit.dart';

abstract class WeeklyState extends Equatable {
  const WeeklyState();

  @override
  List<Object?> get props => [];
}

class WeeklyInitial extends WeeklyState {
  const WeeklyInitial();
}

class WeeklyLoading extends WeeklyState {
  const WeeklyLoading();
}

class WeeklySuccess extends WeeklyState {
  final WeeklyStateModel weeklyState;

  const WeeklySuccess(this.weeklyState);

  @override
  List<Object?> get props => [weeklyState];
}

class WeeklyError extends WeeklyState {
  final String message;

  const WeeklyError(this.message);

  @override
  List<Object?> get props => [message];
}
