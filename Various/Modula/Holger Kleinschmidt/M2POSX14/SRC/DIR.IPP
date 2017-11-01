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
(*---------------------------------------------------------------------------*)
(* 29-Mai-94, Holger Kleinschmidt                                            *)
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
(* CONST*) EOS, NULL, DDIRSEP, PATHMAX, MAXSTR,
(* TYPE *) int, offT, inoT, sizeT, StrPtr, StrRange, PathName;

FROM MEMBLK IMPORT
(* PROC *) memalloc, memdealloc;

FROM OSCALLS IMPORT
(* PROC *) Dcreate, Fchmod, Ddelete, Dopendir, Dreaddir, Drewinddir,
           Dclosedir, Dpathconf, Fdelete, Flink, Fsymlink, Freadlink, Frename;

FROM cstr IMPORT
(* PROC *) AssignM2ToC, strlen, strcmp;

FROM pSTRING IMPORT
(* PROC *) SLEN, ASSIGN, APPEND, EQUAL, LOWER;

IMPORT e;

FROM DosSupport IMPORT
(* CONST*) FINDALL, XDECR, DINCR,
(* VAR  *) INODE,
(* TYPE *) DTA, FileAttributes, FileAttribute,
(* PROC *) CompletePath, DosToUnix, UnixToDos, FindFirst, FindNext;

FROM file IMPORT
(* CONST*) fOK,
(* TYPE *) modeT,
(* PROC *) access;

FROM pSTORAGE IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

(*==========================================================================*)

TYPE
  TOSDIRptr = POINTER TO TOSDIRtype;

  TOSDIRstate = (STARTSEARCH, INSEARCH, NMFILE);
  TOSDIRtype = RECORD
    offset  : offT;
    mint    : BOOLEAN;
    status  : TOSDIRstate;
    dta     : DTA;
    dirname : PathName;
    dirent  : DirentRec;
    dname   : ARRAY [0..13] OF CHAR;
  END;

CONST
  (* Absicherung gegen ``unendlich'' grosse Dateinamen *)
  MaxPathAlloc = 2047;

TYPE
  PathBuf = ARRAY [0..MaxPathAlloc] OF CHAR;

  MiNTDIRptr = POINTER TO MiNTDIRtype;

  MiNTDIRtype = RECORD
    offset  : offT;
    mint    : BOOLEAN;
    dsize   : UNSIGNEDLONG; (* (Tatsaechliche) Groesse des RECORDs *)
    bsize   : UNSIGNEDLONG; (* (Tatsaechliche) Groesse von 'dino' + 'dname' *)
    dhandle : UNSIGNEDLONG;
    dirent  : DirentRec;
    dino    : UNSIGNEDLONG;
    dname   : PathBuf;
    (* Fuer 'dname' wird nur soweit noetig Speicher angefordert. *)
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE mkdir ((* EIN/ -- *) REF dir  : ARRAY OF CHAR;
                 (* EIN/ -- *)     mode : modeT         ): int;

VAR res   : INTEGER;
    dot   : BOOLEAN;
    done  : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 IF access(dir, fOK) = 0 THEN
   e.errno := e.EEXIST;
   RETURN(-1);
 ELSIF (e.errno <> e.ENOENT) AND (e.errno <> e.ENOTDIR) THEN
   RETURN(-1);
 END;

 msize := SLEN(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(dir)), msize - DINCR, VAL(StrRange,msize), path0,
           dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF NOT Dcreate(path0, res) THEN
   e.errno := res;
   memdealloc(stack);
   RETURN(-1);
 END;
 done := Fchmod(path0, mode, res);
 memdealloc(stack);
 RETURN(0);
END mkdir;

(*---------------------------------------------------------------------------*)

PROCEDURE rmdir ((* EIN/ -- *) REF dir : ARRAY OF CHAR ): int;

VAR res   : INTEGER;
    dot   : BOOLEAN;
    done  : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 msize := SLEN(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(dir)), msize - DINCR, VAL(StrRange,msize), path0,
           dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Ddelete(path0, res) THEN
   res := 0;
 ELSE
   IF res = e.eACCDN THEN
     e.errno := e.ENOTEMPTY;
   ELSE
     e.errno := res;
   END;
   res := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END rmdir;

(*---------------------------------------------------------------------------*)

PROCEDURE opendir ((* EIN/ -- *) REF dir : ARRAY OF CHAR ): DIR;

VAR tdir   : TOSDIRptr;
    mdir   : MiNTDIRptr;
    err    : INTEGER;
    ret    : DIR;
    lenDir : INTEGER;
    dot    : BOOLEAN;
    done   : BOOLEAN;
    drive  : ARRAY [0..1] OF CHAR;
    stack  : ADDRESS;
    msize  : CARDINAL;
    path0  : StrPtr;
    nlen   : SIGNEDLONG;
    handle : UNSIGNEDLONG;

BEGIN
 msize := SLEN(dir) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(dir)), msize - DINCR, VAL(StrRange,msize), path0,
           dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(NULL);
 END;

 ret := NULL;

 IF Dopendir(path0, 0, handle) THEN
   (* 'Dopendir' und die anderen Funktionen werden unterstuetzt *)
   IF Dpathconf(path0, 3, nlen) THEN
     (* Feststellen, welche Maximalgroesse Dateinamen haben. *)
     IF nlen > VAL(SIGNEDLONG,TSIZE(PathBuf)) THEN
       nlen := VAL(SIGNEDLONG,TSIZE(MiNTDIRtype));
     ELSE
       nlen :=   VAL(SIGNEDLONG,TSIZE(MiNTDIRtype) - TSIZE(PathBuf))
               + nlen
               + LIC(5); (* Fuer abschliessendes Nullbyte & Sicherheit *)
     END;
     ALLOCATE(mdir, nlen);
     IF mdir = NULL THEN
       e.errno := e.ENOMEM; (* vielleicht bessser: EMFILE ? *)
     ELSE
       WITH mdir^ DO
         mint    := TRUE; (* Flag: 'Dreaddir' usw. benutzen *)
         dsize   := VAL(UNSIGNEDLONG,nlen);
         bsize   := dsize - VAL(UNSIGNEDLONG,ABS(DIFADR(ADR(dino),ADR(dsize))));
         dhandle := handle;
         offset  := 0;
         ret     := CAST(DIR,mdir);
       END;
     END;
   ELSE
     e.errno := INT(nlen);
   END;
   IF ret = NULL THEN
     done := Dclosedir(handle, err);
   END;
   memdealloc(stack);
   RETURN(ret);
__RANGECHECK_OFF__
 ELSIF INT(handle) <> e.eINVFN THEN
__RANGECHECK_PREV__
   (* 'Dopendir' wird unterstuetzt, anderer Fehler *)
   e.errno := INT(handle);
   memdealloc(stack);
   RETURN(NULL);
 END;

 (* 'Dopendir' etc. wird nicht unterstuetzt, TOS-Emulation *)
 NEW(tdir);
 IF tdir = NULL THEN
   e.errno := e.ENOMEM; (* vielleicht bessser: EMFILE ? *)
   memdealloc(stack);
   RETURN(NULL);
 END;

 WITH tdir^ DO
   (* vollstaendigen Pfad mit Laufwerksangabe merken, damit bei
    * "rewinddir()" das richtige Verzeichnis benutzt wird, falls
    * sich das aktuelle Verzeichnis inzwischen aendert.
    *)
   IF NOT CompletePath(path0,
                       PATHMAX + 1, CAST(StrPtr,ADR(dirname)),
                       lenDir,
                       err)
   THEN
     DISPOSE(tdir);
     tdir    := NULL;
     e.errno := err;
   ELSE
     (* alle Dateien finden *)
     IF dirname[VAL(UNSIGNEDWORD,lenDir-1)] = DDIRSEP THEN
       APPEND("*.*", dirname);
     ELSE
       APPEND("\*.*", dirname);
     END;

     IF FindFirst(CAST(StrPtr,ADR(dirname)), FINDALL, dta, err) THEN
       status := STARTSEARCH;
     ELSIF err = e.eFILNF THEN
       status := NMFILE;
     ELSE
       DISPOSE(tdir);
       tdir    := NULL;
       e.errno := err;
     END;
     mint   := FALSE; (* Flag: 'Fsnext' benutzen *)
     offset := 0;
   END;
 END; (* WITH tdir^ *)
 memdealloc(stack);
 RETURN(CAST(DIR,tdir));
END opendir;

(*---------------------------------------------------------------------------*)

PROCEDURE readdir ((* EIN/ -- *) dirp : DIR ): DirentPtr;

VAR err  : INTEGER;
    tdir : TOSDIRptr;
    mdir : MiNTDIRptr;

BEGIN
 IF dirp = NULL THEN
   e.errno := e.EBADF;
   RETURN(NULL);
 END;

 mdir := CAST(MiNTDIRptr,dirp);
 WITH mdir^ DO
   IF mint THEN
     IF NOT Dreaddir(VAL(CARDINAL,bsize), dhandle, ADR(dino), err) THEN
       IF err <> e.eNMFIL THEN
         e.errno := err;
       END;
       RETURN(NULL);
     END;
     INC(offset);
     dirent.dName   := CAST(StrPtr,ADR(dname));
     dirent.dNamlen := strlen(dirent.dName);
     dirent.dIno    := dino;
     RETURN(CAST(DirentPtr,ADR(dirent)));
   END;
 END;

 tdir := CAST(TOSDIRptr,dirp);
 WITH tdir^ DO
   IF status = NMFILE THEN
     RETURN(NULL);
   ELSIF status = STARTSEARCH THEN
     status := INSEARCH;
   ELSE
     IF NOT FindNext(dta, err) THEN
       IF err = e.eNMFIL THEN
         status := NMFILE;
       ELSE
         e.errno := err;
       END;
       RETURN(NULL);
     END;
   END;
   ASSIGN(dta.name, dname);
   LOWER(dname);
   INC(offset);
   dirent.dName   := CAST(StrPtr,ADR(dname));
   dirent.dNamlen := VAL(sizeT,SLEN(dname));
   dirent.dIno    := VAL(inoT,INODE); INC(INODE);
   RETURN(CAST(DirentPtr,ADR(dirent)));
 END; (* WITH tdir^ *)
END readdir;

(*---------------------------------------------------------------------------*)

PROCEDURE rewinddir ((* EIN/ -- *) dirp : DIR );

VAR err  : INTEGER;
    tdir : TOSDIRptr;
    mdir : MiNTDIRptr;

BEGIN
 IF dirp = NULL THEN
   RETURN;
 END;

 mdir := CAST(MiNTDIRptr,dirp);
 WITH mdir^ DO
   IF mint THEN
     IF Drewinddir(dhandle, err) THEN
       offset := 0;
     END;
     RETURN;
   END;
 END;

 tdir := CAST(TOSDIRptr,dirp);
 WITH tdir^ DO
   IF FindFirst(CAST(StrPtr,ADR(dirname)), FINDALL, dta, err) THEN
     status := STARTSEARCH;
   ELSE
     status := NMFILE;
   END;
   offset := 0;
 END;
END rewinddir;

(*---------------------------------------------------------------------------*)

PROCEDURE closedir ((* EIN/AUS *) VAR dirp : DIR ): int;

VAR tdir : TOSDIRptr;
    res  : INTEGER;
    mdir : MiNTDIRptr;

BEGIN
 IF dirp = NULL THEN
   e.errno := e.EBADF;
   RETURN(-1);
 END;

 mdir := CAST(MiNTDIRptr,dirp);
 WITH mdir^ DO
   IF mint THEN
     IF NOT Dclosedir(dhandle, res) THEN
       e.errno := res;
       res     := -1;
     ELSE
       res     := 0;
     END;
     DEALLOCATE(mdir, dsize);
     dirp := NULL;
     RETURN(res);
   END;
 END;

 tdir := CAST(TOSDIRptr,dirp);
 dirp := NULL;
 DISPOSE(tdir);
 RETURN(0);
END closedir;

(*--------------------------------------------------------------------------*)

PROCEDURE telldir ((* EIN/ -- *) dirp : DIR ): offT;

VAR mdir : MiNTDIRptr;

BEGIN
 IF dirp = NULL THEN
   e.errno := e.EBADF;
   RETURN(-1);
 END;
 mdir := CAST(MiNTDIRptr,dirp);
 (* Geht nur, weil 'offset' bei 'TOSDIR' an derselben Stelle sitzt *)
 RETURN(mdir^.offset);
END telldir;

(*--------------------------------------------------------------------------*)

PROCEDURE seekdir ((* EIN/ -- *) dirp : DIR;
                   (* EIN/ -- *) loc  : offT );

VAR mdir : MiNTDIRptr;

BEGIN
 IF dirp <> NULL THEN
   rewinddir(dirp);
   mdir := CAST(MiNTDIRptr,dirp);
   (* Geht nur, weil 'offset' bei 'TOSDIR' an derselben Stelle sitzt *)
   LOOP
     IF (mdir^.offset = loc) OR (readdir(dirp) = NULL) THEN
       RETURN;
     END;
   END;
 END;
END seekdir;

(*--------------------------------------------------------------------------*)

PROCEDURE unlink ((* EIN/ -- *) REF file : ARRAY OF CHAR ): int;

VAR res   : INTEGER;
    done  : BOOLEAN;
    dot   : BOOLEAN;
    stack : ADDRESS;
    msize : CARDINAL;
    path0 : StrPtr;

BEGIN
 msize := SLEN(file) + DINCR;
 memalloc(VAL(sizeT,msize), stack, path0);
 UnixToDos(CAST(StrPtr,REFADR(file)), msize - DINCR, VAL(StrRange,msize),
           path0, dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Fdelete(path0, res) THEN
   res := 0;
 ELSE
   e.errno := res;
   res     := -1;
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
    path01 : StrPtr;
    path02 : StrPtr;
    stack  : ADDRESS;
    void   : ADDRESS;
    msize1 : CARDINAL;
    msize2 : CARDINAL;

BEGIN
 msize1 := SLEN(old) + DINCR;
 msize2 := SLEN(new) + DINCR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(CAST(StrPtr,REFADR(old)), msize1 - DINCR, VAL(StrRange,msize1),
           path01, dot, done1);
 UnixToDos(CAST(StrPtr,REFADR(new)), msize2 - DINCR, VAL(StrRange,msize2),
           path02, dot, done2);
 IF NOT (done1 AND done2) THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Flink(path01, path02, res) THEN
   res := 0;
 ELSE
   e.errno := res;
   res     := -1;
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

BEGIN
 msize1 := SLEN(old) + DINCR;
 msize2 := SLEN(new) + DINCR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(CAST(StrPtr,REFADR(old)), msize1 - DINCR, VAL(StrRange,msize1),
           path01, dot, done1);
 UnixToDos(CAST(StrPtr,REFADR(new)), msize2 - DINCR, VAL(StrRange,msize2),
           path02, dot, done2);
 IF NOT (done1 AND done2) THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF Fsymlink(path01, path02, res) THEN
   res := 0;
 ELSE
   e.errno := res;
   res     := -1;
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

BEGIN
 IF VAL(sizeT,MAXSTR) < bufsiz THEN
   bufsiz := VAL(sizeT,MAXSTR);
 END;
 msize1 := SLEN(lname) + DINCR;
 msize2 := VAL(CARDINAL,bufsiz) + XDECR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(CAST(StrPtr,REFADR(lname)), msize1 - DINCR, VAL(StrRange,msize1),
           path01, dot, done);
 IF NOT done THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF NOT Freadlink(msize2, path02, path01, res) AND (res <> e.eRANGE) THEN
   e.errno := res;
   res     := -1;
 ELSE
   DosToUnix(path02, VAL(StrRange,bufsiz), buf, res, xlen);
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
    done1  : BOOLEAN;
    done2  : BOOLEAN;
    dot    : BOOLEAN;
    path01 : StrPtr;
    path02 : StrPtr;
    stack  : ADDRESS;
    void   : ADDRESS;
    msize1 : CARDINAL;
    msize2 : CARDINAL;

BEGIN
 msize1 := SLEN(old) + DINCR;
 msize2 := SLEN(new) + DINCR;
 memalloc(VAL(sizeT,msize1), stack, path01);
 memalloc(VAL(sizeT,msize2), void, path02);
 UnixToDos(CAST(StrPtr,REFADR(old)), msize1 - DINCR, VAL(StrRange,msize1),
           path01, dot, done1);
 UnixToDos(CAST(StrPtr,REFADR(new)), msize2 - DINCR, VAL(StrRange,msize2),
           path02, dot, done2);
 IF NOT (done1 AND done2) THEN
   memdealloc(stack);
   RETURN(-1);
 END;

 IF strcmp(path01, path02) = 0 THEN
   (* sonst wird die Datei nachher geloescht... *)
   (* Vergleich erst NACH "UnixToDos()", da unterschiedliche *IX-Namen
    * evtl. auf denselben DOS-Namen abgebildet werden!
    *)
   memdealloc(stack);
   RETURN(0);
 END;

 IF access(new, fOK) = 0 THEN
   (* vorhandene Zieldatei zuvor loeschen, falls nicht schreibgeschuetzt,
    * da "GEMDOS" evtl. einen doppelten Name nicht erkennt. Wenn dabei
    * allerdings ein Fehler auftritt, ist die Zieldatei verloren!
    *)

   IF NOT Fdelete(path02, res) THEN
     e.errno := res;
     memdealloc(stack);
     RETURN(-1);
   END;
 END;

 IF Frename(path01, path02, res) THEN
   res := 0;
 ELSE
   e.errno := res;
   res     := -1;
 END;
 memdealloc(stack);
 RETURN(res);
END rename;

END dir.
