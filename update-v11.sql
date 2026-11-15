-- ILÈA RESORT V11 — ESEGUIRE UNA SOLA VOLTA, DOPO BACKUP D1 PRODUCTION.
-- Richiede che la V10 sia già stata installata. Non elimina né riscrive gli ordini.
ALTER TABLE orders ADD COLUMN delivery_planned_time TEXT;
ALTER TABLE orders ADD COLUMN delivery_plan_confirmed_at TEXT;
INSERT OR IGNORE INTO settings(key,value) VALUES
 ('slot_pickup_grace_bowls','2'),
 ('delivery_gap_minutes','15');
-- ATTENZIONE: slot_capacity passa da "ordini" a "Poké".
-- Per non imporre una nuova capienza senza il consenso del ristorante,
-- manteniamo il valore esistente: aggiornarlo dal gestionale (es. 20 Poké).
CREATE INDEX IF NOT EXISTS ix_orders_bowl_capacity ON orders(pickup_date,pickup_time,status);
