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
(* 27-Mai-94, Holger Kleinschmidt                                           *)
(****************************************************************************)

FROM SYSTEM IMPORT
(* PROC *) ADR;
#if (defined MM2)
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* TYPE *) UNSIGNEDWORD, SIGNEDWORD;

FROM types IMPORT
(* TYPE *) StrPtr;

FROM LCTypes IMPORT
(* TYPE *) LCTime, LCNumeric, LCMonetary, LCCtype, LCMessages,
           LCTimeP, LCNumericP, LCMonetaryP, LCCtypeP, LCMessagesP,
           CType, CClass, CClasses, CTrans;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  Vtime = RECORD
    Vabday     : ARRAY [0..6]  OF ARRAY [0..3] OF CHAR;
    Vday       : ARRAY [0..6]  OF ARRAY [0..9] OF CHAR;
    Vabmon     : ARRAY [0..11] OF ARRAY [0..3] OF CHAR;
    Vmon       : ARRAY [0..11] OF ARRAY [0..9] OF CHAR;
    Vampm      : ARRAY [0..1]  OF ARRAY [0..2] OF CHAR;
    Vdtfmt     : ARRAY [0..20] OF CHAR;
    Vdfmt      : ARRAY [0..3]  OF CHAR;
    Vtfmt      : ARRAY [0..3]  OF CHAR;
    Vtfmtampm  : ARRAY [0..3]  OF CHAR;
  END;

TYPE
  Vbioserr    = ARRAY [0..19] OF ARRAY [0..21] OF CHAR;
  Vgemdoserr  = ARRAY [0..16] OF ARRAY [0..27] OF CHAR;
  Vminterr    = ARRAY [0..1]  OF ARRAY [0..23] OF CHAR;
  Vsocketerr  = ARRAY [0..26] OF ARRAY [0..40] OF CHAR;
  Vposixerr   = ARRAY [0..15] OF ARRAY [0..23] OF CHAR;
  Vsignal     = ARRAY [0..30] OF ARRAY [0..31] OF CHAR;
  Vunknownerr = ARRAY [0..13] OF CHAR;
  Vunknownsig = ARRAY [0..14] OF CHAR;

#if ISO_value_constructor && (defined MM2)
CONST
 vtime = Vtime{
   {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"},
   {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
   {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"},
   {"January","February","March","April","May","June","July",
    "August","September","October","November","December"},
   {"AM","PM"},
   "%a %b %e %H:%M:%S %y",
   "%D",  (* <=> "%m/%d/%y" *)
   "%T",  (* <=> "%H:%M:%S" *)
   "%r"   (* <=> "%I:%M:%S %p" *)
 };
#else
VAR
  vtime : Vtime;
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
     CClass{}                                                 BY 128
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

 bios = Vbioserr{
   "OK",
   "Error",
   "Device not ready",
   "Unknown command",
   "Crc error",
   "Bad request",
   "Seek error",
   "Unknown media",
   "Sector not found",
   "Out of paper",
   "Write failure",
   "Read failure",
   "General error",
   "Write protected",
   "Media changed",
   "Unknown device",
   "Bad sectors found",
   "Another disk",
   "Insert media!",
   "Device not responding"
 };
 gemdos = Vgemdoserr{
   "Invalid function number",
   "File not found",
   "Path not found",
   "No more handles",
   "Access denied",
   "Invalid handle",
   "Out of memory",
   "Invalid memory block",
   "Invalid drive",
   "Different drives",
   "No more files",
   "File locked",
   "Invalid lock",
   "Range error",
   "Internal error",
   "Not executable",
   "Memory block growth failure"
 };
 mint = Vminterr{
   "Too many symbolic links",
   "Broken pipe"
 };
 socket = Vsocketerr{
   "Socket operation on non-socket",
   "Destination address required",
   "Message too long",
   "Protocol wrong type for socket",
   "Protocol not available",
   "Protocol not supported",
   "Socket type not supported",
   "Operation not supported",
   "Protocol family not supported",
   "Address family not supported by protocol",
   "Address already in use",
   "Cannot assign requested address",
   "Network is down",
   "Network is unreachable",
   "Network dropped conn. because of reset",
   "Software caused connection abort",
   "Connection reset by peer",
   "Socket is already connected",
   "Socket is not connected",
   "Cannot send after shutdown",
   "Connection timed out",
   "Connection refused",
   "Host is down",
   "No route to host",
   "Operation already in progress",
   "Operation now in progress",
   "Operation would block"
 };
 posix = Vposixerr{
   "Interrupted by signal",
   "Resource unavailable",
   "Deadlock would result",
   "Invalid argument",
   "File exists",
   "File too large",
   "Argument list too long",
   "Is a directory",
   "Too many links",
   "Filename too long",
   "No locks available",
   "No space left on device",
   "Directory not empty",
   "Wrong i/o control op",
   "Result too large",
   "Invalid seek"
 };
 signal = Vsignal{
   "No signal",
   "Hangup",
   "Interrupt",
   "Quit",
   "Illegal instruction",
   "Trace trap",
   "Abort",
   "Privilege violation",
   "Floating point exception",
   "Killed",
   "Bus error",
   "Segmentation fault",
   "Bad argument to system call",
   "Broken pipe",
   "Alarm clock",
   "Terminated",
   "Urgent condition on I/O channel",
   "Stopped (signal)",
   "Stopped",
   "Continued",
   "Child process exited",
   "Stopped (tty input)",
   "Stopped (tty output)",
   "I/O possible",
   "CPU limit exceeded",
   "File size limit exceeded",
   "Virtual timer alarm",
   "Profiling signal",
   "Window system signal",
   "User-defined signal 1",
   "User-defined signal 2"
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

BEGIN
 Vpoint    := ".";
 Vnull     := 0C;
 Vpointadr := ADR(Vpoint);
 Vnulladr  := ADR(Vnull);

#if ISO_value_constructor
 vnumeric := LCNumeric{Vpointadr,Vnulladr,Vnulladr};
#else
 WITH vnumeric DO
   decimalpoint := Vpointadr;
   thousandssep := Vnulladr;
   grouping     := Vnulladr;
 END;
#endif
 Numeric := ADR(vnumeric);

#if ISO_value_constructor
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
 Monetary := ADR(vmonetary);

#if !(ISO_value_constructor && (defined MM2))
#if ISO_value_constructor
 vtime := Vtime{
   {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"},
   {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
   {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"},
   {"January","February","March","April","May","June","July","August",
    "September","October","November","December"},
   {"AM","PM"},
   "%a %b %e %H:%M:%S %y",
   "%D",  (* <=> "%m/%d/%y" *)
   "%T",  (* <=> "%H:%M:%S" *)
   "%r"   (* <=> "%I:%M:%S %p" *)
 };
#else
 WITH vtime DO
   Vabday[0]  := "Sun";
   Vabday[1]  := "Mon";
   Vabday[2]  := "Tue";
   Vabday[3]  := "Wed";
   Vabday[4]  := "Thu";
   Vabday[5]  := "Fri";
   Vabday[6]  := "Sat";
   Vday[0]    := "Sunday";
   Vday[1]    := "Monday";
   Vday[2]    := "Tuesday";
   Vday[3]    := "Wednesday";
   Vday[4]    := "Thursday";
   Vday[5]    := "Friday";
   Vday[6]    := "Saturday";
   Vabmon[0]  := "Jan";
   Vabmon[1]  := "Feb";
   Vabmon[2]  := "Mar";
   Vabmon[3]  := "Apr";
   Vabmon[4]  := "May";
   Vabmon[5]  := "Jun";
   Vabmon[6]  := "Jul";
   Vabmon[7]  := "Aug";
   Vabmon[8]  := "Sep";
   Vabmon[9]  := "Oct";
   Vabmon[10] := "Nov";
   Vabmon[11] := "Dec";
   Vmon[0]    := "January";
   Vmon[1]    := "February";
   Vmon[2]    := "March";
   Vmon[3]    := "April";
   Vmon[4]    := "May";
   Vmon[5]    := "June";
   Vmon[6]    := "July";
   Vmon[7]    := "August";
   Vmon[8]    := "September";
   Vmon[9]    := "October";
   Vmon[10]   := "November";
   Vmon[11]   := "December";
   Vampm[0]   := "AM";
   Vampm[1]   := "PM";
   Vdtfmt     := "%a %b %e %H:%M:%S %Y";
   Vdfmt      := "%D";
   Vtfmt      := "%T";
   Vtfmtampm  := "%r";
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
   ampm[0]  := CADR(vtime.Vampm[0]);
   ampm[1]  := CADR(vtime.Vampm[1]);
   dtfmt    := CADR(vtime.Vdtfmt);
   dfmt     := CADR(vtime.Vdfmt);
   tfmt     := CADR(vtime.Vtfmt);
   tfmtampm := CADR(vtime.Vtfmtampm);
 END;
 Time := ADR(time);

 uerr := "Unknown error";
 usig := "Unknown signal";

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
     CClass{}                                                 BY 128
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

 bios := Vbioserr{
   "OK",
   "Error",
   "Device not ready",
   "Unknown command",
   "Crc error",
   "Bad request",
   "Seek error",
   "Unknown media",
   "Sector not found",
   "Out of paper",
   "Write failure",
   "Read failure",
   "General error",
   "Write protected",
   "Media changed",
   "Unknown device",
   "Bad sectors found",
   "Another disk",
   "Insert media!",
   "Device not responding"
 };
 gemdos := Vgemdoserr{
   "Invalid function number",
   "File not found",
   "Path not found",
   "No more handles",
   "Access denied",
   "Invalid handle",
   "Out of memory",
   "Invalid memory block",
   "Invalid drive",
   "Different drives",
   "No more files",
   "File locked",
   "Invalid lock",
   "Range error",
   "Internal error",
   "Not executable",
   "Memory block growth failure"
 };
 mint := Vminterr{
   "Too many symbolic links",
   "Broken pipe"
 };
 socket := Vsocketerr{
   "Socket operation on non-socket",
   "Destination address required",
   "Message too long",
   "Protocol wrong type for socket",
   "Protocol not available",
   "Protocol not supported",
   "Socket type not supported",
   "Operation not supported",
   "Protocol family not supported",
   "Address family not supported by protocol",
   "Address already in use",
   "Cannot assign requested address",
   "Network is down",
   "Network is unreachable",
   "Network dropped conn. because of reset",
   "Software caused connection abort",
   "Connection reset by peer",
   "Socket is already connected",
   "Socket is not connected",
   "Cannot send after shutdown",
   "Connection timed out",
   "Connection refused",
   "Host is down",
   "No route to host",
   "Operation already in progress",
   "Operation now in progress",
   "Operation would block"
 };
 posix := Vposixerr{
   "Interrupted by signal",
   "Resource unavailable",
   "Deadlock would result",
   "Invalid argument",
   "File exists",
   "File too large",
   "Argument list too long",
   "Is a directory",
   "Too many links",
   "Filename too long",
   "No locks available",
   "No space left on device",
   "Directory not empty",
   "Wrong i/o control op",
   "Result too large",
   "Invalid seek"
 };
 signal := Vsignal{
   "No signal",
   "Hangup",
   "Interrupt",
   "Quit",
   "Illegal instruction",
   "Trace trap",
   "Abort",
   "Privilege violation",
   "Floating point exception",
   "Killed",
   "Bus error",
   "Segmentation fault",
   "Bad argument to system call",
   "Broken pipe",
   "Alarm clock",
   "Terminated",
   "Urgent condition on I/O channel",
   "Stopped (signal)",
   "Stopped",
   "Continued",
   "Child process exited",
   "Stopped (tty input)",
   "Stopped (tty output)",
   "I/O possible",
   "CPU limit exceeded",
   "File size limit exceeded",
   "Virtual timer alarm",
   "Profiling signal",
   "Window system signal",
   "User-defined signal 1",
   "User-defined signal 2"
 };
#else
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
   FOR c := '0' TO '9' DO
     class[c] := CClass{ISdigit,ISxdigit,ISalnum,ISgraph,ISprint};
   END;
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

 bios[0]  := "OK";
 bios[1]  := "Error";
 bios[2]  := "Device not ready";
 bios[3]  := "Unknown command";
 bios[4]  := "Crc error";
 bios[5]  := "Bad request";
 bios[6]  := "Seek error";
 bios[7]  := "Unknown media";
 bios[8]  := "Sector not found";
 bios[9]  := "Out of paper";
 bios[10] := "Write failure";
 bios[11] := "Read failure";
 bios[12] := "General error";
 bios[13] := "Write protected";
 bios[14] := "Media changed";
 bios[15] := "Unknown device";
 bios[16] := "Bad sectors found";
 bios[17] := "Another disk";
 bios[18] := "Insert media!";
 bios[19] := "Device not responding";

 gemdos[0]  := "Invalid function number";
 gemdos[1]  := "File not found";
 gemdos[2]  := "Path not found";
 gemdos[3]  := "No more handles";
 gemdos[4]  := "Access denied";
 gemdos[5]  := "Invalid handle";
 gemdos[6]  := "Out of memory";
 gemdos[7]  := "Invalid memory block";
 gemdos[8]  := "Invalid drive";
 gemdos[9]  := "Different drives";
 gemdos[10] := "No more files";
 gemdos[11] := "File locked";
 gemdos[12] := "Invalid lock";
 gemdos[13] := "Range error";
 gemdos[14] := "Internal error";
 gemdos[15] := "Not executable";
 gemdos[16] := "Memory block growth failure";

 mint[0] := "Too many symbolic links";
 mint[1] := "Broken pipe";

 socket[0]  := "Socket operation on non-socket";
 socket[1]  := "Destination address required";
 socket[2]  := "Message too long";
 socket[3]  := "Protocol wrong type for socket";
 socket[4]  := "Protocol not available";
 socket[5]  := "Protocol not supported";
 socket[6]  := "Socket type not supported";
 socket[7]  := "Operation not supported";
 socket[8]  := "Protocol family not supported";
 socket[9]  := "Address family not supported by protocol";
 socket[10] := "Address already in use";
 socket[11] := "Cannot assign requested address";
 socket[12] := "Network is down";
 socket[13] := "Network is unreachable";
 socket[14] := "Network dropped conn. because of reset";
 socket[15] := "Software caused connection abort";
 socket[16] := "Connection reset by peer";
 socket[17] := "Socket is already connected";
 socket[18] := "Socket is not connected";
 socket[19] := "Cannot send after shutdown";
 socket[20] := "Connection timed out";
 socket[21] := "Connection refused";
 socket[22] := "Host is down";
 socket[23] := "No route to host";
 socket[24] := "Operation already in progress";
 socket[25] := "Operation now in progress";
 socket[26] := "Operation would block";

 posix[0]  := "Interrupted by signal";
 posix[1]  := "Resource unavailable";
 posix[2]  := "Deadlock would result";
 posix[3]  := "Invalid argument";
 posix[4]  := "File exists";
 posix[5]  := "File too large";
 posix[6]  := "Argument list too long";
 posix[7]  := "Is a directory";
 posix[8]  := "Too many links";
 posix[9]  := "Filename too long";
 posix[10] := "No locks available";
 posix[11] := "No space left on device";
 posix[12] := "Directory not empty";
 posix[13] := "Wrong i/o control op";
 posix[14] := "Result too large";
 posix[15] := "Invalid seek";

 signal[0]  := "No signal";
 signal[1]  := "Hangup";
 signal[2]  := "Interrupt";
 signal[3]  := "Quit";
 signal[4]  := "Illegal instruction";
 signal[5]  := "Trace trap";
 signal[6]  := "Abort";
 signal[7]  := "Privilege violation";
 signal[8]  := "Floating point exception";
 signal[9]  := "Killed";
 signal[10] := "Bus error";
 signal[11] := "Segmentation fault";
 signal[12] := "Bad argument to system call";
 signal[13] := "Broken pipe";
 signal[14] := "Alarm clock";
 signal[15] := "Terminated";
 signal[16] := "Urgent condition on I/O channel";
 signal[17] := "Stopped (signal)";
 signal[18] := "Stopped";
 signal[19] := "Continued";
 signal[20] := "Child process exited";
 signal[21] := "Stopped (tty input)";
 signal[22] := "Stopped (tty output)";
 signal[23] := "I/O possible";
 signal[24] := "CPU limit exceeded";
 signal[25] := "File size limit exceeded";
 signal[26] := "Virtual timer alarm";
 signal[27] := "Profiling signal";
 signal[28] := "Window system signal";
 signal[29] := "User-defined signal 1";
 signal[30] := "User-defined signal 2";
#endif
#endif

 Ctype := CADR(vctype);

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
END LCPOSIX.
