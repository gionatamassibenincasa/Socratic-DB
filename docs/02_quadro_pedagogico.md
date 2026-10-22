# Specifica pedagogica {#sec-specifica-pedagogica}

## Destinatari {#sec-destinatari}

Studenti del secondo biennio e del quinto anno di un Istituto Tecnico Economico (ITE), indirizzo «Amministrazione, Finanza e Marketing», articolazione «Sistemi Informativi Aziendali» (SIA, codice ITSI), o di un Istituto Tecnico Tecnologico (ITT), indirizzo «Informatica e Telecomunicazioni», articolazione «Informatica» (codice ITIA), in classi da 5 a 20 persone, con lavoro individuale o a coppie.

Il sistema è progettato tenendo conto dei quadri di riferimento e dei nuclei fondanti della seconda prova scritta dell'Esame di Stato per le discipline d'indirizzo. I quadri di riferimento di ITIA e ITSI includono tra i nuclei la progettazione concettuale, logica e fisica di basi di dati e i linguaggi per basi di dati; la disciplina della seconda prova varia da un anno all'altro. Tali prove richiedono di ricavare le specifiche progettuali da una traccia reale, sviluppare la modellizzazione concettuale del problema, tradurla nel modello logico-relazionale, realizzare la base di dati e formulare le query di interrogazione in linguaggio SQL.

La sperimentazione può inoltre essere estesa e adattata come supporto all'auto-apprendimento guidato in un primo corso universitario di «Basi di Dati» (lauree triennali in Informatica o Ingegneria Informatica).

## Prerequisiti {#sec-prerequisiti}

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

## Obiettivi di apprendimento {#sec-obiettivi-apprendimento}

Al termine lo studente è in grado di, **autonomamente e senza tutor**:

- **O1.** Ricavare da una traccia i dati, le operazioni e i vincoli (espliciti e impliciti), distinguendo ciò che è dichiarato da ciò che è assunto.
- **O2.** Costruire un modello concettuale Entità/Associazioni (*Entity/Relationship*, ER) con entità, attributi, associazioni, cardinalità minime e massime, e motivare ogni scelta.
- **O3.** Distinguere i vincoli rappresentabili nello schema da quelli che richiedono altri meccanismi (`CHECK`, `UNIQUE`, trigger, controllo applicativo).
- **O4.** Tradurre il modello concettuale in schema relazionale scegliendo strategie adeguate per gerarchie, associazioni 1:1 opzionali e obbligatorie, associazioni 1:N e associazioni N:M, trattando i valori nulli e verificando la normalizzazione (1NF, 2NF, 3NF; BCNF se giustificata).
- **O5.** Codificare lo schema usando i costrutti del *Data Definition Language* (DDL) di SQLite, con tipi e vincoli appropriati.
- **O6.** Costruire dati di test significativi, inclusi casi limite, nulli e assenza di corrispondenze, codificandoli con istruzioni del *Data Manipulation Language* (DML) di SQLite.
- **O7.** Scrivere query SQL corrette, verificarle su dati propri e motivarne la correttezza.
- **O8.** Rivedere la propria soluzione a partire da un feedback e giustificare la modifica. Apprendere un modello di sviluppo iterativo in cui la critica di ogni scelta conduce a un modello via via più completo, pertinente, minimale, intelligibile e coerente.

## Ruoli {#sec-ruoli}

### Docente

- Sceglie o inserisce la traccia (dal catalogo o da prove d'esame) e **valida** la checklist dei requisiti proposta dallo strumento d'autore. Facoltativamente fornisce uno schema canonico con dataset e query attese, per il controllo automatico dei risultati nella fase 8. Non scrive soluzioni alternative, dati di riferimento né test.
- Decide la sequenza, i tempi e i livelli di aiuto massimi consentiti per ciascun esercizio, e se abilitare la generazione automatica del DDL (fase 6) e dei dati di test (fase 7).
- Legge le consegne (commit e Merge Request) e il report compatto del processo; legge a campione motivazioni e dialoghi; commenta in modo umano.
- Esamina le segnalazioni di falsi positivi (soluzioni valide respinte) e decide se correggere la checklist o il controllo.
- **È l'unico a esprimere valutazioni.** Conduce la prova individuale di trasferimento.
- Revisiona periodicamente un campione di dialoghi per individuare errori del tutor LLM.

### LLM (tutor)

- Compito principale: trasformare le *diagnosi strutturate* prodotte dai controlli deterministici in una risposta socratica, al livello di aiuto richiesto dallo stato del dialogo. Le diagnosi sono vincolanti: la LLM non le contraddice.
- Chiede allo studente di motivare le scelte e di riformulare.
- Non assegna punteggi, non dichiara «superato/non superato», non fornisce la soluzione completa, non esegue SQL.
- Dove non c'è diagnosi deterministica (decisioni progettuali e correttezza semantica di cardinalità e query), formula domande e controesempi, dichiarando che esistono più soluzioni accettabili.
- Si comporta come sistema esperto che valuta costantemente, ma fornisce il proprio punto di vista **solo su richiesta** (salvo nella fase 8, dove il parere sul risultato delle query fa parte del dialogo) e dichiarandolo *non vincolante* (a differenza delle diagnosi deterministiche), su:
  - l'eliminazione delle ambiguità terminologiche e semantiche;
  - la completezza rispetto alle specifiche e alla possibilità di formulare le interrogazioni richieste dal testo;
  - la correttezza del modello e dei vincoli, oppure della sintassi, rispetto ai costrutti del modello in uso;
  - la minimalità, intesa come non ridondanza nei modelli e come realizzazione di query efficienti che non richiedono elaborazioni non necessarie;
  - la pertinenza del lessico rispetto al testo e al dominio.
- Procede in modo maieutico ai livelli di aiuto L0–L2 e passa all'elicitazione ai livelli L3–L4.
- Nella fase 7, se il docente abilita la generazione automatica, propone i dati di test (istruzioni INSERT) coerenti con lo schema dello studente; l'output è sempre sottoposto a verifica deterministica.
- Nella fase 8 riceve dall'esecutore il risultato della query sui dati di test e formula un parere non vincolante sulla corrispondenza tra richiesta, query e risultato, trasformandolo in domande (righe attese, mancanti o duplicate); non scrive la query corretta.
- Se incerto, richiede di contattare il docente.

### Sistema deterministico (orchestratore e controlli)

- Mantiene lo stato del percorso, valida i formati, esegue operazioni sullo schema (DDL), sui dati (DML) e sulle query (QL) in SQLite isolato e produce le diagnosi. Deriva dallo schema dello studente i test negativi e la copertura strutturale dei dati di test, verifica i dati proposti dalla LLM nella fase 7 e, se abilitato, genera il DDL dal modello relazionale consegnato. Passa al tutor il risultato delle query. Con lo schema canonico opzionale confronta i risultati con le query attese.

## Verifica dell'apprendimento: prodotto, processo, trasferimento {#sec-verifica-apprendimento}

La qualità della soluzione finale non dimostra che lo studente l'abbia compresa. Si raccolgono evidenze distinte:

| Dimensione | Evidenza | Fonte |
| --- | --- | --- |
| Qualità progettuale | Schema corretto, completo, pertinente, minimale | Controlli deterministici + lettura del docente |
| Ragionamento | Motivazioni di cardinalità, chiavi e vincoli | Campo `motivazione` nei file + dialogo (lettura del docente) |
| Revisione | Correzione autonoma dopo feedback | Storia dei commit e dei livelli di aiuto richiesti |
| Competenza SQL | Query eseguibili e corrette su dati significativi | Esecuzione automatica sui dati di test; parere non vincolante del tutor |
| Trasferimento | Soluzione di una traccia nuova, senza assistenza | Prova individuale in aula, valutata dal docente |

Solo l'ultima riga, insieme alla lettura umana delle altre, concorre alla valutazione scolastica.

## Rischi didattici e contromisure {#sec-rischi-didattici}

- **Tutor come sistema di sblocco.** Chi deve raggiungere una soglia ottimizza il punteggio, non la comprensione. *Contromisura:* nessuna soglia; l'avanzamento è consigliato, non vincolato; i punti aperti restano visibili.
- **Delega del pensiero.** *Contromisura:* ogni consegna richiede una motivazione scritta dallo studente; richiesta di aiuto ai livelli alti registrata; prova finale senza tutor.
- **Giudizi non riproducibili.** *Contromisura:* ogni affermazione sulla correttezza proviene da un controllo deterministico ripetibile.
- **Fiducia eccessiva nel tutor.** *Contromisura:* il tutor dichiara quando non è certo e rimanda al docente.
