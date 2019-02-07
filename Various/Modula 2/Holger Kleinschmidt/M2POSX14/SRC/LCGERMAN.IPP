IMPLEMENTATION MODULE LCgerman;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(****************************************************************************)
(* 27-Mai-94, Holger Kleinschmidt                                           *)
(****************************************************************************)

FROM SYSTEM IMPORT
(* PROC *) ADR;
#if (defined MM2)
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD;

FROM LCTypes IMPORT
(* TYPE *) LCCtype, LCTime, LCNumeric, LCMonetary, LCMessages, CType,
           CClass, CClasses, CTrans;

#if !ISO_value_constructor
IMPORT LCPOSIX;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  VTime = RECORD
    Vabday : ARRAY [0..6]  OF ARRAY [0..3] OF CHAR;
    Vday   : ARRAY [0..6]  OF ARRAY [0..11] OF CHAR;
    Vabmon : ARRAY [0..11] OF ARRAY [0..3] OF CHAR;
    Vmon   : ARRAY [0..11] OF ARRAY [0..9] OF CHAR;
    Vampm  : CHAR;
    Vdtfmt : ARRAY [0..27] OF CHAR;
    Vdfmt  : ARRAY [0..9] OF CHAR;
    Vtfmt  : ARRAY [0..9] OF CHAR;
  END;

  VNumeric = RECORD
    Vdecimalpoint : ARRAY [0..1] OF CHAR;
    Vthousandssep : ARRAY [0..1] OF CHAR;
    Vgrouping     : ARRAY [0..1] OF CHAR;
  END;

  VMonetary = RECORD
    Vintcurrsymbol   : ARRAY [0..5] OF CHAR;
    Vcurrencysymbol  : ARRAY [0..3] OF CHAR;
    Vmondecimalpoint : ARRAY [0..1] OF CHAR;
    Vmonthousandssep : ARRAY [0..1] OF CHAR;
    Vmongrouping     : ARRAY [0..1] OF CHAR;
    Vpositivesign    : CHAR;
    Vnegativesign    : ARRAY [0..1] OF CHAR;
  END;


CONST
  UNKNOWNERR = "Unbekannter Fehler";

TYPE
  Vbioserr    = ARRAY [0..19] OF ARRAY [0..25] OF CHAR;
  Vgemdoserr  = ARRAY [0..16] OF ARRAY [0..27] OF CHAR;
  Vminterr    = ARRAY [0..1]  OF ARRAY [0..29] OF CHAR;
  Vsocketerr  = ARRAY [0..26] OF ARRAY [0..46] OF CHAR;
  Vposixerr   = ARRAY [0..15] OF ARRAY [0..29] OF CHAR;
  Vsignal     = ARRAY [0..30] OF ARRAY [0..40] OF CHAR;
  Vunknownerr = ARRAY [0..18] OF CHAR;
  Vunknownsig = ARRAY [0..18] OF CHAR;

#if ISO_value_constructor && (defined MM2)
CONST
 vtime = VTime{
   {"Son","Mon","Die","Mit","Don","Fre","Sam"},
   {"Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"},
   {"Jan","Feb","MÑr","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez"},
   {"Januar","Februar","MÑrz","April","Mai","Juni","Juli","August",
    "September","Oktober","November","Dezember"},
   0C,
   "%A, %e. %B %Y, %H:%M Uhr %Z",
   "%e.%m.%y",
   "%H:%M:%S"
 };
#else
VAR
 vtime : VTime;
#endif

VAR
  uerr : Vunknownerr;
  usig : Vunknownsig;

#if ISO_value_constructor && (defined HM2)
CONST
 vctype = LCCtype{
   CClasses{
     CClass{IScntrl}                                          BY 9,
     CClass{IScntrl,ISspace,ISblank}                          BY 1,
     CClass{IScntrl,ISspace}                                  BY 4,
     CClass{IScntrl}                                          BY 18,
     CClass{ISspace,ISblank,ISprint}                          BY 1,
     CClass{ISpunct,ISgraph,ISprint}                          BY 15,
     CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint}         BY 10,
     CClass{ISpunct,ISgraph,ISprint}                          BY 7,
     CClass{ISxdigit,ISupper,ISalpha,ISalnum,ISgraph,ISprint} BY 6,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 20,
     CClass{ISpunct,ISgraph,ISprint}                          BY 6,
     CClass{ISxdigit,ISlower,ISalpha,ISalnum,ISgraph,ISprint} BY 6,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 20,
     CClass{ISpunct,ISgraph,ISprint}                          BY 4,
     CClass{IScntrl}                                          BY 1,

     CClass{ISgraph,ISprint}                                  BY 1,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* ue *)
     CClass{ISgraph,ISprint}                                  BY 2,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* ae *)
     CClass{ISgraph,ISprint}                                  BY 9,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* Ae *)
     CClass{ISgraph,ISprint}                                  BY 5,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* oe *)
     CClass{ISgraph,ISprint}                                  BY 4,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* Oe *)
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* Ue *)
     CClass{ISgraph,ISprint}                                  BY 3,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* ss *)
     CClass{ISgraph,ISprint}                                  BY 97
   },
   CTrans{
     0C,1C,2C,3C,4C,5C,6C,7C,10C,11C,
     12C,13C,14C,15C,16C,17C,20C,21C,22C,23C,
     24C,25C,26C,27C,30C,31C,32C,33C,34C,35C,
     36C,37C,40C,41C,42C,43C,44C,45C,46C,47C,
     50C,51C,52C,53C,54C,55C,56C,57C,60C,61C,
     62C,63C,64C,65C,66C,67C,70C,71C,72C,73C,
     74C,75C,76C,77C,100C,101C,102C,103C,104C,105C,
     106C,107C,110C,111C,112C,113C,114C,115C,116C,117C,
     120C,121C,122C,123C,124C,125C,126C,127C,130C,131C,
     132C,133C,134C,135C,136C,137C,140C,101C,102C,103C,
     104C,105C,106C,107C,110C,111C,112C,113C,114C,115C,
     116C,117C,120C,121C,122C,123C,124C,125C,126C,127C,
     130C,131C,132C,173C,174C,175C,176C,177C,200C,232C,
     202C,203C,216C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,216C,217C,220C,221C,222C,223C,231C,225C,
     226C,227C,230C,231C,232C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
     276C,277C,300C,301C,302C,303C,304C,305C,306C,307C,
     310C,311C,312C,313C,314C,315C,316C,317C,320C,321C,
     322C,323C,324C,325C,326C,327C,330C,331C,332C,333C,
     334C,335C,336C,337C,340C,341C,342C,343C,344C,345C,
     346C,347C,350C,351C,352C,353C,354C,355C,356C,357C,
     360C,361C,362C,363C,364C,365C,366C,367C,370C,371C,
     372C,373C,374C,375C,376C,377C
   },
   CTrans{
     0C,1C,2C,3C,4C,5C,6C,7C,10C,11C,
     12C,13C,14C,15C,16C,17C,20C,21C,22C,23C,
     24C,25C,26C,27C,30C,31C,32C,33C,34C,35C,
     36C,37C,40C,41C,42C,43C,44C,45C,46C,47C,
     50C,51C,52C,53C,54C,55C,56C,57C,60C,61C,
     62C,63C,64C,65C,66C,67C,70C,71C,72C,73C,
     74C,75C,76C,77C,100C,141C,142C,143C,144C,145C,
     146C,147C,150C,151C,152C,153C,154C,155C,156C,157C,
     160C,161C,162C,163C,164C,165C,166C,167C,170C,171C,
     172C,133C,134C,135C,136C,137C,140C,141C,142C,143C,
     144C,145C,146C,147C,150C,151C,152C,153C,154C,155C,
     156C,157C,160C,161C,162C,163C,164C,165C,166C,167C,
     170C,171C,172C,173C,174C,175C,176C,177C,200C,201C,
     202C,203C,204C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,204C,217C,220C,221C,222C,223C,224C,225C,
     226C,227C,230C,224C,201C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
     276C,277C,300C,301C,302C,303C,304C,305C,306C,307C,
     310C,311C,312C,313C,314C,315C,316C,317C,320C,321C,
     322C,323C,324C,325C,326C,327C,330C,331C,332C,333C,
     334C,335C,336C,337C,340C,341C,342C,343C,344C,345C,
     346C,347C,350C,351C,352C,353C,354C,355C,356C,357C,
     360C,361C,362C,363C,364C,365C,366C,367C,370C,371C,
     372C,373C,374C,375C,376C,377C
   }
 };

 bios = Vbioserr{
   "OK",
   "Fehler",
   "GerÑt nicht bereit",
   "Unbekanntes Kommando",
   "CRC-Fehler",
   "Kommando nicht ausfÅhrbar",
   "SEEK-Fehler",
   "UngÅltiger Bootsektor",
   "Sektor nicht gefunden",
   "Drucker: Kein Papier",
   "Schreibfehler",
   "Lesefehler",
   "Allgemeiner Fehler",
   "Schreibschutz",
   "Diskette gewechselt",
   "Unbekanntes GerÑt",
   "Formatierfehler",
   "Diskette einlegen!",
   "Medium einlegen!",
   "GerÑt antwortet nicht"
 };
 gemdos = Vgemdoserr{
   "UngÅltige Funktionsnummer",
   "Datei nicht gefunden",
   "Pfad nicht gefunden",
   "Keine Dateikennung frei",
   "Zugriff verweigert",
   "UngÅltige Dateikennung",
   "Kein Speicher",
   "UngÅltige Speicheradresse",
   "UngÅltiges Laufwerk",
   "Unterschiedliche Laufwerke",
   "Keine weitere Datei",
   "Datei durch Lock geschÅtzt",
   "Lock existiert nicht",
   "UngÅltiger Dateizeiger",
   "Interner Fehler",
   "Nicht ausfÅhrbar",
   "Fehler bei Speicherfreigabe"
 };
 mint = Vminterr{
   "Zu viele symbolische Links",
   "Pipe nicht zum Lesen geîffnet"
 };
 socket = Vsocketerr{
   "Kein Socket",
   "Zieladresse erforderlich",
   "Nachricht zu lang",
   "Falscher Protokolltyp fÅr Socket",
   "Protokoll nicht vorhanden",
   "Protokoll nicht unterstÅtzt",
   "Socket-Typ nicht unterstÅtzt",
   "Operation nicht unterstÅtzt",
   "Protokollfamilie nicht unterstÅtzt",
   "Adressfamilie nicht vom Protokoll unterstÅtzt",
   "Adresse bereits benutzt",
   "Zuweisung der verlangten Adresse nicht mîglich",
   "Netzwerk nicht aktiv",
   "Netzwerk nicht erreichbar",
   "Verbindung wegen Reset abgebrochen",
   "Verbindung durch Programm abgebrochen",
   "Reset der Verbindung durch hîhere Stelle",
   "Socket ist bereits verbunden",
   "Socket ist nicht verbunden",
   "Kein Senden mehr mîglich",
   "Time-Out bei Verbindung",
   "Verbindung abgewiesen",
   "Ziel nicht aktiv",
   "Kein Weg zum Ziel gefunden",
   "Operation bereits in Arbeit",
   "Operation jetzt in Arbeit",
   "Operation wÅrde blockieren"
 };
 posix = Vposixerr{
   "Durch Signal unterbrochen",
   "Resource nicht verfÅgbar",
   "Deadlock wÅrde auftreten",
   "UngÅltiges Argument",
   "Datei existiert bereits",
   "Datei zu groû",
   "Zu viele Argumente",
   "Datei ist ein Verzeichnis",
   "Zu viele Links",
   "Dateiname zu lang",
   "Keine Locks verfÅgbar",
   "Kein Platz frei auf dem GerÑt",
   "Verzeichnis nicht leer",
   "Falsche E/A-Kontrolloperation",
   "Ergebnis zu groû",
   "UngÅltige SEEK-Operation"
 };
 signal = Vsignal{
   "Kein Signal",
   "Verbindung abbrechen!",
   "Unterbrechung",
   "Prozeû beenden!",
   "Unbekannte Instruktion",
   "Trace-Anweisung",
   "Prozeû abbrechen!",
   "Prozeû nicht priviligiert",
   "Gleitkomma-Ausnahme",
   "Prozeû abgebrochen",
   "Bus-Fehler",
   "Adreû-Fehler",
   "Falscher Parameter bei Systemaufruf",
   "UngÅltige Pipe",
   "Timeout-Zeit abgelaufen",
   "Prozeû beendet",
   "Brenzlige Situation an einem E/A-Kanal",
   "Prozeû gestoppt (Signal)",
   "Prozeû gestoppt",
   "Prozeû fortgesetzt",
   "Kindprozeû beendet",
   "Prozeû gestoppt (Terminal-Eingabe)",
   "Prozeû gestoppt (Terminal-Ausgabe)",
   "E/A mîglich",
   "Grenze fÅr CPU-Zeit Åberschritten",
   "Grenze fÅr Dateigrîûe Åberschritten",
   "Virtuelle Timeout-Zeit abgelaufen",
   "Signal fÅr Laufzeitprofil",
   "Signal des Fenstersystems",
   "Benutzerdefiniertes Signal 1",
   "Benutzerdefiniertes Signal 2"
 };
#else
VAR
  vctype : LCCtype;
  bios   : Vbioserr;
  gemdos : Vgemdoserr;
  mint   : Vminterr;
  socket : Vsocketerr;
  posix  : Vposixerr;
  signal : Vsignal;
#endif

VAR
  vnumeric  : VNumeric;
  vmonetary : VMonetary;

VAR
  time     : LCTime;
  monetary : LCMonetary;
  numeric  : LCNumeric;
  messages : LCMessages;

VAR
  i : UNSIGNEDWORD;
  c : CHAR;

BEGIN
#if ISO_value_constructor
 vnumeric := VNumeric{",",".","3"};
#else
 WITH vnumeric DO
   Vdecimalpoint := ",";
   Vthousandssep := ".";
   Vgrouping     := "3";
 END;
#endif
 WITH numeric DO WITH vnumeric DO
   decimalpoint := ADR(Vdecimalpoint);
   thousandssep := ADR(Vthousandssep);
   grouping     := ADR(Vgrouping);
 END; END;
 Numeric := ADR(numeric);

#if ISO_value_constructor
 vmonetary := VMonetary{"DM  ","DM",",",".","3",0C,"-"};
#else
 WITH vmonetary DO
   Vintcurrsymbol   := "DM  "; (* ?? *)
   Vcurrencysymbol  := "DM";
   Vmondecimalpoint := ",";
   Vmonthousandssep := ".";
   Vmongrouping     := "3";
   Vpositivesign    := 0C;
   Vnegativesign    := "-";
 END;
#endif
 WITH monetary DO WITH vmonetary DO
   intcurrsymbol   := ADR(Vintcurrsymbol);
   currencysymbol  := ADR(Vcurrencysymbol);
   mondecimalpoint := ADR(Vmondecimalpoint);
   monthousandssep := ADR(Vmonthousandssep);
   mongrouping     := ADR(Vmongrouping);
   positivesign    := ADR(Vpositivesign);
   negativesign    := ADR(Vnegativesign);

   intfracdigits   := 4; (* ?? *)
   fracdigits      := 2;
   pcsprecedes     := 0;
   psepbyspace     := 1;
   ncsprecedes     := 0;
   nsepbyspace     := 1;
   psignposn       := 1;
   nsignposn       := 1;
 END; END;
 Monetary := ADR(monetary);

#if !(ISO_value_constructor && (defined MM2))
#if ISO_value_constructor
 vtime := VTime{
   {"Son","Mon","Die","Mit","Don","Fre","Sam"},
   {"Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag"},
   {"Jan","Feb","MÑr","Apr","Mai","Jun","Jul","Aug","Sep","Okt","Nov","Dez"},
   {"Januar","Februar","MÑrz","April","Mai","Juni","Juli","August",
    "September","Oktober","November","Dezember"},
   0C,
   "%A, %e. %B %Y, %H:%M Uhr %Z",
   "%e.%m.%y",
   "%H:%M:%S"
 };
#else
 WITH vtime DO
   Vabday[0]  := "Son";
   Vabday[1]  := "Mon";
   Vabday[2]  := "Die";
   Vabday[3]  := "Mit";
   Vabday[4]  := "Don";
   Vabday[5]  := "Fre";
   Vabday[6]  := "Sam";
   Vday[0]    := "Sonntag";
   Vday[1]    := "Montag";
   Vday[2]    := "Dienstag";
   Vday[3]    := "Mittwoch";
   Vday[4]    := "Donnerstag";
   Vday[5]    := "Freitag";
   Vday[6]    := "Samstag";
   Vabmon[0]  := "Jan";
   Vabmon[1]  := "Feb";
   Vabmon[2]  := "MÑr";
   Vabmon[3]  := "Apr";
   Vabmon[4]  := "Mai";
   Vabmon[5]  := "Jun";
   Vabmon[6]  := "Jul";
   Vabmon[7]  := "Aug";
   Vabmon[8]  := "Sep";
   Vabmon[9]  := "Okt";
   Vabmon[10] := "Nov";
   Vabmon[11] := "Dez";
   Vmon[0]    := "Januar";
   Vmon[1]    := "Februar";
   Vmon[2]    := "MÑrz";
   Vmon[3]    := "April";
   Vmon[4]    := "Mai";
   Vmon[5]    := "Juni";
   Vmon[6]    := "Juli";
   Vmon[7]    := "August";
   Vmon[8]    := "September";
   Vmon[9]    := "Oktober";
   Vmon[10]   := "November";
   Vmon[11]   := "Dezember";
   Vampm      := 0C;
   Vdtfmt     := "%A, %e. %B %Y, %H:%M Uhr %Z";
   Vdfmt      := "%e.%m.%y";
   Vtfmt      := "%H:%M:%S";
 END;
#endif
#endif

 WITH time DO
   FOR i := 0 TO 6 DO
     abday[i] := CADR(vtime.Vabday[i]);
     day[i]   := CADR(vtime.Vday[i]);
   END;
   FOR i := 0 TO 11 DO
     abmon[i] := CADR(vtime.Vabmon[i]);
     mon[i]   := CADR(vtime.Vmon[i]);
   END;
   ampm[0]  := CADR(vtime.Vampm);
   ampm[1]  := CADR(vtime.Vampm);
   dtfmt    := CADR(vtime.Vdtfmt);
   dfmt     := CADR(vtime.Vdfmt);
   tfmt     := CADR(vtime.Vtfmt);
   tfmtampm := CADR(vtime.Vampm);
 END;
 Time := ADR(time);

 uerr := "Unbekannter Fehler";
 usig := "Unbekanntes Signal";

#if !(ISO_value_constructor && (defined HM2))
#if ISO_value_constructor
 vctype := LCCtype{
   CClasses{
     CClass{IScntrl}                                          BY 9,
     CClass{IScntrl,ISspace,ISblank}                          BY 1,
     CClass{IScntrl,ISspace}                                  BY 4,
     CClass{IScntrl}                                          BY 18,
     CClass{ISspace,ISblank,ISprint}                          BY 1,
     CClass{ISpunct,ISgraph,ISprint}                          BY 15,
     CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint}         BY 10,
     CClass{ISpunct,ISgraph,ISprint}                          BY 7,
     CClass{ISxdigit,ISupper,ISalpha,ISalnum,ISgraph,ISprint} BY 6,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 20,
     CClass{ISpunct,ISgraph,ISprint}                          BY 6,
     CClass{ISxdigit,ISlower,ISalpha,ISalnum,ISgraph,ISprint} BY 6,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 20,
     CClass{ISpunct,ISgraph,ISprint}                          BY 4,
     CClass{IScntrl}                                          BY 1,

     CClass{ISgraph,ISprint}                                  BY 1,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* ue *)
     CClass{ISgraph,ISprint}                                  BY 2,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* ae *)
     CClass{ISgraph,ISprint}                                  BY 9,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* Ae *)
     CClass{ISgraph,ISprint}                                  BY 5,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* oe *)
     CClass{ISgraph,ISprint}                                  BY 4,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* Oe *)
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* Ue *)
     CClass{ISgraph,ISprint}                                  BY 3,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}          BY 1, (* ss *)
     CClass{ISgraph,ISprint}                                  BY 97
   },
   CTrans{
     0C,1C,2C,3C,4C,5C,6C,7C,10C,11C,
     12C,13C,14C,15C,16C,17C,20C,21C,22C,23C,
     24C,25C,26C,27C,30C,31C,32C,33C,34C,35C,
     36C,37C,40C,41C,42C,43C,44C,45C,46C,47C,
     50C,51C,52C,53C,54C,55C,56C,57C,60C,61C,
     62C,63C,64C,65C,66C,67C,70C,71C,72C,73C,
     74C,75C,76C,77C,100C,101C,102C,103C,104C,105C,
     106C,107C,110C,111C,112C,113C,114C,115C,116C,117C,
     120C,121C,122C,123C,124C,125C,126C,127C,130C,131C,
     132C,133C,134C,135C,136C,137C,140C,101C,102C,103C,
     104C,105C,106C,107C,110C,111C,112C,113C,114C,115C,
     116C,117C,120C,121C,122C,123C,124C,125C,126C,127C,
     130C,131C,132C,173C,174C,175C,176C,177C,200C,232C,
     202C,203C,216C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,216C,217C,220C,221C,222C,223C,231C,225C,
     226C,227C,230C,231C,232C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
     276C,277C,300C,301C,302C,303C,304C,305C,306C,307C,
     310C,311C,312C,313C,314C,315C,316C,317C,320C,321C,
     322C,323C,324C,325C,326C,327C,330C,331C,332C,333C,
     334C,335C,336C,337C,340C,341C,342C,343C,344C,345C,
     346C,347C,350C,351C,352C,353C,354C,355C,356C,357C,
     360C,361C,362C,363C,364C,365C,366C,367C,370C,371C,
     372C,373C,374C,375C,376C,377C
   },
   CTrans{
     0C,1C,2C,3C,4C,5C,6C,7C,10C,11C,
     12C,13C,14C,15C,16C,17C,20C,21C,22C,23C,
     24C,25C,26C,27C,30C,31C,32C,33C,34C,35C,
     36C,37C,40C,41C,42C,43C,44C,45C,46C,47C,
     50C,51C,52C,53C,54C,55C,56C,57C,60C,61C,
     62C,63C,64C,65C,66C,67C,70C,71C,72C,73C,
     74C,75C,76C,77C,100C,141C,142C,143C,144C,145C,
     146C,147C,150C,151C,152C,153C,154C,155C,156C,157C,
     160C,161C,162C,163C,164C,165C,166C,167C,170C,171C,
     172C,133C,134C,135C,136C,137C,140C,141C,142C,143C,
     144C,145C,146C,147C,150C,151C,152C,153C,154C,155C,
     156C,157C,160C,161C,162C,163C,164C,165C,166C,167C,
     170C,171C,172C,173C,174C,175C,176C,177C,200C,201C,
     202C,203C,204C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,204C,217C,220C,221C,222C,223C,224C,225C,
     226C,227C,230C,224C,201C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
     276C,277C,300C,301C,302C,303C,304C,305C,306C,307C,
     310C,311C,312C,313C,314C,315C,316C,317C,320C,321C,
     322C,323C,324C,325C,326C,327C,330C,331C,332C,333C,
     334C,335C,336C,337C,340C,341C,342C,343C,344C,345C,
     346C,347C,350C,351C,352C,353C,354C,355C,356C,357C,
     360C,361C,362C,363C,364C,365C,366C,367C,370C,371C,
     372C,373C,374C,375C,376C,377C
   }
 };

 bios := Vbioserr{
   "OK",
   "Fehler",
   "GerÑt nicht bereit",
   "Unbekanntes Kommando",
   "CRC-Fehler",
   "Kommando nicht ausfÅhrbar",
   "SEEK-Fehler",
   "UngÅltiger Bootsektor",
   "Sektor nicht gefunden",
   "Drucker: Kein Papier",
   "Schreibfehler",
   "Lesefehler",
   "Allgemeiner Fehler",
   "Schreibschutz",
   "Diskette gewechselt",
   "Unbekanntes GerÑt",
   "Formatierfehler",
   "Diskette einlegen!",
   "Medium einlegen!",
   "GerÑt antwortet nicht"
 };
 gemdos := Vgemdoserr{
   "UngÅltige Funktionsnummer",
   "Datei nicht gefunden",
   "Pfad nicht gefunden",
   "Keine Dateikennung frei",
   "Zugriff verweigert",
   "UngÅltige Dateikennung",
   "Kein Speicher",
   "UngÅltige Speicheradresse",
   "UngÅltiges Laufwerk",
   "Unterschiedliche Laufwerke",
   "Keine weitere Datei",
   "Datei durch Lock geschÅtzt",
   "Lock existiert nicht",
   "UngÅltiger Dateizeiger",
   "Interner Fehler",
   "Nicht ausfÅhrbar",
   "Fehler bei Speicherfreigabe"
 };
 mint := Vminterr{
   "Zu viele symbolische Links",
   "Pipe nicht zum Lesen geîffnet"
 };
 socket := Vsocketerr{
   "Kein Socket",
   "Zieladresse erforderlich",
   "Nachricht zu lang",
   "Falscher Protokolltyp fÅr Socket",
   "Protokoll nicht vorhanden",
   "Protokoll nicht unterstÅtzt",
   "Socket-Typ nicht unterstÅtzt",
   "Operation nicht unterstÅtzt",
   "Protokollfamilie nicht unterstÅtzt",
   "Adressfamilie nicht vom Protokoll unterstÅtzt",
   "Adresse bereits benutzt",
   "Zuweisung der verlangten Adresse nicht mîglich",
   "Netzwerk nicht aktiv",
   "Netzwerk nicht erreichbar",
   "Verbindung wegen Reset abgebrochen",
   "Verbindung durch Programm abgebrochen",
   "Reset der Verbindung durch hîhere Stelle",
   "Socket ist bereits verbunden",
   "Socket ist nicht verbunden",
   "Kein Senden mehr mîglich",
   "Time-Out bei Verbindung",
   "Verbindung abgewiesen",
   "Ziel nicht aktiv",
   "Kein Weg zum Ziel gefunden",
   "Operation bereits in Arbeit",
   "Operation jetzt in Arbeit",
   "Operation wÅrde blockieren"
 };
 posix := Vposixerr{
   "Durch Signal unterbrochen",
   "Resource nicht verfÅgbar",
   "Deadlock wÅrde auftreten",
   "UngÅltiges Argument",
   "Datei existiert bereits",
   "Datei zu groû",
   "Zu viele Argumente",
   "Datei ist ein Verzeichnis",
   "Zu viele Links",
   "Dateiname zu lang",
   "Keine Locks verfÅgbar",
   "Kein Platz frei auf dem GerÑt",
   "Verzeichnis nicht leer",
   "Falsche E/A-Kontrolloperation",
   "Ergebnis zu groû",
   "UngÅltige SEEK-Operation"
 };
 signal := Vsignal{
   "Kein Signal",
   "Verbindung abbrechen!",
   "Unterbrechung",
   "Prozeû beenden!",
   "Unbekannte Instruktion",
   "Trace-Anweisung",
   "Prozeû abbrechen!",
   "Prozeû nicht priviligiert",
   "Gleitkomma-Ausnahme",
   "Prozeû abgebrochen",
   "Bus-Fehler",
   "Adreû-Fehler",
   "Falscher Parameter bei Systemaufruf",
   "UngÅltige Pipe",
   "Timeout-Zeit abgelaufen",
   "Prozeû beendet",
   "Brenzlige Situation an einem E/A-Kanal",
   "Prozeû gestoppt (Signal)",
   "Prozeû gestoppt",
   "Prozeû fortgesetzt",
   "Kindprozeû beendet",
   "Prozeû gestoppt (Terminal-Eingabe)",
   "Prozeû gestoppt (Terminal-Ausgabe)",
   "E/A mîglich",
   "Grenze fÅr CPU-Zeit Åberschritten",
   "Grenze fÅr Dateigrîûe Åberschritten",
   "Virtuelle Timeout-Zeit abgelaufen",
   "Signal fÅr Laufzeitprofil",
   "Signal des Fenstersystems",
   "Benutzerdefiniertes Signal 1",
   "Benutzerdefiniertes Signal 2"
 };
#else
 WITH vctype DO
   class := LCPOSIX.Ctype^.class;
   FOR c := 200C TO 377C DO
     class[c] := CClass{ISgraph,ISprint};
   END;
   class[204C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ae *)
   class[224C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* oe *)
   class[201C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ue *)
   class[236C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ss *)

   class[216C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* Ae *)
   class[231C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* Oe *)
   class[232C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* Ue *)

   toupper       := LCPOSIX.Ctype^.toupper;
   toupper[204C] := 216C;
   toupper[224C] := 231C;
   toupper[201C] := 232C;
   tolower       := LCPOSIX.Ctype^.tolower;
   tolower[216C] := 204C;
   tolower[231C] := 224C;
   tolower[232C] := 201C;
 END;

 bios[0]  := "OK";
 bios[1]  := "Fehler";
 bios[2]  := "GerÑt nicht bereit";
 bios[3]  := "Unbekanntes Kommando";
 bios[4]  := "CRC-Fehler";
 bios[5]  := "Kommando nicht ausfÅhrbar";
 bios[6]  := "SEEK-Fehler";
 bios[7]  := "UngÅltiger Bootsektor";
 bios[8]  := "Sektor nicht gefunden";
 bios[9]  := "Drucker: Kein Papier";
 bios[10] := "Schreibfehler";
 bios[11] := "Lesefehler";
 bios[12] := "Allgemeiner Fehler";
 bios[13] := "Schreibschutz";
 bios[14] := "Diskette gewechselt";
 bios[15] := "Unbekanntes GerÑt";
 bios[16] := "Formatierfehler";
 bios[17] := "Diskette einlegen!";
 bios[18] := "Medium einlegen!";
 bios[19] := "GerÑt antwortet nicht";

 gemdos[0]  := "UngÅltige Funktionsnummer";
 gemdos[1]  := "Datei nicht gefunden";
 gemdos[2]  := "Pfad nicht gefunden";
 gemdos[3]  := "Keine Dateikennung frei";
 gemdos[4]  := "Zugriff verweigert";
 gemdos[5]  := "UngÅltige Dateikennung";
 gemdos[6]  := "Kein Speicher";
 gemdos[7]  := "UngÅltige Speicheradresse";
 gemdos[8]  := "UngÅltiges Laufwerk";
 gemdos[9]  := "Unterschiedliche Laufwerke";
 gemdos[10] := "Keine weitere Datei";
 gemdos[11] := "Datei durch Lock geschÅtzt";
 gemdos[12] := "Lock existiert nicht";
 gemdos[13] := "UngÅltiger Dateizeiger";
 gemdos[14] := "Interner Fehler";
 gemdos[15] := "Nicht ausfÅhrbar";
 gemdos[16] := "Fehler bei Speicherfreigabe";

 mint[0] := "Zu viele symbolische Links";
 mint[1] := "Pipe nicht zum Lesen geîffnet";

 socket[0]  := "Kein Socket";
 socket[1]  := "Zieladresse erforderlich";
 socket[2]  := "Nachricht zu lang";
 socket[3]  := "Falscher Protokolltyp fÅr Socket";
 socket[4]  := "Protokoll nicht vorhanden";
 socket[5]  := "Protokoll nicht unterstÅtzt";
 socket[6]  := "Socket-Typ nicht unterstÅtzt";
 socket[7]  := "Operation nicht unterstÅtzt";
 socket[8]  := "Protokollfamilie nicht unterstÅtzt";
 socket[9]  := "Adressfamilie nicht vom Protokoll unterstÅtzt";
 socket[10] := "Adresse bereits benutzt";
 socket[11] := "Zuweisung der verlangten Adresse nicht mîglich";
 socket[12] := "Netzwerk nicht aktiv";
 socket[13] := "Netzwerk nicht erreichbar";
 socket[14] := "Verbindung wegen Reset abgebrochen";
 socket[15] := "Verbindung durch Programm abgebrochen";
 socket[16] := "Reset der Verbindung durch hîhere Stelle";
 socket[17] := "Socket ist bereits verbunden";
 socket[18] := "Socket ist nicht verbunden";
 socket[19] := "Kein Senden mehr mîglich";
 socket[20] := "Time-Out bei Verbindung";
 socket[21] := "Verbindung abgewiesen";
 socket[22] := "Ziel nicht aktiv";
 socket[23] := "Kein Weg zum Ziel gefunden";
 socket[24] := "Operation bereits in Arbeit";
 socket[25] := "Operation jetzt in Arbeit";
 socket[26] := "Operation wÅrde blockieren";

 posix[0]  := "Durch Signal unterbrochen";
 posix[1]  := "Resource nicht verfÅgbar";
 posix[2]  := "Deadlock wÅrde auftreten";
 posix[3]  := "UngÅltiges Argument";
 posix[4]  := "Datei existiert bereits";
 posix[5]  := "Datei zu groû";
 posix[6]  := "Zu viele Argumente";
 posix[7]  := "Datei ist ein Verzeichnis";
 posix[8]  := "Zu viele Links";
 posix[9]  := "Dateiname zu lang";
 posix[10] := "Keine Locks verfÅgbar";
 posix[11] := "Kein Platz frei auf dem GerÑt";
 posix[12] := "Verzeichnis nicht leer";
 posix[13] := "Falsche E/A-Kontrolloperation";
 posix[14] := "Ergebnis zu groû";
 posix[15] := "UngÅltige SEEK-Operation";

 signal[0]  := "Kein Signal";
 signal[1]  := "Verbindung abbrechen!";
 signal[2]  := "Unterbrechung";
 signal[3]  := "Prozeû beenden!";
 signal[4]  := "Unbekannte Instruktion";
 signal[5]  := "Trace-Anweisung";
 signal[6]  := "Prozeû abbrechen!";
 signal[7]  := "Prozeû nicht priviligiert";
 signal[8]  := "Gleitkomma-Ausnahme";
 signal[9]  := "Prozeû abgebrochen";
 signal[10] := "Bus-Fehler";
 signal[11] := "Adreû-Fehler";
 signal[12] := "Falscher Parameter bei Systemaufruf";
 signal[13] := "UngÅltige Pipe";
 signal[14] := "Timeout-Zeit abgelaufen";
 signal[15] := "Prozeû beendet";
 signal[16] := "Brenzlige Situation an einem E/A-Kanal";
 signal[17] := "Prozeû gestoppt (Signal)";
 signal[18] := "Prozeû gestoppt";
 signal[19] := "Prozeû fortgesetzt";
 signal[20] := "Kindprozeû beendet";
 signal[21] := "Prozeû gestoppt (Terminal-Eingabe)";
 signal[22] := "Prozeû gestoppt (Terminal-Ausgabe)";
 signal[23] := "E/A mîglich";
 signal[24] := "Grenze fÅr CPU-Zeit Åberschritten";
 signal[25] := "Grenze fÅr Dateigrîûe Åberschritten";
 signal[26] := "Virtuelle Timeout-Zeit abgelaufen";
 signal[27] := "Signal fÅr Laufzeitprofil";
 signal[28] := "Signal des Fenstersystems";
 signal[29] := "Benutzerdefiniertes Signal 1";
 signal[30] := "Benutzerdefiniertes Signal 2";
#endif
#endif

 Ctype := ADR(vctype);

 WITH messages DO
   FOR i := 0 TO 19 DO
     bioserr[i] := ADR(bios[i]);
   END;
   FOR i := 0 TO 5 DO
     gemdoserr[i] := ADR(gemdos[i]);
   END;
   gemdoserr[6] := ADR(uerr);
   gemdoserr[7] := ADR(gemdos[6]);
   gemdoserr[8] := ADR(gemdos[7]);
   FOR i := 9 TO 13 DO
     gemdoserr[i] := ADR(uerr);
   END;
   gemdoserr[14] := ADR(gemdos[8]);
   gemdoserr[15] := ADR(uerr);
   gemdoserr[16] := ADR(gemdos[9]);
   gemdoserr[17] := ADR(gemdos[10]);
   FOR i := 18 TO 25 DO
     gemdoserr[i] := ADR(uerr);
   END;
   gemdoserr[26] := ADR(gemdos[11]);
   gemdoserr[27] := ADR(gemdos[12]);
   FOR i := 28 TO 31 DO
     gemdoserr[i] := ADR(uerr);
   END;
   gemdoserr[32] := ADR(gemdos[13]);
   gemdoserr[33] := ADR(gemdos[14]);
   gemdoserr[34] := ADR(gemdos[15]);
   gemdoserr[35] := ADR(gemdos[16]);
   minterr[0] := ADR(mint[0]);
   minterr[1] := ADR(mint[1]);
   FOR i := 0 TO 26 DO
     socketerr[i] := ADR(socket[i]);
   END;
   FOR i := 0 TO 15 DO
     posixerr[i] := ADR(posix[i]);
   END;
   FOR i := 0 TO 30 DO
     signalstr[i] := ADR(signal[i]);
   END;
   unknownerr := ADR(uerr);
   unknownsig := ADR(usig);
 END;

 Messages := ADR(messages);
END LCgerman.
