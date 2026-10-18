# Socratic-DB — Tutor socratico per la progettazione di basi di dati relazionali

*«Dal metodo socratico al modello relazionale di Codd: la costruzione della conoscenza come dialogo tra l'arte della domanda e il rigore della struttura.»*

Si propone una sperimentazione sull'uso didattico dell'Intelligenza Artificiale che trasformi i modelli linguistici di grande dimensione (*Large Language Model*, LLM) da strumenti a cui delegare il pensiero a risorse capaci di sviluppare la *forma mentis* del progettista di basi di dati relazionali.

Un **LLM** non «risolve» il problema di modellizzazione e costruzione del database, ma **agisce** come un **tutor socratico**: stimola il **pensiero critico** e le competenze modellistiche attraverso domande e correzioni guidate degli errori (*learning from feedback*). La verità tecnica (correttezza di schemi, vincoli e SQL) è affidata a controlli deterministici; la valutazione resta al docente.

La fattibilità e l'efficacia didattica della proposta sono da sperimentare su più piani (la verifica di ciascuno è descritta nel §4.5):

- **Piano del modello linguistico.** Non sappiamo se tra le proprietà emergenti dei LLM ci siano l'abilità maieutica e la capacità elicitativa che vorremmo. Verifica: golden set (§3.6C; §4.5, punto 3).
- **Piano dell'infrastruttura di calcolo deterministica.** Un sistema che esegua i controlli e i processi richiesti è complesso: fattibilità e scalabilità non sono stimabili a priori, in assenza di prove empiriche. Verifica: test dei controlli (§3.6A-B) e pilota (§4.5, punto 4).
- **Piano dell'efficacia didattica.** Non è possibile stabilirla a priori: servono test diagnostici pre e post sperimentazione per misurare l'incremento delle prestazioni. Verifica: pre-test, post-test e trasferimento (§4.5, punti 2 e 5).
- **Piano della progressione didattica.** Il metodo e le fasi appaiono ben definiti per granularità e misurabilità, ma ciò va validato sperimentalmente: la suddivisione attuale potrebbe produrre un lavoro ingestibile per il docente o per lo studente, oppure risultare inefficace o inefficiente. Verifica: osservazione nel pilota e analisi dei risultati (§4.5, punti 4 e 6).

---

## 1. Specifica pedagogica

### 1.1 Destinatari

Studenti del secondo biennio e del quinto anno di un Istituto Tecnico Economico (ITE), indirizzo «Amministrazione, Finanza e Marketing», articolazione «Sistemi Informativi Aziendali» (SIA, codice ITSI), o di un Istituto Tecnico Tecnologico (ITT), indirizzo «Informatica e Telecomunicazioni», articolazione «Informatica» (codice ITIA), in classi da 5 a 20 persone, con lavoro individuale o a coppie.

Il sistema è progettato tenendo conto dei quadri di riferimento e dei nuclei fondanti della seconda prova scritta dell'Esame di Stato per le discipline d'indirizzo. I quadri di riferimento di ITIA e ITSI includono tra i nuclei la progettazione concettuale, logica e fisica di basi di dati e i linguaggi per basi di dati; la disciplina della seconda prova varia da un anno all'altro. Tali prove richiedono di ricavare le specifiche progettuali da una traccia reale, sviluppare la modellizzazione concettuale del problema, tradurla nel modello logico-relazionale, realizzare la base di dati e formulare le query di interrogazione in linguaggio SQL.

La sperimentazione può inoltre essere estesa e adattata come supporto all'auto-apprendimento guidato in un primo corso universitario di «Basi di Dati» (lauree triennali in Informatica o Ingegneria Informatica).

### 1.2 Prerequisiti

- **Matematica e logica di base**:
  - concetti elementari della teoria degli insiemi (rappresentazione, appartenenza, unione, intersezione, differenza/complementazione, prodotto cartesiano e concetto di relazione);
  - fondamenti di logica proposizionale e predicativa (valori di verità, connettivi logici `NOT`, `AND`, `OR`).
- **Concetti introduttivi di modellizzazione e basi di dati**:
  - comprensione intuitiva del modello concettuale (entità, associazione, attributo, cardinalità min/max e concetti base di gerarchia/specializzazione);
  - strutture del modello relazionale (concetti informali di tabella, riga/tupla, colonna/attributo, chiave primaria, chiave esterna e vincoli fondamentali di integrità).
- **Linguaggio SQL di base**:
  - familiarità elementare con la sintassi SQL per le interrogazioni semplici (clausole `SELECT`, `FROM`, `WHERE`); il consolidamento di interrogazioni complesse (`JOIN`, aggregazioni `GROUP BY` e sottoquery) è uno degli obiettivi formativi del percorso.
- **Competenze digitali e strumentali**:
  - uso base di un editor di testo o ambiente di sviluppo (IDE) e familiarità con i comandi fondamentali da terminale/CLI;
  - nozioni elementari di Git (`commit`, `push` e consegne tramite repository).

### 1.3 Obiettivi di apprendimento

Al termine lo studente è in grado di, **autonomamente e senza tutor**:

- **O1.** Ricavare da una traccia i dati, le operazioni e i vincoli (espliciti e impliciti), distinguendo ciò che è dichiarato da ciò che è assunto.
- **O2.** Costruire un modello concettuale Entità/Associazioni (*Entity/Relationship*, ER) con entità, attributi, associazioni, cardinalità minime e massime, e motivare ogni scelta.
- **O3.** Distinguere i vincoli rappresentabili nello schema da quelli che richiedono altri meccanismi (`CHECK`, `UNIQUE`, trigger, controllo applicativo).
- **O4.** Tradurre il modello concettuale in schema relazionale scegliendo strategie adeguate per gerarchie, associazioni 1:1 opzionali e obbligatorie, associazioni 1:N e associazioni N:M, trattando i valori nulli e verificando la normalizzazione (1NF, 2NF, 3NF; BCNF se giustificata).
- **O5.** Codificare lo schema usando i costrutti del *Data Definition Language* (DDL) di SQLite, con tipi e vincoli appropriati.
- **O6.** Costruire dati di test significativi, inclusi casi limite, nulli e assenza di corrispondenze, codificandoli con istruzioni del *Data Manipulation Language* (DML) di SQLite.
- **O7.** Scrivere query SQL corrette, verificarle su dati propri e motivarne la correttezza.
- **O8.** Rivedere la propria soluzione a partire da un feedback e giustificare la modifica. Apprendere un modello di sviluppo iterativo in cui la critica di ogni scelta conduce a un modello via via più completo, pertinente, minimale, intelligibile e coerente.

### 1.4 Ruoli

**Docente**

- Predispone tracce, soluzioni di riferimento *multiple* (anche alternative valide), dati di riferimento e dataset nascosti, test e rubriche di valutazione.
- Decide la sequenza, i tempi e i livelli di aiuto massimi consentiti per ciascun esercizio, e se abilitare la generazione automatica del DDL (fase 6) e dei dati (fase 7).
- Legge le consegne (commit e Merge Request) e i log del processo; commenta in modo umano le consegne.
- **È l'unico a esprimere valutazioni.** Conduce la prova individuale di trasferimento.
- Revisiona periodicamente un campione di dialoghi per individuare errori del tutor LLM.

**LLM (tutor)**

- Compito principale: trasformare le *diagnosi strutturate* prodotte dai controlli deterministici in una risposta socratica, al livello di aiuto richiesto dallo stato del dialogo. Le diagnosi sono vincolanti: la LLM non le contraddice.
- Chiede allo studente di motivare le scelte e di riformulare.
- Non assegna punteggi, non dichiara «superato/non superato», non fornisce la soluzione completa, non esegue SQL.
- Dove non c'è diagnosi deterministica (decisioni progettuali), formula domande e controesempi, dichiarando che esistono più soluzioni accettabili.
- Si comporta come sistema esperto che valuta costantemente, ma fornisce il proprio punto di vista **solo su richiesta** e dichiarandolo *non vincolante* (a differenza delle diagnosi deterministiche), su:
  - l'eliminazione delle ambiguità terminologiche e semantiche;
  - la completezza rispetto alle specifiche e alla possibilità di formulare le interrogazioni richieste dal testo;
  - la correttezza del modello e dei vincoli, oppure della sintassi, rispetto ai costrutti del modello in uso;
  - la minimalità, intesa come non ridondanza nei modelli e come realizzazione di query efficienti che non richiedono elaborazioni non necessarie;
  - la pertinenza del lessico rispetto al testo e al dominio.
- Procede in modo maieutico ai livelli di aiuto L0–L2 e passa all'elicitazione ai livelli L3–L4 (§2.3).
- Nella fase 7, se il docente abilita la generazione automatica dei dati, traduce i dati di riferimento del docente in istruzioni INSERT coerenti con lo schema dello studente; l'output è sempre sottoposto a verifica deterministica (§2.1).
- Se incerto, richiede di contattare il docente.

**Sistema deterministico (orchestratore e controlli)**

- Mantiene lo stato del percorso, valida i formati, esegue operazioni sullo schema (DDL), sui dati (DML) e sulle query (QL) in SQLite isolato, confronta i risultati con i test del docente e produce le diagnosi. Verifica anche i dati generati dalla LLM nella fase 7 e, se abilitato, genera il DDL dal modello relazionale consegnato.

### 1.5 Verifica dell'apprendimento: prodotto, processo, trasferimento

La qualità della soluzione finale non dimostra che lo studente l'abbia compresa. Si raccolgono evidenze distinte:

| Dimensione | Evidenza | Fonte |
| --- | --- | --- |
| Qualità progettuale | Schema corretto, completo, pertinente, minimale | Controlli deterministici + lettura del docente |
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
| 6 | Implementazione SQL (DDL) | Scrive il DDL SQLite con tipi e vincoli. Se il docente abilita la traduzione automatica, il DDL è generato deterministicamente dal modello relazionale consegnato e lo studente lo analizza e lo commenta | DDL eseguibile; struttura (`PRAGMA table_info`, `foreign_key_list`) coerente con lo schema relazionale; violazioni attese rifiutate | Esecuzione reale + test negativi |
| 7 | Popolamento e test | Scrive INSERT significativi: casi limite, nulli, assenze di corrispondenza. Se il docente abilita la generazione automatica, la LLM traduce i dati di riferimento del docente in INSERT coerenti con lo schema dello studente, che li verifica e li integra con casi propri | Dati accettati dal DDL; copertura dei casi richiesti (es. cliente senza ordini); casi invalidi rifiutati; dati generati uguali a quelli di riferimento (numero e contenuto delle tuple) | Esecuzione reale + checklist di copertura + confronto deterministico con i dati di riferimento |
| 8 | Query e verifica | Scrive, esegue, confronta e motiva le query | Risultato uguale all'atteso sul dataset nascosto del docente; sintassi eseguibile; motivazione della scelta di JOIN/aggregazione | Esecuzione reale + confronto di insiemi |
| 9 | Prova di trasferimento | Affronta una traccia nuova, individualmente e senza tutor | Rubrica del docente per O1–O7 | Docente |

**Sulla generazione automatica.** Per impostazione predefinita lo studente scrive DDL e INSERT: sono competenze da acquisire (O5, O6). Il docente può abilitare, per singolo esercizio, due scorciatoie:

- **DDL (fase 6):** generato da un *generatore deterministico* (non dalla LLM) a partire dallo schema relazionale, solo dopo che lo schema ha superato le verifiche indipendenti; la struttura ottenuta è poi confrontata con lo schema (§3.6A).
- **Dati (fase 7):** il docente fornisce i dati di riferimento in un formato neutro (CSV o YAML) e la LLM li traduce in istruzioni INSERT per lo schema dello studente; nessun dato è inventato dalla LLM. Lo script è accettato solo se supera una *verifica deterministica*: esecuzione senza errori sul DDL dello studente con chiavi esterne attive, stesso numero e contenuto di tuple dei dati di riferimento, copertura dei casi limite richiesti e rifiuto dei casi invalidi del docente (§3.6D). Se la verifica fallisce lo script non è consegnato: si rigenera (fino a un numero massimo di tentativi) oppure si segnala al docente.

Quando una scorciatoia è attiva, la competenza corrispondente non è esercitata in quella consegna e va verificata nella fase 9.

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

### 2.5 Padronanza per competenza

Per ogni competenza (O1–O7) il sistema mostra, non un punteggio, ma lo stato di una checklist di criteri verificabili, con tre stati descrittivi:

- **Da lavorare:** uno o più criteri oggettivi non soddisfatti.
- **In sviluppo:** criteri oggettivi soddisfatti solo con aiuto di livello ≥ L3.
- **Acquisito sotto guida:** criteri soddisfatti con aiuto ≤ L2 e motivazioni presenti.

Questi stati sono *indicatori di processo per lo studente e per il docente*, non voti. L'acquisizione effettiva è accertata solo dalla fase 9. L'avanzamento è libero: il tutor può consigliare di tornare su un punto aperto, ma l'unico blocco è tecnico (non si può scrivere il DDL senza uno schema relazionale analizzabile sul piano sintattico dal parser e verificabile sul piano semantico dal validatore).

### 2.6 Precisazioni tecniche incorporate

- **Nomi e verbi:** euristica, non algoritmo. La classificazione dipende dal significato nel dominio; il tutor non la «corregge», chiede di motivarla.
- **Gerarchie:** l'eliminazione non è regola universale; si valutano accorpamento nella superclasse, nelle sottoclassi o tabelle separate, in base a copertura, disgiunzione e accessi.
- **Relazioni 1:1:** non si accorpano sempre. Si considerano partecipazione obbligatoria, nullabilità, UNIQUE sulla FK e dipendenze.
- **Normalizzazione:** 1NF, 2NF, 3NF sempre; BCNF solo se giustificata dalla traccia. La 4NF non è richiesta salvo previsione curricolare.
- **Valori nulli:** trattati già nella modellazione (partecipazione minima 0 o 1, attributi opzionali), poi tradotti in NOT NULL o in attributi nullabili.
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
- **Concorrenza:** con una sola GPU, una coda di richieste; 5–20 studenti che lavorano a ritmo di dialogo sono gestibili, con latenze di alcuni secondi per risposta.
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
- *Non-fuga della soluzione:* controllo automatico sulla risposta (assenza di blocchi YAML/SQL completi in fasi 1–5 e 8; per le fasi 6–7 assenza del DDL di riferimento quando la scorciatoia è disattivata; con la scorciatoia dati attiva, assenza di INSERT diversi da quelli derivati dai dati del docente) con rifiuto e rigenerazione.
- *Revisione umana* di un campione da parte di due docenti, con calcolo dell'accordo (kappa di Cohen). Una LLM-judge può servire solo per regressione, mai come misura di validità.

**D. Verifica deterministica dei dati generati dalla LLM (fase 7, se abilitata)**

- Lo script generato si esegue senza errori sul DDL dello studente, con `PRAGMA foreign_keys = ON`.
- Numero di righe per tabella e contenuto delle tuple coincidono con i dati di riferimento (confronto di insiemi dopo normalizzazione dei tipi).
- Nessuna istruzione diversa da `INSERT`; nessun valore assente dai dati di riferimento.
- I casi invalidi del docente (violazioni di PK, FK, NOT NULL, CHECK) sono rifiutati dal DDL.
- Casi limite richiesti presenti (es. cliente senza ordini, valori nulli).
- Valutazione del tasso di successo al primo tentativo sul golden set, per scegliere il modello e il numero massimo di rigenerazioni.

### 3.7 System prompt del tutor (versione per il prototipo)

```text
Sei DB-Socrates, tutor di Basi di Dati. Ricevi in ingresso: (1) la fase corrente,
(2) il file consegnato dallo studente, (3) un elenco di DIAGNOSI prodotte da
controlli automatici, (4) il LIVELLO DI AIUTO consentito (L0-L4),
(5) le eventuali SCORCIATOIE abilitate dal docente (DDL, DATI).

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
- Chiedi sempre allo studente di giustificare la modifica che propone.
- Se non sei sicuro, dillo e rimanda al docente.
- Se la scorciatoia DATI e attiva (fase 7): traduci in INSERT SOLO i dati di
  riferimento forniti, senza aggiungere ne modificare valori; nessun altro codice.
- Rispondi in italiano, in massimo 150 parole (esclusi gli INSERT generati).
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
| Minori | Studenti in prevalenza minorenni (circa 14–19 anni): informativa chiara a studenti e famiglie; con il DPO, verificare la base giuridica e l'eventuale consenso per la parte di ricerca |
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
- Con le scorciatoie attive (DDL e dati generati) le competenze O5 e O6 non sono esercitate in quella consegna; i dati generati dalla LLM sono verificati contro i dati di riferimento, ma un errore dei dati di riferimento non viene rilevato.
- Con classi di 5–20 studenti la sperimentazione ha bassa potenza statistica: i risultati sono indicativi, non generalizzabili.

### 4.5 Protocollo di sperimentazione

Prima di estendere il progetto a più classi si svolge una sperimentazione controllata.

1. **Obiettivi.** Selezionare le competenze da migliorare tra modellazione ER, traduzione relazionale, individuazione dei vincoli, scrittura SQL (O2–O7).
2. **Strumenti di misura.** Una prova iniziale (pre-test), esercizi durante il percorso e una prova finale individuale (post-test), più una prova di trasferimento a distanza (es. 3–4 settimane), con rubrica comune a livelli descrittivi e correzione in cieco (valutatori che non conoscono il gruppo) su un campione, con calcolo dell'accordo tra valutatori.
3. **Prova del tutor su casi noti.** Esecuzione del golden set (§3.6C): modelli corretti, errati e soluzioni alternative valide, con criteri di accettazione stabiliti prima (per esempio: nessuna contraddizione con i controlli, fuga della soluzione sotto una soglia concordata, nessuna segnalazione errata su soluzioni valide nel campione).
4. **Pilota.** Una classe (o due, se disponibili) di 5–20 studenti per 6–8 lezioni, con disegno prevalentemente intra-soggetto (pre/post sugli stessi studenti) e analisi in larga parte qualitativa; osservazione di tempi, difficoltà, tipologie di errore, richieste di aiuto e malfunzionamenti tecnici; raccolta di commenti degli studenti e del docente. Si correggono prompt, test e tracce prima della fase successiva.
5. **Verifica del trasferimento.** Nuova traccia, senza LLM, confrontata con la prestazione iniziale.
6. **Analisi dei risultati.** Non solo punteggi: autonomia (livello di aiuto richiesto nel tempo), qualità delle motivazioni, capacità di correggere gli errori, tipologie di errori residui, esperienza percepita.
7. **Confronto controllato (fase successiva).** Se possibile, confrontare il tutor socratico con una esercitazione tradizionale (classi parallele o schema a rotazione/crossover) tenendo conto delle differenze iniziali (covariata: pre-test). Un miglioramento dopo l'attività è incoraggiante ma da solo non dimostra che sia stato causato dalla LLM.

**Dati da raccogliere (pseudonimi):** esiti dei test tecnici per tentativo, livello di aiuto richiesto, numero di iterazioni per problema, tempi, storia dei commit, punteggi di pre/post/trasferimento, questionario di percezione (utilità, autonomia, fiducia).

**Analisi:** statistiche descrittive e grandezza dell'effetto con intervalli di confidenza; con campioni piccoli, analisi prudente e qualitativa; dichiarazione esplicita delle minacce alla validità (selezione, effetto novità, apprendimento esterno, differenze tra docenti).

**Criteri di successo suggeriti** (da fissare prima dell'avvio): miglioramento nel post-test e nel trasferimento rispetto al pre-test; riduzione del livello medio di aiuto richiesto nel corso del percorso; motivazioni più complete alla fine; assenza di incidenti di privacy; sostenibilità del carico per il docente.

**Etica e governance:** approvazione del dirigente e, per la parte di ricerca, parere del DPO o dell'organo competente; possibilità di ritirarsi senza conseguenze; restituzione dei risultati agli studenti.
