                opt P+

                >PART 'SETUP'
; ***********************************************
;             START
; ***********************************************
                move.w  #4,-(a7)
                trap    #14
                addq.l  #2,a7
                lea     OLDREZ(pc),a0
                move.w  d0,(a0)
                cmp.w   #0,d0
                bne.s   NOTLOW
                move.w  #1,-(a7)
                pea     -1
                pea     -1
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7
NOTLOW:
                pea     STARTSUPER(pc)
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
NOPUS:          bsr     BEGINUS
ENDNOPUS:
                pea     SAVECOL(pc)
                move.w  #6,-(a7)
                trap    #14
                addq.l  #6,a7
                move.w  OLDREZ(pc),-(a7)
                pea     -1
                pea     -1
                move.w  #5,-(a7)
                trap    #14
                lea     12(a7),a7

                clr.w   -(a7)
                trap    #1
                endpart
                PART 'SUPER'
*************************************************
**      SUPER START HERE
*************************************************
STARTSUPER:     move    #$2300,sr
                movem.l $FFFF8240.w,d0-d7
                lea     SAVECOL(pc),a0
                movem.l d0-d7,(a0)
                move.l  #$0FFF,$FFFF8240.w
                move.l  #$0FFF0FFF,$FFFF8244.w
                move.w  #$0FFF,$FFFF825E.w
                movea.l $98.w,a0
                cmpi.l  #'ILAK',2(a0)
                bne.s   NIXNIXI
                cmpi.w  #$0105,6(a0)
                blo.s   NIXNIXI
                rts

NIXNIXI:        lea     OCNOTFOUND(pc),a0
                bsr     PRINTINP
                lea     NOPUS(pc),a0
                lea     ENDNOPUS(pc),a1
MOREA:          move.w  #$4E71,(a0)+
                cmpa.l  a0,a1
                bne.s   MOREA
                rts
OCNOTFOUND:     dc.b 27,"E"
                dc.b "Sorry Pal, You must have
Omega Commands Version 1.05
or higher installed in memory!!",0
                even
                endpart

                >PART 'INITUS'
BEGINUS:        moveq   #2,d0
                trap    #6
                lea     DISKADDR(pc),a1
                move.l  a0,(a1)
                moveq   #7,d0
                trap    #6
                lea     MENUADDR(pc),a1
                move.l  a0,(a1)
                endpart
                >PART 'MAIN LOOP'
MAINLOOP:
                movea.l MENUADDR(pc),a0
                lea     TEXTEN(pc),a1
                move.l  a1,2(a0)
                move.w  #0,6(a0)
                lea     MENUAREA(pc),a1
                move.l  a1,16(a0)
                move.w  #0,20(a0)
                jsr     (a0)

                cmp.w   #5,d0
                beq.s   EXIT
                cmp.w   #1,d0
                bne.s   NOTEXAM         ; examine disc
                bsr     EXAMINE
                bra.s   MAINLOOP
NOTEXAM:        cmp.w   #2,d0
                bne.s   NOTELIM
                bsr.s   ELIMINATE
                bra.s   MAINLOOP
NOTELIM:        cmp.b   #$03,d0
                bne.s   NOTSAVEB
                bsr     SAVEBLOCK       ; save bootblock as file
                bra.s   MAINLOOP
NOTSAVEB:       cmp.b   #$04,d0
                bne.s   MAINLOOP
                bsr     COPYBOOT        ; copy boot block
                bra.s   MAINLOOP

EXIT:           rts
                endpart


ELIMINATE:      >PART 'Virus Eliminate'

ELI_LOOP:       movea.l MENUADDR(pc),a0
                lea     ELIMINATE_TEXT(pc),a1
                move.l  a1,2(a0)
                jsr     (a0)

                cmp.w   #1,d0
                bne.s   NOTSAVEB1
                lea     BLOCK1(pc),a6   ; save bootblock #1
                bsr     KILLVIRUS
                bra.s   ELI_LOOP
NOTSAVEB1:
                cmp.b   #2,d0
                bne.s   NOTSAVEANTI
                lea     BLOCK2(pc),a6   ; save antivirus
                bsr     KILLVIRUS
                bra.s   ELI_LOOP
NOTSAVEANTI:
                cmp.b   #3,d0
                bne.s   NOT_BDEMOS
                bsr     BOOTDEMOS
                bra.s   ELI_LOOP
NOT_BDEMOS:     cmp.b   #4,d0
                bne.s   NOT_OWNBB
                bsr     OWN_BLOCKS
                bra.s   ELI_LOOP
NOT_OWNBB:      cmp.b   #5,d0
                bne.s   ELI_LOOP

                rts
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
                >PART 'COPYBOOTBLOCK'
*******************************************
**      COPY BOOTSECTOR
*******************************************
COPYBOOT:       movea.l MENUADDR(pc),a1
                lea     COPYTEXT(pc),a0
                move.l  a0,2(a1)
                jsr     (a1)
                cmp.w   #1,d0
                bne.s   NOTBF1
                bsr.s   COPYANDKEEP
                bra.s   COPYBOOT
NOTBF1:         cmp.w   #2,d0
                bne.s   NOTBF2
                moveq   #-1,d7
                bsr.s   FINALCOPY
                bra.s   COPYBOOT
NOTBF2:         cmp.w   #3,d0
                bne.s   COPYBOOT
                rts
************************
COPYANDKEEP:
                lea     KEEPCOPY(pc),a0
                bsr.s   PRINTINP
                swap    d0
                cmp.b   #$3B,d0
                bne.s   NOTBBF1
                moveq   #8,d7
                bsr.s   FINALCOPY
                bra.s   COPYANDKEEP
NOTBBF1:        cmp.b   #$3C,d0
                bne.s   NOTBBF2
                move.w  #510,d7
                bsr.s   FINALCOPY
                bra.s   COPYANDKEEP
NOTBBF2:        cmp.b   #1,d0
                bne.s   COPYANDKEEP
                rts
*********************************
FINALCOPY:      move.w  d7,-(a7)
                lea     INSERTTEXT1(pc),a0
                bsr     PRINTINP
                bsr     LADDABOOTBLOCK
                lea     AREA2(pc),a0
                lea     AREA1(pc),a1
                moveq   #127,d0
SHITOH:         move.l  (a1)+,(a0)+
                dbra    d0,SHITOH

                lea     INSERTTEXT2(pc),a0
                bsr     PRINTINP
                bsr     LADDABOOTBLOCK
                move.w  (a7)+,d7
                bmi.s   SKIPIT
                lea     AREA2(pc),a0
                lea     AREA1+11(pc),a2
                lea     11(a0),a3
                moveq   #28,d0
JESUS_YHEAA:    move.b  (a2)+,(a3)+
                dbra    d0,JESUS_YHEAA
                clr.w   0(a0,d7.w)
                move.w  #255,d0
                moveq   #0,d1
                movea.l a0,a1
SO_VERY_NICE:   add.w   (a1)+,d1
                dbra    d0,SO_VERY_NICE
                move.w  #$1234,d0
                sub.w   d1,d0
                move.w  d0,0(a0,d7.w)
SKIPIT:
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
                bmi.s   ERRORA
                rts
***************************
ERRORA:         movea.l MENUADDR(pc),a1
                lea     ERRORTEXT(pc),a0
                move.l  a0,2(a1)
                jsr     (a1)
                rts
                endpart
                >PART 'SAVE A IMG'
*******************************************
**      SAVE BOOT BLOCK AS FILE
*******************************************
SAVEBLOCK:      bsr     LADDABOOTBLOCK
                lea     SAVENAME(pc),a0
                move.l  #"BOOT",(a0)+
                move.l  #"BLK0",(a0)+
                move.l  #".IMG",(a0)+
                lea     SAVENAME(pc),a5
                lea     AREA1(pc),a4
                lea     512(a4),a3
SAVEHIM:        addq.b  #1,7(a5)
                movea.l DISKADDR(pc),a6
                move.w  #1,2(a6)
                move.l  a5,6(a6)
                move.l  a4,10(a6)
                move.l  a3,14(a6)       ; ANVŽND 18 ISTŽLLET
                move.w  #-1,24(a6)      ; SPARA ™VER OM DEN FINNS
                move.w  #0,38(a6)       ; READ/WRITE STATUS
                jsr     (a6)
                movea.l DISKADDR(pc),a6
                cmpi.w  #-2,22(a6)
                beq.s   SAVEHIM
                bmi.s   FUCKFUCK
                pea     SPARATEXT(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                lea     SAVENAME(pc),a0
                bsr     PRINTINP
                rts

FUCKFUCK:       movea.l MENUADDR(pc),a1
                lea     ERROR2(pc),a0
                move.l  a0,2(a1)
                jsr     (a1)
                rts
                endpart

                >PART 'EXAMINE BOOTBLOCK'
*******************************************
**      EXAMINE BOOT BLOCK
*******************************************
EXAMINE:        bsr     LADDABOOTBLOCK
                lea     TAL1(pc),a0
                lea     AREA1(pc),a1
                move.l  a1,(a0)
                lea     TAL2(pc),a0
                lea     PESTRAD(pc),a1
                move.l  a1,(a0)

DRAWALL:        lea     AREA1(pc),a0
                moveq   #0,d7
                move.w  #255,d0
COUNT:          add.w   (a0)+,d7
                dbra    d0,COUNT
                cmp.w   #$1234,d7
                bne.s   NOT_EXEC
                pea     EXEC(pc)
                bra.s   JOIN
NOT_EXEC:       pea     NOEXEC(pc)
JOIN:           move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7

                movea.l TAL1(pc),a6
                movea.l TAL2(pc),a4
                moveq   #15,d7
LOOPROW:        movea.l a6,a5
                moveq   #7,d6
GOX1:           moveq   #1,d3
GOX2:           move.b  (a5)+,d5
                move.b  d5,d4
                and.w   #$0F,d5
                lsr.w   #4,d4
                and.w   #$0F,d4
                add.b   #'0',d4
                add.b   #'0',d5
                cmp.b   #'9',d4
                bls.s   OK1
                add.b   #'A'-'9',d4
OK1:            cmp.b   #'9',d5
                bls.s   OK2
                add.b   #'A'-'9',d5
OK2:            move.w  d4,-(a7)
                move.w  #2,-(a7)
                trap    #1
                move.w  d5,-(a7)
                move.w  #2,-(a7)
                trap    #1
                lea     8(a7),a7
                dbra    d3,GOX2
                move.w  #' ',-(a7)
                move.w  #2,-(a7)
                trap    #1
                addq.l  #4,a7
                dbra    d6,GOX1

                move.l  a4,-(a7)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                lea     7(a4),a4

                moveq   #15,d6
LOOPX3:         move.b  (a6)+,d5
                and.w   #$FF,d5
                cmp.w   #32,d5
                blo.s   OJSAN
                cmp.w   #$7E,d5
                bhi.s   OJSAN
                bra.s   JOIN2
OJSAN:          moveq   #".",d5
JOIN2:          and.w   #$FF,d5
                move.w  d5,-(a7)
                move.w  #2,-(a7)
                trap    #1
                addq.l  #4,a7
                dbra    d6,LOOPX3

                pea     NYRAD(pc)
                move.w  #9,-(a7)
                trap    #1
                addq.l  #6,a7
                dbra    d7,LOOPROW

                movea.l MENUADDR(pc),a0
                move.w  #-1,20(a0)
                lea     INFO(pc),a1
                move.l  a1,2(a0)
                jsr     (a0)
                move.w  #0,20(a0)

WAITKEY:
                cmp.w   #2,d0
                bne.s   NOTTF1
                lea     TAL1(pc),a0
                lea     AREA1(pc),a1
                move.l  a1,(a0)
                lea     TAL2(pc),a0
                lea     PESTRAD(pc),a1
                move.l  a1,(a0)
                bra     DRAWALL
NOTTF1:         cmp.w   #3,d0
                bne.s   NOTTF2
                lea     TAL1(pc),a0
                lea     AREA1+256(pc),a1
                move.l  a1,(a0)
                lea     TAL2(pc),a0
                lea     PESTRAD+112(pc),a1
                move.l  a1,(a0)
                bra     DRAWALL
NOTTF2:         cmp.w   #1,d0
                bne.s   NOTTF3
                bsr     LADDABOOTBLOCK
                bra     DRAWALL
NOTTF3:         cmp.w   #4,d0
                bne.s   NOTF4
                bsr     ELIMINATE
                bsr     LADDABOOTBLOCK
                bra     DRAWALL
NOTF4:
                cmp.w   #5,d0
                bne.s   WAITKEY
                rts

NOEXEC:         dc.b 27,"E"
                dc.b "THIS BOOTBLOCK IS NOT EXECUTABLE",13,10
                dc.b 10,10,10,10,10,10,0
EXEC:           dc.b 27,"E",27,"p"
                dc.b "THIS BOOTBLOCK IS EXECUTABLE"
                dc.b 27,"q",13,10,10,10,10,10,10,10,0
INFO:
                dc.b "q04",0
                dc.b "s01",0
                dc.b "u00",0
                dc.b "d+010",0
                dc.b ">AcLOAD A NEW BOOT BLOCK",0
                dc.b ">BcLOOK AT BYTE 0-255",0
                dc.b ">CcLOOK AT BYTE 256-511",0
                dc.b ">DcVIRUS ELIMINATE",0
                dc.b ">JcGO TO MAIN MENU",0
                dc.b "e",0
NYRAD:          dc.b 13,10,0
PESTRAD:        dc.b " 000  ",0
                dc.b " 010  ",0
                dc.b " 020  ",0
                dc.b " 030  ",0
                dc.b " 040  ",0
                dc.b " 050  ",0
                dc.b " 060  ",0
                dc.b " 070  ",0
                dc.b " 080  ",0
                dc.b " 090  ",0
                dc.b " 0A0  ",0
                dc.b " 0B0  ",0
                dc.b " 0C0  ",0
                dc.b " 0D0  ",0
                dc.b " 0E0  ",0
                dc.b " 0F0  ",0
                dc.b " 100  ",0
                dc.b " 110  ",0
                dc.b " 120  ",0
                dc.b " 130  ",0
                dc.b " 140  ",0
                dc.b " 150  ",0
                dc.b " 160  ",0
                dc.b " 170  ",0
                dc.b " 180  ",0
                dc.b " 190  ",0
                dc.b " 1A0  ",0
                dc.b " 1B0  ",0
                dc.b " 1C0  ",0
                dc.b " 1D0  ",0
                dc.b " 1E0  ",0
                dc.b " 1F0  ",0
                even
TAL1:           dc.l 0
TAL2:           dc.l 0
                endpart

                >PART 'BOOTDEMOS'
BOOTDEMOS:
                movea.l MENUADDR(pc),a0
                lea     BOOTDTEXT(pc),a1
                move.l  a1,2(a0)
                jsr     (a0)
                cmp.b   #1,d0
                bne.s   NOTB1
                lea     BBLOCKD1(pc),a6 ; save antivirus
                bsr     KILLVIRUS
                bra.s   BOOTDEMOS
NOTB1:
                cmp.b   #2,d0
                bne.s   NOTB2
                lea     BBLOCKD2(pc),a6 ; save antivirus
                bsr     KILLVIRUS
                bra.s   BOOTDEMOS
NOTB2:
                cmp.b   #3,d0
                bne.s   NOTB3
                lea     BBLOCKD3(pc),a6 ; save antivirus
                bsr     KILLVIRUS
                bra.s   BOOTDEMOS
NOTB3:
                cmp.b   #4,d0
                bne.s   NOTB4
                lea     BBLOCKD4(pc),a6 ; save antivirus
                bsr     KILLVIRUS
                bra.s   BOOTDEMOS
NOTB4:
                cmp.b   #5,d0
                bne.s   NOTABOUTBD
                movea.l MENUADDR(pc),a0
                lea     ABOUTBDEMOS(pc),a1
                move.l  a1,2(a0)
                jsr     (a0)
                bra.s   BOOTDEMOS
NOTABOUTBD:
                cmp.b   #6,d0
                bne.s   BOOTDEMOS
                rts

                endpart

                >PART 'Specialboot Blocks'
OWN_BLOCKS:
                movea.l MENUADDR(pc),a0
                lea     OWNBTEXT(pc),a1
                move.l  a1,2(a0)
                jsr     (a0)
                cmp.b   #1,d0
                bne.s   OWN_NOTB1
                lea     BC_BLOCK(pc),a6 ; save boot color 1.60
                bsr.s   KILLVIRUS
                bra.s   OWN_BLOCKS
OWN_NOTB1:      cmp.b   #2,d0
                bne.s   OWN_NOTB2
                lea     BC_BLOCK2_05(pc),a6 ; save boot color 2.05
                bsr.s   KILLVIRUS
                bra.s   OWN_BLOCKS
OWN_NOTB2:      cmp.b   #3,d0
                bne.s   OWN_NOTB3
                lea     BC_BLOCK2_06(pc),a6 ; save boot color 2.06
                bsr.s   KILLVIRUS
                bra.s   OWN_BLOCKS
OWN_NOTB3:      cmp.b   #4,d0
                bne.s   NOT_PCB
                lea     PCBOOT(pc),a0
                bsr.s   SAVEBOOT

NOT_PCB:        cmp.b   #5,d0
                bne.s   OWN_NOTABOUTBD
                movea.l MENUADDR(pc),a0
                lea     ABOUT_BC(pc),a1
                move.l  a1,2(a0)
                jsr     (a0)
                bra.s   OWN_BLOCKS
OWN_NOTABOUTBD:
                cmp.b   #6,d0
                bne.s   OWN_BLOCKS
                rts

                endpart

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
ERROR:          movea.l MENUADDR(pc),a1
                lea     ERRORTEXT(pc),a0
                move.l  a0,2(a1)
                jsr     (a1)
                rts
                endpart
                >PART 'COUNT CHECKSUM'
****************************************
**      COUNT CHECKSUM & LOAD DOS INFO
****************************************
COUNT_CHECK:
                bsr     LADDABOOTBLOCK
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
DISKADDR:       dc.l 0
MENUADDR:       dc.l 0
SAVEUSER:       dc.l 0
SAVE:           dc.l 0
OLDREZ:         dc.w 0
OWNBTEXT:       dc.b "q06",0
                dc.b "u05",0
                dc.b "s01",0
                dc.b "d+050",0
                dc.b ";cSAVE A SPECIAL BOOT BLOCK",0
                dc.b ";c-------------------------",0
                dc.b ";z",0
                dc.b ">AcHI FORCE LOW BOOT, TOS 1.60",0
                dc.b ">BcHI FORCE LOW BOOT, TOS 2.50 (2.5 meg FIX)",0
                dc.b ">CcHI FORCE LOW BOOT, TOS 2.60 (2.5 meg FIX)",0
                dc.b ">DcPC-Tools 720kb BootBlock (Warning!)",0
                dc.b ";z",0
                dc.b ">IcABOUT THOOSE BOOT BLOCKS",0
                dc.b ";z",0
                dc.b ">JcBACK TO LAST MENU",0
                dc.b "e",0

ABOUT_BC:       dc.b "d+025",0
                dc.b "q01",0
                dc.b "s01",0
                dc.b ";cHI FORCE LOW BOOT BLOCK",0
                dc.b ";c-----------------------",0
                dc.b ";cI made this boot block coz of the fact that my",0
                dc.b ";cmonitor port broke down and went into the 'mono always",0
                dc.b ";cconnected, althought it's not state' and that I",0
                dc.b ";cstill felt for being able to play games and watch",0
                dc.b ";cdemos. So this is the result of all this... a way",0
                dc.b ";cto boot disk in color (through TV out) althought the",0
                dc.b ";cmono monitor is connected (goes black...)",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ";cPC-Tools 720Kb",0
                dc.b ";c--------------",0
                dc.b ";cThis Bootblock is a copy of the bootblock that is produced by the",0
                dc.b ";cthe pcformat command in PC-Tools, only use this on 720kb formated disks.",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcRETURN TO SPECIAL BOOTBLOCKS",0
                dc.b "e",0

BOOTDTEXT:      dc.b "q06",0
                dc.b "u06",0
                dc.b "s01",0
                dc.b "d+050",0
                dc.b ";cSAVE A BOOTBLOCK DEMO",0
                dc.b ";z",0
                dc.b ">AcDEMO #1 A SCROLL -LIESEN",0
                dc.b ">BcDEMO #2 A DIST -LIESEN",0
                dc.b ">CcDEMO #3 A GAME -LIESEN",0
                dc.b ">DcDEMO #4 A SCROLL -LIESEN",0
                dc.b ";z",0
                dc.b ">IcABOUT BOOT BLOCK DEMOS",0
                dc.b ";z",0
                dc.b ">JcBACK TO LAST MENU",0
                dc.b "e",0
ABOUTBDEMOS:    dc.b "q01",0
                dc.b "s01",0
                dc.b ";cAll bootblock demos made by Martin Liesen",0
                dc.b ";cworks like this; You boot your disc and the",0
                dc.b ";cdemo activates, by pressing reset you may",0
                dc.b ";creturn to desktop (or wahtever you might have",0
                dc.b ";con that very disc)",0
                dc.b ";cRemeber, the virus killers will say that",0
                dc.b ";cthoose bootdemos is virus, but they",0
                dc.b ";creally ain't. The antivirus will also kill",0
                dc.b ";cthem if you press space when the virus warning",0
                dc.b ";cflashes.. (some newer version don't kill",0
                dc.b ";ceachothers, but that's another story...",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcRETURN TO BOOTDEMOS MENU",0
                dc.b "e",0
SPARATEXT:
                dc.b 27,"E"
                dc.b "SAVED BOOTBLOCK AS:",13,10,0
                even
SAVENAME:       ds.b 13
ERROR2:         dc.b "q99",0
                dc.b "d+075",0
                dc.b ";cERROR - ERROR - ERROR",0
                dc.b ";cFILE OPERAND NOT DONE!!",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcWHAT A PITTY",0
                dc.b "e",0

COPYTEXT:       dc.b "q03",0
                dc.b "s03",0
                dc.b "d+040",0
                dc.b ";cCOPY A BOOTBLOCK",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcF1 COPY BUT KEEP FORMAT",0
                dc.b ">BcF2 COPY WHOLE BOOTBLOCK.",0
                dc.b ";z",0
                dc.b ">CcF3 RETURN TO MENU",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ";cONLY USE F2 IF YOU ARE 100% SURE THAT",0
                dc.b ";cTHE DISCS HAS THE SAME NUMBER OF TRACKS",0
                dc.b ";c,SECTORS AND INTERLEAVE.",13,10
                dc.b ";cF2 IS ONLY USEFUL FOR REPAIRING",0
                dc.b ";cDESTROYED BOOTSECTORS. (ACTUALLY THE",0
                dc.b ";cMOST COMMON REASON WHY A DISC DOESN'T WORK)",0
                dc.b "e",0
KEEPCOPY:
                dc.b 27,"E"
                dc.b "COPY BOOT BLOCK AND KEEP FORMAT",13,10,10
                dc.b "PRESS F1 TO PUT CHECKSUM AT 8 (DEFAULT)",13,10
                dc.b "PRESS F2 TO PUT CHECKSUM AT 510 (TOS)",13,10
                dc.b "PRESS ESC TO GO ONE MENU BACK",13,10,10,10
                dc.b "THE CHECKSUM MUST BE PLACED SOMEWERE",13,10
                dc.b "ON THE BOOT BLOCK! TOS AND MS-DOS SAYS",13,10
                dc.b "THAT IT SHOULD BE PLACED AT +510, BUT I",13,10
                dc.b "THOUGHT THAT +8 IS BETTER AS I THEN",13,10
                dc.b "COULD SQUEEZ IN 2 BYTES OF EXTRA CODE ON MY",13,10
                dc.b "BOOTBLOCKS. +8 SHOULD WORK ON ALMOST",13,10
                dc.b "ANY BOOTBLOCK (AT LEAST MORE THAN ON +510",13,10
                dc.b "AS ALL SMART CODERS USES +8 AND BECOUSE",13,10
                dc.b "ALL STUPID CODERS THAT HAVE LEFT +510 FOR",13,10
                dc.b "CHECKSUM MOST LIKLY DON'T USE +8 (GET IT??)).",0
INSERTTEXT1:
                dc.b 27,"E"
                dc.b "PLEASE INSERT SOURCE DISC",13,10,10,10,0
INSERTTEXT2:
                dc.b "PLEASE INSERT DEST. DISC",13,10
                dc.b "   WITH THE WRITE-PROTECTION REMOVED...",0

TEXTEN:         dc.b "u00",0
                dc.b "s01",0
                dc.b "q99",0
                dc.b "d+045",0
                dc.b ";cLIESEN'S Virus Killer V1.21",0
                dc.b ";cA Synchron Assembly Product",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcEXAMINE A DISC",0
                dc.b ">BcVIRUS ELIMINATOR",0
                dc.b ">CcSAVE BOOTBLOCK AS IMAGE FILE",0
                dc.b ">DcCOPY A BOOTBLOCK",0
                dc.b ";z",0
                dc.b ">JcBACK TO DESKTOP",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ";cProgrammed by MARTIN LIESEN 1990,91",0
                dc.b ";cThis is public domain.",0
                dc.b ";z",0
                dc.b ";cDedicated to SOFIA (Hastings 89)",0
                dc.b "e",0



ELIMINATE_TEXT: dc.b "q05",0
                dc.b "u05",0
                dc.b "s01",0
                dc.b "d+050",0
                dc.b ";cSelect Bootblock to save",0
                dc.b ";c------------------------",0
                dc.b ";z",0
                dc.b ">AcSAVE A NOT BOOTABLE BOOTBLOCK",0
                dc.b ">BcSAVE THE ANTIVIRUS V1.5 (2.5 Meg Fix)",0
                dc.b ";z",0
                dc.b ">CcBOOT BLOCK DEMOS",0
                dc.b ">DcSPECIAL BOOT BLOCKS",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">JcBACK TO LAST MENU",0
                dc.b "e",0


ERRORTEXT:      dc.b "q01",0
                dc.b "d+075",0
                dc.b ";c**** ERROR ERROR ERROR ****",0
                dc.b ";z",0
                dc.b ";cTHE DISC MIGHT BE WRITE PROTECTED",0
                dc.b ";cPLEASE REMOVE IT AND TRY AGAIN",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcTOUGH LUCK MAN!!",0
                dc.b "e",0
                even


                endpart

************************************************

                >PART 'BOOT DEMO #1'

*******************************************
*** Boot Block Demo I
*******************************************
BBLOCKD1:       bra.s   BOOTBD1         ;0-1    BRANCH INSTRUCTION
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
                dc.b $00,$00    ;28-29  NUMBER OF HIDEDEN SECTORS

BOOTBD1:        not.w   $04F0.w
                bne.s   BOOTDEMO1
                rts
BOOTDEMO1:
*************************************************
**      COPY FONT TO $20000 1 BITPLANE  128*16
*************************************************
                dc.w $A000
                movea.l 4(a1),a1
                movea.l 76(a1),a1
                lea     $020000,a0
                moveq   #127,d7

LOOP:           moveq   #7,d6
                movea.l a1,a2
ACHT:           move.b  (a2),d0
                moveq   #7,d5
BITS:           moveq   #0,d1
                lsl.b   #1,d0
                bcc.s   OK
                move.w  #$FFFF,d1
OK:             move.w  d1,(a0)+
                dbra    d5,BITS
                adda.l  #$0100,a2
                dbra    d6,ACHT
                addq.l  #1,a1
                dbra    d7,LOOP
*******************************************
***             MAKE COPY TAB
*******************************************
                lea     $030000,a0
                moveq   #0,d7
                move.l  d7,d6
                move.w  #3999,d0
MAKE:           move.w  #$3169,(a0)+
                move.w  d7,(a0)
                sub.w   d6,(a0)
                subi.w  #152,(a0)+
                move.w  d7,(a0)
                sub.w   d6,(a0)+
                addq.l  #8,d7
                add.w   #160,d6
                cmp.w   #3200,d6
                bne.s   OKI
                clr.w   d6
OKI:            dbra    d0,MAKE
                move.w  #$4E75,(a0)+

*******************************************
***             STARTA DEMO
*******************************************
                lea     SOUND(pc),a1
                moveq   #13,d0
MAKE_SND:       move.b  d0,$FFFF8800.w
                move.b  -(a1),$FFFF8802.w
                dbra    d0,MAKE_SND
                lea     $058000,a0
                move.w  #$2FFF,d0
CLEAR:          move.l  #$FFFF,(a0)+
                move.l  #$FFFFFFFF,(a0)+
                dbra    d0,CLEAR
                lea     $07FFF0,a7
                lea     RASTER(pc),a0
                move.l  a0,$0120
                lea     VBL(pc),a0
                move.l  a0,$70
                move.b  #0,$FFFFFA09.w
                move.b  #1,$FFFFFA07.w
                move.b  #1,$FFFFFA13.w
                move    #$2300,sr
STOP:           bra.s   STOP

*******************************************
***             RASTER
*******************************************
RASTER:         subq.w  #7,$FFFF825C.w
                addq.w  #8,$FFFF8240.w
                clr.b   $FFFFFA0F
                rte
*******************************************
***             VBL
*******************************************
VBL:
                clr.l   $FFFF825C.w     ; INITS
                clr.w   $FFFF8240.w
                move.b  #1,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w

                move.b  #$06,$FFFF8201.w ; WITCH SCREEN
                lea     $068000,a5
                lea     $01FFFD,a4
                lea     SWITCH(pc),a0
                not.b   (a0)
                beq.s   SCREEN_DONE
                move.b  #$05,$FFFF8201.w
                lea     $058000,a5
                subq.w  #1,a4
SCREEN_DONE:    movea.l a5,a0
                movea.l a5,a1

                jsr     $030000
                lea     COUNTB1(pc),a0
                subq.w  #1,(a0)         ; NEW CHAR ??
                bpl.s   SAME
                move.w  #15,(a0)
                lea     SCROLLPEK(pc),a1
                movea.l (a1),a0
                move.b  (a0)+,d0
                bpl.s   CHARS
                lea     TEXT(pc),a0
                move.b  (a0)+,d0
CHARS:          move.l  a0,(a1)
                and.w   #$FF,d0
                lsl.l   #7,d0
                lea     CHAR(pc),a1
                move.l  d0,(a1)
SAME:           lea     CHAR(pc),a1     ; PAINT AT RIGHT SIDE
                lea     SWITCH(pc),a2
                tst.b   (a2)
                beq.s   NO
                addq.l  #2,(a1)
NO:             movea.l (a1),a0
                adda.l  a4,a0
                exg     a5,a1
                adda.w  #152,a1
                moveq   #7,d1
SJU:            move.b  (a0),d2
                lsl.w   #8,d2
                move.b  1(a0),d2
                adda.w  #16,a0
                moveq   #25,d0
MANGA:          move.w  d2,(a1)
                adda.w  #160,a1
                dbra    d0,MANGA
                dbra    d1,SJU
*               CMP.B #$39,$FFFFFC02.W
*               BEQ.L BACK
                rte
**********************************************************
******          DATA
**********************************************************
COUNTB1:        dc.w 0
SCROLLPEK:      dc.l $030002
TEXT:           dc.b "OMEGA PRESENTS THEIR BOOT DE"
                dc.b "MO #1 -EAT THIS LAMER!  MUPPIGT!!"
                dc.b "   "
                dc.b $FF
SWITCH:         dc.b 0
                dc.b $0F,$0F,$00,$0F,$80,$0F,$80,$F8
                dc.b $10,$10,$10,$00,$50,$0A
SOUND:
CHAR:
*********
SLUTBD1:
                ds.b 512-(SLUTBD1-BBLOCKD1)
                endpart

************************************************

                >PART 'BOOT DEMO #2'
*******************************************
*** Boot Block Demo II
*******************************************
BBLOCKD2:       bra.s   BOOTBD2         ;0-1    BRANCH INSTRUCTION
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
                dc.b $00,$00    ;28-29  NUMBER OF HIDEDEN SECTORS

BOOTBD2:        not.w   $04F0.w
                bne.s   BOOTDEMO2
                rts
BOOTDEMO2:

********************************************
**      STARTUP
********************************************
BEGINBD2:       move    #$2700,sr
                lea     $077000,a7
                lea     $FFFF8240.w,a0
                move.l  #$100030,(a0)+
                move.l  #$500070,(a0)+
                move.l  #$600040,(a0)+
                move.l  #$200000,(a0)+

                lea     $070000,a0
                lea     COL(pc),a1
                moveq   #7,d0
                move.b  d0,$FFFF8201.w
P1:             moveq   #7,d1
P2:             move.b  (a1)+,d3
                lsl.w   #4,d3
                move.w  d3,16(a0)
                move.w  d3,(a0)+
                dbra    d1,P2
                adda.l  #16,a0
                dbra    d0,P1

                lea     $060000,a0
                move.w  #511,d0
LOOP1:          lea     DIST(pc),a1
                moveq   #63,d1
LOOP2:          move.b  (a1),(a0)+
                move.b  (a1)+,(a0)+
                dbra    d1,LOOP2
                dbra    d0,LOOP1

                lea     $078000+160,a0
                move.w  #40*199,d0
DRAW:           move.l  #$55553333,(a0)+
                move.l  #$0F0FFFFF,(a0)+
                dbra    d0,DRAW

                lea     $078000+4830,a0 ; OMEGA SIGN
                lea     COL(pc),a1
                moveq   #6,d0
LINE:
                movea.l a1,a2
                moveq   #6,d1
ROW:            tst.b   (a2)+
                bne.s   NEP
                movea.l a0,a3
                moveq   #19,d7
HAHA:           clr.w   (a3)
                clr.w   8(a3)
                adda.w  #160,a3
                dbra    d7,HAHA
NEP:
                adda.l  #16,a0
                dbra    d1,ROW
                addq.l  #8,a1
                adda.w  #3088,a0
                dbra    d0,LINE


                lea     $FFFFFA07.w,a0
                clr.b   2(a0)
                move.b  #1,(a0)
                move.b  #1,12(a0)

                lea     RASTERBD2(pc),a0
                move.l  a0,$0120.w
                lea     VBLBD2(pc),a0
                move.l  a0,$70.w

                move    #$2300,sr
NEVER_STOP:     bra.s   NEVER_STOP
********************************************
**      VBL
********************************************
VBLBD2:
*               CMP.B #$39,$FFFFFC02.W
*               BEQ.L BACK
                lea     $FFFFFA1B.w,a0
                clr.b   (a0)
                move.b  #1,6(a0)        ; $FFFFFA21
                move.b  #8,(a0)

                lea     PEK1(pc),a0
                addq.w  #4,2(a0)
                move.l  (a0)+,d6
                addq.w  #2,2(a0)        ; PEK2
                move.l  (a0)+,d5

                subq.w  #1,(a0)
                move.w  (a0),d3

                lea     $FFFF8250.w,a5
                bsr.s   NEWCOL
                rte
********************************************
**      RASTER
********************************************
RASTERBD2:
                movem.l (a6),a0-a3
                movem.l a0-a3,(a5)
                bsr.s   NEWCOL
                bclr    #0,$FFFFFA0F.w
                rte

*********************************************
**      D6=DIST
**      D5=DIST
*********************************************
NEWCOL:         lea     $070000,a6
                addq.w  #2,d6
                addq.w  #2,d5
                movea.l d6,a4
                move.b  (a4),d7
                movea.l d5,a4
                add.b   (a4),d7
                and.w   #$0E,d7
                adda.w  d7,a6

                addq.w  #1,d3
                and.w   #$07,d3
                move.l  d3,d7
                lsl.w   #5,d7
                adda.l  d7,a6
                rts
*********************************************
**      DATA
*********************************************
COL:
                dc.b 1,2,0,0,0,3,2,1
                dc.b 1,0,3,4,4,0,2,1
                dc.b 0,2,3,4,4,3,0,1
                dc.b 0,2,3,4,4,3,0,1
                dc.b 1,0,3,4,4,0,2,1
                dc.b 1,2,0,4,0,3,2,1
                dc.b 0,0,0,4,0,0,0,1
                dc.b 1,2,3,4,4,3,2,1

DIST:           dc.b 0,0,0,0,0,0,2,2,2,2,4,4,4
                dc.b 6,6,6,8,8,10,12,14,14,16,16,16
                dc.b 18,18,18,20,20,20,20
                dc.b 22,22,22,22,22,22,20,20,20,20,18,18,18
                dc.b 16,16,16,14,14,12,10,8,8,6,6,6,4,4,4,2,2,2,2
PEK1:           dc.l $060000
PEK2:           dc.l $06005A
                dc.b "LIESEN"
SLUTBD2:
                ds.b 512-(SLUTBD2-BBLOCKD2)
                endpart

************************************************

                >PART 'BOOT DEMO #3'

*******************************************
*** Boot Block Demo III
*******************************************
BBLOCKD3:       bra.s   BOOTBD3         ;0-1    BRANCH INSTRUCTION
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
                dc.b $00,$00    ;28-29  NUMBER OF HIDEDEN SECTORS

BOOTBD3:        not.w   $04F0.w
                bne.s   BOOTDEMO3
                rts
BOOTDEMO3:
*******************************
**      VIKTIGT:
**      F™LJANDE VŽRDEN ŽR PERMANENTA
**      A1=$FFFFFC02
**      A2=$FFFFFA11
**      A3 ONLY ACIA
**      A4 ONLY ACIA
**      A0 & A5 & A6 ANVŽNDS I VBL (SPARAS EJ DŽR)
**      VISSA DATA REGISTER ANVŽNDS
********************************

************************************************************
***     BOOT GAME #1
************************************************************
BEGINBD3:       move.b  #0,$0484.w

                lea     $FFFFFC00.w,a1
                lea     $FFFFFA11.w,a2
                lea     $06F000,a7
                move.b  #$07,$FFFF8201.w
                bsr.s   ERASE

WAITACIA:       btst    #1,(a1)
                beq.s   WAITACIA
                move.b  #$14,2(a1)

                lea     ACIAN(pc),a4
                move.l  a4,$0118.w

                lea     VBLBD3(pc),a0
                move.l  a0,$70.w
                move    #$2000,sr
YOUNG:          bra.s   YOUNG
*************************************************************
***     MOVE'EM
*************************************************************
FLYTTA:         tst.w   d0
                beq.s   ROGER
                cmp.b   #2,d0
                beq.s   NEJ1
                rol.w   (a5)
                bcc.s   ROGER
                subq.w  #8,-2(a5)
                bra.s   ROGER
NEJ1:           ror.w   (a5)
                bcc.s   ROGER
                addq.w  #8,-2(a5)
ROGER:          movea.l -4(a5),a0
                move.w  (a5),d0
                move.w  (a0),d1
                and.w   d0,d1
                bne.s   CRASH
                move.w  2(a0),d1
                and.w   d0,d1
                bne.s   CRASH
                rts
*************************************************************
CRASH:          move.w  d6,$FFFF8240.w
*************************************************************
***     ERASE SCREEN
*************************************************************
ERASE:          lea     $078000,a0
                move.w  #3999,d0
RENSA:          clr.l   (a0)
                addq.l  #8,a0
                dbra    d0,RENSA

                lea     $078000,a0
                move.w  #319,d0
S1:             not.l   (a0)+
                addq.l  #4,a0
                dbra    d0,S1

                move.w  #167,d0
S2:             not.l   (a0)
                adda.l  #152,a0
                not.l   (a0)
                addq.l  #8,a0
                dbra    d0,S2
                move.w  #319,d0
S3:             not.l   (a0)+
                addq.l  #4,a0
                dbra    d0,S3

                lea     TAB(pc),a6
                move.l  #$078000+12800+32,(a6)
                move.w  #256,4(a6)
                move.l  #$078000+19200+120,6(a6)
                move.w  #256,10(a6)
                clr.l   12(a6)
                move.l  #$020001,16(a6)
                rts
*************************************************************
***     VBL
*************************************************************
VBLBD3:
                move.l  #$03030522,$FFFF8240.w
                move.l  #$02250707,$FFFF8244.w
                lea     TAB(pc),a6

                move.w  12(a6),d0
                add.w   d0,2(a6)
                move.w  14(a6),d0
                add.w   d0,8(a6)

                lea     TAB+4(pc),a5
                move.w  16(a6),d0
                move.w  #$0225,d6
                bsr     FLYTTA
                lea     TAB+10(pc),a5
                move.w  18(a6),d0
                move.w  #$0522,d6
                bsr     FLYTTA

                movea.l (a6),a0
                move.w  4(a6),d0
                or.w    d0,(a0)
                movea.l 6(a6),a0
                addq.l  #2,a0
                move.w  10(a6),d0
                or.w    d0,(a0)

                move.b  JOY0(pc),d0
                lea     TAB+12(pc),a5
                bsr.s   CONTROL
                move.b  JOY1(pc),d0
                lea     TAB+14(pc),a5
                bsr.s   CONTROL
IRQSTOP:        rte
*************************************************************
***     CONTROL
*************************************************************
CONTROL:        cmp.b   #1,d0
                bne.s   B1
                clr.w   4(a5)
                move.w  #-160,(a5)
B1:             cmp.b   #2,d0
                bne.s   B2
                clr.w   4(a5)
                move.w  #160,(a5)
B2:             cmp.b   #4,d0
                bne.s   B3
                move.w  #1,4(a5)
                clr.w   (a5)
B3:             cmp.b   #8,d0
                bne.s   B4
                move.w  #2,4(a5)
                clr.w   (a5)
B4:             rts
*******************************************
                dc.b "LIESEN OF OMEGA 1989"
*************************************************************
***     JOYSTICK ACIA
*************************************************************
ACIAN:          lea     JOY1(pc),a3
                cmpi.b  #$FE,2(a1)
                beq.s   OTHER
                blo.s   ALL_DONE
                lea     JOY0(pc),a3
OTHER:          lea     JOYSTICK(pc),a4
                move.l  a4,$0118.w
ALL_DONE:       bclr    #6,(a2)
                rte
*************************************************
**              JOYSTICK 0
*************************************************
JOYSTICK:       move.b  2(a1),(a3)
                lea     ACIAN(pc),a4
                move.l  a4,$0118.w
                bclr    #6,(a2)
                rte
SLUTBD3:
                ds.b 512-(SLUTBD3-BBLOCKD3)
*************************************************************
***     DATA UTANF™R PROGRAMMET
*************************************************************
JOY0            equ SLUTBD3
JOY1            equ SLUTBD3+2
TAB             equ SLUTBD3+4
ADDR1           equ TAB
BIT1            equ TAB+4
ADDR2           equ TAB+6
BIT2            equ TAB+10
ADD1            equ TAB+12
ADD2            equ TAB+14
FLAG1           equ TAB+16
FLAG2           equ TAB+18
                endpart

************************************************

                >PART 'BOOT DEMO #4'

************************************************
**      BOOT DEMO
************************************************
*       THIS BOOT DEMO WAS MADE BY MARTIN LIESEN 17TH OF APRIL 1990
*       COPYRIGHTS MARTIN LIESEN 1990     OMEGA RULES!!
*************************************
**      INIT ROUT
*************************************

BBLOCKD4:       bra.s   BOOTBD4         ;0-1    BRANCH INSTRUCTION
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
                dc.b $00,$00    ;28-29  NUMBER OF HIDEDEN SECTORS

BOOTBD4:        not.w   $04F0.w
                bne.s   BOOTDEMO4
                rts
BOOTDEMO4:


bdemo4DEMO:     lea     $040000,a0
                moveq   #-1,d0
bdemo4LL2:      clr.l   (a0)+
                dbra    d0,bdemo4LL2

                lea     $040000+6400-160,a6
                movem.l (a6),d0-d7
                moveq   #$10,d4
                move.w  #-1,d3
bdemo4LL6:      movea.l a6,a0
                suba.w  d2,a0
                add.w   #160,d2
                moveq   #19,d5
bdemo4LL5:      lea     bdemo4OHM(pc),a1
                moveq   #7,d6
bdemo4LL4:      move.w  (a1)+,d0
                rol.w   d4,d0
                moveq   #79,d7
bdemo4LL3:      move.w  d0,(a0)+
                dbra    d7,bdemo4LL3
                move.l  d3,-4(a0)
                move.l  d3,-160(a0)
                dbra    d6,bdemo4LL4
                dbra    d5,bdemo4LL5

                lea     (a6),a0
                lea     25600(a6),a1
                adda.l  #$8000,a6
                move.w  #319,d0
bdemo4LL7:      move.l  d3,-(a0)
                move.l  d3,-(a1)
                dbra    d0,bdemo4LL7
                subq.w  #2,d4
                bne.s   bdemo4LL6

                lea     bdemo4VBL(pc),a0
                move.l  a0,$70.w
                move    #$2300,sr
bdemo4STOP:     bra.s   bdemo4STOP
***************************************
**      VBL ROUT
***************************************
bdemo4VBL:
*               CMP.B   #$39,$FFFFFC02.W
*               BEQ.L   BACK
                move    #$2700,sr

                lea     bdemo4HOPP(pc),a6
                lea     bdemo4HOPPA+6(pc),a3
                tst.l   (a6)
                beq.s   bdemo4STURE
                movea.l (a6),a5
                addq.w  #2,a5
                cmpa.l  a5,a3
                bne.s   bdemo4TOLLE
bdemo4STURE:    lea     bdemo4HOPPA(pc),a5



                dc.w $A000
                movea.l 4(a1),a1
                movea.l 76(a1),a3       ;A3=FONT
                lea     bdemo4VALUES(pc),a0 ;A0=DATA TAB START
                movea.l 6(a0),a2        ;A2=BUFFERT
                addq.l  #2,6(a0)
                cmpi.w  #38,8(a0)
                blo.s   bdemo4OK3
                clr.w   8(a0)
bdemo4OK3:
                subq.w  #1,(a0)
                bne.s   bdemo4OK1
                addq.w  #8,(a0)
                addq.l  #1,2(a0)
bdemo4OK1:      movea.l 2(a0),a1
                move.b  (a1),d2
                bne.s   bdemo4OK4
                lea     12(a0),a1
                move.b  (a1)+,d2
                move.l  a1,2(a0)
bdemo4OK4:      lea     0(a3,d2.w),a4   ;A4=CHAR OUT

                moveq   #6,d7
                moveq   #0,d5
                move.w  #$0770,d4
bdemo4SEGMENT:
                move.b  (a4),d0
                lea     $0100(a4),a4
                move.w  (a0),d1
                add.w   #$0101,d5
                sub.w   #$10,d4
                move.w  d5,d2
                ror.b   d1,d0
                and.w   #$01,d0
                beq.s   bdemo4OK2
                move.w  d4,d2
bdemo4OK2:
                moveq   #32,d6
bdemo4LL1:      move.w  d2,(a2)
                move.w  d2,38(a2)
                lea     76(a2),a2
                dbra    d6,bdemo4LL1
                dbra    d7,bdemo4SEGMENT




bdemo4TOLLE:    move.l  a5,(a6)

                lea     $FFFF8240.w,a0  ; A0=BACKGROUND COLOR
                move.b  #$01,$20(a0)
                movea.l a0,a1
                clr.l   (a1)+
                move.w  #-1,(a1)+
                move.w  8(a0),(a1)+
                addq.w  #1,(a1)+

                lea     bdemo4SCREEN(pc),a1
                addi.w  #$80,(a1)
                cmpi.w  #$0800,(a1)
                bne.s   bdemo4OK9
                move.w  #$0400,(a1)
bdemo4OK9:      move.b  (a1)+,-$3F(a0)
                move.b  (a1),-$3D(a0)


bdemo4GOON:     move.b  -$37(a0),d0
                beq.s   bdemo4GOON
                not.w   d0
                lsr.w   d0,d1
                moveq   #18,d0
bdemo4WAIT:     dbra    d0,bdemo4WAIT

                jmp     (a5)
bdemo4HOPPA:    exg     d0,d1
                exg     d0,d1
                exg     d0,d1

                movea.l bdemo4PEKARE(pc),a6
                move.w  #230,d7
bdemo4NEXTLINE: adda.w  #76,a6          ;3
                movea.l a6,a1           ;1
                addi.w  #$01,$FFFF8246.w
                moveq   #18,d0          ;1
bdemo4LOOP:     move.w  (a1)+,(a0)      ;3
                dbra    d0,bdemo4LOOP   ;3/4
                dbra    d7,bdemo4NEXTLINE ;3/4

                rte
**********************************
bdemo4VALUES:
bdemo4COUNT:    dc.w 1
bdemo4SCROLL:   dc.l 3
bdemo4PEKARE:   dc.l bdemo4BUFFERT
bdemo4SCREEN:   dc.w $0780
bdemo4BUFFERT   equ $030000
bdemo4SCROLLTEXT:dc.b "    HELLO FOLKS!!   THIS IS LIESEN OF OMEGA'S"
                dc.b " BOOT DEMO nr:4 (C)"
bdemo4HOPP:     dc.w 0
bdemo4OHM:      dc.w 0
                dc.w %1111111000
                dc.w %111100111100
                dc.w %1110000001110
                dc.w %1110000001110
                dc.w %111000011100
                dc.w %11100111000
                dc.w %11111100111111


                endpart

************************************************

                >PART 'BOOT BLOCK #1'

; ***********************************************
;             BOOT BLOCK !!
; ***********************************************
BLOCK1:         bra.s   BOOT1           ;0-1    BRANCH INSTRUCTION
                dc.b "OMEGA "   ;2-7    LOADER
                dc.b 1,1,0      ;8-10   SERIAL NUMBER (not exectuable)
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

BOOT1:          rts
                dc.b "NO need for Panic!  This bootblock is not executable and it "
                dc.b "sure as hell isn't a virus!... Have a nice DAY!          "


SLUT1:
                ds.b BLOCK1+512-SLUT1 ; BETTER BE SURE


                endpart

************************************************

                >PART 'ANTIVIRUS  #2'

BLOCK2:         bra.s   START           ;0-1    BRANCH INSTRUCTION
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
                dc.b $00,$00    ;28-29  NUMBER OF HIDEDEN SECTORS

BOOT2:
BOOTINFO:
KOLLA:          dc.b "OMEGA's pANTI-VIRUS V1.5q
"
                dc.b "When Flashing, HELP/SPACE
"
                dc.b "leave unchanged.
"
                dc.b "=>SOFIA"
                dc.b 0
                even
************************************
**      INIT BOOT
************************************
START:          movem.l d0-a6,-(a7)
                move.l  a7,$0426.w
                lea     $07FFFE,a7
                bsr.s   CHECKMEM
                pea     BOOTINFO(pc)
                move.w  #9,-(a7)
                trap    #1

                cmpi.b  #9,$0424.w
                bne.s   NOT2_5MB
                cmpi.w  #'25',$0300.w
                beq.s   NOT2_5MB

                move.l  #$280000,$042E.w
                move.l  #$278000,$0436.w
                move.w  #'25',$0300.w
                movea.l 4.w,a0
                jmp     (a0)            ; reset computer
NOT2_5MB:
                move.w  #$0666,$FFFF8240.w

                pea     640             ; RESERVE MEMORY
                move.w  #$48,-(a7)
                trap    #1

                lea     BLOCK2(pc),a0
                movea.l d0,a1
NOWHERE:        lea     GETHERE-BLOCK2(a1),a2
                moveq   #127,d0
COPYALL:        move.l  (a0)+,(a1)+
                dbra    d0,COPYALL
                jmp     (a2)

**********************************************************
**      ENDUP HERE AFTER COPYING INTO RESERVED MEM
**********************************************************
GETHERE:        lea     HOPPAR(pc),a0
                move.l  $0472.w,2(a0)   ; CORRECT JUMP ADDRESS
                lea     OURROUT(pc),a1
                move.l  a1,$0472.w

                movea.l $0426.w,a7
                movem.l (a7)+,d0-a6
                rts

*************************************************
**      CHECK FOR VIRUS IN MEMORY
*************************************************
CHECKMEM:       lea     CHECKADDR(pc),a0
LOOPA:          move.w  (a0)+,d0
                ext.l   d0
                bmi.s   DONE
                movea.l d0,a1
                move.l  (a1),d0
                beq.s   LOOPA
                and.l   #$800000,d0
                bne.s   LOOPA

VIRUS:          lea     $FFFF8240.w,a6  ; VIRUS FOUND
                move.w  (a0),d0
                move.w  #$0270,(a6)
WAIT:           bsr.s   GETKEY
                move.w  d0,(a6)
DONE:           rts

************************************************
**      GET KEY
**      A6=$FFFF8240
**      OUT D0 KEY
************************************************
GETKEY:         moveq   #0,d0
                cmpi.b  #$62,$FFFFFC02.w
                beq.s   OJOJ
                pea     $010002
                trap    #13
                addq.l  #4,a7
                eori.w  #$0747,(a6)
                tst.w   d0
                beq.s   GETKEY
                pea     $020002
                trap    #13
                addq.l  #4,a7
OJOJ:           rts

**********************************************************
**      IRQ ROUT
**********************************************************
OURROUT:        move    sr,-(a7)
                move    #$2300,sr
                movem.l d0-a6,-(a7)
                movea.l $047A.w,a6

BACK1:          jsr     (a6)
                lea     $FFFF8240.w,a6
                move.w  (a6),d7
                movea.l $04C6.w,a5
                tst.w   d0
                bne.s   NOTEXEC
                cmpi.w  #"OM",KOLLA-BLOCK2(a5)
                beq.s   LEAVEDIS


                move.w  #$0F,(a6)
                bra.s   VIRUSBLOCK
NOTEXEC:        move.w  #$033F,(a6)
VIRUSBLOCK:     lea     BLOCK2+11(pc),a4 ; FIX A NEW BOOTBLOCK IN MEM
                lea     11(a5),a5
                moveq   #18,d0
HAN_SOLO:       move.b  (a5)+,(a4)+
                dbra    d0,HAN_SOLO
                lea     -30(a4),a4
                clr.w   8(a4)
                move.w  #255,d0
                moveq   #0,d1
CHECKSUM:       add.w   (a4)+,d1
                dbra    d0,CHECKSUM
                move.w  #$1234,d0
                sub.w   d1,d0
                move.w  d0,-504(a4)

                bsr     GETKEY

                cmp.b   #' ',d0
                beq.s   NOTSAVE

                move.w  #$70,(a6)
                pea     $01             ; TRACK 0 SECTOR 1
                pea     $010000
                move.w  #0,-(a7)        ; DRIVE A
                clr.l   -(a7)           ; POINTLESS
                pea     BLOCK2(pc)
                move.w  #9,-(a7)
                trap    #14
                lea     20(a7),a7

NOTSAVE:        move.w  d7,(a6)

LEAVEDIS:       movem.l (a7)+,d0-a6
                move    (a7)+,sr

HOPPAR:         jmp     $FFFFFF

*****************************
** DATA
*****************************
CHECKADDR:      dc.w $84,$B4,$B8,$0400,$0404,$0408,$0472,$0476,$047A
                dc.w $042A,-1
                dc.b "CocaCola"
SLUT2:

AV_SIZE         equ SLUT2-BLOCK2
                ds.b 512-AV_SIZE ; BETTER BE SURE

                if AV_SIZE>512
                fail
                endc

                endpart

************************************************

                >PART 'BOOT COLOR 1.60'

BC_BLOCK:       bra.s   BC_BOOT         ;0-1    BRANCH INSTRUCTION
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

BC_BOOT:
                movea.l $04F2.w,a0
                cmpi.w  #$0106,2(a0)
                bne.s   BC_WRONGTOS

                pea     BC_BOOTTEXT(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.w  #8,a7

                cmp.b   #"2",d0
                beq.s   BC_WRONGTOS
                cmp.b   #"1",d0
                bne.s   BC_BOOTNOT
                lea     BC_HOPPA+2(pc),a0
                move.l  #$E00572,(a0)

BC_BOOTNOT:     pea     $0200           ; reserve memory
                move.w  #$48,-(a7)
                trap    #1
                addq.l  #6,a7
                tst.l   d0
                bmi.s   BC_WRONGTOS

                movea.l d0,a0           ; copy vbl to reserved memory
                movea.l a0,a6
                lea     BC_VBL(pc),a1
                moveq   #$7F,d0
BC_LOOP:        move.l  (a1)+,(a0)+
                dbra    d0,BC_LOOP

                move.l  a6,$70.w        ; start VBL

                move.w  #$00,-(a7)      ; set low resolution
                pea     $FFFFFFFF
                pea     $FFFFFFFF
                move.w  #$05,-(a7)
                trap    #$0E
                lea     $0C(a7),a7
BC_HOPPA:       jmp     $E0057A

BC_WRONGTOS:    not.w   $FFFF8240.w
                rts

*******************************
********* V B L
*******************************
BC_VBL:         addq.l  #1,$0466.w
                subq.w  #1,$0452.w
                bmi     BC_NO_VBL
                movem.l d0-a6,-(a7)
                addq.l  #1,$0462
                move.b  $044C.w,$FFFF8260.w
                jsr     $E0A938
                tst.l   $045A.w
                beq.s   BC_L702E0
                movem.l $045A,a0
                movem.l (a0),d0-d7
                movem.l d0-d7,$FFFF8240.w
                clr.l   $045A.w
BC_L702E0:      tst.l   $045E.w
                beq.s   BC_L702FE
                move.l  $045E.w,$044E.w
                move.b  $0451.w,$FFFF820D.w
                move.b  $0450.w,$FFFF8203.w
                move.b  $044F.w,$FFFF8201.w
BC_L702FE:      jsr     $E01528
                move.w  $0454.w,d7
                beq.s   BC_L70328
                subq.l  #1,d7
                movea.l $0456.w,a0
BC_L70310:      movea.l (a0)+,a1
                cmpa.l  #$00,a1
                beq.s   BC_L70324
                movem.l d7-a0,-(a7)
                jsr     (a1)
                movem.l (a7)+,d7-a0
BC_L70324:      dbra    d7,BC_L70310
BC_L70328:      tst.w   $04EE.w
                bne.s   BC_L70350
                move.w  #$FFFF,$04EE
                move.b  #$00,$FFFF820A.w
                eori.w  #3,$FFFF8260.w
                move.w  $4000,d0
BC_L70342:      dbra    d0,BC_L70342
                move.b  #$02,$FFFF820A.w
                eori.w  #3,$FFFF8260.w
BC_L70350:      movem.l (a7)+,d0-a6
BC_NO_VBL:      addq.w  #1,$0452.w
                rte

BC_BOOTTEXT:
                dc.b "Boot on TV althought Mono Monitor is connected",13,10
                dc.b "(C)Martin Liesen 1991",13,10
                dc.b "STE Tos 1.6 in ROM Only",13,10,10
                dc.b "1 Boot Other Disk",13,10
                dc.b "2 Mono This Disk",13,10
                dc.b "Other Color This Disk",0

BC_SLUTBLOCK:
BC_BLOCKSIZE    equ BC_SLUTBLOCK-BC_BLOCK
                ds.b 512-BC_BLOCKSIZE ; BETTER BE SURE

                if BC_BLOCKSIZE>512
                fail
                endc

                endpart

                >PART 'BOOT COLOR 2.50'

BC_BLOCK2_05:   bra.s   BC_BOOT2        ;0-1    BRANCH INSTRUCTION
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
BC_BOOTTEXT2:   dc.b "OMEGA's ",27,"pBOOT COLOR",27,"q TOS 2.5 in ROM.",13,10,10
                dc.b "1 Boot Other Disk",13,10
                dc.b "2 Normal boot",13,10
                dc.b "Other Color This Disk",0
                even

BC_BOOT2:
                cmpi.b  #9,$0424.w
                bne.s   BC_NOT2_5MB
                cmpi.w  #'25',$0300.w
                beq.s   BC_NOT2_5MB

                move.l  #$280000,$042E.w
                move.l  #$278000,$0436.w
                move.w  #'25',$0300.w
                movea.l 4.w,a0
                jmp     (a0)            ; reset computer
BC_NOT2_5MB:


                movea.l $04F2.w,a0
                cmpi.w  #$0205,2(a0)
                bne.s   BC_WRONGTOS2

                pea     BC_BOOTTEXT2(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.w  #8,a7

                cmp.b   #"2",d0
                beq.s   BC_WRONGTOS2
                cmp.b   #"1",d0
                bne.s   BC_BOOTNOT2
                lea     BC_HOPPA2+2(pc),a0
                move.l  #$E006AA,(a0)

BC_BOOTNOT2:    pea     $0200           ; reserve memory
                move.w  #$48,-(a7)
                trap    #1
                addq.l  #6,a7
                tst.l   d0
                bmi.s   BC_WRONGTOS2

                movea.l d0,a0           ; copy vbl to reserved memory
                movea.l a0,a6
                lea     BC_VBL2(pc),a1
                moveq   #$7F,d0
BC_LOOP2:       move.l  (a1)+,(a0)+
                dbra    d0,BC_LOOP2

                move.l  a6,$70.w        ; start VBL

                move.w  #$00,-(a7)      ; set low resolution
                pea     $FFFFFFFF
                pea     $FFFFFFFF
                move.w  #$05,-(a7)
                trap    #$0E
                lea     $0C(a7),a7
BC_HOPPA2:      jmp     $E006B2

BC_WRONGTOS2:   not.w   $FFFF8240.w
                rts

*******************************
********* V B L
*******************************
BC_VBL2:
VBL2_05:        addq.l  #1,$0466
                subq.w  #1,$0452
                bpl.s   URK01
                jmp     $E009E4
URK01:          movem.l d0-a6,-(a7)
                addq.l  #1,$0462.w
                move.w  $0454.w,d7
                bne.s   URK02
                jmp     $E009D6
URK02:          subq.l  #1,d7
                movea.l $0456.w,a0
NEXT_VBL:       movea.l (a0)+,a1
                cmpa.w  #0,a1
                beq.s   NO_VECT
                movem.l d7-a0,-(a7)
                jsr     (a1)
                movem.l (a7)+,d7-a0
NO_VECT:        dbra    d7,NEXT_VBL
                move    sr,-(a7)
                ori     #$0700,sr
LE00928:        move.b  $FFFF8901.w,d0
                move.b  $FFFFFA01.w,d1
                btst    #$07,d1
                sne     d1
                move.b  $FFFFFA01.w,d2
                btst    #$07,d2
                sne     d2
                cmp.b   d1,d2
                bne.s   LE00928
                cmp.b   $FFFF8901.w,d0
                bne.s   LE00928
                move    (a7)+,sr
                btst    #$00,d0
                beq.s   LE00954
                not.b   d1
LE00954:
LE00992:        jmp     $E00992
                rept 8
                dc.b " Coca Cola"
                endr
                dc.b "!!!!!!!!"
BC_SLUTBLOCK2_05:
BC_BLOCKSIZE2_05 equ BC_SLUTBLOCK2_05-BC_BLOCK2_05
                ds.b 512-BC_BLOCKSIZE2_05 ; BETTER BE SURE

                if BC_BLOCKSIZE2_05>512
                fail
                endc

                endpart

                PART 'BOOT COLOR 2.60'

BC_BLOCK2_06:   bra.s   BC_BOOT4        ;0-1    BRANCH INSTRUCTION
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
BC_BOOTTEXT3:   dc.b "OMEGA's ",27,"pBOOT COLOR",27,"q TOS 2.6 in ROM.",13,10,10
                dc.b "1 Boot Other Disk",13,10
                dc.b "2 Normal boot",13,10
                dc.b "Other Color This Disk",0
                even

BC_BOOT4:
                cmpi.b  #9,$0424.w
                bne.s   BC_NOT2_5MB2
                cmpi.w  #'25',$0300.w
                beq.s   BC_NOT2_5MB2

                move.l  #$280000,$042E.w
                move.l  #$278000,$0436.w
                move.w  #'25',$0300.w
                movea.l 4.w,a0
                jmp     (a0)            ; reset computer
BC_NOT2_5MB2:


                movea.l $04F2.w,a0
                cmpi.w  #$0206,2(a0)
                bne.s   BC_WRONGTOS3

                pea     BC_BOOTTEXT3(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.w  #8,a7

                cmp.b   #"2",d0
                beq.s   BC_WRONGTOS3
                cmp.b   #"1",d0
                bne.s   BC_BOOTNOT3
                lea     BC_HOPPA3+2(pc),a0
                move.l  #$E00894,(a0)

BC_BOOTNOT3:    pea     $0200           ; reserve memory
                move.w  #$48,-(a7)
                trap    #1
                addq.l  #6,a7
                tst.l   d0
                bmi.s   BC_WRONGTOS3

                movea.l d0,a0           ; copy vbl to reserved memory
                movea.l a0,a6
                lea     BC_VBL3(pc),a1
                moveq   #$7F,d0
BC_LOOP3:       move.l  (a1)+,(a0)+
                dbra    d0,BC_LOOP3

                move.l  a6,$70.w        ; start VBL

                move.w  #$00,-(a7)      ; set low resolution
                pea     $FFFFFFFF
                pea     $FFFFFFFF
                move.w  #$05,-(a7)
                trap    #$0E
                lea     $0C(a7),a7
BC_HOPPA3:      jmp     $E0089C

BC_WRONGTOS3:   not.w   $FFFF8240.w
                rts

*******************************
********* V B L
*******************************
BC_VBL3:

VBL260:         addq.l  #1,$0466.w
                subq.w  #1,$0452.w
                bmi     NOVBL
                movem.l d0-a6,-(a7)
                addq.l  #1,$0462.w
                move.w  $0454.w,d7
                beq     NO_SUB_VBLS
                subq.l  #1,d7
                movea.l $0456.w,a0
NEXT_VECT:      movea.l (a0)+,a1
                cmpa.w  #0,a1
                beq.s   NO_VECT2
                movem.l d7-a0,-(a7)
                jsr     (a1)
                movem.l (a7)+,d7-a0
NO_VECT2:       dbra    d7,NEXT_VECT
                move.b  $FFFFFA01.w,d1
                tst.b   $0A02
                beq.s   LE00C84
                move    sr,-(a7)
                ori     #$0700,sr       ; No IRQ's
LE00C58:        move.b  $FFFF8901.w,d0
                move.b  $FFFFFA01.w,d1
                btst    #7,d1
                sne     d1
                move.b  $FFFFFA01.w,d2
                btst    #7,d2
                sne     d2
                cmp.b   d1,d2
                bne.s   LE00C58
                cmp.b   $FFFF8901.w,d0
                bne.s   LE00C58
                move    (a7)+,sr
                btst    #0,d0
                beq.s   LE00C84
                not.b   d1

LE00C84:
*                move.b  $FFFF8260.w,D0  ; resolution
*                and.b   #3,D0
*                cmp.b   #2,D0
*                bge.s   HighRez
*                btst    #7,D1
*                bne.s   NoWorry
*                jsr     $e01404         ; SomeThing wierd!
*                move.b  #2,D0
*                bra.s   ReadyForChg
*HighRez:        btst    #7,D1
*                beq.s   NoWorry
*                move.b  $0000044A.w,D0  ; DefShiftMode
*                cmp.b   #2,D0
*                blt.s   ReadyForChg
*                clr.b   D0
*ReadyForChg:    move.b  D0,$0000044C.w
*                move.b  D0,$FFFF8260.w
*                movea.l $0000046E.w,A0  ; Get Monitor Change
*                jsr     (A0)            ; Kommer tebax!!! No RESET!
NOWORRY:        jsr     $E064B4
                tst.l   $045A.w         ; PAL for NEXT VBL pek
                beq.s   NONEWPAL
                movea.l $045A.w,a0
                lea     $FFFF8240.w,a1
                move.w  #7,d1
.COPYPAL:       move.l  (a0)+,(a1)+
                dbra    d1,.COPYPAL
                clr.l   $045A.w
NONEWPAL:       tst.l   $045E.w         ; SCREEN ADDRESS for next VBL
                beq.s   NONEWSCREEN
                move.l  $045E.w,$044E.w
                move.b  $0450.w,$FFFF8203.w
                move.b  $044F.w,$FFFF8201.w
                move.b  $0451.w,$FFFF820D.w
NONEWSCREEN:    jsr     $E03D1C
NO_SUB_VBLS:    tst.w   $04EE.w         ; ALT HELP counter
                bne.s   NOHARDCOPY
                jsr     $E0130C
NOHARDCOPY:     movem.l (a7)+,d0-a6
NOVBL:          addq.w  #1,$0452        ; Inc MAKE-NO-VBL flag (sub earlier)
                rte

BC_SLUTBLOCK2_06:
BC_BLOCKSIZE2_06 equ BC_SLUTBLOCK2_06-BC_BLOCK2_06
                ds.b 512-BC_BLOCKSIZE2_06 ; BETTER BE SURE

                if BC_BLOCKSIZE2_06>512
                fail
                endc

                endpart

************************************************

                >PART 'PC BOOT 720Kb'

PCBOOT:         dc.w $EB3E,$9050,$4346,$6F72,$6D61,$7400,$0202
                dc.w $0100,$0270,$A0,$05F9,$0300,$0900,$0200
                dcb.w $05
                dc.w $2912,$3DEE,$0A53,$4242,$5331,$3130,$2020
                dc.w $2020,$4641,$5431,$3220,$2020,$90,$FAB8
                dc.w $3000,$8ED0,$BCFC,$FB,$0E1F,$BB07,$BE
                dc.w $767C,$908A,$0446,$3C00,$7408,$B40E,$56CD
                dc.w $105E,$EBF1,$B401,$CD16,$7406,$B400,$CD16
                dc.w $EBF4,$B400,$CD16,$33D2,$CD19,$0D0A
                dc.b "This disk can't boot: it"
                dc.b " was",$0D,$0A,"formatted without "
                dc.b "the /S (system) option.",$0D
                dc.b $0A,$0A,"To make it bootable, u"
                dc.b "se the DOS utility SYS x"
                dc.b ":",$0D,$0A,$0A,"Change disks & press"
                dc.b " a key.",$0D,$0A,$0A
                dcb.b $7D
                dcb.b $6E
                dc.w $55AA

                endpart

************************************************

                >PART 'BSS DATA'
                bss
SAVECOL:        ds.w 16
MENUAREA:       ds.b 5*1024
AREA1:          ds.b 512
AREA2:          ds.b 512
                endpart
                end
