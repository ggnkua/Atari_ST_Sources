IMPLEMENTATION MODULE VDI;

(*
Global VDI Definitions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM PORTAB   IMPORT SIGNEDWORD,UNSIGNEDWORD;
#if (defined LPRM2) || (defined SPCM2)
FROM SYSTEM   IMPORT VAL,SETREG,ADR,INLINE;
FROM Register IMPORT D1;
#elif (defined TDIM2) || (defined ANAM2) || (defined FTLM2)
FROM SYSTEM   IMPORT SETREG,ADR,CODE;
FROM Register IMPORT D1;
#elif (defined HM2)
FROM SYSTEM   IMPORT LOAD,ADR,CODE;
FROM Register IMPORT D1;
#elif (defined MM2)
FROM SYSTEM   IMPORT ASSEMBLER,CAST,ADR;
#elif (defined FSTM2)
FROM SYSTEM   IMPORT ADR,ASSEMBLER,SEGMENT,OFFSET;
#elif (defined SDSM2)
FROM SYSTEM   IMPORT CODE,RegDS,RegCX,RegDX,SWI,ADR,ADDRESS,WORD;
#elif (defined LM2)
FROM SYSTEM   IMPORT ADDRESS,CODE,SWI,SETREG,DX,CX,ADR;
#elif (defined TSM2_1)
FROM VDISYS   IMPORT callvdi;
#elif (defined TSM2_2)
FROM SYSTEM   IMPORT Seg,Ofs,BYTE,WORD,ADR;
#endif

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE vdi;

  PROCEDURE Trap2;
    CODE(04E42H);

BEGIN
  SETREG(D1,ADR(v)); (* move.l #v,d1   *)
  INLINE(7073H);     (* moveq  #$73,d0 *)
  Trap2;             (* trap   #2      *)
END vdi;

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);

  PROCEDURE Trap2;
    CODE(04E42H);

BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  SETREG(D1,ADR(v));
  INLINE(7073H);
  Trap2;
END CallVDI;
#endif

#ifdef HM2
PROCEDURE vdi;

CONST trap2 = 4E42H;

BEGIN
  LOAD(ADR(v),D1); (* move.l #v,d1   *)
  CODE(7073H);     (* moveq  #$73,d0 *)
  CODE(trap2);     (* trap   #2      *)
END vdi;

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);

CONST trap2 = 4E42H;

BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  LOAD(ADR(v),D1);
  CODE(7073H);
  CODE(trap2);
END CallVDI;
#endif

#if (defined TDIM2) || (defined FTLM2)
PROCEDURE vdi;

CONST trap2 = 4E42H;

BEGIN
  SETREG(D1,ADR(v)); (* move.l #v,d1   *)
  CODE(7073H);       (* moveq  #$73,d0 *)
  CODE(trap2);       (* trap   #2      *)
END vdi;

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);

CONST trap2 = 4E42H;

BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  SETREG(D1,ADR(v));
  CODE(7073H);
  CODE(trap2);
END CallVDI;
#endif

#ifdef ANAM2
PROCEDURE vdi;

CONST trap2 = 4E42H;

BEGIN
  SETREG(D1,ADR(v)); (* move.l #v,d1   *)
  CODE(7073H);       (* moveq  #$73,d0 *)
  CODE(trap2);       (* trap   #2      *)
END vdi;

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);

CONST trap2 = 4E42H;

BEGIN
  WITH contrl DO
    c[0]:= CAST(UNSIGNEDWORD,opcode);
    c[1]:= CAST(UNSIGNEDWORD,nptsin);
    c[3]:= CAST(UNSIGNEDWORD,nintin);
    c[6]:= CAST(UNSIGNEDWORD,handle);
  END;
  SETREG(D1,ADR(v));
  CODE(7073H);
  CODE(trap2);
END CallVDI;
#endif

#ifdef MM2
PROCEDURE vdi;
(*$L-*)
BEGIN
  ASSEMBLER
    MOVE.L #v,D1;
    MOVEQ  #$73,D0;
    TRAP   #2;
  END;
END vdi;
(*$L=*)

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  vdi;
END CallVDI;
#endif

#ifdef MSM2
(* $L- *)
PROCEDURE vdi;
BEGIN
  (*$A+*)
    MOVE.L #v,D1
    MOVEQ  #$73,D0
    TRAP   #2
  (*$A-*)
END vdi;
(* $L+ *)

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  (*$A+*)
    MOVE.L #v,D1
    MOVEQ  #$73,D0
    TRAP   #2
  (*$A-*)
END CallVDI;
#endif

#ifdef FSTM2
  MODULE SystemCall;

  IMPORT ASSEMBLER,SEGMENT,OFFSET,UNSIGNEDWORD,contrl,v;
  EXPORT vdi,CallVDI;

  VAR VDIPBSEG: CARDINAL;
      VDIPBOFS: CARDINAL;

  PROCEDURE vdi;

  CONST GEM    = 0EFH;
        OpCode = 473H;

  BEGIN
    ASM
      PUSH DS
      MOV  DS,VDIPBSEG
      MOV  DX,VDIPBOFS
      MOV  CX,OpCode
      INT  GEM
      POP  DS
    END;
  END vdi;

  PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
  BEGIN
    WITH contrl DO
      c[0]:= opcode;
      c[1]:= nptsin;
      c[3]:= nintin;
      c[6]:= handle;
    END;
    vdi;
  END CallVDI;

  BEGIN
    VDIPBSEG:= SEGMENT(v);
    VDIPBOFS:= OFFSET(v);
  END SystemCall;
#endif

#ifdef LM2
PROCEDURE vdi;

CONST OpCode = 1139;
      GEM    = 0EFH;

TYPE Address = RECORD
                 CASE: BOOLEAN OF
                   TRUE:
                     Adr: ADDRESS;
                 | FALSE:
                     Ofs: CARDINAL;
                     Seg: CARDINAL;
                 END;
               END;

VAR VDIPBADR: Address;
    VDIPBSEG: CARDINAL;
    VDIPBOFS: CARDINAL;

BEGIN
  VDIPBADR.Adr:= ADR(v);

  VDIPBSEG:= VDIPBADR.Seg;
  VDIPBOFS:= VDIPBADR.Ofs;

  CODE(1EH);               (* push ds     *)
  SETREG(DX,VDIPBSEG);
  CODE(08EH,0DAH);         (* mov ds,dx   *)
  SETREG(DX,VDIPBOFS);
  SETREG(CX,OpCode);       (* mov cx,1139 *)
  SWI(GEM);                (* int GEM     *)
  CODE(1FH);               (* pop ds      *)
END vdi;

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  vdi;
END CallVDI;
#endif

#ifdef SDSM2
PROCEDURE vdi;

CONST OpCode = 1139;
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

VAR VDIPBADR: Address;
    VDIPBSEG: WORD;
    VDIPBOFS: WORD;

BEGIN
  VDIPBADR.Adr:= ADR(v);

  VDIPBSEG:= VDIPBADR.Seg;
  VDIPBOFS:= VDIPBADR.Ofs;

  CODE(1EH);        (* push ds     *)
  RegDS:= VDIPBSEG;
  RegDX:= VDIPBOFS;
  RegCX:= OpCode;   (* mov cx,1139 *)
  SWI(GEM);         (* int GEM     *)
  CODE(1FH);        (* pop ds      *)
END vdi;

PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
BEGIN
  WITH contrl DO
    c[0]:= opcode;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[6]:= handle;
  END;
  vdi;
END CallVDI;
#endif

#ifdef TSM2_1
  MODULE SystemCall;

  IMPORT v,contrl,UNSIGNEDWORD,callvdi;
  IMPORT vdi,CallVDI; (* EXPORT *)

  PROCEDURE vdi;
  BEGIN
    callvdi(v);
  END vdi;

  PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
  BEGIN
    WITH contrl DO
      c[0]:= opcode;
      c[1]:= nptsin;
      c[3]:= nintin;
      c[6]:= handle;
    END;
    callvdi(v);
  END CallVDI;

  END SystemCall;
#endif

#ifdef TSM2_2
  MODULE SystemCall;

  IMPORT v,contrl,UNSIGNEDWORD,BYTE,WORD,Seg,Ofs;
  IMPORT vdi,CallVDI; (* EXPORT *)

  PROCEDURE vdi;

  CONST OpCode = 473H;
        GEM    = 0EFH;

  TYPE CODE1 = ARRAY[0..0] OF BYTE;
       CODE2 = ARRAY[0..1] OF BYTE;
       CODE5 = ARRAY[0..4] OF BYTE;

    (*#save *)
    (*#call(inline=>on,
            reg_param=>(dx) *)
    PROCEDURE push_ds = CODE1(01EH); (* push ds *)

    PROCEDURE pop_ds = CODE1(01FH); (* pop ds *)

    PROCEDURE mov_seg(a: WORD) = CODE2(08EH,0DAH); (* mov ds,dx *)

    PROCEDURE callvdi(a: WORD) = CODE5(0B9H,073H,004H, (* mov cx,473h *)
                                       0CDH,GEM);      (* int GEM     *)
    (*#restore *)

  BEGIN
    push_ds;         (* push ds      *)
    mov_seg(Seg(v)); (* mov dx,seg v *)
                     (* mov ds,dx    *)
    callvdi(Ofs(v)); (* mov dx,ofs v *)
                     (* mov cx,0473h *)
                     (* int 0efh     *)
    pop_ds;          (* pop ds       *)
  END vdi;

  PROCEDURE CallVDI(opcode,nptsin,nintin,handle: UNSIGNEDWORD);
  BEGIN
    WITH contrl DO
      c[0]:= opcode;
      c[1]:= nptsin;
      c[3]:= nintin;
      c[6]:= handle;
    END;
    vdi;
  END CallVDI;

  END SystemCall;
#endif

PROCEDURE CallEsc(escno,handle: UNSIGNEDWORD);
BEGIN
  WITH contrl DO
    c[0]:= 5;
    c[1]:= 0;
    c[3]:= 0;
    c[5]:= escno;
    c[6]:= handle;
  END;
  vdi;
END CallEsc;

PROCEDURE CallVDIEsc(escno,nptsin,nintin,handle: UNSIGNEDWORD);
BEGIN
  WITH contrl DO
    c[0]:= 5;
    c[1]:= nptsin;
    c[3]:= nintin;
    c[5]:= escno;
    c[6]:= handle;
  END;
  vdi;
END CallVDIEsc;

PROCEDURE Result(): SIGNEDWORD;
BEGIN
  RETURN intout[0];
END Result;

BEGIN

  (* initialization of VDI parameter block *)

  WITH v DO
    pblock:= ADR(contrl);
    iioff:= ADR(intin);
    pioff:= ADR(ptsin);
    iooff:= ADR(intout);
    pooff:= ADR(ptsout);
  END;

END VDI.
