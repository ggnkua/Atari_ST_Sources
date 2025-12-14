;ST-68017 source code - ported from Run68017 on the Amiga by Kamran Karimi
;
;emulates 30.5 (!) 68020 instructions.
;
;Instructions: bra.l, extb.l, cas, pack, unpk, link.l, movec, rtd, moves,
;              move ccr,<ea>, trapcc, mulu.l, muls.l, divu.l, divs.l,
;              divul.l, divsl.l, cas2, chk.l, chk2, cmp2, bsr.l, bfchg
;              bftst, bfset, bfclr, bfextu, bfexts, bfffo, bfins,
;          (!) bcc.l (bcc.l is emulated only if branch is taken!)
;
;Only the emulated instructions can use new 68020 addressing modes.
;--------------------------------------------------------------------------
;Atari ST Version by Dan Hollis (dhollis@bitsink.UUCP)
;2/23/93 - Original port from Amiga
;2/26/93 - Added XBRA support and error checking
;Assembled with TurboASS 1.7.1 using a standard 1040ST.
;Refer to ST_68017.DOC for more information.

begin:          pea     installit(PC)   ;Address of routine
                move.w  #38,-(SP)       ;Supexec
                trap    #14
                addq.l  #6,SP           ;Fix stack

                cmpi.l  #1,error        ;Error occurred?
                beq.s   crap_out        ;Yup, then exit without install

                pea     title(PC)       ;Address of titlescreen
                move.w  #$09,-(SP)      ;GEMDOS Print Line
                trap    #1              ;Call GEMDOS
                addq.l  #6,SP           ;Fix stack

                clr.w   -(SP)           ;Null word
                move.l  #(EndIllegal-begin)+500,-(SP) ;Length of mem to protect
                move.w  #$31,-(SP)      ;Termres function
                trap    #1              ;Call GEMDOS

crap_out:       pea     error_title(PC) ;Address of error screen
                move.w  #$09,-(SP)      ;GEMDOS Print Line
                trap    #1              ;Call GEMDOS
                addq.l  #6,SP           ;Fix stack

                clr.w   -(SP)           ;GEMDOS term
                trap    #1              ;Call GEMDOS

                >PART 'Text bits - title screen, etc'
title:          DC.B 27,'E',$0D,$0A
                DC.B 27,'p | Emul68017 : The 680x0 emulator  | ',27,'q',$0D,$0A
                DC.B 27,'p| Original by Kamran Karimi (Amiga) |',27,'q',$0D,$0A
                DC.B 27,'p | Ported by Dan Hollis (Atari ST) | ',27,'q',$0D,$0A,0

error_title:    DC.B 27,'E',$0D,$0A
                DC.B 27,'p |                                 | ',27,'q',$0D,$0A
                DC.B 27,'p|          <<<< ERROR >>>>          |',27,'q',$0D,$0A
                DC.B 27,'p |   Emul68017 already installed   | ',27,'q',$0D,$0A,0
                EVEN
                ENDPART

                >PART 'Install ST_68017'
installit:      movea.l $0C,A0          ;Check for previous installation
                cmpi.l  #"ST17",-8(A0)  ;Already installed?
                beq.s   no_install      ;Yup, then exit!

                lea     $0C,A0
                move.l  (A0),baxb_oldvec ;save original 'address error' vector
                move.l  4(A0),bixb_oldvec ;save original illegal inst. vector

                move.l  #BeginAddr,(A0) ;put our new routines in!
                move.l  #BeginIllegal,4(A0)
                clr.l   error           ;No error
                rts

no_install:     move.l  #1,error        ;installation failure (already installed)
                rts
                ENDPART

                >PART 'Address exception handler'
;---------------------------------------------------------------------------
;XBRA Header Information
;---------------------------------------------------------------------------
baxb_magic:     DC.B "XBRA"     ;XBRA identifier
baxb_id:        DC.B "ST17"     ;Unique identifier
baxb_oldvec:    DS.L 1          ;old vector
;---------------------------------------------------------------------------
BeginAddr:      movem.l D0-A6,-(SP)
; move.l  ExecBase,a6
; jsr     Forbid(a6)
                movea.l 30(SP),A0
                move.l  A0,D0
                lsr.l   #1,D0
                bcs.s   OddAddr
                suba.l  #2,A0
                bra.s   TestAddr
OddAddr:        suba.l  #1,A0           ;a0 should hold an even address
TestAddr:       move.w  (A0),D0
                move.w  D0,D1
                cmpi.w  #$61FF,D1
                beq.s   B_S_R_L
                andi.w  #$F0FF,D0
                cmpi.w  #$60FF,D0
                beq.s   B_R_A_L

IllegaleAddr:   movem.l (SP)+,D0-A6
; jsr     Permit(a6)
                move.l  baxb_oldvec(PC),-(SP) ;place address of original except handler
                suba.l  #2,SP           ;as return address on the stack
                move.w  14(SP),(SP)
                bset    #5,(SP)
                bclr    #7,(SP)
                rte

B_c_c_L:                                ;bra.l and bcc.l (when executed)  are te same
B_R_A_L:        movea.l 30(SP),A0
                move.l  (A0),D0
                adda.l  D0,A0
                move.l  A0,30(SP)
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                adda.l  #8,SP           ;remove address error stack frame
                btst    #7,(SP)
                beq.s   NT00
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)         ;no trace
                bset    #5,(SP)         ;supervisor
NT00:           rte


B_S_R_L:        btst    #5,29(SP)       ;supervisor or user stack?
                bne.s   SuperMode
                movea.l 30(SP),A0
                adda.l  #1,A0
                move.l  (A0),D0
                move.l  A0,D1
                add.l   #4,D1
                move    USP,A1
                move.l  D1,(A1)
                adda.l  D0,A0
                move.l  A0,30(SP)
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                adda.l  #8,SP           ;remove address error stack frame
                btst    #7,(SP)
                beq.s   NT10
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)         ;no trace
                bset    #5,(SP)         ;supervisor
NT10:           rte

SuperMode:      movea.l 30(SP),A0
                adda.l  #1,A0
                move.l  (A0),D0
                adda.l  #4,A0
                move.l  A0,34(SP)       ;ret addr.
                adda.l  D0,A0
                move.l  A0,30(SP)       ;branch addr.
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                adda.l  #8,SP           ;remove address error stack frame
                btst    #7,(SP)         ;trace bit set at the time of error?
                beq.s   NT11
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)         ;no trace
                bset    #5,(SP)         ;supervisor
NT11:           rte

EndAddr:        ENDPART

                >PART 'Illegal instruction handler'
;---------------------------------------------------------------------------
;XBRA Header Information
;---------------------------------------------------------------------------
bixb_magic:     DC.B "XBRA"     ;XBRA identifier
bixb_id:        DC.B "ST17"     ;Unique identifier
bixb_oldvec:    DS.L 1          ;old vector
;---------------------------------------------------------------------------
BeginIllegal:   movem.l D0-A6,-(SP)     ;determining which command caused exception
; move.l  ExecBase,a6
; jsr     Forbid(a6)
                lea     StackP(PC),A3
                move.w  60(SP),D0
                btst    #13,D0
                bne.s   SupStack
                move    USP,A1
                move.l  A1,(A3)
                bra.s   StackSaved
SupStack:       move.l  SP,(A3)
                addi.l  #66,(A3)
StackSaved:     movea.l 62(SP),A0       ;a7 at the time of exception saved!
                move.w  (A0),D3
                move.w  D3,D4
                lea     WhichOne(PC),A3
                move.l  #1,(A3)         ;assume bfclr
                andi.w  #$FFC0,D3
                cmpi.w  #$ECC0,D3
                beq     B_F_C_L_R
                move.l  #2,(A3)         ;assume bfset
                cmpi.w  #$EEC0,D3
                beq     B_F_S_E_T
                move.l  #3,(A3)         ;assume bfchg
                cmpi.w  #$EAC0,D3
                beq     B_F_C_H_G
                move.l  #4,(A3)
                cmpi.w  #$EDC0,D3
                beq     B_F_F_F_O
                move.l  #5,(A3)
                cmpi.w  #$E8C0,D3
                beq     B_F_T_S_T
                move.l  #6,(A3)
                cmpi.w  #$E9C0,D3
                beq     B_F_E_X_T_U
                move.l  #7,(A3)
                cmpi.w  #$EBC0,D3
                beq     B_F_E_X_T_S
                cmpi.w  #$EFC0,D3
                beq     B_F_I_N_S
                move.w  D4,D3
                andi.w  #$F9C0,D3
                cmpi.w  #$C0,D3
                beq     CMP2_CHK2       ;chk2 or cmp2 ?
                move.w  D4,D3
                andi.w  #$F1C0,D3
                cmpi.w  #$4100,D3
                beq     C_H_K_L         ;chk.l ?
                move.w  D4,D3
                andi.w  #$FFC0,D3
                cmpi.w  #$4C40,D3
                beq     D_I_V_L         ;division ?
                move.w  D4,D3
                andi.w  #$FFC0,D3
                cmpi.w  #$4C00,D3
                beq     M_U_L_L         ;multiply ?
                move.w  D4,D3
                andi.w  #$F9FF,D3
                cmpi.w  #$08FC,D3
                beq     C_A_S_2         ;cas2 ?
                move.w  D4,D3
                andi.w  #$F9C0,D3
                cmpi.w  #$08C0,D3
                beq     C_A_S           ;cas ?
                move.w  D4,D3
                andi.w  #$F1F0,D3
                cmpi.w  #$8180,D3
                beq     U_N_P_K         ;unpk ?
                move.w  D4,D3
                andi.w  #$F1F0,D3
                cmpi.w  #$8140,D3
                beq     P_A_C_K         ;pack ?
                move.w  D4,D3
                andi.w  #$FFF8,D3
                cmpi.w  #$4808,D3
                beq     L_I_N_K_L       ;link.l
                move.w  D4,D3
                andi.w  #$F0F8,D3
                cmpi.w  #$50F8,D3       ;TRAPcc ?
                beq     T_R_A_P_C_C
                move.w  D4,D3
                andi.w  #$FE00,D3
                cmpi.w  #$4800,D3       ;EXTB ?
                beq     E_X_T_B
                move.w  D4,D3
                cmpi.w  #$4E74,D3       ;was is RTD?
                beq     R_T_D
                lsr.w   #1,D3
                cmpi.w  #$273D,D3       ;or MOVEC?
                bne.s   what1
                move.w  60(SP),D0       ;get status register
                btst    #13,D0          ;check if we were in supervisor mode when exception occured
                bne     M_O_V_E_C
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                move.l  $20,-(SP)       ;making a fake return address and SR on stack
                suba.l  #2,SP
                move.w  $06(SP),(SP)
                bset    #5,(SP)         ;supervisor mode
                bclr    #7,(SP)         ;no trace
                rte                     ;go privillage violation
what1:          move.w  D4,D3
                lsr.w   #8,D3
                cmpi.w  #$0E,D3         ;was the illegal command MOVES?
                bne.s   what2
                move.w  60(SP),D0
                btst    #13,D0          ;in supervisor mode
                bne     M_O_V_E_S
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                move.l  $20,-(SP)       ;making a fake return address and SR on stack
                suba.l  #2,SP
                move.w  $06(SP),(SP)
                bset    #5,(SP)         ;supervisor mode
                bclr    #7,(SP)         ;no trace
                rte                     ; go privillage violation
what2:          move.w  D4,D3
                lsr.w   #6,D3
                cmpi.w  #$010B,D3       ;was the instruction move ccr,<ea> ?
                beq     M_O_V_E_F_C_C_R

illegale:                               ;it was non of them so do the usual exception processing
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                move.l  bixb_oldvec(PC),-(SP) ;place address of original except handler
                suba.l  #2,SP           ;as return address on the stack
                move.w  $06(SP),(SP)
                bset    #5,(SP)
                bclr    #7,(SP)
                rte

B_F_I_N_S:      lea     Nextbfins(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     BFCommon        ;go to the common routine
Nextbfins:      andi.b  #$F0,61(SP)     ;flags cleared
                bset    #2,61(SP)       ;assume zero
                move.l  #7,D3
                move.l  D4,D1           ;d1 has width
                sub.l   #1,D1
                sub.l   D2,D3           ;d2 has offset
                sub.l   D3,D4
                sub.l   #1,D4
                move.l  D3,D6           ;counter
                movea.l 62(SP),A0
                move.w  2(A0),D0
                andi.w  #$7000,D0
                lsr.w   #7,D0
                lsr.w   #5,D0
                mulu    #4,D0
                move.l  0(SP,D0.w),D0
                btst    D1,D0
                beq.s   InsLoop
                bset    #3,61(SP)
InsLoop:        btst    D1,D0
                beq.s   ClrIns
                bclr    #2,61(SP)
                bset    D3,(A1)
                bra.s   InstDone
ClrIns:         bclr    D3,(A1)
InstDone:       sub.l   #1,D1
                sub.l   #1,D3
                sub.l   #1,D6
                bpl.s   InsLoop
                adda.l  #1,A1
                divu    #8,D4
                move.l  D4,D5
                andi.l  #$FFFF,D5
                beq.s   Noinsquote
                move.l  #7,D3
                move.l  #7,D6
                sub.l   #1,D5
                mulu    #8,D5
                swap    D4
                andi.l  #$FFFF,D4
                add.l   D5,D4
                bra.s   InsLoop
Noinsquote:     swap    D4
                tst.w   D4
                beq.s   InsDone
                move.l  D4,D6
                sub.l   #1,D6
                move.l  #7,D3
                moveq   #0,D4
                bra.s   InsLoop
InsDone:        tst.l   D7              ;if the operand was in a data register, update it
                beq.s   insModified
                movea.l 62(SP),A0
                move.w  (A0),D0
                andi.w  #$07,D0
                mulu    #4,D0
                movea.l SaveVal(PC),A1
                move.l  (A1),0(SP,D0.w)
insModified:    movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)         ;trace bit was set at the time of exception?
                beq.s   NT30
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT30:           rte



B_F_E_X_T_S:
B_F_E_X_T_U:    lea     Nextbfext(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     BFCommon
Nextbfext:      move.l  D4,D0
                moveq   #0,D7
                andi.b  #$F0,61(SP)     ;flags cleared
                bset    #2,61(SP)       ;assume zero
                move.l  #7,D3
                sub.l   D2,D3
                sub.l   D3,D4
                sub.l   #1,D4
                move.l  D3,D6           ;counter
                btst    D3,(A1)
                beq.s   ExtLoop
                bset    #3,61(SP)
ExtLoop:        btst    D3,(A1)
                beq.s   AZero
                bclr    #2,61(SP)
                bset    #0,D7
                bra.s   NextBit
AZero:          bclr    #0,D7
NextBit:        sub.l   #1,D3
                sub.l   #1,D6
                bpl.s   CommonLoop
                adda.l  #1,A1
                divu    #8,D4
                move.l  D4,D5
                andi.l  #$FFFF,D5
                beq.s   Noextquote
                move.l  #7,D3
                move.l  #7,D6
                sub.l   #1,D5
                mulu    #8,D5
                swap    D4
                andi.l  #$FFFF,D4
                add.l   D5,D4
                bra.s   CommonLoop
Noextquote:     swap    D4
                tst.w   D4
                beq.s   ExtDone
                move.l  D4,D6
                sub.l   #1,D6
                move.l  #7,D3
                moveq   #0,D4
CommonLoop:     add.l   D7,D7
                bra.s   ExtLoop
ExtDone:        move.l  WhichOne(PC),D5
                cmpi.w  #6,D5
                beq.s   Plus
                btst    #3,61(SP)
                beq.s   Plus
                move.l  #31,D5
                sub.l   D0,D5
bfexts:         bset    D0,D7
                add.l   #1,D0
                dbra    D5,bfexts
Plus:           movea.l 62(SP),A0
                move.w  2(A0),D0
                andi.w  #$7000,D0
                lsr.w   #5,D0
                lsr.w   #7,D0
                mulu    #4,D0
                move.l  D7,0(SP,D0.w)
                movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT40
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT40:           rte

B_F_T_S_T:
B_F_F_F_O:      lea     Nextbftst(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     BFCommon
Nextbftst:      move.l  BFOffset(PC),D7 ;get the offset
                sub.l   #1,D7
                move.l  D4,D0           ;width
                andi.b  #$F0,61(SP)     ;flags cleared
                bset    #2,61(SP)       ;assume zero
                move.l  #7,D3
                sub.l   D2,D3
                sub.l   D3,D4
                sub.l   #1,D4
                move.l  D3,D6           ;counter
                btst    D3,(A1)
                beq.s   TestLoop
                bset    #3,61(SP)
TestLoop:       add.l   #1,D7
                btst    D3,(A1)
                beq.s   tstDone
                bclr    #2,61(SP)
                bra.s   testDone
tstDone:        sub.l   #1,D0
                beq.s   tstDone
                sub.l   #1,D3
                sub.l   #1,D6
                bpl.s   TestLoop
                adda.l  #1,A1
                divu    #8,D4
                move.l  D4,D5
                andi.l  #$FFFF,D5
                beq.s   Notstquote
                move.l  #7,D3
                move.l  #7,D6
                sub.l   #1,D5
                mulu    #8,D5
                swap    D4
                andi.l  #$FFFF,D4
                add.l   D5,D4
                bra.s   TestLoop
Notstquote:     swap    D4
                tst.w   D4
                beq.s   testDone
                move.l  D4,D6
                sub.l   #1,D6
                move.l  #7,D3
                moveq   #0,D4
                bra.s   TestLoop
testDone:       move.l  WhichOne(PC),D5
                cmpi.w  #5,D5
                beq.s   NobfDest
                movea.l 62(SP),A0
                move.w  2(A0),D1
                andi.w  #$7000,D1
                lsr.w   #7,D1
                lsr.w   #5,D1
                mulu    #4,D1
                move.l  D7,0(SP,D1.w)
NobfDest:       adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT50
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT50:           rte



B_F_C_L_R:
B_F_S_E_T:
B_F_C_H_G:      lea     Nextbfchg(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     BFCommon
Nextbfchg:      andi.b  #$F0,61(SP)     ;flags cleared
                bset    #2,61(SP)       ;assume zero
                move.l  #7,D3
                sub.l   D2,D3
                sub.l   D3,D4
                sub.l   #1,D4
                move.l  D3,D6           ;counter
                btst    D3,(A1)
                beq.s   ChangeLoop
                bset    #3,61(SP)
ChangeLoop:     move.l  WhichOne(PC),D5
                cmpi.l  #1,D5
                bne.s   chgset
                bclr    D3,(A1)
                beq.s   chgset
                bclr    #2,61(SP)
chgset:         cmpi.l  #2,D5
                bne.s   chg
                bset    D3,(A1)
                beq.s   chg
                bclr    #2,61(SP)
chg:            cmpi.l  #3,D5
                bne.s   CLSDone
                bchg    D3,(A1)
                beq.s   CLSDone
                bclr    #2,61(SP)
CLSDone:        sub.l   #1,D3
                sub.l   #1,D6
                bpl.s   ChangeLoop
                adda.l  #1,A1
                divu    #8,D4
                move.l  D4,D5
                andi.l  #$FFFF,D5
                beq.s   Nochgquote
                move.l  #7,D3
                move.l  #7,D6
                sub.l   #1,D5
                mulu    #8,D5
                swap    D4
                andi.l  #$FFFF,D4
                add.l   D5,D4
                bra.s   ChangeLoop
Nochgquote:     swap    D4
                tst.w   D4
                beq.s   ChgDone
                move.l  D4,D6
                sub.l   #1,D6
                move.l  #7,D3
                moveq   #0,D4
                bra     ChangeLoop
ChgDone:        tst.l   D7
                beq.s   chgModified
                movea.l 62(SP),A0
                move.w  (A0),D0
                andi.w  #$07,D0
                mulu    #4,D0
                movea.l SaveVal(PC),A1
                move.l  (A1),0(SP,D0.w)
chgModified:    movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT60
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT60:           rte

CMP2_CHK2:      lea     Flag(PC),A3
                move.l  #0,(A3)
                movea.l 62(SP),A0
                move.w  (A0),D0
                move.w  D0,D4
                andi.w  #$0600,D0
                lsr.w   #7,D0
                lsr.w   #2,D0
                cmpi.w  #0,D0
                bne.s   cmplw
                move.w  #$1000,D2
                move.w  #0,D3
                move.l  #2,(A3)
                bra.s   CmpSizeDone
cmplw:          cmpi.w  #$01,D0
                bne.s   cmpl
                move.w  #$3000,D2
                move.w  #$40,D3
                move.l  #1,(A3)
                bra.s   CmpSizeDone
cmpl:           move.w  #$2000,D2
                move.w  #$80,D3
CmpSizeDone:    movea.l 62(SP),A0
                move.w  2(A0),D0
                btst    #15,D0
                beq.s   NotAddr
                addi.l  #4,(A3)         ;address should be compared long!
NotAddr:        lea     MoveCMP1(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D2,(A3)
                lea     MoveCMP2(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D2,(A3)
                lea     CMPHigh(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)
                lea     CMPLow(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)
                move.w  D4,D0
                andi.w  #$3F,D0
                lea     NumAdd(PC),A5
                lea     MoveCMP(PC),A3
                andi.w  #$FFC0,(A3)
                or.w    D0,(A3)
                move.l  #$4E714E71,2(A3)
                move.l  #4,(A5)
                cmpi.w  #$39,D0         ;abs long
                bne.s   labcmp10
                move.l  4(A0),2(A3)
                move.l  #8,(A5)
                bra     CMPDone
labcmp10:       cmpi.w  #$38,D0         ;abs short
                bne.s   labcmp20
                move.w  4(A0),2(A3)
                move.l  #6,(A5)
                bra     CMPDone
labcmp20:       cmpi.w  #$3C,D0         ;imm. data
                bne.s   labcmp30
                move.l  4(A0),2(A3)
                move.l  #8,(A5)
                bra     CMPDone
labcmp30:       cmpi.w  #$3A,D0
                bne.s   labcmp40
                move.w  4(A0),D0
                ext.l   D0
                adda.l  #4,A0
                adda.l  D0,A0
                lea     saved1(PC),A3
                move.l  A0,(A3)
                move.l  #6,(A5)
                bra     PCcmpBack
labcmp40:       cmpi.w  #$3B,D0
                bne     labcmp50
PCIndexcmp:     movea.l 62(SP),A0
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   cmpshort
                lea     BDFlag(PC),A3
                move.l  #1,(A3)
                lea     cmp13(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
cmp13:          lea     MoveCMP(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                bra     CMPDone
cmpshort:       lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #1,(A3)
                lea     cmp23(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
cmp23:          lea     MoveCMP(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                bra     CMPDone
labcmp50:       andi.w  #$38,D0
                cmpi.w  #$28,D0
                bne.s   labcmp60
                move.w  4(A0),2(A3)
                move.l  #6,(A5)
                bra     CMPDone
labcmp60:       cmpi.w  #$30,D0
                bne     labcmp70
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   cmp12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     cmp11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
cmp11:          lea     MoveCMP(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                bra.s   CMPDone
cmp12:          lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     cmp21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
cmp21:          lea     MoveCMP(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                bra.s   CMPDone
labcmp70:       cmpi.w  #$38,D0
                beq     illegale
CMPDone:        move.l  Flag(PC),D7
                cmpi.l  #4,D7
                ble.s   Not32bitAddrcmp
                move.w  #$80,D3
                lea     CMPHigh(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)
                lea     CMPLow(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)
Not32bitAddrcmp:lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                movea.l StackP(PC),SP
MoveCMP:        lea     (A1),A1         ;(a1) will be changed to propper value
                nop
                nop
                lea     SaveVal(PC),SP
                move.l  A1,(SP)         ;SaveVal has the first operand
                movea.l savea1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
PCcmpBack:      movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                move.w  2(A0),D0
                move.w  D0,D1
                andi.w  #$7000,D0
                lsr.w   #7,D0
                lsr.w   #5,D0
                mulu    #4,D0
                btst    #15,D1
                beq.s   cmpdatareg
                add.l   #32,D0
cmpdatareg:     move.l  0(SP,D0.w),D1   ;d1 has the register operand.
                lea     saved1(PC),A3
                move.l  D1,(A3)
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                move.w  60(SP),D7
                bclr    #2,D7           ;reset Z
                bclr    #0,D7           ;reset C
                move.w  D7,60(SP)
                movea.l SaveVal(PC),A1
                lea     Val1(PC),A2
                lea     Val2(PC),A3
MoveCMP1:       move.l  (A1)+,(A2)      ;lower bound
MoveCMP2:       move.l  (A1),(A3)       ;upper bound
                move.l  saved1(PC),D1   ;d1 has register operand
                move.l  Flag(PC),D7
                cmpi.l  #4,D7
                ble.s   CMPLowVal
                move.l  Val1(PC),D3
                move.l  Val2(PC),D4
                btst    #0,D7
                bne.s   extLong
                ext.w   D3
                ext.w   D4
extLong:        ext.l   D3
                ext.l   D4
                lea     Val1(PC),A3
                lea     Val2(PC),A4     ;originally lea val2(a3),a4
                move.l  D3,(A3)
                move.l  D4,(A4)
CMPLowVal:      move.w  60(SP),D7
CMPLow:         cmp.l   Val1(PC),D1
                blt.s   CMPOut
                bne.s   CMPHigh
                bset    #2,D7
CMPHigh:        cmp.l   Val2(PC),D1
                ble.s   CMPIn
CMPOut:         bset    #0,D7
                move.w  D7,60(SP)
                movea.l 62(SP),A0
                move.w  2(A0),D1
                btst    #11,D1
                beq.s   CmpBound
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                move.l  $18,-(SP)       ;go CHK,CHK2 exception routine
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
                rte

CMPIn:          bne.s   CmpBound        ;no need to go CHK,CHK2 exception!,either operands within
                bset    #2,D7           ;bounds or it was CMP2
CmpBound:       move.w  D7,60(SP)
                movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT71
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT71:           rte


C_H_K_L:        movea.l 62(SP),A0
                move.w  (A0),D0
                andi.w  #$3F,D0
                lea     NumAdd(PC),A5
                lea     MoveCHK(PC),A3
                andi.w  #$FFC0,(A3)
                or.w    D0,(A3)
                move.l  #$4E714E71,2(A3)
                move.l  #2,(A5)
                cmpi.w  #$39,D0         ;abs long
                bne.s   labchk10
                move.l  2(A0),2(A3)
                move.l  #6,(A5)
                bra     CHKDone
labchk10:       cmpi.w  #$38,D0         ;abs short
                bne.s   labchk20
                move.w  2(A0),2(A3)
                move.l  #4,(A5)
                bra     CHKDone
labchk20:       cmpi.w  #$3C,D0         ;imm. data
                bne.s   labchk30
                move.l  2(A0),2(A3)
                move.l  #6,(A5)
                bra     CHKDone
labchk30:       cmpi.w  #$3A,D0
                bne.s   labchk40
                moveq   #2,D1           ;operand size for PCRelative
                lea     NumAdd(PC),A3
                move.l  #4,(A3)
                lea     chklr(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     PCRelative
chklr:          bra     PCchkBack
labchk40:       cmpi.w  #$3B,D0
                bne.s   labchk50
                lea     NumAdd(PC),A3
                move.l  #4,(A3)
                moveq   #2,D1
                lea     chkli(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                lea     PCIndex(PC),A3
                jmp     (A3)
chkli:          bra     PCchkBack
labchk50:       andi.w  #$38,D0
                cmpi.w  #$28,D0
                bne.s   labchk60
                move.w  2(A0),2(A3)
                move.l  #4,(A5)
                bra.s   CHKDone
labchk60:       cmpi.w  #$30,D0
                bne.s   labchk70
                move.w  2(A0),D3
                btst    #8,D3
                beq.s   chk12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     chk11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #2,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
chk11:          movea.l RetAddr(PC),A1
                move.l  (A1),D3
                bra.s   PCchkBack
chk12:          lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     NumAdd(PC),A4
                move.l  #4,(A4)
                lea     chk21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #2,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
chk21:          movea.l RetAddr(PC),A1
                move.l  (A1),D3
                bra.s   PCchkBack
labchk70:       cmpi.w  #$38,D0
                beq     illegale
CHKDone:        lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                movea.l StackP(PC),SP
MoveCHK:        movea.l D0,A1           ;d0 will be changed to propper value
                nop
                nop
                lea     saved1(PC),SP
                move.l  A1,(SP)         ;saved1 has the first operand
                movea.l savea1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.l  saved1(PC),D3   ;d3 has the <ea> operand.
PCchkBack:      movea.l 62(SP),A0
                move.w  (A0),D0
                andi.w  #$0E00,D0
                lsr.w   #7,D0
                lsr.w   #2,D0
                mulu    #4,D0
                move.l  0(SP,D0.w),D1   ;d1 has the register operand.
                cmpi.l  #0,D1
                blt.s   LessZero        ;less than zero
                cmp.l   D3,D1
                bgt.s   GreatEf         ;greater than <ea>
                bra.s   DoneCHK
LessZero:       move.w  60(SP),D0
                bset    #3,D0
                move.w  D0,60(SP)
                bra.s   GoCHKTrap
GreatEf:        move.w  60(SP),D0
                bclr    #3,D0
                move.w  D0,60(SP)
GoCHKTrap:      movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                move.l  $18,-(SP)       ;go CHK,CHK2 exception processing
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
                rte
DoneCHK:        movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT80
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT80:           rte

D_I_V_L:        movea.l 62(SP),A0
                move.w  (A0),D0
                andi.w  #$3F,D0
                lea     NumAdd(PC),A5
                lea     MoveDiv(PC),A3
                andi.w  #$FFC0,(A3)
                or.w    D0,(A3)
                move.l  #$4E714E71,2(A3)
                move.l  #4,(A5)
                cmpi.w  #$39,D0         ;abs long
                bne.s   labdiv10
                move.l  4(A0),2(A3)
                move.l  #8,(A5)
                bra     DivDone
labdiv10:       cmpi.w  #$38,D0         ;abs short
                bne.s   labdiv20
                move.w  4(A0),2(A3)
                move.l  #6,(A5)
                bra     DivDone
labdiv20:       cmpi.w  #$3C,D0         ;imm. data
                bne.s   labdiv30
                move.l  4(A0),2(A3)
                move.l  #8,(A5)
                bra     DivDone
labdiv30:       cmpi.w  #$3A,D0
                bne.s   labdiv40
                moveq   #4,D1           ;operand size for PCRelative
                lea     NumAdd(PC),A3
                move.l  #6,(A3)
                lea     divr(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     PCRelative
divr:           bra     PCDivBack
labdiv40:       cmpi.w  #$3B,D0
                bne.s   labdiv50
                lea     NumAdd(PC),A3
                move.l  #6,(A3)
                moveq   #4,D1
                lea     divi(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     PCIndex
divi:           bra     PCDivBack
labdiv50:       andi.w  #$38,D0
                cmpi.w  #$28,D0
                bne.s   labdiv60
                move.w  4(A0),2(A3)
                move.l  #6,(A5)
                bra.s   DivDone
labdiv60:       cmpi.w  #$30,D0         ;index
                bne.s   labdiv70
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   div12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     div11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
div11:          movea.l RetAddr(PC),A1
                move.l  (A1),D3
                bra.s   PCDivBack
div12:          lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     div21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
div21:          movea.l RetAddr(PC),A1
                move.l  (A1),D3
                bra.s   PCDivBack
labdiv70:       cmpi.w  #$38,D0
                beq     illegale
DivDone:        lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                movea.l StackP(PC),SP
MoveDiv:        movea.l D0,A1           ;d0 will be changed to propper value
                nop
                nop
                lea     saved1(PC),SP
                move.l  A1,(SP)         ;saved1 has the first operand
                movea.l savea1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.l  saved1(PC),D3   ;d3 has the <ea> operand.(divisor)
PCDivBack:      movea.l 62(SP),A0
                move.w  2(A0),D0
                lsr.w   #7,D0
                lsr.w   #5,D0
                mulu    #4,D0
                move.l  0(SP,D0.w),D1   ;d1 has the register operand.(dividend)
                tst.l   D3
                bne.s   NotZeroDiv
                move.l  62(SP),D0
                add.l   NumAdd(PC),D0
                move.l  D0,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6     ;go division by zero
                move.l  $14,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
                rte                     ;divide by zero
NotZeroDiv:     lea     SaveVal(PC),A3
                move.l  #0,(A3)
                movea.l 62(SP),A0
                move.w  2(A0),D4
                moveq   #0,D2
                btst    #10,D4
                beq.s   TestSign
                andi.w  #$07,D4
                mulu    #4,D4
                move.l  0(SP,D4.w),D2
                move.w  2(A0),D4
TestSign:       btst    #11,D4          ;test to see if the division is signed
                beq.s   UnSignedDiv     ;if yes, make the operans positive and divide
                btst    #10,D4          ;then adjust the signs
                beq.s   Div32Div
                tst.l   D2
                bpl.s   FirstPlusDiv
                not.l   D1
                not.l   D2
                moveq   #0,D0
                add.l   #1,D1
                addx.l  D0,D2
                addi.l  #1,(A3)
                bra.s   FirstPlusDiv
Div32Div:       tst.l   D1
                bpl.s   FirstPlusDiv
                neg.l   D1
                addi.l  #1,(A3)
FirstPlusDiv:   tst.l   D3
                bpl.s   UnSignedDiv
                neg.l   D3
                addi.l  #2,(A3)
UnSignedDiv:    moveq   #0,D4           ;d2:d1 ;Dividend - quot.
                moveq   #0,D6           ;d4:d3
Div:            move.l  #64,D0          ;counter
                moveq   #0,D5           ;d6:d5 Rem.
                move    #0,CCR
                addx.l  D1,D1           ;d2:d1 Quot.
                addx.l  D2,D2
                addx.l  D5,D5
                addx.l  D6,D6
Div0:           sub.l   D3,D5
                subx.l  D4,D6
                bcc.s   Div1
                add.l   D3,D5
                addx.l  D4,D6
                move    #16,CCR         ;should go to x
Div1:           eori    #$10,CCR
                addx.l  D1,D1
                addx.l  D2,D2
                move    SR,D7
                sub.l   #1,D0
                beq.s   DoneDiv
                move    D7,CCR
                addx.l  D5,D5
                addx.l  D6,D6
                bra.s   Div0
DoneDiv:        movea.l 62(SP),A0
                move.w  2(A0),D0
                btst    #11,D0
                beq.s   UnSignedDiv2
                move.l  SaveVal(PC),D0
                tst.l   D0
                beq.s   UnSignedDiv2
                cmpi.l  #1,D0
                bne.s   DivisorNeg
                neg.l   D5              ;neg rem.
                neg.l   D1              ;and quot.
DivisorNeg:     cmpi.l  #2,D0
                bne.s   RemNeg
                neg.l   D1              ;neg quot.
RemNeg:         cmpi.l  #3,D0
                bne.s   UnSignedDiv2
                neg.l   D5              ;neg rem
UnSignedDiv2:   movea.l 62(SP),A0
                move.w  2(A0),D0
                move.w  D0,D7
                move.w  D7,D6
                andi.w  #$07,D0
                lsr.w   #7,D6
                lsr.w   #5,D6
                mulu    #4,D6
                mulu    #4,D0
                move.l  D5,0(SP,D0.w)
DivQ:           move.l  D1,0(SP,D6.w)
                move    SR,D3           ;affect the flags
                andi.w  #$0F,D3
                move.w  60(SP),D4
                andi.w  #$FFF0,D4
                or.w    D3,D4
                tst.l   D2
                beq.s   NoOverFlow
                bset    #1,D4
NoOverFlow:     move.w  D4,60(SP)
                movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT90
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT90:           rte

M_U_L_L:        movea.l 62(SP),A0
                move.w  (A0),D0
                andi.w  #$3F,D0
                lea     NumAdd(PC),A4
                lea     MoveMul(PC),A3
                andi.w  #$FFC0,(A3)
                or.w    D0,(A3)
                move.l  #$4E714E71,2(A3)
                move.l  #4,(A4)
                cmpi.w  #$39,D0         ;abs long
                bne.s   labmul10
                move.l  4(A0),2(A3)
                move.l  #8,(A4)
                bra     MulDone
labmul10:       cmpi.w  #$38,D0         ;abs short
                bne.s   labmul20
                move.w  4(A0),2(A3)
                move.l  #6,(A4)
                bra     MulDone
labmul20:       cmpi.w  #$3C,D0         ;imm. data
                bne.s   labmul30
                move.l  4(A0),2(A3)
                move.l  #8,(A4)
                bra     MulDone
labmul30:       cmpi.w  #$3A,D0
                bne.s   labmul40
                moveq   #4,D1           ;operand size for PCRelative
                lea     NumAdd(PC),A3
                move.l  #6,(A3)
                lea     mulr(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     PCRelative
mulr:           bra     PCMulBack
labmul40:       cmpi.w  #$3B,D0
                bne.s   labmul50
                lea     NumAdd(PC),A3
                move.l  #6,(A3)
                moveq   #4,D1
                lea     muli(PC),A3
                lea     Val3(PC),A4
                move.l  A3,(A4)
                bra     PCIndex
muli:           bra     PCMulBack
labmul50:       andi.w  #$38,D0
                cmpi.w  #$28,D0
                bne.s   labmul60
                move.w  4(A0),2(A3)
                move.l  #6,(A4)
                bra.s   MulDone
labmul60:       cmpi.w  #$30,D0         ;index
                bne.s   labmul70
                move.l  4(A0),D3
                btst    #8,D3
                beq.s   mul12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     mul11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
mul11:          movea.l RetAddr(PC),A1
                move.l  (A1),D3
                bra.s   PCMulBack
mul12:          lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     mul21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
mul21:          movea.l RetAddr(PC),A1
                move.l  (A1),D3
                bra.s   PCMulBack
labmul70:       cmpi.w  #$38,D0
                beq     illegale
MulDone:        lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                movea.l StackP(PC),SP
MoveMul:        movea.l D0,A1           ;d0 will be changed to propper value
                nop
                nop
                lea     saved1(PC),SP
                move.l  A1,(SP)         ;saved1 has the first operand
                movea.l savea1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.l  saved1(PC),D3   ;d3 has the <ea> operand
PCMulBack:      movea.l 62(SP),A0
                move.w  2(A0),D0
                lsr.w   #7,D0
                lsr.w   #5,D0
                mulu    #4,D0
                move.l  0(SP,D0.w),D1   ;d1 has the register operand
                movea.l 62(SP),A0
                move.w  2(A0),D4
                btst    #11,D4
                beq.s   UnSigned
                lea     SaveVal(PC),A3
                move.l  #0,(A3)
                tst.l   D1
                bpl.s   FirstPlus
                neg.l   D1
                addi.l  #1,(A3)
FirstPlus:      tst.l   D3
                bpl.s   UnSigned
                neg.l   D3
                addi.l  #1,(A3)
UnSigned:       move.l  D1,D2
                move.l  D3,D4
                mulu    D1,D3
                move.l  D3,D6
                move.l  D4,D3
                swap    D3
                mulu    D1,D3
                swap    D3
                move.w  D3,D7
                andi.l  #$FFFF0000,D3
                add.l   D3,D6
                move.l  #0,D5
                addx.l  D5,D7
                move.l  D4,D3
                swap    D1
                mulu    D1,D3
                swap    D3
                add.w   D3,D7
                addx.l  D5,D7
                andi.l  #$FFFF0000,D3
                add.l   D3,D6
                addx.l  D5,D7
                swap    D4
                swap    D2
                mulu    D2,D4
                add.l   D4,D7
                movea.l 62(SP),A0
                move.w  2(A0),D0
                btst    #11,D0          ;if the multiply is signed, change the operand
                beq.s   UnSigned2       ;size to positive. at the end, adjust the signs
                move.l  SaveVal(PC),D3
                btst    #0,D3
                beq.s   UnSigned2
                btst    #10,D0
                bne.s   NegD7
                neg.l   D6
                bra.s   UnSigned2
NegD7:          neg.l   D7
UnSigned2:      move.w  D0,D1
                move.w  D1,D2
                andi.w  #$07,D0
                lsr.w   #7,D1
                lsr.w   #5,D1
                mulu    #4,D1
                mulu    #4,D0
                moveq   #0,D5           ;flag for the size
                btst    #10,D2
                beq.s   Mul32
                move.l  D7,0(SP,D0.w)   ;high long word
                move    SR,D3           ;affect the flags
                andi.w  #$0F,D3
                move.w  60(SP),D4
                andi.w  #$FFF0,D4
                or.w    D3,D4
                move.w  D4,60(SP)
                bclr    #1,61(SP)       ;no overflow
                moveq   #1,D5
Mul32:          move.l  D6,0(SP,D1.w)   ;low long word
                beq.s   NoModifi
                bclr    #2,61(SP)       ;if low long word is not zero,then the total is not zero!
NoModifi:       tst.l   D5
                bne.s   CCRMulDone
                tst.l   D6
                move    SR,D3           ;affect the flags
                andi.w  #$0F,D3
                move.w  60(SP),D4
                andi.w  #$FFF0,D4
                or.w    D3,D4
                move.w  D4,60(SP)
                tst.l   D7
                bne.s   Over32
                bclr    #1,61(SP)       ;no overflow
                bra.s   CCRMulDone
Over32:         bset    #1,61(SP)       ;overflow
CCRMulDone:     movea.l 62(SP),A0
                adda.l  NumAdd(PC),A0
                move.l  A0,62(SP)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT100
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT100:          rte

C_A_S_2:        movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                lea     NumAdd(PC),A3
                move.l  #6,(A3)
                movea.l 66(SP),A0
                move.w  (A0),D1
                move.w  D1,D2
                andi.w  #$0600,D1
                lsr.w   #5,D1
                lsr.w   #4,D1
                cmpi.w  #2,D1
                bne.s   lng2
                move.w  #3,D1
                move.w  #1,D3
                moveq   #2,D7           ; adjust size
                bra.s   adjsize2
lng2:           move.w  #2,D1
                move.w  #2,D3
                moveq   #0,D7
adjsize2:       lsl.w   #7,D1
                lsl.w   #5,D1
                lsl.w   #6,D3           ;d1 for move ,d3 for cmp
                lea     MoveEffAddr1(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     UP1(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Mov21(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Movcas21(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Movcas22(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Comp21(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)
                lea     MoveEffAddr2(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     UP2(PC),A3
                andi.w  #$CFFF,(A3)

                or.w    D1,(A3)
                lea     Mov22(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Comp22(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)         ;operand sizes adjusted
                movea.l 66(SP),A0
                move.w  2(A0),D1
                move.w  D1,D2
                andi.w  #$7000,D1
                lsr.w   #7,D1
                lsr.w   #5,D1
                mulu    #4,D1
                btst    #15,D2
                beq.s   Cas1
                add.l   #32,D1
Cas1:           move.l  0(SP,D1.w),D5   ;d5 has the address
                movea.l D5,A4
                lea     Val1(PC),A3
MoveEffAddr1:   move.l  (A4),(A3)       ;save (r1) in Val1
                movea.l 66(SP),A0
                move.w  4(A0),D1
                move.w  D1,D2
                andi.w  #$7000,D1
                lsr.w   #7,D1
                lsr.w   #5,D1
                mulu    #4,D1
                btst    #15,D2
                beq.s   Cas2
                add.l   #32,D1
Cas2:           move.l  0(SP,D1.w),D6
                movea.l D6,A4
                lea     Val2(PC),A3
MoveEffAddr2:   move.l  (A4),(A3)       ;save (r2) in Val2
                movea.l 66(SP),A0
                move.w  2(A0),D1
                andi.w  #$07,D1
                mulu    #4,D1
                move.l  0(SP,D1.w),D0
Movcas21:       move.l  Val1(PC),D1
Comp21:         cmp.l   D0,D1           ;compare savea1 to dc
                lea     SaveVal(PC),A3
                move    SR,(A3)
                bne.s   NotEQ21
                movea.l 66(SP),A0
                move.w  4(A0),D1
                andi.w  #$07,D1
                mulu    #4,D1
                move.l  0(SP,D1.w),D0
Movcas22:       move.l  Val2(PC),D1
Comp22:         cmp.l   D0,D1           ;compare savea1 to dc2
                lea     SaveVal(PC),A3
                move    SR,(A3)
                bne.s   NotEQ21
                movea.l 66(SP),A0
                move.w  2(A0),D1
                andi.w  #$01C0,D1
                lsr.w   #6,D1
                mulu    #4,D1
                add.l   D7,D1
                movea.l D5,A3
Mov21:          move.l  0(SP,D1.w),(A3) ;move du1 to (r1)
                movea.l 66(SP),A0
                move.w  4(A0),D1
                andi.w  #$01C0,D1
                lsr.w   #6,D1
                mulu    #4,D1
                add.l   D7,D1
                movea.l D6,A3
Mov22:          move.l  0(SP,D1.w),(A3) ;move du2 to (r2)
                bra.s   CASDone21
NotEQ21:        movea.l 66(SP),A0
                move.w  2(A0),D1
                andi.w  #$07,D1
                mulu    #4,D1
                add.l   D7,D1
                movea.l D5,A3
UP1:            move.l  (A3),0(SP,D1.w) ;(r1) to dc1
NotEQ22:        movea.l 66(SP),A0
                move.w  4(A0),D1
                andi.w  #$07,D1
                mulu    #4,D1
                add.l   D7,D1
                movea.l D6,A3
UP2:            move.l  (A3),0(SP,D1.w)
CASDone21:      move.w  SaveVal(PC),D3
                andi.l  #$0F,D3
                move.w  64(SP),D2
                andi.w  #$FFF0,D2
                or.w    D2,D3
                move.w  D3,64(SP)
                move.l  66(SP),D4
                add.l   NumAdd(PC),D4
                move.l  D4,66(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                btst    #7,(SP)
                beq.s   NT110
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT110:          rte

C_A_S:          movea.l 62(SP),A0
                move.w  (A0),D1
                move.w  D1,D2
                andi.w  #$0600,D1
                lsr.w   #5,D1
                lsr.w   #4,D1
                move.w  #0,D3
                cmpi.w  #1,D1
                beq.s   adjsize
longword:       cmpi.w  #2,D1
                bne.s   lng
                move.w  #3,D1
                move.w  #1,D3
                bra.s   adjsize
lng:            move.w  #2,D1
                move.w  #2,D3
adjsize:        lsl.w   #7,D1
                lsl.w   #5,D1
                lsl.w   #6,D3
                lea     EffAddr(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     NotEQ(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Mov(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)

                lea     Comp(PC),A3
                andi.w  #$FE3F,(A3)
                or.w    D3,(A3)
                lea     Movd01(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)
                lea     Movd02(PC),A3
                andi.w  #$CFFF,(A3)
                or.w    D1,(A3)         ;operand sizes adjustecd

                move.w  D2,D1
                andi.w  #$3F,D1
                lea     EffAddr(PC),A3
                andi.w  #$FFC0,(A3)
                or.w    D1,(A3)
                lea     NotEQ(PC),A3
                andi.w  #$FFC0,(A3)
                or.w    D1,(A3)
                andi.w  #$07,D1
                andi.w  #$38,D2
                lsl.w   #2,D1
                lsl.w   #7,D1
                lsl.w   #3,D2
                or.w    D2,D1
                lea     Mov(PC),A3
                lea     NumAdd(PC),A4
                lea     NotEQ(PC),A5
                move.l  #$4E714E71,2(A3)
                lea     EffAddr(PC),A6
                move.l  #$4E714E71,2(A6)
                andi.w  #$F03F,(A3)
                or.w    D1,(A3)
                lsr.w   #6,D2
                cmpi.w  #$05,D2
                bne.s   tst21
                move.l  #6,(A4)         ;it is address reg. indirect with displ.
                move.w  4(A0),2(A3)
                move.w  4(A0),2(A6)
                move.w  4(A0),2(A5)
                bra     Here71
tst21:          cmpi.w  #$06,D2
                bne     tst31
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   her12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     her11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
her11:          lea     Mov(PC),A3      ;Modify necessary insructions
                lea     NotEQ(PC),A5
                lea     EffAddr(PC),A6
                move.l  RetAddr(PC),2(A3)
                move.l  RetAddr(PC),2(A6)
                move.l  RetAddr(PC),2(A5)
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                andi.w  #$FFC0,(A5)
                ori.w   #$39,(A5)
                andi.w  #$FFC0,(A6)
                ori.w   #$39,(A6)
                bra     Here71
her12:          lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     her21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
her21:          lea     Mov(PC),A3
                lea     NotEQ(PC),A5
                lea     EffAddr(PC),A6
                move.l  RetAddr(PC),2(A3)
                move.l  RetAddr(PC),2(A6)
                move.l  RetAddr(PC),2(A5)
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                andi.w  #$FFC0,(A5)
                ori.w   #$39,(A5)
                andi.w  #$FFC0,(A6)
                ori.w   #$39,(A6)
                bra.s   Here71
tst31:          lsr.w   #6,D1
                cmpi.w  #$07,D1
                bne.s   tst41
                move.l  #6,(A4)
                move.w  4(A0),2(A3)
                move.w  4(A0),2(A6)
                move.w  4(A0),2(A5)
                bra.s   Here71
tst41:          cmpi.w  #$0F,D1
                bne.s   tst51
                move.l  #8,(A4)
                move.l  4(A0),2(A3)
                move.l  4(A0),2(A6)
                move.l  4(A0),2(A5)
                bra.s   Here71
tst51:          move.l  #4,(A4)
Here71:         movea.l 62(SP),A0
                move.w  2(A0),D4
                move.w  D4,D5
                andi.w  #$07,D4
                lsl.w   #7,D4
                lsl.w   #2,D4
                lea     NotEQ(PC),A3
                andi.w  #$F1FF,(A3)
                or.w    D4,(A3)
                andi.w  #$01C0,D5
                lsr.w   #6,D5
                lea     Mov(PC),A3
                andi.w  #$FFF8,(A3)
                or.w    D5,(A3)
                lea     SaveVal(PC),A3
                move.l  #0,(A3)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     saved0(PC),SP
                move.l  D0,(SP)
                movea.l StackP(PC),SP
EffAddr:        move.l  D0,D0           ;move <ea> to savea1
                nop
                nop
                lea     savea1(PC),SP
Movd01:         move.l  D0,(SP)         ;place the operand in savea1
                move.l  saved0(PC),D0
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                movea.l 62(SP),A0
                move.w  2(A0),D0
                andi.w  #7,D0
                mulu    #4,D0
                move.l  0(SP,D0.w),D1
Movd02:         move.l  savea1(PC),D0
Comp:           cmp.l   D1,D0           ;compare savea1 to dc
                lea     SaveVal(PC),A3
                move    SR,(A3)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     saved1(PC),SP
                move.l  D1,(SP)
                move.w  SaveVal(PC),D1
                btst    #2,D1           ; Z = 0?
                beq.s   NE
                movea.l StackP(PC),SP
                move.l  saved1(PC),D1
Mov:            move.l  D0,D0           ;move du to <ea>
                nop
                nop
                bra.s   CASDone
NE:             move.l  saved1(PC),D1
NotEQ:          move.l  D0,D1           ;d0 to <ea>, d1 to dc
                nop
                nop
CASDone:        movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.w  SaveVal(PC),D3
                andi.w  #$0F,D3
                move.w  60(SP),D2
                andi.w  #$FFF0,D2
                or.w    D2,D3
                move.w  D3,60(SP)
                move.l  62(SP),D4
                add.l   NumAdd(PC),D4
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT120
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT120:          rte

U_N_P_K:        movea.l 62(SP),A0
                move.w  (A0),D1
                move.w  D1,D2
                andi.w  #$08,D1
                beq.s   datareg
                move.w  #32,D3
                bra.s   lab10
datareg:        move.w  #0,D3
lab10:          move.w  D2,D1
                andi.w  #$07,D1
                or.w    D3,D1           ;get source
                lea     Source(PC),A1
                andi.w  #$FFC0,(A1)
                or.w    D1,(A1)
                move.w  D2,D1
                andi.w  #$0E00,D1
                lsl.w   #3,D3
                or.w    D3,D1
                lea     Dest(PC),A1
                andi.w  #$F03F,(A1)
                or.w    D1,(A1)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     saved1(PC),SP
                move.l  D1,(SP)
                movea.l StackP(PC),SP
Source:         move.b  D0,D1           ; move.b  d0,(a7)
                lea     SaveVal(PC),SP
                move.b  D1,(SP)
                move.l  saved1(PC),D1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.b  SaveVal(PC),D5
                move.w  D5,D4
                andi.w  #$0F,D5
                andi.w  #$F0,D4
                lsl.w   #4,D4
                or.w    D4,D5
                movea.l 62(SP),A0
                move.w  2(A0),D1
                add.w   D1,D5
                lea     Dest(PC),A3
                move.w  D5,2(A3)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                movea.l StackP(PC),SP
Dest:           move.w  #$00,D0
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                move.l  22(SP),D0
                add.l   #4,D0
                move.l  D0,22(SP)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT130
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT130:          rte

P_A_C_K:        movea.l 62(SP),A0
                move.w  (A0),D1
                move.w  D1,D2
                andi.w  #$08,D1
                beq.s   datareg20
                move.w  #32,D3
                bra.s   lab100
datareg20:      move.w  #0,D3
lab100:         move.w  D2,D1
                andi.w  #$07,D1
                or.w    D3,D1           ;get source
                lea     Source20(PC),A1
                andi.w  #$FFC0,(A1)
                or.w    D1,(A1)
                move.w  D2,D1
                andi.w  #$0E00,D1
                lsl.w   #3,D3
                or.w    D3,D1
                lea     Dest20(PC),A1
                andi.w  #$F03F,(A1)
                or.w    D1,(A1)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     saved1(PC),SP
                move.l  D1,(SP)
                movea.l StackP(PC),SP
Source20:       move.w  D0,D1           ; move.w  d0,(a7)
                lea     SaveVal(PC),SP
                move.w  D1,(SP)
                move.l  saved1(PC),D1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.w  SaveVal(PC),D5
                movea.l 62(SP),A0
                move.w  2(A0),D1
                add.w   D1,D5
                move.w  D5,D6
                andi.w  #$0F00,D6
                lsr.w   #4,D6
                andi.w  #$0F,D5
                or.w    D6,D5
                lea     Dest20(PC),A3
                move.w  D5,2(A3)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                movea.l StackP(PC),SP
Dest20:         move.b  #0,D0
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                move.l  22(SP),D0
                add.l   #4,D0
                move.l  D0,22(SP)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT140
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT140:          rte

L_I_N_K_L:      movea.l 62(SP),A0
                move.w  (A0),D1
                andi.w  #$07,D1
                lea     RetAddr(PC),A3
                move.l  62(SP),(A3)
                lea     MySR(PC),A3
                move.w  60(SP),D0
                move.w  D0,(A3)
                btst    #13,D0
                bne.s   SuperS1         ;supervisor or user stack?
                move    USP,A1
                lea     savea1(PC),A3   ;save USP
                move.l  A1,(A3)
                suba.l  #4,A1
                lea     MySP(PC),A3
                move    A1,USP
                move.l  A1,(A3)
                bra.s   DoOr
SuperS1:        lea     savea1(PC),A3
                move.l  SP,D5
                move.l  D5,(A3)
                addi.l  #66,(A3)        ;66 - 4 = 62
                lea     MySP(PC),A3
                move.l  D5,(A3)
                addi.l  #62,(A3)
DoOr:           cmpi.w  #1,D1
                beq.s   lab2
                lea     mova1(PC),A2
                andi.w  #$FFF8,(A2)
                or.w    D1,(A2)+
                lsl.w   #7,D1
                lsl.w   #2,D1
                andi.w  #$F0FF,(A2)
                or.w    D1,(A2)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)         ;save a7
                movem.l (SP)+,D0-A6
                lea     saved1(PC),SP
                move.l  A1,(SP)
                movea.l savea1(PC),A1
mova1:          move.l  A0,-(A1)
                movea.l MySP(PC),A0
                movea.l saved1(PC),A1
                bra.s   lab1
lab2:           lea     SaveA7(PC),A3
                move.l  SP,(A3)         ;save a7
                movem.l (SP)+,D0-A6
                lea     saved1(PC),SP
                move.l  A0,(SP)
                movea.l savea1(PC),A0
mova0:          move.l  A1,-(A0)
                movea.l MySP(PC),A1
                movea.l saved1(PC),A0
lab1:           movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                movea.l RetAddr(PC),A0
                adda.l  #2,A0
                move.l  (A0),D1
                move.w  MySR(PC),D3
                btst    #13,D3
                bne.s   SuperS2
                move    USP,A1
                adda.l  D1,A1
                move    A1,USP
                bra.s   fin
SuperS2:        lea     saved1(PC),A3
                move.l  D1,(A3)
                movem.l (SP)+,D0-A6
                movea.l MySP(PC),SP
                adda.l  saved1(PC),SP
                move.l  RetAddr(PC),-(SP)
                addi.l  #6,(SP)         ;link.l requires 6 bytes.
                move.w  MySR(PC),-(SP)
                movem.l D0-A6,-(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT150
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT150:          rte

fin:            move.l  RetAddr(PC),D0
                add.l   #6,D0
                move.l  D0,62(SP)
                move.w  MySR(PC),D0
                move.w  D0,60(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT160
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT160:          rte


T_R_A_P_C_C:    movea.l 62(SP),A0
                move.w  (A0),D0
                move.w  D0,D4
                andi.w  #$0F00,D0
                lea     bcond(PC),A1
                andi.w  #$F0FF,(A1)
                or.w    D0,(A1)
                andi.w  #$07,D4
                cmpi.w  #4,D4           ;has a operand
                bne.s   HasOp
                moveq   #2,D6
                bra.s   OpFound
HasOp:          cmpi.w  #2,D4           ;is the operand word?
                bne.s   long
                moveq   #4,D6
                bra.s   OpFound
long:           cmpi.w  #3,D4
                beq.s   Found
                bra     illegale
Found:          moveq   #6,D6
OpFound:        cmpi.w  #$0100,D0       ;is it trapf?
                beq.s   Exit1
                cmpi.w  #$00,D0         ;is it trapt?
                beq.s   GoTrap
                move.w  60(SP),D0
                move    D0,CCR
                nop                     ;force the cpu to use the original status register
bcond:          bcs.s   GoTrap
Exit1:          move.l  62(SP),D4
                add.l   D6,D4
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT170
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT170:          rte

GoTrap:         move.l  62(SP),D2
                add.l   D6,D2
                move.l  D2,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                move.l  $1C,-(SP)       ;place address of original except handler
                suba.l  #2,SP           ;as return address on the stack
                move.w  $06(SP),(SP)
                bset    #5,(SP)
                bclr    #7,(SP)
                rte

E_X_T_B:        movea.l 62(SP),A0
                move.w  (A0),D5
                andi.w  #$07,D5
                mulu    #4,D5
                move.l  0(SP,D5.w),D2   ;get the operand in d2
                ext.w   D2
                ext.l   D2              ;extend it
                move    SR,D0
                andi.w  #$0F,D0
                move.w  60(SP),D1
                andi.w  #$FFF0,D1
                or.w    D0,D1
                move.w  D1,60(SP)
                move.l  D2,0(SP,D5.w)
                move.l  62(SP),D4       ;get the address of the extb.l instruction
                add.l   #2,D4           ;add 2 so that execution begins with the next opcode
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT180
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT180:          rte

R_T_D:          movea.l 62(SP),A0       ;Syntax: rtd  #<data>
                moveq   #0,D0
                move.w  2(A0),D0        ;d0 = #<data>
                ext.l   D0
                move.w  60(SP),D1
                btst    #13,D1          ;which stack we were using befor the exception?
                bne.s   SuperStack
                move    USP,A6
                move.l  (A6)+,62(SP)    ;place return address on the usp as the except return
                adda.l  D0,A6           ;address on top of the ssp so we'll return there
;then add  the number of bytes appropriate to the usp
                move    A6,USP
                bra.s   EndIt
SuperStack:     movea.l SP,A6
                adda.l  #70,A6          ;60=15 regs*4,2 for SR,4 for illegal inst,addr,4for ret addr
                adda.l  D0,A6
                move.l  66(SP),-(A6)    ;retun address for rtd
                move.w  60(SP),-(A6)    ;SR
                move.l  #14,D4          ;15 regs
                adda.l  #60,SP
cop:            move.l  -(SP),-(A6)
                dbra    D4,cop
                movea.l A6,SP
EndIt:
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT190
                move.l  $24,-(SP)

                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT190:          rte

M_O_V_E_C:      movem.l (SP)+,D0-A6     ;Syntax:movec CR,Rn or movec Rn,CR (CR=a control register)
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                move.w  (A0),D3         ;this is the illegal instruction
                btst    #0,D3
                bne     ToCR
                move.w  2(A0),D3
                move.w  D3,D4
                andi.w  #$7000,D3
                lsr.w   #7,D3
                lsr.w   #5,D3           ;d3 has the register number
                mulu    #4,D3
                btst    #15,D4
                beq.s   DatReg
                add.l   #32,D3
DatReg:         andi.w  #$0FFF,D4       ;get the control register
                cmpi.w  #$00,D4         ;is it SFC?
                bne.s   nextt1
                movea.l MySFC(PC),A1    ;put its contents in a1
                bra.s   Here1
nextt1:         cmpi.w  #$01,D4         ;is it DFC?
                bne.s   nextt2
                movea.l MyDFC(PC),A1    ;put it in a1
                bra.s   Here1
nextt2:         cmpi.w  #$0800,D4       ;is it USP?
                bne.s   nextt3
                move    USP,A1          ;put it in a1
                bra.s   Here1
nextt3:         cmpi.w  #$02,D4         ;is it CACR?
                bne.s   nextt4
                movea.l MyCACR(PC),A1   ;put it in a1
                bra.s   Here1
nextt4:         cmpi.w  #$0802,D4       ;is it CAAR?
                bne.s   nextt5
                movea.l MyCAAR(PC),A1   ;put it in a1
                bra.s   Here1
nextt5:         cmpi.w  #$0803,D4       ;is it MSP?
                beq.s   ssp1
                cmpi.w  #$0804,D4       ;or ISP?
                bne.s   nextt6
ssp1:           movea.l SP,A1
                adda.l  #70,A1          ;don't consider the pushed registers!
                bra.s   Here1
nextt6:         cmpi.w  #$0801,D4       ;is it VBR ?
                beq.s   mvbr
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                bra     illegale
mvbr:           movea.l MyVBR(PC),A1    ; put it in a1
Here1:          move.l  A1,0(SP,D3.w)   ;put in actual reg.putting in a7 has no effect
                move.l  66(SP),D4       ;get the address of the movec instruction
                add.l   #4,D4           ;add 4 so that execution begins with the next opcode
                move.l  D4,66(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                btst    #7,(SP)
                beq.s   NT200
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT200:          rte

ToCR:           move.w  2(A0),D3
                move.w  D3,D4
                andi.w  #$7000,D3
                lsr.w   #7,D3
                lsr.w   #5,D3
                mulu    #4,D3
                btst    #15,D4
                beq.s   DatReg2
                add.l   #32,D3
DatReg2:        move.l  0(SP,D3.w),D1   ;get the value in d1
                lea     saved1(PC),A3
                move.l  D1,(A3)
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                move.l  saved1(PC),D1
                movea.l 62(SP),A0
                move.w  2(A0),D4
                andi.w  #$0FFF,D4
                cmpi.w  #$00,D4
                bne.s   nextr1
                lea     MySFC(PC),A3
                andi.l  #$07,D1
                move.l  D1,(A3)
                bra     here2
nextr1:         cmpi.w  #$01,D4
                bne.s   nextr2
                lea     MyDFC(PC),A3
                andi.l  #$07,D1
                move.l  D1,(A3)
                bra     here2
nextr2:         cmpi.w  #$0800,D4
                bne.s   nextr3
                movea.l D1,A2
                move    A2,USP
nextr3:         cmpi.w  #$02,D4
                bne.s   nextr4
                lea     MyCACR(PC),A3
                andi.l  #$0F,D1
                move.l  D1,(A3)
                bra     here2
nextr4:         cmpi.w  #$0802,D4
                bne.s   nextr5
                lea     MyCAAR(PC),A3
                move.l  D1,(A3)
                bra     here2
nextr5:         cmpi.w  #$0803,D4
                beq.s   ssp2
                cmpi.w  #$0804,D4
                bne.s   nextr6
ssp2:           lea     saved1(PC),A3
                move.l  D1,(A3)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                movea.l saved1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                move.l  2(SP),-(A1)     ;return address
                move.w  (SP),-(A1)      ;status register
                movea.l A1,SP
                movea.l savea1(PC),A1
                movem.l D0-A6,-(SP)
                bra.s   here2
nextr6:         cmpi.w  #$0801,D4
                bne     illegale
mvbr2:          lea     MyVBR(PC),A3
                move.l  D1,(A3)
                bne.s   NotZero         ;if new address not zero then copy the 1024 bytes at the
                movea.l #0,A5           ;VBR address to the locations 0-1024
                movea.l NewVec(PC),A4
                move.l  #511,D4
copy3:          move.w  (A4)+,(A5)+
                dbra    D4,copy3
                bra.s   here2
NotZero:        movea.l MyVBR(PC),A4    ;if the VBR holds 0,then copy the original vectors in
                movea.l #0,A5           ;in its place
                move.l  #511,D4
copy4:          move.w  (A4)+,(A5)+
                dbra    D4,copy4
here2:          move.l  62(SP),D4
                add.l   #4,D4
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT210
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT210:          rte

M_O_V_E_S:      movem.l (SP)+,D0-A6     ;Syntax:moves Rn,<ea> or moves <ea>,Rn
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                move.w  2(A0),D3
                btst    #11,D3
                beq     ea2Rn
                lea     MovSREf(PC),A3
                andi.w  #$F03F,(A3)
                move.w  (A0),D4
                andi.w  #$3F,D4
                move.w  D4,D3
                andi.w  #$07,D3
                andi.w  #$38,D4
                lsl.w   #7,D3
                lsl.w   #2,D3
                lsl.w   #3,D4
                or.w    D3,D4
                or.w    D4,(A3)
                move.w  (A0),D4
                andi.w  #$3F,D4
                lea     NumAdd(PC),A4
                move.l  #$4E714E71,4(A3)
                move.l  #4,(A4)
                cmpi.w  #$38,D4
                bne.s   MVS10
                move.w  4(A0),4(A3)
                move.l  #6,(A4)
                bra     EffFound
MVS10:          cmpi.w  #$39,D4
                bne.s   MVS20
                move.l  4(A0),4(A3)
                move.l  #8,(A4)
                bra     EffFound
MVS20:          andi.w  #$38,D4
                cmpi.w  #$28,D4
                bne.s   MVS30
                move.w  4(A0),4(A3)
                move.l  #6,(A4)
                bra     EffFound
MVS30:          cmpi.w  #$30,D4         ;index
                bne     MVS40
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   legalMoves1
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     mvs11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
mvs11:          movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                lea     MovSREf(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                movea.l 62(SP),A0
                bra.s   EffFound
legalMoves1:    movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     mvs21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
mvs21:          movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                lea     MovSREf(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                movea.l 62(SP),A0
                bra.s   EffFound
MVS40:          cmpi.w  #$28,D4
                bne.s   EffFound
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                bra     illegale
EffFound:       move.w  (A0),D3         ;first word in d3
                andi.w  #$C0,D3         ;determine operation size (.B, .W or .L)
                lsr.w   #6,D3
                cmpi.w  #0,D3
                bne.s   wl
                move.w  #$1000,D2
                move.l  #24,D7          ;byte operation, so shift mem. loc. SaveVal, 24 bits
                bra.s   size1
wl:             cmpi.w  #1,D3           ;Word or Long
                bne.s   l
                move.w  #$3000,D2
                move.l  #16,D7
                bra.s   size1
l:              move.w  #$2000,D2       ;Long
                move.l  #0,D7
size1:          andi.w  #$CFFF,(A3)
                or.w    D2,(A3)         ;set the size bits in the opcode
                move.w  2(A0),D3        ;second word in d3
                move.w  D3,D4
                andi.w  #$7000,D3
                lsr.w   #7,D3
                lsr.w   #5,D3
                mulu    #4,D3
                btst    #15,D4
                beq.s   DR
                add.l   #32,D3
DR:             move.l  0(SP,D3.w),D1   ;d1 has the Rn contents
                tst.l   D7
                beq.s   NoSh
                lsl.l   D7,D1
NoSh:           lea     SaveVal(PC),A3
                move.l  D1,(A3)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                addi.l  #4,(A3)
                movem.l (SP)+,D0-A6
                movea.l StackP(PC),SP
MovSREf:        move.l  SaveVal(PC),D0  ;d0 will be replaced with the <ea>
                nop
                nop
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.l  62(SP),D4
                add.l   NumAdd(PC),D4
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT220
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT220:          rte

ea2Rn:          lea     MovSEfR(PC),A3
                andi.w  #$FFC0,(A3)
                movea.l 66(SP),A0
                move.w  (A0),D4
                andi.w  #$3F,D4
                or.w    D4,(A3)
                lea     NumAdd(PC),A4
                move.l  #$4E714E71,2(A3)
                move.l  #4,(A4)
                cmpi.w  #$38,D4
                bne.s   MVS100
                move.w  4(A0),2(A3)
                move.l  #6,(A4)
                bra     EffFound2
MVS100:         cmpi.w  #$39,D4
                bne.s   MVS200
                move.l  4(A0),2(A3)
                move.l  #8,(A4)
                bra     EffFound2
MVS200:         andi.w  #$38,D4
                cmpi.w  #$28,D4
                bne.s   MVS300
                move.w  4(A0),2(A3)
                move.l  #6,(A4)
                bra     EffFound2
MVS300:         cmpi.w  #$30,D4         ;index
                bne     MVS400
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   legalMoves2
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     ther11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
ther11:         movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                lea     MovSEfR(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                bra.s   EffFound2
legalMoves2:    movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     ther21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
ther21:         movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                lea     MovSEfR(PC),A3
                andi.w  #$FFC0,(A3)
                ori.w   #$39,(A3)
                move.l  RetAddr(PC),2(A3)
                bra.s   EffFound2
MVS400:         cmpi.w  #$28,D4
                bne.s   EffFound2
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                bra     illegale
EffFound2:      move.w  (A0),D3         ;first word in d3
                andi.w  #$C0,D3         ;determine operation size (.B, .W or .L)
                lsr.w   #6,D3
                cmpi.w  #0,D3
                bne.s   wl2
                move.w  #$1000,D2
                bra.s   size2
wl2:            cmpi.w  #1,D3           ;Word or Long
                bne.s   l2
                move.w  #$3000,D2
                bra.s   size2
l2:             move.w  #$2000,D2       ;Long
size2:          andi.w  #$CFFF,(A3)
                or.w    D2,(A3)         ;set the size bits in the opcode
                move.w  2(A0),D3
                moveq   #0,D4
                btst    #15,D3
                beq.s   DR2
                move.w  #$40,D4
DR2:            andi.w  #$7000,D3
                lsr.w   #3,D3
                or.w    D3,D4
                andi.w  #$F03F,(A3)
                or.w    D4,(A3)
                lea     SaveA7(PC),A4
                move.l  SP,(A4)
                addi.l  #4,(A4)
                movem.l (SP)+,D0-A6
                movea.l StackP(PC),SP
MovSEfR:        move.l  D1,D0           ;d1 will be changed to <ea>.
                nop                     ;putting in a7 has no effect
                nop
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.l  62(SP),D4
                add.l   NumAdd(PC),D4
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT230
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT230:          rte

M_O_V_E_F_C_C_R:movea.l 62(SP),A0       ;Syntax: move CCR,<ea> = move CCR,d0 + move d0,<ea>
                move.w  (A0),D1
                move.w  D1,D2
                andi.w  #$07,D1
                andi.w  #$38,D2
                lsl.w   #2,D1
                lsl.w   #7,D1
                lsl.w   #3,D2
                or.w    D2,D1
                lea     From(PC),A3
                lea     NumAdd(PC),A4
                move.l  #$4E714E71,4(A3)
                andi.w  #$F03F,(A3)
                or.w    D1,(A3)
                lsr.w   #6,D2
                cmpi.w  #$05,D2
                bne.s   tst2
                move.l  #4,(A4)         ;it is address reg. indirect with displ.
                move.w  2(A0),4(A3)
                bra     Here7
tst2:           cmpi.w  #6,D2
                bne.s   tst3
                move.w  2(A0),D3        ;index
                btst    #8,D3
                beq.s   ccr12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     ccr11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #2,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
ccr11:          move.w  60(SP),D0
                andi.l  #$FF,D0
                movea.l RetAddr(PC),A1
                move.w  D0,(A1)
                bra     EndMoveCCR
ccr12:          lea     NumAdd(PC),A4
                move.l  #4,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     ccr21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #2,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
ccr21:          move.w  60(SP),D0
                andi.l  #$FF,D0
                movea.l RetAddr(PC),A1
                move.w  D0,(A1)
                bra.s   EndMoveCCR
tst3:           lsr.w   #6,D1
                cmpi.w  #$07,D1
                bne.s   tst4
                move.l  #4,(A4)
                move.w  2(A0),4(A3)
                bra.s   Here7
tst4:           cmpi.w  #$0F,D1
                bne.s   tst5
                move.l  #6,(A4)
                move.l  2(A0),4(A3)
                bra.s   Here7
tst5:           move.l  #2,(A4)
Here7:          lea     SaveVal(PC),A4
                move.w  60(SP),D0
                andi.w  #$FF,D0
                move.w  D0,(A4)
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                movea.l StackP(PC),SP
From:           move.w  SaveVal(PC),D0
                nop
                nop
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
EndMoveCCR:     move.l  62(SP),D4
                add.l   NumAdd(PC),D4
                move.l  D4,62(SP)
; move.l  ExecBase,a6
; jsr     Permit(a6)
                movem.l (SP)+,D0-A6
                btst    #7,(SP)
                beq.s   NT240
                move.l  $24,-(SP)
                suba.l  #2,SP
                move.w  6(SP),(SP)
                bclr    #7,(SP)
                bset    #5,(SP)
NT240:          rte

BFCommon:       movea.l 62(SP),A0       ;all the bit field instructions call this routine
                move.w  (A0),D1         ;when they start executing.It gets the starting
                move.w  D1,D2           ;address of the operand and also width and offset
                andi.w  #$3F,D1         ;of the intended bitfield.if the operand is in a
                lea     NumAdd(PC),A4   ;data register, it is copied to a memory location
                lea     LEABF(PC),A3    ;and it't address is passed. a flag is set to show
                move.l  #$4E714E71,2(A3) ;this situation.
                move.l  #4,(A4)
                andi.w  #$FFC0,(A3)
                or.w    D1,(A3)
                andi.w  #$38,D2
                bne.s   AddressInvolved
                move.w  D1,D2
                mulu    #4,D2
                move.l  0(SP,D2.w),D0
                lea     Val1(PC),A3
                move.l  D0,(A3)
                lea     Val1(PC),A4
                lea     SaveVal(PC),A3
                move.l  A4,(A3)
                moveq   #1,D7
                bra     bfEADone
AddressInvolved:cmpi.w  #$38,D1         ;imm. short
                bne.s   bflab10
                move.w  4(A0),2(A3)
                move.l  #6,(A4)
                bra     bfDone
bflab10:        cmpi.w  #$39,D1         ;imm. long
                bne.s   bflab20
                move.l  4(A0),2(A3)
                move.l  #8,(A4)
                bra     bfDone
bflab20:        cmpi.w  #$3A,D1         ;pc+displ
                beq.s   pcaddress
                cmpi.w  #$3B,D1
                bne.s   bflab30
                movea.l 62(SP),A0
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   pcaddress
                lea     BDFlag(PC),A3
                move.l  #1,(A3)
                lea     bf13(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
bf13:           lea     SaveVal(PC),A3
                move.l  RetAddr(PC),(A3)
                moveq   #0,D7
                bra     bfEADone
pcaddress:      lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #1,(A3)
                lea     bf23(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
bf23:           lea     SaveVal(PC),A3
                move.l  RetAddr(PC),(A3)
                moveq   #0,D7
                bra     bfEADone
bflab30:        andi.w  #$38,D1
                cmpi.w  #$28,D1         ;displ.
                bne.s   bflab40
                move.w  4(A0),2(A0)
                move.l  #6,(A4)
                bra.s   bfDone
bflab40:        cmpi.w  #$30,D1         ;index
                bne.s   bfDone
                move.w  4(A0),D3
                btst    #8,D3
                beq.s   bf12
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     bf11(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
bf11:           lea     SaveVal(PC),A3
                move.l  RetAddr(PC),(A3)
                moveq   #0,D7
                bra.s   bfEADone
bf12:           lea     NumAdd(PC),A4
                move.l  #6,(A4)
                lea     BDFlag(PC),A3
                move.l  #0,(A3)
                lea     bf21(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  #4,(A3)
                bra     BriefFormat     ;it is a 68020 addressing mode
bf21:           lea     SaveVal(PC),A3
                move.l  RetAddr(PC),(A3)
                moveq   #0,D7
                bra.s   bfEADone
bfDone:         lea     SaveA7(PC),A3
                move.l  SP,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                movea.l StackP(PC),SP
LEABF:          lea     (A1),A1         ;(a1) will be changed to <ea>
                nop
                nop
                lea     SaveVal(PC),SP
                move.l  A1,(SP)
                movea.l savea1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                moveq   #0,D7
bfEADone:       movea.l 62(SP),A0
                move.w  2(A0),D1
                move.w  D1,D3
                btst    #11,D1
                beq.s   OffsetImm
                lsr.w   #6,D1
                andi.w  #$07,D1
                mulu    #4,D1
                move.l  0(SP,D1.w),D0   ;d0 has the offset
                lea     BFOffset(PC),A3
                move.l  D0,(A3)
                divs    #32768,D0
                move.w  D0,D1
                andi.l  #$FFFF,D1
                muls    #4096,D1
                lsr.l   #8,D0
                lsr.l   #8,D0
                divs    #8,D0
                move.w  D0,D2
                andi.l  #$FFFF,D2
                add.l   D2,D1           ;d1 has the number of bytes from the <ea>
                lsr.l   #8,D0
                lsr.l   #8,D0
                ext.l   D0
                tst.l   D0
                bpl.s   bfNoChange
                move.l  #8,D4
                add.l   D0,D4
                move.l  D4,D0
                sub.l   #1,D1
bfNoChange:     move.l  D0,D2           ;d2 has the final offset
                bra.s   OffsetDone
OffsetImm:      lsr.w   #6,D1
                andi.l  #$1F,D1
                lea     BFOffset(PC),A3
                move.l  D1,(A3)
                divu    #8,D1
                move.l  D1,D2
                andi.l  #$FFFF,D1
                swap    D2
                andi.l  #$FFFF,D2
OffsetDone:     move.w  D3,D4
                btst    #5,D4
                beq.s   WidthImm
                andi.w  #$07,D4
                mulu    #4,D4
                move.l  0(SP,D4.w),D0
                andi.l  #$1F,D0         ;modulo 32
                bne.s   mod321
                move.l  #32,D0
mod321:         move.l  D0,D4           ;d4 has the width
                bra.s   WidthDone
WidthImm:       andi.l  #$1F,D4
                bne.s   WidthDone
                move.l  #32,D4
WidthDone:      movea.l SaveVal(PC),A1
                adda.l  D1,A1
;a1 points to the first byte containing the bit to manipulate
                movea.l Val3(PC),A3
                jmp     (A3)


PCRelative:     movea.l 62(SP),A0       ;<ea> = (d16,pc)
                lea     PCRMove(PC),A3
                adda.l  D1,A0           ;a0 holds the pc that the assembler assumed at the
                move.w  (A0),2(A3)      ;time of assembly
                lea     SaveA7(PC),A3
                move.l  SP,(A3)
                lea     savea0(PC),A3
                move.l  A0,(A3)
                movem.l (SP)+,D0-A6
                lea     savea1(PC),SP
                move.l  A1,(SP)
                lea     saved0(PC),SP
                move.l  D0,(SP)
                movea.l savea0(PC),A1
                movea.l StackP(PC),SP
PCRMove:        move.l  0(A1),D0
                nop
                lea     SaveVal(PC),SP
                move.l  D0,(SP)
                move.l  saved0(PC),D0
                movea.l savea1(PC),A1
                movea.l SaveA7(PC),SP
                adda.l  #60,SP
                movem.l D0-A6,-(SP)
                move.l  SaveVal(PC),D3
                movea.l Val3(PC),A3     ;ret addr
                jmp     (A3)

PCIndex:        movea.l 62(SP),A0
                adda.l  D1,A0
                move.w  (A0),D3
                btst    #8,D3
                beq.s   pcindexshort
                lea     BDFlag(PC),A3
                move.l  #1,(A3)
                lea     pc13(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  D1,(A3)
                bra     NEWADDRESSING   ;it is a 68020 addressing mode
pc13:           movea.l RetAddr(PC),A1
                move.l  (A1),D3
                movea.l Val3(PC),A3
                jmp     (A3)
pcindexshort:   lea     BDFlag(PC),A3
                move.l  #1,(A3)
                lea     pc23(PC),A3
                lea     Val2(PC),A4
                move.l  A3,(A4)
                lea     Offset(PC),A3
                move.l  D1,(A3)
                bra.s   BriefFormat     ;it is a 68020 addressing mode
pc23:           movea.l RetAddr(PC),A1
                move.l  (A1),D3
                movea.l Val3(PC),A3
                jmp     (A3)

BriefFormat:    movem.l (SP)+,D0-A6     ;<ea> = (d8,An,Xn*scale)
                move.l  StackP(PC),-(SP)
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                move.l  Offset(PC),D0
                move.l  BDFlag(PC),D1
                beq.s   BaseAddressingBrief
                adda.l  D0,A0
                move.l  A0,D6
                bra.s   BasePCDoneBrief
BaseAddressingBrief:
                move.w  (A0),D1
                andi.w  #$07,D1
                mulu    #4,D1
                add.l   #32,D1
                move.l  0(SP,D1.w),D6   ;d6 has base register
                adda.l  D0,A0
BasePCDoneBrief:move.w  (A0),D1
                move.w  D1,D2
                andi.w  #$7000,D1
                lsr.w   #7,D1
                lsr.w   #5,D1
                mulu    #4,D1
                btst    #15,D2
                beq.s   BriefData
                add.l   #32,D1
BriefData:      move.l  0(SP,D1.w),D4   ;d4 has index register
                btst    #11,D2
                bne.s   BriefLong
                ext.l   D4
BriefLong:      move.w  D2,D1           ;now multiply the index
                andi.w  #$0600,D1
                lsr.w   #7,D1
                lsr.w   #2,D1
                cmpi.w  #0,D1
                beq.s   BriefIndexDone
                cmpi.w  #1,D1
                bne.s   Mul4
                mulu    #2,D4
                bra.s   BriefIndexDone
Mul4:           cmpi.w  #2,D1
                bne.s   Mul8
                mulu    #4,D4
                bra.s   BriefIndexDone
Mul8:           mulu    #8,D4
BriefIndexDone: ext.w   D2              ;d2 has displacement
                ext.l   D2
                add.l   D2,D4           ;add them all
                add.l   D4,D6
                lea     RetAddr(PC),A3
                move.l  D6,(A3)
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                movea.l Val2(PC),A3
                jmp     (A3)

NEWADDRESSING:  movem.l (SP)+,D0-A6
                move.l  StackP(PC),-(SP) ;insert a7
                movem.l D0-A6,-(SP)
                movea.l 66(SP),A0
                move.l  Offset(PC),D0
                move.l  BDFlag(PC),D1
                beq.s   BaseAddressing
                adda.l  D0,A0
                move.l  A0,D6
                bra.s   BasePCDone
BaseAddressing: move.w  (A0),D1
                andi.w  #$07,D1
                mulu    #4,D1
                add.l   #32,D1
                move.l  0(SP,D1.w),D6   ;d6 has base register
                adda.l  D0,A0
BasePCDone:     move.w  (A0),D1
                move.w  D1,D2
                btst    #7,D1
                beq.s   BaseDone
                moveq   #0,D6
BaseDone:       moveq   #0,D5           ;d5 has index
                btst    #6,D1
                bne.s   IndexDone
                andi.w  #$7000,D1
                lsr.w   #7,D1
                lsr.w   #5,D1
                mulu    #4,D1
                btst    #15,D2          ;address or data register?
                beq.s   NAAddr
                add.l   #32,D1
NAAddr:         move.l  0(SP,D1.w),D5
                btst    #11,D2
                bne.s   NALong
                ext.l   D5
NALong:         move.l  D2,D1           ;now multipy index
                andi.w  #$0600,D1
                lsr.w   #7,D1
                lsr.w   #2,D1
                cmpi.w  #0,D1
                beq.s   IndexDone
                cmpi.w  #1,D1
                bne.s   Scale4
                mulu    #2,D5
                bra.s   IndexDone
Scale4:         cmpi.w  #2,D1
                bne.s   Scale8
                mulu    #4,D5
                bra.s   IndexDone
Scale8:         mulu    #8,D5

IndexDone:      move.w  D2,D1
                andi.w  #$30,D1
                lsr.w   #4,D1
                cmpi.w  #1,D1
                beq.s   BaseDispDone
                cmpi.w  #2,D1
                bne.s   LongDisp
                move.w  2(A0),D4        ;d4 has base displacement
                ext.l   D4
                add.l   #4,D0
                bra.s   BaseDispDone
LongDisp:       move.l  2(A0),D4
                add.l   #6,D0

BaseDispDone:   movea.l 66(SP),A0
                adda.l  D0,A0
                moveq   #0,D3           ;d3 has outer displacement
                move.w  D2,D1
                andi.w  #$07,D1
                btst    #6,D2
                bne.s   NoPrePost       ;it is not preindex or post index
                cmpi.w  #0,D1
                beq     AddrDone
                cmpi.w  #1,D1
                beq.s   CalPre
Case2:          cmpi.w  #2,D1
                bne.s   Case3
                move.w  (A0),D3
                ext.l   D3
                add.l   #2,D0
                bra.s   CalPre
Case3:          cmpi.w  #3,D1
                bne.s   Case4
                move.l  (A0),D3
                add.l   #4,D0

CalPre:         add.l   D4,D6           ;calculate pre index
                add.l   D5,D6
                moveq   #0,D4
                moveq   #0,D5
                movea.l D6,A3
                move.l  (A3),D6
                add.l   D3,D6
                moveq   #0,D3
                bra.s   AddrDone        ;pre indexed address calculated

Case4:          cmpi.w  #5,D1
                beq.s   CalPost
                cmpi.w  #6,D1
                bne.s   Case5
                move.w  (A0),D3
                ext.l   D3
                add.l   #2,D0
                bra.s   CalPost
Case5:          move.l  (A0),D3
                add.l   #4,D0

CalPost:        add.l   D4,D6           ;calculate post index
                movea.l D6,A3
                move.l  (A3),D6
                add.l   D5,D6
                moveq   #0,D4
                moveq   #0,D5
                add.l   D3,D6
                moveq   #0,D3
                bra.s   AddrDone        ;post indexed address calculated

NoPrePost:      cmpi.w  #0,D1
                beq.s   AddrDone
                cmpi.w  #1,D1
                beq.s   AddrDone
                cmpi.w  #2,D1
                bne.s   Case6
                move.w  (A0),D3
                ext.l   D3
                add.l   #2,D0
                bra.s   AddrDone
Case6:          move.l  (A0),D3
                add.l   #4,D0
AddrDone:       add.l   D4,D5
                add.l   D5,D6
                add.l   D3,D6
                lea     RetAddr(PC),A3  ;this is the effevctive address.
                move.l  D6,(A3)
                lea     NumAdd(PC),A3   ;length of the instruction.
                move.l  D0,(A3)
                movem.l (SP)+,D0-A6
                adda.l  #4,SP
                movem.l D0-A6,-(SP)
                movea.l Val2(PC),A3
                jmp     (A3)
                ENDPART

                >PART 'Block Storage Space'
                BSS
error:          DS.L 1          ;Installation error?
NewVec:         DS.L 1
Except:         DS.L 1
MyVBR:          DS.L 1
MySFC:          DS.L 1
MyDFC:          DS.L 1
MyCAAR:         DS.L 1
MyCACR:         DS.L 1
MySR:           DS.W 1
MySP:           DS.L 1
SaveVal:        DS.L 1
RetAddr:        DS.L 1
savea0:         DS.L 1
savea1:         DS.L 1
saved1:         DS.L 1
saved0:         DS.L 1
savereg:        DS.L 1
SaveA7:         DS.L 1
NumAdd:         DS.L 1          ;NumAdd holds the instruction length
StackP:         DS.L 1
Val1:           DS.L 1
Val2:           DS.L 1
Val3:           DS.L 1
WhichOne:       DS.L 1
Flag:           DS.L 1
Offset:         DS.L 1
BDFlag:         DS.L 1
BFOffset:       DS.L 1
EndIllegal:     ENDPART

                END
