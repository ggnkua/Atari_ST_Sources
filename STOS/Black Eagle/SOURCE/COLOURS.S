       clr.l -(sp)
       move.w #$20,-(sp)
       trap #1
       add.l #6,sp
       move.l d0,up_save     

       move.w #0,$ff8240 
       move.w #$777,$ff8242 
       move.w #3,$ff8244 
       move.w #$770,$ff8246 
       move.l #txt,-(sp) 
       move.w #9,-(sp) 
       trap #1 
       addq.l #6,sp  
       move.l #100000,d0 
pause:
       dbra d0,pause 

       move.l up_save,-(sp)
       move.w #$20,-(sp)
       trap #1
       add.l #6,sp
    
       move.w #20,-(sp) 
       move.w #$4c,-(sp) 
       trap #1 
txt:   dc.b "BLACK EAGLE desktop colour changer",0 
up_save:ds.l 1
