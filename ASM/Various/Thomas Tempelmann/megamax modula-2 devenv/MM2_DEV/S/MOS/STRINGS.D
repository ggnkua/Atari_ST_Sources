DEFINITION MODULE Strings;


CONST StringSize = 80;  (* Max. LÑnge einer Var. vom Typ 'String' *)
      MaxChars   = StringSize-1;

      End = 0C;         (* String-Terminator bei nicht-vollen Strings *)


TYPE  String = ARRAY [0..MaxChars] OF CHAR;

      Relation = (less, equal, greater);

(*
 * Der Paramter 'success', der bei vielen Funktionen auftritt, liefert
 * immer nach einem Funktionsaufruf, ob ein öberlauf eines Strings bei
 * der Operation aufgetreten ist oder ob ein Parameter ungÅltig war.
 * Nur wenn dies nicht eintritt, ist 'success' nach dem Aufruf TRUE.
 * Es bietet sich an, in jedem Modul eine globale Variable (z.B 'ok')
 * als BOOLEAN zu deklarieren, die dann Åberall dort als 'success'-
 * Parameter Åbergeben wird, wo diese Information nicht benîtigt wird.
 *
 * Die Beispiele zeigen, was passiert, wenn öberlÑufe auftreten oder
 * Argumente auûerhalb des gÅltigen Bereichs liegen.
 *
 * Es werden also keine Laufzeitfehler ausgelîst.
 *
 *
 * FÅr die ganz aufmerksamen Mitdenker:
 *
 *   Die Funktionen kommen trotz der REF-Parameter damit klar, wenn
 * einer der 'source'-Argumente bei Aufruf identisch mit der Ziel-
 * Variable ist.
 *   Beispiel:
 *     Concat (a, a, a, success)
 *   macht keine Fehler, weil trotz der REF-öbergabe, bei der 'a' nicht
 *   kopiert wird, sondern nur seine Adr. Åbergeben wird, die Funktion
 *   dafÅr sorgt, daû beim Zusammensetzen von 'a' keine öberschneidungen
 *   intern auftreten.
 *)

PROCEDURE Pos ( REF pattern, source: ARRAY OF CHAR; start: INTEGER ): INTEGER;
  (* Sucht ab der Position 'start' den String 'pattern' in 'source'.
   * Liefert -1, wenn nicht gefunden, sonst die Position. *)

PROCEDURE PosLen ( REF pattern, source: ARRAY OF CHAR; start: INTEGER ): CARDINAL;
  (* Wie 'Pos', liefert aber 'Length (source)', wenn nicht gefunden. *)

PROCEDURE StrEqual ( REF left, right: ARRAY OF CHAR ): BOOLEAN;
  (* Liefert TRUE, wenn die beiden Strings gleich sind. *)

PROCEDURE Compare ( REF left, right: ARRAY OF CHAR ): Relation;
  (* Vergleicht zwei Strings. Liefert je nach Ergebnis 'equal' (gleich),
   * 'less' (left<right) oder 'greater' (left>right). Der Vergleich wird
   * auf der Basis der Ordnungswerte der einzelnen Zeichen durchgefÅhrt,
   * jedoch werden alle Umlaute direkt hinter den zugehîrigen Vokalen
   * eingeordnet. Beispiele:
   *  Compare ( 'a', 'b' )     = less
   *  Compare ( 'b', 'bb' )    = less
   *  Compare ( ' 1', '00' )   = less
   *  Compare ( 'o', 'î' )     = less
   *  Compare ( 'p', 'î' )     = greater
   *  Compare ( 'î', 'oa' )    = less
   *  Compare ( 'î', 'oe' )    = less
   *)

(*
 * Die Parameter der folgenden Funktionen sind nach folgender Regel angeordnet:
 *  Zuerst Source-String(s), dann evtl. Positions-/LÑngenangaben, dann evtl.
 *  Destination-String(s), zuletzt ein 'success'-Parameter, sofern nîtig.
 *)

PROCEDURE Assign ( REF source : ARRAY OF CHAR;
                   VAR dest   : ARRAY OF CHAR;
                   VAR success: BOOLEAN        );
  (*
   * Weist 'source' auf 'dest' zu.
   * Beispiel:
   *   VAR dest: ARRAY [0..2] OF CHAR;
   *   Assign ( 'abcd', dest, success ) -> dest = 'abc', success = FALSE
   *)

PROCEDURE Delete ( VAR str    : ARRAY OF CHAR;
                       pos    : INTEGER;
                       len    : INTEGER;
                   VAR success: BOOLEAN        );
  (*
   * Lîscht in 'str' ab Position 'pos' 'len' Zeichen.
   * Beispiel:
   *   str:= '123456';
   *   Delete ( str, 2, 1, success ) -> str = '12456', success = TRUE
   *   Delete ( str, 2, 6, success ) -> str = '12',    success = FALSE
   *   Delete ( str,-1, 2, success ) -> str = '23456', success = FALSE
   *   Delete ( str, 5, 0, success ) -> str = '123456',success = TRUE
   *   Delete ( str, 8, 0, success ) -> str = '123456',success = FALSE
   *)


PROCEDURE Append ( REF source : ARRAY OF CHAR;
                   VAR dest   : ARRAY OF CHAR;
                   VAR success: BOOLEAN        );

  (*
   * FÅgt 'source' an 'dest' an.
   * Beispiel:
   *   VAR dest: ARRAY [0..4] OF CHAR;
   *   dest:= 'abc';
   *   Append ( 'def', dest, success ) -> dest = 'abcde', success = FALSE
   *)

PROCEDURE Insert ( REF source : ARRAY OF CHAR;
                       pos    : INTEGER;
                   VAR dest   : ARRAY OF CHAR;
                   VAR success: BOOLEAN        );
  (*
   * FÅgt 'source' an Position 'pos' in 'dest' ein.
   * Ist 'pos' < 0, wird nur hinterer Teil v. 'source' eingefÅgt, 'success'
   * ist dann immer FALSE.
   * Von 'source' wird nur soviel eingefÅgt, daû nichts von 'dest' verloren
   * geht.
   * 'success':= ( Length(source)=0 ) OR ( 'source' wurde ohne Verlust eingefÅgt )
   * Beispiel:
   *   VAR dest: ARRAY [0..9] OF CHAR;
   *   dest:= '123';
   *   Insert ( 'abcde', -2, dest, success ) -> dest = 'cde123', success=FALSE
   *)

PROCEDURE Copy ( REF source : ARRAY OF CHAR;
                     pos    : INTEGER;
                     len    : INTEGER;
                 VAR dest   : ARRAY OF CHAR;
                 VAR success: BOOLEAN        );
  (*
   * Kopiert ab Position 'pos' 'len' Zeichen aus 'source' nach 'dest'.
   * Beispiel:
   *   VAR dest: ARRAY [0..3] OF CHAR;
   *   source:= '123';
   *   Copy ( source, -2, 2, dest, success ) -> dest = '',  success=FALSE
   *   Copy ( source,  2, 0, dest, success ) -> dest = '',  success=TRUE
   *   Copy ( source,  2, 2, dest, success ) -> dest = '3', success=FALSE
   *)


PROCEDURE Concat ( REF source1: ARRAY OF CHAR;
                   REF source2: ARRAY OF CHAR;
                   VAR dest   : ARRAY OF CHAR;
                   VAR success: BOOLEAN        );
  (*
   * FÅgt die Strings 'source1' und 'source2' in 'dest' zusammen.
   * Beispiel:
   *   VAR dest: ARRAY [0..2] OF CHAR;
   *   Concat ( '1234', '56', dest, success ) -> dest = '123', success=FALSE
   *   Concat ( '12', '34, dest, success )    -> dest = '123', success=FALSE
   *)

PROCEDURE Split ( REF source : ARRAY OF CHAR;
                      pos    : INTEGER;
                  VAR dest1  : ARRAY OF CHAR;
                  VAR dest2  : ARRAY OF CHAR;
                  VAR success: BOOLEAN );
  (* Kopiert source[0]..source[pos-1] nach dest1, Rest nach dest2.
   * 'success' liefert FALSE, wenn 'pos'>Length(source) oder wenn die 'dest'-
   * Strings zu klein sind. *)

PROCEDURE Chr ( REF s: ARRAY OF CHAR; n: CARDINAL ): CHAR;
  (*
   * Liefert das Zeichen an der Position 'n' aus dem String 's'.
   * Ist der String kÅrzer als 'n', wird der Wert 0C geliefert.
   *)

PROCEDURE Upper ( VAR dest: ARRAY OF CHAR );
  (* Konvertiert alle Buchstaben in Groûbuchstaben.             *)
  (* Es werden auch die internationalen Umlaute berÅcksichtigt! *)

PROCEDURE Lower ( VAR dest: ARRAY OF CHAR );
  (* Konvertiert alle Buchstaben in Kleinbuchstaben.            *)
  (* Es werden auch die internationalen Umlaute berÅcksichtigt! *)

PROCEDURE DelBlanks ( VAR dest: ARRAY OF CHAR );
  (* Lîscht alle Leerzeichen und TAB-Zeichen. *)

PROCEDURE DelLeadingBlanks ( VAR s: ARRAY OF CHAR );
  (* Lîscht fÅhrende Leerzeichen und TABs *)

PROCEDURE DelTrailingBlanks ( VAR s: ARRAY OF CHAR );
  (* Lîscht anhÑngende Leerzeichen und TABs *)

PROCEDURE EatSpaces ( VAR dest: ARRAY OF CHAR );
  (* Lîscht alle Leerzeichen. *)

PROCEDURE Space ( n: INTEGER ): String;
  (*
   * Liefert einen String mit 'n' Leerzeichen.
   * 'n' darf nicht grîûer als 80 sein.
   *)

PROCEDURE Length ( REF str: ARRAY OF CHAR ): CARDINAL;
  (*
   * Relikt aus alten Tagen.
   *
   * Kann zwar verwendet werden, aber optimaler, weil schneller, ist
   * die neue Standard-Funktion LENGTH.
   *)

PROCEDURE Empty ( REF str: ARRAY OF CHAR ): BOOLEAN;
  (*
   * Relikt aus alten Tagen.
   *
   * Kann zwar verwendet werden, aber optimaler, weil schneller, ist
   * der Vergleich der ersten Feldelements mit dem Terminierungs-Zeichen:
   *   Statt
   *     IF Empty (stringVar) THEN ...
   *   schreiben Sie nun
   *     IF stringVar[0] = '' THEN ...
   *)

END Strings.
