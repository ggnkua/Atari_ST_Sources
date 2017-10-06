
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"

;*************************************************************************
;*
;* Event manager routines 2 of 3.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; evnt_multi - everybody's favorite.
;-------------------------------------------------------------------------

_evnt_multi::

.flags    = 8
.pmbufold = 36
.pmbufnew = 40
.countlo  = 40
.counthi  = 42
.px       = 44
.py       = 48
.pbutton  = 52
.pstate   = 56
.pkreturn = 60
.pbreturn = 64

          link      a6,#-14

          move.l    .pmbufnew(a6),d0            ; Swap timer counts & buffer
          move.l    .pmbufold(a6),.pmbufnew(a6) ; pointer; puts all 'intin'
          move.l    d0,.pmbufold(a6)            ; parms together on stack.

          AControl  25,16,7,1
          
          moveq.l   #-14,d2             ;  = intout
          lea       .flags(a6),a1       ; -> intin
          lea       .pmbufnew(a6),a0    ; -> addrin

          ACall     RET2HERE

          move.l    .pmbufnew(a6),d0            ; Swap the counts & ptr back
          move.l    .pmbufold(a6),.pmbufnew(a6) ; because it isn't nice to
          move.l    d0,.pmbufold(a6)            ; munge the caller's stack.

          moveq.l   #-14,d1
          lea       .px(a6),a1
          jmp       (a0)

;         end of code

