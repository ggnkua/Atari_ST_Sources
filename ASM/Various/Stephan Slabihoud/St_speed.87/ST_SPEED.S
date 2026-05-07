*********************************************************************
*                                                                   *
*    ST-Speed     Copyright by     Stephan Slabihoud                *
*                                  Gustav-Ohm-Str.72                *
*                                    4250  Bottrop                  *
*                                  Tel.: 02041/23488                *
*                                                                   *
*********************************************************************

************************** LÑnge des Programmes berechnen

        move.l  4(sp),a0
        move.l  #$100,d6
        add.l   12(a0),d6
        add.l   20(a0),d6
        add.l   28(a0),d6
        add.l   #12000,d6
        move.l  d6,laenge

************************** Supervisor-Mode

        clr.l   -(a7)
        move.w  #32,-(a7)
        trap    #1
        addq.l  #6,a7
        move.l  d0,d6

************************** Programm in die VBLANK-QUEUE einbinden

        lea     start(pc),a2
        movea.l $456,a0
        adda    #28,a0
        move.l  a2,(a0)

************************** ZurÅck in den User-Mode

        move.l  d6,-(a7)
        move.w  #32,-(a7)
        trap    #1
        addq.l  #6,a7

        bsr     screen_start
        bsr     loesche_screen
        bsr     cursor_home
        lea     install(pc),a2
        move.l  a2,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

************************** Programm beenden und resident halten

        clr     -(sp)
        move.l  laenge,-(sp)
        move.w  #$31,-(sp)
        trap    #1

************************** Anfang Hauptroutine

start:
        tst.w   speedflag * Computer verlangsamen
        bne     speedwait
timeout:
        tst.w   $4ee      * ALT+HELP gedrÅckt ?
        beq     haupt     * Ja !
        rts

speedwait:
        move.l  d0,-(sp)
        move.l  speedtime,d0
time1:
        nop
        dbra    d0,time1
        move.l  (sp)+,d0
        bra     timeout

************************** ALT+HELP wurde gedrÅckt

haupt:
        bsr     maus_aus         * Maus ausschalten
        bsr     screen_start     * Anfang des Screens
        bsr     sichere_screen   * Screenbereich sichern
        bsr     loesche_screen   * Screenbereich lîschen
        bsr     gebe_menu_aus    * MenÅ ausgeben

schleife:
        bsr     inkey            * Tastatur-Abfrage
        bset    #5,d0            * Nur Kleinbuchstaben

        cmpi.b  #'h',d0          * Hardcopy
        beq     m_hardcopy       * drucken !!!

        cmpi.b  #'q',d0          * ZurÅck zum
        beq     m_quit           * Programm (GEM-Desktop)

        cmpi.b  #'c',d0          * Synchronisation
        beq     m_sync           * 50 <--> 60 Hz

        cmpi.b  #'f',d0          * Freier
        beq     m_free           * Speicher

        cmpi.b  #'0',d0          * Tastencode >= '0'
        bge     speed            * Ja !
notspeed:
        bra     schleife

speed:
        cmpi.b  #'9',d0         * Tastencode <= '9'
        ble     speed1          * Ja !
        bra     notspeed

************************** ZurÅck zum Programm oder GEM-Desktop

m_quit:
        bsr     hole_screen      * Screenbereich zurÅckholen
ende:
        move.w  #-1,$4ee         * Hardcopy-Flag auf -1 setzen
        bsr     maus_an          * Maus wieder anschalten
        rts                      * ZurÅck zum Programm

************************** Ausgabe einer Hardcopy

m_hardcopy:
        bsr     hole_screen
        move.w  #20,-(sp)        * XBIOS-Funktion 20 -> Hardcopy
        trap    #14
        addq.l  #2,sp
        bra     ende

************************** Synchronisation  50 <--> 60 Hz

m_sync:
        bchg.b  #1,$ff820a
        bra     m_quit

************************** Freier Speicher

m_free:
        bsr     screen_start
        bsr     loesche_screen
        bsr     cursor_home
        lea     freetext(pc),a2
        move.l  a2,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  #-1,-(sp)
        move.w  #$48,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,d1
        lea     freezahl(pc),a2
        bsr     binasc
        lea     freezahl(pc),a2
        move.l  a2,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
warte1:
        bsr     inkey
        tst.w   d0
        beq     warte1
        bra     m_quit

************************** VerÑndern der Geschwindigkeit

speed1:
        cmpi.b  #'0',d0
        beq     speednormal
        clr.l   d1
        move.b  d0,d1
        sub.b   #48,d1
        mulu    #1070,d1
        move.l  d1,speedtime
        move.w  #-1,speedflag
        bra     m_quit
speednormal:
        clr.w   speedflag
        clr.l   speedtime
        bra     m_quit

freetext:
        dc.b    13,13,10,'  Freier Speicher : ',0,0

freezahl:
        dc.b    '00000000',0,0
        even


************************** Hier steht der MenÅ-Text

text:
        dc.b    '     ST-Speed von Stephan Slabihoud',13,10
        dc.b    '     fÅr Happy-Computer und 68000er',13,10,13,10
        dc.b    ' 0-9 --> Geschwindigkeit',13,10
        dc.b    '  C  --> 50/60 Hz',13,10
        dc.b    '  F  --> Freier Speicher',13,10
        dc.b    '  H  --> Hardcopy ',13,10
        dc.b    '  Q  --> ZurÅck',13,10
        dc.b    0,0

install:
        dc.b    13,10,13,10,13,10
        dc.b    '    ST-Speed V1.3   Now resident ! ',13,10
        dc.b    ' Written by Stephan Slabihoud in 1987 ',13,10
        dc.b    0,0
        even


*####################################################################*
*                           Unterprogramme                           *
*####################################################################*


************************** Wandelt BIN-Zahl --> ASCII

binasc:
        moveq.l #10,d3
        move.l  a2,a0
        moveq.l #7,d0
schleif1:
        move.b  #'0',(a0)+
        dbra    d0,schleif1
binweiter:
        bsr     division
        or.b    #$30,d2
        move.b  d2,-(a0)
        cmpi.l  #0,d1
        bne     binweiter
        rts

division:
        movem.l d0/d3/d4,-(sp)
        move.l  d3,d4
        moveq.l #31,d0
        clr.l   d2
        clr.l   d3
naechstesbit:
        roxl.l  #1,d1
        roxl.l  #1,d2
        asl.l   #1,d3
        sub.l   d4,d2
        bmi     unterlauf
        addq.l  #1,d3
endediv:
        dbra    d0,naechstesbit
        move.l  d3,d1
        movem.l (sp)+,d0/d3/d4
        rts
unterlauf:
        add.l   d4,d2
        bra     endediv

************************** Anfang des Screens

screen_start:
        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,phybase
        rts

************************** Bildschirm sichern

sichere_screen:
        move.l  phybase,a1
        lea     screen_buf(pc),a0
        move.l  #11520-1,d0
jump1:
        move.b  (a1)+,(a0)+
        dbra    d0,jump1
        rts

************************** Bildschirm zurÅckholen

hole_screen:
        movea.l phybase,a1
        lea     screen_buf(pc),a0
        move.l  #11520-1,d0
jump3:
        move.b  (a0)+,(a1)+
        dbra    d0,jump3
        rts

************************** Bildschirm lîschen

loesche_screen:
        movea.l phybase,a0
        move.l  #11520-1,d0
jump2:
        move.b  #0,(a0)+
        dbne    d0,jump2
        rts

***********************+** MenÅ ausgeben

gebe_menu_aus:
        bsr     cursor_home   * Cursor auf POS(0,0)
        lea     text(pc),a0   * Text ausgeben
        move.l  a0,-(sp)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        rts

************************** Cursor auf POS(0,0)

cursor_home:
        move.w  #27,-(sp)
        move.w  #2,-(sp)
        trap    #1
        move.w  #'Y',-(sp)    * ESC-Y  -> Cursor positionieren
        move.w  #2,-(sp)
        trap    #1
        move.w  #32,-(sp)
        move.w  #2,-(sp)
        trap    #1
        move.w  #32,-(sp)
        move.w  #2,-(sp)
        trap    #1
        add.l   #16,sp
        rts

********************+***** Tastatur-Abfrage

inkey:
        move.w  #$b,-(sp)
        trap    #1
        addq.l  #2,sp
        tst.w   d0
        beq     endinkey
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp
        bra     inkey
endinkey:
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp
        rts

************************** Maus anschalten

maus_an:
        move.w  #122,contrl
        move.w  #0,contrl+2
        move.w  #1,contrl+6
        move.w  #0,contrl+12
        move.w  #0,intin
        bsr     vdi
        rts

************************** Maus ausschalten

maus_aus:
        move.w  #123,contrl
        move.w  #0,contrl+2
        move.w  #0,contrl+6
        move.w  #0,contrl+12
        bsr     vdi
        rts

************************** VDI Aufruf

vdi:            
        lea     vdipb(pc),a0
        move.l  a0,d1
        move.w  #$73,d0
        trap    #2
        rts

************************** Variablen

speedflag:
        dc.w    0
speedtime:
        dc.l    0

laenge:
        dc.l    0         * LÑnge des Programms
phybase:
        dc.l    0         * Anfang des Bildschirms

vdipb:
        dc.l    contrl,intin,ptsin,intout,ptsout
intin:
        ds.w    32
ptsin:
        ds.w    32
intout:
        ds.w    32
ptsout:
        ds.w    32

contrl:
opcode:
        ds.w    16

screen_buf:
        ds.w    1

        end
