 lea t(pc),a0
 lea tabledest(pc),a1
 move.l a1,a2
loop
 moveq #0,d0
 move.b (a0)+,d0
 swap d0
 move.b (a0)+,d0
 lsl.l #8,d0
 move.l d0,(a2)+
 move.l (a0)+,(a2)+
 addq.l #2,a0
 cmp.l a1,a0
 blt loop 
 rte
t
 incbin digitab.bin
tabledest