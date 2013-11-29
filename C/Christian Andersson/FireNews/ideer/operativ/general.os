Nytt Operativsystem till Atari Falcon!

GUI:
   F„rger:
   * St”d f”r 16/256/16bit/24bit/32Bit f„rgregister samt mod.
      (24-bit „r ej m”jligt p† dagens falcon, men kanske i framtiden
      och d† kommer detta OS troligtvis att st”dja det)
   * Varje f”nster kan ha sin egen f„rgpalette, dvs n„r det f”nstret aktiveras
      s† „ndras f„rgpaletten till den som tillh”r f”nstret. Detta g„ller 
      endast d† grafikl„get erbjuder en palette.
      I 256-f„rgers mod s† kan man inte „ndra p† de 16 f”rsta f„rgerna
      (man har d† bara 240 kvar) eftersom de „r reserverade av desktopen.
      I 16-f„rgers mod s† kan alla f„rger „ndras, vilket medf”r att
      „ven deskens f„rger „ndras.
      I True-color-l„gena d„r det inte finns en palette som kan „ndras
      s† „r denna m”jlighet av naturliga sk„l ej m”jlig.
   * Om man inte vill att f„rgerna f”r andra program skall „ndras kan man
      reservera f„rger †t sig sj„lv. fr†n b”rjan s† finns det 240 f„rger
      att reservera (16 anv„nds av desktopen) och n„r program reserverar
      f„rger s† minskas naturligtvis „ven detta antal.
      Dessa f„rger kan d† bara „ndras av programmet som „ger dem.
      Andra programs f„rger p†verkas d† inte av dessa „ndringar, om inte
      de programmen endera har en egen palette f”r sina f”nster, eller
      anv„nder f„rger utan att ha reserverat dem.
      Programmet kan n„r som hellst reservera och †terl„mna f„rger,
      Det „r inte n”dv„ndigt att †terl„mna f„rgerna f”r att avsluta sitt
      program, utan OS:et †terl„mnar dem d†, dock s† kan man ju ta det
      som praxis att †terst„lla efter sig.
   * Max 255 f„rger kan reserveras per f”nster.

   Uppl”sning:
   * St”d f”r valfri storlek av sk„rmen, dvs man kan sj„lv st„lla in sk„rmen
      som i typ Blowup. (Inst„llningen kommer att vara mycket b„ttre)
   * St”d f”r Virtuell sk„rm, dvs st”rre sk„rm „n vad monitorn/TV:n klarar
      av. Samt inst„llningar hur hanteringen skall g† till.
      (tex scrollning s† att musmark”ren f”rs”ks h†llas i mitten, eller
      scrollning endast n„r musmark”ren kommer till "kanten" av monitorn,
      Olika parametrar i dessa l„gen „r m”jliga, typ pixel/sid-scroll)
   * Programmen kan, n„rsomhelst, ”ppna en egen sk„rm med, om man vill, en
      annan uppl”sning „n desken. Man kan d† tex visa bilder med h”gre antal
      f„rger „n vad desken k”rde i. Man †terg†r till deskens uppl”sning
      genom att st„nga den sk„rmen. eller vid byte av Program.
      Denna funktion „r "vital" om man vill ha ett bra system som till†ter
      "spel" och andra multimedia produkter.

   Resurs-hantering:
   * St”d f”r flera spr†k genom att ha en speciell spr†k-fil av resursen.
      Varje Spr†k har d† en egen spr†k-fil och namns„ttningen av den
      skall ske genom en viss standard, tex 'filnamn,swed' f”r svensk text
      och 'filnamn.engl' f”r engelsk.
      Operativsystemet laddar automatiskt in r„tt spr†kfil, beroende
      p† vilket spr†k du har valt. Finns inte denna spr†kfil s† f”rs”ker OS:et
      ladda in ett alternativ-spr†k, och finns inte heller denna s† tar den
      den som „r satt i resurs-filen.
   * St”d f”r ett flertal olika typer av Objekt.
   * St”d f”r Speciell Short-key hantering i b†de Menu/Dialog och allm„n (dvs
      inte synlig short-key)
      Beskrivningen av dessa Shortkeys finns „ven de i Spr†k-filerna
      s† att det „r m”jligt att „ndra short-keys beroende p† spr†ket
      tex <CTRL>-Q f”r Quit och <CTRL>-A f”r Avsluta.

   Menu-hantering:
   * Om programmet anv„nder en menu s† finns den alltid tillg„nglig genom
      tangent-bordet via en knapptryckning (<ALT><ESC>), och man kan sedan
      f”rflytta sig i menu:n med piltangenterna, Return fungerar d† som
      musknapp. Under-menyer ”ppnar man med v„nster/h”ger-pil och st„nger
      med h”ger/V„nster
   * St”d f”r flera spr†k (Se Resurs-hantering)

Shell hantering:
   * Vanliga Traditionella Shells skall finnas tillg„ngliga.
   
Process-hantering:
   * St”d f”r "g”mning" av processer, dvs processens f”nster f”rsvinner fr†n
      sk„rmen. Programmet som "g”ms" hamnar automatiskt i bakgrunden, eftersom
      ett annat f”nster hamnar i f”rgrunden vid g”mning, och om processen
      aktiveras igen s† ploppar alla dess f”nster upp igen.
   * Enbart Processen som „r Aktiv tar emot H„ndelser fr†n Tangent-bordet.
   * Full Pre-emptiv Multitasking.
   * non-pre-emptive task-switch f”r viktiga processer som m†ste k”ras fullt ut.
      dessa Processer b”r dock vara sm† s† att inte den tar f”r mycket tid
   * St”d f”r system-Threads.
   * Hela OS:et skall vara re-entrant
     
Quick-key Hantering:
   * St”d f”r reservering av Quick-keys, dvs tangenter som h”r till ett 
     visst program, Oberoende vilket program/f”nster som „r aktivet. 
     Programmet som installerat denna quick-key kan sedan avsluta sig sj„lv 
     och n„r anv„ndaren trycker denna quick-key kombination s† startas 
     programmet upp igen och den utf”r det den skall g”ra! kan vara j„ttebra.
     Naturligtvis s† skall Quick-Keys kunna st„ngas av och s„ttas p† utav 
     anv„ndaren n„r han vill.
     Quick-keys skall „ven kunna installeras av andra program „n sig sj„lva.
     
Fil Hanterning:
   * Se filestru.os och filesyst.os

Generella V„ljare av olika typer skall finnas.
  * Filv„ljare
  * Font-v„ljare
  * F„rg-V„ljare

S„kerhets-system.
 * Se Password.os
  
Skyddade tangent-bordskombinationer.
[SHIFT]-CTRL-ALT-TAB Processbyte (Bottom->Top/Top->Bottom)
[SHIFT]-CTRL-ALT-[F1-F10/F12] Nya Sessioner (F”r att till†ta att flera 
  personer anv„nder samma dator med samma sk„rm/Tangentbord)
[SHIFT]-CTRL-ALT-DELETE  Omstart av dator (OBS endast f”r personer med 
  ROOT-r„ttighet)
CTRL-ALT-ESC Urloggning/L”senordsbyte
CTRL-ALT-HELP Process-hantering (Tex Lista av "AKtiva" processer, med 
  m”jlighet att d”da dem.)
  
Som man kan l„gga m„rke till s† „r alla skyddade kombinationer baserade p† att 
CTRL och ALT ALLTID „r nedtryckt tillsammans.
och p† grund av att det inte skall ske n†gra som helst misstag p† denna 
front, s† „r ALLA kombinationer av tangent-nedtryckningar tillsammans med 
b†de CTRL och ALT skyddade.
S†dana h„r Tangentbords-nedtryckningar kommer INTE att levereras till 
processen ”verhuvudtaget, utan den kommer att processas utav systemet.
Till EX, vissa CTRL-ALT kombinationer kommer att tillh”ra 
f”nsterhanterings-systemet.
