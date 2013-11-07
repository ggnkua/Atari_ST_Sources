                >PART 'INIT'
                pea     SUPER(PC)
                move.w  #$0026,-(A7)
                trap    #$0E
                addq.l  #6,A7
                                                                                                                                                                                                                                                                
                clr.w   -(A7)
                pea     $0000059E.w
                move.w  #$0031,-(A7)
                trap    #$01

                ENDPART
                >PART 'TEXT'
InfoText:       DC.B "


pHIGH FORCE LOW v2.0q


"
                DC.B "Martin Liesen 1991-29
"
                DC.B "only active in Tos 2.05 and 2.06!

"
                DC.B "Keep Alternate pressed while loading for
"
                DC.B "low resolution switch.


"
                DC.B "KARiN


",0
FelText:        DC.B "HI FORCE LOW can only run under",13,10
                DC.B "tos 1.60, 2.50 and 2.60.


",0
                EVEN
                ENDPART
                >PART 'SUPER CALL'
SUPER:          movea.l $000004F2,A0
                cmpi.w  #$0205,2(A0)
                bne.s   .ej205
                lea     VBL250(PC),A0
                move.l  A0,$00000070.w
                bra.s   .cont
.ej205:         cmpi.w  #$0206,2(A0)
                bne.s   .ej206
                lea     VBL260(PC),A0
                move.l  A0,$00000070.w
                bra.s   .cont
.ej206:         cmpi.w  #$0106,2(A0)
                bne.s   wrongtos
                lea     VBL160(PC),A0
                move.l  A0,$00000070.w

.cont:          pea     $000BFFFF       ; Get KEY status
                trap    #13
                addq.l  #4,A7
                btst    #3,D0           ; Alternate pressed
                beq.s   TypeText
                move.w  #$0000,-(A7)    ; Go LOW!
                pea     $FFFFFFFF
                pea     $FFFFFFFF
                move.w  #$0005,-(A7)
                trap    #$0E
                lea     12(A7),A7
TypeText:       pea     InfoText(PC)
                move.w  #$0009,-(A7)
                trap    #$01
                addq.l  #6,A7

                move.w  #37,-(A7)       ; WaitVbl
                trap    #14
                addq.l  #2,A7
                bclr    #1,$FFFF820A.w  ; Set 60hz
                move.w  #37,-(A7)       ; Wait Vbl
                trap    #14
                addq.l  #2,A7
                move.w  #37,-(A7)       ; Wait Vbl
                trap    #14
                addq.l  #2,A7
                bset    #1,$FFFF820A.w  ; Set 50hz
                move.w  #37,-(A7)       ; Wait Vbl
                trap    #14
                addq.l  #2,A7

wrongtos:       pea     FelText(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                rts
                ENDPART
                >PART 'VBL 1.60'
                DC.W "HF",$0200
VBL160:         addq.l  #1,$00000466.w
                subq.w  #1,$00000452.w
                bmi     NO_VBL
                movem.l D0-A6,-(A7)
                addq.l  #1,$00000462
                move.b  $0000044C.w,$FFFF8260.w
                jsr     $00E0A938
                tst.l   $0000045A.w
                beq.s   L702E0
                movem.l $0000045A,A0
                movem.l (A0),D0-D7
                movem.l D0-D7,$FFFF8240.w
                clr.l   $0000045A.w
L702E0:         tst.l   $0000045E.w
                beq.s   L702FE
                move.l  $0000045E.w,$0000044E.w
                move.b  $00000451.w,$FFFF820D.w
                move.b  $00000450.w,$FFFF8203.w
                move.b  $0000044F.w,$FFFF8201.w
L702FE:         jsr     $00E01528
                move.w  $00000454.w,D7
                beq.s   L70328
                subq.l  #1,D7
                movea.l $00000456.w,A0
L70310:         movea.l (A0)+,A1
                cmpa.l  #$00000000,A1
                beq.s   L70324
                movem.l D7-A0,-(A7)
                jsr     (A1)
                movem.l (A7)+,D7-A0
L70324:         dbra    D7,L70310
L70328:         tst.w   $000004EE.w
                bne.s   L70350
                move.w  #$FFFF,$000004EE.w
L70350:         movem.l (A7)+,D0-A6
NO_VBL:         addq.w  #1,$00000452.w
                rte
                ENDPART
                >PART 'VBL 2.50'
                DC.W "HF",$0200
VBL250:         addq.l  #1,$00000466
                subq.w  #1,$00000452
                bpl.s   URK01
                jmp     $00E009E4
URK01:          movem.l D0-A6,-(A7)
                addq.l  #1,$00000462.w
                move.w  $00000454.w,D7
                bne.s   URK02
                jmp     $00E009D6
URK02:          subq.l  #1,D7
                movea.l $00000456.w,A0
NEXT_VBL:       movea.l (A0)+,A1
                cmpa.w  #0,A1
                beq.s   NO_VECT
                movem.l D7-A0,-(A7)
                jsr     (A1)
                movem.l (A7)+,D7-A0
NO_VECT:        dbra    D7,NEXT_VBL
                move    SR,-(A7)
                ori     #$0700,SR
LE00928:        move.b  $FFFF8901.w,D0
                move.b  $FFFFFA01.w,D1
                btst    #$07,D1
                sne     D1
                move.b  $FFFFFA01.w,D2
                btst    #$07,D2
                sne     D2
                cmp.b   D1,D2
                bne.s   LE00928
                cmp.b   $FFFF8901.w,D0
                bne.s   LE00928
                move    (A7)+,SR
                btst    #$00,D0
                beq.s   LE00954
                not.b   D1
LE00954:
LE00992:        jmp     $00E00992
                ENDPART
                >PART 'VBL 2.60'
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

                ENDPART
                END
