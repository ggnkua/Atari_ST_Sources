;       Harddisk autofolder password protection
;       Idea by Richard Karsmakers
;       Programming by Chris Jungen

s:      pea     start(pc)
        move.w  #38,-(sp)       ; super exec
        trap    #14             ; xbios
        addq.l  #6,sp

        clr.l   -(sp)           ; terminate
        trap    #1              ; gemdos

start:  move.b  $3ff.w,d0
        cmpi.b  #7,d0
        beq     end

        lea     times(pc),a0
        move.w  #3,(a0)

again:  pea     esc_cls(pc)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp

        bsr     set_cursor

        lea     keycodes+1(pc),a6
nxt_out:move.w  #"_",-(sp)
        move.w  #2,-(sp)
        trap    #1
        addq.l  #4,sp
        tst.b   (a6)+
        bpl.s   nxt_out

        bsr     set_cursor

        lea     keycodes(pc),a6
        lea     in_string(pc),a5
        moveq   #key_end-keycodes-1-1,d7
keyloop:bsr     getkey
        swap    d0
        move.b  d0,(a5)+
        move.w  #'X',-(sp)
        move.w  #2,-(sp)
        trap    #1
        addq.l  #4,sp
        dbra    d7,keyloop


        lea     keycodes(pc),a6
        lea     in_string(pc),a5
        moveq   #key_end-keycodes-1-1,d7
test_loop:
        cmpm.b  (a5)+,(a6)+
        beq.s   .ok
        subq.w  #1,times
        beq.s   code_failed
        bra.s   again
.ok:    dbra    d7,test_loop
        move.b  #7,$3ff.w
end:    rts


code_failed:
        move.w  #$456,$ffff8240.w
        move.w  #$2700,sr
        clr.b   $ffff820a.w
code_failed_loop:
	REPT	8
        nop
        ENDR
        add.w   #$110,$ffff8240.w
        bra.s   code_failed_loop


keycodes:
        dc.b    $10,$10,-1
key_end:
        EVEN

getkey: move.w  #2,-(sp)
        move.w  #2,-(sp)
        trap    #13
        addq.l  #4,sp
        rts

set_cursor:
        move.b  $ffff8260.w,d0
        and.w   #%11,d0
        cmp.b   #2,d0           ; Mono?
        bne.s   no_mono
        moveq   #12,d1          ; Y/2
        moveq   #40-(key_end-keycodes-1)/2-8,d2 ; X/2
no_mono:
        cmp.b   #1,d0           ; Midres?
        bne.s   no_midres
        moveq   #12,d1          ; Y/2
        moveq   #40-(key_end-keycodes-1)/2-8,d2 ; X/2
no_midres:
        tst.b   d0              ; Lowres?
        bne.s   no_lowres
        moveq   #12,d1           ; Y/2
        moveq   #20-(key_end-keycodes-1)/2-8,d2 ; X/2
no_lowres:
        lea     tab(pc),a0
        add.w   #32,d1
        add.w   #32,d2
        move.b  d1,(a0)+
        move.b  d2,(a0)+
        pea     esc(pc)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        rts


esc_cls:dc.b    27,"E",0
        EVEN
esc:    dc.b    27,"Y"
tab:    dc.w    1
        dc.b    "PASSWORD:",0
        EVEN
times:  dc.w    0
in_string:
        dcb.b   key_end-keycodes+1,0

