                                         (* Chapter 3 - Program 5 *)
MODULE BoolMath;

VAR IsIt, WillIt, What : BOOLEAN;
    A, B, C            : INTEGER;

BEGIN

   A := 22;        (* Assign some values to work with *)
   B := 12;
   C := -12;

   IsIt := A = 22;     (* TRUE    - equal to                    *)
   IsIt := A = 23;     (* FALSE   - equal to                    *)
   WillIt := A > B;    (* TRUE    - greater than                *)
   WillIt := A < B;    (* FALSE   - less than                   *)
   What := WillIt;     (* FALSE   - assignment                  *)
   IsIt := B <= 12;    (* TRUE    - less than or equal          *)
   IsIt := B >= 4;     (* TRUE    - greater than or equal       *)
   IsIt := A # B;      (* FALSE   - not equal                   *)
   IsIt := A <> B;     (* TRUE    - not equal                   *)

   IsIt := TRUE;
   What := FALSE;
   WillIt := IsIt AND What;      (* FALSE because What is FALSE *)
   WillIt := IsIt AND NOT What;  (* TRUE                        *)
   WillIt := IsIt OR What;       (* TRUE because one is TRUE    *)
   WillIt := NOT IsIt OR What;   (* FALSE                       *)
   IsIt := (A = B) OR (B = C) OR (A = 22);
   IsIt := ((A < B) AND (B < C)) OR NOT (B > C);

   (* We have not studied a way to print out representations of *)
   (* BOOLEAN variables so it will have to wait.                *)

END BoolMath.
