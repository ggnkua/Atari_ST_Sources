
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*
;*  Maintenance:
;*   02/10/89 v1.10 - This file is new with this release.  These are the
;*                    two infamous 'undocumented' functions that have been
;*                    available in all versions of TOS, but nobody said so.
;*========================================================================

          .include  "aesfast.sh"
          
;*************************************************************************
;*
;* Form Manager routines 2 of 3.
;*
;*************************************************************************

;-------------------------------------------------------------------------
; form_button
;-------------------------------------------------------------------------

_form_button::
          .cargs    #8,.ptree.l,.obj,.clicks,.pnxtobj.l

          link      a6,#-4
          
          AControl  56,2,2,1

          moveq.l   #-4,d2       
          lea       .ptree(a6),a0       ; -> addrin
          lea       .obj(a6),a1         ; -> intin
          ACall     RET2HERE
          moveq.l   #-4,d1
          lea       .pnxtobj(a6),a1
          jmp       (a0)
          
;-------------------------------------------------------------------------
; form_keybd
;-------------------------------------------------------------------------

_form_keybd::
          .cargs    #8,.ptree.l,.obj,.nxtobj,.thechar,.pnxtobj.l,.pchar.l

          link      a6,#-6
               
          move.l    .nxtobj(a6),d0      ; The order of nxtobj/thechar are
          swap      d0                  ; reversed on the stack compared to
          move.l    d0,.nxtobj(a6)      ; how they are in intin[]. Fix 'em.

          AControl  55,3,3,1

          moveq.l   #-6,d2       
          lea       .ptree(a6),a0       ; -> addrin
          lea       .obj(a6),a1         ; -> intin
          ACall     RET2HERE

          move.l    .nxtobj(a6),d0      ; Since it isn't nice to trash the
          swap      d0                  ; caller's stack parms, swap
          move.l    d0,.nxtobj(a6)      ; nxtobj/thechar back how they were.

          moveq.l   #-6,d1
          lea       .pnxtobj(a6),a1
          jmp       (a0)

;         end of code


