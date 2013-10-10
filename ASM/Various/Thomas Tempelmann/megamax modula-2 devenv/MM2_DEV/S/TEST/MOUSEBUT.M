
(*
stuerzt ab, sobald eine Maustaste gedrueckt wird. Es erscheint noch eine Box:
*)

MODULE VInError;
(* VDI-Inputs Error: Wird eine Maustaste gedrueckt, stuerzt der Rechner ab *)
FROM GEMEnv IMPORT InitGem, RC, DeviceHandle;
FROM GEMGlobals IMPORT MouseButton, MButtonSet;
FROM MOSGlobals IMPORT MemArea, MEM;
FROM VDIInputs  IMPORT ButChgVecCarrier, InstallButChgProc, RemoveButChgProc;
FROM SYSTEM IMPORT ASSEMBLER;
FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, WriteCard, Read;

VAR
  handle : ButChgVecCarrier;
  stack  : ARRAY [1..2048] OF CARDINAL;  (* 4 KByte Stack *)
  count  : LONGCARD;
  ch: CHAR;
  pressed: CARDINAL;
  fl, ok: BOOLEAN;
  dev: DeviceHandle;
  
  PROCEDURE WasClicked( VAR mbut: MButtonSet ) : BOOLEAN;
  BEGIN
    INC (pressed);
    fl:= ~fl;
    RETURN fl
  END WasClicked;


BEGIN
  (*
  InitGem (RC, dev, ok);
  *)
  fl:= FALSE;
  pressed:= 0;
  InstallButChgProc( handle, WasClicked, MEM(stack) );
  FOR count:=1 TO 5000000 DO (* nix *) END;
  RemoveButChgProc(handle);
  WriteString ("Maustaste wurde ");
  WriteCard (pressed, 0);
  WriteString (" mal gedrÅckt/losgelassen.");
  Read (ch);
END VInError.
