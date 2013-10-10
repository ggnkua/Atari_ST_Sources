
MODULE WholeTest;

FROM SYSTEM IMPORT ASSEMBLER;

CONST
  const65536 = LONGINT(65536);
  
VAR
  var65536   : LONGINT;
  
  varResult  : INTEGER;
  constResult: INTEGER;
  
  d          : LONGINT;

BEGIN
  var65536 := 65536;
  d := -65536;         (* Fehler tritt bei negativen Zahlen d auf. *)
  
  (* Division durch eine Variable, die 65536 enthÑlt: *)
  ASSEMBLER BREAK END;
  varResult := SHORT(d DIV var65536);
  (* Klappt ja wunderbar. *)
  
  
  (* Wenn man jetzt die Variable durch eine Konstante ersetzt,
     kînnte der Compiler doch so schlau sein, das Resultat durch
     ein SWAP zu erhalten... *)
  constResult := SHORT(d DIV const65536);
  (* Zu frÅh gefreut. Man sollte schon froh sein, wenn er's
     Åberhaupt berechnen kann. *)

END WholeTest.
