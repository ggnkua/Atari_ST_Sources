 ; Program Name: RELATIVE.S
 ;          aka: PRG_2AP.S

 move.l    up_1, d0
 move.l    up_2, d0
 move.l    #-4, d0

 move.l    #up_1-up_2,d0
 move.l    up_1-up_2, d0
 data
pointer:   dc.l  up_1
up_1:      dc.l  5
up_2:      dc.l  3
 end

