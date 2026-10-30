# Protocollo di sperimentazione empirica di Socratic-DB {#sec-protocollo-sperimentazione}

> **Nota di stato.** Il presente testo è, al momento, un **unico documento in bozza** destinato a più lettori (progettisti della sperimentazione, Dirigente scolastico, docenti coinvolti, DPO, amministratori Google Workspace, personale del progetto Health School, amministratori dell’infrastruttura informatica). Eventuali versioni differenziate per destinatario potranno essere derivate in una fase successiva.

---

## Premessa e inquadramento istituzionale

Socratic-DB è un ambiente di apprendimento assistito dall’Intelligenza Artificiale Generativa progettato per contrastare la *delega cognitiva* (*cognitive offloading*) nella progettazione di basi di dati relazionali. Il sistema affida all’LLM la sola mediazione maieutica (domande, controesempi, livelli di aiuto L0–L4) e riserva al docente umano la valutazione definitiva dell’apprendimento.

### Istituto proponente e destinatari della sperimentazione

La sperimentazione è proposta e avviata presso un Istituto di Istruzione Superiore che comprende, tra gli altri, un **Istituto Tecnico Economico** con indirizzo Amministrazione, Finanza e Marketing e articolazione **Sistemi Informativi Aziendali (SIA / codice ITSI)**.

**Fase iniziale (prioritaria):** studenti dell’articolazione **SIA**.  
**Fasi successive (eventuali):** altre classi dell’Istituto in cui è presente l’insegnamento di Informatica e delle basi di dati relazionali (incluse, con percorso ridotto, classi del Liceo Scientifico opzione Scienze Applicate).

**Nota.** L’indirizzo ITIA (Informatica e Telecomunicazioni) non è presente nell’Istituto proponente; eventuali riferimenti a ITIA in documenti generali del progetto Socratic-DB riguardano la trasferibilità dell’esperienza ad altri contesti, non la popolazione iniziale di questa sperimentazione.

### Destinatari di questo documento

- Progettisti e docenti sperimentatori
- Dirigente scolastico
- Docenti di Informatica coinvolti
- Responsabile della Protezione dei Dati (DPO)
- Amministratori della piattaforma Google Workspace for Education
- Personale e referenti del progetto [Health School](https://formazione.centropapagiovanni.it/health-school/)
- Amministratori dell’infrastruttura informatica e dei servizi di rete dell’Istituto

### Vincoli organizzativi

- Lezioni di Informatica in moduli di **2 ore consecutive**
- Periodo: inizio del secondo quadrimestre (**febbraio–marzo**)
- Durata: **6–8 ore** in classe con il tutor + **2 ore** di prova di trasferimento + eventuali **2–4 ore** di lavoro domestico
- Hardware: workstation di laboratorio con **6 GB di VRAM**, 64 GB di RAM, 32 thread
- Cloud: Google Workspace for Education con Gemini (uso subordinato a conferma del DPO)
- Risorse umane: **3 docenti sperimentatori** + **1 correttore in cieco** interno
- Rubrica analitica condivisa già disponibile tra i docenti

La sperimentazione inizia con una classe quinta SIA di **5 studenti** e può essere estesa in modo progressivo e controllato.

---

## Obiettivi della sperimentazione

### Obiettivi primari (articolazione SIA)

1. Verificare se l’uso di un tutor socratico basato su LLM, con livelli di aiuto espliciti L0–L4, riduce la delega cognitiva e favorisce l’acquisizione autonoma delle competenze di modellazione e interrogazione di basi di dati.
2. Misurare l’efficacia didattica attraverso pre-test, post-test e **prova di trasferimento** su carta, senza dispositivi elettronici.
3. Valutare la tenuta maieutica del tutor (assenza di “fuga della soluzione”) e la sostenibilità operativa per il docente.

### Obiettivi secondari / adattati (Liceo Scientifico Scienze Applicate, se coinvolto)

Limitazione alle fasi di analisi dei requisiti, glossario e modellazione concettuale Entity-Relationship (eventualmente schema relazionale semplificato). **Non** si prevede scrittura né esecuzione di SQL.

### Obiettivi di processo, trasferimento e buone pratiche

- Validare la progressione a piloti (da zero-infrastructure a stack più completo).
- Quantificare e contenere il carico di lavoro dei docenti sperimentatori.
- Raccogliere evidenze utili a definire **buone pratiche trasferibili**:
  - in ambito disciplinare (Informatica nella secondaria di secondo grado; corsi universitari introduttivi di basi di dati);
  - in ambito trasversale (tutor socratici, metodologia maieutica, separazione tra mediazione linguistica e controlli, protocolli di sperimentazione sull’IA a scuola).

### Allineamento alle Indicazioni CINI sull’Informatica a scuola

La proposta si colloca in continuità con la *Proposta di Indicazioni Nazionali per l’insegnamento dell’Informatica nella Scuola* del Laboratorio «Informatica e Scuola» del CINI, in particolare rispetto a:

- capacità di **modellare problemi** e di rappresentare e organizzare dati;
- distinzione tra livelli di astrazione (concettuale / logico);
- consapevolezza di come la rappresentazione dei dati influisca su efficacia ed efficienza;
- uso consapevole degli strumenti digitali, qui declinato come contrasto alla delega cognitiva verso gli LLM.

Il percorso Socratic-DB esercita, in modo mirato, competenze di analisi dei requisiti, modellazione concettuale e logica, e (per i percorsi tecnici) interrogazione, in un contesto di scaffolding dialogico controllato.

---

## Protocollo sperimentale e modalità di rilevazione {#sec-disegno-ricerca}

Il protocollo adotta un approccio **intra-soggetto** (pre-test → intervento → post-test → prova di trasferimento a 3–4 settimane) per tutti gli studenti coinvolti.

Nella prima sperimentazione **non** si prevede un gruppo di controllo formale né un disegno a rotazione (*crossover*), per minimizzare il carico organizzativo e le criticità etiche. Confronti descrittivi con classi parallele potranno essere valutati in fasi successive.

### Strumenti di misurazione e impatto

| Strumento | Momento | Modalità | Finalità |
|-----------|---------|----------|----------|
| **Pre-test diagnostico** | Prima dell’intervento | Su carta o in laboratorio controllato; rubrica condivisa | Livello di partenza su analisi, modellazione, (eventualmente) SQL |
| **Attività formative con Socratic-DB** | Durante le 6–8 ore | Dialogo con tutor + elaborati intermedi (glossario, E/R, modello logico) | Processo e livelli di aiuto richiesti |
| **Post-test** | Al termine dell’intervento | Individuale, rubrica condivisa | Variazione rispetto al pre-test |
| **Prova di trasferimento** | 3–4 settimane dopo | **Su carta, senza dispositivi** (2 ore); rubrica condivisa | Ritenzione e autonomia; **entra nella valutazione sommativa** |
| **Correzione in cieco** | Dopo post-test e prova di trasferimento | Sperimentatore + correttore interno | Accordi inter-valutatore; riduzione bias |
| **Autodichiarazione fuga della soluzione** | Fine attività con tutor | Domanda strutturata + verifica a campione | Tenuta maieutica del tutor |
| **Questionario di esperienza e gradimento** | Fine percorso | Scala Likert + domande aperte | Usabilità, autoefficacia, carico percepito, utilità |
| **Diario / note del docente** | Continuo | Osservazione in classe | Blocchi tecnici/didattici, andamento del dialogo |

Gli elaborati intermedi prodotti con il tutor **non entrano** nella valutazione sommativa; servono al monitoraggio del processo e alla ricerca.

Esempi di item per pre/post-test e prova di trasferimento potranno essere costruiti a partire dalle tracce ministeriali catalogate in `tracce/` (Seconda Prova SIA/ITSI e analoghe), adattate in complessità al tempo disponibile.

---

## Progressione a piloti

1. **Pilota 1 – Zero-infrastructure** (già avviato): Gem di Gemini in Google Classroom.  
2. **Pilota 2 – On-premise leggero**: Ollama sulla workstation (6 GB VRAM).  
3. **Pilota 3 – Stack parziale**: alcuni controlli deterministici e sandbox SQLite.  
4. **Pilota 4 – Stack completo**: architettura neuro-simbolica piena (solo dopo consolidamento).

Criteri di passaggio (go/no-go) includono: tenuta maieutica entro le soglie di fuga, feedback positivo, assenza di incidenti privacy, carico docente entro le stime.

---

## Protocollo operativo

### Ruoli

| Ruolo | Responsabilità | Carico stimato (fase 5 studenti) |
|-------|----------------|----------------------------------|
| Docente sperimentatore (3) | Traccia, gestione classe, osservazione, trascrizioni, prima valutazione | **12 ore** extracurricolari a docente |
| Correttore in cieco (1) | Valutazione indipendente post-test e prova di trasferimento | **5 ore** |
| Studente | Dialogo con tutor, elaborati, prova di trasferimento su carta | — |
| Dirigente / DPO | Autorizzazione, privacy, delibere | — |

### Flusso didattico (articolazione SIA)

**In classe (6–8 ore)**

1. Pre-test
2. Patto formativo e livelli L0–L4
3. Glossario (struttura: Termine, Definizione, Sinonimi, Omonimi/Da non confondere, Classificazione, Termini correlati)
4. Modello concettuale E/R (vincoli espliciti: cardinalità)
5. Modello logico in Markdown + vincoli in linguaggio naturale/SQL-like
6. Eventuali DDL/DML/query se il tempo lo consente
7. Post-test e autodichiarazione sulla fuga della soluzione

**Prova di trasferimento** (2 ore, a 3–4 settimane): su carta, senza dispositivi; entra nel voto.  

### Lavoro domestico e scenari di esecuzione locale

**Fase attuale (Pilota 1).**  
Il lavoro domestico (indicativamente 2–4 ore) consiste nell’uso della **Gem istituzionale** di Gemini, con le stesse istruzioni socratiche impiegate in classe. È **incoraggiato**, non obbligatorio e **non controllabile** ora per ora. L’ancoraggio all’autonomia resta la prova di trasferimento su carta, senza dispositivi elettronici.

**Scenario evolutivo.**  
Se in seguito saranno rilasciati in modo aperto il Modelfile Ollama, immagini Docker o un runtime minimo dello stack, diventa tecnicamente prevedibile l’esecuzione del tutor sul **dispositivo dello studente** (notebook/PC con GPU consumer, NPU integrate, architetture a memoria unificata). In quel caso:

- andrà definita una configurazione “scolastica” del runtime (system prompt non facilmente alterabile);
- andrà valutato l’impatto su **equità** (chi non dispone di hardware adeguato non deve essere svantaggiato nelle attività curricolari);
- i dialoghi locali non entreranno automaticamente nei log istituzionali: le metriche di processo andranno integrate con autodichiarazioni e, se opportuno, esportazioni campionarie di sessioni;
- privacy e integrità del tutor (modifica del prompt, modelli non ufficiali) saranno oggetto di valutazione dedicata con il DPO prima di qualsiasi raccomandazione agli studenti.

**Principi invarianti** (cloud o locale): livelli di aiuto L0–L4; divieto di soluzione completa; valutazione solo del docente; prova di trasferimento senza dispositivi. Nella fase 1 **non** si promuove l’installazione di modelli open-weight su device personali.

### Materiali

Tracce da catalogo Seconda Prova (Esame di Stato), prove d’Istituto, tracce generate da LLM e **sempre revisionate da docenti**. Prove di complessità ridotta per consentire tempi di correzione realistici (~15 min/compito).

---

## Metriche e soglie

**Processo**

- Livello massimo di aiuto (L0–L4)
- Numero di iterazioni
- Tempi stimati

**Fuga della soluzione** (autodichiarazione + verifica a campione)

- Campione di 5 studenti: inferiore al 10 %
- Campione ampio: inferiore al 5 %

**Apprendimento**

- Punteggi pre-test, post-test e prova di trasferimento (rubrica condivisa)
- Qualità delle motivazioni
- Accordo inter-valutatore

**Sostenibilità**

- Tempo di predisposizione e di lettura delle trascrizioni
- Rispetto delle 12 ore extracurricolari a docente (fase iniziale)

**Esperienza**

- Questionario Likert e domande aperte (usabilità, autonomia, utilità, carico)

---

## Consenso e privacy

- Base preferita: **consenso esplicito** dei genitori (o dello studente maggiorenne).  
- Opzione: limitazione ai maggiorenni.  
- Informativa, Registro trattamenti, DPIA se richiesta dal DPO.  
- Pilota 1 su Google Workspace subordinato a conferma del DPO.  
- Nessun dato personale reale nelle tracce.  
- Partecipazione volontaria; diritto di recesso senza penalizzazioni.

---

## Cronoprogramma indicativo

| Periodo | Attività |
|---------|----------|
| Dicembre – gennaio | Informativa e consensi; formazione dei 3 sperimentatori; affinamento Gem; conferma DPO su Gemini |
| Febbraio | Avvio Pilota 1 (classe quinta SIA, 5 studenti): pre-test + attività |
| Febbraio – marzo | Completamento 6–8 ore; post-test e autodichiarazione |
| Marzo – aprile | Prova di trasferimento (2 h); correzione in cieco; prime analisi |
| Aprile – maggio | Eventuale estensione; avvio Pilota 2 se criteri di go soddisfatti |
| Fine anno | Relazione intermedia; decisioni sulla prosecuzione |

---

## Criteri di successo e di interruzione

**Successo**

- Miglioramento misurabile tra pre-test e prova di trasferimento
- Riduzione del ricorso ai livelli di aiuto L3–L4
- Fuga della soluzione sotto le soglie definite
- Carico docente entro le stime
- Assenza di incidenti di privacy
- Feedback complessivamente positivo da studenti e docenti

**Interruzione o ridimensionamento**

- Problemi tecnici non risolvibili in tempi ragionevoli
- Carico incompatibile con l'orario di servizio
- Fuga sistematica della soluzione oltre le soglie
- Criticità segnalate dal DPO
- Feedback fortemente negativo da studenti o famiglie

---

## Rischi e mitigazioni

| Rischio | Mitigazione |
|---------|-------------|
| Delega cognitiva | Livelli L0–L4 + prova di trasferimento su carta |
| Fuga della soluzione | Istruzioni rigorose + autodichiarazione + campione |
| Carico docente | Avvio con 5 studenti; stime orarie esplicite |
| 6 GB VRAM | Modelli quantizzati; priorità al Pilota 1 |
| Privacy | DPO; consenso; opzione maggiorenni |
| Lavoro domestico non controllabile | Accettato come limite in fase 1; solo incoraggiamento; prova di trasferimento come ancoraggio |
| Esecuzione locale su device studente (scenario futuro) | Non attivata in fase 1; se introdotta: runtime “scolastico”, valutazione equità e DPO |

---

## Trasferibilità e piano di espansione

1. Consolidamento del Pilota 1 sulla classe SIA iniziale.  
2. Estensione graduale ad altre classi SIA e, con adattamento, ad altri percorsi dell’Istituto.  
3. Documentazione di **buone pratiche** (prompt, livelli di aiuto, protocollo di rilevazione, rubriche) riutilizzabili da altre scuole e da corsi universitari introduttivi di basi di dati.  
4. Possibile estensione metodologica a tutor socratici in altri ambiti disciplinari.  
5. Relazioni intermedie e finali per la governance dell’Istituto e per la condivisione in reti di scuole / progetti (incluso Health School).

---

## Governance

- Informativa e consensi  
- Parere / conferma del DPO (in particolare su Gemini)  
- Autorizzazione della Dirigente scolastica  
- Eventuali delibere collegiali secondo le prassi dell’Istituto  
- Restituzione formativa agli studenti  

Ogni modifica sostanziale al protocollo va motivata e sottoposta a Dirigente e DPO.
