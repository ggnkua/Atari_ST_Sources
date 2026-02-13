*CA  Cartridge-Programm simulieren

;Drei schon bekannte Makros
;--------------------------
conin   macro
        move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              
        addq.l  #2,sp           
        endm

term    macro
        clr     -(sp)           ;Funktion TERM
        trap    #1
        endm

writes  macro
        pea     \1
        move.w  #9,-(sp)        ;Funk. PRINTLINE
        trap    #1
        addq.l  #6,sp
        endm

*
* Start hier
*

loop    writes  query
        conin                     ;warte auf Taste
        cmp     #'x',d0           ;Abbruch?
        beq     fini              ;wenn so
        sub     #'0',d0           ;in Ziffer wandeln
        and.l   #%1,d0            ;nur Bit 0 gueltig
        jsr     ca_test           ;Ca-Programm aufrufen
        bra     loop              ;auf ein Neues

fini    term

;Die folgende  Routine ist aus dem ST-BIOS disassembliert.
;Disk-TOS Version 1 vom 20.11.85
;---------------------------------------------------------

ca_test lea     ca_base,a0        ;Cartridge Basis-Adresse
        cmp.l   #$ABCDEF42,(a0)+  ;Teste Kennwort und
                                  ;und zeige auf ersten Entry
        bne     return            ;Ende, wenn kein Cartridge
                                  ;installiert
ca1     btst    d0,4(a0)          ;Teste Init-Bit
        beq     noinit            ;wenn nicht gesetzt
        movem.l d0-d7/a0-a6,-(sp) ; Register retten
        move.l  4(a0),a0          ;Adresse der Routine
        jsr     (a0)              ;Aufruf
        movem.l (sp)+,d0-d7/a0-a6 ;Register zurueck
noinit  tst.l   (a0)              ;gibt es noch ein Pgm?
        move.l  (a0),a0           ;wir tun mal so
        bne      ca1              ;wenn ja
return  rts                       ;sonst Ende

;Die folgenden Zeilen simulieren ein Cartridge mit 2 Programmen
;--------------------------------------------------------------
*****   org      $FA0000          ;Falls Sie einen EPROM haben

ca_base dc.l     $ABCDEF42        ;Das Kennwort
        dc.l     pgm_2            ;Zeiger auf naechsten Header
        dc.l     init_1+$01000000 ;Adresse und Bit 24 gesetzt
        dc.l     start_1          ;Startadresse des ersten Pgm
        dc.w     0                ;Uhrzeit
        dc.w     0                ;und Datum, wenn Sie wollen
        dc.l     end_1-start_1    ;Laenge des Pgm
        dc.b     'filename.ext',0 ;File-Name


;next header
;----------
pgm_2   dc.l     0                ;0 = kein weiteres Pgm
        dc.l     init_2+$02000000 ;Jetzt Adresse mit Bit 25
        dc.l     start_2          ;Adresse des Pgm

;       wie vorher                ;kann hier auch entfallen

;-------------------------------------------------------------
;hier starten die Programme mit ihren Init-Routinen

init_1  writes   msg1
        rts

start_1 rts
end_1   equ      *

init_2  writes   msg2
        rts

start_2 rts
end_2   equ      *

query   dc.b     13,10,'Enter Digit ',0
        ds.w     0
msg1    dc.b     ' -> Ca-Pgm One Initialized',0
        ds.w     0
msg2    dc.b     ' -> Ca-Pgm Two Initialized',0

        end
