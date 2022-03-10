
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Graphics Library routines 2 of 5.
;*  The 3 routines here are together because graf_mouse and graf_handle 
;*  are used by virtually every GEM program, and graf_mkstate is avaiable 
;*  for free because its stack looks the same as graf_handle.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; graf_handle
; graf_mkstate
;-------------------------------------------------------------------------

_graf_handle::
          AControl  77,0,5,0
          bra.s     graf_hndstate
_graf_mkstate::
          AControl  79,0,5,0
graf_hndstate:
          .cargs    #8,.p1.l,.p2.l,.p3.l,.p4.l
          link      a6,#-10

          moveq.l   #-10,d2             ;  = intout
          ACall     RET2HERE
          
          moveq.l   #-10,d1
          lea       .p1(a6),a1
          jmp       (a0)
 
;-------------------------------------------------------------------------
; graf_mouse
;-------------------------------------------------------------------------

_graf_mouse::
          .cargs    #4,.num,.pform.l
          AControl  78,1,1,1
          lea       .num(sp),a1         ; -> intin
          lea       .pform(sp),a0       ; -> adrin
          ACall     RET2USER
          
;         end of code

