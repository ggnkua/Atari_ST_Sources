***********************************
*                                 *
* XHDI-Autoparker V1.00 Accessory *
*                                 *
* by Uwe Seimet                   *
*                                 *
* (c) 1992 MAXON Computer         *
*                                 *
***********************************


DIALOG   = 0  
PARKTIME = 3  
OK       = 6  
PARK     = 7  
ABORT    = 8  

XHStop   = 4
XHDrvMap = 6
XHInqDev = 7

GEMDOS   = 1
SUPER    = 32
FOPEN    = 61
FCLOSE   = 62
FREAD    = 63

XBIOS    = 14
SUPEXEC  = 38

APPL_INIT     = 10
EVNT_MULTI    = 25
MENU_REGISTER = 35
OBJC_DRAW     = 42
OBJC_CHANGE   = 47
FORM_DO       = 50
FORM_DIAL     = 51
FORM_CENTER   = 54
GRAF_MOUSE    = 78
WIND_UPDATE   = 107
RSRC_OBFIX    = 114

END_MCTRL = 2
BEG_MCTRL = 3

_hz_200    = $4ba
_p_cookies = $5a0

XHDIMAGIC= $27011992


         loadfast
         ttmem
         ttram


         text

         lea stack+400,sp
         lea intin,a5               ;Pointer auf
                                    ;INTIN-Array
         lea intout,a6              ;Pointer auf
                                    ;INTOUT-Array
         moveq #APPL_INIT,d0
         move.l #$00010000,d1
         bsr aes
         move (a6),(a5)             ;apid_nr
         moveq #MENU_REGISTER,d0
         move.l #$01010100,d1       ;Name in
         lea entry,a0               ;MenÅleiste
         bsr aesobj                 ;eintragen
         move (a6),d5               ;Nummer des
                                    ;Eintrags
                                    ;merken
         bmi quit

         move #_objcnr,(a5)
         bra.s fix
obfix:   moveq #RSRC_OBFIX,d0
         move.l #$01010100,d1
         lea objc000,a0             ;Objektdaten
         bsr aesobj                 ;umrechnen
fix:     subq #1,(a5)                
         bpl obfix

         clr -(sp)
         pea parname
         move #FOPEN,-(sp)
         trap #GEMDOS
         addq.l #8,sp
         move.l d0,d3               ;keine
         bmi.s loop                 ;Parameter-
         pea parbuff
         pea 3
         move d3,-(sp)
         move #FREAD,-(sp)
         trap #GEMDOS
         lea 10(sp),sp
         move d3,-(sp)
         move #FCLOSE,-(sp)
         trap #GEMDOS
         addq.l #4,sp
         lea parbuff,a0
         bsr get

loop:    move #$10,(a5)             ;MU_MESAG
         tst time
         beq.s notime
         move #$30,(a5)             ;MU_MESAG|
                                    ;MU_TIMER
         move.l #$ea600000,28(a5)   ;1 min warten
notime:  lea ev_buff,a0             ;Buffer fÅr
                                    ;GEM-Messages
         moveq #EVNT_MULTI,d0
         move.l #$10070100,d1
         bsr aesobj

         clr.l -(sp)
         move #SUPER,-(sp)
         trap #GEMDOS
         addq.l #6,sp
         move.l d0,-(sp)            ;alter
                                    ;Stackpointer

         move.l _p_cookies,d0       ;keine
         beq supret                 ;cookies-
         sub.l a3,a3
         sub.l a4,a4
         move.l d0,a0
fxhdi:   movem.l (a0)+,d0/a1
         tst.l d0
         beq endjar
         cmp.l #"XHDI",d0
         bne.s noxhdi
         cmp.l #XHDIMAGIC,-4(a1)
         bne.s noxhdi
         move.l a1,a4
         bra fxhdi
noxhdi:  cmp.l #"USPK",d0
         bne fxhdi
         move.l a1,a3
         bra fxhdi
endjar:  move.l a4,d0               ;kein
         beq supret                 ;XHDI-Treiber-
         move.l a3,d0               ;AUTOPARK.PRG
         beq supret                 ;nicht
                                    ;installiert-

         btst #5,1(a6)              ;MU_TIMER?
         beq supret                 ;nein-

         move #XHDrvMap,-(sp)       ;XHDI-
         jsr (a4)                   ;GerÑtevektor
         addq.l #2,sp               ;holen
         move.l d0,d6

*Liste aller XHDI-Devices erstellen
         lea devices,a2             ;Flag fÅr
         move.l #-1,(a2)            ;Tabellenende
         moveq #0,d7
inquire: bsr inqdev
         bmi.s inqnext
         move.l major,(a2)+
         move.l #-1,(a2)
inqnext: addq #1,d7
         cmp #32,d7
         bne inquire

*Totzeit ÅberprÅfen
         moveq #0,d7
test:    bsr inqdev
         bmi.s next
         move d7,d0
         add d0,d0
         add d0,d0
         move time,d1               ;Zeit in
         mulu #12000,d1             ;200 Hertz-
                                    ;Schritten
         add.l (a3,d0),d1           ;letzte
                                    ;Zugriffszeit
         cmp.l _hz_200,d1
         bcs.s next                 ;parken-
         move.l major,d0
         lea devices,a0
skipdev: cmp.l #-1,(a0)
         beq.s next                 ;Listenende
         cmp.l (a0)+,d0
         bne skipdev
         move.l #-2,-4(a0)          ;aus Liste
         bra skipdev                ;streichen
next:    addq #1,d7
         cmp #32,d7
         bne test

         lea devices,a2
park:    cmp.l #-1,(a2)
         beq.s supret
         cmp.l #-2,(a2)+
         beq park
         move.l -4(a2),major
         clr -(sp)                  ;Dummy-Key
         move #1,-(sp)              ;Platte parken
         move minor,-(sp)
         move major,-(sp)
         move #XHStop,-(sp)
         jsr (a4)
         lea 10(sp),sp
         bra park

supret:  move #SUPER,-(sp)
         trap #GEMDOS
         addq.l #6,sp

message: btst #4,1(a6)              ;MU_MESAG?
         beq loop                   ;nein-
         lea ev_buff,a0
         cmp #40,(a0)               ;AC_OPEN?
         bne loop                   ;nein-
         cmp 8(a0),d5               ;AUTOPARK?
         bne loop                   ;nein-
         moveq #BEG_MCTRL,d0
         bsr update
         bsr.s dialog
         moveq #END_MCTRL,d0
         bsr update
         bra loop

quit:
         moveq #19,d0               ;appl_exit
         move.l #$00010000,d1
         bsr aes
         clr -(sp)
         trap #GEMDOS               ;das war's

dialog:
         lea objc000,a2
         move #PARKTIME*24,d0
         move.l 12(a2,d0),a0
         move.l (a0),a0
         moveq #0,d0
         move time,d0
         bsr int
         moveq #FORM_CENTER,d0
         move.l #$00050100,d1
         move.l a2,a0
         bsr aesobj
         movem.l 2(a6),a3-a4        ;form_xy,
                                    ;form_wh
         clr d2
         movem.l a3-a4,2(a5)
         movem.l a3-a4,10(a5)
         bsr form_dial
         moveq #OBJC_DRAW,d0
         move.l #$06010100,d1
         move.l #$00000002,(a5)
         move.l 2(a6),4(a5)
         move.l 6(a6),8(a5)
         move.l a2,a0               ;Dialogbox
         bsr aesobj                 ;darstellen
         moveq #FORM_DO,d0
         move.l #$01010101,d1
         move #PARKTIME,(a5)        ;Eingabefeld
         move.l a2,a0               ;Dialog
         bsr aesobj                 ;starten
         move (a6),d3
         bclr #15,d3
         cmp #ABORT,d3              ;Abbruch?
         beq.s abort                ;ja-
         cmp #PARK,d3               ;alle GerÑte
         beq.s parkall              ;parken-
         move #PARKTIME*24,d0
         move.l 12(a2,d0),a0
         move.l (a0),a0
         bsr get
abort:   moveq #3,d2
         movem.l a3-a4,2(a5)
         bsr fo_dial
         moveq #OBJC_CHANGE,d0
         move.l #$08010100,d1
         move.l a5,a0
         move d3,(a0)+
         clr (a0)+
         movem.l a3-a4,(a0)
         clr.l 12(a5)
         move.l a2,a0               ;Exit-Button
         bra aesobj                 ;deselektieren

parkall:
         move #2,(a5)               ;Biene als
         moveq #GRAF_MOUSE,d0       ;Mauscursor
         move.l #$01010100,d1
         bsr aes
         pea stop(pc)
         move #SUPEXEC,-(sp)
         trap #XBIOS
         addq.l #6,sp
         clr (a5)                   ;Pfeil als
         moveq #GRAF_MOUSE,d0       ;Mauscursor
         move.l #$01010100,d1
         bsr aes
         bra abort

stop:
         move.l _p_cookies,d0       ;keine
         beq.s error                ;cookies-
         move.l d0,a0
nxhdi:   movem.l (a0)+,d0/a4
         tst.l d0
         beq.s error
         cmp.l #"XHDI",d0
         bne.s nxhdi
         cmp.l #XHDIMAGIC,-4(a4)
         bne.s nxhdi

         move #XHDrvMap,-(sp)       ;XHDI-
         jsr (a4)                   ;GerÑtevektor
         addq.l #2,sp               ;holen
         move.l d0,d6
         moveq #0,d7
nxt:     bsr inqdev
         bmi.s nxtdev
         clr -(sp)                  ;Dummy-Key
         move #1,-(sp)              ;Platte parken
         move minor,-(sp)
         move major,-(sp)
         move #XHStop,-(sp)
         jsr (a4)
         lea 10(sp),sp
nxtdev:  addq #1,d7
         cmp #32,d7
         bne nxt
error:   rts


fo_dial:
         movem.l a3-a4,10(a5)
form_dial:
         moveq #FORM_DIAL,d0
         move.l #$09010100,d1
         move d2,(a5)
aesobj:
         move.l a0,addrin
aes:     lea contrl,a0
         move d0,(a0)
         movep.l d1,3(a0)
         move.l #aespb,d1
         move #$c8,d0
         trap #2
         rts

update:
         move d0,(a5)
         moveq #WIND_UPDATE,d0
         move.l #$01010000,d1
         bra aes

*GerÑtenummer zu logischem Laufwerk erfragen
inqdev:
         moveq #-1,d0
         btst d7,d6                 ;kein
         beq.s nodev                ;XHDI-Device-
         clr.l -(sp)
         clr.l -(sp)
         pea minor
         pea major
         move d7,-(sp)
         move #XHInqDev,-(sp)       ;GerÑtenummern
         jsr (a4)                   ;holen
         lea 20(sp),sp
nodev:   tst d0
         rts

*Umwandlung HEX in ASCII
int:
         tst.l d0
         beq int5                   ;Null-
         moveq #2,d3
         move.l a0,a1
         move.l #100,d2             ;Startwert fÅr Subtraktion
int1:    moveq #-1,d1               ;zÑhlt Subtraktionen
int0:    addq.b #1,d1
         sub.l d2,d0                ;so oft wie mîglich subtrahieren
         bcc int0
         add.l d2,d0
         divu #10,d2                ;nÑchste Stelle
         tst.b d1
         bne int3
         cmp.l a1,a0
         beq int4
int3:    add.b #"0",d1              ;Ziffer nach
         move.b d1,(a0)+            ;ASCII wandeln
int4:    dbra d3,int1
         clr.b (a0)
         rts
int5:    move.b #"0",(a0)+
         clr.b (a0)
         rts

*Umwandlung ASCII in HEX
get:
         moveq #0,d0                ;Ergebnis lîschen
         moveq #0,d1
getloop: move.b (a0)+,d1            ;Ziffer holen
         beq.s getret               ;Ende-
         sub.b #'0',d1              ;in HEX wandeln
         add.l d0,d0
         move.l d0,-(sp)
         asl.l #2,d0
         add.l (sp)+,d0
         add.l d1,d0
         bra getloop
getret:  move d0,time
         rts


         data

aespb:   dc.l contrl,global
         dc.l intin,intout
         dc.l addrin,addrout

entry:   dc.b "  XHDI-Autoparker",0

parname: dc.b "AUTOPARK.INF",0

         even

G_BOX     = 20
G_TEXT    = 21
G_BUTTON  = 26
G_FTEXT   = 29

objc000: dc.w $ffff
         dc.w $0001,$0008
         dc.w G_BOX
         dc.w $0000,$0010
         dc.l $00021100
         dc.w $0000,$0000
         dc.w $0027,$000d

         dc.w $0002
         dc.w $ffff,$ffff
         dc.w G_BUTTON
         dc.w $0001,$0011
         dc.l spec000
         dc.w $0008,$0001
         dc.w $0017,$0801

         dc.w $0003
         dc.w $ffff,$ffff
         dc.w G_TEXT
         dc.w $0000,$0000
         dc.l spec001
         dc.w $000b,$0004
         dc.w $0410,$0001

         dc.w $0004
         dc.w $ffff,$ffff
         dc.w G_FTEXT
         dc.w $0008,$0000
         dc.l spec002
         dc.w $0002,$0006
         dc.w $0023,$0001

         dc.w $0005
         dc.w $ffff,$ffff
         dc.w G_TEXT
         dc.w $0000,$0000
         dc.l spec003
         dc.w $0004,$0008
         dc.w $061e,$0001

         dc.w $0006
         dc.w $ffff,$ffff
         dc.w G_TEXT
         dc.w $0000,$0000
         dc.l spec004
         dc.w $000a,$0009
         dc.w $0012,$0001

         dc.w $0007
         dc.w $ffff,$ffff
         dc.w G_BUTTON
         dc.w $0007,$0000
         dc.l spec005
         dc.w $0005,$000b
         dc.w $0009,$0001

         dc.w $0008
         dc.w $ffff,$ffff
         dc.w G_BUTTON
         dc.w $0005,$0000
         dc.l spec006
         dc.w $000f,$000b
         dc.w $0009,$0001

         dc.w $0000
         dc.w $ffff,$ffff
         dc.w G_BUTTON
         dc.w $0025,$0000
         dc.l spec007
         dc.w $0019,$000b
         dc.w $0009,$0001

spec000: dc.b "XHDI-Autoparker V1.00",0

spec001: dc.l txt001,plt001,val001
         dc.w $0005
         dc.w $0006
         dc.w $0000
         dc.w $1180
         dc.w $0000
         dc.w $ffff
         dc.w $0017,$0001
txt001:  dc.b "(C) 1992 by Uwe Seimet",0
plt001:  dc.b 0
val001:  dc.b 0

spec002: dc.l txt002,plt002,val002
         dc.w $0003
         dc.w $0006
         dc.w $0002
         dc.w $1180
         dc.w $0000
         dc.w $ffff
         dc.w $0004,$0024
txt002:  dc.b "___",0
plt002:  dc.b "Zeit bis zum Parken in Minuten: ___",0
val002:  dc.b "999",0

spec003: dc.l txt003,plt003,val003
         dc.w $0005
         dc.w $0006
         dc.w $0000
         dc.w $1180
         dc.w $0000
         dc.w $ffff
         dc.w $002a,$0001
txt003:  dc.b "XHDI-kompatibler Treiber und AUTOPARK.PRG",0
plt003:  dc.b 0
val003:  dc.b 0

spec004: dc.l txt004,plt004,val004
         dc.w $0005
         dc.w $0006
         dc.w $0000
         dc.w $1180
         dc.w $0000
         dc.w $ffff
         dc.w $0019,$0001
txt004:  dc.b "mÅssen installiert sein!",0
plt004:  dc.b 0
val004:  dc.b 0

spec005: dc.b "OK",0

spec006: dc.b "Parken",0

spec007: dc.b "Abbruch",0

_objcnr  equ 0009


         bss

contrl:  ds.w 11

global:  ds.w 15

intin:   ds.w 64

intout:  ds.w 64

addrin:  ds.w 64

addrout: ds.w 64

ev_buff: ds.w 8

ap_buff: ds.w 8

         even

stack:   ds.l 100

time:    ds.w 1

major:   ds.w 1
minor:   ds.w 1

devices: ds.w 68

parbuff: ds.b 4            ;Puffer fÅr Parameterdatei
