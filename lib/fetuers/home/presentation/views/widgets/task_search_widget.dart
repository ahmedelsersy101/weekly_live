import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/core/services/search_service.dart';
import 'package:weekly_dash_board/core/services/performance_service.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';

import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/enhanced_task_item.dart';

class TaskSearchWidget extends StatefulWidget {
  const TaskSearchWidget({super.key});

  @override
  State<TaskSearchWidget> createState() => _TaskSearchWidgetState();
}

class _TaskSearchWidgetState extends State<TaskSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final PerformanceService _performanceService = PerformanceService();

  String _searchQuery = '';
  List<TaskModel> _searchResults = [];
  List<TaskModel> _allTasks = [];
  bool _isSearching = false;

  String? _selectedCategoryId;
  TaskPriority? _selectedPriority;
  bool? _selectedCompletionStatus;
  bool? _selectedImportanceStatus;
  int? _selectedDay;

  bool _showAdvancedFilters = false;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> _selectedTags = [];
  int? _minEstimatedMinutes;
  int? _maxEstimatedMinutes;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _performanceService.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });

    _performanceService.debounceSearch(() {
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
    });
  }

  List<TaskModel> get _filteredTasks {
    if (_searchQuery.trim().isEmpty) {
      return [];
    }
    return _searchResults;
  }

  void _performSearch() {
    if (_searchQuery.trim().isEmpty &&
        _selectedCategoryId == null &&
        _selectedPriority == null &&
        _selectedCompletionStatus == null &&
        _selectedImportanceStatus == null &&
        _selectedDay == null &&
        _startDate == null &&
        _endDate == null &&
        _selectedTags.isEmpty &&
        _minEstimatedMinutes == null &&
        _maxEstimatedMinutes == null) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    Future.microtask(() {
      if (!mounted) return;

      final results = _searchService.advancedSearch(
        query: _searchQuery.trim().isEmpty ? null : _searchQuery,
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        isCompleted: _selectedCompletionStatus,
        isImportant: _selectedImportanceStatus,
        dayOfWeek: _selectedDay,
        startDate: _startDate,
        endDate: _endDate,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
        minEstimatedMinutes: _minEstimatedMinutes,
        maxEstimatedMinutes: _maxEstimatedMinutes,
        tasks: _allTasks,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        if (state is! WeeklySuccess) {
          return const SizedBox.shrink();
        }

        _allTasks = state.weeklyState.tasks;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => _onSearchChanged(),
                decoration: InputDecoration(
                  hintText:  AppLocalizations.of(context).tr('settings.search'),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),

              if (_searchController.text.isNotEmpty) ...[
                const SizedBox(height: 16),

                Text(
                  'Search Results (${_filteredTasks.length})',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: AppTheme.getResponsiveFontSize(
                      context,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                if (_filteredTasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No tasks found matching "${_searchController.text}"',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildSearchResultItem(context, task);
                      },
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchInterface() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              cursorColor: Theme.of(context).colorScheme.primary,
              decoration: InputDecoration(
                focusColor: Theme.of(context).colorScheme.primary,
                hintText: 'Search tasks, categories, tags...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _clearAllFilters();
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          _showAdvancedFilters
                              ? Icons.filter_list
                              : Icons.filter_list_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _showAdvancedFilters = !_showAdvancedFilters;
                          });
                        },
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchQuery.trim().isNotEmpty) {
      return _buildNoResults();
    }

    if (_searchResults.isEmpty) {
      return _buildSearchSuggestions();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${_searchResults.length} task${_searchResults.length == 1 ? '' : 's'} found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: _searchResults.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final task = _searchResults[index];
            return EnhancedTaskItem(
              task: task,
              onEdit: () => _editTask(task),
              onDelete: () => _deleteTask(task),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or filters',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = _searchService.getSearchSuggestions(
      _allTasks,
      _searchQuery,
    );
    final trending = _searchService.getTrendingSearchTerms(_allTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (suggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Search Suggestions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((suggestion) {
                return InkWell(
                  onTap: () {
                    _searchController.text = suggestion;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        if (trending.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Trending',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trending.map((term) {
                return InkWell(
                  onTap: () {
                    _searchController.text = term;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      term,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedPriority = null;
      _selectedCompletionStatus = null;
      _selectedImportanceStatus = null;
      _selectedDay = null;
      _startDate = null;
      _endDate = null;
      _selectedTags.clear();
      _minEstimatedMinutes = null;
      _maxEstimatedMinutes = null;
    });
    _performSearch();
  }

  void _editTask(TaskModel task) {
    print('Edit task: ${task.title}');
  }

  void _deleteTask(TaskModel task) {
    print('Delete task: ${task.title}');
  }

  Widget _buildSearchResultItem(BuildContext context, TaskModel task) {
    return EnhancedTaskItem(
      task: task,
      onEdit: () => _editTask(task),
      onDelete: () => _deleteTask(task),
    );
  }
}
