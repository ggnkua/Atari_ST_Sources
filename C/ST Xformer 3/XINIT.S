
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   XINIT.S - new initialization code for Laser C for .TOS or .PRG files
;             that don't use streams or command lines
;           - replaces Laser C's INIT.O
;           - bindings for BIOS, XBIOS, and GEMDOS calls included
;           - supports desk accessories
;           - supports TSRs
;           - bindings TST D0 for C compatiblity
;
;   created 12/26/88 by Darek Mihocka
;
;   updated 10/12/90 23:00 djm
;
;   This must be the very first file linked!!!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Offsets into base page

ltpa    = 0         ; Low TPA address
htpa    = 4         ; High TPA address
lcode   = 8         ; Code segment start
codelen = 12        ; Code segment length
ldata   = 16        ; Data segment start
datalen = 20        ; Data segment length
lbss    = 24        ; Bss  segment start
bsslen  = 28        ; Bss  segment length
parent  = 36        ; parent's basepage
cmdline = 128       ; command line image

cbStack = 1024

    .globl _main

    .bss

_bss::
    ds.b    cbStack ; lets's have a stack
_topstack:
    ds.w    0

    .data

_data::
    dc.w    0       ; let's have a DATA segment

_stksize::
    dc.l    cbStack ; desired stack size is 4K

_errno::
    dc.l    0       ; error values get stuffed here

__topstack::
    dc.l    _topstack   ; top of the stack, just for interest

__base::
    dc.l    0       ; basepage address, for Laser C compatibility

    .if 0
saveA1:
    dc.l    0       ; save area for TRAPs
saveA2:
    dc.l    0
    .endif

_fAcc::
    dc.w    0       ; ACC/PRG flag

    .text

__main::            ; Laser C compatible name

    lea     __main-256(PC),a5   ; A5 = basepage address (works with .ACC)
    move.l  a5,__base
    lea     _topstack,a7

    tst.l   parent(a5)
    seq     _fAcc
    beq.s   .main

    move.l  codelen(a5),d0      ; compute total amount of memory req'd
    add.l   datalen(a5),d0
    add.l   bsslen(a5),d0
;    add.l   _stksize,d0         ; add stack size
    addi.l  #$100,d0            ; add basepage size
    move.l  d0,d1
    add.l   a5,d1               ; compute stack top
    and.w   #$fffe,d1           ; make sure it is even
;    movea.l d1,a7               ; set new stack pointer
;    move.l  d1,__topstack

    move.l  d0,-(a7)            ; shrink heap
    move.l  a5,-(a7)            ; by returning the rest to OS
    clr.w   -(a7)
    move.w  #$4a, -(a7)
    trap    #1                  ; Mshrink
    addq.l  #8,a7               ; adjust stack but leave D0 on stack

.main:
    jsr     _main               ; call main()
    clr.l   -(a7)
    trap    #1                  ; Pterm (0)
    illegal

; this is in case the program did an explicit exit()

_exit::
    addq.l  #4,a7               ; pop return address, return code is on stack
    clr.w   -(a7)
    trap    #1                  ; Pterm (return code)
    illegal

_term::
    move.l  (sp)+,d0            ; D0 contains total size of segments
    clr.w   -(sp)               ; return code is 0
    move.l  d0,-(sp)            ; size of memory block to keep
    move.w  #$31,-(sp)
    trap    #1                  ; Ptermres (), terminate and stay resident
    illegal

    .if 0

; bios(), xbios(), gemdos() bindings
;
;   - saves A1 and A2 for Laser C compatibility
;   - uses self modifying code, but it's quicker

_bios::
    move.l  a1,saveA1
    move.l  a2,saveA2
    move.l  (sp)+,.bios+2
    trap    #13
    move.l  saveA1,a1
    move.l  saveA2,a2
    tst.w   d0
.bios:
    jmp     $12345678

_xbios::
    move.l  a1,saveA1
    move.l  a2,saveA2
    move.l  (sp)+,.xbios+2
    trap    #14
    move.l  saveA1,a1
    move.l  saveA2,a2
    tst.w   d0
.xbios:
    jmp     $12345678

_gemdos::
    move.l  a1,saveA1
    move.l  a2,saveA2
    move.l  (sp)+,.gemdos+2
    trap    #1
    move.l  saveA1,a1
    move.l  saveA2,a2
    tst.w   d0
.gemdos:
    jmp     $12345678
    .endif

    .end

