PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb

max_x	equ	383
max_y	equ	240

	org	p:$0
	jmp	debut


	org	p:$40
debut
	move	#-1,m7
	move	#$200,r7	
	do	#4000,clip_une_face
wait2
	movep	#1,X:PBC	
	jclr	#0,x:HSR,wait2
	move	x:HTX,a1
	move	a1,x:(r7)+



clip_une_face
	move	#$200,r7
	move	#-1,m0
	move	#-1,m1
	move	#0,r1
	move	#1,r0
	move	#0,a


wait	
	movep	#1,X:PBC	
	jclr	#0,x:HSR,wait
	move	x:HTX,a1
	move	a1,x:(r1)+
	asl	a
	do	a1,fin_receive	
wait1	
	movep	#1,X:PBC	
	jclr	#0,x:HSR,wait1
	move	x:HTX,a1
	move	a1,x:(r1)+
fin_receive
	move	x:(r0)+,a1
	move	a1,x:(r1)+
	move	x:(r0)+,a1
	move	a1,x:(r1)+



	move	#1,n0
	move	#-1,m0
	move	#-1,m2

	move	#0,r0
	move	#0,r2
	move	#1,r1
	move	r0,y:(r2)

	move	x:(r0)+,x0

	do	x0,fin_clip_en_x

	move	#0,a
	move	x:(r0)+,x0	
	move	x:(r0)+,x1	
	cmp	x0,a
	jle	label1
	move	x:(r0),b	
	move	x:(r0+n0),y1	
	cmp	a,b
	jlt	label2
	jsr	intersection	
	jmp	label1bis
label1
	move	x0,y:(r1)+
	move	x1,y:(r1)+
	move	y:(r2),b1
	move	n0,y1
	add	y1,b
	move	b1,y:(r2)
	move	x:(r0),b	
	move	x:(r0+n0),y1	
	cmp	a,b
	jge	label2
	jsr	intersection	
label1bis
	move	r2,y:(r1)+
	move	a1,y:(r1)+
	move	y:(r2),a1
	move	n0,x0
	add	x0,a
	move	a1,y:(r2)
label2
	nop
fin_clip_en_x
;************************************************
	move	#1,r0
	move	r2,x:(r2)
	move	y:(r0)+,a1
	move	a1,y:(r1)+
	move	y:(r0)+,a1
	move	a1,y:(r1)+

	move	#0,r0
	move	#1,r1
	move	y:(r0)+,x0
	move	#0,a
	cmp	x0,a
	jeq	no_face
	do	x0,fin_clip_en_y

	move	#0,a
	move	y:(r0)+,x1	
	move	y:(r0)+,x0	
	cmp	x0,a
	jle	label3
	move	y:(r0),y1
	move	y:(r0+n0),b	
	cmp	a,b
	jlt	label4
	jsr	intersection	
	jmp	label3bis
label3
	move	x1,x:(r1)+
	move	x0,x:(r1)+
	move	x:(r2),b1
	move	n0,y1
	add	y1,b
	move	b1,x:(r2)
	move	y:(r0),y1	
	move	y:(r0+n0),b	
	cmp	a,b
	jge	label4
	jsr	intersection	
label3bis
	move	a1,x:(r1)+
	move	r2,x:(r1)+
	move	x:(r2),a1
	move	n0,x0
	add	x0,a
	move	a1,x:(r2)
label4
	nop
fin_clip_en_y

;************************************************
	move	#1,r0
	move	r2,y:(r2)
	move	x:(r0)+,a1
	move	a1,x:(r1)+
	move	x:(r0)+,a1
	move	a1,x:(r1)+

	move	#max_y,r6
	move	#0,r0
	move	#1,r1
	move	x:(r0)+,x0

	move	#0,a
	cmp	x0,a
	jeq	no_face
	do	x0,fin_clip_en_y1

	move	#0,a2
	move	#max_y,a1
	move	x:(r0)+,x1	
	move	x:(r0)+,x0	
	cmp	x0,a
	jge	label5
	move	x:(r0),y1
	move	x:(r0+n0),b	
	cmp	a,b
	jgt	label6
	jsr	intersection1	
	jmp	label5bis
label5
	move	x1,y:(r1)+
	move	x0,y:(r1)+
	move	y:(r2),b1
	move	n0,y1
	add	y1,b
	move	b1,y:(r2)
	move	x:(r0),y1	
	move	x:(r0+n0),b	
	cmp	a,b
	jle	label6
	jsr	intersection1	
label5bis
	move	a1,y:(r1)+
	move	r6,y:(r1)+
	move	y:(r2),a1
	move	n0,x0
	add	x0,a
	move	a1,y:(r2)
label6
	nop
fin_clip_en_y1
;************************************************

	move	#1,r0
	move	r2,x:(r2)
	move	y:(r0)+,a1
	move	a1,y:(r1)+
	move	y:(r0)+,a1
	move	a1,y:(r1)+

	move	#0,r0
	move	#1,r1
	move	y:(r0)+,x0
	move	#max_x,r6
	move	#0,a
	cmp	x0,a
	jeq	no_face

	do	x0,fin_clip_en_x1
	move	#0,a2
	move	#max_x,a1
	move	y:(r0)+,x0	
	move	y:(r0)+,x1	
	cmp	x0,a
	jge	label7
	move	y:(r0),b	
	move	y:(r0+n0),y1	
	cmp	a,b
	jgt	label8
	jsr	intersection1	
	jmp	label7bis
label7
	move	x0,x:(r1)+
	move	x1,x:(r1)+
	move	x:(r2),b1
	move	n0,y1
	add	y1,b
	move	b1,x:(r2)
	move	y:(r0),b	
	move	y:(r0+n0),y1	
	cmp	a,b
	jle	label8
	jsr	intersection1	
label7bis
	move	r6,x:(r1)+
	move	a1,x:(r1)+
	move	x:(r2),a1
	move	n0,x0
	add	x0,a
	move	a1,x:(r2)
label8
	nop
fin_clip_en_x1

	move	#0,r0
	move	#0,a
	move	x:(r0)+,x1


xmit	jclr	#1,X:HSR,xmit
	move	x1,X:HTX

	cmp	x1,a
	jeq	fin_envoie
	
	do	x1,fin_envoie

	move	x:(r0)+,x1
xmit1	jclr	#1,X:HSR,xmit1
	move	x1,X:HTX
	move	x:(r0)+,x1
xmit2	jclr	#1,X:HSR,xmit2
	move	x1,X:HTX


fin_envoie
	jmp	clip_une_face


no_face
	jclr	#1,X:HSR,no_face
	move	a1,X:HTX
	jmp	clip_une_face



intersection
	sub	x0,a	
	add	a,b	
	jpl	delta_positif0
	neg	b
	neg	a
delta_positif0
	move	a1,x0
	move	y1,a1
	sub	x1,a	
	move	a1,y0
	mpy	y0,x0,a	
	asr	a	b1,n7
	move	a0,y0
	move	x:(r7+n7),x0
	mpyr	y0,x0,a
	add	x1,a
	rts

intersection1
	sub	b,a	
	sub	x0,b
	jpl	delta_positif
	neg	b
	neg	a
delta_positif
	move	a1,x0
	move	y1,a1
	sub	x1,a	
	move	a1,y0
	mpy	y0,x0,a	
	asr	a	b1,n7
	move	a0,y0
	move	x:(r7+n7),x0
	mpyr	y0,x0,a
	add	y1,a
	rts



	org	x:0
	dc	4

	dc	308,192
	dc	281,253
	dc	381,276
	dc	384,210
	dc	308,192
	