* AXXX Adressen der Line-A-Routinen

        dc.w    $A000           ;Init aufrufen
                                ;a2 zeigt nun auf Adress-Tabelle
        move    #15,d6          ;16 Werte ausgeben
loop    move.l  (a2)+,d2  
    
;Start von PRTHEX       
        move    #7,d1           ;Langwort hat 8 Nibbles
next    rol.l   #4,d2           ;Hole ein  Nibble
        move.l  d2,d3           ;  nach d3
        andi.b  #$0f,d3         ;maskiere es
        addi.b  #48,d3          ;'0'..'9' waere jetzt OK
        cmpi.b  #58,d3          ;ist es >9?
        bcs     out             ;nein, dann Ausgabe
        addi.b  #7,d3           ;sonst muss es 'A'..'F' sein
out     move    d3,-(sp)        ;print via GEMDOS
        move    #2,-(sp)        ;mit Funktion CONOUT
        trap    #1
        addq.l  #4,sp
        dbra    d1,next         ;next nibble
        pea     crlf            ;Zeilenvorschub
        move    #9,-(sp)
        trap    #1
        addq.l  #6,sp
        dbra    d6,loop

        move    #1,-(sp)        ;CONIN
        trap    #1
        addq.l  #2,sp
        clr     -(sp)           ;und Ende
        trap    #1

crlf    dc.b   13,10,0
        end
