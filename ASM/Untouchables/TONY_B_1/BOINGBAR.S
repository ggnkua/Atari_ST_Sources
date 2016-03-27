;   big-red-bouncing raster bars!
;   coded by Tony Bennett using devpac V2.23
;   thanx to Argonaut for tips!
;   tabs = 10




	pea	xxx(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr	-(sp)
	trap	#1


*------------------
xxx	clr.b	$ffff8203.w
	bsr	init_ints

main_loop	tst.b	vsync
	bne.s	main_loop
	st	vsync

	bsr.s	raster

	cmp.b	#$39,$fffffc02.w
	bne.s	main_loop

	bsr	ret_ints
	move	#$777,$ffff8240.w
	rts


*------------------
raster	lea	buffer(pc),a0	;clear old raster wave-forms
	rept	25
	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)+
	clr.l	(A0)+
	endr
	
	lea	wave(pC),a1	;address of the sine table
	adda	wave_offset(pc),a1	;by simply adding a value to it.
	
	moveq	#5-1,d5		;amount of bars

get_bar	lea	buffer(pc),a2
	adda	(a1),a2		;so add that to the buffer, and
				;this gives the address at which
				;we display the next bar at...!!

	lea	red_bar(pc),a0	;address of the bars
	rept	14
	move.l	(a0)+,(a2)+	;copy bar to buffer
	endr

	lea	12(a1),a1
	
	dbf	d5,get_bar

	addq	#2,wave_offset	;increment offset into sine-table
	cmp	#278,wave_offset
	ble.s	bye
	clr	wave_offset
	
bye	rts


*------------------
init_ints	move	#$2700,sr
	move.b	$fffffa07.w,mfp1
	move.b	$fffffa09.w,mfp2
	move.b	$fffffa13.w,mfp3
	move.b	$fffffa21.w,mfp4
	move.b	$fffffa1b.w,mfp5
	move.l	$120.w,oldhbl
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l	#vbl,$70.w
	move.l	#hbl,$120.w
	move.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move	#$2300,sr
	rts

ret_ints:	move.b	mfp1(pc),$fffffa07.w
	move.b	mfp2(pc),$fffffa09.w
	move.b	mfp3(pc),$fffffa13.w
	move.b	mfp4(pc),$fffffa21.w
	move.b	mfp5(pc),$fffffa1b.w
	move.l	#$fc06de,$70.w
	move.l	oldhbl(pc),$120.w
	rts

*------------------
mfp1	dc.b	0
mfp2	dc.b	0
mfp3	dc.b	0
mfp4	dc.b	0
mfp5	dc.b	0
oldhbl	dc.l	0


*------------------
vbl:	clr.b	$fffffa1b.w	
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w

	sf	vsync

	move.l	#buffer,the_col

	rte


*------------------
hbl:	move.l	a4,-(sp)
	move.l	the_col(pc),a4
	move	(a4)+,$ffff8240.w
	move.l	a4,the_col
	move.l	(sp)+,a4
	bclr	#0,$fffffa0f.w
	rte


*------------------
wave_offset:
	dc.w	0
	
the_col	dc.l	0

vsync:	dc.b	0
old_stk	dc.l	0


red_bar:	dc.w	0,$100,$100,$200,$200,$300,$300,$400,$400,$500,$500,$600,$600,$711,$711,$600,$600,$500,$500,$400,$400,$300,$300,$200,$200,$100,$100,0

; shit, but ok!, wave!
wave	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	2,2,2,4
	dc.w	6,6,8,$A
	dc.w	$C,$E,$10,$14
	dc.w	$16,$18,$1C,$1E
	dc.w	$22,$26,$2A,$2E
	dc.w	$32,$36,$3A,$3E
	dc.w	$42,$48,$4C,$50
	dc.w	$56,$5C,$62,$66
	dc.w	$6C,$72,$78,$80
	dc.w	$86,$8C,$92,$9A
	dc.w	$A2,$A8,$B0,$B8
	dc.w	$C0,$C8,$D0,$D8
	dc.w	$E0,$E8,$F2,$FA
	dc.w	$102,$10C,$116,$120
	dc.w	$128,$132,$13C,$146
	dc.w	$13C,$132,$128,$120
	dc.w	$116,$10C,$102,$FA
	dc.w	$F2,$E8,$E0,$D8
	dc.w	$D0,$C8,$C0,$B8
	dc.w	$B0,$A8,$A2,$9A
	dc.w	$92,$8C,$86,$80
	dc.w	$78,$72,$6C,$66
	dc.w	$62,$5C,$56,$50
	dc.w	$4C,$48,$42,$3E
	dc.w	$3A,$36,$32,$2E
	dc.w	$2A,$26,$22,$1E
	dc.w	$1C,$18,$16,$14
	dc.w	$10,$E,$C,$A
	dc.w	8,6,6,4
	dc.w	2,2
	dc.w	0,0,0,0,0
	dc.w	0,0,0,0,0
	dc.w	0,0,0,0,0
	dc.w	0,0,0,0,0


	bss
buffer	ds.w	200

