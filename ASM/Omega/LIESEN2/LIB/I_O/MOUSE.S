* This mouse routine uses the system irq (=not an own $118.w)
* which is called when a mouse package has been recived. This routine
* is perfect if you would like all the other keyboard routines to operate
* at the same time.
*
* Made by Martin Liesen 1991 (PC Relativ...) as an example...
*
* Hello To: Mats and Stephan!!!!
*
* Draw on screen rout is for Monochrom....
*
* Make sure that $118.w is not masked away (bit 6 IRB) and that
* the MFP irq's is running (not masked with IPL)
*
***********************************************************************

begin:          bsr.s   mouseinit

                pea     test(PC)        ; start test in supervisor
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7

                bsr     mouserestore

                clr.w   -(A7)
                trap    #1

******************************
**     T E S T
******************************

test:           lea     x(PC),A0        ; kepp mouse on screen...
                cmpi.w  #399,2(A0)
                ble.s   yoki1
                move.w  #399,2(A0)
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
                mulu    #80,D1
                move.w  D0,D2
                and.w   #$000F,D2
                sub.w   D2,D0
                lsr.w   #3,D0
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


******************************
**       MOUSE INIT
******************************

mouseinit:      move.w  #34,-(A7)       ; start mouse irq (and save old)
                trap    #14
                addq.l  #2,A7
                movea.l D0,A0
                lea     16(A0),A0
                lea     savevect(PC),A1
                move.l  A0,(A1)
                move.l  (A0),4(A1)
                lea     mouseirq(PC),A1
                move.l  A1,(A0)

                pea     readmouse(PC)   ; make sure mouse is in right mode..
                move.w  #4,-(A7)
                move.w  #25,-(A7)
                trap    #14
                addq.l  #8,A7
                rts

******************************
**      MOUSE RESTORE
******************************

mouserestore:   movea.l savevect(PC),A0 ; restore mouse vectors and quit
                move.l  saveaddr(PC),(A0)
                pea     mouseoff(PC)
                move.w  #0,-(A7)
                move.w  #25,-(A7)
                trap    #14
                addq.l  #8,A7
                rts

******************************
**      MOUSE IRQ
******************************

mouseirq:       movem.l D0/A0-A1,-(A7)
                cmpi.b  #$F8,(A0)       ; mouse package for sure???
                blo.s   notnow
                cmpi.b  #$FB,(A0)
                bhi.s   notnow
                move.b  (A0),D0         ; handel mouse package
                and.w   #$0003,D0
                lea     knapp(PC),A1
                move.w  D0,(A1)
                lea     x(PC),A1
                move.b  1(A0),D0
                ext.w   D0
                add.w   D0,(A1)         ; make this twice, and you get speed...
                move.b  2(A0),D0
                ext.w   D0
                add.w   D0,2(A1)        ; make this twice to..
                clr.w   6(A1)
notnow:         movem.l (A7)+,D0/A0-A1
                rts

************************************
**       D A T A
************************************

savevect:       DC.L 0          ; address to vector
saveaddr:       DC.L 0          ; old address in vector
knapp:          DC.W 0          ; bit 0 and 1
x:              DC.W 100
y:              DC.W 100
readmouse:      DC.B $08
mouseoff:       DC.B $0C

                END
