X1Y4_X1Y2	equ	$01b7
INBuffer	equ	$0000
OUTBuffer	equ	$0020
QuantMatrix1	equ	$0040
QuantMatrix2	equ	$0060
QuantMatrix3	equ	$0080
QuantMatrix4	equ	$00a0
ExpBuffer1	equ	$1000
ExpBuffer2	equ	$1200
ExpBuffer3	equ	$1400
ExpBuffer4	equ	$1600
OutputBuffer	equ	$1800
RangeTable1	equ	$2000
Range1Ptr	equ	$2100
RangeTable2	equ	$2200
Range2Ptr	equ	$2300
RangeTable3	equ	$2400
Range3Ptr	equ	$2500
RangeTable4	equ	$2600
Range4Ptr	equ	$2700
x_ffe8	equ	$ffe8
x_ffff	equ	$ffff
x_ffe0	equ	$ffe0
x_fffe	equ	$fffe
x_ffe9	equ	$ffe9
x_ffeb	equ	$ffeb
p_005a	equ	$005a
p_0062	equ	$0062
p_0075	equ	$0075
p_007f	equ	$007f
p_0082	equ	$0082
x_ffd6	equ	$ffd6
p_001f	equ	$001f
p_0003	equ	$0003
p_000f	equ	$000f
p_024a	equ	$024a
p_024e	equ	$024e
p_0267	equ	$0267
p_0271	equ	$0271
p_0280	equ	$0280
p_0284	equ	$0284
p_0288	equ	$0288
p_028c	equ	$028c
p_0290	equ	$0290
p_0294	equ	$0294
p_029c	equ	$029c
p_029f	equ	$029f
p_02a6	equ	$02a6
p_02ad	equ	$02ad
	org	p:$0000

	jmp	<JPEGDecoder
	org	p:$0040

JPEGDecoder	ori	#$03,mr
	movep	#>4,x:<<x_ffe8
	movep	#$c00,x:<<x_ffff
	movep	#>1,x:<<x_ffe0
	movep	#>0,x:<<x_fffe
	andi	#$02,mr
	movec	#-1,m0
	movec	#-1,m1
	movec	#-1,m2
	movec	#-1,m3
	movec	#-1,m4
	movec	#-1,m5
	movec	#-1,m6
	movec	#-1,m7
p_005a	jclr	#0,x:<<x_ffe9,p_005e
	movep	x:<<x_ffeb,x0
	jmp	<p_005a
p_005e	move	#$2000,r0
	do	#$800,MainLoop
p_0062	jclr	#0,x:<<x_ffe9,p_0062
	movep	x:<<x_ffeb,y:(r0)+
MainLoop	move	#$1000,x0
	move	x0,x:Exp1Ptr
	move	#$1200,x0
	move	x0,x:Exp2Ptr
	move	#$1400,x0
	move	x0,x:Exp3Ptr
	move	#$1600,x0
	move	x0,x:Exp4Ptr
p_0075	jclr	#0,x:<<x_ffe9,p_0075
	jset	#0,x:<<x_ffeb,JPEGSetStruct
DecodeMCU	move	#$180,r2
	move	#$1800,r4
	do	#$5a,p_0085
p_007f	jclr	#0,x:<<x_ffe9,p_007f
	movep	x:<<x_ffeb,y:(r4)
p_0082	jclr	#0,x:<<x_ffe9,p_0082
	movep	x:<<x_ffeb,x:(r4)+
p_0085	move	#$1800,r4
	movec	#$1f,m0
	move	#$18d,r1
	do	#$5a,p_00ac
	do	#$5a,p_00a9
	move	x:(r2),r3
	movec	#$1f,m3
	move	#>0,r0
	move	x:(r3),x0	y:(r4),y0
	do	#$20,p_0099
	mpy	y0,x0,a	x:(r4)+,x0	y:(r3)+,y0
	move	a0,x:(r0)
	mpy	y0,x0,b	x:(r3),x0	y:(r4),y0
	move	b0,y:(r0)+
p_0099	move	r1,x:SaveR1
	move	r2,x:SaveR2
	move	r4,x:SaveR4
	jsr	IDCTDU
	jsr	ExpandDU
	move	x:SaveR1,r1
	move	x:SaveR2,r2
	move	x:SaveR4,r4
p_00a9	move	(r1)+
	move	(r1)+
	move	(r2)+
p_00ac	jsr	ConvertMCU
	movec	#-1,m5
	jsr	SendMCU
	jmp	<MainLoop
IDCTDU	move	#>0,r0
	move	#<4,n0
	move	#>1,r4
	move	#<4,n4
	move	#>2,r1
	move	#<4,n1
	move	#>3,r5
	move	#<4,n5
	move	#>$20,r2
	move	#<4,n6
	move	#>$c0,r3
	movec	#4,m3
	move	#>$c8,r7
	movec	#4,m7
	do	#2,p_0148
	do	#4,p_013e
	move	x:(r0)-n0,x0	y:(r7)+,y0
	mpy	y0,x0,a	x:(r1)-n1,x1	y:(r7)+,y1
	macr	y1,x1,a
	mpy	x0,y1,a	a,x:(r0)
	cmpm	x1,ax1,a	x:(r4)-n4,x0	y:(r3)+,y0
	mpy	y0,x0,a	a,x:(r1)
	move	x:(r5)-n5,x1	y:(r3)+,y1
	macr	y1,x1,a
	mpy	x0,y1,a	a,x:(r4)
	cmpm	x1,ax1,a	x:(r3)+,x0	y:(r4)-n4,y0
	mpy	y0,x0,a	a,x:(r5)
	move	x:(r7)+,x1	y:(r1)-n1,y1
	macr	y1,x1,a
	mpy	x1,y0,a	x:(r0)-n0,b	a,y:(r4)-n4
	cmpm	x0,ax0,a	y:(r0),y0
	tfr	x1,y0,a	x:(r4)-n4,b	a,y:(r1)-n1
	add	a,b	y:(r4),x0
	movep	x:<<x_ffd6,m0
	tfr	y0,a	a,x:(r4)
	add	a,b	x:(r1),y1
	subl	b,a	x:(r5)-n5,b	b,y:(r0)-n0
	tfr	y1,a	a,y:(r4)
	add	a,b	y:(r5),x0
	subl	b,a	b,x:(r1)
	tfr	x0,a	a,x:(r5)-n5	y:(r1)-n1,b
	add	a,b	y:(r0),y0
	subl	b,a	b,y:(r5)
	move	x:(r7)+,x0	a,y:(r1)-n1
	mpy	y0,x0,a	x:(r3)+,x1	y:(r5)-n5,y1
	macr	y1,x1,a
	mpy	x1,y0,a	a,y:(r0)
	cmpm	x0,ax0,a	x:(r3)+,x0	y:(r4)-n4,y0
	mpy	y0,x0,a	a,y:(r5)
	move	x:(r7)+,x1	y:(r1)-n1,y1
	macr	y1,x1,a
	mpy	x1,y0,a	a,y:(r4)
	cmpm	x0,ax0,a	r2,r6
	move	a,y:(r1)
	move	ab,l:(r0)+n0
	add	a,b
	subl	b,a	b,x:(r6)+n6
	move	a,x0
	move	ab,l:(r1)+n1
	add	a,b
	subl	b,a	b,x:(r6)+n6
	move	x:(r5),a	a,y1
	move	y:(r4),b
	add	a,b
	subl	b,a	b,x:(r6)+n6
	move	x:(r4)+n4,a	a,y0
	move	y:(r5)+n5,b
	add	a,b
	subl	b,a	b,x:(r6)+n6
	move	a,x:(r6)+n6
	move	y0,x:(r6)+n6
	move	y1,x:(r6)+n6
	move	x0,x:(r6)+n6
	move	x:(r0)-n0,x0	y:(r7)+,y0
	mpy	y0,x0,a	x:(r1)-n1,x1	y:(r7)+,y1
	macr	y1,x1,a
	mpy	x0,y1,a	a,x:(r0)
	cmpm	x1,ax1,a	x:(r4)-n4,x0	y:(r3)+,y0
	mpy	y0,x0,a	a,x:(r1)
	move	x:(r5)-n5,x1	y:(r3)+,y1
	macr	y1,x1,a
	mpy	x0,y1,a	a,x:(r4)
	cmpm	x1,ax1,a	x:(r3)+,x0	y:(r4)-n4,y0
	mpy	y0,x0,a	a,x:(r5)
	move	x:(r7)+,x1	y:(r1)-n1,y1
	macr	y1,x1,a
	mpy	x1,y0,a	x:(r0)-n0,b	a,y:(r4)-n4
	cmpm	x0,ax0,a	y:(r0),y0
	tfr	x1,y0,a	x:(r4)-n4,b	a,y:(r1)-n1
	add	a,b	y:(r4),x0
	movep	x:<<x_ffd6,m0
	tfr	y0,a	a,x:(r4)
	add	a,b	x:(r1),y1
	subl	b,a	x:(r5)-n5,b	b,y:(r0)-n0
	tfr	y1,a	a,y:(r4)
	add	a,b	y:(r5),x0
	subl	b,a	b,x:(r1)
	tfr	x0,a	a,x:(r5)-n5	y:(r1)-n1,b
	add	a,b	y:(r0),y0
	subl	b,a	b,y:(r5)
	move	x:(r7)+,x0	a,y:(r1)-n1
	mpy	y0,x0,a	x:(r3)+,x1	y:(r5)-n5,y1
	macr	y1,x1,a
	mpy	x1,y0,a	a,y:(r0)
	cmpm	x0,ax0,a	x:(r3)+,x0	y:(r4)-n4,y0
	mpy	y0,x0,a	a,y:(r5)
	move	x:(r7)+,x1	y:(r1)-n1,y1
	macr	y1,x1,a
	mpy	x1,y0,a	a,y:(r4)
	cmpm	x0,ax0,a	r2,r6
	move	a,y:(r1)
	move	ab,l:(r0)+n0
	add	a,b
	subl	b,a	b,y:(r6)+n6
	move	a,x0
	move	ab,l:(r1)+n1
	add	a,b
	subl	b,a	b,y:(r6)+n6
	move	x:(r5),a	a,y1
	move	y:(r4),b
	add	a,b
	subl	b,a	b,y:(r6)+n6
	move	x:(r4)+n4,a	a,y0
	move	y:(r5)+n5,b
	add	a,b	(r2)+
	subl	b,a	b,y:(r6)+n6
	move	a,y:(r6)+n6
	move	y0,y:(r6)+n6
	move	y1,y:(r6)+n6
	move	x0,y:(r6)+n6
p_013e	move	#>$20,r0
	move	#>$21,r4
	move	#>$22,r1
	move	#>$23,r5
	move	#>0,r2
p_0148	rts
ConvertMCU	move	#>$d0,r0
	move	x:ColorMagic,n0
	nop
	move	x:(r0+n0),r0
	nop
	jmp	(r0)
YToY	move	x:FinalSize,x1
	move	#$1000,r0
	movec	#-1,m0
	move	#$1800,r4
	move	#$200,y1
	do	#$c5,p_0161
	move	x:(r0),x0
	mpyr	x0,y1,a	y:(r0)+,y0
	mpyr	y1,y0,a	a,y:(r4)
	move	a,x:(r4)+
p_0161	rts
YToRGB	move	x:FinalSize,x1
	move	#$1000,r0
	move	#$1800,r4
	move	#$1800,r1
	do	#$c5,p_0172
	move	y:(r0),a
	move	a,x:(r1)+	a,y:(r4)+
	move	a,x:(r1)+
	move	x:(r0)+,a
	move	a,x:(r1)+	a,y:(r4)+
	move	a,y:(r4)+
p_0172	rts
YCbCrToY	jmp	<YToY
YCbCrToRGB	move	x:FinalSize,x1
	move	#$1000,r0
	movec	#-1,m0
	move	#$1200,r1
	move	#$1400,r2
	move	#$1800,r4
	move	#$100,r5
	movec	#4,m5
	ori	#$08,mr
	do	#$c5,p_0197
	move	x:(r5)+,x0	y:(r0)-n0,y0
	mpy	y0,x0,b
	tfr	x1,y0,a	x:(r5)+,x0	y:(r2)-n2,y0
	macr	y0,x0,a	x:(r5)+,x0	y:(r1)-n1,y0
	tfr	x1,y0,a	a,x:(r4)
	mac	y0,x0,a	x:(r5)+,x0	y:(r2)-n2,y0
	cmpm	y0,ay0,a	x:(r5)+,x0	y:(r1)-n1,y0
	macr	y0,x0,b	a,y:(r4)+
	move	x:(r0)+,x0	y:(r5)+,y0
	mpy	y0,x0,a	b,x:(r4)
	tfr	y1,x1,a	x:(r2)-n2,x0	y:(r5)+,y0
	macr	y0,x0,b	x:(r1)-n1,x0	y:(r5)+,y0
	tfr	y1,x1,a	b,y:(r4)+
	mac	y0,x0,b	x:(r2)+,x0	y:(r5)+,y0
	cmpm	y0,by0,b	x:(r1)+,x0	y:(r5)+,y0
	macr	y0,x0,a	b,x:(r4)
	move	a,y:(r4)+
p_0197	andi	#$f3,mr
	rts
ExpandDU	move	#>0,r0
	move	x:SaveR1,r1
	move	#>$d4,r5
	move	x:(r1)+,n5
	move	x:(r1),r4
	move	x:(r5+n5),r5
	move	#>0,r0
	jsr	(r5)
	move	r4,x:(r1)-
	move	r1,x:SaveR1
	rts
X1Y1_X1Y1	move	r4,r5
	move	x:(r0)+,a
	rep	#p_001f
	move	x:(r0)+,a	a,y:(r4)+
	move	a,y:(r4)+
	move	y:(r0)+,a
	rep	#p_001f
	move	a,x:(r5)+	y:(r0)+,a
	move	a,x:(r5)+
	rts
X1Y2_X1Y1	rts
X1Y2_X1Y2	rts
X1Y3_X1Y1	rts
X1Y3_X1Y3	rts
X1Y4_X1Y1	rts
X1Y4_X1Y4	rts
X2Y1_X1Y1	move	r4,r2
	move	#<4,n2
	move	r4,r5
	move	#<5,n4
	move	#<5,n5
	do	#8,p_01c4
	move	x:(r0)+,a
	rep	#p_0003
	move	x:(r0)+,a	a,y:(r4)+
	move	a,y:(r4)+n4
p_01c4	do	#8,p_01ca
	move	y:(r0)+,a
	rep	#p_0003
	move	a,x:(r5)+	y:(r0)+,a
	move	a,x:(r5)+n5
p_01ca	lua	(r2)+n2,r4
	rts
X2Y1_X2Y1	move	r4,r2
	do	#$20,p_01d2
	move	ab,l:(r0)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
p_01d2	rts
X2Y2_X1Y1	move	r4,r2
	move	#<4,n2
	move	r4,r5
	move	#<$d,n4
	move	#<$d,n5
	do	#8,p_01de
	move	x:(r0)+,a
	rep	#p_0003
	move	x:(r0)+,a	a,y:(r4)+
	move	a,y:(r4)+n4
p_01de	do	#8,p_01e4
	move	y:(r0)+,a
	rep	#p_0003
	move	a,x:(r5)+	y:(r0)+,a
	move	a,x:(r5)+n5
p_01e4	lua	(r2)+n2,r4
	rts
X2Y2_X1Y2	rts
X2Y2_X2Y1	rts
X2Y2_X2Y2	move	#<$10,n0
	move	r4,r5
	move	r4,r2
	move	#<$10,n4
	move	#<$10,n5
	move	#<$10,n2
	lua	(r0)+n0,r6
	do	#4,p_020a
	move	ab,l:(r0)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r0)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r0)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r0)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r6)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r6)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r6)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	ab,l:(r6)+
	move	a,x:(r2)+	a,y:(r4)+
	move	b,x:(r2)+	b,y:(r4)+
	move	x:(r2)+n2,x0	y:(r4)+n4,y0
p_020a	do	#4,p_0219
	move	r5,r0
	lua	(r5)+n5,r4
	move	x:(r0)+,a
	rep	#p_000f
	move	x:(r0)+,a	a,y:(r4)+
	move	a,y:(r4)+
	move	r5,r0
	lua	(r5)+n5,r4
	move	x:(r5)+n5,x0	y:(r0)+,a
	rep	#p_000f
	move	a,x:(r4)+	y:(r0)+,a
	move	a,x:(r4)+
	move	(r5)+n5
p_0219	rts
X2Y3_X1Y1	rts
X2Y3_X1Y3	rts
X2Y3_X2Y1	rts
X2Y3_X2Y3	rts
X2Y4_X1Y1	rts
X2Y4_X1Y2	rts
X2Y4_X1Y4	rts
X2Y4_X2Y1	rts
X2Y4_X2Y2	rts
X2Y4_X2Y4	rts
X3Y1_X1Y1	rts
X3Y1_X3Y1	rts
X3Y2_X1Y1	rts
X3Y2_X1Y2	rts
X3Y2_X3Y1	rts
X3Y2_X3Y2	rts
X3Y3_X1Y1	rts
X3Y3_X1Y3	rts
X3Y3_X3Y1	rts
X3Y3_X3Y3	rts
X4Y1_X1Y1	rts
X4Y1_X2Y1	rts
X4Y1_X4Y1	rts
X4Y2_X1Y1	rts
X4Y2_X1Y2	rts
X4Y2_X2Y1	rts
X4Y2_X2Y2	rts
X4Y2_X4Y1	rts
X4Y2_X4Y2	rts
SendMCU	move	#$110,r0
	move	x:SendMagic,n0
	nop
	move	x:(r0+n0),r0
	nop
	jmp	(r0)
Send8BitsY	move	#$1800,r0
	movec	#-1,m0
	move	#$2100,r4
	move	x:FinalSize,x1
	do	#$c5,p_0251
	move	x:(r0),n4
p_024a	jclr	#1,x:<<x_ffe9,p_024a
	movep	y:(r4+n4),x:<<x_ffeb
	move	y:(r0)+,n4
p_024e	jclr	#1,x:<<x_ffe9,p_024e
	movep	y:(r4+n4),x:<<x_ffeb
p_0251	rts
Send16BitsRGB	move	#$1800,r0
	movec	#-1,m0
	move	#$2300,r4
	move	#$2500,r5
	move	#$2700,r6
	move	x:FinalSize,x1
	do	#$c5,p_0274
	move	x:(r0),n4
	move	y:(r0)+,n5
	move	x:(r0),n6
	clr	a	y:(r4+n4),x0
	or	x0,a	y:(r5+n5),x0
	or	x0,a	y:(r6+n6),x0
	or	x0,a
p_0267	jclr	#1,x:<<x_ffe9,p_0267
	movep	a,x:<<x_ffeb
	move	y:(r0)+,n4
	move	x:(r0),n5
	move	y:(r0)+,n6
	clr	a	y:(r4+n4),x0
	or	x0,a	y:(r5+n5),x0
	or	x0,a	y:(r6+n6),x0
	or	x0,a
p_0271	jclr	#1,x:<<x_ffe9,p_0271
	movep	a,x:<<x_ffeb
p_0274	rts
Send24BitsRGB	move	#$1800,r0
	movec	#-1,m0
	move	#$2100,r4
	move	x:FinalSize,x1
	do	#$c5,p_0297
	move	x:(r0),n4
p_0280	jclr	#1,x:<<x_ffe9,p_0280
	movep	y:(r4+n4),x:<<x_ffeb
	move	y:(r0)+,n4
p_0284	jclr	#1,x:<<x_ffe9,p_0284
	movep	y:(r4+n4),x:<<x_ffeb
	move	x:(r0),n4
p_0288	jclr	#1,x:<<x_ffe9,p_0288
	movep	y:(r4+n4),x:<<x_ffeb
	move	y:(r0)+,n4
p_028c	jclr	#1,x:<<x_ffe9,p_028c
	movep	y:(r4+n4),x:<<x_ffeb
	move	x:(r0),n4
p_0290	jclr	#1,x:<<x_ffe9,p_0290
	movep	y:(r4+n4),x:<<x_ffeb
	move	y:(r0)+,n4
p_0294	jclr	#1,x:<<x_ffe9,p_0294
	movep	y:(r4+n4),x:<<x_ffeb
p_0297	rts
JPEGSetStruct	move	#>$40,r0
	do	#$80,p_02a2
p_029c	jclr	#0,x:<<x_ffe9,p_029c
	movep	x:<<x_ffeb,x:(r0)
p_029f	jclr	#0,x:<<x_ffe9,p_029f
	movep	x:<<x_ffeb,y:(r0)+
p_02a2	move	#$180,r0
	do	#$d,p_02a9
p_02a6	jclr	#0,x:<<x_ffe9,p_02a6
	movep	x:<<x_ffeb,x:(r0)+
p_02a9	move	#$18d,r0
	do	#4,p_02b1
p_02ad	jclr	#0,x:<<x_ffe9,p_02ad
	movep	x:<<x_ffeb,x:(r0)+
	move	(r0)+
p_02b1	jmp	<MainLoop
	org	x:$00C0

IDCTXCoef3	dc	$000000
	dc	$000000
	dc	$5A827A
	dc	$0C7C5C
	dc	$238E76
	org	x:$00C8

IDCTXCoef7	dc	$000000
	dc	$000000
	dc	$5A827A
	dc	$3EC530
	dc	$3536CC
	org	y:$00C0

IDCTYCoef3	dc	$3B20D8
	dc	$187DE3
	dc	$000000
	dc	$000000
	dc	$000000
	org	y:$00C8

IDCTYCoef7	dc	$2D413D
	dc	$2D413D
	dc	$000000
	dc	$000000
	dc	$000000

	org	x:$00D0


ColorTable	dc	$000151
	dc	$000162
	dc	$000173
	dc	$000174
	org	x:$00D4

ExpTable	dc	$0001A9
	dc	$0001B3
	dc	$0001B4
	dc	$0001B5
	dc	$0001B6
	dc	$0001B7
	dc	$0001B7
	dc	$0001B8
	dc	$0001B9
	dc	$0001CC
	dc	$0001D3
	dc	$0001E6
	dc	$0001E7
	dc	$0001E8
	dc	$00021A
	dc	$00021B
	dc	$00021C
	dc	$00021D
	dc	$00021E
	dc	$00021F
	dc	$000220
	dc	$000221
	dc	$000222
	dc	$000223
	dc	$000224
	dc	$000225
	dc	$000226
	dc	$000227
	dc	$000228
	dc	$000229
	dc	$00022A
	dc	$00022B
	dc	$00022C
	dc	$00022D
	dc	$00022E
	dc	$00022F
	dc	$000230
	dc	$000231
	dc	$000232
	dc	$000233
	dc	$000234
	dc	$000235
	dc	$000236
	org	x:$0100

RGBMatrix	dc	$000200
	dc	$0002CE
	dc	$0000B0
	dc	$00016E
	dc	$00038B
	org	y:$0100

	dc	$000200
	dc	$0002CE
	dc	$0000B0
	dc	$00016E
	dc	$00038B
	org	x:$0110

SendTable	dc	$00023F
	dc	$000252
	dc	$000275
	org	x:$0180

InitSize	dc	$000000
SrcCompNb	dc	$000000
Comp1DU	dc	$000000
Comp1DQT	dc	$000000
Comp2DU	dc	$000000
Comp2DQT	dc	$000000
Comp3DU	dc	$000000
Comp3DQT	dc	$000000
Comp4DU	dc	$000000
Comp4DQT	dc	$000000
FinalSize	dc	$000000
ColorMagic	dc	$000000
SendMagic	dc	$000000
Exp1Magic	dc	$000000
Exp1Ptr	dc	$001000
Exp2Magic	dc	$000000
Exp2Ptr	dc	$001200
Exp3Magic	dc	$000000
Exp3Ptr	dc	$001400
Exp4Magic	dc	$000000
Exp4Ptr	dc	$001600
SaveR1	dc	$000000
SaveR2	dc	$000000
SaveR4	dc	$000000
