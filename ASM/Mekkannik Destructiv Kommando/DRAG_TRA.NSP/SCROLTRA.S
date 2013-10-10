

scroh   movea.l #adscro,a5
        movea.l #buffer,a4  
        moveq   #23,d0
scro0   moveq   #19,d1
scro1   move.l  (a6)+,d2
        move.l  (a6)+,d3
        move.l  (a4)+,d4
        move.l  (a4)+,d5
        move.l  d2,d7
        or.l    d3,d7
        move.l  d7,d6
        swap    d6
        or.l    d6,d7
        not.l   d7
        and.l   d7,d4
        and.l   d7,d5
        or.l    d2,d4
        or.l    d3,d5
        move.l  d4,(a5)+
        move.l  d5,(a5)+
        
      
        dbra    d1,scro1
        dbra    d0,scro0
        rts
