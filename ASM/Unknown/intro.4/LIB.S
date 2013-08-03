initialize
	; go to	supervisor mode
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_sp

	; save physical	screen
	move.w	#2,-(sp)		
	trap	#14
	addq.l	#2,sp
	move.l	d0,save_phys

	; save logical screen	
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,save_log
	
	; save old resolution
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,save_res

	; save palette	
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,save_pal
	
	; save keyclick	
	move.b	$484.w,save_keymode
	bclr	#0,$484.w

	; save handlers	etc.
	lea		vars,a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$114.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa13.w
	clr.b	$fffffa15.w
		
	rts

deinitialize
	; soundchip	off
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w

	; restore handlers etc.
	lea	vars,a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$114.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$134.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w

	; restore keyclick
	move.b	save_keymode,$484.w

	; restore palette
	movem.l	save_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	; restore resolution and screens
	move.w	save_res,-(sp)
	move.l	save_phys,-(sp)
	move.l	save_log,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea		12(sp),sp

	; enable interrupts
	move.w	#$2300,sr
	
	; restore timer	c
	move.b	#$c0,$fffffa23.w

	; go to	user mode
	move.l	save_sp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	; terminate	program
	clr.w	-(sp)
	trap	#1

low_resolution	
	; go to	low	resolution	
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea		12(sp),sp	

	rts

create_double_buffer
	; sp+8	= size
	; sp+4	= pointer to buffers
	move.l	d0,-(sp)
i	SET		1*4

	move.l	i+4(sp),d0		; pointer to buffer
	add.l	#255,d0
	sub.b	d0,d0			; make 256 byte	aligned
	move.l	d0,physical_screen
	add.l	i+8(sp),d0		; add size
	add.l	#255,d0
	sub.b	d0,d0			; make 256 byte	aligned
	move.l	d0,logical_screen
	move.l	physical_screen,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.l	(sp)+,d0
	
	rts

create_single_buffer
	; sp+4	= pointer to buffer
	move.l	d0,-(sp)
i	SET		1*4

	move.l	i+4(sp),d0		; pointer to buffer
	add.l	#255,d0
	sub.b	d0,d0			; make 256 byte	aligned
	move.l	d0,physical_screen
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.l	(sp)+,d0
	
	rts

swap_buffers
	; swap the screens
	move.l	logical_screen,d0
	move.l	physical_screen,logical_screen
	move.l	d0,physical_screen
	
	rts

memset
	; sp+12	= destination address
	; sp+8	= size
	; sp+4	= value	
	movem.l	d0-d1/a0,-(sp)
i	SET		3*4

	move.l	i+12(sp),a0		; destination address
	move.l	i+8(sp),d0		; size
	move.l	i+4(sp),d1		; value
.loop
	move.b	d1,(a0)+
	subq.l	#1,d0
	bne.s	.loop

	movem.l	(sp)+,d0-d1/a0
	
	rts
	
memcopy
	; sp+12	= source address
	; sp+8	= destination address
	; sp+4	= size
	movem.l	d0/a0-a1,-(sp)
i	SET		3*4

	move.l	i+12(sp),a0		; source address
	move.l	i+8(sp),a1		; destination address
	move.l	i+4(sp),d0		; size
.loop
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.loop

	movem.l	(sp)+,d0/a0-a1

	rts

memcopy_rolled
	; sp+16	= source address
	; sp+12	= destination address
	; sp+8	= size
	; sp+4	= roll
	movem.l	d0-d2/a0-a1,-(sp)
i	SET		5*4

	move.l	i+16(sp),a0		; source address
	move.l	i+12(sp),a1		; destination address
	move.l	i+8(sp),d0		; size
	move.l	i+4(sp),d1		; roll
.loop
	move.b	(a0)+,d2
	rol.b	d1,d2
	move.b	d2,(a1)+
	subq.l	#1,d0
	bne.s	.loop
	
	movem.l	(sp)+,d0-d2/a0-a1
		
	rts

fade_palette
	; sp+20	= source address
	; sp+16	= destination address
	; sp+12	= fade color
	; sp+8	= palette size 
	; sp+4	= delta (0..32768)
	movem.l	d0-d7/a0-a6,-(sp)
i	SET		15*4

	move.l	i+18(sp),a0		; source address
	move.l	i+14(sp),a1		; destination address
	move.l	i+10(sp),d0		; fade color
	move.l	i+6(sp),d1		; palette size

	moveq	#15,d6			; shift amount
	
	move.l	#32768,d2
	sub.w	i+4(sp),d2		; 32768-delta
	
	moveq	#0,d5
	moveq	#2,d3
.pre_multiply
	move.l	d0,d4
	and.w	#$7,d4			; get component
	mulu.w	d2,d4
	lsr.l	d6,d4
	or.w	d4,d5
	ror.w	#4,d5
	lsr.w	#4,d0
	dbra	d3,.pre_multiply
	ror.w	#4,d5
	move.l	d5,d0			; pre-multiplied fade color

	subq	#1,d1			; subtract 1 from size for dbra
.palette_loop
	move.w	(a0)+,d7
	moveq	#0,d5
	moveq	#2,d3
.multiply_source
	move.w	d7,d4
	and.w	#$7,d4			; get component
	mulu.w	i+4(sp),d4
	lsr.l	d6,d4
	or.w	d4,d5
	ror.w	#4,d5
	lsr.w	#4,d7
	dbra	d3,.multiply_source
	ror.w	#4,d5
	add.w	d0,d5			; combined color
	move.w	d5,(a1)+
	dbra	d1,.palette_loop

	movem.l	(sp)+,d0-d7/a0-a6
	
	rts


; *** DATA ***
	
	DATA

	EVEN
	
vars
save_hbl	dc.l	1
save_vbl	dc.l	1
save_tc		dc.l	1
save_acia	dc.l	1
save_tb		dc.l	1
save_ta		dc.l	1
			ds.b	8

save_sp		dc.l	0
save_phys	dc.l	0
save_log	dc.l	0
save_pal	ds.l	8
save_res	dc.w	0
save_keymode	dc.w	0
		
physical_screen	dc.l	0
logical_screen	dc.l	0
vbl_counter	dc.w	0

	EVEN