; *************************************
; ** UPPER AND LOWER BORDER
; ** By Martin Liesen 1991
; *************************************
                >PART 'CALL SUPER PART'
                pea     begin(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                ENDPART
                >PART 'SAVE REGISTERS'
***************************************
**  S A V E   V A L U E S
***************************************
begin:          lea     savetab(PC),A6
                move.l  A7,(A6)+
                move.l  $00000068.w,(A6)+
                move.l  $00000070.w,(A6)+
                move.w  $00000120.w,(A6)+
                move.b  $FFFFFA07.w,(A6)+
                move.b  $FFFFFA09.w,(A6)+
                move.b  $FFFFFA0F.w,(A6)+
                move.b  $FFFFFA11.w,(A6)+
                move.b  $FFFFFA13.w,(A6)+
                move.b  $FFFFFA15.w,(A6)+
                move.w  #4,-(A7)
                trap    #14
                move.w  D0,(A6)+
                move.w  #2,-(A7)
                trap    #14
                move.l  D0,(A6)+
                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,(A6)
                lea     32(A6),A6
                ENDPART
                >PART 'WAIT FOR KEY'
                lea     dummyvbl(PC),A0 ; set vbl
                move.l  A0,$00000070.w
                move.w  #0,-(A7)        ; set rez
                pea     -1
                pea     -1
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7

                lea     vbl(PC),A0      ; set vbl
                move.l  A0,$00000070.w
                lea     hbl(PC),A0      ; set hbl
                move.l  A0,$00000068.w

                move.b  #0,$FFFFFA07.w  ; set timers
                move.b  #0,$FFFFFA09.w
                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w

stopit:         move    #$2300,SR
                cmpi.b  #$39,$FFFFFC02.w ; wait for space
                bne.s   stopit
                ENDPART
                >PART 'RESTORE AND RTS'
*****************************************
**   R E S E T   V A L U E S
*****************************************
back:           move    #$2700,SR
                lea     savetab(PC),A6
                movea.l (A6)+,A7
                move.l  (A6)+,$00000068.w
                move.l  (A6)+,$00000070.w
                move.l  (A6)+,$00000120.w
                move.b  (A6)+,$FFFFFA07.w
                move.b  (A6)+,$FFFFFA09.w
                move.b  (A6)+,$FFFFFA0F.w
                move.b  (A6)+,$FFFFFA11.w
                move.b  (A6)+,$FFFFFA13.w
                move.b  (A6)+,$FFFFFA15.w
                move.w  (A6)+,-(A7)
                move.l  (A6),-(A7)
                move.l  (A6)+,-(A7)
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                movem.l (A6)+,D0-D7
                movem.l D0-D7,$FFFF8240.w
                rts
                ENDPART

                >PART 'VBL'
; *****************************************
; *   V  B  L
; *****************************************
vbl:            move    #$2300,SR
                clr.w   $FFFF8240.w

                lea     $FFFF8240.w,A6
                lea     lines(PC),A0    ; counter for HBL
                move.w  #33,(A0)
                move    #$2100,SR

                move.b  #0,$FFFFFA1B.w  ; start Timer C for lower border
                move.b  #228,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
                lea     lowerborder(PC),A0
                move.l  A0,$00000120.w

* HERE 32 SCANLINES OF CODE CAN GO, BUT NOT MORE!!!!

stopad:         bra.s   stopad

resume:         move    #$2700,SR

* HERE THE PROGRAM GOES!!!!!

dummyvbl:       addq.l  #1,$00000466.w
                rte
                ENDPART

                >PART 'LOWERBORDER'
********************************************
**      lowerborder
********************************************
lowerborder:    move.b  $FFFF8209.w,D7
                move.b  #0,$FFFFFA1B.w
                DS.W 112,$00004E71
                move.b  #0,$FFFF820A.w
                DS.W 13,$00004E71
                move.b  #2,$FFFF820A.w
                bclr    #0,$FFFFFA0F.w
                rte
                ENDPART
                >PART 'HBL'
********************************************
**      HBL
********************************************
hbl:            move    #$2700,SR
                subq.w  #1,lines
                bpl     NOTY

                DS.W 84,$00004E71
                move.b  #0,$FFFF820A.w
                DS.W 12,$00004E71
                move.b  #2,$FFFF820A.w
                move.w  #$00FF,lines
                lea     6(A7),A7
                bra     resume
NOTY:           rte
                ENDPART

savetab:        DS.L 64
lines:          DS.W 1
                END
