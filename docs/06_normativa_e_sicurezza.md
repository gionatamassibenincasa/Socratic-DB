# Quadro normativo, sicurezza e privacy {#sec-normativa-sicurezza}

Quanto segue costituisce una traccia operativa di conformità normativa e di sicurezza da validare con il Responsabile della Protezione dei Dati (DPO) dell'istituzione scolastica e con il Dirigente Scolastico prima dell'avvio della sperimentazione; non costituisce parere legale formale.

---

## Trattamento dei dati personali (GDPR) {#sec-trattamento-dati}

La tabella seguente sintetizza le scelte di conformità al Regolamento Generale sulla Protezione dei Dati (GDPR - Regolamento UE 2016/679):

| Aspetto | Scelta e misura operativa |
| --- | --- |
| **Titolare del trattamento** | L'istituzione scolastica (o universitaria) in cui si svolge la sperimentazione. |
| **Finalità** | Supporto didattico formativo curricolare; eventuale ricerca didattica accademica in forma rigorosamente aggregata e anonima. |
| **Base giuridica** | Esecuzione di un compito di interesse pubblico o connesso all'esercizio di pubblici poteri di cui è investito il titolare (art. 6.1.e GDPR); per la ricerca didattica, specifica informativa e acquisizione del consenso o altra base identificata con il DPO. |
| **Tutela dei minori** | Studenti in prevalenza minorenni (circa 14–19 anni): erogazione di informativa trasparente e accessibile a studenti ed esercenti la responsabilità genitoriale. |
| **Dati trattati** | Elaborati didattici (file YAML, query SQL, testi di motivazione), log delle interazioni e delle diagnosi; **divieto categorico di inserire dati personali reali** nelle tracce e nei dataset di prova. |
| **Minimizzazione e pseudonimizzazione** | Adozione di identificatori pseudonimi casuali (es. `s017`); nessun nome o dato anagrafico inserito nei prompt; per le immagini di schemi manoscritti (sistema avanzato), distruzione del file immagine immediatamente dopo la trascrizione testuale. |
| **Conservazione** | Conservazione dei log tecnici e dei dialoghi limitata alla durata dell'anno scolastico, con successiva cancellazione sicura o anonimizzazione irreversibile; le pubblicazioni di ricerca utilizzano solo dati aggregati. |
| **Ruoli e accessi** | Studente: accesso esclusivo ai propri dati. Docente: accesso ai dati e ai report della propria classe. Amministratore di sistema: accesso per sole finalità di manutenzione tecnica. |
| **Destinatari terzi** | **Nessun destinatario esterno:** modelli di inferenza, banche dati ed esecutori operano interamente in rete locale (*on-premise*). Nessun dato transita verso API cloud commerciali. |
| **Diritti degli interessati** | Esercizio dei diritti di accesso, rettifica, cancellazione e limitazione garantito e gestito direttamente tramite la segreteria dell'istituto. |

### Adempimenti documentali
Prima dell'inizio delle attività devono essere predisposti:
1. Informativa sul trattamento dei dati per studenti e famiglie;
2. Aggiornamento del Registro dei Trattamenti dell'istituto;
3. Valutazione d'Impatto sulla Protezione dei Dati (DPIA) per l'introduzione di strumenti di intelligenza artificiale con minori;
4. Linee guida per gli studenti per l'uso esclusivo di dati sintetici o di fantasia nei test SQL.

---

## Misure di sicurezza tecniche e organizzative {#sec-misure-sicurezza}

- **Isolamento di rete:** I server di inferenza (Ollama/vLLM) e i container di esecuzione risiedono nella sottorete dell'istituto priva di connessioni in uscita verso Internet; gli aggiornamenti di sistema e dei pacchetti Python/OS sono effettuati periodicamente tramite mirror o repository controllati.
- **Autenticazione e controllo degli accessi:** Integrazione con i sistemi di identità scolastici (SSO, LDAP/Active Directory o credenziali pseudonime gestite internamente); cifratura a riposo dei dischi server (`LUKS`) e dei backup.
- **Isolamento dell'esecutore SQL:** I file SQL consegnati sono trattati come non fidati. L'esecuzione avviene in container monouso senza rete o processi vincolati con `rlimit`, con database in memoria e autorizzatore SQLite attivo per bloccare chiamate al filesystem o estensioni C.
- **Protezione da *Prompt Injection*:** Il codice e le motivazioni dello studente sono delimitati come meri dati passivi all'interno del contesto inviato all'LLM. Il modello tutor non dispone di tool d'azione, privilegi di esecuzione o accesso alla memoria esterna. Le risposte generate sono analizzate prima dell'invio allo studente per bloccare la fuga di soluzioni.
- **Tracciabilità e logging:** Conservazione dei log di sistema e delle chiamate di inferenza con canali separati per il monitoraggio operativo e la rilevazione tempestiva di eventuali anomalie.
- **Verifica delle licenze:** Accertamento della compatibilità per uso didattico e accademico delle licenze del software open-source e dei pesi dei modelli linguistici adottati (es. licenze Apache 2.0, MIT o specifiche per pesi aperti conformi all'Open Source Initiative).

---

## Valutazione e quadro regolatorio sull'Intelligenza Artificiale (AI Act) {#sec-ai-act}

- **Assenza di decisioni automatizzate e di valutazione algoritmica:**
  Il sistema è privo di funzioni di calcolo di voti, attribuzione di punteggi sommatori o giudizi di idoneità. Gli esiti dei controlli tecnici deterministici costituiscono pure informazioni diagnostiche formative di processo. La valutazione finale resta un atto esclusivamente umano, esercitato dal docente sulla base di prove individuali in presenza (fase 9) e della lettura qualitativa degli elaborati. Questa scelta garantisce piena conformità con l'art. 22 del GDPR (divieto di decisioni basate unicamente sul trattamento automatizzato).
- **Inquadramento rispetto all'EU AI Act (Regolamento UE 2024/1689):**
  L'AI Act include tra i sistemi ad alto rischio (Allegato III, punto 3) i sistemi di IA destinati a valutare i risultati dell'apprendimento, anche quando tali esiti orientino il percorso scolastico. Socratic-DB è deliberatamente architettato per sottrarsi a tale perimetro:
  - Non calcola punteggi;
  - Non formula raccomandazioni vincolanti di avanzamento o blocco;
  - Non stila graduatorie o profili predittivi dello studente.
  La classificazione va in ogni caso formalizzata nella scheda tecnica del sistema con il DPO dell'istituto.
- **Trasparenza e alfabetizzazione (Art. 50 AI Act):**
  Gli studenti sono esplicitamente informati del fatto che stanno interagendo con un agente artificiale. L'esperienza didattica è integrata da moduli di alfabetizzazione critica sull'IA, volti a chiarire come funziona il tutor, quali sono i suoi limiti e perché le verifiche tecniche provengono da software deterministico e non dal modello linguistico.
- **Percorso alternativo:**
  Viene garantita agli studenti e alle famiglie la possibilità di svolgere il medesimo percorso curricolare con modalità tradizionali (esercitazione standard guidata dal docente in aula e su materiale cartaceo/digitale convenzionale) senza alcuna penalizzazione.

---

## Limiti del sistema e minacce alla validità {#sec-limiti-validita}

- **Allucinazioni e compiacenza dell'LLM (*Sycophancy*):** I modelli linguistici possono produrre risposte errate, incoerenti o accondiscendere a ragionamenti scorretti. Per mitigare tale rischio, l'LLM è confinato al ruolo dialogico e le sue risposte sono vincolate alle diagnosi deterministiche.
- **Rigidità dei controlli deterministici:** I controlli automatici valutano solo ciò che è formalizzato nei test: un controllo eccessivamente stringente rischia di respingere schemi alternativi del tutto validi. Rimane sempre attiva la facoltà di segnalazione di falsi positivi al docente.
- **Limiti espressivi del DDL SQLite:** Vincoli di dominio che coinvolgono tuple multiple o dipendenze temporali complesse non sono esprimibili con semplici vincoli dichiarativi in SQLite e richiedono trigger o controlli applicativi.
- **Dipendenze funzionali incomplete:** La correttezza del calcolo delle forme normali (2NF, 3NF, BCNF) dipende dall'insieme delle dipendenze funzionali dichiarate dallo studente nel modello relazionale; se lo studente omette dipendenze fondamentali, il calcolo algoritmico risulterà parziale.
- **Limiti di scalabilità hardware:** Con una singola GPU locale da 32 GB di VRAM, la capacità di servizio simultaneo è calibrata su una singola classe (5–20 postazioni attive con intervalli di digitazione umana).
- **Automation bias del docente:** Nell'uso dello strumento d'autore (@sec-strumento-autore), esiste il rischio che il docente approvi la checklist o lo schema proposto dall'IA senza un'attenta rilettura critica. La validazione umana deve essere formalizzata come passaggio obbligatorio e verificata a campione.
