 ; Program Name: RELOCATE.S
 ;          aka: PRG_2AR.S

 move.l    up_1, d0
 move.l    up_2, d0
 move.l    #-4, d0        ; The statement below will resemble this one
                          ; after assembly.  Both are relocatable.
 move.l    #up_1-up_2,d0  ; This is Mr. Schulz's example.
 move.l    up_1-up_2, d0  ; I think he meant to use this type of example,
 data                     ; because this one does cause a problem.
pointer:   dc.l  up_1
up_1:      dc.l  5
up_2:      dc.l  3
 end

