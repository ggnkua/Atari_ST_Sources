{ This file is ONLY a sample of what a Personal Pascal GEM program will look
  like.  You must first insert your declarations, as shown below, before you
  can compile this file properly.  If you compile it with no changes, you will
  get syntax errors! }

PROGRAM name ;

  CONST
    {$I GEMCONST.PAS}
    (* ... your CONSTants ... *)

  TYPE
    {$I gemtype.pas}    { note that case doesn't matter }
    (* ... your TYPEs ... *)

  VAR
    (* ... your VARiables ... *)

  {$I gemsubs}          { and that ".PAS" is default }
  (* ... your PROCEDUREs, FUNCTIONs, etc. ... *)

  BEGIN
    IF Init_Gem >= 0 THEN
      BEGIN
        (* ... your main program ... *)
        Exit_Gem ;
      END ;
  END.
