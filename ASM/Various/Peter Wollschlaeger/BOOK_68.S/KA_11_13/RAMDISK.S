**************************************
* RAM-Disk fuer Atari ST             *
* by Peter Wollschlaeger, Hildesheim *
**************************************

gemdos  equ     1               ;gemdos trap
keep    equ     $31             ;ret & keep mem

xbios   equ     14              ;xbios trap
super   equ     38              ;exec in supervr-mode

* hdv_ = hard disk vektor:
hdv_bpb equ     $472            ;get bios parameter block
hdv_rw  equ     $476            ;read/write abs
hdv_mediach equ $47e            ;media changed
drvbits equ     $4c2            ;bit map active drvnames


writes  macro                   ;write string
        pea     \1
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        endm

conin   macro                   ;get char -> d0
        move.w  #7,-(sp)
        trap    #1
        addq.l  #2,sp
        endm

conout  macro
        move.w  \1,-(sp)        ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        endm
*
* start here
*
start   writes  logo            ;Logo und Query ausgeben
        bra     ask           
redo    writes  beep            ;hierher falls Fehler
ask     conin                   
        cmpi    #'1',d0         ;teste '1'         
        bmi     redo            ;wenn kleiner
        cmpi    #'8',d0         ;teste '8'
        bgt     redo            ;wenn groesser

        move    d0,d3           ;Groesse der RAMDISK in 100 K
                                ;hier Konstante nach d3,
                                ;wenn kein Dialog
                                ;sonst hier weiter:
        move    d3,-(sp)        ;Antwort ausgeben
        move    #2,-(sp)        ;d.h. erste Ziffer
        trap    #1
        addq.l  #4,sp
        writes  prompt          ;und '00' + Frage ob OK
        conin
        bclr    #5,d0           ;force uppercase
        cmpi    #'A',d0         ;Abbruch
        bne     weiter          ;wenn nicht
        clr     -(sp)           ;sonst Return
        trap     #1             ;zum Desk
weiter  cmpi    #'J',d0         ;Wenn nun nicht J
        bne     start           ;noch einmal

ok      sub     #48,d3          ;'1'..'8' in 1..8
        ext.l   d3              ;
        mulu    #100,d3         ;und mal 100

* RAM-Disk einrichten
* ===================

* Tracks 0,1 loeschen
* -------------------
        lea     ramdisk,a0
        move    #18*512/4-1,d0  ;2 Tracks in Langworten
Dloop   clr.l   (a0)+           ;mit Nullen laden
        dbra    d0,Dloop

* Boot-Sektor schreiben
* ---------------------
        lea     ramdisk+11,a0   ;0..10 ist schon 0
        lea     bootsec,a1
        move    #seclen-1,d0
bloop   move.b  (a1)+,(a0)+     ;Tabelle kopieren
        dbra    d0,bloop
        move    d3,numcl        ;Groesse der Disk in K
        move    d3,d2           ;retten

* Anzahl Sektoren ermitteln und eintragen
* ---------------------------------------   
        lsl     #1,d3           ;*2=Groesse in Sektoren
        add     #18,d3          ;+18 fuer das Management
        lea     ramdisk+19,a0   ;=Gesamt Sektoren
        move.b  d3,(a0)+        ;LSByte im 8086-
        lsl     #8,d3           ;Format
        move.b  d3,(a0)         ;MSByte eintragen

* Speicherbedarf ermitteln
* ------------------------ 
        moveq   #10,d0          ;*1024 vorbereiten
        lsl.l   d0,d2           ;Groesse in Bytes rechnen
        move.l  4(sp),a0        ;    Zeiger auf Base Page
        add.l   12(a0),d2       ;+ Laenge Text
        add.l   20(a0),d2       ;+ Laenge Data 
        add.l   28(a0),d2       ;+ Laenge BSS
        add.l   #$100,d2        ;+ Laenge Base Page
                                ;= Gesamtbedarf

* in Supervisor-Mode gehen, da Zugriff auf System-Vars.                                   
* -----------------------------------------------------
        pea     patch          ;Adr. Patch-Routine
        move    #super,-(sp)   
        trap    #xbios
        addq.l  #6,sp

* return -> Desktop, Speicher behalten
* ------------------------------------
        writes  manual         ;Bedienungsanleitung,
        conout  drvname        ;Drive-Buchstaben und
        writes  manual1        ;und noch etwas Text
        conin                  ;auf Taste warten
        clr     -(sp)
        move.l  d2,-(sp)        ;Speicherbedarf
        move    #keep,-(sp)     ;anmelden
        trap    #gemdos         ;und Return Desk / Caller

* Vektoren patchen und Drive eintragen
* ------------------------------------
patch   move.l  hdv_bpb,old_bpb      ;getbpb-Vektor retten
        move.l  #new_bpb,hdv_bpb     ;dann patchen

        move.l  hdv_rw,old_rw        ;dto. rw-Vektor  
        move.l  #new_rw,hdv_rw

        move.l  hdv_mediach,old_med  ;dto. media-change-Vektor
        move.l  #new_med,hdv_mediach

* Drive suchen/setzen
* -------------------
        move.l   drvbits,d0          ;get drive bits        
        move     #0,d4               ;count=0
loop    add      #1,d4               
        btst     d4,d0               ;drive bit set?
        bne     loop
        move    d4,drive             ;Drive-Nummer merken
        add     #'A',d4              ; + 'A'
        move    d4,drvname           ; = Drive-Buchstabe
;hier kann man noch testen, ob Drive OK.
;Tun wir nicht, also:
        lsl.l   #1,d0                ;1 Bit links mehr
        or.l    #1,d0                ;das rechte wieder auf 1
        move.l  d0,drvbits           ;nun aber!
        rts

* Die eigentlichen RAM-Disk-Routinen starten hier
* ===============================================

* get bpb: Wenn BIOS-Paramter Block angefordert wird
* -------
new_bpb move    4(sp),d4        ;Drive-Nummer holen
        cmp     drive,d4        ;RAM-Disk?                
        bne     notC1           ;wenn nicht
        move.l  #bpbtab,d0      ;return RAM-Disk's bpp
        rts
notC1   move.l  old_bpb,a0      ;alte Adresse holen
        jmp     (a0)            ;und dahin

* read/write sector: Wenn Disk-I/O angefordert wird
* -----------------
;Dies ist die BIOS-Funktion 4 sozusagen von der anderen
;Seite her gesehen. Auf dem Stack sind bei xx(sp):

rwflag  equ     4               ;Read/Write-Flag
bufadr  equ     6               ;Pufferadresse
seccnt  equ     10              ;Anzahl Sektoren
secno   equ     12              ;Sektor-Nummer
drvno   equ     14              ;Drive-Nummer

new_rw  move    drvno(sp),d4 
        cmp     drive,d4        ;RAM-Disk?               
        bne     notC2           ;if not

        move.l  bufadr(sp),a0   ;Adr. Sektor-Puffer
        move    secno(sp),d0    ; rel. Sektor-Nr.
        ext.l   d0              ;-> long
        move    #9,d1           ;*512
        lsl.l   d1,d0           ;=Offset in RAM-Disk
        lea     ramdisk,a1      ;Start RAM-Disk
        add.l   d0,a1           ;+ Offset 
                                ;= Adr. in RAM-Disk
        move    rwflag(sp),d0   ;Lesen oder Schreiben?
        btst    #0,d0           ;Lesen?
        beq     rdwrt           ;wenn so
        exg     a0,a1           ;nein:Ziel/Quelle tauschen

rdwrt   move    seccnt(sp),d1   ;Sector Count
        subq    #1,d1           ;-1 wegen dbra
rwloop  move    #127,d0         ;128 Longs=1 Sektor
rw1     move.l  (a1)+,(a0)+     ;kopieren
        dbra    d0,rw1
        dbra    d1,rwloop       ;FOR Sector_Count
        moveq   #0,d0
        rts
notC2   move.l  old_rw,a0
        jmp     (a0)

* Media changed
* -------------
new_med move    4(sp),d4        ;Drive holen
        cmp     drive,d4        ;RAM-Disk?
        bne     notC3
        clr     d0              ;RAM-Disk kann natuerlich
        rts                     ;nicht gewechselt werden
notC3   move.l  old_med,a0 
        jmp     (a0)

        data
logo    dc.b    27,'E',13,10    ;cls & crlf
        dc.b    27,'p'          ;reverse on
        dc.b    '                       Computer                  '
        dc.b    27,'q',27,'Y',33,88,'Programm-Service'
        dc.b    13,10,27,'Y',34,88,'fuer ATARI 520 ST'
        dc.b    27,'p',13,10
        dc.b    '                          persoenlich            '
        dc.b    27,'q',13,10,13,10    
        dc.b    13,10
        dc.b    '         R A M - D i s k  fuer ATARI xxx ST',13,10
        dc.b    '         =================================',13,10
        dc.b    '        (c) 1985 Peter Wollschlaeger'
        dc.b    13,10,13,10
        dc.b     ' Auf einem 260 ST kann die RAM-Disk nur 100 K Byte gross sein,'
        dc.b    13,10
        dc.b    ' auf einem ST+ bis zu 600 K (mit ROM jeweils 200 K mehr).'
        dc.b    13,10,13,10,13,10
        dc.b    ' Waehlen Sie 1..8 fuer 100..800 K Byte: '
        dc.b    0

beep    dc.b    7,0
prompt  dc.b    '00 K Byte OK (J/N A)bruch) ? ',0
manual  dc.b    27,'Y',38,32,27,'J'
        dc.b    'Wenn Sie gleich zum Schreibtsch zurueckkehren,'
        dc.b    13,10
        dc.b    'schliessen Sie alle Fenster und'
        dc.b    13,10
        dc.b    'klicken Sie Diskstation A an (so dass die schwarz wird).'
        dc.b    13,10
        dc.b    'Nun waehlen aus dem Menu Optionen Diskstation anmelden.'
        dc.b    13,10
        dc.b    'Dort waehlen Sie als Bildbezeichnung  RAMDISK'
        dc.b    13,10
        dc.b    'und Laufwerk ',0
manual1 dc.b    13,10,'Druecken Sie eine Taste',0
        ds.w    0
drive   ds.w    1
drvname ds.w    1

bpbtab  dc.w    $200            ;Standard BPB
        dc.w    2
        dc.w    $400
        dc.w    7
        dc.w    5
        dc.w    6
        dc.w    18
numcl   ds.w    1               ;hierher Groesse RAM-Disk
        ds.w    8

bootsec dc.b    0,2             ;Boot-Sektor ab Byte $0B
        dc.b    2
        dc.b    1,0
        dc.b    2
        dc.b    112,0
        ds.b    2
        dc.b    0
        dc.b    5,0
        dc.b    9,0
        dc.b    1,0
        dc.b    0
seclen  equ     *-bootsec

        bss
old_bpb ds.l    1
old_rw  ds.l    1
old_med ds.l    1
ramdisk equ     *

        end
  

