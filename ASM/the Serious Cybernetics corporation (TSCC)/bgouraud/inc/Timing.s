;=======================
;=
;=  Time triangles/min.
;= average
;=
;=======================

		section	text
Time.tris_per_sec

		move.l	Time.triangles,d0
		mulu.l	#100*60,d0
		divu.l	Time.diff,d0	; tris/min.
				
		lea.l	.digits+4,a0
		movea.l	Screen,a5

		divu.w	#10000,d0	; Bin->dec
		move.w	d0,d4
		swap.w	d0
		ext.l	d0

		divu.w	#1000,d0
		move.w	d0,d3
		swap.w	d0
		ext.l	d0
		
		divu.w	#100,d0
		move.w	d0,d2
		swap.w	d0
		ext.l	d0
		
		divu.w	#10,d0
		move.w	d0,d1
		swap.w	d0
		
		moveq.l	#7,d5		; Each char is 128 bytes long
		lsl.w	d5,d0
		lsl.w	d5,d1
		lsl.w	d5,d2
		lsl.w	d5,d3
		lsl.w	d5,d4
		lea.l	(a0,d0.w),a4	; Point to apropriate chars
		lea.l	(a0,d1.w),a3
		lea.l	(a0,d2.w),a2
		lea.l	(a0,d3.w),a1
		lea.l	(a0,d4.w),a0

.rows	rept	4			; Plot number
		move.l	(a0)+,(a5)+
	endr
	rept	4
		move.l	(a1)+,(a5)+
	endr
	rept	4
		move.l	(a2)+,(a5)+
	endr
	rept	4
		move.l	(a3)+,(a5)+
	endr
	rept	4
		move.l	(a4)+,(a5)+
	endr
	
		lea.l	x_res*2-5*8*2(a5),a5
	
		dbra	d5,.rows
	
		rts
		
		section	data
.digits		incbin	'inc\numbers.16b'

		section	bss
Time.triangles	ds.l	1	; Nubmer of triangles
Time.diff	ds.l	1	; 100Hz frames passed