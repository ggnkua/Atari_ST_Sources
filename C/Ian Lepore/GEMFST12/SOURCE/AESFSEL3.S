
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*  Maintenance:
;*   04/07/89 v1.2: This source file is new with this version.
;*            Also, the calculation of the location of the prompt on the
;*            screen has been changed.  It was placed one boxchar height
;*            down on the screen, putting it right below the menu bar.
;*            This didn't look too good on a big-monitor system, so now
;*            it is calculated by centering the box, then subtracting a
;*            fixed offset from the centered Y to make it appear right
;*            above the fsel'er box.  The offset is 9 character heights,
;*            (plus 2 extra char heights for the prompt itself), less
;*            2 pixels (just to line everything up real neat).
;*========================================================================

          .include  "aesfast.sh"
          .include  "gemfast.sh"
          .extern   _gl_apversion
          .extern   aesblock

;*************************************************************************
;*
;* Small extended fsel manager routine.
;*   This version emulates the TOS 1.4 fsel_exinput only to the point of
;*   putting up a prompt with the dialog.  
;*
;*************************************************************************

;-------------------------------------------------------------------------
; fsel_smallexinput
;-------------------------------------------------------------------------

_fsel_smallexinput::

          .cargs    #8,.pinpath.l,.pinsel.l,.pbutton.l,.plabel.l
          link      a6,#-4

          move.w    _gl_apversion,d0         ; Check the AES version.  If
          cmp.w     #$0104,d0                ; it's $0104, we're running
          beq.s     .ramaes                  ; on the RAM-based TOS 1.4
          cmp.w     #$0130,d0                ; Else, if it's less than $0130
          blt       simu_exinput             ; we have to simulate exinput.
.ramaes:
          move.l    .plabel(a6),d0           ; Swap the button and prompt
          move.l    .pbutton(a6),.plabel(a6) ; string pointers to make the
          move.l    d0,.pbutton(a6)          ; addrin stuff contiguous.

          AControl  91,0,2,3                 ; AES v1.3 & up: fsel_exinput
          moveq.l   #-4,d2                   ; is a legal function, do it.
          lea       .pinpath(a6),a0          ; a0 -> addrin
          ACall     RET2HERE                 ; Call AES.

          move.l    .plabel(a6),d0           ; Swap the prompt string and
          move.l    .pbutton(a6),.plabel(a6) ; button pointers back to how
          move.l    d0,.pbutton(a6)          ; they were on entry.

          moveq.l   #-4,d1                   ; Return values from
          lea       .pbutton(a6),a1          ; intout[] array to caller
          jmp       (a0)                     ; via aes_return routine.

;*************************************************************************
;* Simulation stuff...
;*  The following is the object tree that displays the prompt on 
;*  pre-TOS 1.4 systems, and the code to display that box.
;*************************************************************************

;-------------------------------------------------------------------------
; Define variables which will be accessed as offsets from a5.
;  (Storage for these things is allocated in the text segment, below).
;-------------------------------------------------------------------------

          .abs                ; Define offsets from a5 base register...
          
prmpflag: ds.w      1         ; Flag: Has one-time object fixup been done?

treeptr:  ds.l      1         ; Ptr to tree: addrin for objc_draw() et. al.
azero:    ds.w      1         ; A handy zero.

dialstuf: ds.w      1         ; Here things get a little ugly: The storage 
          ds.w      2         ; from 'dialstuff' down is the intin array
prmpstob: ds.w      1         ; for form_dial(FMD_FINISH).  From prmpstob
prmpdpth: ds.w      1         ; down, it is also the intin array for
prmpclip: ds.w      4         ; objc_draw().

ABS_SZ    =  *                ; Size of the a5-relative storage block.

          .text

absstore: dcb.b     ABS_SZ,0  ; Set aside memory for the a5-relative block.

;-------------------------------------------------------------------------
; Define the TEDINFO and OBJECT structures for the prompt text. 
; (Macros for defining these things come from gemfast.sh).
;-------------------------------------------------------------------------

YSZ_PROMPT = 2
YSZ_FSEL   = 9
Y_OFFSET   = YSZ_PROMPT+YSZ_FSEL

prmptext: Teddef    0,0,0,3,0,TE_CNTR,$1180,0,1,31,0
prmptree: Treedef   text
          Objdef    ,-1,-1,-1,G_BOXTEXT,LASTOB,NORMAL,0,0,0,40,YSZ_PROMPT
          
;-------------------------------------------------------------------------
; This routine lets us call AES more quickly than going through the
; routines in AESCOMN (and is better tailored to our needs here).
;-------------------------------------------------------------------------
          
aes_icall:
           
          movep.l   d0,control+1(a4)    ; fill in the control array (!),
          move.l    a0,padrin(a4)       ; store the adrin ptr into aespb
          move.l    a1,pintin(a4)       ; store the intin ptr into aespb
          move.l    a2,pintout(a4)      ; store it into aespb
          move.l    a4,d1               ; move the aespb pointer to the
          move.w    #$C8,d0             ; interface register, also the AES
          trap      #2                  ; function code, call AES, return
          rts                           ; to the calling binding routine.

;-------------------------------------------------------------------------
; simu_exinput - Simulate an exinput call on pre-TOS 1.4 systems.
;-------------------------------------------------------------------------

simuregs  reg       a2-a5               ; Registers we use.

simu_exinput:

          movem.l   #simuregs,-(sp)     ; Save registers.
          lea       absstore(pc),a5     ; Load storage base register.
          lea       aesblock,a4         ; Load aesblock base register.
          
          tas       prmpflag(a5)        ; Has first-time object tree fixup
          bne.s     do_simulation       ; been done?  If so, continue below.
 
;-------------------------------------------------------------------------
; Do the one-time object tree fixup:
;
;  - Plug in the various static string pointers.
;  - Plug in a couple of static integer values.
;  - Call rsrc_obfix  for resolution-specific x/y/w/h fixup.
;  - Call form_center to center box in the x coord & calc the clip area.
;  - Call graf_handle to get the height of a boxchar, and use this height
;    as the ob_y of the prompt box (and the clip area).  It just so happens
;    that the AES menu bar is one 'boxchar' in height, so this guarantees
;    we never overlay the menu bar with our prompt.
;-------------------------------------------------------------------------
         
          lea       azero(a5),a1        ; To do fixup, set string pointers
          lea       prmptext(pc),a0     ; in TEDINFO and OBJECT structures.
          move.l    a1,te_ptmplt(a0)    ; The template and valid strings
          move.l    a1,te_pvalid(a0)    ; are NULL.  The ob_spec pointer
          lea       prmptree(pc),a3     ; in the tree must point to the
          move.l    a0,ob_spec(a3)      ; TEDINFO structure.
          move.l    a3,treeptr(a5)      ; Save the tree pointer.

          move.w    #MAX_DEPTH,prmpdpth(a5)   ; Set objc_draw max-depth.
          move.w    #FMD_FINISH,dialstuf(a5)  ; Set form_dial type.
          
          subq.l    #2,sp               ; allocate intout[1] 
          move.l    sp,a2               ; a2 -> intout
          lea       azero(a5),a1        ; a1 -> intin 
          lea       treeptr(a5),a0      ; a0 -> adrin
          AControl  114,1,1,1           ;    rsrc_obfix(prmptree,R_TREE);
          bsr       aes_icall           ; do it.
          addq.l    #2,sp               ; we don't care about intout[0].

          sub.w     #10,sp              ; Allocate intout[5] 
          move.l    sp,a2               ; a2 -> intout
          lea       treeptr(a5),a0      ; a0 -> addrin (prmptree)
          AControl  54,0,5,1            ;    form_center(prmptree, &stack);
          bsr       aes_icall           ; do it.
          addq.l    #2,sp               ; We don't care about intout[0],
          move.l    (sp)+,prmpclip(a5)  ; the rest of intout is the
          move.l    (sp)+,prmpclip+4(a5); clip rectangle, save it.

          sub.w     #10,sp              ; Allocate intout[5], make a2 point
          move.l    sp,a2               ; to it.  Do graf_handle(&stack).
          AControl  77,0,5,0            ; The only value we want back from
          bsr       aes_icall           ; the call is the height of a char
          addq.l    #4,sp               ; which is in intout[2], put that
          move.w    (sp)+,d0            ; in d0, throw everything else away.
          addq.l    #4,sp               ; Calc the placement of the prompt
          mulu      #Y_OFFSET,d0        ; box as Y_OFFSET characters up from
          subq.w    #2,d0               ; the current (centered) location,
          sub.w     d0,ob_y(a3)         ; set the ob_y value in the tree
          sub.w     d0,prmpclip+2(a5)   ; and clip rectange to this value.

;-------------------------------------------------------------------------
; Once the one-time stuff is done (and on all subsequent calls...) do
; the actual simulation of the TOS 1.4 exinput:
;
;  - Plug the prompt string pointer into the TEDINFO.
;  - The prompt string is placed in a box above the fsel dialog box on the
;    screen (but below the menu bar) before the system fsel'er is called.
;    The prompt is displayed inside a box, (it's a BOXTEXT object, which
;    is the entire tree).  The prompt is displayed with an objc_draw, and
;    removed by sending a redraw message (via form_dial).
;  - Call fsel_input() (the old one).
;  - Call form_dial() to send a redraw message to clear the prompt box.
;  - Return to caller.
;-------------------------------------------------------------------------

do_simulation:

          .cargs    #8,.pinpath.l,.pinsel.l,.pbutton.l,.plabel.l

          lea       prmptext(pc),a0     ; a0 -> te_ptext in TEDINFO.
          move.l    .plabel(a6),(a0)    ; Set prompt text pointer.
          
          subq.l    #2,sp               ; allocate intout[1]
          move.l    sp,a2               ; a2 -> intout
          lea       prmpstob(a5),a1     ; a1 -> intin
          lea       treeptr(a5),a0      ; a0 -> addrin
          AControl  42,6,1,1            ;    objc_draw(prmptree,R_TREE....);
          bsr       aes_icall           ; do it.
          addq.l    #2,sp               ; throw away intout[0].
          
          lea       -4(a6),a2           ; a2 -> intout
          lea       .pinpath(a6),a0     ; a0 -> addrin          
          AControl  90,0,2,2            ;    fsel_input(inpath, insel,...);
          bsr       aes_icall           ; do it.

          subq.l    #2,sp               ; allocate intout[1] for form_dial
          move.l    sp,a2               ; a2 -> intout
          lea       dialstuf(a5),a1     ; a1 -> intin
          AControl  51,9,1,0            ;    form_dial(FMD_FINISH,...);
          bsr       aes_icall           ; this sends a redraw message to
          addq.l    #2,sp               ; clean up our prompt text box.

          movem.l   (sp)+,#simuregs     ; Restore working regs.
          
          move.l    .pbutton(a6),a1     ; Return the values from
          move.w    -4(a6),d0           ; intout to the caller.
          move.w    -2(a6),(a1)
          unlk      a6
          rts

;         end of code

