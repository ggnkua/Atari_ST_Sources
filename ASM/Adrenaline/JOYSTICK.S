;------------------------------------------------
; Joystick routine by Dr Computer/ADR
; (c) 1993. ADRENALINE
; Commercial uses need a written agreement
;------------------------------------------------

	pea	main(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	
main
	moveq	#$12,d0	; no mouse
	bsr	write_kbd
	moveq	#$13,d0	; stop sending
	bsr	write_kbd
	move.w	#$2700,sr
	move.l	$fffffa06.w,mfp1
	move.l	$fffffa12.w,mfp2
	move.w	$fffffa16.w,mfp3
	move.l	$070.w,old_070
	move.l	$118.w,old_118
	move.l	#$ff00ff40,$fffffa06.w
	move.l	#$ff00ff40,$fffffa12.w
	bclr	#3,$fffffa17.w
	move.l	#vbl,$070.w
	move.l	#keyboard,$118.w
	move.w	#$2300,sr
	moveq	#$11,d0	; restore sending
	bsr	write_kbd
	bsr	flusk
	
	;--- active joy
	moveq	#$14,d0
	bsr	write_kbd

	;--- main loop
wait	lea	table_hex,a0
	lea	number,a1
	move.w	joy_2,d1	; joy 1 or 2
	move.w	d1,d0
	and.w	#$f0,d0
	lsr.b	#4,d0
	move.b	(a0,d0),(a1)+
	move.w	d1,d0
	and.w	#$0f,d0
	move.b	(a0,d0),(a1)
	pea	message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp	

	cmp.w	#$39,key
	bne.s	wait

	;--- stop joy
	moveq	#$15,d0
	bsr	write_kbd

	moveq	#$13,d0	; stop sending
	bsr	write_kbd
	move.w	#$2700,sr
	move.l	mfp1,$fffffa06.w
	move.l	mfp2,$fffffa12.w
	move.w	mfp3,$fffffa16.w
	move.l	old_070,$070.w
	move.l	old_118,$118.w
	move.w	#$2300,sr
	moveq	#$11,d0	; restore sending
	bsr	write_kbd
	bsr	flusk
	moveq	#$08,d0	; ok mouse
	bsr	write_kbd
	
	rts
	
	;--- clear keyboard buffer
flusk	btst	#0,$fffffc00.w
	beq.s	flusk1
	move.b	$fffffc02.w,d0
	bra.s	flusk
flusk1	rts
	
	;--- send data to keyboard
write_kbd	btst	#1,$fffffc00.w
	beq.s	write_kbd
	move.b	d0,$fffffc02.w
	rts

	;--- interruption keyboard
keyboard	move.w	#$2500,sr
	move.w	d0,-(sp)
	btst	#7,$fffffc00.w
	beq.s	keyboard_1
	clr.w	d0
	move.b	$fffffc02.w,d0
	cmpi.w	#1,joy_test
	beq.s	keyboard_2
	cmpi.w	#2,joy_test
	beq.s	keyboard_3
	cmpi.w	#$fe,d0
	beq.s	keyboard_4
	cmpi.w	#$ff,d0
	beq.s	keyboard_5
	move.w	d0,key
keyboard_1	move.w	(sp)+,d0
	rte		
	;--- value for each joy
keyboard_2	clr.w	joy_test
	move.w	d0,joy_1
	bra.s	keyboard_1
keyboard_3	clr.w	joy_test
	move.w	d0,joy_2
	bra.s	keyboard_1
	;--- the value will come !
keyboard_4	move.w	#1,joy_test
	bra.s	keyboard_1
keyboard_5	move.w	#2,joy_test
	bra.s	keyboard_1
	
	;--- interruption vbl
vbl	rte

table_hex	dc.b	"0123456789ABCDEF"
	even
message	dc.b	27,'H'
number	dc.b	'  ',0

key	dc.w	0
joy_test	dc.w	0
joy_1	dc.w	0
joy_2	dc.w	0

old_118	ds.l	1
old_070	ds.l	1
mfp1	ds.l	1
mfp2	ds.l	1
mfp3	ds.w	1
