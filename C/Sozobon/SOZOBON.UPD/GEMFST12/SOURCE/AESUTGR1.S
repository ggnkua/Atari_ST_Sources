
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*  04/05/89 - v1.2
;*             Added code to insure that the line-a base pointer is in A0
;*             before calling $A00x to turn mouse on & off.  This has
;*             never been needed before, but seems to be required under
;*             TOS 1.4.  Also, for the mouse-on call, the flag value in
;*             INTIN[0] is now properly set to non-zero, to indicate that
;*             we *don't* want the mouse 'forced' on regardless of the
;*             current depth of mouse-off calls.
;*========================================================================

;*************************************************************************
;*
;* Graphics routines 1 of n.
;*
;*************************************************************************
          
lineabase:dc.l      0         ; -> base addr of line-a's vars
noforce:  dc.w      1         ; flag: don't 'force' mouse on for $A009 call

linea_init:
          dc.w      $A000
          lea       lineabase(pc),a0
          move.l    d0,(a0)
          rts

;-------------------------------------------------------------------------
; graqon_mouse - Turn mouse on.
; graqof_mouse - turn mouse off.
;
;  These routines use the Line-A mouse on/off calls, and are a good bit
;  faster than graf_mouse(), but are *completely* non-standard.  They
;  are also pretty much untested. 
;
;   void graqon_mouse();
;   void graqof_mouse();
;-------------------------------------------------------------------------

_graqon_mouse::
          move.l    a2,-(sp)
          move.l    lineabase(pc),d0
          bne.s     .initdone
          bsr.s     linea_init
.initdone:
          move.l    d0,a0
          lea       noforce(pc),a1      ; a1 -> flag indicating that mouse
          move.l    a1,8(a0)            ; is not to be 'forced' on, put
          dc.w      $A009               ; pointer in line-a INTIN var.
          move.l    (sp)+,a2
          rts

_graqof_mouse::
          move.l    a2,-(sp)
          move.l    lineabase(pc),d0
          bne.s     .initdone
          bsr.s     linea_init
.initdone:
          move.l    d0,a0
          dc.w      $A00A
          move.l    (sp)+,a2
          rts

;-------------------------------------------------------------------------
; graq_mstate -  Get mouse state (x/y/buttons) quickly, via Line-A vars.
;
;  This routine is similar to graf_mkstate() in usage, except that the
;  keyboard state is not returned.  
;
;   void graq_mstate(&mousex, &mousey, &mousebtns);
;-------------------------------------------------------------------------


_graq_mstate::
          .cargs    #4,.pmx.l,.pmy.l,.pmb.l
          
          move.l    lineabase(pc),d0
          bne.s     .initdone
          move.l    a2,-(sp)
          bsr.s     linea_init
          move.l    (sp)+,a2
.initdone:
          move.l    d0,a0
          move.l    .pmx(sp),a1
          move.w    -602(a0),(a1)       ; GCURX
          move.l    .pmy(sp),a1
          move.w    -600(a0),(a1)       ; GCURY
          move.l    .pmb(sp),a1
          move.w    -596(a0),(a1)       ; MOUSE_BT
          rts 

;         end of code

