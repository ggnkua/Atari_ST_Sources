DEFINITION MODULE InOut;

FROM SYSTEM IMPORT WORD, LONGWORD;

CONST EOL = 15C;
       (*
        * end-of-line character (= 13 dezimal).
        * Dieser Wert wird geliefert (von 'Read' bzw. durch 'termCH'),
        * wenn ein Zeilenendezeichen gelesen wurde. (Dies kann die
        * Kombination aus CR und LF oder ein einzelnes LF sein).
        * Wird dieses Zeichen bei 'Write' ausgegeben, wirkt dies wie
        * ein WriteLn-Aufruf.
        *)

VAR  Done: BOOLEAN;
       (*
        * Wurde die Ein- oder Ausgabe umgeleitet (mit Redirect...
        * oder OpenIn-/Output), zeigt dieser Wert an, ob die
        * letzte Operation noch erfolgreich auf der Datei
        * ausgefÅhrt werden konnte. Ist der Wert FALSE, ist entweder
        * die Datei nicht zu îffnen (nach OpenIn-/Output bzw.
        * Redirect...), die Datei beim Lesen zu Ende oder es
        * wurde einfach eine ungÅltige Eingabe getÑtigt (z.B.
        * durch falsche Eingabe bei 'ReadCard').
        *)

     termCH: CHAR;
       (*
        * EnthÑlt das Trennzeichen, mit dem die Eingabe bei
        * 'ReadString', 'ReadToken' oder 'ReadLine' sowie den
        * Zahlen-Eingabefunktionen beendet wurde.
        *)


PROCEDURE OpenInput ( REF defExt: ARRAY OF CHAR );
  (*
   * Der Anwender wird nach einem Dateinamen fÅr die Eingabe gefragt.
   * Gibt er keine Endung an, wird 'defExt' verwendet.
   *)

PROCEDURE OpenOutput ( REF defExt: ARRAY OF CHAR );
  (*
   * Der Anwender wird nach einem Dateinamen fÅr die Ausgabe gefragt.
   * Gibt er keine Endung an, wird 'defExt' verwendet.
   *
   * Wenn die angegebene Datei schon existiert, wird sie Åberschrieben.
   *)

PROCEDURE RedirectInput ( REF fileName: ARRAY OF CHAR );
  (* Direkte Angabe der Eingabedatei *)

PROCEDURE RedirectOutput ( REF fileName: ARRAY OF CHAR; append: BOOLEAN );
  (* Direkte Angabe der Ausgabedatei.
   * Wenn die angegebene Datei schon existiert, wird sie, wenn 'append'
   * FALSE ist, Åberschrieben, sonst werden die Daten an die bestehende
   * Datei angefÅgt.
   *)

PROCEDURE CloseInput;

PROCEDURE CloseOutput;


PROCEDURE Read         (VAR c: CHAR);
  (* Liest ein Zeichen *)

PROCEDURE ReadFromLine (VAR s: ARRAY OF CHAR);
  (* Liest aus Zeile, bis String voll oder Zeilenende *)

PROCEDURE ReadToken    (VAR s: ARRAY OF CHAR);
  (* Liest ein Wort *)

PROCEDURE ReadLn;
  (* Verwirft alle Zeichen bis zum Zeilenende. *)

PROCEDURE EndOfLine (skip: BOOLEAN): BOOLEAN;
  (* Liefert TRUE, wenn alle Zeichen bis zum Zeilenende gelesen sind
   * (nur nach Read- und ReadToken-Aufrufen relevant).
   * Ist 'skip' TRUE, werden ggf. alle Zeichen bis zum Zeilenende
   * Åberlesen (wie beim Aufruf von 'ReadLn'
   *)

PROCEDURE ReadString   (VAR s: ARRAY OF CHAR);
  (*
   * Liest je nach Konfiguration des InOut-Treibers
   * eine ganze Zeile oder nur ein Wort.
   * Wird beispielsweise GEMIO (Standard) oder TOSIO als Treiber
   * verwendet, wird hierbei eine ganze Zeile gelesen (wie ReadFromLine).
   *)

PROCEDURE ReadCard     (VAR c: CARDINAL);
PROCEDURE ReadInt      (VAR i: INTEGER);
PROCEDURE ReadLCard    (VAR c: LONGCARD);
PROCEDURE ReadLInt     (VAR i: LONGINT);
  (*
   * Lesen dezimale Zahlen ein.
   * Zur hexadezimalen Eingabe muû ein "$" am Anfang der
   * Zahl stehen, binÑre Werte werden mit "%" eingeleitet.
   *)

PROCEDURE ReadNum      (VAR num: WORD;     base: CARDINAL);
PROCEDURE ReadLNum     (VAR num: LONGWORD; base: CARDINAL);
  (*
   * Lesen vorzeichenlose Zahl zur Basis 'base' ein.
   * Done ist FALSE, wenn die Eingabe ungÅltig war.
   *)

PROCEDURE ReadReal     (VAR r: REAL);
PROCEDURE ReadLReal    (VAR r: LONGREAL);


PROCEDURE KeyPressed   (): BOOLEAN;    (* TRUE, wenn Taste gedrÅckt *)
PROCEDURE BusyRead     (VAR c: CHAR);  (* 'ch'=0C, wenn keine Taste gedrÅckt *)
PROCEDURE CondRead     (VAR c: CHAR; VAR valid: BOOLEAN);
                                  (* 'valid'=FALSE, wenn kein Taste gedrÅckt *)

PROCEDURE FlushKbd;
  (*
   * Lîscht alle Zeichen im Tastaturpuffer.
   * Bei Eingabe von einer Datei geschieht nichts.
   *)


PROCEDURE GotoXY       (x, y: CARDINAL);

PROCEDURE Write        (c: CHAR);
PROCEDURE WriteString  (REF s: ARRAY OF CHAR);
PROCEDURE WriteLn;
PROCEDURE WritePg;                     (* Lîscht Bildschirm *)

PROCEDURE WriteCard    (c: LONGCARD; width: CARDINAL);
PROCEDURE WriteInt     (i: LONGINT;  width: CARDINAL);

PROCEDURE WriteHex     (n: WORD;     width: CARDINAL);
PROCEDURE WriteLHex    (n: LONGWORD; width: CARDINAL);
  (*
   * Die Zahl 'n' wird hexadezimal mit einem "$" und fÅhrenden
   * Nullen ausgegeben. 'width' bestimmt die Mindestbreite
   * einschlieûlich des "$"-Zeichens.
   * Bsp:  WriteHex (18, 4)   ergibt   "$012"
   *)

PROCEDURE WriteNum     (n: WORD;     base, width: CARDINAL; filler: CHAR);
PROCEDURE WriteLNum    (n: LONGWORD; base, width: CARDINAL; filler: CHAR);
  (*
   * Die Zahl 'n' wird zur Basis 'base' asugegeben.
   * 'width' bestimmt die Mindestbreite, ggf. wird mit 'filler'
   * aufgefÅllt.
   * Bsp:  WriteNum (18, 16, 4, '0')   ergibt   "0012"
   *       WriteNum (18, 16, 4, ' ')   ergibt   "  12"
   *       WriteNum (18, 16, 0, ' ')   ergibt   "12"
   *)

PROCEDURE WriteReal    (x: LONGREAL; width, sigFigs: CARDINAL);
  (*
   * Ausgabe des Real-Wertes. Je nach Wert (siehe FixToFloatMin/Max
   * in MOSConfig) wird WriteFix oder WriteFloat aufgerufen (s.u.).
   *)

PROCEDURE WriteFix     (x: LONGREAL; width, sigFigs: CARDINAL);
  (* Festkomma-Darstellung des Real-Wertes *)

PROCEDURE WriteFloat   (x: LONGREAL; width, sigFigs: CARDINAL);
  (* Flieûkomma-Darstellung des Real-Wertes *)

PROCEDURE WriteEng     (x: LONGREAL; width, sigFigs: CARDINAL);
  (* Ingenieur-Darstellung des Real-Wertes *)

END InOut.
