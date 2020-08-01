MODULE MinMax; (* SJ 19.2.95 *)


IMPORT
  S:=SYSTEM;

(*$-c *)

PROCEDURE MinB*(value1, value2: S.BYTE) : S.BYTE;
(*
 Answer the smaller value of value1 and value2 or value1 if equal.
 *)
 BEGIN
  ASSEMBLER
    MOVE.B  4(SP),D0
    CMP.B   6(SP),D0
    BLE.B   end
    MOVE.B  6(SP),D0
  end:
    RTS
  END;
 END MinB;


PROCEDURE MinW*(value1, value2: INTEGER) : LONGINT;
(*
 Answer the smaller value of value1 and value2 or value1 if equal.
 *)
 BEGIN
  ASSEMBLER
    MOVE.W  4(SP),D0
    CMP.W   6(SP),D0
    BLE.B   end
    MOVE.W  6(SP),D0
  end:
    RTS
  END;
 END MinW;


PROCEDURE MinL*(value1, value2: LONGINT) : LONGINT;
(*
 Answer the smaller value of value1 and value2 or value1 if equal.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  4(SP),D0
    CMP.L   8(SP),D0
    BLE.B   end
    MOVE.L  8(SP),D0
  end:
    RTS
  END;
 END MinL;


PROCEDURE MaxB*(value1, value2: S.BYTE) : S.BYTE;
(*
 Answer the bigger value of value1 and value2 or value1 if equal.
 *)
 BEGIN
  ASSEMBLER
    MOVE.B  4(SP),D0
    CMP.B   6(SP),D0
    BGE.B   end
    MOVE.B  6(SP),D0
  end:
    RTS
  END;
 END MaxB;


PROCEDURE MaxW*(value1, value2: INTEGER) : LONGINT;
(*
 Answer the bigger value of value1 and value2 or value1 if equal.
 *)
 BEGIN
  ASSEMBLER
    MOVE.W  4(SP),D0
    CMP.W   6(SP),D0
    BGE.B   end
    MOVE.W  6(SP),D0
  end:
    RTS
  END;
 END MaxW;


PROCEDURE MaxL*(value1, value2: LONGINT) : LONGINT;
(*
 Answer the bigger value of value1 and value2 or value1 if equal.
 *)
 BEGIN
  ASSEMBLER
    MOVE.L  4(SP),D0
    CMP.L   8(SP),D0
    BGE.B   end
    MOVE.L  8(SP),D0
  end:
    RTS
  END;
 END MaxL;

(*$+c *)

END MinMax.