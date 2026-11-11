# Ilèa Resort — Poké online + gestionale

Progetto Cloudflare Workers + asset statici + database D1. Nessun framework UI e nessun servizio di pagamento richiesto.

## Funzionalità incluse

- Sito responsive in `/` con configuratore Starter Bowl basato sul menù cartaceo fornito.
- 1 base, 2 proteine, 3 mix, 1 croccante inclusi; supplementi automatici rispettivamente 3 €, 1,50 €, 1 €; salse gratuite con scelta normale/abbondante.
- Carrello con più Poké, quantità, riepilogo, dati cliente, note e prenotazione slot.
- Ordini salvati in D1, controllo disponibilità/limiti sul server, conferma manuale titolare.
- Pannello `/admin` con login, stati ordine, stampa comanda, collegamento WhatsApp precompilato, registro invio manuale, pagamento registrato al ritiro.
- Disponibilità ingredienti, aggiunta e rinomina, allergeni configurabili, modifica prezzo base e supplementi, orari/chiusure, testi del sito, apertura/chiusura ordini.
- Aggiornamento ordini ogni 12 secondi con segnale sonoro quando il pannello è aperto e il browser consente l'audio.
- Notifica email automatica nuovi ordini **solo se configurata** tramite Resend.

## Pubblicazione su Cloudflare (Workers, non Pages)

1. Crea un repository GitHub con questi file alla radice. Non caricare la cartella `node_modules` né il file `.dev.vars`.
2. Crea su Cloudflare **Workers & Pages → D1 → Create Database** un database chiamato `ilea-poke`.
3. Copia il suo **database ID** e sostituisci `INSERISCI_ID_DATABASE_D1` nel file `wrangler.jsonc`.
4. In locale (Node.js 20+): `npm install`.
5. Applica lo schema alla D1 **remota** una sola volta su database vuoto: `npx wrangler login`, poi `npm run db:remote`. **Non rieseguire questo comando su un database già configurato**: lo schema iniziale serve solo al primo avvio.
6. Imposta i segreti del Worker (non nel codice):

   ```bash
   npx wrangler secret put ADMIN_PASSWORD
   npx wrangler secret put SESSION_SECRET
   ```

   `ADMIN_PASSWORD` deve essere unica e robusta; `SESSION_SECRET` deve essere una stringa casuale di **almeno 32 caratteri**.
7. Pubblica: `npm run deploy`. Oppure configura su Cloudflare la build/deploy dal repository GitHub per il Worker.
8. Accedi a `https://<nome-worker>.<account>.workers.dev/admin` e configura **indirizzo, giorni e orari di ritiro, prezzi, allergeni, ingredienti e privacy**.
9. Per la notifica email a ogni ordine configura anche **RESEND_API_KEY** (segreto), **ORDER_NOTIFY_EMAIL** e **EMAIL_FROM** (variabili o segreti). Il dominio mittente deve essere autorizzato su Resend. Senza configurazione l'ordine viene comunque salvato, ma non arriva alcuna email.
10. Configura, se vuoi, un dominio personalizzato e imposta `APP_ORIGIN` sull'URL pubblico, senza slash finale (ad esempio `https://poke.iltuodominio.it`).
11. **Attiva gli ordini** dal gestionale → Impostazioni **solo dopo** i controlli finali.

### Attenzione ai segreti

Per una configurazione da GitHub, aggiungi i segreti nell'interfaccia Cloudflare (**Worker → Settings → Variables and Secrets**). Non mettere mai password o chiavi email in `wrangler.jsonc`, JavaScript client o nel repository pubblico. Per test locale, copia `.dev.vars.example` in `.dev.vars` e inserisci valori privati.

### Date e orari

Tutti gli slot seguono il fuso `Europe/Rome`. Il ristorante è inizialmente **disattivato agli ordini** e il calendario preimpostato è **solo dimostrativo**, da sostituire prima di aprire. La disponibilità tiene conto degli ordini in attesa, accettati, in preparazione e pronti. Il cliente non può selezionare una fascia piena. È disponibile un intervallo di prenotazione configurabile.

### WhatsApp

Dopo aver accettato un ordine, premi **WhatsApp** per aprire `wa.me` con un messaggio già compilato (contiene cliente, giorno, ora, Poké e totale). Il titolare deve **premere Invia nell'app WhatsApp**: la piattaforma NON invia il messaggio automaticamente. Il pulsante **Segna WhatsApp inviato** serve solo a registrare manualmente la comunicazione dopo l'invio; il clic sul link non è prova di consegna.

### Allergeni, privacy e condizioni commerciali

I nomi ingredienti sono stati trascritti dal foglio del ristorante. I relativi allergeni **non sono precompilati**, perché devono essere verificati dall'attività per ricetta e contaminazioni crociate. Il titolare deve completare gli allergeni, predisporre l'informativa privacy e verificare i prezzi prima dell'attivazione. Le richieste per allergie nelle note **non garantiscono** un prodotto privo di allergeni: è necessaria conferma diretta del locale.

L'ordine è una **richiesta** fino a quando il ristorante non lo accetta. L'importo registrato come incassato è indicativo, **non** costituisce documento fiscale né sostituisce il registratore telematico. Il progetto non gestisce scontrini fiscali, fatture o integrazioni di cassa.

### Limiti della prima versione

- Un solo titolare/credenziale admin; nessun ruolo aggiuntivo.
- Niente invio WhatsApp automatico e nessun pagamento online.
- Email solo con provider Resend configurato (eventuali costi dipendono dal piano del provider).
- Non c'è uno storico audit dettagliato di modifiche o un sistema di backup automatico personalizzato. D1 offre strumenti Cloudflare per backup/ripristino da gestire separatamente.
- Numero WhatsApp cliente: il link presume un numero valido in formato internazionale (preferibilmente `+39...`).
- Le notifiche sonore richiedono il gestionale aperto e il permesso di riproduzione audio del browser.
- Gli ordini sono limitati a 12 righe/30 Poké; report economici avanzati, newsletter e invio automatico notifiche cliente non inclusi.
- Lato cliente è disponibile il controllo dello stato dopo l'invio nella pagina di conferma; un aggiornamento della pagina non ripristina ancora automaticamente la schermata di stato.

## Comandi

```bash
npm install
npm run db:local
npm run dev
npm run db:remote
npm run deploy
npm run check
```

## Struttura semplificata

Unica cartella: `public/` per i file visibili del sito. Nessuna cartella `api`, `src` o `migrations`: le rotte `/api/...` sono gestite internamente da `worker.js` e non corrispondono a cartelle.

## File

- `worker.js` — API e autenticazione del Worker.
- `schema.sql` — schema e menù iniziale D1.
- `public/index.html`, `public/app.js` — sito clienti.
- `public/admin.html`, `public/admin.js` — gestionale titolare.
- `public/styles.css` — grafica responsive.
- `public/logo.png` — logo tratto dall'immagine fornita.
