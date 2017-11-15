 moveq #1,d0
 clr.w player+$9e2
 jsr player
 move.l #player+8,$4d2
 rts
player:
 incbin cud_mus2.b
 end
