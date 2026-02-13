; Demo Hex-Ausgabe

start   move.w  #1,-(sp)        ;Funktion CONIN
        trap    #1              ;aufrufen
        addq.l  #2,sp           ;Stack korrigieren
        cmpi.b  #'x',d0         ;x eingeben
        beq     stop_it         ;wenn ja, stop
        move.l  d0,d2           ;Code nach d2 kopieren


;print (d2) in hex
;-----------------        
        move    #7,d1           ; Langwort hat 8 Nibbles
next    rol.l   #4,d2           ; Hole ein  Nibble
        move.l  d2,d3           ;   nach d3
        andi.b  #$0f,d3         ; maskiere es
        addi.b  #48,d3          ; '0'..'9' waere jetzt OK
        cmpi.b  #58,d3            ist es >9?
        bcs     out             ; nein, dann Ausgabe
        addi.b  #7,d3           ; sonst muss es 'A'..'F' sein
out     move    d3,-(sp)        ; print via GEMDOS
        move    #2,-(sp)        ; mit Funktion CONOUT
        trap    #1
        addq.l  #4,sp
        dbra    d1,next         ; next nibble

        bra    start            ; und wieder von vorn

stop_it clr    -(sp)            ;Funktion 0 = Ende
        trap    #1
        
        end
       
