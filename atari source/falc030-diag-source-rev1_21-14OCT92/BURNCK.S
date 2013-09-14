       .text
;        dc.l    $fa52235f       ;magic numbe
isburn:
        lea     $1000,sp
        move.w  #$2700,sr

        bsr     initky         
        bsr     xkeyres
        tst     d0
        bne    start
;bra start
       move.l  #EndCartAddr,a0         ; relocated cart is at around $fb0000.
.lp1:
        cmp.b   #$fa,(a0)+      ; search for next cart
        bne     .lp1
        subq.l  #1,a0                   ; put a0 back..

        move.l  #$f0000,a1
        move.w  #$7fff,d0

.lp2:
        move.w  (a0)+,(a1)+
        dbra    d0,.lp2
*--- check ram & copy.
        move.w  #$7fff,d0
.lp3:
        move.w  -(a0),d1
        cmp.w   -(a1),d1
        bne     start1
        dbra    d0,.lp3

        jmp     $f000a
        
start1:
        move.w  #red,palette
        bra     start1


*-------------------------------
*       Keyboard reset test
*       Send reset command, wait for self-test status
*       Exit:   d0=0 if pass
*               d0=ff if fail

xkeyres:
        clr.l   d7
        moveq   #$80,d1
        bsr     ikbdput         ;output reset command
        moveq   #$1,d1
        bsr     ikbdput

*       Wait for completion
        move.l  #50000,d6
xkeycomp:
        move.b  comstat(a1),d7  ;grab midi/keyboard status
        btst    #7,d7           ; ?irq from midi/keybd?
        bne.s   xgotstat        ;got response
        sub.l   #1,d6
        bne.s   xkeycomp

        moveq   #$0,d0           ;Fail: time-out no keybd
        rts

xgotstat:
        moveq   #$ff,d0          ;Got status yes keybd
        rts
      
initky:
        movea.l #keyboard,a1            ;point to keyboard register base
        move.b  #rsetacia,comstat(a1)   ;init the acia via master reset
        move.b  #div64+protocol+rtsld+intron,comstat(a1)        
        rts

