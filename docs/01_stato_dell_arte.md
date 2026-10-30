# Stato dell'arte e inquadramento teorico {#sec-stato-arte}

## Introduzione e contesto {#sec-introduzione-contesto}

I modelli linguistici di grandi dimensioni (*Large Language Models*, LLM) hanno reso disponibili interfacce conversazionali capaci di produrre spiegazioni, esempi e codice in linguaggio naturale. Nella didattica dell'informatica, questa possibilità apre opportunità per sostenere l'esplorazione e il feedback, ma pone anche questioni relative all'affidabilità delle risposte, al ruolo attivo dello studente e alla valutazione dell'apprendimento [@becker2023programming; @denny2024computing; @prather2023robots]. Questi contributi discutono opportunità e criticità dell'IA generativa nell'istruzione e formazione informatica; non dimostrano, da soli, che un particolare modello o assetto didattico migliori gli apprendimenti in ogni contesto.

Nel progetto di basi di dati relazionali, l'attività non si esaurisce nella produzione di una query eseguibile. Richiede di interpretare requisiti, costruire un modello concettuale, tradurlo in uno schema relazionale, esplicitare chiavi e vincoli e formulare interrogazioni coerenti con il significato del problema. Il modello relazionale costituisce un riferimento teorico per la rappresentazione dei dati e delle relazioni tra essi [@codd1970relational], mentre il modello Entità/Associazioni è uno dei riferimenti classici, e probabilmente il più utilizzato nella scuola secondaria di secondo grado, per la progettazione concettuale [@chen1976entity]. La correttezza di una soluzione va quindi esaminata a più livelli: sintassi, proprietà formali dello schema, comportamento delle query e adeguatezza rispetto ai requisiti. Un controllo su un singolo insieme di dati, da solo, non prova la correttezza generale della soluzione.

**Socratic-DB** è una proposta di supporto alla progettazione e all'apprendimento delle basi di dati che combina tre componenti con responsabilità distinte:

1. **Controlli formalizzati**, per verificare le proprietà che possono essere espresse in modo deterministico, come vincoli strutturali, alcune proprietà dello schema e risultati dell'esecuzione SQL.
2. **Tutor conversazionale basato su LLM**, per porre domande, richiedere motivazioni, proporre controesempi e graduare gli aiuti, senza assumere che il modello segua sempre tali vincoli.
3. **Docente**, cui restano il giudizio sulle interpretazioni del dominio, la revisione delle diagnosi non formalizzabili e le decisioni valutative.

L'integrazione di questi componenti è una scelta progettuale, non una prova preventiva di correttezza complessiva o di efficacia didattica. Le domande di ricerca riguardano l'affidabilità dei controlli, la fedeltà del tutor al comportamento atteso, l'apprendimento autonomo e il trasferimento a problemi nuovi. Le ipotesi e il disegno di verifica sono descritti nel @sec-protocollo-sperimentazione.

---

## Sistemi di Tutorato Intelligente e didattica dei database {#sec-its-database}

I *Sistemi di Tutorato Intelligente* (*Intelligent Tutoring Systems*, ITS) costituiscono un precedente importante per il feedback automatizzato in domini tecnici. In questo ambito, il lavoro su SQL-Tutor di Mitrović illustra l'impiego del *Constraint-Based Modeling* (CBM): il sistema confronta la soluzione dello studente con vincoli disciplinari espliciti e può restituire feedback sulle violazioni individuate [@mitrovic1998sql; @mitrovic2003cbm]. Questo approccio offre un riferimento per rendere espliciti i criteri di controllo. Non implica, tuttavia, che ogni soluzione semanticamente valida possa essere riconosciuta automaticamente, né che lo stesso modello possa essere trasferito senza adattamenti a tutte le fasi della progettazione di una base di dati.

Socratic-DB condivide con gli approcci basati su vincoli l'idea di non affidare ogni giudizio tecnico alla generazione linguistica. La differenza proposta è l'ambito del percorso: oltre alla formulazione di query, il sistema considera analisi dei requisiti, modellazione concettuale, schema relazionale, implementazione e interrogazione. I controlli sono destinati a coprire proprietà esplicitamente formalizzate; la loro copertura effettiva deve essere misurata, e la correttezza semantica rispetto alla traccia non va considerata automaticamente risolta. Le checklist e i casi di prova richiedono definizione, revisione e manutenzione, mentre il docente deve poter riesaminare possibili falsi positivi o soluzioni alternative.

L'esecuzione di query su un database di prova permette di osservare risultati concreti e riproducibili. È però una forma di evidenza circoscritta: una query che produce il risultato atteso su un dataset potrebbe comportarsi diversamente su dati differenti o non rispettare tutti i requisiti. Per questo Socratic-DB propone di affiancare l'esecuzione a controlli strutturali e a un dialogo che chieda allo studente di motivare le proprie scelte, senza trattare nessuna di queste fonti come sufficiente in isolamento.

### Errori e misconcezioni nella formulazione di query SQL {#sec-errori-sql}

La ricerca sull'apprendimento di SQL analizza difficoltà e misconcezioni che possono emergere mentre gli studenti formulano query. Miedema, Aivaloglou e Fletcher studiano il ragionamento dei principianti attraverso un protocollo *think-aloud* [@miedema2021misconceptions]; Taipalus, Siponen e Vartiainen esaminano errori e complicazioni ricorrenti nella formulazione di query [@taipalus2018errors]. Il lavoro di Miedema sulla formazione sui sistemi di dati offre ulteriore contesto per scomporre i concetti e le difficoltà del dominio [@miedema2024learning]. Questi studi motivano l'attenzione a diagnosi più specifiche del solo messaggio d'errore del DBMS, ma i risultati ottenuti su compiti SQL non vanno trasferiti automaticamente alla modellazione concettuale o alla progettazione relazionale.

Ponzini, Guerrini e Catania propongono una revisione delle tassonomie degli errori SQL basata sulla rilevazione automatizzata [@ponzini2026taxonomy]. Questo filone è pertinente alla progettazione di report e categorie d'errore: una classificazione esplicita può rendere le diagnosi più confrontabili e consentire di studiare quali difficoltà ricorrono. La classificazione automatica, tuttavia, non garantisce da sola che una diagnosi sia corretta in ogni caso, che distingua sempre un errore da una soluzione alternativa valida o che il feedback migliori l'apprendimento.

La proposta di Socratic-DB è di usare categorie di errore e controlli formalizzati come supporto al dialogo, non come sostituti del ragionamento dello studente o della revisione del docente. La tassonomia dovrà essere adattata al compito specifico, soprattutto quando il problema riguarda l'interpretazione dei requisiti e non soltanto la sintassi o la semantica di una query.

### Modelli mentali e spiegazioni dei sistemi di dati {#sec-modelli-mentali-dati}

Miedema et al. discutono il concetto di *notional machine* per spiegare concetti dei sistemi di dati nell'insegnamento dell'informatica [@miedema2025notional]. Questo lavoro è pertinente alla scelta di non limitare il feedback alla forma testuale di una query: l'apprendimento richiede anche di costruire e verificare un modello di ciò che la query o lo schema rappresentano e producono. In Socratic-DB, una possibile traduzione progettuale consiste nel chiedere allo studente di prevedere il comportamento di una query, motivare una scelta di schema e poi confrontare la previsione con l'esecuzione o con un controesempio. L'utilità di questa sequenza per il sistema proposto resta un'ipotesi da verificare.

### Generazione di esercizi SQL con LLM e validazione {#sec-esercizi-sql-llm}

I lavori sulla generazione personalizzata di esercizi SQL con LLM e validazione basata su vincoli [@ponzini2026sql; @catania2026exercises] affrontano un problema vicino, ma distinto, da quello del tutoraggio dialogico: produrre esercizi e controllarne determinate proprietà non equivale a guidare uno studente nella modellazione, nella revisione di una soluzione o nella giustificazione delle scelte. Per Socratic-DB, la lezione progettuale è circoscritta: quando si usa un modello generativo per produrre materiale o spiegazioni, è opportuno esplicitare quali proprietà sono validate e quali rimangono da revisionare.

Un esempio di attività didattica in questo ambito è il laboratorio «Apprendimento di SQL basato su errori frequenti» di Guerrini e Ponzini, pubblicato negli atti ITADINFO 2026 [@guerrini2026sqlerrors]. Il laboratorio propone attività per far emergere e classificare errori, discutere possibili misconcezioni e usare IA generativa per spiegazioni ed esercizi mirati. Il contributo richiama anche LensQL come tutor e RelaX come strumento per l'algebra relazionale [@ponzini2026sql; @ponzini2026taxonomy]. Si tratta di un antecedente per l'uso didattico dell'analisi degli errori e di strumenti di supporto; la descrizione dell'attività non va interpretata come prova sperimentale dell'efficacia di Socratic-DB o di un tutor LLM nella progettazione completa di basi di dati.

---

## LLM nell'istruzione informatica e tutoraggio dialogico {#sec-llm-istruzione}

### Opportunità e rischi dell'uso generativo {#sec-cognitive-offloading}

Gli studi sull'IA generativa nell'istruzione alla programmazione discutono opportunità e criticità degli strumenti capaci di produrre direttamente codice o risposte [@becker2023programming; @denny2024computing; @prather2023robots]. Il possibile effetto sull'apprendimento dipende dal compito, dal livello dello studente, dal tipo di assistenza e da come viene organizzata l'attività; non è corretto assumere un effetto uniforme in tutti i contesti.

Quando un sistema fornisce direttamente una soluzione completa, esiste il rischio che lo studente accetti il risultato senza saperlo spiegare, verificare o trasferire a un problema diverso. Per Socratic-DB questo è un rischio progettuale da affrontare, non un effetto dato per dimostrato. Per valutarlo si propone di osservare non solo il prodotto finale, ma anche le motivazioni espresse, le revisioni effettuate e la capacità di affrontare una traccia nuova senza assistenza. La prova di trasferimento e il protocollo di sperimentazione sono descritti nel @sec-disegno-ricerca.

### Tutoraggio dialogico, scaffolding e limiti degli LLM {#sec-scaffolding-socratico}

Bloom discute la differenza tra tutoraggio individuale e istruzione di gruppo e il problema di trasferire i benefici del primo a contesti più ampi [@bloom1984two]. Vygotskij costituisce un riferimento teorico per il ruolo dell'interazione e della mediazione nell'apprendimento e per il concetto di Zona di Sviluppo Prossimale [@vygotsky1978mind]. Questi riferimenti forniscono un quadro pedagogico generale; non dimostrano direttamente che un LLM che pone domande socratiche produca gli stessi effetti di un tutor umano, né che il dialogo, da solo, garantisca l'apprendimento.

Macina et al. studiano opportunità e limiti dei tutor dialogici neurali in compiti di apprendimento linguistico. Gli autori rilevano che le prestazioni sono migliori in scenari didattici vincolati e più deboli in scenari meno circoscritti, e riportano errori di ragionamento in una quota significativa delle conversazioni valutate [@macina2023opportunities]. Il risultato è rilevante come avvertimento metodologico: un LLM non deve essere considerato un tutor affidabile soltanto perché produce un dialogo plausibile. Il dominio studiato non coincide con la progettazione di basi di dati, quindi le conclusioni non vanno trasferite direttamente a Socratic-DB.

Socratic-DB traduce questi riferimenti in ipotesi di progetto: chiedere allo studente di esplicitare il ragionamento, formulare domande circoscritte, proporre controesempi e graduare il livello di aiuto, evitando per quanto possibile di fornire subito una soluzione completa. Queste regole devono essere valutate separatamente dalla correttezza tecnica: il tutor può non rispettare il comportamento atteso o formulare una diagnosi errata, e la presenza di un prompt non garantisce da sola la conformità. La fedeltà del dialogo, la qualità delle spiegazioni e l'effetto sugli apprendimenti sono pertanto oggetti di verifica distinti.

---

## Architettura ibrida: controlli formali, esecuzione e dialogo {#sec-approccio-neuro-simbolico}

Socratic-DB propone un'architettura ibrida in cui il modello linguistico non è l'unica fonte di giudizio tecnico. I controlli deterministici sono usati solo per proprietà che siano state definite formalmente e implementate; l'esecuzione SQL permette di osservare il comportamento su un insieme di dati specifico; l'LLM sostiene il dialogo e il docente mantiene la responsabilità delle decisioni non automatizzabili. In questo testo, «ibrida» descrive la ripartizione progettuale dei compiti e non implica una garanzia generale di correttezza.

| Limite da considerare | Conseguenza per l'attività | Scelta progettuale di Socratic-DB |
| --- | --- | --- |
| **Risposte linguistiche non affidabili** | Un LLM può formulare affermazioni errate o non coerenti con la diagnosi tecnica. | Separare le diagnosi prodotte dai controlli formalizzati dal testo generato dal tutor; sottoporre a verifica le risposte del tutor. |
| **Verifica limitata al comportamento osservato** | Una query può produrre il risultato atteso sui dati di prova e fallire su altri dati o requisiti. | Eseguire query su dati di test progettati per coprire casi significativi e dichiarare esplicitamente l'ambito della verifica. |
| **Comportamento dialogico non garantito** | Il modello può fornire la soluzione troppo presto, essere incoerente o assecondare un'affermazione scorretta. | Definire livelli di aiuto e regole per il tutor, registrare le interazioni e valutare la conformità su casi di prova. |
| **Controlli incompleti o troppo rigidi** | Proprietà non formalizzate possono sfuggire; controlli eccessivamente restrittivi possono respingere soluzioni valide. | Documentare l'ambito di ogni controllo, testare soluzioni alternative e prevedere la revisione del docente. |
| **Separazione tra prodotto e apprendimento** | Una soluzione corretta non prova che lo studente sappia giustificarla o riprodurla autonomamente. | Valutare separatamente il prodotto, il processo di revisione e il trasferimento senza tutor. |

La tabella descrive rischi da gestire e decisioni proposte, non risultati sperimentali già ottenuti. In particolare, l'esecuzione in SQLite può verificare che una query sia eseguibile e osservare il suo risultato su dati specifici, ma non dimostra da sola la correttezza rispetto a ogni interpretazione della traccia. Analogamente, i controlli sullo schema possono verificare solo le proprietà coperte dalla loro implementazione e non sostituiscono la revisione semantica del dominio.

---

## Contributo della proposta e questioni aperte {#sec-contributo-questioni-aperte}

Sulla base dei sistemi e dei filoni esaminati, il contributo progettuale che Socratic-DB intende esplorare è l'integrazione, in un unico percorso didattico, di:

- analisi dei requisiti e modellazione concettuale;
- traduzione nello schema relazionale e considerazione dei vincoli;
- generazione o verifica dell'implementazione e dei dati di prova;
- scrittura, esecuzione e revisione di query SQL;
- dialogo guidato da domande, motivazioni e controesempi;
- controlli deterministici per le sole proprietà formalizzate;
- valutazione dell'apprendimento separata dalla valutazione automatica del prodotto.

Non si sostiene che ciascuna componente sia nuova in assoluto. Il valore distintivo da verificare è la loro integrazione nel percorso completo, con una separazione esplicita tra controllo formale, mediazione linguistica e giudizio del docente. Rispetto ai sistemi centrati sulla query, Socratic-DB intende includere anche le fasi precedenti di analisi e progettazione; rispetto agli strumenti di generazione di esercizi, si concentra sul dialogo relativo al tentativo dello studente; rispetto a un LLM usato senza controlli esterni, prevede verifiche formalizzate ed esecuzione SQL; rispetto a un sistema interamente deterministico, usa un modello linguistico per interagire in linguaggio naturale. Queste differenze descrivono l'obiettivo architetturale e didattico, non una superiorità empiricamente dimostrata.

La sperimentazione dovrà distinguere almeno quattro aspetti:

- **Affidabilità tecnica:** quali errori rilevano i controlli, quali soluzioni alternative accettano e quali falsi positivi o negativi producono?
- **Fedeltà del tutor:** il modello rispetta i livelli di aiuto, pone domande pertinenti e non introduce diagnosi errate o soluzioni premature?
- **Apprendimento e trasferimento:** gli studenti migliorano nella progettazione autonoma e riescono a lavorare su una traccia nuova senza tutor?
- **Fattibilità:** i tempi, il carico di revisione per il docente e l'usabilità sono sostenibili nel contesto didattico previsto?

Queste domande richiedono evidenze diverse: un insieme di casi attesi e test negativi per i controlli; revisione umana delle risposte del tutor; prove iniziali e finali, possibilmente accompagnate da una prova di trasferimento; osservazioni di fattibilità. Un miglioramento osservato in un singolo pilota, soprattutto in assenza di un confronto adeguato, non basta a dimostrare che l'effetto sia causato dal tutor. Il protocollo è descritto nel @sec-protocollo-sperimentazione.

---

## Quadro normativo e protezione dei dati {#sec-quadro-normativo-scuola}

L'uso di strumenti di IA in contesti scolastici richiede una valutazione del trattamento dei dati personali e delle finalità effettive del sistema. Il GDPR stabilisce principi e obblighi relativi, tra l'altro, a liceità, limitazione delle finalità, minimizzazione, esattezza, conservazione e sicurezza dei dati [@gdpr2016]. Non è corretto ricavare dal Regolamento un divieto generale di usare qualsiasi fornitore cloud: la liceità e le condizioni del trattamento dipendono dal caso concreto, dalla base giuridica, dai ruoli dei soggetti, dagli accordi applicabili, dalle misure di sicurezza e, quando pertinente, dalle regole sui trasferimenti di dati.

L'articolo 22 del GDPR riguarda determinate decisioni basate unicamente su trattamenti automatizzati che producano effetti giuridici o incidano in modo analogamente significativo sull'interessato, nei limiti e con le eccezioni previste dal Regolamento. Non è quindi corretto descriverlo come un divieto assoluto di ogni decisione automatizzata, né come un generico diritto alla spiegabilità applicabile indistintamente a ogni output di un LLM. In Socratic-DB, la scelta progettuale è che il sistema non assegni voti né sostituisca il docente nelle decisioni valutative; ciò va tradotto in procedure operative coerenti con il contesto istituzionale.

Il Regolamento europeo sull'Intelligenza Artificiale (AI Act) include nell'Allegato III, punto 3, determinate categorie di sistemi destinati all'istruzione e alla formazione professionale, tra cui alcuni sistemi destinati a valutare i risultati dell'apprendimento o a orientare il processo di apprendimento. La classificazione dipende dalla finalità prevista e dall'uso concreto del sistema; non è possibile stabilirla soltanto sulla base del nome del progetto o dell'affermazione che non assegna voti. La qualificazione applicabile a Socratic-DB dovrà essere verificata alla luce del testo normativo e delle disposizioni pertinenti con i referenti istituzionali competenti [@eu_ai_act_2024].

L'esecuzione on-premise, se adottata, può ridurre il trasferimento di dati a servizi esterni, ma non costituisce da sola una garanzia assoluta di conformità o riservatezza. Occorre considerare configurazione di rete, autenticazione, autorizzazioni, log, conservazione dei dati, aggiornamenti e procedure di gestione degli incidenti. La minimizzazione dei dati raccolti e l'uso di identificativi non direttamente riconducibili agli studenti, quando appropriato, sono misure da valutare nel quadro complessivo del trattamento, non sostituti degli altri obblighi applicabili.

---

## Sintesi del posizionamento

La letteratura presa in esame offre riferimenti per il feedback basato su vincoli, l'analisi degli errori SQL, la spiegazione dei modelli mentali dei sistemi di dati e l'impiego di LLM nell'istruzione informatica. Non fornisce, nel suo insieme, una prova diretta dell'efficacia di Socratic-DB: i lavori citati riguardano sistemi, compiti e contesti differenti.

La differenza che la proposta intende mettere alla prova è l'integrazione di un percorso che attraversa le principali fasi della progettazione di basi di dati con un tutor dialogico, controlli deterministici circoscritti e un'esecuzione SQL reale, mantenendo espliciti i limiti di ciascun componente e la responsabilità del docente. L'eventuale valore aggiunto dovrà essere stabilito empiricamente rispetto a criteri dichiarati: affidabilità tecnica, qualità del dialogo, apprendimento autonomo, trasferimento e fattibilità didattica.
