MODULE Update;
(* 4.2.96 RS *)
(*$S-,$T-,$Q+*)

IMPORT SYSTEM, AEB;

CONST
 A= "Funktioniert der File-Sel. auch, wenn das Update-Semaphor gesetzt ist?";
 B= "Was macht das *OS, wenn das Update-Semaphor nicht zurÅckgesetzt wird ?";
    (* GrundsÑtzlich ein Programm-Fehler - der *)
    (* aber Desktop/Shell kalt lassen sollte...*)

PROCEDURE WindUpd  (s: INTEGER);
 BEGIN AEB.Ii[0] := s; s := AEB.CallAES (107, 1,1,0,0) END WindUpd;

PROCEDURE FSelInput (VAR p, s: ARRAY OF CHAR): INTEGER;
 BEGIN AEB.Ia[0] := SYSTEM.ADR (p); AEB.Ia[1] := SYSTEM.ADR (s);
   i:= AEB.CallAES (90, 0,2,2,0);
   RETURN AEB.Oi[1]; END FSelInput;

VAR   InSel,InPath: ARRAY [0..64] OF CHAR;
      i: INTEGER;
BEGIN i := AEB.ApplInit ();
      InSel := ""; InPath := "";
   WindUpd (AEB.UPDATE);
   AEB.DeskDisplay (0,0,640,18, 0, A);
   i := FSelInput (InPath, InSel);
   AEB.DeskDisplay (0,0,640,18, 0, B);
   i := AEB.EventKeybd ();
(* _kein_ WindUpd (0) ! *)
   AEB.ApplExit; END Update.
