IMPLEMENTATION MODULE DosSystem;
__IMP_SWITCHES__
__DRIVER__ /* In MiNT-Domain schalten */
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
#ifdef MM2
(*$X+ 68881 Mnemonics *)
#endif
(*****************************************************************************)
(* 27-Aug-96, Holger Kleinschmidt & Ulrich Kaiser                            *)
(*****************************************************************************)

/* LPRM2: Folgende Zeile in #if 1 aendern, falls das Modul unter dem Lader
 * laufen soll. Dadurch funktioniert die Modulterminierung auch in der Shell.
 * !! Bei gelinkten Programmen darf diese Variante nicht verwendet werden !!
 */
#if 0
#define LPR_LTL_MTERM
#endif

/* MM2, HM2: Folgende Zeile in #if 1 aendern, falls die MagicLib 4.x
 * verwendet wird, damit bei der Terminierung des Hauptprozesses durch
 * "exit()" oder "Exit()" auch die Abmeldung von der MagicLib erfolgt.
 */
#if 0
#define __MAGICLIB_TERM__
#endif

/* Dieses Makro fuer jeden Compiler definieren, bei dem die Adresse der
 * Basepage ueber _sysbase, bzw. Fcntl(PBASEADDR), falls vorhanden, abgefragt
 * werden soll.
 * Andernfalls wird ein systemspezifisches Modul verwendet.
 */
#if (defined TDIM2)
#define __USE_SYSBASE_FOR_BASEPAGE__
#endif

VAL_INTRINSIC
CAST_IMPORT
OSCALL_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

#ifndef __USE_SYSBASE_FOR_BASEPAGE__
#if (defined LPRM2)
IMPORT GEMX;
#elif (defined SPCM2)
IMPORT System;
#elif (defined MM2)
IMPORT PrgCtrl;
#elif (defined HM2)
IMPORT TOS;
#elif (defined HM2_OLD)
IMPORT System;
#elif (defined TDIM2)
IMPORT GEMX;
#elif (defined FTLM2)
IMPORT LOADER;
#endif
#endif

#if (defined TSM2_1)
  FROM Lib IMPORT Terminate,SetReturnCode;
#elif (defined FSTM2)
  FROM System IMPORT TermProcedure,Terminate;
#elif (defined SPCM2)
  FROM System IMPORT OnModuleTerminationDo,ModuleDescrPtr,AuxDescrPtr,
                     NextDescriptor,KillThread,SearchModuleByStaticBase,
                     SearchResults;
#elif (defined LPRM2)
#ifdef LPR_LTL_MTERM
#warning This version of DosSystem only suitable for load-time-linking!
  FROM M2Loader IMPORT Status,Terminate,TermProcedure,BasePagePtr;
#else
#warning You need 'LPRTERMINATION' and the new 'GEMX'
  FROM LPRTERMINATION IMPORT InstallTerm,TermRec,Terminate;
#endif
#elif (defined TDIM2)
#warning You need 'CleanUp'
  FROM CleanUp IMPORT Install,ExValue,ModTerm;
#elif (defined MM2)
  FROM PrgCtrl    IMPORT TermCarrier,CatchProcessTerm,TermProcess,ProcessLinked;
  FROM MOSGlobals IMPORT MemArea;
  FROM MOSCtrl    IMPORT ActMOSProcess,BaseProcess,ProcessID;
#elif (defined HM2)
  FROM System IMPORT tTermChain,InstallTerm,Abort;
#elif (defined FTLM2)
  FROM SYSTEM IMPORT TRAP;
#elif (defined ANAM2)
  FROM Program IMPORT Terminate,CallResult;
#endif

#ifdef __MAGICLIB_TERM__
#warning ...using M_Appl.ApplTerm for program termination
FROM M_Appl IMPORT ApplTerm;
#endif

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) ANYBYTE, SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG,
           WORDSET;

FROM er IMPORT
(* CONST*) eINVFN, eRANGE;

FROM types IMPORT
(* CONST*) PATHMAX, DDIRSEP,
(* TYPE *) int, sizeT, StrPtr, PathName;

FROM OSCALLS IMPORT
(* PROC *) Pdomain, Sversion, Setexc, Fopen, Fclose, Fcntl, Super, Dfree,
           Dsetpath, Dgetpath, Dgetcwd, Dsetdrv, Dgetdrv, Pgetpid, Pterm,
           Psigblock, Psigsetmask, Metainit;

FROM blk IMPORT
(* PROC *) memmove, memfill, memalloc, memdealloc;

FROM pLONGSET IMPORT
(* PROC *) LONGELEM;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

TYPE
  SLongPtr = POINTER TO SIGNEDLONG;

TYPE
  CookiePPtr  = POINTER TO CookiePtr;

TYPE
  OsPPtr = POINTER TO OsPtr;

TYPE
  (* Das letzte Wort enthaelt die Versionsnummer *)
  MagiCPtr = POINTER TO ARRAY [0..2] OF
               POINTER TO ARRAY [0..24] OF UNSIGNEDWORD;

VAR
  mch       : MachineType; (* Rechnertyp *)
  cpu       : CPUType;     (* CPU-Typ *)
  fpu       : FPUType;     (* FPU-Typ *)
  lang      : PrefLanguage;(* Landessprache *)
  linef     : UNSIGNEDWORD;(* Line-F-Emulation? *)
  STARTTIME : UNSIGNEDLONG;
  MiNT      : CARDINAL;    (* MiNT-Version *)
  MagC      : INTEGER;     (* MagiC-Version *)
  FLK       : BOOLEAN;     (* File-Locking vorhanden? *)
  SVAR      : BOOLEAN;     (* Fehlen Systemvariablen ausser pcookie? *)
  pcookie   : CookiePtr;
  OSP       : OsPtr;
  pcookies  : CookiePPtr;
  hz200     : SLongPtr;
  shellp    : SLongPtr;
  sysbase   : OsPPtr;
  lval      : SIGNEDLONG;
  lvar      : SLongPtr;
  wval      : SIGNEDWORD;
  wvar      : POINTER TO SIGNEDWORD;
  from      : ADDRESS;
  to        : ADDRESS;
  len       : sizeT;
  pname     : ARRAY [0..13] OF CHAR;
  ssp       : SIGNEDLONG;
  uproc     : ARRAY [0..7] OF CHAR;
  mainpid   : INTEGER;
#ifdef MM2
  loadbp    : ADDRESS;
#endif

CONST
  MAXTERM = 31;

VAR
  Term     : BOOLEAN;
  TermOK   : BOOLEAN;
  TermProc : ARRAY [0..MAXTERM] OF PROC;
  TermIdx  : UNSIGNEDWORD;

#if (defined TSM2_1)
VAR
  TermSave : PROC;
#elif (defined SPCM2)
VAR
  md  : ModuleDescrPtr;
  aux : AuxDescrPtr;
#elif (defined LPRM2) && !(defined LPR_LTL_MTERM)
VAR
  TermSave : TermRec;
#elif (defined MM2)
VAR
  TermSave : TermCarrier;
#elif (defined HM2)
VAR
  TermSave : tTermChain;
#elif (defined FTLM2)
VAR
  rec = RECORD
    Operation  : CARDINAL;
    Proc       : PROC;
    CalledFrom : ADDRESS;
    ErrorCode  : CARDINAL;
  END;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)
#ifdef HM2
(*$E+*)
#endif
__STACKCHECK_OFF__
PROCEDURE getir ( ): SIGNEDLONG;
VAR ir : SIGNEDLONG;
BEGIN
(*
  moveq   #0,D0
  move    SR,D0
  lsr.w   #8,D0
  andi.w  #7,D0
*)
 CODE(7000H,40C0H,0E048H,0240H,0007H);
 GETLREG(0, ir);
 RETURN(ir);
END getir;

PROCEDURE getpcookies ( ): SIGNEDLONG;
BEGIN
 RETURN(CAST(SIGNEDLONG,pcookies^));
END getpcookies;

PROCEDURE gethz200 ( ): SIGNEDLONG;
BEGIN
 RETURN(hz200^);
END gethz200;

PROCEDURE getshellp ( ): SIGNEDLONG;
BEGIN
 RETURN(shellp^);
END getshellp;

PROCEDURE init ( ): SIGNEDLONG;
BEGIN
 OSP := sysbase^;
 OSP := OSP^.osBeg;
 RETURN(hz200^);
END init;

PROCEDURE readlong ( ): SIGNEDLONG;
BEGIN
 RETURN(lvar^);
END readlong;

PROCEDURE readword ( ): SIGNEDLONG;
BEGIN
 RETURN(VAL(SIGNEDLONG,wvar^));
END readword;

PROCEDURE writelong ( ): SIGNEDLONG;
BEGIN
 lvar^ := lval;
 RETURN(0);
END writelong;

PROCEDURE writeword ( ): SIGNEDLONG;
BEGIN
 wvar^ := wval;
 RETURN(0);
END writeword;

PROCEDURE copy ( ): SIGNEDLONG;
BEGIN
 memmove(to, from, len);
 RETURN(0);
END copy;
__STACKCHECK_PREV__
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

PROCEDURE GetCPU ( ): CPUType;
BEGIN
 RETURN(cpu);
END GetCPU;

(*---------------------------------------------------------------------------*)

PROCEDURE GetFPU ((* -- /AUS *) VAR info : FPUInfo );
BEGIN
 info.fpu   := fpu;
 info.linef := linef;
END GetFPU;

(*---------------------------------------------------------------------------*)

PROCEDURE MiNTVersion ( ): CARDINAL;
BEGIN
 RETURN(MiNT);
END MiNTVersion;

(*---------------------------------------------------------------------------*)

PROCEDURE MagiCVersion ( ): INTEGER;
BEGIN
 RETURN(MagC);
END MagiCVersion;

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
#ifdef MM2
__PROCFRAME_OFF__ (* wegen fehlender RETURN-Anweisung *)
#endif
PROCEDURE GetIEEEfpState ( ): IEEEfpState;
BEGIN
#ifdef MM2
 ASSEMBLER
   FMOVE.L FPSR,D0
#ifdef __RES_ON_STACK__
   MOVE.W  D0,(A3)+
#endif
 END;
#else
(*
#if (defined LPRM2) || (defined SPCM2)
   RETURN EQU 12
#elif (defined TDIM2)
   RETURN EQU 8
#endif

   fmove.l fpsr,d0
#if (defined LPRM2) || (defined SPCM2)
   move.w  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   rts
#elif (defined TDIM2)
   move.w  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
   CODE(0F200H,0A800H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(3D40H,000CH);
   CODE(4E5EH,285FH,4E75H);
#elif (defined TDIM2)
   CODE(3D40H,0008H);
   CODE(4E5EH,4E75H);
#endif
#endif
END GetIEEEfpState;
#ifdef MM2
__PROCFRAME_ON__
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE ResetIEEEfpState;
BEGIN
(*
  fmove.l fpsr,d0
  clr.b   d0
  fmove.l d0,fpsr
*)
  CODE(0F200H,0A800H);
  CODE(4200H);
  CODE(0F200H,8800H);
END ResetIEEEfpState;

(*---------------------------------------------------------------------------*)

PROCEDURE ProcessDomain ((* EIN/ -- *) dom : INTEGER ): INTEGER;

VAR res : INTEGER;

BEGIN
 res := Pdomain(dom);
 IF res = eINVFN THEN
   RETURN(0); (* TOS-Domain *)
 ELSE
   RETURN(res);
 END;
END ProcessDomain;

(*---------------------------------------------------------------------------*)

PROCEDURE DosVersion ( ): CARDINAL;
BEGIN
 RETURN(Sversion());
END DosVersion;

(*---------------------------------------------------------------------------*)

PROCEDURE ExecuteSuper ((* EIN/ -- *) proc : SuperProc ): SIGNEDLONG;

VAR lres : SIGNEDLONG;

BEGIN
#if (defined HM2)
 SETREG(0, proc);
(*
  movem.l D2/A2,-(SP)
  move.l  D0,-(SP)
  move.w  #$0026,-(SP)
  trap    #14
  addq.l  #6,SP
  movem.l (SP)+,D2/A2
*)
 CODE(48E7H,2020H,2F00H,3F3CH,0026H,4E4EH,5C8FH,4CDFH,0404H);
#elif (defined MM2) && !(defined __RES_ON_STACK__)
 ASSEMBLER
   MOVE.L  proc(A6),-(SP)
   MOVE.W  #$0026,-(SP)
   TRAP    #14
   ADDQ.L  #6,SP
 END;
#elif (defined MM2) && (defined __RES_ON_STACK__)
 ASSEMBLER
   PEA     wrap(PC)
   MOVE.W  #$0026,-(SP)
   TRAP    #14
   ADDQ.L  #6,SP
   BRA.S   end

wrap:
   MOVE.L  proc(A6),A0
   JSR     (A0)
   MOVE.L  -(A3),D0
   RTS

end:
  END;
#elif (defined LPRM2) || (defined SPCM2) || (defined TDIM2)
(*
  pea     wrap(PC)
  move.w  #$0026,-(SP)
  trap    #14
  addq.l  #6,SP
  bra.s   end

wrap:
  nop                    ; SETREG(8, proc)
  nop
  subq.l  #4,SP
  jsr     (A0)
  move.l  (SP)+,D0
  rts

end:
*)
 CODE(487AH,000CH,3F3CH,0026H,4E4EH,5C8FH,600CH);
 SETREG(8, proc);
 CODE(598FH,4E90H,201FH,4E75H);
#endif
 GETLREG(0, lres);
 RETURN(lres);
END ExecuteSuper;

(*---------------------------------------------------------------------------*)

PROCEDURE GetCookieBase ((* -- /AUS *) VAR pcookies : CookiePtr );
BEGIN
 pcookies := CAST(CookiePtr,ExecuteSuper(getpcookies));
END GetCookieBase;

(*---------------------------------------------------------------------------*)

PROCEDURE findCookie ((* EIN/ -- *)     cookie   : UNSIGNEDLONG;
                      (* -- /AUS *) VAR pcookies : CookiePtr;
                      (* -- /AUS *) VAR idx      : CookieRange;
                      (* -- /AUS *) VAR found    : BOOLEAN      );

VAR __REG__ pc : CookiePtr;
    __REG__ i  : CookieRange;

BEGIN
 GetCookieBase(pcookies);
 pc := pcookies;
 IF pc # NULL THEN
   i := 0;
   WHILE (pc^[i].id # VAL(UNSIGNEDLONG,0)) & (pc^[i].id # cookie) DO
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
 WHILE pc^[i].id # VAL(UNSIGNEDLONG,0) DO
   INC(i);
 END;
 rank := VAL(CARDINAL,i+1);
 size := VAL(CARDINAL,pc^[i].val.ul);
END findTermCookie;

(*--------------------------------------------------------------------------*)

PROCEDURE CookieJarSize( ): CARDINAL;
VAR dummy, size : CARDINAL;
BEGIN
 findTermCookie(dummy, size);
 RETURN(size);
END CookieJarSize;

(*--------------------------------------------------------------------------*)

PROCEDURE FreeCookieEntries( ): CARDINAL;
VAR rank, size : CARDINAL;
BEGIN
 findTermCookie(rank, size);
 RETURN(size - rank);
END FreeCookieEntries;

(*---------------------------------------------------------------------------*)

PROCEDURE SysClock ( ): UNSIGNEDLONG;
BEGIN
 IF SVAR THEN
   RETURN(0);
 ELSE
   RETURN(CAST(UNSIGNEDLONG,ExecuteSuper(gethz200)) - STARTTIME);
 END;
END SysClock;

(*---------------------------------------------------------------------------*)

PROCEDURE ShellInstalled ( ): Shell;

CONST GulamMAGIC = 00420135H;
      XBRAID     = 58425241H; (* 'XBRA' *)
      MasterID   = 4D415354H; (* 'MAST' *)
      MupfelID   = 4D555046H; (* 'MUPF' *)
      GeminiID   = 474D4E49H; (* 'GMNI' *)
      ThingID    = 54484E47H; (* 'THNG' *)

TYPE xbraidp = POINTER TO ARRAY[0..1] OF UNSIGNEDLONG;
     magicp  = SLongPtr;

VAR __REG__ xbraid : xbraidp;
            magic  : magicp;
            shell  : SIGNEDLONG;

BEGIN
 IF SVAR THEN
   RETURN(NoShell);
 END;
 shell := ExecuteSuper(getshellp);

 IF shell = VAL(SIGNEDLONG,0) THEN
   RETURN(NoShell);
 END;
 xbraid := CAST(xbraidp,shell - VAL(SIGNEDLONG,12));
 IF xbraid^[0] = XBRAID THEN
   IF xbraid^[1] = MupfelID THEN
     RETURN(Mupfel);
   ELSIF xbraid^[1] = GeminiID  THEN
     RETURN(Gemini);
   ELSIF xbraid^[1] = MasterID THEN
     RETURN(Master);
   ELSIF xbraid^[1] = ThingID THEN
     RETURN(Thing);
   END;
 END;
 magic := CAST(magicp,shell - VAL(SIGNEDLONG,10));
 IF magic^ = GulamMAGIC THEN
   RETURN(Gulam);
 END;
 RETURN(UnknownShell);
END ShellInstalled;

(*---------------------------------------------------------------------------*)

PROCEDURE CallShell ((* EIN/ -- *) cmd : StrPtr ): INTEGER;

#define PSHL 2F00H
#define JSRA0 4E90H
#define ADDQ4 588FH
#define CALLSHELL(_CMD,_SHELL)\
 SETREG(0,_CMD);SETREG(8,_SHELL);CODE(PSHL,JSRA0,ADDQ4)

VAR retCode : SIGNEDWORD;
    shell   : SIGNEDLONG;

BEGIN
 IF SVAR THEN
   RETURN(-1);
 END;
 shell := ExecuteSuper(getshellp);
 IF shell = VAL(SIGNEDLONG,0) THEN
   RETURN(-1);
 ELSE
   CALLSHELL(cmd, shell);
   GETSWREG(0,retCode);
   RETURN(INT(retCode));
 END;
END CallShell;

(*---------------------------------------------------------------------------*)

PROCEDURE CurrentCPUMode ( ): CPUMode;
BEGIN
 IF Super(1) = VAL(SIGNEDLONG,0) THEN
   RETURN(USER);
 ELSE
   RETURN(SUPERVISOR);
 END;
END CurrentCPUMode;

(*---------------------------------------------------------------------------*)

PROCEDURE SuperOn;
BEGIN
 IF Super(1) = VAL(SIGNEDLONG,0) THEN
   ssp := Super(0);
   (* Der alte Wert des Supervisor-Stackpointers
    * wird gemerkt, damit er beim Wechsel in den
    * User-Modus wieder auf seinen alten Wert
    * gesetzt werden kann.
    *)
 END;
END SuperOn;

(*---------------------------------------------------------------------------*)

PROCEDURE SuperOff;
BEGIN
 IF Super(1) # VAL(SIGNEDLONG,0) THEN
   ssp := Super(ssp);
 END;
END SuperOff;

(*---------------------------------------------------------------------------*)

PROCEDURE CurrentIRLevel ( ): IRLevel;
BEGIN
 RETURN(VAL(IRLevel,VAL(UNSIGNEDWORD,ExecuteSuper(getir))));
END CurrentIRLevel;

(*---------------------------------------------------------------------------*)

PROCEDURE SetIRLevel ((* EIN/ -- *) ir : IRLevel ): IRLevel;

(* Das Statusregister kann nicht so einfach in einer 'Supexec'-Prozedur
   gesetzt werden, da nach Ende der Prozedur automatisch das alte
   Statusregister, das zuvor gerettet wurde, eingesetzt wird.
   Folgender Weg waere moeglich:
   Da bekannt ist, welche Register beim Aufruf einer XBIOS-Funktion gerettet
   werden und wo (Systemvariable 'savptr'), kann das beim Uebergang in
   den Supervisormodus gerettete Statusregister manipuliert werden.

   Beispiel:

    SetIRLevel:
      pea     setir(pc)
      move.w  #38, -(sp)
      trap    #14
      bra.s   ende

    setir:
      movea.l $4A2,A0         ; A0 := savptr
      move.w  10*4+4(A0),D0   ; D0 := gerettetes Statusregister
                              ;       Offset: D3-D7/A3-A7 + RTN-Adresse
      moveq   #0,D1           ; IR-Maske auf Wortlaenge
      move.b  irlevel(a6),D1  ;
      lsl.w   #8,D1           ; an die Position der IR-Maske im SR bringen
      andi.w  #$FFFF-$0700,d0 ; alte IR-Maske loeschen
      or.w    D1,D0           ; und neue setzen
      move.w  D0,10*4+4(a0)   ; neue wird bei RTE gesetzt
      rts

    ende:


   Bei der Rueckkehr aus der Ausnahmebehandlung wird dann dieses veraenderte
   Statusregister in das SR der CPU geschrieben.
   Diese Vorgehensweise haengt natuerlich davon ab, dass die Anzahl und
   Position der geretteten Register sich nicht veraendert.

   Der hier beschrittene Weg scheint mir aber ``sauberer''.
 *)

VAR user  : BOOLEAN;
    oldir : UNSIGNEDWORD;

BEGIN
 user := Super(1) = VAL(SIGNEDLONG,0);

 IF user THEN SuperOn END;
(*
   move    SR,D0
   move.w  D0,-(SP)    ; D0 sichern, falls beim GETUWREG benutzt
   move.w  D0,D1
   lsr.w   #8,D1
   andi.w  #7,D1
*)
   CODE(40C0H,3F00H,3200H,0E049H,0241H,0007H);

   GETUWREG(1, oldir);
   SETREG(1, ir);

(*
   andi.w  #7,D1
   lsl.w   #8,D1
   move.w  (SP)+,D0
   andi.w  #$ffff-$0700,D0
   or.w    D1,D0
   move    D0,SR
*)
   CODE(0241H,0007H,0E149H,301FH,0240H,0F8FFH,8041H,46C0H);

 IF user THEN SuperOff END;

 RETURN(VAL(IRLevel,oldir));
END SetIRLevel;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadSysMem ((* EIN/ -- *)     adr : UNSIGNEDLONG;
                      (* -- /AUS *) VAR val : ARRAY OF ANYBYTE );

VAR void : SIGNEDLONG;

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

 void := ExecuteSuper(copy);
END ReadSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteSysMem ((* EIN/ -- *)     adr : UNSIGNEDLONG;
                       (* EIN/ -- *) VAR val : ARRAY OF ANYBYTE );

VAR void : SIGNEDLONG;

BEGIN
 to   := MAKEADR(adr);
 from := ADR(val);
 len  := VAL(sizeT,HIGH(val) + 1);

 void := ExecuteSuper(copy);
END WriteSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadLongSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG ): UNSIGNEDLONG;
BEGIN
 lvar := MAKEADR(adr);
 RETURN(ExecuteSuper(readlong));
END ReadLongSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE ReadWordSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG ): UNSIGNEDWORD;
BEGIN
 wvar := MAKEADR(adr);
 RETURN(VAL(UNSIGNEDWORD,ExecuteSuper(readword)));
END ReadWordSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteLongSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG;
                           (* EIN/ -- *) val : UNSIGNEDLONG );

VAR void : SIGNEDLONG;

BEGIN
 lvar := MAKEADR(adr);
 lval := val;
 void := ExecuteSuper(writelong);
END WriteLongSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE WriteWordSysMem ((* EIN/ -- *) adr : UNSIGNEDLONG;
                           (* EIN/ -- *) val : UNSIGNEDWORD );

VAR void : SIGNEDLONG;

BEGIN
 wvar := MAKEADR(adr);
 wval := val;
 void := ExecuteSuper(writeword);
END WriteWordSysMem;

(*---------------------------------------------------------------------------*)

PROCEDURE SetException ((* EIN/ -- *)     vec : ExcVector;
                        (* EIN/ -- *)     new : ADDRESS;
                        (* -- /AUS *) VAR old : ADDRESS   );

BEGIN
 old := Setexc(ORD(vec), new);
END SetException;

(*---------------------------------------------------------------------------*)

PROCEDURE GetException ((* EIN/ -- *) vec : ExcVector ): ADDRESS;
BEGIN
 RETURN(Setexc(ORD(vec), CAST(ADDRESS,VAL(LONGINT,-1))));
END GetException;

(*---------------------------------------------------------------------------*)

PROCEDURE ActBasepage ((* -- /AUS *) VAR base : ADDRESS );

CONST PBASEADDR = 5002H; (* ('P'<< 8)|2 *)

VAR basep   : BOOLEAN;
    done    : BOOLEAN;
    phandle : INTEGER;
    lres    : SIGNEDLONG;
    bptr    : BasePPtr;

BEGIN
 basep := FALSE;
 IF Fopen(ADR(pname), 0, phandle) THEN
   basep := Fcntl(phandle, ADR(base), PBASEADDR, lres);
   done  := Fclose(phandle, phandle);
 END;
 IF ~basep THEN
   IF SVAR THEN
     base := NULL;
   ELSE
     IF VAL(CARDINAL,OSP^.osEntry) >= 0102H THEN
       bptr := OSP^.pRun; (* erst ab Blitter-TOS 1.02 *)
     ELSIF lang = lSPA THEN
       (* Spanisches TOS 1.0 *)
       bptr := CAST(BasePPtr,VAL(UNSIGNEDLONG,873CH));
     ELSE
       bptr := CAST(BasePPtr,VAL(UNSIGNEDLONG,602CH));
     END;
     base := bptr^;
   END;
 END;
END ActBasepage;

(*---------------------------------------------------------------------------*)

PROCEDURE DosPid ((* EIN/ -- *) bp : ADDRESS ): INTEGER;
BEGIN
 RETURN(INT((CAST(UNSIGNEDLONG,bp) DIV LC(256)) MOD LC(32768)));
END DosPid;

(*---------------------------------------------------------------------------*)

PROCEDURE ActPid ( ): INTEGER;

VAR pid : INTEGER;

BEGIN
 pid := Pgetpid();
 IF pid < 0 THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(DosPid(BASEP));
 ELSE
   RETURN(pid);
 END;
END ActPid;

(*---------------------------------------------------------------------------*)

PROCEDURE IsMain ( ): BOOLEAN;
BEGIN
 RETURN(ActPid() = mainpid);
END IsMain;

(*---------------------------------------------------------------------------*)

PROCEDURE SetMain;
BEGIN
 mainpid := ActPid();
#ifdef MM2
 ActBasepage(ActMOSProcess);
 IF ProcessLinked() THEN
   BaseProcess := ActMOSProcess;
 ELSE
   BaseProcess := loadbp;
 END;
#endif
END SetMain;

(*---------------------------------------------------------------------------*)

PROCEDURE atexit ((* EIN/ -- *) term : PROC ): int;
BEGIN
 IF TermOK & (TermIdx <= MAXTERM) THEN
   TermProc[TermIdx] := term;
   INC(TermIdx);
   RETURN(0);
 ELSE
   RETURN(-1);
 END;
END atexit;

(*---------------------------------------------------------------------------*)

PROCEDURE ExitSys ((* EIN/ -- *) status : int );
BEGIN
#if (defined MM2)
 IF (ProcessID^ = BaseProcess) OR (ProcessID^ = ActMOSProcess) THEN
   (* Die Ausfuehrung der Terminierung durch die in etv_term installierte
    * Routine soll verhindert werden. Hierzu muessen 'ActMOSProcess' und
    * 'BaseProcess' ungleich 'ProcessID^' sein. Diese Variablen enthalten
    * Basepage-Adressen.
    * Wenn der Aufruf entweder von dem Prozess erfolgt, fuer den
    * "IsMain()" = TRUE gilt (normalerweise der, der beim Programmstart aktiv
    * war), oder von einem mit 'Pfork' oder 'Pvfork' erzeugten Unterprozess,
    * sind die Basepages identisch. Bei "tfork()" ist dies nicht der Fall,
    * da hierbei eine neue Basepage erzeugt wird.
    * Die Werte der Variablen muessen aber beim Programmende wieder
    * auf dem richtigen Wert stehen. Dafuer ist "SetMain()" zustaendig.
    * Bei einem mit 'Pfork' erzeugten Unterprozess braucht nichts gemacht
    * zu werden, da hier getrennte Speicherbereiche vorliegen, wodurch die
    * Variablen im anderen Prozess nicht geaendert werden. Bei 'Pvfork'
    * muessen die Werte jedoch im anderen Prozess restauriert werden, und
    * bei einem mit "tfork()" erzeugten Hintergrundprozess muessen die Werte
    * der neuen Basepage eingesetzt werden.
    *)
   BaseProcess   := NIL;
   ActMOSProcess := NIL;
 END;
#endif
 Pterm(status);
END ExitSys;

(*---------------------------------------------------------------------------*)

PROCEDURE systerm ((* EIN/ - *) status : int );
BEGIN
#if (defined __MAGICLIB_TERM__)
 ApplTerm(VAL(SIGNEDWORD,status));
#elif (defined TSM2_1)
 SetReturnCode(SHORTCARD(status));
 HALT;
#elif (defined FSTM2)
 Terminate(CARDINAL(status));
#elif (defined SPCM2)
 KillThread(md);
#elif (defined LPRM2)
#if (defined LPR_LTL_MTERM)
 IF status = 0 THEN
   Terminate(normal);
 ELSE
   Terminate(killed);
 END;
#else
 Terminate(status);
#endif
#elif (defined TDIM2)
 ExValue := status;
 ModTerm;
#elif (defined MM2)
 TermProcess(status);
#elif (defined HM2)
 Abort(VAL(SHORTINT,status));
#elif (defined FTLM2)
 Pterm(status);
#elif (defined ANAM2)
 Terminate(VAL(CallResult,status));
#endif
END systerm;

(*---------------------------------------------------------------------------*)

PROCEDURE exit ((* EIN/ -- *) status : int );
BEGIN
 IF IsMain() THEN
   (* Dies ist der Hauptprozess. Alle Terminierungsroutinen,
    * sofern vorhanden, sollen ausgefuehrt werden.
    *)
   systerm(status);
 END;
 ExitSys(status);
END exit;

(*---------------------------------------------------------------------------*)

PROCEDURE Exit ((* EIN/ -- *) status : int );
BEGIN
 IF IsMain() THEN
   (* Dies ist der Hauptprozess. Die systeminternen Terminierungsroutinen,
    * sofern vorhanden, sollen ausgefuehrt werden, nicht aber die mit
    * "atexit()" installierten.
    *
    * 'Term' ist eine globale Variable und die Prozedur daher nicht
    * reentrant; da die Prozedur allerdings nicht zurueckkehrt, ist der
    * Wert von 'Term' fuer einen unterbrochenen "Exit()"-Aufruf ohne
    * Bedeutung.
    *)
   Term := FALSE;
   systerm(status);
 END;
 ExitSys(status);
END Exit;

(*---------------------------------------------------------------------------*)

PROCEDURE abort;
BEGIN
END abort;

(*---------------------------------------------------------------------------*)

PROCEDURE AvailableDrives ( ): UNSIGNEDLONG;
BEGIN
 RETURN(Dsetdrv(Dgetdrv()));
END AvailableDrives;

(*---------------------------------------------------------------------------*)

PROCEDURE MetaDOS ((* -- /AUS *) VAR info : MetaInfo ): BOOLEAN;
BEGIN
 memfill(ADR(info), LC(0), VAL(sizeT,SIZE(info)));
 Metainit(ADR(info));
 RETURN(info.version # NULL);
END MetaDOS;

(*---------------------------------------------------------------------------*)

PROCEDURE GetPageSize ( ): SIGNEDLONG;

CONST DEFAULTSIZE  = 1024;
      MAXPATHALLOC = 2048;

VAR old     : CARDINAL;
    void    : UNSIGNEDLONG;
    mask    : UNSIGNEDLONG;
    voidb   : BOOLEAN;
    done    : BOOLEAN;
    pathu   : StrPtr;
    err     : INTEGER;
    meminfo : ARRAY [0..3] OF SIGNEDLONG;
    maxlen  : SIGNEDLONG;
    stack   : ADDRESS;

BEGIN
 old := Dgetdrv();
 IF ~LONGELEM(20, Dsetdrv(old)) THEN
   RETURN(DEFAULTSIZE);
 END;
 (* Waehrend des Verstellens von Laufwerk und Pfad keine Signale *)
 mask := Psigblock(0FFFFFFFFH);
 void := Dsetdrv(20); (* U: *)

 (* Aktuelles Verzeichnis von U: ermitteln *)
 maxlen := PATHMAX;
 LOOP
   IF maxlen > VAL(SIGNEDLONG,MAXPATHALLOC) THEN
     (* Sollte eigentlich nicht passieren *)
     EXIT;
   END;
   memalloc(VAL(sizeT,maxlen), stack, pathu);
   done :=   Dgetcwd(pathu, 0, INT(maxlen), err)
          OR (err = eINVFN) & Dgetpath(pathu, 0, err);
   IF done THEN
     EXIT;
   ELSE
     IF err = eRANGE THEN
       (* Platz zu klein -> Platz verdoppeln und nochmal probieren *)
       memdealloc(stack);
       INC(maxlen, maxlen);
     ELSE
       (* Fehler beim Ermitteln des Verzeichnisses -> aufgeben *)
       EXIT;
     END;
   END;
 END;
 IF ~done THEN
   (* Sollte eigtl. nicht passieren *)
   void := Dsetdrv(old);
   mask := Psigsetmask(mask);
   memdealloc(stack);
   RETURN(DEFAULTSIZE);
 END;

 IF pathu^[0] = 0C THEN
   pathu^[0] := DDIRSEP;
   pathu^[1] := 0C;
 END;
 IF ~Dsetpath(ADR(uproc), err) THEN
   void := Dsetdrv(old);
   mask := Psigsetmask(mask);
   memdealloc(stack);
   RETURN(DEFAULTSIZE);
 END;
 IF ~Dfree(ADR(meminfo), 0, err) THEN
   meminfo[2] := DEFAULTSIZE; (* "Sektorgroesse" *)
   meminfo[3] := 1;           (* Sektoren pro Cluster *)
 END;
 voidb := Dsetpath(pathu, err);
 void  := Dsetdrv(old);
 mask  := Psigsetmask(mask);
 memdealloc(stack);
 RETURN(meminfo[2] * meminfo[3]);
END GetPageSize;

(*---------------------------------------------------------------------------*)
#ifdef HM2
(*$E+*)
#endif
PROCEDURE terminator;
BEGIN
 IF Term THEN
   WHILE TermIdx > 0 DO
     DEC(TermIdx);
     TermProc[TermIdx];
   END;
 ELSE
   Term := TRUE;
 END;
END terminator;
#ifdef HM2
(*$E=*)
#endif
(*===========================================================================*)

CONST
  MagiCk = 4D616758H; (* "MagX" *)
  SvarCk = 53564152H; (* "SVAR" *)

VAR
  mptr : MagiCPtr;
  res  : INTEGER;
  lres : SIGNEDLONG;
  vers : UNSIGNEDLONG;
  i    : CookieRange;
  akp  : BOOLEAN;

BEGIN (* DosSystem *)
 Term    := TRUE;
 TermIdx := 0;
#if (defined TSM2_1)
 Terminate(terminator, TermSave);
 TermOK := TRUE;
#elif (defined FSTM2)
 TermProcedure(terminator);
 TermOK := TRUE;
#elif (defined SPCM2)
 TermOK := OnModuleTerminationDo(terminator);
 IF SearchModuleByStaticBase(REG(12), md, aux) # Done THEN
   (* Sollte eigtl. nicht passieren: Modul nicht gefunden; dann das oberste
    * Modul (Gelinktes Programm oder die Shell) nehmen.
    *)
   md := NIL;
   NextDescriptor(md, aux);
 END;
#elif (defined LPRM2)
#if (defined LPR_LTL_MTERM)
 TermProcedure(terminator, TermOK);
#else
 InstallTerm(TermSave, terminator);
 TermOK := TRUE;
#endif
#elif (defined TDIM2)
 Install(terminator);
 TermOK := TRUE;
#elif (defined MM2)
 CatchProcessTerm(TermSave, terminator, MemArea{NIL,0L});
 TermOK := TRUE;
#elif (defined HM2)
 InstallTerm(TermSave, terminator);
 TermOK := TRUE;
#elif (defined FTLM2)
(*
 rec.Proc:= terminator;
 TRAP(ADR(rec));
*)
 TermOK := FALSE;
#elif (defined ANAM2)
 TermOK := FALSE;
#endif

 SIGMASK    := 0H;
 SIGPENDING := 0H;
 memfill(ADR(SIGHANDLER), LC(0), VAL(sizeT,SIZE(SIGHANDLER)));

 pname     := "u:\proc\x.-1";
 uproc     := "u:\proc";
 sysbase   := CAST(OsPPtr,VAL(UNSIGNEDLONG,Sysbase));
 pcookies  := CAST(CookiePPtr,VAL(UNSIGNEDLONG,PCookies));
 hz200     := CAST(SLongPtr,VAL(UNSIGNEDLONG,Hz200));
 shellp    := CAST(SLongPtr,VAL(UNSIGNEDLONG,ShellP));

 pcookie   := CAST(CookiePtr,ExecuteSuper(getpcookies));

 res := Pdomain(1);

 (* Die folgenden Cookies werden nur waehrend der Initialisierung getestet,
  * da sich deren Inhalt nicht waehrend des Programmlaufs aendert.
  * (Bei _FLK bin ich mir allerdings nicht ganz sicher.)
  *)
 MiNT  := 0;
 MagC  := -1;
 mch   := UnknownMachine;
 cpu   := UnknownCPU;
 fpu   := FPUType{};
 linef := 0;
 FLK   := FALSE;
 SVAR  := FALSE;
 akp   := FALSE;
 IF pcookie # NULL THEN
   i := 0;
   WHILE pcookie^[i].id # VAL(UNSIGNEDLONG,0) DO
     WITH pcookie^[i] DO
       IF id = SvarCk THEN
         SVAR := TRUE; (* Keine Systemvariablen ausser _p_cookies *)
       ELSIF id = MiNTCk THEN
         MiNT := VAL(CARDINAL,val.uwl);
       ELSIF id = FLKCk THEN
         FLK := TRUE;
       ELSIF id = MCHCk THEN
         IF val.ul = 0FFFFFFFFH THEN
           mch := NoAtari; (* MagiCMac? *)
         ELSIF val.uwh <= 3 THEN
           mch := VAL(MachineType,val.uwh);
           IF (mch = atariSTE) & (val.uwl # 0) THEN
             IF val.uwl = 1 THEN
               mch := atariSTBOOK;
             ELSIF val.uwl = 8 THEN
               mch := atariSTEIDE;
             ELSIF val.uwl = 16 THEN
               mch := atariMSTE;
             ELSIF val.uwl = 256 THEN
               mch := atariSPARROW;
             END;
           END;
         END;
       ELSIF id = CPUCk THEN
         IF val.uwl <= 40 THEN
           cpu := VAL(CPUType,val.uwl DIV 10);
         ELSIF val.uwl = 60 THEN
           cpu := CPU68060;
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
         akp := TRUE;
#ifdef HM2
         IF val.ublh < 17 THEN
           lang := VAL(PrefLanguage,val.ublh);
#else
         IF CAST(UNSIGNEDWORD,val.ublh) < 17 THEN
           lang := VAL(PrefLanguage,CAST(UNSIGNEDWORD,val.ublh));
#endif
         ELSE
           lang := UnknownLanguage;
         END;
       ELSIF id = MagiCk THEN
         mptr := val.ptr;
         IF (mptr # NULL) & (mptr^[2] # NULL) THEN
           MagC := VAL(INTEGER,mptr^[2]^[24]);
         ELSE
           MagC := 0; (* AES nicht initialisiert -> Programm im Autoordner *)
         END;
       END;
     END;
     INC(i);
   END;
 END;

 IF SVAR THEN
   STARTTIME := 0;
   OSP       := NULL;
 ELSE
   STARTTIME := ExecuteSuper(init); (* Dabei auch OSP setzen *)
   (* Benutzte Sprache, falls kein '_AKP'-Cookie existiert *)
   IF ~akp THEN
     IF CAST(UNSIGNEDWORD,OSP^.osConf) < 34 THEN
       lang := VAL(PrefLanguage,CAST(UNSIGNEDWORD,OSP^.osConf) DIV 2);
     ELSE
       lang := UnknownLanguage;
     END;
   END;
 END;

#ifdef __USE_SYSBASE_FOR_BASEPAGE__
#warning ...Using _sysbase for determining the Basepage address
 ActBasepage(BASEP);
#else
#if (defined HM2)
 BASEP := BasePtr(TOS.BasePage);
#elif (defined HM2_OLD)
 BASEP := BasePtr(System.BasePage);
#elif (defined LPRM2)
 BASEP := VAL(BasePtr,GEMX.BasePagePtr);
#elif (defined SPCM2)
 BASEP := System.BasePagePtr;
#elif (defined MM2)
 PrgCtrl.GetBasePageAddr(BASEP);
#elif (defined TDIM2)
 BASEP := BasePtr(GEMX.BasePageAddress);
#elif (defined FTLM2)
 BASEP := BasePtr(LOADER.ProgPrefixAddress);
#endif
#endif
 mainpid := ActPid();
#ifdef MM2
 loadbp  := BaseProcess;
#endif
END DosSystem.
