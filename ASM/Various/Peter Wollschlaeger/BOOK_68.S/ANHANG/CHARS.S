conin   macro
        move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              ;aufrufen
        addq.l  #2,sp           ;Stack korrigieren
        endm

writes  macro
        pea     \1
        move.w  #9,-(sp)        ;Funktion PRINTLINE
        trap    #1
        addq.l  #6,sp
        endm

bconout macro
        move     \1,-(sp)       ;Zeichen
        move     \2,-(sp)       ;Device
        move     #3,-(sp)       ;Funktion bCONOUT
        trap     #13
        addq.l   #6,sp
        endm 

        include  "linea.inc"     ;siehe Kapitel 9
       
        writes   hex1            ;A-F waagerecht
        writes   crlf
        lea      hex2,a4         ;A-F senkrecht
        move     #0,d4           ;auszugebendes Zeichen
        move     #15,d5          ;Schleifenzaehler
a_loop  move     #15,d6          ;eine Zeile a 16 Zeichen
        move.b   (a4)+,d7        ;A..F
        bconout  d7,#5           ;ausgeben
        bconout  #32,#5          ;Blank hinterher
i_loop  bconout  d4,#5           ;Zeichen ausgeben
        bconout  #32,#5          ;noch ein Blank
        addq     #1,d4           ;naechstes Zeichen
        dbra     d6,i_loop       ;Schleife 1 Zeile
        writes   crlf            ;neue Zeile
        dbra     d5,a_loop       ;bis alle 16

;nun die Linien zeichen
;----------------------
        init                     ;Line-A initialisieren
        color    #1,#1,#1,#1     ;Farbe s/w
        move     #0,wrt_mode(a5) ;Relace-Mode
        move     #-1,ln_mask(a5) ;durchgezogene Linie
        move     #16,d3          ;Schleifenzaehler
        move     #12,d4          ;Start Linien
lin     line     d4,#0,d4,#272   ;senkrechte Linien
        add      #4,d4           ;waagerechte etwas tiefer
        line     #0,d4,#268,d4   ;nun zeichnen
        add      #12,d4          ;naechste Linien
        dbra     d3,lin 

        conin                    ;auf Taste warten
        clr      -(sp)           ;Terminate
        trap     #1

crlf    dc.b     13,10,0         ;Zeilenvorschub
        ds.w     0
hex1    dc.b     '  0 1 2 3 4 5 6 7 8 9 A B C D E F',0
        ds.w     0
hex2    dc.b     '0123456789ABCDEF'
