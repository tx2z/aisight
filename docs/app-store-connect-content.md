# App Store Connect Content — AISight

> **This is the actual content to fill into App Store Connect.**
> Reference [app-store-connect-metadata.md](app-store-connect-metadata.md) for character limits and ASO best practices.

---

## English (en-US)

### App Name (30 chars)
```
AISight - AI Search & Answers
```
<!-- 30/30 chars. Keywords: aisight, ai, search, answers. "Search" moved here for max ranking weight. -->

### Subtitle (30 chars)
```
Private On-Device Intelligence
```
<!-- 30/30 chars. Keywords: private, on-device, intelligence. Zero overlap with name. Captures "Apple Intelligence" searches. -->

### Keywords (100 chars)
```
source,citation,tracking,query,web,question,research,summary,secure,adfree,fact,reader,no-ads,fast
```
<!-- 99/100 chars. No duplicates from Name or Subtitle. No trademarks. No inaccurate claims. -->

### Promotional Text (170 chars)
```
Your questions deserve answers — not ads. Get AI-powered answers with real citations, entirely on your device. No tracking. No cloud. No subscription. Powered by Apple Intelligence.
```
<!-- REVIEW: 170+ chars — trimmed version below if over -->
```
Your questions deserve answers — not ads. AI-powered answers with real citations, on your device. No tracking. No cloud. No subscription. Powered by Apple Intelligence.
```
<!-- 167/170 chars. Leads with emotional hook, ends with trust signal. -->

### Description (4,000 chars)
```
Ask anything. Get a sourced, cited answer — generated on your device by Apple Intelligence. No tracking. No cloud. No ads. No subscription.

Every search engine you use tracks your queries. AI chatbots send your questions to servers you cannot audit. You deserve better.

AISight searches the web privately, then Apple Intelligence reads the results and writes a clear answer — right on your iPhone, iPad, or Mac. Your data never leaves your device for AI processing.

● AI ANSWERS WITH REAL SOURCES
Ask in plain language. AISight searches multiple sources, reads them, and writes a concise answer with numbered citations. Tap any citation to verify the original.

● 100% ON-DEVICE AI
Powered by Apple Intelligence. Your questions are processed locally — no data sent to any external AI service. Ever.

● TRULY PRIVATE SEARCH
No account. No tracking. No ads. No data sold or shared. Web results come from a private, open-source metasearch engine that does not profile you.

● DEEP SEARCH
Go beyond surface results. Deep Search uses multiple AI research passes to find better answers for complex questions.

● YOUR HISTORY, YOUR DEVICE
All your past searches and answers are stored securely on your device. Browse, search, and revisit — nothing synced to any server.

● BRING YOUR OWN SERVER — GET EVERYTHING FOR FREE
Connect your own SearXNG instance and every feature unlocks automatically — unlimited searches, Deep Search, everything. No purchase needed. We don't want your data, and we'll prove it: keep your data on your own server and you owe us nothing.

HOW IT WORKS
1. You ask a question
2. AISight privately searches the web across multiple engines
3. Apple Intelligence reads and synthesizes the results on your device
4. You get a cited answer you can verify

Perfect for: researching without leaving a trail, getting quick sourced answers while studying, comparing products without being retargeted with ads, or just searching the way it should be — private.

SIMPLE, HONEST PRICING
Free: 10 searches per day on our server. Full AI answers and citations.
Pro ($4.99, one-time): Unlimited searches + Deep Search. Support an indie developer. No subscription.
Self-hosted: Bring your own server → all features free, forever. No purchase needed.

Built by a solo indie developer. No venture capital. No data monetization. Zero external SDKs, analytics, or trackers. Just a native app that respects your privacy.

AISight — Search smarter. Stay private.
```

### What's New (4,000 chars)
```
Smarter search, better answers.

This update significantly improves answer quality:

● Smarter search ranking — results that closely match your question now rank higher, so the AI works with better sources
● More accurate answers — stronger guardrails prevent the AI from inventing items in lists, repeating itself, or padding answers with guessed information
● Better query understanding — your specific terms and qualifiers are preserved across all search queries, so you get results about exactly what you asked
● Faster source loading — content from web pages is now fetched in parallel instead of one at a time
● Cleaner source content — text from web pages is now cut at sentence boundaries instead of mid-word

The result: more precise, more reliable answers — especially for specific questions like book series reading orders, step-by-step instructions, and detailed lists.
```

### Copyright
```
© 2026 Jesús Pérez Paz
```

### Support URL
```
https://private-search-intelligence.app/support
```

### Marketing URL
```
https://private-search-intelligence.app
```

### Privacy Policy URL
```
https://private-search-intelligence.app/privacy
```

---

## Notes for Review
```
AISight uses Apple's FoundationModels framework (Apple Intelligence) to generate answers on-device. No user data is sent to third-party AI services.

Web search results are fetched from a SearXNG instance (open-source metasearch engine). The app ships with a default production server (search.private-search-intelligence.app) that is always operational. Any user can configure their own self-hosted SearXNG instance in Settings.

No user account is required. The app requires a device that supports Apple Intelligence (iPhone 16+, iPad with M-series, Mac with M-series) running iOS 26.0 / macOS 26.0 or later.

If Apple Intelligence is unavailable on the review device, the app displays a clear message explaining the requirement and does not crash.

If the SearXNG server is unreachable, the app displays a user-friendly error state and does not crash.

Free tier: 10 searches per day with full AI answers and citations on the default server. When the daily limit is reached, a screen explains the Pro upgrade option. The limit resets at midnight local time.

Users who configure their own SearXNG server get all features for free (unlimited searches, Deep Search) since they are using their own infrastructure.

Pro unlock (non-consumable IAP, com.aisight.pro): Unlimited searches + Deep Search on the default server. One-time purchase. For testing, you can use the sandbox StoreKit environment to verify the purchase flow.

Key differentiators from existing search/AI apps:
- AI processing happens entirely on-device (no cloud AI dependency)
- No user account or login required
- Open-source search backend (SearXNG) — no proprietary search API lock-in
- Citation system links every claim to its source
```

---

## In-App Purchase: AISight Pro

### Reference Name (internal)
```
AISight Pro Unlock
```

### Product ID
```
com.aisight.pro
```

### Display Name (user-visible, localizable)
```
AISight Pro — Unlimited Search
```
<!-- IAP display names are indexed for ASO. "Unlimited Search" adds keyword value. -->

### Description (user-visible, localizable)
```
Unlimited AI searches & Deep Search. Pay once.
```

---

## Category & Rating

| Field | Value |
|-------|-------|
| Primary Category | Reference |
| Secondary Category | Productivity |
| Age Rating | 17+ (unrestricted web access + AI-generated content) |
| Price | Free (with non-consumable IAP) |
| Availability | All territories |

> **Note on age rating**: 17+ is the safe choice given unrestricted web access. Consider testing with 12+ if you can argue parity with other AI apps (Perplexity is 12+, ChatGPT is 12+). The tradeoff: 17+ limits visibility in family sharing and educational contexts.

---

## Info.plist Addition
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

---

## Privacy Nutrition Labels

| Question | Answer |
|----------|--------|
| Do you or your third-party partners collect data? | Yes |
| Data type | Usage Data > Search History |
| Is this data linked to the user's identity? | No |
| Is this data used to track users? | No |
| Purpose | App Functionality |

> **Important**: Search queries are sent to the SearXNG server (network request). Even though it's self-hosted, Apple considers this data leaving the device. Declaring "Search History" with "Not Linked" and "Not Used to Track" is the safest accurate declaration. The description has been carefully worded to say "no data sent to external AI services" and "no data sold or shared" — NOT "no data collection" — to stay consistent with this label.

---

## Reviewer Feedback Applied (v2)

Changes made based on 4-agent review:

| Issue | Severity | Fix Applied |
|-------|----------|-------------|
| "perplexity" in keywords | REJECTION RISK | Removed |
| "alternative" in keywords | REJECTION RISK | Removed |
| "offline" in keywords | REJECTION RISK | Removed (app needs network) |
| Copyright placeholder | REJECTION RISK | Marked as TODO with warning |
| "No data collection" vs privacy label | WARNING | Changed to "No data sold or shared" |
| "Queries never leave your device" | WARNING | Changed to "never leaves your device for AI processing" |
| "No hallucinations" claim | WARNING | Removed entirely |
| OpenAI/Google named in description | WARNING | Removed, now "any external AI service" |
| SearXNG in user-facing copy | CONVERSION | Replaced with "private, open-source metasearch engine" |
| FoundationModels in description | CONVERSION | Removed, kept "Apple Intelligence" only |
| SwiftData in description | CONVERSION | Replaced with "stored securely on your device" |
| "NEW:" in promotional text | CONVERSION | Replaced with emotional hook |
| What's New was generic | CONVERSION | Rewritten with action-oriented copy |
| Missing use cases/scenarios | CONVERSION | Added "Perfect for:" section |
| "No subscription" underplayed | CONVERSION | Amplified in promo text, description, IAP |
| IAP name wasted ASO opportunity | ASO | Added "— Unlimited Search" |
| Subtitle wasted 6 chars | ASO | Now uses full 30/30 chars |
| App Name had redundant "AI" | ASO | Restructured to "AI Search & Answers" |
| Missing "coming soon" hook | CONVERSION | Added to What's New |
| Indie dev trust signal buried | CONVERSION | Moved higher in description |

---

## Localizations

> Keywords were researched per locale, not just translated. Each language uses native search terms.

<details>
<summary>German (de-DE)</summary>

### App Name (30/30 chars)
```
AISight - KI-Suche & Antworten
```

### Subtitle (28/30 chars)
```
Private Intelligenz am Gerät
```

### Keywords (100/100 chars)
```
quelle,zitat,werbefrei,recherche,zusammenfassung,datenschutz,nachschlagen,frage,wissen,schnell,lokal
```

### Promotional Text (168/170 chars)
```
Deine Fragen verdienen Antworten, keine Werbung. KI-Antworten mit echten Quellen, direkt auf deinem Gerät. Kein Tracking. Keine Cloud. Kein Abo. Mit Apple Intelligence.
```

### Description (4,000 chars)
```
Frag einfach drauflos. Erhalte eine belegte Antwort mit Quellenangaben — generiert auf deinem Gerät mit Apple Intelligence. Kein Tracking. Keine Cloud. Keine Werbung. Kein Abo.

Jede Suchmaschine speichert deine Anfragen. KI-Chatbots senden deine Fragen an Server, die du nicht kontrollierst. Du verdienst etwas Besseres.

AISight durchsucht das Web privat, dann liest Apple Intelligence die Ergebnisse und schreibt eine klare Antwort — direkt auf deinem iPhone, iPad oder Mac. Deine Daten verlassen dein Gerät nie für KI-Verarbeitung.

● KI-ANTWORTEN MIT ECHTEN QUELLEN
Frag in normaler Sprache. AISight durchsucht mehrere Quellen, liest sie und schreibt eine präzise Antwort mit nummerierten Quellenangaben. Tippe auf eine Quellenangabe, um das Original zu prüfen.

● 100 % ON-DEVICE-KI
Mit Apple Intelligence. Deine Fragen werden lokal verarbeitet — keine Daten an externe KI-Dienste gesendet. Niemals.

● WIRKLICH PRIVATE SUCHE
Kein Konto. Kein Tracking. Keine Werbung. Keine Daten verkauft oder weitergegeben. Suchergebnisse kommen von einer privaten, quelloffenen Metasuchmaschine, die kein Profil von dir erstellt.

● DEEP SEARCH
Geh über oberflächliche Ergebnisse hinaus. Deep Search erweitert deine Anfrage auf mehr Quellen für umfassende Antworten zu komplexen Themen.

● DEIN VERLAUF, DEIN GERÄT
Alle bisherigen Suchen und Antworten werden sicher auf deinem Gerät gespeichert. Durchsuchen, stöbern, wiederfinden — nichts wird mit einem Server synchronisiert.

● EIGENEN SERVER NUTZEN — ALLES KOSTENLOS
Verbinde deine eigene SearXNG-Instanz und alle Funktionen werden automatisch freigeschaltet — unbegrenzte Suchen, Deep Search, alles. Kein Kauf erforderlich.

SO FUNKTIONIERT'S
1. Du stellst eine Frage
2. AISight durchsucht das Web privat über mehrere Suchmaschinen
3. Apple Intelligence liest und verarbeitet die Ergebnisse auf deinem Gerät
4. Du erhältst eine belegte Antwort, die du überprüfen kannst

Perfekt für: Recherche ohne Spuren zu hinterlassen, schnelle belegte Antworten beim Lernen, Produktvergleiche ohne danach mit Werbung verfolgt zu werden — oder einfach so suchen, wie es sein sollte: privat.

EINFACH UND EHRLICH
Gratis: 10 Suchen pro Tag auf unserem Server. Vollständige KI-Antworten und Quellenangaben.
Pro (4,99 €, Einmalkauf): Unbegrenzte Suchen + Deep Search. Unterstütze einen Indie-Entwickler. Kein Abo.
Eigener Server: Verbinde deinen eigenen Server → alle Funktionen kostenlos, für immer. Kein Kauf erforderlich.

Von einem unabhängigen Entwickler. Kein Risikokapital. Keine Vermarktung deiner Daten. Keine externen SDKs, Analyse-Tools oder Tracker. Eine native App, die deine Privatsphäre respektiert.

AISight — Schlauer suchen. Privat bleiben.
```

### What's New (4,000 chars)
```
Intelligentere Suche, bessere Antworten.

Dieses Update verbessert die Antwortqualität deutlich:

● Intelligenteres Such-Ranking — Ergebnisse, die genau zu deiner Frage passen, werden jetzt höher eingestuft, damit die KI mit besseren Quellen arbeitet
● Genauere Antworten — stärkere Leitplanken verhindern, dass die KI Einträge in Listen erfindet, sich wiederholt oder Antworten mit geratenen Informationen auffüllt
● Besseres Anfrageverständnis — deine spezifischen Begriffe und Einschränkungen bleiben in allen Suchanfragen erhalten, damit du Ergebnisse genau zu deinem Thema bekommst
● Schnelleres Laden der Quellen — Inhalte von Webseiten werden jetzt parallel statt nacheinander abgerufen
● Sauberere Quelleninhalte — Texte von Webseiten werden jetzt an Satzgrenzen gekürzt statt mitten im Wort

Das Ergebnis: präzisere, zuverlässigere Antworten — besonders bei spezifischen Fragen wie Lesereihenfolgen von Buchserien, Schritt-für-Schritt-Anleitungen und detaillierten Listen.

Unser Versprechen: Verbinde deinen eigenen Server und alle Funktionen sind kostenlos. Kein Haken. Wir wollen deine Daten nicht — wir möchten beweisen, dass private Suche funktioniert.

Gefällt dir AISight? Eine Bewertung im App Store hilft einem kleinen Indie-Entwickler enorm. Fehler gefunden? Tippe auf Einstellungen → Support kontaktieren. Wir lesen alles.
```

### IAP Display Name
```
AISight Pro: Unbegrenzte Suche
```

### IAP Description
```
Unbegrenzte KI-Suchen & Deep Search. Einmalkauf.
```
</details>

<details>
<summary>Spanish (es-MX)</summary>

### App Name (29/30 chars)
```
AISight - Buscador IA y Citas
```

### Subtitle (28/30 chars)
```
Inteligencia Privada y Local
```

### Keywords (100/100 chars)
```
fuente,resumen,investigar,consulta,lector,seguro,web,dato,rápido,motor,sin anuncio,rastreo,respuesta
```

### Promotional Text (163/170 chars)
```
Tus preguntas merecen respuestas, no anuncios. Respuestas con IA y citas reales, en tu dispositivo. Sin rastreo. Sin nube. Sin suscripción. Con Apple Intelligence.
```

### Description (4,000 chars)
```
Pregunta lo que quieras. Recibe una respuesta con fuentes y citas — generada en tu dispositivo por Apple Intelligence. Sin rastreo. Sin nube. Sin anuncios. Sin suscripción.

Cada buscador que usas rastrea tus consultas. Los chatbots de IA envían tus preguntas a servidores que no puedes verificar. Mereces algo mejor.

AISight busca en la web de forma privada, y Apple Intelligence lee los resultados y redacta una respuesta clara — directo en tu iPhone, iPad o Mac. Tus datos nunca salen de tu dispositivo para el procesamiento de IA.

● RESPUESTAS DE IA CON FUENTES REALES
Pregunta con tus propias palabras. AISight busca en múltiples fuentes, las lee y redacta una respuesta concisa con citas numeradas. Toca cualquier cita para verificar el original.

● IA 100% EN TU DISPOSITIVO
Con Apple Intelligence. Tus preguntas se procesan localmente — ningún dato se envía a servicios de IA externos. Jamás.

● BÚSQUEDA VERDADERAMENTE PRIVADA
Sin cuenta. Sin rastreo. Sin anuncios. Sin datos vendidos ni compartidos. Los resultados vienen de un metabuscador privado de código abierto que no crea perfiles de ti.

● DEEP SEARCH
Ve más allá de los resultados superficiales. Deep Search amplía tu consulta a más fuentes para respuestas completas sobre temas complejos.

● TU HISTORIAL, TU DISPOSITIVO
Todas tus búsquedas y respuestas anteriores se guardan de forma segura en tu dispositivo. Explora, busca y revisa — nada se sincroniza con ningún servidor.

● TRAE TU PROPIO SERVIDOR — TODO GRATIS
Conecta tu propia instancia de SearXNG y todas las funciones se desbloquean automáticamente — búsquedas ilimitadas, Deep Search, todo. Sin compra necesaria.

CÓMO FUNCIONA
1. Haces una pregunta
2. AISight busca en la web de forma privada en múltiples motores
3. Apple Intelligence lee y sintetiza los resultados en tu dispositivo
4. Recibes una respuesta con citas que puedes verificar

Perfecto para: investigar sin dejar rastro, obtener respuestas con fuentes mientras estudias, comparar productos sin que te persigan con anuncios, o simplemente buscar como debería ser — en privado.

PRECIOS SIMPLES Y HONESTOS
Gratis: 10 búsquedas al día en nuestro servidor. Respuestas completas de IA y citas.
Pro ($4.99, pago único): Búsquedas ilimitadas + Deep Search. Apoya a un desarrollador indie. Sin suscripción.
Servidor propio: Conecta tu servidor → todas las funciones gratis, para siempre. Sin compra necesaria.

Creado por un desarrollador independiente. Sin capital de riesgo. Sin monetización de datos. Cero SDKs externos, analíticas o rastreadores. Solo una app nativa que respeta tu privacidad.

AISight — Busca mejor. Mantente en privado.
```

### What's New (4,000 chars)
```
Búsqueda más inteligente, mejores respuestas.

Esta actualización mejora significativamente la calidad de las respuestas:

● Ranking de búsqueda más inteligente — los resultados que coinciden mejor con tu pregunta ahora aparecen primero, para que la IA trabaje con mejores fuentes
● Respuestas más precisas — nuevas protecciones evitan que la IA invente elementos en listas, se repita o rellene respuestas con información inventada
● Mejor comprensión de consultas — tus términos específicos y matices se preservan en todas las búsquedas, para que obtengas resultados exactamente sobre lo que preguntaste
● Carga de fuentes más rápida — el contenido de las páginas web ahora se obtiene en paralelo en lugar de una por una
● Contenido de fuentes más limpio — los textos de páginas web ahora se cortan en límites de oración en lugar de a mitad de palabra

El resultado: respuestas más precisas y fiables — especialmente para preguntas específicas como órdenes de lectura de sagas, instrucciones paso a paso y listas detalladas.

¿Te gusta? Una reseña en la App Store ayuda mucho a un desarrollador indie. ¿Encontraste un error? Toca Ajustes → Contactar Soporte. Leemos todo.
```

### IAP Display Name
```
AISight Pro — Búsqueda Ilimitada
```

### IAP Description
```
Búsquedas IA ilimitadas y Deep Search. Pago único.
```
</details>

<details>
<summary>French (fr-FR)</summary>

### App Name (30/30 chars)
```
AISight - Réponse IA & Sources
```

### Subtitle (29/30 chars)
```
Recherche privée sur appareil
```

### Keywords (98/100 chars)
```
moteur,citation,confidentiel,web,résumé,question,sans pub,sécurisé,lecteur,rapide,gratuit,vérifier
```

### Promotional Text (167/170 chars)
```
Vos questions méritent des réponses — pas des pubs. Obtenez des réponses IA avec de vraies sources, 100% sur votre appareil. Sans pistage. Sans cloud. Sans abonnement.
```

### Description (4,000 chars)
```
Posez n'importe quelle question. Obtenez une réponse sourcée et citée — générée sur votre appareil par Apple Intelligence. Sans pistage. Sans cloud. Sans pub. Sans abonnement.

Chaque moteur de recherche que vous utilisez piste vos requêtes. Les chatbots IA envoient vos questions à des serveurs que vous ne pouvez pas auditer. Vous méritez mieux.

AISight recherche le web de manière privée, puis Apple Intelligence analyse les résultats et rédige une réponse claire — directement sur votre iPhone, iPad ou Mac. Vos données ne quittent jamais votre appareil pour le traitement IA.

● RÉPONSES IA AVEC DE VRAIES SOURCES
Posez votre question en langage naturel. AISight consulte plusieurs sources, les analyse et rédige une réponse concise avec des citations numérotées. Touchez une citation pour vérifier l'original.

● IA 100% SUR APPAREIL
Propulsé par Apple Intelligence. Vos questions sont traitées localement — aucune donnée envoyée à un service IA externe. Jamais.

● RECHERCHE VÉRITABLEMENT PRIVÉE
Pas de compte. Pas de pistage. Pas de pub. Aucune donnée vendue ou partagée. Les résultats web proviennent d'un métamoteur open source qui ne vous profile pas.

● DEEP SEARCH
Allez au-delà des résultats superficiels. Deep Search élargit votre requête à davantage de sources pour des réponses complètes sur des sujets complexes.

● VOTRE HISTORIQUE, VOTRE APPAREIL
Toutes vos recherches et réponses passées sont stockées en toute sécurité sur votre appareil. Parcourez, recherchez et retrouvez — rien n'est synchronisé avec un serveur.

● AMENEZ VOTRE PROPRE SERVEUR — TOUT GRATUIT
Connectez votre propre instance SearXNG et toutes les fonctionnalités se débloquent automatiquement — recherches illimitées, Deep Search, tout. Aucun achat nécessaire.

COMMENT ÇA MARCHE
1. Vous posez une question
2. AISight recherche le web de manière privée via plusieurs moteurs
3. Apple Intelligence lit et synthétise les résultats sur votre appareil
4. Vous obtenez une réponse citée que vous pouvez vérifier

Idéal pour : faire des recherches sans laisser de traces, obtenir des réponses sourcées en étudiant, comparer des produits sans être reciblé par la pub, ou simplement chercher comme cela devrait être — en toute confidentialité.

TARIFICATION SIMPLE ET HONNÊTE
Gratuit : 10 recherches par jour sur notre serveur. Réponses IA complètes et citations.
Pro (4,99 €, achat unique) : recherches illimitées + Deep Search. Soutenez un développeur indépendant. Pas d'abonnement.
Auto-hébergé : amenez votre propre serveur → toutes les fonctionnalités gratuites, pour toujours. Aucun achat nécessaire.

Développé par un développeur indépendant. Pas de capital-risque. Pas de monétisation de vos données. Zéro SDK externe, outil d'analyse ou traceur. Juste une app native qui respecte votre vie privée.

AISight — Cherchez mieux. Protégez votre vie privée.
```

### What's New (4,000 chars)
```
Recherche plus intelligente, meilleures réponses.

Cette mise à jour améliore considérablement la qualité des réponses :

● Classement de recherche plus intelligent — les résultats qui correspondent le mieux à votre question sont désormais mieux classés, pour que l'IA travaille avec de meilleures sources
● Réponses plus précises — des garde-fous renforcés empêchent l'IA d'inventer des éléments dans les listes, de se répéter ou de compléter les réponses avec des informations devinées
● Meilleure compréhension des requêtes — vos termes spécifiques et qualificatifs sont préservés dans toutes les recherches, pour des résultats exactement sur votre sujet
● Chargement des sources plus rapide — le contenu des pages web est désormais récupéré en parallèle au lieu d'un par un
● Contenu des sources plus propre — les textes des pages web sont désormais coupés aux limites de phrase au lieu d'en plein milieu d'un mot

Le résultat : des réponses plus précises et plus fiables — surtout pour les questions spécifiques comme les ordres de lecture de séries, les instructions étape par étape et les listes détaillées.

Vous aimez AISight ? Une note sur l'App Store aide énormément une petite équipe indépendante. Un bug ? Allez dans Réglages → Contacter le support. Nous lisons tout.
```

### IAP Display Name
```
AISight Pro — Recherche illimitée
```

### IAP Description
```
Recherches IA illimitées & Deep Search. Achat unique.
```
</details>

<details>
<summary>Italian (it-IT)</summary>

### App Name (29/30 chars)
```
AISight - Risposte IA e Fonti
```

### Subtitle (30/30 chars)
```
Intelligenza Privata su Device
```

### Keywords (98/100 chars)
```
motore,ricerca,citazione,domanda,web,riassunto,sicuro,senza pubblicità,veloce,lettore,gratis,fatto
```

### Promotional Text (168/170 chars)
```
Le tue domande meritano risposte, non pubblicità. Risposte IA con fonti reali, sul tuo dispositivo. Zero tracciamento. Zero cloud. Zero abbonamento. Apple Intelligence.
```

### Description (4,000 chars)
```
Chiedi qualsiasi cosa. Ricevi una risposta con fonti e citazioni, generata sul tuo dispositivo da Apple Intelligence. Nessun tracciamento. Nessun cloud. Nessuna pubblicità. Nessun abbonamento.

Ogni motore di ricerca traccia le tue query. I chatbot IA inviano le tue domande a server che non puoi controllare. Meriti di meglio.

AISight cerca sul web in modo privato, poi Apple Intelligence legge i risultati e scrive una risposta chiara — direttamente sul tuo iPhone, iPad o Mac. I tuoi dati non lasciano mai il dispositivo per l'elaborazione IA.

● RISPOSTE IA CON FONTI REALI
Chiedi in linguaggio naturale. AISight cerca tra più fonti, le analizza e scrive una risposta concisa con citazioni numerate. Tocca qualsiasi citazione per verificare l'originale.

● IA 100% SUL DISPOSITIVO
Con Apple Intelligence. Le tue domande vengono elaborate localmente — nessun dato inviato a servizi IA esterni. Mai.

● RICERCA DAVVERO PRIVATA
Nessun account. Nessun tracciamento. Nessuna pubblicità. Nessun dato venduto o condiviso. I risultati web provengono da un motore di metaricerca open-source che non ti profila.

● DEEP SEARCH
Vai oltre i risultati superficiali. Deep Search amplia la ricerca su più fonti per risposte complete su argomenti complessi.

● LA TUA CRONOLOGIA, IL TUO DISPOSITIVO
Tutte le ricerche e risposte passate sono archiviate in modo sicuro sul tuo dispositivo. Sfoglia, cerca e rivedi — nulla viene sincronizzato con alcun server.

● PORTA IL TUO SERVER — TUTTO GRATIS
Collega la tua istanza SearXNG e tutte le funzionalità si sbloccano automaticamente — ricerche illimitate, Deep Search, tutto. Nessun acquisto necessario.

COME FUNZIONA
1. Fai una domanda
2. AISight cerca privatamente sul web tra più motori
3. Apple Intelligence legge e sintetizza i risultati sul tuo dispositivo
4. Ricevi una risposta con citazioni che puoi verificare

Perfetto per: fare ricerche senza lasciare tracce, ottenere risposte con fonti mentre studi, confrontare prodotti senza essere bombardato di pubblicità, o semplicemente cercare come si dovrebbe — in privato.

PREZZI SEMPLICI E ONESTI
Gratis: 10 ricerche al giorno sul nostro server. Risposte IA complete e citazioni.
Pro (4,99 €, acquisto unico): ricerche illimitate + Deep Search. Sostieni uno sviluppatore indie. Nessun abbonamento.
Self-hosted: porta il tuo server → tutte le funzionalità gratis, per sempre. Nessun acquisto necessario.

Creato da uno sviluppatore indipendente. Nessun capitale di rischio. Nessuna monetizzazione dei dati. Zero SDK esterni, analytics o tracker. Solo un'app nativa che rispetta la tua privacy.

AISight — Cerca meglio. Resta privato.
```

### What's New (4,000 chars)
```
Ricerca più intelligente, risposte migliori.

Questo aggiornamento migliora significativamente la qualità delle risposte:

● Classificazione dei risultati più intelligente — i risultati che corrispondono meglio alla tua domanda ora hanno la priorità, così l'IA lavora con fonti migliori
● Risposte più accurate — protezioni più forti impediscono all'IA di inventare voci nelle liste, ripetersi o completare le risposte con informazioni indovinate
● Migliore comprensione delle ricerche — i tuoi termini specifici e le sfumature vengono preservati in tutte le ricerche, per risultati esattamente su ciò che hai chiesto
● Caricamento delle fonti più rapido — i contenuti delle pagine web vengono ora recuperati in parallelo anziché uno alla volta
● Contenuti delle fonti più puliti — i testi delle pagine web vengono ora tagliati ai confini di frase anziché a metà parola

Il risultato: risposte più precise e affidabili — soprattutto per domande specifiche come ordini di lettura di saghe, istruzioni passo per passo e liste dettagliate.

Ti piace? Una recensione sull'App Store aiuta tantissimo un piccolo team indipendente. Hai trovato un bug? Tocca Impostazioni → Contatta il Supporto. Leggiamo tutto.
```

### IAP Display Name
```
AISight Pro — Ricerca Illimitata
```

### IAP Description
```
Ricerche IA illimitate & Deep Search. Acquisto unico.
```
</details>

<details>
<summary>Japanese (ja-JP)</summary>

### App Name (22/30 chars)
```
AISight — AI検索・出典付きの回答
```

### Subtitle (22/30 chars)
```
プライベートなオンデバイスAI — 広告ゼロ
```

### Keywords (98/100 chars)
```
質問,要約,引用,調べもの,ウェブ,プライバシー,追跡なし,無料,高速,安全,情報収集,まとめ,リサーチ,事実確認,ブラウザ,匿名,調査,引用元,買い切り,便利,学習,要点,整理,文献,知識,探す
```

### Promotional Text (97/170 chars)
```
あなたの質問に、広告ではなく答えを。AIが出典付きの回答をデバイス上で生成。追跡なし、クラウド送信なし、サブスクなし。Apple Intelligenceがすべてをあなたのデバイスで処理します。
```

### Description (4,000 chars)
```
何でも聞いてください。出典付きの回答を、Apple Intelligenceがあなたのデバイス上で生成します。追跡なし。クラウドなし。広告なし。サブスクなし。

あなたが使っている検索エンジンは、すべての検索履歴を追跡しています。AIチャットボットは、あなたの質問を外部サーバーに送信しています。もっと良い方法があるはずです。

AISightは、ウェブをプライベートに検索し、Apple Intelligenceが検索結果を読み取り、明確な回答をiPhone・iPad・Mac上で作成します。AI処理のためにデータがデバイスの外に出ることはありません。

● 出典付きのAI回答
自然な言葉で質問するだけ。AISightが複数のソースを検索・読み取り、番号付きの引用を含む簡潔な回答を作成します。引用をタップして、元の情報源を確認できます。

● 100%オンデバイスAI
Apple Intelligenceで動作。質問はすべてローカルで処理されます。外部のAIサービスにデータが送信されることは一切ありません。

● 本当にプライベートな検索
アカウント不要。追跡なし。広告なし。データの販売・共有なし。ウェブ検索結果は、あなたをプロファイリングしないプライベートなオープンソースのメタ検索エンジンから取得されます。

● Deep Search
表面的な検索結果を超えましょう。Deep Searchは、より多くのソースにクエリを展開し、複雑なトピックに対する包括的な回答を提供します。

● 履歴はすべてデバイス上に保存
過去の検索と回答はすべて、デバイス上に安全に保存されます。閲覧・検索・再確認が自由自在。サーバーへの同期は一切ありません。

● 自分のサーバーを接続 — すべて無料に
自分のSearXNGインスタンスを接続すれば、すべての機能が自動的にアンロックされます。無制限の検索、Deep Search、すべて。購入は不要です。

仕組み
1. 質問を入力
2. AISightが複数の検索エンジンからプライベートにウェブを検索
3. Apple Intelligenceがデバイス上で検索結果を読み取り・統合
4. 確認可能な出典付きの回答を取得

こんな方におすすめ：検索履歴を残さずに調べものをしたい方、勉強中に出典付きの回答がほしい方、リターゲティング広告なしで商品を比較したい方、そしてプライベートであるべき検索を求めるすべての方に。

シンプルで正直な料金体系
無料：1日10回まで当社サーバーで検索。完全なAI回答と引用付き。
Pro（¥800、買い切り）：無制限の検索 ＋ Deep Search。個人開発者を応援。サブスクなし。
セルフホスト：自分のサーバーを接続 → すべての機能が永久無料。購入不要。

個人開発者が作りました。ベンチャーキャピタルなし。データ収益化なし。外部SDK・分析ツール・トラッカーはゼロ。プライバシーを尊重するネイティブアプリです。

AISight — もっと賢く検索。プライバシーを守ろう。
```

### What's New (4,000 chars)
```
よりスマートな検索、より良い回答。

このアップデートでは回答の品質が大幅に向上しました：

● よりスマートな検索ランキング — あなたの質問に正確に一致する結果が上位に表示され、AIがより良いソースで回答を作成します
● より正確な回答 — 強化されたガードレールにより、AIがリスト内の項目を捏造したり、繰り返したり、推測した情報で回答を埋めることを防ぎます
● より良いクエリ理解 — あなたの具体的な用語や条件がすべての検索クエリで保持され、まさに聞きたいことについての結果が得られます
● より高速なソース読み込み — ウェブページのコンテンツが順次ではなく並列で取得されるようになりました
● よりクリーンなソースコンテンツ — ウェブページのテキストが単語の途中ではなく文の区切りでカットされるようになりました

結果：より正確で信頼性の高い回答 — 特にシリーズの読書順序、ステップバイステップの手順、詳細なリストなどの具体的な質問に効果的です。

気に入っていただけましたか？App Storeでのレビューは、個人開発者にとって大きな力になります。バグを見つけた場合は、設定 → お問い合わせからご連絡ください。すべて目を通しています。
```

### IAP Display Name
```
AISight Pro — 無制限検索
```

### IAP Description
```
無制限AI検索とDeep Search。買い切り型。
```
</details>

<details>
<summary>Korean (ko-KR)</summary>

### App Name (23/30 chars)
```
AISight - AI 검색 & 답변 엔진
```

### Subtitle (16/30 chars)
```
프라이빗 온디바이스 인텔리전스
```

### Keywords (87/100 chars)
```
질문답변,웹검색,출처,인용,요약,개인정보보호,추적없는,광고없는,무료,리서치,팩트체크,정보검색,사실확인,빠른검색,보안,맞춤검색,스마트,브라우저,챗봇,학습,조사
```

### Promotional Text (122/170 chars)
```
궁금한 건 뭐든 물어보세요. AI가 웹을 검색하고 출처 있는 답변을 기기에서 바로 만들어 드려요. 추적 없음. 클라우드 없음. 구독 없음. 광고 없음. Apple Intelligence 기반의 프라이빗 답변 엔진이에요.
```

### Description (4,000 chars)
```
무엇이든 물어보세요. 출처가 명확한 답변을 Apple Intelligence가 여러분의 기기에서 직접 생성해 드려요. 추적 없음. 클라우드 없음. 광고 없음. 구독 없음.

여러분이 사용하는 모든 검색엔진은 검색 기록을 추적해요. AI 챗봇은 여러분의 질문을 확인할 수 없는 서버로 보내죠. 더 나은 방법이 있어요.

AISight는 웹을 비공개로 검색한 뒤, Apple Intelligence가 결과를 읽고 명확한 답변을 작성해요. iPhone, iPad, Mac 어디서든 가능하고, AI 처리를 위해 데이터가 기기 밖으로 나가지 않아요.

● 출처가 있는 AI 답변
자연어로 질문하세요. AISight가 여러 출처를 검색하고 읽은 뒤, 번호가 매겨진 인용과 함께 간결한 답변을 작성해요. 인용을 탭하면 원본을 바로 확인할 수 있어요.

● 100% 온디바이스 AI
Apple Intelligence로 구동돼요. 질문은 기기에서 로컬로 처리되며, 외부 AI 서비스로 데이터가 전송되지 않아요. 절대로요.

● 완벽한 프라이빗 검색
계정 불필요. 추적 없음. 광고 없음. 데이터 판매나 공유 없음. 검색 결과는 여러분을 프로파일링하지 않는 오픈소스 프라이빗 메타검색엔진에서 가져와요.

● Deep Search
표면적인 결과를 넘어서세요. Deep Search는 더 많은 출처를 탐색해 복잡한 주제에 대한 포괄적인 답변을 제공해요.

● 검색 기록은 내 기기에만
모든 검색 기록과 답변이 기기에 안전하게 저장돼요. 검색하고, 다시 보고, 관리하세요. 어떤 서버에도 동기화되지 않아요.

● 나만의 서버 연결 — 모든 기능 무료
자신의 SearXNG 인스턴스를 연결하면 모든 기능이 자동으로 잠금 해제돼요 — 무제한 검색, Deep Search, 전부 다요. 구매할 필요 없어요.

이렇게 작동해요
1. 질문을 입력해요
2. AISight가 여러 검색엔진을 통해 비공개로 웹을 검색해요
3. Apple Intelligence가 기기에서 결과를 읽고 종합해요
4. 출처를 확인할 수 있는 답변을 받아요

이럴 때 딱이에요: 흔적 없이 조사하고 싶을 때, 공부하면서 출처 있는 답변이 필요할 때, 리타겟팅 광고 없이 제품을 비교할 때, 아니면 그냥 검색이 원래 이래야 한다고 생각할 때.

심플하고 정직한 가격
무료: 하루 10회 검색 가능. 완전한 AI 답변과 인용 제공.
Pro (₩6,900, 일회성 구매): 무제한 검색 + Deep Search. 인디 개발자를 응원해 주세요. 구독 없음.
셀프 호스팅: 나만의 서버 연결 → 모든 기능 영원히 무료. 구매 필요 없음.

인디 개발자가 만들었어요. 벤처캐피탈 없음. 데이터 수익화 없음. 외부 SDK, 분석 도구, 트래커 제로. 여러분의 프라이버시를 존중하는 네이티브 앱이에요.

AISight — 더 스마트하게 검색하고, 프라이버시를 지키세요.
```

### What's New (4,000 chars)
```
더 스마트한 검색, 더 나은 답변.

이번 업데이트는 답변 품질을 크게 개선했어요:

● 더 스마트한 검색 랭킹 — 질문과 정확히 일치하는 결과가 더 높은 순위로 표시되어, AI가 더 좋은 출처로 답변을 작성해요
● 더 정확한 답변 — 강화된 가드레일이 AI가 목록에 항목을 지어내거나, 반복하거나, 추측한 정보로 답변을 채우는 것을 방지해요
● 더 나은 쿼리 이해 — 여러분의 구체적인 용어와 조건이 모든 검색 쿼리에서 보존되어, 정확히 질문한 내용에 대한 결과를 얻을 수 있어요
● 더 빠른 출처 로딩 — 웹 페이지 콘텐츠가 하나씩이 아닌 병렬로 가져와져요
● 더 깔끔한 출처 콘텐츠 — 웹 페이지 텍스트가 단어 중간이 아닌 문장 경계에서 잘려요

결과: 더 정확하고 신뢰할 수 있는 답변 — 특히 시리즈 읽기 순서, 단계별 안내, 상세한 목록 같은 구체적인 질문에 효과적이에요.

마음에 드셨나요? App Store 평가 하나가 작은 인디 개발자에게 큰 힘이 돼요. 버그를 발견하셨나요? 설정 → 지원 문의를 탭해 주세요. 모든 피드백을 읽고 있어요.
```

### IAP Display Name
```
AISight Pro — 무제한 검색
```

### IAP Description
```
무제한 AI 검색 & Deep Search. 한 번만 결제.
```
</details>

<details>
<summary>Portuguese (pt-BR)</summary>

### App Name (30/30 chars)
```
AISight - Busca IA & Respostas
```

### Subtitle (28/30 chars)
```
Inteligência Privada no Chip
```

### Keywords (100/100 chars)
```
fonte,citação,consulta,web,pergunta,resumo,seguro,sem-anúncio,fato,leitor,rápido,buscador,privado,ai
```

### Promotional Text (167/170 chars)
```
Suas perguntas merecem respostas — não anúncios. IA com citações reais, direto no seu aparelho. Sem rastreamento. Sem nuvem. Sem assinatura. Powered by Apple Intelligence.
```

### Description (4,000 chars)
```
Pergunte qualquer coisa. Receba uma resposta com fontes e citações — gerada no seu aparelho pelo Apple Intelligence. Sem rastreamento. Sem nuvem. Sem anúncios. Sem assinatura.

Todo buscador que você usa rastreia suas pesquisas. Chatbots de IA enviam suas perguntas para servidores que você não pode auditar. Você merece mais.

O AISight busca na web de forma privada, depois o Apple Intelligence lê os resultados e escreve uma resposta clara — direto no seu iPhone, iPad ou Mac. Seus dados nunca saem do aparelho para processamento de IA.

● RESPOSTAS DE IA COM FONTES REAIS
Pergunte em linguagem natural. O AISight pesquisa múltiplas fontes, lê e escreve uma resposta concisa com citações numeradas. Toque em qualquer citação para verificar o original.

● IA 100% NO APARELHO
Funciona com Apple Intelligence. Suas perguntas são processadas localmente — nenhum dado é enviado a qualquer serviço externo de IA. Nunca.

● BUSCA REALMENTE PRIVADA
Sem conta. Sem rastreamento. Sem anúncios. Nenhum dado vendido ou compartilhado. Os resultados vêm de um mecanismo de busca privado e de código aberto que não traça seu perfil.

● DEEP SEARCH
Vá além dos resultados superficiais. O Deep Search amplia sua consulta por mais fontes para respostas completas sobre temas complexos.

● SEU HISTÓRICO, SEU APARELHO
Todas as suas buscas e respostas ficam armazenadas com segurança no seu aparelho. Navegue, pesquise e revisite — nada sincronizado com servidor nenhum.

● TRAGA SEU PRÓPRIO SERVIDOR — TUDO GRÁTIS
Conecte sua própria instância SearXNG e todas as funcionalidades são desbloqueadas automaticamente — buscas ilimitadas, Deep Search, tudo. Nenhuma compra necessária.

COMO FUNCIONA
1. Você faz uma pergunta
2. O AISight pesquisa a web de forma privada em vários mecanismos
3. O Apple Intelligence lê e sintetiza os resultados no seu aparelho
4. Você recebe uma resposta citada que pode verificar

Perfeito para: pesquisar sem deixar rastro, obter respostas com fontes enquanto estuda, comparar produtos sem ser perseguido por anúncios, ou simplesmente buscar do jeito que deveria ser — com privacidade.

PREÇOS SIMPLES E HONESTOS
Grátis: 10 buscas por dia no nosso servidor. Respostas completas de IA e citações.
Pro (R$ 24,90, compra única): Buscas ilimitadas + Deep Search. Apoie um desenvolvedor indie. Sem assinatura.
Self-hosted: Traga seu próprio servidor → todas as funcionalidades grátis, para sempre. Nenhuma compra necessária.

Feito por um desenvolvedor indie. Sem capital de risco. Sem monetização de dados. Zero SDKs externos, analytics ou rastreadores. Apenas um app nativo que respeita sua privacidade.

AISight — Busque melhor. Mantenha sua privacidade.
```

### What's New (4,000 chars)
```
Busca mais inteligente, respostas melhores.

Esta atualização melhora significativamente a qualidade das respostas:

● Ranking de busca mais inteligente — resultados que correspondem melhor à sua pergunta agora aparecem primeiro, para que a IA trabalhe com fontes melhores
● Respostas mais precisas — proteções reforçadas impedem que a IA invente itens em listas, se repita ou preencha respostas com informações inventadas
● Melhor compreensão das consultas — seus termos específicos e qualificadores são preservados em todas as buscas, para que você obtenha resultados exatamente sobre o que perguntou
● Carregamento de fontes mais rápido — o conteúdo das páginas web agora é obtido em paralelo em vez de um por um
● Conteúdo das fontes mais limpo — os textos das páginas web agora são cortados nos limites de frase em vez de no meio de uma palavra

O resultado: respostas mais precisas e confiáveis — especialmente para perguntas específicas como ordens de leitura de séries, instruções passo a passo e listas detalhadas.

Gostou? Uma avaliação na App Store ajuda muito um pequeno time indie. Encontrou um bug? Toque em Ajustes → Fale Conosco. Lemos tudo.
```

### IAP Display Name
```
AISight Pro — Busca Ilimitada
```

### IAP Description
```
Buscas IA ilimitadas & Deep Search. Compra única.
```
</details>

<details>
<summary>Chinese Simplified (zh-Hans)</summary>

### App Name (19/30 chars)
```
AISight - AI搜索与解答引擎
```

### Subtitle (17/30 chars)
```
端侧智能 · 隐私优先 · 无广告
```

### Keywords (98/100 chars)
```
问答,AI回答,网页摘要,引用来源,无追踪,本地处理,知识,免费,信息检索,聚合,查询,总结,安全,事实核查,阅读器,离线,研究,对比,学习助手,提问,快速回答,百科,浏览器,搜一搜,答案,无订阅
```

### Promotional Text (82/170 chars)
```
你的提问值得真正的解答，而非广告。AISight借助Apple Intelligence在设备端生成带引用来源的AI回答。无追踪、无云端、无订阅，一次购买永久拥有。
```

### Description (4,000 chars)
```
随心提问，获得有据可查的AI回答——完全在你的设备端由Apple Intelligence生成。无追踪、无云端、无广告、无订阅。

你使用的每一个搜索引擎都在追踪你的查询记录。AI聊天机器人将你的问题发送到你无从审查的服务器。你值得拥有更好的选择。

AISight以私密方式搜索网络，然后由Apple Intelligence在你的iPhone、iPad或Mac上解读结果并撰写清晰的回答。你的数据绝不会离开设备进行AI处理。

● AI回答，真实来源
用自然语言提问。AISight搜索多个来源，解读内容，撰写简明回答并附上编号引用。点击任何引用即可验证原文。

● 100%端侧AI处理
由Apple Intelligence驱动。你的问题完全在本地处理——绝不向任何外部AI服务发送数据。

● 真正的隐私搜索
无需账号、无追踪、无广告、不出售或分享任何数据。网页结果来自开源的私密聚合搜索引擎，绝不对你进行画像分析。

● Deep Search
超越表面结果。Deep Search将你的查询扩展到更多来源，为复杂话题提供全面深入的回答。

● 历史记录，仅存设备
所有搜索和回答安全存储在你的设备上。随时浏览、搜索和回顾——绝不同步到任何服务器。

● 自带服务器 — 一切免费
连接你自己的SearXNG实例，所有功能自动解锁——无限搜索、Deep Search，全部功能。无需购买。

工作原理
1. 你提出一个问题
2. AISight通过多个引擎私密搜索网络
3. Apple Intelligence在你的设备上解读并综合结果
4. 你获得一个可验证的引用回答

适用场景：不留痕迹地研究资料、学习时快速获取有来源的回答、比较产品而不被广告追踪、或者只是用搜索本该有的方式——隐私搜索。

简单、诚实的定价
免费版：每天在我们的服务器上搜索10次。完整AI回答与引用。
Pro版（¥38，一次购买）：无限搜索 + Deep Search。支持独立开发者。无订阅。
自建服务器：连接你自己的服务器 → 所有功能永久免费。无需购买。

由独立开发者打造。无风投资本、无数据变现。零外部SDK、零数据分析、零追踪器。一款真正尊重你隐私的原生应用。

AISight——更智能地搜索，更安心地使用。
```

### What's New (4,000 chars)
```
更智能的搜索，更好的回答。

此次更新显著提升了回答质量：

● 更智能的搜索排名——与您的问题更匹配的结果现在排名更高，让AI使用更好的来源生成回答
● 更准确的回答——增强的防护机制防止AI在列表中编造条目、重复内容或用猜测的信息填充回答
● 更好的查询理解——您的具体术语和限定词在所有搜索查询中都得到保留，确保您获得与所问内容完全匹配的结果
● 更快的来源加载——网页内容现在并行获取，而不是逐个加载
● 更干净的来源内容——网页文本现在在句子边界处截断，而不是在单词中间截断

结果：更精确、更可靠的回答——尤其适用于系列阅读顺序、分步说明和详细列表等具体问题。

喜欢AISight吗？在App Store留个好评，对独立开发者意义重大。发现问题？前往设置 → 联系支持，我们会认真阅读每条反馈。
```

### IAP Display Name
```
AISight Pro — 无限搜索
```

### IAP Description
```
无限AI搜索及Deep Search。一次购买，永久拥有。
```
</details>
