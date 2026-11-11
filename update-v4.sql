-- Ilèa Resort V4: applicare UNA volta sulla console D1 Production.
-- Mantiene inalterati ordini, ingredienti e impostazioni esistenti.
CREATE TABLE IF NOT EXISTS site_images (
  slot TEXT PRIMARY KEY CHECK(slot IN ('logo','hero','secondary')),
  mime TEXT NOT NULL,
  data_base64 TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
INSERT OR IGNORE INTO settings(key,value) VALUES
  ('instagram_url',''),
  ('facebook_url','');
UPDATE settings SET value='Ilèa Resort, Via G. Garibaldi 212, 88837 Foresta (KR)'
WHERE key='restaurant_address' AND (value IS NULL OR TRIM(value)='');
