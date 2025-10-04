part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final SettingsModel? settings;
  final bool isLoading;
  final String? error;

  const SettingsState({this.settings, this.isLoading = false, this.error});

  SettingsState copyWith({
    SettingsModel? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, error];
}
