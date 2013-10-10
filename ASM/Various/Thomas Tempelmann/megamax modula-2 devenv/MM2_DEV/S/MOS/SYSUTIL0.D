DEFINITION MODULE SysUtil0;

FROM SYSTEM IMPORT BYTE, WORD, LONGWORD, ADDRESS;

PROCEDURE ClearVar ( VAR data: ARRAY OF BYTE );
  (* L”scht eine beliebige Variable. Z.B. Records, Arrays. *)

PROCEDURE VarCleared ( REF data: ARRAY OF BYTE ): BOOLEAN;
  (* Liefert TRUE, wenn gesamte Variable nur Nullbytes enth„lt. *)

PROCEDURE VarEqual ( REF data1, data2: ARRAY OF BYTE ): BOOLEAN;
  (* Liefert TRUE, wenn beide Variablen gleich sind. *)

PROCEDURE SwapVar ( VAR data1, data2: ARRAY OF BYTE );
  (*
   * Vertauscht 'data1' und 'data2'. Belegen die Variablen verschieden
   * viele Bytes im Speicher, tritt ein Laufzeitfehler (Overflow) auf.
   *)

PROCEDURE CopyVar ( REF data1: ARRAY OF BYTE; VAR data2: ARRAY OF BYTE; VAR ok: BOOLEAN );
  (*
   * Kopiert 'data1' nach 'data2'. Wenn 'data2' weniger Bytes fažt, als
   * 'data1' grož ist, liefert 'ok' FALSE und es wird nur der passende
   * Bereich kopiert, sonst ist 'ok' TRUE.
   *)

PROCEDURE Peek ( addr: ADDRESS ): CARDINAL;
  (*
   * Liefert den Wert des Bytes an Adresse 'addr'.
   *)

PROCEDURE Poke ( addr: ADDRESS; value: WORD );
  (*
   * Schreibt 'value' MOD 256 in das Byte auf Adresse 'addr'.
   *)

PROCEDURE Byte ( value: WORD ): BYTE;
  (* Konvertiert einen CARDINAL-/INTEGER-Wert in einen BYTE-Wert *)

PROCEDURE Cardinal ( value: BYTE ): CARDINAL;
  (* Konvertiert einen BYTE-Wert in einen CARDINAL-Wert *)

PROCEDURE InByte ( bitNo: CARDINAL; value: BYTE     ): BOOLEAN;
PROCEDURE InWord ( bitNo: CARDINAL; value: WORD     ): BOOLEAN;
PROCEDURE InLong ( bitNo: CARDINAL; value: LONGWORD ): BOOLEAN;
  (* Liefern TRUE, wenn das Bit 'bitNo' in 'value' gesetzt ist. *)

PROCEDURE BIncl ( VAR value: BYTE;     bitNo: CARDINAL );
PROCEDURE WIncl ( VAR value: WORD;     bitNo: CARDINAL );
PROCEDURE LIncl ( VAR value: LONGWORD; bitNo: CARDINAL );
  (* Setzt das Bit 'bitNo' in 'value'. *)

PROCEDURE BExcl ( VAR value: BYTE;     bitNo: CARDINAL );
PROCEDURE WExcl ( VAR value: WORD;     bitNo: CARDINAL );
PROCEDURE LExcl ( VAR value: LONGWORD; bitNo: CARDINAL );
  (* L”scht das Bit 'bitNo' in 'value'. *)

END SysUtil0.
