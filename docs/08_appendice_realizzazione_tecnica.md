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

## Pilota 2 — On-premise leggero (Ollama)

Quando i criteri di go del Pilota 1 sono soddisfatti, le stesse istruzioni socratiche possono essere caricate in un **Modelfile** per Ollama, eseguito sulla workstation di laboratorio (obiettivo: 6 GB di VRAM, modelli quantizzati di dimensioni contenute).

| Elemento | Collocazione nel repository |
|----------|------------------------------|
| Modelfile | `ollama/Modelfile` |
| Vincoli hardware | Vedi anche Appendice A (scelta del modello e parametri di inferenza) |

Non si promuove, nella fase 1, l’installazione di modelli open-weight sui dispositivi personali degli studenti. L’eventuale esecuzione locale a casa è uno scenario evolutivo descritto nel protocollo di sperimentazione (sezione sul lavoro domestico).

---

## Piloti 3 e 4 — Stack parziale e completo

I controlli deterministici, la sandbox SQLite e l’architettura neuro-simbolica piena sono descritti in **Appendice A**. I formati di consegna strutturati (YAML e affini), utili quando i controlli automatici sono attivi, sono in **Appendice B**. Nella fase iniziale della sperimentazione (Pilota 1) tali formati **non** sono obbligatori per gli studenti.

---

## Principio di separazione

| Documento / componente | Contenuto |
|------------------------|-----------|
| Corpo principale (capitoli 1–7 del volume) | Pedagogia, protocollo di sperimentazione, privacy, governance, metriche |
| Appendice A | Architettura, hardware, controlli deterministici, ipotesi di sistema avanzato |
| Appendice B | Formati di consegna e schemi (YAML, Markdown obbligato, ecc.) |
| Appendice C (questo file) | Collegamento operativo a Gem, Skill e Modelfile |
| File `gemini-gem/`, `ollama/`, `skills/` | Sorgenti pronti all’uso |
