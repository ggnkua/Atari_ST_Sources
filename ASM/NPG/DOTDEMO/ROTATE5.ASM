;Source by Roland Spatzenegger
;Freeware
PBC	equ	$ffe0
HSR	equ	$ffe9
HTRX	equ	$ffeb
;achtung Transfer: z|y|x
;winkel: x|y|z
;	
	org	p:$0	
	jmp	main
	org	p:$40
main:
	movep	#$000001,x:PBC
	bset	#2,omr			;ROM-SINTABLE einblenden
	move	#-1,M0
	move	#-1,M1
	move	M0,M4
	move	M0,M5
	move	M0,M6		;init mx
	jsr	make_div_tab
	jsr	get_start_koors
forever:
	jsr	read_data	;get rotation angles and translation vectors
	move	x1,x:alpha
	jsr	read_data
	move	x1,x:beta
	jsr	read_data
	move	x1,x:gamma
	jsr	read_data
	move	x1,y:xt
	jsr	read_data
	move	x1,y:yt
	jsr	read_data
	move	x1,y:zt

	jsr	get_next
	jsr	make_master		;make master_matrix
	
	move	#>koors,r7
	do	#28*64,mega_loop
	move	#>vector+3,r0
	jsr	make_trans
	move	#>vector+3,r4
	move	#>cbuffer,r0
	move	#>rot_vec,r2
	jsr	vec_mult
	move	#>rot_vec+2,r0
	jsr	project
	jsr	send_data
mega_loop
	move	x:trans_c,a
	move	#>1,x0
	add	x0,a
	move	a1,x:trans_c
	jmp	forever
;************************************************************************
;copy 16 word from x:r0,y:r4->y:r5,x:r1
copy_44:
	do	#16,do_copy
	move	x:(r0)+,a y:(r4)+,b
	move	b,x:(r1)+ a,y:(r5)+
do_copy
	nop
	rts
;************************************************************************
N	equ	4
rotate44:
	move	#bbuffer,R5
	move	#cbuffer,R6
	move	#N,N0	
	move	#N,N5
	do	#N,iloop
	move	#abuffer,R1	
	do	#N,jloop
	move	R5,R4		
	clr	a		R1,R0
	do	#N,kloop
	move	X:(R0)+N0,X0	Y:(R4)+,Y0
	mac	x0,y0,A
kloop
	move	(R1)+
; Now store A in two DSP words
	move	a1,Y:(R6)+		
jloop
	lua	(R5)+N5,R5
iloop
	nop
	rts
;************************************************************************
send_data:
	jclr	#1,x:HSR,send_data	;send data
	movep	x1,x:HTRX	
	rts
read_data:
	jclr	#0,x:HSR,read_data	;read data
	movep	x:HTRX,x1
	rts

;************************************************************************
make_winkel:
	move	#$ff,m1		;Modifier (ring)
	move	#>$100,r1	

	move	X:alpha,n1	
	nop
	move	y:(r1+n1),a		;y0=sin
	move	a,x:xrot+9
	neg	a
	move	a,x:xrot+6
	move	(r1)+n1
	move	#>$40,n1
	nop
	move	y:(r1+n1),a		;y1=cos
	move	a,x:xrot+5
	move	a,x:xrot+10

	move	#>$100,r1	
	move	X:beta,n1	
	nop
	move	y:(r1+n1),a		;y0=sin
	move	a,x:yrot+2
	neg	a
	move	a,x:yrot+8
	move	(r1)+n1
	move	#>$40,n1
	nop
	move	y:(r1+n1),a		;y1=cos
	move	a,x:yrot
	move	a,x:yrot+10	
	
	move	#>$100,r1	
	move	X:gamma,n1	
	nop
	move	y:(r1+n1),a		;y0=sin
	move	a,y:zrot+4
	neg	a
	move	a,y:zrot+1
	move	(r1)+n1
	move	#>$40,n1
	nop
	move	y:(r1+n1),a		;y1=cos
	move	a,y:zrot
	move	a,y:zrot+5
	
	move	y:xt,x0
	move	x0,x:translate+3
	move	y:yt,x0
	move	x0,x:translate+7
	move	y:zt,x0
	move	x0,x:translate+11
	move	#>$ffff,m1		;Modifier (ring)
	rts
;************************************************************************
;x:r0-> dest Koordinaten adr+3
;x:r7-> src Koordinaten adr
make_trans:
	move	#>$8000,y0
	move	x:trans_c,x0
	move	x:(r7)+,x1	;get add
	do	#3,trans_loop
	mpy	x0,x1,a
	asr	a
	move	a0,x1
	mpy	x1,y0,a	 x:(r7)+,x1		;shift>>8	;get koor
	add	x1,a	x:(r7)+,x1	;get next add
	move	a1,x:(r0)-
trans_loop:
	move	(r7)-
	rts
;************************************************************************
;y:r0=matrix
;x:r4=vektorende(letzte koordinate
;x:r2=dest
vec_mult:
	move	#>3,n4		;save vektor
;make x koor
	move	x:(r4)-,x0
	move	y:(r0)+,y0
	mpy	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)+n4,x0 y:(r0)+,y0 
	mac	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	move	a1,x:(r2)+
	mpy	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)+n4,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	move	a1,x:(r2)+
	mpy	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)-,x0 y:(r0)+,y0
	mac	x0,y0,a	x:(r4)+n4,x0 y:(r0)+,y0 
	mac	x0,y0,a	
	move	a1,x:(r2)+
	rts
;************************************************************************
;zproj :->x:r0=point
;	<-x1 Adresse
AUGE	equ	400/2
project:
	move	#>0,y0
	move	#>div_tab,r1
	move	#>AUGE,y1
	move	x:(r0)-,a		;z
	add	y1,a	x:(r0)-,x1	;z+a->n1
	move	a1,n1		
	mpy	y1,x1,b	x:(r0)-,x0	;b=y*auge
	mpy	y1,x0,a	y:(r1+n1),x0	;a=x*auge
	
	move	a0,y1		
	mpy	x0,y1,a		;x/z=a
	move	#>160,x1
	add	x1,a
	tmi	y0,a
	tmi	y0,b
	
	move	#>320,x1
	cmp	x1,a
	tge	y0,a
	tge	y0,b
	
	move	y:(r1+n1),x0
	move	b0,y1
	mpy	x0,y1,b		;y/z=b
	
	move	#>100,x1
	add	x1,b
	tmi	y0,a
	tmi	y0,b

	move	#>200,x1
	cmp	x1,b
	tge	y0,a
	tge	y0,b

	move	b1,x0
	move	#>320,x1
	mpy	x0,x1,b
	move	a,a0
	asl	a
	add	a,b
	move	b0,x1
	rts
;************************************************************
get_start_koors:
	move	#>koors_dest,r0
	move	#>28*64,x1
	move	x1,x:anz_stars
	move	#28*64*6,x0
	do	x0,get_kloop
	jsr	read_data
	move	x1,y:(r0)+
	nop
get_kloop:
	rts
;************************************************************************
;->a/x0
;<-x1
;need: a,b,x0,x1
full_div
	ABS A	A,B				;make dividend positive, copy A1 to B1
	EOR	X0,B				;save rem. sign in X:$0, quo. sign in N
	AND	#$FE,CCR			;clear carry bit C (quotient sign bit)
	REP	#$18				;form a 24-bit quotient
	DIV	X0,A				;form quotient in A0, remainder in A1
	TFR	A,B					;save quotient and remainder in B1,B0
	JPL	SAVEQUO				;go to SAVEQUO if quotient is positive
	NEG	B					;complement quotient if N bit set
SAVEQUO
	TFR	X0,B	B0,X1		;save quo. in X1, get signed divisor
	rts
;************************************************************************
make_div_tab:
	move	#div_tab+1,r0
	move	#>1,r1
	do	#1024*2-1,div_loop
	move	#>1,y1
	move	y1,a
	move	r1,x0
	jsr	full_div
	move	x1,y:(r0)+
	move	(r1)+
div_loop:
	rts
;************************************************************************
;make master matrix
make_master:	
	jsr	make_winkel
	
	move	#zrot,r4
	move	#yrot,r0
	move	#abuffer,r1
	move	#bbuffer,r5
	jsr	copy_44
	jsr	rotate44
	
	move	#cbuffer,r4
	move	#xrot,r0
	move	#abuffer,r1
	move	#bbuffer,r5
	jsr	copy_44
	jsr	rotate44

	move	#cbuffer,r4
	move	#translate,r0
	move	#abuffer,r1
	move	#bbuffer,r5
	jsr	copy_44
	jsr	rotate44	;endgueltige matrix in cbuffer
	rts

;************************************************************************
get_next:
	move	x:trans_c,a
	move	#>$3f,x0
	and	x0,a
	move	a,x1
	move	x1,x:trans_c
	jne	no_transfer
	move	#>koors,r0
	move	#>koors_dest,r4
	move	x:anz_stars,y0
	do	y0,trans_koors
	move	y:(r4)+,b 
	move	b,x:(r0)+	y:(r4)+,a 
	move	a,x:(r0)+	y:(r4)+,b 
	move	b,x:(r0)+	y:(r4)+,a 
	move	a,x:(r0)+	y:(r4)+,b 
	move	b,x:(r0)+	y:(r4)+,a 
	move	a,x:(r0)+
trans_koors:
no_transfer:
	move	#>14*6,x0
	move	#>koors_dest,y0
	move	y0,a0
	mac	x1,x0,a
	move	a0,r0
	do	#28*6,get_new_stars
	jsr	read_data
	move	x1,y:(r0)+
get_new_stars:
	rts
;************************************************************************
cos	equ	0
sin	equ	0
one	equ	$7fffff
	org	x:$0
anz_stars:	dc	0
xrot:	dc	one,000,000,000
	dc	000,cos,-sin,000
	dc	000,sin,cos,000
	dc	000,000,000,one
translate:
	dc	$7fffff,0,0,1
	dc	0,$7fffff,0,1
	dc	0,0,$7fffff,1
	dc	0,0,0,$7fffff
yrot:	dc	cos,000,sin,000
	dc	000,one,000,000
	dc	-sin,000,cos,000
	dc	000,000,000,one

ergrot:		dc	0,0,0,0
		dc	0,0,0,0
		dc	0,0,0,0
		dc	0,0,0,0
abuffer:	dc	0,0,0,0
		dc	0,0,0,0
		dc	0,0,0,0
		dc	0,0,0,0
alpha:	dc	0
beta:	dc	0
gamma:	dc	0
trans_c:	dc	63
vector:	dc	$7fffff,$d0,$d0,$d0
rot_vec:	dc	0,0,0,0
;************************************************************************

	org	y:$0
zrot:	dc	cos,-sin,000,000
	dc	sin,cos,000,000
	dc	000,000,one,000
	dc	000,000,000,one

bbuffer:	dc	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
cbuffer:	dc	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
xt:	dc	1
yt:	dc	2
zt:	dc	3

SAVE:	dc	0
	org	x:$400
koors:	dc	0	;2048*6 Werte !
	org	y:$400
div_tab:	dc	0		;1024*2 werte 
	org	y:$400+1024*2
koors_dest:	dc	0	;2048*6 Werte !
