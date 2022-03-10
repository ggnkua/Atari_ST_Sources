
(*$P-*)
PROCEDURE LENGTHEN (real: REAL);         (* 32 bit Real -> 64 bit LongReal.*)
 BEGIN  (* Offset of result: PMARK *)
   CODE ( 04E56H, 00000H, 048E7H, 0E000H, 0202EH, 00008H, 0E398H, 02400H,
          00280H, 000FFH, 0FFFFH, 00282H, 0FF00H, 00000H, 06612H, 07000H,
          07200H, 048EEH, 00003H, 00008H, 04CDFH, 00007H, 04E5EH, RTS,
          0E68AH, 0E288H, 0E292H, 00682H, 03800H, 00000H, 02200H, 0E688H,
          0E699H, 00281H, 0E000H, 00000H, 08082H, 060D6H) END LENGTHEN; 
                          (* ^ Bug entfernt: statt 07000H .    13.10.91 RS *)
                          (* Verlor das drittletzte Bit! *)

(* Bem.: Das im Zusammenhang mit LENGTHEN zu beobachtende arithmetische
         Aliasing ist eine Konsequenz der Verl„ngerungs-Methode!
         (Hat mit dem Bug nichts zu tun!)
*)

(*$P-*)
PROCEDURE SHORTEN (longreal: LONGREAL);  (* 64 bit LongReal -> 32 bit Real.*)
 BEGIN  (* Offset of result: PMARK +4 *)
   CODE ( 04E56H, 00000H, 048E7H, 0F000H, 04CEEH, 00003H, 00008H, 04840H,
          03400H, 00242H, 07FF0H, 06762H, 00442H, 03800H, 06B00H, 0005CH,
          00C42H, 00FFFH, 06E00H, 00058H, 0E94AH, 0760FH, 00700H, 06704H,
          008C2H, 00000H, 00240H, 0000FH, 008C0H, 00004H, 04840H, 00681H,
          01000H, 00000H, 06412H, 05280H, 07614H, 00700H, 0660AH, 0E288H,
          (* ^ statt 00010H (Rundung in Bit 28 statt 20) *)
          0E291H, 00642H, 00100H, 06526H, 0E788H, 0E799H, 00201H, 00007H,
          08001H, 04840H, 00880H, 00007H, 0E25AH, 08042H, 04840H, 02D40H,
          0000CH, 04CDFH, 0000FH, 04E5EH, 04E75H, 07000H, 060F0H, 07004H);
   HALTX;                                            (* statt 07005H ^. RS *)
   CODE (UNLK, RTS); END SHORTEN;                                    (* RS *)
