# Appendice C — Realizzazione tecnica dei piloti (Gem, Skill, Modelfile) {#sec-appendice-realizzazione}

> **Destinatari di questa appendice:** docenti tecnici, amministratori Google Workspace e chi configura i runtime.  
> Il **corpo principale** del documento descrive *cosa* si sperimenta e *perché*; qui si indica *dove* si trovano le istruzioni operative di implementazione.

---

## Pilota 1 — Zero-infrastructure (Google Classroom + Gemini)

Nella fase iniziale non è richiesta alcuna installazione locale. Si utilizza una **Custom Gem** di Gemini all’interno di Google Workspace for Education, con istruzioni di sistema che impongono il metodo socratico e i livelli di aiuto L0–L4.

| Elemento | Collocazione nel repository |
|----------|------------------------------|
| Istruzioni di sistema per la Gem | `gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md` |
| Skill agentica (stesso ruolo pedagogico) | `skills/socratic-db/SKILL.md` |
| Modalità d’uso | Condivisione della Gem via Google Classroom; gli studenti consegnano le trascrizioni del dialogo come allegato al compito |

L’uso di Gemini è subordinato a conferma del DPO rispetto alle policy dell’Istituto. Non si inseriscono dati personali reali nelle tracce.

---

## Pilota 2 — Feasibility check on-premise (Ollama)

Quando i criteri di go del Pilota 1 sono soddisfatti, le stesse istruzioni socratiche possono essere caricate in un **Modelfile** per Ollama, eseguito sulla workstation di laboratorio (obiettivo: 6 GB di VRAM, modelli quantizzati di dimensioni contenute).

**Natura del pilota.** Il Pilota 2 è un *feasibility check* del modello locale, non un tutor di produzione. Serve a misurare, sullo hardware reale dell’Istituto: contesto utile, latenza per turno, qualità e stabilità del dialogo maieutico, rispetto di L0–L4 e assenza di fuga della soluzione su un campione di sessioni. Un esito negativo o parziale (qualità insufficiente, latenza inaccettabile) non invalida il Pilota 1: consente di restare su Gemini o di rivedere modello/quantizzazione.

| Elemento | Collocazione nel repository |
|----------|------------------------------|
| Modelfile | `ollama/Modelfile` |
| Vincoli hardware | Vedi anche Appendice A (scelta del modello e parametri di inferenza) |

Non si promuove, nella fase 1, l’installazione di modelli open-weight sui dispositivi personali degli studenti. L’eventuale esecuzione locale a casa è uno scenario evolutivo descritto nel protocollo di sperimentazione (sezione sul lavoro domestico).

---

## Composizione delle istruzioni per i Piloti 1 e 2

Gem, Skill e Modelfile devono condividere un **nucleo breve e invariabile**: identità socratica, divieto di fornire soluzioni complete o valutazioni, lingua italiana, tutela dei dati e definizione dei livelli L0–L4. Questo nucleo è integrato, per la singola interazione, da un modulo relativo alla fase o consegna corrente.

Il modulo di consegna descrive il risultato atteso, le dimensioni con cui valutarne correttezza, completezza, minimalità, pertinenza ed efficienza, il formato previsto, gli errori ricorrenti e pochi esempi pertinenti. I livelli L0–L4 restano invece una regola di formulazione trasversale: stabiliscono se presentare un esito, una domanda, un controesempio, un principio o un esempio isomorfo; non richiedono artefatti runtime distinti.

Nei primi due piloti si mantiene quindi una sola configurazione per runtime (una Gem, una Skill e un Modelfile), per evitare disallineamenti e passaggi impropri tra tutor. Una raccolta di esempi fase × livello può essere mantenuta separatamente e usata in modo selettivo; non va riversata integralmente nelle istruzioni statiche, perché sottrae contesto alla traccia, all'elaborato e alla conversazione. Solo una futura fase con input, formati o controlli deterministici sostanzialmente diversi giustifica una configurazione separata.

Una Gem e un Modelfile non selezionano dinamicamente il modulo di consegna: nei Piloti 1 e 2 questa scelta è effettuata manualmente, attraverso il patto formativo, l'indicazione esplicita della fase e l'istruzione contestuale fornita dal docente o dallo studente. La selezione automatica richiede un componente applicativo esterno e appartiene quindi ai piloti con orchestratore.

La configurazione va considerata tecnicamente fattibile ma da validare sul campo. Per Gemini occorre verificare il rispetto effettivo delle istruzioni e la sostenibilità del passaggio manuale; per Ollama vanno misurati contesto utile, latenza e qualità della risposta sul modello e sull'hardware selezionati. In entrambi i casi la verifica include aderenza a L0–L4, pertinenza del feedback e assenza di fuga della soluzione.

Su dialoghi multi-turno i modelli tendono alla *sycophancy*. Mantenere il comportamento maieutico richiede quindi non solo un buon system prompt iniziale, ma un processo di affinamento continuo: aggiornamento del nucleo e dei moduli di fase, golden set di regressione, filtro di non-fuga e revisione campionaria delle trascrizioni. Filtro e golden set non sono «set and forget».

---

## Pilota intermedio (eventuale) e Piloti 3–4

**Pilota intermedio (2.5), se c’è capacità di ricerca.** L’organico scolastico da solo difficilmente realizza in tempi brevi validatori, filtro di non-fuga automatico e golden set. Un accordo con un gruppo universitario (tipicamente uno o due ricercatori con SSD affini a basi di dati / sistemi, es. ING-INF/05) può rendere realistico un pilota dedicato a prototipi minimi: checklist eseguibile, parser leggero, primi test automatici di non-fuga, senza ancora orchestratore e sandbox completi. Non è una fase obbligatoria del protocollo scolastico.

**Piloti 3 e 4 — Stack parziale e completo.** I controlli deterministici, la sandbox SQLite e l’architettura ibrida completa sono descritti in **Appendice A**. I formati di consegna strutturati (YAML e affini), utili quando i controlli automatici sono attivi, sono in **Appendice B**. Nella fase iniziale della sperimentazione (Pilota 1) tali formati **non** sono obbligatori per gli studenti. Fino a quando non esiste software funzionante, non si presenta lo stack come operativo.

---

## Principio di separazione

| Documento / componente | Contenuto |
|------------------------|-----------|
| Corpo principale (capitoli 1–7 del volume) | Pedagogia, protocollo di sperimentazione, privacy, governance, metriche |
| Appendice A | Architettura, hardware, controlli deterministici, ipotesi di sistema avanzato |
| Appendice B | Formati di consegna e schemi (YAML, Markdown obbligato, ecc.) |
| Appendice C (questo file) | Collegamento operativo a Gem, Skill e Modelfile |
| File `gemini-gem/`, `ollama/`, `skills/` | Sorgenti pronti all’uso |
