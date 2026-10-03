PRAGMA foreign_keys = ON;
CREATE TABLE habits (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  name TEXT NOT NULL,
  icon_id TEXT NOT NULL,
  category_id TEXT NOT NULL,
  recurrence_json TEXT NOT NULL,
  cue TEXT NULL,
  minimum_version TEXT NULL,
  is_essential INTEGER NOT NULL DEFAULT 0,
  reminder_minute INTEGER NULL
);
CREATE TABLE habit_logs (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  habit_id TEXT NOT NULL REFERENCES habits(id),
  logical_date TEXT NOT NULL,
  level_id TEXT NOT NULL,
  UNIQUE(habit_id, logical_date)
);
CREATE TABLE tasks (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  title TEXT NOT NULL,
  notes TEXT NULL,
  due_date TEXT NULL,
  due_minute INTEGER NULL,
  estimated_minutes INTEGER NULL,
  priority_id TEXT NOT NULL,
  project_id TEXT NULL,
  recurrence_json TEXT NULL
);
CREATE TABLE task_completions (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  task_id TEXT NOT NULL REFERENCES tasks(id),
  occurrence_date TEXT NOT NULL,
  UNIQUE(task_id, occurrence_date)
);
CREATE TABLE routine_blocks (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  title TEXT NOT NULL,
  start_minute INTEGER NOT NULL,
  duration_minutes INTEGER NOT NULL,
  category_id TEXT NOT NULL,
  weekdays_json TEXT NOT NULL
);
CREATE TABLE focus_sessions (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  started_at INTEGER NOT NULL,
  end_at INTEGER NOT NULL,
  task_id TEXT NULL REFERENCES tasks(id)
);
CREATE TABLE xp_events (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  action_id TEXT NOT NULL,
  source_id TEXT NOT NULL,
  logical_date TEXT NOT NULL,
  units INTEGER NOT NULL,
  xp INTEGER NOT NULL,
  reversed_at INTEGER NULL,
  UNIQUE(action_id, source_id, logical_date)
);
CREATE TABLE app_preferences (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  key TEXT NOT NULL UNIQUE,
  value_json TEXT NOT NULL
);
INSERT INTO habits (
  id, created_at, updated_at, deleted_at, device_id, name, icon_id,
  category_id, recurrence_json, cue, minimum_version, is_essential,
  reminder_minute
) VALUES (
  '00000000-0000-4000-8000-000000000001', 1791028800, 1791028800, NULL,
  'fixture-device', 'Leitura', 'book', 'mind', '{"kind":"daily"}', NULL,
  NULL, 0, NULL
);
PRAGMA user_version = 1;
