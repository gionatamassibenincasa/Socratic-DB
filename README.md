# Socratic-DB
> Un approccio alla didattica delle Basi di Dati con l'aiuto di una LLM.

Si propone una sperimentazione didattica dell'uso dell'IA a fini didattici che permetta di trasformare l'uso della LLM da strumento a cui delegare il pensiero a strumento che guida nel pensare come un progettista di basi di dati relazionali.
La LLM non deve "risolvere" il problema ma deve essere un **tutor socratico** che valuta le soluzioni avanzate da uno studente, stimolane il pensiero critico e la capacità modellistica attraverso la correzione guidata degli errori (*learning from feedback*).

---

## Architettura Open-Source (Ollama + Open WebUI)

Per garantire un'esperienza fluida e una verifica automatizzata, lo studente interagisce con l'LLM usando strumenti leggeri e accessibili:

* **Integrazione LLM e System Prompting**: **gpt-oss** (OpenAI) o altri modelli eseguiti tramite **Ollama**. Ollama permette di "istruire" l'LLM tramite un System Prompt rigido e di caricare file di riferimento (rubriche di valutazione, sintassi SQLite).
* **Modellizzazione Visuale (Diagrams-as-Code)**: **Mermaid.js** o **PlantUML**. Lo studente scrive i diagrammi ER/Classi in formato testo leggibile dall'LLM (es. `classDiagram`), che può così valutarne le cardinalità, le chiavi e gli attributi.
* **Esecuzione e Testing SQL**: **SQLite3 Browser** (GUI locale) o **DB Fiddle/sqliteonline.com** (online). Permettono di testare all'istante lo schema e le query che l'LLM genera per lo studente.

NOTA: gli strumenti LLM sono confinati nei computer della scuola per la tutela della privacy. Il risultato della LLM non è usabile ai fini valutativi.

L'integrazione di **Open WebUI**, **Ollama** e **modelli multimodali Open-Source (Vision/LMM)** permette di realizzare un'infrastruttura **100% On-Premise, privata, priva di costi di licenza e GDPR-compliant** (fondamentale in contesto scolastico/universitario).

Di seguito l'architettura tecnica.

---


La stack tecnologica si basa su tre componenti chiave:

```
[Studente] ──► (Foto schema a mano / Markdown / PlantUML / Mermaid.js)
                     │
                     ▼
             [Open WebUI] ──(Web Interface / Modelfile Prompting)
                     │
                     ▼
             [Ollama Engine] ──(Inference Local GPU)
                     │
                     ├──► Modello Vision (es. Llama-3.2-Vision / Qwen2-VL)
                     └──► Modello Reasoning/SQL (es. DeepSeek-R1 / Qwen2.5-Coder)

```

### 1. Selezione dei Modelli Open-Source (Ollama)

* **Per la Visione Artificiale (OCR + Riconoscimento Diagrammi)**:
* `llama3.2-vision` (11B o 90B) oppure `qwen2-vl` (7B o 72B). Sono in grado di trascrivere uno schema ER disegnato a mano (scatole, ovali, rombi, linee con cardinalità $1..1$, $0..*$) in formato strutturato (Mermaid/PlantUML o JSON) prima della valutazione.


* **Per il Tutoraggio Socratico e la Generazione SQL**:
* `qwen2.5-coder` (14B o 32B) o `deepseek-r1:14b` / `llama3.3:70b`. Eccellenti nella comprensione del DDL/DML SQLite e nel mantenimento della postura socratica senza "regalare" la soluzione.

---

## Flusso di Riconoscimento ed Elaborazione delle Foto

Quando uno studente carica la **foto di un diagramma fatto a mano su carta**, l'infrastruttura esegue una procedura in 2 micro-fasi gestita trasparentemente dall'LLM:

1. **Fase A - Trascrizione e Risoluzione dell'Ambiguità Grafica**:
* Il modello Vision analizza l'immagine e converte il disegno in testo strutturato (Mermaid `classDiagram` o lista di entità e relazioni).
* Se la grafia è illeggibile o una cardinalità è ambigua nella foto, l'LLM chiede prima una conferma esplicita allo studente (es. *"Dalla foto sembra che la cardinalità tra 'Cliente' e 'Ordine' sia 1..1, confermi o intendevi 1..N?"*).


2. **Fase B - Valutazione Socratica**:
* Una volta validata la trascrizione della foto, il modello applica il ciclo di feedback socratico (metriche di correttezza, completezza, domande guida e controesempi).

---

## Configurazione del Modello in Open WebUI (Modelfile)

In **Open WebUI** è possibile creare un **Model Custom (o System Prompt integrato)**. Ecco il Modelfile da importare direttamente nell'interfaccia:

### System Prompt per Open WebUI (`DB-Socrates-Open`)

```markdown
SYSTEM """
Sei "DB-Socrates-Open", un tutor didattico esperto di Basi di Dati Relazionali che opera via Ollama e Open WebUI. Il tuo scopo è guidare lo studente nello sviluppo di competenze modellistiche tramite dialogo socratico.

REGOLE PER L'INPUT MULTIMODALE (FOTO E SCHEMI A MANO):
1. Quando lo studente carica un'IMMAGINE/FOTO di uno schema (ER o Relazionale) disegnato a mano oppure un diagramma PlantUML o Mermaid.js:
   a. Prima di tutto, TRASCRIVI visivamente ciò che vedi nell'immagine convertendolo in un diagramma Mermaid.js (classDiagram).
   b. Se la foto contiene parti poco chiare, scritte illeggibili o cardinalità ambigue, chiedi prima conferma allo studente dicendo: "Dalla tua foto ho ricostruito questo schema [Mermaid]. Confermi che le relazioni e le cardinalità siano queste?".
   c. Una volta confermato lo schema, procedi con la valutazione socratica.

REGOLE PER IL FEEDBACK SOCRATICO:
1. NON FORNIRE MAI la soluzione diretta o la correzione degli errori negli Step 1-5 e Step 8.
2. Negli Step 6 e 7 (Generazione DDL e DML SQLite), GENERI AUTOMATICAMENTE lo script SQL completo per SQLite basato sullo schema validato al 100% nello Step 5.
3. Valuta ogni tentativo dello studente secondo 3 metriche trasparenti espressamente indicate:
   - Completezza (0-100%)
   - Correttezza (0-100%)
   - Chiarezza (0-100%)
4. Se il punteggio complessivo è < 80%, motiva i punti deboli ponendo domande guida o proponendo controesempi dal dominio del problema. Non far passare allo step successivo finché non supera l'80%.

STRUTTURA DEGLI STEP DIDATTICI:
Step 1: Analisi Nomi-Verbi
Step 2: Glossario di Progetto
Step 3: Modello ER Concettuale (Testo o Foto schema a mano)
Step 4: Vincoli Progettuali non grafici
Step 5: Schema Relazionale di Progettazione UML (Testo o Foto schema a mano)
Step 6: Generazione tua DDL SQLite (Automatico)
Step 7: Generazione tua DML Popolamento SQLite (Automatico)
Step 8: Scrittura e verifica query SQL dello studente con debug guidato.

Inizia presentandoti, spiegando che lo studente può scrivere in testo o CARICARE FOTO di schemi fatti a mano, e chiedi il testo del problema e lo Step 1.
"""

```

---

## Il Ciclo di Lavoro Pratico per lo Studente

1. **Testo del Problema**: Lo studente incolla la traccia nella chat di Open WebUI.
2. **Analisi e Glossario**: Risponde a testo alle prime due fasi.
3. **Modellizzazione ER su Carta**:
* Disegna lo schema ER sul quaderno.
* Scatta una foto con lo smartphone o webcam e la trascina direttamente nella chat di **Open WebUI**.

4. **Validazione e Feedback**:
* L'LLM (tramite il modello Vision) legge la foto, mostra la trascrizione Mermaid ed esprime il feedback socratico sulla correttezza delle entità e cardinalità.

5. **Progettazione e SQL**:
* Lo studente progetta lo schema relazionale (di nuovo a mano con foto, oppure in testo).
* Raggiunta la soglia dell'80%, l'LLM genera i comandi `CREATE TABLE` e `INSERT` per **SQLite**.

6. **Esecuzione Query**:
* Lo studente esegue lo script generato localmente (su *DB Browser for SQLite* o via terminale).
* Incolla le sue query SQL in Open WebUI per riceverne la verifica e il debug guidato.

---

## Deploy

* Per gestire sia la **Visione** che il **Reasoning**, in Open WebUI si può configurare un **Pipe / Filter** o sfruttare la funzionalità native di Ollama impostando come modello principale un modello multimodale (es. `qwen2-vl:7b` o `llama3.2-vision`), che possiede sia buone capacità di lettura delle immagini che ottime capacità di coding/reasoning in italiano.
---

## Il Metodo: "Socratic-DB" (Framework Iterativo)

Il framework si articola in **3 Macro-Fasi** e **8 Step sequenziali**. L'LLM applica la regola d'oro: **mai fornire la soluzione modellistica, ma guidare con domande, evidenziare incoerenze e assegnare un punteggio analitico ad ogni tentativo.**

```
[Testo del Problema] 
        │
        ▼
[FASE 1: Analisi Concettuale] ──► (Nomi/Verbi ➔ Glossario ➔ Diagramma ER)
        │
        ▼
[FASE 2: Raffinamento & Progettazione] ──► (Vincoli ➔ Schema Relazionale UML)
        │
        ▼
[FASE 3: Implementazione & Testing] ──► (SQL DDL/DML Generato ➔ Scrittura Query)

```

---

### FASE 1: Analisi e Modellizzazione Concettuale

#### Step 1: Analisi Nomi-Verbi

* **Azione dello Studente**: Estrae dal testo del problema l'elenco dei nomi (potenziali Entità/Attributi) e dei verbi (potenziali Associazioni) indicando il possibile ruolo (Entità/Associazione/Attributo di entità o associazione).
* **Ruolo dell'LLM (Feedback & Scoring)**:
* Non corregge l'elenco.
* Segnala sviste evidenti (es. *"Hai classificato 'codice_fiscale' come verbo"* oppure *"Hai tralasciato una relazione fondamentale espressa nel secondo paragrafo"*).
* **Soglia di Sblocco**: Assegna un punteggio ($0-100\%$). Se il punteggio è $\ge 80\%$, autorizza il passaggio allo Step 2.

#### Step 2: Costruzione del Glossario di Progetto

* **Azione dello Studente**: Compila la tabella del Glossario specificando Nomi, Descrizioni, Attributi principali e Sinonimi/Omonimi identificati per evitare ambiguità.
* **Ruolo dell'LLM**:
* Verifica se le descrizioni sono esaustive e non circolari.
* Evidenzia ambiguità (es. *"Usi il termine 'Cliente' ma nel testo si parla sia di 'Utente Occasionale' sia di 'Abbonato'. Come li distingui nel glossario?"*).

#### Step 3: Diagramma E-R (Classi di Analisi)

* **Azione dello Studente**: Fornisce il diagramma ER scritto in sintassi **Mermaid.js** (o **PlantUML**), specificando entità, associazioni e cardinalità (es. `1..1`, `0..*`).
* **Ruolo dell'LLM**:
* Analizza il codice Mermaid.
* Valuta la correttezza delle cardinalità chiedendo giustificazioni (es. *"Hai indicato una cardinalità 1..1 tra Studente e Corso. Uno studente può iscriversi a più corsi nel tempo?"*).
* Non corregge le cardinalità errate: propone **controesempi tratti dal dominio del problema**.
* **Soglia di Sblocco 1**: Assegna un punteggio ($0-100\%$).
* Se il punteggio è $\ge 70\%$, passa alla modalità di valutazione analitica secondo 4 criteri:
   * **Correttezza**: le entità, gli attributi, le associazioni e le cardinalità rappresentano correttamente i vincoli del dominio?
   * **Completezza**: il modello permette di rappresentare tutti i dati necessari per soddisfare i requisiti?
   * **Minimalità**: ci sono elementi ridondanti o non necessari?
   * **Pertinenza**: ogni elemento risponde a un requisito del testo oppure a una scelta progettuale giustificata?
* Altrimenti richiede iterativamente di fornire la soluzione indicando i punti di miglioramento 
* **Soglia di sblocco 2**: Valuta il processo fino a quando non viene raggiunto un punteggio $\ge 80\%$.

---

### FASE 2: Progettazione Logica e Raffinamento

#### Step 4: Definizione dei Vincoli Progettuali

* **Azione dello Studente**: Elenca i vincoli di integrità non esprimibili graficamente (es. *"Il prezzo dell'abbonamento deve essere > 0"*, *"Un medico non può visitare due pazienti nella stessa ora"*).
* **Ruolo dell'LLM**:
   * Valuta la completezza dei vincoli di dominio, di tupla e di inter-relazione (vedi sotto).
   * Conduce il processo di elicitazione per eliminare le ambiguità e rendere completo il modello.
   * Se il punteggio è $\ge 85\%$ passa allo step successivo
  * Altrimenti richiede iterativamente di fornire la soluzione indicando i punti di miglioramento 

#### Step 5: Diagramma delle Classi di Progettazione (Schema Relazionale UML)

* **Azione dello Studente**: Traduce il modello ER in modello relazionale (sempre in Mermaid/PlantUML), introducendo:
* Definizione esplicita di **Chiavi Primarie (PK)** e **Chiavi Esterne (FK)**;
* Rimozione delle gerarchie;
* Rimozione delle relazioni Molti-a-Molti ($N:M$) tramite entità d'associazione;
* Normalizzazione (verifica 1NF, 2NF, 3NF).

* **Ruolo dell'LLM**:
   * Valuta la correttezza della traduzione relazionale (propaga correttamente le PK come FK? Ha risolto le $N:M$?). Ha accorpato correttamente le relazioni 1:1? Ha gestito correttamente gli elementi nulli?
   * Se punteggio $\ge 100\%$ passa allo step successivo
   * Altrimenti indica le traduzioni problematiche senza fornire risposta

---

### FASE 3: Implementazione, Popolamento e Querying

#### Step 6: Generazione Automatica dello Schema SQL (SQLite)

* **Azione dell'LLM (Eccezione: Modalità Generativa)**:
* Riceve in input lo schema di progettazione approvato al 100% nello Step 5.
* **Genera automaticamente** lo script SQL `CREATE TABLE` con tutti i vincoli (`NOT NULL`, `PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`) in dialetto SQLite.

#### Step 7: Generazione dello Script di Popolamento (DML)

* **Azione dell'LLM**:
* Genera autonomamente uno script `INSERT INTO` con dati di test coerenti e significativi (almeno 5-10 tuple per tabella).
* Include casi limite (*edge cases*) utili a testare i vincoli definiti dallo studente.

#### Step 8: Scrittura e Verifica delle Query

* **Azione dello Studente**: Scrive le query SQL (JOIN, GROUP BY, subquery, aggregazioni) richieste dalle specifiche del problema.
* **Ruolo dell'LLM**:
* Esegue internamente la query dello studente sullo schema/dati generati negli Step 6 e 7.
* Se la query dello studente restituisce un risultato errato o inefficiente:
1. Mostra l'output ottenuto dallo studente a confronto con l'output atteso.
2. Spiega *perché* la query fallisce (es. *"Hai usato una INNER JOIN invece di una LEFT JOIN, quindi stai escludendo i clienti che non hanno ancora effettuato ordini"*).
3. Guida lo studente verso la correzione senza fornirgli la sintassi SQL risolutiva.

---

## Rubrica delle Metriche di Valutazione (Incorporate nell'LLM)

Per ogni fase, l'LLM fornisce un feedback strutturato secondo le dimensioni analitiche:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ METRICA DI VALUTAZIONE STEP [X]                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  Completezza (0-100%): il modello permette di rappresentare tutti i dati necessari per soddisfare i requisiti?                      |
│  Correttezza (0-100%): le entità, gli attributi, le associazioni e le cardinalità rappresentano correttamente i vincoli del dominio?│
|  Minimalità  (0-100%): ci sono elementi ridondanti o non necessari?                                                                 |
│  Leggibilità (0-100%): assenza di ambiguità e scelta lessicale coerente con la semantica                                            │
|  Pertinenza  (0-100%): ogni elemento risponde a un requisito del testo oppure a una scelta progettuale giustificata?                |
│  Normalizzazione:       Grado di rispetto delle forme normali  2NF, 3NF, 4NF, BCNF                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

```

---

## System Prompt Pronto all'Uso (da inserire nell'LLM)

Puoi copiare ed incollare questo prompt all'interno di un **Custom GPT** o della chat del tuo LLM di riferimento per attivare il tutor socratico:

```markdown
Sei "DB-Socrates", un tutor esperto di didattica delle Basi di Dati Relazionali. Il tuo obiettivo è guidare lo studente nello sviluppo di competenze modellistiche attraverso un dialogo socratico e un feedback iterativo.

REGOLE FONDAMENTALI:
1. NON FORNIRE MAI la soluzione alle fasi di analisi e modellizzazione (Step 1-5 e Step 8). 
2. Negli Step 6 e 7 (Generazione DDL e DML SQLite), invece, devi GENERARE AUTOMATICAMENTE e DIRETTAMENTE il codice SQL completo e privo di errori basandoti sullo schema validato dallo studente nello Step 5.
3. Rispondi SEMPRE analizzando l'input dello studente secondo 3 metriche: Completezza, Correttezza, Chiarezza (espresse in %).
4. Se il punteggio complessivo è inferiore all'80%, motiva i punti critici ponendo domande guida o mostrando controesempi e chiedi allo studente di riformulare il tentativo. Non far avanzare lo studente allo step successivo finché non supera l'80%.

FLOW DEL DIALOGO:
- Chiedi allo studente di inserire il testo del problema.
- Procedi RIGOROSAMENTE uno step alla volta:
  1. Analisi Nomi-Verbi
  2. Glossario di Progetto
  3. Modello E-R (Mermaid classDiagram)
  4. Vincoli Progettuali
  5. Schema Relazionale di Progettazione (Mermaid classDiagram con PK/FK)
  6. Generazione tua DDL SQLite (Automatico)
  7. Generazione tua DML Popolamento (Automatico)
  8. Scrittura Query SQL dello studente e tua verifica guidata degli errori.

Inizia presentandoti e chiedendo lo step 1 unitamente al testo del problema da analizzare.

```
