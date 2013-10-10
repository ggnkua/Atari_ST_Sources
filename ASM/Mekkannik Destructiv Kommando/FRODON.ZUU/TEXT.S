
    **intro tres simple pour neophytes*
    ** by fifire from tst**
       move.w   #$20,-(sp)
       trap     #1
       addq.l   #6,-(sp)
       move.w   #$0,$ff8240
       move.w   #$333,$ff825e
       move.w   #$000,$ff8244
debut  move.l   #txt,-(sp)
       move.w   #9,-(sp)
       trap     #1
       addq.l   #6,sp
       move.w   #7,-(sp)
       trap     #1
       cmpi.b   #54,d0
       beq      hz1
       bne      fin
fin    move.w   #$0,$ff825e
       move.w   #$20,-(sp)
       trap     #1
       addq.l   #6,-(sp)
       move.w   #0,-(sp)
       trap     #1
hz1    move.w   #$20,-(sp)
       trap     #1
       addq.l   #6,-(sp)
       move.b   #$10,$ff820a
       move.w   #$20,-(sp)
       trap     #1
       addq.l   #6,-(sp)
       bra      fin

       
txt    dc.b    "**************************************",13,10
       dc.b    "*                 TST                *",13,10
       DC.B    "**************************************",13,10
       dc.b    13,10,"         PROUDLY PRESENT YOU:",13,10
       dc.b    "             THIS STUFF.",13,10,13,10
       DC.b    "Cracked by -THE BRAIN-.",13,10
       dc.b    "The others members of TST are:",13,10
       dc.b    "GLOOSH,IONIX,FIFIRE,RICUS,TOMSTAR and",13,10
       dc.b    "KIDFIRE (paix a leurs ames...).",13,10
       dc.b    "Just an hello to:",13,10
       dc.b    "THE REPLICANTS( FURY,DOM,SNAKE,ect),",13,10
       dc.b    "Steph from CST,Mandrax,TIK,BUB,THE",13,10
       DC.B    "SPYJACKCIE,and to you....",13,10
       dc.b    13,10,13,10,"       BABAILLE !!",13,10,13,10
       DC.B    "PRESS 6 for 60hz",13,10,0

   
