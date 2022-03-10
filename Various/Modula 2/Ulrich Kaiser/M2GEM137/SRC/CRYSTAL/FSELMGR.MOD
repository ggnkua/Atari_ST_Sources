IMPLEMENTATION MODULE FSelMgr;

(*
AES File Selector Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES    IMPORT IntOut,Addr,crystal,Version;
FROM SYSTEM IMPORT ADR;
AES_SYSTEM_IMPORT

#if Seimet
CONST F90 = 05A000202H;
      F91 = 05B000203H;
#endif

PROCEDURE FSelInput(VAR Path  : ARRAY OF CHAR;
                    VAR Name  : ARRAY OF CHAR;
                    VAR Label : ARRAY OF CHAR): BOOLEAN;

BEGIN
  Addr[0]:= ADR(Path);
  Addr[1]:= ADR(Name);
#if ST
#if ABC
#warning ...taking care of ABC-GEM
  IF (Version() < 0140H) OR (Version() = 0220H) THEN
#else
  IF (Version() < 0140H) THEN
#endif
    crystal(90,0,2,2);
  ELSE
    Addr[2]:= ADR(Label);
    crystal(91,0,2,3);
  END;
#else
  crystal(90,0,2,2);
#endif
  RETURN (IntOut[1] # 0) AND (IntOut[0] # 0);
END FSelInput;

END FSelMgr.
