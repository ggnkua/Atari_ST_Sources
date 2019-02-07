IMPLEMENTATION MODULE LCde;
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
(* 29-Apr-96, Holger Kleinschmidt                                           *)
(****************************************************************************)

FROM SYSTEM IMPORT
(* PROC *) ADR;
#if (defined MM2)
FROM SYSTEM IMPORT CADR;
#endif
#if (defined TDIM2)
FROM SYSTEM IMPORT ADDRESS;
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD;

FROM LCTypes IMPORT
(* TYPE *) LCCtype, LCTime, LCNumeric, LCMonetary, LCMessages, CType,
           CClass, CClasses, CTrans;

#if !((defined HM2) || ((defined MM2) && !(defined MM2_43c)))
IMPORT LCPOSIX;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if (defined LPRM2) || (defined SPCM2)
#  define STRADR(_s) ADR(_s)
#elif (defined MM2)
#  define STRADR(_s) CADR(_s)
#endif

CONST
  decimalPoint = ",";
  thousandsSep = ".";
  Grouping     = "3";

CONST
  intCurrSymbol   = "DEM ";
  currencySymbol  = "DM";
  monDecimalPoint = ",";
  monThousandsSep = ".";
  monGrouping     = "3";
  positiveSign    = "";
  negativeSign    = "-";

CONST
  intFracDigits = 4;
  fracDigits    = 2;
  pCsPrecedes   = 0;
  pSepBySpace   = 1;
  nCsPrecedes   = 0;
  nSepBySpace   = 1;
  pSignPosn     = 1;
  nSignPosn     = 1;

#if (defined HM2)
/* Laengster String: 2 Zeichen */
#define abday0 "So"
#define abday1 "Mo"
#define abday2 "Di"
#define abday3 "Mi"
#define abday4 "Do"
#define abday5 "Fr"
#define abday6 "Sa"

/* Laengster String: 10 Zeichen */
#define day0 "Sonntag"
#define day1 "Montag"
#define day2 "Dienstag"
#define day3 "Mittwoch"
#define day4 "Donnerstag"
#define day5 "Freitag"
#define day6 "Samstag"

/* Laengster String: 3 Zeichen */
#define abmon0 "Jan"
#define abmon1 "Feb"
#define abmon2 "MÑr"
#define abmon3 "Apr"
#define abmon4 "Mai"
#define abmon5 "Jun"
#define abmon6 "Jul"
#define abmon7 "Aug"
#define abmon8 "Sep"
#define abmon9 "Okt"
#define abmon10 "Nov"
#define abmon11 "Dez"

/* Laengster String: 9 Zeichen */
#define mon0 "Januar"
#define mon1 "Februar"
#define mon2 "MÑrz"
#define mon3 "April"
#define mon4 "Mai"
#define mon5 "Juni"
#define mon6 "Juli"
#define mon7 "August"
#define mon8 "September"
#define mon9 "Oktober"
#define mon10 "November"
#define mon11 "Dezember"

#define amstr ""
#define pmstr ""

#define dtfmtstr "%A, %e. %B %Y, %H:%M Uhr %Z"
#define dfmtstr "%e.%m.%y"
#define tfmtstr "%H:%M:%S"
#define tfmtampmstr ""

#else /* !(defined HM2) */

CONST (* Laengster String: 2 Zeichen *)
  abday0 = "So";
  abday1 = "Mo";
  abday2 = "Di";
  abday3 = "Mi";
  abday4 = "Do";
  abday5 = "Fr";
  abday6 = "Sa";

CONST (* Laengster String: 10 Zeichen *)
  day0 = "Sonntag";
  day1 = "Montag";
  day2 = "Dienstag";
  day3 = "Mittwoch";
  day4 = "Donnerstag";
  day5 = "Freitag";
  day6 = "Samstag";

CONST (* Laengster String: 3 Zeichen *)
  abmon0 = "Jan";
  abmon1 = "Feb";
  abmon2 = "MÑr";
  abmon3 = "Apr";
  abmon4 = "Mai";
  abmon5 = "Jun";
  abmon6 = "Jul";
  abmon7 = "Aug";
  abmon8 = "Sep";
  abmon9 = "Okt";
  abmon10 = "Nov";
  abmon11 = "Dez";

CONST (* Laengster String: 9 Zeichen *)
  mon0 = "Januar";
  mon1 = "Februar";
  mon2 = "MÑrz";
  mon3 = "April";
  mon4 = "Mai";
  mon5 = "Juni";
  mon6 = "Juli";
  mon7 = "August";
  mon8 = "September";
  mon9 = "Oktober";
  mon10 = "November";
  mon11 = "Dezember";

CONST
  amstr = "";
  pmstr = "";

CONST
  dtfmtstr = "%A, %e. %B %Y, %H:%M Uhr %Z";
  dfmtstr = "%e.%m.%y";
  tfmtstr = "%H:%M:%S";
  tfmtampmstr = "";
#endif

CONST (* Laengster String: 25 Zeichen *)
  bios0 = "OK";
  bios1 = "Fehler";
  bios2 = "GerÑt nicht bereit";
  bios3 = "Unbekanntes Kommando";
  bios4 = "CRC-Fehler";
  bios5 = "Kommando nicht ausfÅhrbar";
  bios6 = "SEEK-Fehler";
  bios7 = "UngÅltiger Bootsektor";
  bios8 = "Sektor nicht gefunden";
  bios9 = "Drucker: Kein Papier";
  bios10 = "Schreibfehler";
  bios11 = "Lesefehler";
  bios12 = "Allgemeiner Fehler";
  bios13 = "Schreibschutz";
  bios14 = "Diskette gewechselt";
  bios15 = "Unbekanntes GerÑt";
  bios16 = "Formatierfehler";
  bios17 = "Diskette einlegen!";
  bios18 = "Medium einlegen!";
  bios19 = "GerÑt antwortet nicht";

CONST (* Laengster String: 31 Zeichen *)
  gemdos0 = "UngÅltige Funktionsnummer";
  gemdos1 = "Datei nicht gefunden";
  gemdos2 = "Kein Verzeichnis";
  gemdos3 = "Keine Dateikennung frei";
  gemdos4 = "Zugriff verweigert";
  gemdos5 = "UngÅltige Dateikennung";
  gemdos7 = "Kein Speicher";
  gemdos8 = "UngÅltige Speicheradresse";
  gemdos14 = "UngÅltiges Laufwerk";
  gemdos16 = "Unterschiedliche Laufwerke";
  gemdos17 = "Keine weitere Datei";
  gemdos26 = "Datei durch Lock geschÅtzt";
  gemdos27 = "Lock existiert nicht";
  gemdos32 = "UngÅltiges Argument";
  gemdos33 = "Interner Fehler";
  gemdos34 = "Nicht ausfÅhrbar";
  gemdos35 = "Fehler bei Speicherfreigabe";
  gemdos36 = "Programmabbruch durch Benutzer";
  gemdos37 = "Programmabbruch wegen Ausnahme";
  gemdos38 = "PfadÅberlauf";

CONST (* Laengster String: 29 Zeichen *)
  mint0 = "Zu viele symbolische Links";
  mint1 = "Pipe nicht zum Lesen geîffnet";

CONST (* Laengster String: 46 Zeichen *)
  socket0 = "Kein Socket";
  socket1 = "Zieladresse erforderlich";
  socket2 = "Nachricht zu lang";
  socket3 = "Falscher Protokolltyp fÅr Socket";
  socket4 = "Protokoll nicht vorhanden";
  socket5 = "Protokoll nicht unterstÅtzt";
  socket6 = "Socket-Typ nicht unterstÅtzt";
  socket7 = "Operation nicht unterstÅtzt";
  socket8 = "Protokollfamilie nicht unterstÅtzt";
  socket9 = "Adreûfamilie nicht vom Protokoll unterstÅtzt";
  socket10 = "Adresse bereits benutzt";
  socket11 = "Zuweisung der verlangten Adresse nicht mîglich";
  socket12 = "Netzwerk nicht aktiv";
  socket13 = "Netzwerk nicht erreichbar";
  socket14 = "Verbindung wegen Reset abgebrochen";
  socket15 = "Verbindung durch Programm abgebrochen";
  socket16 = "Reset der Verbindung durch hîhere Stelle";
  socket17 = "Socket ist bereits verbunden";
  socket18 = "Socket ist nicht verbunden";
  socket19 = "Kein Senden mehr mîglich";
  socket20 = "Time-Out bei Verbindung";
  socket21 = "Verbindung abgewiesen";
  socket22 = "Ziel nicht aktiv";
  socket23 = "Kein Weg zum Ziel gefunden";
  socket24 = "Operation bereits in Arbeit";
  socket25 = "Operation jetzt in Arbeit";
  socket26 = "Operation wÅrde blockieren";

CONST (* Laengster String: 29 Zeichen *)
  posix0 = "Durch Signal unterbrochen";
  posix1 = "Resource nicht verfÅgbar";
  posix2 = "Deadlock wÅrde auftreten";
  posix3 = "Datei existiert bereits";
  posix4 = "Datei zu groû";
  posix5 = "Zu viele Argumente";
  posix6 = "Datei ist ein Verzeichnis";
  posix7 = "Zu viele Links";
  posix8 = "Dateiname zu lang";
  posix9 = "Keine Locks verfÅgbar";
  posix10 = "Kein Platz frei auf dem GerÑt";
  posix11 = "Verzeichnis nicht leer";
  posix12 = "Falsche E/A-Kontrolloperation";
  posix13 = "Ergebnis zu groû";
  posix14 = "UngÅltige Seek-Operation";

CONST (* Laengster String: 38 Zeichen *)
  signal0 = "Kein Signal";
  signal1 = "Verbindung abbrechen!";
  signal2 = "Unterbrechung";
  signal3 = "Prozeû beenden!";
  signal4 = "Unbekannte Instruktion";
  signal5 = "Trace-Anweisung";
  signal6 = "Prozeû abbrechen!";
  signal7 = "Prozeû nicht privilegiert";
  signal8 = "Gleitkomma-Ausnahme";
  signal9 = "Prozeû abgebrochen";
  signal10 = "Busfehler";
  signal11 = "Adreûfehler";
  signal12 = "Falscher Parameter bei Systemaufruf";
  signal13 = "UngÅltige Pipe";
  signal14 = "Timeout-Zeit abgelaufen";
  signal15 = "Prozeû beendet";
  signal16 = "Brenzlige Situation an einem E/A-Kanal";
  signal17 = "Prozeû gestoppt (Signal)";
  signal18 = "Prozeû gestoppt";
  signal19 = "Prozeû fortgesetzt";
  signal20 = "Kindprozeû beendet";
  signal21 = "Prozeû gestoppt (Terminal-Eingabe)";
  signal22 = "Prozeû gestoppt (Terminal-Ausgabe)";
  signal23 = "E/A mîglich";
  signal24 = "Maximale CPU-Zeit Åberschritten";
  signal25 = "Maximale Dateigrîûe Åberschritten";
  signal26 = "Virtuelle Timeout-Zeit abgelaufen";
  signal27 = "Signal fÅr Laufzeitprofil";
  signal28 = "Signal des Fenstersystems";
  signal29 = "Benutzerdefiniertes Signal 1";
  signal30 = "Benutzerdefiniertes Signal 2";

CONST (* Laengster String: 18 Zeichen *)
  unknown0 = "Unbekannter Fehler";
  unknown1 = "Unbekanntes Signal";


TYPE
  VNumeric = RECORD
    Vdecimalpoint : ARRAY [0..1] OF CHAR;
    Vthousandssep : ARRAY [0..1] OF CHAR;
    Vgrouping     : ARRAY [0..1] OF CHAR;
  END;

  VMonetary = RECORD
    Vintcurrsymbol   : ARRAY [0..4] OF CHAR;
    Vcurrencysymbol  : ARRAY [0..2] OF CHAR;
    Vmondecimalpoint : ARRAY [0..1] OF CHAR;
    Vmonthousandssep : ARRAY [0..1] OF CHAR;
    Vmongrouping     : ARRAY [0..1] OF CHAR;
    Vpositivesign    : ARRAY [0..0] OF CHAR;
    Vnegativesign    : ARRAY [0..1] OF CHAR;
  END;

#if (defined HM2)
TYPE
  VTime = RECORD
    Vabday    : ARRAY [0..6]  OF ARRAY [0..2] OF CHAR;
    Vday      : ARRAY [0..6]  OF ARRAY [0..10] OF CHAR;
    Vabmon    : ARRAY [0..11] OF ARRAY [0..3] OF CHAR;
    Vmon      : ARRAY [0..11] OF ARRAY [0..9] OF CHAR;
    Vampm     : ARRAY [0..1]  OF ARRAY [0..0] OF CHAR;
    Vdtfmt    : ARRAY [0..27] OF CHAR;
    Vdfmt     : ARRAY [0..9]  OF CHAR;
    Vtfmt     : ARRAY [0..9]  OF CHAR;
    Vtfmtampm : ARRAY [0..0]  OF CHAR;
  END;

VAR
  vtime : VTime;
#endif

#if ((defined MM2) && !(defined MM2_43c)) || (defined HM2)
CONST
 vctype = LCCtype{
   CClasses{
     CClass{IScntrl}                                           BY 9,
     CClass{IScntrl,ISspace,ISblank}                           BY 1,
     CClass{IScntrl,ISspace}                                   BY 4,
     CClass{IScntrl}                                           BY 18,
     CClass{ISspace,ISblank,ISprint}                           BY 1,
     CClass{ISpunct,ISgraph,ISprint}                           BY 15,
     CClass{ISdigit,ISodigit,ISxdigit,ISalnum,ISgraph,ISprint} BY 8,
     CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint}          BY 2,
     CClass{ISpunct,ISgraph,ISprint}                           BY 7,
     CClass{ISxdigit,ISupper,ISalpha,ISalnum,ISgraph,ISprint}  BY 6,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 20,
     CClass{ISpunct,ISgraph,ISprint}                           BY 6,
     CClass{ISxdigit,ISlower,ISalpha,ISalnum,ISgraph,ISprint}  BY 6,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 20,
     CClass{ISpunct,ISgraph,ISprint}                           BY 4,
     CClass{IScntrl}                                           BY 1,

     CClass{ISgraph,ISprint}                                   BY 1,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* Å *)
     CClass{ISgraph,ISprint}                                   BY 2,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* Ñ *)
     CClass{ISgraph,ISprint}                                   BY 9,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* é *)
     CClass{ISgraph,ISprint}                                   BY 5,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* î *)
     CClass{ISgraph,ISprint}                                   BY 4,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ô *)
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ö *)
     CClass{ISgraph,ISprint}                                   BY 3,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* û *)
     CClass{ISgraph,ISprint}                                   BY 97
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
#else
VAR
  vctype : LCCtype;
#endif

#if (defined HM2)
TYPE
  Vbioserr   = ARRAY [0..19] OF ARRAY [0..25] OF CHAR;
  Vgemdoserr = ARRAY [0..19] OF ARRAY [0..31] OF CHAR;
  Vminterr   = ARRAY [0..1]  OF ARRAY [0..29] OF CHAR;
  Vsocketerr = ARRAY [0..26] OF ARRAY [0..46] OF CHAR;
  Vposixerr  = ARRAY [0..14] OF ARRAY [0..29] OF CHAR;
  Vsignal    = ARRAY [0..30] OF ARRAY [0..38] OF CHAR;
  Vunknown   = ARRAY [0..1]  OF ARRAY [0..18] OF CHAR;

CONST
  bios = Vbioserr{
    bios0, bios1, bios2, bios3, bios4, bios5, bios6, bios7, bios8,
    bios9, bios10, bios11, bios12, bios13, bios14, bios15, bios16,
    bios17, bios18, bios19
  };

CONST
  gemdos = Vgemdoserr{
    gemdos0, gemdos1, gemdos2, gemdos3, gemdos4, gemdos5, gemdos7,
    gemdos8, gemdos14, gemdos16, gemdos17, gemdos26, gemdos27,
    gemdos32, gemdos33, gemdos34, gemdos35, gemdos36, gemdos37, gemdos38
  };

CONST
  mint = Vminterr{
    mint0, mint1
  };

CONST
  socket = Vsocketerr{
    socket0, socket1, socket2, socket3, socket4, socket5, socket6,
    socket7, socket8, socket9, socket10, socket11, socket12, socket13,
    socket14, socket15, socket16, socket17, socket18, socket19, socket20,
    socket21, socket22, socket23, socket24, socket25, socket26
  };

CONST
 posix = Vposixerr{
   posix0, posix1, posix2, posix3, posix4, posix5, posix6, posix7,
   posix8, posix9, posix10, posix11, posix12, posix13, posix14
 };

CONST
  signal = Vsignal{
    signal0, signal1, signal2, signal3, signal4, signal5, signal6,
    signal7, signal8, signal9, signal10, signal11, signal12, signal13,
    signal14, signal15, signal16, signal17, signal18, signal19, signal20,
    signal21, signal22, signal23, signal24, signal25, signal26, signal27,
    signal28, signal29, signal30
  };

CONST
  unknown = Vunknown{
    unknown0, unknown1
  };
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

#if (defined TDIM2)
PROCEDURE STRADR ((* EIN/ -- *) VAR s : ARRAY OF CHAR ): ADDRESS;
(* Hiermit kann die Adresse einer Stringkonstante ermittelt werden *)
BEGIN
 RETURN(ADR(s));
END STRADR;
#endif

BEGIN (* LCde *)
#if (defined HM2) || (defined MM2)
 vnumeric := VNumeric{decimalPoint,thousandsSep,Grouping};
#else
 WITH vnumeric DO
   Vdecimalpoint := decimalPoint;
   Vthousandssep := thousandsSep;
   Vgrouping     := Grouping;
 END;
#endif
 WITH numeric DO WITH vnumeric DO
   decimalpoint := ADR(Vdecimalpoint);
   thousandssep := ADR(Vthousandssep);
   grouping     := ADR(Vgrouping);
 END; END;

#if (defined HM2) || (defined MM2)
 vmonetary := VMonetary{intCurrSymbol,currencySymbol,monDecimalPoint,
                        monThousandsSep,monGrouping,positiveSign,negativeSign};
#else
 WITH vmonetary DO
   Vintcurrsymbol   := intCurrSymbol;
   Vcurrencysymbol  := currencySymbol;
   Vmondecimalpoint := monDecimalPoint;
   Vmonthousandssep := monThousandsSep;
   Vmongrouping     := monGrouping;
   Vpositivesign    := positiveSign;
   Vnegativesign    := negativeSign;
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

   intfracdigits   := intFracDigits;
   fracdigits      := fracDigits;
   pcsprecedes     := pCsPrecedes;
   psepbyspace     := pSepBySpace;
   ncsprecedes     := nCsPrecedes;
   nsepbyspace     := nSepBySpace;
   psignposn       := pSignPosn;
   nsignposn       := nSignPosn;
 END; END;

#if (defined TDIM2) || (defined LPRM2) || (defined SPCM2) || (defined MM2)
 WITH time DO
   abday[0]  := STRADR(abday0);
   abday[1]  := STRADR(abday1);
   abday[2]  := STRADR(abday2);
   abday[3]  := STRADR(abday3);
   abday[4]  := STRADR(abday4);
   abday[5]  := STRADR(abday5);
   abday[6]  := STRADR(abday6);
   day[0]    := STRADR(day0);
   day[1]    := STRADR(day1);
   day[2]    := STRADR(day2);
   day[3]    := STRADR(day3);
   day[4]    := STRADR(day4);
   day[5]    := STRADR(day5);
   day[6]    := STRADR(day6);
   abmon[0]  := STRADR(abmon0);
   abmon[1]  := STRADR(abmon1);
   abmon[2]  := STRADR(abmon2);
   abmon[3]  := STRADR(abmon3);
   abmon[4]  := STRADR(abmon4);
   abmon[5]  := STRADR(abmon5);
   abmon[6]  := STRADR(abmon6);
   abmon[7]  := STRADR(abmon7);
   abmon[8]  := STRADR(abmon8);
   abmon[9]  := STRADR(abmon9);
   abmon[10] := STRADR(abmon10);
   abmon[11] := STRADR(abmon11);
   mon[0]    := STRADR(mon0);
   mon[1]    := STRADR(mon1);
   mon[2]    := STRADR(mon2);
   mon[3]    := STRADR(mon3);
   mon[4]    := STRADR(mon4);
   mon[5]    := STRADR(mon5);
   mon[6]    := STRADR(mon6);
   mon[7]    := STRADR(mon7);
   mon[8]    := STRADR(mon8);
   mon[9]    := STRADR(mon9);
   mon[10]   := STRADR(mon10);
   mon[11]   := STRADR(mon11);
   ampm[0]   := STRADR(amstr);
   ampm[1]   := STRADR(pmstr);
   dtfmt     := STRADR(dtfmtstr);
   dfmt      := STRADR(dfmtstr);
   tfmt      := STRADR(tfmtstr);
   tfmtampm  := STRADR(tfmtampmstr);
 END;
#else
 vtime := VTime{
   {abday0,abday1,abday2,abday3,abday4,abday5,abday6},
   {day0,day1,day2,day3,day4,day5,day6},
   {abmon0,abmon1,abmon2,abmon3,abmon4,abmon5,abmon6,abmon7,abmon8,abmon9,
    abmon10,abmon11},
   {mon0,mon1,mon2,mon3,mon4,mon5,mon6, mon7,mon8,mon9,mon10,mon11},
   {amstr,pmstr},
   dtfmtstr,
   dfmtstr,
   tfmtstr,
   tfmtampmstr
 };

 WITH time DO
   FOR i := 0 TO 6 DO
     abday[i] := ADR(vtime.Vabday[i]);
     day[i]   := ADR(vtime.Vday[i]);
   END;
   FOR i := 0 TO 11 DO
     abmon[i] := ADR(vtime.Vabmon[i]);
     mon[i]   := ADR(vtime.Vmon[i]);
   END;
   ampm[0]  := ADR(vtime.Vampm[0]);
   ampm[1]  := ADR(vtime.Vampm[1]);
   dtfmt    := ADR(vtime.Vdtfmt);
   dfmt     := ADR(vtime.Vdfmt);
   tfmt     := ADR(vtime.Vtfmt);
   tfmtampm := ADR(vtime.Vtfmtampm);
 END;
#endif

#if !((defined HM2) || ((defined MM2) && !(defined MM2_43c)))
 WITH vctype DO
   class := LCPOSIX.Ctype^.class;
   FOR c := 200C TO 377C DO
     class[c] := CClass{ISgraph,ISprint};
   END;
   class[204C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* Ñ *)
   class[224C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* î *)
   class[201C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* Å *)
   class[236C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* û *)

   class[216C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* é *)
   class[231C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* ô *)
   class[232C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* ö *)

   toupper       := LCPOSIX.Ctype^.toupper;
   toupper[204C] := 216C;
   toupper[224C] := 231C;
   toupper[201C] := 232C;
   tolower       := LCPOSIX.Ctype^.tolower;
   tolower[216C] := 204C;
   tolower[231C] := 224C;
   tolower[232C] := 201C;
 END;
#endif

#if (defined TDIM2) || (defined LPRM2) || (defined SPCM2) || (defined MM2)
 WITH messages DO
   bioserr[0]  := STRADR(bios0);
   bioserr[1]  := STRADR(bios1);
   bioserr[2]  := STRADR(bios2);
   bioserr[3]  := STRADR(bios3);
   bioserr[4]  := STRADR(bios4);
   bioserr[5]  := STRADR(bios5);
   bioserr[6]  := STRADR(bios6);
   bioserr[7]  := STRADR(bios7);
   bioserr[8]  := STRADR(bios8);
   bioserr[9]  := STRADR(bios9);
   bioserr[10] := STRADR(bios10);
   bioserr[11] := STRADR(bios11);
   bioserr[12] := STRADR(bios12);
   bioserr[13] := STRADR(bios13);
   bioserr[14] := STRADR(bios14);
   bioserr[15] := STRADR(bios15);
   bioserr[16] := STRADR(bios16);
   bioserr[17] := STRADR(bios17);
   bioserr[18] := STRADR(bios18);
   bioserr[19] := STRADR(bios19);

   gemdoserr[0]  := STRADR(gemdos0);
   gemdoserr[1]  := STRADR(gemdos1);
   gemdoserr[2]  := STRADR(gemdos2);
   gemdoserr[3]  := STRADR(gemdos3);
   gemdoserr[4]  := STRADR(gemdos4);
   gemdoserr[5]  := STRADR(gemdos5);
   gemdoserr[7]  := STRADR(gemdos7);
   gemdoserr[8]  := STRADR(gemdos8);
   gemdoserr[14] := STRADR(gemdos14);
   gemdoserr[16] := STRADR(gemdos16);
   gemdoserr[17] := STRADR(gemdos17);
   gemdoserr[26] := STRADR(gemdos26);
   gemdoserr[27] := STRADR(gemdos27);
   gemdoserr[32] := STRADR(gemdos32);
   gemdoserr[33] := STRADR(gemdos33);
   gemdoserr[34] := STRADR(gemdos34);
   gemdoserr[35] := STRADR(gemdos35);
   gemdoserr[36] := STRADR(gemdos36);
   gemdoserr[37] := STRADR(gemdos37);
   gemdoserr[38] := STRADR(gemdos38);

   minterr[0] := STRADR(mint0);
   minterr[1] := STRADR(mint1);

   socketerr[0]  := STRADR(socket0);
   socketerr[1]  := STRADR(socket1);
   socketerr[2]  := STRADR(socket2);
   socketerr[3]  := STRADR(socket3);
   socketerr[4]  := STRADR(socket4);
   socketerr[5]  := STRADR(socket5);
   socketerr[6]  := STRADR(socket6);
   socketerr[7]  := STRADR(socket7);
   socketerr[8]  := STRADR(socket8);
   socketerr[9]  := STRADR(socket9);
   socketerr[10] := STRADR(socket10);
   socketerr[11] := STRADR(socket11);
   socketerr[12] := STRADR(socket12);
   socketerr[13] := STRADR(socket13);
   socketerr[14] := STRADR(socket14);
   socketerr[15] := STRADR(socket15);
   socketerr[16] := STRADR(socket16);
   socketerr[17] := STRADR(socket17);
   socketerr[18] := STRADR(socket18);
   socketerr[19] := STRADR(socket19);
   socketerr[20] := STRADR(socket20);
   socketerr[21] := STRADR(socket21);
   socketerr[22] := STRADR(socket22);
   socketerr[23] := STRADR(socket23);
   socketerr[24] := STRADR(socket24);
   socketerr[25] := STRADR(socket25);
   socketerr[26] := STRADR(socket26);

   posixerr[0]  := STRADR(posix0);
   posixerr[1]  := STRADR(posix1);
   posixerr[2]  := STRADR(posix2);
   posixerr[3]  := STRADR(posix3);
   posixerr[4]  := STRADR(posix4);
   posixerr[5]  := STRADR(posix5);
   posixerr[6]  := STRADR(posix6);
   posixerr[7]  := STRADR(posix7);
   posixerr[8]  := STRADR(posix8);
   posixerr[9]  := STRADR(posix9);
   posixerr[10] := STRADR(posix10);
   posixerr[11] := STRADR(posix11);
   posixerr[12] := STRADR(posix12);
   posixerr[13] := STRADR(posix13);
   posixerr[14] := STRADR(posix14);

   signalstr[0]  := STRADR(signal0);
   signalstr[1]  := STRADR(signal1);
   signalstr[2]  := STRADR(signal2);
   signalstr[3]  := STRADR(signal3);
   signalstr[4]  := STRADR(signal4);
   signalstr[5]  := STRADR(signal5);
   signalstr[6]  := STRADR(signal6);
   signalstr[7]  := STRADR(signal7);
   signalstr[8]  := STRADR(signal8);
   signalstr[9]  := STRADR(signal9);
   signalstr[10] := STRADR(signal10);
   signalstr[11] := STRADR(signal11);
   signalstr[12] := STRADR(signal12);
   signalstr[13] := STRADR(signal13);
   signalstr[14] := STRADR(signal14);
   signalstr[15] := STRADR(signal15);
   signalstr[16] := STRADR(signal16);
   signalstr[17] := STRADR(signal17);
   signalstr[18] := STRADR(signal18);
   signalstr[19] := STRADR(signal19);
   signalstr[20] := STRADR(signal20);
   signalstr[21] := STRADR(signal21);
   signalstr[22] := STRADR(signal22);
   signalstr[23] := STRADR(signal23);
   signalstr[24] := STRADR(signal24);
   signalstr[25] := STRADR(signal25);
   signalstr[26] := STRADR(signal26);
   signalstr[27] := STRADR(signal27);
   signalstr[28] := STRADR(signal28);
   signalstr[29] := STRADR(signal29);
   signalstr[30] := STRADR(signal30);

   unknownstr[0] := STRADR(unknown0);
   unknownstr[1] := STRADR(unknown1);

   gemdoserr[6] := unknownstr[0];
   FOR i := 9 TO 13 DO
     gemdoserr[i] := unknownstr[0];
   END;
   gemdoserr[15] := unknownstr[0];
   FOR i := 18 TO 25 DO
     gemdoserr[i] := unknownstr[0];
   END;
   FOR i := 28 TO 31 DO
     gemdoserr[i] := unknownstr[0];
   END;
 END;
#else
 WITH messages DO
   FOR i := 0 TO 19 DO
     bioserr[i] := ADR(bios[i]);
   END;

   FOR i := 0 TO 5 DO
     gemdoserr[i] := ADR(gemdos[i]);
   END;
   gemdoserr[7]  := ADR(gemdos[6]);
   gemdoserr[8]  := ADR(gemdos[7]);
   gemdoserr[14] := ADR(gemdos[8]);
   gemdoserr[16] := ADR(gemdos[9]);
   gemdoserr[17] := ADR(gemdos[10]);
   gemdoserr[26] := ADR(gemdos[11]);
   gemdoserr[27] := ADR(gemdos[12]);
   gemdoserr[32] := ADR(gemdos[13]);
   gemdoserr[33] := ADR(gemdos[14]);
   gemdoserr[34] := ADR(gemdos[15]);
   gemdoserr[35] := ADR(gemdos[16]);
   gemdoserr[36] := ADR(gemdos[17]);
   gemdoserr[37] := ADR(gemdos[18]);
   gemdoserr[38] := ADR(gemdos[19]);

   minterr[0] := ADR(mint[0]);
   minterr[1] := ADR(mint[1]);

   FOR i := 0 TO 26 DO
     socketerr[i] := ADR(socket[i]);
   END;

   FOR i := 0 TO 14 DO
     posixerr[i] := ADR(posix[i]);
   END;

   FOR i := 0 TO 30 DO
     signalstr[i] := ADR(signal[i]);
   END;

   unknownstr[0] := ADR(unknown[0]);
   unknownstr[1] := ADR(unknown[1]);

   gemdoserr[6] := ADR(unknown[0]);
   FOR i := 9 TO 13 DO
     gemdoserr[i] := ADR(unknown[0]);
   END;
   gemdoserr[15] := ADR(unknown[0]);
   FOR i := 18 TO 25 DO
     gemdoserr[i] := ADR(unknown[0]);
   END;
   FOR i := 28 TO 31 DO
     gemdoserr[i] := ADR(unknown[0]);
   END;
 END;
#endif

 Numeric  := ADR(vnumeric);
 Monetary := ADR(vmonetary);
 Time     := ADR(time);
 Ctype    := CADR(vctype);
 Messages := ADR(messages);
END LCde.
