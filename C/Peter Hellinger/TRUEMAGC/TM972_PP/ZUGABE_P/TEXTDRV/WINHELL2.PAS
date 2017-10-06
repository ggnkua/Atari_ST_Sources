PROGRAM WinHello;

USES    M_Types,        (* Typ-definitionen     *)
        M_AES,          (* AES-Interface        *)
        M_Appl,         (* Applikation-Manager  *)
        M_Event,        (* Event-Dispatcher     *)
        M_Textwindows;

VAR FirstWin,
    SecondWin,
    ThirdWin: TEXT;

PROCEDURE OpenWin (VAR t: Text; wname, winfo: STRING; farbe: INTEGER; mn: BOOLEAN;
                   xPos, yPos: INTEGER; Breite, Hoehe: INTEGER; wrap: INTEGER);
VAR x: POINTER;
    f: BITSET;
BEGIN
 f:= [M_AES.MOVE, NAME, CLOSER, FULL, INFO, M_AES.SIZE, SMALLER];
 x:= NIL;
 AssignTextwin (t, SimpleWinHandler, f, [], xPos, yPos, Breite, Hoehe, 0, 0, 0, 0,
                0, farbe, 100, 10, [], wrap, wname, winfo, x);
 SYSTEM.Rewrite (t);
END (*OpenWin*);

VAR name: STRING;

BEGIN
 MouseOn;
 MouseArrow;
 STR (ApplIdent:3, name); name := name + ' <- Applikationsnummer!'#0;
 OpenWin (FirstWin, ' Hello World 1 '#0, name, 1, FALSE, 100, 100, 250, 150, 50);
 OpenWin (SecondWin, ' Hello World 2 '#0, name, 2, FALSE, 400, 300, 200, 100, 50);
 OpenWin (ThirdWin, ' Hello World 3 '#0, name, 3, FALSE, 200, 150, 200, 100, 50);
 REPEAT
  CentralDispatcher;
  WriteLn (FirstWin, 'Hello World');
  WriteLn (SecondWin, 'Hello World');
  WriteLn (ThirdWin, 'Hello World');
 UNTIL WindowsOpen = 0;
 Close (FirstWin);
 Close (SecondWin);
 Close (ThirdWin);
 ApplTerm (0)
END.
