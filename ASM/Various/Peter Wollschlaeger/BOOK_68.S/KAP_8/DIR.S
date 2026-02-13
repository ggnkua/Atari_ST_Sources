* File dir.s

GEMDOS  equ     1       ;die Nummer fuer den GEMDOS-Trap
CONIN   equ     1       ;Funktion auf Taste warten
PRTLIN  equ     9       ;Funktion String ausgeben
SETDTA  equ     $1A     ;Setze Disk Transfer Adresse
SFIRST  equ     $4E     ;Search First (suche erstes) File
SNEXT   equ     $4F     ;Suche naechstes File

        text                    ;Programm-Segment

        move.l  #msg,d0         ;Adresse des Strings uebergeben
        bsr     print           ;String drucken

        pea     dta             ;Adresse des DTA-Puffers
        move.w  #SETDTA,-(sp)   ;Funktionsnummer
        trap    #GEMDOS
        addq.l  #6,sp           ;Stack korrigieren

        move.w  #0,-(sp)        ;Attribut "normale Files"
        pea     fname           ;Adresse des File-Namens
        move.w  #SFIRST,-(sp)   ;Funktionsnummer
        trap    #GEMDOS         
        addq.l  #8,sp
loop    tst     d0              ;File gefunden?
        bne     done            ;wenn nicht, fertig
        move.l  #txt,d0         ;sonst ...
        bsr     print           ;... Name drucken

        move.w  #SNEXT,-(sp)    ;naechstes File suchen
        trap    #GEMDOS
        addq.l  #2,sp
        bra     loop    

done    move.l  #wait,d0
        bsr     print
        move    #CONIN,-(sp)
        trap    #GEMDOS
        addq.l  #2,sp
        clr     -(sp)
        trap    #GEMDOS

print   move.l  d0,-(sp)
        move.w  #PRTLIN,-(sp)
        trap    #GEMDOS
        addq.l  #6,sp

        move.l  #crlf-(sp)
        move.w  #PRTLIN,-(sp)
        trap    #GEMDOS
        addq.l  #6,sp     
        rts

        data
msg     dc.b    27,'E'
        dc.b    'Directory'
crlf    dc.b    13,10
        dc.b    0

        ds.w    0
wait    dc.b    13,10,'Warte auf Taste',0

        ds.w    0
fname   dc.b    '*.*',0

        ds.w    0
dta     ds.b    30
txt     ds.b    14

        end        

