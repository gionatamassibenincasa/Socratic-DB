---
versione_catalogo: 1
id: mim-2018-19-itia-straordinaria-ab42
titolo: Seconda prova AB42 2019 straordinaria
anno_esame: 2019
anno_scolastico: "2018/19"
indirizzo:
  istituto: tecnico
  codice: ITIA
  articolazione: Informatica
disciplina:
  - Informatica
sessione: straordinaria
codice_ministeriale: AB42
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Straordinaria/AB42_STR19.pdf
  acquisita_il: "2026-10-30"
riassunto: Seconda prova scritta di Informatica (AB42 2019 straordinaria).
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
markdown: tracce/mim-2018-19-itia-straordinaria-ab42.md
---

# Seconda prova AB42 2019 straordinaria

## Testo completo (estratto da PDF ministeriale)

Pag. 1/2                                                           Sessione straordinaria 2019
                                                                      Seconda prova scritta




         Ministero dell’Istruzione, dell’ Università e della Ricerca
             ESAME DI STATO DI ISTRUZIONE SECONDARIA SUPERIORE

                        Indirizzo: ITIA - INFORMATICA E TELECOMUNICAZIONI
                                     ARTICOLAZIONE INFORMATICA

                                 Tema di: INFORMATICA e SISTEMI E RETI

Il candidato svolga la prima parte della prova e due tra i quesiti proposti nella seconda parte.

PRIMA PARTE

Un ospedale ha sei reparti distribuiti su tre piani (ogni reparto si sviluppa su un unico piano) e vuole
innovare la sua infrastruttura tecnologica per realizzare servizi interni. Una delle procedure da informatizzare
riguarda la gestione delle terapie mediche prescritte giornalmente ai pazienti ricoverati. In particolare, si
vuole che ogni medico di reparto, dopo avere visitato un paziente, possa collegarsi in modalità wireless ad
un server web interno, dislocato in un locale tecnico, per registrare le seguenti informazioni in una base di
dati:
    • identificativi di medico, reparto, paziente
    • data ed ora della visita
    • annotazioni generali relative allo stato di salute del paziente
    • pressione arteriosa minima e massima, temperatura, frequenza cardiaca
    • eventuale prescrizione terapeutica (uno o più farmaci da assumere e relativa posologia)
Poiché nei reparti non sono mantenute scorte di farmaci, allo stesso server si collegherà anche la farmacia
ospedaliera per predisporre i farmaci da inviare ai reparti per le terapie. Il locale tecnico e la farmacia sono
situati nel piano seminterrato dell’ospedale.
Per ragioni di sicurezza si vuole che:
    • le operazioni siano fatte esclusivamente attraverso tablet forniti ai medici dall’azienda ospedaliera;
    • i medici siano identificati al momento dell’accesso alla rete wireless;
    • i tablet non possano collegarsi a siti web non autorizzati.
Il candidato analizzi la realtà di riferimento e, fatte le opportune ipotesi aggiuntive, individui una soluzione
che a suo motivato giudizio sia la più idonea per sviluppare i seguenti punti:
    1.   il progetto, anche mediante rappresentazioni grafiche, dell’infrastruttura tecnologica necessaria a
         gestire il servizio nel suo complesso, dettagliando:
          − l’architettura di rete in termini di apparati, protocolli adottati, topologia e caratteristiche dei
              collegamenti;
          − il piano di indirizzamento;
          − i servizi di rete che ritiene opportuni, con le configurazioni di massima.
    2.   il progetto della porzione della base di dati finalizzata alla gestione delle prescrizioni terapeutiche:
         si richiede in particolare il modello concettuale e il corrispondente modello logico.
    3.   il progetto delle pagine web che consentono agli operatori della farmacia ospedaliera di visionare
         gli elenchi giornalieri dei farmaci previsti nelle prescrizioni terapeutiche provenienti dai singoli
         reparti, codificandone una porzione significativa in un linguaggio a scelta.


   Pag. 2/2                                                                   Sessione straordinaria 2019
                                                                              Seconda prova scritta




           Ministero dell’Istruzione, dell’ Università e della Ricerca
               ESAME DI STATO DI ISTRUZIONE SECONDARIA SUPERIORE

                           Indirizzo: ITIA - INFORMATICA E TELECOMUNICAZIONI
                                        ARTICOLAZIONE INFORMATICA

                                     Tema di: INFORMATICA e SISTEMI E RETI



SECONDA PARTE

Il candidato risponda a due quesiti a scelta tra quelli sotto riportati.
  I.    In relazione al tema proposto nella prima parte, il candidato integri il progetto (database e pagine
        web) prevedendo la funzione che consente al medico di visualizzare via web sul proprio tablet lo
        storico dei dati relativi a pressione arteriosa massima e minima, temperatura, frequenza cardiaca di
        un dato paziente.

 II.    In relazione al tema proposto nella prima parte, considerando che vengono trattati dati sensibili di
        tipo sanitario, il candidato descriva le possibili soluzioni ed i protocolli utilizzabili per impedire l’uso
        di dispositivi diversi dai tablet forniti al personale medico, per garantire l’accesso solo tramite
        autenticazione delle diverse categorie di utenti, per garantire la continuità ed affidabilità del servizio.

III.    La rivoluzione digitale ha profondamente modificato la gestione delle attività economiche portando
        ad una crescente richieste di servizi di natura informatica. Il candidato, dopo aver analizzato le
        esigenze delle imprese che devono gestire le proprie attività in modalità digitale, presenti i principali
        paradigmi di servizi cloud (XaaS) disponibili, delineando le caratteristiche di ciascuno.

IV.     Considerato il seguente schema logico
        LIBRO (COD_L, TITOLO, NR_PAGINE, PREZZO, ANNO_PUBBL, COD_CE*)
        AUTORE (COD_AU, COGNOME, NOME)
        CASA_EDITRICE (COD_CE, NOME, CITTA)
        SCRIVE (COD_L*, COD_AU*)
        * = chiavi esterne
        si sviluppino in linguaggio SQL le query che consentono di:
        a) visualizzare per ciascuna casa editrice il numero di libri aventi prezzo inferiore a €30 e pubblicati
           nell’anno corrente;
        b) modificare il prezzo di un libro il cui codice è specificato in input.




__________________
Durata massima della prova: 6 ore.
È consentito soltanto l’uso dei manuali dei linguaggi di programmazione (language reference) e di calcolatrici scientifiche e/o
grafiche purché non siano dotate di capacità di calcolo simbolico (O.M. n. 205 Art. 17 comma 9).
È consentito l’uso del dizionario bilingue (italiano-lingua del paese di provenienza) per i candidati di madrelingua non italiana.
Non è consentito lasciare l’Istituto prima che siano trascorse 3 ore dall’inizio della prova.
