                opt P+

                >PART 'SetUp'
; ***********************************************
;             START
; ***********************************************
                movea.l 4(a7),a0
                lea     BASEPAGE(pc),a1
                move.l  a0,(a1)

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
                >PART 'Super'
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
                bsr.s   PRINTINP
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

PRINTINP:       >PART 'Print Wait For Key'
                move.l  a0,-(a7)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.l  #8,a7
                rts
                endpart
                PART 'Init'
BEGINUS:        moveq   #2,d0
                trap    #6
                lea     DISKADDR(pc),a1
                move.l  a0,(a1)
                moveq   #7,d0
                trap    #6
                lea     MENUADDR(pc),a1
                move.l  a0,(a1)


                movea.l DISKADDR(pc),a6
                move.w  #0,2(a6)

                movea.l BASEPAGE(pc),a1
                lea     128(a1),a1
                move.b  (a1)+,d0
                ext.w   d0
                clr.b   0(a1,d0.w)

                move.l  a1,6(a6)
                lea     LOADMENU(pc),a0
                move.l  a0,10(a6)
                move.l  #-1,14(a6)
                move.l  #2*1024,18(a6)
                move.w  #0,24(a6)
                move.w  #0,42(a6)
                jsr     (a6)
                tst.w   22(a6)
                beq.s   NOERROR

                lea     CAN_TFIND(pc),a0
                bsr.s   PRINTINP
                rts
NOERROR:
                endpart
                >PART 'Main Loop'
MAINLOOP:
                movea.l MENUADDR(pc),a0
                lea     LOADMENU(pc),a1
                move.l  a1,2(a0)
                move.w  #0,6(a0)
                lea     MENUAREA(pc),a1
                move.l  a1,16(a0)
                move.w  #0,20(a0)
                jsr     (a0)


                rts
                endpart


CAN_TFIND:      dc.b 27,"E","Can't Find the file....",0
                even


                PART 'BSS Data'
                bss
BASEPAGE:       ds.l 1
OLDREZ:         ds.w 1
DISKADDR:       ds.l 1
MENUADDR:       ds.l 1
SAVECOL:        ds.w 15
MENUAREA:       ds.b 4*1024
LOADMENU:       ds.b 5*1024
                endpart
                end
