# Quadro normativo, sicurezza e privacy {#sec-normativa-sicurezza}

Quanto segue costituisce una traccia operativa di conformità normativa e di sicurezza da validare con il Responsabile della Protezione dei Dati (DPO) dell’istituzione scolastica e con il Dirigente Scolastico prima dell’avvio della sperimentazione; **non costituisce parere legale formale**.

---

## Trattamento dei dati personali (GDPR) {#sec-trattamento-dati}

La tabella seguente sintetizza le scelte di conformità al Regolamento Generale sulla Protezione dei Dati (GDPR – Regolamento UE 2016/679):

| Aspetto | Scelta e misura operativa |
| --- | --- |
| **Titolare del trattamento** | L’istituzione scolastica in cui si svolge la sperimentazione. |
| **Finalità** | Supporto didattico formativo curricolare; eventuale ricerca didattica in forma rigorosamente aggregata e anonima. |
| **Base giuridica preferita** | **Consenso esplicito** degli esercenti la responsabilità genitoriale (art. 6.1.a GDPR). In alternativa, per gli studenti maggiorenni, consenso diretto dell’interessato. |
| **Opzione semplificativa** | Possibilità di limitare la partecipazione agli studenti maggiorenni, riducendo la complessità del consenso. |
| **Tutela dei minori** | Informativa trasparente e accessibile a studenti ed esercenti la responsabilità genitoriale. |
| **Dati trattati** | Elaborati didattici, testi di motivazione, trascrizioni dei dialoghi con il tutor, log tecnici; **divieto categorico di inserire dati personali reali** nelle tracce e nei dataset di prova. |
| **Minimizzazione e pseudonimizzazione** | Adozione di identificatori pseudonimi casuali (es. `s017`); nessun nome o dato anagrafico inserito nei prompt. |
| **Conservazione** | Conservazione dei log e dei dialoghi limitata alla durata dell’anno scolastico, con successiva cancellazione sicura o anonimizzazione irreversibile. Le eventuali pubblicazioni di ricerca utilizzano solo dati aggregati. |
| **Ruoli e accessi** | Studente: accesso esclusivo ai propri dati. Docente sperimentatore: accesso ai dati e ai report della propria classe. Correttore in cieco: accesso agli elaborati in forma pseudonimizzata. Amministratore di sistema: accesso per sole finalità di manutenzione tecnica. |
| **Destinatari terzi (Pilota 1)** | Google Workspace for Education / Gemini, già utilizzato e regolamentato dall’Istituto. I dati restano all’interno dell’ambiente protetto dell’account istituzionale. |
| **Destinatari terzi (Piloti successivi)** | Nessun destinatario esterno: modelli di inferenza e controlli operano in rete locale (*on-premise*). |
| **Diritti degli interessati** | Esercizio dei diritti di accesso, rettifica, cancellazione e limitazione garantito e gestito direttamente tramite la segreteria dell’Istituto. |

### Adempimenti documentali

Prima dell’inizio delle attività devono essere predisposti:

1. Informativa sul trattamento dei dati per studenti e famiglie;
2. Modulo di consenso esplicito (genitori o studente maggiorenne);
3. Aggiornamento del Registro dei Trattamenti dell’Istituto;
4. Valutazione d’Impatto sulla Protezione dei Dati (DPIA), se richiesta dal DPO, per l’introduzione di strumenti di intelligenza artificiale con minori;
5. Linee guida per gli studenti sull’uso esclusivo di dati sintetici o di fantasia.

---

## Misure di sicurezza tecniche e organizzative {#sec-misure-sicurezza}

### Pilota 1 (Google Classroom + Gemini)
- Utilizzo esclusivo degli account istituzionali Google Workspace for Education.
- Condivisione delle Gem solo all’interno dell’organizzazione scolastica.
- Gli studenti scaricano le trascrizioni e le consegnano come allegati al compito in Classroom.
- Nessun dato personale reale viene inserito nelle tracce o nei prompt.

### Piloti successivi (Ollama e stack locale)
- **Isolamento di rete:** i server di inferenza e i container di esecuzione risiedono nella sottorete dell’Istituto priva di connessioni in uscita verso Internet non controllate.
- **Isolamento dell’esecutore SQL** (quando presente): esecuzione in ambiente isolato, database in memoria, restrizioni su filesystem e rete.
- **Protezione da Prompt Injection:** il testo prodotto dallo studente è trattato come dato passivo; il modello tutor non dispone di tool d’azione o privilegi di esecuzione.
- **Tracciabilità:** conservazione dei log tecnici con canali separati per monitoraggio operativo.
- **Verifica delle licenze:** accertamento della compatibilità per uso didattico dei modelli open-weight adottati.

---

## Valutazione e quadro regolatorio sull’Intelligenza Artificiale (AI Act) {#sec-ai-act}

Socratic-DB è configurato come **sistema di supporto formativo non valutativo**:

- non assegna voti;
- non produce punteggi automatici;
- non effettua profilazione degli studenti;
- non determina accesso a percorsi educativi o valutazioni ufficiali.

La valutazione dell’apprendimento resta **esclusiva prerogativa del docente umano**, anche attraverso la prova di trasferimento svolta su carta senza dispositivi elettronici.

In questa configurazione il sistema non rientra tra i sistemi di IA ad alto rischio di cui all’Allegato III del Regolamento (UE) 2024/1689 (AI Act), in particolare per quanto riguarda i sistemi destinati a determinare l’accesso o a valutare gli studenti nell’ambito dell’istruzione.

Resta comunque obbligatorio:

- informare chiaramente studenti e famiglie della natura e dei limiti del sistema;
- garantire la supervisione umana;
- consentire il diritto di recesso e il percorso didattico tradizionale alternativo.

---

## Governance e responsabilità

- **DPO di Istituto**: già nominato; coinvolto preventivamente per informativa, consenso e (se necessaria) DPIA.
- **Dirigente Scolastica**: autorizzazione formale all’avvio della sperimentazione.
- **Docenti sperimentatori (3) + correttore in cieco (1)**: responsabilità didattica e di corretta gestione dei dati pseudonimizzati.
- **Volontarietà**: ogni studente può partecipare o ritirarsi in qualsiasi momento senza penalizzazioni valutative, optando per il percorso tradizionale.

Ogni modifica sostanziale al trattamento dei dati o all’architettura dovrà essere sottoposta nuovamente al DPO e alla Dirigente.
