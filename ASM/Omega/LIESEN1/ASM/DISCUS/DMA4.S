                OPT P-
                >PART 'Start'
                pea     super(pc)
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                clr.w   -(a7)
                trap    #1
                ENDPART
super:
                pea     StartT(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7


                lea     DMA(pc),a6

****************************************

                lea     buffert(pc),a5
                bsr     load

****************************************

                move.w  14(a6),d0
                btst    #6,d0
                beq.s   notwp


                pea     WriteProtectT(pc)         ; Write Protect, skip saving
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                bra.s   Join


****************************************

notwp:          pea     NotWritePT(pc)            ; Not Write Protected
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7

                move.w  #7,-(a7)
                trap    #1
                addq.l  #2,a7



                lea     buffert(pc),a5
                bsr     save
                lea     testbuf,a5
                bsr.s   load

                lea     buffert(pc),a0
                lea     testbuf,a1
                move.w  #512*128/4-1,d0
testing:        cmpm.l  (a0)+,(a1)+
                bne.s   felfel
                not.w   $FFFF8240.w
                dbra    d0,testing
                bra.s   NoFel
felfel:         movem.l d0-a6,-(a7)
                pea     SaveErrorT(pc)            ; Error
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                movem.l (a7)+,d0-a6
                move.w  14(a6),d0
                illegal
NoFel:          pea     NoSaveError(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7

****************************************

Join:           pea     MotorOffT(pc)             ; Motor off
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7

                moveq   #3,d7
                jsr     (a6)

****************************************


                rts



load:           >PART 'Load 128 sectors into a5'

                pea     LoadingT(pc)              ; Loading
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7

                move.l  a5,2(a6)
                move.w  #0,6(a6)
                move.w  #0,8(a6)
                move.w  #1,10(a6)
                move.w  #128,12(a6)
                moveq   #0,d7
                jsr     (a6)

loop:           cmpi.w  #1,16(a6)
                beq.s   loop


                cmpi.w  #-1,16(a6)
                bne.s   noterror1

                pea     Error1T(pc)               ; Error
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                move.w  14(a6),d0
                illegal
noterror1:      rts
                ENDPART
save:           >PART 'Save 128 sectors from a5'

                pea     SavingT(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                move.l  a5,2(a6)
                move.w  #0,6(a6)
                move.w  #0,8(a6)
                move.w  #1,10(a6)
                move.w  #128,12(a6)
                moveq   #1,d7
                jsr     (a6)

loop2:          cmpi.w  #1,16(a6)
                beq.s   loop2


                cmpi.w  #-1,16(a6)
                bne.s   noterror2

                pea     Error2T(pc)               ; Error
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                move.w  14(a6),d0
                illegal
noterror2:      rts

                ENDPART




StartT:         DC.B 27,"E"
                DC.B "DMA Interface, made by Martin Liesen 1991.",13,10,10,0
WriteProtectT:  DC.B "Disc is write protected.",13,10,10,0
NotWritePT:     DC.B "Disc is not write protected.",13,10,10,0
LoadingT:       DC.B "Loading 128 sectors",13,10,10,0
SavingT:        DC.B "Saving same 128 sectors",13,10,10,0


MotorOffT:      DC.B "Waiting for motor to stop (2s)",13,10,10,0

Error1T:        DC.B "DMA Error while loading, Error in D0!   Bye!.",13,10,10,0
Error2T:        DC.B "DMA Error while saving, Error in D0!  Bye!",13,10,10,0
SaveErrorT:     DC.B "Saving went all wrong.. Sorry! D0=FDC Status.. Bye!",13,10,10,0
NoSaveError:    DC.B "NO error in saving!",13,10,10,0
                EVEN


                >PART 'DMA Interface doc'

* Status:      bit 0       Bussy (Executing a command)
*              bit 1       Data Request               (type 1, Index pulse)
*              bit 2       !Lost Data                 (type 1, At track 00)
*              bit 3       !Crc Error
*              bit 4       !Record not found
*              bit 5       $F8 data marker (erased)   (type 1, Spin up)
*              bit 6       !Write protected (only after write!)
*              bit 7       Motor on

* When calling D7 should contain the command you wish to execute.

* 0       Load sector(s)
* 1       Write sector(s)
* 2       Update Status
* 3       Wait for motor off

                ENDPART
DMA:            >PART 'DMA Interface'
*********************************************
                bra.s   StartDMA
DestAddr:       DS.L 1                            ;2
Side:           DS.W 1                            ;6
Track:          DS.W 1                            ;8
Sector:         DS.W 1                            ;10
SectorCount:    DS.W 1                            ;12
Status:         DS.W 1                            ;14
Return:         DS.W 1                            ;16  1 Bussy,0 Done,-1 Error
*********************************************

StartDMA:       movem.l d0-a6,-(a7)
                lea     DMA(pc),a6
UpYours:        cmpi.w  #1,Return-DMA(a6)         ; Command in process??
                beq.s   UpYours

Wait_Acia:      btst    #1,$FFFFFC00.w            ; Acia bussy??
                beq.s   Wait_Acia

                move.b  #14,$FFFF8800.w           ; Set Side
                move.b  $FFFF8800.w,d0
                and.b   #$F8,d0
                bset    #2,d0
                tst.w   Side-DMA(a6)
                bne.s   SideOne
                bset    #0,d0
SideOne:        move.b  d0,$FFFF8802.w

*********************************************

                cmp.w   #1,d7
                ble.s   Load_Save
                cmp.w   #2,d7
                bne.s   NotGetStatus
                move.w  #$80,$FFFF8606.w          ; Get Status
                move.w  $FFFF8604.w,Status-DMA(a6)
                bra.s   Get_Lost

NotGetStatus:   cmp.w   #3,d7
                bne.s   Get_Lost                  ; Wait for Motor Off
                move.w  #$80,$FFFF8606.w
WaitForOff:     move.w  $FFFF8604.w,d0
                btst    #7,d0
                bne.s   WaitForOff
                move.w  d0,Status-DMA(a6)

Get_Lost:       movem.l (a7)+,d0-a6
                rts
*********************************************

MFP:            DS.L 1
SaveDMA_Irq:    DS.L 1

*********************************************
Load_Save:      move.w  #1,Return-DMA(a6)         ; Set BUSSY
                move.w  #$80,$FFFF8606.w
StillB:         move.w  $FFFF8604.w,d0
                btst    #0,d0
                bne.s   StillB

                move.b  DestAddr+3(pc),$FFFF860D.w ; Set DMA address
                move.b  DestAddr+2(pc),$FFFF860B.w
                move.b  DestAddr+1(pc),$FFFF8609.w

                move.b  $FFFF8209.w,MFP-DMA(a6)   ; Save MFP
                move.b  $FFFFFA15.w,MFP+1-DMA(a6)
                move.b  $FFFFFA11.w,MFP+2-DMA(a6)
                move.l  $011C.w,SaveDMA_Irq-DMA(a6)

                move.w  #$86,$FFFF8606.w          ; Move to start Track
                move.w  Track(pc),$FFFF8604.w
                move.w  #$80,$FFFF8606.w          ; Command reg.
                move.w  #$13,$FFFF8604.w          ; Seek, 6 ms

                lea     DMA_Load_Irq(pc),a0
                tst.w   d7
                beq.s   Yes_Load
                lea     DMA_Save_Irq(pc),a0
Yes_Load:       move.l  a0,$011C.w
                bset    #7,$FFFFFA09.w            ; Start MFP
                bset    #7,$FFFFFA15.w
                bclr    #7,$FFFFFA11.w

                bra     Get_Lost
*********************************************


*********************************************


*********************************************
*  DMA SAVE RUTINE
*********************************************
DMA_Save_Irq:
                not.w   $FFFF8240.w
                movem.l d0-d1/a5-a6,-(a7)
                lea     DMA(pc),a6

                cmpi.w  #9,Sector-DMA(a6)
                ble.s   DMA_Write                 ; Time to step?

                move.w  #1,Sector-DMA(a6)
                addq.w  #1,Track-DMA(a6)
                move.w  #$80,$FFFF8606.w          ; Command reg.
                move.w  #$53,$FFFF8604.w          ; (Step In 6ms)

                move.w  $FFFF8604.w,d0            ; Check Status
                and.w   #%11000,d0
                bne     DMA_Error

                bra.s   EndIrq2

DMA_Write:      move.w  #$0190,$FFFF8606.w        ; Read sector
                move.w  #$90,$FFFF8606.w
                move.w  #$0190,$FFFF8606.w
                move.w  #1,$FFFF8604.w
                move.w  #$0184,$FFFF8606.w        ; Sector reg.
                move.w  Sector(pc),$FFFF8604.w
                move.w  #$0180,$FFFF8606.w        ; Command reg.
                move.w  #$A0,$FFFF8604.w

                move.w  $FFFF8604.w,d0            ; Check Status
                and.w   #%11000,d0
                bne     DMA_Error


                subq.w  #1,SectorCount-DMA(a6)    ;Decrease counter
                beq     Finished
                addq.w  #1,Sector-DMA(a6)         *Add sector


EndIrq2:        movem.l (a7)+,d0-d1/a5-a6
                bclr    #7,$FFFFFA11.w
                rte



*********************************************
*  DMA LOAD RUTINE
*********************************************
DMA_Load_Irq:
                not.w   $FFFF8240.w
                movem.l d0-d1/a5-a6,-(a7)
                lea     DMA(pc),a6

                cmpi.w  #9,Sector-DMA(a6)
                ble.s   DMA_Read                  ; Time to step?

                move.w  #1,Sector-DMA(a6)
                addq.w  #1,Track-DMA(a6)
                move.w  #$80,$FFFF8606.w          ; Command reg.
                move.w  #$53,$FFFF8604.w          ; (Step In 6ms)

                move.w  $FFFF8604.w,d0            ; Check Status
                and.w   #%11000,d0
                bne.s   DMA_Error

                bra.s   EndIrq

DMA_Read:       move.w  #$90,$FFFF8606.w          ; Read sector
                move.w  #$0190,$FFFF8606.w
                move.w  #$90,$FFFF8606.w
                move.w  #1,$FFFF8604.w
                move.w  #$84,$FFFF8606.w          ; Sector reg.
                move.w  Sector(pc),$FFFF8604.w
                move.w  #$80,$FFFF8606.w          ; Command reg.
                move.w  #$80,$FFFF8604.w

                move.w  $FFFF8604.w,d0            ; Check Status
                and.w   #%11000,d0
                bne.s   DMA_Error


                subq.w  #1,SectorCount-DMA(a6)    ;Decrease counter
                beq.s   Finished
                addq.w  #1,Sector-DMA(a6)         *Add sector


EndIrq:         movem.l (a7)+,d0-d1/a5-a6
                bclr    #7,$FFFFFA11.w
                rte



*********************************************
*     DMA ERROR
*********************************************
DMA_Error:      move.b  MFP(pc),$FFFF8209.w
                move.b  MFP+1(pc),$FFFFFA15.w
                move.b  MFP+2(pc),$FFFFFA11.w
                move.l  SaveDMA_Irq(pc),$011C.w
                move.w  #$80,$FFFF8606.w
                move.w  $FFFF8604.w,d0
                move.w  d0,Status-DMA(a6)
                move.w  #-1,Return-DMA(a6)
                movem.l (a7)+,d0-d1/a5-a6
                bclr    #7,$FFFFFA11.w
                rte
*********************************************
*     Finished with LOAD/SAVE
*********************************************
Finished:
                lea     LastIrq(pc),a0
                move.l  a0,$011C.w
                movem.l (a7)+,d0-d1/a5-a6
                bclr    #7,$FFFFFA11.w
                rte

LastIrq:        movem.l d0-d1/a5-a6,-(a7)
                lea     DMA(pc),a6
                move.b  MFP(pc),$FFFF8209.w
                move.b  MFP+1(pc),$FFFFFA15.w
                move.b  MFP+2(pc),$FFFFFA11.w
                move.l  SaveDMA_Irq(pc),$011C.w
                move.w  #$80,$FFFF8606.w
                move.w  $FFFF8604.w,d0
                move.w  d0,Status-DMA(a6)
                move.w  #0,Return-DMA(a6)
                movem.l (a7)+,d0-d1/a5-a6
                bclr    #7,$FFFFFA11.w
                rte

******************************************************************
                ENDPART

                BSS
buffert:        DS.B 255*512
testbuf:        DS.B 255*512
                END
