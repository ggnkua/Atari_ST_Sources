DEFINITION MODULE Block;

(*
 *  Schnelle Lîsch- und Kopierfunktionen fÅr groûe Datenbereiche (>50 Bytes).
 *
 *  SelbstverstÑndlich sind die Funktionen auch f. kleinere Bereiche (auch
 *  Null Bytes) geeignet, jedoch sind sie fÅr grîûere Bereiche optimiert.
 *  Auch sind ungerade Adressen und LÑngen erlaubt.
 *
 *  --------------------------------------------------------------------------
 *  Autoren: Wolfgang Keller   (W.K)
 *           Dieter   Hametner (D.H)
 *
 *  Erstellt: 23.08.89                  System: MEGAMAX Modula-2 V1.1
 *)

FROM SYSTEM IMPORT ADDRESS;

PROCEDURE Copy (from: ADDRESS; n: LONGCARD; to: ADDRESS);
        (*
         *  Kopiert von 'from' ab 'n' Bytes nach 'to'.
         *  Auf öberlappungen wird RÅcksicht genommen.
         *)

PROCEDURE Clear (from: ADDRESS; n: LONGCARD);
        (*
         *  Lîscht ab 'from' 'n' Bytes.
         *)

END Block.
