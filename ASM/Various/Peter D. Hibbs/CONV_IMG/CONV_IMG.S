;Convert .IMG file to normal (high rez only)
;ENTRY a0=source buffer address
;      a1=destination buffer address
;      (m_buffer) defined
;EXIT  destination buffer holds picture image
;      d0=0 OK, d0<>0 invalid picture format
;      d1=width (bytes)
;      d2=height (scanlines)

conv_img	movem.l	a0-a2/d3-d7,-(sp)
	move	#1,d0	set error	
	cmp	#1,4(a0)	check No planes
	bne	conv_img1	bra if not 1 (high rez)

	move	14(a0),d3
	move	d3,d2	d2=height (scanlines)
	sub	#1,d3

	move	6(a0),d6	
	sub	#1,d6	d6=pattern length-1
	move	2(a0),d0	fetch header size
	lsl	#1,d0	d0*2

	move	12(a0),d7	fetch width (pixels)
	and.l	#$0000ffff,d7
	divu	#8,d7	divide by 8
	move.l	d7,d1
	and.l	#$ffff0000,d7
	beq	conv_img2
	add	#1,d1	d1=width (bytes)
conv_img2	add	d0,a0	skip header
conv_img3	tst.b	(a0)	check next byte
	bne	conv_img4	
	tst.b	1(a0)
	bne	conv_img4
	cmp.b	#-1,2(a0)
	bne	conv_img1
	move.b	3(a0),d4
	and	#$00ff,d4
	add	#4,a0
	move.l	a0,a2
conv_img5	move.l	a2,a0
	bsr	img_line	process one line
	add	d1,a1
	sub	#1,d3
	cmp	#-1,d3	check flag byte (FF)
	beq	conv_img7	bra if error
	sub	#1,d4
	bne	conv_img5
	bra	conv_img3

conv_img4	bsr	img_line	process one line
	add	d1,a1	next output addr
	dbra	d3,conv_img3	repeat for all lines
	clr	d0	no errors
conv_img1	movem.l	(sp)+,a0-a2/d3-d7
	rts

conv_img7	move	#1,d0	flag error
	bra	conv_img1	& exit

;Display one line of data
;ENTRY d1=width (bytes)
;      a0=source pointer
;      a1=destination pointer
;      d6=byte pattern length
;      (m_buffer) defined
;EXIT  a0=next source address

img_line	movem.l	d1/a1-a2,-(sp)
img_line1	tst.b	(a0)	bra if pattern run
	beq	img_line3
	cmp.b	#$80,(a0)	bra if bit string
	beq	img_line4

	tst.b	(a0)	d7=bit 7 (a0) 00 or FF
	smi.b	d7

img_line5	move.b	(a0)+,d0	set counter
	and	#$007f,d0
	sub	#1,d0
img_line6	move.b	d7,(a1)+	copy d7 to O/P
	tst	d1
	beq	img_line0
	sub	#1,d1
img_line0	dbra	d0,img_line6	repaet n times
img_line9	tst	d1
	bne	img_line1
	movem.l	(sp)+,d1/a1-a2
	rts
	
img_line4	add	#1,a0	bit string
	move.b	(a0)+,d0	set byte counter
	and	#$00ff,d0
	sub	#1,d0
img_line7	move.b	(a0)+,d7	copy data to O/P
	move.b	d7,(a1)+
	tst	d1
	beq	img_line2
	sub	#1,d1
img_line2	dbra	d0,img_line7	repeat n times
	bra	img_line9
	
img_line3	add	#1,a0	next byte  pattern run
	move.b	(a0)+,d0	set d0 to count
	and	#$00ff,d0
	sub	#1,d0
	move	d6,d5	fetch pattern length
	lea	m_buffer,a2
img_line14	move.b	(a0)+,(a2)+	copy pattern to buffer
	dbra	d5,img_line14
img_line8	move	d6,d5
	lea	m_buffer,a2
img_line15	move.b	(a2)+,(a1)+	copy buffer to O/P
	tst	d1
	beq	img_line16
	sub	#1,d1
img_line16	dbra	d5,img_line15	repeat 'pattern' times
	dbra	d0,img_line8
	bra	img_line9
	
m_buffer	ds.b	8
