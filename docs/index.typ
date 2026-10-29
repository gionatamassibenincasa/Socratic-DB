// Chapter-based numbering for books with appendix support
#let equation-numbering = it => {
  let pattern = if state("appendix-state", none).get() != none { "(A.1)" } else { "(1.1)" }
  numbering(pattern, counter(heading).get().first(), it)
}
#let callout-numbering = it => {
  let pattern = if state("appendix-state", none).get() != none { "A.1" } else { "1.1" }
  numbering(pattern, counter(heading).get().first(), it)
}
#let subfloat-numbering(n-super, subfloat-idx) = {
  let chapter = counter(heading).get().first()
  let pattern = if state("appendix-state", none).get() != none { "A.1a" } else { "1.1a" }
  numbering(pattern, chapter, n-super, subfloat-idx)
}
// Theorem configuration for theorion
// Chapter-based numbering (H1 = chapters)
#let theorem-inherited-levels = 1

// Appendix-aware theorem numbering
#let theorem-numbering(loc) = {
  if state("appendix-state", none).at(loc) != none { "A.1" } else { "1.1" }
}

// Theorem render function
// Note: brand-color is not available at this point in template processing
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  block(
    width: 100%,
    inset: (left: 1em),
    stroke: (left: 2pt + black),
  )[
    #if full-title != "" and full-title != auto and full-title != none {
      strong[#full-title]
      linebreak()
    }
    #body
  ]
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#f1f3f5")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (x: 2.5cm,y: 2.5cm,),
  numbering: "1",
  columns: 1,
)
// Logo is handled by orange-book's cover page, not as a page background
// NOTE: marginalia.setup is called in typst-show.typ AFTER book.with()
// to ensure marginalia's margins override the book format's default margins
#import "@preview/orange-book:0.7.1": book, part, chapter, appendices

#show: book.with(
  title: [Socratic-DB],
  subtitle: [Tutor socratico per la progettazione di basi di dati relazionali],
  author: "Gionata Massi",
  date: "2026-10-29",
  lang: "it",
  main-color: brand-color.at("primary", default: blue),
  logo: {
    let logo-info = brand-logo.at("medium", default: none)
    if logo-info != none { image(logo-info.path, alt: logo-info.at("alt", default: none)) }
  },
  outline-depth: 3,
  supplement-chapter: "Capitolo",
)


// Reset Quarto's custom figure counters at each chapter (level-1 heading).
// Orange-book only resets kind:image and kind:table, but Quarto uses custom kinds.
// This list is generated dynamically from crossref.categories.
#show heading.where(level: 1): it => {
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: "quarto-float-lst")).update(0)
  counter(figure.where(kind: "quarto-callout-Note")).update(0)
  counter(figure.where(kind: "quarto-callout-Warning")).update(0)
  counter(figure.where(kind: "quarto-callout-Caution")).update(0)
  counter(figure.where(kind: "quarto-callout-Tip")).update(0)
  counter(figure.where(kind: "quarto-callout-Important")).update(0)
  counter(math.equation).update(0)
  it
}

= Introduzione
<introduzione>
#strong[Sommario.]

Questo documento descrive una proposta di strumento e metodologia didattica basata sul metodo socratico, per aiutare gli studenti ad acquisire la capacità di progettare e implementare basi di dati relazionali, dall'analisi concettuale al modello logico. Il processo mira a condurre lo studente a produrre una base di dati completa, pertinente, minimale e intelligibile a partire da una descrizione testuale del problema. La costruzione della conoscenza procede come dialogo tra l'arte della domanda, affidata a modelli linguistici, e il rigore della struttura, verificato mediante controlli logico-simbolici. Le abilità modellistiche e di programmazione sono oggetto di esercizio e feedback durante il percorso; la sperimentazione valuterà l'efficacia della proposta sulla base delle interazioni con il sistema, raccolte e trattate in forma pseudonimizzata secondo le regole definite per lo studio e compatibili con il GDPR e l'IA Act.

#strong[Socratic-DB] è un ambiente di apprendimento assistito dall'Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado (ITE indirizzo #emph[Sistemi Informativi Aziendali] e ITT indirizzo #emph[Informatica]) e per corsi universitari introduttivi di basi di dati.

Il progetto nasce da un principio pedagogico ed epistemologico chiaro: #strong[contrastare la delega cognitiva (#emph[cognitive offloading])] che sta avvenendo con l'uso acritico degli strumenti di #emph[Generative Artificial Intelligence] (GenIA). In questa proposta, il sistema non chiede ai #emph[Large Language Model] (LLM) di risolvere i problemi o scrivere codice al posto dello studente, ma come li fa agire come #strong[tutor socratici]:

+ #strong[La mediazione maieutica è affidata all'LLM]: attraverso domande mirate, controesempi concreti ed elicitazione progressiva dei vincoli (livelli di aiuto graduati da L0 a L4), il tutor guida lo studente nell'individuare errori concettuali e nel motivare formalmente ogni scelta di modellizzazione.
+ #strong[La verità tecnica risiede in controlli deterministici]: l'LLM non valuta la correttezza formale. La validazione sintattica, il calcolo della chiusura degli attributi, la verifica delle forme normali (2NF, 3NF, BCNF) e l'esecuzione di DDL e QL SQL sono affidati a un runtime deterministico e a un esecutore SQLite che opera in memoria.
+ #strong[La valutazione resta prerogativa esclusiva del docente]: il sistema non assegna voti, non stila punteggi né profila gli studenti. La verifica dell'apprendimento effettivo avviene tramite prove individuali in presenza senza ausilio del tutor (#emph[prova di trasferimento]).

== Piani di verifica della sperimentazione
<piani-di-verifica-della-sperimentazione>
La fattibilità e l'efficacia didattica della proposta sono da sperimentare su più piani (il dettaglio metodologico è approfondito nel documento di sperimentazione):

- #strong[Piano del modello linguistico.] Non sappiamo se tra le proprietà emergenti dei LLM ci siano l'abilità maieutica e la capacità elicitativa che desideriamo otterere. #emph[Verifica:] golden set di casi noti (#ref(<sec-test-tutor-llm>, supplement: [Sezione])\; #ref(<sec-disegno-ricerca>, supplement: [Sezione])).
- #strong[Piano dell'infrastruttura di calcolo deterministica.] Un sistema che esegua i controlli e i processi richiesti è complesso: fattibilità e scalabilità non sono stimabili a priori, in assenza di prove empiriche. #emph[Verifica:] test dei controlli deterministici (#ref(<sec-test-controlli-deterministici>, supplement: [Sezione])) e studio pilota su classe di pochi studenti (#ref(<sec-disegno-ricerca>, supplement: [Sezione])).
- #strong[Piano dell'efficacia didattica.] Non è possibile stabilirla a priori: servono test diagnostici pre e post sperimentazione per misurare l'incremento delle prestazioni. #emph[Verifica:] pre-test, post-test e prova di trasferimento (#ref(<sec-disegno-ricerca>, supplement: [Sezione])), analisi dei log di risoluzione di casi da parte degli stessi studenti dopo due o più iterazioni (#emph[follow up]).
- #strong[Piano della progressione didattica.] Il metodo e le fasi appaiono ben definiti per granularità e misurabilità, ma ciò va validato sperimentalmente: la suddivisione attuale potrebbe produrre un lavoro ingestibile per il docente o per lo studente, oppure risultare inefficace o inefficiente. #emph[Verifica:] osservazione nello studio pilota (#ref(<sec-disegno-ricerca>, supplement: [Sezione])) e analisi dei risultati (#ref(<sec-analisi-risultati>, supplement: [Sezione])), test con scala di Likert per docenti e studenti.
- #strong[Piano della sostenibilità per il docente.] Il tempo di preparazione delle tracce e di revisione dei risultati deve essere compatibile con classi numerose e tempi stretti (#ref(<sec-sostenibilita-docente>, supplement: [Sezione])). #emph[Verifica:] misura dei tempi nel pilota, test sull'accetazione del sistema con scala di Likert per docenti (#ref(<sec-raccolta-metriche>, supplement: [Sezione])).

#horizontalrule

== Struttura del documento
<struttura-del-documento>
La documentazione del progetto è strutturata nei seguenti moduli tematici:

- #link("01_stato_dell_arte.md")[Stato dell'arte e inquadramento teorico]: Intelligent Tutoring Systems, Socratic prompting, neuro-simbolico e quadro di ricerca.
- #link("02_quadro_pedagogico.md")[Quadro pedagogico]: destinatari (ITE SIA, ITT Informatica, università), prerequisiti, obiettivi di apprendimento (O1--O8) e ruoli.
- #link("03_protocollo_didattico.md")[Protocollo didattico]: le nove fasi in cinque consegne, livelli di aiuto L0--L4, ciclo di revisione e sostenibilità docente.
- #link("04_architettura_sistema.md")[Architettura del sistema]: orchestratore a stati finiti (FSM), sandbox SQLite isolata, hardware GPU on-premise, system prompt e GitLab CI.
- #link("05_formati_e_schemi.md")[Specifiche dei formati e contratti dati]: specifiche YAML validato per modelli concettuali e relazionali, formati di consegna e report.
- #link("06_normativa_e_sicurezza.md")[Quadro normativo, sicurezza e privacy]: conformità GDPR, AI Act per sistemi scolastici, protezione da prompt injection e limiti noti.
- #link("07_sperimentazione.md")[Protocollo di sperimentazione]: disegno della ricerca, pre/post-test, pilota, metriche e criteri di successo.
- #link("riferimenti.bib")[Bibliografia]: riferimenti in formato BibTeX.

= Stato dell'arte e inquadramento teorico
<sec-stato-arte>
== Introduzione e contesto
<sec-introduzione-contesto>
I modelli linguistici di grandi dimensioni (#emph[Large Language Models], LLM) hanno reso disponibili interfacce conversazionali capaci di produrre spiegazioni, esempi e codice in linguaggio naturale. Nella didattica dell'informatica, questa possibilità apre opportunità per sostenere l'esplorazione e il feedback, ma pone anche questioni relative all'affidabilità delle risposte, al ruolo attivo dello studente e alla valutazione dell'apprendimento @becker2023programming@denny2024computing@prather2023robots. Questi contributi discutono opportunità e criticità dell'IA generativa nell'istruzione e formazione informatica; non dimostrano, da soli, che un particolare modello o assetto didattico migliori gli apprendimenti in ogni contesto.

Nel progetto di basi di dati relazionali, l'attività non si esaurisce nella produzione di una query eseguibile. Richiede di interpretare requisiti, costruire un modello concettuale, tradurlo in uno schema relazionale, esplicitare chiavi e vincoli e formulare interrogazioni coerenti con il significato del problema. Il modello relazionale costituisce un riferimento teorico per la rappresentazione dei dati e delle relazioni tra essi @codd1970relational, mentre il modello Entità/Associazioni è uno dei riferimenti classici, e probabilmente il più utilizzato nella scuola secondaria di secondo grado, per la progettazione concettuale @chen1976entity. La correttezza di una soluzione va quindi esaminata a più livelli: sintassi, proprietà formali dello schema, comportamento delle query e adeguatezza rispetto ai requisiti. Un controllo su un singolo insieme di dati, da solo, non prova la correttezza generale della soluzione.

#strong[Socratic-DB] è una proposta di supporto alla progettazione e all'apprendimento delle basi di dati che combina tre componenti con responsabilità distinte:

+ #strong[Controlli formalizzati], per verificare le proprietà che possono essere espresse in modo deterministico, come vincoli strutturali, alcune proprietà dello schema e risultati dell'esecuzione SQL.
+ #strong[Tutor conversazionale basato su LLM], per porre domande, richiedere motivazioni, proporre controesempi e graduare gli aiuti, senza assumere che il modello segua sempre tali vincoli.
+ #strong[Docente], cui restano il giudizio sulle interpretazioni del dominio, la revisione delle diagnosi non formalizzabili e le decisioni valutative.

L'integrazione di questi componenti è una scelta progettuale, non una prova preventiva di correttezza complessiva o di efficacia didattica. Le domande di ricerca riguardano l'affidabilità dei controlli, la fedeltà del tutor al comportamento atteso, l'apprendimento autonomo e il trasferimento a problemi nuovi. Le ipotesi e il disegno di verifica sono descritti nel #ref(<sec-protocollo-sperimentazione>, supplement: [Capitolo]).

#horizontalrule

== Sistemi di Tutorato Intelligente e didattica dei database
<sec-its-database>
I #emph[Sistemi di Tutorato Intelligente] (#emph[Intelligent Tutoring Systems], ITS) costituiscono un precedente importante per il feedback automatizzato in domini tecnici. In questo ambito, il lavoro su SQL-Tutor di Mitrović illustra l'impiego del #emph[Constraint-Based Modeling] (CBM): il sistema confronta la soluzione dello studente con vincoli disciplinari espliciti e può restituire feedback sulle violazioni individuate @mitrovic1998sql@mitrovic2003cbm. Questo approccio offre un riferimento per rendere espliciti i criteri di controllo. Non implica, tuttavia, che ogni soluzione semanticamente valida possa essere riconosciuta automaticamente, né che lo stesso modello possa essere trasferito senza adattamenti a tutte le fasi della progettazione di una base di dati.

Socratic-DB condivide con gli approcci basati su vincoli l'idea di non affidare ogni giudizio tecnico alla generazione linguistica. La differenza proposta è l'ambito del percorso: oltre alla formulazione di query, il sistema considera analisi dei requisiti, modellazione concettuale, schema relazionale, implementazione e interrogazione. I controlli sono destinati a coprire proprietà esplicitamente formalizzate; la loro copertura effettiva deve essere misurata, e la correttezza semantica rispetto alla traccia non va considerata automaticamente risolta. Le checklist e i casi di prova richiedono definizione, revisione e manutenzione, mentre il docente deve poter riesaminare possibili falsi positivi o soluzioni alternative.

L'esecuzione di query su un database di prova permette di osservare risultati concreti e riproducibili. È però una forma di evidenza circoscritta: una query che produce il risultato atteso su un dataset potrebbe comportarsi diversamente su dati differenti o non rispettare tutti i requisiti. Per questo Socratic-DB propone di affiancare l'esecuzione a controlli strutturali e a un dialogo che chieda allo studente di motivare le proprie scelte, senza trattare nessuna di queste fonti come sufficiente in isolamento.

=== Errori e misconcezioni nella formulazione di query SQL
<sec-errori-sql>
La ricerca sull'apprendimento di SQL analizza difficoltà e misconcezioni che possono emergere mentre gli studenti formulano query. Miedema, Aivaloglou e Fletcher studiano il ragionamento dei principianti attraverso un protocollo #emph[think-aloud] @miedema2021misconceptions\; Taipalus, Siponen e Vartiainen esaminano errori e complicazioni ricorrenti nella formulazione di query @taipalus2018errors. Il lavoro di Miedema sulla formazione sui sistemi di dati offre ulteriore contesto per scomporre i concetti e le difficoltà del dominio @miedema2024learning. Questi studi motivano l'attenzione a diagnosi più specifiche del solo messaggio d'errore del DBMS, ma i risultati ottenuti su compiti SQL non vanno trasferiti automaticamente alla modellazione concettuale o alla progettazione relazionale.

Ponzini, Guerrini e Catania propongono una revisione delle tassonomie degli errori SQL basata sulla rilevazione automatizzata @ponzini2026taxonomy. Questo filone è pertinente alla progettazione di report e categorie d'errore: una classificazione esplicita può rendere le diagnosi più confrontabili e consentire di studiare quali difficoltà ricorrono. La classificazione automatica, tuttavia, non garantisce da sola che una diagnosi sia corretta in ogni caso, che distingua sempre un errore da una soluzione alternativa valida o che il feedback migliori l'apprendimento.

La proposta di Socratic-DB è di usare categorie di errore e controlli formalizzati come supporto al dialogo, non come sostituti del ragionamento dello studente o della revisione del docente. La tassonomia dovrà essere adattata al compito specifico, soprattutto quando il problema riguarda l'interpretazione dei requisiti e non soltanto la sintassi o la semantica di una query.

=== Modelli mentali e spiegazioni dei sistemi di dati
<sec-modelli-mentali-dati>
Miedema et al.~discutono il concetto di #emph[notional machine] per spiegare concetti dei sistemi di dati nell'insegnamento dell'informatica @miedema2025notional. Questo lavoro è pertinente alla scelta di non limitare il feedback alla forma testuale di una query: l'apprendimento richiede anche di costruire e verificare un modello di ciò che la query o lo schema rappresentano e producono. In Socratic-DB, una possibile traduzione progettuale consiste nel chiedere allo studente di prevedere il comportamento di una query, motivare una scelta di schema e poi confrontare la previsione con l'esecuzione o con un controesempio. L'utilità di questa sequenza per il sistema proposto resta un'ipotesi da verificare.

=== Generazione di esercizi SQL con LLM e validazione
<sec-esercizi-sql-llm>
I lavori sulla generazione personalizzata di esercizi SQL con LLM e validazione basata su vincoli @ponzini2026sql@catania2026exercises affrontano un problema vicino, ma distinto, da quello del tutoraggio dialogico: produrre esercizi e controllarne determinate proprietà non equivale a guidare uno studente nella modellazione, nella revisione di una soluzione o nella giustificazione delle scelte. Per Socratic-DB, la lezione progettuale è circoscritta: quando si usa un modello generativo per produrre materiale o spiegazioni, è opportuno esplicitare quali proprietà sono validate e quali rimangono da revisionare.

Un esempio di attività didattica in questo ambito è il laboratorio «Apprendimento di SQL basato su errori frequenti» di Guerrini e Ponzini, pubblicato negli atti ITADINFO 2026 @guerrini2026sqlerrors. Il laboratorio propone attività per far emergere e classificare errori, discutere possibili misconcezioni e usare IA generativa per spiegazioni ed esercizi mirati. Il contributo richiama anche LensQL come tutor e RelaX come strumento per l'algebra relazionale @ponzini2026sql@ponzini2026taxonomy. Si tratta di un antecedente per l'uso didattico dell'analisi degli errori e di strumenti di supporto; la descrizione dell'attività non va interpretata come prova sperimentale dell'efficacia di Socratic-DB o di un tutor LLM nella progettazione completa di basi di dati.

#horizontalrule

== LLM nell'istruzione informatica e tutoraggio dialogico
<sec-llm-istruzione>
=== Opportunità e rischi dell'uso generativo
<sec-cognitive-offloading>
Gli studi sull'IA generativa nell'istruzione alla programmazione discutono opportunità e criticità degli strumenti capaci di produrre direttamente codice o risposte @becker2023programming@denny2024computing@prather2023robots. Il possibile effetto sull'apprendimento dipende dal compito, dal livello dello studente, dal tipo di assistenza e da come viene organizzata l'attività; non è corretto assumere un effetto uniforme in tutti i contesti.

Quando un sistema fornisce direttamente una soluzione completa, esiste il rischio che lo studente accetti il risultato senza saperlo spiegare, verificare o trasferire a un problema diverso. Per Socratic-DB questo è un rischio progettuale da affrontare, non un effetto dato per dimostrato. Per valutarlo si propone di osservare non solo il prodotto finale, ma anche le motivazioni espresse, le revisioni effettuate e la capacità di affrontare una traccia nuova senza assistenza. La prova di trasferimento e il progetto di sperimentazione sono descritti nel #ref(<sec-disegno-ricerca>, supplement: [Sezione]).

=== Tutoraggio dialogico, scaffolding e limiti degli LLM
<sec-scaffolding-socratico>
Bloom discute la differenza tra tutoraggio individuale e istruzione di gruppo e il problema di trasferire i benefici del primo a contesti più ampi @bloom1984two. Vygotskij costituisce un riferimento teorico per il ruolo dell'interazione e della mediazione nell'apprendimento e per il concetto di Zona di Sviluppo Prossimale @vygotsky1978mind. Questi riferimenti forniscono un quadro pedagogico generale; non dimostrano direttamente che un LLM che pone domande socratiche produca gli stessi effetti di un tutor umano, né che il dialogo, da solo, garantisca l'apprendimento.

Macina et al.~studiano opportunità e limiti dei tutor dialogici neurali in compiti di apprendimento linguistico. Gli autori rilevano che le prestazioni sono migliori in scenari didattici vincolati e più deboli in scenari meno circoscritti, e riportano errori di ragionamento in una quota significativa delle conversazioni valutate @macina2023opportunities. Il risultato è rilevante come avvertimento metodologico: un LLM non deve essere considerato un tutor affidabile soltanto perché produce un dialogo plausibile. Il dominio studiato non coincide con la progettazione di basi di dati, quindi le conclusioni non vanno trasferite direttamente a Socratic-DB.

Socratic-DB traduce questi riferimenti in ipotesi di progetto: chiedere allo studente di esplicitare il ragionamento, formulare domande circoscritte, proporre controesempi e graduare il livello di aiuto, evitando per quanto possibile di fornire subito una soluzione completa. Queste regole devono essere valutate separatamente dalla correttezza tecnica: il tutor può non rispettare il comportamento atteso o formulare una diagnosi errata, e la presenza di un prompt non garantisce da sola la conformità. La fedeltà del dialogo, la qualità delle spiegazioni e l'effetto sugli apprendimenti sono pertanto oggetti di verifica distinti.

#horizontalrule

== Architettura ibrida: controlli formali, esecuzione e dialogo
<sec-approccio-neuro-simbolico>
Socratic-DB propone un'architettura ibrida in cui il modello linguistico non è l'unica fonte di giudizio tecnico. I controlli deterministici sono usati solo per proprietà che siano state definite formalmente e implementate; l'esecuzione SQL permette di osservare il comportamento su un insieme di dati specifico; l'LLM sostiene il dialogo e il docente mantiene la responsabilità delle decisioni non automatizzabili. In questo testo, «ibrida» descrive la ripartizione progettuale dei compiti e non implica una garanzia generale di correttezza.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Limite da considerare], [Conseguenza per l'attività], [Scelta progettuale di Socratic-DB],),
  table.hline(),
  [#strong[Risposte linguistiche non affidabili]], [Un LLM può formulare affermazioni errate o non coerenti con la diagnosi tecnica.], [Separare le diagnosi prodotte dai controlli formalizzati dal testo generato dal tutor; sottoporre a verifica le risposte del tutor.],
  [#strong[Verifica limitata al comportamento osservato]], [Una query può produrre il risultato atteso sui dati di prova e fallire su altri dati o requisiti.], [Eseguire query su dati di test progettati per coprire casi significativi e dichiarare esplicitamente l'ambito della verifica.],
  [#strong[Comportamento dialogico non garantito]], [Il modello può fornire la soluzione troppo presto, essere incoerente o assecondare un'affermazione scorretta.], [Definire livelli di aiuto e regole per il tutor, registrare le interazioni e valutare la conformità su casi di prova.],
  [#strong[Controlli incompleti o troppo rigidi]], [Proprietà non formalizzate possono sfuggire; controlli eccessivamente restrittivi possono respingere soluzioni valide.], [Documentare l'ambito di ogni controllo, testare soluzioni alternative e prevedere la revisione del docente.],
  [#strong[Separazione tra prodotto e apprendimento]], [Una soluzione corretta non prova che lo studente sappia giustificarla o riprodurla autonomamente.], [Valutare separatamente il prodotto, il processo di revisione e il trasferimento senza tutor.],
)
La tabella descrive rischi da gestire e decisioni proposte, non risultati sperimentali già ottenuti. In particolare, l'esecuzione in SQLite può verificare che una query sia eseguibile e osservare il suo risultato su dati specifici, ma non dimostra da sola la correttezza rispetto a ogni interpretazione della traccia. Analogamente, i controlli sullo schema possono verificare solo le proprietà coperte dalla loro implementazione e non sostituiscono la revisione semantica del dominio.

#horizontalrule

== Contributo della proposta e questioni aperte
<sec-contributo-questioni-aperte>
Sulla base dei sistemi e dei filoni esaminati, il contributo progettuale che Socratic-DB intende esplorare è l'integrazione, in un unico percorso didattico, di:

- analisi dei requisiti e modellazione concettuale;
- traduzione nello schema relazionale e considerazione dei vincoli;
- generazione o verifica dell'implementazione e dei dati di prova;
- scrittura, esecuzione e revisione di query SQL;
- dialogo guidato da domande, motivazioni e controesempi;
- controlli deterministici per le sole proprietà formalizzate;
- valutazione dell'apprendimento separata dalla valutazione automatica del prodotto.

Non si sostiene che ciascuna componente sia nuova in assoluto. Il valore distintivo da verificare è la loro integrazione nel percorso completo, con una separazione esplicita tra controllo formale, mediazione linguistica e giudizio del docente. Rispetto ai sistemi centrati sulla query, Socratic-DB intende includere anche le fasi precedenti di analisi e progettazione; rispetto agli strumenti di generazione di esercizi, si concentra sul dialogo relativo al tentativo dello studente; rispetto a un LLM usato senza controlli esterni, prevede verifiche formalizzate ed esecuzione SQL; rispetto a un sistema interamente deterministico, usa un modello linguistico per interagire in linguaggio naturale. Queste differenze descrivono l'obiettivo architetturale e didattico, non una superiorità empiricamente dimostrata.

La sperimentazione dovrà distinguere almeno quattro aspetti:

- #strong[Affidabilità tecnica:] quali errori rilevano i controlli, quali soluzioni alternative accettano e quali falsi positivi o negativi producono?
- #strong[Fedeltà del tutor:] il modello rispetta i livelli di aiuto, pone domande pertinenti e non introduce diagnosi errate o soluzioni premature?
- #strong[Apprendimento e trasferimento:] gli studenti migliorano nella progettazione autonoma e riescono a lavorare su una traccia nuova senza tutor?
- #strong[Fattibilità:] i tempi, il carico di revisione per il docente e l'usabilità sono sostenibili nel contesto didattico previsto?

Queste domande richiedono evidenze diverse: un insieme di casi attesi e test negativi per i controlli; revisione umana delle risposte del tutor; prove iniziali e finali, possibilmente accompagnate da una prova di trasferimento; osservazioni di fattibilità. Un miglioramento osservato in un singolo pilota, soprattutto in assenza di un confronto adeguato, non basta a dimostrare che l'effetto sia causato dal tutor. Il protocollo è descritto nel #ref(<sec-protocollo-sperimentazione>, supplement: [Capitolo]).

#horizontalrule

== Quadro normativo e protezione dei dati
<sec-quadro-normativo-scuola>
L'uso di strumenti di IA in contesti scolastici richiede una valutazione del trattamento dei dati personali e delle finalità effettive del sistema. Il GDPR stabilisce principi e obblighi relativi, tra l'altro, a liceità, limitazione delle finalità, minimizzazione, esattezza, conservazione e sicurezza dei dati @gdpr2016. Non è corretto ricavare dal Regolamento un divieto generale di usare qualsiasi fornitore cloud: la liceità e le condizioni del trattamento dipendono dal caso concreto, dalla base giuridica, dai ruoli dei soggetti, dagli accordi applicabili, dalle misure di sicurezza e, quando pertinente, dalle regole sui trasferimenti di dati.

L'articolo 22 del GDPR riguarda determinate decisioni basate unicamente su trattamenti automatizzati che producano effetti giuridici o incidano in modo analogamente significativo sull'interessato, nei limiti e con le eccezioni previste dal Regolamento. Non è quindi corretto descriverlo come un divieto assoluto di ogni decisione automatizzata, né come un generico diritto alla spiegabilità applicabile indistintamente a ogni output di un LLM. In Socratic-DB, la scelta progettuale è che il sistema non assegni voti né sostituisca il docente nelle decisioni valutative; ciò va tradotto in procedure operative coerenti con il contesto istituzionale.

Il Regolamento europeo sull'Intelligenza Artificiale (AI Act) include nell'Allegato III, punto 3, determinate categorie di sistemi destinati all'istruzione e alla formazione professionale, tra cui alcuni sistemi destinati a valutare i risultati dell'apprendimento o a orientare il processo di apprendimento. La classificazione dipende dalla finalità prevista e dall'uso concreto del sistema; non è possibile stabilirla soltanto sulla base del nome del progetto o dell'affermazione che non assegna voti. La qualificazione applicabile a Socratic-DB dovrà essere verificata alla luce del testo normativo e delle disposizioni pertinenti con i referenti istituzionali competenti @eu_ai_act_2024.

L'esecuzione on-premise, se adottata, può ridurre il trasferimento di dati a servizi esterni, ma non costituisce da sola una garanzia assoluta di conformità o riservatezza. Occorre considerare configurazione di rete, autenticazione, autorizzazioni, log, conservazione dei dati, aggiornamenti e procedure di gestione degli incidenti. La minimizzazione dei dati raccolti e l'uso di identificativi non direttamente riconducibili agli studenti, quando appropriato, sono misure da valutare nel quadro complessivo del trattamento, non sostituti degli altri obblighi applicabili.

#horizontalrule

== Sintesi del posizionamento
<sintesi-del-posizionamento>
La letteratura presa in esame offre riferimenti per il feedback basato su vincoli, l'analisi degli errori SQL, la spiegazione dei modelli mentali dei sistemi di dati e l'impiego di LLM nell'istruzione informatica. Non fornisce, nel suo insieme, una prova diretta dell'efficacia di Socratic-DB: i lavori citati riguardano sistemi, compiti e contesti differenti.

La differenza che la proposta intende mettere alla prova è l'integrazione di un percorso che attraversa le principali fasi della progettazione di basi di dati con un tutor dialogico, controlli deterministici circoscritti e un'esecuzione SQL reale, mantenendo espliciti i limiti di ciascun componente e la responsabilità del docente. L'eventuale valore aggiunto dovrà essere stabilito empiricamente rispetto a criteri dichiarati: affidabilità tecnica, qualità del dialogo, apprendimento autonomo, trasferimento e fattibilità didattica.

= Specifica pedagogica
<sec-specifica-pedagogica>
== Destinatari
<sec-destinatari>
Studenti del secondo biennio e del quinto anno di un Istituto Tecnico Economico (ITE), indirizzo «Amministrazione, Finanza e Marketing», articolazione «Sistemi Informativi Aziendali» (SIA, codice ITSI), o di un Istituto Tecnico Tecnologico (ITT), indirizzo «Informatica e Telecomunicazioni», articolazione «Informatica» (codice ITIA), in classi da 5 a 20 persone, con lavoro individuale o a coppie.

Il sistema è progettato tenendo conto dei quadri di riferimento e dei nuclei fondanti della seconda prova scritta dell'Esame di Stato per le discipline d'indirizzo. I quadri di riferimento di ITIA e ITSI includono tra i nuclei la progettazione concettuale, logica e fisica di basi di dati e i linguaggi per basi di dati; la disciplina della seconda prova varia da un anno all'altro e può avere come disciplina di riferimento l'Informatica, come disciplina unica o in associazione a un'altra, oppure un'altra disciplina d'indirizzo. Tali prove frequentemente richiedono di ricavare le specifiche progettuali da una traccia reale, sviluppare la modellizzazione concettuale del problema, tradurla nel modello logico-relazionale, realizzare la base di dati e formulare le query di interrogazione in linguaggio SQL.

La sperimentazione può inoltre essere estesa e adattata come supporto all'auto-apprendimento guidato in un primo corso universitario di «Basi di Dati» (lauree triennali in Informatica o Ingegneria Informatica).

== Prerequisiti
<sec-prerequisiti>
- #strong[Matematica e logica di base]:
  - concetti elementari della teoria degli insiemi (rappresentazione, appartenenza, unione, intersezione, differenza/complementazione, prodotto cartesiano e concetto di relazione);
  - fondamenti di logica proposizionale e predicativa (valori di verità, connettivi logici #NormalTok("NOT");, #NormalTok("AND");, #NormalTok("OR");).
- #strong[Concetti introduttivi di modellizzazione e basi di dati]:
  - comprensione intuitiva del modello concettuale (entità, associazione, attributo, cardinalità min/max e concetti base di gerarchia/specializzazione);
  - strutture del modello relazionale (concetti informali di tabella, riga/tupla, colonna/attributo, chiave primaria, chiave esterna e vincoli fondamentali di integrità).
- #strong[Linguaggio SQL di base]:
  - familiarità elementare con la sintassi SQL per le interrogazioni semplici (clausole #NormalTok("SELECT");, #NormalTok("FROM");, #NormalTok("WHERE");); il consolidamento di interrogazioni complesse (#NormalTok("JOIN");, aggregazioni #NormalTok("GROUP BY"); e sottoquery) è uno degli obiettivi formativi del percorso.
- #strong[Competenze digitali e strumentali]:
  - uso base di un editor di testo o ambiente di sviluppo (IDE) e familiarità con i comandi fondamentali da terminale/CLI;
  - nozioni elementari di Git (#NormalTok("commit");, #NormalTok("push"); e consegne tramite repository).

== Obiettivi di apprendimento
<sec-obiettivi-apprendimento>
Al termine lo studente è in grado di, #strong[autonomamente e senza tutor]:

- #strong[O1.] Ricavare da una traccia i dati, le operazioni e i vincoli (espliciti e impliciti), distinguendo ciò che è dichiarato da ciò che è assunto.
- #strong[O2.] Costruire un modello concettuale Entità/Associazioni (#emph[Entity/Relationship], ER) con entità, attributi, associazioni, cardinalità minime e massime, e motivare ogni scelta.
- #strong[O3.] Distinguere i vincoli rappresentabili nello schema da quelli che richiedono altri meccanismi (#NormalTok("CHECK");, #NormalTok("UNIQUE");, trigger, controllo applicativo).
- #strong[O4.] Tradurre il modello concettuale in schema relazionale scegliendo strategie adeguate per gerarchie, associazioni 1:1 opzionali e obbligatorie, associazioni 1:N e associazioni N:M, trattando i valori nulli e verificando la normalizzazione (1NF, 2NF, 3NF; BCNF se giustificata).
- #strong[O5.] Codificare lo schema usando i costrutti del #emph[Data Definition Language] (DDL) di SQLite, con tipi e vincoli appropriati.
- #strong[O6.] Costruire dati di test significativi, inclusi casi limite, nulli e assenza di corrispondenze, codificandoli con istruzioni del #emph[Data Manipulation Language] (DML) di SQLite.
- #strong[O7.] Scrivere query SQL corrette, verificarle su dati propri e motivarne la correttezza.
- #strong[O8.] Rivedere la propria soluzione a partire da un feedback e giustificare la modifica. Apprendere un modello di sviluppo iterativo in cui la critica di ogni scelta conduce a un modello via via più completo, pertinente, minimale, intelligibile e coerente.

== Ruoli
<sec-ruoli>
=== Docente
<docente>
- Sceglie o inserisce la traccia (dal catalogo o da prove d'esame) e #strong[valida] la checklist dei requisiti proposta dallo strumento d'autore. Facoltativamente fornisce uno schema canonico con dataset e query attese, per il controllo automatico dei risultati nella fase 8. Non scrive soluzioni alternative, dati di riferimento né test.
- Decide la sequenza, i tempi e i livelli di aiuto massimi consentiti per ciascun esercizio, e se abilitare la generazione automatica del DDL (fase 6) e dei dati di test (fase 7).
- Legge le consegne (commit e Merge Request) e il report compatto del processo; legge a campione motivazioni e dialoghi; commenta in modo umano.
- Esamina le segnalazioni di falsi positivi (soluzioni valide respinte) e decide se correggere la checklist o il controllo.
- #strong[È l'unico a esprimere valutazioni.] Conduce la prova individuale di trasferimento.
- Revisiona periodicamente un campione di dialoghi per individuare errori del tutor LLM.

=== LLM (tutor)
<llm-tutor>
- Compito principale: trasformare le #emph[diagnosi strutturate] prodotte dai controlli deterministici in una risposta socratica, al livello di aiuto richiesto dallo stato del dialogo. Le diagnosi sono vincolanti: la LLM non le contraddice.
- Chiede allo studente di motivare le scelte e di riformulare.
- Non assegna punteggi, non dichiara «superato/non superato», non fornisce la soluzione completa, non esegue SQL.
- Dove non c'è diagnosi deterministica (decisioni progettuali e correttezza semantica di cardinalità e query), formula domande e controesempi, dichiarando che esistono più soluzioni accettabili.
- Si comporta come sistema esperto che valuta costantemente, ma fornisce il proprio punto di vista #strong[solo su richiesta] (salvo nella fase 8, dove il parere sul risultato delle query fa parte del dialogo) e dichiarandolo #emph[non vincolante] (a differenza delle diagnosi deterministiche), su:
  - l'eliminazione delle ambiguità terminologiche e semantiche;
  - la completezza rispetto alle specifiche e alla possibilità di formulare le interrogazioni richieste dal testo;
  - la correttezza del modello e dei vincoli, oppure della sintassi, rispetto ai costrutti del modello in uso;
  - la minimalità, intesa come non ridondanza nei modelli e come realizzazione di query efficienti che non richiedono elaborazioni non necessarie;
  - la pertinenza del lessico rispetto al testo e al dominio.
- Procede in modo maieutico ai livelli di aiuto L0--L2 e passa all'elicitazione ai livelli L3--L4.
- Nella fase 7, se il docente abilita la generazione automatica, propone i dati di test (istruzioni INSERT) coerenti con lo schema dello studente; l'output è sempre sottoposto a verifica deterministica.
- Nella fase 8 riceve dall'esecutore il risultato della query sui dati di test e formula un parere non vincolante sulla corrispondenza tra richiesta, query e risultato, trasformandolo in domande (righe attese, mancanti o duplicate); non scrive la query corretta.
- Se incerto, richiede di contattare il docente.

=== Sistema deterministico (orchestratore e controlli)
<sistema-deterministico-orchestratore-e-controlli>
- Mantiene lo stato del percorso, valida i formati, esegue operazioni sullo schema (DDL), sui dati (DML) e sulle query (QL) in SQLite isolato e produce le diagnosi. Deriva dallo schema dello studente i test negativi e la copertura strutturale dei dati di test, verifica i dati proposti dalla LLM nella fase 7 e, se abilitato, genera il DDL dal modello relazionale consegnato. Passa al tutor il risultato delle query. Con lo schema canonico opzionale confronta i risultati con le query attese.

== Verifica dell'apprendimento: prodotto, processo, trasferimento
<sec-verifica-apprendimento>
La qualità della soluzione finale non dimostra che lo studente l'abbia compresa. Si raccolgono evidenze distinte:

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Dimensione], [Evidenza], [Fonte],),
  table.hline(),
  [Qualità progettuale], [Schema corretto, completo, pertinente, minimale], [Controlli deterministici + lettura del docente],
  [Ragionamento], [Motivazioni di cardinalità, chiavi e vincoli], [Campo #NormalTok("motivazione"); nei file + dialogo (lettura del docente)],
  [Revisione], [Correzione autonoma dopo feedback], [Storia dei commit e dei livelli di aiuto richiesti],
  [Competenza SQL], [Query eseguibili e corrette su dati significativi], [Esecuzione automatica sui dati di test; parere non vincolante del tutor],
  [Trasferimento], [Soluzione di una traccia nuova, senza assistenza], [Prova individuale in aula, valutata dal docente],
)
Solo l'ultima riga, insieme alla lettura umana delle altre, concorre alla valutazione scolastica.

== Rischi didattici e contromisure
<sec-rischi-didattici>
- #strong[Tutor come sistema di sblocco.] Chi deve raggiungere una soglia ottimizza il punteggio, non la comprensione. #emph[Contromisura:] nessuna soglia; l'avanzamento è consigliato, non vincolato; i punti aperti restano visibili.
- #strong[Delega del pensiero.] #emph[Contromisura:] ogni consegna richiede una motivazione scritta dallo studente; richiesta di aiuto ai livelli alti registrata; prova finale senza tutor.
- #strong[Giudizi non riproducibili.] #emph[Contromisura:] ogni affermazione sulla correttezza proviene da un controllo deterministico ripetibile.
- #strong[Fiducia eccessiva nel tutor.] #emph[Contromisura:] il tutor dichiara quando non è certo e rimanda al docente.

= Protocollo didattico
<sec-protocollo-didattico>
== Il percorso: nove fasi in cinque consegne
<sec-percorso-consegne>
Il percorso ha #strong[nove fasi] di verifica, raggruppate in #strong[cinque consegne] per contenere il carico di consegna e di tracciamento. Le prime quattro consegne si svolgono con il tutor; la quinta è individuale e senza tutor. Ogni consegna mantiene file e criteri distinti per ciascuna fase che contiene, così lo stato di padronanza resta per competenza. Il percorso distingue progettazione concettuale e logica, chiarisce i vincoli e introduce verifiche effettive dell'esecuzione SQL.

#table(
  columns: (25%, 25%, 25%, 25%),
  align: (auto,auto,auto,auto,),
  table.header([Consegna], [Fasi], [Contenuto], [Automazione],),
  table.hline(),
  [C1. Requisiti e glossario], [1--2], [File di requisiti e glossario], [Controllo deterministico di copertura rispetto alla checklist validata dal docente (termini e sinonimi attesi, definizioni non circolari); il tutor pone le domande],
  [C2. Progettazione concettuale], [3--4], [Modello ER e vincoli del dominio, in sezioni distinte (ogni vincolo con tipo e formulazione)], [Validatore e test di scenario; il tutor conduce l'elicitazione dei vincoli],
  [C3. Progettazione logica e normalizzazione], [5], [Modello relazionale e meccanismo previsto per ciascun vincolo], [Calcolo deterministico delle forme normali; il tutor discute le ridondanze],
  [C4. Implementazione e interrogazione SQL], [6--8], [DDL, dati, query], [Ambiente SQLite isolato con esecuzione immediata e diagnosi; i tre punti di verifica restano distinti],
  [C5. Prova di trasferimento], [9], [Traccia nuova], [Nessuna: prova individuale in aula, valutata dal docente],
)
I criteri di ciascuna fase sono i seguenti:

#table(
  columns: (20%, 20%, 20%, 20%, 20%),
  align: (auto,auto,auto,auto,auto,),
  table.header([\#], [Fase], [Attività dello studente], [Criteri verificabili (esempi)], [Controllo],),
  table.hline(),
  [1], [Requisiti], [Elenca dati da memorizzare, operazioni richieste, vincoli espliciti e impliciti, ambiguità da chiarire], [Copertura delle voci della checklist; vincoli impliciti individuati; ambiguità motivate], [Checklist validata dal docente; domande del tutor],
  [2], [Nomi-verbi e glossario], [Estrae concetti candidati e li definisce senza assumere che ogni nome sia entità e ogni verbo associazione], [Ogni voce ha definizione non circolare; sinonimi/omonimi dichiarati; motivazione della classificazione], [Controllo di presenza e di circolarità semplice; tutor sul resto],
  [3], [Modello concettuale ER], [Entità, attributi, associazioni, cardinalità min/max, identificatori], [Schema valido nel formato; ogni entità ha identificatore; ogni elemento tracciabile a un requisito; cardinalità motivate], [Validatore (struttura); domande e controesempi del tutor sulle cardinalità, non vincolanti],
  [4], [Vincoli del dominio], [Classifica i vincoli: rappresentati nello schema, CHECK/UNIQUE, inter-relazione o temporali (trigger/applicativo)], [Ogni vincolo ha tipo, formulazione non ambigua e meccanismo previsto; i temporali definiscono intervallo, sovrapposizione e concorrenza], [Checklist; tutor conduce l'elicitazione],
  [5], [Modello relazionale], [Applica le regole di traduzione; PK, FK, nullabilità, N:M, gerarchie, 1:1; dipendenze funzionali], [Nessuna FK orfana; PK in ogni tabella; N:M risolte; nulli coerenti con le partecipazioni minime; 1NF/2NF/3NF verificate sulle dipendenze dichiarate], [Validatore + calcolo deterministico delle forme normali],
  [6], [Implementazione SQL (DDL)], [Scrive il DDL SQLite con tipi e vincoli. Se il docente abilita la traduzione automatica, il DDL è generato deterministicamente dal modello relazionale consegnato e lo studente lo analizza e lo commenta], [DDL eseguibile; struttura (#NormalTok("PRAGMA table_info");, #NormalTok("foreign_key_list");) coerente con lo schema relazionale; violazioni attese, derivate dallo schema, rifiutate], [Esecuzione reale + test negativi derivati dallo schema],
  [7], [Popolamento e test], [Scrive INSERT significativi: casi limite, nulli, assenze di corrispondenza. Se il docente abilita la generazione automatica, la LLM propone i dati di test coerenti con lo schema dello studente, che li verifica e li integra con casi propri], [Dati accettati dal DDL; copertura strutturale derivata dallo schema (righe minime per tabella, genitori senza figli, nulli nelle colonne nullabili, valori ripetuti); casi invalidi derivati dallo schema rifiutati], [Esecuzione reale + controlli di copertura derivati dallo schema],
  [8], [Query e verifica], [Scrive, esegue e motiva le query; esamina il risultato ottenuto sui dati di test], [Query eseguibile; risultato esaminato e discusso; motivazione della scelta di JOIN/aggregazione; con schema canonico, risultato uguale all'atteso], [Esecuzione reale + parere non vincolante del tutor sul risultato; confronto con le query attese solo con schema canonico],
  [9], [Prova di trasferimento], [Affronta una traccia nuova, individualmente e senza tutor], [Rubrica del docente per O1--O7], [Docente],
)
=== Sulla generazione automatica
<sulla-generazione-automatica>
Per impostazione predefinita lo studente scrive DDL e INSERT: sono competenze da acquisire (O5, O6). Il docente può abilitare, per singolo esercizio, due scorciatoie:

- #strong[DDL (fase 6):] generato da un #emph[generatore deterministico] (non dalla LLM) a partire dallo schema relazionale, solo dopo che lo schema ha superato le verifiche indipendenti; la struttura ottenuta è poi confrontata con lo schema.
- #strong[Dati di test (fase 7):] la LLM propone le istruzioni INSERT per lo schema dello studente (valori plausibili, senza dati personali reali). Lo script è accettato solo se supera una #emph[verifica deterministica] derivata dallo schema: esecuzione senza errori sul DDL dello studente con chiavi esterne attive, copertura strutturale (righe minime per tabella, genitori senza figli, nulli, valori ripetuti), rifiuto dei casi invalidi. Se la verifica fallisce lo script non è consegnato: si rigenera (fino a un numero massimo di tentativi) oppure si segnala al docente.

Quando una scorciatoia è attiva, la competenza corrispondente non è esercitata in quella consegna e va verificata nella fase 9.

== Errori oggettivi e decisioni progettuali
<sec-errori-decisioni>
Il sistema distingue due classi di rilievi, con trattamento diverso:

- #strong[Errori oggettivamente verificabili] nei file dello studente: formato non valido, FK verso tabella inesistente, tabella senza PK, N:M non risolta, DDL non eseguibile, violazione di un vincolo dichiarato dallo studente nel proprio schema, query non eseguibile, dipendenza funzionale dichiarata che viola la 3NF. Il tutor li segnala con certezza e li guida a correggerli.
- #strong[Decisioni progettuali con più soluzioni corrette:] attributo o entità, strategia di traduzione di una gerarchia, accorpamento o tabella separata per una 1:1, uso di chiave surrogata. Il tutor non dichiara errore; chiede di motivare, mostra le conseguenze con un controesempio e accetta ogni soluzione coerente con i requisiti.
- #strong[Correttezza semantica rispetto alla traccia] (cardinalità, entità, risultato delle query): non è verificata in modo deterministico, salvo l'uso opzionale di uno schema canonico con query attese. Il tutor formula un parere non vincolante, con domande e controesempi; l'accertamento finale spetta alla prova di trasferimento e al docente.

== Livelli di aiuto progressivi
<sec-livelli-aiuto>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Livello], [Forma dell'aiuto], [Quando],),
  table.hline(),
  [L0], [Solo esito dei controlli: area interessata e numero di problemi, senza dettagli], [Primo tentativo],
  [L1], [Domanda mirata sul problema specifico], [Dopo L0 se il problema persiste],
  [L2], [Controesempio dal dominio (dati concreti che violano l'intento)], [Dopo L1 non risolutivo],
  [L3], [Spiegazione del principio applicabile (non della soluzione)], [Dopo L2 o su richiesta],
  [L4], [Esempio svolto parziale su un caso analogo di altro dominio, seguito da un nuovo esercizio autonomo], [Dopo L3 o su richiesta motivata],
)
Regole: l'aiuto sale di un livello alla volta; lo studente può chiedere un livello superiore (la richiesta è registrata, senza penalità); il docente può fissare per esercizio il livello massimo; la soluzione completa non è mai fornita.

== Ciclo di revisione
<sec-ciclo-revisione>
+ Lo studente propone una soluzione e ne spiega il motivo (campo #NormalTok("motivazione");).
+ I controlli deterministici producono le diagnosi; il tutor ne seleziona #emph[una] e pone una domanda mirata.
+ Lo studente rivede la soluzione e giustifica la modifica nel messaggio di commit.
+ Il sistema riesegue i controlli sulla proprietà interessata, con criteri espliciti.
+ Se serve, il tutor passa al livello successivo; al livello L4 propone un esempio parziale e un nuovo esercizio autonomo.

== Padronanza per competenza
<sec-padronanza>
Per ogni competenza (O1--O7) il sistema mostra, non un punteggio, ma lo stato di una checklist di criteri verificabili, con tre stati descrittivi:

- #strong[Da lavorare:] uno o più criteri oggettivi non soddisfatti.
- #strong[In sviluppo:] criteri oggettivi soddisfatti solo con aiuto di livello ≥ L3.
- #strong[Acquisito sotto guida:] criteri soddisfatti con aiuto ≤ L2 e motivazioni presenti.

Questi stati sono #emph[indicatori di processo per lo studente e per il docente], non voti. L'acquisizione effettiva è accertata solo dalla fase 9. L'avanzamento è libero: il tutor può consigliare di tornare su un punto aperto, ma l'unico blocco è tecnico (non si può scrivere il DDL senza uno schema relazionale analizzabile sul piano sintattico dal parser e verificabile sul piano semantico dal validatore).

== Precisazioni tecniche incorporate
<sec-precisazioni-tecniche>
- #strong[Nomi e verbi:] euristica, non algoritmo. La classificazione dipende dal significato nel dominio; il tutor non la «corregge», chiede di motivarla.
- #strong[Gerarchie:] l'eliminazione non è regola universale; si valutano accorpamento nella superclasse, nelle sottoclassi o tabelle separate, in base a copertura, disgiunzione e accessi.
- #strong[Relazioni 1:1:] non si accorpano sempre. Si considerano partecipazione obbligatoria, nullabilità, UNIQUE sulla FK e dipendenze.
- #strong[Normalizzazione:] 1NF, 2NF, 3NF sempre; BCNF solo se giustificata dalla traccia. La 4NF non è richiesta salvo previsione curricolare.
- #strong[Valori nulli:] trattati già nella modellazione (partecipazione minima 0 o 1, attributi opzionali), poi tradotti in NOT NULL o in attributi nullabili.
- #strong[Vincoli temporali:] es. «un medico non può visitare due pazienti nella stessa ora» richiede di definire intervallo (inizio/fine, aperto/chiuso), sovrapposizione e concorrenza. Un CHECK SQLite non può verificare vincoli su più righe: servono UNIQUE su slot discreti, trigger o controllo applicativo, e il test deve verificarlo.

== Metriche separate
<sec-metriche-separate>
+ #strong[Qualità del modello] (calcolata dai controlli): completezza rispetto ai requisiti del docente, correttezza dei controlli oggettivi, minimalità (elementi non tracciabili), pertinenza, forme normali raggiunte.
+ #strong[Qualità della spiegazione] (letta dal docente su campione, con rubrica a 3 livelli): la motivazione cita requisiti, conseguenze, alternative scartate.
+ #strong[Padronanza dello studente:] prova di trasferimento e capacità di revisione (dai commit).

Le tre misure non sono sommate in un punteggio unico.

== Sostenibilità per il docente
<sec-sostenibilita-docente>
Il carico di lavoro è un vincolo di progetto: un protocollo che richiede ore di preparazione per ogni traccia non è applicabile in classi numerose e con tempi stretti. L'automazione riduce solo la preparazione e la lettura; la valutazione resta esclusivamente umana.

=== Pacchetto minimo e pacchetto esteso
<pacchetto-minimo-e-pacchetto-esteso>
Il materiale richiesto al docente è ridotto all'essenziale; il resto si deriva dai file dello studente.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Elemento], [Pacchetto minimo (predefinito)], [Pacchetto esteso (opzionale)],),
  table.hline(),
  [Traccia], [Sì], [Sì],
  [Checklist dei requisiti (5--10 voci), proposta dallo strumento d'autore e validata], [Sì], [Sì],
  [Test negativi e copertura dei dati], [Derivati dallo schema dello studente], [Derivati dallo schema dello studente],
  [Risultato delle query (fase 8)], [Parere non vincolante del tutor su dati di test dello studente o proposti dalla LLM], [Schema canonico, dataset e query attese: controllo deterministico dei risultati, riusabile dal catalogo],
  [Soluzioni alternative e scenari di test], [No], [Solo nel golden set di ricerca],
)
=== Strumento d'autore (AI dietro le quinte)
<strumento-dautore-ai-dietro-le-quinte>
Il docente inserisce la traccia, senza soluzione. Lo strumento propone la checklist dei requisiti e, per il pacchetto esteso, schema canonico, dataset e query attese. Controlli deterministici ne verificano la coerenza interna. Il docente valida o affina il pacchetto, che viene poi congelato e versionato. Il materiale generato da una LLM non è affidabile per sé: la validazione umana è obbligatoria.

=== Catalogo di schemi-tipo
<catalogo-di-schemi-tipo>
Domini ricorrenti (prenotazioni e ticketing, e-commerce, gestione ospedaliera, biblioteca e prestiti) con checklist, errori tipici e, per alcuni domini, schema canonico con dataset e query attese già pronti. Il docente sceglie il modello e lo adatta alla traccia.

=== Tracce iniziali
<tracce-iniziali>
Le prove degli Esami di Stato sono una fonte primaria di tracce. Prima dell'uso, verificare note legali e licenza del sito del Ministero. I PDF riportati sono stati verificati il 22 ottobre 2026. I dati delle tabelle sono mantenuti in #NormalTok("data/tracce_esame.yml"); e #NormalTok("data/materiali_editoriali.yml"); e convertiti automaticamente in Markdown durante la build.

#table(
  columns: (14.29%, 14.29%, 14.29%, 14.29%, 14.29%, 14.29%, 14.29%),
  align: (auto,auto,auto,auto,auto,auto,auto,),
  table.header([Indirizzo], [Anno], [Sessione], [Codice], [Disciplina], [Traccia / dominio nel PDF], [PDF e fonte],),
  table.hline(),
  [ITC -- Programmatori], [2005], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Gestione corsi e iscrizioni di una palestra], [#link("fonti/prove-di-esempio/2005_M733_ITC_ordinaria_palestra.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2005/tecnica/M733.pdf")[Ministero]],
  [ITC -- Programmatori], [2007], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Studio medico associato: medici, visite, pazienti e prestazioni], [#link("fonti/prove-di-esempio/2007_M733_ITC_ordinaria_studio-medico.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2007/M733.PDF")[Ministero]],
  [ITC -- Programmatori], [2009], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Casa editrice di riviste specialistiche, abbonati e punti vendita], [#link("fonti/prove-di-esempio/2009_M733_ITC_ordinaria_riviste.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2009/M733.pdf")[Ministero]],
  [ITC -- Programmatori], [2011], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Agenzia immobiliare e affitti brevi con prenotazioni online], [#link("fonti/prove-di-esempio/2011_M733_ITC_ordinaria_affitti-brevi.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2011/M733.pdf")[Ministero]],
  [ITC -- Programmatori], [2013], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Biglietteria online per un museo e le sue esposizioni], [#link("fonti/prove-di-esempio/2013_M733_ITC_ordinaria_biglietteria-museo.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2013/allegati/M733.pdf")[Ministero]],
  [ITIA -- Informatica], [2015], [Simulazione / esempio], [M963\*], [Informatica], [Consorzio caseario: produzione, vendite e caseifici], [#link("fonti/prove-di-esempio/2015_M963_simulazione_consorzio-caseario.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Esempio%20di%20prova/M963_SIM.pdf")[Ministero]],
  [ITIA -- Informatica], [2015], [Ordinaria], [M963], [Informatica], [Web community per condividere e commentare eventi dal vivo], [#link("fonti/prove-di-esempio/2015_M963_ordinaria_web-community-eventi.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Ordinaria/M963_ORD.pdf")[Ministero]],
  [ITIA -- Informatica], [2015], [Suppletiva], [M963], [Informatica], [Rete di centri e prestito di risorse multimediali], [#link("fonti/prove-di-esempio/2015_M963_suppletiva_prestito-risorse-multimediali.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Suppletiva/M963_SUP.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Esempio di prova], [M967], [Informatica], [Azienda di abbigliamento e tracciamento dei capi nei punti vendita], [#link("fonti/prove-di-esempio/2016_M967_esempio_ITSI_tracciabilita-abbigliamento.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Esempio%20di%20prova/M967_SIM16.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Ordinaria], [M967], [Informatica], [---], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Ordinaria/M967_ORD16.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Straordinaria], [M967], [Informatica], [---], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Straordinaria/M967_STR16.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Suppletiva], [M967], [Informatica], [---], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Suppletiva/M967_SUP16.pdf")[Ministero]],
  [ITIA -- Informatica], [2017], [Ordinaria], [I044], [Informatica], [Piattaforma web di car pooling], [#link("fonti/prove-di-esempio/2017_I044_ordinaria_carpooling.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Ordinaria/I044_ORD17.pdf")[Ministero]],
  [ITIA -- Informatica], [2017], [Suppletiva], [I044], [Informatica], [Applicazione web per la gestione delle assenze scolastiche], [#link("fonti/prove-di-esempio/2017_I044_suppletiva_assenze-scolastiche.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Suppletiva/I044_SUP17.pdf")[Ministero]],
  [ITIA -- Informatica], [2017], [Straordinaria], [I044], [Informatica], [Piattaforma per candidature a una manifestazione culturale], [#link("fonti/prove-di-esempio/2017_I044_straordinaria_manifestazione-culturale.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Straordinaria/I044_STR17.pdf")[Ministero]],
  [ITIA -- Informatica], [2018], [Ordinaria], [I044], [Informatica], [---], [#link("https://www.istruzione.it/esame_di_stato/201718/Istituti%20tecnici/Ordinaria/I044_ORD18.pdf")[Ministero]],
  [ITIA -- Informatica], [2018], [Suppletiva], [I044], [Informatica], [---], [#link("https://www.istruzione.it/esame_di_stato/201718/Istituti%20tecnici/Suppletiva/I044_SUP18.pdf")[Ministero]],
  [ITIA -- Informatica], [2018], [Straordinaria], [I044], [Informatica], [---], [#link("https://www.istruzione.it/esame_di_stato/201718/Istituti%20tecnici/Straordinaria/I044_STR18.pdf")[Ministero]],
  [ITIA -- Informatica], [2019], [Ordinaria], [---], [Informatica e Sistemi e Reti], [Servizio multimediale per punti di interesse turistici], [#link("fonti/prove-di-esempio/2019_ITIA_ordinaria_POI-turistici.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Ordinaria/AB42_ORD19.pdf")[Ministero]],
  [ITIA -- Informatica], [2019], [Suppletiva], [---], [Informatica e Sistemi e Reti], [Azienda di assistenza hardware/software e consulenza informatica], [#link("fonti/prove-di-esempio/2019_ITIA_suppletiva_assistenza-informatica.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Suppletiva/AB42_SUP19.pdf")[Ministero]],
  [ITIA -- Informatica], [2019], [Straordinaria], [---], [Informatica e Sistemi e Reti], [Sistema ospedaliero per la gestione delle terapie dei pazienti], [#link("fonti/prove-di-esempio/2019_ITIA_straordinaria_terapie-ospedaliere.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Straordinaria/AB42_STR19.pdf")[Ministero]],
  [ITIA -- Informatica], [2023], [Ordinaria], [A038], [Informatica], [Piattaforma scolastica per educational games], [#link("fonti/prove-di-esempio/2023_A038_ordinaria_giochi-educativi.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Ordinaria/A038_ORD23.pdf")[Ministero]],
  [ITIA -- Informatica], [2023], [Suppletiva], [A038], [Informatica], [Servizio di accesso a una rete di palestre per utenti in viaggio], [#link("fonti/prove-di-esempio/2023_A038_suppletiva_rete-palestre.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Suppletiva/A038_SUP23.pdf")[Ministero]],
)
Nel PDF di simulazione ministeriale del 2015 il codice M963 compare nel nome del file, non nel testo della prova (\*). Nei PDF del 2019 non è riportato un codice nel frontespizio; per questo non ne è indicato uno. Le voci i cui URL ministeriali restituivano un errore 404 sono state escluse finché non sarà disponibile una fonte funzionante.

Anche materiali editoriali e soluzioni possono essere utili per preparare esercizi e confrontare svolgimenti; quando una risorsa contiene la soluzione, non va confusa con una traccia inedita né usata come prova di trasferimento.

#table(
  columns: (25%, 25%, 25%, 25%),
  align: (auto,auto,auto,auto,),
  table.header([Editore / Fonte], [Anno], [Contenuto], [Risorsa],),
  table.hline(),
  [Zanichelli], [2019], [Prova ministeriale ordinaria e svolgimento Zanichelli: servizio multimediale per punti di interesse turistici], [#link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/AB42_ORD19.pdf")[Testo della prova] · #link("fonti/prove-di-esempio/Zanichelli_Esame_2019_svolgimento.pdf")[Svolgimento locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Esame_2019_svolgimento.pdf")[Zanichelli]],
  [Zanichelli], [2017], [Svolgimento della prova ministeriale ordinaria sul car pooling], [#link("fonti/prove-di-esempio/Zanichelli_Soluzione_Informatica_2017.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Soluzione_Informatica_2017.pdf")[Zanichelli]],
  [Zanichelli], [2017], [Simulazione sul sistema di prenotazione di visite guidate: testo e svolgimento riservato ai docenti], [#link("fonti/prove-di-esempio/Zanichelli_Simulazione_Informatica_Testo_2017.pdf")[Testo] · #link("fonti/prove-di-esempio/Zanichelli_Simulazione_Informatica_Svolgimento_2017.pdf")[Svolgimento riservato]],
  [Zanichelli], [2016], [Simulazione di Informatica sulla gestione del traffico merci di un terminal marittimo: testo e svolgimento riservato ai docenti], [#link("fonti/prove-di-esempio/Zanichelli_Informatica_Simulazione_dicembre2016.pdf")[Testo] · #link("fonti/prove-di-esempio/Zanichelli_Informatica_Simulazione_Svolgimento_dicembre2016.pdf")[Svolgimento riservato]],
  [Zanichelli], [2015], [Prova ministeriale ordinaria sulla web community per eventi dal vivo, con svolgimento Zanichelli], [#link("fonti/prove-di-esempio/2015_Zanichelli_Esame_Informatica.pdf")[PDF locale] · #link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Ordinaria/M963_ORD.pdf")[Ministero]],
  [Zanichelli], [2015], [Simulazione sulla gestione di un consorzio caseario, con svolgimento], [#link("fonti/prove-di-esempio/2015_Zanichelli_simulazione_consorzio-caseario_svolgimento.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici/wp-content/uploads/Zanichelli_Soluzione_Simulazione_2Prova_Informatica.pdf")[Zanichelli]],
  [Zanichelli], [2013], [Traccia d'esame di Informatica ABACUS: controlli passeggeri e merci in aeroporto], [#link("fonti/prove-di-esempio/2013_Zanichelli_Formichi_Tema_Esame_completa.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2013_completa.pdf")[Zanichelli]],
  [Zanichelli], [2011], [Traccia d'esame di Informatica ABACUS: censimento di fauna e flora nei parchi naturali], [#link("fonti/prove-di-esempio/2011_Zanichelli_Formichi_Tema_Esame.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2011.pdf")[Zanichelli]],
  [Zanichelli], [2008], [Traccia d'esame di Informatica ABACUS: gestione delle Olimpiadi Internazionali di Informatica], [#link("fonti/prove-di-esempio/2008_Zanichelli_Formichi_Tema_Esame.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2008.pdf")[Zanichelli]],
  [Zanichelli], [2003], [Traccia d'esame di Informatica ABACUS: gestione delle attività di un vivaio], [#link("fonti/prove-di-esempio/2003_Zanichelli_Formichi_Tema_Esame.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2003.pdf")[Zanichelli]],
  [Zanichelli], [2002], [Traccia d'esame di Informatica ABACUS: gestione di una Banca del Tempo], [#link("fonti/prove-di-esempio/2002_Zanichelli_Formichi_Tema_Esame.pdf")[PDF locale] · #link("https://online.scuola.zanichelli.it/provatecnici-files/Informatica/Zanichelli_Formichi_Tema_Esame_2002.pdf")[Zanichelli]],
  [Zanichelli], [Archivio], [Pagina Informatica con prove e svolgimenti; alcuni materiali sono riservati ai docenti], [#link("https://online.scuola.zanichelli.it/provatecnici/informatica/")[Archivio prove]],
  [Hoepli], [2026], [Prove e proposte di simulazione per ITT Informatica e Sistemi e reti], [#link("https://www.hoeplieditore.it/storage/app/uploads/public/699/83a/8c2/69983a8c24f84650292718.pdf")[PDF ITT Informatica] · #link("https://www.hoeplieditore.it/scuola/notizia/didattica-digitale-integrata/materiali-la-prova-di-maturita")[Pagina dei materiali]],
  [Edizioni Atlas], [2026], [Guida alle prove della Maturità e indicazioni per consultare le tracce degli anni precedenti sul sito del Ministero], [#link("https://www.edatlas.it/it/magazine/cosa-ce-di-nuovo/maturita-esame-2026")[Guida all'Esame di Maturità]],
)
I materiali caricati e contrassegnati come copie riservate ai docenti sono destinati esclusivamente all'area ad accesso ristretto: non pubblicare questi file né l'output Quarto che li include su un sito accessibile senza autenticazione. Le pagine Hoepli e Atlas sono risorse informative, non prove editoriali autonome. Le vecchie pagine di Rizzoli Education, Mondadori Education, SEI ed Edizioni Atlas indicate in precedenza non identificavano materiali specifici accessibili o non sono più raggiungibili e non sono state ripristinate. La pagina attuale di Rizzoli reperita riguarda un webinar del 2025, non una traccia o un PDF di esercizi.

Per la fase 9 non si usano tracce pubbliche di cui circolano soluzioni online (e che una LLM può aver visto in addestramento): si adattano (dominio, requisiti, vincoli) o se ne scrivono di inedite.

=== Report compatto
<report-compatto>
Per lo studente e per il docente: indicatori fattuali per fase (tentativi per tipo di diagnosi, livello di aiuto massimo richiesto), prodotti dai controlli deterministici e non da un giudizio della LLM. Esempio: «3 tentativi con diagnosi 3NF\_VIOLATA nella fase 5». Nessun punteggio e nessuna inferenza sulla competenza; il report non è utilizzabile a fini valutativi.

=== Pre-screening delle motivazioni
<pre-screening-delle-motivazioni>
Nel prototipo, regole deterministiche (lunghezza minima, assenza di riferimenti a elementi dello schema o ai requisiti, testo identico a quello di altri studenti) segnalano al docente i casi da leggere per primi. Il docente legge comunque un campione casuale, per non basarsi solo sulle segnalazioni. Un classificatore basato su modello è rinviato al sistema avanzato.

=== Ipotesi di carico (da misurare nel pilota)
<ipotesi-di-carico-da-misurare-nel-pilota>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Attività del docente], [Ipotesi con strumento d'autore e catalogo], [Misura nel pilota],),
  table.hline(),
  [Preparazione di una traccia], [Scelta o inserimento della traccia e validazione della checklist (pacchetto minimo): 20--30 minuti], [Minuti di validazione per traccia],
  [Lettura dei risultati], [Report compatto, casi segnalati e un campione di motivazioni e dialoghi], [Minuti per classe e per consegna],
  [Riferimento: preparazione manuale senza strumento], [4--6 ore per traccia (stima del proponente)], [Da rilevare su un campione di docenti],
)
La stima non è un risultato: tempi di preparazione e di revisione sono misure del pilota.

= Architettura del sistema e prototipo tecnico
<sec-architettura-sistema>
== Principi architetturali
<sec-principi-architetturali>
- #strong[Open source, on-premise, senza servizi esterni]: L'intera catena di elaborazione risiede sull'hardware dell'istituto scolastico per garantire la sovranità dei dati e la conformità al GDPR.
- #strong[Agenti semplici con responsabilità singola]: Le decisioni sulla correttezza sintattica e formale sono rigorosamente deterministiche; l'LLM si occupa esclusivamente della mediazione maieutica e del dialogo.
- #strong[Un solo formato testuale strutturato]: Formato YAML validato tramite JSON Schema per modelli concettuali e relazionali.
- #strong[Consegna e feedback tramite repository Git]: Flussi di lavoro basati su commit incrementali e pipeline CI per tracciare il processo di revisione.

== Architettura del prototipo
<sec-architettura-prototipo>
#Skylighting(([#NormalTok("[Studente] --testo/YAML--> [Interfaccia unica: Open WebUI o CLI/FastAPI]");],
[#NormalTok("                                   |");],
[#NormalTok("                                   v");],
[#NormalTok("                        [Orchestratore (Python, FSM)]");],
[#NormalTok("              stato del percorso, livello di aiuto, log pseudonimi");],
[#NormalTok("                 |                    |                      |");],
[#NormalTok("                 v                    v                      v");],
[#NormalTok("      [Validatori YAML]     [Esecutore SQLite]      [Tutor LLM (1 modello)]");],
[#NormalTok("  schema, FK, PK, forme    isolato, in memoria,      riceve diagnosi, risultati");],
[#NormalTok("  normali (deterministici) dati di test              delle query e livello di aiuto");],
[#NormalTok("                           dello studente");],
[#NormalTok("                 +---- diagnosi strutturate e risultati ----+");],));
=== Flusso operativo
<flusso-operativo>
+ Lo studente consegna un file (tramite commit/MR o interfaccia web).
+ L'orchestratore valida la sintassi e la conformità allo schema atteso.
+ Vengono eseguiti i controlli deterministici (integrità referenziale, normalizzazione, esecuzione su SQLite isolato) e costruite le diagnosi strutturate.
+ Il tutor LLM riceve le sole diagnosi e il livello di aiuto corrente, trasformandole in una risposta socratica conforme alle regole pedagogiche.
+ L'orchestratore applica un filtro di sicurezza (controllo di non-fuga della soluzione) e restituisce la risposta allo studente.

== Hardware e scelta del modello
<sec-hardware-modello>
Configurazione di riferimento per il server locale: #strong[macchina Linux con 64 GB di RAM e GPU da 32 GB di VRAM].

- #strong[Runtime di inferenza:] Ollama (per semplicità di setup locale) oppure llama.cpp / vLLM (per massimo controllo, throughput e concorrenza); esposizione di API standard compatibile OpenAI su #NormalTok("localhost");.
- #strong[Modello linguistico unico:] Un solo modello linguistico con provate capacità di coding e ragionamento in lingua italiana e licenza permissiva (es. Apache 2.0). Il modello deve essere quantizzato per risiedere interamente nei 32 GB di VRAM (indicativamente modelli da \~30B parametri con quantizzazione a 4--5 bit e contesto utile di 16--32k token).
- #strong[Candidati per il confronto sul golden set:]
  - #NormalTok("gpt-oss-20b"); (Apache 2.0);
  - Modelli della famiglia Qwen 2.5 / 3 (30--32B parametri);
  - Modelli open weights equivalenti con forte supporto SQL e logica. La scelta finale è guidata empiricamente dai risultati sul golden set (#ref(<sec-test-sistema>, supplement: [Sezione])), non dalla notorietà.
- #strong[Parametri di inferenza:] Temperatura bassa ($T approx 0.1 - 0.2$) e seed fisso nei test di conformità per massimizzare la riproducibilità.
- #strong[Concorrenza:] Gestione di una coda FIFO con priorità singola GPU; con 5--20 studenti a ritmo di riflessione e digitazione, la latenza per turno di dialogo resta nell'ordine di pochi secondi.
- #strong[Visione artificiale:] Esclusa dal prototipo iniziale; demandata al sistema avanzato (#ref(<sec-sistema-avanzato>, supplement: [Sezione])).

== Esecutore SQLite isolato
<sec-esecutore-sqlite>
Requisiti di isolamento e sicurezza per l'esecuzione di DDL, popolamento e query dello studente:

- #strong[Isolamento a livello OS:] Processo separato in container Docker senza rete (#NormalTok("--network none");), utente senza privilegi (#NormalTok("nobody");/#NormalTok("runner");), filesystem montato in sola lettura ad eccezione di una directory #NormalTok("/tmp"); volatile; in alternativa, #NormalTok("subprocess"); vincolato con limiti rigidi di sistema (#NormalTok("rlimit"); su CPU time, RSS memory e disk quota).
- #strong[Database in memoria:] Utilizzo di database SQLite #NormalTok(":memory:"); (o file temporaneo distrutto al termine dell'elaborazione); una nuova istanza pulita per ciascun tentativo.
- #strong[Integrità referenziale attiva:] Esecuzione obbligatoria di #NormalTok("PRAGMA foreign_keys = ON;");.
- #strong[Modalità sola lettura per la verifica delle query:] #NormalTok("PRAGMA query_only = ON;"); o apertura della connessione in #NormalTok("mode=ro"); durante la fase 8.
- #strong[Autorizzatore SQLite attivo (#NormalTok("set_authorizer");):] Blocco categorico di istruzioni pericolose come #NormalTok("ATTACH DATABASE");, #NormalTok("DETACH DATABASE");, caricamento di estensioni native (#NormalTok("load_extension");), comandi di #NormalTok("PRAGMA"); non autorizzati e operazioni di scrittura al di fuori delle fasi di DDL e popolamento.
- #strong[Timeout e quote:] Limite di timeout stringente (es. massimo 2 secondi per query) e limite al numero di tuple restituite (max 100 righe) per prevenire blocchi da loop o prodotti cartesiani involontari.
- #strong[Visibilità dei dati:] Lo studente esegue le proprie query esclusivamente sul proprio dataset di test. Se il docente attiva uno schema canonico con dataset di riferimento, quest'ultimo rimane completamente invisibile allo studente (il sistema notifica solo l'eventuale discrepanza o prima differenza riscontrata).

== Test automatici del sistema
<sec-test-sistema>
Il sistema integra tre famiglie di test automatici eseguibili in #NormalTok("pytest"); e nella pipeline CI/CD:

=== Test dei controlli deterministici
<sec-test-controlli-deterministici>
- #strong[Validatore sintattico e semantico:] File YAML validi e casi di test negativi per ciascuna regola (FK orfane, PK mancanti, associazioni N:M non tradotte in tabelle ponte).
- #strong[Calcolo delle forme normali:] Test con insiemi di dipendenze funzionali note per verificare il calcolo algebrico della chiusura degli attributi e la rilevazione di violazioni di 2NF, 3NF e BCNF.
- #strong[Robustezza del sandbox:] Verifica che tentativi di attacco (injection di #NormalTok("ATTACH");, loop di ricorsione CTE, esaurimento memoria) vengano bloccati dall'autorizzatore e terminati per timeout.
- #strong[Coerenza DDL ↔ Modello relazionale:] Verifica deterministica che le tabelle, colonne, indici e vincoli creati in SQLite (#NormalTok("PRAGMA table_info");, #NormalTok("PRAGMA foreign_key_list");) coincidano perfettamente con lo schema relazionale dichiarato nello YAML.
- #strong[Derivazione automatica dei test negativi:] Generazione deterministica di casi di test che violano vincoli di integrità dichiarati (duplicazione PK, violazione NOT NULL, violazione CHECK).

=== Test sugli esercizi (Golden set di ricerca e schema canonico)
<sec-test-esercizi>
- #strong[Checklist dei requisiti:] Verifica che la copertura semantica dei termini sia rilevata correttamente sia su soluzioni esaustive sia su consegne parziali.
- #strong[Golden set di ricerca:] Insieme calibrato di tracce con soluzioni multiple valide e soluzioni errate ottenute per mutazione deterministica (es. rimozione di una chiave esterna, cardinalità invertita, vincolo omesso), ciascuna con la corrispondente diagnosi attesa.
- #strong[Schema canonico:] Esecuzione delle query attese sul dataset di riferimento con confronto tra insiemi di risultati.

=== Test del tutor LLM (Golden set)
<sec-test-tutor-llm>
- #strong[Casi di test:] Almeno 30 casi per ciascuna fase (soluzione corretta, soluzione con errore tipico, soluzione alternativa valida e non convenzionale).
- #strong[Assenza di contraddizioni:] Il tutor non deve mai smentire una diagnosi deterministica né segnalare errori fittizi su varianti valide.
- #strong[Aderenza al livello di aiuto:] A livello L1 il messaggio deve contenere solo domande; controesempi sono ammessi solo da L2; spiegazioni del principio solo da L3; nessun codice risolutivo completo a nessun livello.
- #strong[Filtro di non-fuga della soluzione:] Verifica automatica che la risposta del tutor non contenga blocchi di codice completi o query risolutive; in caso di violazione, la risposta è rigettata e rigenerata con un prompt di ammonimento.
- #strong[Valutazione semantica su query (fase 8):] Misura dell'accuratezza del parere non vincolante del tutor rispetto a valutatori umani su un corpus di query con errori tipici (filtro errato, JOIN incompleta, raggruppamento assente).
- #strong[Validazione umana e accordo inter-valutatore:] Revisione in cieco su un campione di risposte da parte di docenti con calcolo dell'indice Kappa di Cohen.

=== Verifica deterministica dei dati di test generati dalla LLM (fase 7, se abilitata)
<sec-verifica-dati-generati>
Quando il docente abilita la generazione assistita dei dati: - Lo script SQL generato deve essere composto unicamente da istruzioni #NormalTok("INSERT");. - Esecuzione obbligatoria senza errori sul DDL dello studente con #NormalTok("PRAGMA foreign_keys = ON;");. - Verifica della copertura strutturale minima derivata dallo schema: numero minimo di righe per tabella, presenza di almeno un'istanza genitore priva di figli, presenza di valori nulli nelle colonne opzionali, valori ripetuti per consentire test di aggregazione (#NormalTok("GROUP BY"); e #NormalTok("COUNT");). - I casi invalidi generati per test negativo devono fallire l'inserimento.

== System prompt del tutor (Versione per il prototipo)
<sec-system-prompt>
#Skylighting(([#NormalTok("Sei DB-Socrates, tutor di Basi di Dati. Ricevi in ingresso: (1) la fase corrente,");],
[#NormalTok("(2) il file consegnato dallo studente, (3) un elenco di DIAGNOSI prodotte da");],
[#NormalTok("controlli automatici, (4) il LIVELLO DI AIUTO consentito (L0-L4),");],
[#NormalTok("(5) le eventuali SCORCIATOIE abilitate dal docente (DDL, DATI),");],
[#NormalTok("(6) in fase 8, il RISULTATO della query sui dati di test.");],
[],
[#NormalTok("Regole:");],
[#NormalTok("- Le diagnosi sono la verita tecnica: non contraddirle e non aggiungerne.");],
[#NormalTok("- Scegli UNA diagnosi alla volta e rispondi solo al livello di aiuto indicato:");],
[#NormalTok("  L0-L2 maieutica (esito, domanda, controesempio); L3-L4 elicitazione");],
[#NormalTok("  (principio, esempio parziale su un altro dominio).");],
[#NormalTok("- Non fornire mai schemi, DDL o query risolutive. Non assegnare punteggi.");],
[#NormalTok("- Per le decisioni progettuali segnala che esistono piu soluzioni valide e chiedi");],
[#NormalTok("  di motivare la scelta.");],
[#NormalTok("- Esprimi un parere su completezza, minimalita, pertinenza o lessico solo se lo");],
[#NormalTok("  studente lo chiede, dichiarando che non e vincolante.");],
[#NormalTok("- Fase 8: confronta la richiesta, la query e il RISULTATO ricevuto; esprimi un");],
[#NormalTok("  parere non vincolante e trasformalo in domande (righe attese, mancanti o");],
[#NormalTok("  duplicate). Se i dati di test non permettono di distinguere una query");],
[#NormalTok("  corretta da una sbagliata, dillo e chiedi allo studente di aggiungere casi.");],
[#NormalTok("- Chiedi sempre allo studente di giustificare la modifica che propone.");],
[#NormalTok("- Se non sei sicuro, dillo e rimanda al docente.");],
[#NormalTok("- Se la scorciatoia DATI e attiva (fase 7): proponi INSERT coerenti con lo schema");],
[#NormalTok("  dello studente (valori plausibili, senza dati personali reali, con genitori");],
[#NormalTok("  senza figli, nulli e valori ripetuti); nessun altro codice.");],
[#NormalTok("- Rispondi in italiano, in massimo 150 parole (esclusi gli INSERT generati).");],));
== GitLab / Forgejo come piattaforma di consegna e revisione
<sec-piattaforma-consegna>
Infrastruttura basata su istanza on-premise di #strong[GitLab Community Edition] (o #strong[Forgejo / Gitea]) affiancata da un runner Docker privo di connessione Internet.

- #strong[Repository modello:] Predisposto dal docente per ogni esercitazione contenente: traccia, template vuoti dei file di consegna, schema JSON di validazione e file #NormalTok(".gitlab-ci.yml");.

- #strong[Workflow studente:] Ogni studente o coppia lavora in un fork privato (o branch isolato) identificato da uno pseudonimo (es. #NormalTok("s017");).

- #strong[File di consegna:]

  #Skylighting(([#NormalTok("01_requisiti.md");],
  [#NormalTok("02_glossario.md");],
  [#NormalTok("03_concettuale.yaml");],
  [#NormalTok("04_vincoli.md");],
  [#NormalTok("05_relazionale.yaml");],
  [#NormalTok("06_schema.sql");],
  [#NormalTok("07_dati.sql");],
  [#NormalTok("08_query.sql");],
  [#NormalTok("motivazioni.md");],));

- #strong[Commit motivati:] Ogni modifica deve essere accompagnata da un messaggio di commit esplicativo che motivi il perché della variazione; la cronologia Git costituisce la prova primaria della capacità di revisione autonoma.

- #strong[Merge Request e Pipeline CI:] L'apertura della Merge Request per ciascuna consegna scatena la pipeline di validazione:

  #Skylighting(([#FunctionTok("stages");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("valida");#KeywordTok(",");#AttributeTok(" esegui");#KeywordTok("]");],
  [],
  [#FunctionTok("valida");#KeywordTok(":");],
  [#AttributeTok("  ");#FunctionTok("stage");#KeywordTok(":");#AttributeTok(" valida");],
  [#AttributeTok("  ");#FunctionTok("script");#KeywordTok(":");],
  [#AttributeTok("    ");#KeywordTok("-");#AttributeTok(" python -m socratic.validate 03_concettuale.yaml 05_relazionale.yaml");],
  [],
  [#FunctionTok("esegui");#KeywordTok(":");],
  [#AttributeTok("  ");#FunctionTok("stage");#KeywordTok(":");#AttributeTok(" esegui");],
  [#AttributeTok("  ");#FunctionTok("script");#KeywordTok(":");],
  [#AttributeTok("    ");#KeywordTok("-");#AttributeTok(" python -m socratic.run --ddl 06_schema.sql --dati 07_dati.sql --query 08_query.sql --test tests/");],
  [#AttributeTok("  ");#FunctionTok("allow_failure");#KeywordTok(":");#AttributeTok(" ");#CharTok("true");],));

- #strong[Review umana del docente:] Il docente può intervenire direttamente nella discussione della Merge Request commentando a campione gli elaborati. Tutti i commenti automatici del sistema riportano chiaramente la dicitura: #emph[«Verifica tecnica automatica, priva di valore valutativo»].

== Strumento d'autore per il docente
<sec-strumento-autore>
Agente specializzato a compito unico per accelerare la preparazione dei materiali didattici senza trattare dati personali degli studenti:

+ #strong[Input:] Inserimento del testo della traccia e selezione opzionale di uno schema-tipo dal catalogo di dominio.
+ #strong[Generazione della bozza:] L'LLM propone la checklist dei requisiti (5--10 punti chiave); per il pacchetto esteso genera lo schema canonico, il dataset e le query attese per la fase 8.
+ #strong[Controllo automatico di coerenza:] I validatori verificano la corrispondenza lessicale tra traccia e checklist e l'eseguibilità dello schema canonico.
+ #strong[Validazione umana obbligatoria:] Il docente esamina la proposta tramite interfaccia visuale o Merge Request Git, apporta eventuali modifiche e approva il pacchetto, che viene congelato con un tag di versione immutabile.
+ #strong[Ciclo di miglioramento continuo:] Eventuali falsi positivi segnalati dagli studenti consentono al docente di raffinare la checklist con una nuova versione del tag.

== Ipotesi di sistema avanzato (Post-sperimentazione)
<sec-sistema-avanzato>
Funzionalità previste per successive evoluzioni della piattaforma: - #strong[Visione artificiale per schemi manoscritti:] Modello multimodale (VLM) per la trascrizione automatica di diagrammi concettuali disegnati a mano libera su carta; la trascrizione produce un'ipotesi YAML che lo studente corregge e valida prima di avviare il dialogo. - #strong[Architettura multi-agente specializzata:] Disaccoppiamento tra agente trascrittore, agente per l'analisi di vincoli complessi, generatore di controesempi e sintetizzatore di report per il docente, coordinati da una FSM centrale. - #strong[Supporto multi-notazione:] Convertitori bidirezionali tra formato YAML e formati grafici o testuali (Mermaid, PlantUML, diagrammi relazionali Chen/Crow's Foot). - #strong[RAG locale:] Retrieval-Augmented Generation su slide di lezione, testi di riferimento e dispense del docente. - #strong[Cruscotto analitico:] Dashboard con indicatori aggregati di classe per identificare i concetti critici (es. frequenza di violazioni della 3NF, tempo medio di risoluzione delle chiavi esterne).

= Specifiche dei formati e contratti dati
<sec-formati-contratti>
Per garantire interoperabilità, elaborazione automatica deterministica e feedback preciso da parte dell'LLM, il sistema adotta formati testuali standard e rigorosamente tipizzati.

#horizontalrule

== Specifiche YAML per i modelli
<sec-specifiche-yaml>
Tutti i modelli prodotti dagli studenti adottano la sintassi #strong[YAML], validata a tempo di commit o upload mediante #strong[JSON Schema] o schemi #strong[Pydantic]. I diagrammi visuali (es. Mermaid) sono generati dal sistema per visualizzazione a partire dal file YAML e non costituiscono l'input primario.

=== Modello Concettuale (#NormalTok("tipo: concettuale");)
<sec-modello-concettuale>
Il modello concettuale formalizza entità, attributi, identificatori univoci, associazioni, cardinalità minime/massime e vincoli di dominio. Ogni entità e associazione include un campo #NormalTok("motivazione"); in cui lo studente giustifica la scelta rispetto al testo del problema.

#Skylighting(([#FunctionTok("versione");#KeywordTok(":");#AttributeTok(" ");#DecValTok("1");],
[#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" concettuale");],
[],
[#FunctionTok("entita");#KeywordTok(":");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" Paziente");],
[#AttributeTok("    ");#FunctionTok("attributi");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" cf");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" stringa");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("identificatore");#KeywordTok(":");#AttributeTok(" ");#CharTok("true");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" cognome");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" stringa");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("opzionale");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" nome");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" stringa");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("opzionale");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" telefono");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" stringa");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("opzionale");#KeywordTok(":");#AttributeTok(" ");#CharTok("true");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("motivazione");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Il codice fiscale identifica univocamente la persona nel dominio.\"");],
[],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" Medico");],
[#AttributeTok("    ");#FunctionTok("attributi");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" matricola");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" stringa");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("identificatore");#KeywordTok(":");#AttributeTok(" ");#CharTok("true");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" specializzazione");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" stringa");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("opzionale");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("motivazione");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"La matricola ospedaliera è l'identificatore interno del medico.\"");],
[],
[#FunctionTok("associazioni");#KeywordTok(":");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" Visita");],
[#AttributeTok("    ");#FunctionTok("partecipanti");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("entita");#KeywordTok(":");#AttributeTok(" Paziente");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("card");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"0..N\"");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("entita");#KeywordTok(":");#AttributeTok(" Medico");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("card");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"0..N\"");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("attributi");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" inizio");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" datetime");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" durata_min");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" intero");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("motivazione");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Una visita registra data, ora e durata dell'incontro tra paziente e medico.\"");],
[],
[#FunctionTok("vincoli");#KeywordTok(":");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("id");#KeywordTok(":");#AttributeTok(" V1");],
[#AttributeTok("    ");#FunctionTok("testo");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Un medico non può effettuare due visite con intervalli temporali sovrapposti.\"");],
[#AttributeTok("    ");#FunctionTok("classe");#KeywordTok(":");#AttributeTok(" temporale");],
[#AttributeTok("    ");#FunctionTok("meccanismo");#KeywordTok(":");#AttributeTok(" trigger");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("id");#KeywordTok(":");#AttributeTok(" V2");],
[#AttributeTok("    ");#FunctionTok("testo");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"La durata della visita deve essere strettamente positiva.\"");],
[#AttributeTok("    ");#FunctionTok("classe");#KeywordTok(":");#AttributeTok(" attributo");],
[#AttributeTok("    ");#FunctionTok("meccanismo");#KeywordTok(":");#AttributeTok(" check");],));
==== Regole di validazione semantica concettuale
<regole-di-validazione-semantica-concettuale>
+ #strong[Unicità dei nomi]: Nessuna entità o associazione può avere nomi duplicati.
+ #strong[Identificatore presente]: Ogni entità deve possedere almeno un attributo con #NormalTok("identificatore: true"); (o identificatore esterno dichiarato).
+ #strong[Cardinalità valide]: I valori di #NormalTok("card"); ammessi sono #NormalTok("'0..1'");, #NormalTok("'1..1'");, #NormalTok("'0..N'");, #NormalTok("'1..N'"); (o notazioni equivalenti min/max).
+ #strong[Tracciabilità]: Ogni entità deve essere richiamata in almeno una associazione o giustificata esplicitamente.

#horizontalrule

=== Modello Relazionale (#NormalTok("tipo: relazionale");)
<sec-modello-relazionale>
Il modello relazionale definisce tabelle, tipi di dato SQL, nullabilità, chiavi primarie, chiavi esterne, vincoli di unicità, check e #strong[dipendenze funzionali dichiarate]. La presenza esplicita delle dipendenze rende possibile il calcolo deterministico delle chiavi candidate e la verifica formale di 2NF, 3NF e BCNF.

#Skylighting(([#FunctionTok("versione");#KeywordTok(":");#AttributeTok(" ");#DecValTok("1");],
[#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" relazionale");],
[],
[#FunctionTok("tabelle");#KeywordTok(":");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" Paziente");],
[#AttributeTok("    ");#FunctionTok("colonne");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" cf");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" cognome");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" nome");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" telefono");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("true");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("pk");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("cf");#KeywordTok("]");],
[#AttributeTok("    ");#FunctionTok("motivazione");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Tabella anagrafica pazienti con PK codice fiscale.\"");],
[],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" Medico");],
[#AttributeTok("    ");#FunctionTok("colonne");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" matricola");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" specializzazione");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("pk");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("matricola");#KeywordTok("]");],
[#AttributeTok("    ");#FunctionTok("motivazione");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Tabella anagrafica medici con PK matricola.\"");],
[],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" Visita");],
[#AttributeTok("    ");#FunctionTok("colonne");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" id");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" INTEGER");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" cf_paziente");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" matricola_medico");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" inizio");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" TEXT");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("{");#FunctionTok("nome");#KeywordTok(":");#AttributeTok(" durata_min");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("tipo");#KeywordTok(":");#AttributeTok(" INTEGER");#KeywordTok(",");#AttributeTok(" ");#FunctionTok("nullo");#KeywordTok(":");#AttributeTok(" ");#CharTok("false");#KeywordTok("}");],
[#AttributeTok("    ");#FunctionTok("pk");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("id");#KeywordTok("]");],
[#AttributeTok("    ");#FunctionTok("fk");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("colonne");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("cf_paziente");#KeywordTok("]");],
[#AttributeTok("        ");#FunctionTok("riferisce");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Paziente(cf)\"");],
[#AttributeTok("        ");#FunctionTok("on_delete");#KeywordTok(":");#AttributeTok(" RESTRICT");],
[#AttributeTok("        ");#FunctionTok("on_update");#KeywordTok(":");#AttributeTok(" CASCADE");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#FunctionTok("colonne");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("matricola_medico");#KeywordTok("]");],
[#AttributeTok("        ");#FunctionTok("riferisce");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Medico(matricola)\"");],
[#AttributeTok("        ");#FunctionTok("on_delete");#KeywordTok(":");#AttributeTok(" RESTRICT");],
[#AttributeTok("        ");#FunctionTok("on_update");#KeywordTok(":");#AttributeTok(" CASCADE");],
[#AttributeTok("    ");#FunctionTok("unique");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#KeywordTok("[");#AttributeTok("matricola_medico");#KeywordTok(",");#AttributeTok(" inizio");#KeywordTok("]");],
[#AttributeTok("    ");#FunctionTok("check");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#StringTok("\"durata_min > 0\"");],
[#AttributeTok("    ");#FunctionTok("dipendenze");#KeywordTok(":");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#StringTok("\"id -> cf_paziente, matricola_medico, inizio, durata_min\"");],
[#AttributeTok("      ");#KeywordTok("-");#AttributeTok(" ");#StringTok("\"matricola_medico, inizio -> id, cf_paziente, durata_min\"");],
[#AttributeTok("    ");#FunctionTok("motivazione");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"Chiave surrogata id per gestire visite multiple tra gli stessi soggetti.\"");],));
==== Regole di calcolo deterministico
<regole-di-calcolo-deterministico>
- #strong[Chiusura degli attributi ($X^(+)$)]: Calcolo automatico della chiusura degli insiemi di attributi rispetto alle dipendenze dichiarate.
- #strong[Rilevazione chiavi candidate]: Verifica che la chiave primaria scelta (#NormalTok("pk");) sia effettivamente una superchiave minimale.
- #strong[Forme normali]:
  - #emph[1NF]: Valori atomici e presenza di chiave primaria.
  - #emph[2NF]: Assenza di dipendenze parziali di attributi non primi dalla chiave primaria.
  - #emph[3NF]: Assenza di dipendenze transitive verso attributi non primi.
  - #emph[BCNF]: Ogni determinante nelle dipendenze è una superchiave.

#horizontalrule

== Struttura dei file di consegna dello studente
<sec-file-consegna>
Il repository o spazio di lavoro dello studente si compone di file standardizzati:

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([File], [Formato], [Contenuto],),
  table.hline(),
  [#NormalTok("01_requisiti.md");], [Markdown], [Elenco di dati da memorizzare, operazioni richieste, vincoli espliciti/impliciti e ambiguità rilevate.],
  [#NormalTok("02_glossario.md");], [Markdown], [Glossario concetti estratti (nomi/verbi), definizioni formali non circolari, sinonimi e omonimi.],
  [#NormalTok("03_concettuale.yaml");], [YAML], [Modello concettuale ER secondo la specifica #ref(<sec-modello-concettuale>, supplement: [Sezione]).],
  [#NormalTok("04_vincoli.md");], [Markdown], [Tabella di classificazione dei vincoli di business e meccanismo di enforcement scelto (schema, check, trigger, app).],
  [#NormalTok("05_relazionale.yaml");], [YAML], [Modello relazionale secondo la specifica #ref(<sec-modello-relazionale>, supplement: [Sezione]).],
  [#NormalTok("06_schema.sql");], [SQL (SQLite)], [Istruzioni DDL (#NormalTok("CREATE TABLE");, vincoli #NormalTok("CHECK");, #NormalTok("UNIQUE");, indici).],
  [#NormalTok("07_dati.sql");], [SQL (SQLite)], [Istruzioni DML (#NormalTok("INSERT");) con dataset significativo e casi limite.],
  [#NormalTok("08_query.sql");], [SQL (SQLite)], [Query #NormalTok("SELECT"); con commento di motivazione della formulazione logica.],
  [#NormalTok("motivazioni.md");], [Markdown], [Registro narrativo delle decisioni di riprogettazione adottate a seguito dei feedback.],
)

#horizontalrule

== Catalogo, conversione e distribuzione delle tracce
<sec-catalogo-tracce>
Il sistema gestisce ogni traccia come un materiale con una fonte, metadati e derivati distinti. Il PDF acquisito dall'archivio ministeriale o dall'editore è conservato come originale di riferimento; il testo estratto e revisionato è registrato in Markdown; il PDF destinato alla lettura o alla stampa è generato dal Markdown. Originale e derivati non vanno sovrascritti l'uno con l'altro: ogni versione deve poter essere ricondotta alla fonte e alla revisione che l'ha prodotta.

=== Metadati del catalogo
<sec-metadati-tracce>
Ogni scheda identifica il materiale e ne descrive provenienza, uso consentito e contenuto didattico. I campi minimi sono:

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Campo], [Descrizione],),
  table.hline(),
  [#NormalTok("id");], [Identificatore stabile, indipendente dal nome del file.],
  [#NormalTok("titolo");], [Titolo breve e riconoscibile della traccia o del materiale.],
  [#NormalTok("anno_esame"); e #NormalTok("anno_scolastico");], [Anno della prova e anno scolastico a cui si riferisce, se ricavabile dalla fonte. Non inferire l'uno dall'altro senza dichiarare la regola adottata.],
  [#NormalTok("indirizzo");], [Indirizzo e articolazione dell'Istituto Tecnico, quando applicabili e indicati nel documento.],
  [#NormalTok("disciplina");], [Disciplina o discipline riportate nella prova.],
  [#NormalTok("sessione");], [Ordinaria, suppletiva, straordinaria, simulazione o altra tipologia attestata dalla fonte.],
  [#NormalTok("fonte");], [Ente o editore, URL di provenienza, data di acquisizione e citazione da riportare nei derivati.],
  [#NormalTok("riassunto");], [Sintesi redazionale del dominio e dei requisiti, da confrontare con il testo originale.],
  [#NormalTok("stato_diritti"); e #NormalTok("accesso");], [Esito della verifica dei diritti e profilo di accesso assegnato al materiale.],
  [#NormalTok("originale");, #NormalTok("markdown"); e #NormalTok("pdf_esportato");], [Riferimenti ai file corrispondenti, se presenti e autorizzati per il rispettivo uso.],
  [#NormalTok("classificazione_didattica");], [Valutazione opzionale di difficoltà modellistica e competenze richieste per le query, con griglia di valutazione, versione e revisore.],
)
La classificazione didattica non è un fatto estratto automaticamente dalla prova: va motivata e revisionata da un docente. Può descrivere separatamente aspetti quali individuazione delle entità e delle relazioni, cardinalità e vincoli, trasformazione in schema relazionale, normalizzazione, uso di join, aggregazioni, sottoquery e gestione di vincoli temporali. Un campo non ancora valutato resta esplicitamente non classificato; una proposta automatica non diventa metadato approvato senza revisione.

Esempio indicativo di scheda:

#Skylighting(([#FunctionTok("versione_catalogo");#KeywordTok(":");#AttributeTok(" ");#DecValTok("1");],
[#FunctionTok("id");#KeywordTok(":");#AttributeTok(" mim-2018-19-itia-ordinaria-ab42");],
[#FunctionTok("titolo");#KeywordTok(":");#AttributeTok(" Servizio multimediale per punti di interesse turistici");],
[#FunctionTok("anno_esame");#KeywordTok(":");#AttributeTok(" ");#DecValTok("2019");],
[#FunctionTok("anno_scolastico");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"2018/19\"");],
[#FunctionTok("criterio_anno_scolastico");#KeywordTok(":");#AttributeTok(" Attribuito alla sessione d'esame dell'anno solare 2019.");],
[#FunctionTok("indirizzo");#KeywordTok(":");],
[#AttributeTok("  ");#FunctionTok("istituto");#KeywordTok(":");#AttributeTok(" tecnico");],
[#AttributeTok("  ");#FunctionTok("codice");#KeywordTok(":");#AttributeTok(" ITIA");],
[#AttributeTok("  ");#FunctionTok("articolazione");#KeywordTok(":");#AttributeTok(" Informatica");],
[#FunctionTok("disciplina");#KeywordTok(":");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" Informatica");],
[#AttributeTok("  ");#KeywordTok("-");#AttributeTok(" Sistemi e Reti");],
[#FunctionTok("sessione");#KeywordTok(":");#AttributeTok(" ordinaria");],
[#FunctionTok("fonte");#KeywordTok(":");],
[#AttributeTok("  ");#FunctionTok("ente");#KeywordTok(":");#AttributeTok(" Ministero dell'Istruzione");],
[#AttributeTok("  ");#FunctionTok("url");#KeywordTok(":");#AttributeTok(" https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Ordinaria/AB42_ORD19.pdf");],
[#AttributeTok("  ");#FunctionTok("acquisita_il");#KeywordTok(":");#AttributeTok(" ");#StringTok("\"2026-10-22\"");],
[#FunctionTok("riassunto");#KeywordTok(":");#AttributeTok(" Servizio per distribuire contenuti multimediali sui punti di interesse di una città.");],
[#FunctionTok("stato_diritti");#KeywordTok(":");#AttributeTok(" da_verificare");],
[#FunctionTok("accesso");#KeywordTok(":");#AttributeTok(" non_distribuibile_fino_a_verifica");],
[#FunctionTok("originale");#KeywordTok(":");#AttributeTok(" fonti/ministero/AB42_ORD19.pdf");],
[#FunctionTok("markdown");#KeywordTok(":");#AttributeTok(" tracce/mim-2018-19-itia-ordinaria-ab42.md");],
[#FunctionTok("pdf_esportato");#KeywordTok(":");#AttributeTok(" ");#CharTok("null");],
[#FunctionTok("classificazione_didattica");#KeywordTok(":");],
[#AttributeTok("  ");#FunctionTok("stato");#KeywordTok(":");#AttributeTok(" da_valutare");],
[#AttributeTok("  ");#FunctionTok("griglia_di_valutazione");#KeywordTok(":");#AttributeTok(" ");#CharTok("null");],
[#AttributeTok("  ");#FunctionTok("difficolta_modellistica");#KeywordTok(":");#AttributeTok(" ");#CharTok("null");],
[#AttributeTok("  ");#FunctionTok("competenze_query");#KeywordTok(":");#AttributeTok(" ");#KeywordTok("[]");],
[#AttributeTok("  ");#FunctionTok("revisore");#KeywordTok(":");#AttributeTok(" ");#CharTok("null");],));
Gli identificatori, i percorsi e i valori dell'esempio sono illustrativi: il catalogo effettivo deve usare identificatori univoci, percorsi gestiti dal sistema e valori controllati per stato dei diritti e accesso.

=== Acquisizione, trascrizione ed esportazione
<sec-pipeline-tracce>
Il flusso di trattamento è il seguente:

+ #strong[Acquisizione]: conservare l'originale senza modificarlo, registrare URL, titolare/editor, data di acquisizione, impronta del file e stato di accesso. Deduplicare per contenuto, mantenendo eventuali fonti e attribuzioni diverse.
+ #strong[Verifica preliminare]: identificare se il documento è una traccia, una soluzione, una simulazione o materiale editoriale; rilevare avvisi di riservatezza e dati personali. Assegnare l'accesso prima di creare copie destinate alla distribuzione.
+ #strong[Estrazione]: estrarre il testo dal PDF e produrre Markdown strutturato; ricorrere all'OCR solo quando necessario e registrare il metodo e gli eventuali limiti. Conservare la paginazione o riferimenti di pagina utili a verificare la trascrizione.
+ #strong[Revisione]: confrontare Markdown e PDF pagina per pagina, correggere errori di estrazione e verificare tabelle, formule, immagini e caratteri. Una persona approva la trascrizione e il riassunto prima che siano usati per generare una consegna.
+ #strong[Arricchimento didattico]: aggiungere riassunto, difficoltà e competenze come annotazioni separate dal testo della fonte, con autore o revisore e data. Non presentare classificazioni non verificate come dati ufficiali.
+ #strong[Esportazione]: generare il PDF per gli studenti esclusivamente da una versione Markdown approvata e autorizzata per quel pubblico. Il PDF deve riportare identificativo, attribuzione e versione; non deve includere svolgimenti, note riservate o metadati interni.

=== Diritti, riservatezza e profili di distribuzione
<sec-accesso-tracce>
La provenienza ministeriale, la pubblicazione di una traccia d'esame o la sua riproduzione su un quotidiano non sono, da sole, una verifica sufficiente del pubblico dominio o del diritto di redistribuire qualsiasi copia. Per ciascun originale e derivato occorre registrare la base di utilizzo, le condizioni di attribuzione e l'esito della verifica prima della distribuzione. In particolare, una soluzione editoriale è un contenuto distinto dalla traccia ministeriale e non ne eredita automaticamente i diritti o le condizioni d'uso.

Il catalogo distingue almeno materiali #strong[pubblicabili agli studenti], materiali #strong[ad accesso riservato ai docenti] e materiali #strong[in attesa di verifica], che non sono distribuibili. Gli svolgimenti riservati, i file con avvisi di copia per docenti e documenti contenenti dati identificativi restano nell'area protetta; non si riproducono tali dati nei metadati o nei PDF esportati. Eventuali copie anonimizzate si creano solo se autorizzate, mantenendo l'originale nell'archivio protetto e documentando la trasformazione.

Gli originali e le trascrizioni riservati non devono trovarsi in directory incluse automaticamente nella build pubblica. In particolare, il rendering Quarto può copiare nel sito gli asset collocati sotto #NormalTok("docs/");: l'output per studenti va quindi generato da un insieme esplicitamente autorizzato, separato dal deposito delle fonti e dei materiali per docenti. Il repository Git, le copie di build e i backup devono rispettare lo stesso profilo di accesso del materiale; una directory esclusa da Git non costituisce, da sola, un archivio controllato né garantisce che gli asset non siano pubblicati da altri passaggi della pipeline.

#horizontalrule

== Formato delle diagnosi strutturate
<sec-diagnosi-strutturate>
Quando l'orchestratore esegue i validatori deterministici, genera un payload JSON standardizzato che viene fornito al modello linguistico tutor:

#Skylighting(([#FunctionTok("{");],
[#NormalTok("  ");#DataTypeTok("\"consegna_id\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"C3\"");#FunctionTok(",");],
[#NormalTok("  ");#DataTypeTok("\"fase\"");#FunctionTok(":");#NormalTok(" ");#DecValTok("5");#FunctionTok(",");],
[#NormalTok("  ");#DataTypeTok("\"livello_aiuto\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"L1\"");#FunctionTok(",");],
[#NormalTok("  ");#DataTypeTok("\"errori_rilevati\"");#FunctionTok(":");#NormalTok(" ");#OtherTok("[");],
[#NormalTok("    ");#FunctionTok("{");],
[#NormalTok("      ");#DataTypeTok("\"codice\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"3NF_VIOLATA\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"gravita\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"errore_oggettivo\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"tabella\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"Ordine\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"dettaglio\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"L'attributo 'citta_cliente' dipende transitivamente da 'cliente_id' e non direttamente dalla PK 'ordine_id'.\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"dipendenza_violante\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"cliente_id -> citta_cliente\"");],
[#NormalTok("    ");#FunctionTok("}");#OtherTok(",");],
[#NormalTok("    ");#FunctionTok("{");],
[#NormalTok("      ");#DataTypeTok("\"codice\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"FK_ORFANA\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"gravita\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"errore_oggettivo\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"tabella\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"Dettaglio\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"dettaglio\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"La chiave esterna 'prodotto_id' riferisce una colonna non presente nella tabella Prodotti.\"");],
[#NormalTok("    ");#FunctionTok("}");],
[#NormalTok("  ");#OtherTok("]");#FunctionTok(",");],
[#NormalTok("  ");#DataTypeTok("\"metriche\"");#FunctionTok(":");#NormalTok(" ");#FunctionTok("{");],
[#NormalTok("    ");#DataTypeTok("\"completezza_requisiti\"");#FunctionTok(":");#NormalTok(" ");#FloatTok("0.85");#FunctionTok(",");],
[#NormalTok("    ");#DataTypeTok("\"copertura_fk\"");#FunctionTok(":");#NormalTok(" ");#FloatTok("0.90");#FunctionTok(",");],
[#NormalTok("    ");#DataTypeTok("\"forme_normali\"");#FunctionTok(":");#NormalTok(" ");#FunctionTok("{");],
[#NormalTok("      ");#DataTypeTok("\"Ordine\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"2NF\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"Cliente\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"3NF\"");#FunctionTok(",");],
[#NormalTok("      ");#DataTypeTok("\"Prodotto\"");#FunctionTok(":");#NormalTok(" ");#StringTok("\"3NF\"");],
[#NormalTok("    ");#FunctionTok("}");],
[#NormalTok("  ");#FunctionTok("}");],
[#FunctionTok("}");],));
Il tutor riceve questo payload nel prompt di sistema e seleziona #strong[una sola diagnosi alla volta] per non sovraccaricare cognitivamente lo studente.

#horizontalrule

== Formato del report compatto di processo
<sec-report-processo>
Per consentire al docente una consultazione rapida del percorso senza applicare automatismi valutativi, il sistema genera un report sintetico per studente:

#Skylighting(([#NormalTok("======================================================================");],
[#NormalTok("REPORT PROCESSO: Studente s042 - Traccia: Gestione Ospedaliera (M733)");],
[#NormalTok("======================================================================");],
[#NormalTok("Fase 1 (Requisiti):           4 tentativi | Livello aiuto max: L1");],
[#NormalTok("Fase 2 (Glossario):           2 tentativi | Livello aiuto max: L0");],
[#NormalTok("Fase 3 (Concettuale ER):      6 tentativi | Livello aiuto max: L2");],
[#NormalTok("   - Diagnosi ricorrente:     CARDINALITA_INVERTITA (2 volte)");],
[#NormalTok("Fase 4 (Vincoli):             3 tentativi | Livello aiuto max: L2");],
[#NormalTok("Fase 5 (Relazionale):         5 tentativi | Livello aiuto max: L3");],
[#NormalTok("   - Diagnosi ricorrente:     3NF_VIOLATA (3 volte)");],
[#NormalTok("Fase 6 (DDL SQLite):          2 tentativi | Livello aiuto max: L1");],
[#NormalTok("Fase 7 (Popolamento/Test):    3 tentativi | Livello aiuto max: L1");],
[#NormalTok("Fase 8 (Query SQL):           4 tentativi | Livello aiuto max: L2");],
[],
[#NormalTok("Note e flag di attenzione:");],
[#NormalTok("- Superamento di L2 nella fase 5 (richiesto supporto di principio su normalizzazione).");],
[#NormalTok("- Motivazioni sintetiche segnalate dal pre-screening per la fase 3 (righe < 3).");],
[#NormalTok("======================================================================");],));
= Quadro normativo, sicurezza e privacy
<sec-normativa-sicurezza>
Quanto segue costituisce una traccia operativa di conformità normativa e di sicurezza da validare con il Responsabile della Protezione dei Dati (DPO) dell'istituzione scolastica e con il Dirigente Scolastico prima dell'avvio della sperimentazione; non costituisce parere legale formale.

#horizontalrule

== Trattamento dei dati personali (GDPR)
<sec-trattamento-dati>
La tabella seguente sintetizza le scelte di conformità al Regolamento Generale sulla Protezione dei Dati (GDPR - Regolamento UE 2016/679):

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Aspetto], [Scelta e misura operativa],),
  table.hline(),
  [#strong[Titolare del trattamento]], [L'istituzione scolastica (o universitaria) in cui si svolge la sperimentazione.],
  [#strong[Finalità]], [Supporto didattico formativo curricolare; eventuale ricerca didattica accademica in forma rigorosamente aggregata e anonima.],
  [#strong[Base giuridica]], [Esecuzione di un compito di interesse pubblico o connesso all'esercizio di pubblici poteri di cui è investito il titolare (art. 6.1.e GDPR); per la ricerca didattica, specifica informativa e acquisizione del consenso o altra base identificata con il DPO.],
  [#strong[Tutela dei minori]], [Studenti in prevalenza minorenni (circa 14--19 anni): erogazione di informativa trasparente e accessibile a studenti ed esercenti la responsabilità genitoriale.],
  [#strong[Dati trattati]], [Elaborati didattici (file YAML, query SQL, testi di motivazione), log delle interazioni e delle diagnosi; #strong[divieto categorico di inserire dati personali reali] nelle tracce e nei dataset di prova.],
  [#strong[Minimizzazione e pseudonimizzazione]], [Adozione di identificatori pseudonimi casuali (es. #NormalTok("s017");); nessun nome o dato anagrafico inserito nei prompt; per le immagini di schemi manoscritti (sistema avanzato), distruzione del file immagine immediatamente dopo la trascrizione testuale.],
  [#strong[Conservazione]], [Conservazione dei log tecnici e dei dialoghi limitata alla durata dell'anno scolastico, con successiva cancellazione sicura o anonimizzazione irreversibile; le pubblicazioni di ricerca utilizzano solo dati aggregati.],
  [#strong[Ruoli e accessi]], [Studente: accesso esclusivo ai propri dati. Docente: accesso ai dati e ai report della propria classe. Amministratore di sistema: accesso per sole finalità di manutenzione tecnica.],
  [#strong[Destinatari terzi]], [#strong[Nessun destinatario esterno:] modelli di inferenza, banche dati ed esecutori operano interamente in rete locale (#emph[on-premise]). Nessun dato transita verso API cloud commerciali.],
  [#strong[Diritti degli interessati]], [Esercizio dei diritti di accesso, rettifica, cancellazione e limitazione garantito e gestito direttamente tramite la segreteria dell'istituto.],
)
=== Adempimenti documentali
<adempimenti-documentali>
Prima dell'inizio delle attività devono essere predisposti: 1. Informativa sul trattamento dei dati per studenti e famiglie; 2. Aggiornamento del Registro dei Trattamenti dell'istituto; 3. Valutazione d'Impatto sulla Protezione dei Dati (DPIA) per l'introduzione di strumenti di intelligenza artificiale con minori; 4. Linee guida per gli studenti per l'uso esclusivo di dati sintetici o di fantasia nei test SQL.

#horizontalrule

== Misure di sicurezza tecniche e organizzative
<sec-misure-sicurezza>
- #strong[Isolamento di rete:] I server di inferenza (Ollama/vLLM) e i container di esecuzione risiedono nella sottorete dell'istituto priva di connessioni in uscita verso Internet; gli aggiornamenti di sistema e dei pacchetti Python/OS sono effettuati periodicamente tramite mirror o repository controllati.
- #strong[Autenticazione e controllo degli accessi:] Integrazione con i sistemi di identità scolastici (SSO, LDAP/Active Directory o credenziali pseudonime gestite internamente); cifratura a riposo dei dischi server (#NormalTok("LUKS");) e dei backup.
- #strong[Isolamento dell'esecutore SQL:] I file SQL consegnati sono trattati come non fidati. L'esecuzione avviene in container monouso senza rete o processi vincolati con #NormalTok("rlimit");, con database in memoria e autorizzatore SQLite attivo per bloccare chiamate al filesystem o estensioni C.
- #strong[Protezione da #emph[Prompt Injection]:] Il codice e le motivazioni dello studente sono delimitati come meri dati passivi all'interno del contesto inviato all'LLM. Il modello tutor non dispone di tool d'azione, privilegi di esecuzione o accesso alla memoria esterna. Le risposte generate sono analizzate prima dell'invio allo studente per bloccare la fuga di soluzioni.
- #strong[Tracciabilità e logging:] Conservazione dei log di sistema e delle chiamate di inferenza con canali separati per il monitoraggio operativo e la rilevazione tempestiva di eventuali anomalie.
- #strong[Verifica delle licenze:] Accertamento della compatibilità per uso didattico e accademico delle licenze del software open-source e dei pesi dei modelli linguistici adottati (es. licenze Apache 2.0, MIT o specifiche per pesi aperti conformi all'Open Source Initiative).

#horizontalrule

== Valutazione e quadro regolatorio sull'Intelligenza Artificiale (AI Act)
<sec-ai-act>
- #strong[Assenza di decisioni automatizzate e di valutazione algoritmica:] Il sistema è privo di funzioni di calcolo di voti, attribuzione di punteggi sommatori o giudizi di idoneità. Gli esiti dei controlli tecnici deterministici costituiscono pure informazioni diagnostiche formative di processo. La valutazione finale resta un atto esclusivamente umano, esercitato dal docente sulla base di prove individuali in presenza (fase 9) e della lettura qualitativa degli elaborati. Questa scelta garantisce piena conformità con l'art. 22 del GDPR (divieto di decisioni basate unicamente sul trattamento automatizzato).
- #strong[Inquadramento rispetto all'EU AI Act (Regolamento UE 2024/1689):] L'AI Act include tra i sistemi ad alto rischio (Allegato III, punto 3) i sistemi di IA destinati a valutare i risultati dell'apprendimento, anche quando tali esiti orientino il percorso scolastico. Socratic-DB è deliberatamente architettato per sottrarsi a tale perimetro:
  - Non calcola punteggi;
  - Non formula raccomandazioni vincolanti di avanzamento o blocco;
  - Non stila graduatorie o profili predittivi dello studente. La classificazione va in ogni caso formalizzata nella scheda tecnica del sistema con il DPO dell'istituto.
- #strong[Trasparenza e alfabetizzazione (Art. 50 AI Act):] Gli studenti sono esplicitamente informati del fatto che stanno interagendo con un agente artificiale. L'esperienza didattica è integrata da moduli di alfabetizzazione critica sull'IA, volti a chiarire come funziona il tutor, quali sono i suoi limiti e perché le verifiche tecniche provengono da software deterministico e non dal modello linguistico.
- #strong[Percorso alternativo:] Viene garantita agli studenti e alle famiglie la possibilità di svolgere il medesimo percorso curricolare con modalità tradizionali (esercitazione standard guidata dal docente in aula e su materiale cartaceo/digitale convenzionale) senza alcuna penalizzazione.

#horizontalrule

== Limiti del sistema e minacce alla validità
<sec-limiti-validita>
- #strong[Allucinazioni e compiacenza dell'LLM (#emph[Sycophancy]):] I modelli linguistici possono produrre risposte errate, incoerenti o accondiscendere a ragionamenti scorretti. Per mitigare tale rischio, l'LLM è confinato al ruolo dialogico e le sue risposte sono vincolate alle diagnosi deterministiche.
- #strong[Rigidità dei controlli deterministici:] I controlli automatici valutano solo ciò che è formalizzato nei test: un controllo eccessivamente stringente rischia di respingere schemi alternativi del tutto validi. Rimane sempre attiva la facoltà di segnalazione di falsi positivi al docente.
- #strong[Limiti espressivi del DDL SQLite:] Vincoli di dominio che coinvolgono tuple multiple o dipendenze temporali complesse non sono esprimibili con semplici vincoli dichiarativi in SQLite e richiedono trigger o controlli applicativi.
- #strong[Dipendenze funzionali incomplete:] La correttezza del calcolo delle forme normali (2NF, 3NF, BCNF) dipende dall'insieme delle dipendenze funzionali dichiarate dallo studente nel modello relazionale; se lo studente omette dipendenze fondamentali, il calcolo algoritmico risulterà parziale.
- #strong[Limiti di scalabilità hardware:] Con una singola GPU locale da 32 GB di VRAM, la capacità di servizio simultaneo è calibrata su una singola classe (5--20 postazioni attive con intervalli di digitazione umana).
- #strong[Automation bias del docente:] Nell'uso dello strumento d'autore (#ref(<sec-strumento-autore>, supplement: [Sezione])), esiste il rischio che il docente approvi la checklist o lo schema proposto dall'IA senza un'attenta rilettura critica. La validazione umana deve essere formalizzata come passaggio obbligatorio e verificata a campione.

= Protocollo di sperimentazione empirica
<sec-protocollo-sperimentazione>
Prima di estendere l'adozione del sistema a più istituti o corsi, il progetto prevede una sperimentazione controllata volta a quantificare l'efficacia didattica, l'usabilità e la sostenibilità operativa. In particolare, il percorso include una #strong[fase pilota preliminare a basso attrito tecnologico ("zero-infrastructure")] focalizzata sulla sola gestione maieutica del dialogo da parte del modello linguistico, propedeutica alla sperimentazione dell'architettura complessa completa.

#horizontalrule

== Fasi e disegno della ricerca
<sec-disegno-ricerca>
La sperimentazione complessiva si articola in sette passaggi metodologici:

+ #strong[Definizione degli obiettivi formativi mirati:] Focalizzazione su un sottoinsieme specifico di competenze modellistiche e interrogative (da O2 a O7: modellazione ER, traduzione in schema relazionale, individuazione di vincoli non banali, calcolo delle forme normali, scrittura di query SQL con aggregazioni e join).

+ #strong[Strumenti di misurazione standardizzati:]

  - #emph[Pre-test diagnostico]: Somministrazione iniziale per rilevare il livello di partenza degli studenti.
  - #emph[Attività formative con il tutor]: Svolgimento delle consegne C1--C4 con tracciamento dettagliato delle revisioni.
  - #emph[Post-test individuale]: Valutazione delle competenze acquisite al termine dell'intervento.
  - #emph[Prova di trasferimento a distanza (3--4 settimane)]: Risoluzione di una traccia inedita senza alcun supporto del tutor (fase 9 / consegna C5), per verificare la ritenzione nel medio termine e l'assenza di dipendenza dall'assistente.
  - #emph[Correzione in cieco]: Valutazione degli elaborati da parte di due docenti indipendenti all'oscuro dell'identità dello studente, con rubrica analitica descrittiva e calcolo dell'indice di accordo inter-valutatore.

+ #strong[Validazione preventiva del tutor (Golden Set):] Prima dell'interazione con gli studenti, il tutor linguistico è sottoposto al golden set di collaudo (#ref(<sec-test-tutor-llm>, supplement: [Sezione])):

  - Almeno 30 casi noti per ciascuna fase;
  - Misurazione della fedeltà ai livelli di aiuto (nessun controesempio a L1, nessun codice risolutivo completo);
  - Calcolo del tasso di mancata fuga della soluzione (obiettivo: 100%);
  - Verifica di non-contraddizione rispetto alle diagnosi deterministiche.

+ #strong[Fasi pilota progressive della sperimentazione:]

  - #strong[Pilota 1 (Cloud Zero-Infrastructure / Google Classroom e Gemini, #ref(<sec-pilota-classroom>, supplement: [Sezione])):] Sperimentazione del solo tutor LLM in un contesto scolastico reale basato su Google Classroom, utilizzando le Gem di Gemini e le Skill agentiche (#NormalTok("SKILL.md");) per testare la tenuta del dialogo socratico, la qualità maieutica e l'usabilità multimodale a formati aperti, senza il carico di allestimento dei server Git e SQLite.
  - #strong[Pilota 2 (On-Premise / Modelfile Ollama per VLM aperti, #ref(<sec-pilota-ollama>, supplement: [Sezione])):] Trasferimento delle istruzioni socratiche della Gem in un #NormalTok("Modelfile"); per Ollama ed esecuzione locale su workstation scolastica. Valutazione comparativa di modelli vision-language aperti (Qwen2.5-VL 7B, Qwen3-8B, Phi-3.5-vision, LLaVA v1.6, Llama 3.2 3B Vision) per testare l'analisi di immagini/diagrammi, la latenza, il consumo di VRAM e la tenuta maieutica in assenza di connettività cloud.
  - #strong[Pilota 3 (Integrazione tecnologica mista completa, #ref(<sec-piattaforma-consegna>, supplement: [Sezione])):] Coinvolgimento di una o due classi (5--20 studenti per classe) per un ciclo di 6--8 lezioni curricolari in laboratorio con lo stack integrato neuro-simbolico on-premise (GitLab/Forgejo, runner isolati, sandbox SQLite e validatori deterministici rigidi).
  - Disegno di ricerca prevalentemente #emph[intra-soggetto] (confronto pre/post sullo stesso gruppo di studenti).
  - Rilevazione qualitativa continua: osservazione sul campo dei comportamenti degli studenti, registrazione dei blocchi tecnici o didattici, note del docente.
  - Affinamento iterativo dei prompt, dei pesi di quantizzazione e delle regole di validazione prima della sperimentazione su scala più ampia.

+ #strong[Verifica empirica del trasferimento:] Confronto delle prestazioni della prova individuale finale rispetto al pre-test diagnostico iniziale, utilizzando una traccia concettualmente isomorfa ma ambientata in un dominio applicativo differente.

+ #strong[Analisi multidimensionale dei risultati:] Oltre ai punteggi grezzi di correttezza, l'analisi considera:

  - #emph[Grado di autonomia]: Evoluzione della richiesta di livelli di aiuto (tendenza a diminuire il ricorso a L3/L4);
  - #emph[Qualità del ragionamento]: Pertinenza, rigore e ricchezza delle motivazioni fornite nei vari passaggi;
  - #emph[Capacità di correzione attiva]: Analisi della cronologia delle revisioni e dei ripensamenti tra il primo tentativo e l'elaborato approvato;
  - #emph[Esperienza percepita]: Questionario di fine percorso sull'utilità percepita, senso di autoefficacia e fiducia nel tutor.

+ #strong[Confronto controllato (Fase estesa successiva):] Qualora siano disponibili classi parallele con il medesimo programma curricolare, confronto tra:

  - #emph[Gruppo sperimentale]: Attività svolta con Socratic-DB.
  - #emph[Gruppo di controllo]: Attività tradizionale con correzione manuale periodica del docente. Adozione di schemi a rotazione (#emph[crossover]) per garantire a tutti gli studenti le medesime opportunità formative.

#horizontalrule

== Fasi pilota "Zero-Infrastructure": Sperimentazione del dialogo socratico con Google Classroom e Gemini
<sec-pilota-classroom>
=== Contesto didattico e motivazione metodologica
<sec-pilota-classroom-motivo>
L'allestimento dell'architettura completa descritta in #ref(<sec-architettura-sistema>, supplement: [Capitolo]) (server Linux con GPU da 32 GB, istanza on-premise GitLab/Forgejo, container Docker con SQLite in sandbox e validatori YAML/Pydantic) comporta un rilevante investimento infrastrutturale e un notevole carico di configurazione DevOps per il docente. Se introdotto direttamente nella fase iniziale della ricerca, questo carico tecnologico rischia di introdurre variabili spurie nell'osservazione (es. blocchi dovuti a errori di sintassi YAML, disallineamenti di Git o problemi di rete locale), oscurando l'oggetto primario di indagine: #strong[la reale efficacia maieutica del modello linguistico nella conduzione del dialogo socratico per le basi di dati].

Per isolare e valutare rigorosamente la componente conversazionale e pedagogica, il progetto introduce una #strong[fase pilota "zero-infrastructure"] ambientata nello scenario d'uso ordinario di una scuola secondaria di secondo grado italiana dotata di #strong[Google Workspace for Education e Google Classroom].

In tale ambiente:

- Non è richiesta alcuna installazione locale, server dedicato o configurazione di repository Git;
- La scuola sfrutta gli strumenti di IA generativa già integrati e regolamentati nell'infrastruttura d'istituto (Gemini Enterprise o Education);
- La didattica beneficia della disponibilità di #strong[Gem personalizzate (Gemini Gems)] e della generazione e utilizzo di #strong[Skill agentiche standard (#NormalTok("SKILL.md");)]\;
- Gli studenti possono dialogare con il tutor utilizzando qualsiasi dispositivo (Chromebook, PC di laboratorio, tablet o smartphone) e qualsiasi modalità espressiva, inclusa quella grafica e manoscritta.

=== Duplice implementazione: Gem di Gemini e Skill agentica
<sec-duplice-implementazione>
Per consentire la massima flessibilità sia in contesti no-code che in ambienti di programmazione assistita, il tutor socratico è ingegnerizzato e rilasciato in due formati complementari:

+ #strong[Gem di Google Gemini (#NormalTok("DB-Socrates Gem");):] Configurata direttamente dal docente nella console di Gemini Workspace attraverso un set di istruzioni di sistema (#emph[system prompt]) strutturato. La Gem è distribuibile alla classe tramite link o condivisione interna in Google Classroom. Gli studenti vi accedono con il proprio account istituzionale, interagendo in una chat multimodale intuitiva. Le specifiche e il prompt completo per la creazione della Gem sono formalizzati in #link("file:///home/massi/Documenti/GitHub/socratic-db/gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md")[GEM\_SYSTEM\_INSTRUCTIONS.md].

+ #strong[Skill agentica standard (#NormalTok("SKILL.md");):] Definita secondo la specifica standard per assistenti e agenti di sviluppo (Google Antigravity, Gemini CLI, estensioni per Classroom). La skill racchiude i metadati YAML, i trigger operativi, le regole maieutiche L0--L4, i criteri di qualità e le euristiche di scaffolding. Il file sorgente della skill è disponibile in #link("file:///home/massi/Documenti/GitHub/socratic-db/skills/socratic-db/SKILL.md")[SKILL.md].

=== Ingestione del compito e isolamento della componente DB
<sec-ingestione-compito>
Il flusso di lavoro si innesca quando lo studente (o il docente per conto della classe) carica il PDF del compito. Tipicamente si tratta di:

- Una traccia di #strong[Seconda Prova scritta dell'Esame di Stato] per gli Istituti Tecnici (indirizzo Informatica e Telecomunicazioni, articolazione Informatica);
- Una simulazione ministeriale o una prova d'esame degli anni precedenti (cfr. catalogo in #ref(<sec-catalogo-tracce>, supplement: [Sezione]));
- Un compito in classe o studio di caso predisposto dal docente di indirizzo.

Le tracce d'esame ministeriali contengono frequentemente requisiti compositi (ad esempio: architettura di rete e apparati Cisco, progettazione della base di dati, realizzazione di pagine web front-end o policy di sicurezza). L'assistente socratico:

+ #strong[Analizza e isola il dominio dati:] legge il PDF tramite le capacità multimodali native del modello e separa la parte relativa alla persistenza e alle basi di dati (generalmente identificata come #emph[Parte Prima] o #emph[Tema 1]) dagli aspetti accessori;
+ #strong[Definisce il perimetro:] riassume in poche frasi l'universo del discorso e gli obiettivi informativi del sistema;
+ #strong[Presenta il patto formativo:] esplicita allo studente la sequenza rigorosa delle nove tappe maieutiche che dovranno essere percorse prima di considerare concluso il lavoro.

=== Il percorso maieutico in nove passi e la mappatura con il Protocollo Didattico
<sec-mappatura-fasi-pilota>
Il tutor conduce l'interazione richiedendo allo studente di produrre, tassativamente nell'ordine metodologico, nove risultati intermedi. Questa sequenza costituisce una #strong[mappatura biunivoca e fedele delle nove fasi e delle cinque consegne formali descritte nel Protocollo Didattico (#ref(<sec-percorso-consegne>, supplement: [Sezione]))]:

+ #strong[Analisi nomi-verbi (Fasi 1--2 / Consegna C1):] Lo studente estrae dal testo del compito isolato i sostantivi e le forme verbali rilevanti, organizzandoli in una tabella. Ogni sostantivo è categorizzato (#emph[Candidata Entità], #emph[Attributo], #emph[Scartato/Fuori ambito]) con la rispettiva giustificazione semantica. Ogni verbo è categorizzato (#emph[Candidata Associazione], #emph[Operazione di sistema], #emph[Scartato]) specificando i soggetti coinvolti. Il tutor interviene maieuticamente per sfatare l'illusione che "ogni nome sia un'entità e ogni verbo una relazione", guidando lo studente a motivare i confini del modello.

+ #strong[Glossario di progetto (Fase 2 / Consegna C1):] Lo studente fornisce le definizioni rigorose di ciascun termine e concetto candidato selezionato. Il tutor verifica che le definizioni non siano circolari o tautologiche (es. #emph["La Prenotazione è l'atto di prenotare"]), accerta la disambiguazione di omonimi e sinonimi presenti nel testo e fissa il lessico controllato del progetto.

+ #strong[Modello concettuale E/R (Fase 3 / Consegna C2):] Lo studente progetta lo schema Entità-Relazione definendo entità, attributi, identificatori univoci (chiavi concettuali), associazioni e #strong[cardinalità minime e massime] (#NormalTok("0..1");, #NormalTok("1..1");, #NormalTok("0..N");, #NormalTok("1..N");). Il tutor verifica che ogni entità possieda un identificatore, che ogni costrutto risponda a un requisito della traccia e sfida lo studente tramite controesempi concreti sulle cardinalità dubbie o invertite.

+ #strong[Vincoli del dominio (Fase 4 / Consegna C2):] Lo studente individua e classifica le regole aziendali e i vincoli che non possono essere rappresentati puramente dalla topologia del grafo ER: vincoli su singoli attributi, vincoli inter-entità e vincoli temporali (intervalli, sovrapposizioni e concorrenza). Per ciascun vincolo indica il meccanismo di controllo preventivato (vincolo CHECK/UNIQUE, trigger o livello applicativo).

+ #strong[Modello relazionale e meccanismo di controllo dei vincoli (Fase 5 / Consegna C3):] Lo studente applica le regole formali di traduzione concettuale-logica: derivazione delle tabelle, individuazione delle chiavi primarie, traduzione delle associazioni 1:N e N:M (tramite tabelle di giunzione), gestione delle gerarchie e delle relazioni 1:1, definizione delle chiavi esterne (FK) e delle politiche di integrità referenziale (#NormalTok("ON DELETE");, #NormalTok("ON UPDATE");). Lo studente formalizza le dipendenze funzionali, argomenta il raggiungimento della Terza Forma Normale (#strong[3NF]) e spiega in quale tabella o vincolo relazionale viene implementato ciascuno dei vincoli del punto 4.

+ #strong[DDL SQL per la creazione dello schema (Fase 6 / Consegna C4):] Lo studente scrive lo script SQL DDL (#NormalTok("CREATE TABLE");) con tipi di dati corretti, vincoli #NormalTok("NOT NULL");, #NormalTok("UNIQUE");, #NormalTok("CHECK"); e chiavi esterne attive. #emph[Scaffolding controllato:] se lo studente dimostra piena padronanza concettuale ma rimane bloccato su ostacoli sintattici dopo ripetute iterazioni maieutiche (3--4 tentativi infruttuosi), il tutor fornisce lo schema DDL corretto. Lo studente è tuttavia obbligato ad analizzarlo riga per riga, commentando i vincoli e confrontandolo criticamente con il proprio tentativo iniziale.

+ #strong[DML SQL per l'inserimento dei dati (Fase 7 / Consegna C4):] Lo studente popola la base di dati tramite istruzioni #NormalTok("INSERT INTO"); significative e non banali, comprensive di casi ordinari, casi limite, valori nulli in colonne opzionali, tuple genitore prive di figli (per verificare le #NormalTok("LEFT JOIN");) e casi invalidi destinati a essere respinti dai vincoli di integrità. #emph[Scorciatoia su richiesta:] se lo studente richiede assistenza o per evitare un eccessivo affaticamento esecutivo, il tutor propone uno script multi-insert sintetico e plausibile (privo di dati personali reali), coerente con lo schema dell'allievo, chiedendogli di convalidarlo e integrarlo con un caso limite personale.

+ #strong[QL SQL per le query richieste dal compito (Fase 8 / Consegna C4):] Lo studente formula le query #NormalTok("SELECT"); necessarie a rispondere a tutte le interrogazioni previste dal testo d'esame. Motiva la scelta dei tipi di join (#NormalTok("INNER JOIN");, #NormalTok("LEFT JOIN");), delle condizioni di filtro (#NormalTok("WHERE");), dei raggruppamenti (#NormalTok("GROUP BY");, #NormalTok("HAVING");) e degli ordinamenti (#NormalTok("ORDER BY");), commentando criticamente il risultato logico ottenuto sui dati inseriti al punto 7.

+ #strong[Proposta di un problema simile ma più complesso (Fase 9 / Consegna C5 - Prova di Trasferimento):] Al termine del percorso, il tutor non chiude semplicemente la sessione ma formula una traccia didattica di approfondimento: un problema isomorfo o una variante del caso affrontato che introduce un vincolo aggiuntivo o una complicazione di dominio (es. gestione temporale dei prezzi storici, cancellazione logica con trigger di audit, gestione concorrente di quote di capienza). Lo studente è invitato ad affrontarlo in piena autonomia, permettendo di valutare l'effettivo trasferimento delle competenze senza supporto continuo.

La tabella seguente riassume la corrispondenza biunivoca tra le tappe del pilota in Classroom e il protocollo metodologico del progetto:

#table(
  columns: (20%, 20%, 20%, 20%, 20%),
  align: (left,left,left,left,left,),
  table.header([Tappa Pilota Classroom], [Fase Protocollo Didattico], [Consegna Aggregata], [Artefatto Prodotto dallo Studente], [Controllo e Guida Socratica del Tutor],),
  table.hline(),
  [#strong[\0. Traccia PDF]], [Requisiti Iniziali], [Setup], [Upload PDF esame/compito], [Isolamento mirato della porzione Basi di Dati e perimetrazione],
  [#strong[\1. Nomi-Verbi]], [Fase 1--2], [C1. Requisiti e glossario], [Tabella Sostantivi / Verbi categorizzati e motivati], [Domande sulla natura di attributo vs entità; motivazione degli scarti],
  [#strong[\2. Glossario]], [Fase 2], [C1. Requisiti e glossario], [Glossario definizioni e chiarimento sinonimi/omonimi], [Rilevazione tautologie e definizioni circolari; disambiguazione],
  [#strong[\3. Modello E/R]], [Fase 3], [C2. Concettuale], [Diagramma ER (libero: disegno a mano, Mermaid, draw.io, YAML)], [Presenza identificatori; controesempi pratici su cardinalità invertite],
  [#strong[\4. Vincoli Dominio]], [Fase 4], [C2. Concettuale], [Tabella vincoli non strutturali e meccanismi previsti], [Elicitazione vincoli impliciti, temporali e di sovrapposizione],
  [#strong[\5. Modello Relazionale]], [Fase 5], [C3. Relazionale], [Schemi di relazione, PK/FK, dipendenze funzionali, 3NF], [Verifica assenza FK orfane, superchiavi minime e normalizzazione 3NF],
  [#strong[\6. DDL SQL]], [Fase 6], [C4. Implementazione], [Script SQL #NormalTok("CREATE TABLE"); con tipi e vincoli], [Feedback sintattico/semantico; scaffolding DDL se bloccato (con analisi)],
  [#strong[\7. DML SQL]], [Fase 7], [C4. Implementazione], [Script #NormalTok("INSERT INTO"); (casi ordinari, limite, genitori senza figli)], [Verifica copertura; generazione multi-insert su richiesta],
  [#strong[\8. QL SQL]], [Fase 8], [C4. Implementazione], [Query #NormalTok("SELECT"); commentate e discusse], [Verifica join, filtri, aggregazioni ed esame maieutico dei risultati],
  [#strong[\9. Problema Complesso]], [Fase 9], [C5. Trasferimento], [Risoluzione autonoma di un problema isomorfo incrementale], [Verifica del trasferimento e della non-dipendenza dall'assistente],
)
=== Libertà di formato ed espressività multimodale
<sec-liberta-formati>
Uno dei principali limiti operativi dell'infrastruttura automatizzata rigorosa risiede nell'obbligo, per gli studenti delle scuole superiori, di codificare gli schemi concettuali e logici in file YAML rigorosamente conformi a uno schema JSON (cfr. #ref(<sec-formati-contratti>, supplement: [Capitolo])). Nella pratica scolastica, tale vincolo costringe il docente a spendere ore di lezione sull'insegnamento della sintassi YAML e sulla risoluzione di errori di indentazione, distogliendo l'attenzione dagli obiettivi concettuali della modellazione dei dati.

Nella fase pilota con Google Classroom e Gemini, la scelta pedagogica è improntata alla #strong[totale libertà di formato, inclusa la piena valorizzazione della dimensione grafica e multimodale]:

- #strong[Diagrammi disegnati a mano libera:] Lo studente può tracciare lo schema Entità-Relazione su un comune foglio di carta (con rettangoli per le entità, rombi per le associazioni, ovali per gli attributi e cardinalità min..max scritte a penna), fotografarlo con lo smartphone o la webcam del computer e allegare l'immagine alla chat. La visione multimodale della LLM analizza l'immagine, riconosce la struttura del grafo e le annotazioni manoscritte e conduce la discussione maieutica direttamente a partire dal disegno dello studente.
- #strong[Diagrammi digitali visuali:] Lo studente può utilizzare qualsiasi strumento di disegno grafico (draw.io, Canva, Lucidchart, Excalidraw, DIA) ed esportare l'elaborato in formato immagine (PNG, JPEG) o PDF.
- #strong[Notazioni testuali e diagrammi as-code:] Gli studenti più orientati al codice possono sottoporre diagrammi Mermaid, PlantUML o tabelle Markdown.
- #strong[Rappresentazioni testuali semplificate:] Per il modello relazionale, lo studente può utilizzare la notazione testuale classica della letteratura scolastica (es. #NormalTok("Cliente(ID_Cliente, Cognome, Nome, Città*)"); con asterischi per le chiavi esterne e sottolineature per le chiavi primarie) oppure tabelle a colonne.

La LLM non sanziona né forza alcuna specifica sintassi di rappresentazione grafica o testuale: si concentra unicamente sulla comprensione semantica del modello e sulla qualità del ragionamento dello studente.

=== I cinque criteri di qualità della guida socratica
<sec-criteri-qualita-socratica>
Nel corso di tutte le 9 tappe, la Gem e la Skill orientano il dialogo maieutico affinché l'elaborato finale soddisfi costantemente cinque dimensioni qualitative fondamentali:

+ #strong[Corretto (Correttezza formale, logica e sintattica):] Lo schema deve rispettare rigorosamente le regole dell'algebra relazionale e della sintassi SQL: identificatori presenti per ciascuna entità, assenza di relazioni non collegate, coerenza dei tipi di dato tra chiavi primarie e chiavi esterne, assenza di violazioni di integrità referenziale, rispetto della Terza Forma Normale (3NF), e correttezza sintattica del linguaggio specifico di dominio (E/R, DDL, DML, QL).

+ #strong[Completo (Copertura esaustiva delle specifiche):] Ogni requisito informativo, entità, vincolo aziendale (esplicito o implicito) e interrogazione presente nel testo del compito o dell'Esame di Stato deve trovare puntuale riscontro nello schema concettuale, nello schema relazionale e nelle query di interrogazione. Nessun requisito viene omesso o trascurato.

+ #strong[Minimale (Assenza di sovrastrutture e ridondanze):] Il modello deve evitare l'eccesso di complessità (#emph[over-engineering]). Non devono comparire entità fittizie non giustificate dai requisiti, attributi duplicati o calcolabili, tabelle di giunzione superflue per relazioni 1:N; nelle query SQL devono essere coinvolti esclusivamente gli attributi e le tabelle strettamente necessari (rifiuto del costrutto #NormalTok("SELECT *"); e di join ridondanti).

+ #strong[Pertinente (Aderenza semantica al dominio applicativo):] I nomi attribuiti alle entità, agli attributi e alle relazioni, nonché la classificazione dei vincoli, devono rispecchiare con precisione il lessico, i processi aziendali e la realtà operativa descritta nella traccia, evitando generalizzazioni astratte e terminologie non appropriate.

+ #strong[Efficiente (Ottimizzazione strutturale e computazionale):] Nello schema relazionale e nelle query SQL devono essere privilegiate scelte che minimizzano anomalie e costi computazionali: selezione mirata dei tipi fisici di dato, indicizzazione coerente sulle chiavi esterne e sui campi di ricerca frequente, normalizzazione fino a 3NF senza frammentazione ingiustificata, e scrittura di query ottimizzate (scelta corretta tra #NormalTok("JOIN"); e sottoquery, filtri selettivi anticipati nella clausola #NormalTok("WHERE");, eliminazione di prodotti cartesiani involontari).

==== Declinazione operativa della qualità sui 9 deliverable
<sec-matrice-qualita-deliverable>
Per consentire al tutor un'azione maieutica puntuale, la griglia seguente specifica come i cinque criteri si applicano a ciascuno dei deliverable intermedi:

#table(
  columns: (16.67%, 16.67%, 16.67%, 16.67%, 16.67%, 16.67%),
  align: (left,left,left,left,left,left,),
  table.header([Deliverable], [Corretto], [Completo], [Minimale], [Pertinente], [Efficiente],),
  table.hline(),
  [#strong[D1. Nomi-Verbi]], [Rigore grammaticale e logico (sostantivo $arrow.r$ entità/attributo/scartato; verbo $arrow.r$ associazione/operazione)], [Estrazione di tutti i termini chiave dal testo isolato], [Scarto motivato di vocaboli fuori ambito o irrilevanti], [Fuoco esclusivo sui requisiti informativi del dominio], [Organizzazione tabellare concisa con motivazioni chiare],
  [#strong[D2. Glossario]], [Definizioni non circolari, non tautologiche, ontologicamente fondate], [Definizione di tutti i concetti; chiarimento sinonimi e omonimi], [Definizioni sintetiche e circoscritte al profilo dati], [Ancoraggio al contesto aziendale della prova], [Consolidamento di un lessico controllato senza ambiguità],
  [#strong[D3. Modello E/R]], [Identificatori presenti; cardinalità min/max formalmente valide; assenza di grafi orfani], [Copertura di tutte le entità e relazioni richieste], [Assenza di entità fittizie o attributi calcolabili non motivati], [Rispetto fedele delle dinamiche del problema], [Topologia concettuale pulita e pronta alla traduzione logica],
  [#strong[D4. Vincoli]], [Formulazione non ambigua; corretto meccanismo (CHECK, trigger, app)], [Censimento vincoli intra/inter-entità e temporali/concorrenza], [Nessuna duplicazione di vincoli già garantiti dall'E/R], [Vincoli derivanti dalle reali regole aziendali], [Preferenza per vincoli dichiarativi DDL rispetto a trigger pesanti],
  [#strong[D5. Relazionale]], [Traduzione rigorosa (PK, FK, N:M risolte, 1:1 e gerarchie); 3NF verificata], [Tutte le tabelle derivate; mappatura meccanismi vincoli D4], [Nessuna tabella ponte per 1:N; assenza ridondanze transitive], [Rispetto fedele della semantica concettuale di D3], [Normalizzazione 3NF che elimina anomalie di modifica/cancellazione],
  [#strong[D6. DDL SQL]], [Sintassi SQL valida; tipi corretti; PK, FK e vincoli NOT NULL/CHECK/UNIQUE attivi], [Script eseguibile che genera l'intero schema], [Codice pulito, privo di colonne superflue o clausole duplicate], [Nomenclatura chiara, uniforme e professionale], [Tipi dimensionalmente adeguati; indici su FK e campi di ricerca],
  [#strong[D7. DML SQL]], [Istruzioni INSERT valide; rispetto dell'ordine topologico delle FK], [Casi ordinari, limite, nulli, genitori senza figli e test negativo], [Dataset compatto, privo di popolamenti ridondanti fini a se stessi], [Dati realistici e coerenti; assenza di dati personali reali], [Istruzioni multi-insert compatte e ordinate],
  [#strong[D8. QL SQL]], [Sintassi ineccepibile; join corrette (INNER vs LEFT); filtri WHERE/HAVING esatti], [Risoluzione puntuale di tutti i quesiti informativi della traccia], [Solo colonne necessarie (no #NormalTok("SELECT *");); solo tabelle indispensabili], [Restituisce esattamente i dati richiesti, con ordinamento coerente], [Filtri anticipati in WHERE; join su chiavi indicizzate; no subquery lente],
  [#strong[D9. Trasferimento]], [Formulazione chiara, pedagogicamente solida e verificabile], [Traccia completa di contesto, requisiti, vincoli e query], [Incremento mirato e circoscritto di complessità (es. audit, quote)], [Problema isomorfo al dominio di partenza], [Verifica l'effettiva autonomia dello studente senza supporto continuo],
)
=== Gestione dello scaffolding e delle scorciatoie controllate
<sec-scaffolding-scorciatoie>
Nel rispetto dei principi pedagogici espressi in #ref(<sec-specifica-pedagogica>, supplement: [Capitolo]) e delle indicazioni di sostenibilità di #ref(<sec-protocollo-didattico>, supplement: [Capitolo]), il pilota integra due meccanismi controllati di supporto:

- #strong[Scaffolding dello Schema DDL (Tappa 6):] L'obiettivo formativo prioritario nella scuola secondaria risiede nella progettazione logica e nella comprensione dell'integrità referenziale. Se uno studente, pur avendo compreso il modello relazionale, sperimenta frustrazione o stallo bloccante nella traduzione in dialetto SQLite dopo 3--4 iterazioni maieutiche, il tutor è autorizzato a fornire lo schema DDL corretto. Tuttavia, per scongiurare l'accettazione passiva, il tutor subordina il proseguimento alla #strong[spiegazione critica da parte dello studente]: l'allievo deve illustrare ogni tabella, commentare il ruolo delle chiavi esterne e dei vincoli #NormalTok("CHECK");, ed evidenziare esplicitamente quali differenze sussistono rispetto al proprio tentativo iniziale.
- #strong[Scorciatoia DML per la generazione dei dati (Tappa 7):] La digitazione manuale di decine di istruzioni #NormalTok("INSERT INTO"); rappresenta un compito ad alto costo temporale e a basso valore formativo concettuale. Quando lo studente lo richiede, il tutor propone uno script SQL multi-insert sintetico e plausibile, coerente con lo schema dello studente e rigorosamente privo di dati personali reali. Lo studente ha il compito di verificare che i dati rispettino i vincoli del DDL, integrando il dataset con almeno un caso limite e un caso invalido di test.

=== Protocollo di osservazione e metriche specifiche del pilota
<sec-metriche-pilota>
Durante lo svolgimento del pilota "zero-infrastructure" in Google Classroom, i dati per la ricerca vengono raccolti attraverso modalità trasparenti e non invasive:

- #strong[Esportazione delle sessioni di dialogo:] Gli studenti scaricano la trascrizione integrale del dialogo con la Gem o con l'assistente (in formato testo o PDF) e la consegnano come allegato al compito in Google Classroom;
- #strong[Analisi qualitativa della traiettoria maieutica:] I dialoghi vengono analizzati per calcolare:
  - Il livello massimo di aiuto raggiunto per ciascuna delle 9 tappe (scala L0--L4);
  - Il tasso di fedeltà socratica del tutor (assenza di risposte preconfezionate o fughe indebite della soluzione);
  - La frequenza di ricorso allo scaffolding DDL (Tappa 6) e alla generazione assistita dei dati (Tappa 7);
  - La capacità dello studente di recepire i controesempi e correggere autonomamente gli elaborati;
- #strong[Valutazione in cieco degli elaborati finali:] Docenti indipendenti valutano gli elaborati di Tappa 8 (query) e Tappa 9 (problema di trasferimento) con rubrica analitica su scala 1--4 rispetto ai criteri di correttezza, completezza, minimalità, pertinenza ed efficienza;
- #strong[Questionari di gradimento e carico di lavoro:] Rilevazione dell'esperienza d'uso degli studenti (usabilità percepita, senso di autonomia) e del carico orario effettivo del docente (tempo impiegato per predisporre il compito in Classroom e tempo per la revisione delle trascrizioni).

I risultati raccolti in questa fase pilota costituiscono la base empirica per validare i prompt e tarare i pesi dei modelli linguistici prima del collaudo del prototipo completo con integrazione Git e SQLite isolato.

#horizontalrule

== Secondo pilota On-Premise: Sperimentazione locale con Ollama e VLM aperti
<sec-pilota-ollama>
=== Razionale della sperimentazione locale e sovranità del dato
<sec-pilota-ollama-motivo>
Dopo aver validato la tenuta del dialogo socratico e l'accoglienza pedagogica nello scenario cloud "zero-infrastructure" di Google Classroom (#ref(<sec-pilota-classroom>, supplement: [Sezione])), la seconda fase pilota sposta l'indagine sull'#strong[infrastruttura locale d'istituto (#emph[on-premise])], posizionandosi come passaggio intermedio prima della realizzazione dell'infrastruttura mista completa dotata di validatori deterministici rigidi e sandbox SQLite (#ref(<sec-architettura-sistema>, supplement: [Capitolo])).

L'obiettivo di questo secondo pilota è duplice: 1. #strong[Verificare la fattibilità operativa ed economica dell'IA locale nella scuola]: affrancarsi dalla dipendenza da API commerciali cloud, eliminando i costi ricorrenti di inferenza e garantendo la totale sovranità sui dati scolastici (GDPR/DPIA) mediante l'esecuzione autonoma su una singola workstation o server di laboratorio d'istituto dotato di GPU dedicata; 2. #strong[Valutare empiricamente la capacità visiva e maieutica dei modelli aperti (#emph[open-weights])]: verificare se modelli multimodali compatti (3B--8B) siano in grado di interpretare diagrammi concettuali ed E/R (inclusi disegni a mano libera su carta fotografati dagli studenti) e di mantenere la disciplina socratica senza cedere risposte precotte o allucinare sulla sintassi SQL.

A tale scopo, le istruzioni di sistema maieutiche formalizzate per la Gem di Google e per la skill agentica vengono trasferite in un #strong[#NormalTok("Modelfile"); standard per Ollama], consentendo l'orchestrazione e il confronto trasparente tra diversi modelli linguistici e multimodali.

=== Modelli linguistici e multimodali aperti di test
<sec-modelli-vlm-test>
La sperimentazione locale mette a confronto cinque modelli aperti dotati di capacità multimodali (#emph[Vision-Language Models] - VLM) o ad alte prestazioni di reasoning, compatibili con il runtime Ollama e quantizzabili per operare in contesti scolastici con risorse GPU contenute (8--32 GB di VRAM):

+ #strong[Qwen2.5-VL 7B (#NormalTok("qwen2.5vl:7b"); su Ollama):] Rappresenta il modello di riferimento primario per il test. Dotato di un'architettura multimodale all'avanguardia con supporto a risoluzioni dinamiche, eccelle nel riconoscimento della struttura di grafi, diagrammi a blocchi, frecce di associazione e nell'OCR di annotazioni manoscritte su immagini.
+ #strong[Qwen3-8B:] Modello linguistico di nuova generazione con spiccate capacità di ragionamento logico-matematico e coding SQL, particolarmente efficace nel presidio delle regole di normalizzazione (3NF) e nell'analisi sintattica dei vincoli relazionali.
+ #strong[Phi-3.5-vision (#NormalTok("phi3.5-vision");):] Modello compatto da 4.2 miliardi di parametri sviluppato per il reasoning multimodale multi-frame. Si distingue per l'estrema efficienza computazionale e per l'elevata accuratezza nella lettura di tabelle dense e diagrammi concettuali sintetici.
+ #strong[LLaVA v1.6 (#NormalTok("llava:v1.6");):] Modello open source consolidato per l'interazione visiva instruction-tuned (basato su backbone Mistral/Vicuna). Utilizzato nella ricerca come termine di paragone accademico per misurare i progressi delle architetture multimodali nell'istruzione didattica.
+ #strong[Llama 3.2 3B Vision (#NormalTok("llama3.2-vision:3b");):] Architettura multimodale ultra-compatta progettata per edge computing e ambienti con severi vincoli di memoria. Permette di valutare se sia possibile erogare il tutor socratico multimodale persino su GPU consumer o workstation scolastiche economiche dotate di soli 8--12 GB di VRAM.

=== Il Modelfile per Ollama e la taratura dei parametri di inferenza
<sec-modelfile-ollama>
Il tutor locale viene istanziato tramite il file di configurazione #link("file:///home/massi/Documenti/GitHub/socratic-db/ollama/Modelfile")[Modelfile] collocato nella directory #NormalTok("ollama/");. Il file adotta la seguente struttura:

#Skylighting(([#CommentTok("# Modelfile per Ollama - DB-Socrates: Tutor Socratico per Basi di Dati");],
[#CommentTok("# Modello base multimodale intercambiabile (es. Qwen2.5-VL 7B)");],
[#KeywordTok("FROM");#NormalTok(" qwen2.5vl:7b");],
[],
[#CommentTok("# Parametri di inferenza ottimizzati per laboratorio scolastico");],
[#NormalTok("PARAMETER num_ctx 4096");],
[#NormalTok("PARAMETER num_gpu 999");],
[#NormalTok("PARAMETER temperature 0.2");],
[#NormalTok("PARAMETER repeat_penalty 1.1");],
[],
[#CommentTok("# Istruzioni di sistema maieutiche (trasferite da Google Gem)");],
[#NormalTok("SYSTEM ");#StringTok("\"\"\"");],
[#NormalTok("RUOLO E IDENTITÀ:");],
[#NormalTok("Sei ");#StringTok("\"DB-Socrates\"");#NormalTok(", tutor didattico di Basi di Dati...");],
[#NormalTok("[Inclusione integrale dei 5 criteri di qualità, dei 9 deliverable e dei livelli L0-L4]");],
[#StringTok("\"\"\"");],));
I parametri di configurazione del #NormalTok("Modelfile"); rispondono a precisi vincoli tecnici e pedagogici:

- #strong[#NormalTok("PARAMETER num_ctx 4096"); (o #NormalTok("8192");):] La dimensione del contesto è deliberatamente circoscritta a 4096 token (estendibile a 8192 token su GPU con almeno 24 GB di VRAM). Questa limitazione consente di #strong[ridurre drasticamente l'occupazione di memoria della KV cache], evitando che il contesto conversazionale saturi la VRAM e forzi l'offload dei pesi sulla CPU (che degraderebbe il throughput a frazioni di token al secondo). 4096 token risultano ampiamente sufficienti per ospitare il prompt di sistema, le coordinate visive dell'immagine analizzata e i singoli turni maieutici.
- #strong[#NormalTok("PARAMETER num_gpu 999");:] Forza il runtime Ollama a caricare il 100% dei layer della rete neurale e del proiettore visivo all'interno della memoria VRAM della scheda video dedicata. Con l'offload totale, l'elaborazione dei token avviene alla massima velocità consentita dall'hardware (20--50 token/s su schede di fascia media o workstation).
- #strong[#NormalTok("PARAMETER temperature 0.2");:] Una temperatura di campionamento molto bassa è indispensabile nell'ingegneria dei dati per #strong[abbattere il tasso di allucinazione nella sintassi SQL e nella logica relazionale]. Temperature più elevate generano errori sintattici casuali nel DDL o confusioni nelle clausole di JOIN; una temperatura controllata a 0.2 assicura rigore formale e riproducibilità pedagogica, preservando al contempo la naturalezza espressiva necessaria alla formulazione di domande maieutiche.
- #strong[#NormalTok("PARAMETER repeat_penalty 1.1");:] Introduce una moderata penalizzazione per i token già generati. Nelle prove con modelli vision-language, l'analisi di immagini complesse (es. diagrammi con molti attributi ovali o frecce multiple) può innescare #strong[loop degenerativi o ripetizioni ossessive] di frammenti di testo o elenchi; il fattore 1.1 spezza questi cicli ricorsivi garantendo risposte snelle e progressive.

=== Protocollo di valutazione comparativa per il Pilota 2
<sec-valutazione-pilota-ollama>
La sperimentazione locale sottopone ciascuno dei cinque modelli a un benchmark strutturato articolato su quattro dimensioni di collaudo:

+ #strong[Accuratezza dell'analisi visiva (#emph[Vision Benchmark]):]
  - Riconoscimento di diagrammi E/R generati digitalmente (screenshot da Mermaid, draw.io o Canva);
  - Riconoscimento di schemi disegnati a mano libera su carta e fotografati con smartphone (inclusa la corretta lettura delle etichette manoscritte e delle coppie di cardinalità min/max come #NormalTok("0..N"); o #NormalTok("1..1"););
  - Calcolo del tasso di errore nell'individuazione di entità, attributi primari e associazioni rispetto al disegno sorgente dello studente.
+ #strong[Tenuta maieutica e rispetto delle regole socratiche:]
  - Verifica che i modelli open-weight mantengano il vincolo di non fornire schemi completi risolutivi o codice SQL anticipato;
  - Misurazione della capacità di scalare correttamente l'aiuto tra L0 (segnalazione sintetica), L1 (domanda mirata) e L2 (controesempio pratico dal dominio).
+ #strong[Consumo di risorse e profilo hardware:]
  - Rilevazione della VRAM occupata al caricamento del modello (pesi quantizzati a 4/5 bit);
  - Rilevazione dell'espansione della KV cache durante sessioni estese a 4096 token;
  - Misurazione del #emph[Time to First Token] (TTFT) e della velocità media di generazione (token/s).
+ #strong[Capacità di servire sessioni simultanee in laboratorio:]
  - Simulazione di una classe di laboratorio (5--10 studenti che inviano quesiti o immagini contemporaneamente verso l'istanza Ollama centralizzata su LAN);
  - Valutazione del tempo di attesa medio per studente e della stabilità del servizio con gestione tramite coda o inferenza parallela (#NormalTok("OLLAMA_NUM_PARALLEL");).

I risultati del Pilota 2 consentono di selezionare il modello open-weight più affidabile ed efficiente, che costituirà il motore linguistico del prototipo integrato descritto nel capitolo successivo.

#horizontalrule

== Raccolta dati e metriche di processo
<sec-raccolta-metriche>
Tutti i dati raccolti durante la sperimentazione (sia nella fase pilota Classroom che nelle sessioni con sistema integrato) sono associati esclusivamente a identificativi pseudonimi (#NormalTok("s001");, #NormalTok("s002");, …):

- #strong[Metriche quantitative di processo]:
  - Numero di iterazioni conversazionali o commit effettuati per ciascuna fase;
  - Frequenza e tipologia degli errori concettuali e delle diagnosi sollevate (es. cardinalità invertite, attributi transitivi, violazioni di integrità referenziale, errori di sintassi SQL);
  - Livello massimo di aiuto richiesto o erogato (L0--L4) per ciascuna tappa;
  - Frequenza di attivazione dello scaffolding DDL (Tappa 6) e delle scorciatoie DML (Tappa 7);
  - Tempo impiegato per completare ciascuna consegna intermedia e la prova di trasferimento;
  - Tempi effettivi di preparazione e caricamento della traccia da parte del docente (misura della sostenibilità in Classroom e nello strumento d'autore).
- #strong[Metriche di apprendimento e qualità modellistica]:
  - Punteggi ottenuti nelle rubriche analitiche del pre-test, del post-test e della prova di trasferimento autonoma;
  - Valutazione multidimensionale dell'elaborato finale rispetto ai cinque pilastri (#emph[Corretto, Completo, Minimale, Pertinente, Efficiente]);
  - Indice di qualità delle motivazioni scritte (rubrica qualitativa a 3 livelli: menzione di requisiti, analisi delle conseguenze, confronto di alternative).

#horizontalrule

== Analisi statistica e criteri di successo
<sec-analisi-risultati>
- #strong[Trattamento statistico:]
  - Calcolo di statistiche descrittive (mediana, intervallo interquartile, medie e deviazioni standard);
  - Stima delle dimensioni dell'effetto (#emph[effect size], es. $d$ di Cohen o $r$ di Wilcoxon) con intervalli di confidenza al 95%;
  - Data la dimensione contenuta dei campioni tipici scolastici (5--20 studenti per classe), l'analisi quantitativa deve essere interpretata con prudenza ed essere corroborata dall'analisi qualitativa dei percorsi individuali e delle trascrizioni conversazionali.
- #strong[Dichiarazione delle minacce alla validità:]
  - #emph[Effetto novità]: Entusiasmo iniziale per l'uso dell'IA generativa multimodale e delle Gem in chat;
  - #emph[Apprendimento esterno]: Studio autonomo a casa o supporto di pari tra le sessioni di laboratorio;
  - #emph[Maturazione naturale]: Miglioramento fisiologico delle competenze informatiche dovuto al normale avanzamento dell'anno scolastico.

=== Criteri di successo definiti a priori
<criteri-di-successo-definiti-a-priori>
+ #strong[Incremento significativo nel post-test e nel trasferimento]: Miglioramento misurabile nella capacità di modellazione e interrogazione autonoma (fase 9 / Tappa 9) rispetto al livello di ingresso rilevato nel pre-test.
+ #strong[Riduzione della dipendenza dall'aiuto]: Diminuzione visibile del livello medio di aiuto richiesto (da L3/L4 verso L0/L1) tra le prime tappe del percorso e le fasi conclusive.
+ #strong[Tenuta maieutica del tutor LLM nella fase pilota]: Tasso di mancata fuga della soluzione superiore al 95% nelle trascrizioni conversazionali della Gem in Google Classroom, senza rilascio indebito di schemi completi non richiesti dallo scaffolding controllato.
+ #strong[Miglioramento della capacità critica e di motivazione]: Incremento qualitativo dei testi esplicativi forniti dagli studenti nell'analisi nomi-verbi, nelle cardinalità e nella discussione delle forme normali.
+ #strong[Sostenibilità operativa per il docente]: Tempo medio di impostazione del compito in Google Classroom contenuto entro i 15 minuti; tempo di lettura del report e campionamento delle trascrizioni compatibile con il normale orario di servizio curricolare.
+ #strong[Zero incidenti di sicurezza e privacy]: Nessun dato personale di studenti condiviso all'esterno dell'ambiente protetto di Google Workspace for Education e rispetto integrale della normativa GDPR.

#horizontalrule

== Etica, governance e consenso
<sec-etica-governance>
- #strong[Approvazione formale degli organi collegiali:] Delibera del Collegio dei Docenti e del Consiglio di Istituto sull'adozione della sperimentazione didattica con l'IA.
- #strong[Coinvolgimento del DPO e informativa scolastica:] Emissione del parere favorevole sulla Valutazione d'Impatto sulla Protezione dei Dati (DPIA) relativa all'uso di Google Workspace for Education e delle Gem/LLM, con informativa dettagliata alle famiglie e agli studenti.
- #strong[Volontarietà e diritto di recesso:] Possibilità per ogni studente di partecipare senza obbligo e di ritirarsi in qualsiasi momento optando per il percorso didattico tradizionale con correzione periodica del docente, senza alcuna penalizzazione sul piano valutativo curricolare.
- #strong[Restituzione formativa e debriefing:] Sessione finale di confronto in classe con gli studenti per discutere i risultati complessivi, le difficoltà cognitive riscontrate, i limiti riscontrati nelle risposte del modello linguistico e il ruolo consapevole e critico dell'IA generativa nelle professioni informatiche.

#bibliography(("riferimenti.bib"))

