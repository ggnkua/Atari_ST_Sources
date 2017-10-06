UNIT Command;

INTERFACE

FUNCTION ArgV: BOOLEAN;
(* TRUE, wenn die Parameter nach ARGV Åbergeben wurden *)

FUNCTION ParamCount: WORD;
(* Anzahl der Parameter in der Kommandozeile, 0 wenn keine Parameter *)

FUNCTION ParamStr (index: WORD): STRING;
(* Liefert das Argument Nummer 'index' aus der Kommandozeile. Gibts index 
 * nicht, ist ParamString leer. Wurden die Argumente nach ARGV Åbergeben, 
 * ist das Argument mit Nummer 0 der Pfad und Name des Programmes.
 *)

(* Einige Åbliche Environment-Variablen *)

CONST   EnvPath =       'PATH';        (* Suchpfade *)
        EnvRows =       'ROWS';        (* Anzahl der Zeilen auf dem Schirm *)
        EnvColumns =    'COLUMNS';     (* Anzahl der Spalten auf dem Schirm *)
        EnvTempdir =    'TMPDIR';      (* TemporÑres Verzeichnis *)
        EnvClipbrd =    'CLIPBRD';     (* Clipboard-Verzeichnis *)
        EnvHome =       'HOME';        (* Home-Path *)
        EnvEditor =     'EDITOR';      (* Name des Default-Editors *)
        EnvShell =      'SHELL';       (* Name der Shell *)
        EnvStderr =     'STDERR';      (* Standard-Fehlerkanal *)

FUNCTION EnvVar (name: STRING; VAR value: STRING): BOOLEAN;
(* Sucht in einem eventuellen Environment eine Variable namens 'name' und
 * liefert deren Wert in 'value'. Returniert TRUE, wenn die Environment-
 * Variable gefunden wurde, sonst FALSE.
 *)

FUNCTION EnvLine (n, pos: INTEGER; VAR line: ARRAY OF CHAR): BOOLEAN;

IMPLEMENTATION

(*----------------------------------------------------------------------*
 * Int. Vers | Datum    | Name | énderung                               *
 *-----------+----------+------+----------------------------------------*
 *  1.00     | 24.01.92 |  Hp  | Modula-2 to Pascal                     *
 *-----------+----------+------+----------------------------------------*
 * Bemerkung: Wenn ich Den erwische, der bei Pure auf die Idee gekommen *
 *            ist, die einzelnen Parameter in der Baspage-Kommandozeile *
 *            durch ein Nullbyte zu trennen, kommt er in die Suppe!!!   *
 *            Falls das mal geÑndert wird, muû die Konstante 'TermChar' *
 *            angepasst werden!                                         *
 *----------------------------------------------------------------------*)


CONST   TermChar = CHR (0); (* GRMBL!!! Siehe Bemerkung! *)

TYPE    tEnvPtr = ^tEnv;
        tEnv =    ARRAY [0..$07FFF] OF CHAR;

VAR     pCount:   INTEGER;
        Base:     PDPtr;
        IsArgv:   BOOLEAN;
        arg:      INTEGER; (* Pos. des ersten Arg. im Environment *)
        env:      tEnvPtr;
        path:     Pchar;

FUNCTION ArgV: BOOLEAN;
BEGIN
 ArgV:= IsArgv;
END (*ArgV*);

FUNCTION ParamCount: WORD;
BEGIN
 Command.ParamCount:= pCount;
END (*ParamCount*);

FUNCTION EnvLine (n, pos: INTEGER; VAR line: ARRAY OF CHAR): BOOLEAN;
VAR l, d, x, p: INTEGER;
BEGIN
 line[0]:= CHR (0);
 IF Base^.p_Env <> POINTER (0) THEN BEGIN
  env:= Base^.p_Env;  x:= pos;  p:= 0;  d:= 0;  l:= SIZEOF (line);
  REPEAT
   IF p = n THEN BEGIN
    WHILE (env^[x] <> CHR(0)) AND (d < l) DO BEGIN
     line[d]:= env^[x];  INC (x);  INC (d);
    END; (* WHILE *)
    line[d]:= CHR (0);
    EnvLine:= TRUE;
    EXIT;
   END;
   IF (env^[x] = CHR(0)) THEN BEGIN
    IF (env^[x + 1] = CHR(0)) THEN BEGIN
     (* Doppelnull, fertisch *)  EnvLine:= FALSE;  EXIT;
    END;
    INC (p);
   END;
   INC (x);
  UNTIL p > n;
 END;
 EnvLine:= FALSE;
END (*EnvLine*);

FUNCTION ParamStr (index: WORD): STRING;
VAR c, d, x, l, p: INTEGER;
    cs: ARRAY [0..255] OF CHAR;
    ps: STRING;
    b: BOOLEAN;
BEGIN
 IF IsArgv THEN BEGIN (* Parameter im Environment *)
  IF index = 0 THEN BEGIN (* argv0 liefern, daû ist der Programmpfad! *)
   Command.ParamStr:= path; 
   EXIT;
   END
  ELSE IF index > 0 THEN BEGIN
   (*b:=*) EnvLine (index - 1, arg, cs);
   CtoPascalString (ps, @cs);
   Command.ParamStr:= ps;
   EXIT;
  END;
  END (* IF IsArgV *)
 ELSE BEGIN (* Kein Argv, Parameter in der Kommandozeile *)
  IF (index > 0) AND (index <= pCount) THEN BEGIN
   p:= 1;  c:= 1;  ps:= ''; l:= ORD(Base^.p_Cmdlin[0]);

   (* Argumente durchforsten *)
   WHILE c < l DO BEGIN

    (* FÅhrende FÅllzeichen Åberspringen *)
    WHILE (Base^.p_Cmdlin[c] = TermChar) AND (c <= l) DO BEGIN
     INC (c);
    END;

    (* Da haben wirs ja schon *)
    IF index = p THEN BEGIN
     d:= 1;
     WHILE (Base^.p_Cmdlin[c] <> TermChar) AND (c <= l) DO BEGIN
      ps[d]:= Base^.p_Cmdlin[c];  INC (c);  INC (d);
     END;
     ps[0]:= CHR (d-1);
     ParamStr:= ps;
     EXIT;
    END;

    INC (c);

    IF Base^.p_Cmdlin[c] = Termchar THEN BEGIN INC (p); END;

   END; (* WHILE c < l *) 
  END; 
 END;
 Command.ParamStr:= '';
END (*ParamStr*);

FUNCTION EnvVar (name: STRING; VAR value: STRING): BOOLEAN;
VAR i, c: INTEGER;
    cs: ARRAY [0..255] OF CHAR;
    ps: STRING;
BEGIN
 EnvVar:= FALSE;
 i:= 0;  value:= '';
 REPEAT
  IF EnvLine (i, 0, cs) THEN BEGIN
   CtoPascalString (ps, @cs);
   c:= Pos (name, ps); 
   IF c = 1 THEN BEGIN
    value:= ps;
    Delete (value, c, Length(name)+1);  (* +1: auch das '=' lîschen! *)
    EnvVar:= TRUE;
    EXIT;
   END;
  END ELSE BEGIN
   EXIT;
  END;
  INC (i);
 UNTIL FALSE; (* Ende des Environments *)
END (*EnvVar*);

PROCEDURE InitCommand;
VAR v: INTEGER; (* Counter durchs Environment *)
    x, c, l: INTEGER;
BEGIN
 IsArgv:= FALSE;  pCount:= 0;  arg:= 0;  v:= 0;

 (* Basepage auslesen *)
 Base:= BasePage;
 l:= ORD(Base^.p_Cmdlin[0]);
 IF l > 126 THEN BEGIN (* Sollte eine ARGV-Zeile sein. *)
  env:= Base^.p_Env;
  (* 'ARGV=' suchen *)
  REPEAT
   IsArgv:= (env^[v    ] = 'A') AND 
            (env^[v + 1] = 'R') AND 
            (env^[v + 2] = 'G') AND
            (env^[v + 3] = 'V') AND
            (env^[v + 4] = '=') AND
            (env^[v + 5] <> #0);
   IF IsArgv THEN BEGIN  env^[v]:= CHR(0);  INC (v, 5); END
             ELSE BEGIN  INC (v);  END;
  UNTIL (env^[v] = CHR(0)) AND (env^[v + 1] = CHR(0)) OR IsArgv;
 END;
 
 IF IsArgv THEN BEGIN
  (* Nach erstem Null-Char suchen, v zeigt auf das Zeichen nach 'ARGV=' *)
  WHILE env^[v] <> CHR(0) DO BEGIN  INC (v);  END;
  INC (v); (* Erstes Zeichen des folgenden Parameters *)
  (* Hier beginnt der erste Parameter. Das ist der Name und Pfad unter
   * dem das Programm gestartet wurde...
   *)
  x:= 0;
  WHILE (env^[v] <> CHR(0)) AND (x < 255) DO BEGIN
   path[x]:= env^[v];  INC (v);  INC (x);
  END;
  path[x]:= CHR(0);

  arg:= v + 1; (* Position des ersten Arguments im Environment *)
  pCount:= 0; (* ArgumentzÑhler lîschen *)
  REPEAT (* Argumente zÑhlen *)
   WHILE env^[v] <> CHR(0) DO BEGIN  INC (v); END;
   INC (pCount); INC (v);
  UNTIL env^[v] = CHR(0);(* Doppelnull, fertisch *);
  DEC (pCount);

 END ELSE BEGIN (* Kein ARGV, Parameter aus der Basepage holen *)
  IF (l > 0) THEN BEGIN
   pCount:= 1;  c:= 1;
   (* FÅhrende FÅllzeichen Åberspringen *)
   WHILE (Base^.p_Cmdlin[c] = TermChar) AND (c < l) DO BEGIN
    INC (c); IF c = l THEN BEGIN DEC (pCount); END;
   END;
   (* Argumente zÑhlen *)
   WHILE c < l DO BEGIN
    IF (Base^.p_Cmdlin[c] = TermChar) THEN BEGIN
     INC (pCount); 
     WHILE (Base^.p_Cmdlin[c] = TermChar) AND (c < l) DO BEGIN
      INC (c);
      IF c = l THEN BEGIN DEC (pCount); END;
     END;
    END;
    INC (c);
   END;
  END ELSE BEGIN 
   pCount:= 0;
  END; 
 END;
END (*InitCommand*);

BEGIN
 InitCommand;
END (*Command*).
