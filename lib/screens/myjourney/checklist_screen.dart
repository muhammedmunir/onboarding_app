import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // Project and task data
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic>? _selectedProject;

  // Controllers for forms
  final TextEditingController _projectTitleController = TextEditingController();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  DateTime _projectStartDate = DateTime.now();
  DateTime _projectEndDate = DateTime.now().add(const Duration(days: 7));
  DateTime _taskDueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    // Load sample data
    _loadSampleData();
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    // Sample projects
    _projects = [
      {
        'id': 1,
        'title': 'Weekly Checklist',
        'startDate': DateTime(2023, 5, 1),
        'endDate': DateTime(2023, 5, 7),
      },
      {
        'id': 2,
        'title': 'Daily Tasks',
        'startDate': DateTime(2023, 5, 2),
        'endDate': DateTime(2023, 5, 2),
      },
    ];

    // Sample tasks
    _tasks = [
      {
        'id': 1,
        'projectId': 1,
        'title': 'Task 1',
        'description': 'First task description',
        'dueDate': DateTime(2023, 5, 3),
        'completed': false,
      },
      {
        'id': 2,
        'projectId': 1,
        'title': 'Task 2',
        'description': 'Second task description',
        'dueDate': DateTime(2023, 5, 4),
        'completed': true,
      },
      {
        'id': 3,
        'projectId': 2,
        'title': 'Task 3',
        'description': 'Third task description',
        'dueDate': DateTime(2023, 5, 2),
        'completed': false,
      },
    ];
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder, color: Color(0xFFE07C7C)),
                title: const Text('Create New Project'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddProjectDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.task, color: Color(0xFFE07C7C)),
                title: const Text('Add New Task'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTaskDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddProjectDialog() {
    // Reset form fields
    _projectTitleController.clear();
    _projectStartDate = DateTime.now();
    _projectEndDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Project', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _projectTitleController,
                      decoration: InputDecoration(
                        labelText: 'Project Title *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Start and end date selection
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _projectStartDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _projectStartDate = pickedDate;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Start: ${DateFormat('MMM d, yyyy').format(_projectStartDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _projectEndDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _projectEndDate = pickedDate;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'End: ${DateFormat('MMM d, yyyy').format(_projectEndDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_projectTitleController.text.isNotEmpty) {
                      // Create new project
                      final newProject = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'title': _projectTitleController.text,
                        'startDate': _projectStartDate,
                        'endDate': _projectEndDate,
                      };

                      // Add to projects list
                      setState(() {
                        _projects.add(newProject);
                        _selectedProject = newProject;
                      });

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07C7C),
                  ),
                  child: const Text('Create Project'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    if (_projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a project first'),
          backgroundColor: Color(0xFFE07C7C),
        ),
      );
      return;
    }

    // Reset form fields
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    _taskDueDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Task', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project selection
                    DropdownButtonFormField(
                      value: _selectedProject?['id'] ?? _projects.first['id'],
                      items: _projects.map((project) {
                        return DropdownMenuItem(
                          value: project['id'],
                          child: Text(project['title']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProject = _projects.firstWhere((project) => project['id'] == value);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Project *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taskTitleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taskDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _taskDueDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _taskDueDate = pickedDate;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Due Date: ${DateFormat('MMM d, yyyy').format(_taskDueDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskTitleController.text.isNotEmpty) {
                      // Create new task
                      final newTask = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'projectId': _selectedProject?['id'] ?? _projects.first['id'],
                        'title': _taskTitleController.text,
                        'description': _taskDescriptionController.text,
                        'dueDate': _taskDueDate,
                        'completed': false,
                      };

                      // Add to tasks list
                      setState(() {
                        _tasks.add(newTask);
                      });

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07C7C),
                  ),
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    // Set form fields with existing task data
    _taskTitleController.text = task['title'];
    _taskDescriptionController.text = task['description'] ?? '';
    _taskDueDate = task['dueDate'];
    _selectedProject = _projects.firstWhere((project) => project['id'] == task['projectId']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project selection
                    DropdownButtonFormField(
                      value: _selectedProject?['id'],
                      items: _projects.map((project) {
                        return DropdownMenuItem(
                          value: project['id'],
                          child: Text(project['title']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProject = _projects.firstWhere((project) => project['id'] == value);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Project *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taskTitleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _taskDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _taskDueDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _taskDueDate = pickedDate;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Due Date: ${DateFormat('MMM d, yyyy').format(_taskDueDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _confirmDeleteTask(task['id']);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskTitleController.text.isNotEmpty) {
                      // Update task
                      setState(() {
                        final index = _tasks.indexWhere((t) => t['id'] == task['id']);
                        if (index != -1) {
                          _tasks[index] = {
                            ..._tasks[index],
                            'title': _taskTitleController.text,
                            'description': _taskDescriptionController.text,
                            'dueDate': _taskDueDate,
                            'projectId': _selectedProject?['id'],
                          };
                        }
                      });

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07C7C),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTask(int taskId) {
    setState(() {
      _tasks.removeWhere((task) => task['id'] == taskId);
    });
  }

  void _confirmDeleteTask(int taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTask(taskId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProject(int projectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project? All tasks in this project will also be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Delete the project
                  _projects.removeWhere((project) => project['id'] == projectId);
                  
                  // Delete all tasks associated with this project
                  _tasks.removeWhere((task) => task['projectId'] == projectId);
                  
                  // Clear selection if the selected project was deleted
                  if (_selectedProject != null && _selectedProject!['id'] == projectId) {
                    _selectedProject = null;
                  }
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _selectProject(Map<String, dynamic> project) {
    setState(() {
      _selectedProject = project;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedProject = null;
    });
  }

  List<Map<String, dynamic>> _getTasksForProject(int projectId) {
    return _tasks.where((task) => task['projectId'] == projectId).toList();
  }

  int _getCompletedTaskCount(int projectId) {
    return _getTasksForProject(projectId).where((task) => task['completed']).length;
  }

  int _getTotalTaskCount(int projectId) {
    return _getTasksForProject(projectId).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
      //   backgroundColor: const Color(0xFFE07C7C),
      //   foregroundColor: Colors.white,
      //   actions: [
      //     if (_selectedProject != null)
      //       IconButton(
      //         icon: const Icon(Icons.close),
      //         onPressed: _clearSelection,
      //         tooltip: 'Clear Selection',
      //       ),
      //   ],
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Projects section (always shown)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Projects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Projects list
          SizedBox(
  height: 140, // Slightly increased height for better appearance
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: _projects.length,
    itemBuilder: (context, index) {
      final project = _projects[index];
      final startDate = DateFormat('d MMM').format(project['startDate']);
      final endDate = DateFormat('d MMM').format(project['endDate']);
      final completedTasks = _getCompletedTaskCount(project['id']);
      final totalTasks = _getTotalTaskCount(project['id']);
      final progress = totalTasks > 0 ? completedTasks / totalTasks : 0;
      final isSelected = _selectedProject != null && _selectedProject!['id'] == project['id'];
      
      return GestureDetector(
        onTap: () => _selectProject(project),
        child: Container(
          width: 200, // Slightly wider for better content fit
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE07C7C).withOpacity(0.3),
                      const Color(0xFFE07C7C).withOpacity(0.1),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isSelected 
                ? Border.all(color: const Color(0xFFE07C7C), width: 2)
                : Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Project title with icon
                    Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: isSelected ? const Color(0xFFE07C7C) : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFFE07C7C) : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Date range
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$startDate - $endDate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Progress section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFFE07C7C) : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        
                        // Progress bar
                        LinearProgressIndicator(
                          value: progress.toDouble(),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1 
                              ? Colors.green 
                              : const Color(0xFFE07C7C),
                          ),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 4),
                        
                        // Completed tasks count
                        Text(
                          '$completedTasks/$totalTasks tasks completed',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    onPressed: () => _deleteProject(project['id']),
                    padding: EdgeInsets.zero,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),

          // Task List section (shown when a project is selected)
          if (_selectedProject != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedProject!['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_getCompletedTaskCount(_selectedProject!['id'])}/${_getTotalTaskCount(_selectedProject!['id'])} completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            Expanded(
              child: _getTasksForProject(_selectedProject!['id']).isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first task',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _getTasksForProject(_selectedProject!['id']).length,
                      itemBuilder: (context, index) {
                        final task = _getTasksForProject(_selectedProject!['id'])[index];
                        final dueDate = DateFormat('MMM d, yyyy').format(task['dueDate']);
                        
                        return Dismissible(
                          key: Key(task['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            // Show confirmation dialog before deleting
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            _deleteTask(task['id']);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: task['completed'],
                                  onChanged: (value) {
                                    setState(() {
                                      final taskIndex = _tasks.indexWhere((t) => t['id'] == task['id']);
                                      if (taskIndex != -1) {
                                        _tasks[taskIndex]['completed'] = value;
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFFE07C7C),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task['title'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          decoration: task['completed'] 
                                              ? TextDecoration.lineThrough 
                                              : null,
                                          color: task['completed'] 
                                              ? Colors.grey 
                                              : Colors.black,
                                        ),
                                      ),
                                      if (task['description'] != null && task['description'].isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            task['description'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Due: $dueDate',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: task['completed'] ? Colors.grey : const Color(0xFFE07C7C),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                  onPressed: () => _showEditTaskDialog(task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                                  onPressed: () => _confirmDeleteTask(task['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ] else if (_projects.isNotEmpty) ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Select a project to view its tasks',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_task, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No projects yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to create your first project',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptionsDialog,
        backgroundColor: const Color(0xFFE07C7C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}