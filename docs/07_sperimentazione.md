# Protocollo di sperimentazione empirica {#sec-protocollo-sperimentazione}

Prima di estendere l'adozione del sistema a più istituti o corsi, il progetto prevede una sperimentazione controllata volta a quantificare l'efficacia didattica, l'usabilità e la sostenibilità operativa.

---

## Fasi e disegno della ricerca {#sec-disegno-ricerca}

La sperimentazione si articola in sette passaggi metodologici:

1. **Definizione degli obiettivi formativi mirati:**
   Focalizzazione su un sottoinsieme specifico di competenze modellistiche e interrogative (da O2 a O7: modellazione ER, traduzione in schema relazionale, individuazione di vincoli non banali, calcolo delle forme normali, scrittura di query SQL con aggregazioni e join).

2. **Strumenti di misurazione standardizzati:**
   - *Pre-test diagnostico*: Somministrazione iniziale per rilevare il livello di partenza degli studenti.
   - *Attività formative con il tutor*: Svolgimento delle consegne C1–C4 con tracciamento dettagliato delle revisioni.
   - *Post-test individuale*: Valutazione delle competenze acquisite al termine dell'intervento.
   - *Prova di trasferimento a distanza (3–4 settimane)*: Risoluzione di una traccia inedita senza alcun supporto del tutor (fase 9 / consegna C5), per verificare la ritenzione nel medio termine e l'assenza di dipendenza dall'assistente.
   - *Correzione in cieco*: Valutazione degli elaborati da parte di due docenti indipendenti all'oscuro dell'identità dello studente, con rubrica analitica descrittiva e calcolo dell'indice di accordo inter-valutatore.

3. **Validazione preventiva del tutor (Golden Set):**
   Prima dell'interazione con gli studenti, il tutor linguistico è sottoposto al golden set di collaudo (@sec-test-tutor-llm):
   - Almeno 30 casi noti per ciascuna fase;
   - Misurazione della fedeltà ai livelli di aiuto (nessun controesempio a L1, nessun codice risolutivo completo);
   - Calcolo del tasso di mancata fuga della soluzione (obiettivo: 100%);
   - Verifica di non-contraddizione rispetto alle diagnosi deterministiche.

4. **Studio pilota:**
   - Coinvolgimento di una o due classi (5–20 studenti per classe) per un ciclo di 6–8 lezioni curricolari in laboratorio.
   - Disegno di ricerca prevalentemente *intra-soggetto* (confronto pre/post sullo stesso gruppo di studenti).
   - Rilevazione qualitativa continua: osservazione sul campo dei comportamenti degli studenti, registrazione dei blocchi tecnici o didattici, note del docente.
   - Affinamento iterativo dei prompt, dei pesi di quantizzazione e delle regole di validazione prima della sperimentazione su scala più ampia.

5. **Verifica empirica del trasferimento:**
   Confronto delle prestazioni della prova individuale finale rispetto al pre-test diagnostico iniziale, utilizzando una traccia concettualmente isomorfa ma ambientata in un dominio applicativo differente.

6. **Analisi multidimensionale dei risultati:**
   Oltre ai punteggi grezzi di correttezza, l'analisi considera:
   - *Grado di autonomia*: Evoluzione della richiesta di livelli di aiuto (tendenza a diminuire il ricorso a L3/L4);
   - *Qualità del ragionamento*: Pertinenza, rigore e ricchezza delle motivazioni scritte nei campi `motivazione`;
   - *Capacità di correzione attiva*: Analisi della cronologia dei commit Git tra il primo tentativo e la consegna validata;
   - *Esperienza percepita*: Questionario di fine percorso sull'utilità percepita, senso di autoefficacia e fiducia nel tutor.

7. **Confronto controllato (Fase estesa successiva):**
   Qualora siano disponibili classi parallele con il medesimo programma curricolare, confronto tra:
   - *Gruppo sperimentale*: Attività svolta con Socratic-DB.
   - *Gruppo di controllo*: Attività tradizionale con correzione manuale periodica del docente.
   Adozione di schemi a rotazione (*crossover*) per garantire a tutti gli studenti le medesime opportunità formative.

---

## Raccolta dati e metriche di processo {#sec-raccolta-metriche}

Tutti i dati raccolti sono associati esclusivamente a identificativi pseudonimi (`s001`, `s002`, ...):

- **Metriche quantitative di sistema**:
  - Numero di tentativi e commit effettuati per ciascuna fase;
  - Frequenza e tipologia delle diagnosi deterministiche sollevate (es. violazioni di integrità referenziale, errori di normalizzazione, query SQL non sintattiche);
  - Livello massimo di aiuto richiesto (L0–L4) per esercizio;
  - Tempo impiegato per completare ciascuna consegna;
  - Tempi effettivi di preparazione e validazione delle tracce da parte del docente (misura della sostenibilità).
- **Metriche di apprendimento**:
  - Punteggi ottenuti nelle rubriche del pre-test, post-test e prova di trasferimento;
  - Indice di qualità delle spiegazioni (rubrica qualitativa a 3 livelli).

---

## Analisi statistica e criteri di successo {#sec-analisi-risultati}

- **Trattamento statistico:**
  - Calcolo di statistiche descrittive (mediana, intervallo interquartile, medie e deviazioni standard);
  - Stima delle dimensioni dell'effetto (*effect size*, es. d di Cohen o r di Wilcoxon) con intervalli di confidenza al 95%;
  - Data la dimensione contenuta dei campioni tipici scolastici (5–20 studenti per classe), l'analisi quantitativa deve essere interpretata con prudenza ed essere corroborata dall'analisi qualitativa dei percorsi individuali.
- **Dichiarazione delle minacce alla validità:**
  - *Effetto novità*: Entusiasmo iniziale per l'uso dell'IA generativa;
  - *Apprendimento esterno*: Studio autonomo a casa o supporto di terzi tra pre-test e post-test;
  - *Maturazione naturale*: Miglioramento fisiologico dovuto al normale avanzamento dell'anno scolastico.

### Criteri di successo definiti a priori
1. **Incremento significativo nel post-test e nel trasferimento**: Miglioramento misurabile nella capacità di modellazione e interrogazione autonoma rispetto al livello di ingresso.
2. **Riduzione della dipendenza dall'aiuto**: Diminuzione statisticamente visibile del livello medio di aiuto richiesto tra la prima e l'ultima consegna.
3. **Miglioramento della capacità critica**: Incremento qualitativo dei testi di motivazione inseriti negli schemi.
4. **Sostenibilità del carico di lavoro del docente**: Tempo medio di preparazione e validazione della traccia tramite strumento d'autore contenuto entro i 30 minuti; tempo di revisione per classe compatibile con il normale orario di servizio.
5. **Accordo del tutor sulle query**: Accordo tra il parere non vincolante del tutor in fase 8 e il giudizio dei docenti su almeno l'85% del campione esaminato.
6. **Zero incidenti di sicurezza e privacy**: Nessun dato personale esfiltrato e rispetto integrale dei protocolli approvati.

---

## Etica, governance e consenso {#sec-etica-governance}

- **Approvazione formale degli organi collegiali:** Delibera del Collegio dei Docenti e del Consiglio di Istituto sull'adozione della sperimentazione.
- **Coinvolgimento del DPO:** Emissione del parere favorevole sulla DPIA e sulle informative per famiglie e studenti.
- **Volontarietà e diritto di recesso:** Possibilità per ogni studente di partecipare senza obbligo e di ritirarsi in qualsiasi momento optando per il percorso didattico alternativo tradizionale, senza alcuna penalizzazione sul piano valutativo curricolare.
- **Restituzione formativa:** Sessione finale di debriefing con gli studenti per discutere i risultati aggregati, le difficoltà emerse e il ruolo critico dell'IA nei contesti professionali.
