
;*========================================================================
;*
;* AESFAST Public Domain GEM bindings.
;*  Maintenance:
;*   02/11/89 v1.1: This source file is new with this version.
;*
;*   04/07/89 v1.2: 
;*            The calculation of the location of the prompt on the
;*            screen has been changed.  It was placed one boxchar height
;*            down on the screen, putting it right below the menu bar.
;*            This didn't look too good on a big-monitor system, so now
;*            it is calculated by centering the box, then subtracting a
;*            fixed offset from the centered Y to make it appear right
;*            above the fsel'er box.  The offset is 9 character heights,
;*            (plus 2 extra char heights for the prompt itself), less
;*            2 pixels (just to line everything up real neat).
;*
;*   07/22/89 v1.3:
;*            Bugfix...A 'bra.s' instruction was missing just before the
;*            'strcpy' routine, causing 4 bombs on a pre-1.4 machine.
;*========================================================================

          .include  "aesfast.sh"
          .include  "gemfast.sh"
          .extern   _gl_apversion
          .extern   aesblock

;*************************************************************************
;*
;* Extended fsel manager routine.
;*  (Including simulation routines for pre-TOS 1.4 systems).
;*
;*************************************************************************

;-------------------------------------------------------------------------
; fsel_exinput
;  This function is new with TOS 1.4, but this binding supports it in all
;  TOS/AES versions with a simulation of the new routine's actions if the
;  AES version we're running under is pre-TOS 1.4
;-------------------------------------------------------------------------

_fsel_exinput::

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
; The following code and data supports the exinput simulation routines.
;
; The simulator supports *most* of the TOS 1.4 features, to wit:
;
;  - A prompt string of up to 30 chars is displayed with the file selector.
;  - The file selector handles <CR> like TOS 1.4 does (see comments below).
;  - If the caller passes in a path with a leading '\' it will be appended
;    to the current default drive & path (and the whole resulting string
;    will be returned upon exit).
;  - The current DTA is preserved.
;  - The current drive and path is preserved.
;
; These are differences between the simulator and TOS 1.4:
;
;  - There are no drive buttons in the dialog.
;  - There is still a static limit of 100 files that can be displayed.
;  - Long pathnames are NOT handled correctly.
;  - Multiple abort/continue situations will still give problems.
;  - The redraw sequence of the dialog is still the same.
;
; The things not supported are, of course, things I can't affect without
; completely re-writing the fsel_input handler.
;*************************************************************************

;-------------------------------------------------------------------------
; Define variables which will be accessed as offsets from a3.
;  (Storage for these things will be allocated from the stack at runtime).
;-------------------------------------------------------------------------

          .abs                ; Define offsets from a3 base register...
          
savddrv:  ds.w      1         ; Save default drive.
savdpath: ds.b      128       ; Save default path.
savipath: ds.b      128       ; Save input path for compare after <CR>.
savdta:   ds.l      1         ; Save pointer to current DTA.
tmpdta:   ds.b      44        ; Temporary DTA for fsel_input to use.
SAV_SZ    =  *                ; Size of a3-relative storage.

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

lastkeyCR:ds.w      1         ; Flag: was last keystroke during fsel a <CR>?

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
; This routine is installed as a hook in the BIOS vector for the duration
; of the the fsel_input call.  It watches for a Bconin(2) call (which will
; be the AES asking for a character).  The Bconin call is done from in
; here such that we get the character back from the real BIOS and examine
; it.  If the character is a <CR>, we set the flag to say so and return
; the character to the caller.  If not a <CR> we clear the flag and 
; return the character.
;
; The whole reason for this is a bug in the pre-TOS 1.4 AES: If the user
; edited the path but didn't click the mouse on anything or change the
; filename field, then hit <CR>, the system returned a CANCEL status. This
; BIOS hook is the only way to tell for sure that the exit was via <CR>.
;-------------------------------------------------------------------------

oldbios:  dc.l      0         ; Old BIOS vector address.

bioshook:
          lea       6(sp),a0            ; Assume super mode caller.
          btst.b    #5,(sp)             ; Were we in super mode?
          bne.s     .supermode          ; No, user mode...
          move.l    usp,a0              ; So look at parms on user stack.
.supermode:
          move.l    #$00020002,d0       ; Bconin(2) function...
          cmp.l     (a0),d0             ; Is it that?
          bne.s     .biospunt           ; Nope, punt.

          move.l    d0,-(sp)            ; Stack Bconin(2) function code,
          bsr.s     .bioscall           ; Go get the character.
          addq.l    #4,sp
          
          lea       absstore(pc),a0     ; Point to common storage base.
          cmp.b     #'\r',d0            ; Is the char a <CR>? If so set the
          seq       lastkeyCR(a0)       ; flag, either way, return the char.
.biosreturn:  
          rte                           ; Return the char to the caller.

.bioscall:                              ; Call original BIOS, with return
          move.w    sr,-(sp)            ; to caller of 'bioscall'.
.biospunt:                              
          move.l    oldbios(pc),-(sp)   ; Not a BIOS function we handle,
          rts                           ; punt control to the real BIOS.
          
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
          bne       do_simulation       ; been done?  If so, continue below.
 
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

          bra.s     do_simulation       ; Continue with simulation below.

strcpy:
          move.b    (a0)+,(a1)+
          bne.s     strcpy
          rts

strcmp:
          move.b    (a0)+,d0
          beq.s     .checkdone
          cmp.b     (a1)+,d0
          beq.s     strcmp
          rts
.checkdone:
          tst.b     (a1)
          rts

;-------------------------------------------------------------------------
; Once the one-time stuff is done (and on all subsequent calls...) do
; the actual simulation of the TOS 1.4 exinput:
;
;  - Plug the prompt string pointer into the TEDINFO.
;  - The current default drive and path is saved.
;  - The current DTA address is saved, and a temporary DTA is installed.
;  - If the pathname passed to exinput starts with a '\', the passed-in
;    path is appended to the current default path.
;  - A hook is placed into the BIOS vector to watch for <CR> being hit,
;    so that we can mimick the new fsel's actions when just the pathname
;    is edited, and the user hits <CR> (to move to the filename field).
;  - The prompt string is placed in a box above the fsel dialog box on the
;    screen (but below the menu bar) before the system fsel'er is called.
;    The prompt is displayed inside a box, (it's a BOXTEXT object, which
;    is the entire tree).  The prompt is displayed with an objc_draw, and
;    removed by sending a redraw message (via form_dial).
;  - Call fsel_input() (the old one).
;  - Check to see if our BIOS hook set the flag saying a <CR> was the last
;    key hit.  If so, see if the pathname in the fsel dialog was changed.
;    If so, the user probably hit <CR> after typing the path (I always do),
;    so we loop back to do the fsel dialog again.  If the user clicked on
;    OK instead of hitting return, this won't happen.  Also, if the user
;    doesn't change the path (but perhaps does change the filename), then
;    hits return, we will not repeat the dialog.
;  - Call form_dial() to send a redraw message to clear the prompt box.
;  - Restore the current drive & path, and the old DTA.
;  - De-install the BIOS hook.
;  - Return to caller.
;-------------------------------------------------------------------------

do_simulation:

          .cargs    #8,.pinpath.l,.pinsel.l,.pbutton.l,.plabel.l

          sub.w     #SAV_SZ,sp          ; Allocate save area from stack,
          move.l    sp,a3               ; load save area base register.
                    
          move.w    #$19,-(sp)
          trap      #1
          addq.l    #2,sp
          move.w    d0,savddrv(a3)
          add.b     #'A',d0
          move.b    d0,savdpath(a3)
          move.b    #':',1+savdpath(a3)
          
          clr.w     -(sp)
          pea       2+savdpath(a3)
          move.w    #$47,-(sp)
          trap      #1
          addq.l    #8,sp
          
          tst.b     2+savdpath(a3)
          bne.s     .gotpath
          move.w    #$5C00,2+savdpath(a3)         ; 5C00 == "\<NULL>"

.gotpath:

          move.w    #$2F,-(sp)
          trap      #1
          move.l    d0,savdta(a3)
          addq.l    #2,sp

          pea       tmpdta(a3)
          move.w    #$1A,-(sp)
          trap      #1
          addq.l    #6,sp

          move.l    .pinpath(a6),a0     ; a0 -> input path
          lea       savipath(a3),a1     ; a0 -> path save area
          cmp.b     #'\\',(a0)          ; Leading '\' in input path?
          bne.s     .copypath           ; Nope, go do straight copy.
          lea       savdpath(a3),a0     ; Yep, so copy the current
          bsr       strcpy              ; default path to the save
          cmp.b     #'\\',-2(a1)
          bne.s     .noterm
          subq.l    #1,a1
.noterm:
          move.l    .pinpath(a6),a0     ; area first, then concat
          subq.l    #1,a1               ; the input path onto the 
          bsr       strcpy              ; end of it.  Since we changed
          lea       savipath(a3),a0     ; it in the save area, we need to
          move.l    .pinpath(a6),a1     ; copy it back to the input area.
.copypath:
          bsr       strcpy

          lea       prmptext(pc),a0     ; a0 -> te_ptext in TEDINFO.
          move.l    .plabel(a6),(a0)    ; Set prompt text pointer.
          
          subq.l    #2,sp               ; allocate intout[1]
          move.l    sp,a2               ; a2 -> intout
          lea       prmpstob(a5),a1     ; a1 -> intin
          lea       treeptr(a5),a0      ; a0 -> addrin
          AControl  42,6,1,1            ;    objc_draw(prmptree,R_TREE....);
          bsr       aes_icall           ; do it.
          addq.l    #2,sp               ; throw away intout[0].
          
          pea       bioshook(pc)
          move.w    #$2D,-(sp)
          move.w    #5,-(sp)
          trap      #13
          addq.l    #8,sp
          lea       oldbios(pc),a0
          move.l    d0,(a0)

.fsel_loop:

          clr.w     lastkeyCR(a5)       ; Clear <CR> flag.
          
          lea       -4(a6),a2           ; a2 -> intout
          lea       .pinpath(a6),a0     ; a0 -> addrin          
          AControl  90,0,2,2            ;    fsel_input(inpath, insel,...);
          bsr       aes_icall           ; do it.

          tst.w     lastkeyCR(a5)       ; Hack to fix an AES bug: If our
          beq.s     .fsel_done          ; BIOS hook says the last key was
          move.w    #1,-2(a6)           ; a CR, force the button to OK.

          move.l    .pinpath(a6),a0
          lea       savipath(a3),a1
          bsr       strcmp
          beq.s     .fsel_done
          
          move.l    .pinpath(a6),a0
          lea       savipath(a3),a1
          bsr       strcpy
          bra.s     .fsel_loop
          
.fsel_done:

          subq.l    #2,sp               ; allocate intout[1] for form_dial
          move.l    sp,a2               ; a2 -> intout
          lea       dialstuf(a5),a1     ; a1 -> intin
          AControl  51,9,1,0            ;    form_dial(FMD_FINISH,...);
          bsr       aes_icall           ; this sends a redraw message to
          addq.l    #2,sp               ; clean up our prompt text box.

          move.w    savddrv(a3),-(sp)
          move.w    #$0E,-(sp)
          trap      #1
          addq.l    #4,sp
          
          pea       savdpath(a3)
          move.w    #$3B,-(sp)
          trap      #1
          addq.l    #6,sp

          move.l    savdta(a3),-(sp)
          move.w    #$1A,-(sp)
          trap      #1
          addq.l    #6,sp

          move.l    oldbios(pc),-(sp)
          move.w    #$2D,-(sp)
          move.w    #5,-(sp)
          trap      #13
          addq.l    #8,sp

          add.w     #SAV_SZ,sp          ; Deallocate save area from stack.
          movem.l   (sp)+,#simuregs     ; Restore working regs.
          
          move.l    .pbutton(a6),a1     ; Return the values from
          move.w    -4(a6),d0           ; intout to the caller.
          move.w    -2(a6),(a1)
          unlk      a6
          rts

;         end of code

