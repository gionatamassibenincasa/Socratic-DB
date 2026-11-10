# Recensione della letteratura {#sec-stato-arte}

## Introduzione e contesto {#sec-introduzione-contesto}

L'introduzione dei modelli linguistici di grandi dimensioni (*Large Language Models*, LLM) nella didattica dell'informatica ha aperto nuove prospettive per la generazione di spiegazioni, l'esplorazione del codice e il feedback personalizzato. Tuttavia, l'adozione di tali strumenti solleva importanti questioni pedagogiche circa l'affidabilità delle risposte, il rischio di delega cognitiva da parte dello studente e l'effettiva tenuta dei processi di valutazione [@becker2023programming; @denny2024computing; @prather2023robots].

Nel contesto specifico dell'insegnamento delle basi di dati relazionali, la complessità dell'apprendimento non risiede soltanto nella sintassi delle query SQL, ma si estende all'intero ciclo di progettazione: dall'analisi dei requisiti alla modellazione concettuale ed evoluzione verso lo schema relazionale [@codd1970relational; @chen1976entity]. Un supporto didattico efficace deve pertanto combinare il rigore delle verifiche formali con una guida maieutica capace di stimolare il ragionamento autonomo anziché sostituirsi ad esso.

Per collocare teoricamente e metodologicamente la proposta progettuale di **Socratic-DB** — un'architettura ibrida che integra controlli deterministici, un tutor conversazionale guidato da LLM e la supervisione del docente —, questo capitolo organizza la letteratura di riferimento secondo una progressione logica articolata nelle seguenti sezioni:

1. **Quadri teorici su apprendimento, IA e psicologia cognitiva** (@sec-llm-istruzione): si esaminano le opportunità e le criticità dell'IA nella programmazione (@sec-opportunita-criticita-llm), il fenomeno del *cognitive offloading* e le dinamiche del carico cognitivo (@sec-cognitive-offloading), il tutoraggio dialogico fondato sulla Zona di Sviluppo Prossimale e sulla *self-explanation* (@sec-tutoraggio-zsp), l'*Assistance Dilemma* e il trattenimento dell'informazione (@sec-assistance-dilemma), e l'impatto sul carico cognitivo nell'interazione uomo-macchina (@sec-carico-cognitivo-hci).
2. **Sistemi di tutorato e didattica delle basi di dati** (@sec-its-database): si analizza lo stato dell'arte degli *Intelligent Tutoring Systems* (ITS) e del *Constraint-Based Modeling* (CBM) (@sec-its-cbm), la letteratura su errori, misconcezioni e modelli mentali in SQL (@sec-errori-misconcezioni-sql), e le esperienze di generazione di esercizi e analisi degli errori (@sec-generazione-esercizi-errori).
3. **Architettura di Socratic-DB e contributo progettuale** (@sec-approccio-neuro-simbolico e @sec-contributo-questioni-aperte): si definisce la struttura ibrida del sistema formalizzando la ripartizione dei compiti tra controlli deterministici, modello linguistico e docente, proponendo una matrice di mitigazione dei rischi tecnici e operativi e dettagliando le questioni aperte per la sperimentazione.
4. **Metodologia per la valutazione empirica** (@sec-metodi-valutazione): si delineano i principi metodologici per condurre sperimentazioni didattiche in contesti scolastici reali, approfondendo l'integrazione di metodi quantitativi e qualitativi (*mixed methods*) idonei anche per studi pilota condotti su piccoli campioni.
5. **Vincoli normativi e sintesi della letteratura** (@sec-quadro-normativo-scuola e @sec-sintesi-lacune): si richiama la cornice del GDPR e dell'AI Act per l'uso dell'IA nella scuola e si sintetizzano le lacune individuate nella letteratura corrente che motivano la sperimentazione di Socratic-DB.

---

## Quadri teorici: Apprendimento, IA e Psicologia Cognitiva {#sec-llm-istruzione}

### Opportunità e criticità nell'istruzione alla programmazione {#sec-opportunita-criticita-llm}

Gli studi sull'IA generativa nell'istruzione alla programmazione discutono opportunità e criticità degli strumenti capaci di produrre direttamente codice o risposte [@becker2023programming; @denny2024computing; @prather2023robots]. L'effetto sull'apprendimento dipende dal compito, dal livello dello studente, dal tipo di assistenza e dall'organizzazione dell'attività; non è corretto assumere un effetto uniforme.

Quando un sistema fornisce direttamente una soluzione completa, esiste il rischio che lo studente accetti il risultato senza saperlo spiegare, verificare o trasferire a un problema diverso. Per Socratic-DB questo è un rischio progettuale da affrontare, non un effetto già dimostrato. Per valutarlo si propone di osservare non solo il prodotto finale, ma anche le motivazioni espresse, le revisioni e la capacità di affrontare una traccia nuova senza assistenza (prova di trasferimento; vedi @sec-disegno-ricerca).

### Cognitive offloading e psicologia cognitiva {#sec-cognitive-offloading}

Il concetto di *cognitive offloading* descrive l'uso di risorse esterne per ridurre le richieste cognitive interne [@risko2016cognitive]. Uno studio classico di Sparrow, Liu e Wegner mostra che, quando le persone si aspettano di poter recuperare informazioni tramite un motore di ricerca, ricordano meno il contenuto e più *dove* trovarlo [@sparrow2011google]. La preoccupazione sulla delega cognitiva non è quindi astratta: con i motori di ricerca si è già osservata una riorganizzazione della memoria verso l'accesso esterno; con l'IA generativa il rischio si estende dal *ricordare* al *pensare* — o almeno allo sforzo di formalizzare in modo strutturato il proprio ragionamento (modellare, giustificare, verificare).

Nella letteratura recente sull'IA generativa si distingue tra offloading che *sostituisce* il pensiero dello studente e offloading che lo *sostanzia* come scaffolding, con effetti diversi su motivazione e apprendimento [@cash2026ai; @risko2016cognitive]. Il rischio educativo non è l'uso dello strumento in sé, ma la delega delle operazioni costitutive dell'obiettivo di apprendimento senza una successiva ricostruzione autonoma.

Per Socratic-DB la conseguenza progettuale è esplicita: i livelli di aiuto L0–L4 e il divieto di soluzione completa mirano a favorire un uso dello strumento come *scaffolding* e non come sostituto del ragionamento. La prova di trasferimento senza dispositivi misura se le competenze restano disponibili in assenza del tutor.

### Tutoraggio dialogico, Zona di Sviluppo Prossimale e self-explanation {#sec-tutoraggio-zsp}

Bloom discute la differenza tra tutoraggio individuale e istruzione di gruppo e il problema di trasferire i benefici del primo a contesti più ampi [@bloom1984two]. Vygotskij fornisce il riferimento teorico per l'interazione e la mediazione nell'apprendimento e per la Zona di Sviluppo Prossimale [@vygotsky1978mind]. Il concetto di *scaffolding* [@wood1976role] descrive il supporto temporaneo e calibrato che consente di operare entro tale zona. Questi riferimenti offrono un quadro pedagogico generale; non dimostrano che un LLM che pone domande socratiche produca gli stessi effetti di un tutor umano.

La letteratura sul *self-explanation* [@chi1989self] mostra che far esplicitare allo studente le proprie ragioni favorisce l'apprendimento profondo rispetto alla sola ricezione di spiegazioni. È coerente con la scelta di Socratic-DB di richiedere motivazioni scritte e di strutturare il dialogo intorno a domande e controesempi, piuttosto che intorno alla consegna della soluzione.

Macina et al. studiano opportunità e limiti dei tutor dialogici neurali in compiti di apprendimento linguistico: le prestazioni sono migliori in scenari vincolati e più deboli in scenari aperti, con errori di ragionamento in una quota significativa delle conversazioni valutate [@macina2023opportunities]. Il dominio non coincide con le basi di dati, ma il risultato vale come avvertimento metodologico: un LLM non è un tutor affidabile solo perché produce un dialogo plausibile.

Socratic-DB traduce questi riferimenti in ipotesi di progetto: esplicitare il ragionamento, formulare domande circoscritte, proporre controesempi, graduare il livello di aiuto. La fedeltà del dialogo, la qualità delle spiegazioni e l'effetto sugli apprendimenti sono oggetti di verifica distinti.

### Assistance dilemma: quando l'aiuto nuoce all'apprendimento {#sec-assistance-dilemma}

Koedinger e Aleven formulano l'*assistance dilemma*: quanto e quando fornire assistenza in un ambiente di apprendimento interattivo, e quando invece *trattenere* informazione perché lo studente elabori da sé la risposta [@koedinger2007assistance]. Troppo poco aiuto può generare frustrazione e stallo; troppo aiuto può impedire l'apprendimento perché il tutor svolge il lavoro cognitivo al posto dello studente. Il dilemma non è risolto una volta per tutte: dipende dal dominio, dal livello dello studente e dal momento dell'attività.

Per un tutor basato su LLM il rischio è asimmetrico. I modelli generativi tendono, per addestramento e per ottimizzazione alla «utilità» immediata, a *dare* la risposta completa piuttosto che a trattenerla. In questo senso l'aiuto in sé può essere deleterio nella formazione: se la soluzione arriva senza elaborazione, si indeboliscono proprio le competenze che si intendeva sviluppare. La progettazione di Socratic-DB assume quindi un vincolo esplicito: il tutor deve *impedire la delega cognitiva*, non massimizzare la velocità di completamento del compito. I livelli L0–L4 e il divieto di soluzione completa operano come politiche di *withholding* calibrato. Inoltre, quando lo studente è bloccato, il tutor non dovrebbe sostituirsi al materiale didattico formale: può rinviare a definizioni, esempi del libro di testo o della lezione, e chiedere di applicarli al caso in esame, piuttosto che produrre al posto dello studente lo schema o la query. In questo modo l'assistenza resta orientata allo studio strutturato e non alla sostituzione del pensiero.

### Carico cognitivo e interazione uomo–macchina {#sec-carico-cognitivo-hci}

La *Cognitive Load Theory* [@sweller1988cognitive; @sweller2011cognitive] distingue carico intrinseco, estrinseco e pertinente. Un tutor conversazionale può ridurre il carico estrinseco (orientamento, feedback tempestivo) oppure aumentarlo (dialoghi lunghi, ambigui o ridondanti). La progettazione dei livelli di aiuto e la brevità delle risposte del tutor mirano a contenere il carico estrinseco, lasciando spazio al carico pertinente (elaborazione delle scelte di modellazione).

Dal punto di vista dell'interazione uomo–macchina, l'uso di sistemi generativi in contesti formativi richiede interfacce e protocolli che rendano trasparente *quando* lo strumento interviene e *con quale tipo di aiuto*, per sostenere la metacognizione dello studente e la supervisione del docente. Questo aspetto è ancora poco trattato nella letteratura specifica sulle basi di dati e costituisce un'area di attenzione per la sperimentazione.

---

## Didattica delle basi di dati e sistemi di tutorato {#sec-its-database}

### Intelligent Tutoring Systems e Constraint-Based Modeling {#sec-its-cbm}

Gli *Intelligent Tutoring Systems* (ITS) costituiscono un precedente importante per il feedback automatizzato in domini tecnici. In particolare, SQL-Tutor di Mitrović illustra il *Constraint-Based Modeling* (CBM): il sistema confronta la soluzione dello studente con vincoli disciplinari espliciti e restituisce feedback sulle violazioni [@mitrovic1998sql; @mitrovic2003cbm]. Questo approccio offre un riferimento per rendere espliciti i criteri di controllo. Non implica, tuttavia, che ogni soluzione semanticamente valida possa essere riconosciuta automaticamente, né che lo stesso modello si trasferisca senza adattamenti a tutte le fasi della progettazione di una base di dati.

Socratic-DB condivide con gli approcci basati su vincoli l'idea di non affidare ogni giudizio tecnico alla sola generazione linguistica. La differenza proposta è l'ambito del percorso: oltre alla formulazione di query, si considerano analisi dei requisiti, modellazione concettuale, schema relazionale, implementazione e interrogazione. I controlli coprono solo proprietà formalizzate; la loro copertura effettiva va misurata. L'esecuzione su un database di prova fornisce evidenza circoscritta: una query corretta su un dataset può fallire su altri dati o non rispettare tutti i requisiti.

Una rassegna di riferimento sul tutoraggio è quella di VanLehn [@vanlehn2011relative], che confronta tutoraggio umano, *Intelligent Tutoring Systems* e altre forme di tutoraggio rispetto all'istruzione senza tutor. La rassegna stima un effetto medio del tutoraggio umano intorno a *d* ≈ 0,79 e un effetto degli ITS step-based intorno a *d* ≈ 0,76: valori inferiori al classico «effetto due sigma» attribuito al tutor umano individuale, ma comunque rilevanti. Il risultato fornisce un meta-contesto: un sistema di tutorato ben progettato può avvicinarsi all'efficacia del tutoraggio umano, senza però garantire, da solo, un miglioramento automatico in ogni dominio o con ogni interfaccia conversazionale generativa.

### Errori, misconcezioni e modelli mentali in SQL {#sec-errori-misconcezioni-sql}

La ricerca sull'apprendimento di SQL analizza difficoltà e misconcezioni dei principianti. Miedema e colleghi studiano il ragionamento attraverso protocolli *think-aloud* [@miedema2021misconceptions]; Taipalus e colleghi esaminano errori e complicazioni ricorrenti nella formulazione di query [@taipalus2018errors]. Il lavoro successivo di Miedema sulla formazione sui sistemi di dati offre contesto per scomporre concetti e difficoltà del dominio [@miedema2024learning]. Questi risultati motivano diagnosi più specifiche del solo messaggio d'errore del DBMS, ma non vanno trasferiti automaticamente alla modellazione concettuale o alla progettazione relazionale.

Ponzini, Guerrini e Catania propongono una revisione delle tassonomie degli errori SQL orientata alla rilevazione automatizzata [@ponzini2026taxonomy]. Una classificazione esplicita può rendere le diagnosi confrontabili; non garantisce, da sola, che una diagnosi distingua sempre un errore da una soluzione alternativa valida o che il feedback migliori l'apprendimento.

Miedema et al. discutono inoltre il concetto di *notional machine* per spiegare i sistemi di dati nell'insegnamento dell'informatica [@miedema2025notional]. L'apprendimento richiede di costruire e verificare un modello di ciò che query e schema rappresentano. In Socratic-DB una possibile traduzione progettuale consiste nel chiedere allo studente di prevedere il comportamento di una query o di motivare una scelta di schema, e poi confrontare la previsione con l'esecuzione o con un controesempio. L'utilità di questa sequenza resta un'ipotesi da verificare.

### Generazione di esercizi e uso didattico dell'analisi degli errori {#sec-generazione-esercizi-errori}

I lavori sulla generazione personalizzata di esercizi SQL con LLM e validazione basata su vincoli [@ponzini2026sql; @catania2026exercises] affrontano un problema vicino ma distinto dal tutoraggio dialogico: produrre esercizi e controllarne proprietà non equivale a guidare lo studente nella modellazione o nella giustificazione delle scelte. Un esempio di attività didattica correlata è il laboratorio di Guerrini e Ponzini sugli errori frequenti in SQL [@guerrini2026sqlerrors]. Si tratta di antecedenti utili; non costituiscono prova sperimentale dell'efficacia di un tutor LLM sul percorso completo di progettazione.

---

## Architettura ibrida e posizionamento di Socratic-DB {#sec-approccio-neuro-simbolico}

Socratic-DB propone un'architettura ibrida in cui il modello linguistico non è l'unica fonte di giudizio tecnico. I controlli deterministici operano su proprietà formalizzate; l'esecuzione SQL osserva il comportamento su dati specifici; l'LLM sostiene il dialogo; il docente mantiene le decisioni non automatizzabili. «Ibrida» descrive la ripartizione progettuale dei compiti, non una garanzia generale di correttezza.

**Socratic-DB** propone nello specifico un supporto alla progettazione e all'apprendimento delle basi di dati che combina tre componenti con responsabilità distinte:

1. **Controlli formalizzati**, per verificare proprietà esprimibili in modo deterministico (vincoli strutturali, alcune proprietà dello schema, risultati dell'esecuzione SQL).
2. **Tutor conversazionale basato su LLM**, per porre domande, richiedere motivazioni, proporre controesempi e graduare gli aiuti, senza assumere che il modello rispetti sempre tali vincoli.
3. **Docente**, cui restano il giudizio sulle interpretazioni del dominio, la revisione delle diagnosi non formalizzabili e le decisioni valutative.

| Limite | Conseguenza | Scelta progettuale |
| --- | --- | --- |
| Risposte linguistiche non affidabili | L'LLM può formulare affermazioni errate o incoerenti con la diagnosi tecnica | Separare le diagnosi dei controlli formalizzati dal testo del tutor; verificare le risposte del tutor |
| Verifica limitata al comportamento osservato | Una query può passare sui dati di prova e fallire altrove | Dati di test progettati per casi significativi; ambito della verifica dichiarato |
| Comportamento dialogico non garantito | Il modello può fornire la soluzione troppo presto o assecondare errori | Livelli di aiuto, registrazione delle interazioni, valutazione di conformità |
| Controlli incompleti o troppo rigidi | Proprietà non formalizzate sfuggono; soluzioni valide possono essere respinte | Documentare l'ambito di ogni controllo; revisione del docente |
| Separazione tra prodotto e apprendimento | Una soluzione corretta non prova comprensione o trasferimento | Valutare prodotto, processo e trasferimento senza tutor |

La tabella descrive rischi e decisioni proposte, non risultati sperimentali già ottenuti. I dettagli di implementazione sono nelle appendici tecniche.

### Contributo della proposta e questioni aperte {#sec-contributo-questioni-aperte}

Il contributo progettuale che Socratic-DB intende esplorare è l'integrazione, in un unico percorso didattico, di:

- analisi dei requisiti e modellazione concettuale;
- traduzione nello schema relazionale e considerazione dei vincoli;
- implementazione, dati di prova e interrogazione (nei percorsi tecnici);
- dialogo guidato da domande, motivazioni e controesempi;
- controlli deterministici per le sole proprietà formalizzate;
- valutazione dell'apprendimento separata dalla valutazione automatica del prodotto.

Non si sostiene che ciascuna componente sia nuova in assoluto. Il valore distintivo da verificare è l'integrazione, con separazione esplicita tra controllo formale, mediazione linguistica e giudizio del docente. Rispetto ai sistemi centrati sulla query, Socratic-DB include le fasi di analisi e progettazione; rispetto agli strumenti di generazione di esercizi, si concentra sul dialogo relativo al tentativo dello studente; rispetto a un LLM usato senza controlli, prevede verifiche formalizzate; rispetto a un sistema interamente deterministico, usa un modello linguistico per l'interazione in linguaggio naturale.

L'integrazione di questi componenti è una scelta progettuale, non una prova preventiva di efficacia. Le domande di ricerca riguardano l'affidabilità dei controlli, la fedeltà del tutor al comportamento atteso, l'apprendimento autonomo e il trasferimento a problemi nuovi. La sperimentazione dovrà distinguere almeno quattro aspetti:

- **Affidabilità tecnica:** cosa rilevano i controlli, quali falsi positivi o negativi producono.
- **Fedeltà del tutor:** rispetto dei livelli di aiuto, pertinenza delle domande, assenza di soluzioni premature.
- **Apprendimento e trasferimento:** miglioramento nella progettazione autonoma e prova su traccia nuova senza tutor.
- **Fattibilità:** tempi, carico di revisione per il docente, usabilità nel contesto scolastico previsto.

Queste domande richiedono evidenze diverse (casi di test, revisione umana delle risposte, pre/post-test e prova di trasferimento, osservazioni di fattibilità). Un miglioramento osservato in un singolo pilota, in assenza di un confronto adeguato, non basta a dimostrare un nesso causale con il tutor. Il protocollo dettagliato di verifica è descritto nel @sec-protocollo-sperimentazione.

---

## Metodi per valutare l'efficacia di una sperimentazione didattica {#sec-metodi-valutazione}

Anche quando i primi piloti coinvolgono pochi studenti, la sperimentazione può e deve essere condotta con metodo scientifico: le conclusioni, qualitative e quantitative, vanno ancorate a dati espliciti, a strumenti dichiarati e a limiti di generalizzazione chiari.

Nella ricerca educativa, Creswell offre un quadro consolidato per pianificare, condurre e valutare studi quantitativi, qualitativi e a metodi misti [@creswell2012educational]. Shadish, Cook e Campbell forniscono il riferimento classico sui disegni sperimentali e quasi-sperimentali e sulla validità delle inferenze causali in contesti non di laboratorio [@shadish2002experimental]. In assenza di randomizzazione completa — frequente nella scuola per vincoli etici e organizzativi — restano disponibili disegni intra-soggetto (pre-test / post-test / trasferimento), confronti descrittivi con classi parallele e analisi di processo, a patto di dichiarare cosa si può e non si può inferire.

Per i **studi pilota di fattibilità**, la letteratura sui *mixed methods* raccomanda di integrare deliberatamente dati quantitativi e qualitativi per esaminare accettabilità, fattibilità operativa e prime indicazioni di effetto, preparando eventuali sperimentazioni di scala maggiore [@aschbrenner2022mixed]. L'integrazione non è la somma di due report separati: richiede allineamento delle fonti, analisi congiunte e meta-inferenze su cosa il pilota autorizza a concludere.

Per Socratic-DB ciò si traduce in scelte già previste nel protocollo:

- **Quantitativo:** pre-test, post-test e prova di trasferimento con rubrica condivisa; indicatori di processo (livelli di aiuto, iterazioni); soglie sulla fuga della soluzione; stime di carico docente.
- **Qualitativo:** trascrizioni dei dialoghi, note di osservazione, questionari aperti di esperienza e gradimento, revisione in cieco tra docenti.
- **Integrazione:** confrontare esiti di prestazione con la tenuta maieutica del tutor e con la sostenibilità operativa; non presentare un miglioramento su un piccolo campione come prova causale definitiva, ma come evidenza situata e replicabile.

La popolazione ridotta del primo pilota (ad esempio cinque studenti) non autorizza generalizzazioni ampie; autorizza invece a misurare con rigore fattibilità, accettabilità e segnali di apprendimento, e a documentare in modo trasparente i dati su cui poggiano le conclusioni.

---

## Quadro normativo (rinvio) {#sec-quadro-normativo-scuola}

L'uso di strumenti di IA in contesti scolastici richiede la valutazione del trattamento dei dati personali e delle finalità del sistema, in coerenza con il GDPR [@gdpr2016] e con il regolamento europeo sull'IA [@eu_ai_act_2024]. In Socratic-DB la scelta progettuale è che il sistema non assegni voti né sostituisca il docente nelle decisioni valutative. L'approfondimento operativo (base giuridica, consenso, DPO, misure di sicurezza) è trattato nel capitolo sulla normativa e sicurezza.

---

## Sintesi delle aree ancora aperte nella letteratura {#sec-sintesi-lacune}

Rispetto al profilo di Socratic-DB, la letteratura consultata risulta:

- **solida** su ITS e CBM per SQL, su errori e misconcezioni SQL, su opportunità/rischi degli LLM nella programmazione introduttiva;
- **ancora limitata** su tutor socratici basati su LLM per la *progettazione completa* di basi di dati (dall'analisi dei requisiti allo schema e alle query);
- **poco collegata**, nel dominio delle basi di dati, alla letteratura di psicologia cognitiva su *cognitive offloading*, *self-explanation* e carico cognitivo, e agli studi HCI su trasparenza dell'aiuto e metacognizione.

Queste lacune motivano la sperimentazione empirica descritta nel protocollo e orientano le scelte di misura (processo, fuga della soluzione, trasferimento senza dispositivi).