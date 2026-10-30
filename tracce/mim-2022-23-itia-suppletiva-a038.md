---
versione_catalogo: 1
id: mim-2022-23-itia-suppletiva-a038
titolo: Seconda prova A038 2023 suppletiva
anno_esame: 2023
anno_scolastico: "2022/23"
indirizzo:
  istituto: tecnico
  codice: ITIA
  articolazione: Informatica
disciplina:
  - Informatica
sessione: suppletiva
codice_ministeriale: A038
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Suppletiva/A038_SUP23.pdf
  acquisita_il: "2026-10-30"
riassunto: Seconda prova scritta di Informatica (A038 2023 suppletiva).
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
markdown: tracce/mim-2022-23-itia-suppletiva-a038.md
---

# Seconda prova A038 2023 suppletiva

## Testo completo (estratto da PDF ministeriale)

Seconda prova scritta




                         Ministero dell’istruzione e del merito
      A038 - ESAME DI STATO CONCLUSIVO DEL SECONDO CICLO DI ISTRUZIONE

  Indirizzo ITIA - INFORMATICA E TELECOMUNICAZIONI ARTICOLAZIONE "INFORMATICA"
                 (Testo valevole anche per gli indirizzi quadriennali IT32 e ITIT)

                                     Disciplina: INFORMATICA

Il candidato svolga la prima parte della prova e due tra i quesiti proposti nella seconda
parte.
PRIMA PARTE
La società SportOvunque, proprietaria di diverse palestre di fitness in alcune città d’Italia, vuole
lanciare un servizio innovativo che dia la possibilità alle persone che viaggiano di poter accedere,
con un unico abbonamento, ad attività offerte da palestre gestite anche da altre società, in tutta
Italia. A tale scopo SportOvunque ha preso accordi con palestre interessate ad aderire a questa
iniziativa su tutto il territorio nazionale. Le palestre che hanno aderito praticheranno tariffe di
ingresso agevolate riservate agli abbonati di SportOvunque.
L’abbonamento a questo servizio può essere acquistato sul portale web di SportOvunque, dove i
potenziali clienti possono registrarsi pagando on-line la relativa quota annuale.
Ogni palestra che aderisce all’iniziativa dovrà caricare sul portale i propri dati, comprensivi di
indirizzo, città e coordinate geografiche. Dovrà poi caricare anche la propria offerta di fitness: per
ogni tipologia standardizzata di attività (es: Sala macchine, GAG, Zumba, Pilates ecc…) resa
disponibile agli abbonati, indicherà i giorni della settimana (lunedì, martedì, …) in cui le attività
vengono svolte, ciascuna con gli orari in cui possono essere prenotate, il relativo prezzo
convenzionato e il numero massimo di posti disponibili.
Un abbonato potrà prenotare attività presso una qualsiasi palestra tra quelle presenti sul portale:
individuerà la palestra, l’attività, il giorno della settimana e l’orario, e sceglierà la data specifica di
suo interesse. Se in quella data sono già state effettuate prenotazioni in numero pari al massimo
dei posti disponibili per quell’attività, l’attività non sarà prenotabile. Altrimenti la prenotazione verrà
regolarmente registrata, e l’abbonato pagherà on-line il relativo prezzo a SportOvunque;
quest’ultima provvederà poi a versare mensilmente, alle varie palestre che hanno aderito al
servizio, gli incassi relativi alle attività prenotate.
Il candidato, fatte le opportune ipotesi aggiuntive, sviluppi:
1. un’analisi della realtà di riferimento, giungendo alla definizione di uno schema concettuale
     della base di dati che, a suo motivato giudizio, sia idoneo a gestire la realtà presentata;
2. il relativo schema logico;
3. la definizione in linguaggio SQL di un sottoinsieme delle relazioni della base di dati in cui siano
     presenti alcune di quelle che contengono vincoli di integrità referenziale e/o vincoli di dominio,
     se esistenti;
4. le interrogazioni espresse in linguaggio SQL che restituiscono:
     a) l’elenco delle attività disponibili in una data città il mercoledì, indicando, per ciascuna
          attività, la palestra, la tipologia di attività, l’orario di svolgimento, il numero massimo di
          posti disponibili, ed il prezzo, ordinate per palestra;
     b) l’importo totale delle prenotazioni pagate dagli abbonati nel mese di aprile, che
          SportOvunque dovrà versare ad una determinata palestra;
     c) la classifica annuale delle palestre di una certa città, ordinata in base al numero di attività
          prenotate;


 Pag. 2/2                                                                  Sessione suppletiva 2023
                                                                           Seconda prova scritta




                             Ministero dell’istruzione e del merito
          A038 - ESAME DI STATO CONCLUSIVO DEL SECONDO CICLO DI ISTRUZIONE

   Indirizzo ITIA - INFORMATICA E TELECOMUNICAZIONI ARTICOLAZIONE "INFORMATICA"
                     (Testo valevole anche per gli indirizzi quadriennali IT32 e ITIT)

                                           Disciplina: INFORMATICA
 5. il progetto di massima della struttura funzionale dell’applicazione web per la gestione della
    realtà sopra presentata;
 6. una parte significativa dell'applicazione web che consente l’interazione con la base di dati,
    utilizzando appropriati linguaggi a scelta sia lato client che lato server.
 SECONDA PARTE
 I. Con riferimento al tema presentato nella prima parte, si supponga di offrire ad un abbonato la
      possibilità di disdire la prenotazione di un’attività fino a 48 ore prima del suo svolgimento,
      ricevendo sul portale un credito pari al costo dell’attività che viene disdetta. Tale credito potrà
      essere utilizzato per successive prenotazioni. Si descrivano le modifiche da apportare alla
      base di dati e la struttura delle pagine web dedicate a tale funzionalità, scrivendo in un
      linguaggio a scelta una porzione di codice significativa di tali pagine.
 II. In relazione al tema proposto nella prima parte, si realizzi, in un linguaggio a scelta, una
      pagina dinamica che consenta all’utente di ottenere l’elenco in forma testuale delle palestre di
      una certa città. In alternativa, si rappresenti tale insieme di palestre attraverso una mappa
      geografica di quella città con la loro geolocalizzazione.
 III. Si descrivano le differenze, anche attraverso esempi, tra i predicati ANY, ALL ed EXISTS del
      linguaggio SQL.
 IV. Si consideri la seguente tabella:
                            Data    di      Città di     Società             Tel-                          Tel-
Nome         Cognome                                                                          Allenatore
                            nascita         nascita      Sportiva            Squadra                       Allenatore

Mario        Rossi          23-04-2004      Taranto      Atleti Taranto      099123123        Vittorio     3331122331

Luca         Verdi          07-06-2001      Milano       Corridori           02987987         Bruno        3501236786
                                                         Milanesi
Bianca       Rosa           01-01-2001      Perugia      Atleti Perugini     057893541        Raffaele     3475641830

Lorenzo      Verdi          04-05-2002      Roma         Roma sportivi       06549183         Giulio       3465921344
Manuela      Verdi          09-06-2002      Roma         Roma sportivi       06549183         Maria        3468712533

Umberto      Neri           01-03-2001      Taranto      Atleti Taranto      099123123        Vittorio     3331122331


 Il candidato verifichi le proprietà di normalizzazione e proponga uno schema equivalente che
 rispetti la terza Forma Normale, motivando le scelte effettuate.

____________________________
Durata massima della prova: 6 ore.
È consentito soltanto l’uso dei manuali di riferimento dei linguaggi di programmazione (language reference) e di calcolatrici
scientifiche e/o grafiche purché non siano dotate di capacità di calcolo simbolico.
È consentito l’uso del dizionario bilingue (italiano-lingua del paese di provenienza) per i candidati di madrelingua non
italiana.
Non è consentito lasciare l’Istituto prima che siano trascorse 3 ore dalla consegna della traccia.
