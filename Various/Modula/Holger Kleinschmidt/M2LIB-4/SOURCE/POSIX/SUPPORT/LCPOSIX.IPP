IMPLEMENTATION MODULE LCPOSIX;
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
(* 08-Sep-95, Holger Kleinschmidt                                           *)
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

FROM types IMPORT
(* TYPE *) StrPtr;

FROM LCTypes IMPORT
(* TYPE *) LCTime, LCNumeric, LCMonetary, LCCtype, LCMessages,
           LCTimeP, LCNumericP, LCMonetaryP, LCCtypeP, LCMessagesP,
           CType, CClass, CClasses, CTrans;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#if (defined LPRM2) || (defined SPCM2)
#  define STRADR(_s) ADR(_s)
#elif (defined MM2)
#  define STRADR(_s) CADR(_s)
#endif

#if (defined HM2)
/* Laengster String: 3 Zeichen */
#define abday0 "Sun"
#define abday1 "Mon"
#define abday2 "Tue"
#define abday3 "Wed"
#define abday4 "Thu"
#define abday5 "Fri"
#define abday6 "Sat"

/* Laengster String: 9 Zeichen */
#define day0 "Sunday"
#define day1 "Monday"
#define day2 "Tuesday"
#define day3 "Wednesday"
#define day4 "Thursday"
#define day5 "Friday"
#define day6 "Saturday"

/* Laengster String: 3 Zeichen */
#define abmon0 "Jan"
#define abmon1 "Feb"
#define abmon2 "Mar"
#define abmon3 "Apr"
#define abmon4 "May"
#define abmon5 "Jun"
#define abmon6 "Jul"
#define abmon7 "Aug"
#define abmon8 "Sep"
#define abmon9 "Oct"
#define abmon10 "Nov"
#define abmon11 "Dec"

/* Laengster String: 9 Zeichen */
#define mon0 "January"
#define mon1 "February"
#define mon2 "March"
#define mon3 "April"
#define mon4 "May"
#define mon5 "June"
#define mon6 "July"
#define mon7 "August"
#define mon8 "September"
#define mon9 "October"
#define mon10 "November"
#define mon11 "December"

#define amstr "AM"
#define pmstr "PM"

#define dtfmtstr "%a %b %e %H:%M:%S %y"
#define dfmtstr "%D"
#define tfmtstr "%T"
#define tfmtampmstr "%r"

#else /* !(defined HM2) */

CONST (* Laengster String: 3 Zeichen *)
  abday0 = "Sun";
  abday1 = "Mon";
  abday2 = "Tue";
  abday3 = "Wed";
  abday4 = "Thu";
  abday5 = "Fri";
  abday6 = "Sat";

CONST (* Laengster String: 9 Zeichen *)
  day0 = "Sunday";
  day1 = "Monday";
  day2 = "Tuesday";
  day3 = "Wednesday";
  day4 = "Thursday";
  day5 = "Friday";
  day6 = "Saturday";

CONST (* Laengster String: 3 Zeichen *)
  abmon0 = "Jan";
  abmon1 = "Feb";
  abmon2 = "Mar";
  abmon3 = "Apr";
  abmon4 = "May";
  abmon5 = "Jun";
  abmon6 = "Jul";
  abmon7 = "Aug";
  abmon8 = "Sep";
  abmon9 = "Oct";
  abmon10 = "Nov";
  abmon11 = "Dec";

CONST (* Laengster String: 9 Zeichen *)
  mon0 = "January";
  mon1 = "February";
  mon2 = "March";
  mon3 = "April";
  mon4 = "May";
  mon5 = "June";
  mon6 = "July";
  mon7 = "August";
  mon8 = "September";
  mon9 = "October";
  mon10 = "November";
  mon11 = "December";

CONST
  amstr = "AM";
  pmstr = "PM";

CONST
  dtfmtstr = "%a %b %e %H:%M:%S %y";
  dfmtstr = "%D";
  tfmtstr = "%T";
  tfmtampmstr = "%r";
#endif

CONST (* Laengster String: 21 Zeichen *)
  bios0 = "OK";
  bios1 = "Error";
  bios2 = "Device not ready";
  bios3 = "Unknown command";
  bios4 = "Crc error";
  bios5 = "Bad request";
  bios6 = "Seek error";
  bios7 = "Unknown media";
  bios8 = "Sector not found";
  bios9 = "Out of paper";
  bios10 = "Write failure";
  bios11 = "Read failure";
  bios12 = "General error";
  bios13 = "Write protected";
  bios14 = "Media changed";
  bios15 = "Unknown device";
  bios16 = "Bad sectors found";
  bios17 = "Another disk";
  bios18 = "Insert media!";
  bios19 = "Device not responding";

CONST (* Laengster String: 32 Zeichen *)
  gemdos0 = "Invalid function number";
  gemdos1 = "File not found";
  gemdos2 = "Not a directory";
  gemdos3 = "No more handles";
  gemdos4 = "Access denied";
  gemdos5 = "Invalid handle";
  gemdos7 = "Out of memory";
  gemdos8 = "Invalid memory block";
  gemdos14 = "Invalid drive";
  gemdos16 = "Different drives";
  gemdos17 = "No more files";
  gemdos26 = "File locked";
  gemdos27 = "Invalid lock";
  gemdos32 = "Invalid argument";
  gemdos33 = "Internal error";
  gemdos34 = "Not executable";
  gemdos35 = "Memory block growth failure";
  gemdos36 = "Program aborted by user";
  gemdos37 = "Program aborted due to exception";
  gemdos38 = "Path overflow";

CONST (* Laengster String: 23 Zeichen *)
  mint0 = "Too many symbolic links";
  mint1 = "Broken pipe";

CONST (* Laengster String: 40 Zeichen *)
  socket0 = "Socket operation on non-socket";
  socket1 = "Destination address required";
  socket2 = "Message too long";
  socket3 = "Protocol wrong type for socket";
  socket4 = "Protocol not available";
  socket5 = "Protocol not supported";
  socket6 = "Socket type not supported";
  socket7 = "Operation not supported";
  socket8 = "Protocol family not supported";
  socket9 = "Address family not supported by protocol";
  socket10 = "Address already in use";
  socket11 = "Cannot assign requested address";
  socket12 = "Network is down";
  socket13 = "Network is unreachable";
  socket14 = "Network dropped conn. because of reset";
  socket15 = "Software caused connection abort";
  socket16 = "Connection reset by peer";
  socket17 = "Socket is already connected";
  socket18 = "Socket is not connected";
  socket19 = "Cannot send after shutdown";
  socket20 = "Connection timed out";
  socket21 = "Connection refused";
  socket22 = "Host is down";
  socket23 = "No route to host";
  socket24 = "Operation already in progress";
  socket25 = "Operation now in progress";
  socket26 = "Operation would block";

CONST (* Laengster String: 23 Zeichen *)
  posix0 = "Interrupted by signal";
  posix1 = "Resource unavailable";
  posix2 = "Deadlock would result";
  posix3 = "File exists";
  posix4 = "File too large";
  posix5 = "Argument list too long";
  posix6 = "Is a directory";
  posix7 = "Too many links";
  posix8 = "Filename too long";
  posix9 = "No locks available";
  posix10 = "No space left on device";
  posix11 = "Directory not empty";
  posix12 = "Wrong i/o control op";
  posix13 = "Result too large";
  posix14 = "Invalid seek";

CONST (* Laengster String: 31 Zeichen *)
  signal0 = "No signal";
  signal1 = "Hangup";
  signal2 = "Interrupt";
  signal3 = "Quit";
  signal4 = "Illegal instruction";
  signal5 = "Trace trap";
  signal6 = "Abort";
  signal7 = "Privilege violation";
  signal8 = "Floating point exception";
  signal9 = "Killed";
  signal10 = "Bus error";
  signal11 = "Segmentation fault";
  signal12 = "Bad argument to system call";
  signal13 = "Broken pipe";
  signal14 = "Alarm clock";
  signal15 = "Terminated";
  signal16 = "Urgent condition on I/O channel";
  signal17 = "Stopped (signal)";
  signal18 = "Stopped";
  signal19 = "Continued";
  signal20 = "Child process exited";
  signal21 = "Stopped (tty input)";
  signal22 = "Stopped (tty output)";
  signal23 = "I/O possible";
  signal24 = "CPU limit exceeded";
  signal25 = "File size limit exceeded";
  signal26 = "Virtual timer alarm";
  signal27 = "Profiling signal";
  signal28 = "Window system signal";
  signal29 = "User-defined signal 1";
  signal30 = "User-defined signal 2";

CONST (* Laengster String: 14 Zeichen *)
  unknown0 = "Unknown error";
  unknown1 = "Unknown signal";


#if (defined HM2)
TYPE
  Vtime = RECORD
    Vabday    : ARRAY [0..6]  OF ARRAY [0..3] OF CHAR;
    Vday      : ARRAY [0..6]  OF ARRAY [0..9] OF CHAR;
    Vabmon    : ARRAY [0..11] OF ARRAY [0..3] OF CHAR;
    Vmon      : ARRAY [0..11] OF ARRAY [0..9] OF CHAR;
    Vampm     : ARRAY [0..1]  OF ARRAY [0..2] OF CHAR;
    Vdtfmt    : ARRAY [0..20] OF CHAR;
    Vdfmt     : ARRAY [0..2]  OF CHAR;
    Vtfmt     : ARRAY [0..2]  OF CHAR;
    Vtfmtampm : ARRAY [0..2]  OF CHAR;
  END;

VAR
  vtime : Vtime;
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
     CClass{}                                                  BY 128
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
     202C,203C,204C,205C,206C,207C,210C,211C,212C,213C,
     214C,215C,216C,217C,220C,221C,222C,223C,224C,225C,
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
     214C,215C,216C,217C,220C,221C,222C,223C,224C,225C,
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
   }
 };
#else
VAR
  vctype : LCCtype;
#endif

#if (defined HM2)
TYPE
  Vbioserr   = ARRAY [0..19] OF ARRAY [0..21] OF CHAR;
  Vgemdoserr = ARRAY [0..19] OF ARRAY [0..32] OF CHAR;
  Vminterr   = ARRAY [0..1]  OF ARRAY [0..23] OF CHAR;
  Vsocketerr = ARRAY [0..26] OF ARRAY [0..40] OF CHAR;
  Vposixerr  = ARRAY [0..14] OF ARRAY [0..23] OF CHAR;
  Vsignal    = ARRAY [0..30] OF ARRAY [0..31] OF CHAR;
  Vunknown   = ARRAY [0..1]  OF ARRAY [0..14] OF CHAR;

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
  time      : LCTime;
  vmonetary : LCMonetary;
  vnumeric  : LCNumeric;
  messages  : LCMessages;

VAR
  Vpoint    : ARRAY [0..1] OF CHAR;
  Vpointadr : StrPtr;

VAR
  Vnull    : CHAR;
  Vnulladr : StrPtr;

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

BEGIN (* LCPOSIX *)
 Vpoint    := ".";
 Vnull     := 0C;
 Vpointadr := ADR(Vpoint);
 Vnulladr  := ADR(Vnull);

#if (defined MM2) || (defined HM2)
 vnumeric := LCNumeric{Vpointadr,Vnulladr,Vnulladr};
#else
 WITH vnumeric DO
   decimalpoint := Vpointadr;
   thousandssep := Vnulladr;
   grouping     := Vnulladr;
 END;
#endif

#if (defined MM2) || (defined HM2)
 vmonetary := LCMonetary{Vnulladr,Vnulladr,Vnulladr,Vnulladr,Vnulladr,
                         Vnulladr,Vnulladr, -1,-1,-1,-1,-1,-1,-1,-1};
#else
 WITH vmonetary DO
   intcurrsymbol   := Vnulladr;
   currencysymbol  := Vnulladr;
   mondecimalpoint := Vnulladr;
   monthousandssep := Vnulladr;
   mongrouping     := Vnulladr;
   positivesign    := Vnulladr;
   negativesign    := Vnulladr;

   intfracdigits   := -1;
   fracdigits      := -1;
   pcsprecedes     := -1;
   psepbyspace     := -1;
   ncsprecedes     := -1;
   nsepbyspace     := -1;
   psignposn       := -1;
   nsignposn       := -1;
 END;
#endif

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
 vtime := Vtime{
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
   FOR c := 0C TO 10C DO
     class[c] := CClass{IScntrl};
   END;
   class[11C] := CClass{IScntrl,ISspace,ISblank};
   FOR c := 12C TO 15C DO
     class[c] := CClass{IScntrl,ISspace};
   END;
   FOR c := 16C TO 37C DO
     class[c] := CClass{IScntrl};
   END;
   class[' '] := CClass{ISspace,ISblank,ISprint};
   FOR c := 41C TO 57C DO
     class[c] := CClass{ISpunct,ISgraph,ISprint};
   END;
   FOR c := '0' TO '7' DO
     class[c] := CClass{ISdigit,ISodigit,ISxdigit,ISalnum,ISgraph,ISprint};
   END;
   class['8'] := CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint};
   class['9'] := CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint};
   FOR c := 72C TO 100C DO
     class[c] := CClass{ISpunct,ISgraph,ISprint};
   END;
   FOR c := 'A' TO 'F' DO
     class[c] := CClass{ISxdigit,ISupper,ISalpha,ISalnum,ISgraph,ISprint};
   END;
   FOR c := 'G' TO 'Z' DO
     class[c] := CClass{ISupper,ISalpha,ISalnum,ISgraph,ISprint};
   END;
   FOR c := 133C TO 140C DO
     class[c] := CClass{ISpunct,ISgraph,ISprint};
   END;
   FOR c := 'a' TO 'f' DO
     class[c] := CClass{ISxdigit,ISlower,ISalpha,ISalnum,ISgraph,ISprint};
   END;
   FOR c := 'g' TO 'z' DO
     class[c] := CClass{ISlower,ISalpha,ISalnum,ISgraph,ISprint};
   END;
   FOR c := 173C TO 176C DO
     class[c] := CClass{ISpunct,ISgraph,ISprint};
   END;
   class[177C] := CClass{IScntrl};
   FOR c := 200C TO 377C DO
     class[c] := CClass{};
   END;

   FOR c := 0C TO 140C DO
     toupper[c] := c;
   END;
   FOR c := 141C TO 172C DO
     toupper[c] := CHR(ORD(c) - 32);
   END;
   FOR c := 173C TO 377C DO
     toupper[c] := c;
   END;
   FOR c := 0C TO 100C DO
     tolower[c] := c;
   END;
   FOR c := 101C TO 132C DO
     tolower[c] := CHR(ORD(c) + 32);
   END;
   FOR c := 133C TO 377C DO
     tolower[c] := c;
   END;
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
END LCPOSIX.
