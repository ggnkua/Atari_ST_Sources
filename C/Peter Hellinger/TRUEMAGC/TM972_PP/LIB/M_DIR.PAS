UNIT M_Dir;

INTERFACE

USES OS;

CONST   Tos100 = $0100;
        Tos102 = $0102;
        Tos104 = $0104; (* Das aktuelle ST OS *)
        Tos106 = $0106; (* Beim 1040STE zu finden *)
        Tos205 = $0205; (* Die MegaSTE haben so eines *)
        Tos206 = $0206; (* neues fÅr MegaSTE und alle anderen *)
        Tos300 = $0300; (* Das OS des TT *)
        Tos301 = $0301; (* TîTî *)
        Tos305 = $0305; (* auch verbreitet *)
        Tos306 = $0306; (* Das neueste OS fÅr den TT030 *)
        Tos400 = $0400; (* Das OS fÅr den Falcon 030 *)
        Tos402 = $0402; (* Das neueste OS fÅr den Falcon 030 *)


FUNCTION GetFile (wild, message: STRING; VAR name: STRING): BOOLEAN;
(* Bedient sich des FileSelectors zur Eingabe eines Dateinamens. In
 * 'wild' kann ein Wildcard-Name Åbergeben werden, gegebenenfalls mit 
 * Pfad. 'message' wird ab Tos 1.4 in den Fileselector gesetzt.
 * 'name' enthÑlt bei Returnwert TRUE den Dateinamen MIT Pfad.
 *)

PROCEDURE GetPath (VAR pfad: STRING);
(* Ermittelt den aktuellen Pfad *)

PROCEDURE DelTail (VAR pfad: STRING);
(* Lîscht Suffix vom Pfad weg: Aus 'C:\M2\M.PRG' wird 'C:\M2\' *)

PROCEDURE SplitPath (path: STRING; VAR pfad, name, suff: STRING);
(* Zerlegt Pfad in seine Bestandteile *)

FUNCTION ExSelector: BOOLEAN;
(* TRUE, wenn ein extended Fileselector, zB. von Martin Patzel installiert ist
 * ebenfalls TRUE, wenn TOS >= 1.4 verwendet wird.
 *)

FUNCTION GetVersion: INTEGER;
(* Liefert die Version des Betriebssystems *)

FUNCTION Exist (datei: STRING): BOOLEAN;
(* TRUE wenn datei existiert *)

PROCEDURE Replace (old, wildcard: STRING; VAR new: STRING);
(* Bildet aus wildcard und old einen neuen Dateinamen (new). Beispiel:
 *
 *      old             wildcard        new
 *
 *      DATEI.TXT       *.DOC           DATEI.DOC
 *      DATEI.TXT       X*.*            XATEI.TXT
 *      DATEI.TXT       *.*             DATEI.TXT
 *      DATEI.TXT       ?????001.*      DATEI001.TXT
 *      DATEI.TXT       DATEI.BAK       DATEI.BAK
 *
 *)

PROCEDURE SearchParas (maske: STRING; attribut: INTEGER;
                       ptrdta: DTAPtr; firsttime: BOOLEAN);
(* Stellt die Parameter ein, nach denen ein File gesucht wird *)

FUNCTION Found: BOOLEAN;
(* TRUE, wenn eine Datei mit den Parametern aus SearchParas gefunden wurde *)

TYPE FileProc = FUNCTION (path: STRING; ptrdta: DTAPtr): INTEGER;
(* Eine Prozedur dieses Typs Åbernimmt eine Dateioperation.  Sie sollte einen
 * Wert von < 0 liefern, wenn ein Fehler aufgetreten ist, ansonsten 0.
 * Die Prozedur bekommt den Namen der Datei Åbergeben
 *)

PROCEDURE ForEach (mask: STRING; rekurs: BOOLEAN; doproc: FileProc);
(* Ruft 'doproc' fÅr jede Datei auf, die nach dem Muster in 'mask' gefunden
 * wird. Ist 'rekurs' TRUE, werden Unterverzeichnise ebenfalls durchlaufen
 *)

FUNCTION CopyFile (sourcefile, targetfile: STRING): INTEGER;
(* Kopiert eine Datei, liefert folgende Fehlercodes:
 * 0 = Kein Fehler
 * 1 = Quelle und Ziel identisch
 * 2 = Fehler beim ôffnen der Quelle
 * 3 = Fehler beim Erzeugen des Ziels
 * 4 = Fehler wÑhrend des Kopierens (Lese/Schreibfehler)
 *)

IMPLEMENTATION

USES Basics, M_Sys, Cookie, M_Strings, AES, DOS;

CONST   NullChar =      CHR (0);

VAR     version:        INTEGER;
        slash:          ARRAY [0..0] OF CHAR;
        exsel:          BOOLEAN;
        stack:          POINTER;

VAR     Search:         RECORD
                         name:  STRING;
                         attr:  BYTE;
                         first: BOOLEAN;
                         dta:   DTAPtr;
                        END; 

VAR     defDTA:         DTA;
        defDtaPtr:      DTAPtr;
        c1, c2, c3:     CSTRING;



FUNCTION GetFile (wild, message: STRING; VAR name: STRING): BOOLEAN;
VAR s1, s2, s3: STRING;
    b: BOOLEAN;
BEGIN
 FSplit (FExpand (wild), s1, s2, s3);
 IF (Pos ('*', s2) > 0) OR (Pos ('?', s2) > 0) THEN BEGIN
  s1:= Concat (s1, s2, s3);
  s2:= '';
 END ELSE BEGIN
  s1:= Concat (s1, '*', s3);
  s2:= Concat (s2, s3);
 END;
 PascalToCString (message, @c3);
 PascalToCString (s1, @c1);
 PascalToCString (s2, @c2);
 IF StrLen (c3) > 30 THEN  c3[30]:= NullChar;
 IF exselector THEN  b:= AES.fsel_exinput (c3, c1, c2)
               ELSE  b:= AES.fsel_input (c1, c2);
 IF b THEN BEGIN
  CToPascalString (s1, @c1);
  CToPascalString (s2, @c2);
  DelTail (s1);
  name:= Concat (s1, s2);
 END ELSE BEGIN
  name:= '';
 END;
 GetFile:= b;
END (*GetFile*);

PROCEDURE GetPath (VAR pfad: STRING);
BEGIN
 pfad:= FExpand (pfad);
END (*GetPath*);

PROCEDURE DelTail (VAR pfad: STRING);
VAR c: INTEGER;
BEGIN
 c:= Length (pfad);
 WHILE (c > 1) AND (pfad[c-1] <> '\') DO  DEC (c);
 Delete (pfad, c, c);
END (*DelTail*);

PROCEDURE SplitPath (path: STRING; VAR pfad, name, suff: STRING);
BEGIN
 FSplit (path, pfad, name, suff);
END (*SplitPath*);

FUNCTION GetVersion (): INTEGER;
BEGIN
 GetVersion:= version;
END (*GetVersion*);

FUNCTION ExSelector (): BOOLEAN;
BEGIN
 ExSelector:= exsel;
END (*ExSelector*);

PROCEDURE SearchParas (maske: STRING; attribut: INTEGER;
                       ptrdta: DTAPtr; firsttime: BOOLEAN);
BEGIN
 WITH Search DO BEGIN
  name:= maske;
  attr:= attribut;
  first:= firsttime;
  dta:= ptrdta;
 END;
END (*SearchParas*);

FUNCTION Found (): BOOLEAN;
VAR err: INTEGER;
BEGIN
 Fsetdta (Search.dta);
 IF Search.first THEN BEGIN
  Search.first:= FALSE;
  err:= Fsfirst (Search.name, Search.attr);
 END ELSE BEGIN
  err:= Fsnext ();
 END;
 Found:= (err = 0);
END (*Found*);

FUNCTION Exist (datei: STRING): BOOLEAN;
(* Testet, ob Datei oder Ordner schon existiert *)
VAR err: INTEGER;
BEGIN
 Fsetdta (defDtaPtr);
 Exist:= Fsfirst (datei, $FF) = 0;
END (*Exist*);

PROCEDURE Replace (old, wildcard: STRING; VAR new: STRING);
(* Bildet aus wildcard und oldName einen neuen Dateinamen (new). *)
CONST cMaxLen =  11;
      cPrefLen =  8;

 PROCEDURE MakeMask (wld: STRING; VAR maske: CSTRING);
 (* Expandiert einen Dateinamen auf 12 Zeichen, ? und * werden als ?
  * eingetragen. Nichtvorhandene Zeichen werden Blanks!
  *)
 LABEL Loop1;
 VAR c, d, i: INTEGER;
     wild: CSTRING;
 BEGIN (* MachMaske *)
  PascalToCString (wld, @wild);
  (* Vorgefertigte Maske *)
  FOR c:= 0 TO cMaxLen DO maske[c]:= '?';
  c:= 0;  d:= 0;
  WHILE TRUE DO BEGIN
   IF (wild[d] = NullChar) THEN BEGIN
    (* Wildcard zu Ende, Rest der Maske mit Blanks auffÅllen *)
    FOR i:= c TO cMaxLen DO  maske[i]:= ' ';
    EXIT;
   END ELSE IF (wild[d] = '*') THEN BEGIN
    (* Auf einen * muû ein Punkt in der Wildcard folgen! *E*.MOD ist illegal! *)
    INC(d, 2); (* Punkt auslassen *)
    GOTO Loop1; (* Fertig mit Prefix-Teil *)
   END ELSE IF (wild[d] = '.') THEN BEGIN
    (* Punkt gefunden, Prefix bis zur Maximalen LÑnge mit Blanks auffÅllen *)
    FOR i:= c TO cPrefLen DO  maske[i]:= ' ';
    INC(d);
    GOTO Loop1; (* Fertig mit Prefix-Teil *)
   END ELSE BEGIN (* Zeichen aus wild nach maske Åbertragen *)
    maske[c]:= wild[d];  INC(c);  INC(d);
   END;
  END;
  LOOP1:
  c:= cPrefLen + 1; (* Index von maske auf 'nach dem Punkt' einstellen *)
  WHILE TRUE DO BEGIN
   IF (wild[d] = Nullchar) THEN BEGIN
    (* Wildcard zu Ende, Rest der Maske mit Blanks auffÅllen *)
    FOR i:= c TO cMaxLen DO maske[i]:= ' ';
    EXIT;
   END;
   IF (c > cMaxLen) OR (wild[d]='*') THEN
    EXIT; (* wild fertig, bzw. maske voll *)
   (* Zeichen aus wild nach maske Åbertragen *)
   maske[c]:= wild[d];  INC(c); INC(d); 
  END;
 END (*MakeMask*);

VAR c, d: INTEGER;
    wild, maske: CSTRING;
    loop: BOOLEAN;

BEGIN (* Ersetze *)
 MakeMask (wildcard, wild); (* Masken erstellen *)
 MakeMask (old, maske);
 (* Alle legalen Zeichen aus wild nach maske Åbertragen (auch Blanks!) *)
 FOR c:= 0 TO cMaxLen DO BEGIN
  IF wild[c] <> '?' THEN  maske[c]:= wild[c];
 END;
 (* new zur Sicherheit lîschen *)
 FillChar (new, SIZEOF (new), CHR(0));
 c:= 1;  d:= 0;  loop:= TRUE;
 WHILE loop DO BEGIN
  IF d = cPrefLen THEN BEGIN (* Punktposition, Punkt in new einsetzen *)
   new[c]:= '.';  INC(c);  INC(d); 
  END;
  IF (maske[d] <> '?') AND (maske[d] <> ' ') THEN BEGIN  
   (* Blanks und ? aussparen, haben nix im neuen Namen zu suchen! *)
   new[c]:= maske[d];  INC(c); INC(d);
  END ELSE BEGIN
   INC(d);
  END;
  IF (d > cMaxLen) THEN loop:= FALSE; (* Neuer Name fertig *)
 END; (* WHILE loop *)
 new[0]:= CHR (c-1);
END (*Replace*);


PROCEDURE ForEach (mask: STRING; rekurs: BOOLEAN; doproc: FileProc);
VAR mydta: DTA;
    o, p: STRING;
    n, s: STRING[10];
BEGIN
 FSplit (mask, p, n, s);
 (*p:= FExpand (mask);  DelTail (p);*)
 IF rekurs THEN BEGIN
  (* Erst nach Verzeichnissen suchen *)
  SearchParas (p + '*.*', FA_DIREC, @mydta, TRUE);
  WHILE Found DO BEGIN
   IF (mydta.d_fname <> '.') AND 
      (mydta.d_fname <> '..') AND
      ((mydta.d_attrib AND FA_DIREC) = FA_DIREC) THEN BEGIN
    o:= p;
    p:= p + mydta.d_fname + '\' + n + s;
    ForEach (p, TRUE, doproc);
    p:= o;
    SearchParas (p + '*.*', FA_DIREC, @mydta, FALSE);
   END;
  END;
  SearchParas (mask, FA_ATTRIB, @mydta, TRUE);
  WHILE Found DO 
   IF (mydta.d_fname <> '.') AND  (mydta.d_fname <> '..') AND
      ((mydta.d_attrib AND FA_DIREC) <> FA_DIREC) THEN doproc (p, @mydta);
 END ELSE BEGIN
  SearchParas (mask, FA_ATTRIB, @mydta, TRUE);
  WHILE Found DO doproc (p, @mydta);
 END;
END (*ForEach*);


FUNCTION CopyFile (sourcefile, targetfile: STRING): INTEGER;
(* return codes:  0 successful
                  1 source and target the same
                  2 cannot open source
                  3 unable to create target
                  4 error during copy
*)
VAR source, target: FILE;
    bread, bwrite:  LONGINT;
    filebuf:        ARRAY [1..2048] of char;
BEGIN
 CopyFile:= 1;  
 IF sourcefile = targetfile THEN  EXIT;

 CopyFile:= 2;  
 SYSTEM.Assign (source, sourcefile);
 {$I-} SYSTEM.Reset (source, 1); {$I+}
 IF IOResult <> 0 THEN EXIT;

 CopyFile:= 3;  
 SYSTEM.Assign (target, targetfile);
 {$I-}  SYSTEM.Rewrite(target,1); {$I+}
 IF IOResult <> 0 THEN EXIT;

 REPEAT
  SYSTEM.BlockRead (source, filebuf, SIZEOF (filebuf), bread);
  SYSTEM.BlockWrite (target, filebuf, bread, bwrite);
 UNTIL (bread = 0) or (bread <> bwrite);
 SYSTEM.Close (Source);
 SYSTEM.Close (Target);
 IF bread <> bwrite THEN  CopyFile:= 4
                    ELSE  CopyFile:= 0;
END (*CopyFile*);


VAR     c:      INTEGER;
        adr:    POINTER;
        val:    LONGINT;

BEGIN
 slash[0]:= '\';
 defDtaPtr:= ADDR(defDTA);
 version:= TosVersion();
 exsel:= Cookie.FindCookie ('FSEL', val);
 IF NOT exsel THEN exsel:= version > Tos102;
END (*M_Dir*).
