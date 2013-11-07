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
INFOTEXT:       DC.B 27,"E"
                DC.B "pHIGH FORCE LOWq


"
                DC.B "Martin Liesen 1991    - Tos 1.6 only!!!


"
                DC.B "Keep control pressed while loading for
"
                DC.B "low resolution!!

"
                DC.B "Alt Help when Bplanes bug!!",0
                EVEN
                ENDPART
                PART 'SUPER CALL'
SUPER:          movea.l $000004F2,A0
                cmpi.w  #$0106,2(A0)
                bne.s   wrongtos
                lea     VBL(PC),A0
                move.l  A0,$00000070.w

                pea     $000BFFFF
                trap    #13
                addq.l  #4,A7
                btst    #3,D0
                beq.s   jepp
                move.w  #$0000,-(A7)
                pea     $FFFFFFFF
                pea     $FFFFFFFF
                move.w  #$0005,-(A7)
                trap    #$0E
                lea     $000C(A7),A7
jepp:           pea     INFOTEXT(PC)
                move.w  #$0009,-(A7)
                trap    #$01
                addq.l  #6,A7

wrongtos:       rts
                ENDPART
                >PART 'VBL'
VBL:            addq.l  #1,$00000466.w
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
                move.w  #$FFFF,$000004EE
                move.b  #$00,$FFFF820A.w
                eori.w  #3,$FFFF8260.w
                move.w  $00004000,D0
L70342:         dbra    D0,L70342
                move.b  #$02,$FFFF820A.w
                eori.w  #3,$FFFF8260.w
L70350:         movem.l (A7)+,D0-A6
NO_VBL:         addq.w  #1,$00000452.w
                rte
                ENDPART
                END
