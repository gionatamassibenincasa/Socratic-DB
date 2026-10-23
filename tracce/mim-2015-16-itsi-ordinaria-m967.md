---
versione_catalogo: 1
id: mim-2015-16-itsi-ordinaria-m967
titolo: City2City - Collegamenti passeggeri verso città europee
anno_esame: 2016
anno_scolastico: "2015/16"
criterio_anno_scolastico: Attribuito alla sessione d'esame dell'anno solare 2016.
indirizzo:
  istituto: tecnico
  codice: ITSI
  articolazione: Sistemi Informativi Aziendali
disciplina:
  - Informatica
sessione: ordinaria
fonte:
  ente: Ministero dell'Istruzione
  url: https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Ordinaria/M967_ORD16.pdf
  acquisita_il: "2026-10-22"
riassunto: Sistema informativo di una compagnia di autobus GT per collegamenti passeggeri verso città europee, con personale viaggiante, manutenzione dei mezzi e fidelizzazione dei clienti.
stato_diritti: da_verificare
accesso: non_distribuibile_fino_a_verifica
originale: fonti/ministero/M967_ORD16.pdf
markdown: tracce/mim-2015-16-itsi-ordinaria-m967.md
pdf_esportato: null
classificazione_didattica:
  stato: da_valutare
  griglia_di_valutazione: null
  difficolta_modellistica: null
  competenze_query: []
  revisore: null
---

# City2City

## Testo

La compagnia City2City è una società italiana di recente costituzione che offre collegamenti passeggeri diretti verso varie città europee.
City2City si vuole inserire dinamicamente sul mercato del trasporto passeggeri, offrendo un servizio efficiente e a costi contenuti.
Il suo target sono tutti quei soggetti che non amano spostarsi in aereo, non hanno la possibilità di usare un mezzo proprio e desiderano viaggiare comodamente, trasportando facilmente il proprio bagaglio.  

La compagnia, almeno per la fase iniziale di avvio delle attività, ha scelto di offrire collegamenti di andata e di ritorno che partono dalla propria sede operativa, situata in una città di medie dimensioni del centro Italia, e sono diretti ad alcune città europee, raggiungibili in 24 ore di viaggio al massimo.

Si è quindi dotata di un parco di autobus GT (“Gran Turismo”) forniti di differenti livelli di comfort.
La manutenzione degli autobus GT è affidata ad una serie di ditte esterne, e deve essere comunque tenuta sotto attento controllo dalla City2City.
Puntando sulla qualità e sulla sicurezza del servizio  offerto, si è scelto che il personale viaggiante sia costituito da un autista principale ed un secondo 
autista che si alternano alla guida, oltre che da un assistente di viaggio in grado di offrire servizi di cortesia ai passeggeri (es. riviste, frigo bar, noleggio tablet, noleggio videogiochi o film) di cui la City2City periodicamente rifornisce i suoi mezzi.

La compagnia è interessata a fidelizzare i clienti e prevede quindi sistemi di registrazione degli utenti, con tessera virtuale a punti e indagini di mercato di customer satisfaction. Infine, essa intende offrire sistemi di prenotazione on-line.


## Compito

Si richiede, concentrandosi sulla porzione del sistema informativo che gestisce l’attività di trasporto, di sviluppare:

1. un'analisi nomi-verbi del testo per determinare potenziali Entità e Associazioni del dominio con i relativi attributi
2. un glossario di progetto con i termini, la loro descrizione breve, l'identificazione di eventuali omonimi e sinonimi, il ruolo nel modello E/R.
3. uno schema concettuale della relativa base di dati, che dovrà prevedere: 
   1. i collegamenti offerti, registrando per ciascuno la città collegata, il giorno della settimana, l’orario previsto di partenza e di arrivo, se il collegamento è di andata o di ritorno;
   2. il personale viaggiante, del quale oltre ai dati anagrafici interessa il ruolo ricoperto come sopra descritto;
   3. il parco di autobus GT, con i dati identificativi di ciascun mezzo, le relative caratteristiche e i dati necessari a gestirne la manutenzione;
   4. i viaggi effettuati, registrando per ciascuno la data in cui è stato svolto, l’orario effettivo di partenza e di arrivo, il numero dei passeggeri effettivi, l’autobus GT utilizzato e il personale viaggiante impiegato;
   5. i vincoli del sistema.
4. il corrispondente schema logico relazionale; 
5. in linguaggio SQL le query per ottenere le seguenti informazioni:
   1) elenco dei viaggi di andata svolti verso una determinata città, in un intervallo di date fornite in input;
   2) per ciascuna città collegata, calcolare la media del tempo di percorrenza dei viaggi di andata effettuati nel mese di agosto dell’anno corrente. 
6. integrare il modello concettuale della base di dati sviluppata nei punti precedenti inserendo opportunamente un’entità “Cliente”, qualora non già prevista, per effuare operazioni di registrazione online su piattaforma web e per attività di marketing:
   1. definire gli attributi utili alle operazioni di marketing ipotizzate, motivando le scelte  fatte;
   3. derivare lo schema logico aggirnato con le nuove entità e/o attributi;
