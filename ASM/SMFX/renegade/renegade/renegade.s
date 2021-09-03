; Renegade Breakdown
; 2021 spkr/smfx
;
;	- sine generator
;	- palette index
;	- code generation in hardsync execution
;	- text writer for wasting other bytes
;
; loadable palette support incase graphician wants to collaborate... what a waste ;)

LOAD_PAL	equ 1

DO_TEXT		equ 0
DO_YM		equ 1
DO_THREE	equ 1
	
	move.w	#$20,-(sp)								;4	shortest way to execute code; not correcting the stack
	trap 	#1										;2	lets go
	clr.b	$fffffa09.w								;4 	stable rasters

	IFEQ	LOAD_PAL
	jsr	.loadPal
	ENDC

	IFEQ	DO_YM
	lea	$ffff8800.w,a0								;4 bytes		; ym reg
	lea	.ymdata(pc),a1								;4 bytes		; load data
	move.w	(a1)+,d0								;2 bytes		; first val
.ym:	
		movep.w	d0,0(a0)							;4 bytes	; write data to ym chip
		move.w	(a1)+,d0							;2 bytes	; get next value
		bne.s	.ym									;2 bytes	; as long as != 0, loop
	ENDC
	
; code generation
	lea		32000(a4),a6							;4	color space 
	lea		105*40(a6),a5							;4	middle of color space

	move.l	#$D06A0000,d2							;6	add.w	1234(a2),d0
	IFEQ	DO_THREE
	move.l	#$D0690000,d4							;6	add.w	1234(a1),d0
	ENDC
	move.w	#210-1,d7								;4
.ol
	move.l	#$301B4e71,(a4)+						;6	 move.w	(a3)+,d0, nop
	move.l	d2,(a4)+								;2	 
	addq.w	#4,d2									;2
	IFEQ	DO_THREE
	move.l	d4,(a4)+
	subq.w	#4,d4
	ENDC
	move.l	#$49F50000,(a4)+						;6	 lea	(a5,d0.w),a4		;16				move.l	a5,a4	284D ;4	add.w	d0,a4	D8C0

	IFEQ	DO_THREE
	moveq	#74,d3
	ELSE
	move	#76,d3
	ENDC									;2
.il
		move.w	#$309c,(a4)+						;4	 move.w	(a4)+,(a0)
		move.w	.colors(pc,d3),(a6)+				;4
		subq.w	#2,d3								;2
		bge.s	.il									;2
	dbra	d7,.ol									;4

; push the text
		IFEQ	DO_TEXT
		pea		.text(pc)							;4
		move	#9,-(sp)							;4
		trap	#1									;2
		ENDC

	move.l	#$42504E73,(a4)+						;6	 clr.w	(a0), rte


	move.l	a4,usp									;2
SIZE	equ 256										; 	define entries in sine
	move.w	#SIZE-1,d0								;4	number of value in sine table
.exp_based_sine
	addq.w	#1,d1									;2	+1
	move.l	d1,d2									;2	save locally
	muls	d0,d2									;2	multiply 
	swap	d2										;2	<<16
	divs	#(SIZE/2)*(SIZE),d2						;4	divide
	asr.w	#8,d2									;2
	asr.w	#2,d2									;2
	add.w	d2,d2									;2
	sub.w	d2,SIZE*2(a4)							;4 cos
	sub.w	d2,SIZE*6(a4)							;4 cos
	move.w	d2,SIZE*4(a4)							;4 sin
	move.w	d2,(a4)+								;2 sin
	dbra	d0,.exp_based_sine						;4	loop	;30

	move.l	#.vbl,$70.w

.x
	bra.s	.x


	IFEQ	DO_YM
.ymdata:		
		dc.b	$02,$ef				;Tone channel 2 (fine)		
		dc.b	$03,$0e				;Tone channel 2 (rough)
		dc.b	$09,$10				;Volume channel 2
		dc.b	$0B,$f0				;Envelope tone (fine)
		dc.b	$0F,$0F				;Envelope tone (rough)
		dc.b	$0D,%00001000			;Envelope shape
		dc.b	$07,%11111101			;Set mixer for channel 2
		dc.w	0	
	ENDC

	IFEQ	DO_TEXT
.text
		dc.b	10,"CYA@SH22!"				;10 bytes
		even
	ENDC
.colors
	dc.w	$007
	dc.w	$017
	dc.w	$027
	dc.w	$037
	dc.w	$047
	dc.w	$057
	dc.w	$067
	dc.w	$077
	dc.w	$177
	dc.w	$176
	dc.w	$275
	dc.w	$374
	dc.w	$473
	dc.w	$572
	dc.w	$671
	dc.w	$770
	dc.w	$771
	dc.w	$772
	dc.w	$773
	dc.w	$774
	dc.w	$775
	dc.w	$776
	dc.w	$777
	dc.w	$774
	dc.w	$770
	dc.w	$760
	dc.w	$750
	dc.w	$740
	dc.w	$730
	dc.w	$720
	dc.w	$710
	dc.w	$700
	dc.w	$701
	dc.w	$602
	dc.w	$503
	dc.w	$404
	dc.w	$305
	dc.w	$206
	dc.w	$107


	IFEQ	LOAD_PAL
.load_file:	move.l	a1,.buf
		move.l	d0,.size

		clr.w	-(sp)				;fopen()
		move.l	a0,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		bmi.s	.skip
		move.w	d0,.fh

		move.l	.buf,-(sp)			;fread()
		move.l	.size,-(sp)
		move.w	.fh,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	.fh,-(sp)			;fclose()
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
.skip:		rts
.buf:		dc.l	0
.size:		dc.l	0
.fh:		dc.w	0

.rotoFile1		dc.b	'plasma\pal.09b',0
	even
.rotoFile1Size	equ 78


.loadPal
		lea		.rotoFile1,a0
		lea		.colors,a1
		move.l	#.rotoFile1Size,d0
		jsr		.load_file
		rts
	ENDC

.vbl


.sync:
  move.b $ffff8209.w,d0
  beq.s .sync
  not.b d0
  lsr.b d0,d0

	move.w	d5,d6
	addq.w	#1,d5
	and.w	#1024-2,d6
	subq.w	#2,d4
;	move.w	d5,d4
	and.w	#1024-2,d4

	IFEQ	DO_THREE
	sub.w	#2,d1
	and.w	#1024-2,d1
	move.l	usp,a1
	add.w	d1,a1
	ENDC
	
	lea		$ffff8240.w,a0
	move.l	usp,a3
	move.l	usp,a2
	add.w	d6,a3
	add.w	d4,a2
