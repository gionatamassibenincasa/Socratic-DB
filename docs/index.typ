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
        show figure.where(kind: kind): set figure(outlined: false)

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
  lof: false,
  lof-title: none,
  lot: false,
  lot-title: none,
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
      title: title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if lof {
    block(above: 0em, below: 2em)[
    #outline(title: lof-title, target: figure.where(kind: "quarto-float-fig"));
    ]
  }

  if lot {
    block(above: 0em, below: 2em)[
    #outline(title: lot-title, target: figure.where(kind: "quarto-float-tbl"));
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
  date: "2026-11-13",
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

#strong[Socratic-DB] è un ambiente di apprendimento assistito dall'Intelligenza Artificiale Generativa per la scuola secondaria di secondo grado.

#strong[Destinatari prioritari della sperimentazione presso l'Istituto proponente:] \ studenti dell'#strong[Istituto Tecnico Economico], indirizzo Amministrazione, Finanza e Marketing, articolazione #strong[Sistemi Informativi Aziendali (SIA / ITSI)].

Il percorso può essere adattato, limitando le fasi, anche a classi del Liceo Scientifico opzione Scienze Applicate (solo analisi e modellazione concettuale, senza SQL). Riferimenti ad altri indirizzi (es. ITIA) riguardano la #strong[trasferibilità] dell'esperienza ad altri contesti scolastici e universitari, non la popolazione iniziale di questa sperimentazione.

Il progetto nasce da un principio pedagogico chiaro: #strong[contrastare la delega cognitiva (#emph[cognitive offloading])] legata all'uso acritico degli strumenti di #emph[Generative Artificial Intelligence]. In questa proposta i modelli linguistici agiscono come #strong[tutor socratici]:

+ #strong[Mediazione maieutica affidata all'LLM]: domande, controesempi, livelli di aiuto L0--L4.
+ #strong[Verità tecnica], quando formalizzabile, affidata a controlli deterministici (introdotti progressivamente).
+ #strong[Valutazione] riservata al docente umano; verifica dell'apprendimento tramite #strong[prova di trasferimento su carta], senza dispositivi elettronici.

== Destinatari di questa documentazione
<destinatari-di-questa-documentazione>
- Progettisti della sperimentazione
- Dirigente scolastico
- Docenti di Informatica coinvolti
- DPO
- Amministratori Google Workspace for Education
- Personale e referenti del progetto #link("https://formazione.centropapagiovanni.it/health-school/")[Health School]
- Amministratori dell'infrastruttura informatica e dei servizi di rete

== Piani di verifica della sperimentazione
<piani-di-verifica-della-sperimentazione>
- #strong[Modello linguistico:] tenuta maieutica e rispetto dei livelli L0--L4.
- #strong[Infrastruttura:] progressione da zero-infrastructure (Gemini + Classroom) a soluzioni on-premise e, solo in seguito, a stack più completi.
- #strong[Efficacia didattica:] pre-test, post-test, prova di trasferimento, questionari di esperienza e gradimento.
- #strong[Sostenibilità e protocollo:] carico docente, adeguatezza delle fasi al contesto reale, trasferibilità delle buone pratiche.

== Come leggere questo documento
<come-leggere-questo-documento>
Il #strong[corpo principale] è pensato per essere leggibile anche da chi non ha competenze informatiche specialistiche (Dirigente scolastico, DPO, referenti organizzativi, docenti non tecnici). Contiene la pedagogia, il protocollo di sperimentazione, la privacy e la governance.

I #strong[dettagli di infrastruttura e implementazione] (architettura, formati di invio o conservazione dei dati, configurazione di Gem / Skill / Modelfile / Docker) sono raccolti in #strong[appendici tecniche] in calce, destinate a chi realizza o mantiene lo stack.

== Struttura del documento
<struttura-del-documento>
#strong[Corpo principale]

- #link("01_stato_dell_arte.md")[Recensione della letteratura]
- #link("06_normativa_e_sicurezza.md")[Normativa rilevante la sperimentazione]
- #link("02_quadro_pedagogico.md")[Quadro pedagogico]: destinatari (SIA prioritario; adattamento Liceo), prerequisiti, obiettivi, glossario, ruoli
- #link("03_protocollo_didattico.md")[Protocollo didattico]
- #link("07_sperimentazione.md")[Proposta di sperimentazione]: protocollo empirico, metriche, pre/post-test, questionari, criteri di successo, trasferibilità

#strong[Appendici tecniche] (lettura facoltativa per il pubblico non tecnico)

- #link("04_architettura_sistema.md")[Appendice A --- Architettura del sistema e prototipo tecnico]
- #link("05_formati_e_schemi.md")[Appendice B --- Formati, schemi e consegne strutturate]
- #link("08_appendice_realizzazione_tecnica.md")[Appendice C --- Realizzazione tecnica dei piloti (Gem, Skill, Modelfile)]

#strong[Bibliografia]

- #link("riferimenti.bib")[Bibliografia]

#quote(block: true)[
#strong[Nota di stato.] Il presente corpus documentale è, al momento, un #strong[unico insieme di testi in bozza], destinato a più lettori (progettisti, Dirigente scolastico, docenti, DPO, amministratori di piattaforma e di rete, referenti Health School). Eventuali versioni differenziate per destinatario potranno essere prodotte in seguito.
]

= Recensione della letteratura
<sec-stato-arte>
== Introduzione e contesto
<sec-introduzione-contesto>
L'introduzione dei modelli linguistici di grandi dimensioni (#emph[Large Language Models], LLM) nella didattica dell'informatica ha aperto nuove prospettive per la generazione di spiegazioni, l'esplorazione del codice e il feedback personalizzato. Tuttavia, l'adozione di tali strumenti solleva importanti questioni pedagogiche circa l'affidabilità delle risposte, il rischio di delega cognitiva da parte dello studente e l'effettiva tenuta dei processi di valutazione @becker2023programming@denny2024computing@prather2023robots.

Nel contesto specifico dell'insegnamento delle basi di dati relazionali, la complessità dell'apprendimento non risiede soltanto nella sintassi delle query SQL, ma si estende all'intero ciclo di progettazione: dall'analisi dei requisiti alla modellazione concettuale ed evoluzione verso lo schema relazionale @codd1970relational@chen1976entity. Un supporto didattico efficace deve pertanto combinare il rigore delle verifiche formali con una guida maieutica capace di stimolare il ragionamento autonomo anziché sostituirsi ad esso.

Per collocare teoricamente e metodologicamente la proposta progettuale di #strong[Socratic-DB] --- un'architettura ibrida che integra controlli deterministici, un tutor conversazionale guidato da LLM e la supervisione del docente ---, questo capitolo organizza la letteratura di riferimento secondo una progressione logica articolata nelle seguenti sezioni:

+ #strong[Quadri teorici su apprendimento, IA e psicologia cognitiva] (#ref(<sec-llm-istruzione>, supplement: [Sezione])): si esaminano le opportunità e le criticità dell'IA nella programmazione (#ref(<sec-opportunita-criticita-llm>, supplement: [Sezione])), il fenomeno del #emph[cognitive offloading] e le dinamiche del carico cognitivo (#ref(<sec-cognitive-offloading>, supplement: [Sezione])), il tutoraggio dialogico fondato sulla Zona di Sviluppo Prossimale e sulla #emph[self-explanation] (#ref(<sec-tutoraggio-zsp>, supplement: [Sezione])), l'#emph[Assistance Dilemma] e il trattenimento dell'informazione (#ref(<sec-assistance-dilemma>, supplement: [Sezione])), e l'impatto sul carico cognitivo nell'interazione uomo-macchina (#ref(<sec-carico-cognitivo-hci>, supplement: [Sezione])).
+ #strong[Sistemi di tutorato e didattica delle basi di dati] (#ref(<sec-its-database>, supplement: [Sezione])): si analizza lo stato dell'arte degli #emph[Intelligent Tutoring Systems] (ITS) e del #emph[Constraint-Based Modeling] (CBM) (#ref(<sec-its-cbm>, supplement: [Sezione])), la letteratura su errori, misconcezioni e modelli mentali in SQL (#ref(<sec-errori-misconcezioni-sql>, supplement: [Sezione])), e le esperienze di generazione di esercizi e analisi degli errori (#ref(<sec-generazione-esercizi-errori>, supplement: [Sezione])).
+ #strong[Architettura di Socratic-DB e contributo progettuale] (#ref(<sec-approccio-neuro-simbolico>, supplement: [Sezione]) e #ref(<sec-contributo-questioni-aperte>, supplement: [Sezione])): si definisce la struttura ibrida del sistema formalizzando la ripartizione dei compiti tra controlli deterministici, modello linguistico e docente, proponendo una matrice di mitigazione dei rischi tecnici e operativi e dettagliando le questioni aperte per la sperimentazione.
+ #strong[Metodologia per la valutazione empirica] (#ref(<sec-metodi-valutazione>, supplement: [Sezione])): si delineano i principi metodologici per condurre sperimentazioni didattiche in contesti scolastici reali, approfondendo l'integrazione di metodi quantitativi e qualitativi (#emph[mixed methods]) idonei anche per studi pilota condotti su piccoli campioni.
+ #strong[Vincoli normativi e sintesi della letteratura] (#ref(<sec-quadro-normativo-scuola>, supplement: [Sezione]) e #ref(<sec-sintesi-lacune>, supplement: [Sezione])): si richiama la cornice del GDPR e dell'AI Act per l'uso dell'IA nella scuola e si sintetizzano le lacune individuate nella letteratura corrente che motivano la sperimentazione di Socratic-DB.

#horizontalrule

== Quadri teorici: Apprendimento, IA e Psicologia Cognitiva
<sec-llm-istruzione>
=== Opportunità e criticità nell'istruzione alla programmazione
<sec-opportunita-criticita-llm>
Gli studi sull'IA generativa nell'istruzione alla programmazione discutono opportunità e criticità degli strumenti capaci di produrre direttamente codice o risposte @becker2023programming@denny2024computing@prather2023robots. L'effetto sull'apprendimento dipende dal compito, dal livello dello studente, dal tipo di assistenza e dall'organizzazione dell'attività; non è corretto assumere un effetto uniforme.

Quando un sistema fornisce direttamente una soluzione completa, esiste il rischio che lo studente accetti il risultato senza saperlo spiegare, verificare o trasferire a un problema diverso. Per Socratic-DB questo è un rischio progettuale da affrontare, non un effetto già dimostrato. Per valutarlo si propone di osservare non solo il prodotto finale, ma anche le motivazioni espresse, le revisioni e la capacità di affrontare una traccia nuova senza assistenza (prova di trasferimento; vedi #ref(<sec-disegno-ricerca>, supplement: [Sezione])).

=== Cognitive offloading e psicologia cognitiva
<sec-cognitive-offloading>
Il concetto di #emph[cognitive offloading] descrive l'uso di risorse esterne per ridurre le richieste cognitive interne @risko2016cognitive. Uno studio classico di Sparrow, Liu e Wegner mostra che, quando le persone si aspettano di poter recuperare informazioni tramite un motore di ricerca, ricordano meno il contenuto e più #emph[dove] trovarlo @sparrow2011google. La preoccupazione sulla delega cognitiva non è quindi astratta: con i motori di ricerca si è già osservata una riorganizzazione della memoria verso l'accesso esterno; con l'IA generativa il rischio si estende dal #emph[ricordare] al #emph[pensare] --- o almeno allo sforzo di formalizzare in modo strutturato il proprio ragionamento (modellare, giustificare, verificare).

Nella letteratura recente sull'IA generativa si distingue tra offloading che #emph[sostituisce] il pensiero dello studente e offloading che lo #emph[sostanzia] come scaffolding, con effetti diversi su motivazione e apprendimento @cash2026ai@risko2016cognitive. Il rischio educativo non è l'uso dello strumento in sé, ma la delega delle operazioni costitutive dell'obiettivo di apprendimento senza una successiva ricostruzione autonoma.

Per Socratic-DB la conseguenza progettuale è esplicita: i livelli di aiuto L0--L4 e il divieto di soluzione completa mirano a favorire un uso dello strumento come #emph[scaffolding] e non come sostituto del ragionamento. La prova di trasferimento senza dispositivi misura se le competenze restano disponibili in assenza del tutor.

=== Tutoraggio dialogico, Zona di Sviluppo Prossimale e self-explanation
<sec-tutoraggio-zsp>
Bloom discute la differenza tra tutoraggio individuale e istruzione di gruppo e il problema di trasferire i benefici del primo a contesti più ampi @bloom1984two. Vygotskij fornisce il riferimento teorico per l'interazione e la mediazione nell'apprendimento e per la Zona di Sviluppo Prossimale @vygotsky1978mind. Il concetto di #emph[scaffolding] @wood1976role descrive il supporto temporaneo e calibrato che consente di operare entro tale zona. Questi riferimenti offrono un quadro pedagogico generale; non dimostrano che un LLM che pone domande socratiche produca gli stessi effetti di un tutor umano.

La letteratura sul #emph[self-explanation] @chi1989self mostra che far esplicitare allo studente le proprie ragioni favorisce l'apprendimento profondo rispetto alla sola ricezione di spiegazioni. È coerente con la scelta di Socratic-DB di richiedere motivazioni scritte e di strutturare il dialogo intorno a domande e controesempi, piuttosto che intorno alla consegna della soluzione.

Macina et al.~studiano opportunità e limiti dei tutor dialogici neurali in compiti di apprendimento linguistico: le prestazioni sono migliori in scenari vincolati e più deboli in scenari aperti, con errori di ragionamento in una quota significativa delle conversazioni valutate @macina2023opportunities. Il dominio non coincide con le basi di dati, ma il risultato vale come avvertimento metodologico: un LLM non è un tutor affidabile solo perché produce un dialogo plausibile.

Socratic-DB traduce questi riferimenti in ipotesi di progetto: esplicitare il ragionamento, formulare domande circoscritte, proporre controesempi, graduare il livello di aiuto. La fedeltà del dialogo, la qualità delle spiegazioni e l'effetto sugli apprendimenti sono oggetti di verifica distinti.

=== Assistance dilemma: quando l'aiuto nuoce all'apprendimento
<sec-assistance-dilemma>
Koedinger e Aleven formulano l'#emph[assistance dilemma]: quanto e quando fornire assistenza in un ambiente di apprendimento interattivo, e quando invece #emph[trattenere] informazione perché lo studente elabori da sé la risposta @koedinger2007assistance. Troppo poco aiuto può generare frustrazione e stallo; troppo aiuto può impedire l'apprendimento perché il tutor svolge il lavoro cognitivo al posto dello studente. Il dilemma non è risolto una volta per tutte: dipende dal dominio, dal livello dello studente e dal momento dell'attività.

Per un tutor basato su LLM il rischio è asimmetrico. I modelli generativi tendono, per addestramento e per ottimizzazione alla «utilità» immediata, a #emph[dare] la risposta completa piuttosto che a trattenerla. In questo senso l'aiuto in sé può essere deleterio nella formazione: se la soluzione arriva senza elaborazione, si indeboliscono proprio le competenze che si intendeva sviluppare. La progettazione di Socratic-DB assume quindi un vincolo esplicito: il tutor deve #emph[impedire la delega cognitiva], non massimizzare la velocità di completamento del compito. I livelli L0--L4 e il divieto di soluzione completa operano come politiche di #emph[withholding] calibrato. Inoltre, quando lo studente è bloccato, il tutor non dovrebbe sostituirsi al materiale didattico formale: può rinviare a definizioni, esempi del libro di testo o della lezione, e chiedere di applicarli al caso in esame, piuttosto che produrre al posto dello studente lo schema o la query. In questo modo l'assistenza resta orientata allo studio strutturato e non alla sostituzione del pensiero.

=== Carico cognitivo e interazione uomo--macchina
<sec-carico-cognitivo-hci>
La #emph[Cognitive Load Theory] @sweller1988cognitive@sweller2011cognitive distingue carico intrinseco, estrinseco e pertinente. Un tutor conversazionale può ridurre il carico estrinseco (orientamento, feedback tempestivo) oppure aumentarlo (dialoghi lunghi, ambigui o ridondanti). La progettazione dei livelli di aiuto e la brevità delle risposte del tutor mirano a contenere il carico estrinseco, lasciando spazio al carico pertinente (elaborazione delle scelte di modellazione).

Dal punto di vista dell'interazione uomo--macchina, l'uso di sistemi generativi in contesti formativi richiede interfacce e protocolli che rendano trasparente #emph[quando] lo strumento interviene e #emph[con quale tipo di aiuto], per sostenere la metacognizione dello studente e la supervisione del docente. Questo aspetto è ancora poco trattato nella letteratura specifica sulle basi di dati e costituisce un'area di attenzione per la sperimentazione.

#horizontalrule

== Didattica delle basi di dati e sistemi di tutorato
<sec-its-database>
=== Intelligent Tutoring Systems e Constraint-Based Modeling
<sec-its-cbm>
Gli #emph[Intelligent Tutoring Systems] (ITS) costituiscono un precedente importante per il feedback automatizzato in domini tecnici. In particolare, SQL-Tutor di Mitrović illustra il #emph[Constraint-Based Modeling] (CBM): il sistema confronta la soluzione dello studente con vincoli disciplinari espliciti e restituisce feedback sulle violazioni @mitrovic1998sql@mitrovic2003cbm. Questo approccio offre un riferimento per rendere espliciti i criteri di controllo. Non implica, tuttavia, che ogni soluzione semanticamente valida possa essere riconosciuta automaticamente, né che lo stesso modello si trasferisca senza adattamenti a tutte le fasi della progettazione di una base di dati.

Socratic-DB condivide con gli approcci basati su vincoli l'idea di non affidare ogni giudizio tecnico alla sola generazione linguistica. La differenza proposta è l'ambito del percorso: oltre alla formulazione di query, si considerano analisi dei requisiti, modellazione concettuale, schema relazionale, implementazione e interrogazione. I controlli coprono solo proprietà formalizzate; la loro copertura effettiva va misurata. L'esecuzione su un database di prova fornisce evidenza circoscritta: una query corretta su un dataset può fallire su altri dati o non rispettare tutti i requisiti.

Una rassegna di riferimento sul tutoraggio è quella di VanLehn @vanlehn2011relative, che confronta tutoraggio umano, #emph[Intelligent Tutoring Systems] e altre forme di tutoraggio rispetto all'istruzione senza tutor. La rassegna stima un effetto medio del tutoraggio umano intorno a #emph[d] ≈ 0,79 e un effetto degli ITS step-based intorno a #emph[d] ≈ 0,76: valori inferiori al classico «effetto due sigma» attribuito al tutor umano individuale, ma comunque rilevanti. Il risultato fornisce un meta-contesto: un sistema di tutorato ben progettato può avvicinarsi all'efficacia del tutoraggio umano, senza però garantire, da solo, un miglioramento automatico in ogni dominio o con ogni interfaccia conversazionale generativa.

=== Errori, misconcezioni e modelli mentali in SQL
<sec-errori-misconcezioni-sql>
La ricerca sull'apprendimento di SQL analizza difficoltà e misconcezioni dei principianti. Miedema e colleghi studiano il ragionamento attraverso protocolli #emph[think-aloud] @miedema2021misconceptions\; Taipalus e colleghi esaminano errori e complicazioni ricorrenti nella formulazione di query @taipalus2018errors. Il lavoro successivo di Miedema sulla formazione sui sistemi di dati offre contesto per scomporre concetti e difficoltà del dominio @miedema2024learning. Questi risultati motivano diagnosi più specifiche del solo messaggio d'errore del DBMS, ma non vanno trasferiti automaticamente alla modellazione concettuale o alla progettazione relazionale.

Ponzini, Guerrini e Catania propongono una revisione delle tassonomie degli errori SQL orientata alla rilevazione automatizzata @ponzini2026taxonomy. Una classificazione esplicita può rendere le diagnosi confrontabili; non garantisce, da sola, che una diagnosi distingua sempre un errore da una soluzione alternativa valida o che il feedback migliori l'apprendimento.

Miedema et al.~discutono inoltre il concetto di #emph[notional machine] per spiegare i sistemi di dati nell'insegnamento dell'informatica @miedema2025notional. L'apprendimento richiede di costruire e verificare un modello di ciò che query e schema rappresentano. In Socratic-DB una possibile traduzione progettuale consiste nel chiedere allo studente di prevedere il comportamento di una query o di motivare una scelta di schema, e poi confrontare la previsione con l'esecuzione o con un controesempio. L'utilità di questa sequenza resta un'ipotesi da verificare.

=== Generazione di esercizi e uso didattico dell'analisi degli errori
<sec-generazione-esercizi-errori>
I lavori sulla generazione personalizzata di esercizi SQL con LLM e validazione basata su vincoli @ponzini2026sql@catania2026exercises affrontano un problema vicino ma distinto dal tutoraggio dialogico: produrre esercizi e controllarne proprietà non equivale a guidare lo studente nella modellazione o nella giustificazione delle scelte. Un esempio di attività didattica correlata è il laboratorio di Guerrini e Ponzini sugli errori frequenti in SQL @guerrini2026sqlerrors. Si tratta di antecedenti utili; non costituiscono prova sperimentale dell'efficacia di un tutor LLM sul percorso completo di progettazione.

#horizontalrule

== Architettura ibrida e posizionamento di Socratic-DB
<sec-approccio-neuro-simbolico>
Socratic-DB propone un'architettura ibrida in cui il modello linguistico non è l'unica fonte di giudizio tecnico. I controlli deterministici operano su proprietà formalizzate; l'esecuzione SQL osserva il comportamento su dati specifici; l'LLM sostiene il dialogo; il docente mantiene le decisioni non automatizzabili. «Ibrida» descrive la ripartizione progettuale dei compiti, non una garanzia generale di correttezza.

#strong[Socratic-DB] propone nello specifico un supporto alla progettazione e all'apprendimento delle basi di dati che combina tre componenti con responsabilità distinte:

+ #strong[Controlli formalizzati], per verificare proprietà esprimibili in modo deterministico (vincoli strutturali, alcune proprietà dello schema, risultati dell'esecuzione SQL).
+ #strong[Tutor conversazionale basato su LLM], per porre domande, richiedere motivazioni, proporre controesempi e graduare gli aiuti, senza assumere che il modello rispetti sempre tali vincoli.
+ #strong[Docente], cui restano il giudizio sulle interpretazioni del dominio, la revisione delle diagnosi non formalizzabili e le decisioni valutative.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Limite], [Conseguenza], [Scelta progettuale],),
  table.hline(),
  [Risposte linguistiche non affidabili], [L'LLM può formulare affermazioni errate o incoerenti con la diagnosi tecnica], [Separare le diagnosi dei controlli formalizzati dal testo del tutor; verificare le risposte del tutor],
  [Verifica limitata al comportamento osservato], [Una query può passare sui dati di prova e fallire altrove], [Dati di test progettati per casi significativi; ambito della verifica dichiarato],
  [Comportamento dialogico non garantito], [Il modello può fornire la soluzione troppo presto o assecondare errori], [Livelli di aiuto, registrazione delle interazioni, valutazione di conformità],
  [Controlli incompleti o troppo rigidi], [Proprietà non formalizzate sfuggono; soluzioni valide possono essere respinte], [Documentare l'ambito di ogni controllo; revisione del docente],
  [Separazione tra prodotto e apprendimento], [Una soluzione corretta non prova comprensione o trasferimento], [Valutare prodotto, processo e trasferimento senza tutor],
)
La tabella descrive rischi e decisioni proposte, non risultati sperimentali già ottenuti. I dettagli di implementazione sono nelle appendici tecniche.

=== Contributo della proposta e questioni aperte
<sec-contributo-questioni-aperte>
Il contributo progettuale che Socratic-DB intende esplorare è l'integrazione, in un unico percorso didattico, di:

- analisi dei requisiti e modellazione concettuale;
- traduzione nello schema relazionale e considerazione dei vincoli;
- implementazione, dati di prova e interrogazione (nei percorsi tecnici);
- dialogo guidato da domande, motivazioni e controesempi;
- controlli deterministici per le sole proprietà formalizzate;
- valutazione dell'apprendimento separata dalla valutazione automatica del prodotto.

Non si sostiene che ciascuna componente sia nuova in assoluto. Il valore distintivo da verificare è l'integrazione, con separazione esplicita tra controllo formale, mediazione linguistica e giudizio del docente. Rispetto ai sistemi centrati sulla query, Socratic-DB include le fasi di analisi e progettazione; rispetto agli strumenti di generazione di esercizi, si concentra sul dialogo relativo al tentativo dello studente; rispetto a un LLM usato senza controlli, prevede verifiche formalizzate; rispetto a un sistema interamente deterministico, usa un modello linguistico per l'interazione in linguaggio naturale.

L'integrazione di questi componenti è una scelta progettuale, non una prova preventiva di efficacia. Le domande di ricerca riguardano l'affidabilità dei controlli, la fedeltà del tutor al comportamento atteso, l'apprendimento autonomo e il trasferimento a problemi nuovi. La sperimentazione dovrà distinguere almeno quattro aspetti:

- #strong[Affidabilità tecnica:] cosa rilevano i controlli, quali falsi positivi o negativi producono.
- #strong[Fedeltà del tutor:] rispetto dei livelli di aiuto, pertinenza delle domande, assenza di soluzioni premature.
- #strong[Apprendimento e trasferimento:] miglioramento nella progettazione autonoma e prova su traccia nuova senza tutor.
- #strong[Fattibilità:] tempi, carico di revisione per il docente, usabilità nel contesto scolastico previsto.

Queste domande richiedono evidenze diverse (casi di test, revisione umana delle risposte, pre/post-test e prova di trasferimento, osservazioni di fattibilità). Un miglioramento osservato in un singolo pilota, in assenza di un confronto adeguato, non basta a dimostrare un nesso causale con il tutor. Il protocollo dettagliato di verifica è descritto nel #ref(<sec-protocollo-sperimentazione>, supplement: [Capitolo]).

#horizontalrule

== Metodi per valutare l'efficacia di una sperimentazione didattica
<sec-metodi-valutazione>
Anche quando i primi piloti coinvolgono pochi studenti, la sperimentazione può e deve essere condotta con metodo scientifico: le conclusioni, qualitative e quantitative, vanno ancorate a dati espliciti, a strumenti dichiarati e a limiti di generalizzazione chiari.

Nella ricerca educativa, Creswell offre un quadro consolidato per pianificare, condurre e valutare studi quantitativi, qualitativi e a metodi misti @creswell2012educational. Shadish, Cook e Campbell forniscono il riferimento classico sui disegni sperimentali e quasi-sperimentali e sulla validità delle inferenze causali in contesti non di laboratorio @shadish2002experimental. In assenza di randomizzazione completa --- frequente nella scuola per vincoli etici e organizzativi --- restano disponibili disegni intra-soggetto (pre-test / post-test / trasferimento), confronti descrittivi con classi parallele e analisi di processo, a patto di dichiarare cosa si può e non si può inferire.

Per i #strong[studi pilota di fattibilità], la letteratura sui #emph[mixed methods] raccomanda di integrare deliberatamente dati quantitativi e qualitativi per esaminare accettabilità, fattibilità operativa e prime indicazioni di effetto, preparando eventuali sperimentazioni di scala maggiore @aschbrenner2022mixed. L'integrazione non è la somma di due report separati: richiede allineamento delle fonti, analisi congiunte e meta-inferenze su cosa il pilota autorizza a concludere.

Per Socratic-DB ciò si traduce in scelte già previste nel protocollo:

- #strong[Quantitativo:] pre-test, post-test e prova di trasferimento con rubrica condivisa; indicatori di processo (livelli di aiuto, iterazioni); soglie sulla fuga della soluzione; stime di carico docente.
- #strong[Qualitativo:] trascrizioni dei dialoghi, note di osservazione, questionari aperti di esperienza e gradimento, revisione in cieco tra docenti.
- #strong[Integrazione:] confrontare esiti di prestazione con la tenuta maieutica del tutor e con la sostenibilità operativa; non presentare un miglioramento su un piccolo campione come prova causale definitiva, ma come evidenza situata e replicabile.

La popolazione ridotta del primo pilota (ad esempio cinque studenti) non autorizza generalizzazioni ampie; autorizza invece a misurare con rigore fattibilità, accettabilità e segnali di apprendimento, e a documentare in modo trasparente i dati su cui poggiano le conclusioni.

#horizontalrule

== Quadro normativo (rinvio)
<sec-quadro-normativo-scuola>
L'uso di strumenti di IA in contesti scolastici richiede la valutazione del trattamento dei dati personali e delle finalità del sistema, in coerenza con il GDPR @gdpr2016 e con il regolamento europeo sull'IA @eu_ai_act_2024. In Socratic-DB la scelta progettuale è che il sistema non assegni voti né sostituisca il docente nelle decisioni valutative. L'approfondimento operativo (base giuridica, consenso, DPO, misure di sicurezza) è trattato nel capitolo sulla normativa e sicurezza.

#horizontalrule

== Sintesi delle aree ancora aperte nella letteratura
<sec-sintesi-lacune>
Rispetto al profilo di Socratic-DB, la letteratura consultata risulta:

- #strong[solida] su ITS e CBM per SQL, su errori e misconcezioni SQL, su opportunità/rischi degli LLM nella programmazione introduttiva;
- #strong[ancora limitata] su tutor socratici basati su LLM per la #emph[progettazione completa] di basi di dati (dall'analisi dei requisiti allo schema e alle query);
- #strong[poco collegata], nel dominio delle basi di dati, alla letteratura di psicologia cognitiva su #emph[cognitive offloading], #emph[self-explanation] e carico cognitivo, e agli studi HCI su trasparenza dell'aiuto e metacognizione.

Queste lacune motivano la sperimentazione empirica descritta nel protocollo e orientano le scelte di misura (processo, fuga della soluzione, trasferimento senza dispositivi).

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
  [ITSI -- Sistemi Informativi Aziendali], [2025], [Ordinaria], [A043], [Informatica], [MusicOmega: piattaforma di streaming musicale, ascolti, playlist e royalties], [#link("../../tracce/mim-2024-25-itsi-ordinaria-a043.md")[mim-2024-25-itsi-ordinaria-a043.md]], [#link("https://www.istruzione.it/esame_di_stato/202425/Istituti%20tecnici/Ordinaria/A043_ORD25.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2025], [Suppletiva], [A043], [Informatica], [Shopsharing: spazi espositivi, disponibilità e prenotazioni], [#link("../../tracce/mim-2024-25-itsi-suppletiva-a043.md")[mim-2024-25-itsi-suppletiva-a043.md]], [#link("https://www.istruzione.it/esame_di_stato/202425/Istituti%20tecnici/Suppletiva/A043_SUP25.pdf")[Ministero]],
  [ITSI -- Sistemi Informativi Aziendali], [2025], [Straordinaria], [A043], [Informatica], [Sostenibilità aziendale: certificazioni, indicatori ambientali e sanzioni], [#link("../../tracce/mim-2024-25-itsi-straordinaria-a043.md")[mim-2024-25-itsi-straordinaria-a043.md]], [#link("https://www.istruzione.it/esame_di_stato/202425/Istituti%20tecnici/Straordinaria/A043_STR25.pdf")[Ministero]],
  [ITIA -- Informatica], [2025], [Ordinaria], [A038], [Informatica], [Dataset e labeling di notizie per l'addestramento di sistemi di IA], [#link("../../tracce/mim-2024-25-itia-ordinaria-a038.md")[mim-2024-25-itia-ordinaria-a038.md]], [#link("https://www.istruzione.it/esame_di_stato/202425/Istituti%20tecnici/Ordinaria/A038_ORD25.pdf")[Ministero]],
  [ITIA -- Informatica], [2025], [Suppletiva], [A038], [Informatica], [Piattaforma per campagne di sponsorizzazione con comunicatori social], [#link("../../tracce/mim-2024-25-itia-suppletiva-a038.md")[mim-2024-25-itia-suppletiva-a038.md]], [#link("https://www.istruzione.it/esame_di_stato/202425/Istituti%20tecnici/Suppletiva/A038_SUP25.pdf")[Ministero]],
  [ITIA -- Informatica], [2025], [Straordinaria], [A038], [Informatica], [Analisi automatica delle azioni di gioco nelle partite di basket], [#link("../../tracce/mim-2024-25-itia-straordinaria-a038.md")[mim-2024-25-itia-straordinaria-a038.md]], [#link("https://www.istruzione.it/esame_di_stato/202425/Istituti%20tecnici/Straordinaria/A038_STR25.pdf")[Ministero]],
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
La sperimentazione procede per fasi successive. Il dettaglio di configurazione (Gem, Modelfile, stack) è nelle #strong[appendici tecniche]\; qui si riporta solo il senso organizzativo.

+ #strong[Pilota 1 -- Avvio senza infrastruttura dedicata] (già in corso): uso di Gemini tramite Google Classroom, con istruzioni socratiche. Non richiede installazioni locali.
+ #strong[Pilota 2 -- Esecuzione in laboratorio]: stesso ruolo del tutor, su workstation dell'Istituto (quando i criteri di passaggio del Pilota 1 sono soddisfatti).
+ #strong[Pilota 3 e 4 -- Controlli automatici e stack più completo]: solo dopo il consolidamento dei piloti precedenti.

#strong[Criteri di passaggio (go/no-go):] tenuta maieutica entro le soglie di fuga; feedback positivo; assenza di incidenti di privacy; carico docente entro le stime.

#strong[Composizione del contesto del tutor.] Nei Piloti 1 e 2 si mantiene una sola Gem istituzionale e, rispettivamente, una sola Skill e un solo Modelfile. Moltiplicare le configurazioni non riduce il contesto della singola interazione: aumenta invece il rischio di divergenza tra istruzioni, di selezione del tutor errato e di frammentazione del percorso dello studente.

Il prompt è articolato in:

- un #strong[nucleo comune]: ruolo socratico, divieto di soluzione completa e di valutazione, lingua italiana, protezione dei dati e definizioni dei livelli L0--L4;
- un #strong[modulo della fase/consegna corrente]: obiettivo didattico, dimensioni di qualità del prodotto, formato atteso, errori tipici e pochi esempi pertinenti a requisiti, glossario, E/R, modello relazionale, DDL, dati o query;
- una #strong[regola maieutica trasversale]: il livello L0--L4 determina come esporre una diagnosi, non quale attività didattica sia in corso.

Non si configurano Gem, Skill o Modelfile separati per ciascun livello L0--L4. I casi esemplificativi fase × livello possono essere mantenuti come materiale modulare e selezionati solo quando pertinenti; inserirli tutti in un prompt statico competerebbe con traccia, elaborato e cronologia del dialogo, riducendo l'affidabilità del comportamento maieutico. Una configurazione runtime distinta sarà valutata solo se una fase richiederà input, formati o controlli deterministici realmente diversi.

Gem e Modelfile sono configurazioni statiche: con una sola configurazione non selezionano autonomamente il modulo di consegna. Nei Piloti 1 e 2 il passaggio di fase e l'istruzione mirata restano quindi espliciti e guidati dal docente o dallo studente. Un orchestratore leggero potrà in seguito selezionare il modulo pertinente e limitare il contesto trasmesso. Il dettaglio operativo è in Appendice C.

La fattibilità operativa della scelta è un'ipotesi da verificare, non una proprietà già dimostrata. Il Pilota 1 confronterà, quando sostenibile, il nucleo comune da solo, il nucleo con istruzione manuale di fase e l'eventuale configurazione distinta per fase; per ciascun caso rileverà fuga della soluzione, rispetto del livello L0--L4, pertinenza del feedback e carico per docente e studenti. Il Pilota 2 aggiungerà la verifica di contesto, latenza e qualità del modello locale sull'hardware disponibile.

Per l'implementazione tecnica: Appendice C (Gem, Skill, Modelfile), Appendice A (architettura e hardware), Appendice B (formati strutturati, non obbligatori nel Pilota 1).

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

#strong[Fattibilità tecnica]

- Rispetto osservato dei livelli L0--L4 e del divieto di soluzione completa
- Pertinenza del feedback rispetto alla consegna e all'elaborato
- Gestibilità del passaggio manuale di fase nei Piloti 1--2
- Limiti di contesto, latenza e qualità del modello locale nel Pilota 2

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
  [Contesto LLM troppo ampio / diluizione del prompt], [Nucleo maieutico stabile + modulo della consegna corrente; selezione dei soli esempi pertinenti; passaggio esplicito e manuale nei Piloti 1--2; futura orchestrazione leggera del contesto, senza moltiplicare configurazioni per livello L0--L4],
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

#show: appendices.with("Appendici", hide-parent: true)
#heading(level: 1, numbering: none)[Appendici]
= Appendice A --- Architettura del sistema e prototipo tecnico
<sec-architettura-sistema>
#quote(block: true)[
#strong[Destinatari di questa appendice:] amministratori dell'infrastruttura, docenti tecnici e chi realizza o mantiene lo stack. Il corpo principale del documento non richiede la lettura di questa sezione.
]

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

=== Composizione del contesto del tutor
<composizione-del-contesto-del-tutor>
L'orchestratore compone il contesto con un nucleo di policy invarianti e il solo modulo relativo alla fase/consegna corrente. Il nucleo definisce il ruolo socratico, il divieto di fornire soluzioni o valutazioni, i vincoli di privacy e i livelli L0--L4; il modulo di fase contiene formato atteso, dimensioni di qualità, errori tipici ed esempi mirati.

Il livello di aiuto è un parametro trasversale di resa della diagnosi e non determina un prompt o un modello distinto. Eventuali esempi per combinazioni fase × livello sono risorse modulari, da includere solo se pertinenti. Questa composizione limita la competizione tra istruzioni, traccia, consegna e cronologia; l'orchestratore deve preservare il nucleo invariabile e selezionare il minimo contesto necessario. Questa selezione è una capacità dell'orchestratore: non è offerta automaticamente da una configurazione statica di Gem o Modelfile.

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

= Appendice B --- Formati, schemi e consegne strutturate
<sec-formati-schemi>
#quote(block: true)[
#strong[Destinatari di questa appendice:] docenti tecnici e sviluppatori del prototipo. Gli studenti, nella fase iniziale (Pilota 1), non sono obbligati a produrre YAML: le consegne possono restare in Markdown e testo. I formati qui descritti servono ai piloti successivi e all'automazione dei controlli.
]

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
= Appendice C --- Realizzazione tecnica dei piloti (Gem, Skill, Modelfile)
<sec-appendice-realizzazione>
#quote(block: true)[
#strong[Destinatari di questa appendice:] docenti tecnici, amministratori Google Workspace e chi configura i runtime. \ Il #strong[corpo principale] del documento descrive #emph[cosa] si sperimenta e #emph[perché]\; qui si indica #emph[dove] si trovano le istruzioni operative di implementazione.
]

#horizontalrule

== Pilota 1 --- Zero-infrastructure (Google Classroom + Gemini)
<pilota-1-zero-infrastructure-google-classroom-gemini>
Nella fase iniziale non è richiesta alcuna installazione locale. Si utilizza una #strong[Custom Gem] di Gemini all'interno di Google Workspace for Education, con istruzioni di sistema che impongono il metodo socratico e i livelli di aiuto L0--L4.

#table(
  columns: (25%, 75%),
  align: (auto,auto,),
  table.header([Elemento], [Collocazione nel repository],),
  table.hline(),
  [Istruzioni di sistema per la Gem], [#NormalTok("gemini-gem/GEM_SYSTEM_INSTRUCTIONS.md");],
  [Skill agentica (stesso ruolo pedagogico)], [#NormalTok("skills/socratic-db/SKILL.md");],
  [Modalità d'uso], [Condivisione della Gem via Google Classroom; gli studenti consegnano le trascrizioni del dialogo come allegato al compito],
)
L'uso di Gemini è subordinato a conferma del DPO rispetto alle policy dell'Istituto. Non si inseriscono dati personali reali nelle tracce.

#horizontalrule

== Pilota 2 --- On-premise leggero (Ollama)
<pilota-2-on-premise-leggero-ollama>
Quando i criteri di go del Pilota 1 sono soddisfatti, le stesse istruzioni socratiche possono essere caricate in un #strong[Modelfile] per Ollama, eseguito sulla workstation di laboratorio (obiettivo: 6 GB di VRAM, modelli quantizzati di dimensioni contenute).

#table(
  columns: (25%, 75%),
  align: (auto,auto,),
  table.header([Elemento], [Collocazione nel repository],),
  table.hline(),
  [Modelfile], [#NormalTok("ollama/Modelfile");],
  [Vincoli hardware], [Vedi anche Appendice A (scelta del modello e parametri di inferenza)],
)
Non si promuove, nella fase 1, l'installazione di modelli open-weight sui dispositivi personali degli studenti. L'eventuale esecuzione locale a casa è uno scenario evolutivo descritto nel protocollo di sperimentazione (sezione sul lavoro domestico).

#horizontalrule

== Composizione delle istruzioni per i Piloti 1 e 2
<composizione-delle-istruzioni-per-i-piloti-1-e-2>
Gem, Skill e Modelfile devono condividere un #strong[nucleo breve e invariabile]: identità socratica, divieto di fornire soluzioni complete o valutazioni, lingua italiana, tutela dei dati e definizione dei livelli L0--L4. Questo nucleo è integrato, per la singola interazione, da un modulo relativo alla fase o consegna corrente.

Il modulo di consegna descrive il risultato atteso, le dimensioni con cui valutarne correttezza, completezza, minimalità, pertinenza ed efficienza, il formato previsto, gli errori ricorrenti e pochi esempi pertinenti. I livelli L0--L4 restano invece una regola di formulazione trasversale: stabiliscono se presentare un esito, una domanda, un controesempio, un principio o un esempio isomorfo; non richiedono artefatti runtime distinti.

Nei primi due piloti si mantiene quindi una sola configurazione per runtime (una Gem, una Skill e un Modelfile), per evitare disallineamenti e passaggi impropri tra tutor. Una raccolta di esempi fase × livello può essere mantenuta separatamente e usata in modo selettivo; non va riversata integralmente nelle istruzioni statiche, perché sottrae contesto alla traccia, all'elaborato e alla conversazione. Solo una futura fase con input, formati o controlli deterministici sostanzialmente diversi giustifica una configurazione separata.

Una Gem e un Modelfile non selezionano dinamicamente il modulo di consegna: nei Piloti 1 e 2 questa scelta è effettuata manualmente, attraverso il patto formativo, l'indicazione esplicita della fase e l'istruzione contestuale fornita dal docente o dallo studente. La selezione automatica richiede un componente applicativo esterno e appartiene quindi ai piloti con orchestratore.

La configurazione va considerata tecnicamente fattibile ma da validare sul campo. Per Gemini occorre verificare il rispetto effettivo delle istruzioni e la sostenibilità del passaggio manuale; per Ollama vanno misurati contesto utile, latenza e qualità della risposta sul modello e sull'hardware selezionati. In entrambi i casi la verifica include aderenza a L0--L4, pertinenza del feedback e assenza di fuga della soluzione.

#horizontalrule

== Piloti 3 e 4 --- Stack parziale e completo
<piloti-3-e-4-stack-parziale-e-completo>
I controlli deterministici, la sandbox SQLite e l'architettura neuro-simbolica piena sono descritti in #strong[Appendice A]. I formati di consegna strutturati (YAML e affini), utili quando i controlli automatici sono attivi, sono in #strong[Appendice B]. Nella fase iniziale della sperimentazione (Pilota 1) tali formati #strong[non] sono obbligatori per gli studenti.

#horizontalrule

== Principio di separazione
<principio-di-separazione>
#table(
  columns: (68.57%, 31.43%),
  align: (auto,auto,),
  table.header([Documento / componente], [Contenuto],),
  table.hline(),
  [Corpo principale (capitoli 1--7 del volume)], [Pedagogia, protocollo di sperimentazione, privacy, governance, metriche],
  [Appendice A], [Architettura, hardware, controlli deterministici, ipotesi di sistema avanzato],
  [Appendice B], [Formati di consegna e schemi (YAML, Markdown obbligato, ecc.)],
  [Appendice C (questo file)], [Collegamento operativo a Gem, Skill e Modelfile],
  [File #NormalTok("gemini-gem/");, #NormalTok("ollama/");, #NormalTok("skills/");], [Sorgenti pronti all'uso],
)



#bibliography(("riferimenti.bib"))

