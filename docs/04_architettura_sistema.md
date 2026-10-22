# Architettura del sistema e prototipo tecnico {#sec-architettura-sistema}

## Principi architetturali {#sec-principi-architetturali}

- **Open source, on-premise, senza servizi esterni**: L'intera catena di elaborazione risiede sull'hardware dell'istituto scolastico per garantire la sovranità dei dati e la conformità al GDPR.
- **Agenti semplici con responsabilità singola**: Le decisioni sulla correttezza sintattica e formale sono rigorosamente deterministiche; l'LLM si occupa esclusivamente della mediazione maieutica e del dialogo.
- **Un solo formato testuale strutturato**: Formato YAML validato tramite JSON Schema per modelli concettuali e relazionali.
- **Consegna e feedback tramite repository Git**: Flussi di lavoro basati su commit incrementali e pipeline CI per tracciare il processo di revisione.

## Architettura del prototipo {#sec-architettura-prototipo}

```text
[Studente] --testo/YAML--> [Interfaccia unica: Open WebUI o CLI/FastAPI]
                                   |
                                   v
                        [Orchestratore (Python, FSM)]
              stato del percorso, livello di aiuto, log pseudonimi
                 |                    |                      |
                 v                    v                      v
      [Validatori YAML]     [Esecutore SQLite]      [Tutor LLM (1 modello)]
  schema, FK, PK, forme    isolato, in memoria,      riceve diagnosi, risultati
  normali (deterministici) dati di test              delle query e livello di aiuto
                           dello studente
                 +---- diagnosi strutturate e risultati ----+
```

### Flusso operativo
1. Lo studente consegna un file (tramite commit/MR o interfaccia web).
2. L'orchestratore valida la sintassi e la conformità allo schema atteso.
3. Vengono eseguiti i controlli deterministici (integrità referenziale, normalizzazione, esecuzione su SQLite isolato) e costruite le diagnosi strutturate.
4. Il tutor LLM riceve le sole diagnosi e il livello di aiuto corrente, trasformandole in una risposta socratica conforme alle regole pedagogiche.
5. L'orchestratore applica un filtro di sicurezza (controllo di non-fuga della soluzione) e restituisce la risposta allo studente.

## Hardware e scelta del modello {#sec-hardware-modello}

Configurazione di riferimento per il server locale: **macchina Linux con 64 GB di RAM e GPU da 32 GB di VRAM**.

- **Runtime di inferenza:** Ollama (per semplicità di setup locale) oppure llama.cpp / vLLM (per massimo controllo, throughput e concorrenza); esposizione di API standard compatibile OpenAI su `localhost`.
- **Modello linguistico unico:** Un solo modello linguistico con provate capacità di coding e ragionamento in lingua italiana e licenza permissiva (es. Apache 2.0). Il modello deve essere quantizzato per risiedere interamente nei 32 GB di VRAM (indicativamente modelli da ~30B parametri con quantizzazione a 4–5 bit e contesto utile di 16–32k token).
- **Candidati per il confronto sul golden set:**
  - `gpt-oss-20b` (Apache 2.0);
  - Modelli della famiglia Qwen 2.5 / 3 (30–32B parametri);
  - Modelli open weights equivalenti con forte supporto SQL e logica.
  La scelta finale è guidata empiricamente dai risultati sul golden set (@sec-test-sistema), non dalla notorietà.
- **Parametri di inferenza:** Temperatura bassa ($T \approx 0.1 - 0.2$) e seed fisso nei test di conformità per massimizzare la riproducibilità.
- **Concorrenza:** Gestione di una coda FIFO con priorità singola GPU; con 5–20 studenti a ritmo di riflessione e digitazione, la latenza per turno di dialogo resta nell'ordine di pochi secondi.
- **Visione artificiale:** Esclusa dal prototipo iniziale; demandata al sistema avanzato (@sec-sistema-avanzato).

## Esecutore SQLite isolato {#sec-esecutore-sqlite}

Requisiti di isolamento e sicurezza per l'esecuzione di DDL, popolamento e query dello studente:

- **Isolamento a livello OS:** Processo separato in container Docker senza rete (`--network none`), utente senza privilegi (`nobody`/`runner`), filesystem montato in sola lettura ad eccezione di una directory `/tmp` volatile; in alternativa, `subprocess` vincolato con limiti rigidi di sistema (`rlimit` su CPU time, RSS memory e disk quota).
- **Database in memoria:** Utilizzo di database SQLite `:memory:` (o file temporaneo distrutto al termine dell'elaborazione); una nuova istanza pulita per ciascun tentativo.
- **Integrità referenziale attiva:** Esecuzione obbligatoria di `PRAGMA foreign_keys = ON;`.
- **Modalità sola lettura per la verifica delle query:** `PRAGMA query_only = ON;` o apertura della connessione in `mode=ro` durante la fase 8.
- **Autorizzatore SQLite attivo (`set_authorizer`):** Blocco categorico di istruzioni pericolose come `ATTACH DATABASE`, `DETACH DATABASE`, caricamento di estensioni native (`load_extension`), comandi di `PRAGMA` non autorizzati e operazioni di scrittura al di fuori delle fasi di DDL e popolamento.
- **Timeout e quote:** Limite di timeout stringente (es. massimo 2 secondi per query) e limite al numero di tuple restituite (max 100 righe) per prevenire blocchi da loop o prodotti cartesiani involontari.
- **Visibilità dei dati:** Lo studente esegue le proprie query esclusivamente sul proprio dataset di test. Se il docente attiva uno schema canonico con dataset di riferimento, quest'ultimo rimane completamente invisibile allo studente (il sistema notifica solo l'eventuale discrepanza o prima differenza riscontrata).

## Test automatici del sistema {#sec-test-sistema}

Il sistema integra tre famiglie di test automatici eseguibili in `pytest` e nella pipeline CI/CD:

### Test dei controlli deterministici {#sec-test-controlli-deterministici}
- **Validatore sintattico e semantico:** File YAML validi e casi di test negativi per ciascuna regola (FK orfane, PK mancanti, associazioni N:M non tradotte in tabelle ponte).
- **Calcolo delle forme normali:** Test con insiemi di dipendenze funzionali note per verificare il calcolo algebrico della chiusura degli attributi e la rilevazione di violazioni di 2NF, 3NF e BCNF.
- **Robustezza del sandbox:** Verifica che tentativi di attacco (injection di `ATTACH`, loop di ricorsione CTE, esaurimento memoria) vengano bloccati dall'autorizzatore e terminati per timeout.
- **Coerenza DDL ↔ Modello relazionale:** Verifica deterministica che le tabelle, colonne, indici e vincoli creati in SQLite (`PRAGMA table_info`, `PRAGMA foreign_key_list`) coincidano perfettamente con lo schema relazionale dichiarato nello YAML.
- **Derivazione automatica dei test negativi:** Generazione deterministica di casi di test che violano vincoli di integrità dichiarati (duplicazione PK, violazione NOT NULL, violazione CHECK).

### Test sugli esercizi (Golden set di ricerca e schema canonico) {#sec-test-esercizi}
- **Checklist dei requisiti:** Verifica che la copertura semantica dei termini sia rilevata correttamente sia su soluzioni esaustive sia su consegne parziali.
- **Golden set di ricerca:** Insieme calibrato di tracce con soluzioni multiple valide e soluzioni errate ottenute per mutazione deterministica (es. rimozione di una chiave esterna, cardinalità invertita, vincolo omesso), ciascuna con la corrispondente diagnosi attesa.
- **Schema canonico:** Esecuzione delle query attese sul dataset di riferimento con confronto tra insiemi di risultati.

### Test del tutor LLM (Golden set) {#sec-test-tutor-llm}
- **Casi di test:** Almeno 30 casi per ciascuna fase (soluzione corretta, soluzione con errore tipico, soluzione alternativa valida e non convenzionale).
- **Assenza di contraddizioni:** Il tutor non deve mai smentire una diagnosi deterministica né segnalare errori fittizi su varianti valide.
- **Aderenza al livello di aiuto:** A livello L1 il messaggio deve contenere solo domande; controesempi sono ammessi solo da L2; spiegazioni del principio solo da L3; nessun codice risolutivo completo a nessun livello.
- **Filtro di non-fuga della soluzione:** Verifica automatica che la risposta del tutor non contenga blocchi di codice completi o query risolutive; in caso di violazione, la risposta è rigettata e rigenerata con un prompt di ammonimento.
- **Valutazione semantica su query (fase 8):** Misura dell'accuratezza del parere non vincolante del tutor rispetto a valutatori umani su un corpus di query con errori tipici (filtro errato, JOIN incompleta, raggruppamento assente).
- **Validazione umana e accordo inter-valutatore:** Revisione in cieco su un campione di risposte da parte di docenti con calcolo dell'indice Kappa di Cohen.

### Verifica deterministica dei dati di test generati dalla LLM (fase 7, se abilitata) {#sec-verifica-dati-generati}
Quando il docente abilita la generazione assistita dei dati:
- Lo script SQL generato deve essere composto unicamente da istruzioni `INSERT`.
- Esecuzione obbligatoria senza errori sul DDL dello studente con `PRAGMA foreign_keys = ON;`.
- Verifica della copertura strutturale minima derivata dallo schema: numero minimo di righe per tabella, presenza di almeno un'istanza genitore priva di figli, presenza di valori nulli nelle colonne opzionali, valori ripetuti per consentire test di aggregazione (`GROUP BY` e `COUNT`).
- I casi invalidi generati per test negativo devono fallire l'inserimento.

## System prompt del tutor (Versione per il prototipo) {#sec-system-prompt}

```text
Sei DB-Socrates, tutor di Basi di Dati. Ricevi in ingresso: (1) la fase corrente,
(2) il file consegnato dallo studente, (3) un elenco di DIAGNOSI prodotte da
controlli automatici, (4) il LIVELLO DI AIUTO consentito (L0-L4),
(5) le eventuali SCORCIATOIE abilitate dal docente (DDL, DATI),
(6) in fase 8, il RISULTATO della query sui dati di test.

Regole:
- Le diagnosi sono la verita tecnica: non contraddirle e non aggiungerne.
- Scegli UNA diagnosi alla volta e rispondi solo al livello di aiuto indicato:
  L0-L2 maieutica (esito, domanda, controesempio); L3-L4 elicitazione
  (principio, esempio parziale su un altro dominio).
- Non fornire mai schemi, DDL o query risolutive. Non assegnare punteggi.
- Per le decisioni progettuali segnala che esistono piu soluzioni valide e chiedi
  di motivare la scelta.
- Esprimi un parere su completezza, minimalita, pertinenza o lessico solo se lo
  studente lo chiede, dichiarando che non e vincolante.
- Fase 8: confronta la richiesta, la query e il RISULTATO ricevuto; esprimi un
  parere non vincolante e trasformalo in domande (righe attese, mancanti o
  duplicate). Se i dati di test non permettono di distinguere una query
  corretta da una sbagliata, dillo e chiedi allo studente di aggiungere casi.
- Chiedi sempre allo studente di giustificare la modifica che propone.
- Se non sei sicuro, dillo e rimanda al docente.
- Se la scorciatoia DATI e attiva (fase 7): proponi INSERT coerenti con lo schema
  dello studente (valori plausibili, senza dati personali reali, con genitori
  senza figli, nulli e valori ripetuti); nessun altro codice.
- Rispondi in italiano, in massimo 150 parole (esclusi gli INSERT generati).
```

## GitLab / Forgejo come piattaforma di consegna e revisione {#sec-piattaforma-consegna}

Infrastruttura basata su istanza on-premise di **GitLab Community Edition** (o **Forgejo / Gitea**) affiancata da un runner Docker privo di connessione Internet.

- **Repository modello:** Predisposto dal docente per ogni esercitazione contenente: traccia, template vuoti dei file di consegna, schema JSON di validazione e file `.gitlab-ci.yml`.
- **Workflow studente:** Ogni studente o coppia lavora in un fork privato (o branch isolato) identificato da uno pseudonimo (es. `s017`).
- **File di consegna:**
  ```text
  01_requisiti.md
  02_glossario.md
  03_concettuale.yaml
  04_vincoli.md
  05_relazionale.yaml
  06_schema.sql
  07_dati.sql
  08_query.sql
  motivazioni.md
  ```
- **Commit motivati:** Ogni modifica deve essere accompagnata da un messaggio di commit esplicativo che motivi il perché della variazione; la cronologia Git costituisce la prova primaria della capacità di revisione autonoma.
- **Merge Request e Pipeline CI:** L'apertura della Merge Request per ciascuna consegna scatena la pipeline di validazione:
  ```yaml
  stages: [valida, esegui]

  valida:
    stage: valida
    script:
      - python -m socratic.validate 03_concettuale.yaml 05_relazionale.yaml

  esegui:
    stage: esegui
    script:
      - python -m socratic.run --ddl 06_schema.sql --dati 07_dati.sql --query 08_query.sql --test tests/
    allow_failure: true
  ```
- **Review umana del docente:** Il docente può intervenire direttamente nella discussione della Merge Request commentando a campione gli elaborati. Tutti i commenti automatici del sistema riportano chiaramente la dicitura: *«Verifica tecnica automatica, priva di valore valutativo»*.

## Strumento d'autore per il docente {#sec-strumento-autore}

Agente specializzato a compito unico per accelerare la preparazione dei materiali didattici senza trattare dati personali degli studenti:

1. **Input:** Inserimento del testo della traccia e selezione opzionale di uno schema-tipo dal catalogo di dominio.
2. **Generazione della bozza:** L'LLM propone la checklist dei requisiti (5–10 punti chiave); per il pacchetto esteso genera lo schema canonico, il dataset e le query attese per la fase 8.
3. **Controllo automatico di coerenza:** I validatori verificano la corrispondenza lessicale tra traccia e checklist e l'eseguibilità dello schema canonico.
4. **Validazione umana obbligatoria:** Il docente esamina la proposta tramite interfaccia visuale o Merge Request Git, apporta eventuali modifiche e approva il pacchetto, che viene congelato con un tag di versione immutabile.
5. **Ciclo di miglioramento continuo:** Eventuali falsi positivi segnalati dagli studenti consentono al docente di raffinare la checklist con una nuova versione del tag.

## Ipotesi di sistema avanzato (Post-sperimentazione) {#sec-sistema-avanzato}

Funzionalità previste per successive evoluzioni della piattaforma:
- **Visione artificiale per schemi manoscritti:** Modello multimodale (VLM) per la trascrizione automatica di diagrammi concettuali disegnati a mano libera su carta; la trascrizione produce un'ipotesi YAML che lo studente corregge e valida prima di avviare il dialogo.
- **Architettura multi-agente specializzata:** Disaccoppiamento tra agente trascrittore, agente per l'analisi di vincoli complessi, generatore di controesempi e sintetizzatore di report per il docente, coordinati da una FSM centrale.
- **Supporto multi-notazione:** Convertitori bidirezionali tra formato YAML e formati grafici o testuali (Mermaid, PlantUML, diagrammi relazionali Chen/Crow's Foot).
- **RAG locale:** Retrieval-Augmented Generation su slide di lezione, testi di riferimento e dispense del docente.
- **Cruscotto analitico:** Dashboard con indicatori aggregati di classe per identificare i concetti critici (es. frequenza di violazioni della 3NF, tempo medio di risoluzione delle chiavi esterne).
