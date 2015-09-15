;
; Switcher.Q V1.0
;
; Multifunktionales Umschaltprogramm
; geschrieben von Markus Bubendorf
;                 Zollstrasse 1
;                 CH-4124 Schînenbuch
;                 Tel.:CH-061/63 05 92

; Funktionsweise der Tastaturabfrage:
; Die originale Routine aus dem ROM, die fÅr die Auswertung der Tastatur-
; prozessordaten verantwortlich ist, wird in den zweiten Teil der Base-
; page kopiert. Die Maus-, Joystick-, und Zeitdaten werden hier wie in
; der Originalroutine bearbeitet. In die Tastaturabfrage hinein kommt je-
; doch der residente Teil des Switchers. Er fÅhrt, je nach geliefertem
; Scancode der Tastatur, die diversen Funktionen aus.
; Die eigene Routine kann auf zwei verschiedene Arten verlassen werden:
; 1. Durch ein 'rts'. In diesem Fall wird der Scancode vom BIOS nicht
; weiter verarbeitet. D.h. Das Betriebssystem merkt gar nicht, dass eine
; Taste gedrÅckt wurde.
; 2. Durch Sprung in die originale BIOS-Routine, die die Scancodes 
; wie Åblich auswertet.
; Wer genaueres Åber das verwendete Verfahren wissen will, kann dies im
; Heft c't Nummer 11/88 Seite 150 nachlesen.
; Die Routine, die aus dem ROM kopiert wird, ist im TOS 1.0 und im TOS
; 1.2 genau 336 Bytes lang. Die Differenz zwischen 'unsere' und 'hier'
; plus 128 Bytes (halbe Basepage) muss mindestens gleich diesen 336
; Bytes sein.

; Zuerst ein paar Konstantendefinitionen, um das Listing etwas
; Åbersichtlicher zu machen
gemdos:    equ     1
xbios:     equ     14
keytbl:    equ     16
kbdvbase:  equ     34
supexec:   equ     38
crawcin:   equ     7
cconws:    equ     9
super:     equ     32
ptermres:  equ     $31
pterm:     equ     $4c
mshrink:   equ     $4a

           text
_base:     equ     hier-$100    ; Adresse der Basepage
neu_ikbd:  equ     _base+$80    ; Hierhin kommt die Kopie der originalen
                                ; Tastaturroutine
hier:      pea     ok(pc)      ; Adresse der BegrÅssungsmeldung auf Stack
           move.w  #cconws,-(sp)
           trap    #gemdos     ; und Meldung ausgeben
           addq.l  #6,sp
           move.w  #Kbdvbase,-(sp)
           trap    #xbios      ; Adresse der IKB-Routinen
           addq.l  #2,sp       ; ermitteln
           move.l  d0,a5
           move.l  $20(a5),a3  ; Zeiger auf Keyboardroutine laden
           move.w  #256-1,d0   ; max. 256 Words durchsuchen
suche:     addq.w  #2,a3       ; Zeiger erhîhen
           cmpi.l  #$0c0000f6,(a3); und mit "cmpi.b #$f6,d0"-Opcode
           dbeq    d0,suche    ; vergleichen
           bne     err         ; Error ausgeben, falls nicht gefunden
           addq.w  #4,a3       ; Zeiger auf nÑchsten Opcode
           cmpi.w  #$6500,(a3)+; mit "bcs.l"-Opcode vergleichen
           bne     err         ; Error ausgeben, falls anderer Opcode
           adda.w  (a3),a3     ; Wiedereinsprungadresse berechnen
           lea     wdeinsprg(pc),a4
           move.l  a3,(a4)     ; und in wdeinsprg abspeichern
           lea     neu_ikbd(pc),a4
           lea     unsere(pc),a6
           move.l  $20(a5),a3
           bra     Copy

ok:        dc.b    27,'E',10,27,"p Switcher Version 1.0 ",27,"q",13,10
           dc.b    10,10,"von Markus Bubendorf",13,10
           dc.b    "    Zollstr. 1",13,10
           dc.b    "    CH-4124 Schînenbuch",13,10
           dc.b    "    Tel.: CH-061/63 05 92",13,10,10
           dc.b    "Dieses Programm ist Public Domain!",13,10
           dc.b    "Bitte sendet mir dafÅr aber",13,10
           dc.b    "sFr. 15.-. Danke.",13,10,0
           align.w

; Ab jetzt kommt der Speicherresidente Teil des Switchers.
; In d0 befindet sich der Scancode der Tastatur. Es dÅrfen alle
; Register verÑndert werden.

unsere:    lea     sh_flag(pc),a2
           cmp.b   #$2a,d0      ; linke Shift-Taste gedrÅckt?
           beq     set_left
           cmp.b   #$aa,d0      ; linke Shift-Taste losgelassen?
           beq     clr_left
           cmp.b   #$36,d0      ; rechte Shift-Taste gedrÅckt?
           beq     set_right
           cmp.b   #$b6,d0      ; rechte Shift_Taste losgelassen?
           beq     clr_right
testen:    cmp.b   #3,(a2)      ; sind beide Shift-Tasten gedrÅck?
           bne     ins_rom      ; Nein, dann normal ins BIOS springen
           cmp.b   #$20,d0      ; 'D'-Taste?
           beq     dunkel
           cmp.b   #$17,d0      ; 'I'-Taste?
           beq     invers
           cmp.b   #$1f,d0      ; 'S'-Taste?
           beq     slow
           cmp.b   #$1b,d0      ; '+'-Taste?
           beq     plus
           cmp.b   #$35,d0      ; '-'-Taste?
           beq     minus
           cmp.b   #$01,d0      ; Esc-Taste?
           beq     totalneu
           cmp.b   #$53,d0      ; Delete-Taste?
           beq     neustart
           cmp.b   #$19,d0      ; 'P'-Taste?
           beq     pause
           cmp.b   #$3,d0       ; '2'-Taste?
           beq     bpb
           cmp.b   #$21,d0      ; 'F'-Taste?
           beq     frequenz
           cmp.b   #$2f,d0      ; 'V'-Taste?
           beq     verify
           cmp.b   #$22,d0      ; 'G'-Taste?
           beq     beep
           cmp.b   #$25,d0      ; 'K'-Taste?
           beq     klick
           cmp.b   #$11,d0      ; 'W'-Taste?
           beq     wiederh
           cmp.b   #$31,d0      ; 'N'-Taste?
           beq     night
ins_rom:   move.l  wdeinsprg(pc),a1 ; ROM-Einsprungadresse holen
           jmp     (a1)         ; und dorthin springen
           
; Die ist die neue Keyboard-Interrupt Routine. Sie wird direkt nach Aus-
; lîsen des Interruptes angesprungen und kann deshalb auch Mausbewegungen
; auswerten. Alle Register haben undefinierte Wert, die auf jeden Fall
; erhalten bleiben mÅssen.
new_ikb:   move.l  a2,-(a7)     ; a2 sichern     
           lea     vblcount(pc),a2 ; Adresse des Nigth-ZÑhlers laden
           tst.w   (a2)         ; Ist der ZÑhler=0 (=Nigth wurde aktiv)?
           bpl.s   new_ikb1     ; Nein, nichts Ñndern
           bclr    #0,$ffff820a ; sonst, Bildschirm hell machen
new_ikb1:  move.w  #$2200,(a2)  ; ZÑhler neu initialisieren
           move.l  (a7)+,a2     ; a2 restaurieren
ikbsprung: jmp     12345678     ; Sprung in originale Interruptroutine 

dunkel:    bchg    #0,$ffff820a ; Bit fÅr interne/externe Screensynchr-
           rts                  ; nisation invertieren

set_left:  bset    #0,(a2)      ; Flag fÅr linke Shift-Taste setzen
           bra.s   ins_rom
clr_left:  bclr    #0,(a2)      ; Flag fÅr linke Shift-Taste lîschen
           bra.s   ins_rom
set_right: bset    #1,(a2)      ; Flag fÅr rechte Shift-Taste setzen
           bra.s   ins_rom
clr_right: bclr    #1,(a2)      ; Flag fÅr rechte Shift_Taste lîschen
           bra.s   ins_rom


invers:    lea     $ffff8240,a0 ; Alle 16 Farbregister in einer
           moveq   #7,d0        ; einfachen Schlaufe invertieren
invloop:   not.l   (a0)+        ; Longword-Verarbeitung geht schneller
           dbra    d0,invloop
           rts

slow:      lea     slowflag(pc),a0
           not.b   (a0)         ; Flag fÅr Zeitlupe invertieren (Die eigen-
           rts                  ; liche Zeitlupenroutine befindet sich in
                                ; der VBL-Routine)
plus:      lea     verz(pc),a0  ; Adresse des Zeitlupenwertes laden
           move.w  (a0),d0      ; Wert nach d0 holen
           cmp.w   #$2200,d0    ; Ist der Wert grîsser als $2200
           bpl.s   plusrts      ; Ja, dann weiter bei plusrts
           add.w   #$200,d0     ; sonst $200 dazuaddieren
plusok:    move.w  d0,(a0)      ; Wert zurÅckschreiben
plusrts:   rts

minus:     lea     verz(pc),a0  ; Adresse des Zeitlupenwertes laden
           move.w  (a0),d0      ; Wert nach d0 holen
           sub.w   #$200,d0     ; und $200 subtrahieren
           bpl.s   plusok       ; Falls Wert immer noch positiv, abspeichern
           rts

totalneu:  clr.w   $420         ; memvalid ungÅltig machen
           clr.w   $426         ; resvalid ungÅltig machen
neustart:  move.l  $4,a0        ; Åber Resetvektor springen
           jmp     (a0)

pause:     lea     pauseflag(pc),a0
           not.w   (a0)         ; Flag fÅr Pausenstatus invertieren
           bne.s   pausewait    ; Falls es nun gelîscht wurde,
           rts                  ; nichts weiter machen
pausewait: bclr    #6,$fffffa11 ; Sonst Tastaturinterrupt wieder zulassen
           move.w  #$2500,sr    ; Interruptlevel auf 5 stellen
pauseloop: tst.w   (a0)         ; und solange nichts tun, bis das Pausen-
           bne.s   pauseloop    ; flag wieder invertiert wird
           rts

bpb:       lea     newbpb(pc),a0
           cmp.l   $472,a0
           beq.s   unstalbpb
           lea     bpbsprung(pc),a1
           move.l  $472,2(a1)
           move.l  a0,$472
           rts
unstalbpb: move.l  bpbsprung+2(pc),$472
           rts
newbpb:    lea     bpbstack(pc),a0 ; Neue Get BIOS_Parameter_Block Routine
           move.l  (a7),(a0)       ; Alte RÅcksprungadresse sichern
           lea     bpbret(pc),a0   ; und an deren Stelle die eigene
           move.l  a0,(a7)         ; eintragen
bpbsprung: jmp     $12345678       ; nun Åber alte Routine den bpb holen
bpbret:    move.l  bpbstack(pc),-(a7) ; RÅcksprungadresse wiedereinsetzen
           move.l  d0,a0           ; und, als eigentliche Aktion, die Anzahl
           addq.w  #2,14(a0)       ; der freien Cluster um 2 erhîhen
           rts
           
frequenz:  bchg    #1,$ffff820a ; Bit fÅr Bildwiederholfrequenz
           rts                  ; invertieren

verify:    not.b   $444         ; Flag fÅr Verify invertieren
           rts

beep:      bchg    #2,$484      ; Flag fÅr den Beep invertieren
           rts

klick:     bchg    #0,$484      ; Flag fÅr den Klick invertieren
           rts

wiederh:   bchg    #1,$484      ; Flag fÅr die Tastenwiederholung invertieren
           rts

night:     lea     nightflag(pc),a0
           not.b   (a0)         ; Flag fÅr die Night-Funktion invertieren
           rts

newvbl:    lea     slowflag(pc),a0 ; Neue VBL-Routine
           tst.b   1(a0)        ; Ist die Night-Funktion aktiv?
           beq.s   newvbl1      ; Nein, dann Sprung zu newvbl1
           subq.w  #1,-2(a0)    ; sonst den Night-ZÑhler decrementieren
           bpl.s   newvbl1      ; falls er noch grîsser 0 ist ==> newvbl
           bset    #0,$ffff820a ; sonst Bildschirm dunkeltasten
newvbl1:   tst.b   (a0)         ; Ist der Slowmodus aktiv?
           beq.s   newvbl9      ; Nein, dann Sprung zu newvbl9
           move.w  verz(pc),d0  ; Verzîgerungswert laden
slowloop:  dbra    d0,slowloop  ; und entsprechende Zeit 'totschlagen'
newvbl9:
vblsprung: jmp     $12345678    ; Sprung zur originalen VBL-Routine

                         ; Nun noch die diversen Flags und SpeicherplÑtze
sh_flag:   dc.w    0            ; Flag fÅr die Shift-Tasten
wdeinsprg: dc.l    0            ; Wiedereinsprungadresse der Keyboardroutine
verz:      dc.w    $1700        ; Verzîgerung des Slow
pauseflag: dc.w    0            ; Flag fÅr die Pause
bpbstack:  dc.l    0            ; Speicherplatz fÅr bpb-Routine
vblcount:  dc.w    $2200        ; ZÑhler fÅrs Night
slowflag:  dc.b    0            ; Flag fÅr die Zeitlupe
nightflag: dc.b    $ff          ; Flag fÅrs Night
           ; Achtung: die letzen drei Zeilen mÅssen hintereinander bleiben
                        
unser_ende:align.w

; Jetzt kommt der zweite Teil der Initialisierung. Dieser Teil wird
; nach der Initialisierung vom Betriebssystem gelîscht!
copy:      move.w  (a3)+,(a4)+  ; ROM-Routine kopieren
           cmpa.l  a4,a6        ; kommen wir an den Anfang unserer Routine?
           beq     err          ; Ja, dann Fehler ausgeben
           cmpa.l  wdeinsprg(pc),a3 ; Sonst mit Endadresse vergleichen
           bne.s   copy         ; und weiterkopieren
           lea     newvbl(pc),a0
           suba.l  a6,a0        ; in a0 wird nun die Adresse der kopierten
           adda.l  a4,a0        ; newvbl-Routine ausgerechnet
           move.l  a0,buffer
           move.w  #(unser_ende-unsere-2),d0
           lsr     #1,d0        ; undschliesslich wird die eigene Routine an
copyunsere:move.w  (a6)+,(a4)+  ; das Ende der kopierten ROM-Routine kopiert
           dbra    d0,copyunsere
           lea     neu_ikbd,a3
           move.l  a3,$20(a5)   ; Jetzt neue IKB-Adresse eintragen
           lea     _base(pc),a3 
           suba.l  a3,a4        ; LÑnge des residenten Teils ausrechnen
           clr.l   -(sp)
           move.w  #32,-(sp)
           trap    #1           ; In Supervisormodus schalten
           move.l  d0,2(sp)
           move.l  buffer(pc),a0
           move.l  $4ce,2+vblsprung-newvbl(a0)
           move.l  a0,$4ce      ; VBL-Interrupt umbiegen
           move.l  $118,2+ikbsprung-newvbl(a0)
           lea     new_ikb-newvbl(a0),a1
           move.l  a1,$118      ; Keyboard-Interrupt umbiegen
           lea     bpb-newvbl(a0),a0
           jsr     (a0)         ; bpb-Routine installieren
           trap    #1           ; ZurÅck in den Usermodus
           addq.l  #6,sp
           clr.w   -(sp)       ; Errorcode 0 (kein Fehler) zurÅckgeben
           move.l  a4,-(sp)    ; LÑnge des residenten Teils auf Stack
           move.w  #ptermres,-(sp)
           trap    #gemdos     ; und Programm beenden

err:       pea     fehler(pc)  ; Adresse der Fehlermeldung auf Stack
           move.w  #cconws,-(sp)
           trap    #gemdos     ; und Fehlermeldung ausgeben
           addq.l  #6,sp
           move.w  #crawcin,-(sp) ; nun auf Tastendruck warten
           trap    #gemdos
           addq.l  #2,sp
           move.w  #-1,-(sp)   ; und Programm mit Errorcode -1
           move.w  #pterm,-(sp); beenden
           trap    #gemdos

fehler:    dc.b    "Switcher arbeitet nicht mit ihrem TOS.",0
           align.w
           bss
buffer:    dc.l    0

           end

 
 
 
 
 
 
