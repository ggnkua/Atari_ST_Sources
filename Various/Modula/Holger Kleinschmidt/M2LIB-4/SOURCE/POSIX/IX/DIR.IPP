IMPLEMENTATION MODULE dir;
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
(* PROC *) ADR, TSIZE;
#ifdef MM2
FROM SYSTEM IMPORT CADR;
#endif

FROM PORTAB IMPORT
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, WORDSET;

FROM types IMPORT
(* CONST*) EOS, NULL, NAMEMAX, PATHMAX, MAXSTR, DDIRSEP, sIFMT, sIFREG, sIFDIR,
           sIFLNK, sIFBLK, sIFIFO, sIFCHR, sIRWXU, sIRWXG, sIRWXO, STDPERM,
(* TYPE *) int, unsigned, PathName, uidT, gidT, inoT, timeT, offT, sizeT,
           ssizeT, devT, pidT, StrPtr, StrRange, FileMode, modeT;

FROM blk IMPORT
(* PROC *) memalloc, memdealloc, memmove;

FROM OSCALLS IMPORT
(* PROC *) Dcreate, Fchmod, Ddelete, Dopendir, Dreaddir, Drewinddir, Dxreaddir,
           Dclosedir, Dpathconf, Fdelete, Flink, Fsymlink, Freadlink, Frename,
           Fxattr, Fattrib, Fchown, Dcntl, Fopen, Fcntl, Tgettime, Tgetdate,
           Fdatime, Fclose, Dgetdrv, Fseek, Pgetuid, Pgetgid, Fread;

FROM ctype IMPORT
(* PROC *) todigit, tocard, Cisalpha;

FROM str IMPORT
(* PROC *) AssignM2ToC, strlen, strcmp, strcpy, strlwr, strrchr;

FROM ISOStrings IMPORT
(* PROC *) Length, Assign;

FROM pLONGSET IMPORT
(* PROC *) LONGSHIFT;

FROM er IMPORT
(* CONST*) eINVFN, eFILNF, EACCES, EBADF, eRANGE, ENOMEM, eNMFIL, EEXIST,
           ePTHNF, eACCDN, ENOTEMPTY, eNSAME, EINVAL,
(* VAR  *) errno;

FROM DosSystem IMPORT
(* PROC *) MagiCVersion;

FROM DosTime IMPORT
(* TYPE *) TimeCast, DosDate,
(* PROC *) DecodeDate, EncodeDate, DateToSeconds, SecondsToDate;

FROM DosFile IMPORT
(* CONST*) MinHandle, MaxHandle,
(* VAR  *) FD,
(* TYPE *) FileType, HandleRange,
(* PROC *) IsTerm;

FROM DosDir IMPORT
(* CONST*) AllEntries, XDECR, DINCR, DDRVPOSTFIX,
(* VAR  *) INODE, UMASK,
(* TYPE *) DTA, FileAttribute, FileAttributes, XATTR,
(* PROC *) CompletePath, DosToUnix, UnixToDos, FindFirst, FindNext, IsDosDir,
           TstENOTDIR, FileExists, IsDosDevice, IsExec;

FROM mem IMPORT
(* PROC *) malloc, free;

(*==========================================================================*)

CONST
  DIRSIZE   = 0;        (* Groesse eines TOS-Verzeichnisses *)

  BLKSIZE   = LC(1024); (* Default-Blockgroesse *)
  BLKSIZEm1 = LC(1023);

  PSXBLK    = LC(512);  (* POSIX benutzt 512-Byte-Bloecke *)
  PSXBLKm1  = LC(511);

VAR
  tosmask : ARRAY [0..7] OF CHAR; (* "\..\*.*" *)
  rootdir : ARRAY [0..4] OF CHAR; (* "@:\\" *)
  magic   : BOOLEAN;

TYPE
  TOSDIRstate = (STARTSEARCH, INSEARCH, NMFILE);

CONST
  (* Absicherung gegen ``unendlich'' grosse Dateinamen *)
  MAXPATHALLOC = 2048;

TYPE
  DIRptr  = POINTER TO DIRtype;
  DIRtype = RECORD
    offset : offT;         (* Nummer der Datei im Verzeichnis *)
    dirent : DirentRec;    (* Bei "readdir()" wird Zeiger darauf geliefert *)
    cconv  : BOOLEAN;      (* Flag: Gross -> Klein-Konvertierung *)
    dirlen : UNSIGNEDWORD; (* Laenge von fpath^ bzw. dirname bis abschl. \ *)
    CASE posixstyle : BOOLEAN OF
      FALSE:
        status  : TOSDIRstate;
        drive   : devT; (* Laufwerk des Verzeichnisses *)
        dta     : DTA;  (* Der 'StatRec' des TOS... *)
        (* Die max. Laenge eines Dateinamens ist bei Benutzung von
         * 'Fsfirst'/'Fsnext' festgelegt. Ein Byte mehr, damit auf
         * jeden Fall Platz fuer ein Nullbyte ist.
         *)
        dname   : ARRAY [0..14] OF CHAR;
        (* Vollstaendiger Pfad des Verzeichnisses mit Laufwerksangabe.
         * Ist noetig, damit beim "rewinddir()" das richtige Verzeichnis
         * benutzt wird, falls sich das aktuelle Verzeichnis inzwischen
         * geaendert hat.
         * Speicher wird je nach Groesse angefordert.
         *)
        dirname : CHAR;
     |TRUE:
        (* (Tatsaechliche) Groesse von 'dino' + 'fname' *)
        bufsize : SIGNEDLONG;
        (* Vollstaendiger Pfad des Verzeichnisses mit Laufwerksangabe.
         * Ist noetig, weil bei symbolischen Links ein 'Freadlink'
         * ausgefuehrt werden muss, um die Laenge des Zielpfades nach
         * der DOS->*IX-Konvertierung berechnen zu koennen, und um
         * bei "." und ".." ein 'Fxattr' ausfuehren zu koennen.
         *)
        fpath   : StrPtr;
        dhandle : UNSIGNEDLONG;
        xread   : BOOLEAN; (* 'Dxreaddir' wird unterstuetzt *)

        (* Die folgenden beiden Felder muessen hintereinander stehen *)
        dino    : UNSIGNEDLONG;
        fname   : CHAR; (* Speicher wird je nach Groesse angefordert *)
    END;
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE DosToUnixStat ((* EIN/ -- *)     sym  : BOOLEAN;
                         (* EIN/ -- *)     path : StrPtr;
                         (* EIN/AUS *) VAR st   : StatRec );

CONST DPMODEATTR = 7;

VAR done  : BOOLEAN;
    tcast : TimeCast;
    err   : INTEGER;
    stb   : StatRec;
    date  : DosDate;
    stack : ADDRESS;
    lcast : RECORD
      CASE TAG_COLON BOOLEAN OF
        FALSE: lres : SIGNEDLONG;
       |TRUE : wsh  : WORDSET;
               wsl  : WORDSET;
      END;
    END;

BEGIN
 IF magic THEN
   (* MagiC3/4 setzt bei TOS-Dateisystemen immer das x-Bit. Unter bestimmten
    * Umstaenden kann der tatsaechliche Zustand des x-Bits ermittelt
    * werden.
    *)
   done := FALSE;
   IF sym THEN
     IF st.stMode * sIFMT # sIFLNK THEN
       done := Dpathconf(path, DPMODEATTR, lcast.lres);
     END;
   ELSE
     IF (st.stDev >= 0) & (st.stDev <= 25) THEN
       (* Die Zieldatei liegt auf einem GEMDOS-Laufwerk; die Attribute
        * koennen ueber das Wurzelverzeichnis des Laufwerks ermittelt
        * werden.
        *)
       rootdir[0] := todigit(st.stDev + 10);
       done := Dpathconf(ADR(rootdir), DPMODEATTR, lcast.lres);
     ELSIF path # NULL THEN
       (* Feststellen, ob der Originalpfad ein symbolischer Link ist.
        * Nur, wenn das nicht der Fall ist, Attribute ueber den
        * Originalpfad ermitteln.
        *)
       IF Fxattr(1, path, ADR(stb), err) & (stb.stMode * sIFMT # sIFLNK) THEN
         done := Dpathconf(path, DPMODEATTR, lcast.lres);
       END;
     END;
   END;

   (* Wenn der Dpathconf-Aufruf nicht unterstuetzt wird, z.B. bei MinixFS,
    * wird davon ausgegangen, dass die mode-Bits alle gueltig sind.
    *)
   IF done THEN
     lcast.lres := LONGSHIFT(lcast.lres, -8);
#if reverse_set
     IF CAST(modeT,lcast.wsl * WORDSET{4..15}) = modeT{} THEN
#else
     IF CAST(modeT,lcast.wsl * WORDSET{0..11}) = modeT{} THEN
#endif
       WITH st DO
         IF (stMode * sIFMT = sIFDIR) OR IsExec(path) THEN
           stMode := stMode + modeT{sIXUSR, sIXGRP, sIXOTH};
         ELSE
           stMode := stMode - modeT{sIXUSR, sIXGRP, sIXOTH};
         END;
       END;
     END;
   END;
 END;

 (* Anzahl der Bloecke und die Zeiten ins *IX-Format konvertieren *)
 WITH st DO
   IF stMtime # VAL(timeT,0) THEN
     tcast.xtime := stMtime; DecodeDate(tcast.ddate, tcast.dtime, date);
     stMtime     := DateToSeconds(date);
   END;
   IF stAtime # VAL(timeT,0) THEN
     tcast.xtime := stAtime; DecodeDate(tcast.ddate, tcast.dtime, date);
     stAtime     := DateToSeconds(date);
   END;
   IF stCtime # VAL(timeT,0) THEN
     tcast.xtime := stCtime; DecodeDate(tcast.ddate, tcast.dtime, date);
     stCtime     := DateToSeconds(date);
   END;

   stBlocks := (CAST(UNSIGNEDLONG,stBlocks) * CAST(UNSIGNEDLONG,stBlksize))
               DIV PSXBLK;
 END;
END DosToUnixStat;

(*---------------------------------------------------------------------------*)

PROCEDURE SymLengthUnix ((* EIN/ -- *)     path : StrPtr;
                         (* EIN/AUS *) VAR size : offT ): INTEGER;
(* Die Laenge eines symbolischen Links nach der DOS->*IX-Konvertierung *)

VAR
  err   : INTEGER;
  dlen  : INTEGER;
  xlen  : INTEGER;
  stack : ADDRESS;
  msize : CARDINAL;
  slink : StrPtr;

BEGIN
 msize := VAL(CARDINAL,size) + 10; (* sicherheitshalber etwas mehr *)
 memalloc(VAL(sizeT,msize), stack, slink);
 IF Freadlink(msize, slink, path, err) THEN
   (* Keine Gross/Klein-Konvertierung, da es nur um die Pfadlaenge geht *)
   DosToUnix(slink, FALSE, 0, NULL, dlen, xlen);
   size := VAL(offT,xlen);
 END;
 memdealloc(stack);
 RETURN(err);
END SymLengthUnix;

(*---------------------------------------------------------------------------*)

PROCEDURE TOSDeviceStat ((* -- /AUS *) VAR st : StatRec );
(* Dateiinfos fuer TOS-Geraete *)
VAR date : DosDate;

BEGIN
 WITH st DO
   stMode    := sIFCHR + STDPERM;
   stIno     := VAL(inoT,INODE); INC(INODE);
   stDev     := 0;
   stRdev    := 0;
   stNlink   := 1;
   stUid     := 0;
   stGid     := 0;
   stSize    := 0;
   stBlksize := BLKSIZE;
   stBlocks  := 0;
   DecodeDate(Tgetdate(), Tgettime(), date);
   stMtime   := DateToSeconds(date);
   stAtime   := stMtime;
   stCtime   := stMtime;
   stAttr    := FileAttributes{};
 END;
END TOSDeviceStat;

(*--------------------------------------------------------------------------*)

PROCEDURE TOSRootStat ((* -- /AUS *) VAR st : StatRec );
(* Dateiinfos fuer TOS-Wurzelverzeichnisse. 'stDev' wird nicht gesetzt. *)
BEGIN
 WITH st DO
   stMode    := sIFDIR + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
   stIno     := 2; (* ? *)
   stRdev    := 0;
   stNlink   := 2;
   stUid     := 0;
   stGid     := 0;
   stSize    := DIRSIZE;
   stBlksize := BLKSIZE;
   stBlocks  := 2;
   stMtime   := 0;
   stAtime   := 0;
   stCtime   := 0;
   stAttr    := FileAttributes{faSUBDIR};
 END; (* WITH st *)
END TOSRootStat;

(*--------------------------------------------------------------------------*)

PROCEDURE DTAStat ((* EIN/ -- *) VAR dta  : DTA;
                   (* EIN/ -- *)     path : StrPtr;
                   (* -- /AUS *) VAR st   : StatRec );
(* Dateiinfos fuer normale Dateien und Unterverzeichnisse unter TOS.
 * Fuellt alle Felder bis auf 'stDev'. <path> wird nur benoetigt, um anhand
 * der Extension evtl. die Ausfuehrbarkeit festzustellen; es braucht
 * also nur der Dateiname zu sein.
 *)
VAR date : DosDate;

BEGIN
 WITH st DO
   IF faSUBDIR IN dta.attr THEN
     stMode := sIFDIR + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
   ELSIF IsExec(path) THEN
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
   stIno     := VAL(inoT,INODE); INC(INODE);
   stRdev    := 0;
   stUid     := 0;
   stGid     := 0;
   stBlksize := BLKSIZE;
   DecodeDate(dta.date, dta.time, date);
   stMtime   := DateToSeconds(date);
   stAtime   := stMtime;
   stCtime   := stMtime;
   stAttr    := dta.attr;
   IF faSUBDIR IN dta.attr THEN
     stSize   := DIRSIZE;
     stBlocks := 2;
     stNlink  := 2;
   ELSE
     stSize   := dta.size;
     (* Anzahl der 512-Byte-Bloecke.
      * Der Compiler benutzt hoffentlich Bit-Operationen, anstatt
      * Multiplikation und Division...
      *)
     stBlocks := (((dta.size + BLKSIZEm1) DIV BLKSIZE) * BLKSIZE) DIV PSXBLK;
     stNlink  := 1;
   END;
 END; (* WITH st *)
END DTAStat;

(*--------------------------------------------------------------------------*)

PROCEDURE DoStat ((* EIN/ -- *) VAR name : ARRAY OF CHAR;
                  (* EIN/ -- *)     sym  : BOOLEAN;
                  (* -- /AUS *) VAR st   : StatRec ) : INTEGER;

VAR         err      : INTEGER;
    __REG__ pLen     : UNSIGNEDWORD;
            lenDir   : INTEGER;
            dot      : BOOLEAN;
            dotdot   : BOOLEAN;
            done     : BOOLEAN;
            stack    : ADDRESS;
            stack2   : ADDRESS;
            msize    : CARDINAL;
            flag     : CARDINAL;
            path0    : StrPtr;
            prevdir  : StrPtr;
            fullpath : StrPtr;
            dta      : DTA;
            dta2     : DTA;
            maxlen   : SIGNEDLONG;
            root     : BOOLEAN;
            drv      : BOOLEAN;

BEGIN
 msize := Length(name) + DINCR + 10;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(name), msize - DINCR - 10, VAL(StrRange,msize), path0,
           dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 (* Falls BOOLEAN-FALSE/TRUE nicht Null und Eins sind *)
 IF sym THEN
   flag := 1;
 ELSE
   flag := 0;
 END;
 done := Fxattr(flag, path0, ADR(st), err);
 IF err # eINVFN THEN
   (* 'Fxattr'-Aufruf wird unterstuetzt *)
   IF err < 0 THEN
     TstENOTDIR(path0, FALSE, err);
   ELSIF sym & (st.stMode * sIFMT = sIFLNK) THEN
     err := SymLengthUnix(path0, st.stSize);
   END;
   IF err < 0 THEN
     errno := err;
     err   := -1;
   ELSE
     err   := 0;
   END;
   DosToUnixStat(sym, path0, st);
   memdealloc(stack);
   RETURN(err);
 END;

 (* 'Fxattr'-Aufruf wird nicht unterstuetzt, TOS-Emulation *)

 IF IsDosDevice(path0) THEN
   TOSDeviceStat(st);
   memdealloc(stack);
   RETURN(0);
 END;

 IF Cisalpha(path0^[0]) & (path0^[1] = DDRVPOSTFIX) THEN
   st.stDev := VAL(devT,tocard(path0^[0]) - 10);
   drv      := TRUE;
 ELSE
   st.stDev := VAL(devT,Dgetdrv());
   drv      := FALSE;
 END;

 root   := FALSE;
 dotdot := FALSE;
 pLen   := VAL(UNSIGNEDWORD,strlen(path0));
 (* Wurzelverzeichnisse muessen gesondert behandelt werden, da sie nicht
  * wie Unterverzeichnisse in die Baumstruktur eingebunden sind - sie
  * haben kein Erstellungsdatum und besitzen nicht die Eintraege
  * "." und ".." zur Verkettung.
  * Ausserdem liefert 'Fsfirst' fuer "." und ".." die falschen Zeitdaten.
  *)
 IF          (pLen = 1) & (path0^[0] = DDIRSEP)
    OR drv & (pLen = 3) & (path0^[2] = DDIRSEP)
 THEN
   (* Ein Wurzelverzeichnis ist direkt angegeben, deshalb sind keine
    * weiteren Tests noetig.
    *)
   root := TRUE;
 ELSE
   IF path0^[pLen-1] = DDIRSEP THEN
     (* Verzeichnisse ohne abschliessenden \.
      * 'pLen' ist mindestens zwei, da der Fall 'pLen' = 1
      * oben abgefangen wird.
      *)
     path0^[pLen-1] := 0C;
     DEC(pLen);
   ELSIF drv & (pLen = 2) THEN
     (* "Fsfirst("x:")" funktioniert nicht *)
     path0^[2] := '.';
     path0^[3] := 0C;
     dot       := TRUE;
     INC(pLen);
   END;

   IF dot THEN
     (* Pfad endet mit "." oder "..". Vollstaendigen Pfad bestimmen.
      * Den ersten Eintrag suchen, so dass bei allen Verzeichnissen --
      * ausser dem Wurzelverzeichnis -- der Eintrag "." gefunden wird.
      * (Bei "..\*.*" wird der erste Eintrag des uebergeordneten
      * Verzeichnisses gefunden.)
      *)
     dotdot := path0^[pLen-2] = '.';
     strcpy(ADDADR(path0, pLen), ADR(tosmask[3])); (* ++ "\*.*" *)
     memalloc(PATHMAX, stack2, fullpath);
     done := CompletePath(path0, PATHMAX, fullpath, lenDir, err);
     IF done THEN
       path0 := fullpath;
       pLen  := VAL(UNSIGNEDWORD,lenDir - 4); (* -- "\*.*" *)
     ELSE (* Sollte eigtl. nicht passieren *)
       memdealloc(stack2);
     END;
   END;

   IF FindFirst(path0, AllEntries, dta, err) THEN
     IF dot THEN
       IF (dta.name[0] # '.') OR (dta.name[1] # 0C) THEN
         (* Nicht-leeres Wurzelverzeichnis, falls der erste Eintrag nicht
          * mit einem Punkt beginnt (normaler Dateiname), oder nach dem Punkt
          * nicht beendet ist (dann kann es nicht "." sein, das in allen
          * Verzeichnissen zuerst steht.
          *)
         root := TRUE;
       ELSIF done THEN (* dta.name = ".", fullpath *)
         (* Da "." existiert, handelt es sich um ein normales
          * Unterverzeichnis, kein Wurzelverzeichnis.
          * Die (Zeit)Daten der Eintraege "." und ".." sind nicht korrekt.
          * Versuchen, die Verzeichnisnamen zu bestimmen.
          * Bei ".." wird der Verzeichnisname durch rein textuelles Suchen
          * nach dem vorangehenden Pfadtrenner ermittelt. Das funktioniert,
          * solange das Verzeichnis kein symbolischer Link ist und nicht
          * selber mit "." oder ".." angegeben ist.
          *)
         IF dotdot THEN
           path0^[pLen-3] := 0C;
           prevdir := strrchr(path0, DDIRSEP);
           IF prevdir # NULL THEN
             (* Ein vorangehender \ sollte immer gefunden werden, da
              * 'path0' ein vollstaendiger, absoluter Pfad samt
              * Laufwerksangabe ist, und das uebergeordnete Verzeichnis
              * ein normales Unterverzeichnis ist, sonst wuerde "." nicht
              * existieren.
              *)
             prevdir^[0] := 0C;
             IF FindFirst(path0, AllEntries, dta2, err) THEN
               dta := dta2;
             END;
             prevdir^[0]    := DDIRSEP;
             path0^[pLen-3] := DDIRSEP;
           END;
         ELSE
           path0^[pLen-2] := 0C;
           IF FindFirst(path0, AllEntries, dta2, err) THEN
             dta := dta2;
           END;
           path0^[pLen-2] := DDIRSEP;
         END;
       END; (* IF dta.name[0] # '.' *)
     END; (* IF dot *)
   ELSE
     (* Wenn kein Eintrag gefunden wird und "." oder ".." angegeben
      * wurden, handelt es sich wahrscheinlich um ein leeres
      * Wurzelverzeichnis, ansonsten ist ein Fehler aufgetreten
      * (angegebene Datei wurde nicht gefunden).
      *)
     IF dot & (err = eFILNF) THEN
       root := TRUE;
     ELSE
       TstENOTDIR(path0, FALSE, err);
       memdealloc(stack);
       errno := err;
       RETURN(-1);
     END;
   END;
 END;

 IF root THEN
   TOSRootStat(st);
 ELSE
   path0^[pLen] := 0C;
   DTAStat(dta, path0, st);
 END;
 memdealloc(stack);
 RETURN(0);
END DoStat;

(*--------------------------------------------------------------------------*)

PROCEDURE stat ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                (* -- /AUS *) VAR st   : StatRec       ): int;

BEGIN
 RETURN(DoStat(file, FALSE, st));
END stat;

(*--------------------------------------------------------------------------*)

PROCEDURE lstat ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* -- /AUS *) VAR st   : StatRec       ): int;

BEGIN
 RETURN(DoStat(file, TRUE, st));
END lstat;

(*--------------------------------------------------------------------------*)

PROCEDURE access ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                  (* EIN/ -- *)     acc  : AccessModes   ): int;

VAR st  : StatRec;
    uid : INTEGER;

BEGIN
 IF DoStat(file, FALSE, st) < 0 THEN
   RETURN(-1);
 ELSIF acc = fOK THEN
   RETURN(0);
 END;

 uid := Pgetuid();
 IF (uid < 0) OR (uid = INT(st.stUid)) THEN
   IF acc <= CAST(AccessModes,VAL(UNSIGNEDWORD,
               CAST(UNSIGNEDWORD,st.stMode * sIRWXU) DIV 64))
   THEN
     RETURN(0);
   ELSE
     errno := EACCES;
     RETURN(-1);
   END;
 END;

 IF Pgetgid() = INT(st.stGid) THEN
   IF acc <= CAST(AccessModes,VAL(UNSIGNEDWORD,
               CAST(UNSIGNEDWORD,st.stMode * sIRWXG) DIV 8))
   THEN
     RETURN(0);
   ELSE
     errno := EACCES;
     RETURN(-1);
   END;
 END;

 IF acc <= CAST(AccessModes,st.stMode * sIRWXO) THEN
   RETURN(0);
 ELSE
   errno := EACCES;
   RETURN(-1);
 END;
END access;

(*--------------------------------------------------------------------------*)

PROCEDURE fstat ((* EIN/ -- *)     h  : int;
                 (* -- /AUS *) VAR st : StatRec ): int;

CONST FSTAT = 4600H; (* ('F'<< 8)|0 *)

      SEEKSET = 0;
      SEEKCUR = 1;
      SEEKEND = 2;

VAR         pos   : SIGNEDLONG;
            size  : SIGNEDLONG;
    __REG__ void  : BOOLEAN;
            time  : ARRAY [0..1] OF WORDSET;
            lres  : SIGNEDLONG;
            magic : UNSIGNEDWORD;
            dummy : StrPtr;
            tc    : TimeCast;
            date  : DosDate;

BEGIN
 IF Fcntl(h, ADR(st), FSTAT, lres) THEN
   DosToUnixStat(FALSE, NULL, st);
   RETURN(0);
 END;
 IF INT(lres) # eINVFN THEN
   (* 'Fcntl'-Aufruf wird unterstuetzt, anderer Fehler *)
   errno := INT(lres);
   RETURN(-1);
 END;

 (* 'Fcntl'-Aufruf wird nicht unterstuetzt, TOS-Emulation *)

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
 END;
 WITH st DO
   IF FD[VAL(HandleRange,h)].ftype = istty THEN
     stMode   := sIFCHR + STDPERM;
     stSize   := 0;
     tc.dtime := Tgettime();
     tc.ddate := Tgetdate();
   ELSE
     Fdatime(ADR(time), h, 0);
     tc.dtime := time[0];
     tc.ddate := time[1];

     IF Fseek(0, h, SEEKCUR, pos) THEN
       void   := Fseek(0, h, SEEKEND, size);
       stSize := size;

       void := Fseek(0, h, SEEKSET, size);
       void := Fread(h, 2, ADR(magic), lres);
       IF (lres = LIC(2)) & ((magic = 601AH) OR (magic = 2321H))(* #! *) THEN
         stMode := sIFREG + STDPERM + modeT{sIXUSR, sIXGRP, sIXOTH};
       ELSE
         stMode := sIFREG + STDPERM;
       END;
       void := Fseek(pos, h, SEEKSET, size);
     ELSE
       errno := EBADF;
       RETURN(-1);
     END;
   END;

   DecodeDate(tc.ddate, tc.dtime, date);
   stIno     := VAL(inoT,INODE); INC(INODE);
   stDev     := VAL(devT,Dgetdrv());
   stRdev    := 0;
   stNlink   := 1;
   stUid     := 0;
   stGid     := 0;
   stBlksize := BLKSIZE;
   stBlocks  := (((CAST(UNSIGNEDLONG,stSize) + BLKSIZEm1) DIV BLKSIZE) * BLKSIZE) DIV PSXBLK;
   stMtime   := DateToSeconds(date);
   stAtime   := stMtime;
   stCtime   := stMtime;
   stAttr    := FileAttributes{};
 END; (* WITH *)
 RETURN(0);
END fstat;

(*--------------------------------------------------------------------------*)

PROCEDURE opendir ((* EIN/ -- *) REF dir : ARRAY OF CHAR ): DIR;

CONST DPMAXNAME = 3;
      DPCASE    = 6;
        DPCASECONV = 1;

VAR dirp     : DIRptr;
    err      : INTEGER;
    ret      : DIR;
    lenDir   : INTEGER;
    maxlen   : SIGNEDLONG;
    flag     : BOOLEAN;
    done     : BOOLEAN;
    conv     : BOOLEAN;
    stack    : ADDRESS;
    stack2   : ADDRESS;
    msize    : CARDINAL;
    path0    : StrPtr;
    tosdir   : StrPtr;
    fullpath : StrPtr;
    size     : SIGNEDLONG;
    handle   : UNSIGNEDLONG;

BEGIN
 msize := Length(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(dir), msize - DINCR, VAL(StrRange,msize), path0, flag, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(NULL);
 END;

 (* Vollstaendigen Pfad von <dir> ermitteln. Der Platz wird solange
  * erhoeht, bis er reicht oder die max. Pfadlaenge ueberschritten ist.
  * (Begonnen wird mit der maximalen Pfadlaenge innerhalb von <dir>.
  * Das muss aber nicht die maximale Laenge von <dir> sein, da Teile
  * von <dir> auf einem anderen Dateisystem liegen koennen und symbolische
  * Links sein koennen oder gemountet sein koennen, oder die max. Pfadlaenge
  * kann auch von der Verschachtelungstiefe innerhalb des Dateisystems
  * abhaengen!)
  *)
 maxlen := PATHMAX;
 LOOP
   IF maxlen > VAL(SIGNEDLONG,MAXPATHALLOC) THEN
     (* Riesige Pfadlaenge, sollte eigentlich nicht passieren *)
     EXIT;
   END;
   memalloc(VAL(sizeT,maxlen), stack2, fullpath);
   done := CompletePath(path0, VAL(StrRange,maxlen)-2, fullpath, lenDir, err);
   (* Zwei Zeichen weniger Platz, damit noch "\." angehaengt werden kann *)
   IF done THEN
     EXIT;
   ELSE
     IF err = eRANGE THEN
       (* Platz zu klein -> Platz verdoppeln und nochmal probieren *)
       memdealloc(stack2);
       INC(maxlen, maxlen);
     ELSE
       (* Fehler beim Ermitteln des Verzeichnisses -> aufgeben *)
       EXIT;
     END;
   END;
 END;
 IF ~done THEN
   (* Sollte eigtl. nicht passieren *)
   memdealloc(stack);
   errno := err;
   RETURN(NULL);
 END;

 (* An den Verzeichnisnamen "\." anhaengen (fuer den Fall, dass es
  * sich um einen symbolischen Link handelt).
  *)
 flag := fullpath^[VAL(StrRange,lenDir-1)] = DDIRSEP;
 IF ~flag THEN
   fullpath^[VAL(StrRange,lenDir)] := DDIRSEP; INC(lenDir);
 END;
 fullpath^[VAL(StrRange,lenDir)]   := '.';
 fullpath^[VAL(StrRange,lenDir+1)] := 0C;

 (* fullpath^: Vollstaendiger DOS-Pfad von <dir> mit abschl. "\.".
  * lenDir   : Laenge von fullpath^ bis zum Backslash
  *)

 IF Dpathconf(fullpath, DPMAXNAME, maxlen) THEN
   IF maxlen > VAL(SIGNEDLONG,MAXPATHALLOC) THEN
     maxlen := MAXPATHALLOC;
   END;
 ELSIF INT(maxlen) # eINVFN THEN
   (* Noch mal Originalpfad versuchen, falls Dateisystem kein "." kennt *)
   IF flag THEN
     fullpath^[VAL(StrRange,lenDir)]   := 0C;
   ELSE
     fullpath^[VAL(StrRange,lenDir-1)] := 0C;
   END;
   IF Dpathconf(fullpath, DPMAXNAME, maxlen) THEN
     IF maxlen > VAL(SIGNEDLONG,MAXPATHALLOC) THEN
       maxlen := MAXPATHALLOC;
     END;
   ELSE
     (* Max. Laenge kann nicht festgestellt werden, Default nehmen *)
     maxlen := NAMEMAX;
   END;
 ELSE
   maxlen := NAMEMAX;
 END;

 (* Nur wenn das Dateisystem den Dpathconf(DP_CASE)-Aufruf nicht kennt,
  * oder wenn sowieso grundsaetzlich in Grossbuchstaben konvertiert
  * wird, werden die Dateinamen in Kleinbuchstaben konvertiert, sonst
  * werden vom Dateisystem Gross/Kleinbuchstaben entweder unterschieden
  * oder zumindest beibehalten.
  * fullpath^ mit oder ohne "\.", je nach dem eben Festgestellten.
  *)
 conv := ~Dpathconf(fullpath, DPCASE, size) OR (INT(size) = DPCASECONV);

 (* Fuer 'Dopendir' Originalpfad verwenden *)
 IF flag THEN
   fullpath^[VAL(StrRange,lenDir-1)] := DDIRSEP;
   fullpath^[VAL(StrRange,lenDir)]   := 0C;
 ELSE
   fullpath^[VAL(StrRange,lenDir-1)] := 0C;
 END;
 ret  := NULL;
 IF Dopendir(fullpath, 0, handle) THEN
   (* 'Dopendir' und die anderen dir-Funktionen werden unterstuetzt *)
   size :=  VAL(SIGNEDLONG,TSIZE(DIRtype))
          + VAL(SIGNEDLONG,lenDir + 10) + maxlen (* Fuer 'fpath' *)
          + maxlen; (* Fuer 'fname' *)
   dirp := malloc(size);
   IF dirp = NULL THEN
     (* vielleicht bessser: errno := EMFILE; ? *)
     done := Dclosedir(handle, err);
   ELSE
     WITH dirp^ DO
       posixstyle := TRUE; (* Flag: 'Dreaddir' usw. benutzen *)
       xread      := TRUE; (* Erstmal probieren *)
       cconv      := conv;
       dhandle    := handle;
       offset     := 0;
       ret        := CAST(DIR,dirp);
       bufsize    := VAL(SIGNEDLONG,TSIZE(UNSIGNEDLONG) + 1) + maxlen;
       IF ODD(bufsize) THEN
         (* Damit 'fpath' an gerader Adresse liegt *)
         INC(bufsize);
       END;
       fpath      := ADDADR(ADR(dino), bufsize);
       dirlen     := VAL(UNSIGNEDWORD,lenDir);
       memmove(fpath, fullpath, VAL(sizeT,dirlen));
       (* Pfad mit \ abschliessen, damit nur noch der Dateiname
        * angehaengt zu werden braucht. Nullbyte ist unnoetig.
        *)
       fpath^[dirlen-1] := DDIRSEP;
     END;
   END;
   memdealloc(stack);
   RETURN(ret);

__RANGECHECK_OFF__
 ELSIF INT(handle) # eINVFN THEN
   (* 'Dopendir' wird unterstuetzt, anderer Fehler *)
   err := INT(handle);
__RANGECHECK_PREV__
   TstENOTDIR(fullpath, TRUE, err);
   errno := err;
   memdealloc(stack);
   RETURN(NULL);
 END;

 (* 'Dopendir' etc. wird nicht unterstuetzt, TOS-Emulation *)

 size := VAL(SIGNEDLONG,TSIZE(DIRtype)) + VAL(SIGNEDLONG,lenDir + 20);
 dirp := malloc(size);
 IF dirp = NULL THEN
   (* vielleicht bessser: errno := EMFILE; ? *)
   memdealloc(stack);
   RETURN(NULL);
 END;

 WITH dirp^ DO
   posixstyle := FALSE; (* Flag: 'Fsnext' benutzen *)
   tosdir     := ADR(dirname);
   cconv      := conv;
   offset     := 0;
   drive      := VAL(devT,tocard(fullpath^[0]) - 10);
   dirlen     := VAL(UNSIGNEDWORD,lenDir);
   (* Vollstaendigen Pfad mit Laufwerksangabe merken, damit bei
    * "rewinddir()" das richtige Verzeichnis benutzt wird, falls
    * sich das aktuelle Verzeichnis inzwischen aendert.
    *)
   memmove(tosdir, fullpath, VAL(sizeT,dirlen)); (* Nullbyte unnoetig *)
   (* Alle Dateien finden *)
   strcpy(ADDADR(tosdir, dirlen-1), ADR(tosmask[3])); (* ++ "\*.*" *)

   IF FindFirst(tosdir, AllEntries, dta, err) THEN
     status := STARTSEARCH;
   ELSIF err = eFILNF THEN
     status := NMFILE;
   ELSE
     free(dirp);
     dirp := NULL;
     TstENOTDIR(tosdir, TRUE, err);
     errno := err;
   END;
 END; (* WITH dirp^ *)
 memdealloc(stack);
 RETURN(CAST(DIR,dirp));
END opendir;

(*---------------------------------------------------------------------------*)

PROCEDURE readdir ((* EIN/ -- *) dir : DIR ): DirentPtr;

VAR err  : INTEGER;
    dirp : DIRptr;

BEGIN
 IF dir = NULL THEN
   errno := EBADF;
   RETURN(NULL);
 END;

 dirp := CAST(DIRptr,dir);
 WITH dirp^ DO
   dirent.dStatValid := FALSE;
   IF posixstyle THEN
     IF ~Dreaddir(VAL(CARDINAL,bufsize), dhandle, ADR(dino), err) THEN
       IF err # eNMFIL THEN
         errno := err;
       END;
       RETURN(NULL);
     END;
     dirent.dName := ADR(fname);
     dirent.dIno  := dino;
   ELSE
     IF status = NMFILE THEN
       RETURN(NULL);
     ELSIF status = STARTSEARCH THEN
       status := INSEARCH;
     ELSE
       IF ~FindNext(dta, err) THEN
         IF err = eNMFIL THEN
           status := NMFILE;
         ELSE
           errno := err;
         END;
         RETURN(NULL);
       END;
     END;
     Assign(dta.name, dname);
     dirent.dName := ADR(dname);
     dirent.dIno  := VAL(inoT,INODE); INC(INODE);
   END; (* IF posixstyle *)

   IF cconv THEN
     strlwr(dirent.dName);
   END;
   dirent.dNamlen := strlen(dirent.dName);
   INC(offset);
   RETURN(ADR(dirent));
 END; (* WITH dirp^ *)
END readdir;

(*---------------------------------------------------------------------------*)

PROCEDURE xreaddir ((* EIN/ -- *) dir : DIR ): DirentPtr;

VAR err     : INTEGER;
    xerr    : INTEGER;
    dirp    : DIRptr;
    done    : BOOLEAN;
    tosdir  : StrPtr;
    prevdir : StrPtr;
    dta2    : DTA;

BEGIN
 IF dir = NULL THEN
   errno := EBADF;
   RETURN(NULL);
 END;

 dirp := CAST(DIRptr,dir);
 WITH dirp^ DO
   dirent.dStatValid := TRUE;
   IF posixstyle THEN
     IF xread THEN
       done := Dxreaddir(VAL(CARDINAL,bufsize), dhandle, ADR(dino), ADR(dirent.dStat), xerr, err);
       IF err = eINVFN THEN
         xread := FALSE;
       END;
     END;
     IF ~xread THEN
       done := Dreaddir(VAL(CARDINAL,bufsize), dhandle, ADR(dino), err);
     END;
     IF ~done THEN
       IF err # eNMFIL THEN
         errno := err;
       END;
       RETURN(NULL);
     END;

     WITH dirent DO
       dName := ADR(fname);
       dIno  := dino;
       strcpy(ADDADR(fpath, dirlen), dName); (* Mit Nullbyte *)
       IF   ~xread
         OR (dName^[0] = '.') & ((dName^[1] = 0C) OR (dName^[1] = '.')
                                                   & (dName^[2] = 0C))
       THEN
         (* Bei "." und ".." stimmen zumindest bei TOS 2.06 die
          * Zeitdaten nicht, deshalb 'Fxattr' verwenden; oder wenn
          * 'Dxreaddir' nicht unterstuetzt wird.
          *)
         done := Fxattr(1, fpath, ADR(dStat), xerr);
       END;
       IF xerr = 0 THEN
         (* Der 'Fxattr'-Teil war erfolgreich *)
         DosToUnixStat(TRUE, fpath, dStat);
         IF dStat.stMode * sIFMT = sIFLNK THEN
           (* Laenge des symbolischen Links in *IX-Notation ermitteln *)
           IF SymLengthUnix(fpath, dStat.stSize) < 0 THEN
             dStatValid := FALSE;
           END;
         END;
       ELSE
         dStatValid := FALSE;
       END;
     END;
   ELSE (* posixstyle *)
     IF status = NMFILE THEN
       RETURN(NULL);
     ELSIF status = STARTSEARCH THEN
       status := INSEARCH;
     ELSE
       IF ~FindNext(dta, err) THEN
         IF err = eNMFIL THEN
           status := NMFILE;
         ELSE
           errno := err;
         END;
         RETURN(NULL);
       END;
     END;
     Assign(dta.name, dname);
     dirent.dName := ADR(dname);
     dirent.dIno  := VAL(inoT,INODE); INC(INODE);

     done := FALSE;
     IF dta.name[0] = '.' THEN
       (* Die (Zeit)Daten der Eintraege "." und ".." sind zumindest bei
        * TOS 2.06 nicht korrekt. Versuchen, durch die richtigen Namen
        * zu ersetzen.
        *)
       tosdir := ADR(dirname);
       IF dta.name[1] = 0C THEN
         (* Da "." existiert, handelt es sich um ein normales
          * Unterverzeichnis, kein Wurzelverzeichnis, also das Verzeichnis
          * selber ohne angehaengtes "\*.*" benutzen. Das funktioniert,
          * solange das Verzeichnis nicht selbst als "." oder ".."
          * angegeben ist.
          *)
         tosdir^[dirlen-1] := 0C;
         IF FindFirst(tosdir, AllEntries, dta2, err) THEN
           DTAStat(dta2, ADR(dname), dirent.dStat);
           done := TRUE;
         END;
         tosdir^[dirlen-1] := DDIRSEP;
       ELSIF (dta.name[1] = '.') & (dta.name[2] = 0C) THEN
         (* Bei ".." muss ein extra FindFirst("..\*.*") gemacht werden,
          * da ".." auf ein Wurzelverzeichnis verweisen koennte, was speziell
          * behandelt werden muss.
          *)
         strcpy(ADDADR(tosdir, dirlen), ADR(tosmask[1])); (* ++ "..\*.*" *)
         IF FindFirst(tosdir, AllEntries, dta2, err) THEN
           IF (dta2.name[0] # '.') OR (dta2.name[1] # 0C) THEN
             (* Wenn der erste Eintrag nicht "." ist, handelt es sich um
              * ein TOS-Wurzelverzeichnis. Das uebergeordnete Verzeichnis
              * kann nicht leer sein, da sich ja mindestens das zu lesende
              * Verzeichnis darin befindet.
              *)
             TOSRootStat(dirent.dStat);
             done := TRUE;
           ELSE
             (* Das uebergeordnete Verzeichnis ist ein normales
              * Unterverzeichnis, deshalb wie bei "." ein FindFirst
              * auf den Verzeichnisnamen. Der Verzeichnisname wird
              * durch rein textuelles Suchen nach dem vorangehenden
              * Pfadtrenner ermittelt. Das funktioniert, solange das
              * Verzeichnis kein symbolischer Link ist und nicht selbst
              * mit "." oder ".." angegeben ist.
              *)
             tosdir^[dirlen-1] := 0C;
             prevdir := strrchr(tosdir, DDIRSEP);
             IF prevdir # NULL THEN
               (* Ein vorangehender \ sollte immer gefunden werden, da
                * 'tosdir' ein vollstaendiger, absoluter Pfad samt
                * Laufwerksangabe ist.
                *)
               prevdir^[0] := 0C;
               IF FindFirst(tosdir, AllEntries, dta2, err) THEN
                 DTAStat(dta2, ADR(dname), dirent.dStat);
                 done := TRUE;
               END;
               prevdir^[0] := DDIRSEP;
             END;
             tosdir^[dirlen-1] := DDIRSEP;
           END;
         END;
         strcpy(ADDADR(tosdir, dirlen), ADR(tosmask[4])); (* ++ "*.*" *)
       END;
     END; (* IF dta.name[0] = '.' *)
     IF ~done THEN
       DTAStat(dta, ADR(dname), dirent.dStat);
     END;
     dirent.dStat.stDev := drive;
   END; (* IF posixstyle *)

   IF cconv THEN
     strlwr(dirent.dName);
   END;
   dirent.dNamlen := strlen(dirent.dName);
   INC(offset);
   RETURN(ADR(dirent));
 END; (* WITH dirp^ *)
END xreaddir;

(*---------------------------------------------------------------------------*)

PROCEDURE rewinddir ((* EIN/ -- *) dir : DIR );

VAR err  : INTEGER;
    dirp : DIRptr;

BEGIN
 IF dir = NULL THEN
   RETURN;
 END;

 dirp := CAST(DIRptr,dir);
 WITH dirp^ DO
   IF posixstyle THEN
     IF Drewinddir(dhandle, err) THEN
       offset := 0;
     END;
   ELSE
     IF FindFirst(ADR(dirname), AllEntries, dta, err) THEN
       status := STARTSEARCH;
     ELSE
       status := NMFILE;
     END;
     offset := 0;
   END;
 END;
END rewinddir;

(*---------------------------------------------------------------------------*)

PROCEDURE closedir ((* EIN/AUS *) VAR dir : DIR ): int;

VAR dirp : DIRptr;
    res  : INTEGER;

BEGIN
 IF dir = NULL THEN
   errno := EBADF;
   RETURN(-1);
 END;

 dirp := CAST(DIRptr,dir);
 WITH dirp^ DO
   IF posixstyle THEN
     IF ~Dclosedir(dhandle, res) THEN
       errno := res;
       RETURN(-1);
     END;
   END;
   free(dirp);
 END;

 dirp := NULL;
 RETURN(0);
END closedir;

(*--------------------------------------------------------------------------*)

PROCEDURE telldir ((* EIN/ -- *) dir : DIR ): offT;

VAR dirp : DIRptr;

BEGIN
 IF dir = NULL THEN
   errno := EBADF;
   RETURN(-1);
 END;
 dirp := CAST(DIRptr,dir);
 RETURN(dirp^.offset);
END telldir;

(*--------------------------------------------------------------------------*)

PROCEDURE seekdir ((* EIN/ -- *) dir : DIR;
                   (* EIN/ -- *) loc : offT );

VAR dirp : DIRptr;

BEGIN
 IF dir # NULL THEN
   rewinddir(dir);
   dirp := CAST(DIRptr,dir);
   LOOP
     IF (dirp^.offset = loc) OR (readdir(dir) = NULL) THEN
       RETURN;
     END;
   END;
 END;
END seekdir;

(*--------------------------------------------------------------------------*)

PROCEDURE mkdir ((* EIN/ -- *) REF dir  : ARRAY OF CHAR;
                 (* EIN/ -- *)     mode : modeT         ): int;

VAR res   : INTEGER;
    dot   : BOOLEAN;
    done  : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 msize := Length(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(dir), msize - DINCR, VAL(StrRange,msize), path0, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF FileExists(path0, TRUE, res) THEN
   errno := EEXIST;
   memdealloc(stack);
   RETURN(-1);
 ELSIF (res # eFILNF) & (res # ePTHNF) THEN
   errno := res;
   memdealloc(stack);
   RETURN(-1);
 END;

 IF ~Dcreate(path0, res) THEN
   TstENOTDIR(path0, FALSE, res);
   errno := res;
   res   := -1;
 ELSE
   done := Fchmod(path0, mode - UMASK, res);
   res  := 0;
 END;
 memdealloc(stack);
 RETURN(res);
END mkdir;

(*---------------------------------------------------------------------------*)

PROCEDURE rmdir ((* EIN/ -- *) REF dir : ARRAY OF CHAR ): int;

VAR res    : INTEGER;
    res2   : INTEGER;
    dot    : BOOLEAN;
    done   : BOOLEAN;
    stack  : ADDRESS;
    msize  : CARDINAL;
    path0  : StrPtr;
    plen   : CARDINAL;
    dta    : DTA;
    handle : UNSIGNEDLONG;
    buf : RECORD
      index : UNSIGNEDLONG;
      name  : ARRAY [0..3] OF CHAR;
    END;

BEGIN
 msize := Length(dir) + DINCR + 4; (* + 4 wegen ++ "\*.*" *);
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(dir), msize - DINCR - 4, VAL(StrRange,msize), path0,
           dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF ~Ddelete(path0, res) THEN
   IF (res = ePTHNF) OR (res = eFILNF) THEN
     TstENOTDIR(path0, TRUE, res);
   ELSIF res = eACCDN THEN
     (* Testen, ob noch Dateien ausser '.' und '..' im Verzeichnis sind;
      * dann ist die Fehlermeldung gleich ENOTEMPTY.
      *)
     IF Dopendir(path0, 0, handle) THEN
       REPEAT
         done := Dreaddir(SIZE(buf), handle, ADR(buf), res2);
         dot  := done
                 &
                 (buf.name[0] = '.') & ((buf.name[1] = 0C)
                                     OR (buf.name[1] = '.') & (buf.name[2] = 0C));
       UNTIL ~dot;
       IF done OR (res2 # eNMFIL) THEN
         (* Wenn der Fehler eRANGE ist, gibt es auch noch weitere
          * Dateien im Verzeichnis!
          *)
         res := ENOTEMPTY;
       END;
       done := Dclosedir(handle, res2);
__RANGECHECK_OFF__
     ELSIF INT(handle) = eINVFN THEN
__RANGECHECK_PREV__
       (* 'Dopendir' wird nicht unterstuetzt *)
       plen := VAL(CARDINAL,strlen(path0));
       IF path0^[VAL(UNSIGNEDWORD,plen-1)] = DDIRSEP THEN
         strcpy(ADDADR(path0, plen), ADR(tosmask[4])); (* ++ "*.*" *)
       ELSE
         strcpy(ADDADR(path0, plen), ADR(tosmask[3])); (* ++ "\*.*" *)
       END;
       IF FindFirst(path0, AllEntries, dta, res2) THEN
         done := TRUE;
         WHILE done
             & (dta.name[0] = '.') & ((dta.name[1] = 0C)
                                   OR (dta.name[1] = '.') & (dta.name[2] = 0C))
         DO
           done := FindNext(dta, res2);
         END;
         IF done OR (res2 # eNMFIL) THEN
           res := ENOTEMPTY;
         END;
       END;
     END;
   END;
   errno := res;
   res   := -1;
 ELSE
   res := 0;
 END;
 memdealloc(stack);
 RETURN(res);
END rmdir;

(*---------------------------------------------------------------------------*)

PROCEDURE unlink ((* EIN/ -- *) REF file : ARRAY OF CHAR ): int;

VAR res   : INTEGER;
    done  : BOOLEAN;
    dot   : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 msize := Length(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(file), msize - DINCR, VAL(StrRange,msize), path0, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF ~Fdelete(path0, res) THEN
   TstENOTDIR(path0, FALSE, res);
   errno := res;
   res   := -1;
 ELSE
   res := 0;
 END;
 memdealloc(stack);
 RETURN(res);
END unlink;

(*--------------------------------------------------------------------------*)

PROCEDURE link ((* EIN/ -- *) REF old : ARRAY OF CHAR;
                (* EIN/ -- *) REF new : ARRAY OF CHAR ): int;

VAR dot    : BOOLEAN;
    done1  : BOOLEAN;
    done2  : BOOLEAN;
    res    : INTEGER;
    res2   : INTEGER;
    path01 : StrPtr;
    path02 : StrPtr;
    stack  : ADDRESS;
    void   : ADDRESS;
    msize1 : CARDINAL;
    msize2 : CARDINAL;
    xattr  : XATTR;

BEGIN
 msize1 := Length(old) + DINCR;
 msize2 := Length(new) + DINCR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(REFADR(old), msize1-DINCR, VAL(StrRange,msize1), path01, dot, done1);
 UnixToDos(REFADR(new), msize2-DINCR, VAL(StrRange,msize2), path02, dot, done2);
 IF ~(done1 & done2) THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF ~Flink(path01, path02, res) THEN
   IF (res = ePTHNF) OR (res = eFILNF) THEN
     IF ~FileExists(path01, TRUE, res2) THEN
       (* Es liegt an <old> *)
       path02 := path01;
     END;
     TstENOTDIR(path02, FALSE, res);
   ELSIF (res = eACCDN) & Fxattr(1, path02, ADR(xattr), res) THEN
     res := EEXIST;
   END;
   errno := res;
   res   := -1;
 ELSE
   res := 0;
 END;
 memdealloc(stack);
 RETURN(res);
END link;

(*--------------------------------------------------------------------------*)

PROCEDURE symlink ((* EIN/ -- *) REF old : ARRAY OF CHAR;
                   (* EIN/ -- *) REF new : ARRAY OF CHAR ): int;

VAR dot    : BOOLEAN;
    done1  : BOOLEAN;
    done2  : BOOLEAN;
    res    : INTEGER;
    path01 : StrPtr;
    path02 : StrPtr;
    stack  : ADDRESS;
    void   : ADDRESS;
    msize1 : CARDINAL;
    msize2 : CARDINAL;
    xattr  : XATTR;

BEGIN
 msize1 := Length(old) + DINCR;
 msize2 := Length(new) + DINCR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(REFADR(old), msize1-DINCR, VAL(StrRange,msize1), path01, dot, done1);
 UnixToDos(REFADR(new), msize2-DINCR, VAL(StrRange,msize2), path02, dot, done2);
 IF ~(done1 & done2) THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF ~Fsymlink(path01, path02, res) THEN
   IF (res = ePTHNF) OR (res = eFILNF) THEN
     TstENOTDIR(path02, FALSE, res);
   ELSIF (res = eACCDN) & Fxattr(1, path02, ADR(xattr), res) THEN
     res := EEXIST;
   END;
   errno := res;
   res   := -1;
 ELSE
   res := 0;
 END;
 memdealloc(stack);
 RETURN(res);
END symlink;

(*--------------------------------------------------------------------------*)

PROCEDURE readlink ((* EIN/ -- *) REF lname  : ARRAY OF CHAR;
                    (* EIN/ -- *)     buf    : StrPtr;
                    (* EIN/ -- *)     bufsiz : sizeT         ): int;

VAR dot    : BOOLEAN;
    done   : BOOLEAN;
    res    : INTEGER;
    xlen   : INTEGER;
    path01 : StrPtr;
    path02 : StrPtr;
    stack  : ADDRESS;
    void   : ADDRESS;
    msize1 : CARDINAL;
    msize2 : CARDINAL;
    xattr  : XATTR;

BEGIN
 IF VAL(sizeT,MAXSTR) < bufsiz THEN
   bufsiz := VAL(sizeT,MAXSTR);
 END;
 msize1 := Length(lname) + DINCR;
 msize2 := VAL(CARDINAL,bufsiz) + XDECR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(REFADR(lname), msize1-DINCR, VAL(StrRange,msize1), path01, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF ~Freadlink(msize2, path02, path01, res) & (res # eRANGE) THEN
   IF (res = ePTHNF) OR (res = eFILNF) THEN
     TstENOTDIR(path01, FALSE, res);
   ELSIF (res = eACCDN)
       & Fxattr(1, path01, ADR(xattr), res) & (xattr.mode * sIFMT # sIFLNK)
   THEN
     (* Ist kein symbolischer Link *)
     res := EINVAL;
   END;
   errno := res;
   res   := -1;
 ELSE
   IF res = eRANGE THEN
     (* Link ist laenger als msize2. Das letzte Byte durch ein Nullbyte
      * ersetzen, falls nicht schon vom Dateisystem erledigt. (MinixFS
      * schliesst mit Nullbyte ab, uniFS und pipeFS nicht!)
      *)
     path02^[VAL(StrRange,msize2-1)] := 0C;
   END;
   (* Es kann davon ausgegangen werden, dass 'Freadlink' die
    * Gross/Kleinschreibung selbst beruecksichtigt.
    *)
   DosToUnix(path02, FALSE, VAL(StrRange,bufsiz), buf, res, xlen);
   IF VAL(sizeT,xlen) > bufsiz THEN
     res := INT(bufsiz);
   ELSE
     res := xlen;
   END;
 END;
 memdealloc(stack);
 RETURN(res);
END readlink;

(*--------------------------------------------------------------------------*)

PROCEDURE rename ((* EIN/ -- *) REF old : ARRAY OF CHAR;
                  (* EIN/ -- *) REF new : ARRAY OF CHAR ): int;

VAR res    : INTEGER;
    res2   : INTEGER;
    done1  : BOOLEAN;
    done2  : BOOLEAN;
    dot    : BOOLEAN;
    path01 : StrPtr;
    path02 : StrPtr;
    stack  : ADDRESS;
    void   : ADDRESS;
    msize1 : CARDINAL;
    msize2 : CARDINAL;
    dta    : DTA;
    xattr1 : XATTR;
    xattr2 : XATTR;

BEGIN
 msize1 := Length(old) + DINCR;
 msize2 := Length(new) + DINCR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(REFADR(old), msize1-DINCR, VAL(StrRange,msize1), path01, dot, done1);
 UnixToDos(REFADR(new), msize2-DINCR, VAL(StrRange,msize2), path02, dot, done2);
 IF ~(done1 & done2) THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF   Fxattr(1, path01, ADR(xattr1), res)
    & Fxattr(1, path02, ADR(xattr2), res)
    & (xattr1.dev   = xattr2.dev)
    & (xattr1.index = xattr2.index)
   OR (strcmp(path01, path02) = 0)
 THEN
   (* sonst wird die Datei nachher geloescht...
    * Vergleich erst NACH "UnixToDos()", da unterschiedliche *IX-Namen
    * evtl. auf denselben DOS-Namen abgebildet werden!
    *)
   errno := EEXIST;
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Frename(path01, path02, res) THEN
   memdealloc(stack);
   RETURN(0);
 END;

 IF (res # ePTHNF) & (res # eFILNF) & (res # eNSAME) THEN
   IF Fdelete(path02, res2) THEN
     done1 := Frename(path01, path02, res);
   END;
   IF (res = eACCDN) & (res2 # ePTHNF) THEN
     (* Statt 'Frename' mit 'Flink' den neuen Dateieintrag anlegen und den
      * alten mit 'Fdelete' loschen.
      *)
     IF Flink(path01, path02, res) THEN
       IF ~(Fdelete(path01, res2) OR (res2=eFILNF) OR (res2=ePTHNF)) THEN
         (* Wenn die alte Datei nicht geloescht werden kann, den Link
          * wieder entfernen.
          *)
         done1 := Fdelete(path02, res2);
       END;
     ELSIF res = eINVFN THEN
       res := EACCES;
     END;
   END;
 END;
 IF res < 0 THEN
   IF (res = ePTHNF) OR (res = eFILNF) THEN
     IF ~FileExists(path01, TRUE, res2) THEN
       (* Es liegt an <old> *)
       path02 := path01;
     END;
     TstENOTDIR(path02, FALSE, res);
   END;
   errno := res;
   res   := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END rename;

(*---------------------------------------------------------------------------*)

PROCEDURE chmod ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     mode : modeT         ): int;

VAR res    : INTEGER;
    lres   : LONGINT;
    dot    : BOOLEAN;
    done   : BOOLEAN;
    stack  : ADDRESS;
    msize  : CARDINAL;
    ws     : WORDSET;
    attr   : FileAttributes;
    path0  : StrPtr;
    dta    : DTA;

BEGIN
 msize := Length(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(REFADR(file), msize - DINCR, VAL(StrRange,msize), path0, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Fchmod(path0, mode, res) THEN
   res := 0;
 ELSIF res = eFILNF THEN
   (* 'Fchmod'-Aufruf wird unterstuetzt *)
   IF IsDosDir(path0) THEN
     (* Fehler bei Verzeichnis auf DOS-Dateisystem ignorieren *)
     res := 0;
   ELSE
     done := FALSE;
   END;
 ELSIF (res = eINVFN) & FindFirst(path0, AllEntries, dta, res) THEN
   (* 'Fchmod'-Aufruf wird nicht unterstuetzt *)
   attr := dta.attr;
   IF faCHANGED IN attr THEN
     (* Archivbit nicht veraendern *)
     attr := FileAttributes{faRDONLY, faCHANGED};
   ELSE
     attr := FileAttributes{faRDONLY};
   END;
   IF sIWUSR IN mode THEN
     EXCL(attr, faRDONLY);
   END;
   IF Fattrib(path0, 1, attr, ws) OR (faSUBDIR IN attr) THEN
     (* Fehler bei Verzeichnisattributen ignorieren *)
     res := 0;
   ELSE
     done := FALSE;
     res  := INT(CAST(SIGNEDWORD,ws));
   END;
 ELSE
   done := FALSE;
 END;

 IF ~done THEN
   TstENOTDIR(path0, FALSE, res);
   errno := res;
   res   := -1;
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
 msize := Length(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, dot, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Fchown(path0, uid, gid, res) THEN
   res := 0;
 ELSIF res # eINVFN THEN
   (* 'Fchown'-Aufruf wird unterstuetzt, anderer Fehler *)
   TstENOTDIR(path0, FALSE, res);
   errno := res;
   res   := -1;
 ELSIF (uid = 0) & (gid = 0) THEN
   res   := 0;
 ELSE
   errno := EINVAL;
   res   := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END chown;

(*--------------------------------------------------------------------------*)

PROCEDURE utime ((* EIN/ -- *) REF file : ARRAY OF CHAR;
                 (* EIN/ -- *)     time : UTimPtr       ): int;

CONST FUTIME  = 4603H; (* ('F'<<8)|3 *)
      WRONLY  = 1;

VAR lres   : SIGNEDLONG;
    res    : INTEGER;
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
 msize := Length(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, void, done);
 IF ~done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF time = NULL THEN
   (* Fcntl bzw. Dcntl entscheiden selbst weiter *)
   tptr := NULL;
 ELSE
   SecondsToDate(time^.modtime, date);
   EncodeDate(date, tm.modtime.ddate, tm.modtime.dtime);
   SecondsToDate(time^.actime, date);
   EncodeDate(date, tm.actime.ddate, tm.actime.dtime);
   tptr := ADR(tm);
 END;
 IF Dcntl(FUTIME, path0, tptr, lres) THEN
   memdealloc(stack);
   RETURN(0);
 ELSIF INT(lres) # eINVFN THEN
   (* Dateisystem unterstuetzt den Dcntl- bzw. FUTIME-Aufruf, aber anderer
    * Fehler, deswegen abbrechen.
    *)
   res := INT(lres);
   TstENOTDIR(path0, FALSE, res);
   memdealloc(stack);
   errno := res;
   RETURN(-1);
 END;

 done := Fopen(path0, WRONLY, hndl);
 IF done THEN
   IF ~Fcntl(hndl, tptr, FUTIME, lres) THEN
     (* 'Fcntl' oder FUTIME werden nicht unterstuetzt oder anderer Fehler *)
     tm.modtime.dtime := Tgettime();
     tm.modtime.ddate := Tgetdate();
     Fdatime(ADR(tm.modtime), hndl, 1);
   END;
   void := Fclose(hndl, hndl);
 ELSIF (hndl = eFILNF) OR (hndl = ePTHNF)  THEN
   IF (hndl = eFILNF) & IsDosDir(path0) THEN
     (* Fehler bei Verzeichnis auf DOS-Dateisystem ignorieren *)
     done := TRUE;
   ELSE
     TstENOTDIR(path0, FALSE, hndl);
   END;
 END;

 IF done THEN
   hndl := 0;
 ELSE
   errno := hndl;
   hndl  := -1;
 END;
 memdealloc(stack);
 RETURN(hndl);
END utime;

(*---------------------------------------------------------------------------*)

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

PROCEDURE major ((* EIN/ -- *) rdev : devT ): unsigned;
BEGIN
 RETURN(INT((rdev DIV 256) MOD 256));
END major;

(*--------------------------------------------------------------------------*)

PROCEDURE minor ((* EIN/ -- *) rdev : devT ): unsigned;
BEGIN
 RETURN(INT(rdev MOD 256));
END minor;

(*--------------------------------------------------------------------------*)

PROCEDURE makedev ((* EIN/ -- *) maj : unsigned;
                   (* EIN/ -- *) min : unsigned ): devT;
BEGIN
 RETURN(VAL(devT,(maj MOD 256) * 256 + min MOD 256));
END makedev;

(*===========================================================================*)

BEGIN (* dir *)
 tosmask := "\..\*.*";
 rootdir := "@:\\";
 magic   := MagiCVersion() >= 0;
END dir.
