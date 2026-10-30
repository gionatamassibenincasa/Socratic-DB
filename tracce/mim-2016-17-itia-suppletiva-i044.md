---
versione_catalogo: 1
id: mim-2016-17-itia-suppletiva-i044
titolo: Seconda prova ITIA 2017 suppletiva
anno_esame: 2017
anno_scolastico: "2016/17"
indirizzo:
  istituto: tecnico
  codice: ITIA
  articolazione: Informatica
disciplina:
  - Informatica
sessione: suppletiva
codice_ministeriale: I044
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Suppletiva/I044_SUP17.pdf
  acquisita_il: "2026-10-30"
riassunto: Seconda prova scritta di Informatica (ITIA 2017 suppletiva).
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
markdown: tracce/mim-2016-17-itia-suppletiva-i044.md
---

# Seconda prova ITIA 2017 suppletiva

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

  Una scuola superiore vuole gestire le assenze degli studenti. Con ‘assenze’ si intendono sia la mancata
  presenza per un giorno intero, sia l’ingresso in ritardo (con relativo orario), sia l’uscita anticipata (con
  relativo orario). A questo scopo, la scuola richiede lo sviluppo di una applicazione Web che utilizza
  un database nel quale sono memorizzate, relativamente all’anno scolastico in corso, le seguenti
  informazioni:
    - per ogni studente il nome, la data di nascita, la classe frequentata, lo username e la password di
       accesso per la consultazione, da parte dello studente e dei suoi genitori, delle assenze personali;
    - le assenze, delle quali si deve registrare la data di effettuazione e la tipologia (giorno intero,
       ingresso in ritardo con relativo orario, uscita anticipata con relativo orario) ed il docente che l’ha
       inserita;
    - le classi dell’istituto, con la tipologia (liceo o tecnico o professionale),
       l’indirizzo/articolazione/opzione di appartenenza (esempio 1: tecnico indirizzo “Informatica e
       Telecomunicazioni” articolazione “Informatica”; esempio 2: professionale indirizzo “Servizi per
       l’enogastronomia e l’ospitalità alberghiera” articolazione “Enogastronomia” opzione “Prodotti
       dolciari artigianali e industriali”; esempio 3: liceo indirizzo “Classico”);
    - le ore di lezione effettivamente svolte dalle classi nel corso dell’anno: per ciascuna ora di lezione
       il docente registra data, ora, materia, argomento trattato. Eventuali docenti co-presenti (es.
       docente di laboratorio, docente di sostegno) firmano la loro presenza in aula accedendo
       autonomamente alla piattaforma con proprio username e password.

  Il candidato, fatte le opportune ipotesi aggiuntive, sviluppi:
    1. un'analisi della realtà di riferimento, giungendo alla definizione di uno schema concettuale della
       base di dati che, a suo motivato giudizio, sia idoneo a gestire la realtà presentata;
    2. il relativo schema logico;
    3. le seguenti interrogazioni espresse in linguaggio SQL:
        a. elencare tutte le assenze dall’inizio dell’anno di un certo studente con la relativa data;
        b. elencare gli studenti che non hanno mai fatto assenze;
        c. visualizzare l’elenco degli studenti che hanno superato un certo numero di ore di assenza,
            riportando cognome, nome e classe di appartenenza;
    4. il progetto di massima della struttura funzionale dell’applicazione Web, realizzando, con
       appropriati linguaggi a scelta sia lato client che lato server, la porzione dell’applicazione che
       consente di gestire l’accesso riservato da parte di uno studente, per visualizzare tutte le proprie
       assenze dall’inizio dell’anno con la relativa data (vedi interrogazione a. del punto 3).


                                                                               Seconda prova scritta




         Ministero dell’Istruzione, dell’ Università e della Ricerca
        I044 – ESAME DI STATO DI ISTRUZIONE SECONDARIA SUPERIORE
                         Indirizzo: ITIA - INFORMATICA E TELECOMUNICAZIONI
                                         ARTICOLAZIONE INFORMATICA

                                       Tema di: INFORMATICA - Tipologia C

       SECONDA PARTE

  I.    In relazione al tema sviluppato nella prima parte, il candidato integri la base di dati in modo da
        tenere conto delle differenti tipologie di soggetti che possono interagire con essa:
          a. studenti/genitori, che devono visualizzare solo le proprie assenze;
          b. docenti, che possono visualizzare e inserire le assenze;
          c. personale di segreteria, che può inserire i dati relativi a nuovi studenti e visualizzare le assenze
             di tutti gli studenti;
        e sviluppi, con appropriati linguaggi a scelta sia lato client che lato server, il codice necessario per
        visualizzare un menu che offra le sole funzioni significative per il profilo dell’utente accreditato.
 II.    In relazione al tema sviluppato nella prima parte, il candidato definisca in linguaggio SQL un
        sottoinsieme delle relazioni della base di dati in cui siano presenti alcune relazioni che contengono
        vincoli di integrità referenziale e/o vincoli di dominio, laddove presenti. Sviluppi inoltre le due
        query seguenti:
          a. il totale delle ore di lezione fatte da ciascun docente per ogni materia che insegna, ordinando
             i dati per docente e materia insegnata;
          b. visualizzare per ciascuna classe la media delle ore di assenza.
III.    Un’associazione del terzo settore vuole gestire l’iscrizione on-line di volontari per un’attività di
        servizio sociale. Il candidato sviluppi, con appropriati linguaggi a scelta sia lato client che lato
        server, il form on-line per la registrazione dei dati di un volontario, che consenta di memorizzare
        username, password, cognome, nome, data di nascita, indirizzo di posta elettronica, numero di
        telefono, posizione lavorativa (lavoratore dipendente, libero professionista, non occupato,
        pensionato, studente). L’associazione vuole che il form preveda sistemi di gestione delle
        condizioni di errore, con modalità che il candidato specificherà (es: definizione dei campi
        obbligatori, l’e-mail deve contenere il carattere ‘@’, la password deve essere composta di un
        numero minimo di caratteri sia numerici che alfanumerici, il numero di telefono può contenere
        solo cifre e il carattere ‘/’, …).
IV.     Il candidato illustri quali sono gli operatori dell’algebra relazionale discutendone le proprietà
        anche attraverso l’uso di esempi riferiti al seguente schema relazionale:
          Testo (id, titolo, genere)
          Editore (id, ragione_sociale, città, data_fondazione, logo)
          Pubblica (id_testo, id_edit, anno_pubblic, prezzo)
        in cui per la relazione ‘Pubblica’, i campi ‘id_testo’ e ‘id_edit’ referenziano rispettivamente la
        chiave primaria delle relazioni ‘Testo’ ed ‘Editore’.
___________________________
Durata massima della prova: 6 ore.
È consentito l’uso di manuali tecnici e di calcolatrici tascabili non programmabili.
È consentito l’uso del dizionario bilingue (italiano-lingua del paese di provenienza) per i candidati di madrelingua non italiana.
Non è consentito lasciare l’Istituto prima che siano trascorse 3 ore dalla dettatura del tema.
