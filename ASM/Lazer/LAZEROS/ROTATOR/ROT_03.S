 	OUTPUT	h:\dba\rot.PRG

	jmp	main
	bra	init_rout
	bra	exit_rout
	bra	do_once

;-----------------------------------------------------------
	include startup.s
	include	demo.s
;-----------------------------------------------------------
BLITTER = $ffff8a00

HALFTONE	= 0
SRC_XINC	= 32
SRC_YINC	= 34
SRC_ADDR	= 36
ENDMASK1	= 40
ENDMASK2	= 42
ENDMASK3	= 44
DST_XINC	= 46
DST_YINC	= 48
DST_ADDR	= 50
X_COUNT		= 54
Y_COUNT		= 56
HOP		= 58
OP		= 59
LINE_NUM	= 60
SKEW		= 61

FHOP_SOURCE	= 1
FHOP_HALFTONE	= 0
FSKEWFXSR	= 7
FSKEWNFSR	= 6
FLINEBUSY	= 7
FLINEHOG	= 6
FLINESMUDGE	= 5

MHOP_SOURCE	= $02
MHOP_HALFTONE	= $01
MSKEWFXSR	= $80
MSKEWNFSR 	= $40
MLINEBUSY	= $80
MLINEHOG	= $40
MLINESMUDGE	= $20


;-----------------------------------------------------------
;-----------------------------------------------------------
main
	shrink_memory

	bsr	init
	save_stack
	bsr	phoenix_init

	save_interrupts
	set_interrupts

        addi.w  #20,$FFFF8284.w
	move.w	#0,$ffff820e
	bsr	setup_logo
	bsr	singen
	bsr	setup_rotator

.main_loop
	move.l	scr1,d0
	move.l	scr2,scr1
	move.l	d0,scr2
	setscreen
	vsync
	
	bset	#0,$ffff82c3.w		;doublescan

	*move.l	#$4f0000,$ffff9800.w
	bsr	rotator
	*move.l	#$6f0000,$ffff9800.w

	move.l	#$0,$ffff9800.w

	tst.w	exit_flag
	beq.s	.exit

	move.b	key,old_key
	move.b	$fffffc02.w,key
	cmp.b	#$39,key
	bne	.main_loop

.exit

	restore_interrupts
	bsr	phoenix_exit
	restore_stack
	bsr	exit
	terminate
;-----------------------------------------------------------
init_rout
	move.l	a0,parameters

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2
	move.l	EXTRA_SCREEN(a0),scr3

	rts
;-----------------------------------------------------------
exit_rout
	rts
;-----------------------------------------------------------
do_once
	move.l	parameters,a0
	lea	rgb_320x200xtrue,a1
	move.l	a1,SCRMODE(a0)
	move.w	#TRUE,SCRMODE_UPDATE(a0)

	move.l	parameters,a0
	move.w	#2,SCREEN_COUNT(a0)
	move.w	#TRUE,SCREEN_SWAP(a0)

	move.l	parameters,a0
	move.w	#TRUE,PALETTE_UPDATE(a0)
	move.l	#coltab3,PALETTE(a0)
	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2
	bsr	clrscr

        addi.w  #20,$FFFF8284.w
	move.w	#0,$ffff820e
	bsr	setup_logo
	bsr	singen
	bsr	setup_rotator

	bset	#0,$ffff82c3.w		;doublescan

taskloop

	move.l	parameters,a0
	move.l	COUNTER_ABS(a0),d0
.11	cmp.l	COUNTER_ABS(a0),d0
	beq.s	.11

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2


	bsr	rotator

	demo_swapscreens

	bra	taskloop
;-----------------------------------------------------------
;-> a0...palette
set_palette

	lea	coltab3,a1
	move.w	#155,d0
.1	move.l	(a1)+,(a0)+
	dbf	d0,.1

	rts
;-----------------------------------------------------------
setup_logo

        lea     maglogo+8(PC),A0
        lea     orig_gfx,A1
        move.w  #128-1,D0
mag_l0  move.w  #128-1,D1
mag_l1
*        move.w  #-1,512(A1)
*        move.w  #-1,256(A1)
*        move.w  #-1,512+256(A1)
*        move.w  #-1,(A1)+
        move.w  (A0),512(A1)
        move.w  (A0),256(A1)
        move.w  (A0),512+256(A1)
        move.w  (A0)+,(A1)+
        dbra    D1,mag_l1
	lea     256+512(A1),A1
	dbra    D0,mag_l0

	rts
;-----------------------------------------------------------
;512 Werte im Padded-24-Format (fr den DSP geeignet !)
;d.h. 0 ... $007fffff ... 0 ... $00800001 ...
singen:
size                    EQU 512 ;nicht „ndern !

sin_gen:                lea     sin,A0
                        moveq   #0,D6
                        lea     size*2+4(A0),A1
                        movea.l A0,A2
                        moveq   #size/4-1,D7
sin_gen1:               lea     sin_fakdiv+16,A3
                        move.l  D6,D5
                        moveq   #7,D2
sin_gen2:               move.w  D2,D1
                        move.l  D6,D3
sin_gen3:               mulu.l  D6,D4:D3
                        rol.l   #8,D3
                        rol.l   #8,D4
                        move.b  D3,D4
                        move.l  D4,D3
                        dbra    D1,sin_gen3
                        divs.l  -(A3),D3
                        add.l   D3,D5
                        subq.w  #2,D2
                        bcc.s   sin_gen2
sin_gen4:               asr.l   #1,D5
                        move.l  D5,(A0)+
                        move.l  D5,-(A1)
                        add.l   #$06487ED5/size,D6 ;2*pi*(2^24)
                        dbra    D7,sin_gen1
                        move.l  #$007FFFFF,-(A1)
                        lea     size(A1),A1
                        move.w  #size/2+size/4-1,D1
sin_gen6:               move.l  (A2)+,(A1)
                        neg.l   (A1)+
                        dbra    D1,sin_gen6
                        rts
;-----------------------------------------------------------
setup_rotator
							; Grafik doppeln
                        lea     orig_gfx+2*65536,A0
                        lea     gfx+4*65536,A1
                        moveq   #0,D1
                        move.w  #$00010000>>1-1,D0
rotator_gengfx_l0:      move.w  -(A0),D1
                        move.w  D1,-(A1)
                        move.w  d1,-(A1)
                        move.w  -(A0),D1
                        move.w  d1,-(A1)
                        move.w  D1,-(A1)
                        dbra    D0,rotator_gengfx_l0


						; Doubletab generieren...
abdunkelwert            EQU 4
                        lea     doubletab,A0
                        move.l  #$0000FFFF,D0
rota_gendouble_l0:      move.w  D0,D1
                        and.w   #%0000000000011111,D1
                        subq.w  #abdunkelwert,D1
                        bpl.s   rota_gendouble_w0
                        moveq   #0,D1
rota_gendouble_w0:      move.w  D0,D2
                        and.w   #%0000011111100000,D2
                        sub.w   #abdunkelwert<<6,D2
                        bmi.s   rota_gendouble_w2
                        or.w    D2,D1
rota_gendouble_w2:      move.w  D0,D2
                        and.w   #%1111100000000000,D2
                        sub.w   #abdunkelwert<<11,D2
                        bcs.s   rota_gendouble_w3
                        or.w    D2,D1
rota_gendouble_w3:      move.w  D1,0(A0,D0.l*4)
                        move.w  D1,2(A0,D0.l*4)
                        dbra    D0,rota_gendouble_l0
						;¯w%=30
                        move.w  #0,w
						;¯si%=SINQ(w%)*65536

			rts
;-----------------------------------------------------------
rotator
                        bsr     gen_rotdist

                        lea     sin,A0
                        move.w  w,D0
                        move.l  0(A0,D0.w*4),si

                        moveq   #8,D3
                        move.l  si,D6
                        asr.l   D3,D6
                        move.l  D6,si
						;¯co%=COSQ(w%)*65536
                        lea     cos,A0
                        move.l  0(A0,D0.w*4),co

                        move.l  co,D6
                        asr.l   D3,D6
                        move.l  D6,co

                        lea     gfx+128*1024,A0
		        move.l 	scr1,A1
			add.l	#640*200/2,a1
                        lea     rotdist+100*4,A4
							;¯FOR y%=-50 TO 49
                        move.l  #-50,y
rotator_next_y:         move.l  -(A4),D6
                        cmp.l   #$00000A00,D6
                        ble.s   dorot
                        move.w  #640/4-1,D7
norot_l0:
                        move.l  #0,-(A1)
                        dbra    D7,norot_l0
                        bra     norot
dorot:					;¯xstart%=(-50*faktor%) DIV 256
                        move.l  #-80,D3
                        muls    D6,D3
                        asr.l   #8,D3
					;¯ystart%=(y%*faktor%) DIV 256
                        move.l  y,D4
                        add.l   #70-20,D4
                        muls    D6,D4
                        asr.l   #8,D4
					;¯xpos%=xstart%*si%+ystart%*co%
					;¯ypos%=ystart%*si%-xstart%*co%
                        move.l  D3,D0
                        move.l  D4,D1
                        muls.l  si,D0
                        muls.l  co,D4
                        add.l   D4,D0
                        muls.l  si,D1
                        muls.l  co,D3
                        sub.l   D3,D1
					;¯xofs%=(si%*faktor%) DIV 256
                        move.l  si,D2
                        muls.l  D6,D2
                        clr.w   D2
                        swap    D2
					;¯yofs%=-(co%*faktor%) DIV 256
                        move.l  co,D3
                        muls.l  D6,D3
                        asr.l   #8,D3
					;¯FOR x%=0 TO 99
                        neg.l   D3
                        lsr.l   #8,D0
                        swap    D1
                        swap    D3
                        move.l  D1,D7
                        clr.w   D7
                        add.l   D7,D0
                        move.l  D3,D7
                        clr.w   D7
                        add.l   D7,D2
                        move.w  #160/10-1,D7
rotator_next_x:
;¯WORD{scrcntr%+(ypos% DIV 65536)*640+(xpos% DIV 65536)*2}=-1
; d0 xpos  yn|00|xv|xn
; d1 ypos  00|00|00|yv
; d2 xofs  yn|00|xv|xn
; d3 yofs  00|00|00|yv
                        REPT 10
                        move.w  D0,D4
                        move.b  D1,D4
                        move.l  0(A0,D4.w*4),-(A1)
                        *move.l  #-1,-(A1)
                        add.l   D2,D0
                        addx.b  D3,D1
                        ENDR
						;¯NEXT x%
                        dbra    D7,rotator_next_x
						;¯ADD faktor%,3
						;¯NEXT y%
norot:
                        addq.l  #1,y
                        cmpi.l  #50,y
                        bne     rotator_next_y

                        addi.w  #3+2,w
                        cmpi.w  #512,w
                        blt.s   rotator_winkel_w0
                        subi.w  #512,w
rotator_winkel_w0:
rotator_w0:
                        rts

inverse:	dc.w	0
;-----------------------------------------------------------
;> a = 60                      d0   <<20
;> b = 20
;> aofs = b/100                d1   <<20
;> h = 50                      d2   <<20
;¯ FOR c=0 TO 99               d3
;¯   d=h/(TAN(RAD(a))/16)      d4
;¯   PRINT #1,MKL$(d);
;¯   ADD a,aofs
;¯ NEXT c
gen_rotdist:
                        lea     splinewerte,A0
                        lea     splines,A1
                        move.w  splinecnt,D0
                        moveq   #3-1,D6
                        bsr     spline

                        add.w   #$0100,splinecnt
                        andi.w  #$7FFF,splinecnt

                        lea     splinewerte,A0
                        moveq   #0,D0
                        move.w  (A0)+,D0
                        lsl.l   #8,D0

                        moveq   #0,D1
                        move.w  (A0)+,D1
                        lsl.l   #8,D1

                        moveq   #0,D2
                        move.w  (A0)+,D2
                        lsl.l   #8,D2

                        lea     rotdist,A0
                        lea     tan,A1
                        moveq   #128-1,D3
gen_rotdist_l0:         move.l  D2,D4
                        move.l  D0,D5
                        swap    D5
                        ext.l   D5
                        divs.l  0(A1,D5.w*4),D4
                        move.l  D4,(A0)+
                        add.l   D1,D0
                        dbra    D3,gen_rotdist_l0

                        rts
;-----------------------------------------------------------
spline:
                        moveq   #15,D7
.l0:                    lea     tbuff,A2
                        move.l  D0,D1
                        eori.w  #$7FFF,D0 ; t2%   d1
                        move.w  D0,D2
                        move.w  D1,D3
                        mulu    D0,D2
                        lsr.l   D7,D2   ; t_2
                        move.w  D2,D4
                        mulu    D0,D4
                        lsr.l   D7,D4   ; t_3  >>1
                        move.w  D4,(A2)+
                        move.w  D1,D4
                        mulu    D2,D4
                        lsr.l   D7,D4   ; 3*t_2_m_t2 >>2
                        move.w  D4,(A2)+
                        mulu    D1,D3
                        lsr.l   D7,D3
                        move.w  D3,D4
                        mulu    D0,D4
                        lsr.l   D7,D4   ; 3*t_m_t2_2 >>3
                        move.w  D4,(A2)+
                        mulu    D1,D3
                        lsr.l   D7,D3   ; t2_3 >>4
                        move.w  D3,(A2)+
.l1:                    lea     tbuff,A2
                        move.w  (A2)+,D1
                        muls    (A1)+,D1
                        REPT 2
                        move.w  (A2)+,D2
                        muls    (A1)+,D2
                        muls.l  #3,D2
                        add.l   D2,D1
                        ENDR
                        move.w  (A2)+,D2
                        muls    (A1)+,D2
                        add.l   D2,D1
                        add.l   D1,D1
                        swap    D1
                        move.w  D1,(A0)+
                        dbra    D6,.l1

                        rts
;-----------------------------------------------------------
splinewerte:            DS.W 10
splines:                DC.W $A000,$A000,$A000,$0000
                        DC.W $0000,$0000,$0000,$0D00
                        DC.W $0000,$3000,-$1000,$3000+$2000
splinecnt:              DC.W 0
sin_fakdiv:             DC.L -6,120,-5040,362880 ;-3!, 5!, -7!, 9!
;-----------------------------------------------------------



;-----------------------------------------------------------
clrscr
	move.l	scr1,a5
	move.l	scr2,a6
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2

	move.w	#489,d7
.1	
	rept	10
	movem.l	d0-d6/a0-a2,(a5)
	movem.l	d0-d6/a0-a2,(a6)
	lea	40(a5),a5
	lea	40(a6),a6
	endr
	dbf	d7,.1
	rts
;-----------------------------------------------------------
vbl

old_vbl	jmp	$12345678
	rte
;-----------------------------------------------------------
init
	clr_bss

	super_on
	mouse_off

	cache_on

        move.l  $44e.w,old_screen
	save_resolution

	move.l	#screens+256,d0
	clr.b	d0
	move.l	d0,scr1
	add.l	#384*240*2,d0
	move.l	d0,scr2
	add.l	#384*240*2,d0
	move.l	d0,scr3

	move.l	scr1,d0
	setscreen

	lea	rgb_320x200xtrue,a0
	set_resolution

	move.l	#0,$ffff9800.w
        rts
;-----------------------------------------------------------
exit
	
	move.l	old_screen,d0
	setscreen
	restore_resolution

	mouse_on
	super_off
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
scr1		dc.l	0
scr2		dc.l	0
scr3		dc.l	0

exit_flag	dc.w	-1

;-----------------------------------------------------------
coltab3	REPT 256
	dc.l	0
	ENDR

maglogo		incbin yy.tru
magnetic

tan		incbin tan.bin
;-----------------------------------------------------------

	even

	section bss

	ds.l	1000
mystack		ds.l	0

start_bss

rotdist:                DS.L 128
sin:                    DS.L 512/4
cos:                    DS.L 512
w:                      DS.W 1
si:                     DS.L 1
co:                     DS.L 1
y:                      DS.L 1
doubletab:              REPT 4
                        DS.L 65536/2
                        ENDR
gfx:                    DS.L 256*256
inverse_gfx:            DS.L 256*256
tbuff:                  DS.L 6

orig_gfx	ds.w	128*128*4

screens		ds.w	3*384*240+256

end_bss
