# Fase 2 - Analisi Nomi-Verbi

## Importanza dell'analisi Nomi-Verbi nella modellizzazione dei dati

L'analisi nomi-verbi è una tecnica fondamentale nell'Ingegneria dei Requisiti per la progettazione concettuale di basi di dati (Modello E/R). Consente di trasformare in modo oggettivo e tracciabile un testo descrittivo non strutturato (i desiderata degli stakeholder) in elementi strutturati.

La sua importanza risiede nei seguenti aspetti formali:

* **Sistematicità e Tracciabilità:** Garantisce un legame diretto e documentato tra i requisiti espressi nel linguaggio naturale e gli elementi del modello concettuale, rendendo ogni decisione progettuale verificabile e giustificabile.
* **Riduzione dell'Ambiguità:** Permette di identificare ed eliminare sinonimi (termini diversi usati per lo stesso concetto), omonimi (stesso termine usato per concetti diversi) e dettagli irrilevanti o fuori ambito (*out-of-scope*).
* **Mappatura Rigorosa dei Modelli Concettuali:**
* **Sostantivi / Nomi:** Identificano le potenziali **Entità** (se costituiti da oggetti dotati di vita propria e proprietà esplicite) oppure gli **Attributi** (se descrivono proprietà di altre entità).
* **Verbi:** Identificano le potenziali **Associazioni / Relazioni** tra entità (se descrivono azioni, legami strutturali o processi del dominio) o **Funzioni/Operazioni di sistema**.

---

## Esempio di analisi Nomi-Verbi

L'esempio è tratto dalla prova dell'Esame di Stato "City2City".

L'analisi si concentra sulla porzione del sistema informativo che gestisce l'attività di trasporto (incluso personale, autobus, manutenzione e viaggi).

### Estrazione e categorizzazione dei Nomi (Sostantivi)

| Nome / Sostantivo | Categoria Proposta | Motivazione / Ruolo nel modello |
| --- | --- | --- |
| **City2City / Compagnia** | Scartato | Rappresenta la società stessa (confine del sistema, non entità interna). |
| **Collegamento** | **Entità** | Identifica le tratte teoriche programmate (es. andata/ritorno, città, orari previsti). |
| **Città / Sede operativa** | **Entità** (o Attributo) | Può costituire un'entità autonoma (Città europea/Sede) a cui i collegamenti afferiscono. |
| **Giorno della settimana** | Attributo | Proprietà del Collegamento (es. lunedì, martedì). |
| **Orario di partenza/arrivo** | Attributo | Proprietà sia del Collegamento (previsto) sia del Viaggio (effettivo). |
| **Tipo direzione** | Attributo | Proprietà del Collegamento (Andata/Ritorno). |
| **Autobus GT** | **Entità** | Mezzo fisico appartenente al parco autobus con dati identificativi specifici. |
| **Livello di comfort / Caratteristica** | Attributo | Descrive le specifiche dell'Autobus GT. |
| **Ditta esterna** | **Entità** | Società responsabile dei lavori di manutenzione. |
| **Manutenzione** | **Entità** (o Relazione) | Intervento tecnico sul mezzo; possiede dati propri (data, costo, tipo). |
| **Personale viaggiante / Dipendente** | **Entità** | Lavoratori impiegati nella gestione dei viaggi. |
| **Ruolo** | Attributo | Specifica la funzione del personale (Autista Principale, Secondo Autista, Assistente). |
| **Viaggio** | **Entità** | Istanza effettivamente svolta in una specifica data di un Collegamento. |
| **Data viaggio** | Attributo | Proprietà specifica dell'entità Viaggio. |
| **Numero passeggeri** | Attributo | Valore consuntivo registrato per ciascun Viaggio effettivo. |
| **Cliente / Utente** | **Entità** | Soggetto che effettua registrazioni o prenotazioni (ambito esteso). |
| **Servizi di cortesia / Bagaglio** | Scartati (o Attributi) | Dettagli di contesto operativo, irrilevanti se non monitorati singolarmente. |

### Estrazione e categorizzazione dei Verbi

| Verbo / Azione | Categoria Proposta | Motivazione / Ruolo nel modello |
| --- | --- | --- |
| **Offrire / Prevedere (Collegamento)** | **Associazione** | Legame tra Compagnia e Collegamento / Struttura di pianificazione. |
| **Partire da / Raggiungere** | **Associazione** | Relazione tra l'entità *Collegamento* e le entità *Città* (Partenza/Arrivo). |
| **Affidare / Effettuare (Manutenzione)** | **Associazione** | Relazione tra *Autobus GT*, *Ditta Esterna* e l'intervento di *Manutenzione*. |
| **Alternarsi / Essere composto** | **Associazione** | Legame di assegnazione tra *Personale viaggiante* e *Viaggio* con uno specifico *Ruolo*. |
| **Utilizzare (Autobus nel viaggio)** | **Associazione** | Relazione che associa un determinato *Autobus GT* a uno specifico *Viaggio*. |
| **Svolgere / Effettuare (Viaggio)** | **Associazione** | Istanziazione: un *Viaggio* effettivo esegue un *Collegamento* pianificato. |
| **Fidelizzare / Registrare** | Operazione di sistema | Funzionalità orientata ai processi utente/cliente. |

---

### Formalismo per L'Analisi Nomi-Verbi

Per formalizzare i risultati dell'analisi nomi-verbi garantendo la qualità del documento e l'interoperabilità dei dati, definiamo una struttura rigida basata sui seguenti requisiti del dominio:

1. **Meta-informazioni sul Documento:** Ogni analisi deve contenere i metadati del progetto (titolo, versione, autore e ambito del sistema).
2. **Analisi dei Sostantivi (Nomi):**
* **Termine Estratto:** Il sostantivo o la locuzione esatta individuata nel testo.
* **Categoria Concettuale:** Deve appartenere tassativamente a uno dei seguenti valori: `Entità`, `Attributo`, `Scartato` o `Da Rivedere`.
* **Entità/Oggetto di Riferimento:** Se classificato come `Attributo`, deve specificare l'entità a cui appartiene.
* **Motivazione:** Giustificazione formale della scelta progettuale.
* **Gestione Sinonimi/Omonimi:** Elenco di eventuali termini equivalenti o ambigui trovati nel testo.


3. **Analisi dei Verbi:**
* **Verbo / Azione Estratta:** La forma verbale identificata nel testo.
* **Categoria Concettuale:** Deve appartenere tassativamente a uno dei seguenti valori: `Associazione`, `Operazione di Sistema`, `Scartato`.
* **Soggetti Coinvolti:** Per le associazioni, elenca le entità correlate (es. "Autobus GT", "Manutenzione").
* **Motivazione:** Spiegazione del ruolo dell'azione nel modello logico-concettuale.

---

### JSON Schema per la validazione

Il seguente JSON Schema (Draft-07) formalizza i vincoli di struttura e di tipo per il documento di analisi nomi-verbi.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AnalisiNomiVerbiSchema",
  "description": "Schema di validazione formale per il documento di analisi nomi-verbi nella modellazione dati.",
  "type": "object",
  "properties": {
    "progetto": {
      "type": "object",
      "properties": {
        "titolo": { "type": "string" },
        "versione": { "type": "string" },
        "ambito": { "type": "string" }
      },
      "required": ["titolo", "versione", "ambito"]
    },
    "sostantivi": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/ElementoSostantivo"
      }
    },
    "verbi": {
      "type": "array",
      "items": {
        "$ref": "#/definitions/ElementoVerbo"
      }
    }
  },
  "required": ["progetto", "sostantivi", "verbi"],
  "definitions": {
    "ElementoSostantivo": {
      "type": "object",
      "properties": {
        "termine": { "type": "string" },
        "categoria": {
          "type": "string",
          "enum": ["Entità", "Attributo", "Scartato", "Da Rivedere"]
        },
        "riferimento_entita": {
          "type": ["string", "null"],
          "description": "Nome dell'entità di appartenenza se la categoria è Attributo."
        },
        "motivazione": { "type": "string" },
        "sinonimi": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "required": ["termine", "categoria", "motivazione"]
    },
    "ElementoVerbo": {
      "type": "object",
      "properties": {
        "azione": { "type": "string" },
        "categoria": {
          "type": "string",
          "enum": ["Associazione", "Operazione di Sistema", "Scartato"]
        },
        "entita_coinvolte": {
          "type": "array",
          "items": { "type": "string" }
        },
        "motivazione": { "type": "string" }
      },
      "required": ["azione", "categoria", "motivazione"]
    }
  }
}

```

---

### Esempio di istanza YAML validabile dallo schema

Di seguito il file YAML contenente l'istanza di analisi nomi-verbi per il caso **City2City**, conforme in tutti i vincoli definiti nel JSON Schema sopra riportato.

```yaml
progetto:
  titolo: "City2City - Sistema di Gestione Trasporti"
  versione: "1.0.0"
  ambito: "Modellazione concettuale del parco mezzi, viaggi, personale e manutenzione."

sostantivi:
  - termine: "City2City"
    categoria: "Scartato"
    riferimento_entita: null
    motivazione: "Rappresenta l'azienda stessa; definisce il confine del sistema e non un'entità interna."
    sinonimi:
      - "Compagnia"
      - "Società"

  - termine: "Collegamento"
    categoria: "Entità"
    riferimento_entita: null
    motivazione: "Identifica le tratte pianificate con caratteristiche proprie di programmazione."
    sinonimi: []

  - termine: "Giorno della settimana"
    categoria: "Attributo"
    riferimento_entita: "Collegamento"
    motivazione: "Specifica il giorno schedulato per un determinato collegamento."
    sinonimi: []

  - termine: "Autobus GT"
    categoria: "Entità"
    riferimento_entita: null
    motivazione: "Mezzo fisico identificabile con specifiche tecniche e interventi dedicati."
    sinonimi:
      - "Mezzo"
      - "Autobus"

  - termine: "Livello di comfort"
    categoria: "Attributo"
    riferimento_entita: "Autobus GT"
    motivazione: "Proprietà descrittiva del parco veicoli."
    sinonimi:
      - "Caratteristica"

  - termine: "Ditta esterna"
    categoria: "Entità"
    riferimento_entita: null
    motivazione: "Soggetto giuridico esterno che esegue gli interventi di manutenzione."
    sinonimi: []

  - termine: "Manutenzione"
    categoria: "Entità"
    riferimento_entita: null
    motivazione: "Evento/Intervento tecnico dotato di attributi temporali e operativi propri."
    sinonimi: []

  - termine: "Personale viaggiante"
    categoria: "Entità"
    riferimento_entita: null
    motivazione: "Dipendenti impegnati nella gestione operativa dei viaggi."
    sinonimi: []

  - termine: "Ruolo"
    categoria: "Attributo"
    riferimento_entita: "Personale viaggiante"
    motivazione: "Definisce la funzione svolta (Autista Principale, Secondo Autista, Assistente)."
    sinonimi: []

  - termine: "Viaggio"
    categoria: "Entità"
    riferimento_entita: null
    motivazione: "Esecuzione effettiva di un collegamento in una specifica data."
    sinonimi: []

verbi:
  - azione: "Offrire"
    categoria: "Associazione"
    entita_coinvolte:
      - "Collegamento"
    motivazione: "Definisce la pianificazione delle tratte da parte dell'azienda."

  - azione: "Affidare manutenzione"
    categoria: "Associazione"
    entita_coinvolte:
      - "Autobus GT"
      - "Ditta esterna"
      - "Manutenzione"
    motivazione: "Relazione ternaria o doppia associazione tra mezzo, ditta esecutrice e intervento."

  - azione: "Alternarsi alla guida"
    categoria: "Associazione"
    entita_coinvolte:
      - "Personale viaggiante"
      - "Viaggio"
    motivazione: "Assegnazione dei dipendenti al viaggio con indicazione del relativo ruolo."

  - azione: "Svolgere viaggio"
    categoria: "Associazione"
    entita_coinvolte:
      - "Viaggio"
      - "Collegamento"
      - "Autobus GT"
    motivazione: "Istanziazione del collegamento teorico in un viaggio reale mediante l'uso di un autobus."

  - azione: "Fidelizzare clienti"
    categoria: "Operazione di Sistema"
    entita_coinvolte: []
    motivazione: "Funzionalità o caso d'uso orientato al sottosistema di marketing e registrazione."

```

### Griglia di valutazione della qualità dell'analisi Nomi-Verbi

La seguente scheda d'valutazione (*rubric*) si basa sulle best practice d'Ingegneria del Software (ISO/IEC/IEEE 29148 per la gestione dei requisiti e principi di qualità del Software Requirement Specification).

| Criterio di Valutazione | Descrizione e Indicatori di Qualità | Peso | Eccellente (100%) | Adeguato (70%) | Inadeguato (0-40%) |
| --- | --- | --- | --- | --- | --- |
| **1. Completezza (Coverage)** | Tutti i sostantivi e i verbi rilevanti contenuti nel testo dei requisiti sono stati individuati ed estratti senza omissioni critiche. | 25% | Tutti i concetti del dominio sono stati estratti. Nessuna entità o associazione chiave è omessa. | La maggior parte dei termini chiave è stata identificata; mancano elementi secondari. | Omissioni gravi di entità o relazioni primarie del dominio. |
| **2. Correttezza della Classificazione** | Sostantivi e verbi sono stati correttamente assegnati alle categorie concettuali (Entità, Attributo, Relazione, Operazione, Fuori Ambito). | 30% | Distinzione impeccabile tra Entità (oggetti con vita propria) e Attributi (proprietà descrittive). | Lievi confusioni (es. un attributo complesso scambiato per entità o viceversa). | Frequenti errori strutturali (es. verbi scambiati per entità, entità scambiate per attributi). |
| **3. Tracciabilità e Giustificazione** | Ogni decisione di classificazione o scarto è motivata in modo esplicito facendo riferimento al testo e all'ambito del sistema. | 20% | Tutte le decisioni (inclusi gli scarti di termini ridondanti) sono chiaramente motivate. | Motivazioni presenti per i concetti principali, ma assenti per le decisioni marginali. | Mancanza di giustificazioni; categorizzazione arbitraria o non documentata. |
| **4. Gestione di Sinagomi e Omonimi** | Identificazione puntuale delle ambiguità terminologiche e normalizzazione dei concetti nel dominio di riferimento. | 15% | Identificati e risolti tutti i sinonimi (es. "compagnia/società") e omonimi presente nel testo. | Ambiguità principali individuate, ma con alcune imperfezioni nella formalizzazione. | Nessun controllo sulla sinonimia/omonimia; presenza di duplicazioni concettuali. |
| **5. Rigore Formale e Sintassi** | Utilizzo di una terminologia standard, tabelle ben strutturate e aderenza alle convenzioni della modellazione E/R. | 10% | Presentazione altamente professionale, chiara, priva di ambiguità e conforme agli standard. | Struttura comprensibile, con minime imprecisioni formali o tipografiche. | Disorganizzato, ambiguo e privo di una struttura tabellare o formale. |