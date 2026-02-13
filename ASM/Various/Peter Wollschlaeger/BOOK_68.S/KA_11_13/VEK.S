* VEK   Vektor Trap 7 setzen

        pea      neu           ;Adresse der neuen Routine
        move     #39,-(sp)     ;Vektor 39 = Trap #7
        move     #5,-(sp)      ;BIOS-Funktion SETEXEC
        trap     #13           ;aufrufen
        addq.l   #8,sp
     
        trap     #7            ;der neue Trap

        move     #1,-(sp)      ;warte auf Taste
        trap     #1
        addq.l   #2,sp
        clr      -(sp)         ;und Return zum Desk
        trap     #1

neu     pea      msg           ;gebe Text aus
        move     #9,-(sp)
        trap     #1
        addq.l   #6,sp
        rte

        data
msg     dc.b     'Hier ist Trap #7 ',0
        end