;Converts .TNY or .TN1-TN3 file to normal picture
;ENTRY a0 points at source buffer (must start on odd address)
;      a1 points at destination buffer
;EXIT  destination buffer holds picture image
;      d0=0 OK, no other registers changed

conv_tny	movem.l	a0-a3/d1-d5,-(sp)
	move.b	(a0)+,d0	check animation code
	cmp.b	#3,d0
	blt	conv_tny0	skip if none
	add	#4,a0	skip animatiom bytes
	
conv_tny0	movem.l	a0-a1/d0,-(sp)	set palette colours
	move.l	a0,-(sp)
	move	#6,-(sp)
	trap	#14
	addq	#6,sp
	movem.l	(sp)+,a0-a1/d0
	
	add	#32,a0	skip colour palette
	move	#200-1,d5	init column count
	move	#200*20-1,d4	init plane count
	move.l	a1,a3	save a1
	clr.l	d0	
	move.b	(a0)+,d0	
	lsl	#8,d0
	move.b	(a0)+,d0
	add	#2,a0
	move.l	a0,a2
	add	d0,a2

conv_tny1	subq	#1,d0
	move.b	(a0)+,d2
	and	#$00ff,d2
	btst	#7,d2
	bne	conv_tny2
	tst.b	d2
	beq	conv_tny3
	cmp.b	#1,d2
	beq	conv_tny4
	and	#$00ff,d2
conv_tny8	sub	#1,d2
	move.b	(a2)+,d3
	lsl	#8,d3
	move.b	(a2)+,d3
conv_tny5	bsr	out_tny
	dbra	d2,conv_tny5
conv_tny6	tst	d0
	bmi	conv_tny10
	cmp	#1,d0
	bne	conv_tny1
conv_tny10	clr	d0
	movem.l	(sp)+,a0-a3/d1-d5
	rts
	
conv_tny2	neg.b	d2
	and	#$00ff,d2
conv_tny9	subq	#1,d2
conv_tny7	move.b	(a2)+,d3
	lsl	#8,d3
	move.b	(a2)+,d3
	bsr	out_tny
	dbra	d2,conv_tny7
	bra	conv_tny6
	
conv_tny3	move.b	(a0)+,d2
	lsl	#8,d2
	move.b	(a0)+,d2
	subq	#2,d0
	bra	conv_tny8
	
conv_tny4	move.b	(a0)+,d2
	lsl	#8,d2
	move.b	(a0)+,d2
	subq	#2,d0
	bra	conv_tny9
	
;Outputs value in D3.W to next dest address
;ENTRY d3=value
;      a1 points at address
;      d5=column count
;      d4=plane count

out_tny	move	d3,(a1)
	add	#160,a1
	dbra	d5,out_tny1
	move	#199,d5
	sub	#160*200-8,a1
out_tny1	dbra	d4,out_tny2
	move	#200*20-1,d4
	addq	#2,a3
	move.l	a3,a1
out_tny2	rts
