; raster beams -my latest raster trickery!!!!
; code by tony "Stormlord" bennett '91
;
; tabs at 10	devpac v2.23




	pea	start(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1



;----------------------------
*
start	move.b	#$12,$fffffc02.w
	clr.b	$ffff8203.w
	clr	$ffff8240.w
	bsr	set_ints		; save/install interrupts


scan:	cmpi.b	#$39,$fffffc02.w
	bne.s	scan


exit:	bsr	rem_ints		; remove interrupts
	move.b	#$08,$fffffc02.w
	move	#$777,$ffff8240.w
	
	rts



;----------------------------
*
keyhand:	move	#$2500,sr
	move.b	$fffffc02.w,rubbish
	bclr	#6,$fffffa11.w
	jmp	$fc29ce



newvbl:	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l	#timer_b,$120.w
	move.b	#8,$fffffa1b.w

	clr	counter
	
	addq	#2,pointer_up		; offset -top speed
	cmp	#400,pointer_up
	blt.s	keep_on
	clr	pointer_up
	
keep_on	subq	#2,pointer_down		; offset -bottom speed
	tst	pointer_down
	bpl.s	end_vbl

	move	#300,pointer_down
end_vbl	
	rte


timer_b	clr.b	$fffffa1b.w
	movem.l	d0/a0-a3,-(sp)
	move	sr,-(sp)
	move	#$2700,sr
	lea	colors(pc),a0
	adda	pointer_up(pc),a0
	lea	$ffff8240.w,a1
	lea	$ffff8209.w,a2
	lea	top_beam(pc),a3
	moveq	#0,d0
wait_up	tst.b	(a2)
	beq.s	wait_up
	move.b	(a2),d0
	adda.l	d0,a3
	jmp	(a3)

top_beam	rept	172		; synchronize
	nop
	endr
	
	rept	42		; width of screen
	move	(a0)+,(a1)
	endr
	
	move	#0,(a1)
	move	(sp)+,sr
	movem.l	(sp)+,d0/a0-a3
	clr.b	$fffffa1b.w
	move.l	#timer_b_bottom,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte


timer_b_bottom:
	clr.b	$fffffa1b.w
	addq	#1,counter
	cmp	#191,counter
	blt.s	end_hbl
	move.l	#timer_b_beam,$120.w
end_hbl	bclr	#0,$fffffa0f.w
	move.b	#8,$fffffa1b.w
	rte

	
timer_b_beam:
	clr.b	$fffffa1b.w
	movem.l	d0/a0-a3,-(sp)
	move	sr,-(sp)
	move	#$2700,sr
	lea	colors(pc),a0
	adda	pointer_down(pc),a0
	lea	$ffff8240.w,a1
	lea	$ffff8209.w,a2
	lea	bottom_beam(pc),a3
	moveq	#0,d0
wait_down	tst.b	(a2)
	beq.s	wait_down
	move.b	(a2),d0
	adda.l	d0,a3
	jmp	(a3)

bottom_beam:
	rept	203		; wait until next scanline
	nop
	endr
	
	rept	42		; width of screen
	move	(a0)+,(a1)
	endr
	
	move	#0,(a1)
	move	(sp)+,sr
	movem.l	(sp)+,d0/a0-a3
	bclr	#0,$fffffffa0f.w
	rte


;----------------------------
*
set_ints:	move	#$2700,sr
	move.b	$fffffa07.w,mfp1
	move.b	$fffffa09.w,mfp2
	move.b	$fffffa13.w,mfp3
	clr.b	$fffffa07.w	; disable timer b
	clr.b	$fffffa09.w	; disable timer c
	move.l	$120.w,oldhbl
	move.l	$70.w,oldvbl
	move.l	$118.w,oldkey
	move.l	#keyhand,$118.w
	move.l	#newvbl,$70.w
	move.l	#timer_b,$120.w
	bset	#0,$fffffa07.w	; enable timer b
	bset	#0,$fffffa13.w	; set timer b mask
	move	#$2300,sr
	rts


oldvbl	DC.L	0
oldhbl	DC.L	0
oldkey	DC.L	0


rem_ints:	move	#$2700,sr
	move.b	mfp1(pc),$fffffa07.w
	move.b	mfp2(pc),$fffffa09.w
	move.b	mfp3(pc),$fffffa13.w
	move.l	oldvbl,$70.w	; vbl
	move.l	oldhbl,$120.w	; hbl
	move.l	oldkey,$118.w	; key handler
	move	#$2300,sr
	rts



;----------------------------
*
mfp1	dc.b	0
mfp2	dc.b	0
mfp3	dc.b	0

counter	dc.w	0

pointer_up:
	dc.w	0
	
pointer_down:
	dc.w	300

colors	ds.w	100
	dc.w	$101,$111,$221,$321,$421
	dc.w	$431,$431,$431,$432,$432,$432,$433,$433,$433,$434,$434,$434,$435,$435,$435,$436,$436,$436,$437,$437,$437,$436,$436,$436,$435,$435,$435,$434,$434,$434,$433,$433,$433,$432,$432,$432,$431,$431,$431
	dc.w	$421,$321,$221,$111,$101
	ds.w	100

;	dc.w	$211,$211,$211,$212,$212,$212,$213,$213,$213,$214,$214,$214,$215,$215,$215,$216,$216,$216,$217,$217,$217,$216,$216,$216,$215,$215,$215,$214,$214,$214,$213,$213,$213,$212,$212,$212,$211,$211,$211
;	dc.w	$101,$101,$101,$101,$202,$202,$202,$303,$303,$303,$404,$404,$404,$505,$505,$505,$606,$606,$606,$717,$717,$717,$606,$606,$606,$505,$505,$505,$404,$404,$303,$303,$303,$202,$202,$202,$101,$101,$101

rubbish:	dc.b	0

