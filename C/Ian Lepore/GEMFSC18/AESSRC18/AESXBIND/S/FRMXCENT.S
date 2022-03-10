;*************************************************************************
;* FRMXCENT.S - Extended form_center() binding.
;*************************************************************************

          .include  "aesfast.sh"
          
_frmx_center::
          .cargs    #8,.ptree.l,.prect.l

          link      a6,#-10
          AControl  54,0,5,1

          moveq.l    #-10,d2   
          lea       .ptree(a6),a0
          ACall     RET2HERE

          move.l    .prect(a6),a1
return4:
          lea       -10(a6),a0
          move.w    (a0)+,d0
          move.l    (a0)+,(a1)+
          move.l    (a0),(a1)
          tst.w     d0
          unlk      a6
          rts

;         end of code

