MODULE MYSTART;

IMPORT GEMEnv, AESMisc;

VAR handle: GEMEnv.DeviceHandle;
    ok: BOOLEAN;

BEGIN
  ASSEMBLER
        PEA     r(PC)
        MOVE    #38,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        BRA     cont
      r CLR     $446
        RTS
      cont
  END;
  GEMEnv.InitGem (GEMEnv.RC, handle, ok);
  IF NOT ok THEN HALT END;
  AESMisc.ShellWrite (TRUE, AESMisc.graphicPrgm, 'STARTTOS.PRG', '');
END MYSTART.

