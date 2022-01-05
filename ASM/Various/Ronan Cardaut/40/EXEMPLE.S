	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#$2700,sr
	
Plantage_de_BSS_DUG
	
	move.l	$70.w,d0
	clr.l	$70.w			; hop bss bug tourne en 2300 !
	move.l	d0,$70.w
	
Replantage_de_BSS_BUG

	move.b	#$12,$fffffc02.w	; on coupe la souris hihihi
	nop
	move.b	#$8,$fffffc02.w
	
Trace_vector_clear
	
	move.l	$24.w,d0
	clr.l	$24.w
	nop
	nop
	move.l	d0,$24.w
	
	
Use_of_parametrics_bkpt

	moveq	#0,d1
loop
	add.l	#$100,d1
	move.l	d1,d2
	move.l	#$5000,d0
	divu	d1,d0
	move.l	d2,d1
	bra	loop	
	
	
Compt_bkpt
	lea	$2000,a0
loop1
	move.w	(a0)+,d0
	btst	#0,d0
	beq.s	not_odd
	nop
not_odd
	cmp.l	#$2300,a0
	ble.s	loop1
	
	illegal
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
msg
Ascii_msg
	rept 20
	dc.b	' ',$0d
	endr
	dcb.b	30,32
	dc.b	'CENTinel is here ...'
	even
	rept 20
	dc.b	' ',$0d
	endr
	
	
	
	
	
	