MODULE TopEsc;
(* Ω 1996 by ROLF SCHRADER. * 16.2.96 *)
(*
   Wem es immer schon lÑstig war, die Hand von der Maus nehmen zu mÅssen,
   bloû um per ESC das Verzeichnis im obersten Fenster zu aktualisieren,
   der findet hier den fehlenden Menue-Eintrag.
*)
(*$S-,$T-,$Q+*)
IMPORT AEB, AEZ;

PROCEDURE RunAccPrg (VAR AccMenu: ARRAY OF CHAR; Job: PROC);
 VAR   MenuId: INTEGER;  M: AEB.MsgPipeR;
 BEGIN IF ~ AEB.ApplIsAcc ()  THEN Job; RETURN END;
       MenuId := AEB.MenuRegist (ApId, AccMenu);
  LOOP AEB.EventMessage (M);                        (* ACC-typische Ananta.*)
    IF (M.Type = AEB.ACCOPEN) THEN Job END; END (*L*); END RunAccPrg;

VAR   ApId: INTEGER;
BEGIN ApId := AEB.ApplInit ();
      RunAccPrg ("  Send Esc-Key ", AEZ.SendEsc);
      AEB.ApplExit;  END TopEsc.
