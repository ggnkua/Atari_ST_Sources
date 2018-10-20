**************************************
* RAM-Disk fuer Atari ST             *
* by Peter Wollschlaeger, Hildesheim *
**************************************

gemdos          EQU 1                   ;gemdos trap
keep            EQU $31                 ;ret & keep mem

xbios           EQU 14                  ;xbios trap
super           EQU 38                  ;exec in supervr-mode

* hdv_ = hard disk vektor:
hdv_bpb         EQU $0472               ;get bios parameter block
hdv_rw          EQU $0476               ;read/write abs
hdv_mediach     EQU $047E               ;media changed
drvbits         EQU $04C2               ;bit map active drvnames


*
* start here
*

start:
                move.l  #64,D3          ;Groesse der RAMDISK in KByte


* RAM-Disk einrichten
* ===================

* Tracks 0,1 loeschen
* -------------------
                lea     ramdisk(PC),A0
                move.w  #18*512/4-1,D0  ;2 Tracks in Langworten
Dloop:          clr.l   (A0)+           ;mit Nullen laden
                dbra    D0,Dloop

* Boot-Sektor schreiben
* ---------------------
                lea     ramdisk+11(PC),A0 ;0..10 ist schon 0
                lea     bootsec(PC),A1
                move.w  #seclen-1,D0
bloop:          move.b  (A1)+,(A0)+     ;Tabelle kopieren
                dbra    D0,bloop
                move.w  D3,numcl        ;Groesse der Disk in K
                move.w  D3,D2           ;retten

* Anzahl Sektoren ermitteln und eintragen
* ---------------------------------------
                lsl.w   #1,D3           ;*2=Groesse in Sektoren
                add.w   #18,D3          ;+18 fuer das Management
                lea     ramdisk+19(PC),A0 ;=Gesamt Sektoren
                move.b  D3,(A0)+        ;LSByte im 8086-
                lsl.w   #8,D3           ;Format
                move.b  D3,(A0)         ;MSByte eintragen

* Speicherbedarf ermitteln
* ------------------------
                moveq   #10,D0          ;*1024 vorbereiten
                lsl.l   D0,D2           ;Groesse in Bytes rechnen
                movea.l 4(SP),A0        ;    Zeiger auf Base Page
                add.l   12(A0),D2       ;+ Laenge Text
                add.l   20(A0),D2       ;+ Laenge Data
                add.l   28(A0),D2       ;+ Laenge BSS
                add.l   #$0100,D2       ;+ Laenge Base Page
;= Gesamtbedarf

* in Supervisor-Mode gehen, da Zugriff auf System-Vars.
* -----------------------------------------------------
                pea     patch(PC)       ;Adr. Patch-Routine
                move.w  #super,-(SP)
                trap    #xbios
                addq.l  #6,SP

* return -> Desktop, Speicher behalten
* ------------------------------------
conin:
                clr.w   -(SP)
                move.l  D2,-(SP)        ;Speicherbedarf
                move.w  #keep,-(SP)     ;anmelden
                trap    #gemdos         ;und Return Desk / Caller

* Vektoren patchen und Drive eintragen
* ------------------------------------
patch:          move.l  hdv_bpb,old_bpb ;getbpb-Vektor retten
                move.l  #new_bpb,hdv_bpb ;dann patchen

                move.l  hdv_rw,old_rw   ;dto. rw-Vektor
                move.l  #new_rw,hdv_rw

                move.l  hdv_mediach,old_med ;dto. media-change-Vektor
                move.l  #new_med,hdv_mediach

* Drive suchen/setzen
* -------------------
                move.l  drvbits,D0      ;get drive bits
                move.w  #0,D4           ;count=0
loop:           add.w   #1,D4
                btst    D4,D0           ;drive bit set?
                bne.s   loop
                move.w  D4,drive        ;Drive-Nummer merken
                add.w   #'A',D4         ; + 'A'
                move.w  D4,drvname      ; = Drive-Buchstabe
                move.b  D4,meldname     ;fr Screen-Ausgabe

;hier kann man noch testen, ob Drive OK.
;Tun wir nicht, also:
                lsl.l   #1,D0           ;1 Bit links mehr
                or.l    #1,D0           ;das rechte wieder auf 1
                move.l  D0,drvbits      ;nun aber!
;Meldung ausgeben
                lea     meldung(PC),A0  ;Adresse von Text holen
                move.l  A0,-(SP)        ;und auf Stack
                move.w  #9,-(SP)        ;PRTLIN
                trap    #1              ;GEMDOS
                addq.l  #6,SP           ;Stack korrigieren

; und tschž

                rts

* Die eigentlichen RAM-Disk-Routinen starten hier
* ===============================================

* get bpb: Wenn BIOS-Paramter Block angefordert wird
* -------
new_bpb:        move.w  4(SP),D4        ;Drive-Nummer holen
                cmp.w   drive(PC),D4    ;RAM-Disk?
                bne.s   notC1           ;wenn nicht
                move.l  #bpbtab,D0      ;return RAM-Disk's bpp
                rts
notC1:          movea.l old_bpb(PC),A0  ;alte Adresse holen
                jmp     (A0)            ;und dahin

* read/write sector: Wenn Disk-I/O angefordert wird
* -----------------
;Dies ist die BIOS-Funktion 4 sozusagen von der anderen
;Seite her gesehen. Auf dem Stack sind bei xx(sp):

rwflag          EQU 4                   ;Read/Write-Flag
bufadr          EQU 6                   ;Pufferadresse
seccnt          EQU 10                  ;Anzahl Sektoren
secno           EQU 12                  ;Sektor-Nummer
drvno           EQU 14                  ;Drive-Nummer

new_rw:         move.w  drvno(SP),D4
                cmp.w   drive(PC),D4    ;RAM-Disk?
                bne.s   notC2           ;if not

                movea.l bufadr(SP),A0   ;Adr. Sektor-Puffer
                move.w  secno(SP),D0    ; rel. Sektor-Nr.
                ext.l   D0              ;-> long
                move.w  #9,D1           ;*512
                lsl.l   D1,D0           ;=Offset in RAM-Disk
                lea     ramdisk(PC),A1  ;Start RAM-Disk
                adda.l  D0,A1           ;+ Offset
;= Adr. in RAM-Disk
                move.w  rwflag(SP),D0   ;Lesen oder Schreiben?
                btst    #0,D0           ;Lesen?
                beq.s   rdwrt           ;wenn so
                exg     A0,A1           ;nein:Ziel/Quelle tauschen

rdwrt:          move.w  seccnt(SP),D1   ;Sector Count
                subq.w  #1,D1           ;-1 wegen dbra
rwloop:         move.w  #127,D0         ;128 Longs=1 Sektor
rw1:            move.l  (A1)+,(A0)+     ;kopieren
                dbra    D0,rw1
                dbra    D1,rwloop       ;FOR Sector_Count
                moveq   #0,D0
                rts
notC2:          movea.l old_rw(PC),A0
                jmp     (A0)

* Media changed
* -------------
new_med:        move.w  4(SP),D4        ;Drive holen
                cmp.w   drive(PC),D4    ;RAM-Disk?
                bne.s   notC3
                clr.w   D0              ;RAM-Disk kann natuerlich
                rts                     ;nicht gewechselt werden
notC3:          movea.l old_med(PC),A0
                jmp     (A0)

                DATA
                EVEN

meldung:        DC.B 13,10,27,"pRAMDISK",32,$3A,32,27,"q"
meldname:       DS.B 1
                DC.B " installiert",13,10,0

drive:          DS.W 1
drvname:        DS.W 1

bpbtab:         DC.W $0200              ;Standard BPB
                DC.W 2
                DC.W $0400
                DC.W 7
                DC.W 5
                DC.W 6
                DC.W 18
numcl:          DS.W 1                  ;hierher Groesse RAM-Disk
                DS.W 8

bootsec:        DC.B 0,2                ;Boot-Sektor ab Byte $0B
                DC.B 2
                DC.B 1,0
                DC.B 2
                DC.B 112,0
                DS.B 2
                DC.B 0
                DC.B 5,0
                DC.B 9,0
                DC.B 1,0
                DC.B 0
seclen          EQU *-bootsec

                BSS
old_bpb:        DS.L 1
old_rw:         DS.L 1
old_med:        DS.L 1
ramdisk         EQU *

                END
