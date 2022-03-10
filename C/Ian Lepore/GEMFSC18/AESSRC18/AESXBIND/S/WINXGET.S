;*************************************************************************
;* WINXGET.S - Extended wind_get() binding.
;*************************************************************************

          .include  "aesfast.sh"
          
_winx_get::
          .cargs    #8,.handle,.field,.output.l

          link      a6,#-10
          AControl  104,2,5,0

          moveq.l    #-10,d2   
          lea       .handle(a6),a1
          ACall     RET2HERE

          move.l    .output(a6),a1
          lea       -10(a6),a0
          move.w    (a0)+,d0
          move.l    (a0)+,(a1)+
          move.l    (a0),(a1)
          tst.w     d0
          unlk      a6
          rts

