
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Application manager functions 1 of 2.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; appl_init
; appl_exit
;-------------------------------------------------------------------------

_appl_init::
          lea       aesblock,a0                 ; On an appl_init call we
          move.l    a0,a1                       ; do a one-time set up of
          moveq.l   #((SZ_AESBLK/2)-1),d0       ; the AES block.  This 
          moveq.l   #0,d1                       ; block contains the control
.clearloop:                                     ; and global arrays used by
          move.w    d1,(a1)+                    ; the AES. Start by clearing
          dbra      d0,.clearloop               ; the entire memory block.
          
          lea       control(a0),a1              ; Now get the offsets of the
          move.l    a1,pcontrl(a0)              ; control & global arrays
          lea       global(a0),a1               ; within the block, & store 
          move.l    a1,pglobal(a0)              ; them in the aespb part.
          
          AControl  10,0,1,0                    ; Set up the appl_init call.
          bra.s     appl_inout                  ; Continue at common code...
_appl_exit::
          AControl  19,0,1,0                    ; Set up the appl_exit call.
appl_inout:
          ACall     RET2USER                    ; Call AES, return to user.
          
;         end of code


