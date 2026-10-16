# Socratic-DB — Tutor socratico per la progettazione di basi di dati relazionali

Si propone una sperimentazione didattica dell'uso dell'IA a fini didattici che permetta di trasformare l'uso della LLM da strumento a cui delegare il pensiero a strumento che sviluppa il ragionameto da progettista di basi di dati relazionali.
La LLM non deve "risolvere" il problema ma deve essere un **tutor socratico**: stimola il pensiero critico e la capacità modellistica attraverso domande e correzioni guidate degli errori (*learning from feedback*).

---

## 1. Specifica pedagogica

### 1.1 Destinatari

Studenti del triennio di un istituto tecnico a indirizzo informatico (o di un primo corso universitario di Basi di Dati), in classi di 15–30 persone, con lavoro individuale o a coppie. Il sistema è pensato anche per la preparazione a prove d'esame che richiedono progettazione concettuale, logica e query SQL.

### 1.2 Prerequisiti

- Concetti base di insieme, relazione e logica del primo ordine a livello elementare.
- Familiarità con tabella, riga, colonna, chiave.
- Uso minimo di un terminale o di un editor di testo e di git (introdotto nelle prime due ore).
- Nessuna conoscenza preliminare di SQL avanzato: JOIN, GROUP BY e sottoquery sono obiettivi del percorso.

### 1.3 Obiettivi di apprendimento

Al termine lo studente è in grado di, **autonomamente e senza tutor**:

- **O1.** Ricavare da una traccia dati, operazioni e vincoli (espliciti e impliciti), distinguendo ciò che è dichiarato da ciò che è assunto.
- **O2.** Costruire un modello concettuale ER con entità, attributi, associazioni, cardinalità minime e massime, e motivare ogni scelta.
- **O3.** Distinguere i vincoli rappresentabili nello schema da quelli che richiedono altri meccanismi (CHECK, UNIQUE, trigger, controllo applicativo).
- **O4.** Tradurre il modello concettuale in schema relazionale scegliendo strategie adeguate per gerarchie e associazioni 1:1, trattando i valori nulli e verificando la normalizzazione (1NF, 2NF, 3NF; BCNF se giustificata).
- **O5.** Implementare lo schema in SQLite con tipi e vincoli appropriati.
- **O6.** Costruire dati di test significativi, inclusi casi limite, nulli e assenza di corrispondenze.
- **O7.** Scrivere query SQL corrette, verificarle su dati propri e motivarne la correttezza.
- **O8.** Rivedere la propria soluzione a partire da un feedback e giustificare la modifica.

### 1.4 Ruoli

**Docente**

- Predispone tracce, soluzioni di riferimento *multiple* (anche alternative valide), dataset nascosti, test e rubriche.
- Decide la sequenza, i tempi e i livelli di aiuto massimi consentiti per ciascun esercizio.
- Legge le consegne (commit e Merge Request) e i log aggregati del processo; commenta in modo umano.
- **È l'unico a esprimere valutazioni.** Conduce la prova individuale di trasferimento.
- Revisiona periodicamente un campione di dialoghi per individuare errori del tutor.

**LLM (tutor)**

- Compito unico: trasformare le *diagnosi strutturate* prodotte dai controlli deterministici in una risposta socratica, al livello di aiuto richiesto dallo stato del dialogo.
- Chiede allo studente di motivare le scelte e di riformulare.
- Non assegna punteggi, non dichiara «superato/non superato», non fornisce la soluzione completa, non esegue SQL.
- Dove non c'è diagnosi deterministica (decisioni progettuali), formula domande e controesempi, dichiarando che esistono più soluzioni accettabili.

**Sistema deterministico (orchestratore e controlli)**

- Mantiene lo stato del percorso, valida i formati, esegue DDL, dati e query in SQLite isolato, confronta i risultati con i test del docente, produce le diagnosi.

### 1.5 Verifica dell'apprendimento: prodotto, processo, trasferimento

La qualità della soluzione finale non dimostra che lo studente l'abbia compresa. Si raccolgono evidenze distinte:

| Dimensione | Evidenza | Fonte |
| --- | --- | --- |
| Qualità progettuale | Schema corretto, completo, pertinente | Controlli deterministici + lettura del docente |
| Ragionamento | Motivazioni di cardinalità, chiavi e vincoli | Campo `motivazione` nei file + dialogo (lettura del docente) |
| Revisione | Correzione autonoma dopo feedback | Storia dei commit e dei livelli di aiuto richiesti |
| Competenza SQL | Query eseguibili e corrette su dati significativi | Test automatici sul dataset del docente |
| Trasferimento | Soluzione di una traccia nuova, senza assistenza | Prova individuale in aula, valutata dal docente |

Solo l'ultima riga, insieme alla lettura umana delle altre, concorre alla valutazione scolastica.

### 1.6 Rischi didattici e contromisure

- **Tutor come sistema di sblocco.** Chi deve raggiungere una soglia ottimizza il punteggio, non la comprensione. *Contromisura:* nessuna soglia; l'avanzamento è consigliato, non vincolato; i punti aperti restano visibili.
- **Delega del pensiero.** *Contromisura:* ogni consegna richiede una motivazione scritta dallo studente; richiesta di aiuto ai livelli alti registrata; prova finale senza tutor.
- **Giudizi non riproducibili.** *Contromisura:* ogni affermazione sulla correttezza proviene da un controllo deterministico ripetibile.
- **Fiducia eccessiva nel tutor.** *Contromisura:* il tutor dichiara quando non è certo e rimanda al docente.

---

## 2. Protocollo didattico

### 2.1 Il percorso in nove fasi

Le prime otto fasi si svolgono con il tutor; la nona è individuale e senza tutor. Il percorso distingue progettazione concettuale e logica, chiarisce i vincoli e introduce verifiche effettive dell'esecuzione SQL.

| # | Fase | Attività dello studente | Criteri verificabili (esempi) | Controllo |
| --- | --- | --- | --- | --- |
| 1 | Requisiti | Elenca dati da memorizzare, operazioni richieste, vincoli espliciti e impliciti, ambiguità da chiarire | Copertura delle voci richieste dal docente (checklist); vincoli impliciti individuati; ambiguità motivate | Checklist del docente; domande del tutor |
| 2 | Nomi-verbi e glossario | Estrae concetti candidati e li definisce senza assumere che ogni nome sia entità e ogni verbo associazione | Ogni voce ha definizione non circolare; sinonimi/omonimi dichiarati; motivazione della classificazione | Controllo di presenza e di circolarità semplice; tutor sul resto |
| 3 | Modello concettuale ER | Entità, attributi, associazioni, cardinalità min/max, identificatori | Schema valido nel formato; ogni entità ha identificatore; cardinalità coerenti con i casi d'uso del docente; ogni elemento tracciabile a un requisito | Validatore + test di scenario (§3.6) |
| 4 | Vincoli del dominio | Classifica i vincoli: rappresentati nello schema, CHECK/UNIQUE, inter-relazione o temporali (trigger/applicativo) | Ogni vincolo ha tipo, formulazione non ambigua e meccanismo previsto; i temporali definiscono intervallo, sovrapposizione e concorrenza | Checklist; tutor conduce l'elicitazione |
| 5 | Modello relazionale | Applica le regole di traduzione; PK, FK, nullabilità, N:M, gerarchie, 1:1; dipendenze funzionali | Nessuna FK orfana; PK in ogni tabella; N:M risolte; nulli coerenti con le partecipazioni minime; 1NF/2NF/3NF verificate sulle dipendenze dichiarate | Validatore + calcolo deterministico delle forme normali |
| 6 | Implementazione SQL (DDL) | Scrive il DDL SQLite con tipi e vincoli | DDL eseguibile; struttura (`PRAGMA table_info`, `foreign_key_list`) coerente con lo schema relazionale; violazioni attese rifiutate | Esecuzione reale + test negativi |
| 7 | Popolamento e test | Scrive INSERT significativi: casi limite, nulli, assenze di corrispondenza | Dati accettati dal DDL; copertura dei casi richiesti (es. cliente senza ordini); casi invalidi rifiutati | Esecuzione reale + checklist di copertura |
| 8 | Query e verifica | Scrive, esegue, confronta e motiva le query | Risultato uguale all'atteso sul dataset nascosto del docente; sintassi eseguibile; motivazione della scelta di JOIN/aggregazione | Esecuzione reale + confronto di insiemi |
| 9 | Prova di trasferimento | Affronta una traccia nuova, individualmente e senza tutor | Rubrica del docente per O1–O7 | Docente |

**Sulla generazione automatica.** Lo studente scrive di norma DDL e INSERT: sono competenze da acquisire. Un DDL di riferimento può essere generato da un *generatore deterministico* (non dalla LLM) a partire dallo schema relazionale solo dopo che lo schema ha superato le verifiche indipendenti, ed è reso disponibile come aiuto di livello 4 (§2.3) oppure per studenti con difficoltà dichiarate, sempre dopo l'esecuzione di test di coerenza. Un dataset di riferimento è fornito dal docente, non inventato dalla LLM.

### 2.2 Errori oggettivi e decisioni progettuali

Il sistema distingue due classi di rilievi, con trattamento diverso.

- **Errori oggettivamente verificabili:** formato non valido, FK verso tabella inesistente, tabella senza PK, N:M non risolta, DDL non eseguibile, violazione di un vincolo dichiarato dalla traccia, query che non restituisce il risultato atteso, dipendenza funzionale che viola la 3NF. Il tutor li segnala con certezza e li guida a correggerli.
- **Decisioni progettuali con più soluzioni corrette:** attributo o entità, strategia di traduzione di una gerarchia, accorpamento o tabella separata per una 1:1, uso di chiave surrogata. Il tutor non dichiara errore; chiede di motivare, mostra le conseguenze con un controesempio e accetta ogni soluzione coerente con i requisiti. Il docente fornisce per ogni esercizio un insieme di soluzioni alternative valide usate nei test.

### 2.3 Livelli di aiuto progressivi

| Livello | Forma dell'aiuto | Quando |
| --- | --- | --- |
| L0 | Solo esito dei controlli: area interessata e numero di problemi, senza dettagli | Primo tentativo |
| L1 | Domanda mirata sul problema specifico | Dopo L0 se il problema persiste |
| L2 | Controesempio dal dominio (dati concreti che violano l'intento) | Dopo L1 non risolutivo |
| L3 | Spiegazione del principio applicabile (non della soluzione) | Dopo L2 o su richiesta |
| L4 | Esempio svolto parziale su un caso analogo di altro dominio, seguito da un nuovo esercizio autonomo | Dopo L3 o su richiesta motivata |

Regole: l'aiuto sale di un livello alla volta; lo studente può chiedere un livello superiore (la richiesta è registrata, senza penalità); il docente può fissare per esercizio il livello massimo; la soluzione completa non è mai fornita.

### 2.4 Ciclo di revisione

1. Lo studente propone una soluzione e ne spiega il motivo (campo `motivazione`).
2. I controlli deterministici producono le diagnosi; il tutor ne seleziona *una* e pone una domanda mirata.
3. Lo studente rivede la soluzione e giustifica la modifica nel messaggio di commit.
4. Il sistema riesegue i controlli sulla proprietà interessata, con criteri espliciti.
5. Se serve, il tutor passa al livello successivo; al livello L4 propone un esempio parziale e un nuovo esercizio autonomo.

### 2.5 Padronanza per competenza (al posto delle soglie)

Per ogni competenza (O1–O7) il sistema mostra, non un punteggio, ma lo stato di una checklist di criteri verificabili, con tre stati descrittivi:

- **Da lavorare:** uno o più criteri oggettivi non soddisfatti.
- **In sviluppo:** criteri oggettivi soddisfatti solo con aiuto di livello ≥ L3.
- **Acquisito sotto guida:** criteri soddisfatti con aiuto ≤ L2 e motivazioni presenti.

Questi stati sono *indicatori di processo per lo studente e per il docente*, non voti. L'acquisizione effettiva è accertata solo dalla fase 9. L'avanzamento è libero: il tutor può consigliare di tornare su un punto aperto, ma l'unico blocco è tecnico (non si può scrivere il DDL senza uno schema relazionale parsabile).

### 2.6 Precisazioni tecniche incorporate

- **Nomi e verbi:** euristica, non algoritmo. La classificazione dipende dal significato nel dominio; il tutor non la «corregge», chiede di motivarla.
- **Gerarchie:** l'eliminazione non è regola universale; si valutano accorpamento nella superclasse, nelle sottoclassi o tabelle separate, in base a copertura, disgiunzione e accessi.
- **Relazioni 1:1:** non si accorpano sempre. Si considerano partecipazione obbligatoria, nullabilità, UNIQUE sulla FK e dipendenze.
- **Normalizzazione:** 1NF, 2NF, 3NF sempre; BCNF solo se giustificata dalla traccia. La 4NF non è richiesta salvo previsione curricolare.
- **Valori nulli:** trattati già nella modellazione (partecipazione minima 0 o 1, attributi opzionali), poi tradotti in NOT NULL o ammessi.
- **Vincoli temporali:** es. «un medico non può visitare due pazienti nella stessa ora» richiede di definire intervallo (inizio/fine, aperto/chiuso), sovrapposizione e concorrenza. Un CHECK SQLite non può verificare vincoli su più righe: servono UNIQUE su slot discreti, trigger o controllo applicativo, e il test deve verificarlo.

### 2.7 Metriche separate

1. **Qualità del modello** (calcolata dai controlli): completezza rispetto ai requisiti del docente, correttezza dei controlli oggettivi, minimalità (elementi non tracciabili), pertinenza, forme normali raggiunte.
2. **Qualità della spiegazione** (letta dal docente su campione, con rubrica a 3 livelli): la motivazione cita requisiti, conseguenze, alternative scartate.
3. **Padronanza dello studente:** prova di trasferimento e capacità di revisione (dai commit).

Le tre misure non sono sommate in un punteggio unico.

---

## 3. Prototipo tecnico minimo

### 3.1 Principi

- Open source, on-premise, senza servizi esterni.
- Agenti semplici, ciascuno con un solo compito; le decisioni di correttezza sono deterministiche.
- Un solo formato testuale per modelli concettuale e relazionale.
- Consegna e feedback tramite repository.

### 3.2 Architettura del prototipo

```
[Studente] --testo/YAML--> [Interfaccia unica: Open WebUI o CLI/FastAPI]
                                   |
                                   v
                        [Orchestratore (Python, FSM)]
              stato del percorso, livello di aiuto, log pseudonimi
                 |                    |                      |
                 v                    v                      v
      [Validatori YAML]     [Esecutore SQLite]      [Tutor LLM (1 modello)]
  schema, FK, PK, forme    isolato, in memoria,      riceve solo diagnosi
  normali (deterministici) test del docente          + livello di aiuto
                 \____________ diagnosi strutturate ____________/
```

Flusso: lo studente consegna un file; l'orchestratore lo valida, esegue i controlli, costruisce le diagnosi; il tutor LLM le trasforma in una risposta socratica al livello di aiuto corrente; l'orchestratore verifica che la risposta non contenga la soluzione (§3.6) e la restituisce.

### 3.3 Hardware e scelta del modello

Macchina Linux con 64 GB di RAM e GPU da 32 GB di VRAM:

- **Runtime di inferenza:** Ollama (semplicità) oppure llama.cpp/vLLM (controllo e prestazioni); API compatibile OpenAI su localhost.
- **Un solo modello linguistico**, con ragionevole capacità di coding e ragionamento in italiano e licenza permissiva, quantizzato in modo da stare interamente nella VRAM (indicativamente fino a \~30B parametri in quantizzazione a 4–5 bit con contesto di 16–32k token). Candidati da confrontare sul golden set (§3.6): `gpt-oss-20b` (Apache 2.0), un modello della famiglia Qwen di 30–32B con buone capacità di codice, un modello di dimensioni analoghe di altra famiglia. La scelta si fa sui risultati del golden set, non per reputazione; le versioni disponibili vanno verificate al momento dell'installazione.
- **Temperatura bassa** e seed fisso nei test per massimizzare la ripetibilità.
- **Concorrenza:** con una sola GPU, una coda di richieste; 15–30 studenti che lavorano a ritmo di dialogo sono gestibili, con latenze di alcuni secondi per risposta.
- **Modelli di visione:** fuori dal prototipo (§3.9).

### 3.4 Formato strutturato unico (YAML validato con JSON Schema)

Un solo formato, con campo `tipo`, per i due livelli di modello. I diagrammi (Mermaid) sono *prodotti* dal sistema a partire dal YAML, per visualizzazione, e non sono input.

**Modello concettuale**

```yaml
versione: 1
tipo: concettuale
entita:
  - nome: Paziente
    attributi:
      - {nome: cf, tipo: stringa, identificatore: true}
      - {nome: telefono, tipo: stringa, opzionale: true}
    motivazione: 'Il codice fiscale identifica il paziente nel testo.'
  - nome: Medico
    attributi:
      - {nome: matricola, tipo: stringa, identificatore: true}
associazioni:
  - nome: Visita
    partecipanti:
      - {entita: Paziente, card: '0..N'}
      - {entita: Medico, card: '0..N'}
    attributi:
      - {nome: inizio, tipo: datetime}
      - {nome: durata_min, tipo: intero}
    motivazione: 'Una visita ha data e durata, quindi e una associazione con attributi.'
vincoli:
  - id: V1
    testo: 'Un medico non ha due visite con intervalli sovrapposti.'
    classe: temporale
    meccanismo: trigger
```

**Modello relazionale**

```yaml
versione: 1
tipo: relazionale
tabelle:
  - nome: Visita
    colonne:
      - {nome: id, tipo: INTEGER, nullo: false}
      - {nome: cf_paziente, tipo: TEXT, nullo: false}
      - {nome: matricola, tipo: TEXT, nullo: false}
      - {nome: inizio, tipo: TEXT, nullo: false}
      - {nome: durata_min, tipo: INTEGER, nullo: false}
    pk: [id]
    fk:
      - {colonne: [cf_paziente], riferisce: 'Paziente(cf)', on_delete: RESTRICT}
      - {colonne: [matricola], riferisce: 'Medico(matricola)', on_delete: RESTRICT}
    unique: [[matricola, inizio]]
    check: ['durata_min > 0']
    dipendenze: ['id -> cf_paziente, matricola, inizio, durata_min']
    motivazione: 'Chiave surrogata: la stessa coppia paziente-medico puo avere piu visite.'
```

La presenza esplicita di tipi, nullabilità, FK, vincoli e dipendenze funzionali rende possibile il calcolo deterministico di chiavi candidate e forme normali (chiusura degli attributi) e il confronto con lo schema SQLite effettivo.

### 3.5 Esecutore SQLite isolato

Requisiti di isolamento, applicati a ogni esecuzione:

- Processo separato (container senza rete, utente non privilegiato, filesystem in sola lettura tranne una directory temporanea) o, come minimo, `subprocess` con limiti `rlimit` su CPU, memoria e dimensione dei file.
- Database **in memoria** o file temporaneo distrutto al termine; una istanza per tentativo.
- `PRAGMA foreign_keys = ON` sempre attivo; in sola lettura per le query (`PRAGMA query_only = ON` o apertura `mode=ro`).
- Autorizzatore SQLite (`set_authorizer`) che nega `ATTACH`, `load_extension`, e scritture fuori dalla fase di DDL/popolamento.
- Timeout (es. 2 s) e limite al numero di righe restituite.
- Il dataset nascosto del docente non è mai visibile allo studente: le query dello studente vi sono eseguite e lo studente vede solo l'esito del confronto, la prima differenza e un campione limitato.

### 3.6 Test automatici

Tre famiglie di test, tutte eseguibili in pytest e in CI.

**A. Test dei controlli deterministici**

- Validatore: file validi e invalidi per ogni regola (FK orfana, PK assente, N:M non risolta).
- Forme normali: tabelle con dipendenze note; verifica di 2NF, 3NF, BCNF attese.
- Esecutore: DDL valido, DDL con errore, tentativi di `ATTACH`, loop infinito, query lenta.
- DDL ↔ schema relazionale: la struttura di SQLite coincide con quella dichiarata.

**B. Test sugli esercizi (predisposti dal docente per ogni traccia)**

- Soluzioni di riferimento multiple e valide, che devono essere accettate dal sistema.
- Soluzioni errate catalogate per tipo di errore, ciascuna con la diagnosi attesa.
- *Test di scenario:* dati di prova che lo schema deve poter rappresentare (es. paziente senza visite, medico con due visite) e dati che deve rifiutare.
- Query: insiemi attesi sul dataset nascosto, con indicazione se l'ordine conta.

**C. Test del tutor (golden set)**

- Almeno 30 casi per fase: corretto, errato (per tipo di errore), alternativo valido.
- *Diagnosi:* il tutor non deve contraddire i controlli; non deve segnalare errori su soluzioni alternative valide.
- *Aderenza al livello:* a L1 non compaiono controesempi o soluzioni; a L2 compare un controesempio.
- *Non-fuga della soluzione:* controllo automatico sulla risposta (assenza di blocchi YAML/SQL completi in fasi 1–5 e 8; per le fasi 6–7 assenza del DDL di riferimento) con rifiuto e rigenerazione.
- *Revisione umana* di un campione da parte di due docenti, con calcolo dell'accordo (kappa di Cohen). Una LLM-judge può servire solo per regressione, mai come misura di validità.

### 3.7 System prompt del tutor (versione per il prototipo)

```text
Sei DB-Socrates, tutor di Basi di Dati. Ricevi in ingresso: (1) la fase corrente,
(2) il file consegnato dallo studente, (3) un elenco di DIAGNOSI prodotte da
controlli automatici, (4) il LIVELLO DI AIUTO consentito (L0-L4).

Regole:
- Le diagnosi sono la verita tecnica: non contraddirle e non aggiungerne.
- Scegli UNA diagnosi alla volta e rispondi solo al livello di aiuto indicato.
- Non fornire mai schemi, DDL o query risolutive. Non assegnare punteggi.
- Per le decisioni progettuali segnala che esistono piu soluzioni valide e chiedi
  di motivare la scelta.
- Chiedi sempre allo studente di giustificare la modifica che propone.
- Se non sei sicuro, dillo e rimanda al docente.
- Rispondi in italiano, in massimo 150 parole.
```

### 3.8 GitLab come consegna e revisione

GitLab Community Edition on-premise (o Forgejo/Gitea), con runner Docker senza rete.

- **Repository modello** del docente per esercizio: traccia, template dei file YAML e SQL, CI configurata. Studenti o coppie lavorano in un *fork/gruppo privato* con identificativo pseudonimo.
- **Struttura:** `01_requisiti.md`, `02_glossario.md`, `03_concettuale.yaml`, `04_vincoli.md`, `05_relazionale.yaml`, `06_schema.sql`, `07_dati.sql`, `08_query.sql`, `motivazioni.md`.
- **Commit** a ogni revisione, con messaggio che spiega *perché*; la cronologia è evidenza della capacità di revisione.
- **Merge Request** per ogni fase come consegna: la pipeline CI esegue validatori ed esecutore SQLite e pubblica un report tecnico (cosa passa, cosa no). Il tutor LLM può essere invocato dall'interfaccia sul contenuto del commit.
- **Review umana:** il docente commenta la MR (anche a campione); i commenti del docente sono distinti da quelli automatici, etichettati come «verifica tecnica automatica, non valutativa».
- **I risultati della CI non producono voti** e non sono esportati nel registro. Il docente può consultarli come informazione di processo.
- Esempio minimo di pipeline:

```yaml
stages: [valida, esegui]
valida:
  stage: valida
  script: python -m socratic.validate 03_concettuale.yaml 05_relazionale.yaml
esegui:
  stage: esegui
  script: python -m socratic.run --ddl 06_schema.sql --dati 07_dati.sql --query 08_query.sql --test tests/
  allow_failure: true
```

### 3.9 Ipotesi di sistema avanzato (dopo la sperimentazione)

- **Visione artificiale.** Un modello multimodale trascrive fotografie di schemi a mano nello stesso YAML. La trascrizione è sempre un'*ipotesi*: il sistema la mostra come diagramma, evidenzia gli elementi incerti (cardinalità, attributi poco leggibili) e **consente la correzione manuale** del testo prima di ogni valutazione. Si misura separatamente l'errore di trascrizione.
- **Più agenti con un solo compito:** trascrittore, verificatore di vincoli, generatore di controesempi, tutor dialogico, riassuntore per il docente; coordinati dall'orchestratore.
- **Più notazioni** (Mermaid, PlantUML, diagrammi ER) tramite convertitori verso e da YAML, con test di round-trip.
- **RAG** su dispense, rubriche e soluzioni alternative del docente.
- **Cruscotto per il docente** con aggregati formativi: errori frequenti, livelli di aiuto, tempi.
- **Analisi di plagio e di delega** per studenti che consegnano soluzioni non coerenti con la cronologia del dialogo.
- **Più modelli** (reasoning/coding e visione) con coda e instradamento.

---

## 4. Verifica normativa e sperimentazione

Quanto segue è una traccia operativa da validare con il Responsabile della protezione dei dati (DPO) dell'istituto e con il dirigente prima dell'avvio; non costituisce parere legale.

### 4.1 Trattamento dei dati

| Aspetto | Scelta |
| --- | --- |
| Titolare | L'istituzione scolastica o universitaria |
| Finalità | Supporto didattico formativo; eventuale ricerca didattica in forma aggregata e pseudonimizzata |
| Base giuridica | Esecuzione di un compito di interesse pubblico (art. 6.1.e GDPR); per la ricerca, informativa e consenso o altra base individuata dal DPO |
| Minori | Informativa chiara a studenti e famiglie; valutare il consenso per i minori di 14 anni secondo la normativa nazionale per i servizi digitali |
| Dati trattati | Contenuti consegnati (schemi, SQL, motivazioni), dialoghi, log tecnici; **nessun dato personale reale** nelle tracce e nei dataset |
| Minimizzazione | Identificatori pseudonimi (es. `s017`); nessun nome nei prompt; foto (fase avanzata) con eliminazione dell'originale dopo la trascrizione |
| Conservazione | Dialoghi e log per l'anno scolastico, poi cancellazione o anonimizzazione; ricerca solo su dati anonimi |
| Accesso | Studente: i propri dati. Docente: dati del proprio gruppo. Amministratore: solo accesso tecnico |
| Destinatari esterni | Nessuno: modello e servizi in locale |
| Diritti | Accesso, rettifica e cancellazione gestiti dalla scuola |

Da prevedere: informativa, registro dei trattamenti, valutazione d'impatto (DPIA) per l'uso di sistemi di IA con minori, istruzioni agli studenti di non inserire dati personali propri o altrui.

### 4.2 Misure di sicurezza

- Infrastruttura nella rete dell'istituto, nessuna uscita verso Internet per modello ed esecutore; aggiornamenti dei pacchetti tramite mirror controllato.
- Autenticazione con credenziali della scuola (SSO/LDAP), ruoli distinti (studente, docente, amministratore), cifratura del disco e dei backup.
- Esecutore SQL isolato (§3.5); i file consegnati sono trattati come non fidati (nessuna esecuzione fuori dal sandbox).
- Protezione da *prompt injection*: il contenuto dello studente è passato al tutor come dato delimitato; il tutor non ha strumenti, rete o accesso ai file; il controllo di non-fuga filtra le risposte.
- Log di accesso e di amministrazione; copia di sicurezza; procedura di segnalazione di incidenti.
- Licenze: verificare le licenze di modelli e pacchetti (es. Apache 2.0, licenze specifiche dei pesi) e la compatibilità con l'uso scolastico.

### 4.3 Valutazione e quadro regolatorio sull'IA

- **Nessun uso valutativo del sistema.** Punteggi o giudizi del tutor non esistono; gli esiti dei controlli tecnici sono informazioni formative. La valutazione resta una decisione umana del docente, fondata su prova individuale e lettura degli elaborati. Questo è coerente con il vincolo stabilito dal progetto e riduce l'esposizione alle regole sulle decisioni automatizzate (art. 22 GDPR).
- Il Regolamento europeo sull'IA classifica tra i sistemi ad alto rischio quelli destinati a valutare i risultati di apprendimento o a orientare l'accesso all'istruzione. Il prototipo è progettato per **non** essere un tale sistema: lo si documenta nella scheda del sistema e lo si ribadisce nell'informativa. Restano gli obblighi di trasparenza verso gli studenti (stanno dialogando con una IA) e di alfabetizzazione all'IA per chi la usa.
- Verificare con il DPO l'allineamento con le indicazioni del Ministero e del Garante per la protezione dei dati personali sull'IA nella scuola, che possono essere state aggiornate.
- Prevedere un **percorso alternativo** senza tutor per chi non intende usarlo.

### 4.4 Limiti del sistema

- La LLM può sbagliare, essere incoerente o troppo compiacente; per questo non decide sulla correttezza e il suo output è filtrato e campionato.
- I controlli deterministici verificano ciò che è stato formalizzato nei test: soluzioni valide non previste dal docente possono essere segnalate erroneamente. Va mantenuta una procedura di appello al docente e un arricchimento continuo delle soluzioni alternative.
- I vincoli che coinvolgono più righe o il tempo non sono garantiti dal solo DDL SQLite; il tutor lo spiega e il test li verifica solo per gli scenari previsti.
- Le normalizzazioni sono verificate sulle dipendenze funzionali dichiarate: se lo studente le dichiara in modo incompleto, il controllo è incompleto.
- Fotografie e disegni a mano (sistema avanzato): errori di trascrizione possibili; correzione manuale obbligatoria.
- Il tutor riduce ma non elimina il rischio di delega del pensiero; la fase 9 misura il trasferimento.
- Il sistema supporta un sottoinsieme di tracce preparate dal docente, non qualsiasi esercizio.
- Con GPU unica, la scalabilità è limitata a una classe per volta.

### 4.5 Protocollo di sperimentazione

Prima di estendere il progetto a più classi si svolge una sperimentazione controllata.

1. **Obiettivi.** Selezionare le competenze da migliorare tra modellazione ER, traduzione relazionale, individuazione dei vincoli, scrittura SQL (O2–O7).
2. **Strumenti di misura.** Una prova iniziale (pre-test), esercizi durante il percorso e una prova finale individuale (post-test), più una prova di trasferimento a distanza (es. 3–4 settimane), con rubrica comune a livelli descrittivi e correzione in cieco (valutatori che non conoscono il gruppo) su un campione, con calcolo dell'accordo tra valutatori.
3. **Prova del tutor su casi noti.** Esecuzione del golden set (§3.6C): modelli corretti, errati e soluzioni alternative valide, con criteri di accettazione stabiliti prima (per esempio: nessuna contraddizione con i controlli, fuga della soluzione sotto una soglia concordata, nessuna segnalazione errata su soluzioni valide nel campione).
4. **Pilota.** Una o due classi per 6–8 lezioni; osservazione di tempi, difficoltà, tipologie di errore, richieste di aiuto e malfunzionamenti tecnici; raccolta di commenti degli studenti e del docente. Si correggono prompt, test e tracce prima della fase successiva.
5. **Verifica del trasferimento.** Nuova traccia, senza LLM, confrontata con la prestazione iniziale.
6. **Analisi dei risultati.** Non solo punteggi: autonomia (livello di aiuto richiesto nel tempo), qualità delle motivazioni, capacità di correggere gli errori, tipologie di errori residui, esperienza percepita.
7. **Confronto controllato (fase successiva).** Se possibile, confrontare il tutor socratico con una esercitazione tradizionale (classi parallele o schema a rotazione/crossover) tenendo conto delle differenze iniziali (covariata: pre-test). Un miglioramento dopo l'attività è incoraggiante ma da solo non dimostra che sia stato causato dalla LLM.

**Dati da raccogliere (pseudonimi):** esiti dei test tecnici per tentativo, livello di aiuto richiesto, numero di iterazioni per problema, tempi, storia dei commit, punteggi di pre/post/trasferimento, questionario di percezione (utilità, autonomia, fiducia).

**Analisi:** statistiche descrittive e grandezza dell'effetto con intervalli di confidenza; con campioni piccoli, analisi prudente e qualitativa; dichiarazione esplicita delle minacce alla validità (selezione, effetto novità, apprendimento esterno, differenze tra docenti).

**Criteri di successo suggeriti** (da fissare prima dell'avvio): miglioramento nel post-test e nel trasferimento rispetto al pre-test; riduzione del livello medio di aiuto richiesto nel corso del percorso; motivazioni più complete alla fine; assenza di incidenti di privacy; sostenibilità del carico per il docente.

**Etica e governance:** approvazione del dirigente e, per la parte di ricerca, parere del DPO o dell'organo competente; possibilità di ritirarsi senza conseguenze; restituzione dei risultati agli studenti.

