* lmemcpy.s - replacement for a code in dLibs 1.2
*
* After memcpy by David Brooks  - Michal Jaegermann, 11 Mar 89
*
*       char *lmemcpy(dest, source, len)
*               char *dest              at 4(sp)
*               char *source            at 8(sp)
*               unsigned long len       at 12(sp)
*
* Avoid "btst #n,dn" because of a bug in the Sozobon assembler.
* If parity of both adresses the same - copies in 16 byte blocks.
* One has to stop loop unrolling somewhere.
 
.text
.globl _lmemcpy
_lmemcpy:
        lea     4(a7),a2        ; Point to argument list
        move.l  (a2)+,a1        ; a1 = dest
        move.l  (a2)+,a0        ; a0 = source
        move.l  (a2),d2         ; d2 = len
        beq     lmemcpy6        ; return if zero
 
        move.l  a0,d1           ; Check for odd/even alignment
        add.w   a1,d1           ; This is really eor.w on the lsb.  Really.
        asr.w   #1,d1           ; Get lsb into C.  If it's 1, alignment is off.
        bcs     lmemcpy7        ; Go do it slowly
 
        move.l  a0,d1           ; Check for initial odd byte
        asr.w   #1,d1           ; Get lsb
        bcc     lmemcpy1
        subq.l  #1,d2           ; Move initial byte
        move.b  (a0)+,(a1)+     ; 
lmemcpy1:
        moveq.l #15,d1          ; Split into a longword count and remainder
        and.w   d2,d1
        lsr.l   #4,d2           ; for 16 bytes at a time
        move.l  d2,d0           ; a second counter for dbra
        swap    d0
        bra     lmemcpy3        ; Words (!!) d2 and d0 could equal 0.
lmemcpy2:
        move.l  (a0)+,(a1)+     ; Copy 16 bytes
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
lmemcpy3:
        dbra    d2,lmemcpy2
        dbra    d0,lmemcpy2
 
        bra     lmemcpy5        ; Enter final loop.  Again d1 could equal 0.
lmemcpy4:
        move.b  (a0)+,(a1)+     ; Up to 15 trailing bytes
lmemcpy5:
        dbra    d1,lmemcpy4
lmemcpy6:
        move.l  4(a7),d0        ; stick return value into d0
        rts                     ; All done.
 
lmemcpy7:
        move.l  a1,d0           ; Handle the odd/even aligned case, d0=dest
        subq    #1,d2           ; here d2 was positive!
        move.l  d2,d1
        swap    d1              ; second dbra counter
lmemcpy8:
        move.b  (a0)+,(a1)+	; move byte-by-byte
        dbra    d2,lmemcpy8
        dbra    d1,lmemcpy8
        rts                     ; and exit normally
