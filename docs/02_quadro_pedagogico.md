# Specifica pedagogica {#sec-specifica-pedagogica}

## Destinatari {#sec-destinatari}

**Destinatari primari (Istituto proponente e fase iniziale della sperimentazione)**  
Studenti del secondo biennio e del quinto anno dell’**Istituto Tecnico Economico (ITE)**, indirizzo «Amministrazione, Finanza e Marketing», articolazione **«Sistemi Informativi Aziendali» (SIA, codice ITSI)**.

**Destinatari in contesti di trasferibilità**  
Il percorso è progettato in modo da poter essere ripreso anche in Istituti Tecnici Tecnologici, indirizzo Informatica e Telecomunicazioni, articolazione Informatica (ITIA), e in corsi universitari introduttivi di basi di dati. Tali contesti non costituiscono la popolazione iniziale della sperimentazione presso l’Istituto proponente.

Il sistema tiene conto dei quadri di riferimento e dei nuclei fondanti della Seconda Prova scritta dell’Esame di Stato per le discipline d’indirizzo (progettazione concettuale, logica e fisica di basi di dati; linguaggi per basi di dati).

**Destinatari secondari / adattati**  
Classi del **Liceo Scientifico opzione Scienze Applicate**. Per queste classi il percorso è limitato alle fasi di analisi dei requisiti e modellazione concettuale Entity-Relationship (con eventuale traduzione verso schema relazionale e individuazione di vincoli). **Non** si prevede la scrittura né l’esecuzione di SQL.

La sperimentazione può inoltre essere estesa e adattata come supporto all’auto-apprendimento guidato in un primo corso universitario di «Basi di Dati».

Le classi coinvolte lavorano tipicamente in gruppi da 5 a 20 studenti, in modalità individuale o a coppie.

## Prerequisiti {#sec-prerequisiti}

- **Matematica e logica di base**:
  - concetti elementari della teoria degli insiemi (rappresentazione, appartenenza, unione, intersezione, differenza/complementazione, prodotto cartesiano e concetto di relazione);
  - fondamenti di logica proposizionale e predicativa (valori di verità, connettivi logici `NOT`, `AND`, `OR`).
- **Concetti introduttivi di modellizzazione e basi di dati**:
  - comprensione intuitiva del modello concettuale (entità, associazione, attributo, cardinalità min/max e concetti base di gerarchia/specializzazione);
  - strutture del modello relazionale (concetti informali di tabella, riga/tupla, colonna/attributo, chiave primaria, chiave esterna e vincoli fondamentali di integrità).
- **Linguaggio SQL di base** (solo per gli indirizzi tecnici):
  - familiarità elementare con la sintassi SQL per le interrogazioni semplici (clausole `SELECT`, `FROM`, `WHERE`); il consolidamento di interrogazioni complesse (`JOIN`, aggregazioni `GROUP BY` e sottoquery) è uno degli obiettivi formativi del percorso.
- **Competenze digitali e strumentali**:
  - uso base di un editor di testo o ambiente di sviluppo (IDE);
  - familiarità con gli strumenti di Google Workspace for Education (Classroom, Drive) utilizzati nel Pilota 1.

## Struttura del glossario dei termini

Il glossario (derivato dall’analisi nomi-verbi) adotta la struttura consolidata nel Requirements Engineering e nella modellazione di basi di dati:

| Campo | Descrizione |
|-------|-------------|
| **Termine** | Nome del concetto |
| **Definizione** | Descrizione chiara e contestuale |
| **Sinonimi** | Altri nomi usati per lo stesso concetto |
| **Omonimi / Da non confondere** | Termini simili ma con significato diverso |
| **Classificazione** | Entità / Attributo / Associazione / Scartare / Altro |
| **Termini correlati** | Concetti collegati nel dominio |

## Obiettivi di apprendimento {#sec-obiettivi-apprendimento}

Al termine lo studente è in grado di, **autonomamente e senza tutor**:

- **O1.** Ricavare da una traccia i dati, le operazioni e i vincoli (espliciti e impliciti), distinguendo ciò che è dichiarato da ciò che è assunto.
- **O2.** Costruire un modello concettuale Entità/Associazioni (*Entity/Relationship*, ER) con entità, attributi, associazioni, cardinalità minime e massime, e motivare ogni scelta.
- **O3.** Distinguere i vincoli rappresentabili nello schema da quelli che richiedono altri meccanismi (`CHECK`, `UNIQUE`, trigger, controllo applicativo).
- **O4.** Tradurre il modello concettuale in schema relazionale scegliendo strategie adeguate per gerarchie, associazioni 1:1 opzionali e obbligatorie, associazioni 1:N e associazioni N:M, trattando i valori nulli e verificando la normalizzazione (1NF, 2NF, 3NF; BCNF se giustificata).
- **O5.** Codificare lo schema usando i costrutti del *Data Definition Language* (DDL) di SQLite, con tipi e vincoli appropriati. *(Solo indirizzi tecnici)*
- **O6.** Costruire dati di test significativi, inclusi casi limite, nulli e assenza di corrispondenze, codificandoli con istruzioni del *Data Manipulation Language* (DML) di SQLite. *(Solo indirizzi tecnici)*
- **O7.** Scrivere query SQL corrette, verificarle su dati propri e motivarne la correttezza. *(Solo indirizzi tecnici)*
- **O8.** Rivedere la propria soluzione a partire da un feedback e giustificare la modifica. Apprendere un modello di sviluppo iterativo in cui la critica di ogni scelta conduce a un modello via via più completo, pertinente, minimale, intelligibile e coerente.

Per il **Liceo Scientifico Scienze Applicate** gli obiettivi si limitano a O1–O3 (e, se ritenuto opportuno, a una versione semplificata di O4).

## Ruoli {#sec-ruoli}

### Docente

- Sceglie o inserisce la traccia (dal catalogo delle Seconda Prove dell’Esame di Stato, da prove d’Istituto o da tracce revisionate) e valida i requisiti.
- Decide la sequenza, i tempi e i livelli di aiuto massimi consentiti.
- Osserva il lavoro in classe, raccoglie le trascrizioni dei dialoghi e gli elaborati.
- **È l’unico a esprimere valutazioni.** Conduce la prova individuale di trasferimento (su carta, senza dispositivi elettronici).
- Partecipa alla correzione in cieco insieme a un secondo docente interno.
- Monitora il carico di lavoro proprio e dei colleghi sperimentatori.

### LLM (tutor socratico)

- Compito principale: condurre un dialogo maieutico attraverso domande, controesempi ed elicitazione progressiva dei vincoli, rispettando i livelli di aiuto L0–L4.
- Non assegna punteggi, non dichiara «superato/non superato», non fornisce la soluzione completa.
- Non esegue SQL né valuta la correttezza formale (questo compito, quando presente, è riservato ai controlli deterministici o al docente).
- Dichiara esplicitamente quando una valutazione è non vincolante.
- Se incerto, invita lo studente a rivolgersi al docente.

### Sistema deterministico (quando attivo nei piloti successivi)

- Valida formati, esegue controlli strutturali e, nei piloti più avanzati, opera su schema e query in ambiente isolato.
- Produce diagnosi vincolanti che il tutor linguistico non può contraddire.
- Non sostituisce mai il giudizio del docente.

## Verifica dell’apprendimento: prodotto, processo, trasferimento {#sec-verifica-apprendimento}

La qualità della soluzione finale non dimostra da sola che lo studente l’abbia compresa. Si raccolgono evidenze distinte:

| Dimensione | Evidenza | Fonte |
| --- | --- | --- |
| Qualità progettuale | Schema corretto, completo, pertinente, minimale | Lettura del docente (+ eventuali controlli deterministici) |
| Ragionamento | Motivazioni di cardinalità, chiavi e vincoli | Testi prodotti dallo studente + dialogo |
| Revisione | Correzione autonoma dopo feedback | Storia delle revisioni e livelli di aiuto richiesti |
| Competenza SQL (solo indirizzi tecnici) | Query corrette su dati significativi | Elaborati + eventuale esecuzione controllata |
| **Trasferimento** | Soluzione di una traccia nuova, **senza assistenza** | Prova individuale **su carta**, senza dispositivi elettronici, valutata dal docente |

La prova di trasferimento **entra nella valutazione sommativa**. Gli elaborati intermedi prodotti con il tutor **non entrano** nella valutazione sommativa.

## Rischi didattici e contromisure {#sec-rischi-didattici}

- **Delega del pensiero (cognitive offloading).**  
  *Contromisura:* livelli di aiuto espliciti L0–L4; obbligo di motivazione scritta; prova di trasferimento su carta senza dispositivi.

- **Tutor come sistema di sblocco.**  
  *Contromisura:* nessuna soglia automatica di avanzamento; i punti aperti restano visibili; valutazione esclusivamente umana.

- **Sovraccarico cognitivo o di tempo.**  
  *Contromisura:* limitazione iniziale a piccole classi; monitoraggio dei tempi; adattamento degli obiettivi per il Liceo.

- **Disomogeneità tra indirizzi.**  
  *Contromisura:* percorso completo per ITIA e SIA; percorso ridotto (solo fasi iniziali) per il Liceo Scientifico Scienze Applicate.
