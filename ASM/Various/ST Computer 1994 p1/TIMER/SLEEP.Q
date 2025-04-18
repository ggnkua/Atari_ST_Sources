; #####################################
; #             S L E E P       05/87 #
; #####################################
; # gedr�ckte Taste:  | Wirkung:      #
; #-------------------+---------------#
; # - (10er-Block)    | CPU langsamer #
; # + (10er-Block)    | CPU schneller #
; # Shift rechts      | CPU 'stoppen' #
; # Shift links       | ...fortsetzen #
; # Backspace         | full speed on #
; #####################################

 text
 
TASR      equ $FFFA0F        ; Timer A Service Register
TACR      equ $FFFA19        ; Timer A Control Register
TADR      equ $FFFA1F        ; Timer A Data Register
FLOPLK    equ $43E           ; Flag, ob Floppy aktiv ist
KEY       equ $E39           ; enth�lt Code der derzeit gedr�ckten Taste
SKEY      equ $E1B           ; enth�lt Status der Sondertasten

LOAD:
 pea      IRR                ; Adresse der Timer A-Interrupt-Routine
 move.w   #64,-(a7)          ; DATA = 64
 move.w   #7,-(a7)           ; CRTL = 7  (Vorteiler auf 200)
 clr.w    -(a7)              ; Timer A (=0)
 move.w   #31,-(a7)          ; mit XBTIMER()...
 trap     #14                ; ...des XBIOS aktivieren...
 add.l    #12,a7             ; ...und Stapel korrigieren.
 clr.w    -(a7)              ; kein Fehler aufgetreten
 move.l   #600,-(a7)         ; 600 Bytes reservieren...
 move.w   #$31,-(a7)         ; ...KEEP PROCESS...
 trap     #1                 ; ...und weggetreten!
;=========================================================================
IRR:                         ; Hier geht's lang beim Timer A-IR!
 movem.l  d0-d1,-(a7)        ; verwendete Register retten
 move.b   #0,TACR            ; erstmal Timer A ausschalten
 bclr     #5,TASR            ; und die MFP-IRs freigeben,
 andi.w   #$F3FF,SR          ; au�erdem alle IRs ab IPL 4
 tst.w    FLOPLK             ; Floppyzugriff???
 bne      ENDE               ; ja, dann fertig
 btst     #2,8(a7)           ; VBL-IRR unterbrochen???
 bne      ENDE               ; dann aber hurtig beenden!

PLUS:                        ; Verz�gerung bei '-' erh�hen
 move.b   KEY,d0             ; Tastaturcode der gedr�ckten Taste
 cmpi.b   #$4A,d0            ; = '-' auf 10er-Block?
 bne.s    MINUS              ; nein

DEC:                         ; Vorteilungsfaktor dekrementieren
 cmpi.b   #1,CONTROL         ; Schon kleinste Vorteilerstufe?
 beq.s    DELAY_TEST         ; ja, dann Verz�gerung erh�hen
 subi.b   #1,CONTROL         ; sonst kleinere Vorteilung w�hlen
 bra.s    WAIT               ; und warten

DELAY_TEST:                  ; Verz�gerungsfaktor erh�hen
 cmpi.l   #100000,DELAY      ; obere Grenze schon erreicht?
 beq.s    WAIT               ; ja, dann nur warten
 addi.l   #2,DELAY           ; sonst erst Verz�gerung erh�hen
 bra.s    WAIT               ; und dann warten

MINUS:                       ; Verz�gerung bei '+' verkleinern
 cmpi.b   #$4E,d0            ; = '+' auf 10er-Block?
 bne.s    BS                 ; nein, dann vielleicht Backspace?
 tst.l    DELAY              ; if Verz�gerung=0
 beq.s    INC                ;    then CONTROL++
 subi.l   #2,DELAY           ;    else DELAY-=2 und
 bra.s    WAIT               ;         warten

INC:                         ; Vorteilungsfaktor inkrementieren
 cmpi.b   #7,CONTROL         ; Vorteilung schon maximal?
 beq.s    KEYPRESS           ; ja
 addi.b   #1,CONTROL         ; sonst erh�hen
 bra.s    KEYPRESS

BS:
 cmpi.b   #14,d0             ; Backspace-Taste gedr�ckt?
 bne.s    WAIT               ; nein, nur warten
 move.l   #0,DELAY           ; sonst CPU auf volle Lotte und
 move.b   #7,CONTROL         ; Vorteilung auf 200 einstellen
 bra.s    ENDE               ; fertig

WAIT:                        ; Warteschleife
 move.l   DELAY,d0           ; d0=Verz�gerungsz�hler
 beq.s    KEYPRESS           ; falls 0, dann nicht warten
\wait_lp1:                   ; sonst warten...
 move.l   DELAY,d1           ; ...je nach Verz�gerung...
\wait_lp2:
 dbra     d1,\wait_lp2       ; ...aber immer...
 dbra     d0,\wait_lp1       ; ...im Quadrat!

KEYPRESS:
 btst     #0,SKEY            ; rechte Shift-Taste gedr�ckt?
 beq.s    ENDE               ; nein, dann fertig
\key_release:
 btst     #1,SKEY            ; sonst warten, bis linke Shift-
 beq.s    \key_release       ; Taste gedr�ckt wird

ENDE:                        ; alles hat ein Ende, nur der Timer nicht!
 move.b   #64,TADR           ; Timer-Datenregister neu laden...
 move.b   CONTROL,TACR       ; ...und aktivieren...
 movem.l  (a7)+,d0-d1        ; ...schlie�lich Register restaurieren...
 rte                         ; ...und Ende der Veranstaltung!

 data

DELAY:    dc.l 0             ; enth�lt Wert f�r Verz�gerung
CONTROL:  dc.b 7             ; enth�lt Wert f�r Timer A-Control-Register

 end
 