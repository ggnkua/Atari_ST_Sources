IMPLEMENTATION MODULE LowReal;
__IMP_SWITCHES__
__RANGECHECK_OFF__
__STACKCHECK_OFF__
__DEBUG_OFF__
#ifdef HM2
#define REAL SHORTREAL
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
#ifdef MM2
(*$X+ 68881 Mnemonics *)
#endif
(*****************************************************************************)
(* 27-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

(* Fuer eine Implementierung dieses Moduls brauchen nicht unbedingt alle
 * Funktionen ``zu Fuss'' implementiert zu werden. Moeglicherweise
 * lassen sich folgende Aequivalenzen ausnutzen (kommt auch auf die
 * interne Real-Darstellung an!):
 *
 * basemant   ::= fraction(1.0);
 * baseexpo   ::= exponent(1.0);
 * unit(x, p) ::= scale(basemant, exponent(x) - p + 1)
 *
 * ulp(x)          = unit(x, places)
 * succ(x)         = x + ulp(x)
 * pred(x)         = x - ulp(x)
 * intpart(x)      = trunc(x, exponent(x) - baseexpo + 1)
 * fractpart(x)    = x - intpart(x)
 * synthesize(e,f) = scale(f, e)
 * round(x,p) =
 *     int  := trunc(x, i);
 *     rest := x - int;
 *     rnd  := unit(x, i + 1);
 *     last := unit(x, i);
 *
 *     IF rest >= rnd THEN
 *       int + last
 *     ELSE
 *       int
 *     END
 *
 * Wenn alle diese Aequivalenzen verwendet werden, muessen lediglich
 * 'fraction', 'exponent', 'scale' und 'trunc' implementiert werden.
 *)

INLINE_CODE_IMPORT

FROM DosSystem IMPORT
(* TYPE *) FPUInfo, FPUFlag, FPUType,
(* PROC *) GetFPU;

#ifdef ISOM2
IMPORT EXCEPTIONS;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

VAR
  fpu           : FPUInfo;
  hasFpu        : BOOLEAN;
#ifdef ISOM2
  lowRealSource : EXCEPTIONS.ExceptionSource;
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#ifdef MM2
__PROCFRAME_OFF__
(* Kein Prozedurrahmen wegen fehlender RETURN-Anweisung *)
PROCEDURE exponent ((* EIN/ -- *) x : REAL ): INTEGER;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  BPL.S   null
  ANDI.L  #$007F,D0
  SUBI.L  #64,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
#ifdef __LONG_WHOLE__
  MOVE.L  D0,(A3)+
#else
  MOVE.W  D0,(A3)+
#endif
#endif
END;
END exponent;

(*---------------------------------------------------------------------------*)

PROCEDURE fraction ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  BPL.S   null
  ANDI.B  #$80,D0
  ORI.B   #64,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END fraction;

(*---------------------------------------------------------------------------*)

PROCEDURE sign ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  BEQ.S   one
  ANDI.L  #$00000080,D0
  ORI.L   #$80000041,D0
  BRA.S   ende
one:
  MOVE.L  #$800000C1,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END sign;

(*---------------------------------------------------------------------------*)

PROCEDURE succ ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  BEQ.S   min1
  BPL.S   min
  TST.B   D0
  BPL.S   sub
  ADDI.L  #$00000100,D0
  BMI.S   ende
  ADDQ.B  #1,D0
  BPL.S   max
  BSET    #31,D0
  BRA.S   ende
min:
  TST.B   D0
  BPL.S   null
min1:
  MOVE.L  #$80000080,D0
  BRA.S   ende
max:
  MOVEQ   #$FFFFFFFF,D0
  BRA.S   ende
sub:
  SUBI.L  #$00000100,D0
  BMI.S   ende
  SUBQ.B  #1,D0
  BMI.S   null
  BSET    #31,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END succ;

(*---------------------------------------------------------------------------*)

PROCEDURE ulp ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  BPL.S   null
  ANDI.L  #$0000007F,D0
  SUBI.W  #24-1,D0
  BMI.S   null
  ORI.L   #$80000080,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END ulp;

(*---------------------------------------------------------------------------*)

PROCEDURE pred ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  BEQ.S   min1
  BPL.S   min
  TST.B   D0
  BMI.S   sub
  ADDI.L  #$00000100,D0
  BMI.S   ende
  ADDQ.B  #1,D0
  BMI.S   max
  BSET    #31,D0
  BRA.S   ende
min:
  TST.B   D0
  BMI.S   null
min1:
  MOVE.L  #$80000000,D0
  BRA.S   ende
max:
  MOVE.L  #$FFFFFF7F,D0
  BRA.S   ende
sub:
  SUBI.L  #$00000100,D0
  BMI.S   ende
  SUBQ.B  #1,D0
  BPL.S   null
  BSET    #31,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END pred;

(*---------------------------------------------------------------------------*)

PROCEDURE intpart ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  MOVEQ   #$0000007F,D2
  AND.W   D0,D2
  CMPI.B  #64+1,D2
  BLT.S   null
  CMPI.B  #64+24,D2
  BGE.S   ende
  MOVE.L  #$FFF00000,D1
  SUBI.W  #64+12,D2     ; [-11..11]
  BPL.S   shr
  NEG.W   D2
  LSL.L   D2,D1
  BRA.S   mask
shr:
  ASR.L   D2,D1
mask:
  MOVE.B  #$FF,D1
  AND.L   D1,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END intpart;

(*---------------------------------------------------------------------------*)

PROCEDURE fractpart ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D0
  MOVEQ   #$7F,D2
  AND.W   D0,D2
  CMPI.B  #64+1,D2
  BLT.S   ende
  CMPI.B  #64+24,D2
  BGE.S   null
  TST.L   D0
  BPL.S   null
  MOVE.W  D0,D1
  LSR.L   #8,D0
  SUBI.W  #64+23,D2
  NEG.W   D2            ; [22..0]
ffs:
  BTST    D2,D0
  DBNE    D2,ffs
  BEQ.S   null
  SUBI.W  #23,D2
  NEG.W   D2            ; [1..23]
  SUB.B   D2,D1
  ADDQ.W  #8,D2
  CMPI.W  #16,D2
  BLT.S   shl
  SWAP    D0
  CLR.W   D0
  SUBI.W  #16,D2
shl:
  LSL.L   D2,D0
  OR.B    D1,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END fractpart;

(*---------------------------------------------------------------------------*)

PROCEDURE scale ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) n : INTEGER  ): REAL;

BEGIN
ASSEMBLER
#ifdef __LONG_WHOLE__
  MOVE.L  -(A3),D2
#else
  MOVE.W  -(A3),D2
  EXT.L   D2
#endif
  MOVE.L  -(A3),D0
  BPL.S   null
  MOVEQ   #$7f,D1
  AND.W   D0,D1
  ADD.L   D2,D1
  BVS.S   max
  BMI.S   null
  CMPI.L  #127,D1
  BGT.S   max
  ANDI.B  #$80,D0
  OR.B    D1,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
  BRA.S   ende
max:
  ORI.L   #$FFFFFF7F,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END scale;

(*---------------------------------------------------------------------------*)

PROCEDURE trunc ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) n : INTEGER  ): REAL;

BEGIN
ASSEMBLER
#ifdef __LONG_WHOLE__
  MOVE.L  -(A3),D2
#else
  MOVE.W  -(A3),D2
  EXT.L   D2
#endif
  MOVE.L  -(A3),D0
  BPL.S   null
  TST.L   D2
  BLE.S   null
  CMPI.L  #24,D2
  BGE.S   ende
  MOVE.L  #$FFF00000,D1
  SUBI.W  #12,D2        ; [-11..11]
  BPL.S   shr
  NEG.W   D2
  LSL.L   D2,D1
  BRA.S   mask
shr:
  ASR.L   D2,D1
mask:
  MOVE.B  #$FF,D1
  AND.L   D1,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END trunc;

(*---------------------------------------------------------------------------*)

PROCEDURE round ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) n : INTEGER  ): REAL;

BEGIN
ASSEMBLER
#ifdef __LONG_WHOLE__
  MOVE.L  -(A3),D2
#else
  MOVE.W  -(A3),D2
  EXT.L   D2
#endif
  MOVE.L  D3,-(SP)
  MOVE.L  -(A3),D0
  BPL.S   null
  TST.L   D2
  BLE.S   null
  CMPI.L  #24,D2
  BGE.S   ende
  MOVE.W  D2,D3
  MOVE.L  #$FFF00000,D1
  SUBI.W  #12,D2        ; [-11..11]
  BPL.S   shr
  NEG.W   D2
  LSL.L   D2,D1
  BRA.S   rnd
shr:
  ASR.L   D2,D1
rnd:
  SUBI.W  #31,D3
  NEG.W   D3            ; [30..8]
  BTST    D3,D0
  BEQ.S   mask
  MOVE.W  D3,D2
  MOVE.L  D1,D3
  NOT.L   D3
  LSR.L   #1,D3
  CLR.B   D3
  AND.L   D0,D3
  BNE.S   up
  ADDQ.W  #1,D2
  BTST    D2,D0
  BEQ.S   mask
up:
  MOVE.L  D1,D3
  LSL.L   #1,D3
  EOR.L   D1,D3
  ADD.L   D3,D0
  BMI.S   mask
  ADDQ.B  #1,D0
  BCS.S   maxp
  BVS.S   maxn
  BSET    #31,D0
mask:
  MOVE.B  #$FF,D1
  AND.L   D1,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
maxp:
  MOVEQ   #$FFFFFFFF,D0
  BRA.S   ende
maxn:
  MOVE.L  #$FFFFFF7F,D0
ende:
  MOVE.L  (SP)+,D3
#ifdef __RES_ON_STACK__
  MOVE.L  D0,(A3)+
#endif
END;
END round;
__PROCFRAME_ON__
#else

#ifdef TDIM2
__PROCFRAME_OFF__
(* Kein Prozedurrahmen wegen fehlender RETURN-Anweisung *)
#endif
PROCEDURE exponent ((* EIN/ -- *) x : REAL ): INTEGER;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU 4+4
#elif (defined HM2)
   x      EQU 12
#endif

   fgetexp.s x(sp),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.w fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.w fp0,RETURN(sp)
   rts
#elif (defined HM2)
   fmove.l fp0,d0
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,441EH,000CH);
   CODE(0F22FH,7000H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined HM2)
   CODE(0F22FH,441EH,000CH);
   CODE(0F200H,6000H);
#elif (defined TDIM2)
   CODE(0F22FH,441EH,0004H);
   CODE(0F22FH,7000H,0008H,4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU 4+4
#elif (defined HM2)
   x      EQU 12
#endif

   move.w  #$7f80,D0
   and.w   x(SP),D0
   beq.s   ende
   lsr.w   #7,D0
   subi.w  #127,D0
 ende:
#if (defined HM2) && (defined __LONG_WHOLE__)
   ext.l   D0
#endif
#if (defined LPRM2) || (defined SPCM2)
   move.w  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.w  D0,RETURN(SP)
   rts
#endif
*)
   CODE(303CH,7F80H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(0C06FH,000CH);
#elif (defined HM2)
   CODE(0C06FH,000CH);
#elif (defined TDIM2)
   CODE(0C06FH,0004H);
#endif
   CODE(6706H,0EE48H,0440H,007FH);
#if (defined HM2) && (defined __LONG_WHOLE__)
   CODE(48C0H);
#endif
#if (defined LPRM2) || (defined SPCM2)
   CODE(3F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(3F40H,0008H,4E75H);
#endif
 END;
END exponent;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE fraction ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 12
#endif

   fgetman.s x(sp),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(sp)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,441FH,000CH);
#elif (defined HM2)
   CODE(0F22FH,441FH,000CH);
#elif (defined TDIM2)
   CODE(0F22FH,441FH,0004H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F200H,6400H); (* fmove.s FP0,D0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,6400H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,6400H,0008H);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 12
#endif

   move.l  x(SP),D0
   swap    D0
   move.w  #$7f80,D1
   and.w   D0,D1
   bne.s   norm
   moveq   #0,D0
   bra.s   ende
 norm:
   andi.w #$ffff-$7f80,D0
   ori.w   #$3f80,D0
   swap    D0
 ende:
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(202FH,000CH);
#elif (defined HM2)
   CODE(202FH,000CH);
#elif (defined TDIM2)
   CODE(202FH,0004H);
#endif
   CODE(4840H,323CH,7F80H,0C240H,6604H,7000H);
   CODE(600AH,0240H,807FH,0040H,3F80H,4840H);
#ifdef HM2
(*$!f+:
   CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2F40H,0008H);
   CODE(4E75H);
#endif
 END;
END fraction;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE sign ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+4
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+4
#elif (defined HM2)
 x      EQU 12
#endif

 sign:
   move.l  #$7f000000,D0
   lsl.w   x(SP)
   roxr.l  #1,D0

#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
 CODE(203CH,7F00H,0000H);
#if (defined LPRM2) || (defined SPCM2)
 CODE(0E3EFH,000CH);
#elif (defined HM2)
 CODE(0E3EFH,000CH);
#elif (defined TDIM2)
 CODE(0E3EFH,0004H);
#endif

 CODE(0E290H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
 CODE(2F40H,0008H);
 CODE(4E75H);
#elif (defined HM2)
(*$!f+:
 CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#endif
END sign;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE succ ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+4
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+4
#elif (defined HM2)
 x      EQU 12
#endif

 succ:
   move.l  x(SP),D0
   move.l  D0,D1
   swap    D1
   andi.w  #$7f80,D1
   beq.s   min
   cmpi.w  #$7f80,D1
   beq.s   ende
   tst.l   D0
   bmi.s   sub
   addq.l  #1,D0
   bra.s   ende
 min:
   move.l  #$00800000,D0
   bra.s   ende
 sub:
   subq.l  #1,D0
   cmpi.l  #$807fffff,D0
   bne.s   ende
   moveq   #0,D0
 ende:
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(202FH,000CH);
#elif (defined HM2)
 CODE(202FH,000CH);
#elif (defined TDIM2)
 CODE(202FH,0004H);
#endif

 CODE(2200H,4841H,0241H,7F80H,670EH,0C41H);
 CODE(7F80H,671CH,4A80H,6B0CH,5280H,6014H,203CH,0080H);
 CODE(0000H,600CH,5380H,0C80H,807FH,0FFFFH,6602H,7000H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
 CODE(2F40H,0008H);
 CODE(4E75H);
#elif (defined HM2)
(*$!f+:
 CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#endif
END succ;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE ulp ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+4
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+4
#elif (defined HM2)
 x      EQU 12
#endif

ulp:
  move.w  x(SP),D1
  move.w  #$7f80,D0
  and.w   D1,D0
  beq.s   null
  cmpi.w  #1+23<<7,D0
  blt.s   null
  subi.w  #23<<7,D0
;  andi.w  #$ffff-$7fff,D1
;  or.w    D1,D0
  swap    D0
  clr.w   D0
  bra.s   ende
null:
  moveq   #0,D0
ende:
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(322FH,000CH);
#elif (defined HM2)
 CODE(322FH,000CH);
#elif (defined TDIM2)
 CODE(322FH,0004H);
#endif

 CODE(303CH,7F80H,0C041H,6710H,0C40H,0C00H);
 CODE(6D0AH,0440H,0B80H,4840H,4240H,6002H,7000H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
 CODE(2F40H,0008H);
 CODE(4E75H);
#elif (defined HM2)
(*$!f+:
 CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#endif
END ulp;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE pred ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+4
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+4
#elif (defined HM2)
 x      EQU 12
#endif

 pred:
   move.l  x(SP),D0
   move.l  D0,D1
   swap    D1
   andi.w  #$7f80,D1
   beq.s   min
   cmpi.w  #$7f80,D1
   beq.s   ende
   tst.l   D0
   bpl.s   sub
   addq.l  #1,D0
   bra.s   ende
 min:
   move.l  #$80800000,D0
   bra.s   ende
 sub:
   subq.l  #1,D0
   cmpi.l  #$007fffff,D0
   bne.s   ende
   moveq   #0,D0
 ende:
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(202FH,000CH);
#elif (defined HM2)
 CODE(202FH,000CH);
#elif (defined TDIM2)
 CODE(202FH,0004H);
#endif

 CODE(2200H,4841H,0241H,7F80H,670EH,0C41H);
 CODE(7F80H,671CH,4A80H,6A0CH,5280H,6014H,203CH,8080H);
 CODE(0000H,600CH,5380H,0C80H,007FH,0FFFFH,6602H,7000H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
 CODE(2F40H,0008H);
 CODE(4E75H);
#elif (defined HM2)
(*$!f+:
 CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#endif
END pred;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE intpart ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 12
#endif

   fintrz.s x(sp),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,4403H,000CH);
#elif (defined HM2)
   CODE(0F22FH,4403H,000CH);
#elif (defined TDIM2)
   CODE(0F22FH,4403H,0004H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F200H,6400H); (* fmove.s FP0,D0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,6400H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,6400H,0008H);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 16
#endif

#ifdef HM2
   move.l  D2,-(SP)
#endif
   move.l  x(SP),D0
   move.l  D0,D2
   swap    D2
   andi.w  #$7f80,D2
   cmpi.w  #127+0<<7,D2
   blt.s   null
   cmpi.w  #127+23<<7,D2
   bge.s   ende
   lsr.w   #7,D2
   subi.w  #127,D2
   move.l  #$fffff000,D1
   subi.w  #11,D2
   bpl.s   shr
   neg.w   D2
   lsl.l   D2,D1
   bra.s   mask
 shr:
   asr.l   D2,D1
 mask:
   and.l   D1,D0
   bra.s   ende
 null:
   moveq   #0,D0
 ende:
#ifdef HM2
   move.l  (SP)+,D2
#endif
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(202FH,000CH);
#elif (defined HM2)
   CODE(2F02H);
   CODE(202FH,0010H);
#elif (defined TDIM2)
   CODE(202FH,0004H);
#endif
   CODE(2400H,4842H,0242H,7F80H,0C42H,3F80H);
   CODE(6D24H,0C42H,4B00H,6C20H,0EE4AH,0442H,007FH,223CH);
   CODE(0FFFFH,0F000H,0442H,000BH,6A06H,4442H,0E5A9H,6002H);
   CODE(0E4A1H,0C081H,6002H,7000H);
#ifdef HM2
   CODE(241FH);
#endif
#ifdef HM2
(*$!f+:
   CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2F40H,0008H);
   CODE(4E75H);
#endif
 END;
END intpart;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE fractpart ((* EIN/ -- *) x : REAL ): REAL;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 12
#endif

   fmove.s  x(sp),fp0
   fmovem.x fp1,-(sp)
   fintrz.x fp0,fp1
   fsub.x   fp1,fp0
   fmovem.x (sp)+,fp1
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$4,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,4400H,000CH);
#elif (defined HM2)
   CODE(0F22FH,4400H,000CH);
#elif (defined TDIM2)
   CODE(0F22FH,4400H,0004H);
#endif
   (* !!Achtung: Turbo-Assembler MAS-R19 erzeugt leere Registerliste!! *)
   CODE(0F227H,0E002H);
   CODE(0F200H,0083H);
   CODE(0F200H,0428H);
   CODE(0F21FH,0D040H);
#ifdef HM2
(*$!f-:
   CODE(0F200H,6400H); (* fmove.s fp0,d0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,6400H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,6400H,0008H);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+4
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 16
#endif

#ifdef HM2
   move.l  D2,-(SP)
#endif
   move.l  x(SP),D0
   move.l  D0,D2
   swap    D2
   lsr.w   #7,D2
   move.w  D2,D1          ; Exponent bis spaeter aufbewahren
   andi.w  #$00ff,D2      ; Vorzeichen loeschen
   cmpi.w  #127+0,D2      ; Zahl kleiner eins -> alles fractpart
   blt.s   ende
   cmpi.w  #127+23,D2     ; intpart groesser gleich 53+1 Bit -> fractpart = 0
   bge.s   null
   subi.w  #127-1,D2      ; D2 in [1..23] -- um soviele Stellen mindestens
;                           nach links schieben

; erstes gesetztes Bit von links in fractpart suchen, fuer Normalisierung.
; max. 23 - <D2> + 1 Bits testen

   subi.w  #23,D2         ; zu schiebende Stellen in Bitnummer umrechnen
   neg.w   D2             ;
 ffs:                     ; erstes gesetztes Bit in D0 suchen
   btst    D2,D0          ;
   dbne    D2,ffs         ;
   beq.s   null           ; kein Bit im fractpart gesetzt -> fractpart = 0
   subi.w  #23,D2         ; Bitnummer in zu schiebende Stellen umrechnen
   neg.w   D2             ;
   sub.w   D2,D1          ; Exponent fuer normalisierten fractpart berechnen
   lsl.w   #7,D1          ;
 tst16:
   cmpi.w  #16,D2         ; mindestens 16 Positionen nach links ?
   blt.s   shl            ; B: nein
   swap    D0             ; schnelles Linksschieben um 16 Positionen
   clr.w   D0             ;
   subi.w  #16,D2         ; 16 Positionen weniger zu schieben
 shl:
   lsl.l   D2,D0          ; restliche Positionen nach links schieben

   swap    D0             ; Exponent einfuegen
   andi.w  #$007f,D0      ;
   or.w    D1,D0          ;
   swap    D0             ;
   bra.s   ende
 null:
   moveq   #0,D0
 ende:
#ifdef HM2
   move.l  (SP)+,D2
#endif
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$4,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(202FH,000CH);
#elif (defined HM2)
   CODE(2F02H);
   CODE(202FH,0010H);
#elif (defined TDIM2)
   CODE(202FH,0004H);
#endif
   CODE(2400H,4842H,0EE4AH,3202H,0242H,00FFH);
   CODE(0C42H,007FH,6D40H,0C42H,0096H,6C38H,0442H,007EH);
   CODE(0442H,0017H,4442H,0500H,56CAH,0FFFCH,6726H,0442H);
   CODE(0017H,4442H,9242H,0EF49H,0C42H,0010H,6D08H,4840H);
   CODE(4240H,0442H,0010H,0E5A8H,4840H,0240H,007FH,8041H);
   CODE(4840H,6002H,7000H);
#ifdef HM2
   CODE(241FH);
#endif
#ifdef HM2
(*$!f+:
   CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(2F40H,0010H,4E5EH,285FH,205FH,588FH,4ED0H);
#elif (defined TDIM2)
   CODE(2F40H,0008H);
   CODE(4E75H);
#endif
 END;
END fractpart;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE scale ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) n : INTEGER  ): REAL;

BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   n      EQU 12
   x      EQU n+2
   RETURN EQU x+4
#elif (defined TDIM2)
   n      EQU 4
   x      EQU n+2
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 12
   n      EQU x+4
#endif

   fmove.s  x(sp),fp0
#if (defined HM2) && (defined __LONG_WHOLE__)
   fscale.l n(sp),fp0
#else
   fscale.w n(sp),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.s fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$6,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.s fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,4400H,000EH);
   CODE(0F22FH,5026H,000CH);
#elif (defined HM2)
   CODE(0F22FH,4400H,000CH);
#if (defined __LONG_WHOLE__)
   CODE(0F22FH,4026H,0010H);
#else
   CODE(0F22FH,5026H,0010H);
#endif
#elif (defined TDIM2)
   CODE(0F22FH,4400H,0006H);
   CODE(0F22FH,5026H,0004H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F200H,6400H); (* fmove.s fp0,d0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,6400H,0012H,4E5EH,285FH,205FH,5C8FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,6400H,000AH);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   n      EQU 12
   x      EQU n+2
   RETURN EQU x+4
#elif (defined TDIM2)
   n      EQU 4
   x      EQU n+2
   RETURN EQU x+4
#elif (defined HM2)
   x      EQU 12
   n      EQU x+4
#endif

   move.w  x(SP),D1
   move.l  #$7f80,D0
   and.w   D1,D0
   beq.s   null
   lsr.w   #7,D0
#if (defined HM2) && (defined __LONG_WHOLE__)
   add.l   n(SP),D0
#else
   add.w   n(SP),D0
#endif
   bvs.s   max
   ble.s   null
   cmpi.l  #127+127,D0
   bgt.s   max
   lsl.w   #7,D0
   andi.w  #$ffff-$7f80,D1
   or.w    D1,D0
   swap    D0
   move.w  x+2(SP),D0
   bra.s   ende
 null:
   moveq   #0,D0
   bra.s   ende
 max:
   move.l  #$ff000000,D0
   lsl.w   #1,D1
   roxr.l  #1,D0
 ende:
#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$6,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(322FH,000EH);
#elif (defined HM2)
   CODE(322FH,000CH);
#elif (defined TDIM2)
   CODE(322FH,0006H);
#endif
   CODE(203CH,0000H,7F80H,0C041H,6722H,0EE48H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(0D06FH,000CH);
#elif (defined HM2)
#ifdef __LONG_WHOLE__
   CODE(0D0AFH,0010H);
#else
   CODE(0D06FH,0010H);
#endif
#elif (defined TDIM2)
   CODE(0D06FH,0004H);
#endif
   CODE(691EH,6F18H,0C80H,0000H,00FEH,6E14H,0EF48H,0241H);
   CODE(807FH,8041H,4840H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(302FH,0010H);
#elif (defined HM2)
   CODE(302FH,000EH);
#elif (defined TDIM2)
   CODE(302FH,0008H);
#endif
   CODE(600EH,7000H,600AH,203CH,0FF00H,0000H,0E349H,0E290H);
#ifdef HM2
(*$!f+:
   CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(2F40H,0012H,4E5EH,285FH,205FH,5C8FH,4ED0H);
#elif (defined TDIM2)
   CODE(2F40H,000AH);
   CODE(4E75H);
#endif
 END;
END scale;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE trunc ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) n : INTEGER  ): REAL;

BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 n      EQU 12
 x      EQU n+2
 RETURN EQU x+4
#elif (defined TDIM2)
 n      EQU 4
 x      EQU n+2
 RETURN EQU x+4
#elif (defined HM2)
 x      EQU 16
 n      EQU x+4
#endif

 trunc:
#if (defined HM2)
   move.l  D2,-(SP)
#endif
   move.l  x(SP),D0
   move.l  D0,D2
   swap    D2
   andi.l  #$7f80,D2
   beq.s   null
   cmpi.w  #$7f80,D2
   beq.s   ende
#if (defined HM2) && (defined __LONG_WHOLE__)
   move.l  n(SP),D2
#else
   move.w  n(SP),D2
#endif
   ble.s   null
   cmpi.l  #24,D2
   bge.s   ende
   subq.w  #1,D2
   move.l  #$fffff000,D1
   subi.w  #11,D2
   bpl.s   shr1
   neg.w   D2
   lsl.l   D2,D1
   bra.s   mask1
 shr1:
   asr.l   D2,D1
 mask1:
   and.l   D1,D0
   bra.s   ende
 null:
   moveq   #0,D0
 ende:

#if (defined LPRM2) || (defined SPCM2)
   move.l  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$6,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.l  D0,RETURN(SP)
   rts
#elif (defined HM2)
   move.l  (SP)+,D2
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(202FH,000EH);
#elif (defined HM2)
 CODE(2F02H);
 CODE(202FH,0010H);
#elif (defined TDIM2)
 CODE(202FH,0006H);
#endif

 CODE(2400H,4842H,0282H,0000H,7F80H,672EH,0C42H,7F80H,672AH);

#if (defined LPRM2) || (defined SPCM2)
 CODE(342FH,000CH);
#elif (defined HM2)
#ifdef __LONG_WHOLE__
 CODE(242FH,0014H);
#else
 CODE(342FH,0014H);
#endif
#elif (defined TDIM2)
 CODE(342FH,0004H);
#endif

 CODE(6F22H,0C82H,0000H,0018H,6C1CH,5342H,223CH,0FFFFH,0F000H);
 CODE(0442H,000BH,6A06H,4442H,0E5A9H,6002H,0E4A1H,0C081H,6002H,7000H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(2F40H,0012H,4E5EH,285FH,205FH,5C8FH,4ED0H);
#elif (defined TDIM2)
 CODE(2F40H,000AH);
 CODE(4E75H);
#elif (defined HM2)
 CODE(241FH);
(*$!f+:
 CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#endif
END trunc;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE round ((* EIN/ -- *) x : REAL;
                 (* EIN/ -- *) n : INTEGER  ): REAL;

BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 n      EQU 12
 x      EQU n+2
 RETURN EQU x+4
#elif (defined TDIM2)
 n      EQU 4
 x      EQU n+2
 RETURN EQU x+4
#elif (defined HM2)
 x      EQU 20
 n      EQU x+4
#endif

round:
#if (defined HM2)
  movem.l D2/D3,-(SP)
#endif
  move.l  x(SP),D0
  move.l  D0,D2
  swap    D2
  andi.l  #$7f80,D2
  beq.s   null
  cmpi.w  #$7f80,D2
  beq.s   ende
#if (defined HM2) && (defined __LONG_WHOLE__)
  move.l  n(SP),D2
#else
  move.w  n(SP),D2
#endif
  ble.s   null
  cmpi.l  #24,D2
  bge.s   ende
  subq.w  #1,D2          ; D2: Anzahl zu erhaltender Bits [0..22]
  move.w  D2,D3          ;
  move.l  #$fffff000,D1
  subi.w  #11,D2
  bpl.s   shr
  neg.w   D2
  lsl.l   D2,D1
  bra.s   rnd
shr:
  asr.l   D2,D1
rnd:
  subi.w  #22,D3         ; Nummer des hoechstwertigen Rundungsbit
  neg.w   D3             ;
  move.w  D3,D2
  addq.w  #1,D2          ; letztes zu erhaltenden Bit, evtl. impl. Eins
  btst    D3,D0          ; hoechstwertiges Rundungsbit gesetzt ?
  beq.s   trnc           ; B: nein, kleiner 0.5, abrunden
  move.l  D1,D3          ; Maske fuer die restlichen Rundungsbit, ausser dem
  not.l   D3             ;   hoechstwertigen
  lsr.l   #1,D3          ;
  and.l   D0,D3          ; weitere Rundungsbits gesetzt ?
  bne.s   up             ; B: ja, groesser 0.5, aufrunden
; Rest genau 0.5, auf naechste GERADE Zahl runden
  cmpi.w  #23,D2         ; implizite Eins einziges zu erhaltendes Bit ?
  beq.s   up             ; B: ja, aufrunden, da ungerade
  btst    D2,D0          ; letztes zu erhaltendes Bit gesetzt ?
  beq.s   trnc           ; B: nein, nicht aufrunden
up:
  move.l  D1,D3          ; Maske fuer letztes zu erhaltendes Bit
  lsl.l   #1,D3
  eor.l   D1,D3
  add.l   D3,D0          ; Eins auf letztes zu erhaltendes Bit addieren
trnc:
  and.l   D1,D0          ; restliche Stellen abschneiden
  bra.s   ende
null:
  moveq   #0,D0
ende:

#if (defined LPRM2) || (defined SPCM2)
  move.l  D0,RETURN(SP)
  unlk    A6
  movea.l (SP)+,A4
  movea.l (SP)+,A0
  addq.l  #$6,SP
  jmp     (A0)
#elif (defined TDIM2)
  move.l  D0,RETURN(SP)
  rts
#elif (defined HM2)
  movem.l (SP)+,D2/D3
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(202FH,000EH);
#elif (defined HM2)
 CODE(48E7H,3000H);
 CODE(202FH,0014H);
#elif (defined TDIM2)
 CODE(202FH,0006H);
#endif

 CODE(2400H,4842H,0282H,0000H,7F80H,675AH,0C42H,7F80H,6756H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(342FH,000CH);
#elif (defined HM2)
#ifdef __LONG_WHOLE__
 CODE(242FH,0018H);
#else
 CODE(342FH,0018H);
#endif
#elif (defined TDIM2)
 CODE(342FH,0004H);
#endif

 CODE(6F4EH,0C82H,0000H,0018H,6C48H);
 CODE(5342H,3602H,223CH,0FFFFH,0F000H,0442H,000BH,6A06H);
 CODE(4442H,0E5A9H,6002H,0E4A1H,0443H,0016H,4443H,3403H);
 CODE(5242H,0700H,671CH,2601H,4683H,0E28BH,0C680H,660AH);
 CODE(0C42H,0017H,6704H,0500H,6708H,2601H,0E38BH,0B383H);
 CODE(0D083H,0C081H,6002H,7000H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(2F40H,0012H,4E5EH,285FH,205FH,5C8FH,4ED0H);
#elif (defined TDIM2)
 CODE(2F40H,000AH);
 CODE(4E75H);
#elif (defined HM2)
 CODE(4CDFH,000CH);
(*$!f+:
 CODE(0F200H,4400H); (* fmove.s d0,fp0 *)
 *)
#endif
END round;
#ifdef TDIM2
__PROCFRAME_ON__
#endif
#endif /* MM2 */
(*---------------------------------------------------------------------------*)

PROCEDURE synthesize ((* EIN/ -- *) expart  : INTEGER;
                      (* EIN/ -- *) frapart : REAL    ): REAL;

BEGIN
 RETURN(scale(frapart, expart));
END synthesize;

(*---------------------------------------------------------------------------*)
#ifdef MM2
__PROCFRAME_OFF__
#endif
PROCEDURE setMode ((* EIN/ -- *) m : Modes );
BEGIN
#ifndef MM2
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   m EQU 12
#elif (defined TDIM2)
   m EQU 8
#elif (defined HM2)
   m EQU 8
#endif

   moveq   #0,d0
   move.w  m(a6),d0
   fmove.l d0,fpcr
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(7000H,302EH,000CH,0F200H,9000H);
#elif (defined HM2)
   CODE(7000H,302EH,0008H,0F200H,9000H);
#elif (defined TDIM2)
   CODE(7000H,302EH,0008H,0F200H,9000H);
#endif
 END;
#endif
END setMode;

(*---------------------------------------------------------------------------*)

PROCEDURE currentMode ( ): Modes;
BEGIN
 IF hasFpu THEN
#ifdef MM2
   ASSEMBLER
     FMOVE.L FPCR,D0
#ifdef __RES_ON_STACK__
     MOVE.W  D0,(A3)+
#endif
   END;
#else
(*
#if (defined LPRM2) || (defined SPCM2)
   RETURN EQU 12
#elif (defined TDIM2)
   RETURN EQU 8
#endif

   fmove.l fpcr,d0
#if (defined LPRM2) || (defined SPCM2)
   move.w  d0,RETURN(a6)
   unlk    a6
   movea.l (sp)+,a4
   rts
#elif (defined TDIM2)
   move.w  d0,RETURN(a6)
   unlk    a6
   rts
#endif
*)
   CODE(0F200H,0B000H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(3D40H,000CH);
   CODE(4E5EH,285FH,4E75H);
#elif (defined TDIM2)
   CODE(3D40H,0008H);
   CODE(4E5EH,4E75H);
#endif
#endif
 ELSE
   RETURN(ModeNearest + PrecSingle);
 END;
END currentMode;
#ifdef MM2
__PROCFRAME_ON__
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE IsLowException ( ): BOOLEAN;
BEGIN
#ifdef ISOM2
 RETURN(EXCEPTIONS.IsCurrentSource(lowRealSource));
#else
 RETURN(FALSE);
#endif
END IsLowException;

(*===========================================================================*)

BEGIN (* LowReal *)
#ifdef TDIM2
 large := REAL(7F7FFFFFH);
#endif
#ifdef ISOM2
 EXCEPTIONS.AllocateSource(lowRealSource);
#endif
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
END LowReal.
