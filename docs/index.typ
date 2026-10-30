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
  date: "2026-10-30",
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

Questo documento descrive una proposta di strumento e metodologia didattica basata sul metodo socratico, per aiutare gli studenti ad acquisire la capacità di progettare e implementare basi di dati relazionali, dall'analisi concettuale al modello logico. Il processo mira a condurre lo studente a produrre una base di dati completa, pertinente, minimale e intelligibile a partire da una descrizione testuale del problema. La costruzione della conoscenza procede come dialogo tra l'arte della domanda, affidata a modelli linguistici, e il rigore della struttura, verificato (quando presente) mediante controlli logico-simbolici. Le abilità modellistiche e di programmazione sono oggetto di esercizio e feedback durante il percorso; la sperimentazione valuterà l'efficacia della proposta sulla base delle interazioni con il sistema, raccolte e trattate in forma pseudonimizzata secondo le regole definite e compatibili con il GDPR e l'AI Act.

#quote(block: true)[
#strong[Nota di stato.] Il presente corpus documentale è, al momento, un #strong[unico insieme di testi in bozza], destinato a più lettori (progettisti, Dirigente scolastico, docenti, DPO, amministratori di piattaforma e di rete, referenti Health School). Eventuali versioni differenziate per destinatario potranno essere prodotte in seguito.
]

#strong[Socratic-DB] è un ambiente di apprendimento assistito dall'Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado.

#strong[Destinatari prioritari della sperimentazione presso l'Istituto proponente:] \ studenti dell'#strong[Istituto Tecnico Economico], indirizzo Amministrazione, Finanza e Marketing, articolazione #strong[Sistemi Informativi Aziendali (SIA / ITSI)].

Il percorso può essere adattato, limitando le fasi, anche a classi del Liceo Scientifico opzione Scienze Applicate (solo analisi e modellazione concettuale, senza SQL). Riferimenti ad altri indirizzi (es. ITIA) riguardano la #strong[trasferibilità] dell'esperienza ad altri contesti scolastici e universitari, non la popolazione iniziale di questa sperimentazione.

Il progetto nasce da un principio pedagogico chiaro: #strong[contrastare la delega cognitiva (#emph[cognitive offloading])] legata all'uso acritico degli strumenti di #emph[Generative Artificial Intelligence]. In questa proposta i modelli linguistici agiscono come #strong[tutor socratici]:

+ #strong[Mediazione maieutica affidata all'LLM]: domande, controesempi, livelli di aiuto L0--L4.
+ #strong[Verità tecnica], quando formalizzabile, affidata a controlli deterministici (introdotti progressivamente).
+ #strong[Valutazione] riservata al docente umano; verifica dell'apprendimento tramite #strong[prova di trasferimento su carta], senza dispositivi elettronici.

== Piani di verifica della sperimentazione
<piani-di-verifica-della-sperimentazione>
- #strong[Modello linguistico:] tenuta maieutica e rispetto dei livelli L0--L4.
- #strong[Infrastruttura:] progressione da zero-infrastructure (Gemini + Classroom) a soluzioni on-premise e, solo in seguito, a stack più completi.
- #strong[Efficacia didattica:] pre-test, post-test, prova di trasferimento, questionari di esperienza e gradimento.
- #strong[Sostenibilità e protocollo:] carico docente, adeguatezza delle fasi al contesto reale, trasferibilità delle buone pratiche.

== Destinatari di questa documentazione
<destinatari-di-questa-documentazione>
- Progettisti della sperimentazione \
- Dirigente scolastico \
- Docenti di Informatica coinvolti \
- DPO \
- Amministratori Google Workspace for Education \
- Personale e referenti del progetto #link("https://formazione.centropapagiovanni.it/health-school/")[Health School] \
- Amministratori dell'infrastruttura informatica e dei servizi di rete

== Struttura del documento
<struttura-del-documento>
- #link("01_stato_dell_arte.md")[Stato dell'arte e inquadramento teorico]
- #link("02_quadro_pedagogico.md")[Quadro pedagogico]: destinatari (SIA prioritario; adattamento Liceo), prerequisiti, obiettivi O1--O8, glossario, ruoli
- #link("03_protocollo_didattico.md")[Protocollo didattico]
- #link("04_architettura_sistema.md")[Architettura del sistema]
- #link("05_formati_e_schemi.md")[Formati e schemi]
- #link("06_normativa_e_sicurezza.md")[Normativa e sicurezza]
- #link("07_sperimentazione.md")[Sperimentazione]: #strong[protocollo empirico], piloti, metriche, pre/post-test, questionari, criteri di successo, trasferibilità
- #link("riferimenti.bib")[Bibliografia]

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

Quando un sistema fornisce direttamente una soluzione completa, esiste il rischio che lo studente accetti il risultato senza saperlo spiegare, verificare o trasferire a un problema diverso. Per Socratic-DB questo è un rischio progettuale da affrontare, non un effetto dato per dimostrato. Per valutarlo si propone di osservare non solo il prodotto finale, ma anche le motivazioni espresse, le revisioni effettuate e la capacità di affrontare una traccia nuova senza assistenza. La prova di trasferimento e il protocollo di sperimentazione sono descritti nel #ref(<sec-disegno-ricerca>, supplement: [Sezione]).

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
#strong[Destinatari primari (Istituto proponente e fase iniziale della sperimentazione)] \ Studenti del secondo biennio e del quinto anno dell'#strong[Istituto Tecnico Economico (ITE)], indirizzo «Amministrazione, Finanza e Marketing», articolazione #strong[«Sistemi Informativi Aziendali» (SIA, codice ITSI)].

#strong[Destinatari in contesti di trasferibilità] \ Il percorso è progettato in modo da poter essere ripreso anche in Istituti Tecnici Tecnologici, indirizzo Informatica e Telecomunicazioni, articolazione Informatica (ITIA), e in corsi universitari introduttivi di basi di dati. Tali contesti non costituiscono la popolazione iniziale della sperimentazione presso l'Istituto proponente.

Il sistema tiene conto dei quadri di riferimento e dei nuclei fondanti della Seconda Prova scritta dell'Esame di Stato per le discipline d'indirizzo (progettazione concettuale, logica e fisica di basi di dati; linguaggi per basi di dati).

#strong[Destinatari secondari / adattati] \ Classi del #strong[Liceo Scientifico opzione Scienze Applicate]. Per queste classi il percorso è limitato alle fasi di analisi dei requisiti e modellazione concettuale Entity-Relationship (con eventuale traduzione verso schema relazionale e individuazione di vincoli). #strong[Non] si prevede la scrittura né l'esecuzione di SQL.

La sperimentazione può inoltre essere estesa e adattata come supporto all'auto-apprendimento guidato in un primo corso universitario di «Basi di Dati».

Le classi coinvolte lavorano tipicamente in gruppi da 5 a 20 studenti, in modalità individuale o a coppie.

== Prerequisiti
<sec-prerequisiti>
- #strong[Matematica e logica di base]:
  - concetti elementari della teoria degli insiemi (rappresentazione, appartenenza, unione, intersezione, differenza/complementazione, prodotto cartesiano e concetto di relazione);
  - fondamenti di logica proposizionale e predicativa (valori di verità, connettivi logici #NormalTok("NOT");, #NormalTok("AND");, #NormalTok("OR");).
- #strong[Concetti introduttivi di modellizzazione e basi di dati]:
  - comprensione intuitiva del modello concettuale (entità, associazione, attributo, cardinalità min/max e concetti base di gerarchia/specializzazione);
  - strutture del modello relazionale (concetti informali di tabella, riga/tupla, colonna/attributo, chiave primaria, chiave esterna e vincoli fondamentali di integrità).
- #strong[Linguaggio SQL di base] (solo per gli indirizzi tecnici):
  - familiarità elementare con la sintassi SQL per le interrogazioni semplici (clausole #NormalTok("SELECT");, #NormalTok("FROM");, #NormalTok("WHERE");); il consolidamento di interrogazioni complesse (#NormalTok("JOIN");, aggregazioni #NormalTok("GROUP BY"); e sottoquery) è uno degli obiettivi formativi del percorso.
- #strong[Competenze digitali e strumentali]:
  - uso base di un editor di testo o ambiente di sviluppo (IDE);
  - familiarità con gli strumenti di Google Workspace for Education (Classroom, Drive) utilizzati nel Pilota 1.

== Struttura del glossario dei termini
<struttura-del-glossario-dei-termini>
Il glossario (derivato dall'analisi nomi-verbi) adotta la struttura consolidata nel Requirements Engineering e nella modellazione di basi di dati:

#table(
  columns: (35%, 65%),
  align: (auto,auto,),
  table.header([Campo], [Descrizione],),
  table.hline(),
  [#strong[Termine]], [Nome del concetto],
  [#strong[Definizione]], [Descrizione chiara e contestuale],
  [#strong[Sinonimi]], [Altri nomi usati per lo stesso concetto],
  [#strong[Omonimi / Da non confondere]], [Termini simili ma con significato diverso],
  [#strong[Classificazione]], [Entità / Attributo / Associazione / Scartare / Altro],
  [#strong[Termini correlati]], [Concetti collegati nel dominio],
)
== Obiettivi di apprendimento
<sec-obiettivi-apprendimento>
Al termine lo studente è in grado di, #strong[autonomamente e senza tutor]:

- #strong[O1.] Ricavare da una traccia i dati, le operazioni e i vincoli (espliciti e impliciti), distinguendo ciò che è dichiarato da ciò che è assunto.
- #strong[O2.] Costruire un modello concettuale Entità/Associazioni (#emph[Entity/Relationship], ER) con entità, attributi, associazioni, cardinalità minime e massime, e motivare ogni scelta.
- #strong[O3.] Distinguere i vincoli rappresentabili nello schema da quelli che richiedono altri meccanismi (#NormalTok("CHECK");, #NormalTok("UNIQUE");, trigger, controllo applicativo).
- #strong[O4.] Tradurre il modello concettuale in schema relazionale scegliendo strategie adeguate per gerarchie, associazioni 1:1 opzionali e obbligatorie, associazioni 1:N e associazioni N:M, trattando i valori nulli e verificando la normalizzazione (1NF, 2NF, 3NF; BCNF se giustificata).
- #strong[O5.] Codificare lo schema usando i costrutti del #emph[Data Definition Language] (DDL) di SQLite, con tipi e vincoli appropriati. #emph[\(Solo indirizzi tecnici)]
- #strong[O6.] Costruire dati di test significativi, inclusi casi limite, nulli e assenza di corrispondenze, codificandoli con istruzioni del #emph[Data Manipulation Language] (DML) di SQLite. #emph[\(Solo indirizzi tecnici)]
- #strong[O7.] Scrivere query SQL corrette, verificarle su dati propri e motivarne la correttezza. #emph[\(Solo indirizzi tecnici)]
- #strong[O8.] Rivedere la propria soluzione a partire da un feedback e giustificare la modifica. Apprendere un modello di sviluppo iterativo in cui la critica di ogni scelta conduce a un modello via via più completo, pertinente, minimale, intelligibile e coerente.

Per il #strong[Liceo Scientifico Scienze Applicate] gli obiettivi si limitano a O1--O3 (e, se ritenuto opportuno, a una versione semplificata di O4).

== Ruoli
<sec-ruoli>
=== Docente
<docente>
- Sceglie o inserisce la traccia (dal catalogo delle Seconda Prove dell'Esame di Stato, da prove d'Istituto o da tracce revisionate) e valida i requisiti.
- Decide la sequenza, i tempi e i livelli di aiuto massimi consentiti.
- Osserva il lavoro in classe, raccoglie le trascrizioni dei dialoghi e gli elaborati.
- #strong[È l'unico a esprimere valutazioni.] Conduce la prova individuale di trasferimento (su carta, senza dispositivi elettronici).
- Partecipa alla correzione in cieco insieme a un secondo docente interno.
- Monitora il carico di lavoro proprio e dei colleghi sperimentatori.

=== LLM (tutor socratico)
<llm-tutor-socratico>
- Compito principale: condurre un dialogo maieutico attraverso domande, controesempi ed elicitazione progressiva dei vincoli, rispettando i livelli di aiuto L0--L4.
- Non assegna punteggi, non dichiara «superato/non superato», non fornisce la soluzione completa.
- Non esegue SQL né valuta la correttezza formale (questo compito, quando presente, è riservato ai controlli deterministici o al docente).
- Dichiara esplicitamente quando una valutazione è non vincolante.
- Se incerto, invita lo studente a rivolgersi al docente.

=== Sistema deterministico (quando attivo nei piloti successivi)
<sistema-deterministico-quando-attivo-nei-piloti-successivi>
- Valida formati, esegue controlli strutturali e, nei piloti più avanzati, opera su schema e query in ambiente isolato.
- Produce diagnosi vincolanti che il tutor linguistico non può contraddire.
- Non sostituisce mai il giudizio del docente.

== Verifica dell'apprendimento: prodotto, processo, trasferimento
<sec-verifica-apprendimento>
La qualità della soluzione finale non dimostra da sola che lo studente l'abbia compresa. Si raccolgono evidenze distinte:

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Dimensione], [Evidenza], [Fonte],),
  table.hline(),
  [Qualità progettuale], [Schema corretto, completo, pertinente, minimale], [Lettura del docente (+ eventuali controlli deterministici)],
  [Ragionamento], [Motivazioni di cardinalità, chiavi e vincoli], [Testi prodotti dallo studente + dialogo],
  [Revisione], [Correzione autonoma dopo feedback], [Storia delle revisioni e livelli di aiuto richiesti],
  [Competenza SQL (solo indirizzi tecnici)], [Query corrette su dati significativi], [Elaborati + eventuale esecuzione controllata],
  [#strong[Trasferimento]], [Soluzione di una traccia nuova, #strong[senza assistenza]], [Prova individuale #strong[su carta], senza dispositivi elettronici, valutata dal docente],
)
La prova di trasferimento #strong[entra nella valutazione sommativa]. Gli elaborati intermedi prodotti con il tutor #strong[non entrano] nella valutazione sommativa.

== Rischi didattici e contromisure
<sec-rischi-didattici>
- #strong[Delega del pensiero (cognitive offloading).] \ #emph[Contromisura:] livelli di aiuto espliciti L0--L4; obbligo di motivazione scritta; prova di trasferimento su carta senza dispositivi.

- #strong[Tutor come sistema di sblocco.] \ #emph[Contromisura:] nessuna soglia automatica di avanzamento; i punti aperti restano visibili; valutazione esclusivamente umana.

- #strong[Sovraccarico cognitivo o di tempo.] \ #emph[Contromisura:] limitazione iniziale a piccole classi; monitoraggio dei tempi; adattamento degli obiettivi per il Liceo.

- #strong[Disomogeneità tra indirizzi.] \ #emph[Contromisura:] percorso completo per ITIA e SIA; percorso ridotto (solo fasi iniziali) per il Liceo Scientifico Scienze Applicate.

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
  columns: (12.5%, 12.5%, 12.5%, 12.5%, 12.5%, 12.5%, 12.5%, 12.5%),
  align: (auto,auto,auto,auto,auto,auto,auto,auto,),
  table.header([Indirizzo], [Anno], [Sessione], [Codice], [Disciplina], [Traccia / dominio nel PDF], [Markdown], [PDF e fonte],),
  table.hline(),
  [ITC -- Programmatori], [2007], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Studio medico associato: medici, visite, pazienti e prestazioni], [#link("../../tracce/mim-2006-07-itc-ordinaria-m733.md")[mim-2006-07-itc-ordinaria-m733.md]], [#link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2007/M733.PDF")[Ministero]],
  [ITC -- Programmatori], [2009], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Casa editrice di riviste specialistiche, abbonati e punti vendita], [#link("../../tracce/mim-2008-09-itc-ordinaria-m733.md")[mim-2008-09-itc-ordinaria-m733.md]], [#link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2009/M733.pdf")[Ministero]],
  [ITC -- Programmatori], [2011], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Agenzia immobiliare e affitti brevi con prenotazioni online], [#link("../../tracce/mim-2010-11-itc-ordinaria-m733.md")[mim-2010-11-itc-ordinaria-m733.md]], [#link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2011/M733.pdf")[Ministero]],
  [ITC -- Programmatori], [2013], [Ordinaria], [M733], [Informatica Generale ed Applicazioni Gestionali], [Biglietteria online per un museo e le sue esposizioni], [#link("../../tracce/mim-2012-13-itc-ordinaria-m733.md")[mim-2012-13-itc-ordinaria-m733.md]], [#link("https://www.istruzione.it/esame_di_stato/Secondo_Ciclo/tracce_prove_scritte/2013/allegati/M733.pdf")[Ministero]],
  [ITIA -- Informatica], [2015], [Simulazione / esempio], [M963], [Informatica], [Consorzio caseario: produzione, vendite e caseifici], [#link("../../tracce/mim-2014-15-itia-esempio-m963.md")[mim-2014-15-itia-esempio-m963.md]], [#link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Esempio%20di%20prova/M963_SIM.pdf")[Ministero]],
  [ITIA -- Informatica], [2015], [Ordinaria], [M963], [Informatica], [Web community per condividere e commentare eventi dal vivo], [#link("../../tracce/mim-2014-15-itia-ordinaria-m963.md")[mim-2014-15-itia-ordinaria-m963.md]], [#link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Ordinaria/M963_ORD.pdf")[Ministero]],
  [ITIA -- Informatica], [2015], [Suppletiva], [M963], [Informatica], [Rete di centri e prestito di risorse multimediali], [#link("../../tracce/mim-2014-15-itia-suppletiva-m963.md")[mim-2014-15-itia-suppletiva-m963.md]], [#link("https://www.istruzione.it/esame_di_stato/201415/Istituti%20tecnici/Suppletiva/M963_SUP.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Esempio di prova], [M967], [Informatica], [Azienda di abbigliamento e tracciamento dei capi nei punti vendita (Gamma)], [#link("../../tracce/mim-2015-16-itsi-esempio-m967.md")[mim-2015-16-itsi-esempio-m967.md]], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Esempio%20di%20prova/M967_SIM16.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Ordinaria], [M967], [Informatica], [City2City -- Collegamenti passeggeri verso città europee], [#link("../../tracce/mim-2015-16-itsi-ordinaria-m967.md")[mim-2015-16-itsi-ordinaria-m967.md]], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Ordinaria/M967_ORD16.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Straordinaria], [M967], [Informatica], [Sessione straordinaria 2016], [#link("../../tracce/mim-2015-16-itsi-straordinaria-m967.md")[mim-2015-16-itsi-straordinaria-m967.md]], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Straordinaria/M967_STR16.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2016], [Suppletiva], [M967], [Informatica], [Sessione suppletiva 2016], [#link("../../tracce/mim-2015-16-itsi-suppletiva-m967.md")[mim-2015-16-itsi-suppletiva-m967.md]], [#link("https://www.istruzione.it/esame_di_stato/201516/Istituti%20tecnici/Suppletiva/M967_SUP16.pdf")[Ministero]],
  [ITIA -- Informatica], [2017], [Ordinaria], [I044], [Informatica], [Seconda prova ITIA 2017 ordinaria], [#link("../../tracce/mim-2016-17-itia-ordinaria-i044.md")[mim-2016-17-itia-ordinaria-i044.md]], [#link("https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Ordinaria/I044_ORD17.pdf")[Ministero]],
  [ITIA -- Informatica], [2017], [Straordinaria], [I044], [Informatica], [Seconda prova ITIA 2017 straordinaria], [#link("../../tracce/mim-2016-17-itia-straordinaria-i044.md")[mim-2016-17-itia-straordinaria-i044.md]], [#link("https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Straordinaria/I044_STR17.pdf")[Ministero]],
  [ITIA -- Informatica], [2017], [Suppletiva], [I044], [Informatica], [Seconda prova ITIA 2017 suppletiva], [#link("../../tracce/mim-2016-17-itia-suppletiva-i044.md")[mim-2016-17-itia-suppletiva-i044.md]], [#link("https://www.istruzione.it/esame_di_stato/201617/Istituti%20tecnici/Suppletiva/I044_SUP17.pdf")[Ministero]],
  [ITIA -- Informatica], [2018], [Ordinaria], [I044], [Informatica], [Seconda prova ITIA 2018 ordinaria], [#link("../../tracce/mim-2017-18-itia-ordinaria-i044.md")[mim-2017-18-itia-ordinaria-i044.md]], [#link("https://www.istruzione.it/esame_di_stato/201718/Istituti%20tecnici/Ordinaria/I044_ORD18.pdf")[Ministero]],
  [ITIA -- Informatica], [2018], [Straordinaria], [I044], [Informatica], [Seconda prova ITIA 2018 straordinaria], [#link("../../tracce/mim-2017-18-itia-straordinaria-i044.md")[mim-2017-18-itia-straordinaria-i044.md]], [#link("https://www.istruzione.it/esame_di_stato/201718/Istituti%20tecnici/Straordinaria/I044_STR18.pdf")[Ministero]],
  [ITIA -- Informatica], [2018], [Suppletiva], [I044], [Informatica], [Seconda prova ITIA 2018 suppletiva], [#link("../../tracce/mim-2017-18-itia-suppletiva-i044.md")[mim-2017-18-itia-suppletiva-i044.md]], [#link("https://www.istruzione.it/esame_di_stato/201718/Istituti%20tecnici/Suppletiva/I044_SUP18.pdf")[Ministero]],
  [ITIA -- Informatica], [2019], [Ordinaria], [AB42], [Informatica], [Seconda prova 2019 ordinaria (AB42)], [#link("../../tracce/mim-2018-19-itia-ordinaria-ab42.md")[mim-2018-19-itia-ordinaria-ab42.md]], [#link("https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Ordinaria/AB42_ORD19.pdf")[Ministero]],
  [ITIA -- Informatica], [2019], [Straordinaria], [AB42], [Informatica], [Seconda prova 2019 straordinaria (AB42)], [#link("../../tracce/mim-2018-19-itia-straordinaria-ab42.md")[mim-2018-19-itia-straordinaria-ab42.md]], [#link("https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Straordinaria/AB42_STR19.pdf")[Ministero]],
  [ITIA -- Informatica], [2019], [Suppletiva], [AB42], [Informatica], [Seconda prova 2019 suppletiva (AB42)], [#link("../../tracce/mim-2018-19-itia-suppletiva-ab42.md")[mim-2018-19-itia-suppletiva-ab42.md]], [#link("https://www.istruzione.it/esame_di_stato/201819/Istituti%20tecnici/Suppletiva/AB42_SUP19.pdf")[Ministero]],
  [ITIA -- Informatica], [2023], [Ordinaria], [A038], [Informatica], [Seconda prova 2023 ordinaria (A038)], [#link("../../tracce/mim-2022-23-itia-ordinaria-a038.md")[mim-2022-23-itia-ordinaria-a038.md]], [#link("https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Ordinaria/A038_ORD23.pdf")[Ministero]],
  [ITIA -- Informatica], [2023], [Suppletiva], [A038], [Informatica], [Seconda prova 2023 suppletiva (A038)], [#link("../../tracce/mim-2022-23-itia-suppletiva-a038.md")[mim-2022-23-itia-suppletiva-a038.md]], [#link("https://www.istruzione.it/esame_di_stato/202223/Istituti%20tecnici/Suppletiva/A038_SUP23.pdf")[Ministero]],
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
Quando il docente abilita la generazione assistita dei dati:

- Lo script SQL generato deve essere composto unicamente da istruzioni #NormalTok("INSERT");.
- Esecuzione obbligatoria senza errori sul DDL dello studente con #NormalTok("PRAGMA foreign_keys = ON;");.
- Verifica della copertura strutturale minima derivata dallo schema: numero minimo di righe per tabella, presenza di almeno un'istanza genitore priva di figli, presenza di valori nulli nelle colonne opzionali, valori ripetuti per consentire test di aggregazione (#NormalTok("GROUP BY"); e #NormalTok("COUNT");).
- I casi invalidi generati per test negativo devono fallire l'inserimento.

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
Funzionalità previste per successive evoluzioni della piattaforma:

- #strong[Visione artificiale per schemi manoscritti:] Modello multimodale (VLM) per la trascrizione automatica di diagrammi concettuali disegnati a mano libera su carta; la trascrizione produce un'ipotesi YAML che lo studente corregge e valida prima di avviare il dialogo.
- #strong[Architettura multi-agente specializzata:] Disaccoppiamento tra agente trascrittore, agente per l'analisi di vincoli complessi, generatore di controesempi e sintetizzatore di report per il docente, coordinati da una FSM centrale.
- #strong[Supporto multi-notazione:] Convertitori bidirezionali tra formato YAML e formati grafici o testuali (Mermaid, PlantUML, diagrammi relazionali Chen/Crow's Foot).
- #strong[RAG locale:] Retrieval-Augmented Generation su slide di lezione, testi di riferimento e dispense del docente.
- #strong[Cruscotto analitico:] Dashboard con indicatori aggregati di classe per identificare i concetti critici (es. frequenza di violazioni della 3NF, tempo medio di risoluzione delle chiavi esterne).

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
Quanto segue costituisce una traccia operativa di conformità normativa e di sicurezza da validare con il Responsabile della Protezione dei Dati (DPO) dell'istituzione scolastica e con il Dirigente Scolastico prima dell'avvio della sperimentazione; #strong[non costituisce parere legale formale].

#horizontalrule

== Trattamento dei dati personali (GDPR)
<sec-trattamento-dati>
La tabella seguente sintetizza le scelte di conformità al Regolamento Generale sulla Protezione dei Dati (GDPR -- Regolamento UE 2016/679):

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Aspetto], [Scelta e misura operativa],),
  table.hline(),
  [#strong[Titolare del trattamento]], [L'istituzione scolastica in cui si svolge la sperimentazione.],
  [#strong[Finalità]], [Supporto didattico formativo curricolare; eventuale ricerca didattica in forma rigorosamente aggregata e anonima.],
  [#strong[Base giuridica preferita]], [#strong[Consenso esplicito] degli esercenti la responsabilità genitoriale (art. 6.1.a GDPR). In alternativa, per gli studenti maggiorenni, consenso diretto dell'interessato.],
  [#strong[Opzione semplificativa]], [Possibilità di limitare la partecipazione agli studenti maggiorenni, riducendo la complessità del consenso.],
  [#strong[Tutela dei minori]], [Informativa trasparente e accessibile a studenti ed esercenti la responsabilità genitoriale.],
  [#strong[Dati trattati]], [Elaborati didattici, testi di motivazione, trascrizioni dei dialoghi con il tutor, log tecnici; #strong[divieto categorico di inserire dati personali reali] nelle tracce e nei dataset di prova.],
  [#strong[Minimizzazione e pseudonimizzazione]], [Adozione di identificatori pseudonimi casuali (es. #NormalTok("s017");); nessun nome o dato anagrafico inserito nei prompt.],
  [#strong[Conservazione]], [Conservazione dei log e dei dialoghi limitata alla durata dell'anno scolastico, con successiva cancellazione sicura o anonimizzazione irreversibile. Le eventuali pubblicazioni di ricerca utilizzano solo dati aggregati.],
  [#strong[Ruoli e accessi]], [Studente: accesso esclusivo ai propri dati. Docente sperimentatore: accesso ai dati e ai report della propria classe. Correttore in cieco: accesso agli elaborati in forma pseudonimizzata. Amministratore di sistema: accesso per sole finalità di manutenzione tecnica.],
  [#strong[Destinatari terzi (Pilota 1)]], [Google Workspace for Education / Gemini, già utilizzato e regolamentato dall'Istituto. I dati restano all'interno dell'ambiente protetto dell'account istituzionale.],
  [#strong[Destinatari terzi (Piloti successivi)]], [Nessun destinatario esterno: modelli di inferenza e controlli operano in rete locale (#emph[on-premise]).],
  [#strong[Diritti degli interessati]], [Esercizio dei diritti di accesso, rettifica, cancellazione e limitazione garantito e gestito direttamente tramite la segreteria dell'Istituto.],
)
=== Adempimenti documentali
<adempimenti-documentali>
Prima dell'inizio delle attività devono essere predisposti:

+ Informativa sul trattamento dei dati per studenti e famiglie;
+ Modulo di consenso esplicito (genitori o studente maggiorenne);
+ Aggiornamento del Registro dei Trattamenti dell'Istituto;
+ Valutazione d'Impatto sulla Protezione dei Dati (DPIA), se richiesta dal DPO, per l'introduzione di strumenti di intelligenza artificiale con minori;
+ Linee guida per gli studenti sull'uso esclusivo di dati sintetici o di fantasia.

#horizontalrule

== Misure di sicurezza tecniche e organizzative
<sec-misure-sicurezza>
=== Pilota 1 (Google Classroom + Gemini)
<pilota-1-google-classroom-gemini>
- Utilizzo esclusivo degli account istituzionali Google Workspace for Education.
- Condivisione delle Gem solo all'interno dell'organizzazione scolastica.
- Gli studenti scaricano le trascrizioni e le consegnano come allegati al compito in Classroom.
- Nessun dato personale reale viene inserito nelle tracce o nei prompt.

=== Piloti successivi (Ollama e stack locale)
<piloti-successivi-ollama-e-stack-locale>
- #strong[Isolamento di rete:] i server di inferenza e i container di esecuzione risiedono nella sottorete dell'Istituto priva di connessioni in uscita verso Internet non controllate.
- #strong[Isolamento dell'esecutore SQL] (quando presente): esecuzione in ambiente isolato, database in memoria, restrizioni su filesystem e rete.
- #strong[Protezione da Prompt Injection:] il testo prodotto dallo studente è trattato come dato passivo; il modello tutor non dispone di tool d'azione o privilegi di esecuzione.
- #strong[Tracciabilità:] conservazione dei log tecnici con canali separati per monitoraggio operativo.
- #strong[Verifica delle licenze:] accertamento della compatibilità per uso didattico dei modelli open-weight adottati.

#horizontalrule

== Valutazione e quadro regolatorio sull'Intelligenza Artificiale (AI Act)
<sec-ai-act>
Socratic-DB è configurato come #strong[sistema di supporto formativo non valutativo]:

- non assegna voti;
- non produce punteggi automatici;
- non effettua profilazione degli studenti;
- non determina accesso a percorsi educativi o valutazioni ufficiali.

La valutazione dell'apprendimento resta #strong[esclusiva prerogativa del docente umano], anche attraverso la prova di trasferimento svolta su carta senza dispositivi elettronici.

In questa configurazione il sistema non rientra tra i sistemi di IA ad alto rischio di cui all'Allegato III del Regolamento (UE) 2024/1689 (AI Act), in particolare per quanto riguarda i sistemi destinati a determinare l'accesso o a valutare gli studenti nell'ambito dell'istruzione.

Resta comunque obbligatorio:

- informare chiaramente studenti e famiglie della natura e dei limiti del sistema;
- garantire la supervisione umana;
- consentire il diritto di recesso e il percorso didattico tradizionale alternativo.

#horizontalrule

== Governance e responsabilità
<governance-e-responsabilità>
- #strong[DPO di Istituto]: già nominato; coinvolto preventivamente per informativa, consenso e (se necessaria) DPIA.
- #strong[Dirigente Scolastica]: autorizzazione formale all'avvio della sperimentazione.
- #strong[Docenti sperimentatori (3) + correttore in cieco (1)]: responsabilità didattica e di corretta gestione dei dati pseudonimizzati.
- #strong[Volontarietà]: ogni studente può partecipare o ritirarsi in qualsiasi momento senza penalizzazioni valutative, optando per il percorso tradizionale.

Ogni modifica sostanziale al trattamento dei dati o all'architettura dovrà essere sottoposta nuovamente al DPO e alla Dirigente.

= Protocollo di sperimentazione empirica di Socratic-DB
<sec-protocollo-sperimentazione>
#quote(block: true)[
#strong[Nota di stato.] Il presente testo è, al momento, un #strong[unico documento in bozza] destinato a più lettori (progettisti della sperimentazione, Dirigente scolastico, docenti coinvolti, DPO, amministratori Google Workspace, personale del progetto Health School, amministratori dell'infrastruttura informatica). Eventuali versioni differenziate per destinatario potranno essere derivate in una fase successiva.
]

#horizontalrule

== Premessa e inquadramento istituzionale
<premessa-e-inquadramento-istituzionale>
Socratic-DB è un ambiente di apprendimento assistito dall'Intelligenza Artificiale Generativa progettato per contrastare la #emph[delega cognitiva] (#emph[cognitive offloading]) nella progettazione di basi di dati relazionali. Il sistema affida all'LLM la sola mediazione maieutica (domande, controesempi, livelli di aiuto L0--L4) e riserva al docente umano la valutazione definitiva dell'apprendimento.

=== Istituto proponente e destinatari della sperimentazione
<istituto-proponente-e-destinatari-della-sperimentazione>
La sperimentazione è proposta e avviata presso un Istituto di Istruzione Superiore che comprende, tra gli altri, un #strong[Istituto Tecnico Economico] con indirizzo Amministrazione, Finanza e Marketing e articolazione #strong[Sistemi Informativi Aziendali (SIA / codice ITSI)].

#strong[Fase iniziale (prioritaria):] studenti dell'articolazione #strong[SIA]. \ #strong[Fasi successive (eventuali):] altre classi dell'Istituto in cui è presente l'insegnamento di Informatica e delle basi di dati relazionali (incluse, con percorso ridotto, classi del Liceo Scientifico opzione Scienze Applicate).

#strong[Nota.] L'indirizzo ITIA (Informatica e Telecomunicazioni) non è presente nell'Istituto proponente; eventuali riferimenti a ITIA in documenti generali del progetto Socratic-DB riguardano la trasferibilità dell'esperienza ad altri contesti, non la popolazione iniziale di questa sperimentazione.

=== Destinatari di questo documento
<destinatari-di-questo-documento>
- Progettisti e docenti sperimentatori
- Dirigente scolastico
- Docenti di Informatica coinvolti
- Responsabile della Protezione dei Dati (DPO)
- Amministratori della piattaforma Google Workspace for Education
- Personale e referenti del progetto #link("https://formazione.centropapagiovanni.it/health-school/")[Health School]
- Amministratori dell'infrastruttura informatica e dei servizi di rete dell'Istituto

=== Vincoli organizzativi
<vincoli-organizzativi>
- Lezioni di Informatica in moduli di #strong[2 ore consecutive]
- Periodo: inizio del secondo quadrimestre (#strong[febbraio--marzo])
- Durata: #strong[6--8 ore] in classe con il tutor + #strong[2 ore] di prova di trasferimento + eventuali #strong[2--4 ore] di lavoro domestico
- Hardware: workstation di laboratorio con #strong[6 GB di VRAM], 64 GB di RAM, 32 thread
- Cloud: Google Workspace for Education con Gemini (uso subordinato a conferma del DPO)
- Risorse umane: #strong[3 docenti sperimentatori] + #strong[1 correttore in cieco] interno
- Rubrica analitica condivisa già disponibile tra i docenti

La sperimentazione inizia con una classe quinta SIA di #strong[5 studenti] e può essere estesa in modo progressivo e controllato.

#horizontalrule

== Obiettivi della sperimentazione
<obiettivi-della-sperimentazione>
=== Obiettivi primari (articolazione SIA)
<obiettivi-primari-articolazione-sia>
+ Verificare se l'uso di un tutor socratico basato su LLM, con livelli di aiuto espliciti L0--L4, riduce la delega cognitiva e favorisce l'acquisizione autonoma delle competenze di modellazione e interrogazione di basi di dati.
+ Misurare l'efficacia didattica attraverso pre-test, post-test e #strong[prova di trasferimento] su carta, senza dispositivi elettronici.
+ Valutare la tenuta maieutica del tutor (assenza di "fuga della soluzione") e la sostenibilità operativa per il docente.

=== Obiettivi secondari / adattati (Liceo Scientifico Scienze Applicate, se coinvolto)
<obiettivi-secondari-adattati-liceo-scientifico-scienze-applicate-se-coinvolto>
Limitazione alle fasi di analisi dei requisiti, glossario e modellazione concettuale Entity-Relationship (eventualmente schema relazionale semplificato). #strong[Non] si prevede scrittura né esecuzione di SQL.

=== Obiettivi di processo, trasferimento e buone pratiche
<obiettivi-di-processo-trasferimento-e-buone-pratiche>
- Validare la progressione a piloti (da zero-infrastructure a stack più completo).
- Quantificare e contenere il carico di lavoro dei docenti sperimentatori.
- Raccogliere evidenze utili a definire #strong[buone pratiche trasferibili]:
  - in ambito disciplinare (Informatica nella secondaria di secondo grado; corsi universitari introduttivi di basi di dati);
  - in ambito trasversale (tutor socratici, metodologia maieutica, separazione tra mediazione linguistica e controlli, protocolli di sperimentazione sull'IA a scuola).

=== Allineamento alle Indicazioni CINI sull'Informatica a scuola
<allineamento-alle-indicazioni-cini-sullinformatica-a-scuola>
La proposta si colloca in continuità con la #emph[Proposta di Indicazioni Nazionali per l'insegnamento dell'Informatica nella Scuola] del Laboratorio «Informatica e Scuola» del CINI, in particolare rispetto a:

- capacità di #strong[modellare problemi] e di rappresentare e organizzare dati;
- distinzione tra livelli di astrazione (concettuale / logico);
- consapevolezza di come la rappresentazione dei dati influisca su efficacia ed efficienza;
- uso consapevole degli strumenti digitali, qui declinato come contrasto alla delega cognitiva verso gli LLM.

Il percorso Socratic-DB esercita, in modo mirato, competenze di analisi dei requisiti, modellazione concettuale e logica, e (per i percorsi tecnici) interrogazione, in un contesto di scaffolding dialogico controllato.

#horizontalrule

== Protocollo sperimentale e modalità di rilevazione
<sec-disegno-ricerca>
Il protocollo adotta un approccio #strong[intra-soggetto] (pre-test → intervento → post-test → prova di trasferimento a 3--4 settimane) per tutti gli studenti coinvolti.

Nella prima sperimentazione #strong[non] si prevede un gruppo di controllo formale né un disegno a rotazione (#emph[crossover]), per minimizzare il carico organizzativo e le criticità etiche. Confronti descrittivi con classi parallele potranno essere valutati in fasi successive.

=== Strumenti di misurazione e impatto
<strumenti-di-misurazione-e-impatto>
#table(
  columns: (27.5%, 22.5%, 25%, 25%),
  align: (auto,auto,auto,auto,),
  table.header([Strumento], [Momento], [Modalità], [Finalità],),
  table.hline(),
  [#strong[Pre-test diagnostico]], [Prima dell'intervento], [Su carta o in laboratorio controllato; rubrica condivisa], [Livello di partenza su analisi, modellazione, (eventualmente) SQL],
  [#strong[Attività formative con Socratic-DB]], [Durante le 6--8 ore], [Dialogo con tutor + elaborati intermedi (glossario, E/R, modello logico)], [Processo e livelli di aiuto richiesti],
  [#strong[Post-test]], [Al termine dell'intervento], [Individuale, rubrica condivisa], [Variazione rispetto al pre-test],
  [#strong[Prova di trasferimento]], [3--4 settimane dopo], [#strong[Su carta, senza dispositivi] (2 ore); rubrica condivisa], [Ritenzione e autonomia; #strong[entra nella valutazione sommativa]],
  [#strong[Correzione in cieco]], [Dopo post-test e prova di trasferimento], [Sperimentatore + correttore interno], [Accordi inter-valutatore; riduzione bias],
  [#strong[Autodichiarazione fuga della soluzione]], [Fine attività con tutor], [Domanda strutturata + verifica a campione], [Tenuta maieutica del tutor],
  [#strong[Questionario di esperienza e gradimento]], [Fine percorso], [Scala Likert + domande aperte], [Usabilità, autoefficacia, carico percepito, utilità],
  [#strong[Diario / note del docente]], [Continuo], [Osservazione in classe], [Blocchi tecnici/didattici, andamento del dialogo],
)
Gli elaborati intermedi prodotti con il tutor #strong[non entrano] nella valutazione sommativa; servono al monitoraggio del processo e alla ricerca.

Esempi di item per pre/post-test e prova di trasferimento potranno essere costruiti a partire dalle tracce ministeriali catalogate in #NormalTok("tracce/"); (Seconda Prova SIA/ITSI e analoghe), adattate in complessità al tempo disponibile.

#horizontalrule

== Progressione a piloti
<progressione-a-piloti>
+ #strong[Pilota 1 -- Zero-infrastructure] (già avviato): Gem di Gemini in Google Classroom. \
+ #strong[Pilota 2 -- On-premise leggero]: Ollama sulla workstation (6 GB VRAM). \
+ #strong[Pilota 3 -- Stack parziale]: alcuni controlli deterministici e sandbox SQLite. \
+ #strong[Pilota 4 -- Stack completo]: architettura neuro-simbolica piena (solo dopo consolidamento).

Criteri di passaggio (go/no-go) includono: tenuta maieutica entro le soglie di fuga, feedback positivo, assenza di incidenti privacy, carico docente entro le stime.

#horizontalrule

== Protocollo operativo
<protocollo-operativo>
=== Ruoli
<ruoli>
#table(
  columns: (12.28%, 28.07%, 59.65%),
  align: (auto,auto,auto,),
  table.header([Ruolo], [Responsabilità], [Carico stimato (fase 5 studenti)],),
  table.hline(),
  [Docente sperimentatore (3)], [Traccia, gestione classe, osservazione, trascrizioni, prima valutazione], [#strong[12 ore] extracurricolari a docente],
  [Correttore in cieco (1)], [Valutazione indipendente post-test e prova di trasferimento], [#strong[5 ore]],
  [Studente], [Dialogo con tutor, elaborati, prova di trasferimento su carta], [---],
  [Dirigente / DPO], [Autorizzazione, privacy, delibere], [---],
)
=== Flusso didattico (articolazione SIA)
<flusso-didattico-articolazione-sia>
#strong[In classe (6--8 ore)]

+ Pre-test
+ Patto formativo e livelli L0--L4
+ Glossario (struttura: Termine, Definizione, Sinonimi, Omonimi/Da non confondere, Classificazione, Termini correlati)
+ Modello concettuale E/R (vincoli espliciti: cardinalità)
+ Modello logico in Markdown + vincoli in linguaggio naturale/SQL-like
+ Eventuali DDL/DML/query se il tempo lo consente
+ Post-test e autodichiarazione sulla fuga della soluzione

#strong[Prova di trasferimento] (2 ore, a 3--4 settimane): su carta, senza dispositivi; entra nel voto.

=== Lavoro domestico e scenari di esecuzione locale
<lavoro-domestico-e-scenari-di-esecuzione-locale>
#strong[Fase attuale (Pilota 1).] \ Il lavoro domestico (indicativamente 2--4 ore) consiste nell'uso della #strong[Gem istituzionale] di Gemini, con le stesse istruzioni socratiche impiegate in classe. È #strong[incoraggiato], non obbligatorio e #strong[non controllabile] ora per ora. L'ancoraggio all'autonomia resta la prova di trasferimento su carta, senza dispositivi elettronici.

#strong[Scenario evolutivo.] \ Se in seguito saranno rilasciati in modo aperto il Modelfile Ollama, immagini Docker o un runtime minimo dello stack, diventa tecnicamente prevedibile l'esecuzione del tutor sul #strong[dispositivo dello studente] (notebook/PC con GPU consumer, NPU integrate, architetture a memoria unificata). In quel caso:

- andrà definita una configurazione "scolastica" del runtime (system prompt non facilmente alterabile);
- andrà valutato l'impatto su #strong[equità] (chi non dispone di hardware adeguato non deve essere svantaggiato nelle attività curricolari);
- i dialoghi locali non entreranno automaticamente nei log istituzionali: le metriche di processo andranno integrate con autodichiarazioni e, se opportuno, esportazioni campionarie di sessioni;
- privacy e integrità del tutor (modifica del prompt, modelli non ufficiali) saranno oggetto di valutazione dedicata con il DPO prima di qualsiasi raccomandazione agli studenti.

#strong[Principi invarianti] (cloud o locale): livelli di aiuto L0--L4; divieto di soluzione completa; valutazione solo del docente; prova di trasferimento senza dispositivi. Nella fase 1 #strong[non] si promuove l'installazione di modelli open-weight su device personali.

=== Materiali
<materiali>
Tracce da catalogo Seconda Prova (Esame di Stato), prove d'Istituto, tracce generate da LLM e #strong[sempre revisionate da docenti]. Prove di complessità ridotta per consentire tempi di correzione realistici (\~15 min/compito).

#horizontalrule

== Metriche e soglie
<metriche-e-soglie>
#strong[Processo]

- Livello massimo di aiuto (L0--L4)
- Numero di iterazioni
- Tempi stimati

#strong[Fuga della soluzione] (autodichiarazione + verifica a campione)

- Campione di 5 studenti: inferiore al 10 %
- Campione ampio: inferiore al 5 %

#strong[Apprendimento]

- Punteggi pre-test, post-test e prova di trasferimento (rubrica condivisa)
- Qualità delle motivazioni
- Accordo inter-valutatore

#strong[Sostenibilità]

- Tempo di predisposizione e di lettura delle trascrizioni
- Rispetto delle 12 ore extracurricolari a docente (fase iniziale)

#strong[Esperienza]

- Questionario Likert e domande aperte (usabilità, autonomia, utilità, carico)

#horizontalrule

== Consenso e privacy
<consenso-e-privacy>
- Base preferita: #strong[consenso esplicito] dei genitori (o dello studente maggiorenne). \
- Opzione: limitazione ai maggiorenni. \
- Informativa, Registro trattamenti, DPIA se richiesta dal DPO. \
- Pilota 1 su Google Workspace subordinato a conferma del DPO. \
- Nessun dato personale reale nelle tracce. \
- Partecipazione volontaria; diritto di recesso senza penalizzazioni.

#horizontalrule

== Cronoprogramma indicativo
<cronoprogramma-indicativo>
#table(
  columns: (47.37%, 52.63%),
  align: (auto,auto,),
  table.header([Periodo], [Attività],),
  table.hline(),
  [Dicembre -- gennaio], [Informativa e consensi; formazione dei 3 sperimentatori; affinamento Gem; conferma DPO su Gemini],
  [Febbraio], [Avvio Pilota 1 (classe quinta SIA, 5 studenti): pre-test + attività],
  [Febbraio -- marzo], [Completamento 6--8 ore; post-test e autodichiarazione],
  [Marzo -- aprile], [Prova di trasferimento (2 h); correzione in cieco; prime analisi],
  [Aprile -- maggio], [Eventuale estensione; avvio Pilota 2 se criteri di go soddisfatti],
  [Fine anno], [Relazione intermedia; decisioni sulla prosecuzione],
)

#horizontalrule

== Criteri di successo e di interruzione
<criteri-di-successo-e-di-interruzione>
#strong[Successo]

- Miglioramento misurabile tra pre-test e prova di trasferimento
- Riduzione del ricorso ai livelli di aiuto L3--L4
- Fuga della soluzione sotto le soglie definite
- Carico docente entro le stime
- Assenza di incidenti di privacy
- Feedback complessivamente positivo da studenti e docenti

#strong[Interruzione o ridimensionamento]

- Problemi tecnici non risolvibili in tempi ragionevoli
- Carico incompatibile con l'orario di servizio
- Fuga sistematica della soluzione oltre le soglie
- Criticità segnalate dal DPO
- Feedback fortemente negativo da studenti o famiglie

#horizontalrule

== Rischi e mitigazioni
<rischi-e-mitigazioni>
#table(
  columns: (40.91%, 59.09%),
  align: (auto,auto,),
  table.header([Rischio], [Mitigazione],),
  table.hline(),
  [Delega cognitiva], [Livelli L0--L4 + prova di trasferimento su carta],
  [Fuga della soluzione], [Istruzioni rigorose + autodichiarazione + campione],
  [Carico docente], [Avvio con 5 studenti; stime orarie esplicite],
  [6 GB VRAM], [Modelli quantizzati; priorità al Pilota 1],
  [Privacy], [DPO; consenso; opzione maggiorenni],
  [Lavoro domestico non controllabile], [Accettato come limite in fase 1; solo incoraggiamento; prova di trasferimento come ancoraggio],
  [Esecuzione locale su device studente (scenario futuro)], [Non attivata in fase 1; se introdotta: runtime "scolastico", valutazione equità e DPO],
)

#horizontalrule

== Trasferibilità e piano di espansione
<trasferibilità-e-piano-di-espansione>
+ Consolidamento del Pilota 1 sulla classe SIA iniziale. \
+ Estensione graduale ad altre classi SIA e, con adattamento, ad altri percorsi dell'Istituto. \
+ Documentazione di #strong[buone pratiche] (prompt, livelli di aiuto, protocollo di rilevazione, rubriche) riutilizzabili da altre scuole e da corsi universitari introduttivi di basi di dati. \
+ Possibile estensione metodologica a tutor socratici in altri ambiti disciplinari. \
+ Relazioni intermedie e finali per la governance dell'Istituto e per la condivisione in reti di scuole / progetti (incluso Health School).

#horizontalrule

== Governance
<governance>
- Informativa e consensi \
- Parere / conferma del DPO (in particolare su Gemini) \
- Autorizzazione della Dirigente scolastica \
- Eventuali delibere collegiali secondo le prassi dell'Istituto \
- Restituzione formativa agli studenti

Ogni modifica sostanziale al protocollo va motivata e sottoposta a Dirigente e DPO.

#bibliography(("riferimenti.bib"))

