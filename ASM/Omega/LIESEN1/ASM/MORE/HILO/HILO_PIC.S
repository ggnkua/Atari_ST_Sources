; *************************************
; ** UPPER AND LOWER BORDER NEO SHOW
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
                lea     Pictures,A6
                lea     Pal(PC),A5
                lea     Name1(PC),A4
                bsr     LoadNeo
                lea     Pictures+32000,A6
                lea     Pal(PC),A5
                lea     Name2(PC),A4
                bsr     LoadNeo
                movem.l Pal(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w

                lea     12(A7),A7
                lea     Scr+255(PC),A0
                move.l  A0,D0
                and.l   #$FFFFFF00,D0
                lea     Screen(PC),A0
                move.l  D0,(A0)

                bsr     Draw_Pics

                lea     dummyvbl(PC),A0 ; set vbl
                move.l  A0,$00000070.w
                move.w  #0,-(A7)        ; set rez
                pea     -1
                pea     -1
                move.w  #5,-(A7)
                trap    #14

                move.b  Screen+1(PC),$FFFF8201.w
                move.b  Screen+2(PC),$FFFF8203.w

                lea     vbl(PC),A0      ; set vbl
                move.l  A0,$00000070.w
                lea     hbl(PC),A0      ; set hbl
                move.l  A0,$00000068.w

                move.b  #0,$FFFFFA07.w  ; set timers
                move.b  #0,$FFFFFA09.w
                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w

                move    #$2300,SR
stopit:         lea     $FFFFFC02.w,A0
                move.b  (A0),D0
                cmp.b   #$50,D0
                bne.s   .NotDown
                addi.w  #1,PicPos
                bsr     Draw_Pics
                bra.s   stopit
.NotDown:
                cmp.b   #$48,D0
                bne.s   .NotUp
                subi.w  #1,PicPos
                bsr     Draw_Pics
                bra.s   stopit
.NotUp:
                cmp.b   #$4D,D0
                bne.s   .NotRight
.Release2:      cmpi.b  #$CD,(A0)
                bne.s   .Release2
                addi.w  #2,SideWay
                bsr     Draw_Pics
                bra.s   stopit
.NotRight:
                cmpi.b  #$39,D0         ; wait for space
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

LoadNeo:        >PART 'Load Neo Pic'
* a6=Pic address
* a5=Pal address
* a4=address to filename

                clr.w   -(A7)           ; Open
                move.l  A4,-(A7)
                move.w  #$003D,-(A7)
                trap    #1
                addq.l  #8,A7
                tst.l   D0
                bmi.s   error
                move.w  D0,D7

                move.w  #1,-(A7)        ; >> 4
                move.w  D7,-(A7)
                move.l  #4,-(A7)
                move.w  #$0042,-(A7)
                trap    #1
                lea     10(A7),A7

                move.l  A5,-(A7)        ; 32 > Pal
                move.l  #32,-(A7)
                move.w  D7,-(A7)
                move.w  #$003F,-(A7)
                trap    #1
                lea     12(A7),A7

                move.w  #1,-(A7)        ; >> 128-32-4
                move.w  D7,-(A7)
                move.l  #128-32-4,-(A7)
                move.w  #$0042,-(A7)
                trap    #1
                lea     10(A7),A7

                move.l  A6,-(A7)        ; 32000 > Pic
                move.l  #32000,-(A7)
                move.w  D7,-(A7)
                move.w  #$003F,-(A7)
                trap    #1
                lea     12(A7),A7

                move.w  D7,-(A7)
                move.w  #$003E,-(A7)
                trap    #1
                addq.l  #4,A7

                rts

error:          pea     _text(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                clr.w   -(A7)
                trap    #1
_text:          DC.B "Error reading file",0
                EVEN
                ENDPART

Draw_Pics:      >PART 'Draw Pics On Screen'
                lea     Pictures,A1
                move.w  SideWay(PC),D0
                ext.l   D0
                adda.l  D0,A1
                movea.l Screen(PC),A0
                move.w  #299,D7
                move.w  PicPos(PC),D0

.SumpLoop:      tst.w   D0
                bpl.s   .HardOn
                addq.w  #1,D0
                moveq   #9,D6
.Fuckers:       clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D6,.Fuckers
                dbra    D7,.SumpLoop
                rts

.HardOn:        move.w  D0,D6
                ext.l   D6
                mulu    #160,D6
                adda.l  D6,A1

.Gnus_Loop:     moveq   #9,D6
.Fittor:        move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D6,.Fittor
                addq.w  #1,D0
                cmp.w   #399,D0
                bhi.s   .Helvete
                dbra    D7,.Gnus_Loop
                rts

.Helvete:       moveq   #9,D6
.R”vl”:         clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D6,.R”vl”
                dbra    D7,.Helvete
                rts

                ENDPART

                >PART 'VBL'
; *****************************************
; *   V  B  L
; *****************************************
vbl:            move    #$2300,SR
                movem.l D0-A6,-(A7)
*                clr.w   $FFFF8240.w

*                lea     $FFFF8240.w,A6
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
                movem.l (A7)+,D0-A6
                rte

* HERE THE PROGRAM GOES!!!!!

dummyvbl:       addq.l  #1,$00000466.w
                rte
                ENDPART

                >PART 'LOWERBORDER'
********************************************
**      lowerborder
********************************************
lowerborder:                            *  move.b  $FFFF8209.w,D7
                nop
                nop
                nop
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

Name1:          DC.B "\PIC01.NEO",0
Name2:          DC.B "\PIC02.NEO",0

SideWay:        DC.W 0
                BSS
Pal:            DS.B 32
savetab:        DS.L 64
PicPos:         DS.W 1
lines:          DS.W 1
Screen:         DS.L 1
Scr:            DS.B 300*160+256
                DS.B 160
Pictures:       DS.B 400*160
                END
