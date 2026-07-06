;
; Startup code for Lattice C on the Atari
;
; tiny version: originally written for the menu shell 25-feb-86
;
; (c) Metacomco 1985
;
Min_Mem EQU     $0800                   ; 2k default memory allocation
Min_Stk EQU     $0400                   ; 1k minimum stack
Sys_Mem EQU     $1000                   ; 4k left for TOS
;
GEM_Shrk EQU    $4A                     ; TOS shrink memory function
GEM_Term EQU    $4C                     ; Terminate process fn
;
; text section
;
        TEXT
;
        XREF    main
        XREF    _stack
        XREF    _mneed
        XREF    rbrk
;
;       Enter here with address of base page on stack above return address.
;
        move.l  4(sp),a3                ; get address of base page in A3
;
; allocate space for memory allocation and stack
;
        move.l  $18(a3),d1              ; base of BSS
        add.l   $1c(a3),d1              ; add size of BSS for base of free memory
        move.l  sp,d0                   ; d0 = top of memory
        sub.l   _stack,d0               ; allow for declared stack size
        sub.l   d1,d0                   ; d0 = size of free memory
        move.l  _mneed,d2               ; d2 = requested memory
        bne.s   mem1                    ; if zero
        move.l  d0,d2
        sub.l   #Sys_Mem,d2             ; then leave some for TOS
        bra.s   mem3
mem1:
        bgt.s   mem2                    ; if > 0 get that much
        add.l   d0,d2                   ; if < 0 leave that much for TOS
mem2:
        cmp.l   #Min_Mem,d2             ; make sure we get at least the minimum
        bgt.s   mem3
        move.l  #Min_Mem,d2             ; set minimum memory size
mem3:
        move.l  d1,d3                   ; d3 = base of free memory
        sub.l   a3,d3                   ; d3 = size of program
        add.l   d2,d3                   ; add heap requirements
        add.l   _stack,d3               ; add stack requirements
        move.l  d3,-(sp)                ; length of retained memory
        move.l  a3,-(sp)                ; base of retained memory
        clr.w   -(sp)                   ; filler
        move.w  #GEM_Shrk,-(sp)         ; function code
        trap    #1                      ; Memory now shrunk
        tst.l   d0                      ; check it worked
        beq.s   mem4
        move.w  #-39,d0                 ; set no memory error
        bra.s   Abort
mem4:
        move.l  d2,d0                   ; d0 = size of heap
        move.l  d1,sp                   ; set up stack
        add.l   d2,sp                   ; add heap size
        add.l   _stack,sp               ; add stack size for new sp
        move.l  d1,_mbase               ; set base of memory
        move.l  d1,_mnext               ; set next pointer
        move.l  d0,_msize               ; set size
        jsr     rbrk
;
        jsr     main                    ; straight into main
;
        moveq   #0,d0
Abort:
        move.w  d0,-(sp)                set return code
        move.w  #GEM_Term,-(sp)         GEMDOS terminate function
Abort1:
        trap    #1                      should not return
        bra.s   Abort1
;
        XDEF    XCEXIT
;
XCEXIT:
        move.l  4(a7),d0                ; save return status
        bra.s   Abort
;
; data section
;
        DATA
;
        XDEF    _mbase,_mnext,_msize,_oserr
;
_mbase  DC.L    0                       ; base of memory pool
_mnext  DC.L    0                       ; next available memory location
_msize  DC.L    0                       ; size of memory pool
_oserr  DC.L    0
;
        END




