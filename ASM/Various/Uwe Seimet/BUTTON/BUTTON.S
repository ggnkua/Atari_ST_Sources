******************************************
* Beispielprogramm fÅr die Realisierung  *
* eines komfortablen Dialogs             *
* (C) MAXON Computer GmbH                *
* by Uwe Seimet                          *
******************************************

*benîtigte Objekttypen
G_USERDEF= 24
G_BUTTON = 26

*wichtige Variablen OBJECT-Struktur
ob_flags = 8
ob_spec  = 12

*wichtige Variablen der PARMBLK-Struktur
pb_prevstate = 6
pb_currstate = 8
pb_x     = 10
pb_y     = 12
pb_w     = 14
pb_h     = 16
pb_parm  = 26

*fÅr einige wenige Systemaufrufe
GEMDOS   = 1
MSHRINK  = 74

BIOS     = 13
BCONOUT  = 3


         text

         move.l sp,a0
         lea stack+400,sp           ;Stackpointer initialisieren
         move.l 4(a0),a0
         move.l 12(a0),a1
         add.l 20(a0),a1
         add.l 28(a0),a1
         lea $100(a1),a1            ;fÅr Basepage
         pea (a1)
         pea (a0)
         clr -(sp)
         move #MSHRINK,-(sp)
         trap #GEMDOS               ;Restspeicher freigeben
         lea 12(sp),sp
         tst.l d0
         bne error                  ;Fehler-
         lea intin,a5               ;Pointer auf INTIN-Array
         lea intout,a6              ;Pointer auf INTOUT-Array
         moveq #10,d0               ;appl_init
         move.l #$00010000,d1
         bsr aes
         bmi error                  ;Fehler-
         moveq #77,d0               ;graf_handle
         move.l #$00050000,d1
         bsr aes
         move 2(a6),hwchar          ;Zeichenbreite in Pixeln
         move 4(a6),hhchar          ;Zeichenhîhe in Pixeln
         move.l a5,a0
         moveq #9,d0
opn:     move #1,(a0)+
         dbra d0,opn
         move #2,(a0)
         moveq #100,d0              ;v_opnvwk
         lea contrl+2,a3
         clr.l (a3)+
         move #11,(a3)
         move (a6),6(a3)            ;graf_handle
         bsr vdiinit
         move 6(a3),vdi_h           ;vdi_handle merken
         move.l (a6),d0             ;Desktop-Grîûe
         add.l #$00010001,d0
         move.l d0,deskwh           ;Bildschirmbreite und -hîhe
         lea _objcnr,a0
         move a0,(a5)
         bra.s skip
fixloop: moveq #114,d0              ;rsrc_obfix
         move.l #$01010100,d1
         lea objc000,a0
         bsr aesobj                 ;Objektdaten umrechnen
skip:    subq #1,(a5)
         bpl fixloop
         lea objc000,a2
         clr d5                     ;kein Eingabefeld
         bsr.s form_do              ;Dialog ausfÅhren
         moveq #101,d0              ;v_clsvwk
         bsr vdi
         moveq #19,d0               ;appl_exit
         move.l #$00010000,d1
         bsr aes
error:   clr -(sp)
         trap #GEMDOS

form_do:
         clr (a5)                   ;Pfeil als Mauscursor
         moveq #78,d0               ;graf_mouse
         move.l #$01010100,d1
         bsr aes
         move.l a2,a0
         moveq #54,d0               ;form_center
         move.l #$00050100,d1
         bsr aesobj
         movem.l 2(a6),d0/d1        ;form_xy und form_wh
         movem.l d0/d1,xywh
         clr d2                     ;FMD_START
         movem.l d0/d1,2(a5)
         movem.l d0/d1,10(a5)
         bsr form_dial
         moveq #3,d0                ;bis zu Ebene 3
         move.l d0,(a5)
         bsr inituser               ;G_USERDEF-Objekte initialisieren
         movem.l xywh,d0/d1
         movem.l d0/d1,4(a5)
         moveq #42,d0               ;objc_draw
         move.l #$06010100,d1
         move.l a2,a0
         bsr aesobj
         bra _form_do

form_cnt:
         bsr exituser               ;G_BUTTON-Objekte zurÅckholen
         moveq #3,d2                ;FMD_FINISH
         movem.l xywh,d0/d1
         movem.l d0/d1,2(a5)
         bsr.s fo_dial
         move d7,d0
         mulu #24,d0
         move 10(a2,d0),d0          ;alter Objektstatus
         bclr #0,d0                 ;deselektieren
         clr d1                     ;nicht neu zeichnen
         move.l a2,a0
change:  move d7,d2
         mulu #24,d2
         tst.b 9(a0,d2)             ;versteckt?
         bpl *+4                    ;nein-
         clr d1                     ;nicht neu zeichnen
         move 10(a0,d2),d2          ;alter Objektstatus
         and #$fff6,d2
         or d2,d0
         move.l a5,a1
         move d7,(a1)+              ;Objektnummer
         clr (a1)+
         move.l deskxy,(a1)+
         move.l deskwh,(a1)+        ;Breite und Hîhe
         move d0,(a1)+              ;neuer Objektstatus
         move d1,(a1)               ;Flag fÅr neu zeichnen
         moveq #47,d0               ;objc_change
         move.l #$08010100,d1
         bra aesobj

form_end:
         moveq #3,d2                ;FMD_FINISH
         movem.l xywh,d0/d1
         movem.l d0/d1,2(a5)
fo_dial: movem.l xywh,d0/d1
         movem.l d0/d1,10(a5)
form_dial:
         moveq #51,d0                ;form_dial
         move.l #$09010100,d1
         move d2,(a5)
         bra aes

_form_do:movem d5-d6,-(sp)
_form:   moveq #1,d0                ;Cursor einschalten
         bsr objcedit
         move 2(a6),d6              ;Position des Cursors
dloop:   move #2,2(a5)
         move #1,4(a5)              ;linker Mausbutton
         move #1,6(a5)              ;gedrÅckter Mausbutton
         moveq #25,d0               ;evnt_multi
         move.l #$10070100,d1
         move #3,(a5)               ;MU_KEYBD | MU_BUTTON
         lea ev_buff,a0
         clr (a0)                   ;letzte Message lîschen
         bsr aesobj
         btst #1,1(a6)              ;MU_BUTTON?
         bne.s button               ;ja-
         move 10(a6),d0             ;ASCII- und Scancode
         tst.b d0                   ;Alternate-Taste gedrÅckt?
         bne.s noalt                ;nein-
         lsr #8,d0
         move.l a2,a0
uloop:   cmp.b 6(a0),d0             ;Button fÅr Taste gefunden?
         beq.s default              ;ja-
         btst #5,9(a0)              ;letztes Objekt?
         bne.s noalt                ;ja-
         lea 24(a0),a0
         bra uloop
default: tst.b 9(a0)                ;verstecktes Objekt?
         bmi.s noalt                ;ja-
         sub.l a2,a0
         move.l a0,d7
         divu #24,d7                ;ergibt Objektnummer
         move #1,12(a6)             ;fÅr einen Mausklick
         bra.s obj
noalt:   move 10(a6),2(a5)          ;eingegebenes Zeichen
         move d5,(a5)               ;aktuelles Edit-Objekt
         clr 4(a5)
         moveq #55,d0               ;form_keybd
         move.l #$03030100,d1
         move.l a2,a0
         bsr aesobj
         clr d7
         move.b 3(a6),d7            ;neues Edit-Objekt
         tst (a6)                   ;Exit?
         beq exit                   ;ja-
         tst 4(a6)                  ;Wechsel des Eingabefeldes?
         beq.s newin                ;ja-
         move 10(a6),2(a5)          ;eingegebenes Zeichen
         move d6,4(a5)              ;Cursorposition
         moveq #2,d0                ;Zeichen ausgeben
         bsr objcedit
         move 2(a6),d6              ;neue Cursorposition
         bra dloop
button:  clr (a5)
         move #3,2(a5)              ;bis Ebene 3
         move.l 2(a6),d0            ;aktuelle Mausposition
         move.l d0,4(a5)
         moveq #43,d0               ;objc_find
         move.l #$04010100,d1
         move.l a2,a0
         bsr aesobj
         move (a6),d7               ;Objektnummer
         bpl.s obj                  ;Mauszeiger ist innerhalb der Box-
         pea (a2)
         bsr bell                   ;Warnton ausgeben
         move.l (sp)+,a2
         bra dloop
obj:     moveq #56,d0               ;form_button
         move.l #$02020100,d1
         move d7,(a5)               ;angeklicktes Objekt
         move 12(a6),2(a5)          ;Anzahl der Mausklicks
         move.l a2,a0
         bsr aesobj
         tst (a6)                   ;Exit-Objekt?
         beq.s exit                 ;ja-
         move d7,d0
         mulu #24,d0
         btst #3,9(a2,d0)           ;Objekt editierbar?
         beq dloop                  ;nein-
         cmp d7,d5
         beq dloop
newin:   bsr.s cursor
         move d7,d5                 ;neues Eingabefeld
         bra _form
exit:    bsr.s cursor
         movem (sp)+,d5-d6
         bra form_cnt
cursor:  move d6,4(a5)              ;Cursorposition
         moveq #3,d0
objcedit:move d5,(a5)               ;Eingabefeld vorhanden?
         bne *+4                    ;ja-
         rts
         move d0,6(a5)              ;Cursor einschalten
         moveq #46,d0               ;objc_edit
         move.l #$04020100,d1
         move.l a2,a0
         bra aesobj

*markierte Objekte in G_USERDEF Objekte umwandeln
*USERBLK-Struktur erzeugen
inituser:
         lea buffer,a1              ;Puffer fÅr USERBLK-Strukturen
         move.l a2,a0
         clr d0
iloop:   btst #2,ob_flags(a0,d0)    ;markiertes Objekt?
         beq.s noext1               ;nein-
         move.l ob_spec(a0,d0),d1   ;Pointer auf Text
         move.l a1,12(a0,d0)        ;Pointer auf USERBLK-Struktur
         move.l #usercode,(a1)+     ;Pointer auf eigene Zeichenroutine
         move.l d1,(a1)+            ;Pointer auf Text
         move.b #G_USERDEF,7(a0,d0)
         move hhchar,22(a0,d0)
         addq #1,22(a0,d0)          ;Button um ein Pixel erweitern
noext1:  add #24,d0
         btst #5,-15(a0,d0)         ;LASTOB?
         beq iloop                  ;nein-
         rts

*G_USERDEF-Objekte in G_BUTTON-Objekte zurÅckverwandeln
exituser:
         lea buffer,a1              ;Puffer fÅr alte ob_spec-Zeiger
         move.l a2,a0
         clr d0
eloop:   btst #2,ob_flags(a0,d0)
         beq.s noext2
         addq.l #4,a1
         move.l (a1)+,12(a0,d0)
         move.b #G_BUTTON,7(a0,d0)
noext2:  add #24,d0
         btst #5,-15(a0,d0)         ;LASTOB?
         beq eloop                  ;nein-
         rts


usercode:
         movem.l a5/a6,-(sp)
         lea ptsin,a5
         move.l 12(sp),a6           ;Zeiger auf PARMBLK
         move 8(a6),d0
         cmp 6(a6),d0               ;erster Aufruf?
         beq.s first                ;ja-
         movem pb_x(a6),d0/d1
         movem d0/d1,(a5)
         movem d0/d1,8(a5)
         add pb_w(a6),d0
         subq #1,d0
         add pb_h(a6),d1
         subq #1,d1
         movem d0/d1,4(a5)
         movem d0/d1,12(a5)
         lea contrl,a0
         move #4,2(a0)
         move #1,6(a0)
         move.l #mfdb,14(a0)
         move.l #mfdb,18(a0)
         move #12,intin             ;E = not Q
         moveq #109,d0              ;vro_cpyfm
         bsr vdi                    ;Button invertieren
         move pb_currstate(a6),d0
         movem.l (sp)+,a5/a6
         rts
first:   moveq #32,d0               ;vswr_mode
         move.l #$00010001,contrl+6
         move #1,intin              ;REPLACE-Modus
         bsr vdi
         movem pb_x(a6),d0/d1
         subq #1,d0
         subq #1,d1
         movem d0/d1,(a5)
         movem d0/d1,16(a5)
         addq #1,d0
         add pb_w(a6),d0
         movem d0/d1,4(a5)
         addq #1,d1
         add pb_h(a6),d1
         movem d0/d1,8(a5)
         subq #1,d0
         sub pb_w(a6),d0
         movem d0/d1,12(a5)
         move #5,contrl+2
         moveq #6,d0                ;v_pline
         bsr vdi                    ;Rahmen zeichnen
         move.l pb_parm(a6),a4      ;Pointer auf String
         moveq #-1,d1
len:     addq #1,d1
         tst.b (a4,d1)              ;StringlÑnge ermitteln
         bne len
         mulu hwchar,d1             ;ergibt Stringbreite in Pixeln
         move pb_w(a6),d0
         sub d1,d0
         lsr #1,d0
         add pb_x(a6),d0
         move pb_y(a6),d1
         addq #1,d1
         movem d0/d1,(a5)           ;zentrierte Koordinaten eintragen
         move hhchar,d0
         lsr #1,d0
         add d0,2(a5)
         lsr #1,d0
         add d0,2(a5)               ;dto
         lea intin,a1
         clr d0
         moveq #-1,d1
lop:     addq #1,d1
         move.b (a4)+,d0
         move d0,(a1)+
         tst.b d0                   ;markiertes Zeichen erreicht?
         bpl lop                    ;nein-
         tst d1                     ;markiertes Zeichen erstes Zeichen?
         beq.s cont                 ;ja-
         moveq #0,d0                ;Zeichen normal
         bsr.s gtext                ;bis zum markierten Zeichen ausgeben
cont:    move.b -1(a4),d0
         and #$7f,d0                ;Bit 7 lîschen, ergibt ASCII-Code
         move d0,intin
         moveq #1,d1                ;ein Zeichen ausgeben
         moveq #8,d0                ;Zeichen unterstrichen
         bsr.s gtext                ;markiertes Zeichen ausgeben
         lea intin,a1
         clr d0
         moveq #-1,d1
.loop1:  addq #1,d1
         move.b (a4)+,d0
         move d0,(a1)+
         bne.s .loop1               ;Stringende suchen
         tst d1                     ;folgen noch Zeichen?
         beq.s no                   ;nein-
         moveq #0,d0                ;Zeichen normal
         bsr.s gtext                ;restliche Zeichen ausgeben
no:      move pb_currstate(a6),d0
         movem.l (sp)+,a5/a6
         rts

*Text ausgeben
gtext:
         move d1,-(sp)              ;StringlÑnge
         move intin,-(sp)
         move d0,intin              ;Texteffekt
         move.l #$00010001,contrl+6
         moveq #106,d0              ;vst_effects
         bsr.s vdi
         move (sp)+,intin
         move (sp),contrl+6
         move #1,contrl+2
         moveq #8,d0                ;v_gtext
         bsr.s vdi
         move (sp)+,d0
         mulu #8,d0
         add d0,(a5)                ;nÑchste Zeichenposition merken
         rts

*AES aufrufen
aesobj:
         move.l a0,addrin
aes:     lea contrl,a0
         move d0,(a0)
         movep.l d1,3(a0)
         move.l #aespb,d1
         move #$c8,d0
         trap #2
         tst (a6)
         rts

*VDI aufrufen
vdi:
         move vdi_h,contrl+12
vdiinit: move d0,contrl
         move.l #vdipb,d1
         moveq #$73,d0
         trap #2
         rts

*Warnton ausgeben
bell:
         move #$07,-(sp)            ;BEL
         move #2,-(sp)
         move #BCONOUT,-(sp)
         trap #BIOS                 ;Warnton ausgeben
         addq.l #6,sp
         rts


aespb:   dc.l contrl,global,intin,intout,addrin,addrout

vdipb:   dc.l contrl,intin,ptsin,intout,ptsout

*---------------------------------------------------------------------------*

BOX      = 20
TEXT     = 21
BOXTEXT  = 22
IMAGE    = 23
USERDEF  = 24
IBOX     = 25
BUTTON   = 26
BOXCHAR  = 27
STRING   = 28
FTEXT    = 29
FBOXTEXT = 30
ICON     = 31
TITLE    = 32


objc000:.dc.w $ffff
        .dc.w $0001,$0004
        .dc.w BOX
        .dc.w $0000,$0010
        .dc.l $00021100
        .dc.w $000a,$0003
        .dc.w $0022,$0005

        .dc.w $0002
        .dc.w $ffff,$ffff
        .dc.w $781a
        .dc.w $0411,$0001
        .dc.l spec000           ;"Radiobutton ±"
        .dc.w $0002,$0001
        .dc.w $000f,$0001

        .dc.w $0003
        .dc.w $ffff,$ffff
        .dc.w $791a
        .dc.w $0411,$0000
        .dc.l spec001           ;"Radiobutton ≤"
        .dc.w $0012,$0001
        .dc.w $000e,$0001

        .dc.w $0004
        .dc.w $ffff,$ffff
        .dc.w BUTTON
        .dc.w $0007,$0000
        .dc.l spec002           ;"OK"
        .dc.w $0008,$0003
        .dc.w $0009,$0001

        .dc.w $0000
        .dc.w $ffff,$ffff
        .dc.w $611a
        .dc.w $0025,$0000
        .dc.l spec003           ;"ABBRUCH"
        .dc.w $0012,$0003
        .dc.w $0009,$0001

spec000:.dc.b "Radiobutton ±",0

spec001:.dc.b "Radiobutton ≤",0

spec002:.dc.b "OK",0

spec003:.dc.b "ABBRUCH",0



*****************************
* Konvertiert durch RSCCONV *
*     Autor: Uwe Seimet     *
*      (C) 1989 by CCD      *
*****************************

*Gesamtzahl an Objekten: 0005
*ObjektbÑume: 0001
*Tedinfos: 0000
*Icons: 0000
*Bitblîcke: 0000

*freie Strings: 0000
*freie Images: 0000

_objcnr  equ 0005

*---------------------------------------------------------------------------*

         bss

*die obligatorischen GEM-Arrays

contrl:  ds.w 11

global:  ds.w 15

intin:   ds.w 64

ptsin:   ds.w 64

intout:  ds.w 64

ptsout:  ds.w 64

addrin:  ds.w 64

addrout: ds.w 64

vdi_h:   ds.w 1   ;VDI-Handle

hwchar:  ds.w 1   ;Zeichenbreite in Pixeln

hhchar:  ds.w 1   ;Zeichenhîhe in Pixeln

deskxy:  ds.l 1
deskwh:  ds.l 1   ;Breite und Hîhe des Desktop

xywh:    ds.l 2   ;Grîûe der aktuellen Dialogbox

ev_buff: ds.w 8   ;Message-Puffer

mfdb:    ds.w 18  ;Memory Form Descriptor Block

buffer:  ds.l 4   ;Puffer fÅr USERBLK-Struktur von zwei Buttons

stack:   ds.l 100 ;fÅr eigenen Stack

