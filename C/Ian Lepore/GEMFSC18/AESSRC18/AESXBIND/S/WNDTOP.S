;*************************************************************************
;* WNDTOP.S - The wnd_top() function.
;*            This critter is somewhere between a utility and a binding.
;*************************************************************************

          .include  "aesfast.sh"
          
_wnd_top::
          .cargs    #8,.handle
          link      a6,#-10             ; allocate intout[5]
        
          move.w    #10,-(sp)           ; WF_TOP
          clr.w     -(sp)               ; dummy window handle
          move.l    sp,a1               ; a1 -> intin

          AControl  104,2,5,0

          moveq.l    #-10,d2            ; d2 = intout offset   
          ACall     RET2HERE

          move.w    -8(a6),d0           ; move wi_gw1 (top window)
          tst.w     d0                  ; to retval register.
          unlk      a6
          rts

