; mp2 - DSP 44.1kHz Stereo MPEG2 Audio decoder
; Copyright (C) 1996 Fredrik Noring
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; Fredrik Noring
; noring@lysator.liu.se

EXT_CLK	equ	1

 IF	EXT_CLK
BUFFER_SIZE	equ	2304	; 2534	; 2304
 ELSE
BUFFER_SIZE	equ	2534
 ENDIF
	

	include	"equates.asm"

HAN_SIZE	equ	512
SCALE_RANGE	equ	64

INFO_BITRATE		equ	12-8
INFO_FREQUENCY	equ	10-8
INFO_PADDING		equ	9-8
INFO_MODE		equ	6
INFO_EXTMODE		equ	4

MPG_MD_STEREO		equ	0
MPG_MD_JOINT_STEREO	equ	1
MPG_MD_DUAL_CHANNEL	equ	2
MPG_MD_MONO		equ	3

	org	L:$0
fraction	ds	3*32
bit_alloc	ds	32
sample	ds	3*32
scfsi	ds	32

	org	L:$800
buf	ds	2*HAN_SIZE
scale_index	ds	3*32

save_A	ds	1
save_x	ds	1

	org	X:$2000
msb		ds	256	; allign
window		ds	32*16
filter		ds	64*32
multiple	ds	64
fc		dc	0.9090909090,0.0909090909
		dc	0.8181818181,0.1818181818
		dc	0.7272727272,0.2727272727
		dc	0.6363636363,0.3636363636
		dc	0.5454545454,0.4545454545
		dc	0.4545454545,0.5454545454
		dc	0.3636363636,0.6363636363
		dc	0.2727272727,0.7272727272
		dc	0.1818181818,0.8181818181
		dc	0.0909090909,0.9090909090
c		ds	17
d		ds	17
alloc		ds	4*16*32+16*32
mask		dc	$000000,$000001,$000003,$000007
		dc	$00000f,$00001f,$00003f,$00007f
		dc	$0000ff,$0001ff,$0003ff,$0007ff
		dc	$000fff,$001fff,$003fff,$007fff
divs		dc	$7fffff,$400000,$200000,$100000
		dc	$080000,$040000,$020000,$010000
		dc	$008000,$004000,$002000,$001000
		dc	$000800,$000400,$000200,$000100
bitm		dc	$000001,$00002,$000004,$000008
		dc	$000010,$00020,$000040,$000080
		dc	$000100,$00200,$000400,$000800
		dc	$001000,$02000,$004000,$008000
frame		ds	512

	org	Y:$2000
buffer1		ds	BUFFER_SIZE
buffer2		ds	BUFFER_SIZE
buffer0		ds	2304
logic		ds	1
tmp_r6		ds	1

bufp		dc	buf+64
sblimit		ds	1
jsbound		ds	1
frame_size		dc	0
frame_okay		dc	0
frame_x0		dc	0
frame_x1		dc	0
frame_y0		dc	0
frame_got_byte	dc	0
frame_the_byte	dc	0

state		dc	$c00000

fast_forwarding	dc	0

	org	X:$3f00
getbit_cntl	dc	0,0,0,0,0,0,0,0
		dc	1,1,1,1,1,1,1,1
		dc	2,2,2,2,2,2,2,2
getbit_mask	dc	$000000,$000001,$000003,$000007
		dc	$00000f,$00001f,$00003f,$00007f
		dc	$0000ff,$0001ff,$0003ff,$0007ff
		dc	$000fff,$001fff,$003fff,$007fff

	org	Y:$3f00
		dc	$000001,$000002,$000004,$000008
		dc	$000010,$000020,$000040,$000080
		ds	16
		dc	$000000,$000001,$000002,$000004
		dc	$000008,$000010,$000020,$000040
		dc	$000080,$000100,$000200,$000400
		dc	$000800,$001000,$002000,$004000
getbit_cntlp	ds	1
getbit_framep	ds	1

mode	ds	1
stereo	ds	1
sblimits_mono		dc	08,08,08,27,27,27,30,30,30,30,30,30,30,30,30,0
		dc	08,08,08,27,27,27,27,27,27,27,27,27,27,27,27,0
		dc	12,12,12,27,27,27,30,30,30,30,30,30,30,30,30,0
sblimits_stereo	dc	08,08,08,08,08,08,08,27,27,27,30,30,30,30,30,0
		dc	08,08,08,08,08,08,08,27,27,27,27,27,27,27,27,0
		dc	12,12,12,12,12,12,12,27,27,27,30,30,30,30,30,0
frame_sizes		dc	0,104,156,182,208,261,313,365,417,522,626,0731,0835,1044,1253,0
		dc	0,096,144,168,192,240,288,336,384,480,576,0672,0768,0960,1152,0
		dc	0,144,216,252,288,360,432,504,576,720,864,1008,1152,1440,1728,0

	org	P:$0
	jmp	<start

	org p:$000c
	nop

	org	P:$10
	movep	Y:(r7)+,X:<<M_TX

	org	P:$40
start	jsr	<init_tables

	move	#buffer1,r7
	move	#2*BUFFER_SIZE-1,m7

	movep	#%000000000,x:<<M_PCC ; SSI reset
	movep	#%0100000100000000,x:<<M_CRA
	movep	#%0111100000001000,x:<<M_CRB
	movep	#%111100000,x:<<M_PCC ; port C control register
	movep	#%000010000,x:<<M_PCDDR
	movep	#%000000000,x:<<M_PCD ; clear frame syncs
	movep	#$3000,X:<<M_IPR
	andi	#<$FC,MR

main	jsset	#3,X:$ffe9,pause

	move	#>buffer1,x0
	move	#>buffer1+32,y0
_wait1	move	r7,A
	cmp	x0,A
	jlt	_wait1
	cmp	y0,A
	jgt	_wait1
 IF	EXT_CLK
	move	#>buffer2,x0	;;
 ELSE
	move	#>buffer0,x0	;;;
 ENDIF
	move	x0,Y:logic
	jsr	<_replay
 IF	EXT_CLK
 ELSE
	move	#buffer2,r0	;;;
	jsr	<convert	;;;
 ENDIF

	move	#>buffer2,x0
	move	#>buffer2+32,y0
_wait2	move	r7,A
	cmp	x0,A
	jlt	_wait2
	cmp	y0,A
	jgt	_wait2
 IF	EXT_CLK
	move	#>buffer1,x0	;;
 ELSE
	move	#>buffer0,x0	;;;
 ENDIF
	move	x0,Y:logic
	jsr	<_replay
 IF	EXT_CLK
 ELSE
	move	#buffer1,r0	;;;
	jsr	<convert	;;;
 ENDIF
	jmp	<main

_replay	jsr	<read_frame

	move	Y:frame_okay,A
	tst	A
	jmi	_no_sync

	jsr	<decode_bitalloc
	jsr	<decode_scale

	do	#4,_l1
	jsr	<buffer_sample
	jsr	<dequantize_sample
	move	#scale_index+0*32,r0
	jsr	<denormalize_sample
	jsr	<SubBandSynthesis
	nop
_l1	do	#4,_l2
	jsr	<buffer_sample
	jsr	<dequantize_sample
	move	#scale_index+1*32,r0
	jsr	<denormalize_sample
	jsr	<SubBandSynthesis
	nop
_l2	do	#4,_l3
	jsr	<buffer_sample
	jsr	<dequantize_sample
	move	#scale_index+2*32,r0
	jsr	<denormalize_sample
	jsr	<SubBandSynthesis
	nop
_l3
_no_sync	rts

convert	move	#buffer0,r2
	move	#fc,r1
	move	Y:(r2)+,y0
	move	Y:(r2)+,y1
	do	#115,_loop1
	move	y0,Y:(r0)+
	move	y1,Y:(r0)+
	do	#10,_loop2
	move	X:(r1)+,x0
	move	X:(r1)+,x1
	mpy	y0,x0,A Y:(r2)+,y0
	mpy	y1,x0,B Y:(r2)+,y1
	macr	y0,x1,A
	macr	y1,x1,B A,Y:(r0)+
	move	        B,Y:(r0)+
_loop2	move	#fc,r1
_loop1
	move	y0,Y:(r0)+
	move	y1,Y:(r0)+
	move	X:(r1)+,x0
	move	X:(r1)+,x1
	mpy	y0,x0,A Y:(r2)+,y0
	mpy	y1,x0,B Y:(r2)+,y1
	macr	y0,x1,A
	macr	y1,x1,B
	move	A,Y:(r0)+
	move	B,Y:(r0)+
	rts

get_bits
	move	#-1,m5
	move	x0,n5
	move	x0,n4
	move	X:(r5+n5),n6
	move	x0,A
	move	#>$7,y1
	and	y1,A
	move	A1,n5
	move	Y:(r5),y1
	move	X:(r6)+n6,A
	lsr	A
	move	A1,x1
	mpy	x1,y1,A Y:(r4+n4),y1
	move	#8-1,m5
	move	A0,x1
	mpy	x1,y1,A	X:(r4+n4),x1
	and	x1,A (r5)+n5
	move	A1,A
	rts

denormalize_sample
	ori	#%00001000,mr
	move	#multiple,r1
	move	#multiple,r2
	move	#fraction,r3
	move	#fraction,r4
	move	#32,n3
	move	#32,n4
	move	#96-1,m3
	move	#96-1,m4
	move	Y:sblimit,x0
	do	x0,_multiply
	move	X:(r0),n1
	move	Y:(r0)+,n2
	move	X:(r1+n1),x0
	move	X:(r2+n2),y0

	move	X:(r3)+n3,x1 Y:(r4),y1
	mpyr	x0,x1,A X:(r3),x1
	mpyr	y0,y1,B A,X:(r4)
	move	B,Y:(r4)+n4
	mpyr	x0,x1,A Y:(r4),y1
	mpyr	y0,y1,B A,X:(r3)+n3
	move	X:(r3),x1 B,Y:(r4)+n4
	mpyr	x0,x1,A Y:(r4),y1
	mpyr	y0,y1,B A,X:(r3)+n3
	move	B,Y:(r4)+n4
;
;	do	#3,_loop
;	move	X:(r3),x1 Y:(r4),y1
;	mpyr	x0,x1,A
;	mpyr	y0,y1,B
;	move	A,X:(r3)+n3
;	move	B,Y:(r4)+n4
;_loop
	move	(r3)+
	move	(r4)+
_multiply
	move	#-1,m3
	move	#-1,m4
	andi	#%11110011,mr
	rts

SubBandSynthesis
	move	#64,n0
	move	#32,n6
	move	#$3ff,m0
	move	Y:bufp,r0
	move	#fraction,r6
	do	#3,_loop
	move	(r0)-n0

	move	r0,r1
	move	r0,r5
	move	#filter,r4
	do	#64,_f1
	move	r6,r2
	move	X:(r4)+,x1
	move	X:(r2),x0
	move	Y:(r2)+,y0
	mpy	x1,x0,A X:(r2),x0
	mpy	x1,y0,B X:(r4)+,x1 Y:(r2)+,y0
	do	#32-2,_f2
	mac	x1,x0,A X:(r2),x0
	mac	x1,y0,B X:(r4)+,x1 Y:(r2)+,y0
_f2	macr	x1,x0,A
	macr	x1,y0,B
	move	A,X:(r1)+ B,Y:(r5)+
_f1
	ori	#%00001000,mr
	move	#window,r2
	move	#$3ff,m1
	move	#$3ff,m3
	move	#$3ff,m4
	move	#$3ff,m5
	move	#96,n3
	move	r0,r3
	move	r0,r1
	move	(r3)+n3
	move	#128,n4
	move	#128,n5
	move	r6,Y:tmp_r6
	move	Y:logic,r6
 	do	#32,_w1
 	move	r1,r4
 	move	r3,r5
 	move	X:(r4),y0
	move	X:(r2)+,x1 Y:(r4)+n4,y1
	mpy	x1,y0,A X:(r5),y0
	mpy	x1,y1,B X:(r2)+,x1 Y:(r5)+n5,y1
	do	#(16-2)/2,_w2
	mac	x1,y0,A X:(r4),y0
	mac	x1,y1,B X:(r2)+,x1 Y:(r4)+n4,y1
	mac	x1,y0,A X:(r5),y0
	mac	x1,y1,B X:(r2)+,x1 Y:(r5)+n5,y1
_w2 	mac	x1,y0,A (r1)+
	mac	x1,y1,B (r3)+
	move	A,Y:(r6)+
	move	B,Y:(r6)+

_w1	move	r6,Y:logic
	move	Y:tmp_r6,r6
	move	#-1,m1
	move	#-1,m3
	andi	#%11110011,mr
	move	#-1,m4
	move	#-1,m5
	move	(r6)+n6

_loop	move	#-1,m0
	move	r0,Y:bufp
	rts

dequantize_sample
	; Clear fraction
	move	  #fraction,r0
	clr	A #fraction,r4
	do	#3*32,_clear
	move	A,X:(r0)+ A,Y:(r4)+
_clear
	move	#$ff,m1
	move	#96-1,m4
	move	#32,n4
	move	#msb,r1

	jsr	<dequantize_left
	jsr	<dequantize_right

	move	#-1,m1
	move	#-1,m4
	rts

dequantize_left
	move	#alloc,r0
	move	#bit_alloc,r2
	move	#sample,r3
	move	#fraction,r4
	move	Y:sblimit,x0
	do	x0,_loop1
	move	X:(r2)+,A
	tst	A
	jeq	_nope

	move	A,n0
	move	#>$008000,x0
	move	X:(r0+n0),x1
	mpy	x0,x1,A #>8,B
	move	A1,A
	tst	A A,n1
	jne	_ok
	clr	B x1,n1
	nop
_ok	move	X:(r1+n1),x0
	add	x0,B

	move	#3*16*32,n5
	lua	(r0)+n0,r5
	move	#d,r6
	move	X:(r5+n5),n6
	move	X:(r5+n5),n5
	move	#c,r5
	move	X:(r6+n6),y1	; d
	move	X:(r5+n5),y0	; c

	move	B,n5
	move	B,n6
	move	#mask-1,r6
	do	#3,_loop2
	move	#bitm-1,r5
	move	X:(r3),A
	move	X:(r5+n5),x0
	and	x0,A #$800000,x0
	tst	A #0,A
	teq	x0,A
	move	A,A0
	move	#divs,r5
	move	X:(r6+n6),x0
	move	X:(r3)+,B
	and	x0,B X:(r5+n5),x1
	move	B,x0
	mac	x0,x1,A
	move	A0,x1	; fraction
	move	y1,A	; c*d
	mac	y0,x1,A	; c*fraction
	asl	A
	move	A,X:(r4)+n4
_loop2
_nope	move	#16,n0
	move	(r4)+
	move	(r0)+n0
_loop1	rts

dequantize_right
	move	#alloc,r0
	move	#bit_alloc,r2
	move	#sample,r3
	move	#fraction,r4
	move	Y:sblimit,x0
	do	x0,_loop1
	move	Y:(r2)+,A
	tst	A
	jeq	_nope

	move	A,n0
	move	#>$008000,x0
	move	X:(r0+n0),x1
	mpy	x0,x1,A #>8,B
	move	A1,A
	tst	A A,n1
	jne	_ok
	clr	B x1,n1
	nop
_ok	move	X:(r1+n1),x0
	add	x0,B

	move	#3*16*32,n5
	lua	(r0)+n0,r5
	move	#d,r6
	move	X:(r5+n5),n6
	move	X:(r5+n5),n5
	move	#c,r5
	move	X:(r6+n6),y1	; d
	move	X:(r5+n5),y0	; c

	move	B,n5
	move	B,n6
	move	#mask-1,r6
	do	#3,_loop2
	move	#bitm-1,r5
	move	Y:(r3),A
	move	X:(r5+n5),x0
	and	x0,A #$800000,x0
	tst	A #0,A
	teq	x0,A
	move	A,A0
	move	#divs,r5
	move	X:(r6+n6),x0
	move	Y:(r3)+,B
	and	x0,B X:(r5+n5),x1
	move	B,x0
	mac	x0,x1,A
	move	A0,x1	; fraction
	move	y1,A	; c*d
	mac	y0,x1,A	; c*fraction
	asl	A
	move	A,Y:(r4)+n4
_loop2
_nope	move	#16,n0
	move	(r4)+
	move	(r0)+n0
_loop1	rts

buffer_sample
	jsr	<get_bits_init

	move	#bit_alloc,r0
	move	#sample,r1
	move	#3,n1
	move	#alloc,r2
	move	Y:jsbound,x0
	do	x0,_loop1
	move	X:(r0),A
	tst	A
	jeq	_not_right
	jsr	_right
	jmp	<_resume_right
_not_right
	clr	A
	move	A,X:(r1)+
	move	A,X:(r1)+
	move	A,X:(r1)+
_resume_right
	move	(r1)-n1		;;;

	move	Y:(r0)+,A
	tst	A
	jeq	_not_left
	jsr	_left
	jmp	<_resume_left
_not_left
	clr	A
	move	A,Y:(r1)+
	move	A,Y:(r1)+
	move	A,Y:(r1)+
_resume_left

	move	#16,n2
	nop
	move	(r2)+n2
_loop1
	move	Y:jsbound,x0
	move	Y:sblimit,A
	sub	x0,A
	jeq	_nomono
	do	A,_loop2
	move	X:(r0)+,A
	tst	A
	jeq	_not_mono
	jsr	_right
	move	(r1)-n1		;;;
	move	X:(r1),x0
	move	x0,Y:(r1)+
	move	X:(r1),x0
	move	x0,Y:(r1)+
	move	X:(r1),x0
	move	x0,Y:(r1)+
	jmp	<_resume_mono
_not_mono
	clr	A
	move	A,X:(r1)
	move	A,Y:(r1)+
	move	A,X:(r1)
	move	A,Y:(r1)+
	move	A,X:(r1)
	move	A,Y:(r1)+
_resume_mono

	move	#16,n2
	nop
	move	(r2)+n2
_loop2
_nomono	jsr	<get_bits_exit
	rts

_right	move	A,n2
	move	#32*16,n3
	lua	(r2)+n2,r3
	move	#>3,y0
	move	(r3)+n3
	move	X:(r3)+n3,x0
	move	X:(r3)+n3,A
	cmp	y0,A
	jne	_right359
	jsr	<get_bits
	move	A,X:(r1)+
	jsr	<get_bits
	move	A,X:(r1)+
	jsr	<get_bits
	move	A,X:(r1)+
	rts
_right359
	jsr	<get_bits
	move	X:(r3+n3),y0	; 1/nlevels
	move	X:(r2+n2),y1	; nlevels

	clr	A A,x1
	mpy	x1,y0,B x1,A0
	asl	A B,x1
	mac	-y1,x1,A
	move	A0,A
	lsr	A
	move	A,X:(r1)+

	clr	A
	mpy	x1,y0,B x1,A0
	asl	A B,x1
	mac	-y1,x1,A
	move	A0,A
	lsr	A
	move	A,X:(r1)+

	clr	A
	mpy	x1,y0,B x1,A0
	asl	A B,x1
	mac	-y1,x1,A
	move	A0,A
	lsr	A
	move	A,X:(r1)+
	rts

_left	move	A,n2
	move	#32*16,n3
	lua	(r2)+n2,r3
	move	#>3,y0
	move	(r3)+n3
	move	X:(r3)+n3,x0
	move	X:(r3)+n3,A
	cmp	y0,A
	jne	_left359
	jsr	<get_bits
	move	A,Y:(r1)+
	jsr	<get_bits
	move	A,Y:(r1)+
	jsr	<get_bits
	move	A,Y:(r1)+
	rts
_left359
	jsr	<get_bits
	move	X:(r3+n3),y0	; 1/nlevels
	move	X:(r2+n2),y1	; nlevels

	clr	A A,x1
	mpy	x1,y0,B x1,A0
	asl	A B,x1
	mac	-y1,x1,A
	move	A0,A
	lsr	A
	move	A,Y:(r1)+

	clr	A
	mpy	x1,y0,B x1,A0
	asl	A B,x1
	mac	-y1,x1,A
	move	A0,A
	lsr	A
	move	A,Y:(r1)+

	clr	A
	mpy	x1,y0,B x1,A0
	asl	A B,x1
	mac	-y1,x1,A
	move	A0,A
	lsr	A
	move	A,Y:(r1)+
	rts

decode_bitalloc
	jsr	<get_bits_init

	move	#16,n0
	move	#alloc+1*32*16,r0
	move	#bit_alloc,r1
	move	Y:jsbound,y0
	do	y0,_loop1
	move	X:(r0)+n0,x0
	jsr	<get_bits
	move	A,X:(r1)
	jsr	<get_bits
	move	A,Y:(r1)+
_loop1
	move	Y:jsbound,y0
	move	Y:sblimit,A
	sub	y0,A
	jeq	_loop2
	do	A,_loop2
	move	X:(r0)+n0,x0
	jsr	<get_bits
	move	A,X:(r1)
	move	A,Y:(r1)+
_loop2
	jsr	<get_bits_exit
	rts

decode_scale
	jsr	<get_bits_init

	move	#>2,x0
	move	#bit_alloc,r0
	move	#scfsi,r1
	move	Y:sblimit,y0
	do	y0,_loop0
	move	X:(r0),A
	tst	A
	jeq	_n1
	jsr	<get_bits
	move	A,X:(r1)
_n1	move	Y:(r0)+,A
	tst	A
	jeq	_n2
	jsr	<get_bits
	move	A,Y:(r1)
_n2	move	(r1)+
_loop0
	move	#32,n1
	move	#3*32-1,m1
	move	#bit_alloc,r0
	move	#scale_index,r1
	move	#scfsi,r2
	move	Y:sblimit,y0
	do	y0,_loop1

	move	X:(r0),A	; Right
	tst	A
	jeq	<_not_right
	move	X:(r2),A	; Right
	tst	A #>1,x0
	jeq	_r0
	cmp	x0,A #>2,x0
	jeq	_r1
	cmp	x0,A #>3,x0
	jeq	_r2
	cmp	x0,A
	jeq	_r3
	jmp	<_right
_r0	move	#>6,x0
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	jmp	<_right
_r1	move	#>6,x0
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	move	A,X:(r1)+n1	; Right
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	jmp	<_right
_r3	move	#>6,x0
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	move	A,X:(r1)+n1	; Right
	jmp	<_right
_r2	move	#>6,x0
	jsr	<get_bits
	move	A,X:(r1)+n1	; Right
	move	A,X:(r1)+n1	; Right
	move	A,X:(r1)+n1	; Right
	jmp	<_right
_not_right
	move	#>SCALE_RANGE-1,A
	move	A,X:(r1)+n1	; Right
	move	A,X:(r1)+n1	; Right
	move	A,X:(r1)+n1	; Right
_right
	move	Y:(r0),A	; Left
	tst	A
	jeq	<_not_left
	move	Y:(r2),A	; Left
	tst	A #>1,x0
	jeq	_l0
	cmp	x0,A #>2,x0
	jeq	_l1
	cmp	x0,A #>3,x0
	jeq	_l2
	cmp	x0,A
	jeq	_l3
	jmp	<_left
_l0	move	#>6,x0
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	jmp	<_left
_l1	move	#>6,x0
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	move	A,Y:(r1)+n1	; Left
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	jmp	<_left
_l3	move	#>6,x0
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	move	A,Y:(r1)+n1	; Left
	jmp	<_left
_l2	move	#>6,x0
	jsr	<get_bits
	move	A,Y:(r1)+n1	; Left
	move	A,Y:(r1)+n1	; Left
	move	A,Y:(r1)+n1	; Left
	jmp	<_left
_not_left
	move	#>SCALE_RANGE-1,A
	move	A,Y:(r1)+n1	; Left
	move	A,Y:(r1)+n1	; Left
	move	A,Y:(r1)+n1	; Left
_left
	move	(r0)+
	move	(r1)+
	move	(r2)+
_loop1
	move	#-1,m1
	jsr	<get_bits_exit
	rts

zero_buffers	clr	A #buffer1,r0
	do	#BUFFER_SIZE,_zero
	move	A,Y:(r0)+
	move	A,Y:(r0)+
_zero	rts

pause	jsr	zero_buffers
	jset	#3,X:$ffe9,*
	rts

fast_forward	jsset	#3,X:$ffe9,zero_buffers
	bset	#0,Y:fast_forwarding
	do	#20,_skip
	jsr	read_frame
	nop
_skip	bclr	#0,Y:fast_forwarding
	rts

read_frame	move	Y:fast_forwarding,x0
	jset	#0,x0,_nope
	jsset	#4,X:$ffe9,fast_forward
_nope
	move	Y:frame_okay,A
	tst	A
	jne	_again

	jsr	read_header
_again	jsr	parse_header

	clr	A #frame,r0
	jsr	DMA_r_x0
;_wait_5	jclr	#0,X:<<M_HSR,_wait_5
;	movep	X:<<M_HRX,x0
	move	x0,y0
	jsr	DMA_r_x0
	move	x0,x1
	jsr	DMA_r_x0
	move	x0,A0
	move	y0,x0
;_wait_6	jclr	#0,X:<<M_HSR,_wait_6
;	movep	X:<<M_HRX,x1
;_wait_7	jclr	#0,X:<<M_HSR,_wait_7
;	movep	X:<<M_HRX,A0
	move	#>$008000,y0
	mac	x0,y0,A #>$000080,y0
	mac	x1,y0,A
	move	A0,X:(r0)+

	move	#>$000080,y0
	do	y1,_read
	clr	A A0,x0
	move	x0,y1
	jsr	DMA_r_x0
	move	x0,A0
	move	y1,x0
;_wait	jclr	#0,X:<<M_HSR,_wait
;	movep	X:<<M_HRX,A0
	mac	x0,y0,A
	move	A0,X:(r0)+
_read
	; Round off
	do	#8,_s1
	asl	A
_s1	move	A0,X:(r0)+
	do	#8,_s2
	asl	A
_s2	move	A0,X:(r0)+
	; Initialize pointers
	move	#getbit_cntl,r5
	move	#frame,r6
	move	r5,Y:getbit_cntlp
	move	r6,Y:getbit_framep

	jsr	read_header
	rts
get_bits_init
	move	#getbit_mask,r4
	move	Y:getbit_cntlp,r5
	move	Y:getbit_framep,r6
	rts
get_bits_exit
	move	r5,Y:getbit_cntlp
	move	r6,Y:getbit_framep
	move	#-1,m5
	rts

read_header	move	#>1,x0
	move	x0,Y:frame_okay

	; read 32 bit header (12+20)
	jsr	DMA_r_x0
	move	x0,B
	jsr	DMA_r_x0
_again	move	x0,x1
	jsr	DMA_r_x0
	move	x0,y1
	jsr	DMA_r_x0
	move	x0,y0
	move	y1,x0
;_wait_1	jclr	#0,X:<<M_HSR,_wait_1
;	movep	X:<<M_HRX,x0
;_wait_2	jclr	#0,X:<<M_HSR,_wait_2
;	movep	X:<<M_HRX,x1
;_wait_3	jclr	#0,X:<<M_HSR,_wait_3
;	movep	X:<<M_HRX,x0
;_wait_4	jclr	#0,X:<<M_HSR,_wait_4
;	movep	X:<<M_HRX,y0

;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	B,X:<<M_HTX		;;;;
;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	x1,X:<<M_HTX		;;;;
;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	x0,X:<<M_HTX		;;;;
;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	y0,X:<<M_HTX		;;;;

	move	#>$ff,A
	cmp	A,B #>$f0,A
	jne	_sync_lost
	and	x1,A A,B
	cmp	A,B
	jne	_sync_lost

	move	x1,Y:frame_x1
	move	x0,Y:frame_x0
	move	y0,Y:frame_y0

	move	Y:frame_okay,A
	rts
_sync_lost	jsr	zero_buffers

	move	#>-1,x0
	move	x0,Y:frame_okay
_sync_detection
_get_ff	jsr	DMA_r_x0
	move	#>$ff,y0
	move	x0,A
	and	y0,A #>$42,y0
	cmp	y0,A #>$ff,y0
	jeq	_stop
	cmp	y0,A
	jne	_get_ff

	move	#>$f0,y0
_get_f0	jsr	DMA_r_x0
	move	x0,A
	and	y0,A
	cmp	y0,A
	jne	_sync_detection

	move	#>$ff,B
	jmp	<_again

_stop	do	#8,_wait_some
	jsr	DMA_r_x0
	move	#>$ff,y0
	move	x0,A
	and	y0,A #>$42,y0
	cmp	y0,A
	jne	_nope
_wait_some	jmp	_wait_some
_nope	enddo
	jmp	_sync_detection

parse_header	move	Y:frame_x1,x1
	move	Y:frame_x0,x0
	move	Y:frame_y0,y0

;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	x1,X:<<M_HTX		;;;;
;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	x0,X:<<M_HTX		;;;;
;	jclr	#1,X:<<M_HSR,*	;;;;
;	movep	y0,X:<<M_HTX		;;;;

	move	y0,A
	lsr	A
	lsr	A
	lsr	A
	lsr	A
	lsr	A
	lsr	A #>%11,x1
	and	x1,A #>2,x1
	move	#sblimits_stereo,r0
	move	#>MPG_MD_MONO,B
	cmp	A,B A,Y:mode
	jne	_no_mono
	move	#>1,x1
	move	#sblimits_mono,r0
_no_mono	move	x1,Y:stereo

	move	x0,A
	lsr	A
	lsr	A
	lsr	A
	lsr	A #>%001111,x1
	and	x1,A x0,B
	lsl	B
	lsl	B #>%110000,x1
	and	x1,B A,x1
	or	x1,B
	move	B,n0
	nop
	move	Y:(r0+n0),x1
	move	#frame_sizes,r0
	move	x1,Y:sblimit
	move	x1,Y:jsbound
	move	#>1,x1
	move	Y:(r0+n0),A
	jclr	#INFO_PADDING,x0,_no_padding
	add	x1,A
_no_padding	move	#>4+3,x1

	move	Y:frame_x1,x0
	jset	#0,x0,_no_crc
	jsr	DMA_r_x0
	jsr	DMA_r_x0
;	jsr	DMA_r_x0
;	jsr	DMA_r_x0
	move	#>2+4+3,x1
_no_crc
	sub	x1,A
	move	A,y1

	move	Y:mode,x1
	move	#>MPG_MD_JOINT_STEREO,B
	cmp	x1,B
	jne	_no_joint
	move	y0,A
	lsr	A
	lsr	A #>%1100,x1
	and	x1,A #>4,x1
	add	x1,A
	move	A,Y:jsbound
_no_joint	rts

; DMA handshake and Host DSP/030 I/O routines.
Host_get	jclr	#0,X:<<M_HSR,*
	movep	X:<<M_HRX,x0
	rts
Host_send	jclr	#1,X:<<M_HSR,*
	movep	x0,X:<<M_HTX
	rts
DMA_send	bset	#5,x:<<M_PCD	; start frame sync
	movep	x0,x:<<M_TX
	jclr	#6,x:<<M_SR,*
	bclr	#5,x:<<M_PCD	; stop frame sync
	rts

DMA_r_x0	move	A,L:save_A
	move	x1,X:save_x
	move	Y:frame_got_byte,x1
	jset	#0,x1,_ok

	move	#>1,x0
	move	x0,Y:frame_got_byte
	jsr	_read
	move	x0,Y:frame_the_byte
	move	#>$008000,x1
	mpy	x0,x1,A
	move	A1,x0
	
	move	Y:frame_the_byte,x1
	move	#>$ff,A
	and	x1,A
	move	A1,Y:frame_the_byte

	move	X:save_x,x1
	move	L:save_A,A
	rts
_ok	move	#0,x0
	move	x0,Y:frame_got_byte
	move	Y:frame_the_byte,x0
	move	X:save_x,x1
	move	L:save_A,A
	rts

_read

	bset	#4,X:<<M_PCD	; start frame sync
	jclr	#7,X:<<M_SR,*	; RDF
	bclr	#4,X:<<M_PCD	; stop frame sync
	movep	X:<<M_RX,A
	lsr	A
	lsr	A Y:<state,x0
	or	x0,A #>$010000,x1
	lsr	A
	move	A1,x0
	mpy	x0,x1,A #>$ffff,x0
	and	x0,A A0,Y:<state
	move	A1,x0
	rts

init_tables	move	#filter,r0
	do	#64*32,_filter
_f_wait	jclr	#0,X:<<M_HSR,_f_wait
	movep	X:<<M_HRX,X:(r0)+
_filter
	move	#window,r0
	do	#32*16,_window
_w_wait	jclr	#0,X:<<M_HSR,_w_wait
	movep	X:<<M_HRX,X:(r0)+
_window
	move	#alloc,r0
	do	#2048+16*32,_alloc
_a_wait	jclr	#0,X:<<M_HSR,_a_wait
	movep	X:<<M_HRX,X:(r0)+
_alloc
	move	#multiple,r0
	do	#64,_multiple
_m_wait	jclr	#0,X:<<M_HSR,_m_wait
	movep	X:<<M_HRX,X:(r0)+
_multiple
	move	#c,r0
	do	#17,_c
_c_wait	jclr	#0,X:<<M_HSR,_c_wait
	movep	X:<<M_HRX,X:(r0)+
_c
	move	#d,r0
	do	#17,_d
_d_wait	jclr	#0,X:<<M_HSR,_d_wait
	movep	X:<<M_HRX,X:(r0)+
_d
	move	#msb,r0
	do	#256,_msb
_s_wait	jclr	#0,X:<<M_HSR,_s_wait
	movep	X:<<M_HRX,X:(r0)+
_msb
	move	  #buf,r0
	clr	A #buf,r4
	rep	#2*HAN_SIZE
	move	A,X:(r0)+ A,Y:(r4)+

	clr	A #buffer1,r0
	rep	#BUFFER_SIZE
	move	A,Y:(r0)+
	rep	#BUFFER_SIZE
	move	A,Y:(r0)+
	rts

	end
