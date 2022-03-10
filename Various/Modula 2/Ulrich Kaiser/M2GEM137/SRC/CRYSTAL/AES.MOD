IMPLEMENTATION MODULE AES;

(*
Global AES Definitions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB    IMPORT UNSIGNEDWORD,NULL;
#if (defined LPRM2) || (defined SPCM2) || (defined MAMM2)
FROM SYSTEM    IMPORT SETREG,ADR,INLINE,VAL;
FROM Register  IMPORT A1,D1;
#elif (defined TDIM2) || (defined ANAM2) || (defined FTLM2)
FROM SYSTEM    IMPORT SETREG,ADR,CODE;
FROM Register  IMPORT A1,D1;
#elif (defined HM2)
FROM SYSTEM    IMPORT LOAD,ADR,CODE;
FROM Register  IMPORT A1,D1;
#elif (defined MM2)
FROM SYSTEM    IMPORT ASSEMBLER,ADR,CAST;
#elif (defined FSTM2)
FROM SYSTEM    IMPORT ASSEMBLER,ADR,SEGMENT,OFFSET;
#elif (defined SDSM2)
FROM SYSTEM    IMPORT CODE,RegAX,RegBX,RegCX,RegDX,SWI,WORD,ADR,ADDRESS;
#elif (defined LM2)
FROM SYSTEM    IMPORT CODE,SWI,SETREG,AX,BX,CX,DX,ADR,ADDRESS;
#elif (defined TSM2_1) || (defined GPM2)
FROM AESSYS    IMPORT aes;
FROM SYSTEM    IMPORT ADR;
#elif (defined TSM2_2)
FROM SYSTEM    IMPORT Seg,Ofs,WORD,BYTE;
#endif

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE crystal;

CONST OpCode = 200;

  PROCEDURE Trap2;
    CODE(4E42H);

BEGIN
  SETREG(A1,ADR(Control)); (* lea     Control,a1 *)
  INLINE(03C9H,0001H);     (* movep.l d1,1(a1)   *)
  SETREG(D1,ADR(c));       (* move.l  #c,d1      *)
  INLINE(303CH,OpCode);    (* move.w  #$C8,d0    *)
  Trap2;                   (* trap    #2         *)
END crystal;

#elif (defined TDIM2)
  MODULE SystemCall;

  IMPORT Control,c,UNSIGNEDWORD,SETREG,ADR,CODE,A1,D1;
  EXPORT crystal;

  PROCEDURE crystal;

  CONST trap2  = 4E42H;
        OpCode = 200;

  BEGIN
    SETREG(A1,ADR(Control)); (* lea     Control,a1 *)
    CODE(03C9H,0001H);       (* movep.l d1,1(a1)   *)
    SETREG(D1,ADR(c));       (* move.l  #c,d1      *)
    CODE(303CH,OpCode);      (* move.w  #$C8,d0    *)
    CODE(trap2);             (* trap    #2         *)
  END crystal;

  BEGIN

  (* initialize control array *)

  WITH Control DO
    OpCode:= 0;
    SizeIntIn:= 0;
    SizeIntOut:= 0;
    SizeAddrIn:= 0;
    SizeAddrOut:= 0;
  END;

  END SystemCall;

#elif (defined FTLM2)
  PROCEDURE crystal;

  CONST trap2  = 4E42H;
        OpCode = 200;

  BEGIN
    SETREG(A1,ADR(Control)); (* lea     Control,a1 *)
    CODE(03C9H,0001H);       (* movep.l d1,1(a1)   *)
    SETREG(D1,ADR(c));       (* move.l  #c,d1      *)
    CODE(303CH,OpCode);      (* move.w  #$C8,d0    *)
    CODE(trap2);             (* trap    #2         *)
  END crystal;

#elif (defined ANAM2)
  MODULE SystemCall;

  IMPORT Control,c,UNSIGNEDWORD,SETREG,ADR,CODE,A1,D1;
  EXPORT crystal;

  PROCEDURE crystal;

  CONST trap2  = 4E42H;
        OpCode = 200;

  BEGIN
    SETREG(A1,ADR(Control)); (* lea     Control,a1 *)
    CODE(03C9H,0001H);       (* movep.l d1,1(a1)   *)
    SETREG(D1,ADR(c));       (* move.l  #c,d1      *)
    CODE(303CH,OpCode);      (* move.w  #$C8,d0    *)
    CODE(trap2);             (* trap    #2         *)
  END crystal;

  BEGIN

  (* initialize control array *)

  WITH Control DO
    OpCode:= CAST(UNSIGNEDWORD,0);
    SizeIntIn:= CAST(UNSIGNEDWORD,0);
    SizeIntOut:= CAST(UNSIGNEDWORD,0);
    SizeAddrIn:= CAST(UNSIGNEDWORD,0);
    SizeAddrOut:= CAST(UNSIGNEDWORD,0);
  END;

  END SystemCall;

#elif (defined HM2)
  MODULE SystemCall;

  IMPORT Control,c,LOAD,ADR,CODE,A1,D1;
  EXPORT crystal;

  PROCEDURE crystal;

  CONST trap2  = 4E42H;
        OpCode = 200;

  BEGIN
    LOAD(ADR(Control),A1); (* lea     Control,a1 *)
    CODE(03C9H);
    CODE(0001H);           (* movep.l d1,1(a1)   *)
    LOAD(ADR(c),D1);       (* move.l  #c,d1      *)
    CODE(303CH);
    CODE(OpCode);          (* move.w  #$C8,d0    *)
    CODE(trap2);           (* trap    #2         *)
  END crystal;

  BEGIN

  (* initialize control array *)

  WITH Control DO
    OpCode:= 0;
    SizeIntIn:= 0;
    SizeIntOut:= 0;
    SizeAddrIn:= 0;
    SizeAddrOut:= 0;
  END;

  END SystemCall;

#elif (defined MM2)
  MODULE SystemCall;

  IMPORT ASSEMBLER,Control,c;
  EXPORT crystal;

  PROCEDURE crystal;
  (*$L-*)
  CONST OpCode = 200;

  BEGIN
    ASSEMBLER
      LEA     Control,A1
      MOVEP.L D1,1(A1)
      MOVE.L  #c,D1
      MOVE.W  #OpCode,D0
      TRAP    #2
    END;
  END crystal;
  (*$L=*)

  BEGIN

  (* initialize control array *)

  WITH Control DO
    OpCode:= 0;
    SizeIntIn:= 0;
    SizeIntOut:= 0;
    SizeAddrIn:= 0;
    SizeAddrOut:= 0;
  END;

  END SystemCall;

#elif (defined MSM2)
PROCEDURE crystal;
(*$L-*)
CONST OpCode = 200;

BEGIN
  (*$A+*)
    LEA     Control,A1
    MOVEP.L D1,1(A1)
    MOVE.L  #c,D1
    MOVE.W  #OpCode,D0
    TRAP    #2
  (*$A-*)
END crystal;
(*$L+*)

#elif (defined FSTM2)
  MODULE SystemCall;

  IMPORT Control,c,SEGMENT,OFFSET,ASSEMBLER,UNSIGNEDWORD;
  EXPORT crystal;

  VAR AESPBSEG: UNSIGNEDWORD;
      AESPBOFS: UNSIGNEDWORD;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);

  CONST OpCode = 200;
        GEM    = 0EFH;

  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;

    ASM
      MOV  AX,AESPBSEG
      MOV  BX,AESPBOFS
      MOV  CX,OpCode
      MOV  DX,0
      MOV  ES,AX
      INT  GEM
    END;
  END crystal;

  BEGIN
    AESPBSEG:= SEGMENT(c);
    AESPBOFS:= OFFSET(c);
    Control.SizeAddrOut:= 0;
  END SystemCall;

#elif (defined LM2)
PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);

CONST OpCode = 200;
      GEM    = 0EFH;

VAR AESPBADR: ADDRESS;
    AESPBSEG: CARDINAL;
    AESPBOFS: CARDINAL;

BEGIN
  WITH Control DO
    OpCode:= FuncNo;
    SizeIntIn:= NIntIn;
    SizeIntOut:= NIntOut;
    SizeAddrIn:= NAddrIn;
  END;

  AESPBADR:= ADR(c);

  AESPBSEG:= AESPBADR.SEGMENT;
  AESPBOFS:= AESPBADR.OFFSET;

  SETREG(AX,AESPBSEG); (* AESPBSEG must be a local variable *)
  SETREG(BX,AESPBOFS); (* AESPBOFS must be a local variable *)
  SETREG(CX,OpCode);
  SETREG(DX,0);
  CODE(8EH,C0H); (* mov  es,ax *)
  SWI(GEM);
END crystal;

#elif (defined SDSM2)
PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);

CONST OpCode = 200;
      GEM    = 0EFH;

TYPE Address = RECORD
                 CASE: BOOLEAN OF
                   TRUE:
                     Adr: ADDRESS;
                 | FALSE:
                     Ofs: WORD;
                     Seg: WORD;
                 END;
               END;

VAR AESPBADR: Address;

BEGIN
  WITH Control DO
    OpCode:= FuncNo;
    SizeIntIn:= NIntIn;
    SizeIntOut:= NIntOut;
    SizeAddrIn:= NAddrIn;
  END;
  AESPBADR.Adr:= ADR(c);
  RegAX:= AESPBADR.Seg;
  RegBX:= AESPBADR.Ofs;
  RegCX:= OpCode;
  RegDX:= 0;
  CODE(8EH,C0H); (* mov  es,ax *)
  SWI(GEM);
END crystal;

#elif (defined TSM2_1) || (defined GPM2)
  MODULE SystemCall;

  IMPORT Control,aes,c,UNSIGNEDWORD;
  EXPORT crystal;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);
  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;
    aes(c);
  END crystal;

  BEGIN
    Control.SizeAddrOut:= 0;
  END SystemCall;

#elif (defined TSM2_2)
  MODULE SystemCall;

  IMPORT Control,c,Seg,Ofs,WORD,BYTE,UNSIGNEDWORD;
  EXPORT crystal;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);

  CONST OpCode = 200;
        GEM    = 0EFH;

  TYPE CODE = ARRAY[0..3] OF BYTE;

  (*#call(inline=>on) *)
  PROCEDURE aes(seg: WORD; (* -> AX *)
                ofs: WORD; (* -> BX *)
                opc: WORD; (* -> CX *)
                zer: WORD) (* -> DX *)
            = CODE(08EH,0C0H, (* mov es,ax *)
                   0CDH,GEM); (* int GEM   *)
  (*#call(inline=>off) *)

  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;
    aes(Seg(c),Ofs(c),OpCode,0);
  END crystal;

  BEGIN
    Control.SizeAddrOut:= 0;
  END SystemCall;

#elif (defined XHM2)
  MODULE SystemCall;

  IMPORT Control,c,UNSIGNEDWORD;
  EXPORT crystal;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);
  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;

  END crystal;

  BEGIN

  END SystemCall;

#elif (defined XAM2)
  MODULE SystemCall;

  IMPORT Control,c,UNSIGNEDWORD;
  EXPORT crystal;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);
  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;

  END crystal;

  BEGIN

  END SystemCall;

#elif (defined XGM2)
  MODULE SystemCall;

  IMPORT Control,c,UNSIGNEDWORD;
  EXPORT crystal;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);
  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;

  END crystal;

  BEGIN

  END SystemCall;
#elif (defined XRM2)
  MODULE SystemCall;

  IMPORT Control,c,UNSIGNEDWORD;
  EXPORT crystal;

  PROCEDURE crystal(FuncNo,NIntIn,NIntOut,NAddrIn: UNSIGNEDWORD);
  BEGIN
    WITH Control DO
      OpCode:= FuncNo;
      SizeIntIn:= NIntIn;
      SizeIntOut:= NIntOut;
      SizeAddrIn:= NAddrIn;
    END;

  END crystal;

  BEGIN

  END SystemCall;
#endif

PROCEDURE Error(): BOOLEAN;
BEGIN
  RETURN IntOut[0] = 0;
END Error;

PROCEDURE Version(): UNSIGNEDWORD;

VAR Ver: UNSIGNEDWORD;

BEGIN
  Ver:= Global.ApVersion;
  IF (Ver >= 0200H) AND (Ver <= 0220H) THEN
    RETURN 0220H; (* GEM 2.x *)
#if ST
  ELSIF KAOS THEN
    RETURN 1042H; (* 1042H for all versions of KAOS-GEM *)
#endif
  ELSE
    RETURN Ver;
  END;
END Version;

BEGIN
#if no_local_modules
#if Seimet
  (* initialize control array *)

  WITH Control DO
    OpCode:= 0;
    SizeIntIn:= 0;
    SizeIntOut:= 0;
    SizeAddrIn:= 0;
    SizeAddrOut:= 0;
  END;
#else
  (* initialize control array *)

  Control.SizeAddrOut:= 0;
#endif
#endif

  (* initialize AES parameter block *)

  WITH c DO
    PControl:= ADR(Control);
    PGlobal:= ADR(Global);
    PIntIn:= ADR(IntIn);
    PIntOut:= ADR(IntOut);
    PAdrIn:= ADR(Addr);
    PAdrOut:= ADR(Addr[2]); (* AES.MaxAddress is 3 *)
  END;

  (* initialize Global *)

  WITH Global DO
    ApVersion:= 0;
    ApId:= -1;
(*  ApPTree:= NULL; done in RsrcMgr.Mod *)
    ApPMem:= NULL;
  END;

  (* initialize IntOut[0] *)

  IntOut[0]:= -1;

#if ST
  KAOS:= FALSE;
#endif

END AES.