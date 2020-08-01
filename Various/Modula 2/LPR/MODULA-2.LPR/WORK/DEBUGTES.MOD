MODULE DebugTest;
(***********************************************************************
  Version : 07.06.89   14:23

  Dieses Modul dient zum Ausprobieren des Modula-Debuggers.
  Es benÅtzt globale und lokale Variablen verschiedener Typen,
  die im Debugger im Datenfenster 1 bzw. Datenfenster 2 inspiziert
  werden kînnen.
  Auûerdem kann die Prozedur-Aufrufkette verfolgt werden.

                                           M. Bayer
*************************************************************************)

 FROM SYSTEM IMPORT ADR;


TYPE
    GType   = (maennlich, weiblich);
    FType   = (blond, braun, schwarz, grau, glatze);
    RecType = RECORD
                Name :      ARRAY [0..20] OF CHAR;
                Geschlecht: GType;
                Haarfarbe : FType;
                Groesse :   CARDINAL;
               END;

    RecPtr = POINTER TO RecType;

 (* globale Variablendefinition*)
VAR

  globint:    INTEGER;
  globcard:   CARDINAL;
  zeichen:    CHAR;
  pointer:    RecPtr;
  record:     RecType;

PROCEDURE p1 (nutzlos: BOOLEAN);

(* lokale Variablen *)
VAR
  longint:  LONGINT;
  longcard: LONGCARD;

BEGIN
  longint := - 1234567D;
  longcard := 1234567D;
  HALT;
END p1;


PROCEDURE p2;

VAR
  b: BOOLEAN;
  c: CHAR;

BEGIN
  c := "c";
  b := NOT b;
  p1 (FALSE);
END p2;


BEGIN
  globint := -1;
  globcard := 60000;
  zeichen := "A";
  pointer := ADR(record);
  WITH pointer^ DO
    Name := "Mustermann";
    Geschlecht := maennlich;
    Haarfarbe := blond;
    Groesse := 178;
  END (*WITH*);

  p2;

END DebugTest.
