enum TaskStatus {
  toDo,
  inProgress,
  done;

  String get value {
    switch (this) {
      case TaskStatus.toDo:
        return 'to_do';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  String get toReadableString {
    return switch (this) {
      TaskStatus.toDo => 'To Do',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.done => 'Done',
    };
  }

  static TaskStatus fromString(String str) {
    return switch (str) {
      'to_do' => TaskStatus.toDo,
      'in_progress' => TaskStatus.inProgress,
      'done' => TaskStatus.done,
      _ => TaskStatus.toDo,
    };
  }

  static Map<String, String> toMap() {
    return Map.fromEntries(
      TaskStatus.values.map((e) => MapEntry(e.value, e.toReadableString)),
    );
  }
}
