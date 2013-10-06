 ; Program Name: COMBO.S
 ;          aka: PRG_2AC.S

 move.l    up_1(pc), d0
 move.l    up_2(pc), d0
 move.l    #-4, d0

 move.l    #up_1-up_2,d0  ; (pc) can't be used with the labels here.
 move.l    up_1-up_2, d0  ; (pc) can't be used with the labels here.
 data
pointer:   dc.l  up_1
up_1:      dc.l  5
up_2:      dc.l  3
 end

