IMPLEMENTATION MODULE LowLong;
__IMP_SWITCHES__
__RANGECHECK_OFF__
__STACKCHECK_OFF__
__DEBUG_OFF__
#ifdef HM2
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
  lowLongSource : EXCEPTIONS.ExceptionSource;
#endif
(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

#ifdef MM2
__PROCFRAME_OFF__
(* Kein Prozedurrahmen wegen fehlender RETURN-Anweisung *)
PROCEDURE exponent ((* EIN/ -- *) x : LONGREAL ): INTEGER;
BEGIN
ASSEMBLER
  SUBQ.L  #8,A3
  MOVE.W  (A3),D0
  BEQ.S   ende
  ASR.W   #3,D0
ende:
#ifdef __LONG_WHOLE__
  EXT.L   D0
#endif
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

PROCEDURE fraction ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  ANDI.W  #$0007,-8(A3)
END;
END fraction;

(*---------------------------------------------------------------------------*)

PROCEDURE sign ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  SUBQ.L  #8,A3
  MOVE.L  #$80000007,D0
  MOVEQ   #0,D1
  AND.W   (A3),D0
  ADDQ.W  #8,D0
  SWAP    D0
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
END;
END sign;

(*---------------------------------------------------------------------------*)

PROCEDURE succ ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  TST.W   (A3)
  BEQ.S   min
  BTST    #16,D0
  BNE.S   sub
  ADDQ.L  #1,D1
  BCC.S   ende
  ADDQ.W  #1,D0
  BMI.S   ende
  ADDI.L  #$00080000,D0
  BVS.S   max
  BSET    #15,D0
  BRA.S   ende
min:
  MOVEQ   #0,D1
  MOVE.L  #$80028000,D0
  BRA.S   ende
max:
  MOVEQ   #$FFFFFFFF,D1
  MOVE.L  #$7FFAFFFF,D0
  BRA.S   ende
sub:
  SUBQ.L  #1,D1
  BCC.S   ende
  SUBQ.W  #1,D0
  BMI.S   ende
  SUBI.L  #$00080000,D0
  BVS.S   null
  BSET    #15,D0
  BRA.S   ende
null:
  MOVEQ   #0,D1
  MOVEQ   #0,D0
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
END;
END succ;

(*---------------------------------------------------------------------------*)

PROCEDURE ulp ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  SUBQ.L  #8,A3
  MOVE.W  (A3),D0
  BEQ.S   null
  SUBI.W  #47*8,D0
  BVS.S   null
  BCLR    #0,D0
  SWAP    D0
  MOVE.W  #$8000,D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
ende:
  MOVEQ   #0,D1
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
END;
END ulp;

(*---------------------------------------------------------------------------*)

PROCEDURE pred ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  TST.W   (A3)
  BEQ.S   min
  BTST    #16,D0
  BEQ.S   sub
  ADDQ.L  #1,D1
  BCC.S   ende
  ADDQ.W  #1,D0
  BMI.S   ende
  ADDI.L  #$00080000,D0
  BVS.S   max
  BSET    #15,D0
  BRA.S   ende
min:
  MOVEQ   #0,D1
  MOVE.L  #$80029000,D0
  BRA.S   ende
max:
  MOVEQ   #$FFFFFFFF,D1
  MOVE.L  #$7FFBFFFF,D0
  BRA.S   ende
sub:
  SUBQ.L  #1,D1
  BCC.S   ende
  SUBQ.W  #1,D0
  BMI.S   ende
  SUBI.L  #$00080000,D0
  BVS.S   null
  BSET    #15,D0
  BRA.S   ende
null:
  MOVEQ   #0,D1
  MOVEQ   #0,D0
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
END;
END pred;

(*---------------------------------------------------------------------------*)

PROCEDURE intpart ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  MOVE.L  D3,-(SP)
  MOVEQ   #$FFFFFFFF,D3
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  MOVE.L  D0,D2
  SWAP    D2
  ASR.W   #3,D2
  BLE.S   null
  CMPI.W  #48,D2        ; [1..47]
  BGE.S   ende
  CMPI.W  #16,D2        ; [1..16]
  BGT.S   mant2
  CLR.B   D3
  SUBI.W  #8,D2         ; [-7..8]
  BPL.S   shr1
  NEG.W   D2
  LSL.L   D2,D3
  BRA.S   mask1
shr1:
  ASR.L   D2,D3
mask1:
  AND.L   D3,D0
  MOVEQ   #0,D1
  BRA.S   ende
mant2:                  ; [17..47]
  CLR.W   D3
  SUBI.W  #32,D2        ; [-15..15]
  BPL.S   shr2
  NEG.W   D2
  LSL.L   D2,D3
  BRA.S   mask2
shr2:
  ASR.L   D2,D3
mask2:
  AND.L   D3,D1
  BRA.S   ende
null:
  MOVEQ   #0,D0
  MOVEQ   #0,D1
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
  MOVE.L  (SP)+,D3
END;
END intpart;

(*---------------------------------------------------------------------------*)

PROCEDURE fractpart ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
ASSEMBLER
  MOVE.L  D3,-(SP)
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  MOVE.L  D0,D2
  SWAP    D2
  MOVE.W  D2,D3
  ASR.W   #3,D2
  BLE.W   ende
  CMPI.W  #48,D2
  BGE.S   null
  CMPI.W  #15,D2        ; [1..15]
  BGT.S   sffs2
  SUBI.W  #15,D2
  NEG.W   D2            ; [14..0]
ffs1:
  BTST    D2,D0
  DBNE    D2,ffs1
  BEQ.S   tst2
  SUBI.W  #15,D2
  NEG.W   D2
  BRA.S   tst32
tst2:
  MOVEQ   #16,D2
sffs2:
  SUBI.W  #15+32,D2
  NEG.W   D2            ; [31..0]
ffs2:
  BTST    D2,D1
  DBNE    D2,ffs2
  BEQ.S   null
  SUBI.W  #15+32,D2
  NEG.W   D2
tst32:
  LSL.W   #3,D2
  SUB.W   D2,D3
  ASR.W   #3,D2
  CMPI.W  #32,D2
  BLT.S   tst16
  MOVE.W  D1,D0
  MOVEQ   #0,D1
  SUBI.W  #32,D2
tst16:
  CMPI.W  #16,D2
  BLT.S   tst8
  SWAP    D1
  MOVE.W  D1,D0
  CLR.W   D1
  SUBI.W  #16,D2
tst8:
  CMPI.W  #8,D2
  BLT.S   tstshl
  LSL.W   #8,D0
  ROL.L   #8,D1
  MOVE.B  D1,D0
  CLR.B   D1
  SUBQ.W  #8,D2
  BRA.S   tstshl
shl:
  ADD.L   D1,D1
  ADDX.L  D0,D0
tstshl:
  DBRA    D2,shl
  SWAP    D0
  MOVE.W  D3,D0
  SWAP    D0
  BRA.S   ende
null:
  MOVEQ   #0,D1
  MOVEQ   #0,D0
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
  MOVE.L  (SP)+,D3
END;
END fractpart;

(*---------------------------------------------------------------------------*)

PROCEDURE scale ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) n : INTEGER  ): LONGREAL;

BEGIN
ASSEMBLER
  MOVE.L  D3,-(SP)
#ifdef __LONG_WHOLE__
  MOVE.L  -(A3),D2
#else
  MOVE.W  -(A3),D2
  EXT.L   D2
#endif
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  MOVEQ   #0,D3
  SWAP    D0
  MOVE.W  D0,D3
  BEQ.S   null
  ASR.W   #3,D3
  EXT.L   D3
  ADD.L   D2,D3
  BVC.S   range
  TST.L   D2
  BMI.S   null
  BRA.S   max
range:
  CMPI.L  #4095,D3
  BGT.S   max
  CMPI.L  #-4096,D3
  BLT.S   null
  ANDI.W  #$0007,D0
  LSL.W   #3,D3
  OR.W    D3,D0
  SWAP    D0
  BRA.S   ende
null:
  MOVEQ   #0,D0
  MOVEQ   #0,D1
  BRA.S   ende
max:
  MOVEQ   #$FFFFFFFF,D1
  ANDI.W  #$0001,D0
  ORI.L   #$FFFF7FFA,D0
  SWAP    D0
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
  MOVE.L  (SP)+,D3
END;
END scale;

(*---------------------------------------------------------------------------*)

PROCEDURE trunc ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) n : INTEGER  ): LONGREAL;

BEGIN
ASSEMBLER
  MOVE.L  D3,-(SP)
  MOVEQ   #$FFFFFFFF,D3
#ifdef __LONG_WHOLE__
  MOVE.L  -(A3),D2
#else
  MOVE.W  -(A3),D2
  EXT.L   D2
#endif
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  TST.W   (A3)
  BEQ.S   null
  TST.L   D2
  BLE.S   null
  CMPI.L  #48,D2        ; [1..47]
  BGE.S   ende
  CMPI.W  #16,D2        ; [1..16]
  BGT.S   mant2
  CLR.B   D3
  SUBI.W  #8,D2         ; [-7..8]
  BPL.S   shr1
  NEG.W   D2
  LSL.L   D2,D3
  BRA.S   mask1
shr1:
  ASR.L   D2,D3
mask1:
  AND.L   D3,D0
  MOVEQ   #0,D1
  BRA.S   ende
mant2:                  ; [17..47]
  CLR.W   D3
  SUBI.W  #32,D2        ; [-15..15]
  BPL.S   shr2
  NEG.W   D2
  LSL.L   D2,D3
  BRA.S   mask2
shr2:
  ASR.L   D2,D3
mask2:
  AND.L   D3,D1
  BRA.S   ende
null:
  MOVEQ   #0,D0
  MOVEQ   #0,D1
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
  MOVE.L  (SP)+,D3
END;
END trunc;

(*---------------------------------------------------------------------------*)

PROCEDURE round ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) n : INTEGER  ): LONGREAL;

BEGIN
ASSEMBLER
#ifdef __LONG_WHOLE__
  MOVE.L  -(A3),D2
#else
  MOVE.W  -(A3),D2
  EXT.L   D2
#endif
  MOVEM.L D3/D4,-(SP)
  MOVEQ   #$FFFFFFFF,D3
  MOVE.L  -(A3),D1
  MOVE.L  -(A3),D0
  TST.W   (A3)
  BEQ.W   null
  TST.L   D2
  BLE.W   null
  CMPI.L  #48,D2
  BGE.W   ende
  MOVE.W  D2,D4         ; [1..47]
  CMPI.W  #16,D2
  BGT.S   mant2         ; [1..16]
  CLR.B   D3
  SUBQ.W  #8,D2
  BPL.S   shr1
  NEG.W   D2
  LSL.L   D2,D3
  BRA.S   rnd1
shr1:
  ASR.L   D2,D3
rnd1:
  SUBI.W  #15,D4
  NEG.W   D4            ; [14..-1]
  BMI.S   special
  MOVE.W  D4,D2         ; [14..0]
  ADDQ.W  #1,D2         ; [15..1]
  BTST    D4,D0
  BEQ.S   mask1
  MOVE.W  D3,D4
  NOT.W   D4
  LSR.W   #1,D4
  AND.W   D0,D4
  BNE.S   up1
  TST.L   D1
  BNE.S   up1
  BTST    D2,D0
  BEQ.S   mask1
up1:
  MOVE.W  D3,D4
  LSL.W   #1,D4
  EOR.W   D3,D4
  ADD.W   D4,D0
  BMI.S   mask1
ofl1:
  MOVEQ   #0,D1
ofl:
  MOVE.W  #$8000,D0
  ADDI.L  #$00080000,D0
  BVC.S   ende
  MOVEQ   #$FFFFFFFF,D1
  ANDI.L  #$00010000,D0
  ORI.L   #$7FFAFFFF,D0
  BRA.S   ende
special:
  TST.L   D1
  BPL.S   mask1
  ADD.L   D1,D1
  BNE.S   ups
  BTST    #0,D0
  BEQ.S   mask1
ups:
  ADDQ.W  #1,D0
  BPL.S   ofl1
mask1:
  AND.W   D3,D0
  MOVEQ   #0,D1
  BRA.S   ende
mant2:
  CLR.W   D3
  SUBI.W  #32,D2        ; [-15..15]
  BPL.S   shr2
  NEG.W   D2
  LSL.L   D2,D3
  BRA.S   rnd2
shr2:
  ASR.L   D2,D3
rnd2
  SUBI.W  #47,D4
  NEG.W   D4            ; [30..0]
  MOVE.W  D4,D2
  ADDQ.W  #1,D2         ; [31..1]
  BTST    D4,D1
  BEQ.S   mask2
  MOVE.L  D3,D4
  NOT.L   D4
  LSR.L   #1,D4
  AND.L   D1,D4
  BNE.S   up2
  BTST    D2,D1
  BEQ.S   mask2
up2:
  MOVE.L  D3,D4
  LSL.L   #1,D4
  EOR.L   D3,D4
  MOVEQ   #0,D2
  ADD.L   D4,D1
  AND.L   D3,D1
  ADDX.W  D2,D0
  BPL.S   ofl
mask2:
  AND.L   D3,D1
  BRA.S   ende
null:
  MOVEQ   #0,D1
  MOVEQ   #0,D0
ende:
  MOVE.L  D0,(A3)+
  MOVE.L  D1,(A3)+
  MOVEM.L (SP)+,D3/D4
END;
END round;
__PROCFRAME_ON__
#else

#ifdef TDIM2
__PROCFRAME_OFF__
(* Kein Prozedurrahmen wegen fehlender RETURN-Anweisung *)
#endif
PROCEDURE exponent ((* EIN/ -- *) x : LONGREAL ): INTEGER;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
#endif

   fgetexp.d x(sp),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.w fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.w fp0,RETURN(sp)
   rts
#elif (defined HM2)
   fmove.l fp0,d0
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,541EH,000CH);
   CODE(0F22FH,7000H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined HM2)
   CODE(0F22FH,541EH,000CH);
   CODE(0F200H,6000H);
#elif (defined TDIM2)
   CODE(0F22FH,541EH,0004H);
   CODE(0F22FH,7000H,000CH,4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
#endif

   move.w  #$7ff0,D0
   and.w   x(SP),D0
   beq.s   ende
   lsr.w   #4,D0
   subi.w  #1023,D0
 ende:
#if (defined HM2) && (defined __LONG_WHOLE__)
   ext.l   D0
#endif
#if (defined LPRM2) || (defined SPCM2)
   move.w  D0,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   move.w  D0,RETURN(SP)
   rts
#endif
*)
   CODE(303CH,7FF0H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(0C06FH,000CH);
#elif (defined HM2)
   CODE(0C06FH,000CH);
#elif (defined TDIM2)
   CODE(0C06FH,0004H);
#endif
   CODE(6706H,0E848H,0440H,03FFH);
#if (defined HM2) && (defined __LONG_WHOLE__)
   CODE(48C0H);
#endif
#if (defined LPRM2) || (defined SPCM2)
   CODE(3F40H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(3F40H,000CH,4E75H);
#endif
 END;
END exponent;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE fraction ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
#endif

   fgetman.d x(sp),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,541FH,000CH);
#elif (defined HM2)
   CODE(0F22FH,541FH,000CH);
#elif (defined TDIM2)
   CODE(0F22FH,541FH,0004H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,7400H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,7400H,000CH);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 14
#endif

#ifdef HM2
   move.w  D2,-(SP)
#endif
   movem.l x(SP),D0-D1
   swap    D0
   move.w  #$7ff0,D2
   and.w   D0,D2
   bne.s   norm
   moveq   #0,D0
   moveq   #0,D1
   bra.s   ende
 norm:
   andi.w  #$ffff-$fff0,D0
   ori.w   #$3ff0,D0
   swap    D0
 ende:
#ifdef HM2
   move.w  (SP)+,D2
#endif
#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(4CEFH,0003H,000CH);
#elif (defined HM2)
   CODE(3F02H);
   CODE(4CEFH,0003H,000EH);
#elif (defined TDIM2)
   CODE(4CEFH,0003H,0004H);
#endif
   CODE(4840H,343CH,7FF0H,0C440H);
   CODE(6606H,7000H,7200H,600AH,0240H,000FH,0040H,3FF0H,4840H);
#ifdef HM2
   CODE(341FH);
#endif
#ifdef HM2
(*$!f+:
   CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
   CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(48EFH,0003H,000CH);
   CODE(4E75H);
#endif
 END;
END fraction;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE sign ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+8
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+8
#elif (defined HM2)
 x      EQU 12
#endif

 sign:
   move.l  #$7fe00000,D0
   lsl.w   x(SP)
   roxr.l  #1,D0
   moveq   #0,D1

#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#endif
*)
 CODE(203CH,7FE0H,0000H);
#if (defined LPRM2) || (defined SPCM2)
 CODE(0E3EFH,000CH);
#elif (defined HM2)
 CODE(0E3EFH,000CH);
#elif (defined TDIM2)
 CODE(0E3EFH,0004H);
#endif

 CODE(0E290H,7200H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
 CODE(48EFH,0003H,000CH);
 CODE(4E75H);
#elif (defined HM2)
(*$!f+:
 CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
 CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#endif
END sign;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE succ ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+8
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+8
#elif (defined HM2)
 x      EQU 16
#endif

 succ:
#if (defined HM2)
   move.l  D2,-(SP)
#endif
   movem.l x(SP),D0-D1
   move.l  D0,D2
   swap    D2
   andi.w  #$7ff0,D2
   beq.s   min
   cmpi.w  #$7ff0,D2
   beq.s   ende
   tst.l   D0
   bmi.s   sub
   addq.l  #1,D1
   bcc.s   ende
   addq.l  #1,D0
   bra.s   ende
 min:
   moveq   #0,D1
   move.l  #$00100000,D0
   bra.s   ende
 sub:
   subq.l  #1,D1
   bcc.s   ende
   subq.l  #1,D0
   cmpi.l  #$800fffff,D0
   bne.s   ende
   moveq   #0,D0
   moveq   #0,D1
 ende:

#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#elif (defined HM2)
   move.l  (SP)+,D2
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(4CEFH,0003H,000CH);
#elif (defined HM2)
 CODE(2F02H);
 CODE(4CEFH,0003H,0010H);
#elif (defined TDIM2)
 CODE(4CEFH,0003H,0004H);
#endif

 CODE(2400H,4842H,0242H,7FF0H);
 CODE(6712H,0C42H,7FF0H,6728H,4A80H,6B12H,5281H,6420H);
 CODE(5280H,601CH,7200H,203CH,0010H,0000H,6012H,5381H);
 CODE(640EH,5380H,0C80H,800FH,0FFFFH,6604H,7000H,7200H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
 CODE(48EFH,0003H,000CH);
 CODE(4E75H);
#elif (defined HM2)
 CODE(241FH);
(*$!f+:
 CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
 CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#endif
END succ;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE ulp ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+8
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+8
#elif (defined HM2)
 x      EQU 12
#endif

 ulp:
   move.w  x(SP),D1
   move.w  #$7ff0,D0
   and.w   D1,D0
   beq.s   null
   cmpi.w  #1+52<<4,D0
   blt.s   null
   subi.w  #52<<4,D0
;   andi.w  #$ffff-$7fff,D1
;   or.w    D1,D0
   swap    D0
   clr.w   D0
   bra.s   ende
 null:
   moveq   #0,D0
 ende:
   moveq   #0,D1

#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
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

 CODE(303CH,7FF0H,0C041H,6710H,0C40H,0350H);
 CODE(6D0AH,0440H,0340H,4840H,4240H,6002H,7000H,7200H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
 CODE(48EFH,0003H,000CH);
 CODE(4E75H);
#elif (defined HM2)
(*$!f+:
 CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
 CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#endif
END ulp;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE pred ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 x      EQU 12
 RETURN EQU x+8
#elif (defined TDIM2)
 x      EQU 4
 RETURN EQU x+8
#elif (defined HM2)
 x      EQU 16
#endif

 pred:
#if (defined HM2)
   move.l  D2,-(SP)
#endif
   movem.l x(SP),D0-D1
   move.l  D0,D2
   swap    D2
   andi.w  #$7ff0,D2
   beq.s   min
   cmpi.w  #$7ff0,D2
   beq.s   ende
   tst.l   D0
   bpl.s   sub
   addq.l  #1,D1
   bcc.s   ende
   addq.l  #1,D0
   bra.s   ende
 min:
   moveq   #0,D1
   move.l  #$80100000,D0
   bra.s   ende
 sub:
   subq.l  #1,D1
   bcc.s   ende
   subq.l  #1,D0
   cmpi.l  #$000fffff,D0
   bne.s   ende
   moveq   #0,D0
   moveq   #0,D1
 ende:

#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#elif (defined HM2)
   move.l  (SP)+,D2
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(4CEFH,0003H,000CH);
#elif (defined HM2)
 CODE(2F02H);
 CODE(4CEFH,0003H,0010H);
#elif (defined TDIM2)
 CODE(4CEFH,0003H,0004H);
#endif

 CODE(2400H,4842H,0242H,7FF0H);
 CODE(6712H,0C42H,7FF0H,6728H,4A80H,6A12H,5281H,6420H);
 CODE(5280H,601CH,7200H,203CH,8010H,0000H,6012H,5381H);
 CODE(640EH,5380H,0C80H,000FH,0FFFFH,6604H,7000H,7200H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
 CODE(48EFH,0003H,000CH);
 CODE(4E75H);
#elif (defined HM2)
 CODE(241FH);
(*$!f+:
 CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
 CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#endif
END pred;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE intpart ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
#endif

   fintrz.d x(sp),fp0
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,5403H,000CH);
#elif (defined HM2)
   CODE(0F22FH,5403H,000CH);
#elif (defined TDIM2)
   CODE(0F22FH,5403H,0004H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,7400H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,7400H,000CH);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 20
#endif

#ifdef HM2
   movem.l D2/D3,-(SP)
#endif
   movem.l x(SP),D0/D1
   move.l  D0,D2
   swap    D2
   andi.w  #$7ff0,D2
   cmpi.w  #1023+0<<4,D2
   blt.s   null
   cmpi.w  #1023+52<<4,D2
   bge.s   ende
   lsr.w   #4,D2
   subi.w  #1023,D2
   cmpi.w  #20,D2
   bgt.s   mant2
   move.l  #$fffffc00,D1
   subi.w  #10,D2
   bpl.s   shr1
   neg.w   D2
   lsl.l   D2,D1
   bra.s   mask1
 shr1:
   asr.l   D2,D1
 mask1:
   and.l   D1,D0
   moveq   #0,D1
   bra.s   ende
 mant2:
   moveq   #$ffffffff,D3
   clr.w   D3
   subi.w  #36,D2
   bpl.s   shr2
   neg.w   D2
   lsl.l   D2,D3
   bra.s   mask2
 shr2:
   asr.l   D2,D3
 mask2:
   and.l   D3,D1
   bra.s   ende
 null:
   moveq   #0,D0
   moveq   #0,D1
 ende:
#ifdef HM2
   movem.l (SP)+,D2/D3
#endif
#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(4CEFH,0003H,000CH);
#elif (defined HM2)
   CODE(48E7H,3000H);
   CODE(4CEFH,0003H,0014H);
#elif (defined TDIM2)
   CODE(4CEFH,0003H,0004H);
#endif
   CODE(2400H,4842H,0242H);
   CODE(7FF0H,0C42H,3FF0H,6D42H,0C42H,4330H,6C40H,0E84AH);
   CODE(0442H,03FFH,0C42H,0014H,6E1AH,223CH,0FFFFH,0FC00H);
   CODE(0442H,000AH,6A06H,4442H,0E5A9H,6002H,0E4A1H,0C081H);
   CODE(7200H,601AH,76FFH,4243H,0442H,0024H,6A06H,4442H);
   CODE(0E5ABH,6002H,0E4A3H,0C283H,6004H,7000H,7200H);
#ifdef HM2
   CODE(4CDFH,000CH);
#endif
#ifdef HM2
(*$!f+:
   CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
   CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(48EFH,0003H,000CH);
   CODE(4E75H);
#endif
 END;
END intpart;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE fractpart ((* EIN/ -- *) x : LONGREAL ): LONGREAL;
BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
#endif

   fmove.d  x(sp),fp0
   fmovem.x fp1,-(sp)
   fintrz.x fp0,fp1
   fsub.x   fp1,fp0
   fmovem.x (sp)+,fp1
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   addq.l  #$8,sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,5400H,000CH);
#elif (defined HM2)
   CODE(0F22FH,5400H,000CH);
#elif (defined TDIM2)
   CODE(0F22FH,5400H,0004H);
#endif
   (* !!Achtung: Turbo-Assembler MAS-R19 erzeugt leere Registerliste!! *)
   CODE(0F227H,0E002H);
   CODE(0F200H,0083H);
   CODE(0F200H,0428H);
   CODE(0F21FH,0D040H);
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,7400H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,7400H,000CH);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   x      EQU 12
   RETURN EQU x+8
#elif (defined TDIM2)
   x      EQU 4
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 20
#endif

#ifdef HM2
   movem.l D2/D3,-(SP)
#endif
   movem.l x(SP),D0-D1
   move.l  D0,D2
   swap    D2
   lsr.w   #4,D2
   move.w  D2,D3          ; Exponent bis spaeter aufbewahren
   andi.w  #$07ff,D2      ; Vorzeichen ausblenden
   cmpi.w  #1023+0,D2     ; Zahl kleiner eins -> alles fractpart
   blt     ende
   cmpi.w  #1023+52,D2    ; intpart groesser gleich 52+1 Bit -> fractpart = 0
   bge     null
   subi.w  #1023-1,D2     ; D2 in [1..52] -- um soviele Stellen mindestens
;                           nach links schieben

; erstes gesetztes Bit von links in fractpart suchen, fuer Normalisierung.
; max. 52 - <D2> + 1 Bits testen

   cmpi.w  #20,D2
   bgt.s   sffs2          ; fractpart beginnt erst in D1
   subi.w  #20,D2         ; zu schiebende Stellen in Bitnummer umrechnen
   neg.w   D2             ;
 ffs1:                    ; erstes gesetztes Bit in D0 suchen
   btst    D2,D0          ;
   dbne    D2,ffs1        ;
   beq.s   tst2           ; in D0 kein Bit gesetzt, mit D1 versuchen
   subi.w  #20,D2         ; Bitnummer in zu schiebende Stellen umrechnen
   neg.w   D2             ;
   bra.s   tst32          ; jetzt zum Schieben
 tst2:
   move.w  #21,D2
 sffs2:
   subi.w  #20+32,D2      ; zu schiebende Stellen in Bitnummer umrechnen
   neg.w   D2             ;
 ffs2:                    ; erstes gesetztes Bit in D1 suchen
   btst    D2,D1          ;
   dbne    D2,ffs2        ;
   beq.s   null           ; kein Bit im fractpart gesetzt -> fractpart = 0
   subi.w  #20+32,D2      ; Bitnummer in zu schiebende Stellen umrechnen
   neg.w   D2             ;

 tst32:
   sub.w   D2,D3          ; Exponent fuer normalisierten fractpart berechnen
   lsl.w   #4,D3          ;
   cmpi.w  #32,D2         ; mindestens 32 Positionen nach links ?
   blt.s   tst16          ; B: nein
   move.l  D1,D0          ; schnelles Linksschieben um 32 Positionen
   moveq   #0,D1          ;
   subi.w  #32,D2         ; 32 Positionen weniger zu schieben
 tst16:
   cmpi.w  #16,D2         ; mindestens 16 Positionen nach links ?
   blt.s   tst8           ; B: nein
   swap    D0             ; schnelles Linksschieben um 16 Positionen
   swap    D1             ;
   move.w  D1,D0          ;
   clr.w   D1             ;
   subi.w  #16,D2         ; 16 Positionen weniger zu schieben
 tst8:
   cmpi.w  #8,D2          ; mindestens 8 Positionen nach links ?
   blt.s   tstshl         ; B: nein
   lsl.l   #8,D0          ; schnelles Linksschieben um 8 Positionen
   rol.l   #8,D1          ;
   move.b  D1,D0          ;
   clr.b   D1             ;
   subq.w  #8,D2          ; 8 Positionen weniger zu schieben
   bra.s   tstshl
 shl:                     ; restliche Positionen in 1-Bit-Schritten schieben
   add.l   D1,D1          ;
   addx.l  D0,D0          ;
 tstshl:
   dbra    D2,shl         ;

   swap    D0             ; Exponent einfuegen
   andi.w  #$000f,D0      ;
   or.w    D3,D0          ;
   swap    D0             ;
   bra.s   ende
 null:
   moveq   #0,D0
   moveq   #0,D1
 ende:
#ifdef HM2
   movem.l (SP)+,D2/D3
#endif
#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   addq.l  #$8,SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(4CEFH,0003H,000CH);
#elif (defined HM2)
   CODE(48E7H,3000H);
   CODE(4CEFH,0003H,0014H);
#elif (defined TDIM2)
   CODE(4CEFH,0003H,0004H);
#endif

   CODE(2400H,4842H,0E84AH);
   CODE(3602H,0242H,07FFH,0C42H,03FFH,6D00H,0090H,0C42H);
   CODE(0433H,6C00H,0084H,0442H,03FEH,0C42H,0014H,6E1AH);
   CODE(0442H,0014H,4442H,0500H,56CAH,0FFFCH,6708H,0442H);
   CODE(0014H,4442H,6018H,343CH,0015H,0442H,0034H,4442H);
   CODE(0501H,56CAH,0FFFCH,6750H,0442H,0034H,4442H,9642H);
   CODE(0E94BH,0C42H,0020H,6D08H,2001H,7200H,0442H,0020H);
   CODE(0C42H,0010H,6D0CH,4840H,4841H,3001H,4241H,0442H);
   CODE(0010H,0C42H,0008H,6D10H,0E188H,0E199H,1001H,4201H);
   CODE(5142H,6004H,0D281H,0D180H,51CAH,0FFFAH,4840H,0240H);
   CODE(000FH,8043H,4840H,6004H,7000H,7200H);
#ifdef HM2
   CODE(4CDFH,000CH);
#endif
#ifdef HM2
(*$!f+:
   CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
   CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(48EFH,0003H,0014H,4E5EH,285FH,205FH,508FH,4ED0H);
#elif (defined TDIM2)
   CODE(48EFH,0003H,000CH);
   CODE(4E75H);
#endif
 END;
END fractpart;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE scale ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) n : INTEGER  ): LONGREAL;

BEGIN
 IF hasFpu THEN
(*
#if (defined LPRM2) || (defined SPCM2)
   n      EQU 12
   x      EQU n+2
   RETURN EQU x+8
#elif (defined TDIM2)
   n      EQU 4
   x      EQU n+2
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
   n      EQU x+8
#endif

   fmove.d x(sp),fp0
#if (defined HM2) && (defined __LONG_WHOLE__)
   fscale.l n(sp),fp0
#else
   fscale.w n(sp),fp0
#endif
#if (defined LPRM2) || (defined SPCM2)
   fmove.d fp0,RETURN(sp)
   unlk    a6
   movea.l (sp)+,a4
   movea.l (sp)+,a0
   lea     10(sp),sp
   jmp     (a0)
#elif (defined TDIM2)
   fmove.d fp0,RETURN(sp)
   rts
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,5400H,000EH);
   CODE(0F22FH,5026H,000CH);
#elif (defined HM2)
   CODE(0F22FH,5400H,000CH);
#if (defined __LONG_WHOLE__)
   CODE(0F22FH,4026H,0014H);
#else
   CODE(0F22FH,5026H,0014H);
#endif
#elif (defined TDIM2)
   CODE(0F22FH,5400H,0006H);
   CODE(0F22FH,5026H,0004H);
#endif
#ifdef HM2
(*$!f-:
   CODE(0F227H,7400H); (* fmove.d fp0,-(sp) *)
   CODE(4CDFH,0003H);  (* movem.l (sp)+,d0/d1 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(0F22FH,7400H,0016H,4E5EH,285FH,205FH,4FEFH,000AH,4ED0H);
#elif (defined TDIM2)
   CODE(0F22FH,7400H,000EH);
   CODE(4E75H);
#endif
 ELSE
(*
#if (defined LPRM2) || (defined SPCM2)
   n      EQU 12
   x      EQU n+2
   RETURN EQU x+8
#elif (defined TDIM2)
   n      EQU 4
   x      EQU n+2
   RETURN EQU x+8
#elif (defined HM2)
   x      EQU 12
   n      EQU x+8
#endif

   move.w  x(SP),D1
   move.l  #$7ff0,D0
   and.w   D1,D0
   beq.s   null
   lsr.w   #4,D0
#if (defined HM2) && (defined __LONG_WHOLE__)
   add.l   n(SP),D0
#else
   add.w   n(SP),D0
#endif
   bvs.s   max
   ble.s   null
   cmpi.l  #1023+1023,D0
   bgt.s   max
   lsl.w   #4,D0
   andi.w  #$ffff-$7ff0,D1
   or.w    D1,D0
   swap    D0
   move.w  x+2(SP),D0
   move.l  x+4(SP),D1
   bra.s   ende
 null:
   moveq   #0,D0
   moveq   #0,D1
   bra.s   ende
 max:
   move.l  #$ffe00000,D0
   lsl.w   #1,D1
   roxr.l  #1,D0
   moveq   #0,D1
 ende:
#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   lea     10(SP),SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
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
   CODE(203CH,0000H,7FF0H,0C041H,672AH,0E848H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(0D06FH,000CH);
#elif (defined HM2)
#ifdef __LONG_WHOLE__
   CODE(0D0AFH,0014H);
#else
   CODE(0D06FH,0014H);
#endif
#elif (defined TDIM2)
   CODE(0D06FH,0004H);
#endif
   CODE(6924H,6F1CH,0C80H,0000H);
   CODE(07FEH,6E1AH,0E948H,0241H,800FH,8041H,4840H);
#if (defined LPRM2) || (defined SPCM2)
   CODE(302FH,0010H,222FH,0012H);
#elif (defined HM2)
   CODE(302FH,000EH,222FH,0010H);
#elif (defined TDIM2)
   CODE(302FH,0008H,222FH,000AH);
#endif
   CODE(6012H,7000H,7200H,600CH,203CH);
   CODE(0FFE0H,0000H,0E349H,0E290H,7200H);
#ifdef HM2
(*$!f+:
   CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
   CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#elif (defined LPRM2) || (defined SPCM2)
   CODE(48EFH,0003H,0016H,4E5EH,285FH,205FH,4FEFH,000AH,4ED0H);
#elif (defined TDIM2)
   CODE(48EFH,0003H,000EH);
   CODE(4E75H);
#endif
 END;
END scale;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE trunc ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) n : INTEGER  ): LONGREAL;

BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 n      EQU 12
 x      EQU n+2
 RETURN EQU x+8
#elif (defined TDIM2)
 n      EQU 4
 x      EQU n+2
 RETURN EQU x+8
#elif (defined HM2)
 x      EQU 20
 n      EQU x+8
#endif

 trunc:
#if (defined HM2)
   movem.l D2/D3,-(SP)
#endif
   movem.l x(SP),D0-D1
   move.l  D0,D2
   swap    D2
   andi.l  #$7ff0,D2
   beq.s   null
   cmpi.w  #$7ff0,D2
   beq.s   ende
#if (defined HM2) && (defined __LONG_WHOLE__)
   move.l  n(SP),D2
#else
   move.w  n(SP),D2
#endif
   ble.s   null
   cmpi.l  #53,D2
   bge.s   ende
   subq.w  #1,D2
   cmpi.w  #20,D2
   bgt.s   mant2
   move.l  #$fffffc00,D1
   subi.w  #10,D2
   bpl.s   shr1
   neg.w   D2
   lsl.l   D2,D1
   bra.s   mask1
 shr1:
   asr.l   D2,D1
 mask1:
   and.l   D1,D0
   moveq   #0,D1
   bra.s   ende
 mant2:
   moveq   #$ffffffff,D3
   clr.w   D3
   subi.w  #36,D2
   bpl.s   shr2
   neg.w   D2
   lsl.l   D2,D3
   bra.s   mask2
 shr2:
   asr.l   D2,D3
 mask2:
   and.l   D3,D1
   bra.s   ende
 null:
   moveq   #0,D0
   moveq   #0,D1
 ende:

#if (defined LPRM2) || (defined SPCM2)
   movem.l D0/D1,RETURN(SP)
   unlk    A6
   movea.l (SP)+,A4
   movea.l (SP)+,A0
   lea     10(SP),SP
   jmp     (A0)
#elif (defined TDIM2)
   movem.l D0/D1,RETURN(SP)
   rts
#elif (defined HM2)
   movem.l (SP)+,D2/D3
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(4CEFH,0003H,000EH);
#elif (defined HM2)
 CODE(48E7H,3000H);
 CODE(4CEFH,0003H,0014H);
#elif (defined TDIM2)
 CODE(4CEFH,0003H,0006H);
#endif

 CODE(2400H,4842H,0282H);
 CODE(0000H,7FF0H,6750H,0C42H,7FF0H,674EH);

#if (defined LPRM2) || (defined SPCM2)
 CODE(342FH,000CH);
#elif (defined HM2)
#ifdef __LONG_WHOLE__
 CODE(242FH,001CH);
#else
 CODE(342FH,001CH);
#endif
#elif (defined TDIM2)
 CODE(342FH,0004H);
#endif

 CODE(6F40H,0C82H,0000H,0035H,6C3CH,5342H);
 CODE(0C42H,0014H,6E1AH,223CH,0FFFFH,0FC00H,0442H,000AH);
 CODE(6A06H,4442H,0E5A9H,6002H,0E4A1H,0C081H,7200H,601AH);
 CODE(76FFH,4243H,0442H,0024H,6A06H,4442H,0E5ABH,6002H);
 CODE(0E4A3H,0C283H,6004H,7000H,7200H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(48EFH,0003H,0016H,4E5EH,285FH,205FH,4FEFH,000AH,4ED0H);
#elif (defined TDIM2)
 CODE(48EFH,0003H,000EH);
 CODE(4E75H);
#elif (defined HM2)
 CODE(4CDFH,000CH);
(*$!f+:
 CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
 CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#endif
END trunc;

(*---------------------------------------------------------------------------*)
#ifdef TDIM2
__PROCFRAME_OFF__
#endif
PROCEDURE round ((* EIN/ -- *) x : LONGREAL;
                 (* EIN/ -- *) n : INTEGER  ): LONGREAL;

BEGIN
(*
#if (defined LPRM2) || (defined SPCM2)
 n      EQU 12
 x      EQU n+2
 RETURN EQU x+8
#elif (defined TDIM2)
 n      EQU 4
 x      EQU n+2
 RETURN EQU x+8
#elif (defined HM2)
 x      EQU 24
 n      EQU x+8
#endif

round:
#if (defined HM2)
  movem.l D2-D4,-(SP)
#endif
  movem.l x(SP),D0-D1
  move.l  D0,D2
  swap    D2
  andi.l  #$7ff0,D2
  beq     null
  cmpi.w  #$7ff0,D2
  beq     ende
#if (defined HM2) && (defined __LONG_WHOLE__)
  move.l  n(SP),D2
#else
  move.w  n(SP),D2
#endif
  ble     null
  cmpi.l  #53,D2
  bge     ende
  subq.w  #1,D2
  move.w  D2,D4
  cmpi.w  #20,D2
  bgt.s   mant2
  move.l  #$fffffc00,D3
  subi.w  #10,D2
  bpl.s   shr1
  neg.w   D2
  lsl.l   D2,D3
  bra.s   rnd1
shr1:
  asr.l   D2,D3

rnd1:
  subi.w  #19,D4
  neg.w   D4
  bmi.s   special
  move.w  D4,D2
  addq.w  #1,D2         ; letztes zu erhaltendes Bit, evtl. impl. eins
  btst    D4,D0         ; hoechstwertiges Rundungsbit gesetzt ?
  beq.s   mask1         ; B: nein, kleiner 0.5, abrunden
  move.l  D3,D4         ; Maske fuer die restlichen Rundungsbits, ausser
  not.l   D4            ;   dem hoechstwertigen
  lsr.l   #1,D4         ;
  and.l   D0,D4         ; weitere Rundungsbits in oberer Mantisse gesetzt ?
  bne.s   up1           ; B: ja, groesser 0.5, aufrunden
  tst.l   D1            ; weitere Rundungsbits in unterer Mantisse gesetzt ?
  bne.s   up1           ; B: ja, groesser 0.5, aufrunden
; Rest genau 0.5 -> auf naechste GERADE Zahl runden
  cmpi.w  #20,D2        ; impl. eins einziges zu erhaltendes Bit ?
  beq.s   up1           ; B: ja, aufrunden, da ungerade
  btst    D2,D0         ; letztes zu erhaltendes Bit gesetzt ?
  beq.s   mask1         ; B: nein, abrunden
up1:
  move.l  D3,D4         ; Maske fuer letztes zu erhaltendes Bit
  lsl.l   #1,D4         ;
  eor.l   D3,D4         ;
  add.l   D4,D0         ; eins auf letztes zu erhaltendes Bit addieren
  bra.s   mask1
special:
  tst.l   D1
  bpl.s   mask1
  add.l   D1,D1
  bne.s   ups
  btst    #0,D0
  beq.s   mask1
ups:
  addq.l  #1,D0
mask1:
  and.l   D3,D0
  moveq   #0,D1
  bra.s   ende

mant2:
  moveq   #$ffffffff,D3
  clr.w   D3
  subi.w  #36,D2
  bpl.s   shr2
  neg.w   D2
  lsl.l   D2,D3
  bra.s   rnd2
shr2:
  asr.l   D2,D3

rnd2:
  subi.w  #51,D4
  neg.w   D4
  move.w  D4,D2
  addq.w  #1,D2
  btst    D4,D1
  beq.s   mask2
  move.l  D3,D4
  not.l   D4
  lsr.l   #1,D4
  and.l   D1,D4
  bne.s   up2
  btst    D2,D1
  beq.s   mask2
up2:
  move.l  D3,D4
  lsl.l   #1,D4
  eor.l   D3,D4
  moveq   #0,D2
  add.l   D4,D1
  addx.l  D2,D0

mask2:
  and.l   D3,D1
  bra.s   ende
null:
  moveq   #0,D0
  moveq   #0,D1
ende:

#if (defined LPRM2) || (defined SPCM2)
  movem.l D0/D1,RETURN(SP)
  unlk    A6
  movea.l (SP)+,A4
  movea.l (SP)+,A0
  lea     10(SP),SP
  jmp     (A0)
#elif (defined TDIM2)
  movem.l D0/D1,RETURN(SP)
  rts
#elif (defined HM2)
  movem.l (SP)+,D2-D4
#endif
*)
#if (defined LPRM2) || (defined SPCM2)
 CODE(4CEFH,0003H,000EH);
#elif (defined HM2)
 CODE(48E7H,3800H);
 CODE(4CEFH,0003H,0018H);
#elif (defined TDIM2)
 CODE(4CEFH,0003H,0006H);
#endif

 CODE(2400H,4842H,0282H);
 CODE(0000H,7FF0H,6700H,00C4H,0C42H,7FF0H,6700H,00C0H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(342FH,000CH);
#elif (defined HM2)
#ifdef __LONG_WHOLE__
 CODE(242FH,0020H);
#else
 CODE(342FH,0020H);
#endif
#elif (defined TDIM2)
 CODE(342FH,0004H);
#endif

 CODE(6F00H,00B0H,0C82H,0000H);
 CODE(0035H,6C00H,00AAH,5342H,3802H,0C42H,0014H,6E5CH);
 CODE(263CH,0FFFFH,0FC00H,0442H,000AH,6A06H,4442H,0E5ABH);
 CODE(6002H,0E4A3H,0444H,0013H,4444H,6B2AH,3404H,5242H);
 CODE(0900H,6732H,2803H,4684H,0E28CH,0C880H,660EH,4A81H);
 CODE(660AH,0C42H,0014H,6704H,0500H,671AH,2803H,0E38CH);
 CODE(0B784H,0D084H,6010H,4A81H,6A0CH,0D281H,6606H,0800H);
 CODE(0000H,6702H,5280H,0C083H,7200H,6042H,76FFH,4243H);
 CODE(0442H,0024H,6A06H,4442H,0E5ABH,6002H,0E4A3H,0444H);
 CODE(0033H,4444H,3404H,5242H,0901H,671AH,2803H,4684H);
 CODE(0E28CH,0C881H,6604H,0501H,670CH,2803H,0E38CH,0B784H);
 CODE(7400H,0D284H,0D182H,0C283H,6004H,7000H,7200H);

#if (defined LPRM2) || (defined SPCM2)
 CODE(48EFH,0003H,0016H,4E5EH,285FH,205FH,4FEFH,000AH,4ED0H);
#elif (defined TDIM2)
 CODE(48EFH,0003H,000EH);
 CODE(4E75H);
#elif (defined HM2)
 CODE(4CDFH,001CH);
(*$!f+:
 CODE(48E7H,0C000H); (* movem.l d0/d1,-(sp) *)
 CODE(0F21FH,5400H); (* fmove.d (sp)+,fp0 *)
 *)
#endif
END round;
#ifdef TDIM2
__PROCFRAME_ON__
#endif
#endif /* MM2 */
(*---------------------------------------------------------------------------*)

PROCEDURE synthesize ((* EIN/ -- *) expart  : INTEGER;
                      (* EIN/ -- *) frapart : LONGREAL ): LONGREAL;

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
   RETURN(ModeNearest + PrecDouble);
 END;
END currentMode;
#ifdef MM2
__PROCFRAME_ON__
#endif
(*---------------------------------------------------------------------------*)

PROCEDURE IsLowException ( ): BOOLEAN;
BEGIN
#ifdef ISOM2
 RETURN(EXCEPTIONS.IsCurrentSource(lowLongSource));
#else
 RETURN(FALSE);
#endif
END IsLowException;

(*===========================================================================*)
#if (defined TDIM2) || (defined MM2) || (defined SPCM2)
TYPE
  lrc = RECORD
    CASE : BOOLEAN OF
      FALSE : lr  : LONGREAL;
     |TRUE  : lc1 : LONGCARD;
              lc2 : LONGCARD;
    END;
  END;

VAR
  cast : lrc;
#endif
BEGIN (* LowLong *)
#if (defined TDIM2)
 WITH cast DO
   lc1 := 000100000H; lc2 := 000000000H; small := lr;
   lc1 := 07FEFFFFFH; lc2 := 0FFFFFFFFH; large := lr;
 END;
#elif (defined SPCM2)
 WITH cast DO
   lc1 := 000100000H; lc2 := 000000000H; small := lr;
 END;
#elif (defined MM2)
 WITH cast DO
   lc1 := 0800A8000H; lc2 := 000000000H; small := lr;
(* lc1 := 080028000H; lc2 := 000000000H; small := lr; *)
   lc1 := 07FF2FFFFH; lc2 := 0FFFFFFFFH; large := lr;
(* lc1 := 07FFAFFFFH; lc2 := 0FFFFFFFFH; large := lr; *)
 END;
#endif
#ifdef ISOM2
 EXCEPTIONS.AllocateSource(lowLongSource);
#endif
 GetFPU(fpu);
 hasFpu := (fpu.linef # 0) OR (fpu.fpu * FPUType{fpu1,fpu2} # FPUType{});
END LowLong.
