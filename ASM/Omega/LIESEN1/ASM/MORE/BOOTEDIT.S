                opt P+

                PART 'BEGIN AND END'
                lea     TEXT(pc),a0
                bsr.s   PRINTINP
                cmp.w   #32,d0
                beq.s   EXIT

                lea     BLOCK(pc),a6    ; save bootblock #1
                bsr.s   KILLVIRUS

EXIT:           rts
                endpart

                >PART 'PRINT AND GET KEY'
******************************************
**      PRINT A0 AND GET KEY D0
******************************************
PRINTINP:       move.l  a0,-(a7)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                move.w  #2,-(a7)
                move.w  #2,-(a7)
                trap    #13
                addq.l  #4,a7
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
                >PART 'KILL VIRUS'
*******************************************
**      KILL VIRUS
*******************************************
KILLVIRUS:      bsr.s   COUNT_CHECK
                move.w  #1,-(a7)        ; ONE SECTOR
                move.w  #0,-(a7)        ; SIDE 0
                move.w  #0,-(a7)        ; START AT TRACK 0
                move.w  #1,-(a7)        ; START AT SECTOR 1
                move.w  #0,-(a7)        ; DRIVE A
                clr.l   -(a7)           ; POINTLESS
                pea     AREA2(pc)
                move.w  #9,-(a7)
                trap    #14
                lea     20(a7),a7
                tst.l   d0
                bmi.s   ERROR
                rts

*****************************
ERROR:          lea     ERRORTEXT(pc),a0
                bsr.s   PRINTINP
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

                >PART 'DATA'
**************************************
***     DATA
**************************************

TEXT:           dc.b 27,"E"
                dc.b "LIESEN'S BOOTBLOCK TESTER, V1.0",13,10,10
                dc.b "SPACE TO NOT SAVE THIS BOOTBLOCK",0

ERRORTEXT:      dc.b 27,"E"
                dc.b "**** ERROR ERROR ERROR ****",0
                even
                endpart


                PART 'BOOTBLOCKET'

BLOCK:          bra.s   BOOT            ;0-1    BRANCH INSTRUCTION
                dc.b "OMEGA!"   ;2-7    LOADER
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
                dc.b $00,$00    ;28-29  NUMBER OF HIDDEN SECTORS

BOOT:
                movea.l $000004F2,a0
                cmpi.w  #$0106,2(a0)
                bne.s   WRONGTOS

                pea     BOOTTEXT(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.w  #8,a7


                pea     $00000200
                move.w  #$0048,-(a7)
                trap    #1
                addq.w  #6,a7
                tst.l   d0
                bmi.s   WRONGTOS

                movea.l d0,a0
                movea.l a0,a6
                lea     VBL(pc),a1
                moveq   #$7F,d0
LOOP:           move.l  (a1)+,(a0)+
                dbra    d0,LOOP


                move.l  a6,$00000070.w

                move.w  #$0000,-(a7)
                pea     $FFFFFFFF
                pea     $FFFFFFFF
                move.w  #$0005,-(a7)
                trap    #$0E
                lea     $000C(a7),a7
                jmp     $00E00572

WRONGTOS:       not.w   $FFFF8240.w
                rts

*******************************
********* V B L
*******************************
VBL:            addq.l  #1,$00000466.w
                subq.w  #1,$00000452.w
                bmi     NO_VBL
                movem.l d0-a6,-(a7)
                addq.l  #1,$00000462
                move.b  $0000044C.w,$FFFF8260.w
                jsr     $00E0A938
                tst.l   $0000045A.w
                beq.s   L702E0
                movem.l $0000045A,a0
                movem.l (a0),d0-d7
                movem.l d0-d7,$FFFF8240.w
                clr.l   $0000045A.w
L702E0:         tst.l   $0000045E.w
                beq.s   L702FE
                move.l  $0000045E.w,$0000044E.w
                move.b  $00000451.w,$FFFF820D.w
                move.b  $00000450.w,$FFFF8203.w
                move.b  $0000044F.w,$FFFF8201.w
L702FE:         jsr     $00E01528
                move.w  $00000454.w,d7
                beq.s   L70328
                subq.l  #1,d7
                movea.l $00000456.w,a0
L70310:         movea.l (a0)+,a1
                cmpa.l  #$00000000,a1
                beq.s   L70324
                movem.l d7-a0,-(a7)
                jsr     (a1)
                movem.l (a7)+,d7-a0
L70324:         dbra    d7,L70310
L70328:         tst.w   $000004EE.w
                bne.s   L70350
                move.w  #$FFFF,$000004EE
                move.b  #$00,$FFFF820A.w
                eori.w  #3,$FFFF8260.w
                move.w  $00004000,d0
L70342:         dbra    d0,L70342
                move.b  #$02,$FFFF820A.w
                eori.w  #3,$FFFF8260.w
L70350:         movem.l (a7)+,d0-a6
NO_VBL:         addq.w  #1,$00000452.w
                rte

BOOTTEXT:       dc.b "Omega's Boot Color",13,10,10
                dc.b "1 Boot Other Disk",13,10
                dc.b "2 Color This Disk",13,10
                dc.b "Other Mono This Disk",0

SLUTBLOCK:
BLOCKSIZE       equ SLUTBLOCK-BLOCK
                ds.b 512-BLOCKSIZE ; BETTER BE SURE

                if BLOCKSIZE>512
                fail
                endc

                endpart

                >PART 'BSS DATA'
                data
AREA1:          ds.b 512
AREA2:          ds.b 512
                endpart


                end
