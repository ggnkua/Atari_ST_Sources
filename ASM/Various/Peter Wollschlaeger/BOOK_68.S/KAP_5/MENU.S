* Programm menu

start                   
        move    #7,-(sp)        ;conin ohne Echo
        trap    #1
        addq.l  #2,sp
        tst     d0              ;kein ASCII-Zeichen?
        beq     start           ;wenn so
        cmpi    #'A',d0         ;kein Buchstabe?
        blt     start           ;dann ignoriere Taste
        bclr    #5,d0           ;Erzwinge Grossbuchstaben

* Suche Tasten-Code in Tabelle
* ----------------------------
        lea     keys,a0         ;Tabelle gueltiger Keys
        move    #count,d1       ;deren Anzahl
search  cmp.b   (a0)+,d0        ;Key auf aktuellem Platz?
        dbeq    d1,search       ;wenn nicht, weitersuchen
                                ;bis Tabellenende
        tst     d1              ;Key gefunden?
        bmi     start           ;wenn nicht, auf ein Neues

* Suche Adresse zu Key
* -------------------
        neg     d1              ;sub d1,#count
        add     #count,d1       ;ergibt Platznr. von Key
        lsl     #2,d1           ;die mal 4
        lea     table,a0        ;Adr. der Routine
        move.l  0(a0,d1.w),a0   ;bestimmen
        jsr     (a0)            ;und diese aufrufen
        bra     start           ;u.s.w.

Eingabe move    #'E',-(sp)
        move    #2,-(sp)
        trap    #1
        addq.l  #4,sp
        rts

Rechnen move    #'R',-(sp)
        move    #2,-(sp)
        trap    #1
        addq.l  #4,sp
        rts

Sichern clr     -(sp)         ;Fall Exit
        trap    #1

        data
keys    dc.b    'E','R','S'
count   equ     *-keys

        ds.w    0
table   dc.l    Eingabe
        dc.l    Rechnen
        dc.l    Sichern
        
	end
