********************************
*                              *
* SCREENWATCH V1.0             *
*                              * 
* öberwachung des Bildschirms  *
*                              *
* per MMU                      *
*                              *
* (C) 1991 by Uwe Seimet       *
*                              *
********************************


GEMDOS  = 1
CCONWS  = 9
SUPER   = 32
PTERMRES= 49
MXALLOC = 68
MSHRINK = 74


BCONOUT = 3
BIOS    = 13


XBIOS   = 14
SETSCREEN=5 


_v_bas_ad= $44e
_p_cookies= $5a0


magic   = "SCRW"                ;fÅr XBRA


        text

        move.l 4(sp),a0         ;Pointer auf
                                ;Basepage
        move.l 12(a0),a6
        add.l 28(a0),a6
        lea $100(a6),a6
        pea (a6)
        pea (a0)
        clr -(sp)
        move #MSHRINK,-(sp)     ;Restspeicher
        trap #GEMDOS            ;freigeben
        lea 12(sp),sp
        tst.l d0
        bne quit                ;Fehler-

        clr.l -(sp)
        move #SUPER,-(sp)       ;Supervisor-
        trap #GEMDOS            ;Modus
        addq.l #6,sp
        move.l d0,d7            ;SSP merken

        move.l $08,a0
        cmp.l #magic,-8(a0)     ;bereits
        beq exit                ;installiert-

        lea sterr(pc),a5
        move.l _p_cookies,d0
        beq error               ;kein cookie jar-
        move.l d0,a0
nomch:  movem.l (a0)+,d0-d1
        tst.l d0                ;Ende des
        beq error               ;cookie jar-
        cmp.l #"_MCH",d0        ;Computertyp?
        bne nomch               ;nein-
        swap d1
        subq.l #2,d1            ;TT?
        bne error               ;nein-

        lea memerr(pc),a5
        clr -(sp)               ;nur ST-RAM
        pea 5*32768+32767       ;Platz fÅr 5 Pages
        move #MXALLOC,-(sp)     ;anfordern
        trap #GEMDOS
        addq.l #8,sp
        add.l #32767,d0
        and #$8000,d0           ;Bildschirmstart
                                ;auf Page-Anfang
        move.l d0,d5            ;neue Bildschirm-
                                ;Adresse
        beq error               ;kein Speicher-

        move.l _v_bas_ad,a0
        move.l d5,a1
        move #38399,d0
scrcpy: move.l (a0)+,(a1)+      ;Bildschirm
        dbra d0,scrcpy		;kopieren

        move.l #table+15,d6     ;Deskriptortabelle
        and #$fff0,d6           ;auf 16-Byte-Grenze

        pmove crp,crpsav        ;alter CRP
        move.l crpsav+4,a0      ;Pointer auf
                                ;alte Tabelle
        move.l d6,crpreg+4      ;fÅr neuen CRP

        moveq #63,d0            ;64 Deskriptoren
        move.l d6,a1            ;neue Tabelle
        move.l crpsav+4,a2      ;zeigt auf
        lea 256(a2),a2          ;Tabellenende
copy:   move.l (a0)+,d1         ;Kurzformat
        move.l d1,d2
        and.l #$ff,d1           ;Adresse ausblenden
        btst #1,d1              ;Seiten-Deskriptor?
        beq cont                ;ja-
        and #$0f,d1             ;Adresse ausblenden
cont:   or.l #$8000fc01,d1      ;ergibt Langformat
        move.l d1,(a1)+
        btst #1,d1              ;Seiten-
        beq next                ;Deskriptor-
        move.l d2,d1
        clr.b d1
        cmp.l a2,d1             ;auûerhalb
        bcc next0               ;der Tabelle-
        and #$fff0,d2
        sub.l crpsav+4,d2
        add.l d2,d2             ;neue Adresse
        add.l d6,d2             ;berechnen
        bra next0
next:   clr.b d2
next0:  move.l d2,(a1)+
        dbra d0,copy

        move.l a1,a0
        moveq #3,d0
        lea (384,d6.l),a2       ;Tabellen-
dloop:  move.l #$8000fc03,(a2)+ ;Deskriptoren
        move.l a0,(a2)+         ;fÅr ST-RAM
        lea 256(a0),a0
        dbra d0,dloop

        moveq #0,d1
        moveq #127,d0
init:   move.l #$0000fc01,(a1)+
        move.l d1,(a1)+
        add.l #$00008000,d1
        dbra d0,init

        move.l $08,o_bus
        move.l #buserr,$08

        pmove crpreg,crp        ;neuer Rootpointer
                                ;(ATC wird gelîscht!)
        ptestr #7,(d5.l),#7,a0  ;Adresse der
                                ;Bildschirm-
                                ;Deskriptoren
        bset #0,2(a0)           ;Supervisor-Only
        bset #0,10(a0)          ;fÅr 5 Pages
        bset #0,18(a0)          ;(=Videoram)
        bset #0,26(a0)
        bset #0,34(a0)

        move.l d7,-(sp)
        move #SUPER,-(sp)       ;RÅckkehr in
        trap #GEMDOS            ;User-Modus
        addq.l #6,sp

        move #-1,-(sp)
        move.l d5,-(sp)         ;neue Adresse
        move.l d5,-(sp)         ;fÅr Bildschirm
        move #SETSCREEN,-(sp)
        trap #XBIOS
        lea 12(sp),sp
        pea message(pc)         ;SCREENWATCH
        move #CCONWS,-(sp)      ;ist
        trap #GEMDOS            ;installiert
        addq.l #6,sp
        clr -(sp)
        pea (a6)                ;ProgrammlÑnge
        move #PTERMRES,-(sp)    ;Programm
        trap #GEMDOS            ;resident
                                ;halten

error:
        pea (a5)                ;Fehlermeldung
        move #CCONWS,-(sp)      ;ausgeben
        trap #GEMDOS
        addq.l #6,sp
        pea inserr(pc)          ;nicht installiert
        move #CCONWS,-(sp)
        trap #GEMDOS
        addq.l #6,sp
exit:   move.l d7,-(sp)
        move #SUPER,-(sp)       ;zurÅck in
        trap #GEMDOS            ;User-Modus
        addq.l #6,sp
quit:   clr -(sp)
        trap #GEMDOS


        dc.l "XBRA"
        dc.l magic
o_bus:  dc.l 0

buserr:
        ptestr #3,([16,sp]),#7
        pmove psr,status        ;Adresse testen
        btst #5,status          ;Supervisor
        bne wrterr              ;Only-
oldbus: move.l o_bus(pc),-(sp)
        rts

wrterr:
        movem.l a0-a2/d0-d2,-(sp)
        move #7,-(sp)           ;BEL
        move #2,-(sp)
        move #BCONOUT,-(sp)
        trap #BIOS              ;Alarmton ausgeben
        addq.l #6,sp
        movem.l (sp)+,a0-a2/d0-d2
        bset #2,11(sp)          ;Befehl im
        rte                     ;Supervisor-Modus
                                ;wiederholen


crpreg: dc.l $80000003          ;alle Deskriptoren
        dc.l $00000000          ;im Langformat


message:dc.b $0d,$0a,"SCREENWATCH V1.0 "
        dc.b "installiert",$0d,$0a
        dc.b "Ω 1991 by Uwe Seimet",$0d,$0a,0


*Diverse Fehlermeldungen

sterr:  dc.b $0d,$0a,"SCREENWATCH lÑuft nur "
        dc.b "auf einem TT!",0

memerr: dc.b $0d,$0a,"Zu wenig Speicher!",0

inserr: dc.b $0d,$0a,"SCREENWATCH V1.0 "
        dc.b "nicht installiert",$0d,$0a,0


        bss

crpsav: ds.l 2

status: ds.w 1                  ;fÅr MMU-Status

table:  ds.b 512+1024+15        ;Deskriptortabelle

