;Convert .PCX files to image (high rez only)
;ENTRY a0=source buffer address
;      a1=destination buffer address
;EXIT  destination buffer holds picture image
;      d0=0 OK, d0<>0 error
;      d1=width (bytes)
;      d2=height (scanlines)
 
conv_pcx	movem.l	a0-a3/d3-d5,-(sp)
	
	move	#1,d0	set error	
	cmp.b	#1,3(a0)	check if mono image
	bne	conv_pcx1	exit if not

	cmp.b	#10,(a0)	check ident code=10
	bne	conv_pcx1	bra if not
	
	move	4(a0),d0	calc width
	rol	#8,d0
	move	8(a0),d3	get Xmax
	rol	#8,d3
	sub	d0,d3
	add	#1,d3
	
	move	6(a0),d0	calc height
	rol	#8,d0
	move	10(a0),d3	get Xmax
	rol	#8,d3
	sub	d0,d3
	add	#1,d3
	move	d3,d2	save picture height
	sub	#1,d3	correct for dbra
	
	move	66(a0),d5	fetch width (bytes)
	rol	#8,d5	
	move	d5,d1	save width	
	add	#128,a0	a0=data start
conv_pcx4	bsr	pcx_line	convert one line
	add	d5,a1	locate next line addr
	dbra	d3,conv_pcx4	repeat for all lines
	clr	d0	no error
conv_pcx1	movem.l	(sp)+,a0-a3/d3-d5
	rts
	
;Convert one .PCX line
;ENTRY a0=source address
;      a1=dest address
;      d5=line width (bytes)
;EXIT

pcx_line	clr	d4	reset count
	move.l	a1,-(sp)
pcx_line7	move.b	(a0),d0	fetch next byte
	and.b	#%11000000,d0
	cmp.b	#%11000000,d0
	beq	pcx_line3
	
	move.b	(a0)+,(a1)+	copy to dest
	not.b	-1(a1)	and invert

	add	#1,d4	inc chr count
	cmp	d4,d5
	bne	pcx_line7
pcx_line1	move.l	(sp)+,a1
	rts

pcx_line3	move.b	(a0)+,d0
	and	#%00111111,d0
	sub	#1,d0
pcx_line5	move.b	(a0),(a1)+
	not.b	-1(a1)
	add	#1,d4
	cmp	d4,d5
	beq	pcx_line6
	dbra	d0,pcx_line5	
	add	#1,a0	
	bra	pcx_line7

pcx_line6	add	#1,a0
	bra	pcx_line1
