IMPLEMENTATION MODULE DosDir;
__IMP_SWITCHES__
__DRIVER__ /* StdErr auf -1 umlenken */
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
(* "UnixToDos()" basiert auf der MiNTLIB von Eric R. Smith und anderen       *)
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
(* TYPE *) SIGNEDWORD, UNSIGNEDWORD, SIGNEDLONG, UNSIGNEDLONG;

FROM OSCALLS IMPORT
(* PROC *) Dgetdrv, Dsetdrv, Dgetcwd, Dgetpath, Fgetdta, Fsetdta, Fsfirst,
           Fxattr, Fsnext, Fforce, Fcntl, Psigblock, Psigsetmask, Pumask,
           Dpathconf;

FROM blk IMPORT
(* PROC *) memalloc, memdealloc, memmove;

FROM ctype IMPORT
(* PROC *) tolower, Cisalpha, todigit, tocard;

FROM str IMPORT
(* PROC *) AssignM2ToC, strlen, strcmp, strncmp, strncpy, strncasecmp, Token;

FROM ISOStrings IMPORT
(* PROC *) Delete, Equal;

FROM StringsX IMPORT
(* PROC *) EqualPrefix;

FROM pLONGSET IMPORT
(* PROC *) LONGELEM;

FROM types IMPORT
(* CONST*) EOS, PATHMAX, DDIRSEP, XDIRSEP, SUFFIXSEP, CR, LF, sIFMT, sIFREG,
           sIFDIR,
(* TYPE *) modeT, sizeT, StrPtr, StrRange;

FROM er IMPORT
(* CONST*) eIHNDL, eRANGE, eINVFN, ePTHNF, eFILNF, ENOENT, ENOTDIR,
           ENAMETOOLONG,
(* VAR  *) errno;

FROM DosFile IMPORT
(* PROC *) IsTerm;

FROM args IMPORT
(* PROC *) getenv;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  DELIMITER = ",;";
  DELIMLEN  = 2;

VAR
  Delim : ARRAY [0..DELIMLEN] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE SplitPath ((* EIN/ -- *)     full  : StrPtr;
                     (* -- /AUS *) VAR drive : SIGNEDWORD;
                     (* -- /AUS *) VAR path  : SIGNEDWORD;
                     (* -- /AUS *) VAR file  : SIGNEDWORD;
                     (* -- /AUS *) VAR ext   : SIGNEDWORD;
                     (* -- /AUS *) VAR flen  : SIGNEDWORD );

VAR __REG__ i    : SIGNEDWORD;
    __REG__ c    : CHAR;
    __REG__ didx : SIGNEDWORD;
    __REG__ eidx : SIGNEDWORD;

BEGIN
 flen := 0; drive := -1; path := -1; file := -1; ext := -1;
 didx := -1; eidx := -1;
 IF full = NULL THEN
   RETURN;
 END;
 IF Cisalpha(full^[0]) & (full^[1] = DDRVPOSTFIX) THEN
   drive := 0;
   i     := 2;
 ELSE
   i     := 0;
 END;
 path := i;
 LOOP
   c := full^[i];
   IF c = 0C THEN
     EXIT;
   END;
   IF c = DDIRSEP THEN
     didx := i;
   ELSIF c = SUFFIXSEP THEN
     eidx := i;
   END;
   INC(i);
 END;
 IF didx >= 0 THEN
   file := didx + 1;
 ELSE
   file := path;
   path := -1;
 END;
 IF file = i THEN
   file := -1;
 END;
 IF (file >= 0) & (eidx > file) & (eidx + 1 < i) THEN
   ext := eidx;
 END;
 flen := i;
END SplitPath;

(*---------------------------------------------------------------------------*)

PROCEDURE isexec ((* EIN/ -- *)     path    : StrPtr;
                  (* EIN/ -- *) REF default : ARRAY OF CHAR;
                  (* EIN/ -- *) REF var     : ARRAY OF CHAR ): BOOLEAN;

VAR  sAdr      : StrPtr;
     slen      : StrRange;
     sidx      : StrRange;
     tlen      : StrRange;
     token     : StrPtr;
     suffices  : StrPtr;
     d,p,f,e,l : SIGNEDWORD;

BEGIN
 SplitPath(path, d, p, f, e, l);
 IF e < 0 THEN
   (* Keine Extension -> nicht ausfuehrbar *)
   RETURN(FALSE);
 END;
 sAdr := ADR(path^[e+1]);

 suffices := getenv(var);
 IF suffices = NULL THEN
   suffices := REFADR(default);
 END;

 sidx := 0;
 slen := VAL(StrRange,strlen(suffices));
 WHILE Token(suffices, ADR(Delim), slen, sidx, tlen, token) DO
   IF (tlen > 0) & (strncasecmp(sAdr, token, VAL(sizeT,tlen)) = 0) THEN
     RETURN(TRUE);
   END;
 END;
 RETURN(FALSE);
END isexec;

(*---------------------------------------------------------------------------*)

PROCEDURE IsExec ((* EIN/ -- *) path : StrPtr ): BOOLEAN;
BEGIN
 RETURN(isexec(path, EXECSUFFIX, "SUFFIX"));
END IsExec;

(*---------------------------------------------------------------------------*)

PROCEDURE IsGEMExec ((* EIN/ -- *) path : StrPtr ): BOOLEAN;
BEGIN
 RETURN(isexec(path, GEMEXT, "GEMEXT"));
END IsGEMExec;

(*---------------------------------------------------------------------------*)

PROCEDURE IsDosExec ((* EIN/ -- *) path : StrPtr ): BOOLEAN;
BEGIN
#ifdef __GEMDOS__
 RETURN(isexec(path, TOSEXT, "TOSEXT"));
#else
 RETURN(isexec(path, DOSEXT, "DOSEXT"));
#endif
END IsDosExec;

(*---------------------------------------------------------------------------*)

PROCEDURE prefixLen ((* EIN/ -- *) path : StrPtr ): UNSIGNEDWORD;

VAR __REG__ i : UNSIGNEDWORD;
    __REG__ c : CHAR;
    __REG__ p : StrPtr;

BEGIN
 i := 0;
 p := path;
 REPEAT
   c := p^[i];
   INC(i);
 UNTIL (c = 0C) OR (c = DDIRSEP) OR (c = DDRVPOSTFIX);
 IF c = DDRVPOSTFIX THEN
   RETURN(i);
 ELSE
   RETURN(0);
 END;
END prefixLen;

(*---------------------------------------------------------------------------*)

PROCEDURE IsDosDevice ((* EIN/ -- *) path : StrPtr ): BOOLEAN;

VAR __REG__ i : UNSIGNEDWORD;

BEGIN
 i := prefixLen(path);
 RETURN((i > 2) & (path^[i] = 0C));
END IsDosDevice;

(*---------------------------------------------------------------------------*)

PROCEDURE CompletePath ((* EIN/ -- *)     path  : StrPtr;
                        (* EIN/ -- *)     fSize : StrRange;
                        (* EIN/ -- *)     full  : StrPtr;
                        (* -- /AUS *) VAR fLen  : INTEGER;
                        (* -- /AUS *) VAR err   : INTEGER   ): BOOLEAN;

VAR __REG__ drv  : CARDINAL;
    __REG__ pIdx : UNSIGNEDWORD;
    __REG__ fIdx : UNSIGNEDWORD;
    __REG__ f    : StrPtr;
    __REG__ p    : StrPtr;

BEGIN
 f := full;
 p := path;
 IF fSize < 4 THEN
   (* weniger als drei Zeichen + Nullbyte Platz *)
   err := eRANGE;
   RETURN(FALSE);
 END;
 IF (p^[0] = 0C) OR (p^[1] # DDRVPOSTFIX) THEN
   (* Wenn kein Laufwerk angegeben ist, aktuelles Laufwerk ermitteln *)
   drv   := Dgetdrv();
   f^[0] := todigit(drv + 10);
   pIdx  := 0;
   INC(drv); (* fuer "Dgetpath" *)
 ELSE
   (* sonst angegebenes Laufwerk uebernehmen *)
   f^[0] := p^[0];
   pIdx  := 2;
   drv   := tocard(p^[0]) - 9; (* - 10 + 1 *)
 END;
 f^[1] := DDRVPOSTFIX;

 fIdx := 2;
 err  := 0;
 IF p^[pIdx] # DDIRSEP THEN
   (* relativer Pfad angegeben -> aktuellen Pfad ermitteln *)
   IF ~Dgetcwd(ADDADR(f, 2), drv, fSize - 2, err)
      & ((err # eINVFN) OR ~Dgetpath(ADDADR(f, 2), drv, err))
   THEN
     RETURN(FALSE);
   END;

   WHILE f^[fIdx] # 0C DO
     INC(fIdx);
   END;
   IF fIdx >= fSize THEN
     (* Ist wahrscheinlich schon zu spaet, da ueber <full> hinaus
      * geschrieben wurde, aber schaden kanns auch nicht.
      * (Kann nur auftreten, wenn 'Dgetpath' benutzt wurde)
      *)
     err := eRANGE;
     RETURN(FALSE);
   ELSE
     IF (fIdx = 2) OR (p^[pIdx] # 0C) THEN
       (* Ein Wurzelverzeichnis muss mit einem Backslash gekennzeichnet
        * werden. Wenn ein (relativer) Pfad angegeben war, muss ebenfalls
        * ein Backslash zur Trennung eingefuegt werden.
        *)
       f^[fIdx] := DDIRSEP;
       INC(fIdx);
     END;
   END;
 END;

 WHILE (p^[pIdx] # 0C) & (fIdx < fSize) DO
   f^[fIdx] := p^[pIdx];
   INC(fIdx);
   INC(pIdx);
 END;

 IF fIdx >= fSize THEN
   err := eRANGE;
   RETURN(FALSE);
 ELSE
   f^[fIdx] := 0C;
   fLen     := INT(fIdx);
   RETURN(TRUE);
 END;
END CompletePath;

(*---------------------------------------------------------------------------*)

PROCEDURE DosToUnix ((* EIN/ -- *)     dpath : StrPtr;
                     (* EIN/ -- *)     conv  : BOOLEAN;
                     (* EIN/ -- *)     xSize : StrRange;
                     (* EIN/ -- *)     xpath : StrPtr;
                     (* -- /AUS *) VAR dlen  : INTEGER;
                     (* -- /AUS *) VAR xlen  : INTEGER  );

VAR __REG__ dIdx   : UNSIGNEDWORD;
    __REG__ dLen   : UNSIGNEDWORD;
    __REG__ c      : CHAR;
    __REG__ drv    : CHAR;
    __REG__ d      : StrPtr;
            pre    : UNSIGNEDWORD;
            pipe   : BOOLEAN;
            device : BOOLEAN;
            tmp    : ARRAY [0..14] OF CHAR;
            tmpLen : UNSIGNEDWORD;

BEGIN
 d    := dpath;
 dIdx := 0;
 WHILE d^[dIdx] # 0C DO
   (*  \ --> /  und gegebenenfalls in Kleinbuchstaben wandeln *)
   c := d^[dIdx];
   IF c = DDIRSEP THEN
     c := XDIRSEP;
   ELSIF conv THEN
     c := tolower(c);
   END;
   d^[dIdx] := c;
   INC(dIdx);
 END;

 dLen := dIdx;
 dlen := VAL(INTEGER,dIdx);
 pre  := prefixLen(d);
 drv  := tolower(d^[0]);

 IF pre = 2 THEN
   (* Laufwerk, "x:" *)
   pipe   := FALSE;
   device := FALSE;
   dIdx   := 2;

   IF drv = 'u' THEN
     c     := d^[0];
     d^[0] := drv;
     tmp   := "u:/pipeu:/dev";
     IF strncmp(ADR(tmp), d, 7) = 0 THEN
       pipe := (dLen = 7) OR (d^[7] = XDIRSEP);
       IF pipe THEN
         (* <xpath>^ wird 2 Zeichen kuerzer als <dpath>^, wenn ein absoluter
          * Pfad angegeben ist, sonst 1 Zeichen.
          *)
         dIdx := 7;
       END;
     ELSIF strncmp(ADR(tmp[7]), d, 6) = 0 THEN
       device := (dLen = 6) OR (d^[6] = XDIRSEP);
       IF device THEN
         (* <xpath>^ wird 2 Zeichen kuerzer als <dpath>^, wenn ein absoluter
          * Pfad angegeben ist, sonst 1 Zeichen.
          *)
         dIdx := 6;
       END;
     ELSIF (dLen >= 4) & (d^[2] = XDIRSEP)
         & ((dLen = 4) OR (d^[4] = XDIRSEP))
     THEN
       (* "u:/x" oder "u:/x/..." *)
       drv  := tolower(d^[3]);
       dIdx := 4;
     END;
     d^[0] := c;
   END;

   IF pipe THEN
     tmp    := "/pipe";
     tmpLen := 5;
   ELSIF device THEN
     tmp    := "/dev";
     tmpLen := 4;
   ELSE
     IF ROOTDIR = drv THEN
       IF dLen = dIdx THEN
         tmp    := "/";
         tmpLen := 1;
       ELSE
         tmp    := "";
         tmpLen := 0;
       END;
     ELSIF ROOTDIR = 'u' THEN
       tmp    := "/@";
       tmp[1] := drv;
       tmpLen := 2;
     ELSE
       tmp    := "/dev/@";
       tmp[5] := drv;
       tmpLen := 6;
     END;
   END; (* IF pipe *)
   IF (dIdx < dLen) & (d^[dIdx] # XDIRSEP) THEN
     tmp[tmpLen] := XDIRSEP;
     INC(tmpLen);
   END;
 ELSIF pre = 1 THEN
   (* duerfte nicht auftreten, ":..." *)
   tmp[0] := XDIRSEP;
   tmp[1] := EOS;
   tmpLen := 1;
   dIdx   := 1;
 ELSE
   dIdx := 0; (* nichts vom "DOS"-Pfad loeschen *)
   IF pre > 2 THEN
     tmp := "con:";
     IF strcmp(ADR(tmp), d) = 0 THEN
       AssignM2ToC("/dev/tty", xSize, xpath);
       xlen := 8;
       RETURN;
     ELSE
       tmp       := "/dev/";
       tmpLen    := 5;
       d^[pre-1] := EOS; (* den Doppelpunkt loeschen *)
       dLen      := pre - 1; (* fuer die Berechnung von 'xlen' korr. *)
     END;
   ELSE (* pre = 0 *)
     tmp    := "";
     tmpLen := 0;
   END;
 END; (* IF pre *)

 xlen := VAL(INTEGER,dLen - dIdx + tmpLen);
 AssignM2ToC(tmp, xSize, xpath);
 IF xSize > tmpLen THEN
   (* Den restlichen (umgewandelten) Dospfad anhaengen *)
   strncpy(ADDADR(xpath, tmpLen), ADDADR(d, dIdx), VAL(sizeT,xSize - tmpLen));
 END;
END DosToUnix;

(*---------------------------------------------------------------------------*)

PROCEDURE UnixToDos ((* EIN/ -- *)     xpath : StrPtr;
                     (* EIN/ -- *)     xlen  : CARDINAL;
                     (* EIN/ -- *)     dSize : StrRange;
                     (* EIN/ -- *)     dpath : StrPtr;
                     (* -- /AUS *) VAR dot   : BOOLEAN;
                     (* -- /AUS *) VAR done  : BOOLEAN       );

CONST TMPMAX = 13;

VAR __REG__ xIdx    : UNSIGNEDWORD;
    __REG__ xLen    : UNSIGNEDWORD;
    __REG__ dIdx    : UNSIGNEDWORD;
    __REG__ c       : CHAR;
    __REG__ d       : StrPtr;
            xOffs   : UNSIGNEDWORD;
            tmp     : ARRAY [0..TMPMAX] OF CHAR;
            actRoot : BOOLEAN;
            replace : BOOLEAN;
            shift   : BOOLEAN;
            stack   : ADDRESS;
            bufP    : StrPtr;
            res     : INTEGER;
            buf     : ARRAY [0..1] OF CHAR;

BEGIN (* UnixToDos *)
 d       := dpath;
 xOffs   := 0;
 done    := FALSE;
 actRoot := FALSE;
 replace := FALSE;
 shift   := FALSE;
 IF dSize = 0 THEN
   errno := ENAMETOOLONG;
   RETURN;
 END;
 xLen := VAL(UNSIGNEDWORD,xlen);
 IF xLen = 0 THEN
   errno := ENOENT;
   RETURN;
 END;

 IF xLen <= TMPMAX THEN
   strncpy(ADR(tmp), xpath, VAL(sizeT,xLen));
   tmp[xLen] := EOS;
 ELSE
   strncpy(ADR(tmp), xpath, VAL(sizeT,TMPMAX+1));
 END;
 FOR dIdx := 0 TO TMPMAX DO
   IF tmp[dIdx] = DDIRSEP THEN
     tmp[dIdx] := XDIRSEP;
   END;
 END;

 (* Da bei "GEMDOS" die Eintraege "." und ".." im Hauptverzeichnis nicht
  * existieren, werden sie durch das Hauptverzeichnis ersetzt, falls mit
  * Sicherheit festgestellt werden kann, dass das Hauptverzeichnis gemeint ist.
  * Dies ist auch korrekt, wenn ein Dateisystem benutzt wird, dass diese
  * Eintraege hat, da sie dann auch aufs Hauptverzeichnis verweisen.
  *
  * Es gibt folgende Faelle:
  * - "/.", "/..", "/./xxx", "/../xxx" absoluter Pfad
  *   hier kann sofort korrigiert werden.
  *
  * - ".", "..", "./xxx", "../xxx" relativer Pfad
  *   hier muss zuerst festgestellt werden, ob das aktuelle Verzeichnis
  *   das Hauptverzeichnis ist.
  *
  * - alle anderen Faelle (wenn "." oder ".." als Teil einer Pfadangabe
  *   auftreten, auch wenn nur ein Laufwerk angegeben ist) werden hier
  *   nicht korrigiert, da dies einen grossen Aufwand bedeutet, aber
  *   seltener auftritt.
  *)

 c := tmp[0];
 IF c = '.' THEN
   IF xLen > 1 THEN
     c := tmp[1];
   END;
   IF (xLen = 1) OR (xLen = 2) & (c = '.') THEN
     replace := TRUE;
   ELSIF (xLen > 1) & (   (c = XDIRSEP)
                       OR (xLen > 2) & (c = '.') & (tmp[2] = XDIRSEP))
   THEN
     shift := TRUE;
   END;
   IF replace OR shift THEN
     (* Testen, ob das aktuelle Verzeichnis das Wurzelverzeichnis ist *)
     actRoot := Dgetcwd(ADR(buf), 0, 2, res) & (buf[0] = 0C);
     (* Wenn 'Dgetcwd' unterstuetzt wird aber nicht geklappt hat, war der
      * Platz zu klein, d.h. das aktuelle Verzeichnis kann nicht das
      * Wurzelverzeichnis sein.
      *)
     IF ~actRoot & (res = eINVFN) THEN
       (* Der 'Dgetcwd'-Aufruf wird nicht unterstuetzt, also 'Dgetpath'
        * benutzen und hoffen, dass PATHMAX ausreicht...
        *)
       memalloc(PATHMAX, stack, bufP);
       actRoot := Dgetpath(bufP, 0, res) & (bufP^[0] = 0C);
       memdealloc(stack);
     END;
     IF actRoot & shift THEN
       IF c = XDIRSEP THEN
         (* "./xxx" --> "/xxx" *)
         xOffs := 1;
       ELSE (* tmp[2] = XDIRSEP *)
         (* "../xxx" --> "/xxx" *)
         xOffs := 2;
       END;
     ELSE
       replace := FALSE;
     END;
   END;
 ELSIF (xLen > 1) & (c = XDIRSEP) & (tmp[1] = '.') THEN
   IF xLen > 2 THEN
     c := tmp[2];
   END;
   IF (xLen = 2) OR (xLen = 3) & (c = '.') THEN
     replace := TRUE;
   ELSIF (xLen > 2) & (   (c = XDIRSEP)
                       OR (xLen > 3) & (c = '.') & (tmp[3] = XDIRSEP))
   THEN
     IF c = XDIRSEP THEN
       (* "/./xxx" --> "/xxx" *)
       xOffs := 2;
     ELSE (* tmp[3] = XDIRSEP *)
       (* "/../xxx" --> "/xxx" *)
       xOffs := 3;
     END;
   END;
 END;
 IF replace THEN
   (* ".", "..", "/.", "/.." --> "/" *)
   xLen   := 1;
   tmp[0] := XDIRSEP;
   tmp[1] := EOS;
 ELSIF xOffs > 0 THEN
   Delete(tmp, 0, xOffs);
   DEC(xLen, xOffs);
 END;

 dot  := FALSE;
 dIdx := 0;
 xIdx := xOffs;

 IF EqualPrefix(5, XDEVPREFIX, tmp) THEN
   (* xpath^ = /dev/... *)
   IF (xLen > 5) & Cisalpha(tmp[5]) & ((xLen = 6) OR (tmp[6] = XDIRSEP)) THEN
     (* "GEMDOS"-Laufwerksbezeichner: /dev/A, /dev/A/..., /dev/A\... --> A:
      * <dpath>^ wird 4 Zeichen kuerzer als <xpath>^.
      *)
     tmp[0] := tmp[5];
     tmp[1] := DDRVPOSTFIX;
     tmp[2] := EOS;
     dIdx   := 2;
     INC(xIdx, 6);
   ELSIF DRVU THEN
     (* ANNAHME: Wenn Laufwerk U: existiert, existiert auch das spezielle
      *          Verzeichnis U:\dev.
      *)
     INC(xIdx, 5);
     (* Geraete sind bei MiNT ueber Laufwerk 'U' ansprechbar:
      * /dev/... --> u:\dev\...
      * <dpath>^ wird 2 Zeichen laenger als <xpath>^.
      *)
     tmp  := "u:\dev\\"; (* \\ wegen Praeprozessor... *)
     dIdx := 7;
   ELSE
     IF Equal("/dev/tty", tmp) THEN
       (* <dpath>^ wird 4 Zeichen kuerzer als <xpath>^ *)
       AssignM2ToC("con:", dSize, d);
       done := dSize > 4; (* incl. Nullbyte *)
     ELSE
       (* <dpath>^ wird 4 Zeichen kuerzer als <xpath>^, falls <xpath>^
        * nicht mit einem ':' abgechlossen ist, sonst 5 Zeichen.
        *)
       IF xpath^[xOffs+xLen-1] # DDRVPOSTFIX THEN
         dIdx := 1; (* Flag: ":" anfuegen *)
       END;
       DEC(xLen, 5);
       (* /dev/ ueberspringen: *)
       strncpy(d, ADDADR(xpath, xOffs+5), VAL(sizeT,dSize));
       done := xLen + dIdx < dSize;
       IF done & (dIdx = 1) THEN
         d^[xLen]   := DDRVPOSTFIX;
         d^[xLen+1] := 0C;
       END;
     END;
     RETURN;
   END;
 ELSIF DRVU & EqualPrefix(6, "/pipe/", tmp) THEN
   (* ANNAHME: Wenn Laufwerk U: existiert, existiert auch das spezielle
    *          Verzeichnis U:\pipe.
    *)
   INC(xIdx, 6);
   (* Pipes koennen ueber Laufwerk U: angesprochen werden:
    * /pipe/... --> u:\pipe\...
    * <dpath>^ wird 2 Zeichen laenger als <xpath>^.
    *)
   tmp  := "u:\pipe\\";
   dIdx := 8;
 ELSIF (tmp[0] = XDIRSEP) & ~actRoot & (ROOTDIR # 0C) THEN
   (* <dpath>^ wird 2 Zeichen laenger als <xpath>^. *)
   tmp[0] := ROOTDIR;
   tmp[1] := DDRVPOSTFIX;
   tmp[2] := EOS;
   dIdx   := 2;
 END;

 INC(xLen, xOffs);
 IF (xLen - xIdx) + dIdx >= dSize THEN
   errno := ENAMETOOLONG;
   RETURN;
 END;

 AssignM2ToC(tmp, dIdx, d);
 WHILE xIdx < xLen DO
   c := xpath^[xIdx];
   IF c = XDIRSEP THEN (* / --> \ *)
     c := DDIRSEP;
   END;
   d^[dIdx] := c;
   INC(xIdx);
   INC(dIdx);
 END;
 d^[dIdx] := 0C;
 done     := TRUE;

 (* Die Zuweisung an CHAR-Variable steht hier nur, weil der nachfolgende
  * Ausdruck moeglicherweise zu komplex fuer den einen oder anderen
  * Compiler ist (-> TDI).
  *)
 IF dIdx > 1 THEN
   c := d^[dIdx-2];
 ELSE
   c := 0C;
 END;
#ifdef TDIM2
__RANGECHECK_OFF__ (* Ausdruck sonst zu kompliziert ... *)
#endif
 dot :=   (dIdx > 0)
        & (d^[dIdx-1] = '.')
        & (   (dIdx = 1)
           OR (c = DDIRSEP)
           OR (c = DDRVPOSTFIX)
           OR (c = '.') & (   (dIdx = 2)
                           OR (d^[dIdx-3] = DDIRSEP)
                           OR (d^[dIdx-3] = DDRVPOSTFIX)));
END UnixToDos;
#ifdef TDIM2
__RANGECHECK_PREV__
#endif

(*---------------------------------------------------------------------------*)

PROCEDURE PathToken ((* EIN/ -- *)     str  : StrPtr;
                     (* EIN/ -- *)     slen : StrRange;
                     (* EIN/AUS *) VAR idx  : StrRange;
                     (* -- /AUS *) VAR plen : StrRange;
                     (* -- /AUS *) VAR path : StrPtr   ): BOOLEAN;

VAR __REG__ min    : StrRange;
    __REG__ max    : StrRange;
    __REG__ strLen : StrRange;
    __REG__ c2     : CHAR;
    __REG__ c      : CHAR;
            pidx   : StrRange;
            drive  : BOOLEAN;

BEGIN
 strLen := slen;
 min    := idx;
 IF min > strLen THEN
   (* <str> vollstaendig durchsucht *)
   plen := 0;
   path := NULL;
   RETURN(FALSE);
 END;

 (* Anfang des naechsten Pfades suchen, dabei fuehrende Leerzeichen
  * ueberlesen.
  *)
 WHILE (min < strLen) & (str^[min] = ' ') DO
   INC(min);
 END;

 (* Abschliessendes Trennzeichen suchen, das fuehrende wurde schon
  * beim letzten Mal ueberlesen, oder es ist der erste Pfad im String.
  *)
 max   := min;
 drive := FALSE;
 pidx  := 0;
 LOOP
   c := str^[max];
   IF (c = 0C) OR (c = ',') OR (c = ';') THEN
     (* Pfad ist auf jeden Fall beendet *)
     EXIT;
   END;
   IF c = DDRVPOSTFIX THEN
     (* Moeglicherweise Laufwerkskennung *)
     c2 := str^[max+1];
     IF   drive
       OR (pidx # 1) OR ~Cisalpha(str^[max-1])
       OR (c2 # 0C) & (c2 # DDIRSEP) & (c2 # XDIRSEP) & (c2 # ',') & (c2 # ';')
     THEN
       (* Ist doch Trennzeichen *)
       EXIT;
     END;
     drive := TRUE;  (* Zweites ':' auf jeden Fall Trennzeichen *)
   END;
   INC(max);
   INC(pidx);
 END;

 IF max = strLen THEN
   (* Kein Trennzeichen mehr -> jetzt kommt letztes Token, oder der
    * String ist zuende.
    *)
   idx := strLen + 1; (* beim naechsten Mal abbrechen *)
 ELSE
   idx := max + 1; (* beim naechsten Mal hinter dem Trenner starten *)
 END;

 WHILE (max > min) & (str^[max-1] = ' ') DO
   (* abschliessende Leerzeichen ueberlesen *)
   DEC(max);
 END;

 plen := max - min;
 path := ADR(str^[min]);
 RETURN(TRUE);
END PathToken;

(*---------------------------------------------------------------------------*)

PROCEDURE FindFirst ((* EIN/ -- *)     path : StrPtr;
                     (* EIN/ -- *)     attr : FileAttributes;
                     (* EIN/AUS *) VAR dta  : DTA;
                     (* -- /AUS *) VAR res  : INTEGER ): BOOLEAN;

VAR olddta : ADDRESS;
    done   : BOOLEAN;

BEGIN
 olddta := Fgetdta();
 Fsetdta(ADR(dta));
 done := Fsfirst(path, attr, res);
 Fsetdta(olddta);
 RETURN(done);
END FindFirst;

(*---------------------------------------------------------------------------*)

PROCEDURE FindNext ((* EIN/AUS *) VAR dta : DTA;
                    (* -- /AUS *) VAR res : INTEGER ): BOOLEAN;

VAR olddta : ADDRESS;
    done   : BOOLEAN;

BEGIN
 olddta := Fgetdta();
 Fsetdta(ADR(dta));
 done := Fsnext(res);
 Fsetdta(olddta);
 RETURN(done);
END FindNext;

(*---------------------------------------------------------------------------*)

PROCEDURE FileExists ((* EIN/ -- *)     path : StrPtr;
                      (* EIN/ -- *)     sym  : BOOLEAN;
                      (* -- /AUS *) VAR res  : INTEGER ): BOOLEAN;

VAR xattr : XATTR;
    dta   : DTA;

BEGIN
 IF Fxattr(ORD(sym), path, ADR(xattr), res) THEN
   IF xattr.mode * sIFMT = sIFDIR THEN
     res := 0;
   ELSIF xattr.mode * sIFMT = sIFREG THEN
     res := 1;
   ELSE
     res := 2;
   END;
   RETURN(TRUE);
 ELSIF (res = eINVFN) & FindFirst(path, AllEntries, dta, res) THEN
   IF faSUBDIR IN dta.attr THEN
     res := 0;
   ELSE
     res := 1;
   END;
   RETURN(TRUE);
 END;
 RETURN(FALSE);
END FileExists;

(*---------------------------------------------------------------------------*)

PROCEDURE TstENOTDIR ((* EIN/ -- *)     path : StrPtr;
                      (* EIN/ -- *)     last : BOOLEAN;
                      (* EIN/AUS *) VAR err  : INTEGER );

VAR __REG__ i     : SIGNEDWORD;
    __REG__ p     : StrPtr;
            oldm  : UNSIGNEDLONG;
            c     : CHAR;
            res   : INTEGER;
            done  : BOOLEAN;

BEGIN
 IF (err # eFILNF) & (err # ePTHNF) THEN
   RETURN;
 END;
 err := ENOENT;

 p := path;
 IF (p^[0] # 0C) & (p^[1] = DDRVPOSTFIX) THEN
   (* Laufwerk alleine laesst sich (unter TOS) nicht testen, es muss
    * mindestens ein Verzeichnis dabei sein. Wenn nur ein Laufwerk
    * angegeben ist: ENOENT.
    *)
   IF p^[2] = DDIRSEP THEN
     i := 3;
   ELSE
     i := 2;
   END;
 ELSE
   i := 0;
 END;
 oldm := Psigblock(0FFFFFFFFH);

 WHILE p^[i] # 0C DO
   IF p^[i] = DDIRSEP THEN
     p^[i] := 0C;
     done  := FileExists(p, FALSE, res);
     p^[i] := DDIRSEP;
     IF res # 0 THEN
       oldm := Psigsetmask(oldm);
       IF res > 0 THEN
         err := ENOTDIR;
       END;
       RETURN;
     END;
   END;
   INC(i);
 END;
 IF last & (i > 0) & (p^[i-1] # DDIRSEP) THEN
   done := FileExists(p, FALSE, res);
   IF res > 0 THEN
     err := ENOTDIR;
   END;
 END;
 oldm := Psigsetmask(oldm);
END TstENOTDIR;

(*---------------------------------------------------------------------------*)

PROCEDURE IsDosDir ((* EIN/ -- *) path : StrPtr ): BOOLEAN;

CONST DPTRUNC = 5;
        DPDOSTRUNC = 2;

VAR lres  : SIGNEDLONG;
    res   : INTEGER;
    stack : ADDRESS;
    plen  : StrRange;
    tlen  : StrRange;
    path0 : StrPtr;
    dos   : BOOLEAN;

BEGIN
 IF FileExists(path, FALSE, res) & (res = 0) THEN
   plen := VAL(StrRange,strlen(path));
   tlen := plen;
   memalloc(VAL(sizeT,tlen + 2 + 1), stack, path0); (* + \. + 0C *)
   memmove(path0, path, VAL(sizeT,tlen));
   IF (tlen # 0) & (path0^[tlen-1] # DDIRSEP) THEN
     path0^[tlen] := DDIRSEP; INC(tlen);
   END;
   path0^[tlen]   := '.';
   path0^[tlen+1] := 0C;
   IF Dpathconf(path0, DPTRUNC, lres) THEN
     dos := INT(lres) = DPDOSTRUNC;
   ELSIF lres # VAL(SIGNEDLONG,eINVFN) THEN
     (* Noch mal Originalpfad probieren *)
     path0^[plen] := 0C;
     dos := ~Dpathconf(path0, DPTRUNC, lres) OR (INT(lres) = DPDOSTRUNC);
   ELSE
     dos := TRUE;
   END;
   memdealloc(stack);
 ELSE
   dos := FALSE;
 END;
 RETURN(dos);
END IsDosDir;

(*===========================================================================*)

VAR xmode  : StrPtr;
    i      : StrRange;
    h      : SIGNEDWORD;
    res    : INTEGER;
    lres   : SIGNEDLONG;
    done   : BOOLEAN;
    c      : CHAR;
    c1     : CHAR;
    drv    : CARDINAL;
    drives : UNSIGNEDLONG;

BEGIN (* DosDir *)
 Delim   := DELIMITER;
 INODE   := 32 (* ?? *);
 ROOTDIR := 0C;
 BINIO   := FALSE;
 drv     := Dgetdrv();
 drives  := Dsetdrv(drv);
 DRVU    := LONGELEM(20, drives);

 xmode   := getenv("UNIXMODE");
 IF xmode # NULL THEN
   i := 0;
   c := xmode^[0];
   WHILE c # 0C DO
     c1 := xmode^[i+1];
     IF (c = 'r') & (c1 # 0C) & LONGELEM(tocard(c1) - 10, drives) THEN
       ROOTDIR := tolower(c1);
       INC(i);
     ELSIF (c = '.') & (c1 # 0C) THEN
       INC(i);
     ELSIF c = 'b' THEN
       BINIO := TRUE;
     END;
     INC(i);
     c := xmode^[i];
   END;
 END;
 IF (ROOTDIR = 0C) & (drv = 20(*U:*)) THEN
   ROOTDIR := 'u';
 END;

 IF (getenv("STDERR") = NULL) & IsTerm(2) THEN
   (* siehe Profibuch von 1992 *)
   done := Fforce(2, -1, res);
 END;

 lres := Pumask(0);
 IF lres < VAL(SIGNEDLONG,0) THEN
   (* Aufruf wird nicht unterstuetzt *)
   UMASK := modeT{};
 ELSE
   UMASK := CAST(modeT,VAL(UNSIGNEDWORD,lres));
   lres  := Pumask(UMASK);
 END;
END DosDir.
