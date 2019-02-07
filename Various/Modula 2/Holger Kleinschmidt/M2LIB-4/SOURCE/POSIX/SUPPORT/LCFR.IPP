IMPLEMENTATION MODULE LCfr;
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
(* 29-Apr-96, Ulrich Kaiser & Holger Kleinschmidt                           *)
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
  intCurrSymbol   = "FRF ";
  currencySymbol  = "F";
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
/* Laengster String: 3 Zeichen */
#define abday0 "dim"
#define abday1 "lun"
#define abday2 "mar"
#define abday3 "mer"
#define abday4 "jeu"
#define abday5 "ven"
#define abday6 "sam"

/* Laengster String: 8 Zeichen */
#define day0 "dimanche"
#define day1 "lundi"
#define day2 "mardi"
#define day3 "mercredi"
#define day4 "jeudi"
#define day5 "vendredi"
#define day6 "samedi"

/* Laengster String: 3 Zeichen */
#define abmon0 "jan"
#define abmon1 "fÇv"
#define abmon2 "mar"
#define abmon3 "avr"
#define abmon4 "mai"
#define abmon5 "jui"
#define abmon6 "jui"
#define abmon7 "aoñ"
#define abmon8 "sep"
#define abmon9 "oct"
#define abmon10 "nov"
#define abmon11 "dÇc"

/* Laengster String: 9 Zeichen */
#define mon0 "janvier"
#define mon1 "fÇvrier"
#define mon2 "mars"
#define mon3 "avril"
#define mon4 "mai"
#define mon5 "juin"
#define mon6 "juillet"
#define mon7 "aoñt"
#define mon8 "septembre"
#define mon9 "octobre"
#define mon10 "novembre"
#define mon11 "dÇcembre"

#define amstr ""
#define pmstr ""

#define dtfmtstr "%a %b %e %H:%M:%S %y"
#define dfmtstr "%D"
#define tfmtstr "%T"
#define tfmtampmstr ""

#else /* !(defined HM2) */

CONST (* Laengster String: 3 Zeichen *)
  abday0 = "dim";
  abday1 = "lun";
  abday2 = "mar";
  abday3 = "mer";
  abday4 = "jeu";
  abday5 = "ven";
  abday6 = "sam";

CONST (* Laengster String: 8 Zeichen *)
  day0 = "dimanche";
  day1 = "lundi";
  day2 = "mardi";
  day3 = "mercredi";
  day4 = "jeudi";
  day5 = "vendredi";
  day6 = "samedi";

CONST (* Laengster String: 3 Zeichen *)
  abmon0 = "jan";
  abmon1 = "fÇv";
  abmon2 = "mar";
  abmon3 = "avr";
  abmon4 = "mai";
  abmon5 = "jui";
  abmon6 = "jui";
  abmon7 = "aoñ";
  abmon8 = "sep";
  abmon9 = "oct";
  abmon10 = "nov";
  abmon11 = "dÇc";

CONST (* Laengster String: 9 Zeichen *)
  mon0 = "janvier";
  mon1 = "fÇvrier";
  mon2 = "mars";
  mon3 = "avril";
  mon4 = "mai";
  mon5 = "juin";
  mon6 = "juillet";
  mon7 = "aoñt";
  mon8 = "septembre";
  mon9 = "octobre";
  mon10 = "novembre";
  mon11 = "dÇcembre";

CONST
  amstr = "AM";
  pmstr = "PM";

CONST
  dtfmtstr = "%a %b %e %H:%M:%S %y";
  dfmtstr = "%D";
  tfmtstr = "%T";
  tfmtampmstr = "%r";
#endif

CONST (* Laengster String: 29 Zeichen *)
  bios0 = "OK";
  bios1 = "erreur";
  bios2 = "appareil pas pràt";
  bios3 = "commande inconnue";
  bios4 = "erreur de crc";
  bios5 = "mauvaise demande";
  bios6 = "erreur de seek";
  bios7 = "medium inconnu";
  bios8 = "secteur pas trouvÇ";
  bios9 = "pas de papier";
  bios10 = "erreur d'Çcriture";
  bios11 = "erreur de lecture";
  bios12 = "erreur gÇnÇral";
  bios13 = "protection d'Çcriture";
  bios14 = "medium changÇ";
  bios15 = "appareil inconnu";
  bios16 = "trouvÇ des mauvaises secteurs";
  bios17 = "autre disque";
  bios18 = "introduire un medium!";
  bios19 = "appareil ne rÇpond pas";

CONST (* Laengster String: 33 Zeichen *)
  gemdos0 = "nombre de fonction non valable";
  gemdos1 = "fichier pas trouvÇ";
  gemdos2 = "chemin pas trouvÇ";
  gemdos3 = "plus d'identifiers de fichier";
  gemdos4 = "accäs refusÇ";
  gemdos5 = "identifier de fichier non valable";
  gemdos7 = "pas de mÇmoire";
  gemdos8 = "adresse de mÇmoire non valable";
  gemdos14 = "invalid drive";
  gemdos16 = "different drives";
  gemdos17 = "plus de fichiers";
  gemdos26 = "fichier protegÇ par lock";
  gemdos27 = "lock non valable";
  gemdos32 = "paramätre non valable";
  gemdos33 = "erreur intern";
  gemdos34 = "pas ÇxÇcutable";
  gemdos35 = "memory block growth failure";
  gemdos36 = "Program aborted by user";
  gemdos37 = "Program aborted due to exception";
  gemdos38 = "Path overflow";

CONST (* Laengster String: 32 Zeichen *)
  mint0 = "trop beaucoup de links symbolics";
  mint1 = "pipe cassÇ";

CONST (* Laengster String: 40 Zeichen *)
  socket0 = "opÇration de socket sur non-socket";
  socket1 = "adresse de dÇpart necessaire";
  socket2 = "message trop long";
  socket3 = "faux type de potocol pour socket";
  socket4 = "protocol inexistant";
  socket5 = "protocol pas assistÇ";
  socket6 = "type de socket pas assistÇ";
  socket7 = "opÇration pas assistÇ";
  socket8 = "Protocol family not supported";
  socket9 = "Address family not supported by protocol";
  socket10 = "Address already in use";
  socket11 = "Cannot assign requested address";
  socket12 = "rÇseau pas actif";
  socket13 = "Network is unreachable";
  socket14 = "Network dropped conn. because of reset";
  socket15 = "Software caused connection abort";
  socket16 = "Connection reset by peer";
  socket17 = "socket est dÇjÖ reliÇ";
  socket18 = "socket n'est pas reliÇ";
  socket19 = "plus d'Çmission possible apräs shutdown";
  socket20 = "time-out durant connexion";
  socket21 = "connexion refusÇ";
  socket22 = "dÇpart pas actif";
  socket23 = "pas de route Ö l'host";
  socket24 = "Operation already in progress";
  socket25 = "Operation now in progress";
  socket26 = "Operation would block";

CONST (* Laengster String: 44 Zeichen *)
  posix0 = "interrompu par signal";
  posix1 = "Resource unavailable";
  posix2 = "Deadlock would result";
  posix3 = "fichier dÇjÖ existe";
  posix4 = "fichier trop long";
  posix5 = "trop beaucoup des paramätres";
  posix6 = "est un dossier";
  posix7 = "trop beaucoup de links";
  posix8 = "nom de fichier trop long";
  posix9 = "pas de locks atteignable";
  posix10 = "plus de place libre sur l'appareil";
  posix11 = "dossier pas vide";
  posix12 = "fausse opÇration de contrìle d'entrÇe/sortie";
  posix13 = "rÇsultat trop ÇlevÇ";
  posix14 = "seek non valable";

CONST (* Laengster String: 45 Zeichen *)
  signal0 = "pas de signal";
  signal1 = "Hangup";
  signal2 = "interruption";
  signal3 = "quit";
  signal4 = "instruction illegale";
  signal5 = "trace trap";
  signal6 = "abort";
  signal7 = "privilege violation";
  signal8 = "exception de point de flottement";
  signal9 = "tuÇ";
  signal10 = "erreur de bus";
  signal11 = "segmentation fault";
  signal12 = "Bad argument to system call";
  signal13 = "pipe cassÇ";
  signal14 = "temps de timeout passÇ";
  signal15 = "terminÇ";
  signal16 = "situation urgent sur un canal d'entrÇe/sortie";
  signal17 = "Stopped (signal)";
  signal18 = "Stopped";
  signal19 = "continuÇ";
  signal20 = "processus d'enfant terminÇ";
  signal21 = "processus interrompu (entrÇe du terminal)";
  signal22 = "processus interrompu (sortie du terminal)";
  signal23 = "entrÇe/sortie possible";
  signal24 = "CPU limit exceeded";
  signal25 = "File size limit exceeded";
  signal26 = "Virtual timer alarm";
  signal27 = "signal pour le profilage";
  signal28 = "signal du systäme de fenàtre";
  signal29 = "signal defini par l'utilisateur 1";
  signal30 = "signal defini par l'utilisateur 2";

CONST (* Laengster String: 15 Zeichen *)
  unknown0 = "erreur inconnue";
  unknown1 = "signal inconnu";


TYPE
  VNumeric = RECORD
    Vdecimalpoint : ARRAY [0..1] OF CHAR;
    Vthousandssep : ARRAY [0..1] OF CHAR;
    Vgrouping     : ARRAY [0..1] OF CHAR;
  END;

  VMonetary = RECORD
    Vintcurrsymbol   : ARRAY [0..4] OF CHAR;
    Vcurrencysymbol  : ARRAY [0..1] OF CHAR;
    Vmondecimalpoint : ARRAY [0..1] OF CHAR;
    Vmonthousandssep : ARRAY [0..1] OF CHAR;
    Vmongrouping     : ARRAY [0..1] OF CHAR;
    Vpositivesign    : ARRAY [0..0] OF CHAR;
    Vnegativesign    : ARRAY [0..1] OF CHAR;
  END;

#if (defined HM2)
TYPE
  VTime = RECORD
    Vabday    : ARRAY [0..6]  OF ARRAY [0..3] OF CHAR;
    Vday      : ARRAY [0..6]  OF ARRAY [0..8] OF CHAR;
    Vabmon    : ARRAY [0..11] OF ARRAY [0..3] OF CHAR;
    Vmon      : ARRAY [0..11] OF ARRAY [0..9] OF CHAR;
    Vampm     : ARRAY [0..1]  OF ARRAY [0..2] OF CHAR;
    Vdtfmt    : ARRAY [0..20] OF CHAR;
    Vdfmt     : ARRAY [0..2] OF CHAR;
    Vtfmt     : ARRAY [0..2] OF CHAR;
    Vtfmtampm : ARRAY [0..2] OF CHAR;
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

     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* Ä *)
     CClass{ISgraph,ISprint}                                   BY 1,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* Ç *)
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* É *)
     CClass{ISgraph,ISprint}                                   BY 1,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* Ö *)
     CClass{ISgraph,ISprint}                                   BY 1,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* á *)
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* à *)
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* â *)
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ä *)
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ã *)
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* å *)
     CClass{ISgraph,ISprint}                                   BY 3,
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ê *)
     CClass{ISgraph,ISprint}                                   BY 2,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ì *)
     CClass{ISgraph,ISprint}                                   BY 2,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ñ *)
     CClass{ISgraph,ISprint}                                   BY 29,
     CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* ¥ *)
     CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}           BY 1, (* µ *)
     CClass{ISgraph,ISprint}                                   BY 74
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
     130C,131C,132C,173C,174C,175C,176C,177C,200C,201C,
     220C,203C,204C,205C,206C,200C,210C,211C,212C,213C,
     214C,215C,216C,217C,220C,221C,222C,223C,224C,225C,
     226C,227C,230C,231C,232C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     265C,265C,266C,267C,270C,271C,272C,273C,274C,275C,
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
     170C,171C,172C,173C,174C,175C,176C,177C,207C,201C,
     202C,203C,204C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,216C,217C,202C,221C,222C,223C,224C,225C,
     226C,227C,230C,231C,232C,233C,234C,235C,236C,237C,
     240C,241C,242C,243C,244C,245C,246C,247C,250C,251C,
     252C,253C,254C,255C,256C,257C,260C,261C,262C,263C,
     264C,264C,266C,267C,270C,271C,272C,273C,274C,275C,
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
  Vbioserr   = ARRAY [0..19] OF ARRAY [0..29] OF CHAR;
  Vgemdoserr = ARRAY [0..19] OF ARRAY [0..33] OF CHAR;
  Vminterr   = ARRAY [0..1]  OF ARRAY [0..32] OF CHAR;
  Vsocketerr = ARRAY [0..26] OF ARRAY [0..40] OF CHAR;
  Vposixerr  = ARRAY [0..14] OF ARRAY [0..44] OF CHAR;
  Vsignal    = ARRAY [0..30] OF ARRAY [0..45] OF CHAR;
  Vunknown   = ARRAY [0..1]  OF ARRAY [0..15] OF CHAR;

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

BEGIN (* LCfr *)
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

   class[200C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* Ä *)
   class[202C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* Ç *)
   class[203C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* É *)
   class[205C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* Ö *)
   class[207C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* á *)
   class[210C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* à *)
   class[211C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* â *)
   class[212C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ä *)
   class[213C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ã *)
   class[214C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* å *)
   class[220C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* ê *)
   class[223C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ì *)
   class[226C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ñ *)
   class[264C] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint}; (* ¥ *)
   class[265C] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint}; (* µ *)

   toupper       := LCPOSIX.Ctype^.toupper;
   toupper[202C] := 220C;
   toupper[207C] := 200C;
   toupper[264C] := 265C;
   tolower       := LCPOSIX.Ctype^.tolower;
   tolower[200C] := 207C;
   tolower[220C] := 202C;
   tolower[265C] := 264C;
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
END LCfr.
