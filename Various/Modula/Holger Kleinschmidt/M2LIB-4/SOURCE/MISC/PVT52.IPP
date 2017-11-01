IMPLEMENTATION MODULE pVT52;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* Sep-91 / 04-Feb-95, Holger Kleinschmidt                                   *)
(*****************************************************************************)

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS;

FROM types IMPORT
(* CONST*) ESC;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  Write : WriteProc;
  Par   : ADDRESS;
  WRITE : BOOLEAN;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE esc ((* EIN/ -- *) function : CHAR );
BEGIN
 IF WRITE THEN
   Write(Par, ESC);
   Write(Par, function);
 END;
END esc;

(*===========================================================================*)

PROCEDURE AssignWrite ((* EIN/ -- *) write : WriteProc;
                       (* EIN/ -- *) par   : ADDRESS   );

BEGIN
 Write := write;
 Par   := par;
 WRITE := TRUE;
END AssignWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE UnAssignWrite;
BEGIN
 WRITE := FALSE;
END UnAssignWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE GetWrite ((* -- /AUS *) VAR write : WriteProc;
                    (* -- /AUS *) VAR par   : ADDRESS   );

BEGIN
 write := Write;
 par   := Par;
END GetWrite;

(*---------------------------------------------------------------------------*)

PROCEDURE CursorUp;
BEGIN
 esc('A');
END CursorUp;

(*---------------------------------------------------------------------------*)

PROCEDURE CursorUpScroll;
BEGIN
 esc('I');
END CursorUpScroll;

(*---------------------------------------------------------------------------*)

PROCEDURE CursorDown;
BEGIN
 esc('B');
END CursorDown;

(*---------------------------------------------------------------------------*)

PROCEDURE CursorRight;
BEGIN
 esc('C');
END CursorRight;

(*---------------------------------------------------------------------------*)

PROCEDURE CursorLeft;
BEGIN
 esc('D');
END CursorLeft;

(*---------------------------------------------------------------------------*)

PROCEDURE CursorHome;
BEGIN
 esc('H');
END CursorHome;

(*---------------------------------------------------------------------------*)

PROCEDURE ClearScreen;
BEGIN
 esc('E');
END ClearScreen;

(*---------------------------------------------------------------------------*)

PROCEDURE EraseToEndOfPage;
BEGIN
 esc('J');
END EraseToEndOfPage;

(*---------------------------------------------------------------------------*)

PROCEDURE EraseToEndOfLine;
BEGIN
 esc('K');
END EraseToEndOfLine;

(*---------------------------------------------------------------------------*)

PROCEDURE EraseLine;
BEGIN
 esc('l');
END EraseLine;

(*---------------------------------------------------------------------------*)

PROCEDURE EraseToStartOfPage;
BEGIN
 esc('d');
END EraseToStartOfPage;

(*---------------------------------------------------------------------------*)

PROCEDURE EraseToStartOfLine;
BEGIN
 esc('o');
END EraseToStartOfLine;

(*---------------------------------------------------------------------------*)

PROCEDURE InsertLine;
BEGIN
 esc('L');
END InsertLine;

(*---------------------------------------------------------------------------*)

PROCEDURE DeleteLine;
BEGIN
 esc('M');
END DeleteLine;

(*---------------------------------------------------------------------------*)

PROCEDURE GotoXY ((* EIN/ -- *) col  : CARDINAL;
                  (* EIN/ -- *) line : CARDINAL );

BEGIN
 IF WRITE THEN
   esc('Y');
   Write(Par, CHR(32 + line));
   Write(Par, CHR(32 + col));
 END;
END GotoXY;

(*---------------------------------------------------------------------------*)

PROCEDURE SaveCursorPos;
BEGIN
 esc('j');
END SaveCursorPos;

(*---------------------------------------------------------------------------*)

PROCEDURE RestoreCursorPos;
BEGIN
 esc('k');
END RestoreCursorPos;

(*---------------------------------------------------------------------------*)

PROCEDURE AutoWrapOn;
BEGIN
 esc('v');
END AutoWrapOn;

(*---------------------------------------------------------------------------*)

PROCEDURE AutoWrapOff;
BEGIN
 esc('w');
END AutoWrapOff;

(*---------------------------------------------------------------------------*)

PROCEDURE InverseOn;
BEGIN
 esc('p');
END InverseOn;

(*---------------------------------------------------------------------------*)

PROCEDURE InverseOff;
BEGIN
 esc('q');
END InverseOff;

(*---------------------------------------------------------------------------*)

PROCEDURE SetForegroundColor ((* EIN/ -- *) col : CARDINAL );
BEGIN
 IF WRITE THEN
   esc('b');
   Write(Par, CHR(30H + (col MOD 16)));
 END;
END SetForegroundColor;


(*---------------------------------------------------------------------------*)

PROCEDURE SetBackgroundColor ((* EIN/ -- *) col : CARDINAL );
BEGIN
 IF WRITE THEN
   esc('c');
   Write(Par, CHR(30H + (col MOD 16)));
 END;
END SetBackgroundColor;

(*===========================================================================*)

BEGIN (* pVT52 *)
 UnAssignWrite;
END pVT52.

