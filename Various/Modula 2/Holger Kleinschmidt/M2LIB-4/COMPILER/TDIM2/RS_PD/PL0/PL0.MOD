MODULE PL0; (* Modell-Compiler nach N.Wirth: "Compilerbau", 1986 Stuttgart.*)
            (* Korrigierte Fassung aus PD.334, an GEM angepažt & erweitert.*)
(* ½ 1995-96 ROLF SCHRADER.                              * 9.2.95 ~ 1.5.95 *)
(*$S-,$T-,$Q+*)

IMPORT AEI,(*ž AEB, EveMan,*) EventDispatcher, CleanUp, Mus, FSel, Aux, BIOX;

FROM  Terminal       IMPORT StatusProc, DoStatus, DoRead, ReadAgain;
FROM  FileSystem     IMPORT Lookup, Response, Close;
FROM  TextWindows    IMPORT Window, tKey, Invert, SetCaret, OpenTextWindow,
                  AssignFont, Write, WriteLn, WriteString, CloseTextWindow;
FROM  PL0Scanner     IMPORT OpenScanWindow, InitScanner,source, CloseScanner;
FROM  PL0Parser      IMPORT OpenParsWindow, Parse, noerr,  EndParser;
FROM  PL0Generator   IMPORT OpenCodeWindow, InitGenerator, EndGenerator;
FROM  PL0Interpreter IMPORT OpenUserWindow, Interpret, EndInterpreter;

CONST NL = 64; ESC = 27; BS = 10c; CC = 2E03H; CTL = 2; LOK = 4; SEL = 100H;
      WINTITLE = " PL0-DIALOG (quit by ESC, step by LOCK, abort by ^C) ";
      SELTITLE = " Choose PL0-Prg.-File: ";

VAR   eK:   INTEGER;
      win:  Window;
      PrgF: ARRAY [0..NL] OF CHAR;
(*ž*) Pipe: ARRAY [0..07] OF INTEGER;
      oSt:  StatusProc;
(*   pSens: POINTER TO AEB.EvSensor; *)

PROCEDURE eRead (VAR ch: CHAR);
 BEGIN eK := 0;
   REPEAT EventDispatcher.DispatchEvents (*ž EveMan.yield *) UNTIL (eK # 0);
   IF (eK = CC) THEN eK := ESC; CleanUp.ModTerm;
   ELSE  ch := CHAR (eK) END; END eRead;

PROCEDURE Pause (): BOOLEAN;
   VAR ks: BITSET;
 BEGIN REPEAT ks := BIOX.KBShiftS ();
          IF (ks * {CTL,LOK} # { }) THEN ReadAgain; RETURN TRUE END;
       UNTIL (ks = { });
   RETURN oSt (); END Pause;

PROCEDURE Exit;
 BEGIN CloseScanner; EndParser; EndGenerator; EndInterpreter;
       CloseTextWindow (win); END Exit;

PROCEDURE AccClose;
 BEGIN IF (Pipe[0] = 41) (*ž (pSens^.Msg.Type = AEB.ACCLOSE) *) THEN
          eK := ESC; tKey := CC END; END AccClose;
(*ž
PROCEDURE KeyPress; BEGIN eK := pSens^.Ret.KeyC END KeyPress;
*)
PROCEDURE Init;
 BEGIN (*ž pSens := Aux.AD (EveMan.Sens);
       EveMan.Install (AccClose, AEB.MSG);
       EveMan.Install (KeyPress, AEB.KEY);
ž*)    IF (0 = EventDispatcher.InstallEventMessage  (AccClose,Aux.Adr(Pipe)))
       OR (0 = EventDispatcher.InstallEventKeyboard (Aux.NOACT, eK))
       THEN HALT END;
       CleanUp.Install (Exit);
       FSel.Accredit (PrgF, "*.PL0","", SELTITLE);
   DoRead := eRead;
       (* With this substitution, the Terminal.BusyRead in PL0Scanner will *)
       (* not function properly anymore ('cause it's polling contradicts   *)
       (* the event-driven paradigma requested by the AES); so, to provide *)
       (* a stepping mode, we also substitute Terminal's input state proc. *)
   oSt := DoStatus;
   DoStatus := Pause;
   END Init;

PROCEDURE Select;
 BEGIN (*ž IF (pSens^.Ret.Clix # 2) THEN RETURN END; *)
   eK := SEL; END Select;

PROCEDURE readFileName;
 BEGIN Mus.Off; eK:= FSel.ExInput (PrgF);
       Mus.On;  WriteString (win,  PrgF); END readFileName;

(* --- *)

PROCEDURE ReadFileName;
   VAR   ch: CHAR; i: CARDINAL; (*ž*) bId, d: INTEGER;
   CONST NC = Aux.CS {'a'..'z', 'A'..'Z', '0'..'9', '_','.',':','\', BS};
   PROCEDURE wt; BEGIN Write (win, ch) END wt;
 BEGIN (*ž EveMan.Install (Select, AEB.BTN); *)
(*ž*)  bId := EventDispatcher.InstallEventButton (Select, 2,1,1,d,d,d,d,d);
       eRead (ch); i := 0;
(*ž*)  EventDispatcher.RemoveEvent (bId);
(*ž    EveMan.Remove  (Select); *)
       IF (eK = SEL) THEN readFileName; RETURN END;
   WHILE  (ch IN NC) DO
       IF (ch #  BS) THEN IF (i< NL) THEN wt; PrgF[i] := ch; INC (i) END;
       ELSIF (i > 0) THEN wt; Write (win, ' '); wt; DEC (i) END;
       eRead (ch); END;
   IF (1 < i) & (i < NL) & (PrgF[i-1] = ".") THEN
       PrgF[i] := "P"; INC (i);
       PrgF[i] := "L"; INC (i);
       PrgF[i] := "0"; INC (i);
       WriteString (win, "PL0"); END;
   PrgF[i] := 0c;
   END ReadFileName;

PROCEDURE pl0;
 BEGIN OpenTextWindow (win, {0, 6,7   }, 007,320, 626,075, WINTITLE);
       OpenScanWindow;
       OpenParsWindow;
       OpenCodeWindow;
       OpenUserWindow;
       AssignFont  (win, 2, 09);
  LOOP WriteString (win, " In > ");
       SetCaret (win, TRUE);
       Invert (win, TRUE);
       ReadFileName;
       Invert (win, FALSE);
    IF (CHAR(eK) = CHR(ESC)) THEN EXIT END;
    Lookup (source, PrgF, FALSE);
    IF (source.res = done) THEN
       InitScanner;
       InitGenerator;
       WriteString (win, "  parsing,");
       Parse;
       Close (source);
       IF ~ noerr THEN WriteString (win, " is incorrect!");
       ELSE WriteString (win, " interpreting.");
            SetCaret (win, FALSE);
            Interpret; END;
    ELSE WriteString (win, " not found.") END;
    IF (tKey = CC) THEN EXIT END;
    WriteLn (win); END (*L*);
  Exit; END pl0;

BEGIN Init; AEI.RunAccPrg ("  PL0 ", pl0) END PL0.
