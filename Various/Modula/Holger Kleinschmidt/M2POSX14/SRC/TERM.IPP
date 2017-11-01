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
(* 18-Apr-93, Holger Kleinschmidt                                            *)
(*****************************************************************************)

VAL_INTRINSIC
CAST_IMPORT

FROM SYSTEM IMPORT
(* PROC *) ADR;

FROM PORTAB IMPORT
(* CONST*) NULL,
(* TYPE *) UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG, SIGNEDWORD, WORDSET;

FROM types IMPORT
(* TYPE *) int, sizeT, pidT, StrPtr, StrRange;

IMPORT e;

FROM OSCALLS IMPORT
(* PROC *) Fcntl, Fxattr, Dopendir, Dreaddir, Dclosedir;

FROM cstr IMPORT
(* PROC *) strcpy, AssignM2ToC;

FROM DosSystem IMPORT
(* PROC *) FcntlAvail;

FROM DosSupport IMPORT
(* CONST*) MinHandle, MaxHandle,
(* TYPE *) HandleRange, FileType,
(* VAR  *) FD,
(* PROC *) IsTerm, DosToUnix;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  ISPEED = tccflagT{tccflag8..tccflag11};
  OSPEED = tccflagT{tccflag12..tccflag15};

#if no_MIN_MAX
  MAXSPEED = B38400;
#else
  MAXSPEED = MAX(speedT);
#endif

TYPE
  Ctermid = ARRAY [0..LCtermid - 1] OF CHAR;

TYPE
  XATTR = RECORD
    mode    : WORDSET;
    index   : UNSIGNEDLONG;
    dev     : UNSIGNEDWORD;
    rdev    : UNSIGNEDWORD; (* ab MiNT 1.10 mit sinnvollem Wert *)
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

VAR
  hasFcntl : BOOLEAN; (* Wird Fcntl unterstuetzt ? *)
  xattr    : XATTR;
  TTYNAME  : Ctermid;
  (* Diese Variable wird von "ctermid()" und "ttyname()" benutzt, da diese
   * beiden Funktionen nicht reentrant sein muessen, also nicht innerhalb
   * eines Signalhandlers o.ae. benutzt werden duerfen.
   *)
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE isatty ((* EIN/ -- *) fd : int ): int;
BEGIN
 IF (fd<MinHandle) OR (fd>MaxHandle) THEN
   e.errno := e.EBADF;
   RETURN(-1);
 END;
 WITH FD[VAL(HandleRange,fd)] DO
   IF ftype = unknown THEN
     IF IsTerm(fd) THEN
       ftype := istty;
     ELSE
       ftype := notty;
     END;
   END;
   IF ftype = istty THEN
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
   IF NOT Dopendir(ADR(tname), 0, dhandle) THEN
     RETURN(FALSE);
   END;
   WHILE Dreaddir(LCtermid + 4, dhandle, ADR(dino), err) DO
     strcpy(CAST(StrPtr,ADR(tname[tlen])), CAST(StrPtr,ADR(dname)));
     IF Fxattr(0, ADR(tname), ADR(xattr), err) THEN
       IF (xattr.dev = d) AND (xattr.index = idx) THEN
         void := Dclosedir(dhandle, err);
         DosToUnix(CAST(StrPtr,ADR(tname)),
                   LCtermid, CAST(StrPtr,ADR(TTYNAME)),
                   err,
                   xlen);
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

CONST FSTAT = 00004600H;

VAR lres  : SIGNEDLONG;
    tname : Ctermid;
    index : UNSIGNEDLONG;
    dev   : UNSIGNEDWORD;

BEGIN
 IF NOT IsTerm(fd) THEN
   RETURN(NULL);
 END;
 IF hasFcntl THEN
   IF NOT Fcntl(fd, ADR(xattr), FSTAT, lres) THEN
     e.errno := INT(lres);
     RETURN(NULL);
   END;
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
 IF buf <> NULL THEN
   ts := buf;
   AssignM2ToC(TTYNAME, LCtermid, buf);
 ELSE
   ts := CAST(StrPtr,ADR(TTYNAME));
 END;
 RETURN(ts);
END ctermid;

(*--------------------------------------------------------------------------*)

PROCEDURE cfgetispeed ((* EIN/ -- *) term : TermiosRec ): speedT;
BEGIN
 RETURN(VAL(speedT,CAST(UNSIGNEDWORD,term.cCflag * ISPEED) DIV 256));
END cfgetispeed;

(*---------------------------------------------------------------------------*)

PROCEDURE cfsetispeed ((* EIN/ -- *) term  : TermiosRec;
                       (* EIN/ -- *) speed : speedT     ): int;
BEGIN
 IF ORD(speed) > ORD(MAXSPEED) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 ELSE
   term.cCflag :=  term.cCflag - ISPEED
                 + (ISPEED * CAST(tccflagT,VAL(UNSIGNEDWORD,ORD(speed)*256)));
   RETURN(0);
 END;
END cfsetispeed;

(*---------------------------------------------------------------------------*)

PROCEDURE cfgetospeed ((* EIN/ -- *) term : TermiosRec ): speedT;
BEGIN
 RETURN(VAL(speedT,CAST(UNSIGNEDWORD,term.cCflag * OSPEED) DIV 4096));
END cfgetospeed;

(*---------------------------------------------------------------------------*)

PROCEDURE cfsetospeed ((* EIN/ -- *) term  : TermiosRec;
                       (* EIN/ -- *) speed : speedT     ): int;
BEGIN
 IF ORD(speed) > ORD(MAXSPEED) THEN
   e.errno := e.EINVAL;
   RETURN(-1);
 ELSE
   term.cCflag :=  term.cCflag - OSPEED
                 + (OSPEED * CAST(tccflagT,VAL(UNSIGNEDWORD,ORD(speed)*4096)));
   RETURN(0);
 END;
END cfsetospeed;

(*---------------------------------------------------------------------------*)

PROCEDURE tcgetattr ((* EIN/ -- *)     fd   : int;
                     (* -- /AUS *) VAR term : TermiosRec ): int;
BEGIN
 e.errno := e.ENOSYS;
 RETURN(-1);
END tcgetattr;

(*---------------------------------------------------------------------------*)

PROCEDURE tcsetattr ((* EIN/ -- *) fd   : int;
                     (* EIN/  - *) act  : AttrActions;
                     (* EIN/AUS *) term : TermiosRec  ): int;
BEGIN
 e.errno := e.ENOSYS;
 RETURN(-1);
END tcsetattr;

(*---------------------------------------------------------------------------*)

PROCEDURE tcsendbreak ((* EIN/ -- *) fd       : int;
                       (* EIN/ -- *) duration : int ): int;
BEGIN
 e.errno := e.ENOSYS;
 RETURN(-1);
END tcsendbreak;

(*---------------------------------------------------------------------------*)

PROCEDURE tcdrain ((* EIN/ -- *) fd : int ): int;
BEGIN
 e.errno := e.ENOSYS;
 RETURN(-1);
END tcdrain;

(*---------------------------------------------------------------------------*)

PROCEDURE tcflow ((* EIN/ -- *) fd     : int;
                  (* EIN/ -- *) action : FlowActions ): int;
BEGIN
 e.errno := e.ENOSYS;
 RETURN(-1);
END tcflow;

(*---------------------------------------------------------------------------*)

PROCEDURE tcflush ((* EIN/ -- *) fd   : int;
                   (* EIN/ -- *) qsel : QueueTypes ): int;
BEGIN
 e.errno := e.ENOSYS;
 RETURN(-1);
END tcflush;

(*---------------------------------------------------------------------------*)

PROCEDURE tcgetpgrp ((* EIN/ -- *) fd : int ): pidT;

CONST TIOCGPGRP = 5406H; (* ('T'<<8)|6 *)

VAR         lres : SIGNEDLONG;
            arg  : SIGNEDLONG;
    __REG__ res  : INTEGER;

BEGIN
 IF hasFcntl THEN
   IF Fcntl(fd, ADR(arg), TIOCGPGRP, lres) THEN
     IF arg = VAL(SIGNEDLONG,0) THEN
       (* Gehoert keiner Prozessgruppe *)
       e.errno := e.ENOENT;
       RETURN(-1);
     ELSE
       RETURN(VAL(pidT,arg));
     END;
   ELSE
     res := INT(lres);
     IF res = e.eINVFN THEN
       e.errno := e.ENOTTY;
     ELSE
       e.errno := res;
     END;
     RETURN(-1);
   END;
 ELSE
   e.errno := e.ENOSYS; (* Kein ``Job-Control'' *)
   RETURN(-1);
 END;
END tcgetpgrp;

(*---------------------------------------------------------------------------*)

PROCEDURE tcsetpgrp ((* EIN/ -- *) fd   : int;
                     (* EIN/ -- *) pgrp : pidT ): int;

CONST TIOCSPGRP = 5407H; (* ('T'<<8)|7 *)

VAR         lres : SIGNEDLONG;
            arg  : SIGNEDLONG;
    __REG__ res  : INTEGER;

BEGIN
 IF hasFcntl THEN
   arg := VAL(SIGNEDLONG,pgrp);
   IF Fcntl(fd, ADR(arg), TIOCSPGRP, lres) THEN
     RETURN(0);
   ELSE
     res := INT(lres);
     IF res = e.eINVFN THEN
       e.errno := e.ENOTTY;
     ELSE
       e.errno := res;
     END;
     RETURN(-1);
   END;
 ELSE
   e.errno := e.ENOSYS; (* Kein ``Job-Control'' *)
   RETURN(-1);
 END;
END tcsetpgrp;

(*===========================================================================*)

BEGIN (* term *)
 hasFcntl := FcntlAvail();
END term.
