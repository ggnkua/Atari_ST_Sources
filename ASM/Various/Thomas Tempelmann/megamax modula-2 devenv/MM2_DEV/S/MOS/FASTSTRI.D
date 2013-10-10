DEFINITION MODULE FastStrings;

(*
   String - Bibliothek

   Die hiesigen Funktionen ersetzen zum Teil die gleichnamigen Funktionen
   aus 'Strings'.
   
   FrÅher (Version 1) waren diese Funktionen schneller als die im Modul
   Strings, weil hier VAR-Parameter eingesetzt waren, wo im Strings-Modul
   die Werte 'by value' (ohne VAR) Åbergeben wurden, was eine zusÑtzliche,
   oft ÅberflÅssige interne Kopieraktion der Argumente erforderte.
   
   Seit EinfÅhrung der REF-Parameter ist dies aber nicht mehr der Fall -
   die Strings-Funktionen sind nun ebenso schnell wie die von diesem
   Modul.
   
   Dies Modul ist nur noch vorhanden, damit frÅhere Programme nicht
   umgestellt werden brauchen.
*)

FROM Strings IMPORT Relation;


PROCEDURE Length ( REF str: ARRAY OF CHAR ): CARDINAL;
  (* Liefert LÑnge eines Strings. *)

PROCEDURE Chr ( REF s: ARRAY OF CHAR; n: CARDINAL ): CHAR;
  (*
   * Liefert das Zeichen an der Position 'n' aus dem String 's'.
   * Ist der String kÅrzer als 'n', wird der Wert 0C geliefert.
   *)

PROCEDURE Pos ( REF pattern, source: ARRAY OF CHAR ): INTEGER;
  (* Sucht ab der ersten Position in 'source' den String 'pattern'.
   * Liefert -1, wenn nicht gefunden, sonst die Position. *)

PROCEDURE PosLen ( REF pattern, source: ARRAY OF CHAR ): CARDINAL;
  (* Wie 'Pos', liefert aber 'Length (source)', wenn nicht gefunden. *)

PROCEDURE Assign ( REF source: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR );
  (* Weist die Variable 'source' auf 'dest' zu. *)

PROCEDURE Delete ( REF str    : ARRAY OF CHAR;
                       pos    : INTEGER;
                       len    : INTEGER );
  (* Lîscht 'len' Zeichen ab Position 'pos' aus dem String 'str'. *)

PROCEDURE Append ( REF source: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR );
  (* FÅgt 'source' an 'dest' an. *)

PROCEDURE Insert ( REF source : ARRAY OF CHAR;
                       pos    : INTEGER;
                   VAR dest   : ARRAY OF CHAR );
  (* FÅgt 'source' an Position 'pos' in 'dest' ein. *)

PROCEDURE Copy ( REF source : ARRAY OF CHAR;
                     pos    : INTEGER;
                     len    : INTEGER;
                 VAR dest   : ARRAY OF CHAR );
  (* Kopiert ab Position 'pos' 'len' Zeichen aus 'source' nach 'dest'. *)


PROCEDURE Concat ( REF source1, source2: ARRAY OF CHAR;
                   VAR dest: ARRAY OF CHAR );
  (*
   * FÅgt die Strings 'source1' und 'source2' in 'dest' zusammen.
   *)

PROCEDURE Split ( REF source : ARRAY OF CHAR;
                      pos    : INTEGER;
                  VAR dest1  : ARRAY OF CHAR;
                  VAR dest2  : ARRAY OF CHAR );
  (* Kopiert source[0]..source[pos-1] nach dest1, Rest nach dest2. *)

PROCEDURE Compare ( REF left, right: ARRAY OF CHAR ): Relation;
  (* Vergleicht 'left' mit 'right'. *)

END FastStrings.
