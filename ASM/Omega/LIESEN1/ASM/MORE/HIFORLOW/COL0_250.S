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
                DC.B "Martin Liesen 1991    - Tos 2.5 only!!!


"
                DC.B "Keep Alternate pressed while loading for
"
                DC.B "low resolution!!

"
                DC.B "Alt Help when Bplanes bug!!",0
                EVEN
                ENDPART
                >PART 'SUPER CALL'
SUPER:          movea.l $000004F2,A0
                cmpi.w  #$0205,2(A0)
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

                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
                bclr    #1,$FFFF820A.w
                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
                bset    #1,$FFFF820A.w
                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7

wrongtos:       rts
                ENDPART
                >PART 'VBL'
VBL:
*******************************
********* V B L
*******************************
BC_VBL2:
VBL2_05:        addq.l  #1,$00000466
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
                END
