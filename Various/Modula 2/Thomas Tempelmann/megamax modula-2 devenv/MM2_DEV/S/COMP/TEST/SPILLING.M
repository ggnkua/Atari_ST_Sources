MODULE T;

(*
 * Testet Spilling-Verhalten
 *)

PROCEDURE p (d: ARRAY OF CARDINAL; c: CARDINAL);
  VAR w: RECORD a,b: CARDINAL END;
  VAR w2: RECORD a2,b2: CARDINAL END;
  BEGIN
    WITH w DO
      WITH w2 DO
        p (d, a) (* dies mag er z.Zt. nicht *)
      END
    END
  END p;

END T.
