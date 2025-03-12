; vasmm68k_mot -Fbin tcal.s -o tcal.tos
    dc.w $601a ; ph_branch
    dc.l end-start ; ph_tlen
    dc.l $0 ; ph_dlen
    dc.l $0 ; ph_blen
    dc.l $0 ; ph_slen
    dc.l $0 ; ph_res1
    dc.l $0 ; ph_prgflags
    dc.w $1 ; ph_absflag
start
    ; supervisor mode (allow mem. access)
    move.w #$20,-(sp)
    trap #1
    ; line-a init : https://freemint.github.io/tos.hyp/en/linea_main.html
    dc.w $a000
    movem.l (a0),a1-a4

    ; screen setup / clear
    pea vt52Commands(pc)
    move.w #9,-(sp)
    trap #1

    move #140,d3 ; rs
    clr.l d4 ; rc
l
    ; rs += rc >> 5
    move.w d4,d0
    asr.w #5,d0
    add.w d0,d3

    ; generate cond. body: (rs < 0) ? 63 - n : n
    lea invert_patch(pc),a5
    bpl default
    move.l #$92459446,(a5) ; sub.w d5,d1 sub.w d6,d2
    bra skip
default
    move.l #$32053406,(a5) ; move.w d5,d1 move.w d6,d2
skip

    ; x += 127
    lea offset_patch(pc),a5
    moveq #127,d0
    add d3,d0
    move.w d0,(a5)

    ; rc -= rs >> 6
    move.w d3,d0
    asr.w #6,d0
    sub.w d0,d4

    ; ~abs(rs)
    asr #1,d0
    eor d3,d0
    asr #3,d0
    movea d0,a5 ; tri

    clr.w (a3) ; set pixel color (white)

    moveq #-1,d5 ; x
    move d5,d6 ; y
    
    moveq #31,d7 ; number of points (end up being * 2 due to midline)
    p:
        swap d7
        moveq #15,d0
        r: ; can merge the two loops for some bytes gain (but speed loss)
            ; x += y >> 6
            move.w d6,d2
            asr.w #6,d2
            add.w d2,d5

            ; y -= x >> 6
            move.w d5,d1
            asr.w #6,d1
            sub.w d1,d6

            ; xf += tr
            add.w a5,d7
            ; (xf >= 0) ? { x -= 1; xf -= 38 }
            bmi skip_adjust
                subq.w #1,d5
                sub.w #38,d7
skip_adjust
            dbra.w d0,r

        ; simpler / cheap way to do it, fractional adjust above is then uneeded (not as smooth though)
        ;sub.w a5,d5

        move d6,a6
        move.w #1,d7
transforms
        ; x: ((x * rc + y * -rs) >> 7)
        bsr transform
        swap d0
        ; y: ((x * rs + y * rc) >> 7)
        bsr transform

        dc.w $d0bc ; add.l #,d0
offset_patch
        nop ; x +=
        dc.w $0040 ; y += 64
    ;    add.l #$7f0040,d0 ; x += 127, y += 64

        ; plot
        move.l d0,-(sp) ; accumulate points on stack to clear them later
        move.l d0,(a4) ; set put pixel x,y (ptsin)
        dc.w $a001 ; put pixel
        moveq #63,d6 ; midline collapse

        dbra.w d7,transforms
        move.w a6,d6

        swap d7
        dbra.w d7,p

    ; vsync wait
    move.w #$25,-(sp)
    trap #14
    addq.l #2,sp

    subq #1,(a3) ;  points color (black)
    ; clear points on stack
    moveq #63,d7
    c:
        move.l (sp)+,d0 ; get xy
        move.l d0,(a4) ; set xy
        dc.w $a001 ; set pixel off
        dbra.w d7,c

    ; check for space key
    cmp.b #$39,$fffc02
    bne l

    ; clean exit
    clr.l -(a7)
    trap #1
    bra l

transform
    neg.w d3
    moveq #63,d1
    moveq #63,d2
invert_patch
    nop
    nop
    muls.w d4,d1
    muls.w d3,d2
    add.w d2,d1
    asr.w #7,d1
    move.w d1,d0
    exg d5,d6 ; prepare y
    rts

vt52Commands
    dc.b 27,"f" ; disable cursor
    dc.b 27,"c",15 ; background color
    dc.b 27,"E" ; clear to start of screen
    dc.b 0
end
