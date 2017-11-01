IMPLEMENTATION MODULE DosSupport;
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
(* "UnixToDos()" basiert auf der MiNTLIB von Eric R. Smith und anderen       *)
(* --------------------------------------------------------------------------*)
(* 18-Mai-94, Holger Kleinschmidt                                            *)
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

FROM OSCALLS IMPORT
(* PROC *) Dgetdrv, Dsetdrv, Dgetcwd, Dgetpath, Fgetdta, Fsetdta, Fsfirst,
           Fsnext, Fseek, Fforce, Dpathconf, Fcntl, Fopen, Fclose;

FROM MEMBLK IMPORT
(* PROC *) memalloc, memdealloc, memset;

FROM ctype IMPORT
(* PROC *) tolower, isalpha, todigit, tocard;

FROM cstr IMPORT
(* PROC *) AssignM2ToC, strrchr, strcmp, strncmp, strncpy, strnicmp, Token;

FROM pSTRING IMPORT
(* PROC *) DELETE, EQUAL, EQUALN;

FROM pLONGSET IMPORT
(* PROC *) INlong;

FROM types IMPORT
(* CONST*) EOS, PATHMAX, DDIRSEP, XDIRSEP, DDRVPOSTFIX, XDEVPREFIX, SUFFIXSEP,
           EXTMAX, SecMask, MinMask, HourMask, DayMask, MonMask, YearMask,
(* TYPE *) sizeT, ExtName, StrPtr, StrRange;

IMPORT e;

FROM cmdline IMPORT
(* PROC *) getenv;

FROM DosSystem IMPORT
(* PROC *) DpathconfAvail;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  pconf : BOOLEAN;  (* Wird der 'Dpathconf'-Aufruf unterstuetzt ? *)
  Delim : ARRAY [0..2] OF CHAR;
  drvU  : BOOLEAN;  (* Existiert Laufwerk U: ? *)
  nulp  : ARRAY [0..15] OF CHAR;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE isexec ((* EIN/ -- *)     path    : StrPtr;
                  (* EIN/ -- *) REF default : ARRAY OF CHAR;
                  (* EIN/ -- *) REF var     : ARRAY OF CHAR ): BOOLEAN;
(*T*)
VAR  sAdr,dAdr : StrPtr;
     l1, l2    : StrRange;
     tIdx      : StrRange;
     tlen      : StrRange;
     token     : StrPtr;
     suffices  : StrPtr;

BEGIN
 sAdr := strrchr(path, SUFFIXSEP);
 dAdr := strrchr(path, DDIRSEP);

 IF (DIFADR(sAdr, dAdr) <= VAL(SIGNEDLONG,0)) OR (sAdr^[1] = 0C) THEN
   (* Keine Extension -> nicht ausfuehrbar *)
   RETURN(FALSE);
 END;
 sAdr := CAST(StrPtr,ADDADR(sAdr, 1));

 suffices := getenv(var);
 IF suffices = NULL THEN
   suffices := CAST(StrPtr,REFADR(default));
 END;

 tIdx  := 0;
 l1    := 0;
 WHILE Token(suffices, CAST(StrPtr,ADR(Delim)), tIdx, l1, l2, tlen, token) DO
   IF (tlen > 0) AND (strnicmp(sAdr, token, VAL(sizeT,tlen)) = 0) THEN
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
 UNTIL (c = 0C) OR (c = DDIRSEP) OR (c = XDIRSEP) OR (c = DDRVPOSTFIX);
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
 RETURN((i > 2) AND (path^[i] = 0C));
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
   err := e.eRANGE;
   RETURN(FALSE);
 END;
 IF (p^[0] = 0C) OR (p^[1] <> DDRVPOSTFIX) THEN
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
 IF p^[pIdx] <> DDIRSEP THEN
   (* relativer Pfad angegeben -> aktuellen Pfad ermitteln *)
   IF NOT Dgetcwd(ADDADR(f, 2), drv, fSize - 2, err)
      AND (   (err <> e.eINVFN)
           OR NOT Dgetpath(ADDADR(f, 2), drv, err))
   THEN
     RETURN(FALSE);
   END;

   WHILE f^[fIdx] <> 0C DO
     INC(fIdx);
   END;
   IF fIdx >= fSize THEN
     (* Ist wahrscheinlich schon zu spaet, da ueber <full> hinaus
      * geschrieben wurde, aber schaden kanns auch nicht.
      * (Kann nur auftreten, wenn 'Dgetpath' benutzt wurde)
      *)
     err := e.eRANGE;
     RETURN(FALSE);
   ELSE
     IF (fIdx = 2) OR (p^[pIdx] <> 0C) THEN
       (* Ein Wurzelverzeichnis muss mit einem Backslash gekennzeichnet
        * werden. Wenn ein (relativer) Pfad angegeben war, muss ebenfalls
        * ein Backslash zur Trennung eingefuegt werden.
        *)
       f^[fIdx] := DDIRSEP;
       INC(fIdx);
     END;
   END;
 END;

 WHILE (p^[pIdx] <> 0C) AND (fIdx < fSize) DO
   f^[fIdx] := p^[pIdx];
   INC(fIdx);
   INC(pIdx);
 END;

 IF fIdx >= fSize THEN
   err := e.eRANGE;
   RETURN(FALSE);
 ELSE
   f^[fIdx] := 0C;
   fLen     := INT(fIdx);
   RETURN(TRUE);
 END;
END CompletePath;

(*---------------------------------------------------------------------------*)

PROCEDURE DosToUnix ((* EIN/ -- *)     dpath : StrPtr;
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
 WHILE d^[dIdx] <> 0C DO
   (*  \ --> /  und gegebenenfalls in Kleinbuchstaben wandeln *)
   c := d^[dIdx];
   IF c = DDIRSEP THEN
     c := XDIRSEP;
   ELSIF NOT pconf THEN
     (* ANNAHME: Wenn 'Dpathconf' existiert, sorgt das Betriebssystem
      * selber fuer die richtige Gross/Kleinschreibung von Dateinamen.
      *)
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

   IF drv = 'q' THEN
     (* <xpath>^ wird 3 Zeichen laenger als <dpath>^, wenn ein absoluter
      * Pfad angegeben ist, sonst 4 Zeichen.
      *)
     pipe := TRUE;
   ELSIF drv = 'v' THEN
     (* <xpath>^ wird 2 Zeichen laenger als <dpath>^, wenn ein absoluter
      * Pfad angegeben ist, sonst 3 Zeichen.
      *)
     device := TRUE;
   ELSIF drv = 'u' THEN
     c     := d^[0];
     d^[0] := drv;
     tmp   := "u:/pipeu:/dev";
     IF strncmp(CAST(StrPtr,ADR(tmp)), d, 7) = 0 THEN
       pipe := (dLen = 7) OR (d^[7] = XDIRSEP);
       IF pipe THEN
         (* <xpath>^ wird 2 Zeichen kuerzer als <dpath>^, wenn ein absoluter
          * Pfad angegeben ist, sonst 1 Zeichen.
          *)
         dIdx := 7;
       END;
     ELSIF strncmp(CAST(StrPtr,ADR(tmp[7])), d, 6) = 0 THEN
       device := (dLen = 6) OR (d^[6] = XDIRSEP);
       IF device THEN
         (* <xpath>^ wird 2 Zeichen kuerzer als <dpath>^, wenn ein absoluter
          * Pfad angegeben ist, sonst 1 Zeichen.
          *)
         dIdx := 6;
       END;
     ELSIF (dLen >= 4) AND (d^[2] = XDIRSEP)
       AND ((dLen = 4) OR (d^[4] = XDIRSEP))
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
   IF (dIdx < dLen) AND (d^[dIdx] <> XDIRSEP) THEN
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
     IF strcmp(CAST(StrPtr,ADR(tmp)), d) = 0 THEN
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
   strncpy(CAST(StrPtr,ADDADR(xpath, tmpLen)),
           CAST(StrPtr,ADDADR(d, dIdx)),
           VAL(sizeT,xSize - tmpLen));
 END;
END DosToUnix;

(*---------------------------------------------------------------------------*)

PROCEDURE UnixToDos ((* EIN/ -- *)     xpath : StrPtr;
                     (* EIN/ -- *)     xlen  : CARDINAL;
                     (* EIN/ -- *)     dSize : StrRange;
                     (* EIN/ -- *)     dpath : StrPtr;
                     (* -- /AUS *) VAR dot   : BOOLEAN;
                     (* -- /AUS *) VAR done  : BOOLEAN       );
(**)
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
   e.errno := e.ENAMETOOLONG;
   RETURN;
 END;
 xLen := VAL(UNSIGNEDWORD,xlen);
 IF xLen = 0 THEN
   e.errno := e.ENOENT;
   RETURN;
 END;

 IF xLen <= TMPMAX THEN
   strncpy(CAST(StrPtr,ADR(tmp)), xpath, VAL(sizeT,xLen));
   tmp[xLen] := EOS;
 ELSE
   strncpy(CAST(StrPtr,ADR(tmp)), xpath, VAL(sizeT,TMPMAX+1));
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
   IF (xLen = 1) OR (xLen = 2) AND (c = '.') THEN
     replace := TRUE;
   ELSIF (xLen > 1) AND ((c = XDIRSEP)
                     OR (xLen > 2) AND (c = '.') AND (tmp[2] = XDIRSEP))
   THEN
     shift := TRUE;
   END;
   IF replace OR shift THEN
     (* Testen, ob das aktuelle Verzeichnis das Wurzelverzeichnis ist *)
     actRoot := Dgetcwd(ADR(buf), 0, 2, res) AND (buf[0] = 0C);
     (* Wenn 'Dgetcwd' unterstuetzt wird aber nicht geklappt hat, war der
      * Platz zu klein, d.h. das aktuelle Verzeichnis kann nicht das
      * Wurzelverzeichnis sein.
      *)
     IF NOT actRoot AND (res = e.eINVFN) THEN
       (* Der 'Dgetcwd'-Aufruf wird nicht unterstuetzt, also 'Dgetpath'
        * benutzen und hoffen, dass PATHMAX ausreicht...
        *)
       memalloc(PATHMAX, stack, bufP);
       actRoot := Dgetpath(bufP, 0, res) AND (bufP^[0] = 0C);
       memdealloc(stack);
     END;
     IF actRoot AND shift THEN
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
 ELSIF (xLen > 1) AND (c = XDIRSEP) AND (tmp[1] = '.') THEN
   IF xLen > 2 THEN
     c := tmp[2];
   END;
   IF (xLen = 2) OR (xLen = 3) AND (c = '.') THEN
     replace := TRUE;
   ELSIF (xLen > 2) AND ((c = XDIRSEP)
                     OR (xLen > 3) AND (c = '.') AND (tmp[3] = XDIRSEP))
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
   DELETE(0, xOffs, tmp);
   DEC(xLen, xOffs);
 END;

 dot  := FALSE;
 dIdx := 0;
 xIdx := xOffs;

 IF EQUALN(5, XDEVPREFIX, tmp) THEN
   (* xpath^ = /dev/... *)
   IF (xLen > 5) AND isalpha(tmp[5]) AND ((xLen = 6) OR (tmp[6] = XDIRSEP)) THEN
     (* "GEMDOS"-Laufwerksbezeichner: /dev/A, /dev/A/..., /dev/A\... --> A:
      * <dpath>^ wird 4 Zeichen kuerzer als <xpath>^.
      *)
     tmp[0] := tmp[5];
     tmp[1] := DDRVPOSTFIX;
     tmp[2] := EOS;
     dIdx   := 2;
     INC(xIdx, 6);
   ELSIF drvU THEN
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
     IF EQUAL("/dev/tty", tmp) THEN
       (* <dpath>^ wird 4 Zeichen kuerzer als <xpath>^ *)
       AssignM2ToC("con:", dSize, d);
       done := dSize > 4; (* incl. Nullbyte *)
     ELSE
       (* <dpath>^ wird 4 Zeichen kuerzer als <xpath>^, falls <xpath>^
        * nicht mit einem ':' abgechlossen ist, sonst 5 Zeichen.
        *)
       IF xpath^[xOffs+xLen-1] <> DDRVPOSTFIX THEN
         dIdx := 1; (* Flag: ":" anfuegen *)
       END;
       DEC(xLen, 5);
       (* /dev/ ueberspringen: *)
       strncpy(d, CAST(StrPtr,ADDADR(xpath, xOffs+5)), VAL(sizeT,dSize));
       done := xLen + dIdx < dSize;
       IF done AND (dIdx = 1) THEN
         d^[xLen]   := DDRVPOSTFIX;
         d^[xLen+1] := 0C;
       END;
     END;
     RETURN;
   END;
 ELSIF drvU AND EQUALN(6, "/pipe/", tmp) THEN
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
 ELSIF (tmp[0] = XDIRSEP) AND NOT actRoot AND (ROOTDIR <> 0C) THEN
   (* <dpath>^ wird 2 Zeichen laenger als <xpath>^. *)
   tmp[0] := ROOTDIR;
   tmp[1] := DDRVPOSTFIX;
   tmp[2] := EOS;
   dIdx   := 2;
 END;

 INC(xLen, xOffs);
 IF (xLen - xIdx) + dIdx >= dSize THEN
   e.errno := e.ENAMETOOLONG;
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
 dot :=     (dIdx > 0)
        AND (d^[dIdx-1] = '.')
             AND ((dIdx = 1)
              OR  (c = DDIRSEP)
              OR  (c = DDRVPOSTFIX)
              OR  (c = '.')
                   AND ((dIdx = 2)
                    OR  (d^[dIdx-3] = DDIRSEP)
                    OR  (d^[dIdx-3] = DDRVPOSTFIX)));
END UnixToDos;
#ifdef TDIM2
__RANGECHECK_PREV__
#endif

(*---------------------------------------------------------------------------*)

PROCEDURE FindFirst ((* EIN/ -- *)     path : StrPtr;
                     (* EIN/ -- *)     attr : FileAttribute;
                     (* EIN/AUS *) VAR dta  : DTA;
                     (* -- /AUS *) VAR res  : INTEGER       ): BOOLEAN;
(*T*)
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
(*T*)
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

PROCEDURE IsTerm ((* EIN/ -- *) h : INTEGER ): BOOLEAN;
(*T*)
VAR old  : SIGNEDLONG;
    lres : SIGNEDLONG;
    done : BOOLEAN;

BEGIN
 done := Fseek(0, h, 1, old);
 done := Fseek(1, h, 0, lres);
 done := Fseek(old, h, 0, old);

 RETURN(lres = VAL(SIGNEDLONG,0));
END IsTerm;

(*---------------------------------------------------------------------------*)

PROCEDURE IsCTerm ((* EIN/ -- *) h : INTEGER ): BOOLEAN;

CONST
 FSTAT = 00004600H;

TYPE
  XATTR = RECORD
    mode    : WORDSET;
    index   : UNSIGNEDLONG;
    dev     : UNSIGNEDWORD;
    rdev    : UNSIGNEDWORD;
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
  st1, st2 : XATTR;
  lres     : SIGNEDLONG;

BEGIN
 IF NOT (IsTerm(h) OR IsTerm(-1)) THEN
   RETURN(FALSE);
 ELSIF h = -1 THEN
   RETURN(TRUE);
 END;
 IF Fcntl(h, ADR(st1), FSTAT, lres) AND Fcntl(-1, ADR(st2), FSTAT, lres) THEN
   (* Wenn <h> dieselbe Datei wie die Kennung -1 kennzeichnet, ist <h>
    * das Kontrollterminal.
    *)
   RETURN((st1.dev = st2.dev) AND (st1.index = st2.index));
 END;
 (* Sonst annehmen, dass das CON:-Device gemeint ist, wenn nicht das
  * AUX:-Device gemeint ist.
  *)
 RETURN(h <> -2)
END IsCTerm;

(*---------------------------------------------------------------------------*)

PROCEDURE Disconnect ((* EIN/ -- *)     h   : INTEGER;
                      (* -- /AUS *) VAR res : INTEGER ): BOOLEAN;

CONST RDWR = 2;

VAR nulh : INTEGER;
    void : BOOLEAN;

BEGIN
 IF (h < 0) OR NOT IsCTerm(h) THEN
   res := e.eIHNDL;
   RETURN(FALSE);
 END;
 IF Fopen(ADR(nulp), RDWR, nulh) THEN
   void := Fclose(h, res);
   void := Fforce(-1, nulh, res);
   FD[VAL(HandleRange, h)].ftype := unknown;
   FD[VAL(HandleRange,-1)].ftype := unknown;
   IF nulh <> h THEN
     (* Sollte eigentlich immer der Fall sein *)
     void := Fforce(h, nulh, res);
     void := Fclose(nulh, res);
   END;
   RETURN(TRUE);
 ELSE
   res := nulh;
   RETURN(FALSE);
 END;
END Disconnect;

(*---------------------------------------------------------------------------*)

PROCEDURE DecodeDate ((* EIN/ -- *)     date    : WORDSET;
                      (* EIN/ -- *)     time    : WORDSET;
                      (* -- /AUS *) VAR decoded : DosDate );
(*T*)
BEGIN
 WITH decoded DO
   year := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,date * YearMask) DIV 512 + 1980);
   mon  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,date * MonMask) DIV 32);
   day  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,date * DayMask));
   IF mon > 0 THEN
     DEC(mon);
   END;

   hour := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,time * HourMask) DIV 2048);
   min  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,time * MinMask) DIV 32);
   sec  := VAL(UNSIGNEDWORD,CAST(UNSIGNEDWORD,time * SecMask) * 2);
 END;
END DecodeDate;

(*---------------------------------------------------------------------------*)

PROCEDURE EncodeDate ((* EIN/ -- *) VAR encoded : DosDate;
                      (* -- /AUS *) VAR date    : WORDSET;
                      (* -- /AUS *) VAR time    : WORDSET );
(*T*)
BEGIN
 WITH encoded DO
   date :=
       CAST(WORDSET,VAL(UNSIGNEDWORD,(year - 1980) * 512)) * YearMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,(mon + 1) * 32)) * MonMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,day)) * DayMask;

   time :=
       CAST(WORDSET,VAL(UNSIGNEDWORD,hour * 2048)) * HourMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,min * 32)) * MinMask
     + CAST(WORDSET,VAL(UNSIGNEDWORD,sec DIV 2)) * SecMask;
 END;
END EncodeDate;

(*---------------------------------------------------------------------------*)

PROCEDURE DateToSeconds ((* EIN/ -- *) VAR date : DosDate ): UNSIGNEDLONG;
(*T*)
BEGIN
 WITH date DO
   RETURN(VAL(UNSIGNEDLONG,  (year - 1970) * 365
                           + (year - 1969) DIV 4
                           + MonthDays[year MOD 4 = 0][mon]
                           + day - 1
          ) * SECSPERDAY
          + VAL(UNSIGNEDLONG,hour) * SECSPERHOUR
          + VAL(UNSIGNEDLONG,min)  * SECSPERMIN
          + VAL(UNSIGNEDLONG,sec)
         );
 END;
END DateToSeconds;

(*---------------------------------------------------------------------------*)

PROCEDURE SecondsToDate ((* EIN/ -- *)     time : UNSIGNEDLONG;
                         (* -- /AUS *) VAR date : DosDate      );
(*T*)
VAR __REG__ days  : UNSIGNEDLONG;
    __REG__ tmp1  : UNSIGNEDLONG;
    __REG__ tmp2  : UNSIGNEDWORD;
    __REG__ years : INTEGER;
            leap  : BOOLEAN;

BEGIN
 WITH date DO
   tmp1 := time;
   days := tmp1 DIV SECSPERDAY;
   tmp1 := tmp1 MOD SECSPERDAY;
   wday := INT((days + VAL(UNSIGNEDLONG,4)) MOD VAL(UNSIGNEDLONG,7));
   hour := INT(tmp1 DIV SECSPERHOUR);
   tmp1 := tmp1 MOD SECSPERHOUR;
   min  := INT(tmp1 DIV SECSPERMIN);
   sec  := INT(tmp1 MOD SECSPERMIN);

   years := 1970;
   tmp1  := 365;
   tmp2  := 2;
   WHILE days >= tmp1 DO
     INC(years);
     DEC(days, tmp1);
     DEC(tmp2);
     IF tmp2 = 0 THEN
       tmp1 := 366;
       tmp2 := 4;
     ELSE
       tmp1 := 365;
     END;
   END;

   year := years;
   yday := INT(days);

   leap := tmp2 = 4;
   tmp2 := 0;
   WHILE days >= VAL(UNSIGNEDLONG,DaysPerMonth[leap][tmp2]) DO
     DEC(days, VAL(UNSIGNEDLONG,DaysPerMonth[leap][tmp2]));
     INC(tmp2);
   END;

   mon := INT(tmp2);
   day := INT(days) + 1;
 END;
END SecondsToDate;

(*===========================================================================*)

VAR xmode : StrPtr;
    i     : StrRange;
    h     : SIGNEDWORD;
    res   : INTEGER;
    lres  : SIGNEDLONG;
    done  : BOOLEAN;
    c     : CHAR;
    drv   : CARDINAL;

BEGIN (* DosSupport *)
 nulp    := "u:\dev\null";
 pconf   := DpathconfAvail();
 Delim   := ";,";
 INODE   := 32 (* ?? *);
 ROOTDIR := 0C;
 BINIO   := FALSE;
 xmode   := getenv("UNIXMODE");
 IF xmode <> NULL THEN
   i := 0;
   c := xmode^[0];
   WHILE c <> 0C DO
     IF (c = 'r') AND (xmode^[i+1] <> 0C) THEN
       ROOTDIR := tolower(xmode^[i+1]);
       INC(i);
     ELSIF (c = '.') AND (xmode^[i+1] <> 0C) THEN
       INC(i);
     ELSIF c = 'b' THEN
       BINIO := TRUE;
     END;
     INC(i);
     c := xmode^[i];
   END;
 END;

 IF (getenv("STDERR") = NULL) AND IsTerm(2) THEN
   (* siehe Profibuch von 1992 *)
   done := Fforce(2, -1, res);
 END;

 drv  := Dgetdrv();
 drvU := INlong(20, Dsetdrv(drv));
 IF (ROOTDIR = 0C) AND (drv = 20(*U:*)) THEN
   ROOTDIR := 'u';
 END;

 FOR h := MinHandle TO MaxHandle DO
   FD[h].ftype := unknown;
 END;

 SIGMASK    := 0H;
 SIGPENDING := 0H;
 memset(ADR(SIGHANDLER), 0, VAL(sizeT,SIZE(SIGHANDLER)));

#if ISO_value_constructor
 DaysPerMonth := DayMonth{{31,28,31,30,31,30,31,31,30,31,30,31},
                          {31,29,31,30,31,30,31,31,30,31,30,31}};

 MonthDays    := DayMonth{{0,31,59,90,120,151,181,212,243,273,304,334},
                          {0,31,60,91,121,152,182,213,244,274,305,335}};
#else
 DaysPerMonth[FALSE][0]  := 31;
 DaysPerMonth[FALSE][1]  := 28;
 DaysPerMonth[FALSE][2]  := 31;
 DaysPerMonth[FALSE][3]  := 30;
 DaysPerMonth[FALSE][4]  := 31;
 DaysPerMonth[FALSE][5]  := 30;
 DaysPerMonth[FALSE][6]  := 31;
 DaysPerMonth[FALSE][7]  := 31;
 DaysPerMonth[FALSE][8]  := 30;
 DaysPerMonth[FALSE][9]  := 31;
 DaysPerMonth[FALSE][10] := 30;
 DaysPerMonth[FALSE][11] := 31;

 DaysPerMonth[TRUE]    := DaysPerMonth[FALSE];
 DaysPerMonth[TRUE][1] := 29;

 MonthDays[FALSE][0] := 0;
 FOR i := 0 TO 10 DO
   MonthDays[FALSE][i+1] := MonthDays[FALSE][i] + DaysPerMonth[FALSE][i];
 END;
 MonthDays[TRUE][0] := 0;
 FOR i := 0 TO 10 DO
   MonthDays[TRUE][i+1] := MonthDays[TRUE][i] + DaysPerMonth[TRUE][i];
 END;
#endif
END DosSupport.
