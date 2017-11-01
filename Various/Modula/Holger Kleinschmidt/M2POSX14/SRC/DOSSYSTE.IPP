IMPLEMENTATION MODULE DosSystem;
__IMP_SWITCHES__
__DRIVER__ (* evtl. unnoetig? *)
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
(*****************************************************************************)
(* 18-Mai-94, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
OSCALL_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) ANYBYTE, SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG,
           WORDSET;

IMPORT e;

FROM types IMPORT
(* TYPE *) sizeT, StrPtr;

FROM OSCALLS IMPORT
(* PROC *) Pdomain, Supexec, Sversion, Setexc, Fcntl, Dgetcwd, Dpathconf,
           Sysconf;

FROM MEMBLK IMPORT
(* PROC *) memmove;

#if (defined LPRM2)
IMPORT GEMX;
#elif (defined SPCM2)
IMPORT GEMDOS;
#elif (defined MM2)
IMPORT PrgCtrl;
#elif (defined HM2)
IMPORT TOS;
/*
#elif (defined HM2_OLD)
IMPORT System;
*/
#elif (defined TDIM2)
IMPORT GEMX;
#elif (defined FTLM2)
IMPORT LOADER;
#endif


#define PSHL 2F00H
#define JSRA0 4E90H
#define ADDQ4 588FH
#define CALLSHELL(_CMD,_SHELL)\
 SETREG(0,_CMD);SETREG(8,_SHELL);CODE(PSHL,JSRA0,ADDQ4)

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  ULongPtr = POINTER TO UNSIGNEDLONG;

TYPE
  CookiePPtr  = POINTER TO CookiePtr;

TYPE
  OsPPtr = POINTER TO OsPtr;

TYPE
  (* Das letzte Wort enthaelt die Versionsnummer *)
  MagiXPtr = POINTER TO ARRAY [0..2] OF
               POINTER TO ARRAY [0..24] OF UNSIGNEDWORD;

VAR
  hasFcntl     : BOOLEAN;     (* Wird 'Fcntl'-Aufruf unterstuetzt ? *)
  hasDpathconf : BOOLEAN;     (* fuer 'Dpathconf' *)
  hasSysconf   : BOOLEAN;     (* fuer 'Sysconf' *)
  hasDgetcwd   : BOOLEAN;     (* fuer 'Dgetcwd' *)
  mch          : MachineType; (* Rechnertyp *)
  cpu          : CPUType;     (* CPU-Typ *)
  fpu          : FPUType;     (* FPU-Typ *)
  lang         : PrefLanguage;(* Landessprache *)
  linef        : UNSIGNEDWORD;(* Line-F-Emulation ? *)
  STARTTIME    : UNSIGNEDLONG;
  MiNT         : CARDINAL;    (* MiNT-Version *)
  MagX         : CARDINAL;    (* Mag!X-Version *)
  FLK          : BOOLEAN;     (* File-Locking vorhanden ? *)
  pcookie      : CookiePtr;
  OSP          : OsPtr;
  PCookies     : CookiePPtr;
  Hz200        : ULongPtr;
  ShellP       : ULongPtr;
  Sysbase      : OsPPtr;
  lval         : UNSIGNEDLONG;
  lvar         : POINTER TO UNSIGNEDLONG;
  wval         : UNSIGNEDWORD;
  wvar         : POINTER TO UNSIGNEDWORD;
  from         : ADDRESS;
  to           : ADDRESS;
  len          : sizeT;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#ifdef HM2
(*$E+*)
#endif
PROCEDURE getpcookies;
(* Ergebnis ueber Register D0, damit die Prozedur reentrant bleibt *)
BEGIN
 SETREG(0, PCookies^);
END getpcookies;

PROCEDURE gethz200;
BEGIN
 SETREG(0, Hz200^);
END gethz200;

PROCEDURE getshellp;
BEGIN
 SETREG(0, ShellP^);
END getshellp;

PROCEDURE init;
(* Reentranz unwichtig *)
BEGIN
 OSP     := Sysbase^;
 OSP     := OSP^.osBeg;
 pcookie := PCookies^;
END init;

PROCEDURE readlong;
(* Reentranz nicht moeglich *)
BEGIN
 lval := lvar^;
END readlong;

PROCEDURE readword;
BEGIN
 wval := wvar^;
END readword;

PROCEDURE writelong;
BEGIN
 lvar^ := lval;
END writelong;

PROCEDURE writeword;
BEGIN
 wvar^ := wval;
END writeword;

PROCEDURE copy;
BEGIN
 memmove(to, from, len);
END copy;
#ifdef HM2
(*$E=*)
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE GetOsHeader ((* -- /AUS *) VAR osp : ADDRESS );
BEGIN
 osp := OSP;
END GetOsHeader;

(*--------------------------------------------------------------------------*)

PROCEDURE Machine ( ): MachineType;
BEGIN
 RETURN(mch);
END Machine;

(*---------------------------------------------------------------------------*)

PROCEDURE CPU ( ): CPUType;
BEGIN
 RETURN(cpu);
END CPU;

(*---------------------------------------------------------------------------*)

PROCEDURE FPU ((* -- /AUS *) VAR info : FPUInfo );
BEGIN
 info.fpu   := fpu;
 info.linef := linef;
END FPU;

(*---------------------------------------------------------------------------*)

PROCEDURE MiNTVersion ( ): CARDINAL;
BEGIN
 RETURN(MiNT);
END MiNTVersion;

(*---------------------------------------------------------------------------*)

PROCEDURE MagiXVersion ( ): CARDINAL;
BEGIN
 RETURN(MagX);
END MagiXVersion;

(*---------------------------------------------------------------------------*)

PROCEDURE FileLocking ( ): BOOLEAN;
BEGIN
 RETURN(FLK);
END FileLocking;

(*---------------------------------------------------------------------------*)

PROCEDURE Language ( ): PrefLanguage;
BEGIN
 RETURN(lang);
END Language;

(*---------------------------------------------------------------------------*)

PROCEDURE ProcessDomain ((* EIN/ -- *) dom : INTEGER ): INTEGER;

VAR res : SIGNEDWORD;

BEGIN
 IF MiNT > 0 THEN
   RETURN(Pdomain(dom));
 ELSE
   RETURN(0); (* TOS-Domain *)
 END;
END ProcessDomain;

(*---------------------------------------------------------------------------*)

PROCEDURE DosVersion ( ): CARDINAL;
BEGIN
 RETURN(Sversion());
END DosVersion;

(*---------------------------------------------------------------------------*)

PROCEDURE GetCookieBase ((* -- /AUS *) VAR pcookies : CookiePtr );
(*T*)
VAR pc : CookiePtr;

BEGIN
 Supexec(getpcookies);
 GETREGADR(0, pc);
 pcookies := pc;
END GetCookieBase;

(*---------------------------------------------------------------------------*)

PROCEDURE findCookie ((* EIN/ -- *)     cookie   : UNSIGNEDLONG;
                      (* -- /AUS *) VAR pcookies : CookiePtr;
                      (* -- /AUS *) VAR idx      : CookieRange;
                      (* -- /AUS *) VAR found    : BOOLEAN      );
(*T*)
VAR __REG__ pc : CookiePtr;
    __REG__ i  : CookieRange;

BEGIN
 GetCookieBase(pcookies);
 pc := pcookies;
 IF pc <> NULL THEN
   i := 0;
   WHILE (pc^[i].id <> VAL(UNSIGNEDLONG,0)) AND (pc^[i].id <> cookie) DO
     INC(i);
   END;
   found := pcookies^[i].id = cookie;
 ELSE
   found := FALSE;
 END;
 idx := i;
END findCookie;

(*--------------------------------------------------------------------------*)

PROCEDURE GetCookie ((* EIN/ -- *)     cookie : UNSIGNEDLONG;
                     (* -- /AUS *) VAR value  : CookieVal    ): BOOLEAN;
(*T*)
VAR pcookie : CookiePtr;
    idx     : CookieRange;
    found   : BOOLEAN;

BEGIN
 findCookie(cookie, pcookie, idx, found);
 IF found THEN
   value := pcookie^[idx].val;
   RETURN(TRUE);
 ELSE
   value.ul := VAL(UNSIGNEDLONG,0);
   RETURN(FALSE);
 END;
END GetCookie;

(*--------------------------------------------------------------------------*)

PROCEDURE SetCookie ((* EIN/ -- *)     cookie : UNSIGNEDLONG;
                     (* EIN/ -- *)     value  : CookieVal;
                     (* -- /AUS *) VAR done   : BOOLEAN      );
(**)
VAR pcookie : CookiePtr;
    i       : CookieRange;
    size    : UNSIGNEDLONG;

BEGIN
 findCookie(cookie, pcookie, i, done);
 WITH pcookie^[i] DO
   IF done THEN
     val := value;
   ELSE
     size := val.ul;
     done := VAL(UNSIGNEDLONG,i+1) < size;
     IF done THEN
       (* Es ist noch Platz fuer einen Cookie *)
       id                   := cookie;
       val                  := value;
       pcookie^[i+1].id     := VAL(UNSIGNEDLONG,0);
       pcookie^[i+1].val.ul := size;
     END;
   END;
 END;
END SetCookie;

(*--------------------------------------------------------------------------*)

PROCEDURE RemoveCookie ((* EIN/ -- *)     cookie : UNSIGNEDLONG;
                        (* -- /AUS *) VAR found  : BOOLEAN      );
(**)
VAR __REG__ pc      : CookiePtr;
    __REG__ i       : CookieRange;
            idx     : CookieRange;
            pcookie : CookiePtr;

BEGIN
 findCookie(cookie, pcookie, idx, found);
 IF found THEN
   i  := idx;
   pc := pcookie;
   REPEAT
     pc^[i].id  := pc^[i+1].id;
     pc^[i].val := pc^[i+1].val;
     INC(i);
   UNTIL pc^[i].id = VAL(UNSIGNEDLONG,0);
 END;
END RemoveCookie;

(*--------------------------------------------------------------------------*)

PROCEDURE findTermCookie ((* -- /AUS *) VAR rank : CARDINAL;
                          (* -- /AUS *) VAR size : CARDINAL );
(*T*)
VAR __REG__ pc      : CookiePtr;
    __REG__ i       : CookieRange;
            pcookie : CookiePtr;

BEGIN
 GetCookieBase(pcookie);
 pc := pcookie;
 IF pc = NULL THEN
   rank := 0;
   size := 0;
   RETURN;
 END;
 i := 0;
 WHILE pc^[i].id <> VAL(UNSIGNEDLONG,0) DO
   INC(i);
 END;
 rank := VAL(CARDINAL,i+1);
 size := VAL(CARDINAL,pc^[i].val.ul);
END findTermCookie;

(*--------------------------------------------------------------------------*)

PROCEDURE CookieJarSize( ): CARDINAL;
(*T*)
VAR dummy, size : CARDINAL;
BEGIN
 findTermCookie(dummy, size);
 RETURN(size);
END CookieJarSize;

(*--------------------------------------------------------------------------*)

PROCEDURE FreeEntries( ): CARDINAL;
(*T*)
VAR rank, size : CARDINAL;
BEGIN
 findTermCookie(rank, size);
 RETURN(size - rank);
END FreeEntries;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadHz200 ( ): UNSIGNEDLONG;

VAR time : UNSIGNEDLONG;

BEGIN
 Supexec(gethz200);
 GETLREG(0, time);
 RETURN(time);
END ReadHz200;

(*---------------------------------------------------------------------------*)

PROCEDURE SysClock ( ): UNSIGNEDLONG;
BEGIN
 RETURN(ReadHz200() - STARTTIME);
END SysClock;

(*---------------------------------------------------------------------------*)

PROCEDURE ShellInstalled ( ): Shell;

CONST GulamMAGIC = 00420135H;
      XBRAID     = 58425241H; (* 'XBRA' *)
      MasterID   = 4D415354H; (* 'MAST' *)
      MupfelID   = 4D555046H; (* 'MUPF' *)
      GeminiID   = 474D4E49H; (* 'GMNI' *)

TYPE xbraidp = POINTER TO ARRAY[0..1] OF UNSIGNEDLONG;
     magicp  = ULongPtr;

VAR __REG__ xbraid : xbraidp;
            magic  : magicp;
            shell  : UNSIGNEDLONG;

BEGIN
 Supexec(getshellp);
 GETLREG(0, shell);

 IF shell = VAL(UNSIGNEDLONG,0) THEN
   RETURN(None);
 END;
 xbraid := CAST(xbraidp,shell - VAL(UNSIGNEDLONG,12));
 IF xbraid^[0] = XBRAID THEN
   IF xbraid^[1] = MupfelID THEN
     RETURN(Mupfel);
   ELSIF xbraid^[1] = GeminiID  THEN
     RETURN(Gemini);
   ELSIF xbraid^[1] = MasterID THEN
     RETURN(Master);
   END;
 END;
 magic := CAST(magicp,shell - VAL(UNSIGNEDLONG,10));
 IF magic^ = GulamMAGIC THEN
   RETURN(Gulam);
 END;
 RETURN(Unknown);
END ShellInstalled;

(*---------------------------------------------------------------------------*)

PROCEDURE FcntlAvail ( ): BOOLEAN;
BEGIN
 RETURN(hasFcntl);
END FcntlAvail;

(*---------------------------------------------------------------------------*)

PROCEDURE DpathconfAvail ( ): BOOLEAN;
BEGIN
 RETURN(hasDpathconf);
END DpathconfAvail;

(*---------------------------------------------------------------------------*)

PROCEDURE SysconfAvail ( ): BOOLEAN;
BEGIN
 RETURN(hasSysconf);
END SysconfAvail;

(*---------------------------------------------------------------------------*)

PROCEDURE DgetcwdAvail ( ): BOOLEAN;
BEGIN
 RETURN(hasDgetcwd);
END DgetcwdAvail;

(*---------------------------------------------------------------------------*)

PROCEDURE DosPid ((* EIN/ -- *) bp : ADDRESS ): INTEGER;
BEGIN
 RETURN(INT((CAST(UNSIGNEDLONG,bp) DIV LC(256)) MOD LC(32768)));
END DosPid;

(*---------------------------------------------------------------------------*)

PROCEDURE CallShell ((* EIN/ -- *) cmd : StrPtr ): INTEGER;

VAR retCode : SIGNEDWORD;
    shell   : UNSIGNEDLONG;

BEGIN
 Supexec(getshellp);
 GETLREG(0, shell);
 IF shell = VAL(UNSIGNEDLONG,0) THEN
   RETURN(-1);
 ELSE
   CALLSHELL(cmd, shell);
   GETSWREG(0,retCode);
   RETURN(INT(retCode));
 END;
END CallShell;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadSysMem ((* EIN/ -- *)     adr : UNSIGNEDLONG;
                      (* -- /AUS *) VAR val : ARRAY OF ANYBYTE );
(**)
BEGIN
 (* Die Parameter fuer die Kopierfunktion muessen
  * globalen Variablen zugewiesen werden, damit die
  * parameterlose Prozedur "copy()", die sie an die
  * eigentliche Kopierfunktion uebergibt, im Supervisor-
  * modus mit 'Supexec' ausgefuehrt werden kann.
  *)
 from := MAKEADR(adr);
 to   := ADR(val);
 len  := VAL(sizeT,HIGH(val) + 1);

 Supexec(copy);
END ReadSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteSysMem ((* EIN/ -- *)     adr : UNSIGNEDLONG;
                       (* EIN/ -- *) VAR val : ARRAY OF ANYBYTE );
(**)
BEGIN
 to   := MAKEADR(adr);
 from := ADR(val);
 len  := VAL(sizeT,HIGH(val) + 1);

 Supexec(copy);
END WriteSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadLongSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG ): UNSIGNEDLONG;
(**)
BEGIN
 lvar := MAKEADR(adr);
 Supexec(readlong);
 RETURN(lval);
END ReadLongSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadWordSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG ): UNSIGNEDWORD;
(**)
BEGIN
 wvar := MAKEADR(adr);
 Supexec(readword);
 RETURN(wval);
END ReadWordSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteLongSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG;
                           (* EIN/ -- *) val : UNSIGNEDLONG );
(**)
BEGIN
 lvar := MAKEADR(adr);
 lval := val;
 Supexec(writelong);
END WriteLongSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteWordSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG;
                           (* EIN/ -- *) val : UNSIGNEDWORD );
(**)
BEGIN
 wvar := MAKEADR(adr);
 wval := val;
 Supexec(writeword);
END WriteWordSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE SetException ((* EIN/ -- *)     vec : ExcVector;
                        (* EIN/ -- *)     new : ADDRESS;
                        (* -- /AUS *) VAR old : ADDRESS   );
(**)
BEGIN
 old := Setexc(ORD(vec), new);
END SetException;

(*---------------------------------------------------------------------------*)

PROCEDURE GetException ((* EIN/ -- *) vec : ExcVector ): ADDRESS;
(**)
BEGIN
 RETURN(Setexc(ORD(vec), CAST(ADDRESS,VAL(LONGINT,-1))));
END GetException;

(*===========================================================================*)

CONST
  MagXCk = 4D616758H;

  FGETFD = 1;  (* ``Harmlose'' Fcntl-Funktion *)
  MAXINQ = -1; (* ``Harmlose'' Dpathconf- und Sysconf-Funktion *)

VAR
  bptr   : BasePPtr;
  mptr   : MagiXPtr;
  res    : INTEGER;
  lres   : SIGNEDLONG;
  vers   : UNSIGNEDLONG;
  i      : CookieRange;
  period : ARRAY [0..1] OF CHAR;

BEGIN (* DosSystem *)
 period   := ".";
 Sysbase  := CAST(OsPPtr,VAL(UNSIGNEDLONG,4F2H));
 PCookies := CAST(CookiePPtr,VAL(UNSIGNEDLONG,5A0H));
 Hz200    := CAST(ULongPtr,VAL(UNSIGNEDLONG,4BAH));
 ShellP   := CAST(ULongPtr,VAL(UNSIGNEDLONG,4F6H));

 STARTTIME := ReadHz200();

 Supexec(init); (* OSP und pcookie setzen *)

 (* Benutzte Sprache, falls kein '_AKP'-Cookie existiert *)
 IF CAST(UNSIGNEDWORD,OSP^.osConf) < 30 THEN
   lang := VAL(PrefLanguage,CAST(UNSIGNEDWORD,OSP^.osConf) DIV 2);
 ELSE
   lang := lUSA;
 END;

#if (defined HM2)
 BASEP := BasePtr(TOS.BasePage);
#elif (defined LPRM2)
 BASEP := VAL(BasePtr,GEMX.BasePagePtr);
#elif (defined SPCM2)
 BASEP := VAL(BasePtr,GEMDOS.BasePagePtr);
#elif (defined MM2)
 PrgCtrl.GetBasePageAddr(BASEP);
#elif (defined TDIM2)
 BASEP := BasePtr(GEMX.BasePageAddress);
#elif (defined FTLM2)
 BASEP := BasePtr(LOADER.ProgPrefixAddress);
#else
 IF VAL(CARDINAL,OSP^.osEntry) >= 0102H THEN
   bptr := OSP^.pRun; (* erst ab Blitter-TOS 1.02 *)
 ELSIF lang = lSpanish THEN
   (* Spanisches TOS 1.0 *)
   bptr := CAST(BasePPtr,VAL(UNSIGNEDLONG,873CH));
 ELSE
   bptr := CAST(BasePPtr,VAL(UNSIGNEDLONG,602CH));
 END;
 BASEP := bptr^;
#endif

 (* Die folgenden Cookies werden nur waehrend der Initialisierung getestet,
  * da sich deren Inhalt nicht waehrend des Programmlaufs aendert.
  * (Bei _FLK bin ich mir allerdings nicht ganz sicher.)
  *)
 MiNT  := 0;
 MagX  := 0;
 mch   := atariST;
 cpu   := CPU68000;
 fpu   := FPUType{};
 linef := 0;
 FLK   := FALSE;
 IF pcookie <> NULL THEN
   i := 0;
   WHILE pcookie^[i].id <> VAL(UNSIGNEDLONG,0) DO
     WITH pcookie^[i] DO
       IF id = MiNTCk THEN
         MiNT := VAL(CARDINAL,val.uwl);
         res  := Pdomain(1);
       ELSIF id = FLKCk THEN
         FLK := TRUE;
       ELSIF id = MCHCk THEN
         IF val.uwh <= 3 THEN
           mch := VAL(MachineType,val.uwh);
           IF (mch = atariSTE) AND (val.uwl <> 0) THEN
             mch := atariMSTE;
           END;
         ELSE
           mch := atari;
         END;
       ELSIF id = CPUCk THEN
         IF val.uwl <= 40 THEN
           cpu := VAL(CPUType,val.uwl DIV 10);
         ELSE
           cpu := CPU68XXX;
         END;
       ELSIF id = FPUCk THEN
#ifdef HM2
         fpu   := CAST(FPUType,CHR(val.uwh));
#else
         fpu   := CAST(FPUType,val.uwh);
#endif
         linef := val.uwl;
       ELSIF id = AKPCk THEN
         (* Cookie hat Vorrang vor 'OsHeader' *)
#ifdef HM2
         IF val.ublh < 15 THEN
           lang := VAL(PrefLanguage,val.ublh);
#else
         IF CAST(UNSIGNEDWORD,val.ublh) < 15 THEN
           lang := VAL(PrefLanguage,CAST(UNSIGNEDWORD,val.ublh));
#endif
         ELSE
           lang := lUSA;
         END;
       ELSIF id = MagXCk THEN
         mptr := val.ptr;
         IF mptr <> NULL THEN
           MagX := VAL(CARDINAL,mptr^[2]^[24]);
         END;
       END;
     END;
     INC(i);
   END;
 END;

 hasFcntl     := (MiNT > 0) OR Fcntl(0, 0, FGETFD, lres) OR
                               (lres <> VAL(SIGNEDLONG,e.eINVFN));
 hasDpathconf := (MiNT > 0) OR Dpathconf(ADR(period), MAXINQ, lres) OR
                               (lres <> VAL(SIGNEDLONG,e.eINVFN));
 hasSysconf   := (MiNT > 0) OR Sysconf(MAXINQ, lres) OR
                               (lres <> VAL(SIGNEDLONG,e.eINVFN));
 hasDgetcwd   := (MiNT > 95) OR Dgetcwd(ADR(period), 0, 0, res) OR
                                (res <> e.eINVFN);
END DosSystem.
