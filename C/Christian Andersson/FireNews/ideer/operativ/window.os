F”nsterhantering:
   
   * 3 typer av f”nster st”ds (Vanliga GEM st”djer bar 1 typ.)
     a) User-defined window, h„r tar programmet hand om all
        f”nster-hantering.
     b) Dialog window, H„r tar operativ-systemet hand om N„stan all f”nster
        hantering, uppdatering, flyttning, osv, bara ett f†tal saker sk”ts
        av programmet.
     c) Sk„rm-f”nster, Detta „r egentligen inte ett F”nster utan ett helt 
        egen sk„rm Denna sk„rm kan man kombinera ihop med typ a och b f”r 
        att man skall kunna hantera det b„ttre. Man kan st„lla in hur detta 
        "f”nster" skall fungera p† ett mera precist s„tt „n vad man kan f”r 
        andra f”nster
   * St”d f”r g”mning av f”nster (se Process-hantering)
   * St”d f”r ikonisering av f”nstret.
      G”mda eller ikoniserade f”nster kan fortfarande vara det aktiva,
      men de reagerar inte p† tangent/mus l„ngre, f”rutom vid
      framtagning eller deikonisering.
   * St”d f”r Bearbetning av f”nster i Bakgrunden.
      dvs man kan flytta/iconisera/„ndra storlek, mm p† icke aktiva f”nster
   * Alla f”nster „r †tkomliga genom en tangentkombination (<ALT><TAB> och
     <SHIFT><ALT><TAB>) Denna Funkltion kan EJ st„ngas av!
   * Alla f”nster „r scroll-bara, dvs inneh†llet i f”nstret kan vara st”rre „n
      vad f”nstret „r! (Žven dialog-f”nster)
   * Operativsystemet styr s† mycket som m”jligt av f”nster hanteringen.
      dvs flyttning, f”rstorning, f”rminskning, inmatning, updatering,
      scrollning mm. Bara det Programmeraren v„ljer Sturs av programmet.
   * Varje ram kan flyttas hur den vill, tex tar man tag i H”ger ram kan man
      „ndra p† storleken p† f”nstret den v„gen, det samma g„ller alla de andra
      sidorna p† f”nstret. Allts† inte som i Vanliga Gem d„r det finns en
      "knapp" f”r att „ndra f”nsterstorlek, „ven h”rnen kan man dra i och
      d† f† 2 sidor att „ndra sig. genom att h†lla inne vissa knappar
      samtidigt kan man f† andra flyttningseffekter.
   * Varje f”nster kan ha en egen f„rgpalette (se f„rger)
     Detta g„ller endast vid grafik-l„gen d„r det finns Palette.
     Denna f„rgpallet kan man endera reservera som "global" eller Privat.
     Om f„rgpalletten „r global s† kan f„rgpalletten „ndras OM et annat 
     f”nster aktiveras. Žr f„rgpalletten privat s† „ndras f„rgerna INTE utav 
     att man "toppar" andra f”nster. Žndrandet av f„rgpalletter „r dock 
     n†got man skall f”rs”ka undvika, eftersom det p†verkar utseenden f”r 
     andra program.
   * Grafisk Klippning vid Uppdatering sker Automatiskt. Man beh”ver inte 
     bry sig om Klipp-rektanglar. INGET kan ritas utanf”r ett f”nster.
     Klipprektangalr kan d„remot anv„ndas f”r att internt i f”nstret 
     begr„nsa uppdatering.
   * Omdirigering av f”nster till andra datorers sk„rmar (via olika portar och 
     protokoll)
   * Under-f”nster, DVS varje f”nster kan „ven ha ett underf”nster i sig, som d†
     anv„nder sig utav helt egna inst„llningar. Detta „r anv„ndbart n„r man skall
     anv„nda sig utav flera olika visningar, tex flera dokument.
     Man kan f”rst†ss „ven ha underf”nster i underf”nster :)
     
olika f”nster funktioner
* window_create(...)      skapar ett f”nster
* window_delete(...)      Plockar bort f”nstret fr†n minnet
* window_open(...)        Visar f”nstret p† sk„rmen
* window_close(...)       Plockar bort f”nstret fr†n sk„rmen
* window_set(...)         Žndrar f”nstret inst„llningar
* window_get(...)         H„mtar f”nstrets olika inst„llningar.
* window_redraw(...)      Ritar om ett f”nster
** window_hide(...)        G”mmer f”nstret (fungerar ungef„r som window_close(...)
** window_unhide(...)      visar ett g”mt f”nster
** window_iconize(...)     Ikoniserar ett f”nster
** window_deiconize(...)   Plockar upp ett ikoniserat f”nster
** window_move(...)        flyttar ett f”nster
** window_size(...)        Žndrar storlek p† ett f”nster
** window_pallette(...)    Žndrar palette f”r ett f”nster

(** funktionerna „r "makron" som anv„nder sig utav window_set(...) och 
window_get(...) funktionerna.)

long window_create(int type, int parent)
  Desc: skapar ett f”nster objekt i Operativsystemet
  In  : type - Vilken typ av f”nster som man skall anv„nda sig utav.
               WINDOW_FREE   - Ett helt FRITT f”nster, all uppdatering skers 
                               utav anv„ndaren, alla hantering av f”nster 
                               sker „ven detta utav anv„ndaren.
               WINDOW_DIALOG - Ett dialog f”nster (Det vanligaste man 
                               anv„nder sig utav. Detta f”nster sk”ter sig 
                               n„stan helt och h†llet sj„lvt, det finns dock 
                               vissa objekt som anv„ndaren tvingas att ta 
                               hand om sj„lv. (och finns s†dana objekt med 
                               s† kommer anv„ndaren att f† ta hand om mer 
                               meddelanden ocks†)
               WINDOW_SCREEN - Detta f”nster „r ganska unikt, ist„llet f”r 
                               att f”nstret tilldelas Ramar och liknande s† 
                               tilldelas hela sk„rmen som ett f”nster, Man 
                               kan kombinera denna typ med WINDOW_DIALOG och 
                               WINDOW_FREE, Oftast „r det dock vanligast att 
                               man anv„nder sig utav WINDOW_FREE tillsammans 
                               med denna f”nster typ (undantag Desktoppen)
                               Detta f”nster kan ocks† anv„nda sig utav helt
                               andra typer av uppl”sningar i s†dana h„ra
                               f”nster (Perfekt f”r spel) F”r att kunna g”ra
                               detta (Ha andra uppl”sningar) s† m†ste f”nster-
                               hanteraren k„nna till dessa uppl”sningar i
                               f”rhand.
        parent - vilket f”nster „r detta f”nstrets F”r„lder? anv„nder man 
                 sig utav n†gon F”r„lder s† kommer detta f”nster bara att 
                 existera i det f”nstret. Att „ndra ett f”nster f”r„lder „r 
                 ytters anv„ndbart om f”r„lder „r av typen WINDOW_SCREEN
  Out : id - F”nstrets ID, denna ID anv„nds st„ndigt om man vill hantera 
             f”nster. ID=0 talar om att f”nstret inte gick att skapas.

long window_set(long id, long mask, ...)
  Desc: S„tter olika f”nster Parametrar
  In  : id - F”nstret ID p† det f”ster som man skall st„lla in.
        mask - Vad skall st„llas in.
        ... - de olika inst„llningarna.
              Dessa inst„llningar talar om hur f”nstret skall bete sig, se 
              ut, mm., mm.
              Man kan h„r skicka in mer „n 1 parameter, antalet som l„ses 
              av beror p† hur hur m†nga bitar i mask som anv„nds.
              Ordningen p† det som skall st„llas in „r ocks† ytterst 
              specifik, dvs man kaninte byta plats p† 2 olika typer av data.
  Out  : svar - Om allt fungerade som det skulle, bitm”nstret f”r de delar 
         som inte fungerade returneras.

int window_delete(long id)
  Desc: Tar bort f”nsterObjektet fr†n Operativsystemet.
  In  : id - F”nster ID p† det f”nster som skall raderas.
  Out : svar - Om det gick att ta d”d p† F”nstret eller inte, en av 
               orsakerna till at det inte lyckades kan vara att f”nstret 
               fortfarande var ”ppet.

int window_open(long id,short xy[4])
  Desc: ™ppnar ett f”nster och b”rjar skicka meddelanden (om det beh”vs), Žr f”nstret
        ett WINDOW_DIALOG s† ritas dialogen up s† mycket som kan.
        Žr f”nstret av typen WINDOW_SCREEN s† sker „ven eventuell uppl”sningsbyte nu.
  In: id - F”nster Id p† det f”nster som skall ”ppnas.
      xy[4] - Koordinater f”r f”nstret.

Se window.h i window katalogen f”r olika strukturer, etc.