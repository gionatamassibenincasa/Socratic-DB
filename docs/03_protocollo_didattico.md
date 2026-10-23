# Protocollo didattico {#sec-protocollo-didattico}

## Il percorso: nove fasi in cinque consegne {#sec-percorso-consegne}

Il percorso ha **nove fasi** di verifica, raggruppate in **cinque consegne** per contenere il carico di consegna e di tracciamento. Le prime quattro consegne si svolgono con il tutor; la quinta è individuale e senza tutor. Ogni consegna mantiene file e criteri distinti per ciascuna fase che contiene, così lo stato di padronanza resta per competenza. Il percorso distingue progettazione concettuale e logica, chiarisce i vincoli e introduce verifiche effettive dell'esecuzione SQL.

| Consegna | Fasi | Contenuto | Automazione |
| --- | --- | --- | --- |
| C1. Requisiti e glossario | 1–2 | File di requisiti e glossario | Controllo deterministico di copertura rispetto alla checklist validata dal docente (termini e sinonimi attesi, definizioni non circolari); il tutor pone le domande |
| C2. Progettazione concettuale | 3–4 | Modello ER e vincoli del dominio, in sezioni distinte (ogni vincolo con tipo e formulazione) | Validatore e test di scenario; il tutor conduce l'elicitazione dei vincoli |
| C3. Progettazione logica e normalizzazione | 5 | Modello relazionale e meccanismo previsto per ciascun vincolo | Calcolo deterministico delle forme normali; il tutor discute le ridondanze |
| C4. Implementazione e interrogazione SQL | 6–8 | DDL, dati, query | Ambiente SQLite isolato con esecuzione immediata e diagnosi; i tre punti di verifica restano distinti |
| C5. Prova di trasferimento | 9 | Traccia nuova | Nessuna: prova individuale in aula, valutata dal docente |

I criteri di ciascuna fase sono i seguenti:

| # | Fase | Attività dello studente | Criteri verificabili (esempi) | Controllo |
| --- | --- | --- | --- | --- |
| 1 | Requisiti | Elenca dati da memorizzare, operazioni richieste, vincoli espliciti e impliciti, ambiguità da chiarire | Copertura delle voci della checklist; vincoli impliciti individuati; ambiguità motivate | Checklist validata dal docente; domande del tutor |
| 2 | Nomi-verbi e glossario | Estrae concetti candidati e li definisce senza assumere che ogni nome sia entità e ogni verbo associazione | Ogni voce ha definizione non circolare; sinonimi/omonimi dichiarati; motivazione della classificazione | Controllo di presenza e di circolarità semplice; tutor sul resto |
| 3 | Modello concettuale ER | Entità, attributi, associazioni, cardinalità min/max, identificatori | Schema valido nel formato; ogni entità ha identificatore; ogni elemento tracciabile a un requisito; cardinalità motivate | Validatore (struttura); domande e controesempi del tutor sulle cardinalità, non vincolanti |
| 4 | Vincoli del dominio | Classifica i vincoli: rappresentati nello schema, CHECK/UNIQUE, inter-relazione o temporali (trigger/applicativo) | Ogni vincolo ha tipo, formulazione non ambigua e meccanismo previsto; i temporali definiscono intervallo, sovrapposizione e concorrenza | Checklist; tutor conduce l'elicitazione |
| 5 | Modello relazionale | Applica le regole di traduzione; PK, FK, nullabilità, N:M, gerarchie, 1:1; dipendenze funzionali | Nessuna FK orfana; PK in ogni tabella; N:M risolte; nulli coerenti con le partecipazioni minime; 1NF/2NF/3NF verificate sulle dipendenze dichiarate | Validatore + calcolo deterministico delle forme normali |
| 6 | Implementazione SQL (DDL) | Scrive il DDL SQLite con tipi e vincoli. Se il docente abilita la traduzione automatica, il DDL è generato deterministicamente dal modello relazionale consegnato e lo studente lo analizza e lo commenta | DDL eseguibile; struttura (`PRAGMA table_info`, `foreign_key_list`) coerente con lo schema relazionale; violazioni attese, derivate dallo schema, rifiutate | Esecuzione reale + test negativi derivati dallo schema |
| 7 | Popolamento e test | Scrive INSERT significativi: casi limite, nulli, assenze di corrispondenza. Se il docente abilita la generazione automatica, la LLM propone i dati di test coerenti con lo schema dello studente, che li verifica e li integra con casi propri | Dati accettati dal DDL; copertura strutturale derivata dallo schema (righe minime per tabella, genitori senza figli, nulli nelle colonne nullabili, valori ripetuti); casi invalidi derivati dallo schema rifiutati | Esecuzione reale + controlli di copertura derivati dallo schema |
| 8 | Query e verifica | Scrive, esegue e motiva le query; esamina il risultato ottenuto sui dati di test | Query eseguibile; risultato esaminato e discusso; motivazione della scelta di JOIN/aggregazione; con schema canonico, risultato uguale all'atteso | Esecuzione reale + parere non vincolante del tutor sul risultato; confronto con le query attese solo con schema canonico |
| 9 | Prova di trasferimento | Affronta una traccia nuova, individualmente e senza tutor | Rubrica del docente per O1–O7 | Docente |

### Sulla generazione automatica
Per impostazione predefinita lo studente scrive DDL e INSERT: sono competenze da acquisire (O5, O6). Il docente può abilitare, per singolo esercizio, due scorciatoie:

- **DDL (fase 6):** generato da un *generatore deterministico* (non dalla LLM) a partire dallo schema relazionale, solo dopo che lo schema ha superato le verifiche indipendenti; la struttura ottenuta è poi confrontata con lo schema.
- **Dati di test (fase 7):** la LLM propone le istruzioni INSERT per lo schema dello studente (valori plausibili, senza dati personali reali). Lo script è accettato solo se supera una *verifica deterministica* derivata dallo schema: esecuzione senza errori sul DDL dello studente con chiavi esterne attive, copertura strutturale (righe minime per tabella, genitori senza figli, nulli, valori ripetuti), rifiuto dei casi invalidi. Se la verifica fallisce lo script non è consegnato: si rigenera (fino a un numero massimo di tentativi) oppure si segnala al docente.

Quando una scorciatoia è attiva, la competenza corrispondente non è esercitata in quella consegna e va verificata nella fase 9.

## Errori oggettivi e decisioni progettuali {#sec-errori-decisioni}

Il sistema distingue due classi di rilievi, con trattamento diverso:

- **Errori oggettivamente verificabili** nei file dello studente: formato non valido, FK verso tabella inesistente, tabella senza PK, N:M non risolta, DDL non eseguibile, violazione di un vincolo dichiarato dallo studente nel proprio schema, query non eseguibile, dipendenza funzionale dichiarata che viola la 3NF. Il tutor li segnala con certezza e li guida a correggerli.
- **Decisioni progettuali con più soluzioni corrette:** attributo o entità, strategia di traduzione di una gerarchia, accorpamento o tabella separata per una 1:1, uso di chiave surrogata. Il tutor non dichiara errore; chiede di motivare, mostra le conseguenze con un controesempio e accetta ogni soluzione coerente con i requisiti.
- **Correttezza semantica rispetto alla traccia** (cardinalità, entità, risultato delle query): non è verificata in modo deterministico, salvo l'uso opzionale di uno schema canonico con query attese. Il tutor formula un parere non vincolante, con domande e controesempi; l'accertamento finale spetta alla prova di trasferimento e al docente.

## Livelli di aiuto progressivi {#sec-livelli-aiuto}

| Livello | Forma dell'aiuto | Quando |
| --- | --- | --- |
| L0 | Solo esito dei controlli: area interessata e numero di problemi, senza dettagli | Primo tentativo |
| L1 | Domanda mirata sul problema specifico | Dopo L0 se il problema persiste |
| L2 | Controesempio dal dominio (dati concreti che violano l'intento) | Dopo L1 non risolutivo |
| L3 | Spiegazione del principio applicabile (non della soluzione) | Dopo L2 o su richiesta |
| L4 | Esempio svolto parziale su un caso analogo di altro dominio, seguito da un nuovo esercizio autonomo | Dopo L3 o su richiesta motivata |

Regole: l'aiuto sale di un livello alla volta; lo studente può chiedere un livello superiore (la richiesta è registrata, senza penalità); il docente può fissare per esercizio il livello massimo; la soluzione completa non è mai fornita.

## Ciclo di revisione {#sec-ciclo-revisione}

1. Lo studente propone una soluzione e ne spiega il motivo (campo `motivazione`).
2. I controlli deterministici producono le diagnosi; il tutor ne seleziona *una* e pone una domanda mirata.
3. Lo studente rivede la soluzione e giustifica la modifica nel messaggio di commit.
4. Il sistema riesegue i controlli sulla proprietà interessata, con criteri espliciti.
5. Se serve, il tutor passa al livello successivo; al livello L4 propone un esempio parziale e un nuovo esercizio autonomo.

## Padronanza per competenza {#sec-padronanza}

Per ogni competenza (O1–O7) il sistema mostra, non un punteggio, ma lo stato di una checklist di criteri verificabili, con tre stati descrittivi:

- **Da lavorare:** uno o più criteri oggettivi non soddisfatti.
- **In sviluppo:** criteri oggettivi soddisfatti solo con aiuto di livello ≥ L3.
- **Acquisito sotto guida:** criteri soddisfatti con aiuto ≤ L2 e motivazioni presenti.

Questi stati sono *indicatori di processo per lo studente e per il docente*, non voti. L'acquisizione effettiva è accertata solo dalla fase 9. L'avanzamento è libero: il tutor può consigliare di tornare su un punto aperto, ma l'unico blocco è tecnico (non si può scrivere il DDL senza uno schema relazionale analizzabile sul piano sintattico dal parser e verificabile sul piano semantico dal validatore).

## Precisazioni tecniche incorporate {#sec-precisazioni-tecniche}

- **Nomi e verbi:** euristica, non algoritmo. La classificazione dipende dal significato nel dominio; il tutor non la «corregge», chiede di motivarla.
- **Gerarchie:** l'eliminazione non è regola universale; si valutano accorpamento nella superclasse, nelle sottoclassi o tabelle separate, in base a copertura, disgiunzione e accessi.
- **Relazioni 1:1:** non si accorpano sempre. Si considerano partecipazione obbligatoria, nullabilità, UNIQUE sulla FK e dipendenze.
- **Normalizzazione:** 1NF, 2NF, 3NF sempre; BCNF solo se giustificata dalla traccia. La 4NF non è richiesta salvo previsione curricolare.
- **Valori nulli:** trattati già nella modellazione (partecipazione minima 0 o 1, attributi opzionali), poi tradotti in NOT NULL o in attributi nullabili.
- **Vincoli temporali:** es. «un medico non può visitare due pazienti nella stessa ora» richiede di definire intervallo (inizio/fine, aperto/chiuso), sovrapposizione e concorrenza. Un CHECK SQLite non può verificare vincoli su più righe: servono UNIQUE su slot discreti, trigger o controllo applicativo, e il test deve verificarlo.

## Metriche separate {#sec-metriche-separate}

1. **Qualità del modello** (calcolata dai controlli): completezza rispetto ai requisiti del docente, correttezza dei controlli oggettivi, minimalità (elementi non tracciabili), pertinenza, forme normali raggiunte.
2. **Qualità della spiegazione** (letta dal docente su campione, con rubrica a 3 livelli): la motivazione cita requisiti, conseguenze, alternative scartate.
3. **Padronanza dello studente:** prova di trasferimento e capacità di revisione (dai commit).

Le tre misure non sono sommate in un punteggio unico.

## Sostenibilità per il docente {#sec-sostenibilita-docente}

Il carico di lavoro è un vincolo di progetto: un protocollo che richiede ore di preparazione per ogni traccia non è applicabile in classi numerose e con tempi stretti. L'automazione riduce solo la preparazione e la lettura; la valutazione resta esclusivamente umana.

### Pacchetto minimo e pacchetto esteso
Il materiale richiesto al docente è ridotto all'essenziale; il resto si deriva dai file dello studente.

| Elemento | Pacchetto minimo (predefinito) | Pacchetto esteso (opzionale) |
| --- | --- | --- |
| Traccia | Sì | Sì |
| Checklist dei requisiti (5–10 voci), proposta dallo strumento d'autore e validata | Sì | Sì |
| Test negativi e copertura dei dati | Derivati dallo schema dello studente | Derivati dallo schema dello studente |
| Risultato delle query (fase 8) | Parere non vincolante del tutor su dati di test dello studente o proposti dalla LLM | Schema canonico, dataset e query attese: controllo deterministico dei risultati, riusabile dal catalogo |
| Soluzioni alternative e scenari di test | No | Solo nel golden set di ricerca |

### Strumento d'autore (AI dietro le quinte)
Il docente inserisce la traccia, senza soluzione. Lo strumento propone la checklist dei requisiti e, per il pacchetto esteso, schema canonico, dataset e query attese. Controlli deterministici ne verificano la coerenza interna. Il docente valida o affina il pacchetto, che viene poi congelato e versionato. Il materiale generato da una LLM non è affidabile per sé: la validazione umana è obbligatoria.

### Catalogo di schemi-tipo
Domini ricorrenti (prenotazioni e ticketing, e-commerce, gestione ospedaliera, biblioteca e prestiti) con checklist, errori tipici e, per alcuni domini, schema canonico con dataset e query attese già pronti. Il docente sceglie il modello e lo adatta alla traccia.

### Tracce iniziali
Le prove degli Esami di Stato sono una fonte primaria di tracce. Prima dell'uso, verificare note legali e licenza del sito del Ministero. I PDF riportati sono stati verificati il 22 ottobre 2026.

| Indirizzo | Anno | Sessione | Codice | Disciplina | Traccia / dominio nel PDF | PDF e fonte |
| --- | --- | --- | --- | --- | --- | --- |
| ITC – Programmatori | 2005 | Ordinaria | M733 | Informatica Generale ed Applicazioni Gestionali | Gestione corsi e iscrizioni di una palestra | [PDF locale](fonti/prove-di-esempio/2005_M733_ITC_ordinaria_palestra.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2005/tecnica/M733.pdf) |
| ITC – Programmatori | 2007 | Ordinaria | M733 | Informatica Generale ed Applicazioni Gestionali | Studio medico associato: medici, visite, pazienti e prestazioni | [PDF locale](fonti/prove-di-esempio/2007_M733_ITC_ordinaria_studio-medico.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2007/M733.PDF) |
| ITC – Programmatori | 2009 | Ordinaria | M733 | Informatica Generale ed Applicazioni Gestionali | Casa editrice di riviste specialistiche, abbonati e punti vendita | [PDF locale](fonti/prove-di-esempio/2009_M733_ITC_ordinaria_riviste.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2009/M733.pdf) |
| ITC – Programmatori | 2011 | Ordinaria | M733 | Informatica Generale ed Applicazioni Gestionali | Agenzia immobiliare e affitti brevi con prenotazioni online | [PDF locale](fonti/prove-di-esempio/2011_M733_ITC_ordinaria_affitti-brevi.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2011/M733.pdf) |
| ITC – Programmatori | 2013 | Ordinaria | M733 | Informatica Generale ed Applicazioni Gestionali | Biglietteria online per un museo e le sue esposizioni | [PDF locale](fonti/prove-di-esempio/2013_M733_ITC_ordinaria_biglietteria-museo.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2013/allegati/M733.pdf) |
| ITIA – Informatica | 2015 | Simulazione / esempio | M963* | Informatica | Consorzio caseario: produzione, vendite e caseifici | [PDF locale](fonti/prove-di-esempio/2015_M963_simulazione_consorzio-caseario.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Esempio%20di%20prova/M963_SIM.pdf) |
| ITIA – Informatica | 2015 | Ordinaria | M963 | Informatica | Web community per condividere e commentare eventi dal vivo | [PDF locale](fonti/prove-di-esempio/2015_M963_ordinaria_web-community-eventi.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Ordinaria/M963_ORD.pdf) |
| ITIA – Informatica | 2015 | Suppletiva | M963 | Informatica | Rete di centri e prestito di risorse multimediali | [PDF locale](fonti/prove-di-esempio/2015_M963_suppletiva_prestito-risorse-multimediali.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Suppletiva/M963_SUP.pdf) |
| ITSI – Sistemi Informativi Aziendali | 2016 | Esempio di prova | M967 | Informatica | Azienda di abbigliamento e tracciamento dei capi nei punti vendita | [PDF locale](fonti/prove-di-esempio/2016_M967_esempio_ITSI_tracciabilita-abbigliamento.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Esempio%20di%20prova/M967_SIM16.pdf) |
| ITIA – Informatica | 2017 | Ordinaria | I044 | Informatica | Piattaforma web di car pooling | [PDF locale](fonti/prove-di-esempio/2017_I044_ordinaria_carpooling.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Ordinaria/I044_ORD17.pdf) |
| ITIA – Informatica | 2017 | Suppletiva | I044 | Informatica | Applicazione web per la gestione delle assenze scolastiche | [PDF locale](fonti/prove-di-esempio/2017_I044_suppletiva_assenze-scolastiche.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Suppletiva/I044_SUP17.pdf) |
| ITIA – Informatica | 2017 | Straordinaria | I044 | Informatica | Piattaforma per candidature a una manifestazione culturale | [PDF locale](fonti/prove-di-esempio/2017_I044_straordinaria_manifestazione-culturale.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Straordinaria/I044_STR17.pdf) |
| ITIA – Informatica | 2019 | Ordinaria | — | Informatica e Sistemi e Reti | Servizio multimediale per punti di interesse turistici | [PDF locale](fonti/prove-di-esempio/2019_ITIA_ordinaria_POI-turistici.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Ordinaria/AB42_ORD19.pdf) |
| ITIA – Informatica | 2019 | Suppletiva | — | Informatica e Sistemi e Reti | Azienda di assistenza hardware/software e consulenza informatica | [PDF locale](fonti/prove-di-esempio/2019_ITIA_suppletiva_assistenza-informatica.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Suppletiva/AB42_SUP19.pdf) |
| ITIA – Informatica | 2019 | Straordinaria | — | Informatica e Sistemi e Reti | Sistema ospedaliero per la gestione delle terapie dei pazienti | [PDF locale](fonti/prove-di-esempio/2019_ITIA_straordinaria_terapie-ospedaliere.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Straordinaria/AB42_STR19.pdf) |
| ITIA – Informatica | 2023 | Ordinaria | A038 | Informatica | Piattaforma scolastica per educational games | [PDF locale](fonti/prove-di-esempio/2023_A038_ordinaria_giochi-educativi.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Ordinaria/A038_ORD23.pdf) |
| ITIA – Informatica | 2023 | Suppletiva | A038 | Informatica | Servizio di accesso a una rete di palestre per utenti in viaggio | [PDF locale](fonti/prove-di-esempio/2023_A038_suppletiva_rete-palestre.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Suppletiva/A038_SUP23.pdf) |

Nel PDF di simulazione ministeriale del 2015 il codice M963 compare nel nome del file, non nel testo della prova (*). Nei PDF del 2019 non è riportato un codice nel frontespizio; per questo non ne è indicato uno. Le voci i cui URL ministeriali restituivano un errore 404 sono state escluse finché non sarà disponibile una fonte funzionante.

Anche materiali editoriali e soluzioni possono essere utili per preparare esercizi e confrontare svolgimenti; quando una risorsa contiene la soluzione, non va confusa con una traccia inedita né usata come prova di trasferimento.

| Editore / Fonte | Anno | Contenuto | Risorsa |
| --- | --- | --- | --- |
| Zanichelli | 2019 | Prova ministeriale ordinaria e svolgimento Zanichelli: servizio multimediale per punti di interesse turistici | [Testo della prova](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/AB42_ORD19.pdf) · [Svolgimento locale](fonti/prove-di-esempio/Zanichelli_Esame_2019_svolgimento.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Esame_2019_svolgimento.pdf) |
| Zanichelli | 2017 | Svolgimento della prova ministeriale ordinaria sul car pooling | [PDF locale](fonti/prove-di-esempio/Zanichelli_Soluzione_Informatica_2017.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Soluzione_Informatica_2017.pdf) |
| Zanichelli | 2017 | Simulazione sul sistema di prenotazione di visite guidate: testo e svolgimento riservato ai docenti | [Testo](fonti/prove-di-esempio/Zanichelli_Simulazione_Informatica_Testo_2017.pdf) · [Svolgimento riservato](fonti/prove-di-esempio/Zanichelli_Simulazione_Informatica_Svolgimento_2017.pdf) |
| Zanichelli | 2016 | Simulazione di Informatica sulla gestione del traffico merci di un terminal marittimo: testo e svolgimento riservato ai docenti | [Testo](fonti/prove-di-esempio/Zanichelli_Informatica_Simulazione_dicembre2016.pdf) · [Svolgimento riservato](fonti/prove-di-esempio/Zanichelli_Informatica_Simulazione_Svolgimento_dicembre2016.pdf) |
| Zanichelli | 2015 | Prova ministeriale ordinaria sulla web community per eventi dal vivo, con svolgimento Zanichelli | [PDF locale](fonti/prove-di-esempio/2015_Zanichelli_Esame_Informatica.pdf) · [Ministero](https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Ordinaria/M963_ORD.pdf) |
| Zanichelli | 2015 | Simulazione sulla gestione di un consorzio caseario, con svolgimento | [PDF locale](fonti/prove-di-esempio/2015_Zanichelli_simulazione_consorzio-caseario_svolgimento.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici/wp-content/uploads/Zanichelli_Soluzione_Simulazione_2Prova_Informatica.pdf) |
| Zanichelli | 2013 | Traccia d'esame di Informatica ABACUS: controlli passeggeri e merci in aeroporto | [PDF locale](fonti/prove-di-esempio/2013_Zanichelli_Formichi_Tema_Esame_completa.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2013_completa.pdf) |
| Zanichelli | 2011 | Traccia d'esame di Informatica ABACUS: censimento di fauna e flora nei parchi naturali | [PDF locale](fonti/prove-di-esempio/2011_Zanichelli_Formichi_Tema_Esame.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2011.pdf) |
| Zanichelli | 2008 | Traccia d'esame di Informatica ABACUS: gestione delle Olimpiadi Internazionali di Informatica | [PDF locale](fonti/prove-di-esempio/2008_Zanichelli_Formichi_Tema_Esame.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2008.pdf) |
| Zanichelli | 2003 | Traccia d'esame di Informatica ABACUS: gestione delle attività di un vivaio | [PDF locale](fonti/prove-di-esempio/2003_Zanichelli_Formichi_Tema_Esame.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2003.pdf) |
| Zanichelli | 2002 | Traccia d'esame di Informatica ABACUS: gestione di una Banca del Tempo | [PDF locale](fonti/prove-di-esempio/2002_Zanichelli_Formichi_Tema_Esame.pdf) · [Zanichelli](https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2002.pdf) |
| Zanichelli | Archivio | Pagina Informatica con prove e svolgimenti; alcuni materiali sono riservati ai docenti | [Archivio prove](https://online.scuola.zanichelli.it/provatecnici/informatica/) |
| Hoepli | 2026 | Prove e proposte di simulazione per ITT Informatica e Sistemi e reti | [PDF ITT Informatica](https://www.hoeplieditore.it/storage/app/uploads/public/699/83a/8c2/69983a8c24f84650292718.pdf) · [Pagina dei materiali](https://www.hoeplieditore.it/scuola/notizia/didattica-digitale-integrata/materiali-la-prova-di-maturita) |
| Edizioni Atlas | 2026 | Guida alle prove della Maturità e indicazioni per consultare le tracce degli anni precedenti sul sito del Ministero | [Guida all'Esame di Maturità](https://www.edatlas.it/it/magazine/cosa-ce-di-nuovo/maturita-esame-2026) |

I materiali caricati e contrassegnati come copie riservate ai docenti sono destinati esclusivamente all'area ad accesso ristretto: non pubblicare questi file né l'output Quarto che li include su un sito accessibile senza autenticazione. Le pagine Hoepli e Atlas sono risorse informative, non prove editoriali autonome. Le vecchie pagine di Rizzoli Education, Mondadori Education, SEI ed Edizioni Atlas indicate in precedenza non identificavano materiali specifici accessibili o non sono più raggiungibili e non sono state ripristinate. La pagina attuale di Rizzoli reperita riguarda un webinar del 2025, non una traccia o un PDF di esercizi.

Per la fase 9 non si usano tracce pubbliche di cui circolano soluzioni online (e che una LLM può aver visto in addestramento): si adattano (dominio, requisiti, vincoli) o se ne scrivono di inedite.

### Report compatto
Per lo studente e per il docente: indicatori fattuali per fase (tentativi per tipo di diagnosi, livello di aiuto massimo richiesto), prodotti dai controlli deterministici e non da un giudizio della LLM. Esempio: «3 tentativi con diagnosi 3NF\_VIOLATA nella fase 5». Nessun punteggio e nessuna inferenza sulla competenza; il report non è utilizzabile a fini valutativi.

### Pre-screening delle motivazioni
Nel prototipo, regole deterministiche (lunghezza minima, assenza di riferimenti a elementi dello schema o ai requisiti, testo identico a quello di altri studenti) segnalano al docente i casi da leggere per primi. Il docente legge comunque un campione casuale, per non basarsi solo sulle segnalazioni. Un classificatore basato su modello è rinviato al sistema avanzato.

### Ipotesi di carico (da misurare nel pilota)

| Attività del docente | Ipotesi con strumento d'autore e catalogo | Misura nel pilota |
| --- | --- | --- |
| Preparazione di una traccia | Scelta o inserimento della traccia e validazione della checklist (pacchetto minimo): 20–30 minuti | Minuti di validazione per traccia |
| Lettura dei risultati | Report compatto, casi segnalati e un campione di motivazioni e dialoghi | Minuti per classe e per consegna |
| Riferimento: preparazione manuale senza strumento | 4–6 ore per traccia (stima del proponente) | Da rilevare su un campione di docenti |

La stima non è un risultato: tempi di preparazione e di revisione sono misure del pilota.
