IMPLEMENTATION MODULE file;
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
(* 10-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR;
#ifdef MM2
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, WORDSET;

FROM blk IMPORT
(* PROC *) memalloc, memdealloc, memchr, memset;

FROM OSCALLS IMPORT
(* PROC *) Fcreate, Fopen, Fclose, Fdelete, Fread, Fwrite, Fseek, Flock,
           Fcntl, Fdup, Fforce, Fchmod, Fattrib,
           Fpipe, Fxattr, Pgetpgrp, Pgetpid, Bconstat,
           Bconin, Cauxis, Cconis, Crawcin, Cauxin;

FROM ctype IMPORT
(* PROC *) isblank;

FROM ISOStrings IMPORT
(* PROC *) Length;

FROM types IMPORT
(* CONST*) EOS, DDIRSEP, CR, LF, BS, HT, DEL, ESC, sIFMT, sIFREG, sIFDIR,
           STDPERM,
(* TYPE *) int, unsigned, PathName, offT, sizeT, ssizeT, pidT, StrPtr,
           StrRange, FileMode, modeT;

FROM er IMPORT
(* CONST*) eINVFN, EEXIST, EACCES, ENOENT, eFILNF, EISDIR, EBADF, EINVAL,
           eLOCKED, eNSLOCK, EAGAIN, ENOSPC, ESPIPE,
(* VAR  *) errno;

FROM sig IMPORT
(* CONST*) SIGINT, SIGQUIT,
(* PROC *) raise;

FROM DosSystem IMPORT
(* PROC *) DosVersion, FileLocking, MiNTVersion, MagiCVersion;

FROM DosFile IMPORT
(* CONST*) MinHandle, MaxHandle, getmask, setmask, TEOFC,
           TEOLC, TERASEC, TKILLC, TINTRC, TQUITC, TSUSPC, TSTARTC, TSTOPC,
           TLNEXTC, TWERASEC, TRPRNTC,
(* TYPE *) DosFlags, DosFlag, HandleRange, TTYmode, ttymode, FileType,
(* VAR  *) FD, TTYMODE,
(* PROC *) IsTerm;

FROM DosDir IMPORT
(* CONST*) AllEntries, DINCR, DDRVPOSTFIX,
(* TYPE *) DTA, FileAttributes, FileAttribute, XATTR,
(* VAR  *) INODE, UMASK,
(* PROC *) UnixToDos, DosToUnix, TstENOTDIR, FileExists, FindFirst;

(*==========================================================================*)

CONST
  EOKL      = LIC(0);
  UNLIMITED = LIC(1000000);

  FSTAT     = 4600H; (* ('F'<< 8)|0 *)
  FIONREAD  = 4601H; (* ('F'<< 8)|1 *)
  FIONWRITE = 4602H; (* ('F'<< 8)|2 *)
  TIOCGETP  = 5400H; (* ('T'<< 8)|0 *)
  TIOCGPGRP = 5406H; (* ('T'<< 8)|6 *)

CONST
  BLKSIZE = 1024;

CONST
  FRDLCK = 0;
  FWRLCK = 1;
  FUNLCK = 3;

TYPE
  FLOCK = RECORD
    type   : UNSIGNEDWORD;
    whence : UNSIGNEDWORD;
    start  : SIGNEDLONG;
    len    : SIGNEDLONG;
    pid    : SIGNEDWORD;
  END;

TYPE
  sgttyb = RECORD
    sgIspeed : CHAR;
    sgOspeed : CHAR;
    sgErase  : CHAR;
    sgKill   : CHAR;
    sgFlags  : WORDSET;
  END;

TYPE
  CharPtr = POINTER TO CHAR;

VAR
  zerofill   : ARRAY [0..BLKSIZE-1] OF CHAR;
  MiNT       : BOOLEAN;
  MagiC3     : BOOLEAN;
  DOSVersion : CARDINAL;
  crlf       : ARRAY [0..1] OF CHAR;
  cdel       : ARRAY [0..5] OF CHAR;
  escseq     : BOOLEAN;
  chesc      : CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE iopen ((* EIN/ -- *) VAR file   : ARRAY OF CHAR;
                 (* EIN/ -- *)     access : OpenModes;
                 (* EIN/ -- *)     mode   : modeT ): int;

VAR res     : INTEGER;
    handle  : INTEGER;
    fd      : HandleRange;
    accMask : OpenModes;
    attr    : WORDSET;
    lres    : SIGNEDLONG;
    arg     : SIGNEDLONG;
    done    : BOOLEAN;
    tty     : BOOLEAN;
    isdir   : BOOLEAN;
    tstdev  : BOOLEAN;
    exists  : BOOLEAN;
    xmode   : BOOLEAN;
    msize   : CARDINAL;
    stack   : ADDRESS;
    xattr   : XATTR;
    dta     : DTA;
    path0   : StrPtr;

BEGIN
 (* Pfadname DOS-konform gestalten *)
 msize := Length(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, tty, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(MINHANDLE-1);
 END;

 (* Flags ermitteln, die das OS selbst auswerten kann *)
 IF MiNT OR MagiC3 THEN
   accMask := oACCMODE + OpenModes{oAPPEND, oNONBLOCK, oCREAT, oTRUNC, oEXCL};
 ELSE
   accMask := oACCMODE;
 END;

 exists := FALSE;
 isdir  := FALSE;
 tstdev := FALSE;
 xmode  := FALSE;
 IF Fxattr(0, path0, ADR(xattr), res) THEN
   attr   := xattr.attr;
   isdir  := xattr.mode * sIFMT = sIFDIR;
   exists := TRUE;
   xmode  := TRUE;
 ELSIF res = eINVFN THEN
   IF FindFirst(path0, AllEntries, dta, res) THEN
     attr   := CAST(WORDSET,dta.attr);
     isdir  := faSUBDIR IN dta.attr;
     exists := TRUE;
   ELSE
     tstdev := TRUE; (* Auf CON: usw. testen *)
   END;
 END;

 IF exists THEN
   (* Datei existiert bereits *)
   IF OpenModes{oCREAT, oEXCL} <= access THEN
     (* Exklusiver Zugriff nicht moeglich *)
     handle := EEXIST;
   ELSE
     (* Datei im angegebenen Modus oeffnen *)
     done := Fopen(path0, access * accMask, handle);
     IF (oTRUNC IN access) & ~(oTRUNC IN accMask) & (handle >= 0) THEN
       (* OS kann oTRUNC bei einer normalen Datei (kein Geraet) nicht
        * selbst behandeln.
        *)
       done := Fclose(handle, res);
       IF access * oACCMODE = oRDONLY THEN
         (* Wenn die Datei nur zum Lesen geoeffnet wurde, ist kein
          * Kuerzen moeglich.
          *)
         handle := EACCES;
       ELSE
         (* Sonst wird die Datei neu erzeugt und mit dem gewuenschten
          * Zugriffsmodus geoeffnet. Die alten Dateiattribute werden
          * uebernommen (auch faHIDDEN und faSYSTEM).
          *)
         done :=   Fcreate(path0, 0, handle)
                 & Fclose(handle, handle)
                 & Fopen(path0, access * accMask, handle)
                 & Fattrib(path0, 1, attr, attr)
                 & xmode & Fchmod(path0, xattr.mode, res);
       END;
     END;
   END;
 ELSIF oCREAT IN access THEN
   (* Datei soll mit den angegebenen Attributen neu angelegt werden.
    * Die Prozessmaske muss auch fuer 'Fchmod' beruecksichtigt werden.
    *)
   mode := mode - UMASK;

   (* Datei erzeugen und im angegebenen Modus oeffnen *)
   IF oCREAT IN accMask THEN
     (* oCREAT wird vom OS erledigt *)
     done := Fopen(path0, access * accMask, handle);
   ELSE
     (* Sonst wird die Datei neu erzeugt und mit dem gewuenschten
      * Zugriffsmodus geoeffnet.
      *)
     done :=   Fcreate(path0, 0, handle)
             & Fclose(handle, handle)
             & Fopen(path0, access * accMask, handle);
   END;

   IF done THEN
     (* Attribute setzen, Fehler ignorieren *)
     IF ~Fchmod(path0, mode, res) & (res = eINVFN) THEN
       (* Leider nur TOS-Attribute moeglich *)
       attr := WORDSET{};
       IF ~(sIWUSR IN mode) THEN
         (* Fehlende Schreibberechtigung wird mit dem RDONLY-Attribut
          * simuliert, analog zu "stat()".
          *)
         INCL(attr, VAL(UNSIGNEDWORD,faRDONLY));
       END;
       IF ~(sIRUSR IN mode) THEN
         (* Fehlende Leseberechtigung wird mit dem HIDDEN-Attribut
          * simuliert, analog zu "stat()".
          *)
         INCL(attr, VAL(UNSIGNEDWORD,faHIDDEN));
       END;
       done := Fattrib(path0, 1, attr, attr);
     END;
   END;
 ELSIF ~(tstdev & Fopen(path0, access * accMask, handle)) THEN
   (* Datei existiert nicht und soll auch nicht neu angelegt werden.
    * Unter TOS trotzdem nochmal probieren die Datei zu oeffnen, falls
    * es sich um ein Geraet (CON: usw.) handelt, was nicht von 'FindFirst'
    * erkannt wird.
    *)
   handle := ENOENT;
 END;

 memdealloc(stack);
 IF handle < MINHANDLE THEN
   IF isdir & (handle = eFILNF) THEN
     (* Falls 'Fopen' keine Verzeichnisse oeffnen kann *)
     handle := EISDIR;
   ELSE
     TstENOTDIR(path0, FALSE, handle);
   END;
   errno := handle;
   RETURN(MINHANDLE-1);
 END;

 (* Die kleinste Kennung, die 'Fopen' fuer eine Datei liefert,
  * ist auch unter MiNT gleich 6. Falls aber eine kleinere Kennung
  * frei ist, kann diese stattdessen benutzt werden. Also wird
  * eine weitere Kennung fuer diese Datei erzeugt, und die kleinere
  * der beiden verwendet, waehrend die andere wieder freigegeben wird.
  *)
 IF Fcntl(handle, 0, ORD(fDUPFD), lres) THEN
   res := INT(lres);
   IF res < handle THEN
     (* Eine kleinere Kennung ist frei, also diese nehmen und die
      * andere freigeben.
      *)
     done   := Fclose(handle, handle);
     handle := res;
   ELSE
     (* Die von 'Fopen' gelieferte Kennung ist bereits die kleinste
      * freie gewesen, also die neue wieder freigeben.
      *)
     done := Fclose(res, res);
   END;
 END;

 (* MiNT schliesst normalerweise alle Dateikennungen, ausser den
  * Standardkanaelen, bei Ausfuehren eines 'Pexec'.
  *)
 IF Fcntl(handle, 0, ORD(fGETFD), lres) & ODD(lres) THEN
   (* 'FdCloExec'-Flag ist gesetzt, also loeschen. *)
   DEC(lres);
   done := Fcntl(handle, lres, ORD(fSETFD), lres);
 END;

 tty := IsTerm(handle);
 WITH FD[VAL(HandleRange,handle)] DO
   IF tty THEN
     ftype := istty;
   ELSE
     ftype := notty;
   END;
   flags := CAST(DosFlags,access); (* Wird von MiNT nicht beachtet *)
 END;

 IF tty THEN
   IF  ~(oNOCTTY IN access)
     & ~IsTerm(-1)
     & (Pgetpgrp() >= 0) & (Pgetpgrp() = Pgetpid())
     & Fcntl(handle, ADR(arg), TIOCGPGRP, lres)
     & (arg = VAL(SIGNEDLONG,0))
   THEN
     (* Wenn Handle -1 (aktuelles Kontrollterminal) kein Terminal ist
      * (auf /dev/null umgelenkt), aber die geoeffnete Datei, wird die neu
      * geoffnete Datei zum Kontrollterminal, wenn sie noch kein
      * Kontrollterminal eines anderen Prozesses ist, und der aufrufende
      * Prozess eine Prozessgruppe anfuehrt, ausser, sowas ist unerwuenscht.
      * (Kann nur unter MiNT auftreten.)
      *)
     done := Fforce(-1, handle, res);
     FD[VAL(HandleRange,-1)].ftype := istty;
   END;
 END;
 RETURN(handle);
END iopen;

(*--------------------------------------------------------------------------*)

PROCEDURE open3 ((* EIN/ -- *) REF file   : ARRAY OF CHAR;
                 (* EIN/ -- *)     access : OpenModes;
                 (* EIN/ -- *)     mode   : modeT         ): int;

BEGIN
 RETURN(iopen(file, access, mode));
END open3;

(*--------------------------------------------------------------------------*)

PROCEDURE creat ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     mode : modeT         ): int;

BEGIN
 RETURN(iopen(file, oWRONLY + OpenModes{oCREAT,oTRUNC}, mode));
END creat;

(*--------------------------------------------------------------------------*)

PROCEDURE open ((* EIN/ -- *) REF file   : ARRAY OF CHAR;
                (* EIN/ -- *)     access : OpenModes     ): int;

BEGIN
 RETURN(iopen(file, access, STDPERM));
END open;

(*--------------------------------------------------------------------------*)

PROCEDURE fcntl ((* EIN/ -- *)     h   : int;
                 (* EIN/ -- *)     cmd : FcntlCmd;
                 (* EIN/AUS *) VAR arg : FcntlArg ): int;

VAR done : BOOLEAN;
    res  : INTEGER;
    lres : SIGNEDLONG;
    lock : FLOCK;

BEGIN
 IF (h<MinHandle) OR (h>MaxHandle) THEN
   errno := EBADF;
   RETURN(-1);
 END;

 WITH arg DO
   CASE cmd OF
     fDUPFD:
       IF Fcntl(h, VAL(SIGNEDLONG,handle), ORD(fDUPFD), lres) THEN
         handle := INT(lres);
         (* 'FdCloExec'-Flag loeschen, falls gesetzt *)
         IF Fcntl(handle, 0, ORD(fGETFD), lres) & ODD(lres) THEN
           DEC(lres);
           done := Fcntl(handle, lres, ORD(fSETFD), lres);
         END;
         WITH FD[VAL(HandleRange,handle)] DO
           ftype := FD[VAL(HandleRange,h)].ftype;
           flags := DosFlags{};
         END;
         RETURN(0);
       ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
         IF Fdup(h, handle) THEN
           FD[VAL(HandleRange,handle)] := FD[VAL(HandleRange,h)];
           RETURN(0);
         ELSE
           errno := handle;
           RETURN(-1);
         END;
       ELSE
         errno := INT(lres);
         RETURN(-1);
       END;
    |fGETFD:
       IF Fcntl(h, VAL(UNSIGNEDLONG,0), ORD(fGETFD), lres) THEN
         fdflags := CAST(FDFlags,VAL(UNSIGNEDWORD,lres));
         RETURN(0);
       ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
         fdflags := FDFlags{};
         RETURN(0);
       ELSE
         errno := INT(lres);
         RETURN(-1);
       END;
    |fSETFD:
       IF Fcntl(h, VAL(UNSIGNEDLONG,CAST(UNSIGNEDWORD,fdflags)),
                ORD(fSETFD),
                lres)
       THEN
         RETURN(0);
       ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
         RETURN(0);
       ELSE
         errno := INT(lres);
         RETURN(-1);
       END;
    |fGETFL:
       IF Fcntl(h, VAL(UNSIGNEDLONG,0), ORD(fGETFL), lres) THEN
         mode := CAST(OpenModes,VAL(UNSIGNEDWORD,lres));
         RETURN(0);
       ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
         mode := CAST(OpenModes,FD[VAL(HandleRange,h)].flags * getmask);
         RETURN(0);
       ELSE
         errno := INT(lres);
         RETURN(-1);
       END;
    |fSETFL:
       IF Fcntl(h, VAL(UNSIGNEDLONG,CAST(UNSIGNEDWORD,mode)),
                ORD(fSETFL),
                lres)
       THEN
         RETURN(0);
       ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
         WITH FD[VAL(HandleRange,h)] DO
           flags := flags * setmask + (CAST(DosFlags,mode) - setmask);
         END;
         RETURN(0);
       ELSE
         errno := INT(lres);
         RETURN(-1);
       END;
    |fGETLK,
     fSETLK,
     fSETLKW:
       WITH flock DO WITH lock DO
         IF lType <= fWRLCK THEN
           type := VAL(UNSIGNEDWORD,lType);
         ELSE
           type := FUNLCK;
         END;
         whence := VAL(UNSIGNEDWORD,lWhence);
         start  := VAL(SIGNEDLONG,lStart);
         len    := VAL(SIGNEDLONG,lLen);
         pid    := VAL(SIGNEDWORD,lPid);
       END; END;

       IF Fcntl(h, ADR(lock), ORD(cmd), lres) THEN
         WITH flock DO WITH lock DO
           IF type <= FWRLCK THEN
             lType := VAL(LockType,type);
           ELSE
             lType := fUNLCK;
           END;
           lWhence := VAL(SeekMode,whence);
           lStart  := VAL(offT,start);
           lLen    := VAL(offT,len);
           lPid    := VAL(pidT,pid);
         END; END;
         RETURN(0);
       ELSIF (lres = VAL(SIGNEDLONG,eINVFN))
           & (cmd = fSETLK)
           & FileLocking()
       THEN
         WITH flock DO
           IF  (lType # fRDLCK) & (lWhence = SeekSet)
             & Flock(h, ORD(lType), lStart, lLen, res)
           THEN
             RETURN(0);
           ELSE
             lres := VAL(SIGNEDLONG,res);
           END;
         END;
       END;

       res := INT(lres);
       IF res = eINVFN THEN
         errno := EINVAL;
       ELSIF (res = eLOCKED) OR (res = eNSLOCK) THEN
         errno := EACCES;
       ELSE
         errno := res;
       END;
       RETURN(-1);
   ELSE
     errno := EINVAL;
     RETURN(-1);
   END; (* CASE *)
 END; (* WITH arg *)
END fcntl;

(*--------------------------------------------------------------------------*)

PROCEDURE close ((* EIN/ -- *) h : int ): int;

VAR res : INTEGER;

BEGIN
 IF (h<MinHandle) OR (h>MaxHandle) THEN
   errno := EBADF;
   RETURN(-1);
 END;
 IF Fclose(h, res) THEN
   WITH FD[VAL(HandleRange,h)] DO
     ftype := unknown;
     flags := DosFlags{};
   END;
   RETURN(0);
 ELSE
   errno := res;
   RETURN(-1);
 END;
END close;

(*---------------------------------------------------------------------------*)

PROCEDURE TTYread ((* EIN/ -- *) hd  : INTEGER;
                   (* EIN/ -- *) buf : ADDRESS;
                   (* EIN/ -- *) len : SIGNEDLONG ): SIGNEDLONG;

VAR __REG__ ch    : CHAR;
    __REG__ cnt   : SIGNEDLONG;
    __REG__ to    : CharPtr;
            c     : CHAR;
            tmode : TTYmode;
            sigch : BOOLEAN;
            res   : INTEGER;
            lres  : SIGNEDLONG;
            void  : BOOLEAN;
            i     : SIGNEDLONG;


PROCEDURE devReady ( ): BOOLEAN;
BEGIN
 CASE hd OF
   -3..-1: RETURN(escseq OR Bconstat(hd+3));
  |0     : RETURN(escseq OR Cconis());
  |2     : RETURN(Cauxis());
 ELSE      RETURN(escseq OR Bconstat(2)); (* Nicht feststellbar, Konsole annehmen *)
 END;
END devReady;

PROCEDURE devReadChar ( ): CHAR;

CONST
  KINS   = 122C;
  KDEL   = 123C;
  KHOME  = 107C;
  KUNDO  = 141C;
  KHELP  = 142C;
  CURSUP = 110C;
  CURSDN = 120C;
  CURSRT = 115C;
  CURSLF = 113C;
  F1     = 73C;
  F10    = 104C;
  SHF1   = 124C;
  SHF10  = 135C;

TYPE
  KEYCODE = RECORD
    CASE TAG_COLON BOOLEAN OF
      FALSE: long   : UNSIGNEDLONG;
     |TRUE : kbshft : CHAR;
             scan   : CHAR;
             fill   : CHAR;
             ascii  : CHAR;
    END;
  END;

VAR key : KEYCODE;

BEGIN
 IF escseq THEN
   escseq := FALSE;
   RETURN(chesc);
 END;

 WITH key DO
   CASE hd OF
     -3..-1: long := Bconin(hd+3);
    |0     : long := Crawcin();
    |2     : RETURN(CHR(Cauxin()));
   ELSE      long := Bconin(2); (* Nicht feststellbar, Konsole annehmen *)
   END;
   IF ~tmode.xkey THEN
     RETURN(ascii);
   END;

   escseq := TRUE;
   IF (ascii = 0C) & (scan > 0C) THEN
     CASE scan OF
       CURSUP      : chesc := 'A';
      |CURSDN      : chesc := 'B';
      |CURSRT      : chesc := 'C';
      |CURSLF      : chesc := 'D';
      |KHELP       : chesc := 'H';
      |KUNDO       : chesc := 'K';
      |KINS        : chesc := 'I';
      |KHOME       : chesc := 'E';
      |F1..F10     : chesc := CHR(ORD('P') + ORD(scan) - ORD(F1));
      |SHF1..SHF10 : chesc := CHR(ORD('p') + ORD(scan) - ORD(SHF1));
     ELSE            escseq := FALSE;
                     RETURN(0C);
     END;
   ELSIF (scan = CURSUP) & (ascii = '8') THEN
     chesc := 'a';
   ELSIF (scan = CURSDN) & (ascii = '2') THEN
     chesc := 'b';
   ELSIF (scan = CURSRT) & (ascii = '6') THEN
     chesc := 'c';
   ELSIF (scan = CURSLF) & (ascii = '4') THEN
     chesc := 'd';
   ELSIF (scan = KINS)   & (ascii = '0') THEN
     chesc := 'i';
   ELSIF (scan = KHOME)  & (ascii = '7') THEN
     chesc := 'e';
   ELSE
     escseq := FALSE;
     RETURN(ascii);
   END;
   RETURN(ESC);
 END;
END devReadChar;

PROCEDURE devEraseChar ((* EIN/ -- *) ch : CHAR );
BEGIN
 IF (ch < ' ') & (ch # HT) OR (ch = DEL) THEN
   void := Fwrite(hd, 6, ADR(cdel), lres);
 ELSE
   void := Fwrite(hd, 3, ADR(cdel), lres);
 END;
END devEraseChar;

PROCEDURE devEchoChar ((* EIN/ -- *) ch : CHAR );
BEGIN
 IF (ch < ' ') & (ch # HT) OR (ch = DEL) THEN
   c    := '^';
   void := Fwrite(hd, 1, ADR(c), lres);
   IF ch = DEL THEN
     ch := '?';
   ELSE
     ch := CHR(ORD(ch) + ORD('@'));
   END;
 END;
 void := Fwrite(hd, 1, ADR(ch), lres);
END devEchoChar;

BEGIN (* TTYread *)
 tmode := TTYMODE;
 to    := buf;
 cnt   := 0;
 IF tmode.mode = raw THEN
   WHILE cnt < len DO
     ch  := devReadChar();
     to^ := ch;
     to  := ADDADR(to, 1);
     INC(cnt);
     IF tmode.echo THEN
       devEchoChar(ch);
     END;
     IF ~devReady() THEN
       (* MIN = 1 *)
       RETURN(cnt);
     END;
   END;
   RETURN(cnt);
 END;

 WHILE cnt < len DO
   ch := devReadChar();
   IF tmode.crmod & (ch = CR) THEN
     ch := LF;
   END;
   sigch := (ch = TINTRC) OR (ch = TQUITC);
   IF sigch THEN
     IF ~tmode.noflsh THEN
       cnt := 0;
       to  := buf;
     END;
     IF ch = TINTRC THEN
       res := raise(SIGINT);
     ELSE
       res := raise(SIGQUIT);
     END;
   END;
   IF tmode.mode = cbreak THEN
     IF ~sigch THEN
       IF tmode.echo THEN
         IF (ch = LF) & tmode.crmod THEN
           void := Fwrite(hd, 2, ADR(crlf), lres);
         ELSE
           devEchoChar(ch);
         END;
       END;
       to^ := ch;
       to  := ADDADR(to, 1);
       INC(cnt);
     END;
     IF ~devReady() THEN
       (* MIN = 1 *)
       RETURN(cnt);
     END;
   ELSE (* mode = cooked *)
     CASE ch OF
       TINTRC, TQUITC:  (* Nicht in die Eingabe uebernehmen *)
      |TSTARTC:
      |TSTOPC:
      |TLNEXTC:
         IF tmode.echo THEN
           c := '^'; void := Fwrite(hd, 1, ADR(c), lres);
           c := BS;  void := Fwrite(hd, 1, ADR(c), lres);
         END;
         ch := devReadChar();
         IF tmode.echo THEN
           devEchoChar(ch);
         END;
         to^ := ch;
         to  := ADDADR(to, 1);
         INC(cnt);
      |TEOFC:
         RETURN(cnt);
      |LF, TEOLC:
         to^ := ch;
         to  := ADDADR(to, 1);
         INC(cnt);
         IF tmode.echo THEN
           void := Fwrite(hd, 2, ADR(crlf), lres);
         END;
         RETURN(cnt);
      |TERASEC:
         IF cnt > VAL(SIGNEDLONG,0) THEN
           DEC(cnt);
           to := SUBADR(to, 1);
           IF tmode.echo THEN
             devEraseChar(to^);
           END;
         END;
      |TKILLC, TRPRNTC:
         IF tmode.echo THEN
           void := Fwrite(hd, 2, ADR(crlf), lres);
         END;
         IF ch = TKILLC THEN
           to  := buf;
           cnt := 0;
         ELSIF tmode.echo THEN
           to := buf;
           i  := 0;
           WHILE i < cnt DO
             devEchoChar(to^);
             to := ADDADR(to, 1);
             INC(i);
           END;
         END;
      |TWERASEC:
         to := SUBADR(to, 1);
         WHILE (cnt > VAL(SIGNEDLONG,0)) & isblank(to^) DO
           DEC(cnt);
           to := SUBADR(to, 1);
           IF tmode.echo THEN
             devEraseChar(to^);
           END;
         END;
         WHILE (cnt > VAL(SIGNEDLONG,0)) & ~isblank(to^) DO
           DEC(cnt);
           to := SUBADR(to, 1);
           IF tmode.echo THEN
             devEraseChar(to^);
           END;
         END;
         to := ADDADR(to, 1);
     ELSE
       IF tmode.echo THEN
         devEchoChar(ch);
       END;
       to^ := ch;
       to  := ADDADR(to, 1);
       INC(cnt);
     END; (* CASE *)
   END; (* IF tmode.mode *)
 END; (* WHILE *)
 RETURN(cnt);
END TTYread;

(*---------------------------------------------------------------------------*)

PROCEDURE read ((* EIN/ -- *) h   : int;
                (* EIN/ -- *) buf : ADDRESS;
                (* EIN/ -- *) len : sizeT   ): ssizeT;

VAR lres   : SIGNEDLONG;
    lres2  : SIGNEDLONG;
    toread : SIGNEDLONG;
    sgb    : sgttyb;

BEGIN
 IF ~Fcntl(h, ADR(sgb), TIOCGETP, lres) & (INT(lres) = eINVFN) THEN
   (* ANNAHME: Wenn sich die Terminalparameter nicht feststellen lassen,
    * handelt es sich entweder nicht um ein Terminal oder die Eigenschaften
    * des Terminals lassen sich nicht vom Betriebssystem konfigurieren.
    *)
   IF (h<MinHandle) OR (h>MaxHandle) THEN
     errno := EBADF;
     RETURN(-1);
   END;
   WITH FD[VAL(HandleRange,h)] DO
     IF ftype = unknown THEN
       IF IsTerm(h) THEN
         ftype := istty;
       ELSE
         ftype := notty;
       END;
     END;

     IF ftype = istty THEN
       (* Wenns ein Terminal ist, dann *IX-read emulieren *)
       RETURN(TTYread(h, buf, len));
     END;
   END;
 END;

 IF Fread(h, VAL(UNSIGNEDLONG,len), buf, lres) THEN
   (* Wenn nichts gelesen wurde und sich die Datei im nicht blockierenden
    * Modus befindet und noch was zum Lesen da ist, POSIX-Fehlermeldung
    * EAGAIN liefern.
    * Abfrage aus Kay Roemers 'portlib' fuer MiNT-Net.
    *)
   IF (lres = VAL(SIGNEDLONG,0)) & (len # VAL(sizeT,0)) THEN
     IF  Fcntl(h, 0, ORD(fGETFL), lres2)
       & (oNONBLOCK IN CAST(OpenModes,VAL(UNSIGNEDWORD,lres2)))
     THEN
       IF  Fcntl(h, ADR(toread), FIONREAD, lres2)
         & (toread >= VAL(SIGNEDLONG,0)) & (toread < UNLIMITED)
       THEN
         errno := EAGAIN;
         RETURN(-1);
       END;
     END;
   END;
   RETURN(VAL(ssizeT,lres));
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END read;

(*--------------------------------------------------------------------------*)

PROCEDURE TTYwrite ((* EIN/ -- *) h   : INTEGER;
                    (* EIN/ -- *) buf : ADDRESS;
                    (* EIN/ -- *) len : SIGNEDLONG ): SIGNEDLONG;

VAR         lf    : BOOLEAN;
            lres  : SIGNEDLONG;
    __REG__ size  : SIGNEDLONG;
    __REG__ cnt   : SIGNEDLONG;
            lfadr : ADDRESS;

BEGIN
 IF (TTYMODE.mode # raw) & (TTYMODE.crmod) THEN
   size := len;
   WHILE size > VAL(SIGNEDLONG,0) DO
     lfadr := memchr(buf, ORD(LF), size);
     IF lfadr = NULL THEN
       cnt := size;
       lf  := FALSE;
     ELSE
       cnt := DIFADR(lfadr, buf);
       lf  := TRUE;
     END;

     IF Fwrite(h, CAST(UNSIGNEDLONG,cnt), buf, lres) THEN
       IF cnt # lres THEN
         RETURN(len - (size - lres));
       END;
     ELSE
       errno := INT(lres);
       RETURN(-1);
     END;
     IF lf THEN
       lf := Fwrite(h, 2, ADR(crlf), lres);
       INC(cnt);
     END;
     DEC(size, cnt);
     buf := ADDADR(buf, cnt);
   END;
   RETURN(len);
 ELSE
   IF Fwrite(h, len, buf, lres) THEN
     RETURN(lres);
   ELSE
     errno := INT(lres);
     RETURN(-1);
   END;
 END;
END TTYwrite;

(*--------------------------------------------------------------------------*)

PROCEDURE write ((* EIN/ -- *) h   : int;
                 (* EIN/ -- *) buf : ADDRESS;
                 (* EIN/ -- *) len : sizeT   ): ssizeT;

VAR lres     : SIGNEDLONG;
    lres2    : SIGNEDLONG;
    xattr    : XATTR;
    towrite  : SIGNEDLONG;
    void     : BOOLEAN;
    nonblock : BOOLEAN;
    sgb      : sgttyb;
    mode     : OpenModes;

BEGIN
 IF (h<MinHandle) OR (h>MaxHandle) THEN
   errno := EBADF;
   RETURN(-1);
 END;

 IF ~Fcntl(h, ADR(sgb), TIOCGETP, lres) & (INT(lres) = eINVFN) THEN
   (* ANNAHME: Wenn sich die Terminalparameter nicht feststellen lassen,
    * handelt es sich entweder nicht um ein Terminal oder die Eigenschaften
    * des Terminals lassen sich nicht vom Betriebssystem konfigurieren.
    *)
   WITH FD[VAL(HandleRange,h)] DO
     IF ftype = unknown THEN
       IF IsTerm(h) THEN
         ftype := istty;
       ELSE
         ftype := notty;
       END;
     END;

     IF ftype = istty THEN
       (* Wenns ein Terminal ist, dann *IX-write emulieren *)
       RETURN(TTYwrite(h, buf, len));
     END;
   END;
 END;

 IF Fcntl(h, 0, ORD(fGETFL), lres) THEN
   nonblock := oNONBLOCK IN CAST(OpenModes,VAL(UNSIGNEDWORD,lres));
 ELSE
   nonblock := FALSE;
   IF (INT(lres) = eINVFN) & (append IN FD[VAL(HandleRange,h)].flags) THEN
     (* Betriebssystem kann O_APPEND nicht selbst behandeln *)
     void := Fseek(0, h, ORD(SeekEnd), lres);
   END;
 END;

 IF Fwrite(h, VAL(UNSIGNEDLONG,len), buf, lres) THEN
   (* Wenn bei einer regulaeren Datei nichts geschrieben wurde, aber
    * trotzdem keine Fehlermeldung kam, POSIX-Fehlermeldung ENOSPC liefern.
    * Wenn es keine regulaere Datei ist und nichts geschrieben wurde
    * und sich die Datei im nicht blockierenden Modus befindet und noch
    * etwas geschrieben werden kann, POSIX-Fehlermeldung EAGAIN liefern.
    * Abfrage aus Kay Roemers 'portlib' fuer MiNT-net.
    *)
   IF (lres = VAL(SIGNEDLONG,0)) & (len # VAL(sizeT,0)) THEN
     IF ~Fcntl(h, ADR(xattr), FSTAT, lres2)
        OR (xattr.mode * sIFMT = sIFREG)
     THEN
       (* Regulaere Datei *)
       errno := ENOSPC;
       RETURN(-1);
     END;

     IF nonblock THEN
       IF  Fcntl(h, ADR(towrite), FIONWRITE, lres2)
         & (towrite >= VAL(SIGNEDLONG,0)) & (towrite < UNLIMITED)
       THEN
         errno := EAGAIN;
         RETURN(-1);
       END;
     END;
   END;
   RETURN(VAL(ssizeT,lres));
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END write;

(*--------------------------------------------------------------------------*)

PROCEDURE lseek ((* EIN/ -- *) h    : int;
                 (* EIN/ -- *) off  : offT;
                 (* EIN/ -- *) mode : SeekMode ): offT;

CONST ERANGEL = LIC(-64);
      EACCDNL = LIC(-36);

VAR lres   : SIGNEDLONG;
    curPos : SIGNEDLONG;
    newPos : SIGNEDLONG;
    len    : SIGNEDLONG;
    done   : BOOLEAN;

BEGIN
 len := VAL(SIGNEDLONG,off);

 IF len <= VAL(SIGNEDLONG,0) THEN
   (* Datei braucht nicht verlaengert zu werden *)
   IF Fseek(len, h, ORD(mode), lres) THEN
     RETURN(VAL(offT,lres));
   ELSIF (MiNT OR MagiC3) & (lres = EACCDNL) THEN
     errno := ESPIPE;
   ELSE
     errno := INT(lres);
   END;
   RETURN(-1);
 END;

 (* Augenblickliche Position feststellen, bei 'SeekEnd' gleich
  * ans Ende der Datei.
  *)
 IF mode = SeekEnd THEN
   done := Fseek(0, h, ORD(SeekEnd), curPos);
 ELSE
   done := Fseek(0, h, ORD(SeekCur), curPos);
 END;
 IF ~done THEN
   IF (MiNT OR MagiC3) & (curPos = EACCDNL) THEN
     errno := ESPIPE;
   ELSE
     errno := INT(curPos);
   END;
   RETURN(-1);
 END;

 (* gewuenschte Position berechnen. 'SeekEnd' und 'SeekCur' koennen
  * gleichbehandelt werden, da der Zeiger bei 'SeekEnd' schon am
  * Ende der Datei steht.
  *)
 IF mode = SeekSet THEN
   newPos := len;
 ELSE
   newPos := curPos + len;
 END;

 (* Es kann sein (ist auch meistens der Fall), dass die gewuenschte
  * Position innerhalb der bestehenden Datei liegt. Deswegen wird zuerst
  * versucht, die gewuenschte Position direkt anzufahren. Wenn dabei ein
  * ``Range-Fehler'' auftritt, muss die Datei verlaengert werden.
  * Ein ``Range-Fehler'' tritt nicht auf, wenn das Dateisystem
  * (z.B. MinixFS) ein Fseek hinter das Dateiende selbst verwaltet.
  *)
 done := Fseek(len, h, ORD(mode), curPos);
 IF curPos = newPos THEN
   RETURN(VAL(offT,curPos));
 ELSIF ~done & (curPos # ERANGEL) THEN
   errno := INT(curPos);
   RETURN(-1);
 END;


 done := Fseek(0, h, ORD(SeekEnd), curPos);

 (* Solange Nullbytes schreiben, bis die Datei auf die gewuenschte
  * Laenge gebracht ist.
  *)
 REPEAT
   len := newPos - curPos;
   IF len > VAL(SIGNEDLONG,BLKSIZE)  THEN
     len := VAL(SIGNEDLONG,BLKSIZE);
   END;
   done := Fwrite(h, len, ADR(zerofill), lres);
   IF lres # len  THEN
     IF done THEN
       RETURN(VAL(offT,curPos + lres));
     ELSE
       errno := INT(lres);
       RETURN(VAL(offT,curPos));
     END;
   END;
   INC(curPos, len);
 UNTIL curPos >= newPos;
 RETURN(VAL(offT,curPos));
END lseek;

(*--------------------------------------------------------------------------*)

PROCEDURE ftruncate ((* EIN/ -- *) h   : int;
                     (* EIN/ -- *) len : offT ): int;

CONST FTRUNCATE = 4604H; (* ('F'<<8)|4 *)

VAR lres : SIGNEDLONG;

BEGIN
 IF Fcntl(h, ADR(len), FTRUNCATE, lres) THEN
   RETURN(0);
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END ftruncate;

(*--------------------------------------------------------------------------*)

PROCEDURE dup ((* EIN/ -- *) h : int ): int;

VAR lres : SIGNEDLONG;
    done : BOOLEAN;
    newh : INTEGER;

BEGIN
 IF (h<MinHandle) OR (h>MaxHandle) THEN
   errno := EBADF;
   RETURN(-1);
 END;

 IF Fcntl(h, 0, ORD(fDUPFD), lres) THEN
   newh := INT(lres);
   (* 'FdCloExec'-Flag loeschen, falls gesetzt *)
   IF Fcntl(newh, 0, ORD(fGETFD), lres) & ODD(lres) THEN
     DEC(lres);
     done := Fcntl(newh, lres, ORD(fSETFD), lres);
   END;
   WITH FD[VAL(HandleRange,newh)] DO
     ftype := FD[VAL(HandleRange,h)].ftype;
     flags := DosFlags{};
   END;
   RETURN(newh);
 ELSIF lres = VAL(SIGNEDLONG,eINVFN) THEN
   IF Fdup(h, newh) THEN
     FD[VAL(HandleRange,newh)] := FD[VAL(HandleRange,h)];
     RETURN(newh);
   ELSE
     errno := newh;
     RETURN(-1);
   END;
 ELSE
   errno := INT(lres);
   RETURN(-1);
 END;
END dup;

(*--------------------------------------------------------------------------*)

PROCEDURE dup2 ((* EIN/ -- *) oldh : int;
                (* EIN/ -- *) newh : int ): int;

VAR res  : INTEGER;
    lres : SIGNEDLONG;
    void : BOOLEAN;

BEGIN
 IF oldh = newh THEN
   RETURN(newh);
 END;
 IF   (oldh < MinHandle) OR (oldh > MaxHandle)
   OR (newh < MinHandle) OR (newh > MaxHandle)
 THEN
   errno := EBADF;
   RETURN(-1);
 END;

 (* Das Schliessen eines Standardkanals macht eine vorherige
  * Umleitung rueckgaengig. Ist aber erst seit GEMDOS 0.15
  * anwendbar.
  *)
 IF DOSVersion >= 1500H THEN
   void := Fclose(newh, res);
 END;

 IF Fforce(newh, oldh, res) THEN
   (* 'FdCloExec'-Flag loeschen, falls gesetzt *)
   IF Fcntl(newh, 0, ORD(fGETFD), lres) & ODD(lres) THEN
     DEC(lres);
     void := Fcntl(newh, lres, ORD(fSETFD), lres);
   END;
   FD[VAL(HandleRange,newh)] := FD[VAL(HandleRange,oldh)];
   RETURN(newh);
 ELSE
   errno := res;
   RETURN(-1);
 END;
END dup2;

(*--------------------------------------------------------------------------*)

PROCEDURE pipe ((* -- /AUS *) VAR ph : PipeBuf ): int;

VAR handle : ARRAY [0..1] OF SIGNEDWORD;
    res    : INTEGER;

BEGIN
 ph[0] := 0;
 ph[1] := 0;
 IF Fpipe(ADR(handle), res) THEN
   ph[0] := INT(handle[0]);
   ph[1] := INT(handle[1]);
   (* Mit 'Fpipe' erzeugte Pipes koennen keine Pseudoterminals sein *)
   FD[handle[0]].ftype := notty;
   FD[handle[1]].ftype := notty;
   RETURN(0);
 ELSE
   (* 'Fpipe'-Aufruf wird nicht unterstuetzt oder anderer Fehler *)
   errno := res;
   RETURN(-1);
 END;
END pipe;

(*==========================================================================*)

BEGIN (* file *)
 crlf[0] := CR;
 crlf[1] := LF;
 cdel[0] := BS;
 cdel[1] := ' ';
 cdel[2] := BS;
 cdel[3] := BS;
 cdel[4] := ' ';
 cdel[5] := BS;
 memset(ADR(zerofill), 0, BLKSIZE);
 escseq     := FALSE;
 DOSVersion := DosVersion();
 MiNT       := MiNTVersion() > 0;
 MagiC3     := MagiCVersion() >= 0300H;
END file.
