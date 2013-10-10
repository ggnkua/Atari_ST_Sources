MODULE DataSegment;

(*
 * L„dt Ptr auf DATA-Segment. Sollte mit "-D"-Option gelinkt werden.
 *)

FROM PrgCtrl IMPORT GetBasePageAddr;
FROM SysTypes IMPORT PtrBP;
FROM SYSTEM IMPORT ADDRESS, ASSEMBLER;

VAR bp: PtrBP;
    dataPtr: ADDRESS;
    dataLen: LONGCARD;

BEGIN
  GetBasePageAddr (bp);
  dataPtr:= bp^.p_dbase;
  dataLen:= bp^.p_dlen;
  ASSEMBLER
    MOVE.L  dataPtr,A0
    MOVE.L  dataLen,D0
    BREAK
  END
END DataSegment.
