**************   Ein  Disk-Monitor     *************

        text                    ;und schon geht es los

        bsr     init            ;Startwerte vorgeben
        bsr     status          ;Status anzeigen
        move.l  #menu,d0        ;Menu ausgeben
        bsr     print

* Hauptschleife
* -----------------------------------------------
loop    

* Warte auf Taste
* --------------                        
        move    #7,-(sp)        ;conin ohne Echo
        trap    #1
        addq.l  #2,sp
        tst     d0              ;kein ASCII-Zeichen?
        beq     loop            ;wenn so
        cmpi    #'A',d0         ;kein Buchstabe?
        blt     loop            ;dann ignoriere Taste
        bclr    #5,d0           ;Erzwinge Grossbuchstaben

* Suche Tasten-Code in Tabelle
* ----------------------------
        lea     keys,a0         ;Tabelle gueltige Keys
        move    #count,d1       ;deren Anzahl
search  cmp.b   (a0)+,d0        ;Key auf aktuellem Platz?
        dbeq    d1,search       ;wenn nicht, weitersuchen
                                ;bis Tabellenende
        tst     d1              ;Key gefunden?
        bmi     loop            ;wenn nicht, auf ein Neues

* Suche Adresse zu Key
* -------------------
        neg     d1              ;sub d1,#count
        add     #count,d1       ;ergibt Platznr. von Key
        lsl     #2,d1           ;die mal 4
        lea     table,a0        ;Adr. der Routine
        move.l  0(a0,d1.w),a0   ;bestimmen
        jsr     (a0)            ;und diese aufrufen
        bra     loop            ;u.s.w.
* -----------------------------------------------------------
* Ende der Hauptschleife

* Beginn der Unterprogramme
* -----------------------------------------------------------
print   move.l  d0,-(sp)        ;Zeile drucken
        move.w  #9,-(sp)        ;Funk. PRINTLINE
        trap    #1
        addq.l  #6,sp
        rts

;Initialisierung
;---------------
init    move    #0,driveno      ;Drive=0
        move    #0,sideno       ;Seite=0                
        move    #0,trackno      ;Track=0
        move    #1,secno        ;Sektor=1
        rts

;Status ausgeben
;---------------
status  move.l  #txt_1,d0       ;Drive-Nummer
        bsr     print           ;Text 'Drive' drucken
        move    driveno,d1      ;und dann die Zahl
        bsr     prtnn

        move.l  #txt_2,d0       ;Seitennummer
        bsr     print
        move    sideno,d1
        bsr     prtnn

        move.l  #txt_3,d0       ;Track-Nummer
        bsr     print
        move    trackno,d1
        bsr     prtnn

        move.l  #txt_4,d0       ;Sektor-Nummer
        bsr     print
        move    secno,d1
        bsr     prtnn

        move.l  #prompt,d0      ;Cursor auf Prompt-Zeile
        bsr     print
        rts

;(d1) in dezi. ausgeben (<= 2 Digits)
;------------------------------------
prtnn   andi.l  #$FF,d1         ;Stellen begrenzen
        cmpi    #9,d1           ;ein Digit?
        bls     simpel          ;wenn so
        divu    #10,d1          ;Zehner ermitteln
        bsr     simpel          ;ausgeben
        swap    d1              ;Einer (Div.-Rest)
simpel  add     #48,d1          ;in ASCII        
        move.w  d1,-(sp)        ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        rts

;Input Nummer
;------------
;Dezimalzahl wird als String gelesen und konvertiert.0
;Ergebnis in D4

input   move.b  #3,inbuff       ;max 2 Zeichen +CR lesen
        pea     inbuff          ;Pufferadresse
        move.w  #10,-(sp)       ;Funktion Zeile lesen
        trap    #1              ;aufrufen
        addq.l  #6,sp
        movem.l a0/d1-d2,-(sp)  ;benutzte Register retten
        clr.l   d1              ;Arbeitsregister initialisieren
        clr.l   d2
        clr.l   d4
        lea     inbuff,a0       ;Zeiger auf Puffer
        move.b  1(a0),d1        ;Anzahl Zeichen 
        sub.b   #1,d1           ;-1 fuer CR
        addq.l  #2,a0           ;Zeiger auf erstes Zeichen
30$     move.b  (a0)+,d2        ;Zeichen -> d2
        subi.b  #$30,d2         ;in Ziffer wandeln
        mulu    #10,d4          ;mal Stellenwert
        add.l   d2,d4           ;und auf Ergebnis addieren   
        dbra    d1,30$          ;"for" alle Ziffern
        movem.l (sp)+,a0/d1-d2  ;Restore Register
        move.l  #prompt,d0      ;letze Frage loeschen
        bsr     print
        rts

;Drive/Seiten/Track/Sektor-Nummern holen
;--------------------------------------
drive   move.l  #prompt,d0      ;Cursor -> Prompt-Stelle  
        bsr     print
        move.l  #txt_11,d0      ;Drive-Nr. fragen
        bsr     print
        bsr     input           ;Antwort holen
        move    d4,driveno      ;und speichern
        bsr     status          ;Statuszeile updaten
        rts

side    move.l  #prompt,d0      ;wie vor 
        bsr     print
        move.l  #txt_21,d0
        bsr     print
        bsr     input    
        move    d4,sideno 
        bsr     status    
        rts

track   move.l  #prompt,d0   ;wie vor
        bsr     print
        move.l  #txt_31,d0
        bsr     print
        bsr     input
        move    d4,trackno
        bsr     status
        rts

sector  move.l  #prompt,d0     ;wie vor
        bsr     print
        move.l  #txt_41,d0
        bsr     print
        bsr     input
        move    d4,secno
        bsr     status  
        rts

;Sektor lesen/schreiben
;----------------------
read    move    #8,f_nr         ;Entry Lesen
        bsr     rdwr            ;Sektor lesen
        bsr     hex             ;und ausgeben 
        rts
    
write   move    #9,f_nr         ;Entry Schreiben

rdwr    move    #1,-(sp)        ;1 Sektor lesen/schreiben
        move    sideno,-(sp)    ;Seitennummer
        move    trackno,-(sp)   ;Track-Nummer
        move    secno,-(sp)     ;Sektor-Nummer
        move    driveno,-(sp)   ;Drive-Nummer
        clr.l   -(sp)           ;Filler;
        pea     buffer          ;Pufferadresse
        move    f_nr,-(sp)      ;Funktion (r/w)
        trap    #14             ;XBIOS aufrufen
        add.l   #20,sp          ;Stack korr.

;auf Fehler testen, OK oder Error ausgeben

errtest tst     d0              ;Teste Status
        bne     error           ;wenn Fehler
        move.l  #ok_txt,d0
        bsr     print
        rts
error   move.l  #er_txt,d0
        bsr     print
        rts   

* Formatieren eines Tracks
* ------------------------
flopfmt clr     -(sp)           ;Init-Daten
        move.l  #$87654321,-(sp);Keep XBIOS happy
        move    #1,-(sp)        ;Interleave
        move    sideno,-(sp)    ;Seite
        move    trackno,-(sp)   ;Track
        move    secno,-(sp)     ;Anzahl Sektoren
        move    driveno,-(sp)   ;Laufwerk
        clr.l   -(sp)           ;Filler
        pea     buffer          ;for bad sectors
        move    #10,-(sp)       ;Funktion Format
        trap    #14             ;call it
        add.l   #26,sp          ;Stack korr.
        bra     errtest         ;teste error & ret

* Sektor als 256 Worte in Hex drucken
* Format: 16 Worte/Zeile, 16 Zeilen
* -----------------------------------
hex     move.l  #line_3,d0      ;Cursor auf Zeile 3
        bsr     print
        lea     buffer,a4
        move    #15,d1          ;16 Zeilen zu drucken
oloop   move    #15,d3          ;16 Worte/Zeile
iloop   clr.l   d2              ;work register
        move    (a4)+,d2        ;1 Wort aus Puffer
        bsr     prthex          ;drucken
        move.w  #32,-(sp)       ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        dbra    d3,iloop        ;bis Zeile voll
        move.l  #crlf,d0        ;nun neue Zeile
        bsr     print
        dbra    d1,oloop        ;bis alle Zeilen
        move.l  #prompt,d0
        bsr     print
        rts

* Ein Wort in d2 in Hex (als Text) drucken
* ----------------------------------------
prthex  movem.l d0-d3,-(sp) 
        move.l  #3,d1           ; loop 4 nibbles
p1      rol.w   #4,d2           ; get nibble
        move.l  d2,d3
        andi.b  #$0f,d3         ; mask it
        addi.b  #48,d3          ; '0'..'9' anyway
        cmpi.b  #58,d3          ; >9?
        bcs     out             ; no
        addi.b  #7,d3           ; 'A'..'F'
out 
        move.w  d3,-(sp)        ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        dbra    d1,p1
        movem.l (sp)+,d0-d3
        rts

* Einen Sektor (512 Bytes) in ASCII drucken
* Format: 16 Zeilen a 32 Zeichen
* Problem: nur auf rechter Bildhaelfte
* Nicht druckbare Zeichen als Punkt
* -----------------------------------------
ascii   lea     buffer,a4
        move    #15,d1          ;16 Zeilen zu drucken
        move.b  #32+3,d5        ;Cursor auf Zeile 3        
olp     move.b  d5,TheX         ;modifiziert ESC-String!
        move.l  #line_x,d0      ;Cursor positionieren
        bsr     print
        move.w  #'|',-(sp)      ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        move    #31,d3          ;32 Chars/Zeile
ilp     move.b  (a4)+,d2        ;1 Char aus Puffer
        cmpi.b  #$1F,d2         ;nicht druckbares Zeichen?
        ble     punkt           ;wenn ja
        cmpi.b  #$7F,d2
        ble     disp 
punkt   move    #'.',d2         ;sonst '.'   
disp    
        move.w  d2,-(sp)        ;Zeichen
        move.w  #2,-(sp)        ;Funktion CONOUT
        trap    #1              ;aufrufen
        addq.l  #4,sp           ;Stack korrigieren
        dbra    d3,ilp          ;bis Zeile voll
        addi    #1,d5           ;nun neue Zeile
        dbra    d1,olp          ;bis alle Zeilen
        move.l  #prompt,d0 
        bsr     print
        rts

exit    clr     -(sp)         ;Fall Exit
        trap    #1

        data
keys    dc.b    'D','I','T','S','R','W','F','H','A','X'
count   equ     *-keys
        ds.w    0
table   dc.l    drive
        dc.l    side
        dc.l    track
        dc.l    sector
        dc.l    read
        dc.l    write
        dc.l    flopfmt 
        dc.l    hex
        dc.l    ascii
        dc.l    exit

nowrap  dc.b    27,'v',0
        ds.w    0
txt_1   dc.b    27,'H'          ;Cursor home
        dc.b    27,'K'          ;Clear to EOL
        dc.b    27,'w'          ;Wraping off
txt_11  dc.b    'Drive=',0
txt_2   dc.b    '    '
txt_21  dc.b    'Side=',0
txt_3   dc.b    '    '
txt_31  dc.b    'Track=',0
txt_4   dc.b    '    '
txt_41  dc.b    'Sector=',0
  
menu    dc.b    27,'Y',23+32,2+32      ;gotoyx 23,2
        dc.b    27,'pD',27,'qrive '
        dc.b    'S',27,'pi',27,'qde '
        dc.b    27,'pT',27,'qrack ' 
        dc.b    27,'pS',27,'qektor '
        dc.b    27,'pR',27,'qead '
        dc.b    27,'pW',27,'qrite '
        dc.b    27,'pF',27,'qormt '
        dc.b    27,'pH',27,'qex '
        dc.b    27,'pA',27,'qscii '
        dc.b    'E',27,'px',27,'qit '
        dc.b    0
        ds.w    0
prompt  dc.b    27,'Y',23+32,66+32
        dc.b    27,'K'
        dc.b    0
        ds.w    0
crlf    dc.b    13,10,0
        ds.w    0
line_3  dc.b    27,'Y',35,32,0
        ds.w    0
line_x  dc.b    27,'Y'
TheX    dc.b    32,32+46,0
        ds.w    0
er_txt  dc.b    27,'Y',32+0,32+60,27,'K'
        dc.b    'Operation fehlerhaft',0
ok_txt  dc.b    27,'Y',32+0,32+60,27,'K'
        dc.b    'Operation OK',0
        bss
driveno ds.w    1
sideno  ds.w    1
trackno ds.w    1
secno   ds.w    1
f_nr    ds.w    1
inbuff  ds.w    5
buffer  ds.b    $2000
        end
    
