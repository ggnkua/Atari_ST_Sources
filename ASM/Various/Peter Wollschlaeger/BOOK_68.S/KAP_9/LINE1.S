* LINE1 ein paar Linien zeichnen
       
       include  "linea.inc"

       init                       ;Line-A initialisieren
       color    #1,#1,#1,#1       ;hochaufloesend
       move     #0,wrt_mode(a5)   ;Replace-Modus

;Zeichne grosses Kreuz und X
;---------------------------
       line     #0,#200,#639,#200 ;wird __
       line     #320,#0,#320,#399 ;     |
       line     #0,#0,#639,#399   ;     \
       line     #0,#399,#639,#0   ;     /
              
       move     #1,-(sp)          ;Funktion CONIN
       trap     #1                ;GEMDOS aufrufen
       addq.l   #2,sp             ;Stack korrigieren
       move     #0,-(sp)          ;Funktion TERM(inate)
       trap     #1

       end
