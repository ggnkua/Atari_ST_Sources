
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Resource manager routines 1 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; rsrc_load
;-------------------------------------------------------------------------

_rsrc_load::
          .cargs    #4,.ptr.l
          AControl  110,0,1,1
          lea       .ptr(sp),a0       ; -> addrin
          ACall     RET2USER
          
;-------------------------------------------------------------------------
; rsrc_free
;-------------------------------------------------------------------------

_rsrc_free::
          AControl  111,0,1,0
          ACall     RET2USER

;-------------------------------------------------------------------------
; rsrc_gaddr - The one AES function that uses 'addrout'...
;-------------------------------------------------------------------------

_rsrc_gaddr::
          .cargs    #8,.type,.idx,.paddr.l
          link      a6,#-2
          
          lea       aesblock,a0             ; Since this function uses
          move.l    .paddr(a6),padrout(a0)  ; 'addrout', we will set it &
          move.w    #1,sadrout(a0)          ; 'sintout' here (into aespb).

          AControl  112,2,1,0

          moveq.l   #-2,d2    
          lea       .type(a6),a1
          ACall     RET2HERE
          
          lea       aesblock,a0         ; Put sadrout and sintout back to
          clr.l     padrout(a0)         ; zero, since all other functions
          clr.w     sadrout(a0)         ; assume they will always be zero.
          
          move.w    -2(a6),d0
          unlk      a6
          rts
          
;         end of code

