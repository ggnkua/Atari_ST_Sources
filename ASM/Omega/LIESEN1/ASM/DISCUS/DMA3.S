                OPT P+
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
                lea     buffert(pc),a1
                move.l  a1,2(a6)
                move.w  #0,6(a6)
                move.w  #0,8(a6)
                move.w  #1,10(a6)
                move.w  #100,12(a6)
                moveq   #0,d7
                jsr     (a6)

loop:           cmpi.w  #1,16(a6)
                beq.s   loop

                pea     MotorOffT(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7

                moveq   #3,d7
                jsr     (a6)

                rts
StartT:         DC.B 27,"E"
                DC.B "DMA Interface, made by MAartin Liesen 1991",13,10,10
                DC.B "Loading 100 sectors",13,10,10,0
MotorOffT:      DC.B "Waiting for motor to stop (2s)",13,10,10,0
WriteProtectT:  DC.B "Disc is write protected",13,10,10

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

                bra.s   Get_Lost
*********************************************


*********************************************


DMA_Save_Irq:

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
                bra.s   EndIrq

DMA_Read:       move.w  #$90,$FFFF8606.w          ; Read sector
                move.w  #$0190,$FFFF8606.w
                move.w  #$90,$FFFF8606.w
                move.w  #1,$FFFF8604.w
                move.w  #$84,$FFFF8606.w          ; Sector reg.
                move.w  Sector(pc),$FFFF8604.w
                move.w  #$80,$FFFF8606.w          ; Command reg.
                move.w  #$80,$FFFF8604.w

                subq.w  #1,SectorCount-DMA(a6)    ;Decrease counter
                beq.s   Finished
                addq.w  #1,Sector-DMA(a6)         *Add sector


EndIrq:         movem.l (a7)+,d0-d1/a5-a6
                bclr    #7,$FFFFFA11.w
                rte



*********************************************
*     Finished with LOAD/SAVE
*********************************************
Finished:       move.b  MFP(pc),$FFFF8209.w
                move.b  MFP+1(pc),$FFFFFA15.w
                move.b  MFP+2(pc),$FFFFFA11.w
                move.l  SaveDMA_Irq(pc),$011C.w
                move.w  #$80,$FFFF8606.w
                move.w  $FFFF8604.w,d0
                move.w  d0,Status-DMA(a6)
                move.w  #0,Return-DMA(a6)
                movem.l (a7)+,d0-d1/a5-a6
                rte

******************************************************************
                ENDPART

buffert:        REPT 100*32
                DC.B 'SkinnyPuppy.NEP.'
                ENDR
                END
