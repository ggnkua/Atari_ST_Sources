;Instructions set
	org	p:$200
ABS:	abs	a
	nop
	abs	b
	nop
ADC:	adc	x,a
	nop
	adc	x,b
	nop
	adc	y,a
	nop
	adc	y,b
	nop
ADD:	add	b,a
	nop
	add	a,b
	nop
	add	x,a
	nop
	add	x,b
	nop
	add	y,a
	nop
	add	y,b
	nop
	add	x0,a
	nop
	add	x0,b
	nop
	add	y0,a
	nop
	add	y0,b
	nop
	add	x1,a
	nop
	add	x1,b
	nop
	add	y1,a
	nop
	add	y1,b
	nop
ADDL:	addl	b,a
	nop
	addl	a,b
	nop
ADDR:	addr	b,a
	nop
	addr	a,b
	nop
AND:	and	x0,a
	nop
	and	x1,a
	nop
	and	y0,a
	nop
	and	y1,a
	nop
	and	x0,b
	nop
	and	x1,b
	nop
	and	y0,b
	nop
	and	y1,b
	nop
ANDI:	andi	#$fe,mr
	nop
	andi	#$fe,ccr
	nop
	andi	#$fe,omr
	nop
ASL:	asl	a
	nop
	asl	b
	nop
ASR:	asr	a
	nop
	asr	b
	nop
BCHGea:	;#n,[XY]:ea
	bchg	#0,x:(r0)
	nop
	bchg	#0,y:(r0)
	nop
	bchg	#0,y:(r0+n0)
	nop
	bchg	#0,y:(r0)+
	nop
	bchg	#0,y:(r0)-
	nop
	bchg	#0,y:(r0)+n0
	nop
	bchg	#0,y:(r0)-n0
	nop
	bchg	#0,y:(r1)
	nop
	bchg	#0,y:(r2)
	nop
	bchg	#0,y:(r3)
	nop
	bchg	#0,y:(r4)
	nop
	bchg	#0,y:(r5)
	nop
	bchg	#0,y:(r6)
	nop
	bchg	#0,y:(r7)
	nop
	bchg	#0,y:>$dead
	nop
BCHGaa:	;#n,[XY]:aa
	bchg	#0,x:<$3a
	nop
	bchg	#0,y:<$3a
	nop
BCHGpp:	;#n,[XY]:pp
	bchg	#0,x:<<$fff0
	nop
	bchg	#0,y:<<$fff0
	nop
BCHGD:	;#n,D
	bchg	#0,x0
	nop
	bchg	#0,x1
	nop
	bchg	#0,y0
	nop
	bchg	#0,y1
	nop
	bchg	#0,a0
	nop
	bchg	#0,b0
	nop
	bchg	#0,a2
	nop
	bchg	#0,b2
	nop
	bchg	#0,a1
	nop
	bchg	#0,b1
	nop
	bchg	#0,a
	nop
	bchg	#0,b
	nop
	bchg	#0,sr
	nop
	bchg	#0,omr
	nop
	bchg	#0,sp
	nop
	bchg	#0,ssh
	nop
	bchg	#0,ssl
	nop
	bchg	#0,la
	nop
	bchg	#0,lc
	nop
	bchg	#0,r0
	nop
	bchg	#0,r1
	nop
	bchg	#0,r2
	nop
	bchg	#0,r3
	nop
	bchg	#0,r4
	nop
	bchg	#0,r5
	nop
	bchg	#0,r6
	nop
	bchg	#0,r7
	nop
	bchg	#0,n0
	nop
	bchg	#0,n1
	nop
	bchg	#0,n2
	nop
	bchg	#0,n3
	nop
	bchg	#0,n4
	nop
	bchg	#0,n5
	nop
	bchg	#0,n6
	nop
	bchg	#0,n7
	nop
	bchg	#0,m0
	nop
	bchg	#0,m1
	nop
	bchg	#0,m2
	nop
	bchg	#0,m3
	nop
	bchg	#0,m4
	nop
	bchg	#0,m5
	nop
	bchg	#0,m6
	nop
	bchg	#0,m7
	nop
BCLRea:	;#n,[XY]:ea
	bclr	#0,x:(r0)
	nop
	bclr	#0,y:(r0)
	nop
BCLRaa:	;#n,[XY]:aa
	bclr	#0,x:<$3a
	nop
	bclr	#0,y:<$3a
	nop
BCLRpp:	;#n,[XY]:pp
	bclr	#0,x:<<$fff0
	nop
	bclr	#0,y:<<$fff0
	nop
BCLRD:	;#n,D
	bclr	#0,x0
	nop
BSETea:	;#n,[XY]:ea
	bset	#0,x:(r0)+
	nop
	bset	#0,y:(r1)
	nop
	bset	#0,x:>$dead
	nop
BSETaa:	;#n,[XY]:aa
	bset	#0,x:<$33
	nop
	bset	#0,y:<$33
	nop
BSETpp:	;#n,[XY]:pp
	bset	#0,x:<<$fff0
	nop
	bset	#0,y:<<$fff0
	nop
BSETD:	;#n,D
	bset	#0,x0
	nop
BTSTea:	;#n,[XY]:ea
	btst	#0,x:(r0)
	nop
	btst	#0,y:(r0)+
	nop
	btst	#0,x:>$dead
	nop
BTSTaa:	;#n,[XY]:aa
	btst	#0,x:<$33
	nop
	btst	#0,y:<$33
	nop
BTSTpp:	;#n,[XY]:pp
	btst	#0,x:<<$fff0
	nop
	btst	#0,y:<<$fff0
	nop
BTSTD:	;#n,D
	btst	#0,x0
	nop
CLR:	;D
	clr	a
	nop
	clr	b
	nop
CMP:	;S1,S2
	cmp	b,a
	nop
	cmp	a,b
	nop
	cmp	x0,a
	nop
	cmp	x0,b
	nop
	cmp	y0,a
	nop
	cmp	y0,b
	nop
	cmp	x1,a
	nop
	cmp	x1,b
	nop
	cmp	y1,a
	nop
	cmp	y1,b
	nop
CMPM:	;S1,S2
	cmpm	b,a
	nop
	cmpm	a,b
	nop
	cmpm	x0,a
	nop
	cmpm	x0,b
	nop
	cmpm	y0,a
	nop
	cmpm	y0,b
	nop
	cmpm	x1,a
	nop
	cmpm	x1,b
	nop
	cmpm	y1,a
	nop
	cmpm	y1,b
	nop
DIV:	;S,D
	div	x0,a
	nop
	div	x0,b
	nop
	div	y0,a
	nop
	div	y0,b
	nop
	div	x1,a
	nop
	div	x1,b
	nop
	div	y1,a
	nop
	div	y1,b
	nop
DOea:	;[XY]:ea,expr
	do	x:(r0),fin_do0
	nop
fin_do0:
	nop
	do	y:(r0),fin_do1
	nop
fin_do1:
	nop
DOaa:	;[XY]:aa,expr
	do	x:<$33,fin_do2
	nop
fin_do2:
	nop
	do	y:<$33,fin_do3
	nop
fin_do3:
	nop
DOxxx:	;#xxx,expr
	do	#$dad,fin_do4
	nop
fin_do4:
	nop
DOS:	;S,expr
	do	x0,fin_do5
	nop
fin_do5:
	nop
	do	x1,fin_do6
	nop
fin_do6:
	nop
	do	y0,fin_do7
	nop
fin_do7:
	nop
	do	y1,fin_do8
	nop
fin_do8:
	nop
	do	a0,fin_do9
	nop
fin_do9:
	nop
	do	b0,fin_do10
	nop
fin_do10:
	nop
	do	a2,fin_do11
	nop
fin_do11:
	nop
	do	b2,fin_do12
	nop
fin_do12:
	nop
	do	a1,fin_do13
	nop
fin_do13:
	nop
	do	b1,fin_do14
	nop
fin_do14:
	nop
	do	a,fin_do15
	nop
fin_do15:
	nop
	do	b,fin_do16
	nop
fin_do16:
	nop
	do	sr,fin_do17
	nop
fin_do17:
	nop
	do	omr,fin_do18
	nop
fin_do18:
	nop
	do	sp,fin_do19
	nop
fin_do19:
	nop
	do	ssl,fin_do20
	nop
fin_do20:
	nop
	do	la,fin_do21
	nop
fin_do21:
	nop
	do	lc,fin_do22
	nop
fin_do22:
	nop
	do	r0,fin_do23
	nop
fin_do23:
	nop
	do	r1,fin_do24
	nop
fin_do24:
	nop
	do	r2,fin_do25
	nop
fin_do25:
	nop
	do	r3,fin_do26
	nop
fin_do26:
	nop
	do	r4,fin_do27
	nop
fin_do27:
	nop
	do	r5,fin_do28
	nop
fin_do28:
	nop
	do	r6,fin_do29
	nop
fin_do29:
	nop
	do	r7,fin_do30
	nop
fin_do30:
	nop
	do	n0,fin_do31
	nop
fin_do31:
	nop
	do	n1,fin_do32
	nop
fin_do32:
	nop
	do	n2,fin_do33
	nop
fin_do33:
	nop
	do	n3,fin_do34
	nop
fin_do34:
	nop
	do	n4,fin_do35
	nop
fin_do35:
	nop
	do	n5,fin_do36
	nop
fin_do36:
	nop
	do	n6,fin_do37
	nop
fin_do37:
	nop
	do	n7,fin_do38
	nop
fin_do38:
	nop
	do	m0,fin_do39
	nop
fin_do39:
	nop
	do	m1,fin_do40
	nop
fin_do40:
	nop
	do	m2,fin_do41
	nop
fin_do41:
	nop
	do	m3,fin_do42
	nop
fin_do42:
	nop
	do	m4,fin_do43
	nop
fin_do43:
	nop
	do	m5,fin_do44
	nop
fin_do44:
	nop
	do	m6,fin_do45
	nop
fin_do45:
	nop
	do	m7,fin_do46
	nop
ENDDO
	enddo
fin_do46:
	nop
;EOR	S,D
EOR:	eor	x0,a
	nop
	eor	x1,a
	nop
	eor	y0,a
	nop
	eor	y1,a
	nop
	eor	x0,b
	nop
	eor	x1,b
	nop
	eor	y0,b
	nop
	eor	y1,b
	nop
ILLEGAL:	illegal
	nop
;Jcc	xxx
Jccxx:	jcc	<$dad
	jge	<$dad
	jne	<$dad
	jpl	<$dad
	jnn	<$dad
	jec	<$dad
	jlc	<$dad
	jle	<$dad
	jcs	<$dad
	jlt	<$dad
	jeq	<$dad
	jmi	<$dad
	jnr	<$dad
	jes	<$dad
	jls	<$dad
	jle	<$dad
	nop
fin_jcc_x:
;Jcc	ea
Jccea:	jcc	(r0)+n0
	jge	(r0)+n0
	jne	(r0)+n0
	jpl	(r0)+n0
	jnn	(r0)+n0
	jec	(r0)+n0
	jlc	(r0)+n0
	jle	(r0)+n0
	jcs	(r0)+n0
	jlt	(r0)+n0
	jeq	(r0)+n0
	jmi	(r0)+n0
	jnr	(r0)+n0
	jes	(r0)+n0
	jls	(r0)+n0
	jle	(r0)+n0
	nop
;JCLR	#n,[XY]:ea,xxxx
JCLRea:	jclr	#0,x:(r0),fin_jclr_neax
	nop
fin_jclr_neax:
;JCLR:	#n,[XY]:aa,xxxx
JCLRaa:	jclr	#0,x:<$33,fin_jclr_naax
	nop
fin_jclr_naax:
;JCLR	#n,[XY]:pp,xxxx
JCLRpp:	jclr	#0,x:<<$fff1,fin_jclr_nppx
	nop
fin_jclr_nppx:
;JCLR:	#n,S,xxxx
JCLRS:	jclr	#0,x0,fin_jclr_nsx
	nop
fin_jclr_nsx:
;JMP	xxx
JMPxxx:	jmp	<$dad
	nop
;JMP	ea
JMPea:	jmp	(r0+n0)
	nop
;JScc	xxx
JSccxxx:	jscc	<$dad
	jscs	<$dad
	jsec	<$dad
	jseq	<$dad
	jses	<$dad
	jsge	<$dad
	jsgt	<$dad
	jslc	<$dad
	jsle	<$dad
	jsls	<$dad
	jslt	<$dad
	jsmi	<$dad
	jsne	<$dad
	jsnr	<$dad
	jspl	<$dad
	jsnn	<$dad
	nop
;JScc	ea
JSccea:	jscc	(r1)+
	jscs	(r1)+
	jsec	(r1)+
	jseq	(r1)+
	jses	(r1)+
	jsge	(r1)+
	jsgt	(r1)+
	jslc	(r1)+
	jsle	(r1)+
	jsls	(r1)+
	jslt	(r1)+
	jsmi	(r1)+
	jsne	(r1)+
	jsnr	(r1)+
	jspl	(r1)+
	jsnn	(r1)+
	nop
;JSCLRea	#n,[XY]:ea,xxxx
JSCLRea:	jsclr	#0,x:(r0),routine
	nop
JSCLRaa:	;#n,[XY]:aa,xxxx
	jsclr	#0,x:<$33,routine
	nop
JSCLRpp:	;#n,[XY]:pp,xxxx
	jsclr	#0,x:<<$fff1,routine
	nop
JSCLRS:	;#n,S,xxxx
	jsclr	#0,x0,routine
	nop
JSETea:	;#n,[XY]:ea,xxxx
	jset	#0,x:(r0),fin_jset_nxyeax
	nop
fin_jset_nxyeax:
JSETaa:	;#n,[XY]:aa,xxxx
	jset	#0,x:<$33,fin_jset_nxyaax
	nop
fin_jset_nxyaax:
JSETpp:	;#n,[XY]:pp,xxxx
	jset	#0,x:<<$fff1,fin_jset_nxyppx
	nop
fin_jset_nxyppx:
JSETS:	;#n,S,xxxx
	jset	#0,x0,fin_jset_nsx
	nop
fin_jset_nsx:
JSRxxx:	;xxx
	jsr	<$dad
	nop
JSRea:	;ea
	jsr	(r0)-
	nop
	jsr	routine
	nop
JSSETea:	;#n,[XY]:ea,xxxx
	jsset	#0,x:(r5)+,routine
	nop
JSSETaa:	;#n,[XY]:aa,xxxx
	jsset	#0,x:<$33,routine
	nop
JSSETpp:	;#n,[XY]:pp,xxxx
	jsset	#0,x:<<$fff1,routine
	nop
JSSETS:	;#n,S,xxxx
	jsset	#0,x0,routine
	nop
LSL:	;D
	lsl	a
	nop
	lsl	b
	nop
LSR:	;D
	lsr	a
	nop
	lsr	b
	nop
LUA:	;ea,D
	lua	(r0)-n0,n0
	nop
	lua	(r0)+n0,n0
	nop
	lua	(r0)-,n0
	nop
	lua	(r0)+,n0
	nop
	lua	(r1)-n1,n0
	nop
	lua	(r1)+n1,n0
	nop
	lua	(r1)-,n0
	nop
	lua	(r1)+,n0
	nop
	lua	(r2)-n2,n0
	nop
	lua	(r2)+n2,n0
	nop
	lua	(r2)-,n0
	nop
	lua	(r2)+,n0
	nop
	lua	(r3)-n3,n0
	nop
	lua	(r3)+n3,n0
	nop
	lua	(r3)-,n0
	nop
	lua	(r3)+,n0
	nop
	lua	(r4)-n4,n0
	nop
	lua	(r4)+n4,n0
	nop
	lua	(r4)-,n0
	nop
	lua	(r4)+,n0
	nop
	lua	(r5)-n5,n0
	nop
	lua	(r5)+n5,n0
	nop
	lua	(r5)-,n0
	nop
	lua	(r5)+,n0
	nop
	lua	(r6)-n6,n0
	nop
	lua	(r6)+n6,n0
	nop
	lua	(r6)-,n0
	nop
	lua	(r6)+,n0
	nop
	lua	(r7)-n7,n0
	nop
	lua	(r7)+n7,n0
	nop
	lua	(r7)-,n0
	nop
	lua	(r7)+,n0
	nop
	lua	(r0)+,n1
	nop
	lua	(r0)+,n2
	nop
	lua	(r0)+,n3
	nop
	lua	(r0)+,n4
	nop
	lua	(r0)+,n5
	nop
	lua	(r0)+,n6
	nop
	lua	(r0)+,n7
	nop
MAC:	;(+-)S1,S2,D
	mac	-x0,x0,a
	nop
	mac	-y0,y0,a
	nop
	mac	-x1,x0,a
	nop
	mac	-y1,y0,a
	nop
	mac	-x0,y1,a
	nop
	mac	-y0,x0,a
	nop
	mac	-x1,y0,a
	nop
	mac	-y1,x1,a
	nop
	mac	-x0,x0,b
	nop
	mac	x0,x0,b
	nop
MACR:	;(+-)S1,S2,D
	macr	-x0,x0,a
	nop
	macr	-y0,y0,a
	nop
	macr	-x1,x0,a
	nop
	macr	-y1,y0,a
	nop
	macr	-x0,y1,a
	nop
	macr	-y0,x0,a
	nop
	macr	-x1,y0,a
	nop
	macr	-y1,x1,a
	nop
	macr	-x0,x0,b
	nop
	macr	x0,x0,b
	nop
MOVExxD:	;#xx,D
	move	#<0,x0
	nop
	move	#<0,x1
	nop
	move	#<0,y0
	nop
	move	#<0,y1
	nop
	move	#<0,a0
	nop
	move	#<0,b0
	nop
	move	#<0,a2
	nop
	move	#<0,b2
	nop
	move	#<0,a1
	nop
	move	#<0,b1
	nop
	move	#<0,a
	nop
	move	#<0,b
	nop
	move	#<0,r0
	nop
	move	#<0,r1
	nop
	move	#<0,r2
	nop
	move	#<0,r3
	nop
	move	#<0,r4
	nop
	move	#<0,r5
	nop
	move	#<0,r6
	nop
	move	#<0,r7
	nop
	move	#<0,n0
	nop
	move	#<0,n1
	nop
	move	#<0,n2
	nop
	move	#<0,n3
	nop
	move	#<0,n4
	nop
	move	#<0,n5
	nop
	move	#<0,n6
	nop
	move	#<0,n7
	nop
MOVESD:	;S,D
	move	x0,r0
	nop
MOVEea:	;ea
	move	(r0)-n0
	nop
	move	(r0)+n0
	nop
	move	(r0)-
	nop
	move	(r0)+
	nop
MOVEeaD:	;X:ea,D MOVE S,X:ea MOVE #xxxxxx,D
	move	x:(r0)-n0,x0
	nop
	move	x:(r0)-n0,x1
	nop
	move	x:(r0)-n0,y0
	nop
	move	x:(r0)-n0,y1
	nop
	move	x:(r0)-n0,a0
	nop
	move	x:(r0)-n0,b0
	nop
	move	x:(r0)-n0,a2
	nop
	move	x:(r0)-n0,b2
	nop
	move	x:(r0)-n0,a1
	nop
	move	x:(r0)-n0,b1
	nop
	move	x:(r0)-n0,a
	nop
	move	x:(r0)-n0,b
	nop
	move	x:(r1)-n1,r0
	nop
	move	x:(r0)-n0,r1
	nop
	move	x:(r0)-n0,r2
	nop
	move	x:(r0)-n0,r3
	nop
	move	x:(r0)-n0,r4
	nop
	move	x:(r0)-n0,r5
	nop
	move	x:(r0)-n0,r6
	nop
	move	x:(r0)-n0,r7
	nop
	move	x:(r0)-n0,n0
	nop
	move	x:(r0)-n0,n1
	nop
	move	x:(r0)-n0,n2
	nop
	move	x:(r0)-n0,n3
	nop
	move	x:(r0)-n0,n4
	nop
	move	x:(r0)-n0,n5
	nop
	move	x:(r0)-n0,n6
	nop
	move	x:(r0)-n0,n7
	nop
	move	#>$bafbaf,x0
	nop
	move	x0,x:(r0)+
	nop
MOVEXaa:	;X:aa,D MOVE S,X:aa
	move	x:<$33,x0
	nop
	move	x0,X:<$33
	nop
MOVEeaD2:	;X:ea,D1 S2,D2 MOVE S1,X:ea S2,D2 MOVE #xxxxxx,D1 S2,D2
	move	x:(r0)-,x0	a,y0
	nop
	move	x:(r0)-,x1	a,y0
	nop
	move	x:(r0)-,a	a,y0
	nop
	move	x:(r0)-,b	a,y0
	nop
	move	x:(r0)-,b	b,y0
	nop
	move	x:(r0)-,b	a,y1
	nop
	move	x:(r0)-,b	b,y1
	nop
	move	#>$bafbaf,x0	a,y0
	nop
MOVEAea:	;A,X:ea X0,A MOVE B,X:ea X0,B
	move	a,x:(r0)+	x0,a
	nop
	move	b,x:(r0)-	x0,b
	nop
MOVESea:	;Y:ea,D MOVE S,Y:ea MOVE #xxxxxx,D
	move	y:(r0)-n0,x0
	nop
	move	y:(r0)-n0,x1
	nop
	move	y:(r0)-n0,y0
	nop
	move	y:(r0)-n0,y1
	nop
	move	y:(r0)-n0,a0
	nop
	move	y:(r0)-n0,b0
	nop
	move	y:(r0)-n0,a2
	nop
	move	y:(r0)-n0,b2
	nop
	move	y:(r0)-n0,a1
	nop
	move	y:(r0)-n0,b1
	nop
	move	y:(r0)-n0,a
	nop
	move	y:(r0)-n0,b
	nop
	move	y:(r1)-n1,r0
	nop
	move	y:(r0)-n0,r1
	nop
	move	y:(r0)-n0,r2
	nop
	move	y:(r0)-n0,r3
	nop
	move	y:(r0)-n0,r4
	nop
	move	y:(r0)-n0,r5
	nop
	move	y:(r0)-n0,r6
	nop
	move	y:(r0)-n0,r7
	nop
	move	y:(r0)-n0,n0
	nop
	move	y:(r0)-n0,n1
	nop
	move	y:(r0)-n0,n2
	nop
	move	y:(r0)-n0,n3
	nop
	move	y:(r0)-n0,n4
	nop
	move	y:(r0)-n0,n5
	nop
	move	y:(r0)-n0,n6
	nop
	move	y:(r0)-n0,n7
	nop
	move	#>$bafbaf,x0
	nop
	move	x0,y:(r0)+
	nop
MOVEYaa:	;Y:aa,D MOVE S,Y:aa
	move	y:<$33,x0
	nop
	move	x0,y:<$33
	nop
MOVESD1:	;S1,D1 Y:ea,D2 MOVE S1,D1 S2,Y:ea MOVE S1,D1 #xxxxxx,D2
	move	a,x0	y:(r0),y0
	nop
	move	a,x1	y:(r0),y1
	nop
	move	b,x0	y:(r0),a
	nop
	move	b,x1	y:(r0),b
	nop
	move	a,x0	y0,y:(r0)+
	nop
	move	a,x1	y1,y:(r0)-
	nop
	move	b,x0	a,y:(r0)
	nop
	move	b,x1	b,y:(r0)-n0
	nop
	move	a,x0	#>$33dead,y0
	nop
MOVEY0A:	;Y0,A A,Y:ea MOVE Y0,B B,Y:ea
	move	y0,a	a,y:(r0)-
	nop
	move	y0,b	b,y:(r1)+
	nop
MOVELea:	;L:ea,D MOVE S,L:ea
	move	l:(r0)+,a10
	nop
	move	l:(r0)+,b10
	nop
	move	l:(r0)+,x
	nop
	move	l:(r0)+,y
	nop
	move	l:(r0)+,a
	nop
	move	l:(r0)+,b
	nop
	move	l:(r0)+,ab
	nop
	move	l:(r0)+,ba
	nop
	move	a10,l:(r7)-
	nop
MOVELaa:	;L:aa,D MOVE D,L:aa
	move	l:<$33,a10
	nop
	move	l:<$33,b10
	nop
	move	l:<$33,x
	nop
	move	l:<$33,y
	nop
	move	l:<$33,a
	nop
	move	l:<$33,b
	nop
	move	l:<$33,ab
	nop
	move	l:<$33,ba
	nop
	move	a10,l:<$33
	nop
MOVEXYeax:	;X:<eax>,D1 Y:<eay>,D2
	move	x:(r0)+n0,x0	y:(r4)+n4,y0
	nop
	move	x:(r0)+n0,x1	y:(r4)+n4,y0
	nop
	move	x:(r0)+n0,a	y:(r4)+n4,y0
	nop
	move	x:(r0)+n0,b	y:(r4)+n4,y0
	nop
	move	x:(r0)+n0,x0	y:(r4)+n4,y1
	nop
	move	x:(r0)+n0,x0	y:(r4)+n4,a
	nop
	move	x:(r0)+n0,x0	y:(r4)+n4,b
	nop
MOVEXeaxY:	;X:<eax>,D1 S2,Y:<eay>
	move	x:(r0)+n0,x0	y0,y:(r4)+n4
	nop
MOVEeaxXY:	;S1,X:<eax> Y:<eay>,D2
	move	x0,x:(r0)+n0	y:(r4)+n4,y0
	nop
MOVESSeax:	;S1,X:<eax> S2,Y:<eay>
	move	x0,x:(r0)+n0	y0,y:(r4)+n4
	nop
	move	x0,x:(r0)-	y0,y:(r4)+n4
	nop
	move	x0,x:(r0)+	y0,y:(r4)+n4
	nop
	move	x0,x:(r0)	y0,y:(r4)+n4
	nop
MOVECeaD:	;X:ea,D1
	movec	x:(r2)+,m0
	nop
	movec	x:(r2)+,m1
	nop
	movec	x:(r2)+,m2
	nop
	movec	x:(r2)+,m3
	nop
	movec	x:(r2)+,m4
	nop
	movec	x:(r2)+,m5
	nop
	movec	x:(r2)+,m6
	nop
	movec	x:(r2)+,m7
	nop
	movec	x:(r2)+,sr
	nop
	movec	x:(r2)+,omr
	nop
	movec	x:(r2)+,sp
	nop
	movec	x:(r2)+,ssh
	nop
	movec	x:(r2)+,ssl
	nop
	movec	x:(r2)+,la
	nop
	movec	x:(r2)+,lc
	nop
MOVECSea:	;S1,X:ea
	movec	m0,x:(r7)+
	nop
MOVECYeaD:	;Y:ea,D1
	movec	y:(r3),m0
	nop
MOVECSYea:	;S1,Y:ea
	movec	m0,y:(r2)-
	nop
MOVECxxxD:	;#xxxx,D1
	movec	#>$3baf,m0
	nop
MOVECXaaD:	;X:aa,D1
	movec	x:<$33,m0
	nop
MOVECSXaa:	;S1,X:aa
	movec	m0,x:<$33
	nop
MOVECYaaD:	;Y:aa,D1
	movec	y:<$33,m0
	nop
MOVECSYaa:	;S1,Y:aa
	movec	m0,y:<$33
	nop
MOVECSD:	;S1,D2 MOVEC S2,D1
	movec	m0,x0
	nop
	movec	m0,x1
	nop
	movec	m0,y0
	nop
	movec	m0,y1
	nop
	movec	m0,a0
	nop
	movec	m0,b0
	nop
	movec	m0,a2
	nop
	movec	m0,b2
	nop
	movec	m0,a1
	nop
	movec	m0,b1
	nop
	movec	m0,a
	nop
	movec	m0,b
	nop
	movec	m0,sr
	nop
	movec	m0,omr
	nop
	movec	m0,sp
	nop
	movec	m0,ssh
	nop
	movec	m0,ssl
	nop
	movec	m0,la
	nop
	movec	m0,lc
	nop
	movec	m0,r0
	nop
	movec	m0,r1
	nop
	movec	m0,r2
	nop
	movec	m0,r3
	nop
	movec	m0,r4
	nop
	movec	m0,r5
	nop
	movec	m0,r6
	nop
	movec	m0,r7
	nop
	movec	m0,n0
	nop
	movec	m0,n1
	nop
	movec	m0,n2
	nop
	movec	m0,n3
	nop
	movec	m0,n4
	nop
	movec	m0,n5
	nop
	movec	m0,n6
	nop
	movec	m0,n7
	nop
	movec	m1,m0
	nop
	movec	m0,m1
	nop
	movec	m0,m2
	nop
	movec	m0,m3
	nop
	movec	m0,m4
	nop
	movec	m0,m5
	nop
	movec	m0,m6
	nop
	movec	m0,m7
	nop
	movec	x0,m0
	nop
MOVECxxD:	;#xx,D1
	movec	#<$33,m0
	nop
MOVEMPea:	;S,P:ea MOVE P:ea,D
	movem	x0,p:(r0)+
	nop
	movem	x0,p:>$dead
	nop
	movem	p:(r0)+,x0
	nop
MOVEMPaa:	;S,P:aa MOVEM P:aa,D
	movem	x0,p:<$33
	nop
	movem	p:<$33,x0
	nop
MOVEPPeaXpp:	;P:ea,X:pp
	movep	p:(r0),x:<<$fff0
	nop
MOVEPXppPea:	;X:pp,P:ea
	movep	x:<<$fff0,p:(r1)
	nop
MOVEPPeaYpp:	;P:ea,Y:pp
	movep	p:(r5),y:<<$fff1
	nop
MOVEPYppPea:	;Y:pp,P:ea
	movep	y:<<$fff1,p:(r6)
	nop
MOVEPSXpp:	;S,X:pp
	movep	x0,x:<<$fff1
	nop
MOVEPXppD:	;X:pp,D
	movep	x:<<$fff1,x0
	nop
MOVEPSYpp:	;S,Y:pp
	movep	x0,y:<<$fff4
	nop
MOVEPYppD:	;Y:pp,D
	movep	y:<<$fff4,x0
	nop
MPY	;(+-)S1,S2,D
	mpy	-x0,x0,a
	nop
	mpy	-y0,y0,a
	nop
	mpy	-x1,x0,a
	nop
	mpy	-y1,y0,a
	nop
	mpy	-x0,y1,a
	nop
	mpy	-y0,x0,a
	nop
	mpy	-x1,y0,a
	nop
	mpy	-y1,x1,a
	nop
	mpy	-y1,x1,b
	nop
	mpy	x0,x0,a
	nop
	mpy	y0,y0,a
	nop
	mpy	x1,x0,a
	nop
	mpy	y1,y0,a
	nop
	mpy	x0,y1,a
	nop
	mpy	y0,x0,a
	nop
	mpy	x1,y0,a
	nop
	mpy	y1,x1,a
	nop
	mpy	y1,x1,b
	nop
MPYR:	;(+-)S1,S2,D
	mpyr	x0,x0,a
	nop
NEG:	;D
	neg	a
	nop
	neg	b
	nop
NOP
	nop
NORM:	;Rn,D
	norm	r0,a
	nop
	norm	r1,a
	nop
	norm	r2,a
	nop
	norm	r3,a
	nop
	norm	r4,a
	nop
	norm	r5,a
	nop
	norm	r6,a
	nop
	norm	r7,a
	nop
	norm	r0,b
	nop
	norm	r1,b
	nop
	norm	r2,b
	nop
	norm	r3,b
	nop
	norm	r4,b
	nop
	norm	r5,b
	nop
	norm	r6,b
	nop
	norm	r7,b
	nop
NOT:	;D
	not	a
	nop
	not	b
	nop
OR:	;S,D
	or	x0,a
	nop
	or	x1,a
	nop
	or	y0,a
	nop
	or	y1,a
	nop
	or	y1,b
	nop
ORI:	;#xx,D
	ori	#<0,mr
	nop
	ori	#<0,ccr
	nop
	ori	#<0,omr
	nop
REPea:	;X:ea REP Y:ea
	rep	x:(r0)
	nop
	rep	y:(r0)
	nop
REPaa:	;X:aa REP Y:aa
	rep	x:<$33
	nop
	rep	y:<$33
	nop
REPS:	;S
	rep	x0
	nop
RESET
	reset
RND:	;D
	rnd	a
	nop
	rnd	b
	nop
ROL:	;D
	rol	a
	nop
	rol	b
	nop
ROR:	;D
	ror	a
	nop
	ror	b
	nop
RTI
	rti
	nop
RTS
	rts
	nop
SBC:	;S,D
	sbc	x,a
	nop
	sbc	x,b
	nop
	sbc	y,a
	nop
	sbc	y,b
	nop
STOP
	stop
	nop
SUB:	;S,D
	sub	b,a
	nop
	sub	a,b
	nop
	sub	x,a
	nop
	sub	x,b
	nop
	sub	y,a
	nop
	sub	y,b
	nop
	sub	x0,a
	nop
	sub	x0,b
	nop
	sub	y0,a
	nop
	sub	y0,b
	nop
	sub	x1,a
	nop
	sub	x1,b
	nop
	sub	y1,a
	nop
	sub	y1,b
	nop
SUBL:	;S,D
	sub	b,a
	nop
	sub	a,b
	nop
SUBR:	;S,D
	subr	b,a
	nop
	subr	a,b
	nop
SWI
	swi
	nop
TccSD:	;S1,D1
	tcc	b,a
	nop
	tcc	a,b
	nop
	tcc	x0,a
	nop
	tcc	x0,b
	nop
	tcc	y0,a
	nop
	tcc	y0,b
	nop
	tcc	x1,a
	nop
	tcc	x1,b
	nop
	tcc	y1,a
	nop
	tcc	y1,b
	nop
TccSDSD:	;S1,D1 S2,D2
	tcc	b,a	r7,r0
	nop
	tcc	a,b	r0,r1
	nop
	tcc	x0,a	r0,r6
	nop
	tcc	x0,b	r0,r7
	nop
	tcc	y0,a	r1,r0
	nop
	tcc	y0,b	r2,r0
	nop
	tcc	x1,a	r3,r0
	nop
	tcc	x1,b	r4,r0
	nop
	tcc	y1,a	r5,r0
	nop
	tcc	y1,b	r6,r0
	nop
TFRSD:	;S,D
	tfr	b,a
	nop
	tfr	a,b
	nop
	tfr	x0,a
	nop
	tfr	x0,b
	nop
	tfr	y0,a
	nop
	tfr	y0,b
	nop
	tfr	x1,a
	nop
	tfr	x1,b
	nop
	tfr	y1,a
	nop
	tfr	y1,b
	nop
TSTS:	;S
	tst	a
	nop
	tst	b
	nop
WAIT
	wait
routine:
	nop
	rts



	nop
	nop
	nop
	nop

