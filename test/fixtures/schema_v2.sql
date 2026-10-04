-- Apply after schema_v1.sql. This is the v1 -> v2 migration fixture.
CREATE TABLE workout_plans (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  title TEXT NOT NULL,
  exercises_json TEXT NOT NULL
);
CREATE TABLE workout_sessions (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  plan_id TEXT NOT NULL REFERENCES workout_plans(id),
  started_at INTEGER NOT NULL,
  ended_at INTEGER NULL
);
CREATE TABLE workout_sets (
  id TEXT NOT NULL PRIMARY KEY,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER NULL,
  device_id TEXT NOT NULL,
  session_id TEXT NOT NULL REFERENCES workout_sessions(id),
  exercise_id TEXT NOT NULL,
  set_index INTEGER NOT NULL,
  repetitions INTEGER NOT NULL,
  load_kg REAL NOT NULL,
  rest_seconds INTEGER NOT NULL,
  UNIQUE(session_id, exercise_id, set_index)
);
PRAGMA user_version = 2;
