                DC.W "HF",$0200
VBL260:         addq.l  #1,$00000466.w
                subq.w  #1,$00000452.w
                bmi     NoVbl
                movem.l D0-A6,-(A7)
                addq.l  #1,$00000462.w
                move.w  $00000454.w,D7
                beq     No_Sub_VBLs
                subq.l  #1,D7
                movea.l $00000456.w,A0
Next_Vect:      movea.l (A0)+,A1
                cmpa.w  #0,A1
                beq.s   No_Vect
                movem.l D7-A0,-(A7)
                jsr     (A1)
                movem.l (A7)+,D7-A0
No_Vect:        dbra    D7,Next_Vect
                move.b  $FFFFFA01.w,D1
                tst.b   $00000A02
                beq.s   LE00C84
                move    SR,-(A7)
                ori     #$0700,SR       ; No IRQ's
LE00C58:        move.b  $FFFF8901.w,D0
                move.b  $FFFFFA01.w,D1
                btst    #7,D1
                sne     D1
                move.b  $FFFFFA01.w,D2
                btst    #7,D2
                sne     D2
                cmp.b   D1,D2
                bne.s   LE00C58
                cmp.b   $FFFF8901.w,D0
                bne.s   LE00C58
                move    (A7)+,SR
                btst    #0,D0
                beq.s   LE00C84
                not.b   D1

LE00C84:
*                move.b  $FFFF8260.w,D0  ; resolution
*                and.b   #3,D0
*                cmp.b   #2,D0
*                bge.s   HighRez
*                btst    #7,D1
*                bne.s   NoWorry
*                jsr     $e01404         ; SomeThing wierd!
*                move.b  #2,D0
*                bra.s   ReadyForChg
*HighRez:        btst    #7,D1
*                beq.s   NoWorry
*                move.b  $0000044A.w,D0  ; DefShiftMode
*                cmp.b   #2,D0
*                blt.s   ReadyForChg
*                clr.b   D0
*ReadyForChg:    move.b  D0,$0000044C.w
*                move.b  D0,$FFFF8260.w
*                movea.l $0000046E.w,A0  ; Get Monitor Change
*                jsr     (A0)            ; Kommer tebax!!! No RESET!
NoWorry:        jsr     $00E064B4
                tst.l   $0000045A.w     ; PAL for NEXT VBL pek
                beq.s   NoNewPal
                movea.l $0000045A.w,A0
                lea     $FFFF8240.w,A1
                move.w  #7,D1
.CopyPal:       move.l  (A0)+,(A1)+
                dbra    D1,.CopyPal
                clr.l   $0000045A.w
NoNewPal:       tst.l   $0000045E.w     ; SCREEN ADDRESS for next VBL
                beq.s   NoNewScreen
                move.l  $0000045E.w,$0000044E.w
                move.b  $00000450.w,$FFFF8203.w
                move.b  $0000044F.w,$FFFF8201.w
                move.b  $00000451.w,$FFFF820D.w
NoNewScreen:    jsr     $00E03D1C
No_Sub_VBLs:    tst.w   $000004EE.w     ; ALT HELP counter
                bne.s   NoHardCopy
                jsr     $00E0130C
NoHardCopy:     movem.l (A7)+,D0-A6
NoVbl:          addq.w  #1,$00000452    ; Inc MAKE-NO-VBL flag (sub earlier)
                rte
