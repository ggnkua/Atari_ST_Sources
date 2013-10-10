DEFINITION MODULE TextQueues;

TYPE    TextQueue;

(*
 * Lesen aus der Schlange
 *)

PROCEDURE Reset (q: TextQueue);

PROCEDURE GetNext (q: TextQueue; VAR str: ARRAY OF CHAR): BOOLEAN;

(*
 * Schreiben in die Schlange
 *)

PROCEDURE Clear (q: TextQueue);

PROCEDURE Append (q: TextQueue; REF str: ARRAY OF CHAR; VAR ok: BOOLEAN);

END TextQueues.
