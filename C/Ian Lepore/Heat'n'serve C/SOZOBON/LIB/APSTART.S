;**************************************************************************
;
; apstart.s   APPLICATION STARTUP PROGRAM
;
; This version only contains what is necessary for a application to run.
; C runtime support has been trashed or re-written, implying that you
; usually can't link 'gemlib' using this startup.
;
;    Modified 03/22/87          (Ian Lepore) 
;         >Stack size doubled (now 2k).
;         >The functions _gemdos, _bios, _xbios were added to eliminate
;          the need to link OSBIND.O.
;
;    Modified 09/20/87          (Ian Lepore)
;         >Stack is now set via calc at startup, instead of being static
;          in the BSS area. (Seems cleaner, somehow).
;         >The heap/stack, & all registers are zeroed, as a debugging aid.
;         >This startup code now builds and passes ARGC and ARGV as
;          Alcyon C expects to find it.
;    Modified 10/05/87          (Ian again)
;         >Added _trap0 (callable from C) for debugging things.
;         >Added __base (accessable from C), handy for Ptermres() from C.
;    Modified 10/13/87          (Ian again)
;         >Fixed bug in which d0 was supposed to hold the number of bytes
;          to keep for Mshrink, but was being trashed by the routine
;          which builds argv/argc.
;    Modified 01/11/88          (I'm gonna stop putting my name here).
;         >Fixed major bugs involving argv/argc, dynamic allocation, etc.
;          (Essentially it's usable again.)  
;         >Added hack to allow C program to set stacksize by defining
;          the variable ___stksz in the data section, and initializing
;          it to something non-zero at definition time.
;         >Moved '_ctrl_cnts' array used by AES to AESBIND library,
;          where it should have been in the first place.
;         >Also, removed all of Atari's copyrights, etc, since this code 
;          no longer bears any resemblance to the original startup code.
;    Modified 04/28/90
;         >Added __envp for use with getenv()/putenv().
;         >Converted to Madmac format.
;**************************************************************************

STACKSIZE = 2048                        ; Default stacksize in bytes.

          .globl    _main,__base,__heap,___stksz
          .globl    __envp
          .globl    _crystal
          .globl    _gemdos,_bios,_xbios
          .globl    _trap0

          .text

          nop                           ; Room to force cmdlin null-term.

          move.l    4(sp),a6            ; Basepage address.
          move.l    a6,__base           ; Handy to have globaly available.
          move.l    44(a6),__envp       ; Pointer to env used by get/putenv.
          
          move.l    $c(a6),d0           ; Length of text
          add.l     $14(a6),d0          ; Length of data
          add.l     $1c(a6),d0          ; Length of bss
          add.l     #$100,d0            ; Length of base page

          lea       0(a6,d0.l),a5       ; Bottom-of-heap is basepage
          move.l    a5,__heap           ; address + above sizes.

          tst.l     ___stksz            ; Has C code defined and init'd 
          bne.s     setstack            ; a stacksize at compile/link 
          move.l    #STACKSIZE,___stksz ; time?  No -- supply default.
setstack: add.l     ___stksz,d0         ; Top-of-stack is basepage 
          lea       0(a6,d0.l),sp       ; addr + above sizes + stacksize.

          move.l    d0,-(sp)            ; d0 holds bytes to keep,
          move.l    a6,-(sp)            ; starting at the basepage.
          move.w    #0,-(sp)            ; Junk word.
          move.w    #$4A,-(sp)          ; Function code.
          trap      #1                  ; Do Mshrink()
          lea       12(sp),sp           ; Clean up stack.

          move.l    a5,a0               ; Set up to clear heap/stack.
          move.l    #0,d1               ; Use quick register-store of 0's.
          move.l    #(STACKSIZE/4)-1,d0 ; Clear the heap/stack area -- 
stkloop:  move.l    d1,(a0)+            ; handy for debugging,
          dbra      d0,stkloop          ; and it doesn't take long.

          move.l    a5,a0               ; a0 -> argv (on heap).
          move.l    a0,-(sp)            ; Put ptr to argv on stack.
          move.w    #1,-(sp)            ; Always 1 arg available: program
          move.l    #Cruntime,(a0)+     ; name which is 'C runtime'.

          add.l     #128,a6             ; a6 -> cmdline in basepage.
          move.b    (a6)+,d1            ; d0 =  cmdline length.
          beq.s     argvdone            ; If length = 0, we're done.

argvl1:   cmp.b     #' ',(a6)           ; Argv loop 1: cruise thru
          bne.s     argvfnd             ; blank chars until non-blank
argvl3:   add.l     #1,a6               ; is found or we run out of
          subq.b    #1,d1               ; chars.
          bne       argvl1
          bra.s     argvdone
argvfnd:  move.l    a6,(a0)+            ; Argv: found a non-blank char,
          add.w     #1,(sp)             ; save a pointer to it in argv[n]
argvl2:   addq.l    #1,a6               ; >> Hacked this in 07/22/88 <<
          subq.b    #1,d1               ; & count it. Argv loop 2: cruise
          beq.s     argvdone            ; thru non-blank chars until a 
          cmp.b     #' ',(a6)           ; space is found or we run out of
          bgt       argvl2              ; chars.  When a space is found,
          move.b    #0,(a6)             ; put a NULL there to keep C
          bra       argvl3              ; happy, then go back to cruise
argvdone: move.b    #0,(a6)             ; the blanks again.

          movem.l   (a0),d1-d7/a1-a6    ; Zap all registers except d0/a0.

          jsr       _main               ; Go to program

          move.l    #0,-(a7)            ; Back to gemdos
          trap      #1

;
;    For debugging
;
_trap0:   trap #0
          rts

;
;       For GEMAES calls from AESBIND.ARC or cryslib.o
;
_crystal:
          move.l    4(sp),d1
          move.w    #200,d0
          trap      #2
          rts
;
;       For GEMDOS, BIOS, or XBIOS calls from C (OSBIND.H)
;
_gemdos:  move.l    (sp)+,save_ret
          trap      #1
          move.l    save_ret,-(sp)
          rts
_bios:    move.l    (sp)+,save_ret
          trap      #13
          move.l    save_ret,-(sp)
          rts
_xbios:   move.l    (sp)+,save_ret
          trap      #14
          move.l    save_ret,-(sp)
          rts

          bss

__base:   ds.l      1                   ; Pointer to basepage, for C.
__heap:   ds.l      1                   ; Pointer to heap, for C.
__envp:   ds.l      1                   ; Pointer to env area.
save_ret: ds.l      1                   ; Return addr save for TOS calls.

          data
          comm      ___stksz,4          ; Runtime stacksize is common.
Cruntime: dc.b      'C runtime',$0      ; Bogus program name.


