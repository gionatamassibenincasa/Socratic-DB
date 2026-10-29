# Protocollo di sperimentazione empirica {#sec-protocollo-sperimentazione}

Prima di estendere l'adozione del sistema a più istituti o corsi, il progetto prevede una sperimentazione controllata volta a quantificare l'efficacia didattica, l'usabilità e la sostenibilità operativa. In particolare, il percorso include una **fase pilota preliminare a basso attrito tecnologico ("zero-infrastructure")** focalizzata sulla sola gestione maieutica del dialogo da parte del modello linguistico, propedeutica alla sperimentazione dell'architettura complessa completa.

---

## Fasi e disegno della ricerca {#sec-disegno-ricerca}

La sperimentazione complessiva si articola in sette passaggi metodologici:

1. **Definizione degli obiettivi formativi mirati:**
   Focalizzazione su un sottoinsieme specifico di competenze modellistiche e interrogative (da O2 a O7: modellazione ER, traduzione in schema relazionale, individuazione di vincoli non banali, calcolo delle forme normali, scrittura di query SQL con aggregazioni e join).

2. **Strumenti di misurazione standardizzati:**
   - *Pre-test diagnostico*: Somministrazione iniziale per rilevare il livello di partenza degli studenti.
   - *Attività formative con il tutor*: Svolgimento delle consegne C1–C4 con tracciamento dettagliato delle revisioni.
   - *Post-test individuale*: Valutazione delle competenze acquisite al termine dell'intervento.
   - *Prova di trasferimento a distanza (3–4 settimane)*: Risoluzione di una traccia inedita senza alcun supporto del tutor (fase 9 / consegna C5), per verificare la ritenzione nel medio termine e l'assenza di dipendenza dall'assistente.
   - *Correzione in cieco*: Valutazione degli elaborati da parte di due docenti indipendenti all'oscuro dell'identità dello studente, con rubrica analitica descrittiva e calcolo dell'indice di accordo inter-valutatore.

3. **Validazione preventiva del tutor (Golden Set):**
   Prima dell'interazione con gli studenti, il tutor linguistico è sottoposto al golden set di collaudo (@sec-test-tutor-llm):
   - Almeno 30 casi noti per ciascuna fase;
   - Misurazione della fedeltà ai livelli di aiuto (nessun controesempio a L1, nessun codice risolutivo completo);
   - Calcolo del tasso di mancata fuga della soluzione (obiettivo: 100%);
   - Verifica di non-contraddizione rispetto alle diagnosi deterministiche.

4. **Fasi pilota progressive della sperimentazione:**
   - **Pilota 1 (Cloud Zero-Infrastructure / Google Classroom e Gemini, @sec-pilota-classroom):** Sperimentazione del solo tutor LLM in un contesto scolastico reale basato su Google Classroom, utilizzando le Gem di Gemini e le Skill agentiche (`SKILL.md`) per testare la tenuta del dialogo socratico, la qualità maieutica e l'usabilità multimodale a formati aperti, senza il carico di allestimento dei server Git e SQLite.
   - **Pilota 2 (On-Premise / Modelfile Ollama per VLM aperti, @sec-pilota-ollama):** Trasferimento delle istruzioni socratiche della Gem in un `Modelfile` per Ollama ed esecuzione locale su workstation scolastica. Valutazione comparativa di modelli vision-language aperti (Qwen2.5-VL 7B, Qwen3-8B, Phi-3.5-vision, LLaVA v1.6, Llama 3.2 3B Vision) per testare l'analisi di immagini/diagrammi, la latenza, il consumo di VRAM e la tenuta maieutica in assenza di connettività cloud.
   - **Pilota 3 (Integrazione tecnologica mista completa, @sec-piattaforma-consegna):** Coinvolgimento di una o due classi (5–20 studenti per classe) per un ciclo di 6–8 lezioni curricolari in laboratorio con lo stack integrato neuro-simbolico on-premise (GitLab/Forgejo, runner isolati, sandbox SQLite e validatori deterministici rigidi).
   - Disegno di ricerca prevalentemente *intra-soggetto* (confronto pre/post sullo stesso gruppo di studenti).
   - Rilevazione qualitativa continua: osservazione sul campo dei comportamenti degli studenti, registrazione dei blocchi tecnici o didattici, note del docente.
   - Affinamento iterativo dei prompt, dei pesi di quantizzazione e delle regole di validazione prima della sperimentazione su scala più ampia.

5. **Verifica empirica del trasferimento:**
   Confronto delle prestazioni della prova individuale finale rispetto al pre-test diagnostico iniziale, utilizzando una traccia concettualmente isomorfa ma ambientata in un dominio applicativo differente.

6. **Analisi multidimensionale dei risultati:**
   Oltre ai punteggi grezzi di correttezza, l'analisi considera:
   - *Grado di autonomia*: Evoluzione della richiesta di livelli di aiuto (tendenza a diminuire il ricorso a L3/L4);
   - *Qualità del ragionamento*: Pertinenza, rigore e ricchezza delle motivazioni fornite nei vari passaggi;
   - *Capacità di correzione attiva*: Analisi della cronologia delle revisioni e dei ripensamenti tra il primo tentativo e l'elaborato approvato;
   - *Esperienza percepita*: Questionario di fine percorso sull'utilità percepita, senso di autoefficacia e fiducia nel tutor.

7. **Confronto controllato (Fase estesa successiva):**
   Qualora siano disponibili classi parallele con il medesimo programma curricolare, confronto tra:
   - *Gruppo sperimentale*: Attività svolta con Socratic-DB.
   - *Gruppo di controllo*: Attività tradizionale con correzione manuale periodica del docente.
   Adozione di schemi a rotazione (*crossover*) per garantire a tutti gli studenti le medesime opportunità formative.

---

## Fasi pilota "Zero-Infrastructure": Sperimentazione del dialogo socratico con Google Classroom e Gemini {#sec-pilota-classroom}

### Contesto didattico e motivazione metodologica {#sec-pilota-classroom-motivo}

L'allestimento dell'architettura completa descritta in @sec-architettura-sistema (server Linux con GPU da 32 GB, istanza on-premise GitLab/Forgejo, container Docker con SQLite in sandbox e validatori YAML/Pydantic) comporta un rilevante investimento infrastrutturale e un notevole carico di configurazione DevOps per il docente. Se introdotto direttamente nella fase iniziale della ricerca, questo carico tecnologico rischia di introdurre variabili spurie nell'osservazione (es. blocchi dovuti a errori di sintassi YAML, disallineamenti di Git o problemi di rete locale), oscurando l'oggetto primario di indagine: **la reale efficacia maieutica del modello linguistico nella conduzione del dialogo socratico per le basi di dati**.

Per isolare e valutare rigorosamente la componente conversazionale e pedagogica, il progetto introduce una **fase pilota "zero-infrastructure"** ambientata nello scenario d'uso ordinario di una scuola secondaria di secondo grado italiana dotata di **Google Workspace for Education e Google Classroom**.

In tale ambiente:

- Non è richiesta alcuna installazione locale, server dedicato o configurazione di repository Git;
- La scuola sfrutta gli strumenti di IA generativa già integrati e regolamentati nell'infrastruttura d'istituto (Gemini Enterprise o Education);
- La didattica beneficia della disponibilità di **Gem personalizzate (Gemini Gems)** e della generazione e utilizzo di **Skill agentiche standard (`SKILL.md`)**;
- Gli studenti possono dialogare con il tutor utilizzando qualsiasi dispositivo (Chromebook, PC di laboratorio, tablet o smartphone) e qualsiasi modalità espressiva, inclusa quella grafica e manoscritta.

### Duplice implementazione: Gem di Gemini e Skill agentica {#sec-duplice-implementazione}

Per consentire la massima flessibilità sia in contesti no-code che in ambienti di programmazione assistita, il tutor socratico è ingegnerizzato e rilasciato in due formati complementari:

1. **Gem di Google Gemini (`DB-Socrates Gem`):**
   Configurata direttamente dal docente nella console di Gemini Workspace attraverso un set di istruzioni di sistema (*system prompt*) strutturato. La Gem è distribuibile alla classe tramite link o condivisione interna in Google Classroom. Gli studenti vi accedono con il proprio account istituzionale, interagendo in una chat multimodale intuitiva.
   Le specifiche e il prompt completo per la creazione della Gem sono formalizzati in [GEM_SYSTEM_INSTRUCTIONS.md](file:///home/massi/Documenti/GitHub/socratic-db/gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md).

2. **Skill agentica standard (`SKILL.md`):**
   Definita secondo la specifica standard per assistenti e agenti di sviluppo (Google Antigravity, Gemini CLI, estensioni per Classroom). La skill racchiude i metadati YAML, i trigger operativi, le regole maieutiche L0–L4, i criteri di qualità e le euristiche di scaffolding.
   Il file sorgente della skill è disponibile in [SKILL.md](file:///home/massi/Documenti/GitHub/socratic-db/skills/socratic-db/SKILL.md).

### Ingestione del compito e isolamento della componente DB {#sec-ingestione-compito}

Il flusso di lavoro si innesca quando lo studente (o il docente per conto della classe) carica il PDF del compito. Tipicamente si tratta di:

- Una traccia di **Seconda Prova scritta dell'Esame di Stato** per gli Istituti Tecnici (indirizzo Informatica e Telecomunicazioni, articolazione Informatica);
- Una simulazione ministeriale o una prova d'esame degli anni precedenti (cfr. catalogo in @sec-catalogo-tracce);
- Un compito in classe o studio di caso predisposto dal docente di indirizzo.

Le tracce d'esame ministeriali contengono frequentemente requisiti compositi (ad esempio: architettura di rete e apparati Cisco, progettazione della base di dati, realizzazione di pagine web front-end o policy di sicurezza). L'assistente socratico:

1. **Analizza e isola il dominio dati:** legge il PDF tramite le capacità multimodali native del modello e separa la parte relativa alla persistenza e alle basi di dati (generalmente identificata come *Parte Prima* o *Tema 1*) dagli aspetti accessori;
2. **Definisce il perimetro:** riassume in poche frasi l'universo del discorso e gli obiettivi informativi del sistema;
3. **Presenta il patto formativo:** esplicita allo studente la sequenza rigorosa delle nove tappe maieutiche che dovranno essere percorse prima di considerare concluso il lavoro.

### Il percorso maieutico in nove passi e la mappatura con il Protocollo Didattico {#sec-mappatura-fasi-pilota}

Il tutor conduce l'interazione richiedendo allo studente di produrre, tassativamente nell'ordine metodologico, nove risultati intermedi. Questa sequenza costituisce una **mappatura biunivoca e fedele delle nove fasi e delle cinque consegne formali descritte nel Protocollo Didattico (@sec-percorso-consegne)**:

1. **Analisi nomi-verbi (Fasi 1–2 / Consegna C1):**
   Lo studente estrae dal testo del compito isolato i sostantivi e le forme verbali rilevanti, organizzandoli in una tabella. Ogni sostantivo è categorizzato (*Candidata Entità*, *Attributo*, *Scartato/Fuori ambito*) con la rispettiva giustificazione semantica. Ogni verbo è categorizzato (*Candidata Associazione*, *Operazione di sistema*, *Scartato*) specificando i soggetti coinvolti. Il tutor interviene maieuticamente per sfatare l'illusione che "ogni nome sia un'entità e ogni verbo una relazione", guidando lo studente a motivare i confini del modello.

2. **Glossario di progetto (Fase 2 / Consegna C1):**
   Lo studente fornisce le definizioni rigorose di ciascun termine e concetto candidato selezionato. Il tutor verifica che le definizioni non siano circolari o tautologiche (es. *"La Prenotazione è l'atto di prenotare"*), accerta la disambiguazione di omonimi e sinonimi presenti nel testo e fissa il lessico controllato del progetto.

3. **Modello concettuale E/R (Fase 3 / Consegna C2):**
   Lo studente progetta lo schema Entità-Relazione definendo entità, attributi, identificatori univoci (chiavi concettuali), associazioni e **cardinalità minime e massime** (`0..1`, `1..1`, `0..N`, `1..N`). Il tutor verifica che ogni entità possieda un identificatore, che ogni costrutto risponda a un requisito della traccia e sfida lo studente tramite controesempi concreti sulle cardinalità dubbie o invertite.

4. **Vincoli del dominio (Fase 4 / Consegna C2):**
   Lo studente individua e classifica le regole aziendali e i vincoli che non possono essere rappresentati puramente dalla topologia del grafo ER: vincoli su singoli attributi, vincoli inter-entità e vincoli temporali (intervalli, sovrapposizioni e concorrenza). Per ciascun vincolo indica il meccanismo di controllo preventivato (vincolo CHECK/UNIQUE, trigger o livello applicativo).

5. **Modello relazionale e meccanismo di controllo dei vincoli (Fase 5 / Consegna C3):**
   Lo studente applica le regole formali di traduzione concettuale-logica: derivazione delle tabelle, individuazione delle chiavi primarie, traduzione delle associazioni 1:N e N:M (tramite tabelle di giunzione), gestione delle gerarchie e delle relazioni 1:1, definizione delle chiavi esterne (FK) e delle politiche di integrità referenziale (`ON DELETE`, `ON UPDATE`). Lo studente formalizza le dipendenze funzionali, argomenta il raggiungimento della Terza Forma Normale (**3NF**) e spiega in quale tabella o vincolo relazionale viene implementato ciascuno dei vincoli del punto 4.

6. **DDL SQL per la creazione dello schema (Fase 6 / Consegna C4):**
   Lo studente scrive lo script SQL DDL (`CREATE TABLE`) con tipi di dati corretti, vincoli `NOT NULL`, `UNIQUE`, `CHECK` e chiavi esterne attive.
   *Scaffolding controllato:* se lo studente dimostra piena padronanza concettuale ma rimane bloccato su ostacoli sintattici dopo ripetute iterazioni maieutiche (3–4 tentativi infruttuosi), il tutor fornisce lo schema DDL corretto. Lo studente è tuttavia obbligato ad analizzarlo riga per riga, commentando i vincoli e confrontandolo criticamente con il proprio tentativo iniziale.

7. **DML SQL per l'inserimento dei dati (Fase 7 / Consegna C4):**
   Lo studente popola la base di dati tramite istruzioni `INSERT INTO` significative e non banali, comprensive di casi ordinari, casi limite, valori nulli in colonne opzionali, tuple genitore prive di figli (per verificare le `LEFT JOIN`) e casi invalidi destinati a essere respinti dai vincoli di integrità.
   *Scorciatoia su richiesta:* se lo studente richiede assistenza o per evitare un eccessivo affaticamento esecutivo, il tutor propone uno script multi-insert sintetico e plausibile (privo di dati personali reali), coerente con lo schema dell'allievo, chiedendogli di convalidarlo e integrarlo con un caso limite personale.

8. **QL SQL per le query richieste dal compito (Fase 8 / Consegna C4):**
   Lo studente formula le query `SELECT` necessarie a rispondere a tutte le interrogazioni previste dal testo d'esame. Motiva la scelta dei tipi di join (`INNER JOIN`, `LEFT JOIN`), delle condizioni di filtro (`WHERE`), dei raggruppamenti (`GROUP BY`, `HAVING`) e degli ordinamenti (`ORDER BY`), commentando criticamente il risultato logico ottenuto sui dati inseriti al punto 7.

9. **Proposta di un problema simile ma più complesso (Fase 9 / Consegna C5 - Prova di Trasferimento):**
   Al termine del percorso, il tutor non chiude semplicemente la sessione ma formula una traccia didattica di approfondimento: un problema isomorfo o una variante del caso affrontato che introduce un vincolo aggiuntivo o una complicazione di dominio (es. gestione temporale dei prezzi storici, cancellazione logica con trigger di audit, gestione concorrente di quote di capienza). Lo studente è invitato ad affrontarlo in piena autonomia, permettendo di valutare l'effettivo trasferimento delle competenze senza supporto continuo.

La tabella seguente riassume la corrispondenza biunivoca tra le tappe del pilota in Classroom e il protocollo metodologico del progetto:

| Tappa Pilota Classroom | Fase Protocollo Didattico | Consegna Aggregata | Artefatto Prodotto dallo Studente | Controllo e Guida Socratica del Tutor |
| :--- | :--- | :--- | :--- | :--- |
| **0. Traccia PDF** | Requisiti Iniziali | Setup | Upload PDF esame/compito | Isolamento mirato della porzione Basi di Dati e perimetrazione |
| **1. Nomi-Verbi** | Fase 1–2 | C1. Requisiti e glossario | Tabella Sostantivi / Verbi categorizzati e motivati | Domande sulla natura di attributo vs entità; motivazione degli scarti |
| **2. Glossario** | Fase 2 | C1. Requisiti e glossario | Glossario definizioni e chiarimento sinonimi/omonimi | Rilevazione tautologie e definizioni circolari; disambiguazione |
| **3. Modello E/R** | Fase 3 | C2. Concettuale | Diagramma ER (libero: disegno a mano, Mermaid, draw.io, YAML) | Presenza identificatori; controesempi pratici su cardinalità invertite |
| **4. Vincoli Dominio** | Fase 4 | C2. Concettuale | Tabella vincoli non strutturali e meccanismi previsti | Elicitazione vincoli impliciti, temporali e di sovrapposizione |
| **5. Modello Relazionale** | Fase 5 | C3. Relazionale | Schemi di relazione, PK/FK, dipendenze funzionali, 3NF | Verifica assenza FK orfane, superchiavi minime e normalizzazione 3NF |
| **6. DDL SQL** | Fase 6 | C4. Implementazione | Script SQL `CREATE TABLE` con tipi e vincoli | Feedback sintattico/semantico; scaffolding DDL se bloccato (con analisi) |
| **7. DML SQL** | Fase 7 | C4. Implementazione | Script `INSERT INTO` (casi ordinari, limite, genitori senza figli) | Verifica copertura; generazione multi-insert su richiesta |
| **8. QL SQL** | Fase 8 | C4. Implementazione | Query `SELECT` commentate e discusse | Verifica join, filtri, aggregazioni ed esame maieutico dei risultati |
| **9. Problema Complesso** | Fase 9 | C5. Trasferimento | Risoluzione autonoma di un problema isomorfo incrementale | Verifica del trasferimento e della non-dipendenza dall'assistente |

### Libertà di formato ed espressività multimodale {#sec-liberta-formati}

Uno dei principali limiti operativi dell'infrastruttura automatizzata rigorosa risiede nell'obbligo, per gli studenti delle scuole superiori, di codificare gli schemi concettuali e logici in file YAML rigorosamente conformi a uno schema JSON (cfr. @sec-formati-contratti). Nella pratica scolastica, tale vincolo costringe il docente a spendere ore di lezione sull'insegnamento della sintassi YAML e sulla risoluzione di errori di indentazione, distogliendo l'attenzione dagli obiettivi concettuali della modellazione dei dati.

Nella fase pilota con Google Classroom e Gemini, la scelta pedagogica è improntata alla **totale libertà di formato, inclusa la piena valorizzazione della dimensione grafica e multimodale**:

- **Diagrammi disegnati a mano libera:** Lo studente può tracciare lo schema Entità-Relazione su un comune foglio di carta (con rettangoli per le entità, rombi per le associazioni, ovali per gli attributi e cardinalità min..max scritte a penna), fotografarlo con lo smartphone o la webcam del computer e allegare l'immagine alla chat. La visione multimodale della LLM analizza l'immagine, riconosce la struttura del grafo e le annotazioni manoscritte e conduce la discussione maieutica direttamente a partire dal disegno dello studente.
- **Diagrammi digitali visuali:** Lo studente può utilizzare qualsiasi strumento di disegno grafico (draw.io, Canva, Lucidchart, Excalidraw, DIA) ed esportare l'elaborato in formato immagine (PNG, JPEG) o PDF.
- **Notazioni testuali e diagrammi as-code:** Gli studenti più orientati al codice possono sottoporre diagrammi Mermaid, PlantUML o tabelle Markdown.
- **Rappresentazioni testuali semplificate:** Per il modello relazionale, lo studente può utilizzare la notazione testuale classica della letteratura scolastica (es. `Cliente(ID_Cliente, Cognome, Nome, Città*)` con asterischi per le chiavi esterne e sottolineature per le chiavi primarie) oppure tabelle a colonne.

La LLM non sanziona né forza alcuna specifica sintassi di rappresentazione grafica o testuale: si concentra unicamente sulla comprensione semantica del modello e sulla qualità del ragionamento dello studente.

### I cinque criteri di qualità della guida socratica {#sec-criteri-qualita-socratica}

Nel corso di tutte le 9 tappe, la Gem e la Skill orientano il dialogo maieutico affinché l'elaborato finale soddisfi costantemente cinque dimensioni qualitative fondamentali:

1. **Corretto (Correttezza formale, logica e sintattica):**
   Lo schema deve rispettare rigorosamente le regole dell'algebra relazionale e della sintassi SQL: identificatori presenti per ciascuna entità, assenza di relazioni non collegate, coerenza dei tipi di dato tra chiavi primarie e chiavi esterne, assenza di violazioni di integrità referenziale, rispetto della Terza Forma Normale (3NF), e correttezza sintattica del linguaggio specifico di dominio (E/R, DDL, DML, QL).

2. **Completo (Copertura esaustiva delle specifiche):**
   Ogni requisito informativo, entità, vincolo aziendale (esplicito o implicito) e interrogazione presente nel testo del compito o dell'Esame di Stato deve trovare puntuale riscontro nello schema concettuale, nello schema relazionale e nelle query di interrogazione. Nessun requisito viene omesso o trascurato.

3. **Minimale (Assenza di sovrastrutture e ridondanze):**
   Il modello deve evitare l'eccesso di complessità (*over-engineering*). Non devono comparire entità fittizie non giustificate dai requisiti, attributi duplicati o calcolabili, tabelle di giunzione superflue per relazioni 1:N; nelle query SQL devono essere coinvolti esclusivamente gli attributi e le tabelle strettamente necessari (rifiuto del costrutto `SELECT *` e di join ridondanti).

4. **Pertinente (Aderenza semantica al dominio applicativo):**
   I nomi attribuiti alle entità, agli attributi e alle relazioni, nonché la classificazione dei vincoli, devono rispecchiare con precisione il lessico, i processi aziendali e la realtà operativa descritta nella traccia, evitando generalizzazioni astratte e terminologie non appropriate.

5. **Efficiente (Ottimizzazione strutturale e computazionale):**
   Nello schema relazionale e nelle query SQL devono essere privilegiate scelte che minimizzano anomalie e costi computazionali: selezione mirata dei tipi fisici di dato, indicizzazione coerente sulle chiavi esterne e sui campi di ricerca frequente, normalizzazione fino a 3NF senza frammentazione ingiustificata, e scrittura di query ottimizzate (scelta corretta tra `JOIN` e sottoquery, filtri selettivi anticipati nella clausola `WHERE`, eliminazione di prodotti cartesiani involontari).

#### Declinazione operativa della qualità sui 9 deliverable {#sec-matrice-qualita-deliverable}

Per consentire al tutor un'azione maieutica puntuale, la griglia seguente specifica come i cinque criteri si applicano a ciascuno dei deliverable intermedi:

| Deliverable | Corretto | Completo | Minimale | Pertinente | Efficiente |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **D1. Nomi-Verbi** | Rigore grammaticale e logico (sostantivo $\rightarrow$ entità/attributo/scartato; verbo $\rightarrow$ associazione/operazione) | Estrazione di tutti i termini chiave dal testo isolato | Scarto motivato di vocaboli fuori ambito o irrilevanti | Fuoco esclusivo sui requisiti informativi del dominio | Organizzazione tabellare concisa con motivazioni chiare |
| **D2. Glossario** | Definizioni non circolari, non tautologiche, ontologicamente fondate | Definizione di tutti i concetti; chiarimento sinonimi e omonimi | Definizioni sintetiche e circoscritte al profilo dati | Ancoraggio al contesto aziendale della prova | Consolidamento di un lessico controllato senza ambiguità |
| **D3. Modello E/R** | Identificatori presenti; cardinalità min/max formalmente valide; assenza di grafi orfani | Copertura di tutte le entità e relazioni richieste | Assenza di entità fittizie o attributi calcolabili non motivati | Rispetto fedele delle dinamiche del problema | Topologia concettuale pulita e pronta alla traduzione logica |
| **D4. Vincoli** | Formulazione non ambigua; corretto meccanismo (CHECK, trigger, app) | Censimento vincoli intra/inter-entità e temporali/concorrenza | Nessuna duplicazione di vincoli già garantiti dall'E/R | Vincoli derivanti dalle reali regole aziendali | Preferenza per vincoli dichiarativi DDL rispetto a trigger pesanti |
| **D5. Relazionale** | Traduzione rigorosa (PK, FK, N:M risolte, 1:1 e gerarchie); 3NF verificata | Tutte le tabelle derivate; mappatura meccanismi vincoli D4 | Nessuna tabella ponte per 1:N; assenza ridondanze transitive | Rispetto fedele della semantica concettuale di D3 | Normalizzazione 3NF che elimina anomalie di modifica/cancellazione |
| **D6. DDL SQL** | Sintassi SQL valida; tipi corretti; PK, FK e vincoli NOT NULL/CHECK/UNIQUE attivi | Script eseguibile che genera l'intero schema | Codice pulito, privo di colonne superflue o clausole duplicate | Nomenclatura chiara, uniforme e professionale | Tipi dimensionalmente adeguati; indici su FK e campi di ricerca |
| **D7. DML SQL** | Istruzioni INSERT valide; rispetto dell'ordine topologico delle FK | Casi ordinari, limite, nulli, genitori senza figli e test negativo | Dataset compatto, privo di popolamenti ridondanti fini a se stessi | Dati realistici e coerenti; assenza di dati personali reali | Istruzioni multi-insert compatte e ordinate |
| **D8. QL SQL** | Sintassi ineccepibile; join corrette (INNER vs LEFT); filtri WHERE/HAVING esatti | Risoluzione puntuale di tutti i quesiti informativi della traccia | Solo colonne necessarie (no `SELECT *`); solo tabelle indispensabili | Restituisce esattamente i dati richiesti, con ordinamento coerente | Filtri anticipati in WHERE; join su chiavi indicizzate; no subquery lente |
| **D9. Trasferimento**| Formulazione chiara, pedagogicamente solida e verificabile | Traccia completa di contesto, requisiti, vincoli e query | Incremento mirato e circoscritto di complessità (es. audit, quote) | Problema isomorfo al dominio di partenza | Verifica l'effettiva autonomia dello studente senza supporto continuo |

### Gestione dello scaffolding e delle scorciatoie controllate {#sec-scaffolding-scorciatoie}

Nel rispetto dei principi pedagogici espressi in @sec-specifica-pedagogica e delle indicazioni di sostenibilità di @sec-protocollo-didattico, il pilota integra due meccanismi controllati di supporto:

- **Scaffolding dello Schema DDL (Tappa 6):**
  L'obiettivo formativo prioritario nella scuola secondaria risiede nella progettazione logica e nella comprensione dell'integrità referenziale. Se uno studente, pur avendo compreso il modello relazionale, sperimenta frustrazione o stallo bloccante nella traduzione in dialetto SQLite dopo 3–4 iterazioni maieutiche, il tutor è autorizzato a fornire lo schema DDL corretto.
  Tuttavia, per scongiurare l'accettazione passiva, il tutor subordina il proseguimento alla **spiegazione critica da parte dello studente**: l'allievo deve illustrare ogni tabella, commentare il ruolo delle chiavi esterne e dei vincoli `CHECK`, ed evidenziare esplicitamente quali differenze sussistono rispetto al proprio tentativo iniziale.
- **Scorciatoia DML per la generazione dei dati (Tappa 7):**
  La digitazione manuale di decine di istruzioni `INSERT INTO` rappresenta un compito ad alto costo temporale e a basso valore formativo concettuale. Quando lo studente lo richiede, il tutor propone uno script SQL multi-insert sintetico e plausibile, coerente con lo schema dello studente e rigorosamente privo di dati personali reali. Lo studente ha il compito di verificare che i dati rispettino i vincoli del DDL, integrando il dataset con almeno un caso limite e un caso invalido di test.

### Protocollo di osservazione e metriche specifiche del pilota {#sec-metriche-pilota}

Durante lo svolgimento del pilota "zero-infrastructure" in Google Classroom, i dati per la ricerca vengono raccolti attraverso modalità trasparenti e non invasive:

- **Esportazione delle sessioni di dialogo:** Gli studenti scaricano la trascrizione integrale del dialogo con la Gem o con l'assistente (in formato testo o PDF) e la consegnano come allegato al compito in Google Classroom;
- **Analisi qualitativa della traiettoria maieutica:** I dialoghi vengono analizzati per calcolare:
  - Il livello massimo di aiuto raggiunto per ciascuna delle 9 tappe (scala L0–L4);
  - Il tasso di fedeltà socratica del tutor (assenza di risposte preconfezionate o fughe indebite della soluzione);
  - La frequenza di ricorso allo scaffolding DDL (Tappa 6) e alla generazione assistita dei dati (Tappa 7);
  - La capacità dello studente di recepire i controesempi e correggere autonomamente gli elaborati;
- **Valutazione in cieco degli elaborati finali:** Docenti indipendenti valutano gli elaborati di Tappa 8 (query) e Tappa 9 (problema di trasferimento) con rubrica analitica su scala 1–4 rispetto ai criteri di correttezza, completezza, minimalità, pertinenza ed efficienza;
- **Questionari di gradimento e carico di lavoro:** Rilevazione dell'esperienza d'uso degli studenti (usabilità percepita, senso di autonomia) e del carico orario effettivo del docente (tempo impiegato per predisporre il compito in Classroom e tempo per la revisione delle trascrizioni).

I risultati raccolti in questa fase pilota costituiscono la base empirica per validare i prompt e tarare i pesi dei modelli linguistici prima del collaudo del prototipo completo con integrazione Git e SQLite isolato.

---

## Secondo pilota On-Premise: Sperimentazione locale con Ollama e VLM aperti {#sec-pilota-ollama}

### Razionale della sperimentazione locale e sovranità del dato {#sec-pilota-ollama-motivo}

Dopo aver validato la tenuta del dialogo socratico e l'accoglienza pedagogica nello scenario cloud "zero-infrastructure" di Google Classroom (@sec-pilota-classroom), la seconda fase pilota sposta l'indagine sull'**infrastruttura locale d'istituto (*on-premise*)**, posizionandosi come passaggio intermedio prima della realizzazione dell'infrastruttura mista completa dotata di validatori deterministici rigidi e sandbox SQLite (@sec-architettura-sistema).

L'obiettivo di questo secondo pilota è duplice:
1. **Verificare la fattibilità operativa ed economica dell'IA locale nella scuola**: affrancarsi dalla dipendenza da API commerciali cloud, eliminando i costi ricorrenti di inferenza e garantendo la totale sovranità sui dati scolastici (GDPR/DPIA) mediante l'esecuzione autonoma su una singola workstation o server di laboratorio d'istituto dotato di GPU dedicata;
2. **Valutare empiricamente la capacità visiva e maieutica dei modelli aperti (*open-weights*)**: verificare se modelli multimodali compatti (3B–8B) siano in grado di interpretare diagrammi concettuali ed E/R (inclusi disegni a mano libera su carta fotografati dagli studenti) e di mantenere la disciplina socratica senza cedere risposte precotte o allucinare sulla sintassi SQL.

A tale scopo, le istruzioni di sistema maieutiche formalizzate per la Gem di Google e per la skill agentica vengono trasferite in un **`Modelfile` standard per Ollama**, consentendo l'orchestrazione e il confronto trasparente tra diversi modelli linguistici e multimodali.

### Modelli linguistici e multimodali aperti di test {#sec-modelli-vlm-test}

La sperimentazione locale mette a confronto cinque modelli aperti dotati di capacità multimodali (*Vision-Language Models* - VLM) o ad alte prestazioni di reasoning, compatibili con il runtime Ollama e quantizzabili per operare in contesti scolastici con risorse GPU contenute (8–32 GB di VRAM):

1. **Qwen2.5-VL 7B (`qwen2.5vl:7b` su Ollama):**
   Rappresenta il modello di riferimento primario per il test. Dotato di un'architettura multimodale all'avanguardia con supporto a risoluzioni dinamiche, eccelle nel riconoscimento della struttura di grafi, diagrammi a blocchi, frecce di associazione e nell'OCR di annotazioni manoscritte su immagini.
2. **Qwen3-8B:**
   Modello linguistico di nuova generazione con spiccate capacità di ragionamento logico-matematico e coding SQL, particolarmente efficace nel presidio delle regole di normalizzazione (3NF) e nell'analisi sintattica dei vincoli relazionali.
3. **Phi-3.5-vision (`phi3.5-vision`):**
   Modello compatto da 4.2 miliardi di parametri sviluppato per il reasoning multimodale multi-frame. Si distingue per l'estrema efficienza computazionale e per l'elevata accuratezza nella lettura di tabelle dense e diagrammi concettuali sintetici.
4. **LLaVA v1.6 (`llava:v1.6`):**
   Modello open source consolidato per l'interazione visiva instruction-tuned (basato su backbone Mistral/Vicuna). Utilizzato nella ricerca come termine di paragone accademico per misurare i progressi delle architetture multimodali nell'istruzione didattica.
5. **Llama 3.2 3B Vision (`llama3.2-vision:3b`):**
   Architettura multimodale ultra-compatta progettata per edge computing e ambienti con severi vincoli di memoria. Permette di valutare se sia possibile erogare il tutor socratico multimodale persino su GPU consumer o workstation scolastiche economiche dotate di soli 8–12 GB di VRAM.

### Il Modelfile per Ollama e la taratura dei parametri di inferenza {#sec-modelfile-ollama}

Il tutor locale viene istanziato tramite il file di configurazione [Modelfile](file:///home/massi/Documenti/GitHub/socratic-db/ollama/Modelfile) collocato nella directory `ollama/`. Il file adotta la seguente struttura:

```dockerfile
# Modelfile per Ollama - DB-Socrates: Tutor Socratico per Basi di Dati
# Modello base multimodale intercambiabile (es. Qwen2.5-VL 7B)
FROM qwen2.5vl:7b

# Parametri di inferenza ottimizzati per laboratorio scolastico
PARAMETER num_ctx 4096
PARAMETER num_gpu 999
PARAMETER temperature 0.2
PARAMETER repeat_penalty 1.1

# Istruzioni di sistema maieutiche (trasferite da Google Gem)
SYSTEM """
RUOLO E IDENTITÀ:
Sei "DB-Socrates", tutor didattico di Basi di Dati...
[Inclusione integrale dei 5 criteri di qualità, dei 9 deliverable e dei livelli L0-L4]
"""
```

I parametri di configurazione del `Modelfile` rispondono a precisi vincoli tecnici e pedagogici:

- **`PARAMETER num_ctx 4096` (o `8192`):**
  La dimensione del contesto è deliberatamente circoscritta a 4096 token (estendibile a 8192 token su GPU con almeno 24 GB di VRAM). Questa limitazione consente di **ridurre drasticamente l'occupazione di memoria della KV cache**, evitando che il contesto conversazionale saturi la VRAM e forzi l'offload dei pesi sulla CPU (che degraderebbe il throughput a frazioni di token al secondo). 4096 token risultano ampiamente sufficienti per ospitare il prompt di sistema, le coordinate visive dell'immagine analizzata e i singoli turni maieutici.
- **`PARAMETER num_gpu 999`:**
  Forza il runtime Ollama a caricare il 100% dei layer della rete neurale e del proiettore visivo all'interno della memoria VRAM della scheda video dedicata. Con l'offload totale, l'elaborazione dei token avviene alla massima velocità consentita dall'hardware (20–50 token/s su schede di fascia media o workstation).
- **`PARAMETER temperature 0.2`:**
  Una temperatura di campionamento molto bassa è indispensabile nell'ingegneria dei dati per **abbattere il tasso di allucinazione nella sintassi SQL e nella logica relazionale**. Temperature più elevate generano errori sintattici casuali nel DDL o confusioni nelle clausole di JOIN; una temperatura controllata a 0.2 assicura rigore formale e riproducibilità pedagogica, preservando al contempo la naturalezza espressiva necessaria alla formulazione di domande maieutiche.
- **`PARAMETER repeat_penalty 1.1`:**
  Introduce una moderata penalizzazione per i token già generati. Nelle prove con modelli vision-language, l'analisi di immagini complesse (es. diagrammi con molti attributi ovali o frecce multiple) può innescare **loop degenerativi o ripetizioni ossessive** di frammenti di testo o elenchi; il fattore 1.1 spezza questi cicli ricorsivi garantendo risposte snelle e progressive.

### Protocollo di valutazione comparativa per il Pilota 2 {#sec-valutazione-pilota-ollama}

La sperimentazione locale sottopone ciascuno dei cinque modelli a un benchmark strutturato articolato su quattro dimensioni di collaudo:

1. **Accuratezza dell'analisi visiva (*Vision Benchmark*):**
   - Riconoscimento di diagrammi E/R generati digitalmente (screenshot da Mermaid, draw.io o Canva);
   - Riconoscimento di schemi disegnati a mano libera su carta e fotografati con smartphone (inclusa la corretta lettura delle etichette manoscritte e delle coppie di cardinalità min/max come `0..N` o `1..1`);
   - Calcolo del tasso di errore nell'individuazione di entità, attributi primari e associazioni rispetto al disegno sorgente dello studente.
2. **Tenuta maieutica e rispetto delle regole socratiche:**
   - Verifica che i modelli open-weight mantengano il vincolo di non fornire schemi completi risolutivi o codice SQL anticipato;
   - Misurazione della capacità di scalare correttamente l'aiuto tra L0 (segnalazione sintetica), L1 (domanda mirata) e L2 (controesempio pratico dal dominio).
3. **Consumo di risorse e profilo hardware:**
   - Rilevazione della VRAM occupata al caricamento del modello (pesi quantizzati a 4/5 bit);
   - Rilevazione dell'espansione della KV cache durante sessioni estese a 4096 token;
   - Misurazione del *Time to First Token* (TTFT) e della velocità media di generazione (token/s).
4. **Capacità di servire sessioni simultanee in laboratorio:**
   - Simulazione di una classe di laboratorio (5–10 studenti che inviano quesiti o immagini contemporaneamente verso l'istanza Ollama centralizzata su LAN);
   - Valutazione del tempo di attesa medio per studente e della stabilità del servizio con gestione tramite coda o inferenza parallela (`OLLAMA_NUM_PARALLEL`).

I risultati del Pilota 2 consentono di selezionare il modello open-weight più affidabile ed efficiente, che costituirà il motore linguistico del prototipo integrato descritto nel capitolo successivo.

---

## Raccolta dati e metriche di processo {#sec-raccolta-metriche}

Tutti i dati raccolti durante la sperimentazione (sia nella fase pilota Classroom che nelle sessioni con sistema integrato) sono associati esclusivamente a identificativi pseudonimi (`s001`, `s002`, ...):

- **Metriche quantitative di processo**:
  - Numero di iterazioni conversazionali o commit effettuati per ciascuna fase;
  - Frequenza e tipologia degli errori concettuali e delle diagnosi sollevate (es. cardinalità invertite, attributi transitivi, violazioni di integrità referenziale, errori di sintassi SQL);
  - Livello massimo di aiuto richiesto o erogato (L0–L4) per ciascuna tappa;
  - Frequenza di attivazione dello scaffolding DDL (Tappa 6) e delle scorciatoie DML (Tappa 7);
  - Tempo impiegato per completare ciascuna consegna intermedia e la prova di trasferimento;
  - Tempi effettivi di preparazione e caricamento della traccia da parte del docente (misura della sostenibilità in Classroom e nello strumento d'autore).
- **Metriche di apprendimento e qualità modellistica**:
  - Punteggi ottenuti nelle rubriche analitiche del pre-test, del post-test e della prova di trasferimento autonoma;
  - Valutazione multidimensionale dell'elaborato finale rispetto ai cinque pilastri (*Corretto, Completo, Minimale, Pertinente, Efficiente*);
  - Indice di qualità delle motivazioni scritte (rubrica qualitativa a 3 livelli: menzione di requisiti, analisi delle conseguenze, confronto di alternative).

---

## Analisi statistica e criteri di successo {#sec-analisi-risultati}

- **Trattamento statistico:**
  - Calcolo di statistiche descrittive (mediana, intervallo interquartile, medie e deviazioni standard);
  - Stima delle dimensioni dell'effetto (*effect size*, es. $d$ di Cohen o $r$ di Wilcoxon) con intervalli di confidenza al 95%;
  - Data la dimensione contenuta dei campioni tipici scolastici (5–20 studenti per classe), l'analisi quantitativa deve essere interpretata con prudenza ed essere corroborata dall'analisi qualitativa dei percorsi individuali e delle trascrizioni conversazionali.
- **Dichiarazione delle minacce alla validità:**
  - *Effetto novità*: Entusiasmo iniziale per l'uso dell'IA generativa multimodale e delle Gem in chat;
  - *Apprendimento esterno*: Studio autonomo a casa o supporto di pari tra le sessioni di laboratorio;
  - *Maturazione naturale*: Miglioramento fisiologico delle competenze informatiche dovuto al normale avanzamento dell'anno scolastico.

### Criteri di successo definiti a priori
1. **Incremento significativo nel post-test e nel trasferimento**: Miglioramento misurabile nella capacità di modellazione e interrogazione autonoma (fase 9 / Tappa 9) rispetto al livello di ingresso rilevato nel pre-test.
2. **Riduzione della dipendenza dall'aiuto**: Diminuzione visibile del livello medio di aiuto richiesto (da L3/L4 verso L0/L1) tra le prime tappe del percorso e le fasi conclusive.
3. **Tenuta maieutica del tutor LLM nella fase pilota**: Tasso di mancata fuga della soluzione superiore al 95% nelle trascrizioni conversazionali della Gem in Google Classroom, senza rilascio indebito di schemi completi non richiesti dallo scaffolding controllato.
4. **Miglioramento della capacità critica e di motivazione**: Incremento qualitativo dei testi esplicativi forniti dagli studenti nell'analisi nomi-verbi, nelle cardinalità e nella discussione delle forme normali.
5. **Sostenibilità operativa per il docente**: Tempo medio di impostazione del compito in Google Classroom contenuto entro i 15 minuti; tempo di lettura del report e campionamento delle trascrizioni compatibile con il normale orario di servizio curricolare.
6. **Zero incidenti di sicurezza e privacy**: Nessun dato personale di studenti condiviso all'esterno dell'ambiente protetto di Google Workspace for Education e rispetto integrale della normativa GDPR.

---

## Etica, governance e consenso {#sec-etica-governance}

- **Approvazione formale degli organi collegiali:** Delibera del Collegio dei Docenti e del Consiglio di Istituto sull'adozione della sperimentazione didattica con l'IA.
- **Coinvolgimento del DPO e informativa scolastica:** Emissione del parere favorevole sulla Valutazione d'Impatto sulla Protezione dei Dati (DPIA) relativa all'uso di Google Workspace for Education e delle Gem/LLM, con informativa dettagliata alle famiglie e agli studenti.
- **Volontarietà e diritto di recesso:** Possibilità per ogni studente di partecipare senza obbligo e di ritirarsi in qualsiasi momento optando per il percorso didattico tradizionale con correzione periodica del docente, senza alcuna penalizzazione sul piano valutativo curricolare.
- **Restituzione formativa e debriefing:** Sessione finale di confronto in classe con gli studenti per discutere i risultati complessivi, le difficoltà cognitive riscontrate, i limiti riscontrati nelle risposte del modello linguistico e il ruolo consapevole e critico dell'IA generativa nelle professioni informatiche.
