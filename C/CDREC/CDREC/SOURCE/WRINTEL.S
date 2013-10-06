; Motorola-Format -> Intel
;
              export    wri_long, wri_int

module        wri_long
              move.b    d0,(a0)+
              lsr.l     #8,d0
              move.b    d0,(a0)+
              lsr.l     #8,d0
              move.b    d0,(a0)+
              lsr.w     #8,d0
              move.b    d0,(a0)+
              rts
endmod

module        wri_int
              move.b    d0,(a0)+
              lsr.w     #8,d0
              move.b    d0,(a0)
              rts
endmod
