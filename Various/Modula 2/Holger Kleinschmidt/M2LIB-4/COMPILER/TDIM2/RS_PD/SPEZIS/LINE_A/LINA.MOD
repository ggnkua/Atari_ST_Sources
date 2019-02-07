IMPLEMENTATION MODULE LinA;
(* ½ 1991 ROLF SCHRADER. * .. 25.4.91 *)
(*
IMPORT TT,IO;
*)
FROM SYSTEM IMPORT ADDRESS, CODE, REGISTER;

PROCEDURE Init;
 BEGIN CODE (0A000H (*INIT*));
  pVars := REGISTER (8 (* oder 0 *));
  pFonts:= REGISTER (9);
  pVecs := REGISTER (10); END Init;

(*žž*)
BEGIN Init END LinA. Test: *)

CONST LINE = 0A003H;

PROCEDURE LineH (x0, x,y: CARDINAL);
 BEGIN WITH pVars^.P DO X1 := x0; Y1 := y; X2 := x END;
  CODE (LINE +1); END LineH;

PROCEDURE Line (x0,y0, x,y: CARDINAL);
 BEGIN WITH pVars^.P DO X1 := x0; Y1 := y0; X2 := x; Y2 := y END;
  CODE (LINE); END Line;

VAR aVars: ADDRESS; pNPl,pBpSL: POINTER TO CARDINAL;

BEGIN Init;
   aVars := pVars;
   pNPl  := aVars;
   pBpSL := aVars +2;
   pVars^.LstLin := -1;
   LineH (20, 620,100);
   Line  (50,350, 600,50);
   TT.Home; TT.Cr; TT.Cr;
   IO.ws (" # Farb-Ebenen:  "); IO.write (pNPl^);  TT.Cr;
   IO.ws (" # BytesProScan: "); IO.write (pBpSL^); TT.Cr;
   TT.Pause; END LinA.
