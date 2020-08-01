*************************************************************************
*                                                                       *
*    DSTART.S modifi‚ :  Startup module for C programs using dLibs      *
*                                                                       *
*************************************************************************
*
* entry points
*
.globl    __base              ; basepage pointer
.globl    __start             ; startup entry point
.globl    _etext              ; end of text segment
.globl    _edata              ; end of data segment
.globl    _end                ; end of BSS segment (end of program)
.globl    __break             ; location of stack/heap break
.globl    __exit              ; terminate immediately with exit code
.globl    __argc              ; number of arguments
.globl    __argv              ; argument list pointer
.globl    __envp              ; environment string pointer
.globl    _errno              ; system error number
.globl    _gemdos             ; trap #1 (gemdos) hook
.globl    _bios               ; trap #13 (bios) hook
.globl    _xbios              ; trap #14 (xbios) hook
.globl    _bdos               ; trap #2 (bdos) hook

*
* external references
*
.globl    __STKSIZ            ; Stack size value from C (unsigned long)
; .globl    __main              ; Initial entry point for C program
.globl    _main               ; C program main() function

*
* useful constants
*
MINSTK    equ       1024      ; Minimum 1K stack size
MARGIN    equ       512       ; Minimum memory to return to OS

*
* GEMDOS functions
*
Cconws    equ       $09       ; Console write string
Pterm     equ       $4C       ; Process terminate (with exit code)
Mshrink   equ       $4A       ; Shrink program space

*
* basepage offsets
*
p_hitpa   equ       $04       ; top of TPA
p_tbase   equ       $08       ; base of text
p_tlen    equ       $0C       ; length of text
p_dbase   equ       $10       ; base of data
p_dlen    equ       $14       ; length of data
p_bbase   equ       $18       ; base of BSS
p_blen    equ       $1C       ; length of BSS
p_env     equ       $2C       ; environment string
p_cmdlin  equ       $80       ; command line image

*
* STARTUP ROUTINE (must be first object in link)
*
          text
*
* save initial stack and basepage pointers
*
__start:  move.l    sp,a5               ; a5 = initial stack pointer
          move.l    4(sp),a4            ; a4 = basepage address
          move.l    a4,__base
          move.l    p_tbase(a4),d3
          add.l     p_tlen(a4),d3
          move.l    d3,_etext           ; end of text segment
          move.l    p_dbase(a4),d3
          add.l     p_dlen(a4),d3
          move.l    d3,_edata           ; end of data segment
          move.l    p_bbase(a4),d3
          add.l     p_blen(a4),d3
          move.l    d3,_end             ; end of BSS (end of program)
          move.l    d3,__break          ; set initial _break value
          move.l    p_env(a4),__envp    ; save environment pointer
*
* calculate free space available to program
*
          move.l    __break,d3
          move.l    d3,a3               ; a3 = base of free space
          neg.l     d3
          add.l     p_hitpa(a4),d3
          sub.l     #MARGIN,d3          ; d3 = free space
*
* calculate new stack size (store in d2)
*
          move.l    #__STKSIZ,a2        ; a2 = &_STKSIZ
          move.l    (a2),d2             ; if __STKSIZ is undefined
          beq       minimum             ;   use MINSTK
          bpl       setstk              ;   use __STKSIZ
          add.l     d3,d2               ; if __STKSIZ is negative
          cmp.l     #MINSTK,d2          ;   try (free space + __STKSIZ)
          bge       setstk              ; if < MINSTK
minimum:  move.l    #MINSTK,d2          ;   use MINSTK
*
* check to see if there is enough room for requested stack
*
setstk:   cmp.l     d3,d2
          blt       shrink              ; if (available < requested)
          move.l    #stkerr,-(sp)
          move.w    #Cconws,-(sp)
          trap      #1                  ;   report a stack error
          addq.l    #6,sp
          move.w    #-39,-(sp)
          move.w    #Pterm,-(sp)
          trap      #1                  ;   and return error -39 (ENSMEM)
*
* set up new stack pointer and Mshrink
*
shrink:   add.l     a3,d2               ; new stack = free base + stack size
          move.l    d2,sp
          sub.l     a4,d2               ; keep space = new stack - __base
          move.l    d2,-(sp)
          move.l    a4,-(sp)
          clr.w     -(sp)
          move.w    #Mshrink,-(sp)
          trap      #1                  ; Mshrink(0, _base, keep);
          add.l     #12,sp
*
* call C entry point function _main()
*
          jsr       _main

*
* void _exit(code)
*   int code;
*
* Terminate process with a return value of <code>
*
__exit:              ;tst.l     (sp)+   ; pop return PC off the stack
          move.w    #Pterm,-(sp)        ;   leaving <code>
          trap      #1                  ;   and terminate.
*
* operating system trap hooks for C

*
* long gemdos(function, [parameter, ...])
*   int function;
*
_gemdos:  move.l    (sp)+,traprtn       ; save return address
          trap      #1                  ; do gemdos trap
          bra       chkstk
*
* long bios(function, [parameter, ...])
*   int function;
*
_bios:    move.l    (sp)+,traprtn       ; save return address
          trap      #13                 ; do bios trap
          bra       chkstk
*
* long xbios(function, [parameter, ...])
*   int function;
*
_xbios:   move.l    (sp)+,traprtn       ; save return address
          trap      #14                 ; do xbios trap
          bra       chkstk
*
* int bdos(function, parameter)
*   int function;
*   long parameter;
*
_bdos:    move.l    (sp),traprtn        ; save return address
          move.l    a6,(sp)             ; save old frame pointer
          move.l    sp,a6               ; set up frame pointer
          tst.l     -(a6)               ;  (fake "link a6,#0")
          move.w    8(a6),d0            ; function code in D0.W
          move.l    10(a6),d1           ; parameter value in D1.L
          trap      #2                  ; do bdos trap
          move.l    (sp)+,a6            ; restore old frame pointer
*
* check for stack overflow (done after all OS traps)
*
chkstk:   cmp.l     __break,sp
          bgt       nosweat             ; if (_break > sp)
          move.l    #stkovf,-(sp)
          move.w    #Cconws,-(sp)
          trap      #1                  ; report a stack overflow
          addq.l    #6,sp
          move.w    #-1,-(sp)
          move.w    #Pterm,-(sp)
          trap      #1                  ; and return error -1 (ERROR)
nosweat:  move.l    traprtn,-(sp)       ; else, restore return address
          rts                           ; and do a normal return.
*
* this call to _main ensures that it the user's main() function will be
* linked, even if it is in a library.
*
          jsr       _main               ; NO PATH TO THIS STATEMENT

* THE FOLLOWING IS SELF MODIFYING CODE, DO NOT DISTURB
          move.l    #$644c6962,$7320(sp)
          moveq.l   #$31,d3
          move.l    $0(a2,d0),d7

*
* initialized data space
*
           .data
           .even
stkerr:   .dc.b       'Not enough memory',$d,$a,0
stkovf:   .dc.b       'Stack overflow',$d,$a,0

_errno:   .dc.w       0         ; system error number
__argc:   .dc.w       0         ; number of command line args
__argv:   .dc.l       0         ; pointer to command line arg list
*
* uninitialized data space
*
           .bss
           .even
__base:   .ds.l       1         ; pointer to basepage
_etext:   .ds.l       1         ; pointer to end of text segment
_edata:   .ds.l       1         ; pointer to end of data segment
_end:     .ds.l       1         ; pointer to end of BSS (end of program)
__break:  .ds.l       1         ; pointer to stack/heap break
__envp:   .ds.l       1         ; pointer to environment string
traprtn:  .ds.l       1         ; storage for return PC in trap hooks

           end
