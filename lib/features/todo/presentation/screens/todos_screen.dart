import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tes_venteny/core/utils/extension/context_ext.dart';
import 'package:tes_venteny/core/utils/extension/dartz_ext.dart';
import 'package:tes_venteny/core/utils/extension/extension.dart';
import 'package:tes_venteny/core/utils/extension/string_ext.dart';
import 'package:tes_venteny/core/utils/local_notification.dart';
import 'package:tes_venteny/features/todo/domain/entities/todo.dart';
import 'package:tes_venteny/features/todo/presentation/blocs/todo_form/todo_form_bloc.dart';

import '../../../../core/utils/debouncer.dart';
import '../../../../injection.dart';
import '../blocs/todo/todo_bloc.dart';

class TodosScreen extends StatelessWidget {
  static const routeName = '/todos';
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoBloc>(
      create: (context) => getIt<TodoBloc>()..add(TodoEvent.getTodos()),
      child: TodosScaffold(),
    );
  }
}

class TodosScaffold extends StatelessWidget {
  const TodosScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    void createTodo() {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<TodoFormBloc>(
                create: (context) => getIt<TodoFormBloc>(),
              ),
              BlocProvider<TodoBloc>.value(
                value: context.read<TodoBloc>(),
              ),
            ],
            child: _FormTodoBottomSheetModal(),
          );
        },
      );
    }

    void updateTodo(Todo? todo) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<TodoFormBloc>(
                create: (context) => getIt<TodoFormBloc>(),
              ),
              BlocProvider<TodoBloc>.value(
                value: context.read<TodoBloc>(),
              ),
            ],
            child: _FormTodoBottomSheetModal(todo),
          );
        },
      );
    }

    void deleteTodo(int? id) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<TodoBloc>(),
          child: AlertDialog(
            title: Text('Delete Todo'),
            content: Text('Are you sure want to delete this todo?'),
            actions: [
              BlocConsumer<TodoBloc, TodoState>(
                listenWhen: (previous, current) {
                  return previous.deleteTodo != current.deleteTodo ||
                      previous.isDeleting != current.isDeleting;
                },
                listener: (context, state) {
                  if (state.deleteTodo?.isRight() == true &&
                      state.isDeleting == false) {
                    Navigator.pop(context);
                  }
                },
                buildWhen: (previous, current) {
                  return previous.isDeleting != current.isDeleting;
                },
                builder: (context, state) {
                  if (state.isDeleting) {
                    return CircularProgressIndicator();
                  }
                  return TextButton(
                    onPressed: () {
                      context
                          .read<TodoBloc>()
                          .add(TodoEvent.deleteTodo(id: id!));
                    },
                    child: Text('Yes'),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
            ],
          ),
        ),
      );
    }

    final debouncer = Debouncer(milliseconds: 500);
    return BlocListener<TodoBloc, TodoState>(
      listenWhen: (previous, current) {
        return previous.deleteTodo != current.deleteTodo ||
            previous.isDeleting != current.isDeleting;
      },
      listener: (context, state) {
        if (state.deleteTodo?.isRight() == true && state.isDeleting == false) {
          context.showInfoToast('Todo deleted');
          context.read<TodoBloc>().add(TodoEvent.getTodos());
        }
        if (state.deleteTodo?.isLeft() == true && state.isDeleting == false) {
          final message = state.deleteTodo?.asLeft().message ??
              'Something went wrong, please try again';
          context.showErrorToast(message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Todos'),
          actions: [
            // schedule notification
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                final scheduledDate = DateTime.now().add( const Duration(seconds: 5));

                getIt<LocalNotification>().schedule(
                  id: 0,
                  scheduledDate: scheduledDate,
                  title: 'Reminder Todo',
                  body: 'Don\'t forget to do your todo',
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                context.read<TodoBloc>().add(TodoEvent.getTodos());
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.restorablePushNamed(context, '/settings');
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createTodo,
          child: Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                constraints: BoxConstraints(
                  maxHeight: 50.0,
                  minHeight: 40.0,
                ),
                elevation: WidgetStateProperty.all(0.0),
                backgroundColor: WidgetStateProperty.all(
                  context.theme.colorScheme.primaryContainer,
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                hintText: 'Search title',
                onChanged: (value) {
                  debouncer.run(() {
                    context.read<TodoBloc>().add(
                          TodoEvent.changeSearchTitle(value),
                        );
                  });
                },
              ),
            ),
            BlocBuilder<TodoBloc, TodoState>(
              buildWhen: (previous, current) {
                return previous.filterStatus != current.filterStatus;
              },
              builder: (context, state) {
                final filterStatus = state.filterStatus;
                return Wrap(
                  spacing: 8.0,
                  children: [
                    ChoiceChip(
                      label: Text('All'),
                      selected: filterStatus == null,
                      onSelected: (selected) {
                        if (selected) {
                          context
                              .read<TodoBloc>()
                              .add(TodoEvent.changeFilterStatus(null));
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('Pending'),
                      selected: filterStatus?.name == TodoStatus.pending.name,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<TodoBloc>().add(
                                TodoEvent.changeFilterStatus(
                                    TodoStatus.pending),
                              );
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('In Progress'),
                      selected:
                          filterStatus?.name == TodoStatus.inProgress.name,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<TodoBloc>().add(
                                TodoEvent.changeFilterStatus(
                                  TodoStatus.inProgress,
                                ),
                              );
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('Completed'),
                      selected: filterStatus?.name == TodoStatus.completed.name,
                      onSelected: (selected) {
                        if (selected) {
                          context.read<TodoBloc>().add(
                                TodoEvent.changeFilterStatus(
                                  TodoStatus.completed,
                                ),
                              );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<TodoBloc, TodoState>(
                builder: (context, state) {
                  if (state.isFetching && state.page == 1) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (state.todos?.isLeft() == true) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.todos?.asLeft().message ?? ''),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<TodoBloc>()
                                  .add(TodoEvent.getTodos());
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final todos = state.todos?.asRight();
                  if (todos?.data?.isEmpty == true) {
                    return Center(
                      child: Text('No data found, try to create one'),
                    );
                  }
                  return ListView.builder(
                    itemCount: (todos?.data?.length ?? 0) + 1,
                    itemBuilder: (context, index) {
                      if (index == todos?.data?.length) {
                        if (todos?.data?.length == todos?.total) {
                          return SizedBox();
                        }

                        return state.isFetching
                            ? Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<TodoBloc>().add(
                                          TodoEvent.changePage(state.page + 1),
                                        );
                                  },
                                  child: Text('Load More'),
                                ),
                              );
                      }
                      final todo = todos?.data?[index];
                      return ListTile(
                        title: Text(
                          todo?.title ?? '',
                          style: context.textTheme.headlineSmall?.copyWith(
                            decoration: todo?.status == TodoStatus.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          '${todo?.description ?? ''}\n${todo?.dueDate?.formatDateTime() ?? ''}\n${todo?.status?.name ?? ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => updateTodo(todo),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => deleteTodo(todo?.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormTodoBottomSheetModal extends StatefulWidget {
  final Todo? todo;
  const _FormTodoBottomSheetModal([this.todo]);

  @override
  State<_FormTodoBottomSheetModal> createState() =>
      _FormTodoBottomSheetModalState();
}

class _FormTodoBottomSheetModalState extends State<_FormTodoBottomSheetModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController(
    text: DateTime.now().formatDateTime(),
  );
  var _status = TodoStatus.pending;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title ?? '';
      _descriptionController.text = widget.todo!.description ?? '';
      _dueDateController.text = widget.todo!.dueDate?.formatDateTime() ?? '';
      _status = widget.todo!.status ?? TodoStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dueDateController,
                      decoration: InputDecoration(labelText: 'Due Date'),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: (){
                          final currentState = _dueDateController.text.toDateTime();
                          if(currentState.isBefore(DateTime.now())){
                            return DateTime.now();
                          } else {
                            return currentState;
                          }
                        }(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        final current = _dueDateController.text.toDateTime();
                        _dueDateController.text = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          current.hour,
                          current.minute,
                        ).formatDateTime();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: (){
                          final currentState = _dueDateController.text.toDateTime();
                          return TimeOfDay.fromDateTime(currentState);
                        }(),
                      );
                      if (selectedTime != null) {
                        final current = _dueDateController.text.toDateTime();
                        _dueDateController.text = DateTime(
                          current.year,
                          current.month,
                          current.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ).formatDateTime();
                      }
                    },
                  ),
                ],
              ),
              // status
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: Text('Pending'),
                    selected: _status == TodoStatus.pending,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _status = TodoStatus.pending;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text('In Progress'),
                    selected: _status == TodoStatus.inProgress,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _status = TodoStatus.inProgress;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: Text('Completed'),
                    selected: _status == TodoStatus.completed,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _status = TodoStatus.completed;
                        });
                      }
                    },
                  ),
                ],
              ),
              BlocConsumer<TodoFormBloc, TodoFormState>(
                listenWhen: (previous, current) {
                  return previous.isSubmitting != current.isSubmitting ||
                      previous.result != current.result;
                },
                listener: (context, state) {
                  if (state.result?.isRight() == true && !state.isSubmitting) {
                    context.read<TodoBloc>().add(TodoEvent.getTodos());
                    Navigator.pop(context);
                  }
                  if (state.result?.isLeft() == true && !state.isSubmitting) {
                    context.showErrorToast(
                      state.result?.asLeft().message ?? '',
                    );
                  }
                },
                builder: (context, state) {
                  if (state.isSubmitting) {
                    return CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: () {
                      final data = Todo(
                        id: widget.todo?.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        dueDate: _dueDateController.text.toDateTime(),
                        status: _status,
                      );
                      if (widget.todo != null) {
                        context.read<TodoFormBloc>().add(
                              TodoFormEvent.updateTodo(todo: data),
                            );
                        return;
                      }

                      context.read<TodoFormBloc>().add(
                            TodoFormEvent.createTodo(
                              todo: data,
                            ),
                          );
                    },
                    child: Text(widget.todo == null ? 'Create' : 'Update'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
