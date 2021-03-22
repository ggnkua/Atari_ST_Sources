DEFINITION MODULE ArgCV;

(* Wertet keine I/O-Umleitungsangabe (mit '<','>') in der Argumentzeile aus *)

TYPE ArgStr = ARRAY [0..127] OF CHAR;

     PtrArgStr = POINTER TO ArgStr;


PROCEDURE InitArgCV ( VAR ArgC : CARDINAL; VAR ArgV : ARRAY OF PtrArgStr );
  (*
   * 'ArgC' enthÑlt nach dem Aufruf die Anzahl der initialisierten ArgV-Felder.
   * Das 'ArgV'-Feld sollte die Grîûe [0..ErlaubteArgumentAnzahl] haben.
   * 'ArgV[0]' ist immer ein Leerstring, 'ArgV[1]' enthÑlt das erste Argument.
   * Das letzte gÅltige Argument steht demnach in 'ArgV[ArgC-1]'.
   *)

END ArgCV.
