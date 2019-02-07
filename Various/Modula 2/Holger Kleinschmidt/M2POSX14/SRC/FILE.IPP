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
(* 18-Apr-94, Holger Kleinschmidt                                            *)
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

FROM MEMBLK IMPORT
(* PROC *) memalloc, memdealloc;

FROM OSCALLS IMPORT
(* PROC *) Fcreate, Fopen, Fclose, Fdelete, Fread, Fwrite, Fseek, Flock,
           Fcntl, Fdup, Fforce, Pumask, Fchmod, Fattrib, Fchown, Fdatime,
           Fpipe, Fxattr, Dgetdrv, Pgetuid, Pgetgid, Tgettime, Tgetdate,
           Freadlink, Dcntl, Pgetpgrp, Pgetpid;

FROM ctype IMPORT
(* PROC *) tocard;

FROM cstr IMPORT
(* PROC *) strlen, AssignM2ToC;

FROM pSTRING IMPORT
(* PROC *) SLEN, APPEND;

FROM types IMPORT
(* CONST*) EOS, DDRVPOSTFIX, DDIRSEP,
(* TYPE *) int, PathName, uidT, gidT, inoT, timeT, offT, sizeT, ssizeT, devT,
           pidT, StrPtr, StrRange, TimeCast;

IMPORT e;

FROM DosSystem IMPORT
(* PROC *) DosVersion, FileLocking, FcntlAvail, MiNTVersion;

FROM DosSupport IMPORT
(* CONST*) FINDALL, DINCR, MinHandle, MaxHandle, getmask, setmask,
(* TYPE *) DTA, FileAttributes, FileAttribute, DosFlags, DosFlag, HandleRange,
           FileType, DosDate,
(* VAR  *) INODE, FD,
(* PROC *) IsTerm, IsDosDevice, UnixToDos, FindFirst, IsExec, DosToUnix,
           DecodeDate, EncodeDate, DateToSeconds, SecondsToDate;

(*==========================================================================*)

CONST
  EOKL  = LIC(0);
  FSTAT = 00004600H;

  BLKSIZE  = 1024;
  LBLKSIZE = 256; (* BLKSIZE DIV 4 *)

  STDPERM = modeT{sIRUSR,sIWUSR,sIRGRP,sIWGRP,sIROTH,sIWOTH};

TYPE
  XATTR = RECORD
    mode    : modeT;
    index   : UNSIGNEDLONG;
    dev     : UNSIGNEDWORD;
    rdev    : UNSIGNEDWORD; (* Ab MiNT 1.10 mit sinnvollem Wert *)
    nlink   : UNSIGNEDWORD;
    uid     : UNSIGNEDWORD;
    gid     : UNSIGNEDWORD;
    size    : SIGNEDLONG;
    blksize : SIGNEDLONG;
    nblocks : SIGNEDLONG;
    mtime   : WORDSET;
    mdate   : WORDSET;
    atime   : WORDSET;
    adate   : WORDSET;
    ctime   : WORDSET;
    cdate   : WORDSET;
    attr    : WORDSET;
    res2    : SIGNEDWORD;
    res3    : ARRAY [0..1] OF SIGNEDLONG;
  END;

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

VAR
  UMASK      : modeT;
  zerofill   : ARRAY [0..LBLKSIZE-1] OF UNSIGNEDLONG;
  hasFcntl   : BOOLEAN; (* Wird 'Fcntl'-Aufruf unterstuetzt ? *)
  MiNT       : BOOLEAN; (* Ist MiNT aktiv ? *)
  DOSVersion : CARDINAL;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE open ((* EIN/ -- *) REF file   : ARRAY OF CHAR;
                (* EIN/ -- *)     access : OpenMode;
                (* EIN/ -- *)     mode   : modeT         ): int;

CONST TIOCGPGRP = 5406H; (* ('T'<<8)|6 *)

VAR res     : INTEGER;
    handle  : INTEGER;
    fd      : HandleRange;
    accMask : OpenMode;
    attr    : WORDSET;
    lres    : SIGNEDLONG;
    arg     : SIGNEDLONG;
    done    : BOOLEAN;
    tty     : BOOLEAN;
    msize   : CARDINAL;
    stack   : ADDRESS;
    path0   : StrPtr;

BEGIN
 (* Pfadname DOS-konform gestalten *)
 msize := SLEN(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, tty, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(MINHANDLE-1);
 END;

 (* Flags ermitteln, die das OS selbst auswerten kann *)
 IF hasFcntl THEN
   (* ANNAHME: Wenn 'Fcntl' unterstuetzt wird, kann das OS den Dateimodus
    *          selbst verwalten.
    *)
   accMask := oACCMODE + OpenMode{oAPPEND, oNONBLOCK, oCREAT, oTRUNC, oEXCL};
 ELSE
   accMask := oACCMODE;
 END;

 IF Fattrib(path0, 0, 0, attr) THEN
   (* Datei existiert bereits *)
   IF OpenMode{oCREAT, oEXCL} <= access THEN
     (* Exklusiver Zugriff nicht moeglich *)
     handle := e.EEXIST;
   ELSE
     (* Datei im angegebenen Modus oeffnen *)
     done := Fopen(path0, access * accMask, handle);
     IF NOT hasFcntl AND (oTRUNC IN access) AND (handle >= 0) THEN
       (* TOS kann oTRUNC bei einer normalen Datei (kein Geraet) nicht
        * selbst behandeln.
        *)
       done := Fclose(handle, res);
       IF access * oACCMODE = oRDONLY THEN
         (* Wenn die Datei nur zum Lesen geoeffnet wurde, ist kein
          * Kuerzen moeglich.
          *)
         handle := e.EACCES;
       ELSE
         (* Sonst wird die Datei neu erzeugt und mit dem gewuenschten
          * Zugriffsmodus geoeffnet. Die alten Dateiattribute werden
          * uebernommen (auch faHIDDEN und faSYSTEM).
          *
          * Unter alten TOS-Versionen wurde nach einem 'Fcreate' eine
          * alte Datei gleichen Namens manchmal nicht geloescht, deswegen
          * zuerst das 'Fdelete'.
          *)
         done :=     Fdelete(path0, handle)
                 AND Fcreate(path0, 0, handle)
                 AND Fclose(handle, handle)
                 AND Fopen(path0, access * accMask, handle)
                 AND Fattrib(path0, 1, attr, attr);
       END;
     END;
   END;
 ELSIF oCREAT IN access THEN
   (* Datei soll mit den angegebenen Attributen neu angelegt werden *)
   mode := mode - UMASK;
   (* Auch fuer MiNT, da 'Fchmod' die Prozessmaske nicht beruecksichtigt *)
   IF hasFcntl THEN
     (* oCREAT wird vom OS erledigt *)
     done :=     Fopen(path0, access * accMask, handle)
             AND Fchmod(path0, mode, res);
   ELSE
     (* Sonst wird die Datei neu erzeugt und mit dem gewuenschten
      * Zugriffsmodus geoeffnet. Fuer die Attribute der neuen Datei
      * wird die Prozessmaske beruecksichtigt.
      *)
     IF sIWUSR IN mode THEN
       attr := WORDSET{};
     ELSE
       attr := CAST(WORDSET,FileAttribute{faRDONLY});
     END;
     done :=     Fcreate(path0, 0, handle)
             AND Fclose(handle, handle)
             AND Fopen(path0, access * accMask, handle)
             AND Fattrib(path0, 1, attr, attr);
   END;
 ELSE
   (* Datei existiert nicht und soll auch nicht neu angelegt werden *)
   handle := e.ENOENT;
 END;

 memdealloc(stack);
 IF handle < MINHANDLE THEN
   e.errno := handle;
   RETURN(MINHANDLE-1);
 END;

 tty := IsTerm(handle);

 IF hasFcntl THEN
   (* Die kleinste Kennung, die 'Fopen' fuer eine Datei liefert,
    * ist auch unter MiNT gleich 6. Falls aber eine kleinere Kennung
    * frei ist, kann diese stattdessen benutzt werden. Also wird
    * eine weitere Kennung fuer diese Datei erzeugt, und die kleinere
    * der beiden verwendet, waehrend die andere wieder freigegeben wird.
    * Eine andere Kennung veraendert nicht das Ergebnis von "IsTerm"!
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
   done := Fcntl(handle, 0, ORD(fGETFD), lres);
   IF ODD(lres) THEN
     DEC(lres);
   END;
   done := Fcntl(handle, lres, ORD(fSETFD), lres);
   IF tty THEN
     FD[VAL(HandleRange,handle)].ftype := istty;
     IF    NOT(oNOCTTY IN access)
       AND NOT IsTerm(-1)
       AND (Pgetpgrp() >= 0) AND (Pgetpgrp() = Pgetpid())
       AND Fcntl(handle, ADR(arg), TIOCGPGRP, lres)
       AND (arg = VAL(SIGNEDLONG,0))
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
   ELSE
     FD[VAL(HandleRange,handle)].ftype := notty;
   END;
 ELSE
   WITH FD[VAL(HandleRange,handle)] DO
     cloex := FALSE;
     IF tty THEN
       ftype := istty;
     ELSE
       ftype := notty;
     END;
     flags := CAST(DosFlag,access);
   END;
 END; (* IF MiNT *)
 RETURN(handle);
END open;

(*--------------------------------------------------------------------------*)

PROCEDURE creat ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     mode : modeT         ): int;

BEGIN
 RETURN(open(file, oWRONLY + OpenMode{oCREAT,oTRUNC}, mode));
END creat;

(*--------------------------------------------------------------------------*)

PROCEDURE fcntl ((* EIN/ -- *)     h   : int;
                 (* EIN/ -- *)     cmd : FcntlCmd;
                 (* EIN/AUS *) VAR arg : FcntlArg ): int;

VAR done : BOOLEAN;
    res  : INTEGER;
    lres : SIGNEDLONG;
    lock : FLOCK;
    par  : SIGNEDLONG;

BEGIN
 IF hasFcntl THEN
   WITH arg DO
     CASE cmd OF
       fDUPFD  : par := VAL(SIGNEDLONG,handle);
      |fSETFD  : par := VAL(SIGNEDLONG,CAST(UNSIGNEDWORD,fdflags));
      |fSETFL  : par := VAL(SIGNEDLONG,CAST(UNSIGNEDWORD,mode));
      |fGETLK,
       fSETLK,
       fSETLKW : WITH flock DO WITH lock DO
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
                 par := CAST(SIGNEDLONG,ADR(lock));
     ELSE (* fGETFD, fGETFL *)
       par := 0;
     END;
     IF Fcntl(h, par, ORD(cmd), lres) THEN
       CASE cmd OF
         fDUPFD  : handle := INT(lres);
                   FD[VAL(HandleRange,handle)] := FD[VAL(HandleRange,h)];
        |fGETFD  : fdflags := CAST(FDFlag,VAL(UNSIGNEDWORD,lres));
        |fGETFL  : mode    := CAST(OpenMode,VAL(UNSIGNEDWORD,lres));
        |fGETLK,
         fSETLK,
         fSETLKW : WITH flock DO WITH lock DO
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
       ELSE
         (* fSETFD, fSETFL *)
       END;
       RETURN(0);
     ELSE
       e.errno := INT(lres);
       IF (e.errno = e.eLOCKED) OR (e.errno = e.eNSLOCK) THEN
         e.errno := e.EACCES;
       END;
       RETURN(-1);
     END;
   END; (* WITH arg *)
 ELSE (* NOT hasFcntl *)
   IF (h<MinHandle) OR (h>MaxHandle) THEN
     e.errno := e.EBADF;
     RETURN(-1);
   END;
   WITH arg DO
     CASE cmd OF
       fSETFD : FD[VAL(HandleRange,h)].cloex := FdCloExec IN fdflags;
      |fGETFD : IF FD[VAL(HandleRange,h)].cloex THEN
                  fdflags := FDFlag{FdCloExec};
                ELSE
                  fdflags := FDFlag{};
                END;
      |fSETFL : WITH FD[VAL(HandleRange,h)] DO
                  flags := flags * setmask + (CAST(DosFlag,mode) - setmask);
                END;
      |fGETFL : mode := CAST(OpenMode,FD[VAL(HandleRange,h)].flags * getmask);
      |fDUPFD : IF Fdup(h, handle) THEN
                  FD[VAL(HandleRange,handle)]       := FD[VAL(HandleRange,h)];
                  FD[VAL(HandleRange,handle)].cloex := FALSE;
                ELSE
                  e.errno := handle;
                  RETURN(-1);
                END;
      |fSETLK : WITH flock DO
                  res := e.EINVAL;
                  IF    NOT FileLocking()
                     OR (lType = fRDLCK) OR (lWhence <> SeekSet)
                     OR NOT Flock(h, ORD(lType), lStart, lLen, res)
                  THEN
                    IF (res = e.eLOCKED) OR (res = e.eNSLOCK) THEN
                      e.errno := e.EACCES;
                    ELSE
                      e.errno := res;
                    END;
                    RETURN(-1);
                  END;
                END;
     ELSE
       e.errno := e.EINVAL;
       RETURN(-1);
     END; (* CASE *)
     RETURN(0);
   END; (* WITH arg *)
 END; (* IF hasFcntl *)
END fcntl;

(*--------------------------------------------------------------------------*)

PROCEDURE close ((* EIN/ -- *) h : int ): int;

VAR res : INTEGER;

BEGIN
 IF (h<MinHandle) OR (h>MaxHandle) THEN
   e.errno := e.EBADF;
   RETURN(-1);
 END;
 IF Fclose(h, res) THEN
   WITH FD[VAL(HandleRange,h)] DO
     ftype := unknown;
     cloex := FALSE;
   END;
   RETURN(0);
 ELSE
   e.errno := res;
   RETURN(-1);
 END;
END close;

(*--------------------------------------------------------------------------*)

PROCEDURE read ((* EIN/ -- *) h   : int;
                (* EIN/ -- *) buf : ADDRESS;
                (* EIN/ -- *) len : sizeT   ): ssizeT;

VAR lres : SIGNEDLONG;

BEGIN
 IF Fread(h, VAL(SIGNEDLONG,len), buf, lres) THEN
   RETURN(VAL(ssizeT,lres));
 ELSE
   e.errno := INT(lres);
   RETURN(-1);
 END;
END read;

(*--------------------------------------------------------------------------*)

PROCEDURE write ((* EIN/ -- *) h   : int;
                 (* EIN/ -- *) buf : ADDRESS;
                 (* EIN/ -- *) len : sizeT   ): ssizeT;

VAR lres : SIGNEDLONG;

BEGIN
 IF NOT hasFcntl THEN
   IF (h<MinHandle) OR (h>MaxHandle) THEN
     e.errno := e.EBADF;
     RETURN(-1);
   ELSIF append IN FD[VAL(HandleRange,h)].flags THEN
     IF NOT Fseek(0, h, ORD(SeekEnd), lres) THEN
       e.errno := INT(lres);
       RETURN(-1);
     END;
   END;
 END;
 IF Fwrite(h, VAL(SIGNEDLONG,len), buf, lres) THEN
   RETURN(VAL(ssizeT,lres));
 ELSE
   e.errno := INT(lres);
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

 IF len <= LIC(0) THEN
   (* Datei braucht nicht verlaengert zu werden *)
   IF Fseek(len, h, ORD(mode), lres) THEN
     RETURN(VAL(offT,lres));
   ELSIF MiNT AND (lres = EACCDNL) THEN
     e.errno := e.ESPIPE;
   ELSE
     e.errno := INT(lres);
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
 IF NOT done THEN
   IF MiNT AND (curPos = EACCDNL) THEN
     e.errno := e.ESPIPE;
   ELSE
     e.errno := INT(curPos);
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
 ELSIF NOT done AND (curPos <> ERANGEL) THEN
   e.errno := INT(curPos);
   RETURN(-1);
 END;


 done := Fseek(0, h, ORD(SeekEnd), curPos);

 (* Solange Nullbytes schreiben, bis die Datei auf die gewuenschte
  * Laenge gebracht ist.
  *)
 REPEAT
   len := newPos - curPos;
   IF  len > VAL(SIGNEDLONG,BLKSIZE)  THEN
     len := VAL(SIGNEDLONG,BLKSIZE);
   END;
   done := Fwrite(h, len, ADR(zerofill), lres);
   IF  lres <> len  THEN
     IF done THEN
       RETURN(VAL(offT,curPos + lres));
     ELSE
       e.errno := INT(lres);
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

(* MinixFS 0.60pl6 funktioniert nur, wenn die Datei mit oWRONLY
   geoeffnet wurde.
 *)
CONST FTRUNCATE = 4604H; (* ('F'<<8)|4 *)

VAR lres : SIGNEDLONG;

BEGIN
 IF Fcntl(h, ADR(len), FTRUNCATE, lres) THEN
   RETURN(0);
 ELSE
   e.errno := INT(lres);
   RETURN(-1);
 END;
END ftruncate;

(*--------------------------------------------------------------------------*)

PROCEDURE dup ((* EIN/ -- *) h : int ): int;

VAR lres : SIGNEDLONG;
    done : BOOLEAN;
    newh : INTEGER;

BEGIN
 IF hasFcntl THEN
   done := Fcntl(h, 0, ORD(fDUPFD), lres);
   newh := INT(lres);
   IF done THEN
     (* 'FdCloExec'-Flag loeschen, falls gesetzt *)
     done := Fcntl(newh, 0, ORD(fGETFD), lres);
     IF ODD(lres) THEN
       DEC(lres);
     END;
     done := Fcntl(newh, lres, ORD(fSETFD), lres);
     FD[VAL(HandleRange,newh)].ftype := FD[VAL(HandleRange,h)].ftype;
     RETURN(newh);
   ELSE
     e.errno := newh;
     RETURN(-1);
   END;
 ELSE
   IF (h<MinHandle) OR (h>MaxHandle) THEN
     e.errno := e.EBADF;
     RETURN(-1);
   END;
   IF Fdup(h, newh) THEN
     FD[VAL(HandleRange,newh)]       := FD[VAL(HandleRange,h)];
     FD[VAL(HandleRange,newh)].cloex := FALSE;
     RETURN(newh);
   ELSE
     e.errno := newh;
     RETURN(-1);
   END;
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
 (* Das Schliessen eines Standardkanals macht eine vorherige
  * Umleitung rueckgaengig. Ist aber erst seit dem GEMDOS des TOS 1.04
  * anwendbar.
  *)
 IF DOSVersion >= 1500H THEN
   void := Fclose(newh, res);
 END;

 IF Fforce(newh, oldh, res) THEN
   IF hasFcntl THEN
     (* 'FdCloExec'-Flag loeschen, falls gesetzt *)
     void := Fcntl(newh, 0, ORD(fGETFD), lres);
     IF ODD(lres) THEN
       DEC(lres);
     END;
     void := Fcntl(newh, lres, ORD(fSETFD), lres);
     FD[VAL(HandleRange,newh)].ftype := FD[VAL(HandleRange,oldh)].ftype;
   ELSE
     IF (newh<MinHandle) OR (newh>MaxHandle) THEN
       e.errno := e.EBADF;
       RETURN(-1);
     END;
     FD[VAL(HandleRange,newh)]       := FD[VAL(HandleRange,oldh)];
     FD[VAL(HandleRange,newh)].cloex := FALSE;
   END;
   RETURN(newh);
 ELSE
   e.errno := res;
   RETURN(-1);
 END;
END dup2;

(*--------------------------------------------------------------------------*)

PROCEDURE umask ((* EIN/ -- *) excl : modeT ): modeT;

VAR oldmask : modeT;
    lres    : SIGNEDLONG;

BEGIN
 oldmask := UMASK;
 UMASK   := excl;
 lres    := Pumask(excl);
 IF lres < VAL(SIGNEDLONG,0) THEN
   (* Aufruf wird nicht unterstuetzt *)
   RETURN(oldmask);
 ELSE
   RETURN(CAST(modeT,VAL(UNSIGNEDWORD,lres)));
 END;
END umask;

(*---------------------------------------------------------------------------*)

PROCEDURE chmod ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     mode : modeT         ): int;

VAR         res    : INTEGER;
            dot    : BOOLEAN;
            done   : BOOLEAN;
            dta    : DTA;
    __REG__ attr   : FileAttribute;
            old    : WORDSET;
            stack  : ADDRESS;
            msize  : CARDINAL;
            path0  : StrPtr;

BEGIN
 msize := SLEN(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Fchmod(path0, mode, res) THEN
   res := 0;
 ELSIF res <> e.eINVFN THEN
   (* 'Fchmod'-Aufruf wird unterstuetzt, anderer Fehler *)
   e.errno := res;
   res     := -1;
 ELSIF FindFirst(path0, FINDALL, dta, res) THEN
   (* 'Fchmod'-Aufruf wird nicht unterstuetzt *)
   attr := dta.attr;
   IF faSUBDIR IN attr THEN
     (* Verzeichnisse in Ruhe lassen (duerfen keine weiteren Attribute haben)*)
     memdealloc(stack);
     RETURN(0);
   END;
   IF faCHANGED IN attr THEN
     (* Archivbit nicht veraendern *)
     attr := FileAttribute{faRDONLY, faCHANGED};
   ELSE
     attr := FileAttribute{faRDONLY};
   END;
   IF sIWUSR IN mode THEN
     EXCL(attr, faRDONLY);
   END;
   IF Fattrib(path0, 1, attr, old) THEN
     res := 0;
   ELSE
     e.errno := INT(CAST(SIGNEDWORD,old));
     res     := -1;
   END;
 ELSE
   e.errno := res;
   res     := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END chmod;

(*--------------------------------------------------------------------------*)

PROCEDURE chown ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     uid  : uidT;
                 (* EIN/ -- *)     gid  : gidT          ): int;

VAR res    : INTEGER;
    dot    : BOOLEAN;
    done   : BOOLEAN;
    stack  : ADDRESS;
    msize  : CARDINAL;
    path0  : StrPtr;

BEGIN
 msize := SLEN(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Fchown(path0, uid, gid, res) THEN
   res     := 0;
 ELSIF res <> e.eINVFN THEN
   (* 'Fchown'-Aufruf wird unterstuetzt, anderer Fehler *)
   e.errno := res;
   res     := -1;
 ELSIF (uid = 0) AND (gid = 0) THEN
   res     := 0;
 ELSE
   e.errno := e.EINVAL;
   res     := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END chown;

(*--------------------------------------------------------------------------*)

PROCEDURE utime ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     time : UTimPtr       ): int;
(**)
CONST FUTIME = 4603H; (* ('F'<<8)|3 *)

VAR lres   : SIGNEDLONG;
    hndl   : INTEGER;
    void   : BOOLEAN;
    done   : BOOLEAN;
    tmp    : WORDSET;
    stack  : ADDRESS;
    tptr   : ADDRESS;
    msize  : CARDINAL;
    path0  : StrPtr;
    date   : DosDate;
    tm : RECORD
      actime  : TimeCast;
      modtime : TimeCast;
    END;

BEGIN
 msize := SLEN(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, void, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 WITH tm DO
   IF time = NULL THEN
     (* Fcntl bzw. Dcntl entscheiden selbst weiter *)
     tptr := NULL;
   ELSE
     SecondsToDate(time^.modtime, date);
     EncodeDate(date, modtime.date, modtime.time);
     SecondsToDate(time^.actime, date);
     EncodeDate(date, actime.date, actime.time);
     tptr := ADR(tm);
   END;
   IF Dcntl(FUTIME, path0, tptr, lres) THEN
     memdealloc(stack);
     RETURN(0);
   ELSIF INT(lres) <> e.eINVFN THEN
     (* Dateisystem unterstuetzt den FUTIME-Aufruf, aber anderer
      * Fehler, deswegen abbrechen.
      *)
     memdealloc(stack);
     e.errno := INT(lres);
     RETURN(-1);
   END;

   done := Fopen(path0, oWRONLY, hndl);
   IF done THEN
     IF NOT Fcntl(hndl, tptr, FUTIME, lres) THEN
       (* 'Fcntl' oder FUTIME werden nicht unterstuetzt oder anderer Fehler *)
       modtime.time := Tgettime();
       modtime.date := Tgetdate();
       Fdatime(ADR(modtime), hndl, 1);
     END;
     void := Fclose(hndl, hndl);
   ELSIF hndl = e.eFILNF THEN
     void := Fattrib(path0, 0, 0, tmp);
     IF faSUBDIR IN CAST(FileAttribute,tmp) THEN
       (* Verzeichnisse in Ruhe lassen *)
       done := TRUE;
     END;
   END;
 END; (* WITH *)
 IF done THEN
   hndl := 0;
 ELSE
   e.errno := hndl;
   hndl    := -1;
 END;
 memdealloc(stack);
 RETURN(hndl);
END utime;

(*---------------------------------------------------------------------------*)

PROCEDURE pipe ((* -- /AUS *) VAR ph : PipeBuf ): int;

VAR handle : ARRAY [0..1] OF SIGNEDWORD;
    res    : INTEGER;

BEGIN
 ph.readh  := 0;
 ph.writeh := 0;
 IF Fpipe(ADR(handle), res) THEN
   ph.readh  := INT(handle[0]);
   ph.writeh := INT(handle[1]);
   FD[handle[0]].ftype := notty;
   FD[handle[1]].ftype := notty;
   RETURN(0);
 ELSE
   (* 'Fpipe'-Aufruf wird nicht unterstuetzt oder anderer Fehler *)
   e.errno := res;
   RETURN(-1);
 END;
END pipe;

(*---------------------------------------------------------------------------*)

PROCEDURE MiNTstat ((* EIN/ -- *)     hndl : BOOLEAN;
                    (* EIN/ -- *)     sym  : BOOLEAN;
                    (* EIN/ -- *)     h    : INTEGER;
                    (* EIN/ -- *)     path : StrPtr;
                    (* -- /AUS *) VAR st   : StatRec ): INTEGER;

VAR
  lres  : SIGNEDLONG;
  done  : BOOLEAN;
  dlen  : INTEGER;
  xlen  : INTEGER;
  xattr : XATTR;
  stack : ADDRESS;
  msize : CARDINAL;
  slink : StrPtr;
  date  : DosDate;

BEGIN
 IF hndl THEN
   done := Fcntl(h, ADR(xattr), FSTAT, lres);
   h    := INT(lres);
 ELSE
   done := Fxattr(ORD(sym), path, ADR(xattr), h);
   IF sym AND done AND (xattr.mode * sIFMT = sIFLNK) THEN
     msize := VAL(CARDINAL,xattr.size) + 1;
     memalloc(VAL(sizeT,msize), stack, slink);
     done := Freadlink(msize, slink, path, h);
     IF done THEN
       DosToUnix(slink, 0, NULL, dlen, xlen);
       xattr.size := VAL(SIGNEDLONG,xlen);
     END;
     memdealloc(stack);
   END;
 END;
 IF NOT done THEN
   RETURN(h);
 END;

 WITH st DO WITH xattr DO
   stMode    := mode;
   stIno     := index;
   stDev     := dev;
   stRdev    := rdev;
   stNlink   := nlink;
   stUid     := uid;
   stGid     := gid;
   stSize    := size;
   stBlksize := blksize;
   stBlocks  := (CAST(UNSIGNEDLONG,nblocks) * CAST(UNSIGNEDLONG,blksize))
                DIV VAL(UNSIGNEDLONG,512);

   DecodeDate(mdate, mtime, date);
   stMtime := DateToSeconds(date);
   DecodeDate(adate, atime, date);
   stAtime := DateToSeconds(date);
   DecodeDate(cdate, ctime, date);
   stCtime := DateToSeconds(date);
 END; END;
 RETURN(0);
END MiNTstat;

(*--------------------------------------------------------------------------*)

PROCEDURE istat (VAR name : ARRAY OF CHAR;
                 VAR st   : StatRec;
                     sym  : BOOLEAN       ): INTEGER;

CONST DIRSIZE = 1024;
      BLKSIZE = 1024;

VAR         dta    : DTA;
            err    : INTEGER;
    __REG__ pLen   : UNSIGNEDWORD;
            ROOT   : BOOLEAN;
            DOT    : BOOLEAN;
            drv    : BOOLEAN;
            stack  : ADDRESS;
            msize  : CARDINAL;
            path0  : StrPtr;
            date   : DosDate;

BEGIN
 msize := SLEN(name) + DINCR + 4; (* + 4 wegen ++ "\*.*" *)
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(name)), msize - DINCR - 4, VAL(StrRange,msize),
           path0, DOT, drv);
 IF NOT drv THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 err := MiNTstat(FALSE, sym, 0, path0, st);
 IF err <> e.eINVFN THEN
   (* 'Fxattr'-Aufruf wird unterstuetzt *)
   memdealloc(stack);
   IF err < 0 THEN
     e.errno := err;
     RETURN(-1);
   ELSE
     RETURN(0);
   END;
 END;

 (* 'Fxattr'-Aufruf wird nicht unterstuetzt, TOS-Emulation *)

 pLen := VAL(UNSIGNEDWORD,strlen(path0));
 WITH st DO
   stUid     := 0;
   stGid     := 0;
   stRdev    := 0;
   stBlksize := BLKSIZE;
 END;

 IF IsDosDevice(path0) THEN
   WITH st DO
     stIno    := VAL(inoT,INODE); INC(INODE);
     stMode   := sIFCHR + STDPERM;
     stDev    := 0;
     DecodeDate(Tgetdate(), Tgettime(), date);
     stMtime  := DateToSeconds(date);
     stAtime  := stMtime;
     stCtime  := stMtime;
     stNlink  := 1;
     stSize   := 0;
     stBlocks := 0;
   END;
   memdealloc(stack);
   RETURN(0);
 END;

 IF path0^[1] = DDRVPOSTFIX THEN
   st.stDev := VAL(devT,tocard(path0^[0]) - 10);
   drv      := TRUE;
 ELSE
   st.stDev := VAL(devT,Dgetdrv());
   drv      := FALSE;
 END;

 (* Hauptverzeichnisse muessen gesondert behandelt werden, da sie nicht
  * wie Unterverzeichnisse in der Baumstruktur eingebunden sind - sie
  * haben kein Erstellungsdatum und besitzen nicht die Eintraege
  * "." und ".." zur Verkettung.
  *)
 IF            (pLen = 1) AND (path0^[0] = DDIRSEP)
    OR drv AND (pLen = 3) AND (path0^[2] = DDIRSEP)
 THEN
   (* Ein Hauptverzeichnis ist direkt angegeben, deshalb sind keine
    * weiteren Tests noetig.
    *)
   ROOT := TRUE;
 ELSE
   IF path0^[pLen-1] = DDIRSEP THEN
     (* Verzeichnisse nicht extra kennzeichnen.
      * 'pLen' ist mindestens zwei, da der Fall 'pLen' = 1
      * oben abgefangen wird.
      *)
     path0^[pLen-1] := 0C;
     DEC(pLen);
   ELSIF drv AND (pLen = 2) THEN
     (* "Fsfirst("x:")" funktioniert nicht *)
     path0^[2] := '.';
     path0^[3] := 0C;
     DOT       := TRUE;
     INC(pLen);
   END;

   IF DOT THEN
     AssignM2ToC("\*.*", msize - VAL(CARDINAL,pLen), ADDADR(path0, pLen));
     (* Den ersten Eintrag suchen, sodass bei allen Verzeichnissen - ausser
      * den Hauptverzeichnissen - der Eintrag "." gefunden wird.
      * (Bei "..\*.*" wird das "." des uebergeordneten Verzeichnisses
      * gefunden.)
      *)
   END;

   IF FindFirst(path0, FINDALL, dta, err) THEN
     ROOT := DOT AND ((dta.name[0] <> '.') OR (dta.name[1] <> 0C));
     (* nicht-leeres Hauptverzeichnis, falls der erste Eintrag nicht
      * mit einem Punkt beginnt (normaler Dateiname), oder nach dem Punkt
      * nicht beendet ist (dann kann es nicht "." sein, das in allen
      * Verzeichnissen zuerst steht.
      *)
   ELSE
     (* Wenn kein Eintrag gefunden wird und "." oder ".." angegeben
      * wurden, handelt es sich um ein leeres Hauptverzeichnis,
      * ansonsten ist ein Fehler aufgetreten (angegebene Datei wurde
      * nicht gefunden).
      *)
     IF DOT AND (err = e.eFILNF) THEN
       ROOT := TRUE;
     ELSE
       e.errno := err;
       memdealloc(stack);
       RETURN(-1);
     END;
   END;
 END;

 IF ROOT THEN
   (* Einem Hauptverzeichnis lassen sich leider kaum Informationen
    * entlocken.
    *)
   WITH st DO
     stIno    := 2; (* ?? *)
     stSize   := DIRSIZE;
     stBlocks := 2;
     stNlink  := 2;
     stMode   := sIFDIR + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
     stMtime  := 0;
     stAtime  := 0;
     stCtime  := 0;
   END;
   memdealloc(stack);
   RETURN(0);
 END;

 WITH st DO
   stIno   := VAL(inoT,INODE); INC(INODE);
   DecodeDate(dta.date, dta.time, date);
   stMtime := DateToSeconds(date);
   stAtime := stMtime;
   stCtime := stMtime;
   IF faSUBDIR IN dta.attr THEN
     stSize   := DIRSIZE;
     stBlocks := 2;
     stNlink  := 2;
   ELSE
     stSize   := dta.size;
     stBlocks := (CAST(UNSIGNEDLONG,stSize) + VAL(UNSIGNEDLONG,BLKSIZE - 1))
                 DIV VAL(UNSIGNEDLONG,512);
     stNlink  := 1;
   END;
   IF faSUBDIR IN dta.attr THEN
     stMode := sIFDIR + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
   ELSIF IsExec(path0) THEN
     stMode := sIFREG + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
   ELSE
     stMode := sIFREG + STDPERM;
   END;
   IF faRDONLY IN dta.attr THEN
     stMode := stMode - modeT{sIWUSR, sIWGRP, sIWOTH};
   END;
   IF faHIDDEN IN dta.attr THEN
     stMode := stMode - modeT{sIRUSR, sIRGRP, sIROTH};
   END;
 END; (* WITH st *)
 memdealloc(stack);
 RETURN(0);
END istat;

(*--------------------------------------------------------------------------*)

PROCEDURE stat ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                (* -- /AUS *) VAR st   : StatRec       ): int;

BEGIN
 RETURN(istat(file, st, FALSE));
END stat;

(*--------------------------------------------------------------------------*)

PROCEDURE lstat ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* -- /AUS *) VAR st   : StatRec       ): int;

BEGIN
 RETURN(istat(file, st, TRUE));
END lstat;

(*--------------------------------------------------------------------------*)

PROCEDURE fstat ((* EIN/ -- *)     h  : int;
                 (* -- /AUS *) VAR st : StatRec ): int;

CONST BLKSIZE = 1024;

VAR         err    : INTEGER;
            pos    : SIGNEDLONG;
            size   : SIGNEDLONG;
    __REG__ void   : BOOLEAN;
            time   : ARRAY [0..1] OF WORDSET;
            lres   : SIGNEDLONG;
            magic  : UNSIGNEDWORD;
            dummy  : StrPtr;
            tc     : TimeCast;
            date   : DosDate;

BEGIN
 err := MiNTstat(TRUE, FALSE, h, dummy, st);
 IF err <> e.eINVFN THEN
   (* 'Fcntl'-Aufruf wird unterstuetzt *)
   IF err < 0 THEN
     e.errno := err;
     RETURN(-1);
   ELSE
     RETURN(0);
   END;
 END;

 (* 'Fcntl'-Aufruf wird nicht unterstuetzt, TOS-Emulation *)

 IF (h<MinHandle) OR (h>MaxHandle) THEN
   e.errno := e.EBADF;
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
 END;
 WITH st DO
   IF FD[VAL(HandleRange,h)].ftype = istty THEN
     stMode  := sIFCHR + STDPERM;
     stSize  := 0;
     tc.time := Tgettime();
     tc.date := Tgetdate();
   ELSE
     Fdatime(ADR(time), h, 0);
     tc.time := time[0];
     tc.date := time[1];

     IF Fseek(0, h, ORD(SeekCur), pos) THEN
       void   := Fseek(0, h, ORD(SeekEnd), size);
       stSize := size;

       void := Fseek(0, h, ORD(SeekSet), size);
       void := Fread(h, 2, ADR(magic), lres);
       IF (lres = LIC(2)) AND ((magic = 601AH) OR (magic = 2321H))(* #! *) THEN
         stMode := sIFREG + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
       ELSE
         stMode := sIFREG + STDPERM;
       END;
       void := Fseek(pos, h, ORD(SeekSet), size);
     ELSE
       e.errno := e.EBADF;
       RETURN(-1);
     END;
   END;

   DecodeDate(tc.date, tc.time, date);
   stMtime   := DateToSeconds(date);
   stAtime   := stMtime;
   stCtime   := stMtime;
   stUid     := 0;
   stGid     := 0;
   stDev     := VAL(devT,Dgetdrv());
   stRdev    := 0;
   stNlink   := 1;
   stBlksize := BLKSIZE;
   stBlocks  := (CAST(UNSIGNEDLONG,stSize) + VAL(UNSIGNEDLONG,BLKSIZE - 1))
                DIV VAL(UNSIGNEDLONG,512);
   stIno     := VAL(inoT,INODE); INC(INODE);
 END; (* WITH *)
 RETURN(0);
END fstat;

(*--------------------------------------------------------------------------*)

PROCEDURE sISCHR ((* EIN/ -- *) stMode : modeT ): BOOLEAN;
BEGIN
 RETURN(stMode * sIFMT = sIFCHR);
END sISCHR;

(*--------------------------------------------------------------------------*)

PROCEDURE sISDIR ((* EIN/ -- *) stMode : modeT ): BOOLEAN;
BEGIN
 RETURN(stMode * sIFMT = sIFDIR);
END sISDIR;

(*--------------------------------------------------------------------------*)

PROCEDURE sISBLK ((* EIN/ -- *) stMode : modeT ): BOOLEAN;
BEGIN
 RETURN(stMode * sIFMT = sIFBLK);
END sISBLK;

(*--------------------------------------------------------------------------*)

PROCEDURE sISREG ((* EIN/ -- *) stMode : modeT ): BOOLEAN;
BEGIN
 RETURN(stMode * sIFMT = sIFREG);
END sISREG;

(*--------------------------------------------------------------------------*)

PROCEDURE sISFIFO ((* EIN/ -- *) stMode : modeT ): BOOLEAN;
BEGIN
 RETURN(stMode * sIFMT = sIFIFO);
END sISFIFO;

(*--------------------------------------------------------------------------*)

PROCEDURE sISLNK ((* EIN/ -- *) stMode : modeT ): BOOLEAN;
BEGIN
 RETURN(stMode * sIFMT = sIFLNK);
END sISLNK;

(*--------------------------------------------------------------------------*)

PROCEDURE access ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                  (* EIN/ -- *)     acc  : AccessMode    ): int;

VAR dta : DTA;
    st  : StatRec;
    uid : INTEGER;

BEGIN
 IF istat(file, st, FALSE) < 0 THEN
   RETURN(-1);
 ELSIF acc = fOK THEN
   RETURN(0);
 END;

 uid := Pgetuid();
 IF (uid < 0) OR (uid = INT(st.stUid)) THEN
   IF acc <= CAST(AccessMode,VAL(UNSIGNEDWORD,
               CAST(UNSIGNEDWORD,st.stMode * sIRWXU) DIV 64))
   THEN
     RETURN(0);
   ELSE
     e.errno := e.EACCES;
     RETURN(-1);
   END;
 END;

 IF Pgetgid() = INT(st.stGid) THEN
   IF acc <= CAST(AccessMode,VAL(UNSIGNEDWORD,
               CAST(UNSIGNEDWORD,st.stMode * sIRWXG) DIV 8))
   THEN
     RETURN(0);
   ELSE
     e.errno := e.EACCES;
     RETURN(-1);
   END;
 END;

 IF acc <= CAST(AccessMode,st.stMode * sIRWXO) THEN
   RETURN(0);
 ELSE
   e.errno := e.EACCES;
   RETURN(-1);
 END;
END access;

(*==========================================================================*)

VAR
  i   : CARDINAL;
  res : SIGNEDLONG;

BEGIN (* file *)
 FOR i := 0 TO LBLKSIZE - 1 DO
   zerofill[i] := 0;
 END;
 hasFcntl   := FcntlAvail();
 DOSVersion := DosVersion();
 MiNT       := MiNTVersion() > 0;
 res        := Pumask(0);
 IF res < VAL(SIGNEDLONG,0) THEN
   (* Aufruf wird nicht unterstuetzt *)
   UMASK := modeT{};
 ELSE
   UMASK := CAST(modeT,VAL(UNSIGNEDWORD,res));
   res   := Pumask(UMASK);
 END;
END file.
