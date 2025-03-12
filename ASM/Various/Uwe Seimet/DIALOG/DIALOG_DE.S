********************************
*     neue form_do-Routine     *
*  mit erweiterten Funktionen  *
*        by Uwe Seimet         *
* (c) 1992 MAXON Computer GmbH *
******************************** 


*fÅr die wenigen Systemaufrufe
GEMDOS   = 1
MSHRINK  = 74
BIOS     = 13
BCONOUT  = 3


         move.l sp,a0
         lea stack+400,sp           ;Stackpointer initialisieren
         move.l 4(a0),a0            ;Pointer auf Basepage
         move.l 12(a0),a1           ;LÑnge des TEXT-Segments
         add.l 20(a0),a1            ;LÑnge des DATA-Segments
         add.l 28(a0),a1            ;LÑnge des BSS-Segments
         lea $100(a1),a1            ;256 Bytes fÅr die Basepage
         move.l a1,-(sp)
         move.l a0,-(sp)
         clr -(sp)
         move #MSHRINK,-(sp)
         trap #GEMDOS               ;nicht benîtigten Speicher zurÅckgeben
         lea 12(sp),sp
         tst.l d0                   ;Fehler?
         bne error                  ;ja-
         lea intin,a5               ;Pointer auf INTIN-Array
         lea intout,a6              ;Pointer auf INTOUT-Array
         moveq #10,d0               ;appl_init
         move.l #$00010000,d1
         bsr aes
         bmi.s error                ;Fehler-
         moveq #77,d0               ;graf_handle
         move.l #$00050000,d1
         bsr aes
         move.l a5,a0
         moveq #9,d0
.opn:    move #1,(a0)+
         dbra d0,.opn
         move #2,(a0)
         moveq #100,d0              ;v_opnvwk
         lea contrl+2,a3
         clr.l (a3)+
         move #11,(a3)
         move (a6),6(a3)            ;graf_handle
         bsr vdiinit
         move 6(a3),vdi_h           ;vdi_handle merken
         move #7,(a5)               ;Objektzahl eintragen
fix:     moveq #114,d0              ;rsrc_obfix
         move.l #$01010100,d1
         lea objc000(pc),a0         ;Adresse der Objektdaten
         bsr aesobj                 ;Koordinaten umrechnen
         subq #1,(a5)
         bpl fix                    ;nÑchstes Objekt, falls vorhanden
         clr (a5)                   ;Pfeil als Mauscursor
         moveq #78,d0               ;graf_mouse
         move.l #$01010100,d1
         bsr aes
         lea objc000(pc),a4         ;Adresse der Dialogbox
         moveq #2,d4                ;Nummer des ersten Eingabefeldes
         bsr.s form_do              ;Dialog ausfÅhren
         moveq #19,d0               ;appl_exit
         move.l #$00010000,d1
         bsr aes
error:   clr -(sp)                  ;das war's
         trap #GEMDOS

form_do:
         moveq #54,d0               ;form_center
         move.l #$00050100,d1
         move.l a4,a0
         bsr aesobj
         movem.l 2(a6),d5/d6        ;form_xy und form_wh
         clr d2                     ;FMD_START
         movem.l d5/d6,2(a5)
         movem.l d5/d6,10(a5)
         bsr.s form_dial
         moveq #1,d0                ;bis zu Ebene 1 zeichnen
         move.l d0,(a5)
         movem.l d5/d6,4(a5)
         moveq #42,d0               ;objc_draw
         move.l #$06010100,d1
         move.l a4,a0
         bsr aesobj                 ;Dialogbox darstellen
         bsr.s _form_do             ;zur neuen Dialogroutine
         moveq #3,d2                ;FMD_FINISH
         movem.l d5/d6,2(a5)
         movem.l d5/d6,10(a5)
form_dial:
         moveq #51,d0               ;form_dial
         move.l #$09010100,d1
         move d2,(a5)
         bra aes

*neue form_do-Routine, Exit-Button wird in D7 zurÅckgeliefert
_form_do:
         moveq #1,d0                ;Cursor einschalten
         bsr objcedit
         move 2(a6),d3              ;Position des Cursors
dloop:   move #1,2(a5)              ;warten auf einen Mausklick
         move #1,4(a5)              ;auf linken Mausbutton warten
         move #1,6(a5)              ;gedrÅckter Mausbutton
         moveq #25,d0               ;evnt_multi
         move.l #$10070100,d1
         move #3,(a5)               ;MU_KEYBD|MU_BUTTON
         lea ev_buff,a0
         bsr aesobj                 ;Benutzeraktion abwarten
         btst #1,1(a6)              ;MU_BUTTON?
         bne.s button               ;ja-
         move 10(a6),d0             ;Scan- und ASCII-Code der Taste
         tst.b d0                   ;ASCII-Zeichen?
         bne.s noalt                ;ja-
         lsr #8,d0                  ;Scancode ins low Byte
         move.l a4,a0
uloop:   cmp.b 6(a0),d0             ;Button fÅr gedrÅckte Taste gefunden?
         beq.s default              ;ja-
         tst (a0)                   ;letztes Objekt im Baum erreicht?
         beq.s noalt                ;ja-
         lea 24(a0),a0              ;nÑchstes Objekt prÅfen
         bra uloop
default: sub.l a4,a0
         move.l a0,d7
         divu #24,d7                ;ergibt Objektnummer
         move #1,12(a6)             ;fÅr Simulation eines Mausklicks
         bra.s obj
noalt:   move 10(a6),2(a5)          ;eingegebenes Zeichen
         move d4,(a5)               ;aktuelles Eingabefeld
         clr 4(a5)
         moveq #55,d0               ;form_keybd
         move.l #$03030100,d1
         move.l a4,a0
         bsr aesobj
         move 2(a6),d7              ;neues Eingabefeld
         tst (a6)                   ;Exit-Objekt betÑtigt?
         beq exit                   ;ja-
         tst 4(a6)                  ;Wechsel des Eingabefeldes?
         beq.s newinput             ;ja-
         move 10(a6),2(a5)          ;eingegebenes Zeichen
         move d3,4(a5)              ;aktuelle Cursorposition
         moveq #2,d0                ;Zeichen ausgeben
         bsr.s objcedit
         move 2(a6),d3              ;neue Cursorposition
         bra dloop
button:  clr (a5)
         move #1,2(a5)              ;bis Ebene 1 suchen
         move.l 2(a6),4(a5)         ;aktuelle Mausposition
         moveq #43,d0               ;objc_find
         move.l #$04010100,d1
         move.l a4,a0
         bsr.s aesobj
         move (a6),d7               ;Objektnummer
         bpl.s obj                  ;Objekt wurde gefunden-
         move #$07,-(sp)            ;BEL
         move #2,-(sp)
         move #BCONOUT,-(sp)
         trap #BIOS                 ;Glockenton als Fehlermeldung
         addq.l #6,sp
         bra dloop
obj:     moveq #56,d0               ;form_button
         move.l #$02020100,d1
         move d7,(a5)               ;angeklicktes Objekt
         move 12(a6),2(a5)          ;Anzahl der Mausklicks
         move.l a4,a0
         bsr.s aesobj
         tst (a6)                   ;wurde Exit-Objekt angeklickt?
         beq.s exit                 ;ja-
         move d7,d0
         mulu #24,d0
         btst #3,9(a4,d0)           ;Objekt editierbar?
         beq dloop                  ;nein-
         cmp d7,d4                  ;Wechsel des Eingabefeldes?
         beq dloop                  ;nein-
newinput:bsr.s exit                 ;Cursor abschalten
         move d7,d4                 ;neues Eingabefeld
         bra _form_do               ;Dialog fortfÅhren
exit:    move d3,4(a5)              ;Cursorposition
         moveq #3,d0
objcedit:move d4,(a5)               ;Nummer des Eingabefeldes
         move d0,6(a5)
         moveq #46,d0               ;objc_edit
         move.l #$04020100,d1
         move.l a4,a0
aesobj:  move.l a0,addrin
aes:     lea contrl,a0
         move d0,(a0)
         movep.l d1,3(a0)
         move.l #aespb,d1
         move #$c8,d0
         trap #2                    ;AES-Aufruf
         rts

vdi:     move vdi_h,contrl+12
vdiinit: move d0,contrl
         move.l #vdipb,d1
         moveq #$73,d0
         trap #2                    ;VDI-Aufruf
         rts

*Benutzerdefiniertes Objekt zeichnen
draw:
         move.l 4(sp),a0
         move.l 10(a0),d0           ;x/y-Koordinaten
         sub.l #$00030000,d0
         move.l d0,ptsin
         add.l #$00060000,d0
         add.l 14(a0),d0
         move.l d0,ptsin+4
         lea contrl,a0
         move.l #$02000000,d0
         movep.l d0,3(a0)
         move #8,contrl+10
         moveq #11,d0               ;v_rbox
         bsr vdi                    ;abgerundete Box zeichnen
         move.l 4(sp),a0
         move.l 26(a0),a1           ;Pointer auf Textstring
         lea intin,a2
         clr d0
         clr d1
.loop:   move.b (a1)+,d0
         beq.s .end
         move d0,(a2)+
         addq #1,d1
         bra .loop
.end:    move.l #$01000000,d0
         lea contrl,a1
         movep.l d0,3(a1)
         move d1,contrl+6
         move.l 10(a0),ptsin
         add #17,ptsin+2
         moveq #8,d0                ;v_gtext
         bra vdi

user:    dc.l draw
         dc.l spec000

*Daten fÅr die Dialogbox
*----------------------------------------------------------------------------
*verwendetet Objekttypen
BOX      = 20
BUTTON   = 26
STRING   = 24
FTEXT    = 29


objc000:.dc.w $ffff
        .dc.w $0001,$0007
        .dc.w BOX
        .dc.w $0000,$0010
        .dc.l $00021100
        .dc.w $0007,$0004
        .dc.w $002b,$000f

        .dc.w $0002
        .dc.w $ffff,$ffff
        .dc.w STRING
        .dc.w $0000,$0011
        .dc.l user              ;" Testdialog fÅr neue form_do-Routine"
        .dc.w $0003,$0001
        .dc.w $0025,$0801

        .dc.w $0003
        .dc.w $ffff,$ffff
        .dc.w FTEXT
        .dc.w $0008,$0000
        .dc.l spec001           ;"Eingabefeld 1: __________"
        .dc.w $0009,$0005
        .dc.w $0019,$0001

        .dc.w $0004
        .dc.w $ffff,$ffff
        .dc.w FTEXT
        .dc.w $0008,$0000
        .dc.l spec002           ;"Eingabefeld 2: __________"
        .dc.w $0009,$0007
        .dc.w $0019,$0001

        .dc.w $0005
        .dc.w $ffff,$ffff
        .dc.w $781a
        .dc.w $0011,$0001
        .dc.l spec003           ;"Radiobutton 1"
        .dc.w $0007,$000a
        .dc.w $000e,$0001

        .dc.w $0006
        .dc.w $ffff,$ffff
        .dc.w $791a
        .dc.w $0011,$0000
        .dc.l spec004           ;"Radiobutton 2"
        .dc.w $0016,$000a
        .dc.w $000e,$0001

        .dc.w $0007
        .dc.w $ffff,$ffff
        .dc.w BUTTON
        .dc.w $0007,$0000
        .dc.l spec005           ;"OK"
        .dc.w $000c,$000d
        .dc.w $0009,$0001

        .dc.w $0000
        .dc.w $ffff,$ffff
        .dc.w $611a
        .dc.w $0025,$0000
        .dc.l spec006           ;"ABBRUCH"
        .dc.w $0016,$000d
        .dc.w $0009,$0001

spec000:.dc.b " Testdialog fÅr neue form_do-Routine",0,0

spec001:.dc.l txt001,plt001,val001
        .dc.w $0003
        .dc.w $0006
        .dc.w $0000
        .dc.w $1180
        .dc.w $0000
        .dc.w $ffff
        .dc.w $000b,$001a
txt001: .dc.b "@         ",0
plt001: .dc.b "Eingabefeld 1: __________",0
val001: .dc.b "XXXXXXXXXX",0

spec002:.dc.l txt002,plt002,val002
        .dc.w $0003
        .dc.w $0006
        .dc.w $0000
        .dc.w $1180
        .dc.w $0000
        .dc.w $ffff
        .dc.w $000b,$001a
txt002: .dc.b "@         ",0
plt002: .dc.b "Eingabefeld 2: __________",0
val002: .dc.b "XXXXXXXXXX",0

spec003:.dc.b "Radiobutton 1",0

spec004:.dc.b "Radiobutton 2",0

spec005:.dc.b "OK",0

spec006:.dc.b "ABBRUCH",0

*****************************
* Konvertiert durch RSCCONV *
*     Autor: Uwe Seimet     *
*      (C) 1989 by CCD      *
*****************************

*----------------------------------------------------------------------------


         DATA

aespb:   dc.l contrl,global,intin,intout,addrin,addrout

vdipb:   dc.l contrl,intin,ptsin,intout,ptsout


         bss

*diverse AES- und VDI-Arrays

contrl:  ds.w 11

global:  ds.w 15

intin:   ds.w 64

intout:  ds.w 64

addrin:  ds.w 64

addrout: ds.w 64

ptsin:   ds.w 64

ptsout:  ds.w 64

ev_buff: ds.w 8   ;Puffer fÅr evnt_multi

vdi_h:   ds.w 1   ;VDI-Handle

         even

stack:   ds.l 100 ;eigener Stackbereich
