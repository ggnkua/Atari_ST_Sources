MODULE ClipTest;
(* ½ 1994 ROLF SCHRADER. * 12.3.94 *)     (* Clip-Test: Alles...Deine Elli.*)
(*$T-,$S-,$A+*)

IMPORT VDI, VDY, GEMDOX;
FROM   VDI  IMPORT GDEV, CURSEX,CURSON;

PROCEDURE Elli;
 BEGIN
   VDI.DrawEllArc (GDEV, 300,200, 270,170, 0,3600);
   VDI.DrawArc    (GDEV, 300,200, 150, 0,3600);
   VDI.Line       (GDEV, 0,0, 639,399);
   END Elli;

VAR    P: VDI.PxyArr;
       i: INTEGER;
BEGIN  VDI.MouseCursor (CURSEX);
       VDI.Asg4 (P, 0,19,639,399);
       VDI.SetClipping (GDEV, P);
       VDI.FillRect (GDEV, P);
   VDI.DrawEllArc (GDEV, 320,210, 270,170, 0,3600);
   VDI.DrawArc    (GDEV, 320,210, 150, 0,3600);
   VDI.Line       (GDEV, 0,20, 639,419);

   FOR i := 20 TO 390 DO VDI.Asg4 (P, 0,i, 639,i);       (* Streifen-weise.*)
       VDI.SetClipping (GDEV, P);
       Elli; END (*i*);

   VDI.SetClippOff (GDEV);
   VDI.MouseCursor (CURSON);
   VDY.Pause;
   GEMDOX.Halt; END ClipTest.
