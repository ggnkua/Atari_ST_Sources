; Cookie-Routinen, (PD) 1993, Dirk Haun @ WI2

               export get_cookie, set_cookie, put_cookie

               import Super, Malloc, Supexec

module         get_p_cookies
               move.l    $5a0.w,d0
               rts
endmod

; int get_cookie(long cookie[D0],long *cval[A0]);

module         get_cookie
               movem.l   D4/A2-A3,-(A7)
               move.l    D0,D4
               move.l    A0,A3
               lea       get_p_cookies,A0
               jsr       Supexec
               tst.l     D0
               beq.s     c_ende
               move.l    D0,A0
               clr.l     D0
c_loop:        move.l    (A0)+,D1
               beq.s     c_ende
               move.l    (A0)+,D2
               cmp.l     D4,D1
               bne.s     c_loop
c_found:       move.l    D2,(A3)
               moveq     #1,D0
c_ende:        movem.l   (A7)+,D4/A2-A3
               rts
               endmod


; int set_cookie(long cookie[D0],long newval[D1]);

module         set_cookie

RESMAGIC       equ       $31415926

_p_cookies     equ       $5A0.w
_resvalid      equ       $426.w
_resvector     equ       $42a.w


               movem.l   D3-D4/A2-A4,-(A7)
               move.l    D0,D4
               move.l    D1,A4
               suba.l    a0,a0
               jsr       Super
               move.l    D0,A3
               moveq     #0,D3
               moveq     #0,d1
               move.l    0x5a0.w,D0
               beq.s     s_alloc
               move.l    d0,a0
s_loop:        addq.l    #1,d1
               move.l    (a0)+,d0
               beq.s     s_null
               cmp.l     d0,d4
               beq.s     s_found
               addq.l    #4,a0
               bra.s     s_loop

s_null:        cmp.l     (a0),d1
               bmi.s     s_insert

s_alloc:       moveq     #8,d0
               add.l     d1,d0
               asl.l     #3,d0
               jsr       Malloc
               move.l    a0,d1
               beq.s     s_ende
               move.l    0x5a0.w,d0
               beq.s     s_newjar
               move.l    d0,a1
s_copy:        move.l    (a1)+,(a0)+
               beq.s     s_nullcp
               move.l    (a1)+,(a0)+
               bra.s     s_copy
s_nullcp:      move.l    (a1)+,a2
               adda.w    #8,a2
               move.l    a2,(a0)
               move.l    d1,0x5a0.w
               bra.s     s_install

s_newjar:      move.l    d1,0x5a0.w
               clr.l     (a0)+

s_install:     bsr.s     _instReset

s_insert:      clr.l     4(a0)
               move.l    (a0),8(a0)
               subq.l    #4,a0
               move.l    d4,(a0)+

s_found:       move.l    a4,(a0)+
s_ok:          moveq     #1,D3
s_ende:        move.l    A3,A0
               jsr       Super
               move.l    D3,D0
               movem.l   (A7)+,D3-D4/A2-A4
               rts

_instReset:    move.l    D4,xbraId
               move.l    _resvalid,oldResValid
               move.l    #RESMAGIC,_resvalid
               move.l    _resvector,oldReset
               move.l    #newReset,_resvector
               rts

oldResValid:   dc.l      0
               dc.b      "XBRA"
xbraId:        dc.b      "ck01"             ; XBRA-structure
oldReset:      dc.l      0
newReset:      clr.l     _p_cookies         ; clear the cookie jar
               move.l    oldReset,_resvector
               move.l    oldResValid,_resvalid
               jmp       (a6)
               endmod


; int put_cookie(long cookie[D0],long newval[D1]);

module         put_cookie
               movem.l   D3-D4/A2-A4,-(A7)
               move.l    D0,D4
               move.l    D1,A4
               suba.l    a0,a0
               jsr       Super
               move.l    D0,A3
               moveq     #0,D3
               move.l    0x5a0.w,D0
               beq.s     p_ende
               move.l    D0,A0
               moveq     #0,D0
p_loop:        move.l    (A0)+,D1
               bne.s     p_other
               move.l    (a0)+,d2
               cmp.l     d0,d2
               bls.s     p_ende
               move.l    d4,-8(a0)
               move.l    a4,-4(a0)
               clr.l     (a0)+
               move.l    d2,(a0)
               bra.s     p_ok
p_other:       addq.l    #1,d0
               move.l    (A0)+,D2
               cmp.l     D4,D1
               bne.s     p_loop
p_found:       move.l    A4,-(a0)
p_ok:          moveq     #1,D3
p_ende:        move.l    A3,A0
               jsr       Super
               move.l    D3,D0
               movem.l   (A7)+,D3-D4/A2-A4
               rts
               endmod
