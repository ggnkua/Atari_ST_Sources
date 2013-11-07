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
                >PART 'SUPER'
*************************************************
**      SUPER START HERE
*************************************************
STARTSUPER:     move    #$2300,sr
                movem.l $FFFF8240.w,d0-d7
                lea     SAVECOL(pc),a0
                movem.l d0-d7,(a0)
                move.l  #$0000FFFF,$FFFF8240.w
                move.l  #$FFFFFFFF,$FFFF8244.w
                movea.l $00000098.w,a0
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

EXIT:           rts
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
TEXTEN:         dc.b "u00",0
                dc.b "s01",0
                dc.b "q99",0
                dc.b "d+025",0
                dc.b ";cOMEGA COMMANDS MENU SYSTEM",0
                dc.b ";cA Synchron Assembly Product",0
                dc.b ";z",0
                dc.b ";z",0
                dc.b ">AcLET'S GET BACK #1",0
                dc.b ">BcGET BACK #2",0
                dc.b "e",0

                endpart

                >PART 'BSS DATA'
                data
SAVECOL:        ds.w 15
MENUAREA:       ds.b 5*1024
                endpart
                end
