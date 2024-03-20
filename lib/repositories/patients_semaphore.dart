import 'dart:async';

enum PatientTask {
  pictureLoad,
}

class PatientsSemaphore {
  final Map<int, TaskSemaphore> patientLocks = {};

  TaskSemaphore? get(int patientId) => patientLocks[patientId];

  TaskSemaphore getOrCreate(int patientId) {
    var instance = get(patientId);
    if (instance != null) return instance;
    var patientSemaphore = TaskSemaphore();
    patientLocks[patientId] = patientSemaphore;
    return patientSemaphore;
  }

  Future<bool> lockWhile({
    required int patientId,
    required PatientTask task,
    required FutureOr<void> Function() func,
    bool abortIfLocked = true,
  }) async {
    var semaphore = getOrCreate(patientId);
    var result = await semaphore.lockWhile(
      task: task,
      func: func,
      abortIfLocked: abortIfLocked,
    );
    if (semaphore.isEmpty) patientLocks.remove(patientId);
    return result;
  }
}

class TaskSemaphore {
  final Set<PatientTask> _locks = {};

  bool has(PatientTask task) => _locks.contains(task);

  bool get isEmpty => _locks.isEmpty;

  void lock(PatientTask task) {
    if (has(task)) throw Exception('Task already in execution');
    _locks.add(task);
  }

  /// If [abortIfLocked] is `false` and the task is locked, an Exception will
  /// be thrown.
  ///
  /// Returns `true` if [func] was executed.
  Future<bool> lockWhile({
    required PatientTask task,
    required FutureOr<void> Function() func,
    bool abortIfLocked = true,
  }) async {
    if (has(task)) {
      if (abortIfLocked) {
        return false;
      } else {
        throw Exception('Task $task already locked');
      }
    }
    _locks.add(task);
    try {
      await func();
    } finally {
      _locks.remove(task);
    }
    return true;
  }
}
