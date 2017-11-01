IMPLEMENTATION MODULE term;
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
(*****************************************************************************)
(* Basiert auf der MiNTLIB von Eric R. Smith und anderen                     *)
(* --------------------------------------------------------------------------*)
(* 02-Sep-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, SIGNEDWORD, WORDSET;

FROM types IMPORT
(* TYPE *) int, sizeT, pidT, StrPtr, StrRange;

FROM er IMPORT
(* CONST*) EBADF, ENOTTY, eINVFN, EINVAL, ENOENT,
(* VAR  *) errno;

FROM OSCALLS IMPORT
(* PROC *) Fcntl, Fxattr, Dopendir, Dreaddir, Dclosedir, Syield, Psigblock,
           Psigsetmask, Rsconf, Fselect;

FROM str IMPORT
(* PROC *) strcpy, AssignM2ToC;

FROM DosSystem IMPORT
(* PROC *) SysClock;

FROM DosFile IMPORT
(* CONST*) MinHandle, MaxHandle, TEOFC, TEOLC, TERASEC, TKILLC, TINTRC, TQUITC,
           TSUSPC, TSTARTC, TSTOPC, TLNEXTC, TWERASEC, TRPRNTC, TUNDEFC,
(* TYPE *) HandleRange, FileType, ttymode, TTYmode,
(* VAR  *) FD, TTYMODE,
(* PROC *) IsTerm, Disconnect;

FROM DosDir IMPORT
(* TYPE *) XATTR,
(* PROC *) DosToUnix;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

(* Definitionen fuer 'Fcntl' *)
CONST (* fuer TIOCFLUSH *)
  FREAD  = 1;
  FWRITE = 2;

CONST (* fuer TIOCSFLAGSB, TIOCGSTATE, TIOCSSTATEB *)
  ivalue = 0;
  imask  = 1;
#if reverse_set
  tsBLIND  = 4;
  tsHOLD   = 3;
  tsHPCL   = 1;
  tsCOOKED = 0;
#else
  tsBLIND  = 11;
  tsHOLD   = 12;
  tsHPCL   = 14;
  tsCOOKED = 15;
#endif

CONST (* fuer TIOCG/SVMIN *)
  ivmin  = 0;
  ivtime = 1;

CONST (* fuer TIOCG/SFLAGS *)
#if reverse_set
  tfSTOPBITS = WORDSET{14,15};
    tf1STOP    = WORDSET{15};
    tf15STOP   = WORDSET{14};
    tf2STOP    = WORDSET{14,15};
  tfCHARBITS = WORDSET{12,13};
    tf8BIT     = WORDSET{};
    tf7BIT     = WORDSET{13};
    tf6BIT     = WORDSET{12};
    tf5BIT     = WORDSET{12,13};
  tfBRKINT   = 8;
  tfNLOCAL   = 4;
#else
  tfSTOPBITS = WORDSET{0,1};
    tf1STOP    = WORDSET{0};
    tf15STOP   = WORDSET{1};
    tf2STOP    = WORDSET{0,1};
  tfCHARBITS = WORDSET{2,3};
    tf8BIT     = WORDSET{};
    tf7BIT     = WORDSET{2};
    tf6BIT     = WORDSET{3};
    tf5BIT     = WORDSET{2,3};
  tfBRKINT   = 7;
  tfNLOCAL   = 11;
#endif

(* Definitionen fuer 'Rsconf' *)
#if reverse_set
CONST
  rsODDP     = 14; (* Register 'ucr' *)
  rsPARITY   = 13; (* Register 'ucr' *)

  rsBREAK    = 12; (* Register 'tsr' *)

CONST (* Register 'ucr' *)
  rsSTOPBITS = WORDSET{11,12};
    rs1STOP    = WORDSET{12};
    rs15STOP   = WORDSET{11};
    rs2STOP    = WORDSET{11,12};
  rsCHARBITS = WORDSET{9,10};
    rs8BIT     = WORDSET{};
    rs7BIT     = WORDSET{10};
    rs6BIT     = WORDSET{9};
    rs5BIT     = WORDSET{9,10};
#else
CONST
  rsODDP     = 1; (* Register 'ucr' *)
  rsPARITY   = 2; (* Register 'ucr' *)

  rsBREAK    = 3; (* Register 'tsr' *)

CONST (* Register 'ucr' *)
  rsSTOPBITS = WORDSET{3,4};
    rs1STOP    = WORDSET{3};
    rs15STOP   = WORDSET{4};
    rs2STOP    = WORDSET{3,4};
  rsCHARBITS = WORDSET{5,6};
    rs8BIT     = WORDSET{};
    rs7BIT     = WORDSET{5};
    rs6BIT     = WORDSET{6};
    rs5BIT     = WORDSET{5,6};
#endif

CONST
  rsNOFLOWCTRL = 0;
  rsXONXOFF    = 1;
  rsRTSCTS     = 2;
  rsRTSXON     = 3;

TYPE
  RsconfRes = RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: long : SIGNEDLONG;
     |TRUE : ucr  : CHAR;
             rsr  : CHAR;
             tsr  : CHAR;
             scr  : CHAR;
    END;
  END;

TYPE
  Baud = ARRAY [0..15] OF INTEGER;

VAR
  xbaud : Baud;
  dbaud : Baud;

CONST
#if no_MIN_MAX
  MAXSPEED = B38400;
#else
  MAXSPEED = MAX(speedT);
#endif

TYPE
  Ctermid = ARRAY [0..LCtermid-1] OF CHAR;

VAR
  LineDiscipline : UNSIGNEDWORD;
  TtyDiscipline  : UNSIGNEDWORD;

  xattr    : XATTR;
  TTYNAME  : Ctermid;
  (* Diese Variable wird von "ctermid()" und "ttyname()" benutzt, da diese
   * beiden Funktionen nicht reentrant sein muessen, also nicht innerhalb
   * eines Signalhandlers o.ae. benutzt werden duerfen.
   *)
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE isatty ((* EIN/ -- *) fd : int ): int;
BEGIN
 IF (fd < MinHandle) OR (fd > MaxHandle) THEN
   errno := EBADF;
   RETURN(-1);
 END;
 WITH FD[VAL(HandleRange,fd)] DO
   IF ftype = unknown THEN
     IF IsTerm(fd) THEN
       ftype := istty;
       RETURN(1);
     ELSE
       ftype := notty;
       RETURN(0);
     END;
   ELSIF ftype = istty THEN
     RETURN(1);
   ELSE
     RETURN(0);
   END;
 END;
END isatty;

(*--------------------------------------------------------------------------*)

PROCEDURE findIno ((* EIN/AUS *) VAR tname : Ctermid;
                   (* EIN/ -- *)     tlen  : StrRange;
                   (* EIN/ -- *)     idx   : UNSIGNEDLONG;
                   (* EIN/ -- *)     d     : UNSIGNEDWORD ): BOOLEAN;

(* Diese Funktion sucht im Verzeichnis <tname> nach einer Datei mit dem
   Inode <idx> und der Geraetenummer <d>. Falls eine solche Datei gefunden
   wird, enthaelt 'TTYNAME' den vollstaendigen Pfadnamen im *IX-Format
   und <tname> in DOS-Format, sonst wird FALSE zurueckgeliefert.
*)
TYPE
  DIR = RECORD
    dhandle : UNSIGNEDLONG;
    dino    : UNSIGNEDLONG;
    dname   : Ctermid;
  END;

VAR dir  : DIR;
    err  : INTEGER;
    void : BOOLEAN;
    xlen : INTEGER;

BEGIN
 WITH dir DO
   IF ~Dopendir(ADR(tname), 0, dhandle) THEN
     RETURN(FALSE);
   END;
   WHILE Dreaddir(LCtermid + 4, dhandle, ADR(dino), err) DO
     strcpy(ADR(tname[tlen]), ADR(dname));
     IF Fxattr(0, ADR(tname), ADR(xattr), err) THEN
       IF (xattr.dev = d) & (xattr.index = idx) THEN
         void := Dclosedir(dhandle, err);
         (* Es kann davon ausgegangen werden, dass 'Dreaddir' die
          * Gross/Kleinschreibung selbst beruecksichtigt.
          *)
         DosToUnix(ADR(tname), FALSE, LCtermid, ADR(TTYNAME), err, xlen);
         TTYNAME[LCtermid-1] := 0C;
         RETURN(TRUE);
       END;
     END;
   END;
   void := Dclosedir(dhandle, err);
   RETURN(FALSE);
 END;
END findIno;

(*--------------------------------------------------------------------------*)

PROCEDURE ttyname ((* EIN/ -- *) fd : int ): StrPtr;

VAR lres  : SIGNEDLONG;
    tname : Ctermid;
    index : UNSIGNEDLONG;
    dev   : UNSIGNEDWORD;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(NULL);
 END;

 IF Fcntl(fd, ADR(xattr), FSTAT, lres) THEN
   index := xattr.index;
   dev   := xattr.dev;
   tname := "u:\dev\\"; (* wegen Praeprozessor... *)
   IF findIno(tname, 7, index, dev) THEN
     RETURN(CAST(StrPtr,ADR(TTYNAME)));
   END;
   tname := "u:\pipe\\";
   IF findIno(tname, 8, index, dev) THEN
     RETURN(CAST(StrPtr,ADR(TTYNAME)));
   END;
 ELSIF lres # VAL(SIGNEDLONG,eINVFN) THEN
   (* 'Fcntl' wird unterstuetzt, echter Fehler *)
   errno := INT(lres);
   RETURN(NULL);
 END;
 IF fd = -2 THEN
   TTYNAME := "/dev/aux";
 ELSE
   TTYNAME := "/dev/tty";
 END;
 RETURN(CAST(StrPtr,ADR(TTYNAME)));
END ttyname;

(*--------------------------------------------------------------------------*)

PROCEDURE ctermid ((* EIN/ -- *) buf : StrPtr ): StrPtr;

VAR ts : StrPtr;

BEGIN
 IF ttyname(-1) = NULL THEN
   TTYNAME := "";
 END;
 IF buf # NULL THEN
   ts := buf;
   AssignM2ToC(TTYNAME, LCtermid, buf);
 ELSE
   ts := ADR(TTYNAME);
 END;
 RETURN(ts);
END ctermid;

(*--------------------------------------------------------------------------*)

PROCEDURE cfgetispeed ((* EIN/ -- *) term : TermiosRec ): speedT;
BEGIN
 RETURN(term.cIspeed);
END cfgetispeed;

(*---------------------------------------------------------------------------*)

PROCEDURE cfsetispeed ((* EIN/AUS *) VAR term  : TermiosRec;
                       (* EIN/ -- *)     speed : speedT     ): int;

BEGIN
 IF ORD(speed) > ORD(MAXSPEED) THEN
   errno := EINVAL;
   RETURN(-1);
 ELSE
   term.cIspeed := speed;
   RETURN(0);
 END;
END cfsetispeed;

(*---------------------------------------------------------------------------*)

PROCEDURE cfgetospeed ((* EIN/ -- *) term : TermiosRec ): speedT;
BEGIN
 RETURN(term.cOspeed);
END cfgetospeed;

(*---------------------------------------------------------------------------*)

PROCEDURE cfsetospeed ((* EIN/AUS *) VAR term  : TermiosRec;
                       (* EIN/ -- *)     speed : speedT     ): int;

BEGIN
 IF ORD(speed) > ORD(MAXSPEED) THEN
   errno := EINVAL;
   RETURN(-1);
 ELSE
   term.cOspeed := speed;
   RETURN(0);
 END;
END cfsetospeed;

(*---------------------------------------------------------------------------*)

PROCEDURE tcgetattr ((* EIN/ -- *)     fd   : int;
                     (* -- /AUS *) VAR term : TermiosRec ): int;

VAR __REG__ ccflag : tccflagT;
    __REG__ clflag : tclflagT;
    __REG__ ciflag : tciflagT;
    __REG__ sgflag : WORDSET;
            sgb    : SgttybRec;
            tc     : TcharsRec;
            ltc    : LtcharsRec;
            tflags : WORDSET;
            res    : INTEGER;
            speed  : INTEGER;
            lres   : SIGNEDLONG;
            rsres  : RsconfRes;
            tmp    : WORDSET;
            tmode  : TTYmode;
            vmin   : ARRAY [0..1] OF UNSIGNEDWORD;
            state  : ARRAY [0..1] OF WORDSET;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 IF Fcntl(fd, ADR(sgb), TIOCGETP, lres) THEN
   (* ANNAHME: Terminalparameter koennen durchs Betriebssystem behandelt werden *)
   sgflag := sgb.sgFlags;
   IF   ~Fcntl(fd, ADR(tc), TIOCGETC, lres)
     OR ~Fcntl(fd, ADR(ltc), TIOCGLTC, lres)
   THEN
     errno := INT(lres);
     RETURN(-1);
   END;
   IF ~Fcntl(fd, ADR(tflags), TIOCGFLAGS, lres) THEN
     tflags := WORDSET{};
   END;
   IF ~Fcntl(fd, ADR(state), TIOCGSTATE, lres) THEN
     state[0] := WORDSET{};
     state[1] := WORDSET{};
   END;

   (* input modes *)
   IF tfBRKINT IN tflags THEN
     ciflag := tciflagT{BRKINT};
   ELSE
     ciflag := tciflagT{};
   END;
   IF tCRMOD IN sgflag THEN
     INCL(ciflag, ICRNL);
   END;
   IF (tODDP IN sgflag) OR (tEVENP IN sgflag) THEN
     INCL(ciflag, INPCK);
   ELSIF ~(tRAW IN sgflag) THEN
     INCL(ciflag, IGNPAR);
   END;
   IF tTANDEM IN sgflag THEN
     ciflag := ciflag + tciflagT{IXON,IXOFF};
   END;
   IF ~(tRAW IN sgflag) THEN
     INCL(ciflag, IXON);
   END;

   (* output modes *)
   IF tRAW IN sgflag THEN
     term.cOflag := tcoflagT{};
   ELSE
     term.cOflag := tcoflagT{OPOST};
   END;
   IF tCRMOD IN sgflag THEN
     INCL(term.cOflag, ONLCR);
   END;

   (* control modes *)
   IF tfNLOCAL IN tflags THEN
     ccflag := tccflagT{CREAD,PARENB};
   ELSE
     ccflag := tccflagT{CREAD,PARENB,CLOCAL};
   END;
   IF tODDP IN sgflag THEN
     INCL(ccflag, PARODD);
   ELSIF ~(tEVENP IN sgflag) THEN
     EXCL(ccflag, PARENB);
   END;
   IF tsHPCL IN state[1] THEN
     INCL(ccflag, HUPCL);
   END;
   IF tRTSCTS IN sgflag THEN
     INCL(ccflag, CRTSCTS);
   END;
   IF tflags * tfSTOPBITS = tf2STOP THEN
     INCL(ccflag, CSTOPB);
   END;
   tmp := tflags * tfCHARBITS;
   IF tmp = tf5BIT THEN
     ccflag := ccflag + CS5;
   ELSIF tmp = tf6BIT THEN
     ccflag := ccflag + CS6;
   ELSIF tmp = tf7BIT THEN
     ccflag := ccflag + CS7;
   ELSE
     ccflag := ccflag + CS8;
   END;

   (* local modes *)
   IF tECHO IN sgflag THEN
     clflag := tclflagT{ECHO,ECHOE,ECHOK};
   ELSE
     clflag := tclflagT{};
   END;
   IF tECHOCTL IN sgflag THEN
     INCL(clflag, ECHOCTL);
   END;
   IF tXKEY IN sgflag THEN
     INCL(clflag, IEXTEN);
   END;
   IF tTOSTOP IN sgflag THEN
     INCL(clflag, TOSTOP);
   END;
   IF tNOFLSH IN sgflag THEN
     INCL(clflag, NOFLSH);
   END;
   (* {}               -> {ISIG, ICANON}
    * {tCBREAK}        -> {ISIG}
    * {tRAW}           -> {}
    * {tRAW,tCBREAK}   -> {}
    *)
   IF ~(tRAW IN sgflag) THEN
     INCL(clflag, ISIG);
     IF ~(tCBREAK IN sgflag) THEN
       INCL(clflag, ICANON);
     END;
   END;


   WITH term DO
     cCflag := ccflag;
     cIflag := ciflag;
     cLflag := clflag;

     cIspeed := VAL(speedT,VAL(UNSIGNEDWORD,sgb.sgIspeed));
     cOspeed := VAL(speedT,VAL(UNSIGNEDWORD,sgb.sgOspeed));

     cCc[VEOF]     := VAL(ccT,tc.tEofc);
     cCc[VEOL]     := VAL(ccT,tc.tBrkc);
     cCc[VERASE]   := VAL(ccT,sgb.sgErase);
     cCc[VKILL]    := VAL(ccT,sgb.sgKill);
     cCc[VINTR]    := VAL(ccT,tc.tIntrc);
     cCc[VQUIT]    := VAL(ccT,tc.tQuitc);
     cCc[VSUSP]    := VAL(ccT,ltc.tSuspc);
     cCc[VSTART]   := VAL(ccT,tc.tStartc);
     cCc[VSTOP]    := VAL(ccT,tc.tStopc);

     IF Fcntl(fd, ADR(vmin), TIOCGVMIN, lres) THEN
       IF vmin[ivtime] > 0 THEN
         cCc[VMIN] := VAL(ccT,0);
         IF vmin[ivtime] < 150 THEN
           (* Nur die Null darf wieder eine Null geben, da dies bedeutet,
            * dass es keinen Timeout gibt.
            *)
           cCc[VTIME] := VAL(ccT,1);
         ELSE
           (* Millisekunden auf Zehntelsekunden runden *)
           cCc[VTIME] := VAL(ccT,(vmin[ivtime] + 50) DIV 100);
         END;
       ELSE
         cCc[VMIN]  := VAL(ccT,vmin[ivmin]);
         cCc[VTIME] := VAL(ccT,0);
       END;
     ELSE
       cCc[VMIN]  := VAL(ccT,1);
       cCc[VTIME] := VAL(ccT,0);
     END;

     cCc[VLNEXT]   := VAL(ccT,ltc.tLnextc);
     cCc[VWERASE]  := VAL(ccT,ltc.tWerasc);
     cCc[VDSUSP]   := VAL(ccT,ltc.tDsuspc);
     cCc[VREPRINT] := VAL(ccT,ltc.tRprntc);
     cCc[VFLUSHO]  := VAL(ccT,ltc.tFlushc);
   END;
   RETURN(0);
 ELSIF lres # VAL(SIGNEDLONG,eINVFN) THEN
   errno := INT(lres);
   RETURN(-1);
 ELSE (* Terminalparameter muessen emuliert werden *)
   speed      := INT(Rsconf(-2, -1, -1, -1, -1, -1)); (* Ab TOS 1.04 *)
   rsres.long := Rsconf(-1, -1, -1, -1, -1, -1);
   sgflag     := CAST(WORDSET,VAL(UNSIGNEDWORD,rsres.ucr));
   tmode      := TTYMODE;

   (* input modes *)
   ciflag := tciflagT{IXON};
   IF (tmode.mode # raw) & tmode.crmod THEN
     INCL(ciflag, ICRNL);
   END;
   IF rsPARITY IN sgflag THEN
     INCL(ciflag, INPCK);
   ELSIF tmode.mode # raw THEN
     INCL(ciflag, IGNPAR);
   END;

   (* output modes *)
   IF tmode.mode # raw THEN
     term.cOflag := tcoflagT{OPOST};
   ELSE
     term.cOflag := tcoflagT{};
   END;
   IF tmode.crmod THEN
     INCL(term.cOflag, ONLCR);
   END;

   (* control modes *)
   ccflag := tccflagT{CLOCAL,CREAD};
   IF rsPARITY IN sgflag THEN
     INCL(ccflag, PARENB);
   END;
   IF rsODDP IN sgflag THEN
     INCL(ccflag, PARODD);
   END;
   IF sgflag * rsSTOPBITS = rs2STOP THEN
     INCL(ccflag, CSTOPB);
   END;
   tmp := sgflag * rsCHARBITS;
   IF tmp = rs5BIT THEN
     ccflag := ccflag + CS5;
   ELSIF tmp = rs6BIT THEN
     ccflag := ccflag + CS6;
   ELSIF tmp = rs7BIT THEN
     ccflag := ccflag + CS7;
   ELSE
     ccflag := ccflag + CS8;
   END;

   (* local modes *)
   IF tmode.echo THEN
     clflag := tclflagT{ECHO,ECHOE,ECHOK,ECHOCTL};
   ELSE
     clflag := tclflagT{ECHOCTL};
   END;
   IF tmode.xkey THEN
     INCL(clflag, IEXTEN);
   END;
   IF tmode.noflsh THEN
     INCL(clflag, NOFLSH);
   END;
   IF tmode.mode # raw THEN
     INCL(clflag, ISIG);
   END;
   IF tmode.mode = cooked THEN
     INCL(clflag, ICANON);
   END;

   IF (speed < 0) OR (speed > 15) THEN
     speed := 0;
   ELSE
     speed := xbaud[VAL(UNSIGNEDWORD,speed)];
   END;

   WITH term DO
     cCflag := ccflag;
     cIflag := ciflag;
     cLflag := clflag;

     cIspeed := VAL(speedT,speed);
     cOspeed := VAL(speedT,speed);

     cCc[VEOF]     := VAL(ccT,TEOFC);
     cCc[VEOL]     := VAL(ccT,TEOLC);
     cCc[VERASE]   := VAL(ccT,TERASEC);
     cCc[VKILL]    := VAL(ccT,TKILLC);
     cCc[VINTR]    := VAL(ccT,TINTRC);
     cCc[VQUIT]    := VAL(ccT,TQUITC);
     cCc[VSUSP]    := VAL(ccT,TUNDEFC);
     cCc[VSTART]   := VAL(ccT,TSTARTC);
     cCc[VSTOP]    := VAL(ccT,TSTOPC);
     cCc[VMIN]     := VAL(ccT,1);
     cCc[VTIME]    := VAL(ccT,0);
     cCc[VLNEXT]   := VAL(ccT,TLNEXTC);
     cCc[VWERASE]  := VAL(ccT,TWERASEC);
     cCc[VDSUSP]   := VAL(ccT,TUNDEFC);
     cCc[VREPRINT] := VAL(ccT,TRPRNTC);
     cCc[VFLUSHO]  := VAL(ccT,TUNDEFC);
   END;
   RETURN(0);
 END;
END tcgetattr;

(*---------------------------------------------------------------------------*)

PROCEDURE tcsetattr ((* EIN/ -- *)     fd   : int;
                     (* EIN/ -- *)     act  : AttrActions;
                     (* EIN/ -- *) VAR term : TermiosRec  ): int;

VAR __REG__ ccflag   : tccflagT;
    __REG__ clflag   : tclflagT;
    __REG__ sgflag   : WORDSET;
    __REG__ flags    : WORDSET;
    __REG__ ciflag   : tciflagT;
            sgb      : SgttybRec;
            tc       : TcharsRec;
            ltc      : LtcharsRec;
            tflags   : WORDSET;
            tmp      : tccflagT;
            rsres    : RsconfRes;
            res      : INTEGER;
            flow     : INTEGER;
            lres     : SIGNEDLONG;
            tmode    : TTYmode;
            done     : BOOLEAN;
            vmin     : ARRAY [0..1] OF UNSIGNEDWORD;
            bflags   : ARRAY [0..1] OF SIGNEDLONG;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 IF Fcntl(fd, ADR(sgb), TIOCGETP, lres) THEN
   (* ANNAHME: Terminalparameter koennen durchs Betriebssystem behandelt werden *)
   IF ~Fcntl(fd, ADR(ltc), TIOCGLTC, lres) THEN
     errno := INT(lres);
     RETURN(-1);
   END;

   WITH term DO
     ccflag := cCflag;
     clflag := cLflag;
     ciflag := cIflag;

     sgb.sgIspeed := CHR(VAL(UNSIGNEDWORD,cIspeed));
     sgb.sgOspeed := CHR(VAL(UNSIGNEDWORD,cOspeed));

     tc.tEofc     := CHR(cCc[VEOF]);
     tc.tBrkc     := CHR(cCc[VEOL]);
     sgb.sgErase  := CHR(cCc[VERASE]);
     sgb.sgKill   := CHR(cCc[VKILL]);
     tc.tIntrc    := CHR(cCc[VINTR]);
     tc.tQuitc    := CHR(cCc[VQUIT]);
     ltc.tSuspc   := CHR(cCc[VSUSP]);
     tc.tStartc   := CHR(cCc[VSTART]);
     tc.tStopc    := CHR(cCc[VSTOP]);
     IF cCc[VMIN] # 0 THEN
       vmin[ivmin]  := VAL(UNSIGNEDWORD,cCc[VMIN]);
       vmin[ivtime] := 0;
     ELSE
       vmin[ivmin]  := 1;
       vmin[ivtime] := VAL(UNSIGNEDWORD,cCc[VTIME] * 100);
     END;
     ltc.tLnextc  := CHR(cCc[VLNEXT]);
     ltc.tWerasc  := CHR(cCc[VWERASE]);
     ltc.tDsuspc  := CHR(cCc[VDSUSP]);
     ltc.tRprntc  := CHR(cCc[VREPRINT]);
     ltc.tFlushc  := CHR(cCc[VFLUSHO]);
   END;

   sgflag := sgb.sgFlags - WORDSET{tCRMOD,tCBREAK,tECHO,tRAW,tNOFLSH,tTOSTOP,
                                   tXKEY,tTANDEM,tEVENP,tODDP,tRTSCTS,tECHOCTL};
   IF ICRNL IN ciflag THEN
     INCL(sgflag, tCRMOD);
   END;
   IF tciflagT{IXON,IXOFF} * ciflag = tciflagT{IXON,IXOFF} THEN
     INCL(sgflag, tTANDEM);
   END;
   IF CRTSCTS IN ccflag THEN
     INCL(sgflag, tRTSCTS);
   END;
   IF PARENB IN ccflag THEN
     IF PARODD IN ccflag THEN
       INCL(sgflag, tODDP);
     ELSE
       INCL(sgflag, tEVENP);
     END;
   END;
   IF ECHO IN clflag THEN
     INCL(sgflag, tECHO);
   END;
   IF NOFLSH IN clflag THEN
     INCL(sgflag, tNOFLSH);
   END;
   IF TOSTOP IN clflag THEN
     INCL(sgflag, tTOSTOP);
   END;
   IF ECHOCTL IN clflag THEN
     INCL(sgflag, tECHOCTL);
   END;
   IF IEXTEN IN clflag THEN
     INCL(sgflag, tXKEY);
   END;
   (* {}            -> {tRAW}
    * {ICANON}      -> {tRAW}
    * {ISIG}        -> {tCBREAK}
    * {ISIG,ICANON} -> {}
    *)
   IF ISIG IN clflag THEN
     IF ~(ICANON IN clflag) THEN
       INCL(sgflag, tCBREAK);
     END;
   ELSE
     INCL(sgflag, tRAW);
   END;
   sgb.sgFlags := sgflag;


   IF CSTOPB IN ccflag THEN
     flags := tf2STOP;
   ELSE
     flags := tf1STOP;
   END;
   tmp := ccflag * CSIZE;
   IF tmp = CS5 THEN
     flags := flags + tf5BIT;
   ELSIF tmp = CS6 THEN
     flags := flags + tf6BIT;
   ELSIF tmp = CS7 THEN
     flags := flags + tf7BIT;
   ELSE
     flags := flags + tf8BIT;
   END;
   IF ~(CLOCAL IN ccflag) THEN
     INCL(flags, tfNLOCAL);
   END;
   IF BRKINT IN ciflag THEN
     INCL(flags, tfBRKINT);
   END;


   done := TRUE;
   IF act = TCSAFLUSH THEN
     lres := FREAD;
     done := Fcntl(fd, ADR(lres), TIOCFLUSH, lres);
   END;
   IF act = TCSANOW THEN
     done := done & Fcntl(fd, ADR(sgb), TIOCSETN, lres);
   ELSE
     done := done & Fcntl(fd, ADR(sgb), TIOCSETP, lres);
   END;
   IF ~done THEN
     errno := INT(lres);
     RETURN(-1);
   END;
   (* Ab hier bei einem Fehler nicht mehr abbrechen, da schon etwas
    * geaendert wurde.
    *)
   done := Fcntl(fd, ADR(tc), TIOCSETC, lres);
   done := Fcntl(fd, ADR(ltc), TIOCSLTC, lres);
   done := Fcntl(fd, ADR(vmin), TIOCSVMIN, lres);

   bflags[ivalue] := VAL(UNSIGNEDLONG,CAST(UNSIGNEDWORD,flags));
   bflags[imask]  := VAL(UNSIGNEDLONG,CAST(UNSIGNEDWORD,tfSTOPBITS+tfCHARBITS+WORDSET{tfNLOCAL,tfBRKINT}));
   IF ~Fcntl(fd, ADR(bflags), TIOCSFLAGSB, lres) THEN
     IF ~Fcntl(fd, ADR(tflags), TIOCGFLAGS, lres) THEN
       tflags := WORDSET{};
     END;
     tflags := (tflags - (tfSTOPBITS+tfCHARBITS)) + (flags * (tfSTOPBITS+tfCHARBITS));
     done   := Fcntl(fd, ADR(tflags), TIOCSFLAGS, lres);
   END;
   IF HUPCL IN ccflag THEN
     bflags[ivalue] := VAL(UNSIGNEDLONG,CAST(UNSIGNEDWORD,WORDSET{tsHPCL}));
   ELSE
     bflags[ivalue] := VAL(UNSIGNEDLONG,0);
   END;
   bflags[imask] := VAL(UNSIGNEDLONG,CAST(UNSIGNEDWORD,WORDSET{tsHPCL}));
   done := Fcntl(fd, ADR(bflags), TIOCSSTATEB, lres);
   RETURN(0);
 ELSIF lres # VAL(SIGNEDLONG,eINVFN) THEN
   errno := INT(lres);
   RETURN(-1);
 ELSE (* Terminalparameter muessen emuliert werden *)
   rsres.long := Rsconf(-1, -1, -1, -1, -1, -1);
   flags      :=   CAST(WORDSET,VAL(UNSIGNEDWORD,rsres.ucr))
                 - (rsCHARBITS + rsSTOPBITS + WORDSET{rsPARITY,rsODDP});
   WITH term DO
     ccflag := cCflag;
     clflag := cLflag;
     ciflag := cIflag;
   END;

   tmode.crmod  := ICRNL  IN ciflag;
   tmode.echo   := ECHO   IN clflag;
   tmode.noflsh := NOFLSH IN clflag;
   tmode.xkey   := IEXTEN IN clflag;

   IF ISIG IN clflag THEN
     IF ICANON IN clflag THEN
       tmode.mode := cooked;
     ELSE
       tmode.mode := cbreak;
     END;
   ELSE
     tmode.mode := raw;
   END;

   ciflag := ciflag * tciflagT{IXON,IXOFF};
   IF ciflag = tciflagT{IXON,IXOFF} THEN
     IF CRTSCTS IN ccflag THEN
       flow := rsRTSXON;
     ELSE
       flow := rsXONXOFF;
     END;
   ELSIF ciflag = tciflagT{} THEN
     IF CRTSCTS IN ccflag THEN
       flow := rsRTSCTS;
     ELSE
       flow := rsNOFLOWCTRL;
     END;
   ELSE
     flow := -1;
   END;

   IF PARENB IN ccflag THEN
     INCL(flags, rsPARITY);
     IF PARODD IN ccflag THEN
       INCL(flags, rsODDP);
     END;
   END;
   IF CSTOPB IN ccflag THEN
     flags := flags + rs2STOP;
   ELSE
     flags := flags + rs1STOP;
   END;
   tmp := ccflag * CSIZE;
   IF tmp = CS5 THEN
     flags := flags + rs5BIT;
   ELSIF tmp = CS6 THEN
     flags := flags + rs6BIT;
   ELSIF tmp = CS7 THEN
     flags := flags + rs7BIT;
   ELSE
     flags := flags + rs8BIT;
   END;

   TTYMODE := tmode;
   lres := Rsconf(dbaud[VAL(UNSIGNEDWORD,term.cIspeed)],
                  flow,
                  INT(CAST(UNSIGNEDWORD,flags)),
                  -1,
                  -1,
                  -1
                 );
   RETURN(0);
 END;
END tcsetattr;

(*---------------------------------------------------------------------------*)

PROCEDURE tcsendbreak ((* EIN/ -- *) fd       : int;
                       (* EIN/ -- *) duration : int ): int;

VAR lres   : SIGNEDLONG;
    rsres  : RsconfRes;
    settsr : WORDSET;
    arg    : SIGNEDLONG;
    mask   : UNSIGNEDLONG;
    until  : UNSIGNEDLONG;
    res    : INTEGER;
    done   : BOOLEAN;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 IF duration < 0 THEN
   errno := EINVAL;
   RETURN(-1);
 ELSIF duration = 0 THEN
   (* Ein bischen mehr, damit das Minimum von 250
    * auf jeden Fall eingehalten wird.
    *)
   duration := 270;
 END;

 mask := Psigblock(0FFFFFFFFH);
 IF Fcntl(fd, 0, TIOCSBRK, lres) THEN
   done := Fselect(duration, NULL, NULL, NULL, res);
   done := Fcntl(fd, 0, TIOCCBRK, lres);
   mask := Psigsetmask(mask);
   RETURN(0);
 ELSIF lres # VAL(SIGNEDLONG,eINVFN) THEN
   mask  := Psigsetmask(mask);
   errno := INT(lres);
   RETURN(-1);
 ELSE
   mask := Psigsetmask(mask);
   rsres.long := Rsconf(-1, -1, -1, -1, -1, -1);
   settsr := CAST(WORDSET,VAL(UNSIGNEDWORD,rsres.tsr));
   INCL(settsr, rsBREAK);
   rsres.long := Rsconf(-1, -1, -1, -1, INT(CAST(UNSIGNEDWORD,settsr)), -1);

   until := SysClock() + VAL(UNSIGNEDLONG,duration DIV 5);
   REPEAT
   UNTIL SysClock() >= until;

   EXCL(settsr, rsBREAK);
   rsres.long := Rsconf(-1, -1, -1, -1, INT(CAST(UNSIGNEDWORD,settsr)), -1);
   RETURN(0);
 END;
END tcsendbreak;

(*---------------------------------------------------------------------------*)

PROCEDURE tcdrain ((* EIN/ -- *) fd : int ): int;

VAR lres : SIGNEDLONG;
    arg  : SIGNEDLONG;
    res  : INTEGER;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 LOOP
   IF ~Fcntl(fd, ADR(arg), TIOCOUTQ, lres) THEN
     errno := INT(lres);
     RETURN(-1);
   ELSIF arg = VAL(SIGNEDLONG,0) THEN
     RETURN(0);
   END;
   (* Spaeter nochmal probieren *)
   res := Syield();
 END;
END tcdrain;

(*---------------------------------------------------------------------------*)

PROCEDURE tcflow ((* EIN/ -- *) fd     : int;
                  (* EIN/ -- *) action : FlowActions ): int;

VAR lres : SIGNEDLONG;
    cmd  : CARDINAL;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 CASE action OF
   TCOOFF : cmd := TIOCSTOP;
  |TCOON  : cmd := TIOCSTART;
 ELSE
   errno := EINVAL;
   RETURN(-1);
 END;

 IF Fcntl(fd, 0, cmd, lres) THEN
   RETURN(0);
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END tcflow;

(*---------------------------------------------------------------------------*)

PROCEDURE tcflush ((* EIN/ -- *) fd   : int;
                   (* EIN/ -- *) qsel : QueueTypes ): int;

VAR lres : SIGNEDLONG;
    arg  : SIGNEDLONG;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 CASE qsel OF
   TCIFLUSH : arg := FREAD;
  |TCOFLUSH : arg := FWRITE;
 ELSE         arg := FREAD + FWRITE;
 END;

 IF Fcntl(fd, ADR(arg), TIOCFLUSH, lres) THEN
   RETURN(0);
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END tcflush;

(*---------------------------------------------------------------------------*)

PROCEDURE tcgetpgrp ((* EIN/ -- *) fd : int ): pidT;

VAR lres : SIGNEDLONG;
    arg  : SIGNEDLONG;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 IF Fcntl(fd, ADR(arg), TIOCGPGRP, lres) THEN
   IF arg = VAL(SIGNEDLONG,0) THEN
     (* Gehoert keiner Prozessgruppe *)
     errno := ENOENT;
     RETURN(-1);
   ELSE
     RETURN(VAL(pidT,arg));
   END;
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END tcgetpgrp;

(*---------------------------------------------------------------------------*)

PROCEDURE tcsetpgrp ((* EIN/ -- *) fd   : int;
                     (* EIN/ -- *) pgrp : pidT ): int;

VAR lres : SIGNEDLONG;
    arg  : SIGNEDLONG;

BEGIN
 IF isatty(fd) <= 0 THEN
   errno := ENOTTY;
   RETURN(-1);
 END;

 arg := VAL(SIGNEDLONG,pgrp);
 IF Fcntl(fd, ADR(arg), TIOCSPGRP, lres) THEN
   RETURN(0);
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END tcsetpgrp;

(*---------------------------------------------------------------------------*)

PROCEDURE ioctl ((* EIN/ -- *) fd  : int;
                 (* EIN/ -- *) cmd : int;
                 (* EIN/ -- *) arg : ADDRESS ): int;

TYPE uwptr = POINTER TO UNSIGNEDWORD;
     slptr = POINTER TO SIGNEDLONG;
     WinsizePtr = POINTER TO WinsizeRec;
     TcharsPtr = POINTER TO TcharsRec;
     LtcharsPtr = POINTER TO LtcharsRec;
     SgttybPtr = POINTER TO SgttybRec;

VAR lres : SIGNEDLONG;
    up   : uwptr;
    wp   : WinsizePtr;
    sp   : slptr;
    tp   : TcharsPtr;
    lp   : LtcharsPtr;
    gp   : SgttybPtr;
    res  : INTEGER;

BEGIN
 IF cmd = TIOCGWINSZ THEN
   (* MiNT setzt auch manchmal unbekannte Werte nicht auf Null *)
   wp := arg;
   WITH wp^ DO
     wsRow    := 0;
     wsCol    := 0;
     wsXpixel := 0;
     wsYpixel := 0;
   END;
 END;
 IF Fcntl(fd, arg, cmd, lres) THEN
   RETURN(INT(lres));
 ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
   IF (cmd >= TIOCGETP) & (cmd <= TIOCSETP) THEN
     CASE cmd OF
       TIOCGETP:
        gp := arg;
        WITH gp^ DO
          sgIspeed := 0C;
          sgOspeed := 0C;
          sgErase  := TERASEC;
          sgKill   := TKILLC;
          sgFlags  := WORDSET{};
          IF TTYMODE.mode = raw THEN
            INCL(sgFlags, tRAW);
          ELSIF TTYMODE.mode = cbreak THEN
            INCL(sgFlags, tCBREAK);
          END;
          IF TTYMODE.crmod THEN
            INCL(sgFlags, tCRMOD);
          END;
          IF TTYMODE.echo THEN
            INCL(sgFlags, tECHO);
          END;
          IF TTYMODE.noflsh THEN
            INCL(sgFlags, tNOFLSH);
          END;
          IF TTYMODE.xkey THEN
            INCL(sgFlags, tXKEY);
          END;
        END;
        RETURN(0);
      |TIOCSETN, TIOCSETP:
        gp := arg;
        WITH gp^ DO
          IF tRAW IN sgFlags THEN
            TTYMODE.mode := raw;
          ELSIF tCBREAK IN sgFlags THEN
            TTYMODE.mode := cbreak;
          ELSE
            TTYMODE.mode := cooked;
          END;
          TTYMODE.crmod  := tCRMOD IN sgFlags;
          TTYMODE.echo   := tECHO IN sgFlags;
          TTYMODE.noflsh := tNOFLSH IN sgFlags;
          TTYMODE.xkey   := tXKEY IN sgFlags;
        END;
      |TIOCGETC:
        tp := arg;
        WITH tp^ DO
          tIntrc  := TINTRC;
          tQuitc  := TQUITC;
          tStartc := TSTARTC;
          tStopc  := TSTOPC;
          tEofc   := TEOFC;
          tBrkc   := TEOLC;
        END;
        RETURN(0);
      |TIOCGLTC:
        lp := arg;
        WITH lp^ DO
          tSuspc  := TUNDEFC;
          tDsuspc := TUNDEFC;
          tRprntc := TRPRNTC;
          tFlushc := TUNDEFC;
          tWerasc := TWERASEC;
          tLnextc := TLNEXTC;
        END;
        RETURN(0);
      |TIOCGPGRP:
        sp  := arg;
        sp^ := LIC(0);
      |TIOCSETC, TIOCSLTC, TIOCSPGRP, TIOCGWINSZ, TIOCSWINSZ:
        RETURN(0);
     ELSE
     END;
   ELSIF (cmd >= TIOCLBIS) & (cmd <= TIOCLSET) THEN
     CASE cmd OF
       TIOCLBIS:
        up := arg;
        LineDiscipline := CAST(UNSIGNEDWORD,CAST(WORDSET,LineDiscipline) + CAST(WORDSET,up^));
        RETURN(0);
      |TIOCLBIC:
        up := arg;
        LineDiscipline := CAST(UNSIGNEDWORD,CAST(WORDSET,LineDiscipline) - CAST(WORDSET,up^));
        RETURN(0);
      |TIOCNOTTY:
        IF Disconnect(fd, res) THEN
          RETURN(0);
        ELSE
          errno := res;
          RETURN(-1);
        END;
      |TIOCGETD:
        up  := arg;
        up^ := TtyDiscipline;
        RETURN(0);
      |TIOCSETD:
        up := arg;
        TtyDiscipline := up^;
        RETURN(0);
      |TIOCLGET:
        up  := arg;
        up^ := LineDiscipline;
        RETURN(0);
      |TIOCLSET:
        up := arg;
        LineDiscipline := up^;
        RETURN(0);
     ELSE
     END;
   ELSE
     errno := eINVFN;
     RETURN(-1);
   END;
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END ioctl;

(*===========================================================================*)
#if !ISO_value_constructor
VAR i : UNSIGNEDWORD;
#endif
BEGIN (* term *)
 LineDiscipline := LLITOUT;
 TtyDiscipline  := NTTYDISC;
#if ISO_value_constructor
 dbaud := Baud{-1,15,14,13,12,11,10,9,8,7,6,4,2,1,0,-1};
 xbaud := Baud{14,13,12,0,11,0,10,9,8,7,6,5,4,3,2,1};
#else
 dbaud[0] := -1;
 FOR i := 1 TO 10 DO
   dbaud[i] := 16 - i;
 END;
 dbaud[11] := 4;
 dbaud[12] := 2;
 dbaud[13] := 1;
 dbaud[14] := 0;
 dbaud[15] := -1;

 xbaud[0]  := 14;
 xbaud[1]  := 13;
 xbaud[2]  := 12;
 xbaud[3]  := 0;
 xbaud[4]  := 11;
 xbaud[5]  := 0;
 FOR i := 6 TO 15 DO
   xbaud[i] := 16 - i;
 END;
#endif
END term.
