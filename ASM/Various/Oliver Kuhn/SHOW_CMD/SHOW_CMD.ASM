*******************************************************
*                                                     *
*   SHOW_CMD - zeigt die Åbergebene Command Line      *
*                                                     *
*   geschrieben von:  Oliver Kuhn                     *
*                     Heinrich-Heine-Str. 28          *
*                     3550 Marburg                    *
*                                                     *
*   Version vom 10.10.88                              *
*                                                     *
*******************************************************

        text               ; Programm benutzt nur 
                           ; Textsegment

        move.l  4(sp),a6   ; Anfangsadresse Basepage 
                           ; -> a6

        lea     $80(a6),a5 ; Anfangsadresse 
                           ; Command Line -> a5
        clr.w   d7         ; d7 lîschen, damit oberes
                           ; Byte 0 ist
        move.b  (a5)+,d7   ; Anzahl der Zeichen
                           ; -> d7
        tst.b   d7         ; Sind Åberhaupt Zeichen
                           ; auszugeben ?
        beq     ende       ; wenn nicht, beenden
        subq.w  #1,d7      ; d7 fÅr dbra um 1
                           ; verringern
                           
aus:                       ; hier beginnt die
                           ; Ausgabeschleife
        clr.w   d0         ; d0 lîschen, damit oberes
                           ; Byte 0 ist
        move.b  (a5)+,d0   ; Zeichen in d0
                           ; zwischenspeichern
        move.w  d0,-(sp)   ; Zeichen fÅr Ausgabe
                           ; auf Stack legen
        move.w  #2,-(sp)   ; Funktionscode 'Conout'
                           ; auf Stack legen
        trap    #1         ; GEMDOS aufrufen
        addq.l  #4,sp      ; Stack restaurieren
        dbra    d7,aus     ; wenn noch Zeichen
                           ; auszugeben sind nach
                           ; aus springen
                
        move.w  #$D,-(sp)  ; CR (Carriage Return) 
                           ; auf Stack legen
        move.w  #$2,-(sp)  ; Funktionscode 'Conout'
                           ; auf Stack legen
        trap    #1         ; GEMDOS aufrufen
        addq.l  #4,sp      ; Stack restaurieren

        move.w  #$A,-(sp)  ; LF (Linefeed) auf 
                           ; Stack legen
        move.w  #$2,-(sp)  ; Funktionscode 'Conout'
                           ; auf Stack legen
        trap    #1         ; GEMDOS aufrufen
        addq.l  #4,sp      ; Stack restaurieren

        move.w  #7,-(sp)   ; Funktionscode 
                           ; 'Direct Con Without Echo'
                           ; auf Stack legen
        trap    #1         ; GEMDOS aufrufen
        addq.l  #2,sp      ; Stack restaurieren


ende    clr.w   -(sp)      ; Funktionscode 'Term' auf
                           ; Stack legen
        trap    #1         ; mit GEMDOS-Aufruf
                           ; Programm beenden

        end
