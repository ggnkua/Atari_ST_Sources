;*========================================================================
;* EVNXMULT.S - Extended evnt_multi() binding.
;*========================================================================

          .include  "aesfast.sh"

        abs                   ; XMULTI structure
msgbuf:   ds.w    8
mflags:   ds.w    1
mbclicks: ds.w    1
mbmask:   ds.w    1
mbstate:  ds.w    1
mm1flags: ds.w    1
mm1rect:  ds.w    4
mm2flags: ds.w    1
mm2rect:  ds.w    4
mtlocount:ds.w    1
mthicount:ds.w    1

mwhich:   ds.w    1
mmox:     ds.w    1
mmoy:     ds.w    1
mmobutton:ds.w    1
mmokstate:ds.w    1
mkreturn: ds.w    1
mbreturn: ds.w    1

          text

_evnx_multi::

          cargs     #4,.pmstruct.l

          AControl  25,16,7,1           ; Load control parms.
          lea       aesblock,a0         ; Load pointer to AES block, 
          movep.l   d0,control+1(a0)    ; fill in the control array (!),

          exg       a2,d2               ; save a2 register for Laser C.
          lea       .pmstruct(sp),a2    ; make double-indirect pointer
          move.l    a2,padrin(a0)       ; to msgbuf, store as adrin pointer.

          move.l    (a2),a2             ; get pointer to evnx_multi struct.

          lea       mflags(a2),a1       ; get pointer to intin part of
          move.l    a1,pintin(a0)       ; evnx_multi structure, store it.

          lea       mwhich(a2),a1       ; get pointer to intout part of
          move.l    a1,pintout(a0)      ; evnx_multi structure, store it.

          exg       a2,d2               ; restore a2 register.

          move.l    a0,d1               ; move the aespb pointer to the
          move.w    #$C8,d0             ; interface register, also the AES
          trap      #2                  ; function code, call AES.

          move.l    .pmstruct(sp),a0    ; get pointer to evnx_multi struct,
          move.w    mwhich(a0),d0       ; return event flags in d0, with
          rts                           ; CCR regs set for Laser C.

;         end of code

