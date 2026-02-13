* LINE2 Grafik-Demo
     
       include  "linea.inc"

       init                     ;Initialisierung
       color    #1,#1,#1,#1     ;hochaufloesend
       move     #2,wrt_mode(a5) ;Invertier-Modus

       move     #639,d3         ;Schauen Sie sich das an,
       move     d3,d4
loop1  sub      d3,d4
       line     d3,#0,d4,#399
       move     #639,d4
       dbra     d3,loop1
       
       move     #399,d3         ;und probieren Sie es aus!
       move     d3,d4
loop2  sub      d3,d4
       line     #0,d4,#639,d3
       move     #399,d4
       dbra     d3,loop2
            
       move     #1,-(sp)       ;Warte auf Taste
       trap     #1
       addq.l   #2,sp  
       move     #0,-(sp)       ;Funktion TERM(inate)
       trap     #1

       end
