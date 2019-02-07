IMPLEMENTATION MODULE AESTool;

(*
AES Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB     IMPORT ANYPOINTER;
FROM pSTORAGE   IMPORT ALLOCATE,DEALLOCATE;
#if (defined LPRM2) || (defined SPCM2)
FROM Register   IMPORT D0,A7;
FROM SYSTEM     IMPORT VAL,LONG,SETREG,INLINE,REG;
#elif (defined HM2)
FROM Register   IMPORT D0,A7;
FROM SYSTEM     IMPORT CAST,LOAD,STORE,CODE;
#elif (defined MM2)
FROM Calls      IMPORT Registers,NewCaller;
FROM MOSGlobals IMPORT MemArea;
FROM SYSTEM     IMPORT CAST,WORD;
#elif (defined TDIM2)
FROM Register   IMPORT D0,A7;
FROM SYSTEM     IMPORT SETREG,REGISTER,CODE;
#elif (defined FSTM2)
FROM SYSTEM     IMPORT ASSEMBLER;
#elif (defined SDSM2)
FROM SYSTEM     IMPORT CODE,RegAX,RegBX,RegCX,RegDX,WORD,ADR,ADDRESS;
#elif (defined LM2)
FROM SYSTEM     IMPORT CODE,SETREG,AX,BX,CX,DX,ADR,ADDRESS;
#elif (defined TSM2)
FROM SYSTEM     IMPORT Seg,Ofs,WORD;
#endif
FROM SYSTEM     IMPORT TSIZE,ADDRESS,ADR;

IMPORT AES,GetObject,SetObject;

CONST GUserDefStacksize = 1024; (* bytes * TSIZE(ADDRESS) *)

VAR GUserDefStack: ARRAY[0..GUserDefStacksize] OF ADDRESS;
    OldSP        : ADDRESS;

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
PROCEDURE FrameCode(VAR PB: AES.ParmBlk);

CONST PUSH   = 048E7H;
      D35A35 = 01C1CH;
      POP    = 04CDFH;
      A35D35 = 03838H;

#elif (defined HM2)
PROCEDURE FrameCode(VAR PB: AES.ParmBlk);

CONST POPA5  = 2A5FH;
      UNLKA6 = 4E5EH;
      RTS    = 4E75H;

#elif (defined MM2)
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
  (* thanks a lot H. Kleinschmidt for this hack *)

  INLINE(PUSH,A3D3D7); (* don't touch A3, it's needed by the AES *)

  OldSP:= REG(A7); (* save old SP *)
  SETREG(A7,ADR(GUserDefStack[GUserDefStacksize])); (* set new stack *)
  SETREG(D0,LONG(PB.PBParm^.Func(PB)));
  SETREG(A7,OldSP); (* restore old SP *)

  INLINE(POP,D3D7A3);
  INLINE(UNLKA6,POPA4,RTS);

#elif (defined MM2)
  (* thanks a lot T. Tempelmann for this hack *)

  PB:= Regs.parm^.ad;
  Regs.regD0.w:= CAST(WORD,PB^.PBParm^.Func(PB^));

#elif (defined ANAM2) || (defined FTLM2)
  RETURN PB.PBParm^.Func(PB);

#elif (defined TDIM2)
  (* thanks a lot H. Kleinschmidt for help *)

  CODE(PUSH,D35A35);   (* MOVEM.L D3-D5/A3-A5,-(A7) *)

  OldSP:= ADDRESS(REGISTER(A7));
  SETREG(A7,ADR(GUserDefStack[GUserDefStacksize]));
  SETREG(D0,PB.PBParm^.Func(PB));
  SETREG(A7,OldSP);

  CODE(POP,A35D35);    (* MOVEM.L (A7)+,D3-D5/A3-A5 *)

#elif (defined FSTM2)
  (* fetch parameter from AX:BX *)

  ASM
    MOV SEG PB,AX
    MOV OFFSET PB,BX
  END;

  (* the state is expected in AX. RETURN would do this, but adds 4 to the *)
  (* stack pointer, so this will not follow C calling conventions.        *)

  State:= CARDINAL(PB.PBParm^.Func(PB^));

  ASM
    MOV AX,State (* move state in AX                  *)
    RETF         (* avoid stack adding by Modula code *)
  END;
#elif (defined HM2)
  STORE(A7,OldSP);
  LOAD(ADR(GUserDefStack[GUserDefStacksize]),A7);
  LOAD(PB.PBParm^.Func(PB),D0);
  LOAD(OldSP,A7);
  CODE(POPA5);
  CODE(UNLKA6);
  CODE(RTS);
#else
  RETURN PB.PBParm^.Func(PB);
#endif
END FrameCode;

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
          bottom:= ADR(GUserDefStack);
          length:= SIZE(GUserDefStack);
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

(*
  IF Spec.UserBlk^.UBCode # FrameCode THEN (* not our own *)
*)

#if (defined LPRM2) || (defined SPCM2)
  IF CAST(ADDRESS,Spec.UserBlk^.UBCode) # ADR(FrameCode) THEN (* not our own *)
    RETURN;
  END;
#elif (defined MM2)
  IF CAST(ADDRESS,Spec.UserBlk^.UBCode) # ADR(GUserDefStack) THEN (* not our own *)
    RETURN;
  END;
#else
  IF CAST(ADDRESS,Spec.UserBlk^.UBCode) # CAST(ADDRESS,FrameCode) THEN (* not our own *)
    RETURN;
  END;
#endif

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
