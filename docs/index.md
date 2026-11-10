**Sommario.**

Questo documento descrive una proposta di strumento e metodologia didattica basata sul metodo socratico, per aiutare gli studenti ad acquisire la capacità di progettare e implementare basi di dati relazionali, dall’analisi concettuale al modello logico. Il processo mira a condurre lo studente a produrre una base di dati completa, pertinente, minimale e intelligibile a partire da una descrizione testuale del problema. La costruzione della conoscenza procede come dialogo tra l’arte della domanda, affidata a modelli linguistici, e il rigore della struttura, verificato (quando presente) mediante controlli logico-simbolici. Le abilità modellistiche e di programmazione sono oggetto di esercizio e feedback durante il percorso; la sperimentazione valuterà l’efficacia della proposta sulla base delle interazioni con il sistema, raccolte e trattate in forma pseudonimizzata secondo le regole definite e compatibili con il GDPR e l’AI Act.

# Introduzione

**Socratic-DB** è un ambiente di apprendimento assistito dall’Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado.

**Destinatari prioritari della sperimentazione presso l’Istituto proponente:**  
studenti dell’**Istituto Tecnico Economico**, indirizzo Amministrazione, Finanza e Marketing, articolazione **Sistemi Informativi Aziendali (SIA / ITSI)**.

Il percorso può essere adattato, limitando le fasi, anche a classi del Liceo Scientifico opzione Scienze Applicate (solo analisi e modellazione concettuale, senza SQL). Riferimenti ad altri indirizzi (es. ITIA) riguardano la **trasferibilità** dell’esperienza ad altri contesti scolastici e universitari, non la popolazione iniziale di questa sperimentazione.

Il progetto nasce da un principio pedagogico chiaro: **contrastare la delega cognitiva (*cognitive offloading*)** legata all’uso acritico degli strumenti di *Generative Artificial Intelligence*. In questa proposta i modelli linguistici agiscono come **tutor socratici**:

1. **Mediazione maieutica affidata all’LLM**: domande, controesempi, livelli di aiuto L0–L4.
2. **Verità tecnica**, quando formalizzabile, affidata a controlli deterministici (introdotti progressivamente).
3. **Valutazione** riservata al docente umano; verifica dell’apprendimento tramite **prova di trasferimento su carta**, senza dispositivi elettronici.

## Destinatari di questa documentazione

- Progettisti della sperimentazione
- Dirigente scolastico
- Docenti di Informatica coinvolti
- DPO
- Amministratori Google Workspace for Education
- Personale e referenti del progetto [Health School](https://formazione.centropapagiovanni.it/health-school/)
- Amministratori dell’infrastruttura informatica e dei servizi di rete

## Piani di verifica della sperimentazione

- **Modello linguistico:** tenuta maieutica e rispetto dei livelli L0–L4.
- **Infrastruttura:** progressione da zero-infrastructure (Gemini + Classroom) a soluzioni on-premise e, solo in seguito, a stack più completi.
- **Efficacia didattica:** pre-test, post-test, prova di trasferimento, questionari di esperienza e gradimento.
- **Sostenibilità e protocollo:** carico docente, adeguatezza delle fasi al contesto reale, trasferibilità delle buone pratiche.

## Come leggere questo documento

Il **corpo principale** è pensato per essere leggibile anche da chi non ha competenze informatiche specialistiche (Dirigente scolastico, DPO, referenti organizzativi, docenti non tecnici). Contiene la pedagogia, il protocollo di sperimentazione, la privacy e la governance.

I **dettagli di infrastruttura e implementazione** (architettura, formati di invio o conservazione dei dati, configurazione di Gem / Skill / Modelfile / Docker) sono raccolti in **appendici tecniche** in calce, destinate a chi realizza o mantiene lo stack.

## Struttura del documento

**Corpo principale**

- [Recensione della letteratura](01_stato_dell_arte.md)
- [Normativa rilevante la sperimentazione](06_normativa_e_sicurezza.md)
- [Quadro pedagogico](02_quadro_pedagogico.md): destinatari (SIA prioritario; adattamento Liceo), prerequisiti, obiettivi, glossario, ruoli
- [Protocollo didattico](03_protocollo_didattico.md)
- [Proposta di sperimentazione](07_sperimentazione.md): protocollo empirico, metriche, pre/post-test, questionari, criteri di successo, trasferibilità

**Appendici tecniche** (lettura facoltativa per il pubblico non tecnico)

- [Appendice A — Architettura del sistema e prototipo tecnico](04_architettura_sistema.md)
- [Appendice B — Formati, schemi e consegne strutturate](05_formati_e_schemi.md)
- [Appendice C — Realizzazione tecnica dei piloti (Gem, Skill, Modelfile)](08_appendice_realizzazione_tecnica.md)

**Bibliografia**

- [Bibliografia](riferimenti.bib)

> **Nota di stato.** Il presente corpus documentale è, al momento, un **unico insieme di testi in bozza**, destinato a più lettori (progettisti, Dirigente scolastico, docenti, DPO, amministratori di piattaforma e di rete, referenti Health School). Eventuali versioni differenziate per destinatario potranno essere prodotte in seguito.
