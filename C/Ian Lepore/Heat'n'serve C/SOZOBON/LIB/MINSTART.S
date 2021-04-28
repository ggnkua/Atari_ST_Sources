;**************************************************************************
;
; DO NOT ASSEMBLE WITH JAS!!! A bug in JAS's handling of PC-relative
; operands causes runtime errors in the OS-interface routines.
;
; minstart.s   MINI-APPLICATION STARTUP PROGRAM
;
; This version contains ONLY what is necessary to start a C program up;
; C runtime support has been trashed (don't try to use printf, et al).
;
; The stacksize in this startup file is fixed at 2k.  You can't change it
; other than by tweaking the constant below and re-assembling the file.
; If anybody knows of a way to do dynamically-sized stacks at runtime in
; an ACC, please let me know.
;
; 08/12/89 - Added _accflag & code to make this startup file support ACCs.
;
; 08/26/91 - Modified .ACC detection per Ken Badertscher's info.  Now the
;            a0 reg at entry is used for detection: non-zero == ACC.
; 09/23/91 - Fixed glitch that was leaving stack pointer in high memory 
;            after we gave up that memory to DOS, when running as PRG.
;            Also, added __base and __envp, so that programs could access
;            env data and command line args, concepts which are useful
;            only when running as a PRG, of course.
;            Added stack cookie logic, and functions to query stack usage.
;**************************************************************************

STKSIZE   =         2048                ; MUST be multiple of 4!!!
STKCOOKIE =         $ECECECEC           ; for stacksize highwater check

;imports...

          .extern   _main               ; C-language main() function.

; exports...

          .globl    _gemdos,_bios,_xbios; glue functions
          .globl    __stkinuse,__stkused; utility functions
          
          .globl    __accflag           ; flag: are we running as .ACC?
          .globl    __base              ; -> basepage
          .globl    __envp              ; -> env data

          .bss
          .even
          .ds.b     STKSIZE-2           ; Stacksize in bytes, less the two
localstk: .ds.w     1                   ; bytes which are defined on this line.
stktop:   .ds.l     1                   ; pointer to top of runtime stack.
__base:   .ds.l     1                   ; pointer to basepage.
__envp:   .ds.l     1                   ; pointer to environement data.

          .data
          .even
__accflag:.dc.w     0                   ; Is this an ACC? Assume not.

          .text
_entry:
          nop                           ; room to force nullterm on cmdline.
          
          lea       _entry-256(pc),a6   ; load pointer to basepage, works with
          move.l    a6,__base           ; prg and acc, save the pointer for C.
          move.l    $2c(a6),__envp      ; store pointer to env data for C.

          move.l    a0,d0               ; test reg a0, if non-zero, we're
          bne.b     .acc                ; running as a .ACC.

          move.l    $c(a6),a0           ; Length of text.
          adda.l    $14(a6),a0          ; Length of data.
          adda.l    $1c(a6),a0          ; Length of bss.
          lea       256+STKSIZE(a0),a0  ; Basepage size plus stack size.

          lea       0(a0,a6.l),sp       ; load new stack pointer.

          move.l    a0,-(sp)            ; a0 holds bytes to keep,
          move.l    a6,-(sp)            ; starting at the basepage.
          clr.w     -(sp)               ; Junk word.
          move.w    #$4A,-(sp)          ; Function code.
          trap      #1                  ; Do Mshrink().
          lea       12(sp),sp           ; Clean up stack.
          bra.b     .startcommon        ; For programs, skip setting accflag...
.acc:
          lea       localstk,sp         ; Load new stack pointer.
          move.w    #1,__accflag        ; For ACCs, set accflag = TRUE.
.startcommon:
          move.l    sp,stktop           ; save stack pointer.
          lea       -STKSIZE(sp),a0     ; point to bottom of stack.
          move.w    #[STKSIZE/4]-1,d0   ; load count of longwords in stack.
          move.l    #STKCOOKIE,d1       ; load stack cookie value.
.stkcookies:
          move.l    d1,(a0)+            ; store cookie into stack area,
          dbra      d0,.stkcookies      ; feels so good, do it some more.

          clr.l     -(sp)               ; NULL envp to main()
          clr.l     -(sp)               ; NULL argv to main()
          clr.w     -(sp)               ; zero argc to main()
          jsr       _main               ; Go to program.
          clr.l     (sp)                ; Back to gemdos,
          trap      #1                  ; if _main returns.

;**************************************************************************
;       For GEMDOS, BIOS, or XBIOS calls from C (OSBIND.H)
;**************************************************************************

save_ret: .dc.l     0                   ; Return addr save for TOS calls.

_gemdos:  move.l    (sp)+,save_ret
          trap      #1
          move.l    save_ret(pc),-(sp)
          rts
_bios:    move.l    (sp)+,save_ret
          trap      #13
          move.l    save_ret(pc),-(sp)
          rts
_xbios:   move.l    (sp)+,save_ret
          trap      #14
          move.l    save_ret(pc),-(sp)
          rts

;*************************************************************************
;* stack usage detection functions...
;*************************************************************************

__stkinuse:                             ; how much stack is in use right now?
          move.l    stktop,d0
          sub.l     sp,d0
          rts

__stkused:                              ; what's the most stack used so far?

          move.l    stktop,a0           ; load pointer to top of runtime stack,
          move.l    #STKSIZE,d0         ; load stack size.
          sub.l     d0,a0               ; point to base of stack.
          moveq.l   #-1,d2              ; zero out cookie counter.
          move.l    #STKCOOKIE,d1       ; load cookie value
.countloop:
          addq.l    #1,d2               ; count this cookie.
          cmp.l     (a0)+,d1            ; compare this cookie.
          beq.s     .countloop          ; if equal, just keep counting.

          asl       #2,d2               ; change longword count to bytes.
          sub.l     d2,d0               ; subtract unchanged cookies count
          rts                           ; from stack size to get highwater.

          .end

