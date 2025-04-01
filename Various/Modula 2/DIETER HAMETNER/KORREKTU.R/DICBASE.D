DEFINITION MODULE DicBase;

FROM SYSTEM     IMPORT  ADDRESS;
FROM Strings    IMPORT  String, Relation;

TYPE CPtr = POINTER TO CHAR;
     SPtr = POINTER TO String;

CONST CardSize = 2;
      AdrSize  = 4;
      
VAR voidS: String;
    voidC: CARDINAL;
    voidO: BOOLEAN;

PROCEDURE FileToMem (VAR fn: ARRAY OF CHAR;
                     VAR adr: ADDRESS;VAR n: LONGCARD);

(*  Liest 'fn' nach 'adr'. Bei adr=NIL wird alloziert *)
  
PROCEDURE MemToFile (VAR fn: ARRAY OF CHAR; adr: ADDRESS; n: LONGCARD);

  (*  Schreibt Daten ab 'adr' ('n' = Grîûe) *)

PROCEDURE allocate (VAR adr: ADDRESS; size: LONGCARD);

  (*  ALLOCATE mit eingebauter Fehlerabfrage *)

PROCEDURE Check (err: BOOLEAN; res: INTEGER; txt: ARRAY OF CHAR);

  (*  Entspricht IF err THEN WriteString (GetErrMsg + txt),TermProcess *)

PROCEDURE inc (c: CHAR): CHAR;

  (* Liefert 'c'+1 zurÅck *)

PROCEDURE CardToMem (card: CARDINAL; adr: ADDRESS);
PROCEDURE MemToCard (adr: ADDRESS): CARDINAL;

  (* kopiert 'card' nach 'adr', bzw. umgekehrt. *)

PROCEDURE cmp (a, b: CPtr): Relation;

  (* schneller Vergleich von Nullterminierten Strings *)

PROCEDURE ByteCopy (from: ADDRESS; n: CARDINAL; to: ADDRESS);

  (* schnelle Copyroutiene - nur fÅr kleine 'n' verwenden.*)

PROCEDURE FILESIZE (VAR fn: ARRAY OF CHAR): LONGCARD;

END DicBase.
