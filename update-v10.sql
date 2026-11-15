-- ESEGUIRE UNA SOLA VOLTA SU D1 PRODUCTION DOPO BACKUP.
-- Non elimina né modifica gli ordini esistenti.
ALTER TABLE orders ADD COLUMN fulfillment_type TEXT NOT NULL DEFAULT 'pickup';
ALTER TABLE orders ADD COLUMN delivery_zone_id TEXT;
ALTER TABLE orders ADD COLUMN delivery_address_json TEXT;
ALTER TABLE orders ADD COLUMN delivery_fee_cents INTEGER NOT NULL DEFAULT 0;
CREATE TABLE IF NOT EXISTS delivery_zones (
 id TEXT PRIMARY KEY,
 name TEXT NOT NULL UNIQUE,
 postal_codes TEXT NOT NULL DEFAULT '',
 fee_cents INTEGER NOT NULL DEFAULT 0 CHECK(fee_cents >= 0),
 active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1)),
 sort_order INTEGER NOT NULL DEFAULT 0,
 created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_grouping ON orders(fulfillment_type,delivery_zone_id,pickup_date,pickup_time);
INSERT OR IGNORE INTO settings(key,value) VALUES ('delivery_enabled','false');
INSERT OR IGNORE INTO settings(key,value) VALUES ('delivery_order_start','15:00');
INSERT OR IGNORE INTO settings(key,value) VALUES ('delivery_order_end','19:30');
