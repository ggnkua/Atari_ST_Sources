                opt P+
                                                                                                                                                                                                                                                                
STARTEN:        PART 'SetUp'
; ***********************************************
;             START
; ***********************************************
                movea.l a7,a5           ; release memory
                lea     SAVEA7(pc),a0
                move.l  a7,(a0)
                lea     STACK(pc),a7
                movea.l 4(a5),a5

                lea     MEGASLUT(pc),a0
                lea     STARTEN(pc),a1
                suba.l  a1,a0
                lea     1024(a0),a0
                move.l  a0,-(a7)
                move.l  a5,-(a7)
                move.w  #0,-(a7)
                move.w  #$004A,-(a7)
                trap    #1
                lea     12(a7),a7


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
                >PART 'Init'
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
                lea     INFOFILE(pc),a0
                move.l  a0,6(a6)
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
                cmp.w   #-1,d1
                bne.s   NOFEL
                lea     MENUFEL(pc),a0
                bsr     PRINTINP
                rts
NOFEL:

                endpart

                lea     CHOOSENMENU(pc),a0
                subq.w  #1,d0
                move.w  d0,(a0)
                lea     LOADMENU(pc),a6
FINDEND:        bsr     GETCHAR
                cmp.b   #'E',d0
                beq.s   G™TT
                bsr     NEXTLINE
                bra.s   FINDEND
G™TT:           bsr     NEXTLINE

                move.w  CHOOSENMENU(pc),d7
SEARCHA:        tst.w   d7
                beq.s   SCAN_FUNC
SEARCH:         bsr     GETCHAR
                cmp.b   #'#',d0
                beq.s   FOUNDONE_BG
                bsr     NEXTLINE
                bra.s   SEARCH
FOUNDONE_BG:    bsr     NEXTLINE
                subq.w  #1,d7
                bra.s   SEARCHA


SCAN_FUNC:      bsr     GETCHAR
                move.w  d0,d6
                bsr     NEXTLINE

                >PART 'P  Path Change'
                cmp.b   #'P',d6
                bne.s   NOTPATH
                lea     WORK(pc),a1
                bsr     COPYLINE
                bsr     NEXTLINE
                pea     WORK(pc)
                move.w  #$003B,-(a7)
                trap    #1
                addq.l  #6,a7
                bra.s   ANY_ERROR
NOTPATH:        endpart

                >PART 'R  Run Program'
                cmp.b   #'R',d6
                bne.s   NOTRUN
                lea     WORK(pc),a1
                bsr     COPYLINE
                bsr.s   NEXTLINE
                lea     WORK(pc),a2
LOOPMORE:       cmpi.b  #32,(a2)
                beq.s   FOUNDSPACE
                addq.l  #1,a2
                tst.b   (a2)
                beq.s   NOT_SPACE
                bra.s   LOOPMORE
FOUNDSPACE:     move.b  #0,(a2)
                addq.l  #1,a2
NOT_SPACE:      pea     NULL(pc)
                move.l  a2,-(a7)
                pea     WORK(pc)
                move.w  #0,-(a7)
                move.w  #$004B,-(a7)
                trap    #1
                lea     16(a7),a7
                bra.s   ANY_ERROR
NOTRUN:         endpart

                >PART 'D  Exit to Desktop'
                cmp.b   #'D',d6         ; Exit to Desktop
                bne.s   NOT_DESKTOP
                rts
NOT_DESKTOP:    endpart

                >PART '#  No more commands, ->Menu'
                cmp.b   #'#',d6         ; no more commands to this button
                bne.s   NOT_SLUT
                bra     MAINLOOP
NOT_SLUT:       endpart


GETNEXT:        bra.s   SCAN_FUNC


ANY_ERROR:      tst.w   d0
                bpl.s   GETNEXT
                lea     ERROR(pc),a0
                bsr     PRINTINP
                rts



GETCHAR:        >PART 'Plocka bokstav (a0) som STOR'
                move.b  (a6),d0
                cmp.b   #"a",d0
                blt.s   NOHARM
                cmp.b   #"z",d0
                bgt.s   NOHARM
                sub.b   #'a'-'A',d0
NOHARM:         and.l   #$000000FF,d0
                rts
                endpart
NEXTLINE:       >PART 'Move A6 to next Line'
                move.b  (a6)+,d0
                cmp.w   #13,d0
                blo.s   FOUNDNEWLINE
                cmp.b   #-1,d0
                bne.s   NEXTLINE
FOUNDNEWLINE:   cmpi.b  #-1,(a6)
                beq.s   NOTNORMAL
                cmpi.b  #13,(a6)
                bhi.s   NORMAL
NOTNORMAL:      addq.l  #1,a6
                bra.s   FOUNDNEWLINE
NORMAL:
                rts
                endpart
COPYLINE:       >PART 'Copy A6 (till endmark) till A1'
                movem.l a0-a6,-(a7)
COPYMORE:       move.b  (a6)+,d0
                cmp.b   #-1,d0
                beq.s   SLUTANU
                cmp.b   #14,d0
                blo.s   SLUTANU

                move.b  d0,(a1)+
                bra.s   COPYMORE

SLUTANU:        move.b  #0,(a1)+
                movem.l (a7)+,a0-a6
                rts
                endpart



INFOFILE:       dc.b "\MENU.INF",0

CAN_TFIND:      dc.b 27,"E","Can't Find MENU.INF....",0
MENUFEL:        dc.b 27,"E","Error in MenuSystem....",0
ERROR:          dc.b 27,"E","Error, check your disc/info file..",0
NULL:           dc.b 0
                even

* Doc ™ver Info filen
* f”rst kommer "menusystem" data som slutas med "e",0
* sedan kommer f”r varje knapp man har anv„nt f”ljande data

* f”r VARJ knapp kan man ha ett antal kommandon... sista raden „r en rad som
* har tecknet "#" p† f”rsta x posen...
* Alla kommandon kan f”ljas av "remark" text typ... "# slut p† knapp 1"

* man kan anv„nda f”ljande kommandon

* #   = denna knapp „r klar

* d   = goto desktop

* p   = change path....
* path

* r   = run program
* filename commandline



                PART 'BSS Data'
                bss
CHOOSENMENU:    ds.w 1
SAVEA7:         ds.l 1
OLDREZ:         ds.w 1
DISKADDR:       ds.l 1
MENUADDR:       ds.l 1
SAVECOL:        ds.w 15
WORK:           ds.b 256
MENUAREA:       ds.b 4*1024
STACK:
LOADMENU:       ds.b 2*1024

MEGASLUT:
                endpart
                end
