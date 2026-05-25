          section   text
druck:
          move.l    4(sp),a0      ;varptr(sp%(0))
          move.l    8(sp),a1      ;varptr(dr$)
          move.w    12(sp),d0     ;L% =(Zeilennummer)
          muls      #3,d0
          adda.l    d0,a0
          move.l    a0,a2
          move.l    #1279,d1
          moveq     #2,d0 
l0:
          move.b    (a0)+,(a1)+   
          dbra      d0,l0(pc)
          adda.l    #100,a2
          move.l    a2,a0
          moveq     #2,d0
          dbra      d1,l0(pc)

          rts
          end             
