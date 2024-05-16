**********************************************************************
* The ICE Collection disk #1                                         *
* This code by Techwave/ICE, february -92                            *
**********************************************************************
go:
* init
                movea.l   4(sp),a5
                move.l    $0c(a5),d0
                add.l     $14(a5),d0
                add.l     $1c(a5),d0
                add.l     #$1100,d0
                move.l    a5,d1
                add.l     d0,d1
                and.l     #-2,d1
                movea.l   d1,sp

                move.l    #35000,-(sp)            ; d0
                move.l    a5,-(sp)
                move.w    d0,-(sp)
                move.w    #$4a,-(sp)              ; mshrink
                trap      #1
                lea       12(sp),sp


;                move.l    #270000,-(sp)           ; reserve mem
;                move.w    #72,-(sp)
;                trap      #1
;                addq.l    #6,sp


                clr.l     -(sp)
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp
                move.l    d0,old_shit
                bra       go_on

**********************************************************************
loader:
* clr 1st
                lea       go_on,a0
                movea.l   a0,a1
                adda.l    #250000,a1
                moveq     #0,d0
clr_lp:         move.l    d0,(a0)+
                cmpa.l    a0,a1
                bhi.s     clr_lp

                move.l    old_shit,-(sp)
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

* p_exec
                move.l    #0,-(sp)
                move.l    address2,-(sp)
                move.l    a3,-(sp)
                clr.w     -(sp)
                move.w    #75,-(sp)
                trap      #1
                lea       16(sp),sp
                tst.l     d0
                bmi       error

                clr.w     -(sp)
                trap      #1

**********************************************************************
old_shit:     dc.l 0

enchanted:    dc.b "icedemo.bin",0
digi:         dc.b "digworld.bin",0
digi_2:       dc.b "digiwor2.bin",0
intruder:     dc.b "intruder.bin",0
hard_ice:     dc.b "hard_ice.bin",0
jam:          dc.b "jamdemo.bin",0
              even
address2:     ds.b 128
              even

error:
                clr.l     -(sp)
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

                move      #$2700,sr
err_lp:         addi.b    #$01,$ffff8240.w
                addi.b    #$01,$ffff8240.w
                bra.s     err_lp

**********************************************************************

go_on:          move.b    #2,$0484.w

                move.w    #0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                move.l    #screen+128,screen1

b_init:         move.b    #2,$ffff8a3a.w          ; hop
                move.b    #3,$ffff8a3b.w          ; op
                move.w    #$ffff,$ffff8a2a.w      ; endmask 2
                move.w    #$ffff,$ffff8a2c.w      ; endmask 3
                move.w    #8,$ffff8a20.w          ; src x inc
                move.w    #8,$ffff8a2e.w          ; des x inc

                jsr       set_mw
                jsr       init_noise

i_init:         move.l    $70.w,oldvbl
                move.l    #vbl,$70.w

key_lp:         move.w    #7,-(sp)
                trap      #1
                addq.l    #2,sp

                swap      d0
                cmp.b     #$3b,d0
                beq.s     f1
                cmp.b     #$3c,d0
                beq.s     f2
                cmp.b     #$3d,d0
                beq.s     f3
                cmp.b     #$3e,d0
                beq.s     f4
                cmp.b     #$3f,d0
                beq.s     f5
                cmp.b     #$40,d0
                beq.s     f6
                bra.s     key_lp

init_exit:      st        key_flg
exit_lp:        tst.b     back_flg
                beq.s     exit_lp
                jsr       back
                move.w    #$0404,d0
                lea       $ffff8240,a0
                move.w    #0,(a0)+
              rept 15
                move.w    d0,(a0)+
              endr
                rts

f1:             bsr.s     init_exit
                lea       enchanted(pc),a3
                bra       loader
f2:             bsr.s     init_exit
                lea       digi(pc),a3
                bra       loader
f3:             bsr.s     init_exit
                lea       digi_2(pc),a3
                bra       loader
f4:             bsr.s     init_exit
                lea       intruder(pc),a3
                bra       loader
f5:             bsr.s     init_exit
                lea       hard_ice(pc),a3
                bra       loader
f6:             bsr.s     init_exit
                lea       jam(pc),a3
                bra       loader

**********************************************************************
**********************************************************************
vbl:
;                not.w     $ffff8240.w
                movem.l   d0-a6,-(sp)

                lea       screen1+1,a0
                move.b    (a0)+,$ffff8205.w
                move.b    (a0)+,$ffff8207.w
                move.b    (a0)+,$ffff8209.w

                lea       screen+4,a0
                movem.l   (a0),d0-d7
                movem.l   d0-d7,$ffff8240.w
                move.w    #$0112,$ffff8242.w

                bsr       b_scrl
                bsr       b_charout

                bsr       noise_vbl

                tst.b     no_high_flg
                bne.s     no_high

                addq.b    #1,pause_times
                bmi.s     end_vbl
                move.b    #-4,pause_times
                addq.w    #1,mw_set
                jsr       set_mw
                cmpi.w    #%10011000000+40,mw_set
                bne.s     end_vbl
                st        no_high_flg

no_high:
                tst.b     key_flg
                beq.s     end_vbl

                addq.b    #1,pause_times
                bmi.s     no_low
                move.b    #-2,pause_times
                subq.w    #1,mw_set
                jsr       set_mw
                cmpi.w    #%10011000000+20,mw_set
                bne.s     no_low
                st        back_flg

no_low:

                tst.b     scroll_flg
                bne.s     end_vbl
                lea       screen1,a0
                addi.l    #640*2,(a0)
                lea       end_scroll,a1
                cmpa.l    (a0),a1
                bhi.s     end_vbl
                st        scroll_flg

end_vbl:
                movem.l   (sp)+,d0-a6
;                not.w     $ffff8240.w
                rte
**********************************************************************
no_high_flg:  dc.b 0
pause_times:  dc.b 0
scroll_flg:   dc.b 0
key_flg:      dc.b 0
back_flg:     dc.b 0

              even
b_scrl:
                move.w    #$00,$ffff8a28.w        ; endmask 1
                move.w    #8,$ffff8a22.w          ; src y inc
                move.w    #8,$ffff8a30.w          ; des y inc

                move.l    #screen+128+(160*192)+4,$ffff8a24.w ; src addr
                move.l    #screen+128-8+(160*192)+4,$ffff8a32.w ; des addr
                move.w    #20*8+1,$ffff8a36.w     ; x-cnt
                move.w    #1,$ffff8a38.w          ; y-cnt

                move.b    #%1111,$ffff8a3d.w      ; skew
                move.b    #%11000000,$ffff8a3c.w
                rts

* --------------------------------------------------------------------
b_charout:
                lea       fontpic+34,a0
                adda.w    offset,a0
                move.l    a0,$ffff8a24.w          ; src addr

                move.l    #screen+128+152+(160*192)+4,$ffff8a32.w ; des addr

                move.w    #$01,$ffff8a28.w        ; endmask 1
                move.w    #160,$ffff8a22.w        ; src y inc
                move.w    #160,$ffff8a30.w        ; des y inc

                move.w    #1,$ffff8a36.w          ; x cnt
                move.w    #8,$ffff8a38.w          ; y cnt

                move.b    to_skew,$ffff8a3d.w
                move.b    #%11000000,$ffff8a3c.w

                subq.b    #1,to_skew
                cmpi.b    #7,to_skew
                beq.s     read
                rts


read:           move.b    #15,to_skew

                moveq     #0,d0
                lea       txt,a0
                adda.w    txt_pointer,a0
                move.b    (a0),d0
                tst.b     d0
                bne.s     ascii
                move.w    #0,txt_pointer
                bra.s     read

ascii:          sub.b     #32,d0
                add.w     d0,d0
                lea       char_off,a0
                move.w    0(a0,d0.w),offset
                addq.w    #1,txt_pointer
                rts

**********************************************************************
**********************************************************************
******************************************************************************
* Noise replay route using no timer! Done by Techwave. Original code by Wizz *
******************************************************************************
; MVOL = Main volume      (Unnecessary to adjust. $80 default)          ;
; FREQ = replay frequency (See below)                                   ;
;-----------------------------------------------------------------------;

MVOL          equ $80
; 0=6.259, 1=12.517, 2=25.036

PARTS         equ 1-1                         ;5-1                        ; 25.035
LEN           equ 250*2                       ; 100
INC           equ 6091033
;$8efb4e                 ; 3579546/25035*65536

* --------------------------------------------------------------------
* --------------------------------------------------------------------
init_noise:
                bsr       vol                     ; Calculate volume tables
                bsr       incrcal                 ; Calculate tonetables

                jsr       init                    ; Initialize music
                jsr       prepare                 ; Prepare samples

;                lea       $ffff8907.w,a0

;                move.l    #sample2,d0
;                move.b    d0,(a0)
;                lsr.w     #8,d0
;                move.l    d0,-5(a0)

;                move.l    #sample2+LEN*2,d0
;                move.b    d0,12(a0)
;                lsr.w     #8,d0
;                move.l    d0,7(a0)

                move.b    #2,$ffff8921.w
;                move.b    #3,$ffff8901.w          ; Start DMA
                rts
* --------------------------------------------------------------------
noise_vbl:
;                move.w    #$0300,$ffff8240.w
                movem.l   d0-a6,-(sp)

                move.l    samp2,d0                ; exg buff 1 <> buff2
                move.l    samp1,samp2
                move.l    d0,samp1

                lea       $ffff8907.w,a0          ; dma start

                move.l    samp2,d0
                move.b    d0,(a0)                 ; start low
                lsr.w     #8,d0
                move.l    d0,-5(a0)               ; start mid, high

                move.l    samp2,d0
                add.l     #LEN*2,d0               ; end sample (200 bytes)
                move.b    d0,12(a0)               ; end low
                lsr.w     #8,d0
                move.l    d0,7(a0)                ; end mid, high

                move.b    #0,$ffff8901.w          ; Stop  DMA
                move.b    #1,$ffff8901.w          ; Start DMA

                bsr       noise_rout

                movem.l   (sp)+,d0-a6
;                move.w    #$03,$ffff8240.w
                rts

**********************************************************************
**********************************************************************

* --------------------------------------------------------- Volume table

vol:            moveq     #64,d0
                lea       vtabend(pc),a0

.ploop:         move.w    #255,d1
.mloop:         move.w    d1,d2
                ext.w     d2
                muls      d0,d2
                divs      #MVOL,d2
                move.b    d2,-(a0)
                dbra      d1,.mloop
                dbra      d0,.ploop

                rts

vtab:         ds.b 65*256
vtabend:

* ------------------------------------------------------ Increment-table
incrcal:        lea       stab(pc),a0
                move.w    #$30,d1                 ; $30
                move.w    #$039f-$30,d0
                move.l    #INC,d2                 ; <----- INC

recalc:         swap      d2
                moveq     #0,d3
                move.w    d2,d3
                divu      d1,d3
                move.w    d3,d4
                swap      d4

                swap      d2
                move.w    d2,d3
                divu      d1,d3
                move.w    d3,d4
                move.l    d4,(a0)+

                addq.w    #1,d1
                dbra      d0,recalc
                rts

* --------------------------------------------------------------------
              even
itab:         ds.l $30
stab:         ds.l $03a0-$30

**********************************************************************
noise_rout:
                subq.w    #1,count
                bpl.s     .nomus

                move.w    #PARTS,count            ; 5-1
                jsr       music                   ; branch subrout

**********************************************************************

.nomus:         lea       itab(pc),a5
                lea       vtab(pc),a3
                moveq     #0,d0
                moveq     #0,d4

v1:             movea.l   wiz2lc(pc),a0

                move.w    wiz2pos(pc),d0
                move.w    wiz2frc(pc),d1

                move.w    aud2per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d2

                movea.w   2(a5,d7.w),a4

                move.w    aud2vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a2

* --------------------------------------------------------------------

                movea.l   wiz3lc(pc),a1
                move.w    wiz3pos(pc),d4
                move.w    wiz3frc(pc),d5

                move.w    aud3per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d6
                movea.w   2(a5,d7.w),a5

                move.w    aud3vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a3

                movea.l   samp1(pc),a6            ; buffer 1
                moveq     #0,d3

              rept LEN                        ; some times
                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.w    d7,(a6)+                ; .w
              endr

                cmp.l     wiz2len(pc),d0
                blt.s     .ok2
                sub.w     wiz2rpt(pc),d0

.ok2:           move.w    d0,wiz2pos
                move.w    d1,wiz2frc

                cmp.l     wiz3len(pc),d4
                blt.s     .ok3
                sub.w     wiz3rpt(pc),d4

.ok3:           move.w    d4,wiz3pos
                move.w    d5,wiz3frc

**********************************************************************

                lea       itab(pc),a5
                lea       vtab,a3                 ; (pc)
                moveq     #0,d0
                moveq     #0,d4

v2:             movea.l   wiz1lc(pc),a0
                move.w    wiz1pos(pc),d0
                move.w    wiz1frc(pc),d1

                move.w    aud1per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d2
                movea.w   2(a5,d7.w),a4

                move.w    aud1vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a2

* --------------------------------------------------------------------

                movea.l   wiz4lc(pc),a1
                move.w    wiz4pos(pc),d4
                move.w    wiz4frc(pc),d5

                move.w    aud4per(pc),d7
                add.w     d7,d7
                add.w     d7,d7
                move.w    0(a5,d7.w),d6
                movea.w   2(a5,d7.w),a5

                move.w    aud4vol(pc),d7
                asl.w     #8,d7
                lea       0(a3,d7.w),a3

                movea.l   samp1(pc),a6            ; buffer 1
                moveq     #0,d3

              rept LEN                        ; some times
                add.w     a4,d1
                addx.w    d2,d0
                add.w     a5,d5
                addx.w    d6,d4
                move.b    0(a0,d0.l),d3
                move.b    0(a2,d3.w),d7
                move.b    0(a1,d4.l),d3
                add.b     0(a3,d3.w),d7
                move.b    d7,(a6)                 ; .b
                addq.w    #2,a6                   ; stereo
              endr

                cmp.l     wiz1len(pc),d0
                blt.s     .ok1
                sub.w     wiz1rpt(pc),d0

.ok1:           move.w    d0,wiz1pos
                move.w    d1,wiz1frc

                cmp.l     wiz4len(pc),d4
                blt.s     .ok4
                sub.w     wiz4rpt(pc),d4

.ok4:           move.w    d4,wiz4pos
                move.w    d5,wiz4frc

;               movem.l   (sp)+,d0-a6
;                move.w    #$03,$ffff8240.w
                rts                               ; rte
**********************************************************************
* -------------------------------------------- Hardware-registers & data
count:        dc.w PARTS

wiz1lc:       dc.l sample1
wiz1len:      dc.l 0
wiz1rpt:      dc.w 0
wiz1pos:      dc.w 0
wiz1frc:      dc.w 0

wiz2lc:       dc.l sample1
wiz2len:      dc.l 0
wiz2rpt:      dc.w 0
wiz2pos:      dc.w 0
wiz2frc:      dc.w 0

wiz3lc:       dc.l sample1
wiz3len:      dc.l 0
wiz3rpt:      dc.w 0
wiz3pos:      dc.w 0
wiz3frc:      dc.w 0

wiz4lc:       dc.l sample1
wiz4len:      dc.l 0
wiz4rpt:      dc.w 0
wiz4pos:      dc.w 0
wiz4frc:      dc.w 0

aud1lc:       dc.l dummy
aud1len:      dc.w 0
aud1per:      dc.w 0
aud1vol:      dc.w 0
              ds.w 3

aud2lc:       dc.l dummy
aud2len:      dc.w 0
aud2per:      dc.w 0
aud2vol:      dc.w 0
              ds.w 3

aud3lc:       dc.l dummy
aud3len:      dc.w 0
aud3per:      dc.w 0
aud3vol:      dc.w 0
              ds.w 3

aud4lc:       dc.l dummy
aud4len:      dc.w 0
aud4per:      dc.w 0
aud4vol:      dc.w 0

dmactrl:      dc.w 0

dummy:        dc.l 0

samp1:        dc.l sample1
samp2:        dc.l sample2

sample1:      ds.w LEN                        ; sample buffer 1 (200 bytes)
sample2:      ds.w LEN                        ; sample buffer 2

* ========================================================= EMULATOR END

prepare:        lea       workspc,a6
                movea.l   samplestarts(pc),a0
                movea.l   end_of_samples(pc),a1

tostack:        move.w    -(a1),-(a6)
                cmpa.l    a0,a1                   ; Move all samples to stack
                bgt.s     tostack

                lea       samplestarts(pc),a2
                lea       data(pc),a1             ; Module
                movea.l   (a2),a0                 ; Start of samples
                movea.l   a0,a5                   ; Save samplestart in a5

                moveq     #30,d7

roop:           move.l    a0,(a2)+                ; Sampleposition

                tst.w     $2a(a1)
                beq.s     samplok                 ; Len=0 -> no sample

                tst.w     $2e(a1)                 ; Test repstrt
                bne.s     repne                   ; Jump if not zero


repeq:          move.w    $2a(a1),d0              ; Length of sample
                move.w    d0,d4
                subq.w    #1,d0

                movea.l   a0,a4
fromstk:        move.w    (a6)+,(a0)+             ; Move all samples back from stack
                dbra      d0,fromstk

                bra.s     rep



repne:          move.w    $2e(a1),d0
                move.w    d0,d4
                subq.w    #1,d0

                movea.l   a6,a4
get1st:         move.w    (a4)+,(a0)+             ; Fetch first part
                dbra      d0,get1st

                adda.w    $2a(a1),a6              ; Move a6 to next sample
                adda.w    $2a(a1),a6



rep:            movea.l   a0,a5
                moveq     #0,d1
toosmal:        movea.l   a4,a3
                move.w    $30(a1),d0
                subq.w    #1,d0
moverep:        move.w    (a3)+,(a0)+             ; Repeatsample
                addq.w    #2,d1
                dbra      d0,moverep
                cmp.w     #320,d1                 ; Must be > 320
                blt.s     toosmal

                move.w    #320/2-1,d2
last320:        move.w    (a5)+,(a0)+             ; Safety 320 bytes
                dbra      d2,last320

done:           add.w     d4,d4

                move.w    d4,$2a(a1)              ; length
                move.w    d1,$30(a1)              ; Replen
                clr.w     $2e(a1)

samplok:        lea       $1e(a1),a1
                dbra      d7,roop

                cmpa.l    #workspc,a0
                bgt.s     .nospac

                rts

.nospac:        illegal

end_of_samples:dc.l 0

* ------------------------------------------------------ Main replayrout
init:           lea       data(pc),a0
                lea       $03b8(a0),a1

                moveq     #$7f,d0
                moveq     #0,d1
loop:           move.l    d1,d2
                subq.w    #1,d0
lop2:           move.b    (a1)+,d1
                cmp.b     d2,d1
                bgt.s     loop
                dbra      d0,lop2
                addq.b    #1,d2

                lea       samplestarts(pc),a1
                asl.l     #8,d2
                asl.l     #2,d2
                add.l     #$043c,d2
                add.l     a0,d2
                movea.l   d2,a2

                moveq     #$1e,d0
lop3:           clr.l     (a2)
                move.l    a2,(a1)+
                moveq     #0,d1
                move.w    42(a0),d1
                add.l     d1,d1
                adda.l    d1,a2
                adda.l    #$1e,a0
                dbra      d0,lop3

                move.l    a2,end_of_samples
                rts
* --------------------------------------------------------------------
music:          lea       data(pc),a0             ; <---- music subrout
                addq.w    #$01,counter
                move.w    counter(pc),d0
                cmp.w     speed(pc),d0
                blt.s     nonew
                clr.w     counter
                bra       getnew

nonew:          lea       voice1(pc),a4
                lea       aud1lc(pc),a3
                bsr       checkcom
                lea       voice2(pc),a4
                lea       aud2lc(pc),a3
                bsr       checkcom
                lea       voice3(pc),a4
                lea       aud3lc(pc),a3
                bsr       checkcom
                lea       voice4(pc),a4
                lea       aud4lc(pc),a3
                bsr       checkcom
                bra       endr

arpeggio:
                moveq     #0,d0
                move.w    counter(pc),d0
                divs      #$03,d0
                swap      d0
                tst.w     d0
                beq.s     arp2
                cmp.w     #$02,d0
                beq.s     arp1

                moveq     #0,d0
                move.b    $03(a4),d0
                lsr.b     #4,d0
                bra.s     arp3

arp1:           moveq     #0,d0
                move.b    $03(a4),d0
                and.b     #$0f,d0
                bra.s     arp3

arp2:           move.w    $10(a4),d2
                bra.s     arp4

arp3:           add.w     d0,d0
                moveq     #0,d1
                move.w    $10(a4),d1
                lea       periods(pc),a0
                moveq     #$24,d4
arploop:        move.w    0(a0,d0.w),d2
                cmp.w     (a0),d1
                bge.s     arp4
                addq.l    #2,a0
                dbra      d4,arploop
                rts

arp4:           move.w    d2,$06(a3)
                rts

getnew:         lea       data+$043c(pc),a0
                lea       -$043c+$0c(a0),a2
                lea       -$043c+$03b8(a0),a1

                moveq     #0,d0
                move.l    d0,d1
                move.b    songpos(pc),d0
                move.b    0(a1,d0.w),d1
                asl.l     #8,d1
                asl.l     #2,d1
                add.w     pattpos(pc),d1
                clr.w     dmacon

                lea       aud1lc(pc),a3
                lea       voice1(pc),a4
                bsr.s     playvoice
                lea       aud2lc(pc),a3
                lea       voice2(pc),a4
                bsr.s     playvoice
                lea       aud3lc(pc),a3
                lea       voice3(pc),a4

                bsr.s     playvoice
                lea       aud4lc(pc),a3
                lea       voice4(pc),a4
                bsr.s     playvoice
                bra       setdma

playvoice:
                move.l    0(a0,d1.l),(a4)
                addq.l    #4,d1
                moveq     #0,d2
                move.b    $02(a4),d2
                and.b     #$f0,d2
                lsr.b     #4,d2
                move.b    (a4),d0
                and.b     #$f0,d0
                or.b      d0,d2
                tst.b     d2
                beq.s     setregs
                moveq     #0,d3
                lea       samplestarts(pc),a1
                move.l    d2,d4
                subq.l    #$01,d2
                asl.l     #2,d2
                mulu      #$1e,d4
                move.l    0(a1,d2.l),$04(a4)
                move.w    0(a2,d4.l),$08(a4)
                move.w    $02(a2,d4.l),$12(a4)
                move.w    $04(a2,d4.l),d3
                tst.w     d3
                beq.s     noloop
                move.l    $04(a4),d2
                add.w     d3,d3
                add.l     d3,d2
                move.l    d2,$0a(a4)
                move.w    $04(a2,d4.l),d0
                add.w     $06(a2,d4.l),d0
                move.w    d0,8(a4)
                move.w    $06(a2,d4.l),$0e(a4)
                move.w    $12(a4),$08(a3)
                bra.s     setregs

noloop:         move.l    $04(a4),d2
                add.l     d3,d2
                move.l    d2,$0a(a4)
                move.w    $06(a2,d4.l),$0e(a4)
                move.w    $12(a4),$08(a3)
setregs:        move.w    (a4),d0
                and.w     #$0fff,d0
                beq       checkcom2
                move.b    $02(a4),d0
                and.b     #$0f,d0
                cmp.b     #$03,d0
                bne.s     setperiod
                bsr       setmyport
                bra       checkcom2

setperiod:
                move.w    (a4),$10(a4)
                andi.w    #$0fff,$10(a4)
                move.w    $14(a4),d0
                move.w    d0,dmactrl
                clr.b     $1b(a4)

                move.l    $04(a4),(a3)
                move.w    $08(a4),$04(a3)
                move.w    $10(a4),d0
                and.w     #$0fff,d0
                move.w    d0,$06(a3)
                move.w    $14(a4),d0
                or.w      d0,dmacon
                bra       checkcom2

setdma:         move.w    dmacon(pc),d0

                btst      #0,d0
                beq.s     wz_nch1
                move.l    aud1lc(pc),wiz1lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud1len(pc),d1
                move.w    voice1+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,wiz1len
                move.w    d2,wiz1rpt
                clr.w     wiz1pos

wz_nch1:        btst      #1,d0
                beq.s     wz_nch2
                move.l    aud2lc(pc),wiz2lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud2len(pc),d1
                move.w    voice2+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,wiz2len
                move.w    d2,wiz2rpt
                clr.w     wiz2pos

wz_nch2:        btst      #2,d0
                beq.s     wz_nch3
                move.l    aud3lc(pc),wiz3lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud3len(pc),d1
                move.w    voice3+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,wiz3len
                move.w    d2,wiz3rpt
                clr.w     wiz3pos

wz_nch3:        btst      #3,d0
                beq.s     wz_nch4
                move.l    aud4lc(pc),wiz4lc
                moveq     #0,d1
                moveq     #0,d2
                move.w    aud4len(pc),d1
                move.w    voice4+$0e(pc),d2
                add.l     d2,d1
                move.l    d1,wiz4len
                move.w    d2,wiz4rpt
                clr.w     wiz4pos

wz_nch4:        addi.w    #$10,pattpos
                cmpi.w    #$0400,pattpos
                bne.s     endr
nex:            clr.w     pattpos
                clr.b     break
                addq.b    #1,songpos
                andi.b    #$7f,songpos
                move.b    songpos(pc),d1
                cmp.b     data+$03b6(pc),d1
                bne.s     endr
                move.b    data+$03b7(pc),songpos
endr:           tst.b     break
                bne.s     nex
                rts

setmyport:
                move.w    (a4),d2
                and.w     #$0fff,d2
                move.w    d2,$18(a4)
                move.w    $10(a4),d0
                clr.b     $16(a4)
                cmp.w     d0,d2
                beq.s     clrport
                bge.s     rt
                move.b    #$01,$16(a4)
                rts

clrport:        clr.w     $18(a4)
rt:             rts

myport:         move.b    $03(a4),d0
                beq.s     myslide
                move.b    d0,$17(a4)
                clr.b     $03(a4)
myslide:        tst.w     $18(a4)
                beq.s     rt
                moveq     #0,d0
                move.b    $17(a4),d0
                tst.b     $16(a4)
                bne.s     mysub
                add.w     d0,$10(a4)
                move.w    $18(a4),d0
                cmp.w     $10(a4),d0
                bgt.s     myok
                move.w    $18(a4),$10(a4)
                clr.w     $18(a4)

myok:           move.w    $10(a4),$06(a3)
                rts

mysub:          sub.w     d0,$10(a4)
                move.w    $18(a4),d0
                cmp.w     $10(a4),d0
                blt.s     myok
                move.w    $18(a4),$10(a4)
                clr.w     $18(a4)
                move.w    $10(a4),$06(a3)
                rts

vib:            move.b    $03(a4),d0
                beq.s     vi
                move.b    d0,$1a(a4)

vi:             move.b    $1b(a4),d0
                lea       sin(pc),a1
                lsr.w     #$02,d0
                and.w     #$1f,d0
                moveq     #0,d2
                move.b    0(a1,d0.w),d2
                move.b    $1a(a4),d0
                and.w     #$0f,d0
                mulu      d0,d2
                lsr.w     #$06,d2
                move.w    $10(a4),d0
                tst.b     $1b(a4)
                bmi.s     vibmin
                add.w     d2,d0
                bra.s     vib2

vibmin:         sub.w     d2,d0
vib2:           move.w    d0,$06(a3)
                move.b    $1a(a4),d0
                lsr.w     #$02,d0
                and.w     #$3c,d0
                add.b     d0,$1b(a4)
                rts

nop:            move.w    $10(a4),$06(a3)
                rts

checkcom:
                move.w    $02(a4),d0
                and.w     #$0fff,d0
                beq.s     nop
                move.b    $02(a4),d0
                and.b     #$0f,d0
                tst.b     d0
                beq       arpeggio
                cmp.b     #$01,d0
                beq.s     portup
                cmp.b     #$02,d0
                beq       portdown
                cmp.b     #$03,d0
                beq       myport
                cmp.b     #$04,d0
                beq       vib
                cmp.b     #$05,d0
                beq       port_toneslide
                cmp.b     #$06,d0
                beq       vib_toneslide
                move.w    $10(a4),$06(a3)
                cmp.b     #$0a,d0
                beq.s     volslide
                rts

volslide:
                moveq     #0,d0
                move.b    $03(a4),d0
                lsr.b     #4,d0
                tst.b     d0
                beq.s     voldown
                add.w     d0,$12(a4)
                cmpi.w    #$40,$12(a4)
                bmi.s     vol2
                move.w    #$40,$12(a4)
vol2:           move.w    $12(a4),$08(a3)
                rts

voldown:        moveq     #0,d0
                move.b    $03(a4),d0
                and.b     #$0f,d0
                sub.w     d0,$12(a4)
                bpl.s     vol3
                clr.w     $12(a4)
vol3:           move.w    $12(a4),$08(a3)
                rts

portup:         moveq     #0,d0
                move.b    $03(a4),d0
                sub.w     d0,$10(a4)
                move.w    $10(a4),d0
                and.w     #$0fff,d0
                cmp.w     #$71,d0
                bpl.s     por2
                andi.w    #$f000,$10(a4)
                ori.w     #$71,$10(a4)
por2:           move.w    $10(a4),d0
                and.w     #$0fff,d0
                move.w    d0,$06(a3)
                rts

port_toneslide:
                bsr       myslide
                bra.s     volslide

vib_toneslide:
                bsr       vi
                bra.s     volslide

portdown:
                clr.w     d0
                move.b    $03(a4),d0
                add.w     d0,$10(a4)
                move.w    $10(a4),d0
                and.w     #$0fff,d0
                cmp.w     #$0358,d0
                bmi.s     por3
                andi.w    #$f000,$10(a4)
                ori.w     #$0358,$10(a4)
por3:           move.w    $10(a4),d0
                and.w     #$0fff,d0
                move.w    d0,$06(a3)
                rts

checkcom2:
                move.b    $02(a4),d0
                and.b     #$0f,d0
                cmp.b     #$0d,d0
                beq.s     pattbreak
                cmp.b     #$0b,d0
                beq.s     posjmp
                cmp.b     #$0c,d0
                beq.s     setvol
                cmp.b     #$0f,d0
                beq.s     setspeed
                rts

pattbreak:
                st        break
                rts

posjmp:         move.b    $03(a4),d0
                subq.b    #$01,d0
                move.b    d0,songpos
                st        break
                rts

setvol:         moveq     #0,d0
                move.b    $03(a4),d0
                cmp.w     #$40,d0
                ble.s     vol4
                move.b    #$40,$03(a4)
vol4:           move.b    $03(a4),$09(a3)
                move.b    $03(a4),$13(a4)
                rts

setspeed:
                cmpi.b    #$1f,$03(a4)
                ble.s     sets
                move.b    #$1f,$03(a4)
sets:           move.b    $03(a4),d0
                beq.s     rts2
                move.w    d0,speed
                clr.w     counter
rts2:           rts

sin:          dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
              dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

periods:      dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
              dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$fe
              dc.w $f0,$e2,$d6,$ca,$be,$b4,$aa,$a0,$97,$8f,$87
              dc.w $7f,$78,$71,$00,$00

speed:        dc.w $06
counter:      dc.w $00
songpos:      dc.b $00
break:        dc.b $00
pattpos:      dc.w $00

dmacon:       dc.w $00
samplestarts: ds.l $1f

voice1:       ds.w 10
              dc.w $01
              ds.w 3
voice2:       ds.w 10
              dc.w $02
              ds.w 3
voice3:       ds.w 10
              dc.w $04
              ds.w 3
voice4:       ds.w 10
              dc.w $08
              ds.w 3

data:         ibytes 'ZAP.MOD'

              ds.b 16384                      ; Workspace
workspc:      ds.w 1

              even
**********************************************************************
**********************************************************************
* MW set
set_mw:         move.w    #$07ff,$ffff8924.w      ; to mw mask
                lea       mw_set,a0               ; microwire settings
                lea       $ffff8922.w,a1          ; mw data

                move.w    (a1),d7                 ; save previous
mw_loop:        move.w    (a0)+,(a1)
mw_wait:        cmp.w     (a1),d7
                bne.s     mw_wait
                cmpa.l    #mw_setend,a0
                bne.s     mw_loop
                rts

* --------------------------------------------------------------------
mw_set:       dc.w %10011000000+15            ;+40            ; master    0-40
              dc.w %10101000000+20            ; left      0-20
              dc.w %10100000000+20            ; right     0-20
              dc.w %10010000000+6             ; treble    0-12 (6=0dB)
              dc.w %10001000000+9             ; bass      0-12 (6=0dB)
;              dc.w %10000000000+1             ; mix       0-03
mw_setend:

**********************************************************************

* --------------------------------------------------------------- restore

back:           move.l    oldvbl,$70.w
                move.b    #0,$ffff8901.w
                move.w    #1,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp
                lea       mw_set,a0
                addi.w    #20,(a0)+
                addq.l    #6,a0
                subq.w    #3,(a0)
                jsr       set_mw
                rts


* --------------------------------------------------------------- data
* starts with "space", 32
char_off:
              dc.w 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152
              dc.w $0500,$0500+8,$0500+16,$0500+24,$0500+32,$0500+40,$0500+48,$0500+56,$0500+64
              dc.w $0500+72,$0500+80,$0500+88,$0500+96,$0500+104,$0500+112,$0500+120,$0500+128
              dc.w $0500+136,$0500+144,$0500+152
              dc.w $0a00,$0a00+8,$0a00+16,$0a00+24,$0a00+32,$0a00+40,$0a00+48,$0a00+56,$0a00+64
              dc.w $0a00+72,$0a00+80,$0a00+88,$0a00+96,$0a00+104,$0a00+112,$0a00+120,$0a00+128
              dc.w $0a00+136,$0a00+144,$0a00+152
              dc.w $0f00,$0f00+8,$0f00+16,$0f00+24,$0f00+32,$0f00+40,$0f00+48,$0f00+56,$0f00+64
              dc.w $0f00+72,$0f00+80,$0f00+88,$0f00+96,$0f00+104,$0f00+112,$0f00+120,$0f00+128
              dc.w $0f00+136,$0f00+144,$0f00+152
              dc.w $1400,$1400+8,$1400+16,$1400+24,$1400+32,$1400+40,$1400+48,$1400+56
              dc.w $1400+64,$1400+72,$1400+80,$1400+88,$1400+96,$1400+104,$1400+112
              dc.w $1400+120,$1400+128,$1400+136,$1400+144,$1400+152

* --------------------------------------------------------------------
txt:
              dc.b "           "
              dc.b "THE INNER CIRCUIT EXPLORERS ARE BACK ON THE STAGE!  THIS TIME WITH "
              dc.b "A NICE COLLECTION DISK.  IT CONTAINS SOME COOLED ICE STE "
              dc.b "DEMOS RELEASED FROM THE FIRST OF APRIL 1991 TO THE "
              dc.b "BEGINNING OF 1992!    "

              dc.b "OUR FIRST PRODUCED DEMO WAS ",34,"THE ENCHANTED DEMO",34
              dc.b ".  NEVER WELL SPREADED, EITHER THE FOLLOWING DEMOS "
              dc.b "WE THINK.  THAT'S THE MAIN REASON WHY THIS COLLECTION "
              dc.b "DISK WAS BORN!  TO SPREAD OUR STE DEMOS EVEN FURTHER!  "
              dc.b "SO PLEASE LET THE DRIVE EAT IT, MAN!   COPY 10 SECTORS, 83 TRACKS, DS!"
              dc.b "  IT'S ALL SHAREWARE!  U KNOW WHAT THAT MEAN, EH??        "
              dc.b "CREDITS FOR 'DIS LITTLE SCREEN:     "
              dc.b "CODE & GFX BY TECHWAVE.    SMALL, SHORT & NICE MODULE BY "
              dc.b "MAGNUS ERIKSSON  (HI! KEEP ON COMPOSING MAN!)...   "
              dc.b "SORRY, BUT THIS TRACK-PLAYER AIN'T SO CORRECT YET...   "
              dc.b "NOW SOME ADVERTISMENT:  WATCH OUT FOR CODFI'S NEW, "
              dc.b "GREAT & ICEIGT 3D DEMO: ",34,"THE SKYWALKING DEMO",34,"!            "
              dc.b "LITTLE MESSAGE TO ANTOX & TURTLE: -EARL GREY SKALL ALDRIG VARA KYLT MEN DET SKALL ICE!  (GAMMAL TE VISDOM!)      "
              dc.b "MESSAGE TO OTHER MEMBERS OF ICE: -DRICK TE OCH SKYLL ER SELF ATT JAG GJORDE DENNA SCREEN...      "
              dc.b "TIME TO PUT AN END TO 'DIS!  (AND DON'T U THINK I DON'T HAVE SOME SMALL LETTERS... ICE rules the world! Hahaha!) "
              dc.b " FEED THE TEA-BUSH...  LET'S SCRATCH IT!   Bye!                                    "
              dc.b 0
              even

* --------------------------------------------------------------------

oldvbl:       dc.l 0

to_skew:      dc.b 12
bit_flg:      dc.b 0
              even

txt_pointer:  dc.w 0
offset:       dc.w 0
screen1:      dc.l 0

fontpic:      ibytes 'COMPFONT.PI1',6434      ; 6400+34
screen:       ibytes 'COLLECT2.NEO'
end_scroll:   ds.b 32000+(640)
              end
