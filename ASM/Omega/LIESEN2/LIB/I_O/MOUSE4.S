* This Mouse routine is placed on the acia irq $118.w
* A good idea is to make som changes; coz right now I'm using
* the new X&Y as soon as it's changed, this might result in that
* I draw with New X and old Y, as it takes a while to send the coordintes.
* So, It's better to have two X&Y addresses, one while sending which then
* will be transfared to the one used by the program in the routine
* mouseirq3, as that's the last mouse irq (handels Y).....
*
* Made by Martin Liesen 1991 (PC Relativ...) as an example...
*
* Hello To: Mats and Stephan!!!!
*
* Draw on screen rout is for Medium....
*
* Make sure that $118.w is not masked away (bit 6 IRB) and that
* the MFP irq's is running (not masked with IPL)
*
***********************************************************************
                pea     begin(PC)       ; Start program in Supervisor
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                clr.w   -(A7)
                trap    #1
                                                                                                                                                                                                                                                                
begin:          bsr.s   mouseinit
                bsr.s   test
                bsr     mouserestore
                rts

******************************
**     T E S T
******************************

test:           lea     x(PC),A0        ; kepp mouse on screen...
                cmpi.w  #199,2(A0)
                ble.s   yoki1
                move.w  #199,2(A0)
yoki1:          cmpi.w  #639,(A0)
                ble.s   xoki1
                move.w  #639,2(A0)
xoki1:          tst.w   2(A0)
                bge.s   yoki2
                clr.w   2(A0)
yoki2:          tst.w   (A0)
                bge.s   xoki2
                clr.w   (A0)
xoki2:
                move.w  (A0),D0
                move.w  2(A0),D1
                mulu    #160,D1
                move.w  D0,D2
                and.w   #$000F,D2
                sub.w   D2,D0
                lsr.w   #2,D0
                add.w   D0,D1
                moveq   #0,D0
                eori.w  #$000F,D2
                bset    D2,D0

                movea.l $0000044E.w,A0
                adda.w  D1,A0
                or.w    D0,(A0)

                tst.w   knapp
                beq.s   test

                rts

************************************************

                >PART 'Mouse Init'
******************************
**       MOUSE INIT
******************************

mouseinit:      pea     readmouse(PC)   ; make sure mouse is in right mode..
                move.w  #4,-(A7)
                move.w  #25,-(A7)
                trap    #14
                addq.l  #8,A7

                lea     olda09(PC),A0
                move.b  $FFFFFA09.w,(A0)

                lea     saveaddr(PC),A0
                move.l  $00000118.w,(A0)
                lea     mouseirq1(PC),A0
                move.l  A0,$00000118.w

                bset    #6,$FFFFFA09.w
                rts
                ENDPART

                >PART 'Mouse Restore'
******************************
**      MOUSE RESTORE
******************************

mouserestore:   move.b  olda09(PC),$FFFFFA09.w
                move.l  saveaddr(PC),$00000118.w
                pea     mouseoff(PC)
                move.w  #0,-(A7)
                move.w  #25,-(A7)
                trap    #14
                addq.l  #8,A7
                rts

                ENDPART

******************************
**      MOUSE IRQ
******************************

mouseirq1:      movem.l D0/A0,-(A7)
                move.b  $FFFFFC02.w,D0
                cmpi.b  #$F8,D0         ; mouse package for sure???
                blo.s   notnow
                cmpi.b  #$FB,D0
                bhi.s   notnow
                and.w   #$0003,D0
                lea     knapp(PC),A0
                move.w  D0,(A0)
                lea     mouseirq2(PC),A0
                move.l  A0,$00000118.w
notnow:         movem.l (A7)+,D0/A0
                bclr    #6,$FFFFFA11.w
                rte

mouseirq2:      movem.l D0/A0,-(A7)     ; X
                move.b  $FFFFFC02.w,D0
                ext.w   D0
                lea     permx(PC),A0
                add.w   D0,(A0)
                lea     mouseirq3(PC),A0
                move.l  A0,$00000118.w
                movem.l (A7)+,D0/A0
                bclr    #6,$FFFFFA11.w
                rte

mouseirq3:      movem.l D0/A0,-(A7)     ; Y
                move.b  $FFFFFC02.w,D0
                ext.w   D0
                lea     x(PC),A0
                add.w   D0,2(A0)
                move.w  4(A0),(A0)
                lea     mouseirq1(PC),A0
                move.l  A0,$00000118.w
                movem.l (A7)+,D0/A0
                bclr    #6,$FFFFFA11.w
                rte

************************************
**       D A T A
************************************

saveaddr:       DC.L 0          ; old address in $118.w
knapp:          DC.W 0          ; bit 0 and 1
x:              DC.W 100
y:              DC.W 100
permx:          DC.W 0
olda09:         DC.B 0
readmouse:      DC.B $08
mouseoff:       DC.B $0C
                EVEN
                END
