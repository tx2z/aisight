---
title: "Informativa sulla Privacy"
description: "Informativa sulla Privacy di AISight. Non raccogliamo, memorizziamo o trasmettiamo i tuoi dati personali. L'elaborazione IA avviene per impostazione predefinita sul tuo dispositivo."
layout: "single"
---

# Informativa sulla Privacy

*Ultimo aggiornamento: 11 novembre 2026*

## Il Nostro Impegno per la Privacy

AISight è progettato con la privacy come principio fondamentale. Non raccogliamo, memorizziamo o trasmettiamo i tuoi dati personali a server esterni da noi gestiti. Non ci sono analisi, tracciamento, pubblicità o account utente. I tuoi dati restano sul tuo dispositivo. Le uniche eccezioni sono le richieste di rete e l'elaborazione IA descritte di seguito.

## Informazioni Che Non Raccogliamo

AISight non raccoglie:

- Identificatori personali (nome, e-mail, numero di telefono)
- Identificatori del dispositivo a scopo di tracciamento
- Dati di posizione
- Analisi di utilizzo o telemetria
- Identificatori pubblicitari
- Cookie o impronte digitali del browser

Non vendiamo, noleggiamo, condividiamo o monetizziamo mai i dati degli utenti — mai.

## Dati Memorizzati sul Tuo Dispositivo

AISight memorizza i seguenti dati localmente, solo sul tuo dispositivo:

**Cronologia delle ricerche:** Le tue query di ricerca e le risposte generate dall'IA vengono salvate sul tuo dispositivo utilizzando il framework SwiftData di Apple. Questi dati non lasciano mai il tuo dispositivo a meno che tu non scelga di condividerli.

**Preferenze:** Le impostazioni dell'app (preferenze linguistiche, URL del server SearXNG) sono memorizzate in UserDefaults sul tuo dispositivo.

Puoi eliminare tutti i dati memorizzati localmente in qualsiasi momento da Impostazioni → Dati → Elimina tutti i dati.

Impostazioni del provider IA personalizzato: se configuri un provider IA personalizzato, il suo URL, il nome del modello e la dimensione del contesto sono salvati in UserDefaults sul tuo dispositivo, mentre la chiave API è salvata nel portachiavi del dispositivo, solo su questo dispositivo. L'eliminazione di tutti i dati dalle Impostazioni li rimuove.

## Dati Trasmessi sulla Rete

AISight effettua fino a quattro tipi di richieste di rete:

1. **Query di ricerca:** Quando esegui una ricerca, la tua query viene inviata al server SearXNG che hai configurato. AISight non gestisce questo server — sei tu a fornirlo e controllarlo. La privacy delle tue query di ricerca dipende dalla configurazione della tua istanza SearXNG.

2. **Recupero di contenuti web:** AISight recupera pagine web pubblicamente accessibili dagli URL restituiti dai risultati di ricerca per estrarre contenuto testuale per la sintesi con IA. Si tratta di richieste HTTP standard, simili alla visita di un sito web in un browser.

AISight non aggiunge parametri di tracciamento, intestazioni personalizzate o informazioni identificative a queste richieste oltre a quanto è standard per il caricamento di URL su iOS/macOS.

3. Apple Private Cloud Compute (facoltativo): Solo se lo attivi in Impostazioni, la tua domanda, il testo estratto dalle fonti web e le istruzioni per l'IA vengono inviati al servizio Private Cloud Compute di Apple per scrivere la risposta.

4. Provider IA personalizzato (facoltativo): Solo se ne configuri uno e confermi l'avviso in Impostazioni, la tua domanda, il testo estratto dalle fonti web e le istruzioni per l'IA vengono inviati al server di quel provider. La Ricerca approfondita invia più richieste per domanda. Si applicano i termini e le pratiche sulla privacy del provider.

## Elaborazione IA

Per impostazione predefinita, tutta l'elaborazione IA in AISight avviene interamente sul tuo dispositivo utilizzando il framework FoundationModels di Apple (Apple Intelligence). Le tue query, i risultati di ricerca e le risposte generate non vengono inviati a nessun servizio di IA cloud. Se scegli «Apple Private Cloud Compute» in Impostazioni → Modello IA, la tua query e i risultati di ricerca necessari per scrivere una risposta vengono invece elaborati sui server Private Cloud Compute di Apple, con le protezioni della privacy di Apple per quel servizio. Puoi tornare al dispositivo in qualsiasi momento. Se configuri un provider IA personalizzato in Impostazioni → Modello IA e confermi l'avviso, la tua domanda, il testo estratto dalle fonti web e le istruzioni per l'IA vengono inviati a tale provider secondo i suoi termini; la Ricerca approfondita invia più richieste. La chiave API è salvata nel portachiavi del tuo dispositivo e viene inviata solo a quel provider.

## Servizi di Terze Parti

AISight stesso non si integra con servizi di analisi, pubblicità, segnalazione di errori o raccolta dati di terze parti.

La tua istanza SearXNG auto-ospitata può avere le proprie pratiche relative ai dati a seconda di come è configurata. Ti consigliamo di consultare la documentazione di SearXNG per i dettagli.

Le pagine web recuperate durante la ricerca possono contenere i propri meccanismi di tracciamento, ma AISight estrae solo contenuto in testo semplice e non esegue JavaScript né carica risorse di tracciamento.

## Privacy dei Minori

AISight non raccoglie consapevolmente informazioni personali da nessuno, inclusi i minori di 13 anni. Dato che non raccogliamo dati personali, non ci sono dati di minori da gestire. Tuttavia, il contenuto generato dall'IA potrebbe non essere sempre appropriato per tutte le età. Si raccomanda la supervisione dei genitori.

## I Tuoi Diritti

Poiché AISight non raccoglie né memorizza i tuoi dati personali su alcun server esterno, molti diritti tradizionali sui dati sono soddisfatti per design:

- **Diritto di accesso:** Tutti i tuoi dati sono memorizzati localmente sul tuo dispositivo e sono accessibili a te.
- **Diritto alla cancellazione:** Puoi eliminare tutti i dati dell'app dalle Impostazioni in qualsiasi momento, oppure eliminando l'app.
- **Diritto alla portabilità dei dati:** I tuoi dati sono memorizzati in formati standard sul tuo dispositivo.
- **Diritto di opporsi alla vendita:** Non vendiamo mai i tuoi dati.

Questi diritti si applicano agli utenti di tutte le giurisdizioni, inclusi quelli coperti dal Regolamento Generale sulla Protezione dei Dati (GDPR) dell'UE e dal California Consumer Privacy Act (CCPA).

## Sicurezza

I tuoi dati sono protetti dalle funzionalità di sicurezza integrate nel tuo dispositivo Apple, tra cui la crittografia del dispositivo, il sandboxing delle app e i blocchi biometrici o tramite codice. Poiché AISight memorizza i dati solo sul tuo dispositivo utilizzando i framework di Apple, i tuoi dati beneficiano dell'intera architettura di sicurezza di iOS e macOS.

Le richieste di rete alla tua istanza SearXNG e ai siti web di origine utilizzano la crittografia HTTPS standard quando il server la supporta.

## Conservazione dei Dati

La cronologia delle ricerche viene conservata sul tuo dispositivo fino a quando non la elimini esplicitamente. Nessun dato viene conservato su server esterni da noi gestiti. Quando elimini l'app, tutti i dati memorizzati localmente vengono rimossi. L'eliminazione di tutti i dati dalle Impostazioni rimuove anche la chiave API e le impostazioni del tuo provider personalizzato.

## Questo Sito Web

Questo sito web (private-search-intelligence.app) non utilizza cookie, analisi o tracciamento. Il modulo di contatto invia il tuo messaggio direttamente via e-mail e non memorizziamo i tuoi dati su alcun server.

## Modifiche a Questa Informativa

Potremmo aggiornare questa informativa sulla privacy di volta in volta. Le modifiche saranno riportate nell'app con una data di "Ultimo aggiornamento" aggiornata. L'uso continuato dell'app dopo le modifiche costituisce accettazione dell'informativa aggiornata.

## Contatti

Per domande su questa informativa sulla privacy, contattaci all'indirizzo [jesus@perezpaz.es](mailto:jesus@perezpaz.es).
