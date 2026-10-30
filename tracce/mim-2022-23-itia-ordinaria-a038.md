---
versione_catalogo: 1
id: mim-2022-23-itia-ordinaria-a038
titolo: Seconda prova A038 2023 ordinaria
anno_esame: 2023
anno_scolastico: "2022/23"
indirizzo:
  istituto: tecnico
  codice: ITIA
  articolazione: Informatica
disciplina:
  - Informatica
sessione: ordinaria
codice_ministeriale: A038
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Ordinaria/A038_ORD23.pdf
  acquisita_il: "2026-10-30"
riassunto: Seconda prova scritta di Informatica (A038 2023 ordinaria).
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
markdown: tracce/mim-2022-23-itia-ordinaria-a038.md
---

# Seconda prova A038 2023 ordinaria

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
Una scuola vuole progettare una piattaforma web per la fruizione di educational games (ovvero
videogiochi in ambito educativo), per migliorare l’apprendimento nelle varie materie.
Ciascun docente, una volta completata la registrazione alla piattaforma, può creare una o più
classi virtuali (identificate da un nome e una materia di pertinenza: es. 3B, matematica) e aprire
l’iscrizione alle singole classi ai propri studenti tramite la condivisione del codice iscrizione (link o
QR-code).
Nella piattaforma è presente il catalogo dei videogiochi didattici, classificati in base ad un elenco di
argomenti prestabiliti (es: triangoli, legge di Ohm, verismo …): ciascun docente può selezionare
uno o più videogiochi per includerli in una classe virtuale. Per ogni videogioco è presente un titolo,
una descrizione breve di massimo 160 caratteri, una descrizione estesa, il numero di “monete
virtuali” che si possono raccogliere all’interno del gioco e fino a tre immagini sul gioco.
Uno studente si iscriverà sulla piattaforma alle classi cui è stato invitato (es: 3B matematica, 3B
italiano ...) tramite il relativo codice iscrizione, e all’interno di ciascuna classe troverà i link ai
videogiochi didattici proposti dal docente. Svolgendo ciascun videogioco, lo studente potrà
raccogliere sequenzialmente delle monete tramite quiz o attività da completare. Una moneta è un
riconoscimento che viene assegnato nel videogioco al raggiungimento di determinati traguardi
educativi graduali.
Attraverso il numero di monete, raccolte man mano da uno studente in ciascun videogioco di
quella classe, si può determinare una classifica per ciascun gioco e anche una classifica generale
comprensiva di tutti i giochi della classe; il docente può quindi seguire l’andamento degli studenti e
supportarli individualmente nel completamento della raccolta delle monete.
Il candidato, fatte le opportune ipotesi aggiuntive, sviluppi:
1. un’analisi della realtà di riferimento, giungendo alla definizione di uno schema concettuale
   della base di dati che, a suo motivato giudizio, sia idoneo a gestire la realtà presentata;
2. il relativo schema logico;
3. la definizione in linguaggio SQL di un sottoinsieme delle relazioni della base di dati in cui siano
   presenti alcune di quelle che contengono vincoli di integrità referenziale e/o vincoli di dominio,
   se esistenti;
4. le interrogazioni espresse in linguaggio SQL che restituiscono:
    a) l’elenco in ordine alfabetico dei giochi classificati per uno specifico argomento;
    b) la classifica degli studenti di una certa classe virtuale, in base alle monete raccolte per un
       certo gioco;
    c) il numero di classi in cui è utilizzato ciascun videogioco del catalogo;


    Pag. 2/2                                                             Sessione ordinaria 2023
                                                                         Seconda prova scritta




                                Ministero dell’istruzione e del merito
            A038 - ESAME DI STATO CONCLUSIVO DEL SECONDO CICLO DI ISTRUZIONE

         Indirizzo ITIA - INFORMATICA E TELECOMUNICAZIONI ARTICOLAZIONE "INFORMATICA"
                         (Testo valevole anche per gli indirizzi quadriennali IT32 e ITIT)

                                            Disciplina: INFORMATICA

    5. il progetto di massima della struttura dell’applicazione web per la gestione della realtà sopra
          presentata;
    6. una parte significativa dell'applicazione web che consente l’interazione con la base di dati,
          utilizzando appropriati linguaggi a scelta sia lato client che lato server.

    SECONDA PARTE

    I.    In relazione al tema proposto nella prima parte, si sviluppi, in un linguaggio a scelta, una
          porzione di codice significativa delle pagine web necessarie a presentare la classifica generale
          degli studenti di una certa classe virtuale, in base alle monete raccolte in tutti i videogiochi di
          quella classe.
    II. In relazione al tema proposto nella prima parte, si descriva in che modo è possibile integrare la
        base di dati sopra sviluppata, per gestire anche i feedback da parte degli studenti sui
        videogiochi. Ogni feedback è costituito da un punteggio che può andare da 1 a 5 e una
        descrizione di massimo 160 caratteri. Si descriva anche la struttura delle pagine web dedicate
        a tale funzionalità, scrivendo in un linguaggio a scelta una porzione di codice significativa di
        tali pagine.
    III. Si descriva, anche attraverso esempi, il concetto di “raggruppamento” nelle interrogazioni
         SQL, indicando in tale contesto come operano le funzioni di aggregazione e la clausola
         HAVING.
    IV. Data la seguente tabella “Progetti”, il candidato verifichi se soddisfa le proprietà di
        normalizzazione e proponga uno schema relazionale equivalente che rispetti la terza Forma
        Normale, motivando le scelte effettuate. Si implementi in linguaggio SQL lo schema
        relazionale ottenuto.
ID         Titolo               Budget       Tipo       DataInizio        DataFine          Tutor             TelTutor
1          Pensiero             40.000       PON        20/02/2023        Null              Rossi Mario       345678910
           computazionale
2          Robotica             13.000       PCTO       10/11/2022        30/03/2023        Bianchi           333444555
           educativa                                                                        Carlo
3          Tinkering            25.000       PCTO       14/10/2022        20/02/2023        Bianchi           333444555
                                                                                            Carlo
4          Realtà virtuale      30.000       PCTO       16/02/2023        30/05/2023        Rossi Mario       345678910

____________________________
Durata massima della prova: 6 ore.
È consentito soltanto l’uso dei manuali di riferimento dei linguaggi di programmazione (language reference) e di calcolatrici
scientifiche e/o grafiche purché non siano dotate di capacità di calcolo simbolico.
È consentito l’uso del dizionario bilingue (italiano-lingua del paese di provenienza) per i candidati di madrelingua non
italiana.
Non è consentito lasciare l’Istituto prima che siano trascorse 3 ore dalla consegna della traccia.
