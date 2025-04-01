****************************
* FILEINFO V1.00, 				 *
* (C) Uwe Seimet           *
* Buchenlochstraûe 29      *
* 6750 Kaiserslautern      *
* Telefon: 0631/21237      *
* (c) 1992 MAXON Computer  *
****************************


*GEMDOS-Konstanten
GEMDOS  =  1
OPEN    = $3d
CLOSE   = $3e
CHMOD   = $43
RENAME  = $56
GSDTOF  = $57

*Wichtige Objektindices
NAME    =  6
OK      = 14


        text

        lea stack+400,sp        ;Stackpointer initialisieren
        move.l #"\*.*",inpath   ;Pfad fÅr Disk
        lea intin,a5            ;Pointer auf INTIN-Array
        lea intout,a6           ;Pointer auf INTOUT-Array
        moveq #10,d0            ;appl_init
        move.l #$00010000,d1
        bsr aes
        move (a6),d4            ;apid_nr merken
        move #18,(a5)           ;19 Objekte
fix:    moveq #114,d0           ;rsrc_obfix
        move.l #$01010100,d1
        bsr aesobj              ;Koordinaten auf Auflîsung umrechnen
        subq #1,(a5)            
        bpl fix                 ;nÑchstes Objekt
        moveq #77,d0            ;graf_handle
        move.l #$00050000,d1
        bsr aes
        move (a6),phys_h        ;phys_handle merken
        moveq #35,d0            ;menu_register
        move.l #$01010100,d1
        move d4,(a5)
        lea name(pc),a0         ;Accessory-Name
        bsr aes                 ;in MenÅleiste eintragen
        move (a6),nr            ;Nummer des Eintrags merken
*Warteschleife
doacc:  moveq #23,d0            ;evnt_mesag
        move.l #$00010100,d1
        lea ev_buff,a3          ;Puffer fÅr GEM-Messages
        move.l a3,a0
        bsr aes
        cmp #40,(a3)            ;AC_OPEN?
        bne doacc               ;nein-
        move nr,d0
        cmp 8(a3),d0            ;Programm angeklickt?
        bne doacc               ;nein-
        bsr.s act               ;Dialog ausfÅhren
        bra doacc               ;weiter in Warteschleife

*Dialog mit dem Benutzer
act:
        move.l a5,a0            ;Pointer auf INTIN-Array
        moveq #9,d0
opn:    move #1,(a0)+           ;Parameter fÅr OPEN VIRTUAL WORKSTATION
        dbf d0,opn
        move #2,(a0)
        moveq #100,d0           ;v_opnvwk
        lea contrl+2,a4
        clr.l (a4)+
        move #11,(a4)
        move phys_h,vdi_h
        bsr vdi
        move 6(a4),vdi_h        ;vdi_handle merken

        moveq #90,d0            ;fsel_input
        move.l #$00020200,d1
        move.l #insel,addrin+4
        lea inpath,a0
        bsr aes                 ;Eingabe des Filenamens
        tst 2(a6)               ;Abbruch?
        beq exit                ;ja-
        moveq #2,d0             ;Biene als Mauscursor
        bsr mouse
        lea inpath,a0           ;Pointer auf Pfad
        lea nam,a1              ;Pointer auf alten Filenamen
        lea nnam,a2             ;Pointer auf neuen Filenamen
tpat:   move.b (a0)+,d0
        move.b d0,(a1)+         ;Pfadnamen kopieren
        move.b d0,(a2)+
        bne tpat
tpat1:  cmp.l #nam,a1
        bcs exit
        subq.l #1,a2
        cmp.b #"\",-(a1)
        bne tpat1
        addq.l #1,a1
        addq.l #1,a2
        move.l a2,newnam        ;Pointer auf Beginn des neuen Namens
        lea insel,a0
        lea filnam(pc),a2
        moveq #10,d0
filspc: move.b #" ",(a2)+       ;Bereich fÅr Filenamen lîschen
        dbf d0,filspc
        lea filnam(pc),a2
tsel:   move.b (a0)+,d0         ;Pfad- und Filenamen zusammensetzen
        cmp.b #".",d0
        bne.s tsel1
        lea filnam+8(pc),a2
        bra.s tsel2
tsel1:  move.b d0,(a2)+
tsel2:  move.b d0,(a1)+
        bne.s tsel

        clr.l -(sp)             ;Attribut ermitteln
        pea nam
        move #CHMOD,-(sp)
        trap #GEMDOS
        add #10,sp
        tst d0                  ;alles klar?
        bmi exit                ;dummerweise nicht-
        lea flg1+3(pc),a0       ;Pointer auf
        lea flg2+3(pc),a1       ;Radio-Buttons
        btst #0,d0              ;Read Only?
        bne.s ro                ;ja-
        exg.l a0,a1
ro:     bclr #0,(a0)            ;Buttons deselektieren
        bset #0,(a1)            ;bzw. selektieren
        lea flg3+3(pc),a0
        lea flg4+3(pc),a1
        btst #1,d0              ;versteckt?
        bne.s hidden            ;ja-
        exg.l a0,a1
hidden: bclr #0,(a0)
        bset #0,(a1)
        lea flg5+3(pc),a0
        lea flg6+3(pc),a1
        btst #2,d0              ;System-File?
        bne.s system            ;ja-
        exg.l a0,a1
system: bclr #0,(a0)
        bset #0,(a1)

        clr -(sp)
        pea nam
        move #OPEN,-(sp)        ;Datei muû vor GSDTOF
        trap #GEMDOS            ;erst geîffnet werden
        addq.l #8,sp
        move.l d0,d6            ;Fehler beim ôffnen?
        bmi exit                ;ja-
        clr -(sp)               ;Flag fÅr Datum und Zeit ermitteln
        move d6,-(sp)
        pea dati                ;Puffer fÅr Datum und Zeit
        move #GSDTOF,-(sp)
        trap #GEMDOS
        add #10,sp
        clr.l d1
        move dati,d1            ;Zeit holen
        lsr #5,d1               ;Sekundenbits rausschieben
        move.l d1,d0
        and #%111111,d0         ;Minuten isolieren
        divu #10,d0
        add.b #"0",d0           ;und nach ASCII wandeln
        lea time(pc),a0
        move.b d0,2(a0)
        swap d0
        add.b #"0",d0
        move.b d0,3(a0)
        lsr #6,d1               ;Stunden isolieren
        divu #10,d1
        add.b #"0",d1
        move.b d1,(a0)+
        swap d1
        add.b #"0",d1
        move.b d1,(a0)
        clr.l d1
        move dati+2,d1          ;Datum holen
        move.l d1,d0
        and #%11111,d0          ;Tag
        divu #10,d0
        add.b #"0",d0
        lea date(pc),a0
        move.b d0,(a0)+
        swap d0
        add.b #"0",d0
        move.b d0,(a0)+
        lsr #5,d1
        move.l d1,d0
        and #%1111,d0           ;Monat
        divu #10,d0
        add.b #"0",d0
        move.b d0,(a0)+
        swap d0
        add.b #"0",d0
        move.b d0,(a0)+
        lsr #4,d1               ;Jahr
        add #80,d1
        cmp #100,d1             ;falls im Jahr 2000 oder spÑter erstellt
        bcs.s ovr               ;(man kann ja nie wissen)
        sub #100,d1
ovr:    divu #10,d1
        add.b #"0",d1
        move.b d1,(a0)+
        swap d1
        add.b #"0",d1
        move.b d1,(a0)

        moveq #107,d0           ;wind_update
        move.l #$01010000,d1
        move #1,(a5)
        bsr aes
        moveq #54,d0            ;form_center
        move.l #$00050100,d1
        bsr aesobj
        movem.l 2(a6),a3/a4     ;form_xy und form_wh merken
        clr d2                  ;Bildschirmspeicher reservieren
        movem.l a3/a4,2(a5)
        bsr form_dial
        moveq #42,d0            ;objc_draw
        move.l #$06010100,d1
        move.l #$00000002,(a5)
        move.l 2(a6),4(a5)
        move.l 6(a6),8(a5)
        bsr aesobj              ;Dialogbox darstellen
        clr d0                  ;Pfeil als Mauscursor
        bsr mouse
        moveq #50,d0            ;form_do
        move.l #$01010101,d1
        move #NAME,(a5)         ;Eingabefeld
        bsr aesobj              ;Dialog starten
        move (a6),d7
        bclr #15,d7             ;Bit fÅr Doppelklick lîschen
        cmp #OK,d7              ;OK-Button angewÑhlt?
        bne break               ;nein-keine énderung vornehmen

        lea date(pc),a0
        clr d0
        move.b 4(a0),d0
        sub.b #"0",d0
        mulu #10,d0
        sub.b #"0",d0
        add.b 5(a0),d0
        sub #80,d0
        move d0,d1
        asl #4,d1               ;Jahr
        clr d0
        move.b 2(a0),d0
        sub.b #"0",d0
        mulu #10,d0
        sub.b #"0",d0
        add.b 3(a0),d0
        or d0,d1
        asl #5,d1               ;Monat
        clr d0
        move.b (a0)+,d0
        sub.b #"0",d0
        mulu #10,d0
        sub.b #"0",d0
        add.b (a0),d0
        or d0,d1                ;Tag
        move d1,dati+2          ;Datum merken
        lea time(pc),a0
        clr d0
        move.b (a0)+,d0
        sub.b #"0",d0
        mulu #10,d0
        sub.b #"0",d0
        add.b (a0)+,d0
        move d0,d1
        asl #6,d1               ;Stunden
        clr d0
        move.b (a0)+,d0
        sub.b #"0",d0
        mulu #10,d0
        sub.b #"0",d0
        add.b (a0),d0
        or d0,d1                ;Minuten
        asl #5,d1
        move d1,dati            ;Zeit merken

        move #1,-(sp)           ;Datum und Zeit setzen
        move d6,-(sp)
        pea dati
        move #GSDTOF,-(sp)
        trap #GEMDOS
        add #10,sp

        clr d0
        btst #0,flg2+3          ;Read Only?
        beq.s ro1               ;nein-
        bset #0,d0
ro1:    btst #0,flg4+3          ;versteckt?
        beq.s hidden1           ;nein-
        bset #1,d0
hidden1:btst #0,flg6+3          ;System-File?
        beq.s system1           ;nein-
        bset #2,d0
system1:move d0,-(sp)
        move #1,-(sp)
        pea nam
        move #CHMOD,-(sp)
        trap #GEMDOS            ;neue Attribute setzen
        add #10,sp

        move.l newnam,a1
        lea filnam(pc),a0
        moveq #7,d0
copnew: move.b (a0)+,d1
        cmp.b #" ",d1
        beq.s copn2
        move.b d1,(a1)+         ;neuen Filenamen zusammensetzen
        beq.s copn1
        dbf d0,copnew
        bra.s copn3
copn2:  add.l d0,a0
copn3:  move.b #".",(a1)+
copnew1:move.b (a0)+,(a1)+
        bne copnew1
copn1:  pea nnam                ;neuer Name
        pea nam                 ;alter Name
        clr -(sp)
        move #RENAME,-(sp)
        trap #GEMDOS            ;Datei umbenennen
        add #12,sp

break:  moveq #3,d2             ;Bildschirmspeicher wieder freigeben
        movem.l a3/a4,2(a5)
        bsr.s fo_dial
        moveq #47,d0            ;objc_change
        move.l #$08010100,d1
        move.l a5,a0
        move d7,(a0)+
        clr (a0)+
        movem.l a3/a4,(a0)
        clr.l 12(a5)
        bsr.s aesobj            ;ausgewÑhlten Button wieder deselektieren
        move d7,-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS            ;das war's
        addq.l #4,sp
        moveq #107,d0           ;wind_update
        move.l #$01010000,d1
        clr (a5)
        bsr.s aes

exit:
        clr d0                  ;Pfeil als Mauscursor
        bsr.s mouse
        moveq #101,d0           ;v_clsvwk
vdi:    lea contrl,a0
        move vdi_h,12(a0)       ;vdi_handle
        move d0,(a0)            ;Funktionsnummer
        move.l #vdipb,d1
        moveq #$73,d0           ;VDI
        trap #2                 ;aufrufen
        rts

*Mausform auswÑhlen
mouse:
        move d0,(a5)            ;Mausform festlegen
        moveq #78,d0            ;graf_mouse
        move.l #$01010100,d1
        bra.s aes

fo_dial:
        movem.l a3/a4,10(a5)
form_dial:
        moveq #51,d0            ;form_dial
        move.l #$09010100,d1
        move d2,(a5)

aesobj:
        lea _objcdat(pc),a0
aes:
        move.l a0,addrin        ;Objekt-Adresse
        lea contrl,a0           ;Pointer auf CONTRL-Array
        move d0,(a0)            ;Befehlsnummer
        movep.l d1,3(a0)        ;Parameter in Array Åbertragen
        move.l #aespb,d1
        move #$c8,d0            ;AES
        trap #2                 ;aufrufen
        rts


name:   dc.b "  Fileinfo",0     ;Name des MenÅeintrags


        even

*--------------------
*Objektdaten fÅr die Dialogbox
_objcdat:

        dc.w $ffff
        dc.w $0001,$0012
        dc.w $0014
        dc.w $0000,$0010
        dc.l $00021100
        dc.w $0006,$0001
        dc.w $0028,$0012

        dc.w $0002
        dc.w $ffff,$ffff
        dc.w $001c
        dc.w $0000,$0011
        dc.l spec000
        dc.w $000c,$0001
        dc.w $0010,$0001

        dc.w $0003
        dc.w $ffff,$ffff
        dc.w $0015
        dc.w $0000,$0000
        dc.l spec001
        dc.w $000c,$0003
        dc.w $0410,$0001

        dc.w $0004
        dc.w $ffff,$ffff
        dc.w $0015
        dc.w $0000,$0000
        dc.l spec002
        dc.w $000d,$0004
        dc.w $020e,$0001

        dc.w $0005
        dc.w $ffff,$ffff
        dc.w $0015
        dc.w $0000,$0000
        dc.l spec003
        dc.w $000d,$0005
        dc.w $020e,$0001

        dc.w $0006
        dc.w $ffff,$ffff
        dc.w $0015
        dc.w $0000,$0000
        dc.l spec004
        dc.w $000d,$0006
        dc.w $020e,$0001

        dc.w $0007
        dc.w $ffff,$ffff
        dc.w $001d
        dc.w $0008,$0000
        dc.l spec005
        dc.w $000a,$0008
        dc.w $0016,$0001

        dc.w $0008
        dc.w $ffff,$ffff
        dc.w $001d
        dc.w $0008,$0000
        dc.l spec006
        dc.w $0002,$0009
        dc.w $001a,$0001

        dc.w $0009
        dc.w $ffff,$ffff
        dc.w $001d
        dc.w $0008,$0000
        dc.l spec007
        dc.w $0003,$000a
        dc.w $0016,$0001

        dc.w $000a
        dc.w $ffff,$ffff
        dc.w $001a
flg1:   dc.w $0011,$0000
        dc.l spec008
        dc.w $0002,$000c
        dc.w $000b,$0001

        dc.w $000b
        dc.w $ffff,$ffff
        dc.w $001a
flg2:   dc.w $0011,$0000
        dc.l spec009
        dc.w $000e,$000c
        dc.w $000b,$0001

        dc.w $000e
        dc.w $000c,$000d
        dc.w $0019
        dc.w $0000,$0000
        dc.l $00001100
        dc.w $0002,$000e
        dc.w $0017,$0001

        dc.w $000d
        dc.w $ffff,$ffff
        dc.w $001a
flg3:   dc.w $0011,$0000
        dc.l spec010
        dc.w $0000,$0000
        dc.w $000b,$0001

        dc.w $000b
        dc.w $ffff,$ffff
        dc.w $001a
flg4:   dc.w $0011,$0000
        dc.l spec011
        dc.w $000c,$0000
        dc.w $000b,$0001

        dc.w $000f
        dc.w $ffff,$ffff
        dc.w $001a
        dc.w $0007,$0000
        dc.l spec012
        dc.w $001e,$000e
        dc.w $0008,$0001

        dc.w $0012
        dc.w $0010,$0011
        dc.w $0019
        dc.w $0000,$0000
        dc.l $00001100
        dc.w $0002,$0010
        dc.w $0017,$0001

        dc.w $0011
        dc.w $ffff,$ffff
        dc.w $001a
flg5:   dc.w $0011,$0000
        dc.l spec013
        dc.w $0000,$0000
        dc.w $000b,$0001

        dc.w $000f
        dc.w $ffff,$ffff
        dc.w $001a
flg6:   dc.w $0011,$0000
        dc.l spec014
        dc.w $000c,$0000
        dc.w $000b,$0001

        dc.w $0000
        dc.w $ffff,$ffff
        dc.w $001a
        dc.w $0025,$0000
        dc.l spec015
        dc.w $001e,$0010
        dc.w $0008,$0001

spec000:dc.b ' FILEINFO V1.00 ',0

spec001:dc.l spec001+$001c,spec001+$0033,spec001+$0034
        dc.w $0005
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $0017,$0001
        dc.b '(C) 1987 by Uwe Seimet',0
        dc.b 0
        dc.b 0

spec002:dc.l spec002+$001c,spec002+$0030,spec002+$0031
        dc.w $0005
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $0014,$0001
        dc.b 'Buchenlochstraûe 29',0
        dc.b 0
        dc.b 0

spec003:dc.l spec003+$001c,spec003+$0030,spec003+$0031
        dc.w $0005
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $0014,$0001
        dc.b '6750 Kaiserslautern',0
        dc.b 0
        dc.b 0

spec004:dc.l spec004+$001c,spec004+$0030,spec004+$0031
        dc.w $0005
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $0014,$0001
        dc.b 'Telefon: 0631/21237',0
        dc.b 0
        dc.b 0

spec005:dc.l spec005+$001c,spec005+$0028,spec005+$003f
        dc.w $0003
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $000c,$0017
filnam: dc.b 'FILENAMEEXT',0
        dc.b 'Filename: ________.___',0
        dc.b 'ppppppppppp',0

spec006:dc.l spec006+$001c,spec006+$0023,spec006+$003e
        dc.w $0003
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $0007,$001b
date:   dc.b '000000',0
        dc.b 'Erstellungsdatum: __.__.__',0
        dc.b '999999',0

spec007:dc.l spec007+$001c,spec007+$0021,spec007+$0038
        dc.w $0003
        dc.w $0006
        dc.w $0000
        dc.w $1180
        dc.w $0000
        dc.w $ffff
        dc.w $0005,$0017
time:   dc.b '0000',0
        dc.b 'Erstellungszeit: __:__',0
        dc.b '9999',0

spec008:dc.b 'Read/Write',0

spec009:dc.b 'Read Only',0

spec010:dc.b 'Sichtbar',0

spec011:dc.b 'Versteckt',0

spec012:dc.b 'OK',0

spec013:dc.b 'Normal',0

spec014:dc.b 'System',0

spec015:dc.b 'ABBRUCH',0
*--------------------

        data

aespb:  dc.l contrl,global,intin,intout,addrin,addrout

vdipb:  dc.l contrl,intin,ptsin,intout,ptsout


        bss

*Speicherbereiche fÅr VDI und AES
contrl: ds 11

global: ds 15

intin:  ds 64

ptsin:  ds 64

intout: ds 64

ptsout: ds 64

addrin: ds 64

addrout:ds 64

phys_h: ds 1

vdi_h:  ds 1

nr:     ds 1            ;Nummer des Accessory-Eintrags

ev_buff:ds 8            ;Puffer fÅr GEM-Mitteilungen

dati:   ds 2            ;Puffer fÅr Datum und Zeit

newnam: ds.l 1          ;Pointer auf neuen Dateinamen

        even

inpath: ds.b 40         ;Pfad fÅr Fileselector

insel:  ds.b 13         ;Dateiname fÅr Fileselector

nam:    ds.b 52         ;kompletter alter Name der Datei

nnam:   ds.b 52         ;kompletter neuer Name der Datei

        even

stack:  ds.l 100        ;fÅr Stack
