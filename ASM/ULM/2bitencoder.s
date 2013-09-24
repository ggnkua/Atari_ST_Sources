
; the unlimited matricks 2 bit digit kompressor by Gunstick (1992)
; unearthed from the dust in 2004

def_version equ 10
d0_for_mcp equ 0
mcp_adr equ $0500
keyboard set 10

test    equ 10

        ifeq def_version
        opt D-
        org $2500
keyboard set 0
        endc

        text
x:
        ifne def_version
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

        bsr     waitvbl1
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
        bsr.s   waitvbl1
        move.b  #0,$ffff820a.w
        bsr.s   waitvbl1
        move.b  #2,$ffff820a.w
        bsr.s   waitvbl1

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

waitvbl1:
        move.w  #9000,d0
waitvbl2:
        dbra    d0,waitvbl2
waitvbl:
        lea     $ffff8209.w,a0
        movep.w -8(a0),d0
waitvbl3:
        tst.b   (a0)
        bne.s   waitvbl3
        movep.w -4(a0),d1
        cmp.w   d0,d1
        bne.s   waitvbl3
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
        move    #$2700,sr

        bsr.s   waitvbl
        bsr.s   waitvbl

        move.b  #0,$fffffa19.w
        move.b  #255,$fffffa1f.w
        move.b  #$20,$fffffa07.w
        move.b  #0,$fffffa13.w

        moveq   #30,d1
        lea     $ffff8209.w,a0
check_mfp_s1:
        move.b  (a0),d0
        beq.s   check_mfp_s1
        sub.w   d0,d1
        lsl.w   d1,d1
        move.b  #0,$fffffa0b.w
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
        add.l   #255,d0
        and.l   #$ffff00,d0
        move.l  d0,screenad
        ror.l   #8,d0
        lea     $ffff8201.w,a0
        movep.w d0,0(a0)

        lea     my_stack,sp
        bsr     waitvbl

;*************** 2 bit sound *************

        lea     soundstart,a0
        lea     soundend,a1

volumeloop:
        move.b  (a0),d0
;        lsr.b   #1,d0
;        add.b   #64,d0
;        andi.b  #%11000000,d0
        move.b  d0,(a0)+

        cmpa.l  a1,a0
        blo.s   volumeloop


;*************** Compress ***********

        lea     soundstart,a0
        lea     soundend,a1
        lea     compdat,a2
        lea     convdat,a3
        move.b  (a0)+,d0        ;first 2 values
        move.b  d0,(a2)+
        move.b  (a0)+,d1
        move.b  d1,(a2)+
codeloop:

        move.b  d0,d2
        sub.b   d1,d2           ;calc diff
        move.b  d1,d3
        sub.b   d2,d3           ;approx. value

        clr.w   d4
        move.b  (a0)+,d4        ;correct value
        sub.b   d3,d4
        move.b  0(a3,d4.w),d5   ;write code
        move.b  d5,(a2)+

        add.b   d5,d3           ;new approx value

        move.b  d1,d0           ;shift window
        move.b  d3,d1

        cmpa.l  a1,a0
        blo.s   codeloop


        lea     soundstart,a0
        lea     soundend,a1

andloop:
        move.b  (a0),d0
;        andi.b  #%10000000,d0
        move.b  d0,(a0)+

        cmpa.l  a1,a0
        blo.s   andloop




loop:

no_key:

        lea     soundstart,a0
        lea     soundend,a1
        lea     compdat,a2
        lea     convdat,a3
        lea     voldat,a4
        lea     $ffff8800.w,a5
        move.b  (a2)+,d0        ;first 2 values
;        move.b  d0,(a2)+
        move.b  (a2)+,d1
;        move.b  d1,(a2)+
        addq.l  #2,a0
playloop:
        cmpi.b  #57,$fffffc02.w
        beq     exit


        move.b  d0,d2
        sub.b   d1,d2           ;calc diff
        move.b  d1,d3
        sub.b   d2,d3           ;approx. value

;        move.b  (a0)+,d4        ;correct value
;        sub.b   d3,d4
;        move.b  0(a3,d4.w),d5   ;write code
        move.b  (a2)+,d5

        add.b   d5,d3           ;new approx value

        move.b  d1,d0           ;shift window
        move.b  d3,d1




        clr.w   d7

        move.b  (a0)+,d7
        cmpi.b  #56,$fffffc02.w
        bne.s   playnormal
        move.b  d1,d7           ;get data
playnormal:

        lsl.w   #3,d7
        move.l  4(a4,d7.w),(a5)
        move.l  0(a4,d7.w),d7
        movep.l d7,0(a5)

        mulu    #%1111111111111111,d7
        mulu    #%1111111111111111,d7
        mulu    #%1111111111111111,d7
        mulu    #%1111111111111111,d7

        cmpa.l  a1,a0
        blo.s   playloop



        bra     loop

        data
voldat:
        path 'E:\MUSIX\SAMPLING'
        ibytes 'STREP_8B.BIN'
convdat:
s       set 0

        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s

s       set s+64


        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s

s       set -128

        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
s       set s+64


        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s
        dc.b s,s,s,s,s,s,s,s

soundstart:
        ibytes 'JASYEFF.DIG'


        path 'E:\'
;        ibytes 'DIGWRLD1.DIG'
;        ibytes 'DIGWRLD2.DIG'
;        ibytes 'DIGWRLD3.DIG'
;        ibytes 'DIGWRLD4.DIG'
;        ibytes 'METROPOL.DIG'
;        ibytes 'MOREFUN.DIG'
;        ibytes 'TEE1.SAM'
soundend:



        bss

bss_start:                      ;here starts the bss

screenad:ds.l 1

screenmem:ds.l 64
        ds.l 8000

        ds.l 100
my_stack:
compdat:
        ds.l 30000

bss_end:                        ;here ends the bss
        end
