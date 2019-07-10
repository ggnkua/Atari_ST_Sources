MODULE HDWait;                     (* for bootsector *)
FROM SYSTEM IMPORT BYTE, WORD, LONGWORD;
FROM HDAus    IMPORT ParkHardDisk;
FROM XBIOS    IMPORT SuperExec;
FROM ConInOut IMPORT ConInWait;
FROM GEMDOS   IMPORT ConWS;

VAR ControllerAccessReg [0FF8604H]: WORD;
    DMAModeReg          [0FF8606H]: WORD;
    DMACommandRegs [0FF8604H]: LONGWORD; (* Controller Access & Mode Reg. *)
    flock [43EH]: BYTE;
    Hz200 [4BAH]: LONGCARD;
    MFP [0FFFA00H]: ARRAY [1..24] OF BITSET; (* use only (0..7) *)
    ACSIReady: ARRAY [0..7] OF BOOLEAN;
    NoHDMes, Pacifier: ARRAY [0..34] OF CHAR;

CONST GPIP = 1; DMABit = 5;
      A1 = 1; ACSIReg = 3; FDCData = 7;
      PARK = 1BH; TEST = 0;

(*$S-,$T-,$Q+ no stack check, no range check, quick subr.calls *)
PROCEDURE BootSector;
VAR n, Target: CARDINAL;
BEGIN
   n:=0;
   LOOP
      TestACSI;
      FOR Target :=0 TO 7 DO IF ACSIReady[Target] THEN EXIT END END;
      IF n = 51 THEN ConWS(NoHDMes); EXIT END;
      INC(n);
      Pacifier[32]:=CHR(n DIV 10 + ORD('0'));
      Pacifier[33]:=CHR(n MOD 10 + ORD('0'));
      ConWS(Pacifier);
   END
(* IF Pacifier[32] # 'x' THEN ConWS(ClrMes) END *)
END BootSector;

PROCEDURE INTWait(wait200: LONGCARD): BOOLEAN;
VAR time: LONGCARD;
BEGIN
   time:=Hz200+wait200;
   REPEAT
      IF NOT (DMABit IN MFP[GPIP]) THEN RETURN TRUE END
   UNTIL Hz200 >= time;
   RETURN FALSE
END INTWait;

PROCEDURE TestTarget(Device: CARDINAL): BOOLEAN;
VAR CommandByte: BYTE;
    cmd : LONGCARD;
    mode: LONGBITSET;
    i   : CARDINAL;
BEGIN
   CommandByte:=BYTE(Device * 20H + TEST);
   mode:=LONGBITSET{FDCData,ACSIReg};
   DMAModeReg:=WORD(mode);
   cmd:=LONGCARD(CommandByte) * 10000H + LONGCARD(mode);
   DMACommandRegs:=LONGWORD(cmd);
   IF NOT INTWait(10) THEN RETURN FALSE END;
   INCL(mode,A1); cmd:=LONGCARD(mode);
   FOR i:=1 TO 4 DO
      DMACommandRegs:=LONGWORD(cmd);
      IF NOT INTWait(10) THEN RETURN FALSE END
   END;
   EXCL(mode,FDCData); cmd:=LONGCARD(mode);
   DMACommandRegs:=LONGWORD(cmd);
   IF NOT INTWait(200) THEN RETURN FALSE END;
   INCL(mode,FDCData);
   DMAModeReg:=WORD(mode);
   RETURN TRUE
END TestTarget;

PROCEDURE TestACSI;
VAR Target: CARDINAL;
BEGIN
   FOR Target:=0 TO 7 DO
      flock:=BYTE(0FFH);
      ACSIReady[Target]:=TestTarget(Target);
      DMAModeReg:=WORD({FDCData});
      flock:=BYTE(0)
   END
END TestACSI;
   (*S+ *)

BEGIN
   Pacifier:=" Y,9jkSoft waiting for Harddisk xx";
   Pacifier[0]:=33C;
   NoHDMes :=" Y,9         No Harddisk          ";
   NoHDMes[0]:=33C;
   ParkHardDisk;
   ConInWait;

   SuperExec(BootSector)

END HDWait.
