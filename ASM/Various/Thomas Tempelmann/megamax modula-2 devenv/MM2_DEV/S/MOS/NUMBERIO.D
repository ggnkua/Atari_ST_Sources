DEFINITION MODULE NumberIO;

FROM SYSTEM IMPORT WORD, LONGWORD;

FROM Files IMPORT File;


  (* Die folgenden Read... Prozeduren lesen Zahlen in Textform aus
   * einer Datei ein.
   * Der Parameter 'success' liefert FALSE im Fehlerfall beim Lesen,
   * ansonsten das Ergebnis, ob die Zahl ermittelt werden konnte.
   * Nach Aufruf der Funktionen steht, sofern kein Fehler aufgetreten ist,
   * der Dateizeiger direkt hinter dem Zeichen, das die einzulesende Zahl
   * begrenzte. Siehe hierzu die Umwandlungsfunktionen aus 'Convert'.
   * Das begrenzende Zeichen kann mit den Aufrufen 'UndoRead' und
   * 'ReadChar' ermittelt werden.
   *)

PROCEDURE ReadCard (f: File; VAR card: CARDINAL; VAR success: BOOLEAN);
  (* akzeptiert Dezimalzahlen, Hexzahlen ('$' voran) und Bin„rzahlen
   * ('%' voran). *)

PROCEDURE ReadInt (f: File; VAR int: INTEGER; VAR success: BOOLEAN);
  (* akzeptiert Dezimalzahlen, Hexzahlen ('$' voran) und Bin„rzahlen
   * ('%' voran). *)

PROCEDURE ReadLCard (f: File; VAR card: LONGCARD; VAR success: BOOLEAN);
  (* akzeptiert Dezimalzahlen, Hexzahlen ('$' voran) und Bin„rzahlen
   * ('%' voran). *)

PROCEDURE ReadLInt (f: File; VAR int: LONGINT; VAR success: BOOLEAN);
  (* akzeptiert Dezimalzahlen, Hexzahlen ('$' voran) und Bin„rzahlen
   * ('%' voran). *)

PROCEDURE ReadNum (    f      : File;
                   VAR num    : WORD;
                       base   : CARDINAL; (* [2..36] *)
                   VAR success: BOOLEAN);
  (* akzeptiert positive, ganze Zahlen zur angegebenen Basis (Vorzeichen,
   * sowie '%' und '$' werden nicht akzeptiert).
   * Die Ziffernwerte 10 bis 36 werden dabei durch die Buchstaben 'A' bis 'Z'
   * (grož oder klein) bestimmt *)

PROCEDURE ReadLNum (    f      : File;
                    VAR num    : LONGWORD;
                        base   : CARDINAL; (* [2..36] *)
                    VAR success: BOOLEAN);
  (* akzeptiert positive, ganze Zahlen zur angegebenen Basis (Vorzeichen,
   * sowie '%' und '$' werden nicht akzeptiert).
   * Die Ziffernwerte 10 bis 36 werden dabei durch die Buchstaben 'A' bis 'Z'
   * (grož oder klein) bestimmt *)


PROCEDURE ReadReal  (f: File; VAR r: REAL;     VAR success: BOOLEAN);
PROCEDURE ReadLReal (f: File; VAR r: LONGREAL; VAR success: BOOLEAN);


PROCEDURE WriteCard  (f: File; card: LONGCARD; width: CARDINAL);
PROCEDURE WriteInt   (f: File; int : LONGINT;  width: CARDINAL);

PROCEDURE WriteHex   (f: File; hex : WORD;     width: CARDINAL);
PROCEDURE WriteLHex  (f: File; hex : LONGWORD; width: CARDINAL);

PROCEDURE WriteNum (f      : File;
                    num    : WORD;
                    base   : CARDINAL;  (* [2..26] *)
                    width  : CARDINAL;
                    filler : CHAR);

PROCEDURE WriteLNum (f      : File;
                     num    : LONGWORD;
                     base   : CARDINAL; (* [2..36] *)
                     width  : CARDINAL;
                     filler : CHAR);

PROCEDURE WriteFix   (f        : File;
                      real     : LONGREAL;
                      width    : CARDINAL;
                      decPlaces: CARDINAL);

PROCEDURE WriteFloat (f        : File;
                      real     : LONGREAL;
                      width    : CARDINAL;
                      decPlaces: CARDINAL);

PROCEDURE WriteEng   (f        : File;
                      real     : LONGREAL;
                      width    : CARDINAL;
                      decPlaces: CARDINAL);

PROCEDURE WriteReal  (f        : File;
                      real     : LONGREAL;
                      width    : CARDINAL;
                      decPlaces: CARDINAL);

END NumberIO.
