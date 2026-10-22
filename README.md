---
title: Socratic-DB
subtitle: Tutor socratico per la progettazione di basi di dati relazionali
author: Gionata Massi
abstract: |
    Uno strumento e una metodologia didattica che, tramite il metodo socratico, vuole aiutare gli studenti nell'acquisire la capacità di sviluppare una base di dati relazionale dalle fasi di analisi concettuale a quella di implementazione passando per il modello logico relazionale.
    Il processo deve condurre lo studente a produrre una base di dati completa, pertinente, minimale e intelligibile, a partire da una descrizione testuale del problema.
    La costruzione della conoscenza procede come dialogo, tra l'arte della domanda gestita a livello subsimbolico da modelli lingustici, e il rigore della struttura validato a livello logico-simbolico. 
---

# Socratic-DB — Tutor socratico per la progettazione di basi di dati relazionali

[![Infrastruttura: On--Premise](https://img.shields.io/badge/Privacy-100%25_On--Premise_GDPR-success.svg)](#quadro-normativo-e-privacy)
[![AI Act: Supporto Formativo](https://img.shields.io/badge/EU_AI_Act-Non_Valutativo-orange.svg)](#quadro-normativo-e-privacy)

---

## Visione di progetto

**Socratic-DB** è un ambiente di apprendimento assistito dall'Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado (ITE indirizzo *Sistemi Informativi Aziendali* e ITT indirizzo *Informatica*) e per corsi universitari introduttivi di basi di dati.

Il progetto nasce da un principio pedagogico ed epistemologico chiaro: **contrastare la delega cognitiva (*cognitive offloading*)** che sta avvenendo con l'uso acritico degli strumenti di *Generative Artificial Intelligence* (GenIA). In questa proposta, il sistema non impiega i *Large Language Model* (LLM) per risolvere i problemi o scrivere codice al posto dello studente,  ma come **tutor socratici**:

1. **La mediazione maieutica è affidata all'LLM**: attraverso domande mirate, controesempi concreti ed elicitazione progressiva dei vincoli (livelli di aiuto graduati da L0 a L4), il tutor guida lo studente nell'individuare errori concettuali e nel motivare formalmente ogni scelta di modellizzazione.
2. **La verità tecnica risiede in controlli deterministici**: l'LLM non valuta la correttezza formale. La validazione sintattica, il calcolo della chiusura degli attributi, la verifica delle forme normali (2NF, 3NF, BCNF) e l'esecuzione di DDL e query SQL sono affidati a un runtime deterministico e a un esecutore isolato SQLite.
3. **La valutazione resta prerogativa esclusiva del docente**: il sistema non assegna voti, non stila punteggi né profila gli studenti. La verifica dell'apprendimento effettivo avviene tramite prove individuali in presenza senza ausilio del tutor (*prova di trasferimento*).

---

## Mappa della documentazione

L'intera documentazione tecnica, pedagogica e sperimentale è presente nella *directory* [`docs/`](docs/) del *repository* ospitato alla pagina <https://github.com/gionatamassibenincasa/socratic-db>:

| Sezione | Documento | Argomenti principali |
| :--- | :--- | :--- |
| **01. Stato dell'Arte** | [`docs/01_stato_dell_arte.md`](docs/01_stato_dell_arte.md) | Intelligent Tutoring Systems (SQL-Tutor, CBM), cognitive offloading, scaffolding socratico, architettura neuro-simbolica e quadro di ricerca. |
| **02. Pedagogia** | [`docs/02_quadro_pedagogico.md`](docs/02_quadro_pedagogico.md) | Destinatari (ITE SIA, ITT Informatica, Università), prerequisiti, obiettivi formativi O1–O8, ruoli docente/tutor e rischi didattici. |
| **03. Didattica** | [`docs/03_protocollo_didattico.md`](docs/03_protocollo_didattico.md) | Il percorso in 9 fasi e 5 consegne, livelli di aiuto L0–L4, ciclo di revisione con motivazioni, sostenibilità docente e archivio tracce d'esame e altre prove. |
| **04. Architettura** | [`docs/04_architettura_sistema.md`](docs/04_architettura_sistema.md) | Orchestratore Python (FSM), sandbox SQLite isolata in memoria, requisiti hardware GPU, golden set di collaudo, system prompt e GitLab CI/ForgeJo. |
| **05. Formati & Schemi** | [`docs/05_formati_e_schemi.md`](docs/05_formati_e_schemi.md) | Specifiche dei file YAML per validare schemi concettuali e relazionali, contratti di consegna, formato diagnosi JSON e report compatto di processo. |
| **06. Normativa** | [`docs/06_normativa_e_sicurezza.md`](docs/06_normativa_e_sicurezza.md) | Conformità GDPR (minori, pseudonimizzazione), EU AI Act (esclusione dai sistemi di profiling ad alto rischio), isolamento di rete e mitigazione injection. |
| **07. Sperimentazione**| [`docs/07_sperimentazione.md`](docs/07_sperimentazione.md) | Disegno di ricerca empirica pre/post-test, studio pilota in classe, prova di trasferimento a distanza, metriche di processo e criteri di successo. |
| **Bibliografia** | [`docs/riferimenti.bib`](docs/riferimenti.bib) | Fonti accademiche e normative in formato BibTeX (Codd, Chen, Mitrovic, Bloom, Vygotskij, Becker, AI Act, GDPR). |

---

## Il percorso didattico: 9 fasi in 5 consegne

L'apprendimento è scandito da un ciclo iterativo di sottomissione, diagnosi deterministica e revisione argomentata:

```text
[Requisiti della Traccia]
        │
        ▼
   [Consegna C1] ──► 1. Analisi requisiti & 2. Glossario non circolare
        │
        ▼
   [Consegna C2] ──► 3. Modello concettuale ER & 4. Classificazione vincoli di dominio
        │
        ▼
   [Consegna C3] ──► 5. Modello relazionale, chiavi, FK e normalizzazione (1NF, 2NF, 3NF)
        │
        ▼
   [Consegna C4] ──► 6. DDL SQLite & 7. Popolamento di test & 8. Query SQL verificate
        │
        ▼
   [Consegna C5] ──► 9. Prova individuale di trasferimento (In aula, traccia inedita, SENZA tutor)
```

### Livelli di aiuto progressivi del tutor (L0–L4)
Il tutor LLM modula il proprio intervento in base allo stato della revisione:
- **L0 (Esito sintetico)**: Solo area interessata e numero di anomalie, senza dettagli.
- **L1 (Domanda maieutica)**: Domanda mirata volta a far emergere il conflitto logico.
- **L2 (Controesempio)**: Esempio concreto dal dominio che viola l'intento dello schema.
- **L3 (Principio teorico)**: Spiegazione del costrutto o della regola formale (senza applicarla alla soluzione).
- **L4 (Esempio isomorfo)**: Esempio svolto parziale su un dominio differente e rilancio di un nuovo esercizio autonomo.

---

## Architettura logica del sistema

```
[Studente] ──(File YAML / SQL)──► [Interfaccia: WebUI / CLI / Git]
                                            │
                                            ▼
                               [Orchestratore Python (FSM)]
                       Mantiene stato percorso e gestisce livelli L0-L4
                         │                  │                   │
                         ▼                  ▼                   ▼
                [Validatori YAML]  [Esecutore SQLite]  [Tutor Socratico LLM]
                - JSON Schema      - Sandbox :memory:  - Riceve solo diagnosi
                - Chiusura attr.   - Authorizer attivo - Non contraddice i test
                - Verifica 3NF/FK  - Timeout & quote   - Nessuna soluzione diretta
                         │                  │                   │
                         └──────── Diagnosi strutturate ────────┘
```

---

## Requisiti infrastrutturali (100% On-Premise)

Per garantire la tutela dei dati degli studenti e l'indipendenza operativa dell'Istituto, il sistema non richiede servizi cloud:

- **Server locale**: Macchina Linux (Ubuntu/Debian) con almeno 64 GB RAM.
- **Accelerazione GPU**: Scheda con 32 GB di VRAM (supporto per modelli aperti quantizzati ~20B–32B a 4–5 bit, es. famiglie Qwen 2.5/3 o equivalenti con licenza permissiva Apache 2.0).
- **Runtime di inferenza**: [Ollama](https://ollama.com/) o [vLLM](https://github.com/vllm-project/vllm) esposti su rete locale.
- **Consegna e CI/CD**: Istanza locale di **GitLab Community Edition** o **Forgejo** con runner Docker isolati privi di accesso Internet.

---

## Struttura del repository

```text
.
├── README.md                      # Questo documento (dashboard e sintesi)
├── docs/                          # Documentazione modulare e approfondimenti
│   ├── index.md
│   ├── 01_stato_dell_arte.md
│   ├── 02_quadro_pedagogico.md
│   ├── 03_protocollo_didattico.md
│   ├── 04_architettura_sistema.md
│   ├── 05_formati_e_schemi.md
│   ├── 06_normativa_e_sicurezza.md
│   ├── 07_sperimentazione.md
│   └── riferimenti.bib
├── schemas/                       # Schemi JSON di validazione dei formati YAML
├── infra/                         # Configurazione Docker Compose e playbook Ansible
├── catalog/                       # Catalogo delle tracce e checklist validate
└── experiments/                   # Strumenti per la sperimentazione (golden set, rubriche)
```

---

## Generazione della documentazione unificata (PDF / DOCX / Markdown)

I capitoli presenti in `docs/` possono essere compilati automaticamente in un unico documento stampabile o distribuibile (PDF, DOCX editabile o Markdown unico):

```bash
# Esempio con Quarto (raccomandato):
quarto render --to pdf
quarto render --to docx

# Oppure tramite Pandoc / Makefile:
make pdf
make docx
make single-markdown
```

---

## Quadro normativo e privacy

- **GDPR (Regolamento UE 2016/679)**: Elaborazione interamente on-premise senza trasmissione di dati a terzi; utilizzo esclusivo di credenziali pseudonime per gli studenti (`s001`, `s002`, ...); divieto di impiego di dati anagrafici reali nei database di prova.
- **EU AI Act (Regolamento UE 2024/1689)**: Il tutor opera esclusivamente come supporto formativo interattivo e non applica algoritmi di profilazione o valutazione vincolante dei risultati di apprendimento, escludendo l'inquadramento come sistema ad alto rischio subordinato a scoring automatico.

<!--
---

## Contatti e contributi

Progetto sviluppato nell'ambito della sperimentazione sull'integrazione della GenIA nella didattica dell'Informatica.
I contributi, le segnalazioni di falsi positivi nelle checklist e i riscontri empirici sono benvenuti tramite Issue e Pull 
Request.
-->
