                output 'OSELECT.PRG'

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
                move.l  #$FFFF0000,$FFFF8240.w
                move.l  #$00000000,$FFFF8244.w
                movea.l $00000098.w,a0
                cmpi.l  #'ILAK',2(a0)
                bne.s   NIXNIXI
                cmpi.w  #$0105,6(a0)
                blo.s   NIXNIXI
                rts

NIXNIXI:        pea     OCNOTFOUND(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.l  #8,a7
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

                >PART 'GET ALL FILES'

                move.w  #$002F,-(a7)    ; save old dta
                trap    #1
                addq.l  #2,a7
                move.l  a7,OLDDTA
                pea     DTA(pc)         ; set new dta
                move.w  #$001A,-(a7)
                trap    #1
                addq.l  #6,a7


                lea     AUTO(pc),a6     ;  make auto
                lea     SLUTAUTO(pc),a3
                lea     AUTOFIL(pc),a2
                moveq   #"G",d6
                moveq   #"A",d7
                bsr.s   SEARCH

                lea     ACCE(pc),a6     ;  make accessories
                lea     SLUTACCE(pc),a3
                lea     ACCEFIL(pc),a2
                moveq   #"C",d6
                moveq   #"a",d7
                bsr.s   SEARCH


                move.l  OLDDTA(pc),-(a7) ; restore old DTA
                move.w  #$001A,-(a7)
                trap    #1
                addq.l  #6,a7

                endpart

                >PART 'MAIN LOOP'
MAINLOOP:
                movea.l MENUADDR(pc),a0
                lea     TEXT(pc),a1
                move.l  a1,2(a0)
                move.w  #0,6(a0)
                lea     MENUAREA(pc),a1
                move.l  a1,16(a0)
                move.w  #0,20(a0)
                jsr     (a0)

EXIT:           rts
                endpart

SEARCH:         >PART 'SEARCH AND PUT ON MENU'
* a2=addr. search string
* a3=addr. slut meny
* a6=addr. start meny
* d6=inte aktiv bokstav
* d7=start ascII f”r knapp
                move.w  #0,-(a7)        ; Search First
                move.l  a2,-(a7)
                move.w  #$004E,-(a7)
                trap    #1
                addq.l  #8,a7
                tst.w   d0
                bne.s   NOMORE

GOON:           cmpa.l  a3,a6
                beq.s   FINISHED

                lea     DTA+30(pc),a5   ; get to last character
GETEND:         tst.b   (a5)+
                bne.s   GETEND
ENDMARK:        cmp.b   -2(a5),d6
                bne.s   NOT_INACTIVE
ACCES:          move.b  #"¯",3(a6)
                bra.s   LEAGAL
NOT_INACTIVE:   cmpi.b  #"X",-2(a5)
                bne.s   GETNEXT

LEAGAL:
                move.b  d7,2(a6)
                addq.b  #1,d7

                lea     DTA+30(pc),a5
                lea     5(a6),a4        ; copy to menu data
KOPIERA:        move.b  (a5)+,(a4)+
                cmpi.b  #".",(a5)
                bne.s   KOPIERA

                lea     14(a6),a6
GETNEXT:        move.w  #$004F,-(a7)    ; serach Next
                trap    #1
                addq.l  #2,a7
                tst.w   d0
                bne.s   NOMORE

                bra.s   GOON

NOMORE:
                move.b  #"!",(a6)
                lea     14(a6),a6
                cmpa.l  a3,a6
                bne.s   NOMORE
FINISHED:       rts
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
OLDDTA:         dc.l 0

AUTOFIL:        dc.b "A:\AUTO\*.PR?",0
ACCEFIL:        dc.b "A:\*.AC?",0
                even

TEXT:           dc.b "d+000",0
                dc.b "t0075",0
                dc.b "s01",0
                dc.b "q00",0
                dc.b ";cOmega's Selecter V1.0, Written By Martin Liesen 1991",0
                dc.b ";c----------------------------------------------------",0

                dc.b "y024",0
                dc.b "o200",0
                dc.b ";cAUTO FOLDER",0
                dc.b ";c-----------",0
AUTO:           dc.b ">Ac          ",0
                dc.b ">Bc          ",0
                dc.b ">Cc          ",0
                dc.b ">Dc          ",0
                dc.b ">Ec          ",0
                dc.b ">Fc          ",0
                dc.b ">Gc          ",0
                dc.b ">Hc          ",0
                dc.b ">Ic          ",0
                dc.b ">Jc          ",0
SLUTAUTO:

                dc.b "y024",0
                dc.b "o420",0
                dc.b ";cACCESSORIES",0
                dc.b ";c-----------",0
ACCE:           dc.b ">Kc          ",0
                dc.b ">Lc          ",0
                dc.b ">Mc          ",0
                dc.b ">Nc          ",0
                dc.b ">Oc          ",0
                dc.b ">Pc          ",0
                dc.b ">Qc          ",0
                dc.b ">Rc          ",0
                dc.b ">Sc          ",0
                dc.b ">Tc          ",0
SLUTACCE:
                dc.b "e",0

                endpart

                >PART 'BSS DATA'
                data
DTA:            ds.b 64
SAVECOL:        ds.w 15
MENUAREA:       ds.b 5*1024
                endpart
                end
