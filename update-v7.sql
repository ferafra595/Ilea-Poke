-- ILÈA RESORT V7 — eseguire su D1 Production dopo backup.
-- Eseguire UNA SOLA VOLTA. Non eliminare ordini esistenti.
CREATE TABLE IF NOT EXISTS ingredient_images (
  ingredient_id TEXT PRIMARY KEY REFERENCES ingredients(id) ON DELETE CASCADE,
  mime TEXT NOT NULL,
  data_base64 TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS order_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  old_value TEXT,
  new_value TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX IF NOT EXISTS ix_order_events_order ON order_events(order_id,created_at);
CREATE TABLE IF NOT EXISTS request_limits (
  limit_key TEXT PRIMARY KEY,
  hits INTEGER NOT NULL,
  reset_at INTEGER NOT NULL
);
-- La tabella orders della V4 ha un CHECK che non consente 'no_show'.
-- La ricreazione mantiene colonne e righe esistenti; se la migrazione viene interrotta,
-- utilizzare il backup D1 prima di riprovare.
ALTER TABLE orders RENAME TO orders_v7_old;
CREATE TABLE orders (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 public_id TEXT NOT NULL UNIQUE,
 public_token TEXT NOT NULL UNIQUE,
 customer_name TEXT NOT NULL,
 phone TEXT NOT NULL,
 pickup_date TEXT NOT NULL,
 pickup_time TEXT NOT NULL,
 notes TEXT NOT NULL DEFAULT '',
 status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','accepted','preparing','ready','completed','rejected','cancelled','no_show')),
 items_json TEXT NOT NULL,
 total_cents INTEGER NOT NULL,
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
 whatsapp_sent_at TEXT,
 email_status TEXT NOT NULL DEFAULT 'not_configured',
 payment_status TEXT NOT NULL DEFAULT 'unpaid',
 admin_notes TEXT NOT NULL DEFAULT '',
 client_request_id TEXT UNIQUE
);
INSERT INTO orders(id,public_id,public_token,customer_name,phone,pickup_date,pickup_time,notes,status,items_json,total_cents,created_at,updated_at,whatsapp_sent_at,email_status,payment_status,admin_notes)
SELECT id,public_id,public_token,customer_name,phone,pickup_date,pickup_time,notes,status,items_json,total_cents,created_at,updated_at,whatsapp_sent_at,email_status,payment_status,admin_notes FROM orders_v7_old;
DROP TABLE orders_v7_old;
CREATE INDEX IF NOT EXISTS ix_orders_day ON orders(pickup_date,pickup_time,status);
CREATE INDEX IF NOT EXISTS ix_orders_created ON orders(created_at);
CREATE INDEX IF NOT EXISTS ix_orders_phone ON orders(phone,created_at);
INSERT OR IGNORE INTO settings(key,value) VALUES
 ('privacy_controller',''),('privacy_contact',''),('privacy_retention_days','365'),('privacy_policy_enabled','false');
