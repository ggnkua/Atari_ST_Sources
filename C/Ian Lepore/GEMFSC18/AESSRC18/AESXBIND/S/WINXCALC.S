;*************************************************************************
;* WINXCALC.S - Extended wind_calc() binding.
;*************************************************************************

          .include  "aesfast.sh"
          
_winx_calc::
          .cargs    #8,.i1,.i2,.i3,.i4,.i5,.i6,.output.l

          link      a6,#-10

          AControl  108,6,5,0
          
          moveq.l   #-10,d2    
          lea       .i1(a6),a1
          ACall     RET2HERE

          move.l    .output(a6),a1
          lea       -10(a6),a0
          move.w    (a0)+,d0
          move.l    (a0)+,(a1)+
          move.l    (a0),(a1)
          tst.w     d0
          unlk      a6
          rts

;         end of code

