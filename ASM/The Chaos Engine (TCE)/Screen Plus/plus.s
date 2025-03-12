;************************************************ 
;*                                              *
;*                  SCREEN plus                 *
;*                  Steffen Scharfe             *
;*                                              *
;*              (c) 1992 MAXON Computer         *
;************************************************

v_bas_ad equ $044e 
nvbls    equ $0454 
vblqueue equ $0456 
sysbase  equ $04f2

mfp  equ $fffa01 ;MFP 68901
aer  equ $fffa03 ;Aktive-Edge-Register
iera equ $fffa07 ;Interrupt-Enable-Register A
isra equ $fffa0f ;Interrupt-in-Service-Register A
imra equ $fffa13 ;Interrupt-Mask-Register A
tbcr equ $fffa1b ;Timer-B-Control-Reg±ster
tbdr equ $fffa21 ;Timer-B-Data-Register

sync_mod equ $ff820a ;Sync-Mode-Register

zeile    equ 190

;Das hintere Programmstuck wird nur zur 
;Initialisierung benötigt

        bra init

;hier folgt nun das residente Programmstück

;diese Trap #2-Routine wird nur einmal 
;angesprungen, um nach der Initialisierung des 
;VDI die Parameter der neuen Bildschirmhöhe zu 
;setzen (245 Pixelzeilen)

;neuer Trap #2 Routine

trap_2: move.l  d1,vdipb            ;vdipb merken
        move.w  d0,vdi_aes          ;VDI oder AES
        move.l  2(sp),return        ;Return-Adresse merken
        move.l  #new_return,2(sp)   ;neue Return-Adresse
        movea.l vblqueue,a1
        move.l  #new_maus,(a1)      ;teilweise neue Mausroutine
        movea.l old_vektor,a1
        jmp     (a1)                ;ab zum Trap 2-Dispatcher



new_return:
        cmpi.w  #$73,vdi_aes        ;war dies ein VDI-Aufruf? 
        beq.s   vdi                 ;ja
zurueck:movea.l return,a1           ;alte Return-Adresse
        jmp     (a1)                ;zurück ins Hauptprogramm

vdi:    movem.l d0-d2/a0-a2,-(sp)
        movea.l vdipb,a0
        movea.l (a0),a1             ;Zeiger auf Control-Array 
        cmpi.w  #1,(a1)             ;Open Workstation? 
        bne.s   no_open             ;nein
        movea.l 12(a0),a1           ;Zeiger auf Intout-Array 
        move.w  #244,2(a1)          ;neue Rasterhöhe
        movea.l linea_param,a0
        move.w  #244,-$02b2(a0)     ;neue Werte in die negativen
        addi.w  #5,-$2a(a0)         ;Line-A-Variablen eintragen
        addi.w  #45,-4(a0)          ;45 Pixelzeilen mehr

        move.l  old_yektor,-(sp)    ;ausklinken 
        move.w  #34,-(sp) 
        move.w  #5,-(sp)
        trap    #13                 ;Setexc
        addq.l  #8,sp
no_open:movem.l (sp)+,d0-d2/a0-a2 
        bra.s   zurueck

;leider notwendig ein neuer Maustreiber
; (wegen 1 Befehl !!)

new_maus:movea.l linea_param,a5     ;wegen verschiedener BS-Varianten 
        tst.b   -$0153(a5)          ;Maus-Flag
        bne.s   maus_end
        bclr    #0,-$0154(a5)       ;Cur-Flag
        beq.s   maus_end
        move.l  -$0158(a5),d1       ;x/y-Position
        move.l  d1,d0
        swap    d0
        movem.w d0-d1,-(sp)
        lea     -$014a(a5),a2       ;Save-Len
maus_adr1:
        jsr     0
        movem.w (sp)+,d0-dl 
        movea.l linea_param,a5 
        lea     -$0358(a5),a0       ;x-Hot-Spot
        lea     -$014a(a5),a2       ;Save-Len
        bsr.s   new_maus1
maus_end:
        rts

new_maus1:
        move.w  6(a0),-(sp)         ;Hintergrundfarbe 4(sp)
        move w  8(a0),-(sp)         ;Vordergrundfarbe 2(sp)
        clr.w   d2
        tst.w   4(a0)               ;Replace/Xor
        bge.s   replace             ;Replace-Modus
        moveq   #$10,d2             ;XOR-Modus
replace:move.w  d2,-(sp)            ;Modus merken 0(sp)
        clr.w   d2
        bclr    #1,6(a2)            ;Words gebuffert 
        sub.w   (a0),d0             ;x:=x-hotspot
        bcs.s   x_hotspot
        move.w  -$02b4(a5),d3       ;maximale Rasterbreite 
        subi.w  #15,d3              ;minus 15
        cmp.w   d3,d0               ;Mauszeiger vollständig sichtbar?
        bhi.s   teilweise_x         ;nein
        bset    #1,6(a2)            ;Longs gebuffert
        bra.s   maus_y

x_hotspot:
        addx.w  #16,d0
        moveq   #8,d2               ;anmerken: x-hotspot
        bra.s   maus_y

teilweise_x:
        moveq   #16,d2

maus_y: sub.w   2(a0),d1            ;y:=y-hotspot
        lea     $0a(a0),a0          ;Tabelle für Vordergrund und Maske
        bcs.s   y_hotspot
        move.w  -$02b2(a5),d3       ;Anzahl der Pixelzeilen
        subi.w  #15,d3
        cmp.w   d3,d1               ;Mauszeiger vollständig sichtbar? 
        bhi.s   teilweise_y         ;nein
        moveq   #16,d5              ;ja -> Höhe:=16 Pixelzeilen
        bra.s   maus1

y_hotspot:
        move.w  d1,d5
        addi.w  #16,d5              ;Höhe berechnen
        asl.w   #2,d1               ;y:=y*4
        suba.w  d1,a0               ;ersten Pixelzeilen des Mauszeigers übergehen
        clr.w   d1
        bra.s   maus1

teilweise_y:
        move.w  -$02b2(a5),d5       ;Anzahl der Pixelzeilen
        sub.w   d1,d5
        addq.w  #1,d5               ;Höhe berechnen
maus1:  jsr     0                   ;rel Adresse im Bildspeicher 
                                    ;ab der die Maus gezeichnet wird

        movea.l v_bas_ad,a1         ;Zeiger auf Anfang des Bildspeichers

;und nun der entscheidende Befehl 
;aus adda.w d1,a1 wird...

        adda.l  d1,a1               ;absolute Adresse

;aha, die Maus funktioniert jetzt auch mit über 
;32767 Bytes Bildspeicher

maus_adr3:jmp   0                   ;weiter im Original-Programm

                ;Interrupt-Routinen


new_vbl:move.b  #zeile,tbdr         ;Timer B
        move.b  #8,tbcr             ;Start
        rts


timer_b:move.l  d0,-(sp)
        move    #$2700,sr           ;alle Ints gesperrt
w200:   cmpi.b  #180,tbdr           ;auf 200
        bne.s   w200                ;Pixelzeile warten
        move.b  #0,sync_mod         ;Sync-Bit
        move w  #2,d0               ;kippeln
w:      nop
        dbra    d0,w                ;etwas warten
        move.b  #2,sync_mod
        move    #$2300,sr
        move.b  #0,tbcr             ;Zähler stop
        move.l  (sp)+,d0
        bclr    #0,isra             ;Interrupt-Service fertig
        rte

        even

old_vektor: ds.l 1
return:     ds.l 1
vdipb:      ds.l 1
vdi_aes:    ds.w 1
linea_param:ds.l 1 
old_stack:  ds.l 1

;bis hier ist das Programm resident !!


init:   movea.l 4(sp),a6            ;Adresse der Basepage
        move.w  #$0100,d7           ;Länge der Basepage
        add.l   12(a6),d7           ;Länge des Text-Segments 
        add.l   20(a6),d7           ;Länge des Daten-Segments 
        add.l   28(a6),d7           ;Länge des Speicher-/Segments
        move.w  #4,-(sp)            ;Bildschirmauflösung holen
        trap    #14                 ;Getrez
        addq.l  #2,sp
        cmp.w   #2,d0
        beq     error1              ;monochrom kann ich nicht !

        dc.w    $a000               ;Line-A Init
        move.l  a0,linea_param      ;merken

        clr.l   -(sp)               ;Supermodus
        move.w  #32,-(sp) 
        trap    #1 
        addq.l  #6,sp
        move.l  d0,old_stack        ;alten Stack merken

;ermittelt je nach TOS-Version bestimmte Adressen 
        movea.l sysbase,a0
        move.w  2(a0),d0            ;Versionsnummer holen
        lea     tos_1_2,a1
        cmp.w   #$0102,d0           ;TOS 1.2 ?
        beq.s   tos1                ;ja
        lea     tos_1_4,a1
        emp.w   #$0104,d0           ;TOS 1.4 ?
        bne     error3 ;nein
tos1:   move.l  (a1)+,maus_adr1+2   ;TOS-abhängige Adressen
        move.l  (a1)+,maus1+2       ;initialisieren
        move.l  (a1)+,maus_adr3+2

        sub.l   #init_end-init,d7   ;Initialisierungsteil wegwerfen
        move.l  a6,d6               ;Adresse Base-Page
        add.l   d7,d6
        cmp.w   #0,d6               ;unterste Byte 0 ?
        beq.s   byte0               ;ja
        and.l   #$ffff00,d6
        add.l   #$0100,d6           ;wegen Videoprozessor

;neue physikalische und logische 
;Bildanfangsadresse setzen

byte0:  move.w  #-1,(sp)
        move.l  d6,-(sp)            ;neue Bildanfangsadresse 
        move.l  d6,-(sp)            ;logische Bildanfangsadresse 
        move.w  #5,-(sp)            ;Setscreen
        trap    #14
        lea     12(sp),sp

;VBL-Interrupt in Queue eintragen

        movea.l vblqueue,a0
        addq.l  #4,a0               ;1.Eintrag freilassen (für GEM)
        move.w  nvbls,d0
        subq.w  #2,d0
such:   move.l  (a0)+,d1
        beq.s   eintrag             ;leeren Eintrag gefunden
        dbra    d0,such             ;weitersuchen
        bra     error2

eintrag:move.l  #new_vbl,-(a0)

;Timer-B-Interrupt initialisieren

        move.l  #timer_b,$0120      ;Beginn der Interruptroutine
        move.b  #0,tbcr             ;Timer gestoppt

;MFP Timer B initialisieren

        andi.b  #$f7,aer            ;H-L Flanke wirksam
        move.b  #zeile,tbdr         ;Int. bei zeile
        ori.b   #1,imra             ;Interruptmaske freigeben
        ori.b   #1,iera             ;Interrupt Timer B einschalten 
        move.w  #37,-(sp)           ;Wait Vbl
        trap    #14
        addq.l  #2,sp
        move.b  #8,tbcr             ;Ereigniszählung

;Trap #2-Vektor verbiegen 

        pea     trap_2
        move.w  #34,-(sp)           ;Trap #2
        move.w  #5,-(sp)            ;neuen Vektor setzen
        trap    #13                 ;Setexc
        addq.l  #8,sp
        move.l  d0,old_vektor       ;alten Vektor merken

        move.l  old_stack,-(sp)     ;User-Modus
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp

;Programm resident hinterlassen

        add.l   #32000+7200,d6      ;Große Bildspeicher 
        sub.l   a6,d6               ;benötigter Speicherplatz 
        clr.w   -(sp)               ;Status ok
        move.l  d6,-(sp)            ;Länge
        move.w  #$31,-(sp)
        trap    #1                  ;Ptermres

;Error-Meldung

error1: pea     err_txt1
        bra.s   error
error2: pea     err_txt2
        bra.s   error
error3: pea     err_txt3
error:  move.w  #9,-(sp)            ;Cconws
        trap    #1
        addq.l  #6, sp

        move.w  #-1,d0
warte:  dbra    d0,warte

        clr.w   -(sp)
        trap    #1

;Tabelle für die verschiedenen TOS-Versionen 
;dc.l maus_ad1,maus_ad2,maus_ad3

        even
tos_1_2:dc.l    $fd01de,$fca212,$fd008c 
tos_1_4:dc.l    0,0,0
err_txt1:dc.b   "nur niedrige oder mittlere" 
         dc.b   " Auflösung !",0 
err_txt2:dc.b   "alle VBL-Slots belegt !",0 
err_txt3:dc.b   "unbekannte TOS-Version '",0 
        even 
init_end:
        end
