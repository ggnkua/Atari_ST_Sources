        xdef    _memsetword
        xdef    _setColor
        xdef    _getCookie

_memsetword:
        move.l  4+4(sp),d0                     ;d0:word value
        move.w  4+4(sp),d0                     ;d0:long value
        move.l  4+6(sp),d1                     ;d1:bytes to fill
        move.l  4+0(sp),a0                     ;a0:start of memory
        add.l   d1,a0
        add.l   d1,a0                          ;a0:end of memory
        movem.l d2-d7/a2-a5,-(sp)

        cmp.l   #50,d1
        ble.s   .enterfill2

                    moveq   #20,d2                         ; constant
                    move.l  d0,d3
                    move.l  d0,d4
                    move.l  d0,d5
                    move.l  d0,d6
                    move.l  d0,d7
                    move.l  d7,a1
                    move.l  d7,a2
                    move.l  d7,a3
                    move.l  d7,a4
                    move.l  d7,a5

.fill40:            sub.l   d2,d1
                    blt.s   .endfill40
                    movem.l d3-d7/a1-a5,-(a0)
                    bra.s   .fill40
.endfill40:         add.w   d2,d1
                    bra.s   .enterfill2
.fill2:             move.w  d0,-(a0)
.enterfill2:        dbra    d1,.fill2

                movem.l (a7)+,d2-d7/a2-a5
                rts



; setColor
; Test the _VDO cookie
; If STF/STE, then use Setcolor  (Xbios $07)
; If Falcon,  then use VsetRGB   (Xbios $5d) and VgetRGB (Xbios $5e)
; If TT030,   then use Esetcolor (Xbios $53)
; parameters:
;     sp+4 .w color index
;     sp+6 .w color value, STe format
; returns:
;     D0 : previous color, in STe format
; alters:
;     d0-d4/a0-a3

_setColor:
                move.l  #"_VDO",d3
                bsr     _getCookie
                tst.l   d3
                beq.s   .vdoFound
                moveq   #0,d4                       ; 0 if no cookie found
.vdoFound:      ;d4: "_VDO" cookie
                movem.w 4(sp),d0-d1                 ; d0: color number
                                                    ; d1: color value
                swap    d4
                cmp.w   #2,d4
                bmi     .vdoStOrSte
                beq     .vdoTT

                ;_VDO is Falcon030
                lea     .tmprgb(pc),a3
                pea     (a3)        ;rgb
                move.w  #1,-(sp)    ;count
                move.w  d0,-(sp)    ;index
                move.w  #$5e,-(sp)  ;VgetRGB
                trap    #14
                lea     10(sp),sp

                movem.w 4(sp),d0-d1                 ; d0: color number
                                                    ; d1: color value
                addq.l  #8,a3
                bsr.s   .cStePlanar                 ; d1:convert to R..rG..gB..b
                move.w  d1,d2
                and.w   #15,d2                      ; d2:0000B..b
                move.w  d2,d3                       ; d3:0000B..b
                lsl.w   #4,d2                       ; d2:B..b0000
                add.b   d3,d2                       ; d2:B..bB..b
                move.b  d2,-(a3)                    ; save BLUE
                move.w  d1,d2
                and.w   #$f0,d2                     ; d2:G..g0000
                move.w  d2,d3                       ; d3:G..g0000
                lsr.w   #4,d2                       ; d2:0000G..g
                add.b   d3,d2                       ; d2:G..gG..g
                move.b  d2,-(a3)                    ; save GREEN
                lsr.w   #8,d1                       ; d1:0000R..r
                move.w  d1,d2                       ; d2:0000R..r
                lsl.w   #4,d2                       ; d2:R..r0000
                add.b   d1,d2                       ; d2:R..rR..r
                move.b  d2,-(a3)                    ; save BLUE

                subq.l  #1,a3
                pea     (a3)        ;rgb
                move.w  #1,-(sp)    ;count
                move.w  d0,-(sp)    ;index
                move.w  #$5d,-(sp)  ;VsetRGB
                trap    #14
                lea     10(sp),sp

                movem.w 4(sp),d0-d1                 ; d0: color number
                                                    ; d1: color value
                move.l  -(a3),d1                    ; d1: 00000000R......r G......gB......b
                lsr.l   #4,d1                       ; d1: 000000000000R... ...rG......gB..b
                move.b  d1,d0
                and.w   #$f,d0                      ; d0: 00000000 0000B..b
                lsr.l   #4,d1                       ; d1: R......r G......g
                move.w  d1,d2
                and.b   #$f0,d2                     ; d2: 00000000 G..g0000
                add.b   d2,d0                       ; d0: 00000000 G..gB..b
                lsr.l   #4,d1                       ; d1: 0000R... ...rG...
                and.w   #$f00,d1                    ; d1: 0000R..r 00000000
                add.w   d1,d0                       ; d0: 0000R..r G..gB..b

                bra.s   .cPlanarSte                 ; convert to Ste and exit

.tmprgb         ds.l    1                           ; used by VgetRGB
                ds.l    1                           ; used by VsetRGB
.cStePlanar:    ;(d1->d1)
                ;convert the color from 0321 0321 0321
                ;                    to 3210 3210 3210
                ;modify d2
                move.w  d1,d2
                                                    ; r rrrg gggb bbb0
                add.w   d1,d1                       ; 0 3210 3210 3210
                and.w   #$eee,d1                    ; 0 rrr0 ggg0 bbb0
                btst    #3,d2
                beq.s   .okb
                addq.w  #$1,d1
.okb:           btst    #7,d2
                beq.s   .okg
                add.w   #$10,d1
.okg:           btst    #11,d2
                beq.s   .okr
                add.w   #$100,d1
.okr:           rts

.vdoTT:         ;_VDO is TT030
                bsr.s   .cStePlanar

                movem.w d0/d1,-(sp)
                move.w  #$53,-(sp)  ;EsetColor
                trap    #14
                addq.l  #6,sp

.cPlanarSte:    ;(d0->d0)
                ;convert back from R__r G__g B__b
                ;               to rR__ gG__ bB__
                ;modify d2
                move.w  d0,d2
                lsr.w   #1,d0                       ;0R__ rG__ gB__ (missing 1 bit)
                and.w   #$777,d0                    ;0R__ 0G__ 0B__
                btst    #0,d2                       ;test the lost bit
                beq.s   .okb2
                addq.w  #8,d0
.okb2:          btst    #4,d2
                beq.s   .okg2
                add.w   #$80,d0
.okg2:          btst    #8,d2
                beq.s   .end
                add.w   #$800,d0
.end:           rts

.vdoStOrSte:    ;_VDO is ST/Ste
                movem.w d0/d1,-(sp)
                move.w  #7,-(sp)        ;Setcolor
                trap    #14
                addq.l  #6,sp
                rts


;in:  d3: cookie to search
;out: d3 =0 cookie found d4:value of the cookie
;     d3!=0 cookie not found
_getCookie:     movem.l d0-d2/d5-d6/a0-a2,-(sp)
                moveq   #0,d6                       ; old stack or zero if no stack change

                ;this can no longer be used because move from SR is a supervisor instruction since 68010 !
                ;move    SR,d5
                ;btst    #13,d5
                ;bne.s   .super

                moveq   #1,d6       ;SUP_INQUIRE
                move.l  d6,-(sp)    ;stack
                move.w  #$20,-(sp)  ;Super()
                trap    #1
                addq.l  #6,sp
                tst.w   d0
                bne.s   .alreadysuper

                ;user mode: switch to super mode
                clr.l   -(sp)       ;SUP_SET
                move.w  #$20,-(sp)  ;Super()
                trap    #1
                addq.l  #6,sp
                move.l  d0,d6                       ; save old stack
.alreadysuper:  move.l  $5a0.w,d0                   ;_p_cookies
                beq.s   .notfound
                move.l  d0,a0
.nxtCookie:     movem.l (a0)+,d0/d4
                cmp.l   d0,d3
                beq.s   .found
                tst.l   d0
                bne.s   .nxtCookie
.found:         moveq   #0,d3                       ; cookie found
.notfound:      tst.l   d6
                beq.s   .end
                ;return to user mode
                move.l  d6,-(sp)    ;stack
                move.w  #$20,-(sp)  ;Super()
                trap    #1
                addq.l  #6,sp
.end:           movem.l (sp)+,d0-d2/d5-d6/a0-a2
                rts
