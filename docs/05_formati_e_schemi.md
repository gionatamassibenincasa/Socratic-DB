# Specifiche dei formati e contratti dati {#sec-formati-contratti}

Per garantire interoperabilità, elaborazione automatica deterministica e feedback preciso da parte dell'LLM, il sistema adotta formati testuali standard e rigorosamente tipizzati.

---

## Specifiche YAML per i modelli {#sec-specifiche-yaml}

Tutti i modelli prodotti dagli studenti adottano la sintassi **YAML**, validata a tempo di commit o upload mediante **JSON Schema** o schemi **Pydantic**.
I diagrammi visuali (es. Mermaid) sono generati dal sistema per visualizzazione a partire dal file YAML e non costituiscono l'input primario.

### Modello Concettuale (`tipo: concettuale`) {#sec-modello-concettuale}

Il modello concettuale formalizza entità, attributi, identificatori univoci, associazioni, cardinalità minime/massime e vincoli di dominio. Ogni entità e associazione include un campo `motivazione` in cui lo studente giustifica la scelta rispetto al testo del problema.

```yaml
versione: 1
tipo: concettuale

entita:
  - nome: Paziente
    attributi:
      - {nome: cf, tipo: stringa, identificatore: true}
      - {nome: cognome, tipo: stringa, opzionale: false}
      - {nome: nome, tipo: stringa, opzionale: false}
      - {nome: telefono, tipo: stringa, opzionale: true}
    motivazione: "Il codice fiscale identifica univocamente la persona nel dominio."

  - nome: Medico
    attributi:
      - {nome: matricola, tipo: stringa, identificatore: true}
      - {nome: specializzazione, tipo: stringa, opzionale: false}
    motivazione: "La matricola ospedaliera è l'identificatore interno del medico."

associazioni:
  - nome: Visita
    partecipanti:
      - {entita: Paziente, card: "0..N"}
      - {entita: Medico, card: "0..N"}
    attributi:
      - {nome: inizio, tipo: datetime}
      - {nome: durata_min, tipo: intero}
    motivazione: "Una visita registra data, ora e durata dell'incontro tra paziente e medico."

vincoli:
  - id: V1
    testo: "Un medico non può effettuare due visite con intervalli temporali sovrapposti."
    classe: temporale
    meccanismo: trigger
  - id: V2
    testo: "La durata della visita deve essere strettamente positiva."
    classe: attributo
    meccanismo: check
```

#### Regole di validazione semantica concettuale
1. **Unicità dei nomi**: Nessuna entità o associazione può avere nomi duplicati.
2. **Identificatore presente**: Ogni entità deve possedere almeno un attributo con `identificatore: true` (o identificatore esterno dichiarato).
3. **Cardinalità valide**: I valori di `card` ammessi sono `'0..1'`, `'1..1'`, `'0..N'`, `'1..N'` (o notazioni equivalenti min/max).
4. **Tracciabilità**: Ogni entità deve essere richiamata in almeno una associazione o giustificata esplicitamente.

---

### Modello Relazionale (`tipo: relazionale`) {#sec-modello-relazionale}

Il modello relazionale definisce tabelle, tipi di dato SQL, nullabilità, chiavi primarie, chiavi esterne, vincoli di unicità, check e **dipendenze funzionali dichiarate**. La presenza esplicita delle dipendenze rende possibile il calcolo deterministico delle chiavi candidate e la verifica formale di 2NF, 3NF e BCNF.

```yaml
versione: 1
tipo: relazionale

tabelle:
  - nome: Paziente
    colonne:
      - {nome: cf, tipo: TEXT, nullo: false}
      - {nome: cognome, tipo: TEXT, nullo: false}
      - {nome: nome, tipo: TEXT, nullo: false}
      - {nome: telefono, tipo: TEXT, nullo: true}
    pk: [cf]
    motivazione: "Tabella anagrafica pazienti con PK codice fiscale."

  - nome: Medico
    colonne:
      - {nome: matricola, tipo: TEXT, nullo: false}
      - {nome: specializzazione, tipo: TEXT, nullo: false}
    pk: [matricola]
    motivazione: "Tabella anagrafica medici con PK matricola."

  - nome: Visita
    colonne:
      - {nome: id, tipo: INTEGER, nullo: false}
      - {nome: cf_paziente, tipo: TEXT, nullo: false}
      - {nome: matricola_medico, tipo: TEXT, nullo: false}
      - {nome: inizio, tipo: TEXT, nullo: false}
      - {nome: durata_min, tipo: INTEGER, nullo: false}
    pk: [id]
    fk:
      - colonne: [cf_paziente]
        riferisce: "Paziente(cf)"
        on_delete: RESTRICT
        on_update: CASCADE
      - colonne: [matricola_medico]
        riferisce: "Medico(matricola)"
        on_delete: RESTRICT
        on_update: CASCADE
    unique:
      - [matricola_medico, inizio]
    check:
      - "durata_min > 0"
    dipendenze:
      - "id -> cf_paziente, matricola_medico, inizio, durata_min"
      - "matricola_medico, inizio -> id, cf_paziente, durata_min"
    motivazione: "Chiave surrogata id per gestire visite multiple tra gli stessi soggetti."
```

#### Regole di calcolo deterministico
- **Chiusura degli attributi ($X^+$)**: Calcolo automatico della chiusura degli insiemi di attributi rispetto alle dipendenze dichiarate.
- **Rilevazione chiavi candidate**: Verifica che la chiave primaria scelta (`pk`) sia effettivamente una superchiave minimale.
- **Forme normali**:
  - *1NF*: Valori atomici e presenza di chiave primaria.
  - *2NF*: Assenza di dipendenze parziali di attributi non primi dalla chiave primaria.
  - *3NF*: Assenza di dipendenze transitive verso attributi non primi.
  - *BCNF*: Ogni determinante nelle dipendenze è una superchiave.

---

## Struttura dei file di consegna dello studente {#sec-file-consegna}

Il repository o spazio di lavoro dello studente si compone di file standardizzati:

| File | Formato | Contenuto |
| --- | --- | --- |
| `01_requisiti.md` | Markdown | Elenco di dati da memorizzare, operazioni richieste, vincoli espliciti/impliciti e ambiguità rilevate. |
| `02_glossario.md` | Markdown | Glossario concetti estratti (nomi/verbi), definizioni formali non circolari, sinonimi e omonimi. |
| `03_concettuale.yaml` | YAML | Modello concettuale ER secondo la specifica @sec-modello-concettuale. |
| `04_vincoli.md` | Markdown | Tabella di classificazione dei vincoli di business e meccanismo di enforcement scelto (schema, check, trigger, app). |
| `05_relazionale.yaml` | YAML | Modello relazionale secondo la specifica @sec-modello-relazionale. |
| `06_schema.sql` | SQL (SQLite) | Istruzioni DDL (`CREATE TABLE`, vincoli `CHECK`, `UNIQUE`, indici). |
| `07_dati.sql` | SQL (SQLite) | Istruzioni DML (`INSERT`) con dataset significativo e casi limite. |
| `08_query.sql` | SQL (SQLite) | Query `SELECT` con commento di motivazione della formulazione logica. |
| `motivazioni.md` | Markdown | Registro narrativo delle decisioni di riprogettazione adottate a seguito dei feedback. |

---

## Catalogo, conversione e distribuzione delle tracce {#sec-catalogo-tracce}

Il sistema gestisce ogni traccia come un materiale con una fonte, metadati e derivati distinti. Il PDF acquisito dall'archivio ministeriale o dall'editore è conservato come originale di riferimento; il testo estratto e revisionato è registrato in Markdown; il PDF destinato alla lettura o alla stampa è generato dal Markdown. Originale e derivati non vanno sovrascritti l'uno con l'altro: ogni versione deve poter essere ricondotta alla fonte e alla revisione che l'ha prodotta.

### Metadati del catalogo {#sec-metadati-tracce}

Ogni scheda identifica il materiale e ne descrive provenienza, uso consentito e contenuto didattico. I campi minimi sono:

| Campo | Descrizione |
| --- | --- |
| `id` | Identificatore stabile, indipendente dal nome del file. |
| `titolo` | Titolo breve e riconoscibile della traccia o del materiale. |
| `anno_esame` e `anno_scolastico` | Anno della prova e anno scolastico a cui si riferisce, se ricavabile dalla fonte. Non inferire l'uno dall'altro senza dichiarare la regola adottata. |
| `indirizzo` | Indirizzo e articolazione dell'Istituto Tecnico, quando applicabili e indicati nel documento. |
| `disciplina` | Disciplina o discipline riportate nella prova. |
| `sessione` | Ordinaria, suppletiva, straordinaria, simulazione o altra tipologia attestata dalla fonte. |
| `fonte` | Ente o editore, URL di provenienza, data di acquisizione e citazione da riportare nei derivati. |
| `riassunto` | Sintesi redazionale del dominio e dei requisiti, da confrontare con il testo originale. |
| `stato_diritti` e `accesso` | Esito della verifica dei diritti e profilo di accesso assegnato al materiale. |
| `originale`, `markdown` e `pdf_esportato` | Riferimenti ai file corrispondenti, se presenti e autorizzati per il rispettivo uso. |
| `classificazione_didattica` | Valutazione opzionale di difficoltà modellistica e competenze richieste per le query, con griglia di valutazione, versione e revisore. |

La classificazione didattica non è un fatto estratto automaticamente dalla prova: va motivata e revisionata da un docente. Può descrivere separatamente aspetti quali individuazione delle entità e delle relazioni, cardinalità e vincoli, trasformazione in schema relazionale, normalizzazione, uso di join, aggregazioni, sottoquery e gestione di vincoli temporali. Un campo non ancora valutato resta esplicitamente non classificato; una proposta automatica non diventa metadato approvato senza revisione.

Esempio indicativo di scheda:

```yaml
versione_catalogo: 1
id: mim-2018-19-itia-ordinaria-ab42
titolo: Servizio multimediale per punti di interesse turistici
anno_esame: 2019
anno_scolastico: "2018/19"
criterio_anno_scolastico: Attribuito alla sessione d'esame dell'anno solare 2019.
indirizzo:
  istituto: tecnico
  codice: ITIA
  articolazione: Informatica
disciplina:
  - Informatica
  - Sistemi e Reti
sessione: ordinaria
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Ordinaria/AB42_ORD19.pdf
  acquisita_il: "2026-10-22"
riassunto: Servizio per distribuire contenuti multimediali sui punti di interesse di una città.
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
originale: fonti/ministero/AB42_ORD19.pdf
markdown: tracce/mim-2018-19-itia-ordinaria-ab42.md
pdf_esportato: null
classificazione_didattica:
  stato: da_valutare
  griglia_di_valutazione: null
  difficolta_modellistica: null
  competenze_query: []
  revisore: null
```

Gli identificatori, i percorsi e i valori dell'esempio sono illustrativi: il catalogo effettivo deve usare identificatori univoci, percorsi gestiti dal sistema e valori controllati per stato dei diritti e accesso.

### Acquisizione, trascrizione ed esportazione {#sec-pipeline-tracce}

Il flusso di trattamento è il seguente:

1. **Acquisizione**: conservare l'originale senza modificarlo, registrare URL, titolare/editor, data di acquisizione, impronta del file e stato di accesso. Deduplicare per contenuto, mantenendo eventuali fonti e attribuzioni diverse.
2. **Verifica preliminare**: identificare se il documento è una traccia, una soluzione, una simulazione o materiale editoriale; rilevare avvisi di riservatezza e dati personali. Assegnare l'accesso prima di creare copie destinate alla distribuzione.
3. **Estrazione**: estrarre il testo dal PDF e produrre Markdown strutturato; ricorrere all'OCR solo quando necessario e registrare il metodo e gli eventuali limiti. Conservare la paginazione o riferimenti di pagina utili a verificare la trascrizione.
4. **Revisione**: confrontare Markdown e PDF pagina per pagina, correggere errori di estrazione e verificare tabelle, formule, immagini e caratteri. Una persona approva la trascrizione e il riassunto prima che siano usati per generare una consegna.
5. **Arricchimento didattico**: aggiungere riassunto, difficoltà e competenze come annotazioni separate dal testo della fonte, con autore o revisore e data. Non presentare classificazioni non verificate come dati ufficiali.
6. **Esportazione**: generare il PDF per gli studenti esclusivamente da una versione Markdown approvata e autorizzata per quel pubblico. Il PDF deve riportare identificativo, attribuzione e versione; non deve includere svolgimenti, note riservate o metadati interni.

### Diritti, riservatezza e profili di distribuzione {#sec-accesso-tracce}

La provenienza ministeriale, la pubblicazione di una traccia d'esame o la sua riproduzione su un quotidiano non sono, da sole, una verifica sufficiente del pubblico dominio o del diritto di redistribuire qualsiasi copia. Per ciascun originale e derivato occorre registrare la base di utilizzo, le condizioni di attribuzione e l'esito della verifica prima della distribuzione. In particolare, una soluzione editoriale è un contenuto distinto dalla traccia ministeriale e non ne eredita automaticamente i diritti o le condizioni d'uso.

Il catalogo distingue almeno materiali **pubblicabili agli studenti**, materiali **ad accesso riservato ai docenti** e materiali **in attesa di verifica**, che non sono distribuibili. Gli svolgimenti riservati, i file con avvisi di copia per docenti e documenti contenenti dati identificativi restano nell'area protetta; non si riproducono tali dati nei metadati o nei PDF esportati. Eventuali copie anonimizzate si creano solo se autorizzate, mantenendo l'originale nell'archivio protetto e documentando la trasformazione.

Gli originali e le trascrizioni riservati non devono trovarsi in directory incluse automaticamente nella build pubblica. In particolare, il rendering Quarto può copiare nel sito gli asset collocati sotto `docs/`: l'output per studenti va quindi generato da un insieme esplicitamente autorizzato, separato dal deposito delle fonti e dei materiali per docenti. Il repository Git, le copie di build e i backup devono rispettare lo stesso profilo di accesso del materiale; una directory esclusa da Git non costituisce, da sola, un archivio controllato né garantisce che gli asset non siano pubblicati da altri passaggi della pipeline.

---

## Formato delle diagnosi strutturate {#sec-diagnosi-strutturate}

Quando l'orchestratore esegue i validatori deterministici, genera un payload JSON standardizzato che viene fornito al modello linguistico tutor:

```json
{
  "consegna_id": "C3",
  "fase": 5,
  "livello_aiuto": "L1",
  "errori_rilevati": [
    {
      "codice": "3NF_VIOLATA",
      "gravita": "errore_oggettivo",
      "tabella": "Ordine",
      "dettaglio": "L'attributo 'citta_cliente' dipende transitivamente da 'cliente_id' e non direttamente dalla PK 'ordine_id'.",
      "dipendenza_violante": "cliente_id -> citta_cliente"
    },
    {
      "codice": "FK_ORFANA",
      "gravita": "errore_oggettivo",
      "tabella": "Dettaglio",
      "dettaglio": "La chiave esterna 'prodotto_id' riferisce una colonna non presente nella tabella Prodotti."
    }
  ],
  "metriche": {
    "completezza_requisiti": 0.85,
    "copertura_fk": 0.90,
    "forme_normali": {
      "Ordine": "2NF",
      "Cliente": "3NF",
      "Prodotto": "3NF"
    }
  }
}
```

Il tutor riceve questo payload nel prompt di sistema e seleziona **una sola diagnosi alla volta** per non sovraccaricare cognitivamente lo studente.

---

## Formato del report compatto di processo {#sec-report-processo}

Per consentire al docente una consultazione rapida del percorso senza applicare automatismi valutativi, il sistema genera un report sintetico per studente:

```text
======================================================================
REPORT PROCESSO: Studente s042 - Traccia: Gestione Ospedaliera (M733)
======================================================================
Fase 1 (Requisiti):           4 tentativi | Livello aiuto max: L1
Fase 2 (Glossario):           2 tentativi | Livello aiuto max: L0
Fase 3 (Concettuale ER):      6 tentativi | Livello aiuto max: L2
   - Diagnosi ricorrente:     CARDINALITA_INVERTITA (2 volte)
Fase 4 (Vincoli):             3 tentativi | Livello aiuto max: L2
Fase 5 (Relazionale):         5 tentativi | Livello aiuto max: L3
   - Diagnosi ricorrente:     3NF_VIOLATA (3 volte)
Fase 6 (DDL SQLite):          2 tentativi | Livello aiuto max: L1
Fase 7 (Popolamento/Test):    3 tentativi | Livello aiuto max: L1
Fase 8 (Query SQL):           4 tentativi | Livello aiuto max: L2

Note e flag di attenzione:
- Superamento di L2 nella fase 5 (richiesto supporto di principio su normalizzazione).
- Motivazioni sintetiche segnalate dal pre-screening per la fase 3 (righe < 3).
======================================================================
```
