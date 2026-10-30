---
versione_catalogo: 1
id: mim-2016-17-itia-ordinaria-i044
titolo: Seconda prova ITIA 2017 ordinaria
anno_esame: 2017
anno_scolastico: "2016/17"
indirizzo:
  istituto: tecnico
  codice: ITIA
  articolazione: Informatica
disciplina:
  - Informatica
sessione: ordinaria
codice_ministeriale: I044
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Ordinaria/I044_ORD17.pdf
  acquisita_il: "2026-10-30"
riassunto: Seconda prova scritta di Informatica (ITIA 2017 ordinaria).
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
markdown: tracce/mim-2016-17-itia-ordinaria-i044.md
---

# Seconda prova ITIA 2017 ordinaria

## Testo completo (estratto da PDF ministeriale)

Seconda prova scritta




      Ministero dell’Istruzione, dell’ Università e della Ricerca
     I044 – ESAME DI STATO DI ISTRUZIONE SECONDARIA SUPERIORE
                     Indirizzo: ITIA - INFORMATICA E TELECOMUNICAZIONI
                                   ARTICOLAZIONE INFORMATICA

                                 Tema di: INFORMATICA - Tipologia C



  Il candidato (che potrà eventualmente avvalersi delle conoscenze e competenze maturate attraverso
  esperienze di alternanza scuola-lavoro, stage o formazione in azienda) svolga la prima parte della
  prova e due tra i quesiti proposti nella seconda parte.

  PRIMA PARTE

  Un’azienda start-up vuole costruire una piattaforma Web che consenta il car pooling tra viaggiatori
  sul territorio nazionale, con l’obiettivo di diffondere l’uso di una mobilità flessibile e personalizzata
  in termini di percorsi e costi.
  Gli utenti della piattaforma possono essere di due tipi: utenti-autisti (coloro che offrono un passaggio
  con la propria macchina) e utenti-passeggeri (coloro che usufruiscono del passaggio).
  Gli autisti devono registrarsi sul sito ed inserire i propri dati: generalità, numero e scadenza patente
  di guida, dati dell’automobile utilizzata, recapito telefonico, email, fotografia.
  Per ogni viaggio che intendono condividere, gli autisti devono indicare città di partenza, città di
  destinazione, data ed ora di partenza, contributo economico richiesto ad ogni passeggero, tempi di
  percorrenza stimati. È responsabilità dell’autista, mano a mano che accetterà passeggeri per un certo
  viaggio, dichiarare chiuse le prenotazioni per quel viaggio, utilizzando un’apposita funzione sul
  portale.
  L’utente-passeggero si deve registrare sulla piattaforma, indicando cognome e nome, documento di
  identità, recapito telefonico ed email. La piattaforma fornisce ai passeggeri la possibilità di indicare
  città di partenza e di destinazione e data desiderata; presenta quindi un elenco di viaggi (per cui non
  siano ancora chiuse le prenotazioni), ciascuno con le caratteristiche dell’autista e le modalità del
  viaggio stesso inserite dall’autista (orario, eventuali soste previste alle stazioni di servizio, possibilità
  di caricare bagaglio o animali, …).
  Il passeggero sceglie quindi il viaggio desiderato con il corrispondente autista, anche esaminando il
  voto medio e i giudizi dei feedback assegnati tramite la piattaforma dai precedenti passeggeri
  all’autista stesso, e si prenota. Le informazioni sul passeggero vengono inviate per email dalla
  piattaforma all’autista scelto, il quale può consultare sul portale il voto medio e i giudizi dei feedback
  ricevuti dal passeggero da parte di precedenti autisti e decidere se accettarlo o meno. Il passeggero di
  conseguenza riceverà una email di accettazione o di rifiuto della prenotazione effettuata, contenente,
  in caso di accettazione, un promemoria con città di partenza e destinazione, data e orario del viaggio,
  dati dell’autista e della sua automobile.
  A viaggio effettuato, il passeggero può inserire un feedback sull’autista, espresso sia in forma di voto
  numerico che di giudizio discorsivo. A sua volta, l’autista può inserire un feedback sul passeggero,
  espresso sia in forma di voto numerico che di giudizio discorsivo. Sia i voti medi che i singoli giudizi
  dei feedback ricevuti da ciascun autista sono disponibili ai passeggeri; analogamente, sia i voti medi
  che i singoli giudizi dei feedback ricevuti da ciascun passeggero sono disponibili agli autisti.


                                                                   Seconda prova scritta




       Ministero dell’Istruzione, dell’ Università e della Ricerca
       I044 – ESAME DI STATO DI ISTRUZIONE SECONDARIA SUPERIORE
                    Indirizzo: ITIA - INFORMATICA E TELECOMUNICAZIONI
                                   ARTICOLAZIONE INFORMATICA

                                Tema di: INFORMATICA - Tipologia C


  Il candidato, fatte le opportune ipotesi aggiuntive, sviluppi:

   1. un'analisi della realtà di riferimento, giungendo alla definizione di uno schema concettuale della
      base di dati che, a suo motivato giudizio, sia idoneo a gestire la realtà presentata;
   2. il relativo schema logico;
   3. le seguenti interrogazioni espresse in linguaggio SQL:
        a) data una città di partenza, una di arrivo e una data, elencare gli autisti che propongono un
           viaggio corrispondente con prenotazioni non ancora chiuse, in ordine crescente di orario,
           riportando i dati dell’auto e il contributo economico richiesto;
        b) dato il codice di una prenotazione accettata, estrarre i dati necessari per predisporre l’email
           di promemoria da inviare all’utente passeggero;
        c) dato un certo viaggio, consentire all’autista di valutare le caratteristiche dei passeggeri
           visualizzando l’elenco di coloro che lo hanno prenotato, con il voto medio dei feedback
           ricevuti da ciascun passeggero, presentando solo i passeggeri che hanno voto medio
           superiore ad un valore indicato dall’autista;
   4. il progetto di massima della struttura funzionale dell’applicazione Web, realizzando, con
      appropriati linguaggi a scelta sia lato client che lato server, un segmento significativo
      dell'applicazione che consente l'interazione con la base di dati.



  SECONDA PARTE

  I.    In relazione al tema proposto nella prima parte, il candidato integri il modello già realizzato al
        fine di gestire in automatico il numero di posti disponibili nei vari viaggi, evitando che sia
        responsabilità dell’autista dichiarare chiuse le prenotazioni sul portale. Nel momento in cui
        inserisce un viaggio, l’autista dichiara il numero massimo di posti disponibili. Mano a mano che
        gli autisti accettano le prenotazioni, il sistema visualizzerà solo i viaggi con posti ancora
        disponibili: a tal fine, una prenotazione non ancora accettata dall’autista non comporta alcun
        impegno del posto, che resta così ancora disponibile per prenotazioni di altri passeggeri. Per
        ciascun viaggio, la piattaforma mostrerà il numero dei posti disponibili e il numero delle
        prenotazioni non ancora accettate. Il candidato sviluppi poi la pagina web, sia lato client che
        lato server, per fornire ai passeggeri tali informazioni.


                                                                               Seconda prova scritta




        Ministero dell’Istruzione, dell’ Università e della Ricerca
       I044 – ESAME DI STATO DI ISTRUZIONE SECONDARIA SUPERIORE
                         Indirizzo: ITIA - INFORMATICA E TELECOMUNICAZIONI
                                         ARTICOLAZIONE INFORMATICA

                                       Tema di: INFORMATICA - Tipologia C


  II. In relazione al tema proposto nella prima parte, il candidato immagini di volere documentare al
      committente l’operatività della piattaforma proposta. A tal fine, imposti una relazione tecnica che
      presenti le principali caratteristiche dell’applicazione Web in termini di organizzazione e
      funzionalità. In particolare, imposti la struttura di tale relazione, motivando le scelte e scrivendo
      un esempio significativo dei relativi contenuti.
 III. Dato il seguente schema relazionale:
      film (id, titolo, durata, anno di produzione, genere);
      attore (id, nome, cognome, data_nascita, fotografia);
      recita (id_film, id_attore, ruolo);
       il candidato:
          determini la modalità di gestione del campo ‘fotografia’ che prevede la memorizzazione di
            una immagine dell’attore in un formato grafico (es. JPG);
          formalizzi in linguaggio SQL lo schema fisico corrispondente allo schema relazionale,
            sapendo che:
            a. il campo ‘genere’ ammette solo i seguenti valori: fantasy, giallo, commedia, horror,
               drammatico, fantascienza, azione;
            b. per la relazione ‘recita’, i campi ‘id_film’ e ‘id_attore’ referenziano rispettivamente la
               chiave primaria delle relazioni ‘film’ e ‘attore’;
          discuta l’uso degli indici nel modello fisico di una base di dati e suggerisca con motivato
            giudizio indici appropriati per questo schema relazionale, definendoli in linguaggio SQL.
 IV.     Un’azienda desidera sviluppare un’applicazione Web per la prenotazione on-line di eventi
         culturali, fruibile sia da computer desktop che da dispositivi mobili come tablet e smartphone. Il
         candidato esponga i punti critici da affrontare relativamente alle differenti proprietà di
         visualizzazione delle varie tipologie di dispositivi e alla rispettiva fruizione dei contenuti. Illustri
         possibili misure risolutive, con esempi relativi all’applicazione in questione.




___________________________
Durata massima della prova: 6 ore.
È consentito l’uso di manuali tecnici e di calcolatrici tascabili non programmabili.
È consentito l’uso del dizionario bilingue (italiano-lingua del paese di provenienza) per i candidati di madrelingua non italiana.
Non è consentito lasciare l’Istituto prima che siano trascorse 3 ore dalla dettatura del tema.
