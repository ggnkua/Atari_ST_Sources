
        >PART
        endpart

; play field demo by The Fate of ULM (c) 1990 and for all eternity...

        default 4
        output 'PLAY_FLD.PRG'

def_version equ 10
d0_for_mcp equ 0
mcp_adr equ $0500
keyboard set 10

bg_font equ 2
music_len set 0                 ;499

test    equ 10

        ifne def_version
stmspl  set $0608
        endc
        ifeq def_version
        opt D-
        default 3
        output 'E:\PACK\PLAY_FLD.BIN'
beg:    org $2500
keyboard set 0

        bra.s   start
play_buf:
        ds.l 20

stmspl  set $2500+play_buf-beg
music_len set 0
        endc

        text
x:
        ifne def_version
        opt D+
        pea     start(pc)
        move.w  #38,-(sp)
        trap    #14
        addq.l  #6,sp

        clr.w   -(sp)
        trap    #1
        endc

start:
        lea     oldcpu(pc),a0
        move.l  sp,(a0)+
        lea     my_stack,sp
        move    sr,(a0)+
        move    #$2700,sr
        move    usp,a1
        move.l  a1,(a0)+

        ifne def_version
        moveq   #$12,d0
        bsr     ikbd_wrt
        moveq   #$1a,d0
        bsr     ikbd_wrt

        move.l  $0408.w,old_408
        move.l  #exit_with_408,$0408.w
        endc

        lea     oldvideo(pc),a0
        move.b  $ffff8260.w,(a0)+
        move.b  $ffff820a.w,(a0)+
        move.l  $ffff8200.w,(a0)+
        movem.l $ffff8240.w,d0-d7
        movem.l d0-d7,(a0)

        movem.l black(pc),d0-d7
        movem.l d0-d7,$ffff8240.w

        lea     oldvectors(pc),a0
        move.l  $68.w,(a0)+
        move.l  $70.w,(a0)+
        move.l  $0114.w,(a0)+
        move.l  $0118.w,(a0)+
        move.l  $0120.w,(a0)+
        move.l  $0134.w,(a0)+
        move.l  #nix,$68.w
        move.l  #nix,$70.w
        move.l  #nix,$0114.w
        ifeq keyboard
        move.l  #nix,$0118.w
        endc
        move.l  #nix,$0120.w
        move.l  #nix,$0134.w

        lea     oldmfp(pc),a0
        move.b  $fffffa07.w,(a0)+
        move.b  $fffffa09.w,(a0)+
        move.b  $fffffa13.w,(a0)+
        move.b  $fffffa15.w,(a0)+
        move.b  $fffffa17.w,(a0)+
        move.b  $fffffa19.w,(a0)+
        move.b  $fffffa1b.w,(a0)+
        move.b  $fffffa1d.w,(a0)+

        bclr    #3,$fffffa17.w
        clr.b   $fffffa07.w
        ifeq keyboard
        clr.b   $fffffa09.w
        endc
        ifne keyboard
        move.b  #%1000000,$fffffa09.w
        endc

        bsr     waitvbl
        move.b  #0,$ffff8260.w
        move.b  #2,$ffff820a.w

        bsr     psginit

        bsr     mfp_test

        bra     screen
back:

        lea     my_stack,sp

        bsr     psginit

        lea     oldmfp(pc),a0
        move.b  (a0)+,$fffffa07.w
        move.b  (a0)+,$fffffa09.w
        move.b  (a0)+,$fffffa13.w
        move.b  (a0)+,$fffffa15.w
        move.b  (a0)+,$fffffa17.w
        move.b  (a0)+,$fffffa19.w
        move.b  (a0)+,$fffffa1b.w
        move.b  (a0)+,$fffffa1d.w

        lea     oldvectors(pc),a0
        move.l  (a0)+,$68.w
        move.l  (a0)+,$70.w
        move.l  (a0)+,$0114.w
        move.l  (a0)+,$0118.w
        move.l  (a0)+,$0120.w
        move.l  (a0)+,$0134.w

        move.b  #2,$ffff820a.w
        bsr.s   waitvbl
        move.b  #0,$ffff820a.w
        bsr.s   waitvbl
        move.b  #2,$ffff820a.w
        bsr.s   waitvbl

        lea     oldvideo(pc),a0
        move.b  (a0)+,$ffff8260.w
        move.b  (a0)+,$ffff820a.w
        move.l  (a0)+,$ffff8200.w
        movem.l (a0),d0-d7
        movem.l d0-d7,$ffff8240.w

        ifne def_version
        moveq   #$14,d0
        bsr.s   ikbd_wrt
        moveq   #$08,d0
        bsr.s   ikbd_wrt
        endc

        lea     oldcpu(pc),a0
        movea.l (a0)+,sp
        move    (a0)+,sr
        movea.l (a0)+,a1
        move    a1,usp

        ifne def_version
        move.l  old_408(pc),$0408.w

        rts
        endc

        ifeq def_version
        moveq   #d0_for_mcp,d0
        jsr     mcp_adr.w
        endc

psginit:
        moveq   #10,d0
        lea     $ffff8800.w,a0
nextinit:
        move.b  d0,(a0)
        move.b  #0,2(a0)
        dbra    d0,nextinit
        move.b  #7,(a0)
        move.b  #$7f,2(a0)
        move.b  #14,(a0)
        move.b  #$26,2(a0)
        rts

waitvbl:
        movem.l d0-d1/a0,-(sp)
        lea     $ffff8209.w,a0
        movep.w -8(a0),d0
waitvblx1:
        tst.b   (a0)
        beq.s   waitvblx1
waitvblx2:
        tst.b   (a0)
        bne.s   waitvblx2
        movep.w -4(a0),d1
        cmp.w   d0,d1
        bne.s   waitvblx2
        movem.l (sp)+,d0-d1/a0
        rts

ikbd_wrt:
        lea     $fffffc00.w,a0
ik_wait:
        move.b  (a0),d1
        btst    #1,d1
        beq.s   ik_wait
        move.b  d0,2(a0)
        rts

mfp_test:
        move.b  #0,$fffffa19.w
        move.b  #255,$fffffa1f.w
        move.b  #1,$fffffa19.w

        moveq   #-1,d0
mfp_test_loop:
        dbra    d0,mfp_test_loop

        moveq   #0,d0
        move.b  $fffffa1f.w,d0
        move.b  #0,$fffffa19.w
        cmp.w   #$9b,d0
        ble.s   mfp_of_my_st
        move.w  #-1,mfp_type
mfp_of_my_st:
        rts

        ifne def_version
        dc.l 'XBRA'
        dc.l 'TFSY'
old_408:
        dc.l 0
exit_with_408:
        bsr.s   exit
        movea.l old_408(pc),a0
        jmp     (a0)
        endc

exit:
        movem.l black(pc),d0-d7
        movem.l d0-d7,$ffff8240.w

        bra     back

nix:
        rte

oldcpu: ds.w 4
oldvideo:ds.w 19
oldvectors:ds.l 6
oldmfp: ds.w 5
mfp_type:ds.w 1
black:  ds.l 16

screen:
        lea     bss_start,a0
        lea     bss_end,a1
        movem.l black(pc),d1-d7/a2-a6
clear_loop:
        movem.l d1-d7/a2-a6,(a0)
        movem.l d1-d7/a2-a6,12*4(a0)
        movem.l d1-d7/a2-a6,24*4(a0)
        lea     36*4(a0),a0
        cmpa.l  a0,a1
        bpl.s   clear_loop

        move.l  #screenmem,d0
        ror.l   #8,d0
        lea     $ffff8201.w,a0
        movep.w d0,0(a0)

        moveq   #0,d0
        movea.l movetab2pos(pc),a0
        move.b  (a0),d0
        bclr    #0,d0
        ext.w   d0
        move.w  d0,rl_rich

        lea     screenmem,a0
        adda.l  #-4*8+230,a0
        move.l  a0,screenadr

        lea     6+5*8+138*230(a0),a0
        lea     11*230(a0),a0
        move.l  a0,scrollbas

        lea     screenmem,a6
        lea     graphic(pc),a5
        movem.l (a5),d1-d2
        movem.l (a5),d3-d4
        movem.l (a5),d5-d6
        movem.l (a5),d7-a0
        movem.l (a5),a1-a2
        move.w  #549,d0
graphiccop:
        movem.l d1-a2,(a6)
        movem.l d1-a2,40(a6)
        movem.l d1-a2,80(a6)
        movem.l d1-a2,120(a6)
        movem.l d1-a2,160(a6)
        movem.l d1-a2,200(a6)
        lea     230(a6),a6
        dbra    d0,graphiccop

        lea     screenmem,a6
        lea     139*230+3*8(a6),a6
        lea     59*230(a6),a6
        lea     pic2,a0
        move.w  #185,d0
pic_loop:
        movem.l (a0)+,d1-d7/a1-a5
        movem.l d1-d7/a1-a5,(a6)
        movem.l (a0)+,d1-d7/a1-a5
        movem.l d1-d7/a1-a5,12*4(a6)
        movem.l (a0)+,d1-d7/a1-a5
        movem.l d1-d7/a1-a5,24*4(a6)
        movem.l (a0)+,d1-d4
        movem.l d1-d4,36*4(a6)
        lea     230(a6),a6
        dbra    d0,pic_loop

        lea     screenmem,a6
        lea     5*230+3*8(a6),a6
        lea     pic(pc),a0
        move.w  #144,d0
pic_loop2:
        movem.l (a0)+,d1-d7/a1-a5
        movem.l d1-d7/a1-a5,(a6)
        movem.l (a0)+,d1-d7/a1-a5
        movem.l d1-d7/a1-a5,12*4(a6)
        movem.l (a0)+,d1-d7/a1-a5
        movem.l d1-d7/a1-a5,24*4(a6)
        movem.l (a0)+,d1-d4
        movem.l d1-d4,36*4(a6)
        lea     230(a6),a6
        dbra    d0,pic_loop2

        lea     screenmem,a3
        lea     screenmem2,a4
        move.w  #388,d0
shift8:
        movea.l a3,a5
        movea.l a4,a6
        moveq   #27,d1
shift81:
        movep.l 0(a5),d2
        movep.l d2,-7(a6)
        movep.l 1(a5),d2
        movep.l d2,0(a6)
        lea     8(a5),a5
        lea     8(a6),a6
        dbra    d1,shift81
        lea     230(a3),a3
        lea     230(a4),a4
        dbra    d0,shift8

        lea     my_stack,sp

        moveq   #1,d0
        jsr     music

        move.w  #stmspl,music+$0250

        lea     music_buf,a0

        ifeq music_len
        move.w  #9449,d0
        endc
        ifne music_len
        move.w  #music_len,d0
        endc
all_play:
        move.w  d0,music_keepd0
        move.l  a0,music_keepa0
        jsr     music+8
music_keepa0 equ *+2
        movea.l #0,a0
        lea     stmspl+2.w,a1
        lea     music_tab,a2
        move.b  (a1),(a0)+      ;reg0
        move.b  8(a1),(a0)+     ;reg2
        move.b  16(a1),(a0)+    ;reg4
        move.b  28(a1),(a0)+    ;reg7
        move.b  24(a1),(a0)+    ;reg6

        moveq   #0,d0

        move.b  4(a1),d0
        and.b   #%1111,d0
        move.b  0(a2,d0.w),d0
        or.b    32(a1),d0
        move.b  d0,(a0)+

        move.b  12(a1),d0
        and.b   #%1111,d0
        move.b  0(a2,d0.w),d0
        or.b    36(a1),d0
        move.b  d0,(a0)+

        move.b  20(a1),d0
        and.b   #%1111,d0
        move.b  0(a2,d0.w),d0
        or.b    40(a1),d0
        move.b  d0,(a0)+

music_keepd0 equ *+2
        move.w  #0,d0
        dbra    d0,all_play

        move.l  a0,music_end

        lea     farbtab,a0
        lea     hsin,a1
        moveq   #0,d1
        move.w  #599,d0
fill_loop:
        move.b  (a1)+,d1
        move.w  d1,(a0)+
        cmpa.l  #hsinend,a1
        bne.s   fill_ok
        lea     hsin,a1
fill_ok:
        dbra    d0,fill_loop
        move.l  a1,aktinhsin

        lea     scr_puf1,a0
        move.w  #(scr_puf2-scr_puf1)*2/4-1,d0
        moveq   #-1,d1
fill_scr_puf:
        move.l  d1,(a0)+
        dbra    d0,fill_scr_puf

        lea     text,a0
        moveq   #0,d0
        move.b  (a0)+,d0
        move.l  a0,text_poin
        lsl.w   #3,d0
        lea     fonttab,a0
        move.l  0(a0,d0.w),akt_char_poin
        move.w  6(a0,d0.w),scr_max_char_off

        bsr     waitvbl

        lea     $ffff8209.w,a0
        moveq   #0,d0
        moveq   #20,d2
sync2:
        move.b  (a0),d0
        beq.s   sync2
        sub.w   d0,d2
        lsl.l   d2,d2

testl:
        bsr     waitvbl

loop:

        ds.w 2,$4e71
        movem.l black(pc),d0-d7
        lea     $ffff8240.w,a0
        movem.l d0-d7,(a0)

        move.w  #4,d3
hz_504  equ *+2
        sub.w   #0,d3
        move.w  d3,hz_504

        movem.l pal(pc),d6-d7/a5-a6
        lea     $ffff8209.w,a3
        moveq   #0,d3
        moveq   #10,d4

        move.w  #$00,d0
        lea     bg_scr_pal1,a1
        move.w  (a1)+,d1

        moveq   #4,d2
bg_line1:
        ds.w 3,$4e71
        move.w  d2,(a0)
bg_buf1:
        ds.w 52,$3080           ;52 words scrolline,$3080

        move.w  d2,(a0)
        move.w  (a1)+,d1
        ds.w 14-2,$4e71
        dbra    d2,bg_line1

        moveq   #4,d2
        bra.s   bg_buf2

bg_line2:
        ds.w 3,$4e71
        move.w  d2,(a0)
bg_buf2:
        ds.w 52,$3080           ;52 words scrolline,$3080

        move.w  d2,(a0)
        move.w  (a1)+,d1
        ds.w 14-2,$4e71
        dbra    d2,bg_line2

        moveq   #4,d2
        bra.s   bg_buf3
bg_line3:
        ds.w 3,$4e71
        move.w  d2,(a0)
bg_buf3:
        ds.w 52,$3080           ;52 words scrolline,$3080

        move.w  d2,(a0)
        move.w  (a1)+,d1
        ds.w 14-2,$4e71
        dbra    d2,bg_line3

        moveq   #4,d2
        bra.s   bg_buf4
bg_line4:
        ds.w 3,$4e71
        move.w  d2,(a0)
bg_buf4:
        ds.w 52,$3080           ;52 words scrolline,$3080

        move.w  d2,(a0)
        move.w  (a1)+,d1
        ds.w 14-2,$4e71
        dbra    d2,bg_line4

        moveq   #4,d2
        bra.s   bg_buf5
bg_line5:
        ds.w 3,$4e71
        move.w  d2,(a0)
bg_buf5:
        ds.w 52,$3080           ;52 words scrolline,$3080
        move.w  d2,(a0)
        move.w  d0,(a0)
        move.w  (a1)+,d1
        ds.w 14-2-2,$4e71
        dbra    d2,bg_line5

        cmpi.b  #57,$fffffc02.w
        beq     exit

        movea.l schaltnum,a0

sync:
        move.b  (a3),d3
        beq.s   sync
        sub.w   d3,d4
        lsl.l   d4,d4

        moveq   #5,d0
        nop

        bra     intoall

switchloop:
        ds.w 3,$4e71
        tst.b   (a0)+
        bne.s   links1
        move.b  #2,$ffff820a.w
        ds.w 19,$4e71           ;-4*2
        bra.s   cont1

links1:
        move.b  #1,$ffff8260.w  ;GunsticK's right border end switch
        move.b  #0,$ffff8260.w
;links1:
        move.b  #2,$ffff820a.w
        ds.w 5,$4e71
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
cont1:
        ds.w 28,$4e71
intoall:
        tst.b   (a0)+
        bne.s   mitte
        ds.w 6,$4e71
        bra.s   cont3
mitte:
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
cont3:
        lea     coltab,a2
codmodvsin equ *+2
        adda.w  #0,a2
        lea     farbtab,a1
codmodhsin equ *+2
        adda.w  #0,a1

        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        ds.w 6,$4e71

        tst.b   (a0)+
        bne.s   rechts1
        tst.b   (a0)+
        bne.s   rechts2
        ds.w 7,$4e71
        bra.s   cont4

rechts1:
        move.b  #0,$ffff820a.w
        addq.w  #1,a0
        ds.w 4,$4e71
        bra.s   cont4

rechts2:
        ds.w 4,$4e71
        move.b  #0,$ffff820a.w
        nop
cont4:
        dbra    d0,switchloop
        move.b  #2,$ffff820a.w
;HERE WE ARE SYNCHRON
;These lines are to be used if the screen uses left border

        ds.w 3,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l d6-d7/a5-a6,$ffff8240.w

        moveq   #0,d0
        tst.w   rl_rich
        beq.s   rl_null
        bmi.s   rl_minus
rl_plus:
        lea     screenmem+8,a5
        adda.l  screenoff,a5
        adda.w  blknum,a5
        lea     -22+230(a5),a6
        bra.s   rl_stop
rl_null:
        lea     screenmem,a5
        adda.l  screenoff,a5
        adda.w  blknum,a5
        lea     0(a5),a6
        bra.s   rl_stop2
rl_minus:
        lea     screenmem-16,a5
        adda.l  screenoff,a5
        adda.w  blknum,a5
        lea     22-230(a5),a6
        ds.w 1,$4e71
rl_stop2:
        ds.w 1,$4e71
rl_stop:

;jumping raster init
jump_lines equ *+2
        move.w  #145*4,d4

        ds.w 27-2,$4e71

        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        lea     $ffff8260.w,a0
        moveq   #77,d0
lo0001:
        move.l  (a5)+,(a6)+

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5/a7,$ffff8250.w
        move.b  #2,(a0)
        move.b  #0,(a0)
        move.l  (a5)+,(a6)+
        move.l  222(a5),222(a6)
        move.l  226(a5),226(a6)
        move.l  222+230*1(a5),222+230*1(a6)
        move.l  226+230*1(a5),226+230*1(a6)
        move.l  222+230*2(a5),222+230*2(a6)
        move.l  226+230*2(a5),226+230*2(a6)
        move.l  222+230*3(a5),222+230*3(a6)
        move.l  226+230*3(a5),226+230*3(a6)
        lea     5*230-8(a5),a5
        lea     5*230-8(a6),a6
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back0:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w
        dbra    d0,lo0001

        ds.w 4,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

textpoin equ *+2
        lea     bg_scr_text,a5
charpoin equ *+2
        lea     bg_scr_font,a6
charlen equ *+2
        move.w  #1,d0
        subq.w  #1,d0
        beq.s   charlen_nok
        ds.w 26,$4e71
        bra.s   charlen_ok
charlen_nok:
        move.b  (a5)+,d0
        bmi.s   bg_text_end
        ds.w 3,$4e71
        bra.s   text_notend
bg_text_end:
        lea     bg_scr_text,a5
        move.b  (a5)+,d0

text_notend:
        move.l  a5,textpoin
        ifne bg_font-2
        lsl.w   #6,d0
        lea     bg_scr_font+4,a6
        adda.w  d0,a6
        move.w  -4(a6),d0
        endc
        ifeq bg_font-2
        lsl.w   #7,d0
        lea     bg_scr_font+8,a6
        adda.w  d0,a6
        move.w  -8(a6),d0
        endc

charlen_ok:
        move.w  d0,charlen

        ds.w 22-5,$4e71

        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back1:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8-4,$4e71
        lea     bg_buf1+2(pc),a0
        lea     32(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.l  (a0)+,-6(a0)
        ds.w 1,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back2:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        move.l  (a0)+,-6(a0)

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.w  (a6)+,-4(a0)
        nop
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back3:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8-4,$4e71
        lea     bg_buf2+2(pc),a0
        lea     32(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.l  (a0)+,-6(a0)
        ds.w 5-4,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back4:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        move.l  (a0)+,-6(a0)

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.w  (a6)+,-4(a0)
        ds.w 1,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back5:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 4,$4e71
        lea     bg_buf3+2(pc),a0
        lea     32(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.l  (a0)+,-6(a0)
        ds.w 5-4,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back6:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        move.l  (a0)+,-6(a0)

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.w  (a6)+,-4(a0)
        ds.w 1,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back7:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 4,$4e71
        lea     bg_buf4+2(pc),a0
        lea     32(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.l  (a0)+,-6(a0)
        ds.w 5-4,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back8:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        move.l  (a0)+,-6(a0)

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.w  (a6)+,-4(a0)
        ds.w 1,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back9:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 4,$4e71
        lea     bg_buf5+2(pc),a0
        lea     32(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.l  (a0)+,-6(a0)
        ds.w 5-4,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back10:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        move.l  (a0)+,-6(a0)

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l (a0)+,d0-d3/d5-d7/a3-a5/a7
        movem.l d0-d3/d5-d7/a3-a5/a7,-11*4-2(a0)
        move.l  (a0)+,-6(a0)
        move.w  (a6)+,-4(a0)
        ds.w 1,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back11:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        move.l  a6,charpoin
        lea     32(a2),a2
        ds.w 1,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

pointdist equ *+2
        move.w  #0,d0
        move.w  d0,d1
        addq.w  #4,d0
        cmp.w   #300*4,d0
        bne.s   pointdis_ok
        moveq   #0,d0
pointdis_ok:
        move.w  d0,pointdist
        move.w  d0,codmodhsin

        moveq   #0,d0
        movea.l aktinhsin,a0
        move.b  (a0)+,d0
        swap    d0
        move.b  (a0)+,d0
        cmpa.l  #hsinend+2,a0
        bne.s   hsin_ok
        lea     hsin,a0
        move.b  (a0)+,d0
        swap    d0
        move.b  (a0)+,d0
        bra.s   hsin_nok
hsin_ok:
        ds.w 11,$4e71
hsin_nok:
        move.l  a0,aktinhsin
        lea     farbtab,a0
        adda.w  d1,a0
        move.l  d0,(a0)
        move.l  d0,1200(a0)

        nop

        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back12:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movea.l aktinvsin,a0
        move.w  (a0)+,d0
        move.w  (a0)+,d1
        cmpa.l  #vsinend+4,a0
        bne.s   vsin_ok
        lea     vsin,a0
        move.w  (a0)+,d0
        move.w  (a0)+,d1
        bra.s   vsin_nok
vsin_ok:
        ds.w 10,$4e71
vsin_nok:
        move.w  d0,codmodvsin
        move.l  a0,aktinvsin
        add.w   d1,codmodhsin

        ds.w 31-4-8-5,$4e71

        opt O-
movetab2pos equ *+2
        lea     movetab2,a0
        opt O+
screenadr equ *+2
        movea.l #0,a5
        move.b  (a0),d1

        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back13:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 6,$4e71
        lea     32(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        bclr    #0,d1
        bne.s   sp_word
        move.l  #screenmem2-screenmem,d0
screenoff equ *+2
        sub.l   #0,d0
        move.l  d0,screenoff
        tst.w   d0
        beq.s   herz251
        move.b  (a0),d1
        bclr    #0,d1
        ext.w   d1
        move.w  d1,rl_rich
        tst.w   d1
        blt.s   other_way2
        moveq   #0,d1
other_way2:
        adda.w  d1,a5
        move.w  d1,d3
        add.w   blknum,d1
        bra.s   herz252
herz251:
        move.b  (a0)+,d1
        bclr    #0,d1
        ext.w   d1
        move.w  d1,rl_rich
        tst.w   d1
        bgt.s   other_way1
        moveq   #0,d1
other_way1:
        adda.w  d1,a5
        move.w  d1,d3
        add.w   blknum,d1
        ds.w 2,$4e71
herz252:
        bra.s   sp_byte
sp_word:
        moveq   #0,d0
        move.b  (a0)+,d1
        bclr    #0,d1
        ext.w   d1
        move.w  d1,rl_rich
        adda.w  d1,a5
        move.w  d1,d3
        add.w   blknum,d1
        ds.w 23,$4e71
sp_byte:
        ext.l   d3
        add.l   d3,scrollbas

        ds.w 13-5,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back14:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        cmpa.l  #movetab2end,a0
        bne.s   move2pos_ok
        lea     movetab2(pc),a0
        bra.s   move2pos_nok
move2pos_ok:
        ds.w 5,$4e71
move2pos_nok:

        move.l  a0,movetab2pos

        ds.w 70-4-5-12-4,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back15:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        move.l  d0,scr_ad_corr

        opt O-
movetabpos equ *+2
        lea     movetab,a0
        opt O+
        moveq   #0,d0
        move.b  (a0)+,d0
        ext.w   d0
        cmpa.l  #movetabend,a0
        bne.s   movepos_ok
        lea     movetab(pc),a0
        bra.s   movepos_nok
movepos_ok:
        ds.w 5,$4e71
movepos_nok:
        move.l  a0,movetabpos
        lea     mul230(pc),a0
        move.w  0(a0,d0.w),d0
        adda.w  d0,a5
        move.l  a5,screenadr

        cmp.w   #-8,d1
        bne.s   blknum_ok
        move.w  #912,d1
        bra.s   blknum_nok
blknum_ok:
        ds.w 4,$4e71
blknum_nok:
        cmp.w   #920,d1
        bne.s   blknum_ok2
        moveq   #0,d1
blknum_ok2:
        move.w  d1,blknum

        ds.w 2,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back16:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

akt_in_music equ *+2
        lea     music_buf,a0
        lea     stmspl+2.w,a5
        move.b  (a0)+,(a5)      ;reg0

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        move.b  (a0)+,8(a5)     ;reg2
        move.b  (a0)+,16(a5)    ;reg4
        move.b  (a0)+,28(a5)    ;reg7
        move.b  (a0)+,24(a5)    ;reg6


        move.b  (a0)+,d0
        move.w  d0,d1
        and.w   #%1111,d0
        move.b  d0,32(a5)
        lsr.w   #4,d1
        move.b  d1,4(a5)

        move.b  (a0)+,d0
        move.w  d0,d1
        and.w   #%1111,d0
        move.b  d0,36(a5)
        lsr.w   #4,d1
        move.b  d1,12(a5)

        ds.w 17,$4e71

        move.w  (a1)+,d2
        movem.l 32(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back17:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 6,$4e71
        lea     64(a2),a2

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        move.b  (a0)+,d0
        move.w  d0,d1
        and.w   #%1111,d0
        move.b  d0,40(a5)
        lsr.w   #4,d1
        move.b  d1,20(a5)

        ds.w 1+12+26-5,$4e71

music_end equ *+2
        cmpa.l  #0,a0
        beq.s   music_nok
        bra.s   music_ok
music_nok:
        lea     music_buf,a0
music_ok:
        move.l  a0,akt_in_music

        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back18:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l stmspl.w,d0-d3/d5-a0/a5-a7
        movem.l d0-d3/d5-a0/a5-a7,$ffff8800.w

        ds.w 70-31-26-4-5,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back19:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

scr_ad_corr equ *+2
        move.l  #0,d2

        lea     screenadr(pc),a6
        add.l   d2,(a6)
        moveq   #0,d1
        move.b  3(a6),d1
        move.w  d1,d0
        add.w   d1,d1
        add.w   d0,d1
        add.w   d1,d1
        add.w   d1,d1           ;*12 (24 byte per tabentry)
        lea     $ffff8201.w,a5
        lea     hwscrolldat,a0
        lea     0(a0,d1.w),a0
        movep.w 1(a6),d1
        move.b  2(a6),d1
        move.b  (a0)+,d0
        ext.w   d0
        add.w   d0,d1
        movep.w d1,0(a5)
        move.l  a0,schaltnum
        sub.l   d2,(a6)

        ds.w 70-54-4-4,$4e71

        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back20:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        ds.w 70-4-5,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back21:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        moveq   #95-50,d0       ;mark
lo0002:
        ds.w 5,$4e71
        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        ds.w 70-4-5,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

;jumping raster
        subq.l  #4,d4
        beq     jump_rast
ras_back22:

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w
        dbra    d0,lo0002

        ds.w 4,$4e71
        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        ds.w 72-4,$4e71
        move.w  (a1)+,d2
        movem.l 32(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        lea     64(a2),a2
        ds.w 10,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w
        move.b  #2,$ffff820a.w  ;lower border

        ds.w 68-4,$4e71
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        ds.w 70-4,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

wcount  equ 6

scr_off equ *+2
        move.w  #0,d0
        move.w  hz_504(pc),d1
        beq.s   off_add
        ds.w 2+3,$4e71
        bra.s   no_off_add
off_add:
        add.w   #4,d0
        cmp.w   #(20+wcount)*4,d0
        bne.s   scr_off_ok
        moveq   #0,d0
scr_off_ok:
no_off_add:
        move.w  d0,scr_off

        lea     scr_puf_tab,a3
        movea.l 0(a3,d1.w),a3
        adda.w  d0,a3
        movea.l a3,a5

        movea.l scrollbas,a6
        adda.l  screenoff,a6

        ds.w 70-31-11-4+1,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        moveq   #13,d0
lo00032:
        ds.w 5,$4e71
        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movea.l (a5)+,a0
        move.w  (a0)+,(a6)
var1    set 0
        rept 15
var1    set var1+1
        move.w  (a0)+,var1*230(a6)
        endr

        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        rept 16
var1    set var1+1
        move.w  (a0)+,var1*230(a6)
        endr

        ds.w 2,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        rept 16
var1    set var1+1
        move.w  (a0)+,var1*230(a6)
        endr
        lea     8(a6),a6

        ds.w 12-12,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        dbra    d0,lo00032

        ds.w 4,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        ds.w 70-7,$4e71
        movem.l black(pc),d0-d7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        movem.l d0-d7,$ffff8240.w

        moveq   #5+wcount,d0
scr_cop_loop:
        movea.l (a5)+,a0
        move.w  (a0)+,(a6)
var1    set 0
        rept 47
var1    set var1+1
        move.w  (a0)+,var1*230(a6)
        endr
        lea     8(a6),a6
        dbra    d0,scr_cop_loop

        movea.l (a3),a6
scr_char_off equ *+2
        move.w  #-96,d0

        tst.w   hz_504
        bne.s   nachpuff2

akt_char_poin equ *+2
        lea     font,a0
        adda.w  d0,a0
        movem.l (a0)+,d0-d7/a2-a5
        movem.l d0-d7/a2-a5,(a6)
        movem.l (a0)+,d0-d7/a2-a5
        movem.l d0-d7/a2-a5,12*4(a6)

        moveq   #109,d0
scr_tgb2:
        dbra    d0,scr_tgb2

        bra     nachpuff1
text_end:
        nop
        bra.s   text_endy

char_off_ok:
        moveq   #11,d1
scr_tgb3:
        dbra    d1,scr_tgb3
        ds.w 1,$4e71

        bra.s   char_off_oky

nachpuff2:

        add.w   #96,d0
scr_max_char_off equ *+2
        cmp.w   #96*200,d0
        bne.s   char_off_ok

text_poin equ *+2
        lea     text,a2
        moveq   #0,d0
        move.b  (a2)+,d0
        cmp.b   #-1,d0
        bne.s   text_end
        lea     text,a2
        move.b  (a2)+,d0
text_endy:
        move.l  a2,text_poin
        lea     fonttab,a2
        lsl.w   #3,d0
        move.l  0(a2,d0.w),akt_char_poin
        move.w  6(a2,d0.w),scr_max_char_off
        moveq   #0,d0

char_off_oky:
        move.w  d0,scr_char_off
        movea.l akt_char_poin(pc),a0
        adda.w  d0,a0
        movea.l scr_puf_add_tab3-scr_puf_add_tab2(a3),a2

        move.b  1(a2),(a6)+
        move.b  (a0),(a6)+

var1    set 2
        rept 47
        move.b  1+var1(a2),(a6)+
        move.b  var1(a0),(a6)+
var1    set var1+2
        endr

nachpuff1:

        move.w  in_megscrl_buf(pc),d0
        move.w  d0,d1
        add.w   #16,d0
        cmp.w   #199*16,d0
        bne.s   in_megscrl_buf_ok
        moveq   #0,d0
in_megscrl_buf_ok:
        move.w  d0,in_megscrl_buf

mg_scrl_which_line equ *+2
        move.w  #0,d2
        add.w   #16,d2
        cmp.w   #8*16,d2
        beq.s   mg_scrl_last_line
        ds.w 6,$4e71
        bra.s   mg_scrl_nlast_line
mg_scrl_last_line:
        moveq   #0,d2
        addq.l  #1,in_megtext
mg_scrl_nlast_line:
        move.w  d2,mg_scrl_which_line

        moveq   #0,d0
        opt O-
in_megtext equ *+2
        lea     megtext,a0
        opt O+
        move.b  (a0),d0
        bmi.s   megtext_end
        ds.w 3,$4e71
        bra.s   megtext_nend
megtext_end:
        lea     megtext,a0
        move.b  (a0),d0
megtext_nend:
        move.l  a0,in_megtext

        lea     megscrl_buf,a0
        adda.w  d1,a0
        lsl.w   #7,d0
        lea     megscrl_fnt,a1
        adda.w  d0,a1
        adda.w  d2,a1

        opt O-
in_megscrl_pal equ *+2
        lea     megscrl_pal,a2
        opt O+
        move.w  (a2),d4
        swap    d4
        move.w  (a2)+,d4
        cmpa.l  #megscrl_pal_end,a2
        beq.s   megscrl_pal_ends
        bra.s   megscrl_pal_nends
megscrl_pal_ends:
        lea     megscrl_pal,a2
megscrl_pal_nends:
        move.l  a2,in_megscrl_pal

        movem.l (a1),d0-d3
        and.l   d4,d0
        and.l   d4,d1
        and.l   d4,d2
        and.l   d4,d3
        movem.l d0-d3,(a0)
        movem.l d0-d3,199*16(a0)

        move.w  #768,d0
wait_border3:
        dbra    d0,wait_border3

        ds.w 2,$4e71

        moveq   #0,d4
        movea.l movetabpos(pc),sp
        move.b  -1(sp),d4
        ext.w   d4
        add.w   d4,d4
        sub.w   d4,jump_lines

        ifeq 1
        lea     $ffff8800.w,sp
        move.b  #$36,d7
        move.b  #10,(sp)
        move.b  (sp),d0
        cmpi.b  #$0e,d0
        bge.s   led1_on
        nop
        bra.s   led1_off
led1_on:
        bclr    #1,d7
led1_off:
        move.b  #9,(sp)
        move.b  (sp),d0
        cmpi.b  #$0e,d0
        bge.s   led2_on
        nop
        bra.s   led2_off
led2_on:
        bclr    #2,d7
led2_off:
        move.b  #8,(sp)
        move.b  (sp),d0
        cmpi.b  #$0e,d0
        bge.s   led3_on
        nop
        bra.s   led3_off
led3_on:
        bclr    #4,d7
led3_off:
        move.b  #14,(sp)
        move.b  d7,2(sp)
        endc

        lea     my_stack,sp

        bra     loop

; jumping raster
jump_rast:
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 8,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l d0-d1/d4/d6-a0/a3-a6,jras_regs

        move.w  jump_lines(pc),d0
        lea     ras_back_tab(pc),a0
        move.l  0(a0,d0.w),ras_back_jmp

        lea     megscrl_buf,a6
in_megscrl_buf equ *+2
        adda.w  #0,a6
        movem.l (a6)+,d4/d6-a0
        ds.w 11,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w

        ds.w 2,$4e71
        moveq   #44,d0          ;mark
lo00020:
        ds.w 1,$4e71
        move.l  d4,$ffff8240.w
        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w
        movem.l d6-a0,$ffff8244.w

        ds.w 46,$4e71
        movem.l (a6)+,d4/d6-a0

        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7
        move.b  #0,$ffff820a.w
        move.b  #2,$ffff820a.w
        dbra    d0,lo00020

        ds.w 4,$4e71

        move.b  #1,$ffff8260.w
        move.b  #0,$ffff8260.w
        movem.l d2-d3/d5,$ffff8250.w
        move.b  #2,$ffff8260.w
        move.b  #0,$ffff8260.w
        move.l  sp,$ffff825c.w

        movem.l pal2(pc),d2-d3/d5/a7
        movem.l d2-d3/d5/a7,$ffff8240.w

        movem.l jras_regs(pc),d0-d1/d4/d6-a0/a3-a6
        ds.w 16,$4e71
        lea     32(a2),a2
        move.w  (a1)+,d2
        movem.l 0(a2,d2.w),d2-d3/d5/a7

ras_back_jmp equ *+2
        jmp     $00


ras_back_tab:
        dc.l ras_back0
        rept 78
        dc.l ras_back0
        endr
        dc.l ras_back1
        dc.l ras_back2
        dc.l ras_back3
        dc.l ras_back4
        dc.l ras_back5
        dc.l ras_back6
        dc.l ras_back7
        dc.l ras_back8
        dc.l ras_back9
        dc.l ras_back10
        dc.l ras_back11
        dc.l ras_back12
        dc.l ras_back13
        dc.l ras_back14
        dc.l ras_back15
        dc.l ras_back16
        dc.l ras_back17
        dc.l ras_back18
        dc.l ras_back19
        dc.l ras_back20
        dc.l ras_back21
        rept 46
        dc.l ras_back22
        endr

jras_regs:ds.l 15

;here starts the data section

        data
graphic:
        dc.l %1010101010101010011001100110011
        dc.l %1111000011111111111111111111

        dc.w -230*8,-230*7,-230*6,-230*5,-230*4,-230*3,-230*2,-230
mul230:
        dc.w 0,230*1,230*2,230*3,230*4,230*5,230*6,230*7,230*8

        dc.b 0,0                ;panic_buffer
movetab:
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 0,0,0,0,0,0,0,0,0,0
;movetabend:
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 6,6,6,6,6,6,6,6,6,6
        dc.b 6,6,6,6,6,6,6,6,6,6
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 4,4,4,4,4,4,4,4,4,4
        dc.b 4,4,4,4,4,4,4,4,4,4
        dc.b 4,4,4,4,4,4,4,4,4,4
        dc.b 4,4,4,4,4,4,4,4,4,4
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b -4,-4,-4,-4,-4,-4,-4,-4,-4,-4
        dc.b -4,-4,-4,-4,-4,-4,-4,-4,-4,-4
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b -6,-6,-6,-6,-6,-6,-6,-6,-6,-6
        dc.b -6,-6,-6,-6,-6,-6,-6,-6,-6,-6
        dc.b 0,0,0,0,0,0,0,0,0,0
        dc.b -4,-4,-4,-4,-4,-4,-4,-4,-4,-4
        dc.b -4,-4,-4,-4,-4,-4,-4,-4,-4,-4
        dc.b 0,0                ;must be nul,nul vor panic
movetabend:
        even
movetab2:
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 1,1,1,1,1,1,1,1,1,1
;movetab2end:
        dc.b -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
        dc.b -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
        dc.b -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 8,8,8,8,8,8,8,8,8,8,8,8
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
        dc.b -7,-7,-7,-7,-7,-7,-7,-7,-7,-7
        dc.b -7,-7,-7,-7,-7,-7,-7,-7,-7,-7
        dc.b -7,-7,-7,-7,-7,-7,-7,-7,-7,-7
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 9,9,9,9,9,9,9,9,9,9
        dc.b 9,9,9,9,9,9,9,9,9,9
        dc.b 9,9,9,9,9,9,9,9,9,9
        dc.b 8,8,8,8,8,8,8,8,8,8,8,8
        dc.b -7,-7,-7,-7,-7,-7,-7,-7,-7,-7
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 9,9,9,9,9,9,9,9,9,9
        dc.b 8,8,8,8,8,8,8,8,8,8,8,8
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b -8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8,-8
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 8,8,8,8,8,8,8,8,8,8,8,8
        dc.b 8,8,8,8,8,8,8,8,8,8,8,8
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 1,1,1,1,1,1,1,1,1,1
        dc.b 8,8,8,8,8,8,8,8,8,8,8,8
movetab2end:
        even

scrl_pal:
        dc.w $0101,$0202,$0404,$0606,$0707,$0606,$0404,$0202
pal     equ *+4
pic     equ *+128
        path 'INCLUDES\'
        ibytes 'ULM_LOGO.NEO',24128
pal2    equ *+4
pic2    equ *+128
        ibytes 'PLAYTUS3.NEO'
hsin:
        path 'INCLUDES\'
        ibytes 'HSIN.BIN'
hsinend:
aktinvsin:
        dc.l vsin
vsin:
        path 'INCLUDES\'
        ibytes 'VSIN.BIN'
        path '..'
vsinend:

coltab:
        path 'INCLUDES\'
        ibytes 'COLORS.BIN'
        path '..'

hwscrolldat:
        ibytes 'HWDAT.BIN'

scr_puf_tab:
        dc.l scr_puf_add_tab1,scr_puf_add_tab2

scr_puf_add_tab1:
var1    set 0
        rept 20+wcount
        dc.l scr_puf1+var1
var1    set var1+96
        endr
var1    set 0
        rept 20+wcount
        dc.l scr_puf1+var1
var1    set var1+96
        endr

scr_puf_add_tab2:
var1    set 0
        rept 20+wcount
        dc.l scr_puf2+var1
var1    set var1+96
        endr
var1    set 0
        rept 20+wcount
        dc.l scr_puf2+var1
var1    set var1+96
        endr

scr_puf_add_tab3:
var1    set 0
        rept 20+wcount
        dc.l scr_puf1+var1
var1    set var1+96
        endr
var1    set 0
        rept 20+wcount
        dc.l scr_puf1+var1
var1    set var1+96
        endr

megtext:
        ds.b 10,62
        dc.b 7,34,62,45,33,30,43,30,62,71,71,71,62,19,33,34,44,62,34,44
        dc.b 62,45,33,30,62,28,40,38,41,37,30,45,30,37,50,62,46,39,43,30
        dc.b 26,29,26,27,37,30,62,44,28,43,40,37,37,62,34,39,62,40,46,43
        dc.b 62,1,34,45,38,26,41,62,18,28,43,30,30,39,62,71,71,71,62,14
        dc.b 45,33,30,43,62,28,43,30,48,44,62,40,39,37,50,62,46,44,30,62
        dc.b 56,62,1,34,45,38,26,41,44,64,62,48,30,62,46,44,30,62,58,62
        dc.b 1,34,45,38,26,41,44,62,71,71,71,62,19,33,26,45,72,44,62,26
        dc.b 62,47,30,43,50,62,39,30,48,62,45,43,34,28,36,62,26,39,29,62
        dc.b 48,30,62,26,43,30,62,45,33,30,62,31,34,43,44,45,62,48,33,40
        dc.b 62,33,26,47,30,62,29,34,44,28,40,47,30,43,30,29,62,45,33,30
        dc.b 62,58,62,1,34,45,41,37,26,39,30,44,62,17,30,32,34,44,45,30
        dc.b 43,62,40,39,62,45,33,30,62,18,19,62,18,40,46,39,29,28,33,34
        dc.b 41,63,63,63,62,22,30,62,26,37,44,40,62,33,26,47,30,62,29,34
        dc.b 44,28,40,47,30,43,30,29,62,45,33,30,62,5,34,39,30,62,18,28
        dc.b 43,40,37,37,62,17,30,32,34,44,45,30,43,62,26,37,37,40,48,34
        dc.b 39,32,62,46,44,62,45,40,62,44,30,45,62,45,33,30,62,44,28,43
        dc.b 30,30,39,62,26,29,29,43,30,44,44,62,45,40,62,26,39,50,62,1
        dc.b 34,45,62,34,39,62,45,33,30,62,48,33,40,37,30,62,38,30,38,40
        dc.b 43,50,62,71,71,71,62,62,62,6,40,62,26,39,29,62,33,26,47,30
        dc.b 62,26,62,37,40,40,36,62,26,45,62,45,33,30,62,40,45,33,30,43
        dc.b 62,44,28,43,40,37,37,44,64,62,26,44,62,45,33,34,44,62,44,28
        dc.b 43,40,37,37,62,38,26,50,62,29,30,44,45,43,40,50,62,45,33,30
        dc.b 62,47,30,43,50,62,37,34,45,45,37,30,62,27,43,26,34,39,28,30
        dc.b 37,37,44,62,43,30,38,26,34,39,34,39,32,62,34,39,62,50,40,46
        dc.b 43,62,33,30,26,29,63,63,63,62,62,62,1,50,30,62,26,39,29,62
        dc.b 44,30,30,62,50,26,62,44,40,40,39,62,34,39,62,44,40,38,30,62
        dc.b 40,45,33,30,43,62,44,28,43,40,37,37,50,62,38,30,44,44,26,32
        dc.b 30,63,63,63,62,62,62,62,62,62,62
        dc.b -1

text:
        dc.b 36,36,36,36,36,36,36,36,36,36,36,36

        dc.b 1,0,2,0,17,3,8,46,36,36,36,24,4,0,7,37,36,36,36,22
        dc.b 4,36,36,36,11,14,21,4,36,36,36,8,19,37,36,36,36,8,19,36
        dc.b 36,36,8,18,36,36,36,3,4,5,8,13,8,19,4,11,24,36,36,36
        dc.b 19,7,4,36,36,36,1,4,18,19,36,36,36,18,19,20,5,5,36,36
        dc.b 36,4,23,2,4,15,19,36,36,36,6,8,17,11,18,46,36,36,36,4
        dc.b 18,15,4,2,8,0,11,11,24,36,36,36,3,20,19,2,7,36,36,36
        dc.b 6,8,17,11,18,42,36,36,36,24,14,20,36,36,36,22,14,13,39,19
        dc.b 36,36,36,1,4,11,8,4,21,4,36,36,36,8,19,36,36,36,1,20
        dc.b 19,36,36,36,22,4,36,36,36,40,22,4,36,36,36,22,7,14,36,36
        dc.b 36,22,17,14,19,4,36,36,36,19,7,8,18,36,36,36,18,7,8,19
        dc.b 46,36,36,36,2,7,17,8,18,36,36,36,0,13,3,36,36,36,13,8
        dc.b 2,10,36,36,36,14,5,36,36,36,19,7,4,36,36,36,21,4,17,24
        dc.b 36,36,36,5,0,12,14,20,18,36,36,36,20,11,19,8,12,0,19,4
        dc.b 36,36,36,17,8,2,7,36,36,36,0,13,3,36,36,36,1,4,0,20
        dc.b 19,8,5,20,11,46,36,36,36,12,20,11,19,8,12,20,11,20,18,36
        dc.b 36,36,0,13,3,36,36,36,18,7,8,5,19,4,3,36,36,36,11,4
        dc.b 5,19,36,36,36,6,0,17,11,8,2,36,36,36,4,0,19,4,17,18
        dc.b 41,36,36,36,2,0,13,39,19,36,36,36,17,4,12,4,12,1,4,17
        dc.b 36,36,36,19,7,0,19,36,36,36,22,4,36,36,36,7,0,21,4,36
        dc.b 36,36,18,4,4,13,36,36,36,14,13,4,36,36,36,20,6,11,24,36
        dc.b 36,36,6,8,17,11,36,36,36,7,4,17,4,36,36,36,18,8,13,2
        dc.b 4,36,36,36,22,4,36,36,36,0,17,4,36,36,36,7,4,17,4,42
        dc.b 36,36,36,18,14,46,36,36,36,13,14,22,36,36,36,22,4,36,36,36
        dc.b 22,8,11,11,36,36,36,19,4,11,11,36,36,36,24,14,20,36,36,36
        dc.b 0,1,14,20,19,36,36,36,14,20,17,36,36,36,11,0,18,19,36,36
        dc.b 36,13,8,6,7,19,36,36,36,22,7,8,2,7,36,36,36,22,4,36
        dc.b 36,36,18,15,4,13,19,36,36,36,8,13,36,36,36,0,36,36,36,17
        dc.b 4,0,11,11,24,36,36,36,6,17,4,0,19,36,36,36,3,8,18,2
        dc.b 14,36,36,36,13,4,0,17,36,36,36,14,18,18,42,36,36,36,19,7
        dc.b 4,36,36,36,13,0,12,4,36,36,36,22,0,18,36,36,36,39,36,36
        dc.b 36,6,14,11,3,5,8,13,6,4,17,36,36,36,39,36,36,36,0,13
        dc.b 3,36,36,36,22,4,36,36,36,2,0,13,36,36,36,19,4,11,11,36
        dc.b 36,36,24,14,20,36,36,36,19,7,0,19,36,36,36,8,19,36,36,36
        dc.b 22,0,18,36,36,36,21,4,17,24,36,36,36,6,14,14,3,36,36,36
        dc.b 0,13,3,36,36,36,21,4,17,24,46,36,36,36,21,4,17,24,36,36
        dc.b 36,11,14,20,3,42,36,36,36,7,4,24,46,36,36,36,9,20,18,19
        dc.b 36,36,36,0,19,36,36,36,19,7,4,36,36,36,12,14,12,4,13,19
        dc.b 36,36,36,3,8,25,25,24,36,36,36,14,5,36,36,36,19,14,14,11
        dc.b 36,36,36,34,36,36,36,8,13,19,4,17,17,20,15,19,4,3,36,36
        dc.b 36,12,24,36,36,36,22,17,8,19,8,13,6,36,36,36,2,14,25,36
        dc.b 36,36,7,4,36,36,36,18,19,4,15,15,4,3,36,36,36,8,13,19
        dc.b 14,36,36,36,19,7,4,36,36,36,17,14,14,12,36,36,36,22,8,19
        dc.b 7,36,36,36,0,13,14,19,7,4,17,36,36,36,13,8,2,4,36,36
        dc.b 36,6,8,17,11,36,36,36,5,17,14,12,36,36,36,14,18,18,42,36
        dc.b 36,36,8,36,36,36,19,7,8,13,10,36,36,36,8,19,39,18,36,36
        dc.b 36,19,7,4,36,36,36,14,13,4,36,36,36,22,4,36,36,36,5,20
        dc.b 2,10,4,3,36,36,36,24,4,18,19,4,17,3,0,24,36,36,36,8
        dc.b 13,36,36,36,19,7,4,36,36,36,3,8,18,2,14,36,36,36,8,13
        dc.b 36,36,36,19,7,4,36,36,36,19,14,8,11,4,19,19,4,42,36,36
        dc.b 36,15,4,17,7,0,15,18,36,36,36,8,36,36,36,18,7,14,20,11
        dc.b 3,36,36,36,3,4,18,2,17,8,1,4,36,36,36,7,4,17,36,36
        dc.b 36,0,36,36,36,1,8,19,42,42,42,36,36,36,18,7,4,36,36,36
        dc.b 7,0,18,36,36,36,11,14,13,6,36,36,36,1,11,14,13,3,36,36
        dc.b 36,7,0,8,17,18,36,36,36,11,8,10,4,36,36,36,0,11,11,36
        dc.b 36,36,19,7,4,36,36,36,14,19,7,4,17,18,36,36,36,7,4,17
        dc.b 4,36,36,36,0,13,3,36,36,36,22,14,13,3,4,17,5,20,11,36
        dc.b 36,36,6,17,4,4,13,36,36,36,40,36,36,36,26,30,26,36,36,36
        dc.b 8,13,36,36,36,7,4,23,42,42,42,36,36,36,41,36,36,36,4,24
        dc.b 4,18,36,36,36,13,14,19,36,36,36,19,14,36,36,36,5,14,17,6
        dc.b 4,19,36,36,36,19,7,4,36,36,36,22,14,13,3,4,17,5,20,11
        dc.b 36,36,36,1,14,3,24,42,36,36,36,8,36,36,36,22,14,20,11,3
        dc.b 36,36,36,4,18,19,8,12,0,19,4,36,36,36,19,7,0,19,36,36
        dc.b 36,7,4,17,36,36,36,21,4,17,24,36,36,36,6,14,14,3,36,36
        dc.b 36,1,0,11,11,18,36,36,36,7,0,21,4,36,36,36,0,36,36,36
        dc.b 22,8,3,19,7,36,36,36,14,5,36,36,36,0,1,14,20,19,36,36
        dc.b 36,22,14,13,3,4,17,5,20,11,36,36,36,34,35,36,36,36,2,12
        dc.b 42,36,36,36,8,36,36,36,19,7,8,13,10,36,36,36,19,7,0,19
        dc.b 36,36,36,22,4,36,36,36,22,8,11,11,36,36,36,19,17,24,36,36
        dc.b 36,8,19,36,36,36,19,7,8,18,36,36,36,4,21,4,13,8,13,6
        dc.b 36,36,36,0,36,36,36,18,4,2,14,13,3,36,36,36,19,8,12,4
        dc.b 36,36,36,1,20,19,36,36,36,22,4,36,36,36,5,8,17,18,19,36
        dc.b 36,36,7,0,21,4,36,36,36,19,14,36,36,36,1,20,24,36,36,36
        dc.b 18,14,12,4,36,36,36,12,14,17,4,36,36,36,14,5,36,36,36,19
        dc.b 7,8,18,36,36,36,15,11,0,18,19,8,2,36,36,36,18,19,20,5
        dc.b 5,42,42,42,36,36,36,24,14,20,36,36,36,10,13,14,22,36,36,36
        dc.b 22,7,0,19,36,36,36,8,36,36,36,12,4,0,13,42,42,42,36,36
        dc.b 36,8,5,36,36,36,0,2,2,14,36,36,36,14,5,36,36,36,19,7
        dc.b 4,36,36,36,20,11,19,8,12,0,19,4,36,36,36,6,0,17,11,8
        dc.b 2,36,36,36,4,0,19,4,17,18,36,36,36,22,14,20,11,3,36,36
        dc.b 36,17,4,0,3,36,36,36,19,7,8,18,36,36,36,19,4,23,19,36
        dc.b 36,36,7,4,36,36,36,22,14,20,11,3,36,36,36,18,0,24,46,36
        dc.b 36,36,0,18,36,36,36,0,11,22,0,24,18,46,36,36,36,39,36,36
        dc.b 36,4,7,46,36,36,36,4,7,46,36,36,36,22,0,17,19,4,36,36
        dc.b 36,12,0,11,42,42,42,42,39,36,36,36,0,13,3,36,36,36,0,11
        dc.b 18,14,36,36,36,7,4,36,36,36,22,14,20,11,3,36,36,36,18,0
        dc.b 24,36,36,36,19,7,0,19,36,36,36,12,4,36,36,36,0,13,3,36
        dc.b 36,36,13,8,2,10,36,36,36,0,17,4,36,36,36,18,4,23,18,8
        dc.b 18,19,18,42,36,36,36,15,4,17,7,0,15,18,36,36,36,24,14,20
        dc.b 36,36,36,2,14,20,11,3,36,36,36,20,13,3,4,17,18,19,0,13
        dc.b 3,36,36,36,19,7,8,18,36,36,36,1,4,19,19,4,17,36,36,36
        dc.b 8,5,36,36,36,24,14,20,36,36,36,10,13,14,22,36,36,36,19,7
        dc.b 0,19,36,36,36,7,8,18,36,36,36,6,8,17,11,5,17,8,4,13
        dc.b 3,36,36,36,7,0,18,36,36,36,11,4,5,19,36,36,36,5,14,17
        dc.b 36,36,36,0,36,36,36,24,4,0,17,36,36,36,19,14,36,36,36,11
        dc.b 14,13,3,14,13,36,36,36,0,13,3,36,36,36,18,14,36,36,36,7
        dc.b 4,39,18,36,36,36,19,14,19,0,11,11,24,36,36,36,15,8,18,18
        dc.b 4,3,36,36,36,14,5,5,42,42,42,42,36,36,36,18,14,46,36,36
        dc.b 36,22,4,36,36,36,13,14,22,36,36,36,22,8,11,11,36,36,36,22
        dc.b 17,8,19,4,36,36,36,18,14,12,4,19,7,8,13,6,36,36,36,0
        dc.b 1,14,20,19,36,36,36,5,20,17,24,36,36,36,40,4,23,36,36,36
        dc.b 17,4,15,11,8,2,0,13,19,18,46,36,36,36,13,14,22,36,36,36
        dc.b 11,4,6,0,2,24,36,36,36,40,19,22,14,36,36,36,6,20,24,18
        dc.b 36,36,36,6,17,14,20,15,41,41,42,36,36,36,7,4,39,18,36,36
        dc.b 36,0,36,36,36,21,4,17,24,36,36,36,6,14,14,3,36,36,36,2
        dc.b 14,3,4,17,36,36,36,22,7,14,36,36,36,12,0,3,4,36,36,36
        dc.b 8,19,36,36,36,15,14,18,18,8,1,11,4,36,36,36,19,14,36,36
        dc.b 36,12,0,10,4,36,36,36,15,4,14,15,11,4,36,36,36,1,4,11
        dc.b 8,4,21,4,36,36,36,19,7,0,19,36,36,36,19,7,4,24,36,36
        dc.b 36,7,0,21,4,36,36,36,0,13,36,36,36,18,19,4,36,36,36,8
        dc.b 13,36,36,36,19,8,12,4,18,36,36,36,22,7,4,13,36,36,36,19
        dc.b 7,4,36,36,36,2,14,12,15,20,19,4,17,36,36,36,22,0,18,13
        dc.b 39,19,36,36,36,0,11,17,4,0,3,24,36,36,36,17,4,11,4,0
        dc.b 18,4,3,42,42,42,36,36,36,22,0,8,19,36,36,36,5,20,17,24
        dc.b 36,36,36,8,18,36,36,36,9,20,18,19,36,36,36,19,4,11,11,8
        dc.b 13,6,36,36,36,12,4,36,36,36,19,7,0,19,36,36,36,0,19,36
        dc.b 36,36,19,7,8,18,36,36,36,19,8,12,4,36,36,36,7,4,36,36
        dc.b 36,7,0,3,36,36,36,0,36,36,36,18,19,4,36,36,36,22,8,19
        dc.b 7,36,36,36,5,14,20,17,36,36,36,12,4,6,0,1,24,19,4,36
        dc.b 36,36,0,13,3,36,36,36,7,4,36,36,36,22,0,18,36,36,36,0
        dc.b 18,10,4,3,36,36,36,1,24,36,36,36,0,19,0,17,8,36,36,36
        dc.b 19,14,36,36,36,12,0,10,4,36,36,36,0,36,36,36,3,4,12,14
        dc.b 36,36,36,5,14,17,36,36,36,19,7,4,36,36,36,18,19,4,42,36
        dc.b 36,36,18,14,46,36,36,36,8,36,36,36,3,14,13,39,19,36,36,36
        dc.b 2,0,17,4,42,42,42,36,36,36,11,4,19,36,36,36,12,4,36,36
        dc.b 36,18,0,24,36,36,36,42,42,42,42,42,36,36,36,19,7,4,36,36
        dc.b 36,1,14,19,19,11,4,36,36,36,8,18,36,36,36,13,4,0,17,11
        dc.b 24,36,36,36,5,8,13,8,18,7,4,3,42,42,42,36,36,36,13,14
        dc.b 22,36,36,36,18,15,0,25,36,36,36,22,8,11,11,36,36,36,22,17
        dc.b 8,19,4,36,36,36,18,14,12,4,36,36,36,13,8,2,4,36,36,36
        dc.b 22,14,17,3,18,36,36,36,42,42,42,42,36,36,36,8,36,36,36,7
        dc.b 14,15,4,36,36,36,19,7,0,19,36,36,36,24,14,20,17,36,36,36
        dc.b 18,15,11,4,4,13,36,36,36,8,18,36,36,36,17,8,15,15,4,3
        dc.b 36,36,36,8,13,36,36,36,19,22,14,36,36,36,1,24,36,36,36,0
        dc.b 36,36,36,17,0,1,1,8,3,36,36,36,3,14,6,36,36,36,22,7
        dc.b 14,36,36,36,15,8,18,18,4,18,36,36,36,14,13,36,36,36,24,14
        dc.b 20,17,36,36,36,7,4,0,3,36,36,36,0,13,3,36,36,36,19,7
        dc.b 4,36,36,36,19,7,17,14,22,36,36,36,19,7,4,36,36,36,17,4
        dc.b 12,0,8,13,18,36,36,36,14,5,36,36,36,24,14,20,17,36,36,36
        dc.b 2,14,0,17,15,18,4,36,36,36,8,13,19,14,36,36,36,0,36,36
        dc.b 36,6,11,14,22,8,13,6,36,36,36,1,0,6,36,36,36,14,5,36
        dc.b 36,36,15,20,18,36,36,36,19,7,0,19,36,36,36,8,18,36,36,36
        dc.b 14,14,25,8,13,6,36,36,36,22,8,19,7,36,36,36,12,0,6,6
        dc.b 14,19,18,36,36,36,0,13,3,36,36,36,17,14,19,19,8,13,6,36
        dc.b 36,36,5,14,4,19,20,0,18,4,18,42,42,42,42,42,42,42,42,42
        dc.b 42,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,42
        dc.b 42,42,42,42,42,42,0,13,3,36,36,36,7,0,21,4,36,36,36,0
        dc.b 36,36,36,7,0,15,15,24,36,36,36,2,7,17,8,18,19,12,0,18
        dc.b 37,37,37,36,36,36,36,36,36,3,8,3,36,36,36,24,14,20,36,36
        dc.b 36,10,13,14,22,36,36,36,19,7,0,19,36,36,36,5,20,17,24,39
        dc.b 18,36,36,36,6,8,17,11,5,17,8,4,13,3,36,36,36,11,4,5
        dc.b 19,36,36,36,7,8,12,36,36,36,2,14,25,36,36,36,7,4,36,36
        dc.b 36,7,0,3,36,36,36,11,14,19,18,0,36,36,36,15,17,14,1,11
        dc.b 4,12,18,36,36,36,22,8,19,7,36,36,36,3,0,13,3,17,20,5
        dc.b 5,42,42,42,36,36,36,22,0,8,19,36,36,36,16,20,14,19,0,19
        dc.b 8,14,13,36,36,36,18,15,0,25,36,36,36,39,36,36,36,24,14,20
        dc.b 36,36,36,2,0,13,39,19,36,36,36,5,20,2,10,36,36,36,0,36
        dc.b 36,36,12,14,20,18,4,36,36,36,0,13,3,36,36,36,24,14,20,36
        dc.b 36,36,2,0,13,39,19,36,36,36,5,20,2,10,36,36,36,11,14,19
        dc.b 18,0,36,36,36,12,8,2,4,36,36,36,2,14,25,36,36,36,19,7
        dc.b 4,24,36,36,36,18,15,11,8,19,37,36,36,36,39,36,36,36,3,14
        dc.b 13,39,19,36,36,36,22,14,17,17,24,36,36,36,19,7,8,18,36,36
        dc.b 36,22,0,18,36,36,36,14,13,11,24,36,36,36,0,36,36,36,11,4
        dc.b 18,18,14,13,36,36,36,19,14,36,36,36,18,7,14,22,36,36,36,24
        dc.b 14,20,36,36,36,7,14,22,36,36,36,19,14,36,36,36,20,18,4,36
        dc.b 36,36,15,11,20,17,0,11,18,42,36,36,36,1,0,17,17,36,36,36
        dc.b 1,0,17,17,36,36,36,1,11,0,2,10,36,36,36,18,7,4,4,15
        dc.b 46,36,36,36,7,0,21,4,36,36,36,24,14,20,36,36,36,0,13,24
        dc.b 36,36,36,22,14,14,11,46,36,36,36,24,4,18,36,36,36,18,8,17
        dc.b 36,36,36,24,4,18,36,36,36,18,8,17,36,36,36,19,7,17,4,4
        dc.b 36,36,36,1,0,6,18,36,36,36,5,20,11,11,42,36,36,36,14,13
        dc.b 4,36,36,36,5,14,17,36,36,36,19,7,4,36,36,36,12,0,18,19
        dc.b 4,17,36,36,36,0,13,3,36,36,36,14,13,4,36,36,36,5,14,17
        dc.b 36,36,36,19,7,4,36,36,36,3,0,12,4,46,36,36,36,0,13,3
        dc.b 36,36,36,14,13,4,36,36,36,5,14,17,36,36,36,19,7,4,36,36
        dc.b 36,11,8,19,19,11,4,36,36,36,1,14,24,36,36,36,22,7,14,36
        dc.b 36,36,11,8,21,4,18,36,36,36,3,14,22,13,36,36,36,0,36,36
        dc.b 36,3,17,0,8,13,42,42,42,42,42,42,36,36,36,36,36,36,36,36
        dc.b 36,7,4,24,36,36,36,16,20,14,19,0,19,8,14,13,36,36,36,18
        dc.b 15,0,25,36,36,36,39,36,36,36,0,17,4,36,36,36,24,14,20,36
        dc.b 36,36,7,14,19,38,36,36,36,39,36,36,36,0,13,3,36,36,36,39
        dc.b 36,36,36,7,0,21,4,36,36,36,24,14,20,36,36,36,1,8,6,36
        dc.b 36,36,19,8,19,18,38,36,36,36,39,36,36,36,0,13,3,36,36,36
        dc.b 39,36,36,36,8,39,12,36,36,36,0,36,36,36,6,14,14,3,36,36
        dc.b 36,5,20,2,10,4,17,37,36,36,36,39,36,36,36,36,36,36,36,36
        dc.b 36,42,42,42,42,36,36,36,22,4,36,36,36,2,14,12,4,36,36,36
        dc.b 1,0,2,10,36,36,36,19,14,36,36,36,19,7,4,36,36,36,17,4
        dc.b 0,11,36,36,36,22,14,17,11,3,42,42,42,42,36,36,36,7,4,24
        dc.b 46,36,36,36,5,20,17,24,36,36,36,0,13,3,36,36,36,19,24,17
        dc.b 4,12,36,36,36,14,5,36,36,36,19,7,4,36,36,36,17,4,18,15
        dc.b 4,2,19,0,1,11,4,18,36,36,36,22,7,14,36,36,36,0,17,4
        dc.b 36,36,36,18,8,19,19,8,13,6,36,36,36,13,4,23,19,36,36,36
        dc.b 19,14,36,36,36,20,18,36,36,36,0,13,3,36,36,36,22,17,8,19
        dc.b 8,13,6,36,36,36,19,7,4,36,36,36,18,2,17,14,11,11,19,4
        dc.b 23,19,36,36,36,8,13,36,36,36,19,7,4,36,36,36,20,15,15,4
        dc.b 17,36,36,36,1,14,17,3,4,17,36,36,36,9,20,18,19,36,36,36
        dc.b 7,0,3,36,36,36,0,13,3,36,36,36,21,8,17,20,18,36,36,36
        dc.b 22,7,8,2,7,36,36,36,22,17,14,19,4,36,36,36,14,13,11,24
        dc.b 36,36,36,19,7,4,36,36,36,11,4,19,19,4,17,18,36,36,36,39
        dc.b 36,36,36,19,7,14,17,36,36,36,39,36,36,36,14,13,36,36,36,19
        dc.b 7,4,36,36,36,18,2,17,4,4,13,36,36,36,0,13,3,36,36,36
        dc.b 0,5,19,4,17,36,36,36,0,36,36,36,22,7,8,11,4,36,36,36
        dc.b 19,7,4,8,17,36,36,36,2,14,12,15,20,19,4,17,36,36,36,5
        dc.b 20,2,10,4,3,36,36,36,14,5,5,42,42,42,36,36,36,13,14,22
        dc.b 36,36,36,19,7,4,24,36,36,36,7,0,21,4,36,36,36,19,14,36
        dc.b 36,36,17,4,22,17,8,19,4,36,36,36,19,7,4,8,17,36,36,36
        dc.b 18,7,8,19,36,36,36,0,6,0,8,13,42,42,42,36,36,36,13,14
        dc.b 22,36,36,36,22,4,36,36,36,7,0,21,4,36,36,36,0,11,17,4
        dc.b 0,3,24,36,36,36,30,30,36,36,36,11,8,13,4,18,36,36,36,14
        dc.b 5,36,36,36,5,8,11,4,36,36,36,11,4,13,6,19,7,36,36,36
        dc.b 12,14,17,4,36,36,36,19,7,0,13,36,36,36,19,7,4,12,42,42
        dc.b 42,42,36,36,36,18,14,46,36,36,36,19,7,8,18,36,36,36,8,18
        dc.b 36,36,36,0,13,14,19,7,4,17,36,36,36,15,17,14,14,21,4,36
        dc.b 36,36,19,7,0,19,36,36,36,22,4,36,36,36,0,17,4,36,36,36
        dc.b 19,7,4,36,36,36,1,4,18,19,36,36,36,0,13,3,36,36,36,20
        dc.b 13,1,4,0,19,0,1,11,4,46,36,36,36,5,0,12,14,20,18,36
        dc.b 36,36,0,13,3,36,36,36,2,14,14,11,46,36,36,36,17,8,2,7
        dc.b 36,36,36,0,13,3,36,36,36,1,4,0,20,19,8,5,20,11,36,36
        dc.b 36,6,0,17,11,8,2,36,36,36,4,0,19,4,17,18,36,36,36,22
        dc.b 7,14,36,36,36,2,0,13,39,19,36,36,36,1,4,36,36,36,1,4
        dc.b 0,19,4,13,36,36,36,20,15,36,36,36,2,14,25,36,36,36,19,7
        dc.b 4,24,36,36,36,0,17,4,36,36,36,19,14,36,36,36,18,12,0,11
        dc.b 11,36,36,36,19,14,36,36,36,1,4,36,36,36,1,4,0,19,4,13
        dc.b 36,36,36,20,15,42,42,42,42,36,36,36,1,20,19,36,36,36,22,4
        dc.b 36,36,36,2,0,13,36,36,36,19,4,11,11,36,36,36,24,14,20,36
        dc.b 36,36,7,14,22,36,36,36,19,14,36,36,36,5,20,2,10,36,36,36
        dc.b 0,36,36,36,6,8,17,11,36,36,36,8,13,36,36,36,0,36,36,36
        dc.b 17,4,0,11,11,24,36,36,36,7,0,17,3,36,36,36,22,0,24,36
        dc.b 36,36,19,7,0,19,36,36,36,12,0,10,4,18,36,36,36,7,4,17
        dc.b 36,36,36,19,7,8,13,10,36,36,36,19,7,0,19,36,36,36,18,7
        dc.b 4,39,18,36,36,36,5,11,24,8,13,6,36,36,36,19,14,36,36,36
        dc.b 7,4,0,21,4,13,42,36,36,36,5,8,17,18,19,46,36,36,36,24
        dc.b 14,20,36,36,36,7,0,21,4,36,36,36,19,14,36,36,36,15,20,19
        dc.b 36,36,36,14,13,36,36,36,24,14,20,17,36,36,36,12,14,18,19,36
        dc.b 36,36,11,14,21,4,11,24,36,36,36,5,0,2,4,36,36,36,19,7
        dc.b 0,19,36,36,36,24,14,20,36,36,36,4,21,4,17,36,36,36,5,14
        dc.b 20,13,3,36,36,36,8,13,36,36,36,24,14,20,17,36,36,36,12,8
        dc.b 17,17,14,17,46,36,36,36,19,7,4,13,36,36,36,18,7,4,36,36
        dc.b 36,22,8,11,11,36,36,36,0,20,19,14,12,0,19,8,2,0,11,11
        dc.b 24,36,36,36,18,12,4,11,19,36,36,36,0,22,0,24,36,36,36,11
        dc.b 8,10,4,36,36,36,0,11,11,36,36,36,19,7,4,36,36,36,6,8
        dc.b 17,11,18,36,36,36,11,8,10,4,36,36,36,19,14,36,36,36,3,14
        dc.b 46,36,36,36,13,14,22,36,36,36,8,5,36,36,36,24,14,20,36,36
        dc.b 36,17,4,0,2,7,4,3,36,36,36,19,7,8,18,36,36,36,11,4
        dc.b 21,4,11,36,36,36,14,5,36,36,36,19,7,4,36,36,36,6,0,12
        dc.b 4,36,36,36,24,14,20,39,11,11,36,36,36,18,20,17,4,36,36,36
        dc.b 19,14,36,36,36,22,8,13,36,36,36,19,7,4,36,36,36,5,8,6
        dc.b 7,19,42,36,36,36,24,4,18,46,36,36,36,8,19,36,36,36,8,18
        dc.b 36,36,36,0,36,36,36,17,4,0,11,36,36,36,5,8,6,7,19,36
        dc.b 36,36,2,14,25,36,36,36,24,14,20,36,36,36,7,0,21,4,36,36
        dc.b 36,19,14,36,36,36,20,18,4,36,36,36,0,11,11,36,36,36,24,14
        dc.b 20,17,36,36,36,18,19,14,12,0,2,7,36,36,36,12,20,18,2,11
        dc.b 4,18,36,36,36,19,14,36,36,36,5,20,2,10,36,36,36,7,4,17
        dc.b 42,36,36,36,8,5,36,36,36,18,7,4,36,36,36,18,19,0,17,19
        dc.b 18,36,36,36,19,14,36,36,36,18,2,17,4,0,12,36,36,36,0,13
        dc.b 3,36,36,36,18,7,14,20,19,36,36,36,21,4,17,24,36,36,36,11
        dc.b 14,20,3,11,24,36,36,36,40,11,8,10,4,36,36,36,19,7,4,36
        dc.b 36,36,6,8,17,11,36,36,36,24,4,18,19,4,17,3,0,24,42,42
        dc.b 42,41,36,36,36,19,7,4,13,36,36,36,18,7,4,36,36,36,22,8
        dc.b 11,11,36,36,36,2,14,12,4,36,36,36,13,4,0,17,4,17,36,36
        dc.b 36,19,14,36,36,36,4,23,19,0,18,24,42,36,36,36,3,14,13,39
        dc.b 19,36,36,36,18,19,14,15,36,36,36,10,13,14,22,46,36,36,36,14
        dc.b 19,7,4,17,22,8,18,4,36,36,36,24,14,20,39,11,11,36,36,36
        dc.b 13,4,21,4,17,36,36,36,6,4,19,36,36,36,0,6,0,8,13,36
        dc.b 36,36,0,36,36,36,2,7,0,13,2,4,36,36,36,19,14,36,36,36
        dc.b 5,20,2,10,36,36,36,7,4,17,36,36,36,0,6,0,8,13,36,36
        dc.b 36,1,4,2,0,20,18,4,36,36,36,18,7,4,36,36,36,22,8,11
        dc.b 11,36,36,36,19,7,8,13,10,36,36,36,19,7,0,19,36,36,36,24
        dc.b 14,20,36,36,36,0,17,4,36,36,36,0,36,36,36,11,0,12,4,17
        dc.b 46,36,36,36,11,8,10,4,36,36,36,0,11,11,36,36,36,19,7,4
        dc.b 36,36,36,14,19,7,4,17,36,36,36,42,42,42,42,11,0,12,4,17
        dc.b 18,36,36,36,7,4,17,4,42,42,42,36,36,36,24,14,20,36,36,36
        dc.b 7,0,21,4,36,36,36,19,14,36,36,36,10,13,14,22,36,36,36,19
        dc.b 7,0,19,36,36,36,19,7,4,24,36,36,36,7,0,21,4,36,36,36
        dc.b 19,7,4,8,17,36,36,36,14,22,13,36,36,36,18,4,15,4,17,0
        dc.b 19,4,36,36,36,17,14,14,12,36,36,36,0,13,3,36,36,36,8,13
        dc.b 36,36,36,19,7,8,18,36,36,36,17,14,14,12,36,36,36,19,7,4
        dc.b 24,36,36,36,0,17,4,36,36,36,0,11,11,36,36,36,0,11,14,13
        dc.b 4,36,36,36,5,20,2,10,8,13,6,42,36,36,36,39,11,8,5,4
        dc.b 18,36,36,36,0,36,36,36,1,8,19,2,7,36,36,36,0,13,3,36
        dc.b 36,36,19,7,4,13,36,36,36,24,14,20,36,36,36,12,0,17,17,24
        dc.b 36,36,36,14,13,4,37,39,36,36,36,12,0,13,8,10,8,13,36,36
        dc.b 36,16,20,14,19,4,42,36,36,36,22,7,0,19,36,36,36,0,36,36
        dc.b 36,5,20,2,10,8,13,6,36,36,36,18,8,11,11,24,36,36,36,18
        dc.b 2,17,14,11,11,19,4,23,19,36,36,36,8,19,36,36,36,2,0,13
        dc.b 36,36,36,14,13,11,24,36,36,36,1,4,36,36,36,22,17,8,19,19
        dc.b 4,13,36,36,36,1,24,36,36,36,19,7,4,36,36,36,8,13,5,8
        dc.b 13,8,19,4,11,24,36,36,36,18,8,11,11,24,36,36,36,2,7,17
        dc.b 8,18,36,36,36,14,5,36,36,36,19,7,4,36,36,36,6,0,17,11
        dc.b 8,2,36,36,36,4,0,19,4,17,18,42,36,36,36,19,7,4,36,36
        dc.b 36,6,20,24,36,36,36,8,18,36,36,36,12,8,18,18,8,13,6,36
        dc.b 36,36,16,20,8,19,4,36,36,36,0,36,36,36,11,0,17,6,4,36
        dc.b 36,36,13,20,12,1,4,17,36,36,36,14,5,36,36,36,1,17,0,8
        dc.b 13,36,36,36,2,4,11,11,18,36,36,36,8,36,36,36,19,7,8,13
        dc.b 10,37,37,37,37,36,36,36,42,42,42,24,4,18,36,36,36,7,4,39
        dc.b 18,36,36,36,13,14,19,36,36,36,22,17,14,13,6,36,36,36,0,19
        dc.b 36,36,36,0,11,11,36,36,36,1,20,19,36,36,36,17,4,12,4,12
        dc.b 1,4,17,36,36,36,7,8,18,36,36,36,13,8,2,10,13,0,12,4
        dc.b 18,36,36,36,5,14,17,36,36,36,39,12,0,13,8,10,8,13,39,36
        dc.b 36,36,11,8,10,4,36,36,36,39,22,0,13,10,4,17,36,36,36,10
        dc.b 8,13,6,39,36,36,36,14,17,36,36,36,39,12,0,13,8,10,8,13
        dc.b 3,8,18,2,7,39,36,36,36,14,17,36,36,36,4,18,15,4,2,8
        dc.b 0,11,11,24,36,36,36,39,12,0,13,24,36,36,36,2,0,12,4,36
        dc.b 36,36,40,8,13,36,36,36,7,8,18,36,36,36,0,18,18,36,36,36
        dc.b 37,37,37,37,41,39,36,36,36,42,42,42,36,36,36,14,7,46,36,36
        dc.b 36,24,14,20,36,36,36,7,0,21,4,36,36,36,19,14,36,36,36,10
        dc.b 13,14,22,36,36,36,19,7,0,19,36,36,36,17,8,2,7,0,17,3
        dc.b 36,36,36,10,0,17,18,12,0,10,4,17,18,36,36,36,8,18,36,36
        dc.b 36,8,13,19,4,17,4,18,19,4,3,36,36,36,8,13,36,36,36,8
        dc.b 13,2,11,20,3,8,13,6,36,36,36,19,7,8,18,36,36,36,18,2
        dc.b 17,14,11,11,19,4,23,19,36,36,36,8,13,19,14,36,36,36,19,7
        dc.b 4,36,36,36,13,4,22,36,36,36,18,19,43,13,4,22,18,36,36,36
        dc.b 22,7,8,2,7,36,36,36,22,8,11,11,36,36,36,1,4,36,36,36
        dc.b 15,20,1,11,8,18,7,4,3,36,36,36,18,14,14,13,42,36,36,36
        dc.b 19,7,8,18,36,36,36,22,8,11,11,36,36,36,1,4,36,36,36,0
        dc.b 36,36,36,13,4,22,36,36,36,18,4,17,8,4,36,36,36,2,0,11
        dc.b 11,4,3,36,36,36,39,7,14,22,36,36,36,19,14,36,36,36,1,4
        dc.b 2,14,12,4,36,36,36,0,36,36,36,11,20,18,19,36,36,36,1,14
        dc.b 24,36,36,36,37,39,36,36,36,24,4,0,7,46,36,36,36,24,14,20
        dc.b 36,36,36,7,0,21,4,36,36,36,19,14,36,36,36,10,13,14,22,36
        dc.b 36,36,19,7,0,19,36,36,36,24,4,18,19,4,17,3,0,24,36,36
        dc.b 36,22,7,4,13,36,36,36,22,4,36,36,36,22,4,17,4,36,36,36
        dc.b 8,13,36,36,36,19,7,4,36,36,36,3,8,18,2,14,36,36,36,18
        dc.b 14,12,4,36,36,36,3,20,19,2,7,36,36,36,6,20,24,18,36,36
        dc.b 36,0,18,10,4,3,36,36,36,20,18,36,36,36,8,5,36,36,36,22
        dc.b 4,36,36,36,22,14,20,11,3,36,36,36,11,8,10,4,36,36,36,19
        dc.b 14,36,36,36,7,0,21,4,36,36,36,18,14,12,4,36,36,36,18,7
        dc.b 8,19,36,36,36,0,13,3,36,36,36,14,5,36,36,36,2,14,20,17
        dc.b 18,4,36,36,36,22,4,36,36,36,18,0,8,3,36,36,36,24,4,18
        dc.b 36,36,36,2,14,25,36,36,36,22,4,36,36,36,11,8,10,4,3,36
        dc.b 36,36,19,14,36,36,36,19,17,24,36,36,36,8,19,36,36,36,1,20
        dc.b 19,36,36,36,19,7,4,24,36,36,36,6,0,21,4,36,36,36,20,18
        dc.b 36,36,36,0,36,36,36,12,8,13,3,1,14,12,1,42,42,42,42,36
        dc.b 36,36,14,7,46,36,36,36,0,13,14,19,7,4,17,36,36,36,16,20
        dc.b 14,19,0,19,8,14,13,36,36,36,14,5,36,36,36,19,24,17,4,12
        dc.b 36,36,36,14,5,36,36,36,19,7,4,36,36,36,17,4,18,15,4,2
        dc.b 19,0,1,11,4,18,42,42,42,36,36,36,39,17,8,2,7,0,17,3
        dc.b 36,36,36,8,18,36,36,36,14,13,11,24,36,36,36,8,13,19,4,17
        dc.b 4,18,19,4,3,36,36,36,19,14,36,36,36,6,4,19,36,36,36,24
        dc.b 14,20,17,36,36,36,18,2,17,14,11,11,19,4,23,19,36,36,36,2
        dc.b 14,25,36,36,36,7,4,39,18,36,36,36,5,4,3,36,36,36,20,15
        dc.b 36,36,36,22,8,19,7,36,36,36,20,18,8,13,6,36,36,36,12,8
        dc.b 17,8,13,3,0,36,36,36,1,14,19,19,11,4,18,36,36,36,5,14
        dc.b 17,36,36,36,18,4,23,36,36,36,8,13,18,19,4,0,3,36,36,36
        dc.b 14,5,36,36,36,18,14,12,4,36,36,36,13,8,2,4,36,36,36,15
        dc.b 20,18,18,8,4,18,36,36,36,14,5,36,36,36,18,14,12,4,36,36
        dc.b 36,3,20,19,2,7,36,36,36,6,8,17,11,18,42,42,42,42,39,36
        dc.b 36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36
        dc.b 18,14,36,36,36,7,4,17,4,36,36,36,2,14,12,4,36,36,36,19
        dc.b 7,4,36,36,36,2,17,4,3,8,19,18,36,36,36,5,14,17,36,36
        dc.b 36,19,7,8,18,36,36,36,22,14,13,3,4,17,5,20,11,36,36,36
        dc.b 0,13,3,36,36,36,20,13,13,8,2,10,0,1,11,4,36,36,36,18
        dc.b 2,17,4,4,13,42,42,42,42,42,36,36,36,2,14,3,8,13,6,36
        dc.b 36,36,36,36,36,19,7,4,36,36,36,20,11,19,8,12,0,19,4,36
        dc.b 36,36,5,0,19,4,36,36,36,14,5,36,36,36,20,11,12,36,36,36
        dc.b 36,36,36,42,42,42,42,42,36,36,36,6,17,0,15,7,8,2,18,36
        dc.b 36,36,5,17,14,12,36,36,36,3,8,25,25,24,36,36,36,14,5,36
        dc.b 36,36,19,14,14,11,36,36,36,34,36,36,36,40,19,7,4,36,36,36
        dc.b 6,8,17,11,41,36,36,36,0,13,3,36,36,36,7,0,22,10,12,14
        dc.b 14,13,36,36,36,40,19,7,4,36,36,36,20,13,1,4,0,19,0,1
        dc.b 11,4,36,36,36,20,11,12,36,36,36,11,14,6,14,36,36,36,22,8
        dc.b 19,7,36,36,36,19,7,4,36,36,36,1,4,18,19,36,36,36,12,0
        dc.b 17,12,14,20,17,36,36,36,4,5,5,4,2,19,36,36,36,19,7,4
        dc.b 36,36,36,1,11,20,4,36,36,36,0,3,4,15,19,36,36,36,7,0
        dc.b 18,36,36,36,4,21,4,17,36,36,36,18,4,4,13,42,42,42,42,41
        dc.b 36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,12,20,18,0,23
        dc.b 36,36,36,1,24,36,36,36,39,6,8,21,4,36,36,36,7,8,12,36
        dc.b 36,36,0,36,36,36,2,7,0,13,2,4,36,36,36,42,42,42,42,39
        dc.b 36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,20,15,15,4,17
        dc.b 36,36,36,18,2,17,14,11,11,19,4,23,19,36,36,36,1,24,36,36
        dc.b 36,19,24,17,4,12,36,36,36,0,13,3,36,36,36,18,12,0,11,11
        dc.b 36,36,36,2,14,13,19,17,8,1,20,19,8,14,13,18,36,36,36,5
        dc.b 17,14,12,36,36,36,5,20,17,24,42,42,42,42,42,42,42,42,42,36
        dc.b 36,36,18,14,36,36,36,11,4,19,39,18,36,36,36,22,17,0,15,36
        dc.b 36,36,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42,42
        dc.b 42,42,36,36,36,36,36,36,36,36,36
        dc.b -1
        even

        path 'SCR_INC\'
font:   ibytes 'FONT.BIN'
        path '..'

fonttab:
        dc.l font+0,1152/2
        dc.l font+1152/2,1152/2
        dc.l font+2304/2,1152/2
        dc.l font+3456/2,1152/2
        dc.l font+4608/2,1152/2
        dc.l font+5760/2,1152/2
        dc.l font+6912/2,1152/2
        dc.l font+8064/2,1152/2
        dc.l font+9216/2,576/2
        dc.l font+9792/2,960/2
        dc.l font+10752/2,1152/2
        dc.l font+11904/2,1152/2
        dc.l font+13056/2,1152/2
        dc.l font+14208/2,1152/2
        dc.l font+15360/2,1152/2
        dc.l font+16512/2,1152/2
        dc.l font+17664/2,1152/2
        dc.l font+18816/2,1152/2
        dc.l font+19968/2,1152/2
        dc.l font+21120/2,1152/2
        dc.l font+22272/2,1152/2
        dc.l font+23424/2,1152/2
        dc.l font+24576/2,1152/2
        dc.l font+25728/2,1152/2
        dc.l font+26880/2,1152/2
        dc.l font+28032/2,1152/2
        dc.l font+29184/2,960/2
        dc.l font+30144/2,768/2
        dc.l font+30912/2,960/2
        dc.l font+31872/2,960/2
        dc.l font+32832/2,1152/2
        dc.l font+33984/2,960/2
        dc.l font+34944/2,960/2
        dc.l font+35904/2,960/2
        dc.l font+36864/2,960/2
        dc.l font+37824/2,960/2
        dc.l font+38784/2,192/2
        dc.l font+38976/2,384/2
        dc.l font+39360/2,960/2
        dc.l font+40320/2,384/2
        dc.l font+40704/2,576/2
        dc.l font+41280/2,576/2
        dc.l font+41856/2,384/2
        dc.l font+42240/2,768/2
        dc.l font+43008/2,384/2
        dc.l font+43392/2,768/2
        dc.l font+44160/2,384/2
        dc.l font+44544/2,768/2
        dc.l font+45312/2,1920/2
;       number of characters : 49

bg_scr_text:

        dc.b 9,14,29,26,9,14,29,26,19,7,8,18,26,8,18,26,22,7,0,19
        dc.b 26,8,26,2,0,11,11,26,0,26,20,18,4,11,4,18,18,26,18,2
        dc.b 17,14,11,11,4,17,26,0,13,3,26,8,28,12,26,13,14,19,26,19
        dc.b 7,4,26,14,13,11,24,14,13,4,26,22,7,14,26,8,18,26,19,7
        dc.b 8,13,10,8,13,6,26,19,7,0,19,29,26,14,19,7,4,17,22,8
        dc.b 18,4,26,18,14,12,4,14,13,4,26,14,5,26,19,7,4,26,20,11
        dc.b 12,8,4,18,26,22,14,20,11,3,26,22,17,8,19,4,26,19,7,8
        dc.b 18,26,18,19,20,5,5,30,26,1,20,19,26,1,4,2,0,20,18,4
        dc.b 26,19,7,8,18,26,17,4,0,11,11,24,26,8,18,26,20,18,4,11
        dc.b 4,18,18,26,8,26,7,0,21,4,26,19,14,26,3,14,26,19,7,8
        dc.b 18,27,26,22,7,14,26,0,12,26,8,31,26,12,24,26,13,0,12,4
        dc.b 26,8,18,26,19,24,17,4,12,26,0,13,3,26,8,5,26,24,14,20
        dc.b 26,0,17,4,26,22,0,19,2,7,8,13,6,26,19,7,4,26,18,19
        dc.b 26,18,2,4,13,4,26,24,14,20,26,12,0,24,1,4,26,0,11,17
        dc.b 4,0,3,24,26,10,13,14,22,26,12,4,30,26,8,28,12,26,0,26
        dc.b 12,4,12,1,4,17,26,14,5,26,19,7,4,26,17,4,18,15,4,2
        dc.b 19,0,1,11,4,18,30,26,5,14,17,19,20,13,0,19,4,11,24,26
        dc.b 8,28,12,26,13,14,19,26,19,7,4,26,14,13,11,24,26,14,13,4
        dc.b 26,8,13,26,19,7,8,18,26,17,14,14,12,26,18,14,26,8,5,26
        dc.b 8,28,12,26,17,20,13,13,8,13,6,26,14,20,19,26,14,5,26,8
        dc.b 3,4,0,18,26,8,2,0,13,26,18,19,8,11,11,26,0,18,10,26
        dc.b 0,26,5,4,22,26,14,19,7,4,17,26,6,20,24,18,26,19,14,26
        dc.b 22,17,8,19,4,26,5,14,17,26,12,4,26,0,13,3,26,8,26,22
        dc.b 8,11,11,26,3,14,26,19,7,8,18,26,17,8,6,7,19,26,13,14
        dc.b 22,30,26,19,7,4,17,4,26,8,18,26,0,11,18,14,26,0,26,21
        dc.b 4,17,24,26,18,19,17,0,13,6,4,26,0,13,3,26,20,6,11,24
        dc.b 26,18,12,4,11,11,26,8,13,26,19,7,8,18,26,17,14,14,12,0
        dc.b 13,3,26,19,7,8,18,26,2,0,13,26,14,13,11,24,26,12,4,0
        dc.b 13,26,14,13,4,26,19,7,8,13,6,29,26,5,20,17,24,26,8,18
        dc.b 26,7,4,17,4,27,27,27,26,14,7,26,13,14,29,26,7,4,26,8
        dc.b 18,13,28,19,30,26,7,4,26,8,18,26,14,20,19,18,8,3,4,26
        dc.b 7,20,13,19,8,13,6,26,13,14,15,11,4,0,18,4,26,0,13,3
        dc.b 26,2,14,11,11,4,2,19,8,13,6,26,5,17,20,8,19,26,14,17
        dc.b 26,22,8,19,7,26,14,19,7,4,17,26,22,14,17,3,18,30,30,30
        dc.b 26,7,4,26,8,18,26,11,14,14,10,8,13,6,26,5,14,17,26,18
        dc.b 14,12,4,19,7,8,13,6,26,19,14,26,4,0,19,30,26,7,4,26
        dc.b 5,14,20,13,3,26,19,22,14,26,2,14,11,3,26,18,2,7,13,8
        dc.b 19,25,4,11,18,30,26,8,26,7,0,21,4,26,19,14,26,22,0,8
        dc.b 19,26,19,8,11,11,26,7,4,28,18,26,1,0,2,10,26,8,13,26
        dc.b 19,7,8,18,26,11,8,19,19,11,4,26,2,14,11,3,26,17,14,14
        dc.b 12,30,26,26,26,26,0,7,7,7,30,26,1,24,26,19,7,4,26,22
        dc.b 0,24,30,30,30,30,26,8,5,26,24,14,20,26,0,17,4,26,17,4
        dc.b 0,3,8,13,6,26,19,7,4,26,19,4,23,19,26,8,13,26,19,7
        dc.b 4,26,12,8,3,3,11,4,26,14,5,26,19,7,4,26,18,2,17,4
        dc.b 4,13,26,19,7,4,13,26,9,20,18,19,26,5,14,17,6,4,19,26
        dc.b 19,7,4,26,18,7,8,19,26,19,7,0,19,26,24,14,20,26,0,17
        dc.b 4,26,0,1,11,4,26,19,14,26,18,4,4,26,19,7,4,17,4,30
        dc.b 26,2,7,17,8,18,26,5,17,14,12,26,19,7,4,26,10,13,14,1
        dc.b 11,0,20,2,7,5,17,4,18,18,4,17,18,26,8,18,26,12,20,2
        dc.b 7,26,1,4,19,19,4,17,26,8,13,26,12,0,10,8,13,6,26,12
        dc.b 20,23,0,25,26,19,7,0,13,26,8,13,26,22,17,8,19,8,13,6
        dc.b 26,18,2,17,14,11,11,19,4,23,19,18,30,26,7,0,7,0,30,26
        dc.b 12,0,24,1,4,26,7,4,26,8,18,26,19,4,11,11,8,13,6,26
        dc.b 24,14,20,26,18,14,12,4,26,3,8,18,6,20,18,19,8,13,6,26
        dc.b 18,19,14,17,8,4,18,26,0,1,14,20,19,26,6,8,17,11,18,26
        dc.b 0,13,3,26,7,14,22,26,19,14,26,12,0,10,4,26,19,7,4,12
        dc.b 26,7,0,15,15,24,26,22,8,19,7,14,20,19,26,20,18,8,13,6
        dc.b 26,2,14,13,3,14,12,18,26,0,13,3,26,21,8,1,17,0,19,14
        dc.b 17,18,30,26,26,26,14,7,14,7,29,26,5,20,17,24,29,26,19,7
        dc.b 4,26,19,0,11,10,8,13,6,26,7,14,17,18,4,26,8,18,26,1
        dc.b 0,2,10,26,18,14,26,22,4,26,7,0,21,4,26,19,14,26,6,17
        dc.b 4,4,19,26,0,26,5,4,22,26,15,4,14,15,11,4,30,30,30,26
        dc.b 19,7,8,18,26,19,8,12,4,26,19,7,4,24,26,6,14,26,19,14
        dc.b 26,18,2,7,14,17,18,2,7,26,0,13,3,26,2,7,17,8,18,19
        dc.b 8,0,13,26,5,14,17,26,11,4,19,19,8,13,6,26,20,18,26,22
        dc.b 17,8,19,4,26,0,11,11,26,19,7,8,18,26,18,7,8,19,29,26
        dc.b 26,19,14,26,19,7,4,26,11,14,18,19,26,1,14,24,18,30,30,30
        dc.b 26,19,7,0,13,23,26,5,14,17,26,19,7,4,26,21,4,17,24,26
        dc.b 13,8,2,4,26,23,26,12,0,18,26,2,0,17,3,26,8,26,6,14
        dc.b 19,26,5,17,14,12,26,24,14,20,27,27,27,29,26,26,19,14,26,19
        dc.b 7,4,26,2,0,17,4,1,4,0,17,18,26,5,14,17,26,19,7,4
        dc.b 8,17,26,5,17,8,4,13,3,18,7,8,15,26,0,13,3,26,19,7
        dc.b 4,8,17,26,15,4,0,13,20,19,26,1,20,19,19,4,17,29,19,14
        dc.b 26,19,7,4,26,3,4,11,19,0,26,5,14,17,2,4,30,30,26,7
        dc.b 4,8,11,8,6,18,26,1,11,4,2,7,11,4,29,26,3,0,26,10
        dc.b 14,12,12,19,26,3,4,17,26,18,2,7,11,4,8,12,27,27,29,26
        dc.b 11,4,6,0,2,24,29,26,19,14,26,19,6,4,29,26,1,12,19,29
        dc.b 26,19,7,4,26,14,21,4,17,11,0,13,3,4,17,18,29,26,14,12
        dc.b 4,6,0,29,26,18,24,13,2,26,0,13,3,26,0,11,11,26,19,7
        dc.b 4,26,14,19,7,4,17,26,8,12,15,14,17,19,0,13,19,26,6,20
        dc.b 24,18,30,26,26,26,26,26,14,7,26,22,4,11,11,29,26,19,14,3
        dc.b 0,24,26,22,4,26,7,0,21,4,26,2,7,17,8,18,19,12,0,18
        dc.b 29,26,22,4,26,18,19,8,11,11,26,7,0,21,4,26,19,14,26,12
        dc.b 0,10,4,26,0,26,12,0,15,26,5,14,17,26,19,7,4,26,12,0
        dc.b 8,13,26,12,4,13,20,26,0,13,3,26,8,28,12,26,15,8,18,18
        dc.b 4,3,26,14,5,26,22,8,19,7,26,19,7,8,18,26,3,4,12,14
        dc.b 30,26,26,26,26,18,4,4,26,24,14,20,26,18,14,14,13,30,30,30
        dc.b 30,26,26,26,19,24,17,4,12,26,14,5,26,19,7,4,26,17,4,18
        dc.b 15,4,2,19,0,1,11,4,18,30,30,30,30,30,30,30,30,30,30,30
        dc.b 30,30,26,26,26,26,26,11,4,19,28,18,26,1,20,17,15,27,27,27
        dc.b 27,27,27,27,27,27,26,26,26,26,26,26
        dc.b -1
        even

bg_scr_font:
        path 'BGS_INC\'
        ifeq bg_font-1
        ibytes 'FONT.BIN'
        endc
        ifeq bg_font-2
        ibytes 'FONT2.BIN'
        endc
        ifeq *-bg_scr_font
        fail 'Please set bg_font to 1 or 2'
        endc
        path '..'

bg_scr_pal1:
        dc.w $0700,$0601,$0502,$0403,$0304,$0205,$0106,$07
        dc.w $16,$25,$34,$43,$52,$61,$70,$0161
        dc.w $0252,$0343,$0434,$0525,$0616,$0707,$0606,$0505
        dc.w $0404

;scr_pufs use (20+wcount)*48*4 bytes = 4992 bytes
scr_puf1:                       ;       ds.l    ((20+wcount)*48*2)/4
scr_puf2 equ *+(20+wcount)*48*2 ;       ds.l    ((20+wcount)*48*2)/4
;farbtab uses 2400 bytes
farbtab equ *+(20+wcount)*48*4  ;       ds.l    600

music:                          ;7300 bytes free
        ibytes 'COLORSHK.BIN'
music_tab:
        opt W-
var1    set 0
        rept 16
        dc.b var1
var1    set var1+16
        endr
        opt W+

        ds.w 10

        >PART 'megscrl palette'
megscrl_pal:
        dc.w $0707,$0707,$0607,$0607,$0507,$0507,$0407,$0407
        dc.w $0307,$0307,$0207,$0207,$0107,$0107,$07,$07
        dc.w $17,$17,$27,$27,$37,$37,$47,$47
        dc.w $57,$57,$67,$67,$77,$77,$76,$76
        dc.w $75,$75,$74,$74,$73,$73,$72,$72
        dc.w $71,$71,$70,$70,$0170,$0170,$0270,$0270
        dc.w $0370,$0370,$0470,$0470,$0570,$0570,$0670,$0670
        dc.w $0770,$0770,$0760,$0760,$0750,$0750,$0740,$0740
        dc.w $0730,$0730,$0720,$0720,$0710,$0710,$0700,$0700
        dc.w $0701,$0701,$0702,$0702,$0703,$0703,$0704,$0704
        dc.w $0705,$0705,$0706,$0706,$0707,$0707,$0617,$0617
        dc.w $0527,$0527,$0427,$0427,$0337,$0337,$0247,$0247
        dc.w $0257,$0257,$0167,$0167,$77,$77,$0176,$0176
        dc.w $0275,$0275,$0274,$0274,$0373,$0373,$0472,$0472
        dc.w $0572,$0572,$0671,$0671,$0770,$0770,$0761,$0761
        dc.w $0752,$0752,$0742,$0742,$0733,$0733,$0724,$0724
        dc.w $0725,$0725,$0716,$0716,$0707,$0707,$0616,$0616
        dc.w $0525,$0525,$0434,$0434,$0343,$0343,$0252,$0252
        dc.w $0161,$0161,$70,$70,$0160,$0160,$0250,$0250
        dc.w $0340,$0340,$0430,$0430,$0520,$0520,$0610,$0610
        dc.w $0700,$0700,$0611,$0611,$0522,$0522,$0433,$0433
        dc.w $0344,$0344,$0255,$0255,$0166,$0166,$77,$77
        dc.w $0176,$0176,$0275,$0275,$0374,$0374,$0473,$0473
        dc.w $0572,$0572,$0671,$0671,$0770,$0770,$0661,$0661
        dc.w $0552,$0552,$0443,$0443,$0334,$0334,$0225,$0225
        dc.w $0116,$0116,$07,$07,$16,$16,$25,$25
        dc.w $34,$34,$43,$43,$52,$52,$61,$61
        dc.w $70,$70,$0170,$0170,$0271,$0271,$0371,$0371
        dc.w $0472,$0472,$0572,$0572,$0673,$0673,$0773,$0773
        dc.w $0763,$0763,$0752,$0752,$0742,$0742,$0731,$0731
        dc.w $0721,$0721,$0710,$0710,$0700,$0700,$0701,$0701
        dc.w $0712,$0712,$0713,$0713,$0724,$0724,$0725,$0725
        dc.w $0736,$0736,$0737,$0737,$0637,$0637,$0527,$0527
        dc.w $0427,$0427,$0317,$0317,$0217,$0217,$0107,$0107
        dc.w $07,$07,$17,$17,$0127,$0127,$0137,$0137
        dc.w $0247,$0247,$0257,$0257,$0367,$0367,$0377,$0377
        dc.w $0376,$0376,$0275,$0275,$0274,$0274,$0173,$0173
        dc.w $0172,$0172,$71,$71,$70,$70,$0161,$0161
        dc.w $0252,$0252,$0343,$0343,$0434,$0434,$0525,$0525
        dc.w $0616,$0616
megscrl_pal_end:
        endpart

        path 'INCLUDES\'
megscrl_fnt:
        ibytes 'MEGFONT.BIN'

;end of data section

        bss
;please leave all section indications unchanged...
bss_start:                      ;here starts the bss

screenadr2:ds.l 1
schaltnum:ds.l 1
rl_rich:ds.w 1
blknum: ds.w 1
aktinhsin:ds.l 1
scrollbas:ds.l 1

        ds.l 100
my_stack:

megscrl_buf:
        ds.l 200*8

music_buf:
        ifeq music_len
        ds.l 8000
        ds.l 8000
        ds.l 2000
        endc
        ds.l 1000

        ds.l 1000-50
screenmem:
        ds.l 8000
        ds.l 8000
        ds.l 7000
        ds.l 100
screenmem2:
        ds.l 8000
        ds.l 8000
        ds.l 8000-50
bss_end:                        ;here ends the bss
y:
        end
