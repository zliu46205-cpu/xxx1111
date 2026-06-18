CREATE TABLE IF NOT EXISTS reports (
  id TEXT PRIMARY KEY,
  created_at TEXT NOT NULL,
  method_id TEXT,
  method_name TEXT,
  question TEXT NOT NULL,
  concern_type TEXT,
  report_json TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_reports_created_at
ON reports(created_at DESC);

