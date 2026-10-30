---
title: Socratic-DB
subtitle: Tutor socratico per la progettazione di basi di dati relazionali
author: Gionata Massi
abstract: |
    Uno strumento e una metodologia didattica che, tramite il metodo socratico, vuole aiutare gli studenti ad acquisire la capacità di sviluppare una base di dati relazionale dalle fasi di analisi concettuale a quella di implementazione passando per il modello logico relazionale.
    Il processo deve condurre lo studente a produrre una base di dati completa, pertinente, minimale e intelligibile, a partire da una descrizione testuale del problema.
    La costruzione della conoscenza procede come dialogo, tra l'arte della domanda gestita a livello subsimbolico da modelli linguistici, e il rigore della struttura validato a livello logico-simbolico.
---

# Socratic-DB — Tutor socratico per la progettazione di basi di dati relazionali

[![AI Act: Supporto Formativo](https://img.shields.io/badge/EU_AI_Act-Non_Valutativo-orange.svg)](#quadro-normativo-e-privacy)
[![Privacy: Consenso + Pseudonimizzazione](https://img.shields.io/badge/Privacy-GDPR_Consenso_Esplicito-blue.svg)](#quadro-normativo-e-privacy)

---

## Visione di progetto

**Socratic-DB** è un ambiente di apprendimento assistito dall’Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado.

**Destinatari prioritari della sperimentazione presso l’Istituto proponente:**  
**ITE** – indirizzo Amministrazione, Finanza e Marketing, articolazione **Sistemi Informativi Aziendali (SIA / ITSI)**.

Il percorso è trasferibile ad altri contesti (es. ITIA, corsi universitari di basi di dati) e adattabile al **Liceo Scientifico opzione Scienze Applicate** (solo analisi e modellazione concettuale, senza SQL).

Il progetto nasce da un principio pedagogico ed epistemologico chiaro: **contrastare la delega cognitiva (*cognitive offloading*)** che sta avvenendo con l’uso acritico degli strumenti di *Generative Artificial Intelligence* (GenIA). In questa proposta, il sistema non impiega i *Large Language Model* (LLM) per risolvere i problemi o scrivere codice al posto dello studente, ma come **tutor socratici**:

1. **La mediazione maieutica è affidata all’LLM**: attraverso domande mirate, controesempi concreti ed elicitazione progressiva dei vincoli (livelli di aiuto graduati da L0 a L4), il tutor guida lo studente nell’individuare errori concettuali e nel motivare formalmente ogni scelta di modellizzazione.
2. **La verità tecnica**, quando formalizzabile, risiede in controlli deterministici (introdotti progressivamente).
3. **La valutazione resta prerogativa esclusiva del docente**: il sistema non assegna voti, non stila punteggi né profila gli studenti. La verifica dell’apprendimento effettivo avviene tramite prove individuali in presenza senza ausilio del tutor (**prova di trasferimento su carta**, senza dispositivi elettronici).

---

## Mappa della documentazione

L’intera documentazione tecnica, pedagogica e sperimentale è presente nella *directory* [`docs/`](docs/):

| Sezione | Documento | Argomenti principali |
| :--- | :--- | :--- |
| **01. Stato dell’Arte** | [`docs/01_stato_dell_arte.md`](docs/01_stato_dell_arte.md) | Intelligent Tutoring Systems, cognitive offloading, scaffolding socratico, architettura neuro-simbolica. |
| **02. Pedagogia** | [`docs/02_quadro_pedagogico.md`](docs/02_quadro_pedagogico.md) | Destinatari (ITIA, SIA e adattamento Liceo), prerequisiti, obiettivi O1–O8, ruoli. |
| **03. Didattica** | [`docs/03_protocollo_didattico.md`](docs/03_protocollo_didattico.md) | Percorso in fasi e consegne, livelli di aiuto L0–L4, ciclo di revisione, catalogo tracce. |
| **04. Architettura** | [`docs/04_architettura_sistema.md`](docs/04_architettura_sistema.md) | Componenti del sistema e progressione dei piloti. |
| **05. Formati & Schemi** | [`docs/05_formati_e_schemi.md`](docs/05_formati_e_schemi.md) | Specifiche tecniche (in fase di semplificazione). |
| **06. Normativa** | [`docs/06_normativa_e_sicurezza.md`](docs/06_normativa_e_sicurezza.md) | GDPR (consenso esplicito, tutela dei minori), AI Act (sistema non valutativo), misure di sicurezza. |
| **07. Sperimentazione** | [`docs/07_sperimentazione.md`](docs/07_sperimentazione.md) | **Protocollo empirico completo**: quattro piloti progressivi, metriche, criteri di successo, cronoprogramma, governance. |
| **Bibliografia** | [`docs/riferimenti.bib`](docs/riferimenti.bib) | Fonti bibliografiche e normative. |
| **Gemini Gem** | [`gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md`](gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md) | Istruzioni di sistema per la Gem di Gemini in Google Workspace for Education / Classroom. |
| **Agentic Skill** | [`skills/socratic-db/SKILL.md`](skills/socratic-db/SKILL.md) | Definizione della Skill socratica standard. |
| **Ollama Modelfile** | [`ollama/Modelfile`](ollama/Modelfile) | Modelfile per l’esecuzione locale con Ollama. |

---

## Il percorso didattico

L’apprendimento è scandito da un ciclo iterativo di sottomissione, feedback maieutico e revisione argomentata, articolato in fasi e consegne. La prova finale di trasferimento (Consegna C5 / Tappa 9) avviene **su carta, senza accesso a dispositivi elettronici**.

### Livelli di aiuto progressivi del tutor (L0–L4)

- **L0 (Esito sintetico)**: Solo area interessata e numero di anomalie, senza dettagli.
- **L1 (Domanda maieutica)**: Domanda mirata volta a far emergere il conflitto logico.
- **L2 (Controesempio)**: Esempio concreto dal dominio che viola l’intento dello schema.
- **L3 (Principio teorico)**: Spiegazione del costrutto o della regola formale (senza applicarla alla soluzione).
- **L4 (Esempio isomorfo)**: Esempio svolto parziale su un dominio differente e rilancio di un nuovo esercizio autonomo.

---

## Progressione dei piloti

La sperimentazione segue una progressione controllata a basso rischio:

1. **Pilota 1 – Zero-infrastructure** (già avviato): Gem di Gemini condivise tramite Google Classroom.
2. **Pilota 2 – On-premise leggero**: Ollama sulla workstation di laboratorio (6 GB VRAM).
3. **Pilota 3 – Stack parziale**: introduzione graduale di controlli deterministici e sandbox SQLite.
4. **Pilota 4 – Stack completo**: architettura neuro-simbolica piena (solo dopo consolidamento dei piloti precedenti).

---

## Quadro normativo e privacy

- Base giuridica preferita: **consenso esplicito** dei genitori (o dello studente maggiorenne).
- Opzione di limitazione agli studenti maggiorenni.
- Sistema configurato come **supporto formativo non valutativo** (AI Act): nessuna assegnazione di voti, nessuna profilazione.
- Valutazione dell’apprendimento riservata esclusivamente al docente umano.
- Coinvolgimento preventivo del DPO di Istituto.
- Dettagli completi in [`docs/06_normativa_e_sicurezza.md`](docs/06_normativa_e_sicurezza.md).

---

## Struttura del repository

```text
.
├── README.md                      # Questo documento (dashboard e sintesi)
├── docs/                          # Documentazione modulare
│   ├── index.md
│   ├── 01_stato_dell_arte.md
│   ├── 02_quadro_pedagogico.md
│   ├── 03_protocollo_didattico.md
│   ├── 04_architettura_sistema.md
│   ├── 05_formati_e_schemi.md
│   ├── 06_normativa_e_sicurezza.md
│   ├── 07_sperimentazione.md      # Protocollo operativo principale
│   └── riferimenti.bib
├── gemini-gem/                    # Istruzioni per la Gem di Gemini
├── skills/socratic-db/            # Skill agentica
├── ollama/                        # Modelfile per esecuzione locale
└── ...
```

I percorsi e i file di sviluppo locale sono mantenuti separati dalla documentazione principale destinata alla Dirigente e al Ministero.
