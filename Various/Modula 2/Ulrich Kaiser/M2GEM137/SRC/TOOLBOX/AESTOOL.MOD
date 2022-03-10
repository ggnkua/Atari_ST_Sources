IMPLEMENTATION MODULE AESTool;

(*
AES Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB     IMPORT ANYPOINTER;
FROM pSTORAGE   IMPORT ALLOCATE,DEALLOCATE;
#if (defined LPRM2) || (defined SPCM2)
FROM Register   IMPORT D0;
FROM SYSTEM     IMPORT VAL,LONG,SETREG,INLINE;
#elif (defined HM2)
FROM Register   IMPORT D0;
FROM SYSTEM     IMPORT CAST,LOAD,CODE;
#elif (defined MM2)
FROM Calls      IMPORT Registers,NewCaller;
FROM MOSGlobals IMPORT MemArea;
FROM SYSTEM     IMPORT CAST,ADR,WORD,BYTE;
#elif (defined TDIM2)
FROM Register   IMPORT D0;
FROM SYSTEM     IMPORT SETREG,CODE;
#elif (defined FSTM2)
FROM SYSTEM     IMPORT ASSEMBLER;
#elif (defined SDSM2)
FROM SYSTEM     IMPORT CODE,RegAX,RegBX,RegCX,RegDX,WORD,ADR,ADDRESS;
#elif (defined LM2)
FROM SYSTEM     IMPORT CODE,SETREG,AX,BX,CX,DX,ADR,ADDRESS;
#elif (defined TSM2)
FROM SYSTEM     IMPORT Seg,Ofs,WORD,BYTE;
#endif
FROM SYSTEM     IMPORT TSIZE;

IMPORT AES,GetObject,SetObject;

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE FrameCode(VAR PB: AES.ParmBlk);

CONST PUSH   = 48E7H;
      A3D3D7 = 1F10H;
      POP    = 4CDFH;
      D3D7A3 = 08F8H;
      UNLKA6 = 4E5EH;
      POPA4  = 285FH;
      RTS    = 4E75H;

#elif (defined TDIM2)
(*$P-*)
PROCEDURE FrameCode(VAR PB: AES.ParmBlk);

CONST PBParm = 0001AH;
      PUSH   = 048E7H;
      D35A35 = 01C1CH;
      POP    = 04CDFH;
      A35D35 = 03838H;

#elif (defined HM2)
PROCEDURE FrameCode(VAR PB: AES.ParmBlk);

CONST POPA5  = 2A5FH;
      UNLKA6 = 4E5EH;
      RTS    = 4E75H;

#elif (defined MM2)
VAR Stack: ARRAY [0..2047] OF BYTE;

PROCEDURE FrameCode(VAR Regs: Registers);

TYPE ParmBlkPtr = POINTER TO AES.ParmBlk;

VAR PB: ParmBlkPtr;

#elif (defined ANAM2) || (defined FTLM2)
PROCEDURE FrameCode(VAR PB: AES.ParmBlk): AES.ObjectState;

#elif (defined FSTM2)
PROCEDURE FrameCode();

TYPE ParmBlkPtr = POINTER TO AES.ParmBlk;

VAR State: CARDINAL;
    PB   : ParmBlkPtr;

#elif (defined TSM2_2)
PROCEDURE FrameCode(): AES.ObjectState;

#else
PROCEDURE FrameCode(VAR PB: AES.ParmBlk): AES.ObjectState;
#endif

BEGIN
#if (defined LPRM2) || (defined SPCM2)
  (* Thanks a lot H. Kleinschmidt for this hack *)
  INLINE(PUSH,A3D3D7);
  SETREG(D0,LONG(PB.PBParm^.Func(PB)));
  INLINE(POP,D3D7A3);
  INLINE(UNLKA6,POPA4,RTS);

#elif (defined MM2)
  (* Thanks a lot T. Tempelmann for this hack *)
  PB:= Regs.parm^.ad;
  Regs.regD0.w:= CAST(WORD,PB^.PBParm^.Func(PB^));

#elif (defined ANAM2) || (defined FTLM2)
  RETURN PB.PBParm^.Func(PB);

#elif (defined TDIM2)
  (* Thanks a lot H. Kleinschmidt for help *)
  CODE(04E56H,00000H); (* LINK    A6,#0000H     *)
  CODE(PUSH,D35A35);   (* MOVEM.L D3-D5/A3-A5,-(A7) *)

(* the following code does nothing more than
  SETREG(D0,PB.PBParm^.Func(PB));
*)
  CODE(0286EH,00008H); (* MOVE.L  PB(A6),A4     *)
  CODE(0286CH,PBParm); (* MOVE.L  PBParm(A4),A4 *)
  CODE(0558FH);        (* SUBQ.L  #2,A7         *)
  CODE(0266EH,00008H); (* MOVE.L  PB(A6),A3     *)
  CODE(04853H);        (* PEA     (A3)          *)
  CODE(02854H);        (* MOVE.L  (A4),A4       *)
  CODE(04E94H);        (* JSR     (A4)          *)
  CODE(0588FH);        (* ADDQ.L  #4,A7         *)
  CODE(0301FH);        (* MOVE.W  (A7)+,D0      *)
  CODE(POP,A35D35);    (* MOVEM.L (A7)+,D3-D5/A3-A5 *)
  CODE(04E5EH);        (* UNLK    A6            *)
  CODE(04E75H);        (* RTS                   *)

#elif (defined FSTM2)
  (* fetch parameter from AX:BX *)

  ASM
    MOV SEG PB,AX
    MOV OFFSET PB,BX
  END;

  (* The state is expected in AX. RETURN would do this, but adds 4 to the *)
  (* stack pointer, so this will not follow C calling conventions.        *)

  State:= CARDINAL(PB.PBParm^.Func(PB^));

  ASM
    MOV AX,State (* move state in AX                  *)
    RETF         (* avoid stack adding by Modula code *)
  END;
#elif (defined HM2)
  LOAD(PB.PBParm^.Func(PB),D0);
  CODE(POPA5);
  CODE(UNLKA6);
  CODE(RTS);
#else
  RETURN PB.PBParm^.Func(PB);
#endif
END FrameCode;
#ifdef TDIM2
(*$P=*)
#endif

PROCEDURE NewObject(Tree  : AES.TreePtr;
                    Index : AES.ObjectIndex;
                    MyFunc: AES.UserDefFunc;
                    MyParm: ANYPOINTER): BOOLEAN;

#ifdef MM2
VAR Mem: MemArea;
#endif

BEGIN
  SetObject.Type(Tree,Index,AES.GUserDef);
  WITH Tree^[Index].ObSpec DO
    ALLOCATE(UserBlk,TSIZE(AES.UserBlk));
    IF UserBlk # NIL THEN
      WITH UserBlk^ DO
#ifdef MM2
        WITH Mem DO
          bottom:= ADR(Stack);
          length:= SIZE(Stack);
        END;

        NewCaller(FrameCode,FALSE,Mem,UBCode);

        IF UBCode = NIL THEN
          RETURN FALSE;
        END;
#else
        UBCode:= FrameCode;
#endif
        ALLOCATE(UBParm,TSIZE(AES.UserDefBlk));

        IF UBParm # NIL THEN
          WITH UBParm^ DO
            Func:= MyFunc;
            Parm:= MyParm;
          END;
        ELSE
          RETURN FALSE;
        END;

      END;
    ELSE
      RETURN FALSE;
    END;
  END;
  RETURN TRUE;
END NewObject;

PROCEDURE DisposeObject(Tree : AES.TreePtr;
                        Index: AES.ObjectIndex;
                        Type : AES.ObjectTypes);

VAR Parm: ANYPOINTER;
    Spec: AES.ObjectSpec;

BEGIN
  IF NOT(AES.Indirect IN Tree^[Index].ObFlags) THEN
    Spec:= Tree^[Index].ObSpec;
  ELSE
    Spec:= Tree^[Index].ObSpec.Extension^.Spec;
  END;

  Parm:= Spec.UserBlk^.UBParm^.Parm;

  DEALLOCATE(Spec.UserBlk^.UBParm,TSIZE(AES.UserDefBlk));
  DEALLOCATE(Spec.UserBlk,TSIZE(AES.UserBlk));

  SetObject.Type(Tree,Index,Type);

  IF NOT(AES.Indirect IN Tree^[Index].ObFlags) THEN
    Tree^[Index].ObSpec.Address:= Parm;
  ELSE
    Tree^[Index].ObSpec.Extension^.Spec.Address:= Parm;
  END;
END DisposeObject;

END AESTool.