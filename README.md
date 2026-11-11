# Ilèa Resort — versione Cloudflare Pages (compatibile con D1 esistente)

## Correzione

Il precedente `worker.js` era configurato per Workers. Su Cloudflare **Pages** il codice backend ora si trova in `public/_worker.js`, che Pages riconosce come **Pages Functions advanced mode**. Non occorre una cartella `api` né una cartella `functions`.

`public/_routes.json` fa eseguire il backend soltanto sulle URL `/api/*` e `/admin`; gli altri file sono statici. `/admin` continua ad aprire `admin.html`.

## Pubblicazione sul progetto Pages esistente

1. Carica **il contenuto** di questo ZIP nella radice dello **stesso repository GitHub** collegato a Pages, sostituendo i file esistenti e **rimuovendo** i precedenti `worker.js` e `wrangler.jsonc` dalla radice. Non caricare lo ZIP come singolo file su GitHub.
2. In Cloudflare Pages > progetto > **Builds & deployments / Settings**, imposta **Build command** vuoto (nessun comando di build); **Build output directory** `public`; **Root directory** radice del repository.
3. Su **Pages > Settings > Bindings**, verifica il collegamento D1 esistente: nome binding esatto `DB`, database `ilea-poke`. Verifica sia ambiente **Production** sia Preview se li utilizzi. Se modifichi il binding, ridistribuisci il sito.
4. Su **Pages > Settings > Variables and Secrets** (le voci possono variare), controlla che `ADMIN_PASSWORD` e `SESSION_SECRET` siano configurati **per il progetto Pages** (e nell'ambiente Production). `SESSION_SECRET` >= 32 caratteri. Non scrivere password nel repository.
5. Lascia gli ordini disattivati finché non hai completato i test. Nessuna nuova inizializzazione del database è necessaria.
6. Attendi che il nuovo commit termini il deploy; apri `https://TUODOMINIO/api/public/config`: deve mostrare un oggetto JSON. Poi prova `/admin` e accedi.

## Diagnosi rapida

- Se `/api/public/config` mostra `<!doctype html>` o la homepage, significa che `_worker.js` non è stato distribuito correttamente: controlla `public` come directory di output e il deploy GitHub.
- Se la risposta è JSON `Database non collegato`, manca il binding `DB` nel progetto Pages o nell'ambiente corretto.
- Se ritorna JSON con un messaggio di errore interno, consulta Pages > Logs (Functions), e verifica che lo schema SQL sia già presente in D1.
- Se il login dice `Credenziali admin non configurate`, ricontrolla i segreti **del progetto Pages**.
- Se il login dice `Password non corretta`, il backend funziona: ricontrolla la password.

## Notifiche email

Per le email serve configurare nel progetto Pages `RESEND_API_KEY`, `ORDER_NOTIFY_EMAIL`, `EMAIL_FROM`, oltre al dominio autorizzato nel servizio email. Senza questi valori gli ordini vengono comunque registrati, ma non vengono recapitate email.

## Contenuto

- `public/_worker.js`: API, autenticazione, integrazione D1 e gestione statica in Pages
- `public/_routes.json`: instradamento selettivo
- `public/index.html`, `app.js`, `admin.html`, `admin.js`, `styles.css`, `logo.png`: sito e pannello
- `schema.sql`: riferimento per lo schema già installato
- `package.json`: comandi opzionali per sviluppo locale e deploy CLI

**Il database remoto rimane invariato.**
