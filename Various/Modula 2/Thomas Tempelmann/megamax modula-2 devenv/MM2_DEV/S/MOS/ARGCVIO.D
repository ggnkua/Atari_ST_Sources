DEFINITION MODULE ArgCVIO;

(* Wertet I/O-Umleitungsangabe (mit '<','>') automatisch *)
(* aus, importiert dazu das 'InOut' Modul !              *)

TYPE ArgStr = ARRAY [0..127] OF CHAR;

     PtrArgStr = POINTER TO ArgStr;


PROCEDURE InitArgCV ( VAR ArgC : CARDINAL; VAR ArgV : ARRAY OF PtrArgStr );
  (*
   * Die mîgliche I/O-Umleitung wird erst bei Aufruf dieser Prozedur durch-
   * gefÅhrt.
   *
   * 'ArgC' enthÑlt nach dem Aufruf die Anzahl der initialisierten ArgV-Felder.
   * Das 'ArgV'-Feld sollte die Grîûe [0..ErlaubteArgumentAnzahl] haben.
   * 'ArgV[0]' ist immer ein Leerstring, 'ArgV[1]' enthÑlt das erste Argument.
   * Das letzte gÅltige Argument steht demnach in 'ArgV[ArgC-1]'.
   *)

END ArgCVIO.
