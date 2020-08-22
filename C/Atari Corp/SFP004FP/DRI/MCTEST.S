fpreset equ     $fffa46
BUSTRAP equ     $8

        .globl _mctest                  ; Testet of MC68881 vorhanden
                                        ; und initialisieren
_mctest:
        move.l  #$0,-(sp)               ; Umschalten in SUPER-Modus
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,__ssp
        move.l  $8,bu_err               ; BUS-Fehler Adresse retten
        move.l  #newerror,BUSTRAP       ; und neu setzen
        move.l  #0,fpreset              ; MC68881 initialisieren
                                        ; BUS-Fehler falls nicht vorhanden
        move.l  bu_err,BUSTRAP          ; falls vorhanden -> alten Vektor setzen
        move.l  __ssp,-(sp)             ; Umschalten in USER-Modus
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp
        rts
newerror:
        move.l  bu_err,BUSTRAP          ; falls nicht vorhandn -> alten Vektor setzen
        move.l  __ssp,-(sp)             ; Umschalten in USER-Modus
        move.w  #$20,-(sp)
        trap    #1
        addq    #6,sp
        pea     fp_str
        move.w  #$9,-(sp)               ; Cconws fp_str
        trap    #1
        addq    #6,sp
        move.w  #7,-(sp)                ; Gemdos(7);
        trap    #1
        addq    #2,sp
        clr.w   -(sp)                   ; Pterm0
        trap    #1
        rts

        .data
fp_str: .dc.b   "MC68881 ist nicht Vorhanden",$d,$a
        .dc.b   "Weiter mit Tastendruck",$d,$a,$0

        .bss
__ssp:    .ds.l 1                       ; Speicher fÅr USER-Stack
bu_err:   .ds.l 1                       ; Speicher fÅr BUS-Fehler Vektor
        .end
