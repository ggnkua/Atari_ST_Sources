; custom, minimal startup for C code
;(c)2011 Mariusz Buras (all), Pawel Goralski (modifications for C)

REDIRECT_OUTPUT_TO_SERIAL   equ 0   ;0-output to console,1-output to serial port

        xdef    _exit
        xdef    _memcpy
        xdef    _strlen
        xdef    _strcmp
        xdef    _strstr
        xdef    ___mulsi3
        xdef    ___udivsi3
        xdef    ___umodsi3
        xdef    ___modsi3
        xdef    ___divsi3

BASEPAGE_SIZE   equ $100
STACK_SIZE      equ $1000
;reduced stack size from 64 KiB to 4 kiB

; --------------------------------------------------------------
start:
        move.l  4(sp),a5                ;address to basepage
        move.l  $0c(a5),d0              ;length of text segment
        add.l   $14(a5),d0              ;length of data segment
        add.l   $1c(a5),d0              ;length of bss segment
        add.l   #STACK_SIZE+BASEPAGE_SIZE,d0        ;length of stackpointer+basepage
        move.l  a5,d1                   ;address to basepage
        add.l   d0,d1                   ;end of program
;        and.b   #$f0,d1                 ;align stack
        lea     basepage(pc),a0
        move.l  a5,(a0)+
        move.l  d1,sp                   ;new stackspace
        move.l  d0,-(sp)                ;mshrink()
        pea     (a5)                    ;start of the block, note that ALL other implementations
                                        ;assume basepage = start of the block. That's wrong.
        clr.w   -(sp)
        move.w  #$4a,-(sp)              ;mshrink()
        trap    #1
        lea.l   12(sp),sp

;########################## redirect output to serial
        if (REDIRECT_OUTPUT_TO_SERIAL==1)
        ; redirect to serial
        move.w #2,-(sp)
        move.w #1,-(sp)
        move.w #$46,-(sp)
        trap #1
        addq.l #6,sp
        endif

        jsr _main

_exit:
;       move.w #1,-(sp)
;       trap #1
;       addq.l #2,sp

;check if the dta exists. If yes, it means that the program was loaded normally, otherwise,
;it means that the program was loaded with the bootloader.
;If loaded normally, exits normally
;If loaded with bootloader, try to execute the bootsector.

        move.l  basepage(pc),a5         ;basepage
        tst.l   $24(a5)                 ;dta exists ?
        beq.s   .bootsector
        clr.w   -(sp)                   ;Pterm
        trap #1
.bootsector:
        pea     (a5)                    ;mfree the block
        move.w  #$49,-(sp)
        trap    #1
        addq.l  #6,sp

        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1
        move.l  d0,sp                   ;restore the old stack

        move.l  $4c6.w,a3               ;a3: adress to load boot sector to
        move.w  $446.w,-(sp)            ;dev: _bootdev
        pea     $10000                  ;recno=0, count=1
        pea     (a3)                    ;buf
        pea     $40000                  ;mode=0, rwabs
        trap    #13                     ;rwabs
        lea     14(sp),sp

        moveq   #0,d0
        move    #512/2-1,d1
.chksum:add.w   (a3)+,d0
        dbra    d1,.chksum
        cmp.w   #$1234,d0
        bne.s   .noexe
        jmp     -512(a3)                ;jump, so the rts of the bootsector will return to TOS

.noexe:    rts
basepage:  dc.l 0

; --------------------------------------------------------------
_memcpy:
        move.l  d2,-(sp)
        move.l  4+4(sp),a0      ;a0=source
        move.l  4+8(sp),a1      ;a1=dest
        move.l  4+12(sp),d2     ;d2=length

        cmp.l   #16,d2
        blo.b   .inf16

        move.l  a0,d0
        move.l  a1,d1
        and.b   #1,d0
        and.b   #1,d1
        cmp.b   d0,d1
        bne.b   .oddcp

        move.l  a0,d0
        tst.b   d1
        beq.b   .alig
            ;both addr are odd
        move.b  (a1)+,(a0)+
        subq.l  #1,d2
.alig:
        moveq   #3,d1
        and.l   d2,d1
        sub.l   d1,d2
;=barrier
.c:
        move.l  (a1)+,(a0)+
        subq.l  #4,d2
        bne.b   .c
        move.w  d1,d2
        bra.b   .remai

.oddcp: cmp.l   #$10000,d2
        blo.b   .inf16
        move.l  a0,d0
.c2:
        move.b  (a1)+,(a0)+
        subq.l  #1,d2
        bne.b   .c2
        bra.b   .end

.inf16:
        move.l  a0,d0
.remai:
        subq.w  #1,d2
        blo.b   .end
.c3:
        move.b  (a1)+,(a0)+
        dbf     d2,.c3

.end:
        move.l  (sp)+,d2
        rts

; --------------------------------------------------------------
;
;_strcpy:
;        move.l    4(sp), a0
;        move.l    8(sp), a1
;
;l1:     move.b    (a1)+, (a0)+
;        bne.s     l1
;        rts

; --------------------------------------------------------------

_strlen:
        move.l    4(sp), a0
        moveq     #0,d0
        bra.s     .l1
.l2:    addq.l    #1,d0
.l1:    tst.b     (a0)+
        bne.s     .l2
        rts

; --------------------------------------------------------------

_strcmp:
;from https://code.google.com/p/plan9front/source/browse/sys/src/libc/68000/strcmp.s?r=9123bbc7c967e80c38003f42bd47911db953aa75
        move.l    4(sp),a0
        move.l    8(sp),a1
.next:  move.b    (a1)+,d0
        beq.s     .end
        cmp.b     (a0)+,d0
        beq.s     .next
        bcs.s     .gtr
        moveq     #-1,d0
        rts
.gtr:   moveq     #1,d0
        rts
.end:   tst.b     (a0)
        bne.s     .gtr
        moveq     #0,d0
        rts

; --------------------------------------------------------------

_strstr:
; this code is 52 bytes bigger than the c implementation. But it is way faster.
;from http://cristi.indefero.net/p/uClibc-cristi/source/tree/ff250619f58caa6b10c951911c43fbb8a34fda8d/libc/string/strstr.c
            movem.l 4(sp),a0-a1
            movem.l d2/a2-a3,-(sp)
;a0: aystack
;a1: needle (>=1 char string)

            move.b  (a1),d1             ; d1: neddle0
            beq.s   .ret1
            subq.l  #1,a0
.do1:       addq.l  #1,a0
            move.b  (a0),d2             ; d2: haystack0
            beq.s   .ret0
            cmp.b   d2,d1
            bne.s   .do1

            addq.l  #1,a1
            move.b  (a1)+,d2            ;d2: needle1
            beq.s   .ret1
            bra.s   .jin

.for:
.do2:       addq.l  #1,a0
            move.b  (a0),d0             ;d0: haystack1
            beq.s   .ret0
            cmp.b   d0,d1
            beq.s   .do2break
            addq.l  #1,a0
            move.b  (a0),d0
            beq.s   .ret0
.shloop:    cmp.b   d0,d1
            bne.s   .do2

.do2break:
.jin:       addq.l  #1,a0
            move.b  (a0),d0
            beq.s   .ret0
            cmp.b   d0,d2
            bne.s   .shloop

            move.l  a0,a2               ;a2: rhaystack
            addq.l  #1,a2
            subq.l  #1,a0
            move.l  a1,a3               ;a3: rneedle
            move.b  (a3),d0

            cmp.b   (a2),d0
            bne.s   .endif
.do3        tst.b   d0
            beq.s   .ret1
            addq.l  #1,a1
            move.b  (a1),d0
            addq.l  #1,a2
            cmp.b   (a2),d0
            bne.s   .do3break
            tst.b   d0
            beq.s   .ret1
            addq.l  #1,a1
            move.b  (a1),d0
            addq.l  #1,a2
            cmp.b   (a2),d0
            beq.s   .do3
.do3break:
.endif:      move.l  a3,a1
            tst.b   d0
            bne.s   .for

.ret1:       move.l   a0,d0
            bra.s   .ret
.ret0:       moveq   #0,d0
.ret:        movem.l (sp)+,d2/a2-a3
            rts

; --------------------------------------------------------------

___mulsi3:
;from http://svn.opentom.org/opentom/trunk/linux-2.6/arch/m68knommu/lib/mulsi3.S
;      move.w   4(sp),d0            ; x0 -> d0          12
;      mulu     10(sp),d0           ;x0*y1              78
;      move.w   6(sp),d1            ; x1 -> d1          12
;      mulu     8(sp),d1            ;x1*y0              78
;      add.l    d1,d0               ;                    6 (upx: add.w)
;      swap     d0                  ;                    4
;      clr.w    d0                  ;                    4
;      move.w   6(sp),d1            ;/* x1 -> d1 */     12
;      mulu.w   10(sp),d1           ;/* x1*y1 */        78
;      add.l    d1,d0               ;                    6
;      rts                          ;                  290

; from upx-ucl-3.08/src/stub/src/m68k-atari.tos.S
    ;// compute high-word
        lea     4(sp),a0            ;                    8
        move.w  (a0)+,d1            ;                    8
        move.w  (a0)+,d0            ;                    8
        mulu.w  (a0)+,d0            ;                   74
        mulu.w  (a0),d1             ;                   74
        add.w   d1,d0               ;                    4
        swap    d0                  ;                    4
        clr.w   d0                  ;                    4
    ;add low-word                   ;
        move.w  6(sp),d1            ;                   12
        mulu.w  (a0),d1             ;                   74
        add.l   d1,d0               ;                    6
        rts                         ;                  274


; --------------------------------------------------------------

;from http://svn.opentom.org/opentom/trunk/linux-2.6/arch/m68knommu/lib/umodsi3.S
___umodsi3:
    move.l  8(sp),d1        ;/* d1 = divisor */
    move.l  4(sp),d0        ;/* d0 = dividend */
    move.l  d1,-(sp)
    move.l  d0,-(sp)
    bsr.s   ___udivsi3
                            ;delayed popping: 8
    move.l  8+8(sp),-(sp)   ;/* d1 = divisor */
    move.l  d0,-(sp)
    bsr.s   ___mulsi3       ;/* d0 = (a/b)*b */
    lea     16(sp),sp       ;delayed popping: 0
    move.l  4(sp),d1        ;/* d1 = dividend */
    sub.l   d0,d1           ;/* d1 = a - (a/b)*b */
    move.l  d1,d0
    rts

; --------------------------------------------------------------

;from http://svn.opentom.org/opentom/trunk/linux-2.6/arch/m68knommu/lib/modsi3.S
;(modified)
___modsi3:
    move.l  8(sp),d1        ;/* d1 = divisor */
    move.l  4(sp),d0        ;/* d0 = dividend */
    move.l  d1,-(sp)
    move.l  d0,-(sp)
    bsr.s   ___divsi3
                            ;delayed popping: 8
    move.l  8+8(sp),-(sp)   ;/* divisor */
    move.l  d0,-(sp)
    bsr.s   ___mulsi3       ;/* d0 = (a/b)*b */
    lea     16(sp),sp       ;delayed popping: 0
    move.l  4(sp), d1       ;/* d1 = dividend */
    sub.l   d0,d1           ;/* d1 = a - (a/b)*b */
    move.l  d1,d0
    rts

; --------------------------------------------------------------

;from http://www.koders.com/noncode/fid355C9167E5496B5F863EAEB5758B4236711466D2.aspx
___udivsi3:
;#if !(defined(__mcf5200__) || defined(__mcoldfire__))
    move.l  d2,-(sp)
    move.l  4+8(sp),d1      ;/* d1 = divisor */
    move.l  4+4(sp),d0      ;/* d0 = dividend */

    cmp.l   #$10000,d1      ;/* divisor >= 2 ^ 16 ?   */
    bcc.s   L3              ;/* then try next algorithm */
    move.l  d0,d2
    clr.w   d2
    swap    d2
    divu    d1,d2           ;/* high quotient in lower word */
    move.w  d2,d0           ;/* save high quotient */
    swap    d0
    move.w  4+6(sp),d2      ;/* get low dividend + high rest */
    divu    d1,d2           ;/* low quotient */
    move.w  d2,d0
    bra.s   L6

L3: move.l  d1,d2           ;/* use d2 as divisor backup */
L4: lsr.l   #1,d1           ;/* shift divisor */
    lsr.l   #1,d0           ;/* shift dividend */
    cmp.l   #$10000,d1      ;/* still divisor >= 2 ^ 16 ?  */
    bcc.s   L4
    divu    d1,d0           ;/* now we have 16 bit divisor */
    and.l   #$ffff,d0       ;/* mask out divisor, ignore remainder */

;/* Multiply the 16 bit tentative quotient with the 32 bit divisor.  Because of
;   the operand ranges, this might give a 33 bit product.  If this product is
;   greater than the dividend, the tentative quotient was too large. */
    move.l  d2,d1
    mulu    d0,d1           ;/* low part, 32 bits */
    swap    d2
    mulu    d0,d2           ;/* high part, at most 17 bits */
    swap    d2              ;/* align high part with low part */
    tst.w   d2              ;/* high part 17 bits? */
    bne.s   L5              ;/* if 17 bits, quotient was too large */
    add.l   d2,d1           ;/* add parts */
    bcs.s   L5              ;/* if sum is 33 bits, quotient was too large */
    cmp.l   4+4(sp),d1      ;/* compare the sum with the dividend */
    bls.s   L6              ;/* if sum > dividend, quotient was too large */
L5: subq.l  #1,d0           ;/* adjust quotient */

L6: move.l  (sp)+,d2
    rts

; --------------------------------------------------------------

; from http://svn.opentom.org/opentom/trunk/linux-2.6/arch/m68knommu/lib/divsi3.S
___divsi3:
    move.l  d2,-(sp)

    moveq   #1,d2           ;/* sign of result stored in d2 (=1 or =-1) */
    move.l  4+8(sp),d1      ;/* d1 = divisor */
    bpl.s   L1
    neg.l   d1
    neg.b   d2              ;/* change sign because divisor <0  */
L1: move.l  4+4(sp),d0      ;/* d0 = dividend */
    bpl.s   l2
    neg.l   d0
    neg.b   d2

l2:
    move.l  d1, -(sp)
    move.l  d0, -(sp)
    bsr.s   ___udivsi3      ;/* divide abs(dividend) by abs(divisor) */
    addq.l  #8,sp

    tst.b   d2
    bpl.s   l3
    neg.l   d0

l3: move.l  (sp)+,d2
    rts
