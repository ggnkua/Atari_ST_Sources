DEFINITION MODULE UserBreak;

(*
   Dies Modul dient dazu, Programme durch DrÅcken von Ctrl-C oder
   Ctrl-Enter abzubrechen.
   
   Zur Aktivierung dieser Option muû die exportierte Prozedur
   'EnableBreak', zur Deaktivierung 'DisableBreak' aufgerufen
   werden. 'EnableBreak' liefert TRUE, wenn die Aktivierung wie
   gewÅnscht erfolgte.
   
   Ctrl-C wird erst erkannt, wenn AES-Events (Keyboard, Button
   oder Timer) abgefragt werden, also z.B. bei Benutung der
   Funktionen aus Textwindows oder einem MultiEvent-Aufruf.
   Dann erscheint wie bei einem Laufzeitfehler eine Meldung
   und das Programm kann abgebrochen oder fortgefÅhrt werden.
   
   Ctrl-Enter ist gegenÅber Ctrl-C mit Vorsicht zu benutzen.
   Diese Funktion reagiert sofort. Dies kann u.U. dazu fÅhren,
   daû sich das System danach fehlerhaft verhÑlt.
   Dies passiert dann, wenn Ctrl-Enter zu einem Zeitpunkt
   gedrÅckt wird, in dem Betriebssystemfunktionen ausgefÅhrt
   werden. Deshalb sollte zuerst immer Ctrl-C probiert werden
   und nur, wenn es unbedingt notwendig ist, Ctrl-Enter verwendet
   werden.
   
   Sollte sich das Programm allerdings in einer Endlosschleife
   befinden, die nur aus Modula-Funktionen besteht, oder das
   Programm gerade eine zeitaufwendige Berechnung durchfÅhren,
   kann in der Regel Ctrl-Enter ohne Gefahr benutzt werden.
   
   öbrigens ist das Modul ausschlieûlich in MODULA programmiert.
*)


PROCEDURE EnableBreak () :BOOLEAN;
   (*
    *  Nach Aufruf dieser Routine ist es mîglich, das laufende
    *  Programm zu unterbrechen.
    *)

PROCEDURE DisableBreak;
   (*
    *  Hiernach kann das Programm nicht mehr mit Ctrl-C bzw.
    *  Ctrl-Enter abgebrochen werden. Dies ist auch der
    *  Anfangszustand.
    *)

VAR Break: BOOLEAN;
   (*
    * Wird TRUE, sobald Ctrl-C gedrÅckt wurde.
    *
    * Sobald daraufhin ein Event-Aufruf (z.B. EventMulti) oder eine
    * Ausgabe Åber TextWindows erfolgt, wird das Programm automatisch
    * terminiert.
    * Programme kînnen diese Variable auch selbst abfragen und dann ggf.
    * zurÅck auf FALSE setzen.
    *)

END UserBreak.
