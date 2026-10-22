**Sommario.**

Questo documento descrive una proposta di strumento e metodologia didattica basata sul metodo socratico, per aiutare gli studenti ad acquisire la capacità di progettare e implementare basi di dati relazionali, dall'analisi concettuale al modello logico. Il processo mira a condurre lo studente a produrre una base di dati completa, pertinente, minimale e intelligibile a partire da una descrizione testuale del problema. La costruzione della conoscenza procede come dialogo tra l'arte della domanda, affidata a modelli linguistici, e il rigore della struttura, verificato mediante controlli logico-simbolici. Le abilità modellistiche e di programmazione sono oggetto di esercizio e feedback durante il percorso; la sperimentazione valuterà l'efficacia della proposta sulla base delle interazioni con il sistema, raccolte e trattate in forma pseudonimizzata secondo le regole definite per lo studio e compatibili con il GDPR e l'IA Act.

# Introduzione

**Socratic-DB** è un ambiente di apprendimento assistito dall'Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado (ITE indirizzo *Sistemi Informativi Aziendali* e ITT indirizzo *Informatica*) e per corsi universitari introduttivi di basi di dati.

Il progetto nasce da un principio pedagogico ed epistemologico chiaro: **contrastare la delega cognitiva (*cognitive offloading*)** che sta avvenendo con l'uso acritico degli strumenti di *Generative Artificial Intelligence* (GenIA). In questa proposta, il sistema non chiede ai *Large Language Model* (LLM) di risolvere i problemi o scrivere codice al posto dello studente,  ma come li fa agire come **tutor socratici**:

1. **La mediazione maieutica è affidata all'LLM**: attraverso domande mirate, controesempi concreti ed elicitazione progressiva dei vincoli (livelli di aiuto graduati da L0 a L4), il tutor guida lo studente nell'individuare errori concettuali e nel motivare formalmente ogni scelta di modellizzazione.
2. **La verità tecnica risiede in controlli deterministici**: l'LLM non valuta la correttezza formale. La validazione sintattica, il calcolo della chiusura degli attributi, la verifica delle forme normali (2NF, 3NF, BCNF) e l'esecuzione di DDL e QL SQL sono affidati a un runtime deterministico e a un esecutore SQLite che opera in memoria.
3. **La valutazione resta prerogativa esclusiva del docente**: il sistema non assegna voti, non stila punteggi né profila gli studenti. La verifica dell'apprendimento effettivo avviene tramite prove individuali in presenza senza ausilio del tutor (*prova di trasferimento*).

## Piani di verifica della sperimentazione

La fattibilità e l'efficacia didattica della proposta sono da sperimentare su più piani (il dettaglio metodologico è approfondito nel documento di sperimentazione):

- **Piano del modello linguistico.** Non sappiamo se tra le proprietà emergenti dei LLM ci siano l'abilità maieutica e la capacità elicitativa che desideriamo otterere. *Verifica:* golden set di casi noti (@sec-test-tutor-llm; @sec-disegno-ricerca).
- **Piano dell'infrastruttura di calcolo deterministica.** Un sistema che esegua i controlli e i processi richiesti è complesso: fattibilità e scalabilità non sono stimabili a priori, in assenza di prove empiriche. *Verifica:* test dei controlli deterministici (@sec-test-controlli-deterministici) e studio pilota su classe di pochi studenti (@sec-disegno-ricerca).
- **Piano dell'efficacia didattica.** Non è possibile stabilirla a priori: servono test diagnostici pre e post sperimentazione per misurare l'incremento delle prestazioni. *Verifica:* pre-test, post-test e prova di trasferimento (@sec-disegno-ricerca), analisi dei log di risoluzione di casi da parte degli stessi studenti dopo due o più iterazioni (*follow up*).
- **Piano della progressione didattica.** Il metodo e le fasi appaiono ben definiti per granularità e misurabilità, ma ciò va validato sperimentalmente: la suddivisione attuale potrebbe produrre un lavoro ingestibile per il docente o per lo studente, oppure risultare inefficace o inefficiente. *Verifica:* osservazione nello studio pilota (@sec-disegno-ricerca) e analisi dei risultati (@sec-analisi-risultati), test con scala di Likert per docenti e studenti.
- **Piano della sostenibilità per il docente.** Il tempo di preparazione delle tracce e di revisione dei risultati deve essere compatibile con classi numerose e tempi stretti (@sec-sostenibilita-docente). *Verifica:* misura dei tempi nel pilota, test sull'accetazione del sistema con scala di Likert per docenti (@sec-raccolta-metriche).

---

## Struttura del documento

La documentazione del progetto è strutturata nei seguenti moduli tematici:

- [Stato dell'arte e inquadramento teorico](01_stato_dell_arte.md): Intelligent Tutoring Systems, Socratic prompting, neuro-simbolico e quadro di ricerca.
- [Quadro pedagogico](02_quadro_pedagogico.md): destinatari (ITE SIA, ITT Informatica, università), prerequisiti, obiettivi di apprendimento (O1–O8) e ruoli.
- [Protocollo didattico](03_protocollo_didattico.md): le nove fasi in cinque consegne, livelli di aiuto L0–L4, ciclo di revisione e sostenibilità docente.
- [Architettura del sistema](04_architettura_sistema.md): orchestratore a stati finiti (FSM), sandbox SQLite isolata, hardware GPU on-premise, system prompt e GitLab CI.
- [Specifiche dei formati e contratti dati](05_formati_e_schemi.md): specifiche YAML validato per modelli concettuali e relazionali, formati di consegna e report.
- [Quadro normativo, sicurezza e privacy](06_normativa_e_sicurezza.md): conformità GDPR, AI Act per sistemi scolastici, protezione da prompt injection e limiti noti.
- [Protocollo di sperimentazione](07_sperimentazione.md): disegno della ricerca, pre/post-test, pilota, metriche e criteri di successo.
- [Bibliografia](riferimenti.bib): riferimenti in formato BibTeX.
