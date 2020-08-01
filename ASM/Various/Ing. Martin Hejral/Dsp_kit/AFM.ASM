y_0000	equ	$0000
x_ffef	equ	$ffef
x_0000	equ	$0000
x_0001	equ	$0001
p_01a0	equ	$01a0
p_0140	equ	$0140
p_00e0	equ	$00e0
x_0009	equ	$0009
x_0008	equ	$0008
x_0004	equ	$0004
x_0020	equ	$0020
x_0021	equ	$0021
y_0008	equ	$0008
y_0009	equ	$0009
x_ffff	equ	$ffff
x_0011	equ	$0011
x_ffe1	equ	$ffe1
x_ffec	equ	$ffec
x_ffe8	equ	$ffe8
x_ffe0	equ	$ffe0
x_ffed	equ	$ffed
x_ffe9	equ	$ffe9
x_ffeb	equ	$ffeb
y_0001	equ	$0001
p_0390	equ	$0390
p_03c0	equ	$03c0
p_03f0	equ	$03f0
p_03d0	equ	$03d0
p_03a0	equ	$03a0
p_0370	equ	$0370
p_0010	equ	$0010
x_0022	equ	$0022
x_0010	equ	$0010
p_0008	equ	$0008
y_0021	equ	$0021
y_0039	equ	$0039
y_0025	equ	$0025
y_ffe4	equ	$ffe4
p_0021	equ	$0021
p_d8ae	equ	$d8ae
x_0030	equ	$0030
p_0002	equ	$0002
	org	p:$0000

	jmp	Reset
	org	p:$000C

	jsr	Rcv
	org	p:$0010

p_0010	jsr	Xmit
	org	p:$0040

Rcv	jset	#8,y:<y_0000,R_do
	movep	x:<<x_ffef,x:x_0000
	bchg	#8,y:<y_0000
	rti
R_do	movep	x:<<x_ffef,x:x_0001
	bchg	#8,y:<y_0000
	move	b,l:(r2)-n2
	move	y,l:(r3)-n3
	jsset	#6,y:<y_0000,p_01a0
	jsset	#5,y:<y_0000,p_0140
	jsset	#4,y:<y_0000,p_00e0
	jsset	#3,y:<y_0000,Flng
	jsset	#2,y:<y_0000,Cyb
	jsset	#1,y:<y_0000,Hall
	jsset	#0,y:<y_0000,Equa
	move	x:<x_0001,x0
	move	x0,x:<x_0009
	move	x:<x_0000,x0
	move	x0,x:<x_0008
	move	b,l:(r2)-n2
	move	y,l:(r3)-n3
	rti
Xmit	jset	#9,y:<y_0000,X_dt
	movep	x:x_0008,x:<<x_ffef
	bchg	#9,y:<y_0000
	rti
X_dt	movep	x:x_0009,x:<<x_ffef
	bchg	#9,y:<y_0000
	rti
Equa	clr	a	x:<x_0000,x0
	move	y:(r4)+,y0
	ori	#$08,mr
	do	#8,E_gche
	mpy	y0,x0,b	x:(r0)-n0,x1	y:(r4)+,y1
	mac	x1,y0,b	x:(r1)+,x1	y:(r4)+,y0
	mac	y1,x1,b	x:(r1),x1
	cmpm	x1,bx1,b	y:(r5)+,x1
	move	x:(r1)+,b	b,y1
	mac	y1,x1,a	x:(r1)+n1,x1	y:(r4)+,y0
E_gche	move	x0,x:(r0)+
	andi	#$f7,mr
	move	a,x:<x_0004
	clr	a	x:<x_0001,x0
	ori	#$08,mr
	do	#8,E_drte
	mpy	y0,x0,b	x:(r0)-n0,x1	y:(r4)+,y1
	mac	x1,y0,b	x:(r1)+,x1	y:(r4)+,y0
	mac	y1,x1,b	x:(r1),x1
	cmpm	x1,bx1,b	y:(r5)+,x1
	move	x:(r1)+,b	b,y1
	mac	y1,x1,a	x:(r1)+n1,x1	y:(r4)+,y0
E_drte	andi	#$f7,mr
	move	x0,x:(r0)+	y:(r4)-,y0
	move	x:<x_0020,y0
	move	x:<x_0004,b
	macr	y0,x0,a	x:<x_0000,x0
	macr	y0,x0,b	x:<x_0021,y0
	move	a,x0	y:(r1)+,y1
	mpy	y0,x0,a	b,x1
	mpy	x1,y0,b	#<$20,n1
	asl	a
	asl	a	(r1)-n1
	asl	b	#<2,n1
	asl	b
	move	a,x:<x_0001
	move	b,x:<x_0000
	rts
Hall	move	x:<x_0000,a
	move	a,x:(r2+n2)
	move	y:(r2),y1
	move	y:<y_0008,y0
	macr	y1,y0,a	x:<x_0001,b
	move	b,y:(r2+n2)
	move	x:(r2)+,y1
	macr	y1,y0,b	a,x:<x_0000
	move	b,x:<x_0001
	rts
Cyb	move	x:<x_0000,a
	move	y:<y_0008,y0
	move	y:<y_0009,x1
	move	a,x:(r2+n2)
	move	x:(r6)-n6,x0	y:(r2)-n2,y1
	mac	y0,x0,a
	macr	y1,x1,a	x:(r2)-n2,x0	y:(r6)-n6,y1
	move	a,x:(r6+n6)
	move	a,x:<x_0000
	move	x:<x_0001,a
	mac	x1,x0,a	a,y:(r2+n2)
	macr	y1,y0,a	(r2)+
	move	a,y:(r6+n6)
	move	a,x:<x_0001
	move	(r6)+
	rts
Flng	move	b,l:(r3)+n3
	move	a,l:(r2)+n2
	add	a,b
	tst	b
	jgt	F_up
	neg	a
	jmp	F_do
F_up	move	#$100,x0
	cmp	x0,b
	jmi	F_do
	neg	a
	add	a,b
F_do	move	b1,n3
	move	b,l:(r3)+n3
	move	a,l:(r2)+n2
	move	x:<x_0000,x0
	move	x:<x_0001,x1
	move	x0,x:(r3)
	move	x1,y:(r3)
	tfr	x0,a	x:(r3+n3),x0
	add	x0,a
	tfr	x1,a	a,x:<x_0000
	move	y:(r3+n3),x1
	add	x1,a	(r3)+
	move	a,x:<x_0001
	rts
	org	p:$0200

Reset	ori	#$04,omr
	nop
	nop
	nop
	movep	x:<<x_ffff,x:x_0011
	move	#<0,x0
	move	x0,y:<y_0000
	movep	#$1000,x:<<x_ffff
	movep	#$1f8,x:<<x_ffe1
	movep	#$4100,x:<<x_ffec
	movep	#>0,x:<<x_ffe8
	movep	#>1,x:<<x_ffe0
	movep	#$f800,x:<<x_ffed
	andi	#$fc,mr
Main	jclr	#0,x:<<x_ffe9,Main
	movep	x:<<x_ffeb,y:y_0001
	jsset	#$17,y:<y_0001,A_equa
	jsset	#$16,y:<y_0001,A_hall
	jsset	#$15,y:<y_0001,A_cyb
	jsset	#$14,y:<y_0001,A_flng
	jsset	#$13,y:<y_0001,p_0390
	jsset	#$12,y:<y_0001,p_03c0
	jsset	#$11,y:<y_0001,p_03f0
	jsset	#$10,y:<y_0001,Load
	jsset	#$e,y:<y_0001,p_03d0
	jsset	#$d,y:<y_0001,p_03a0
	jsset	#$c,y:<y_0001,p_0370
	jsset	#$b,y:<y_0001,F_off
	jsset	#$a,y:<y_0001,C_off
	jsset	#9,y:<y_0001,H_off
	jsset	#8,y:<y_0001,E_off
	jsset	#6,y:<y_0001,p_03d0
	jsset	#5,y:<y_0001,p_03a0
	jsset	#4,y:<y_0001,p_0370
	jsset	#3,y:<y_0001,F_sw
	jsset	#2,y:<y_0001,C_sw
	jsset	#1,y:<y_0001,H_sw
	jsset	#0,y:<y_0001,E_sw
	jmp	<Main
E_sw	jset	#0,y:<y_0000,E_off
	jset	#$16,y:<y_0000,E_one
	move	#$2ac,r0
	move	#<$40,r4
	move	#<0,y0
	do	#$20,E_init
	movem	p:(r0)+,y1
	move	y0,x:(r4)
	move	y1,y:(r4)+
E_init	move	#<$20,r4
	rep	#p_0010
	move	y0,y:(r4)+
	move	#<$20,y0
	move	y0,x:<x_0020
	move	#$7fffff,y0
	move	y0,x:<x_0021
	move	#>$40,y0
	move	y0,x:<x_0022
E_one	move	#<$20,r5
	movec	#$f,m5
	move	#<$40,r4
	movec	#$17,m4
	move	#<$3c,r0
	movec	#3,m0
	move	#<$40,r1
	movec	#1,m1
	move	#<2,n1
	bset	#$16,y:<y_0000
	bset	#0,y:<y_0000
	rts
E_off	bclr	#0,y:<y_0000
	rts
A_equa	jset	#$16,y:<y_0001,E_adj
	jset	#$15,y:<y_0001,E_ask
	jset	#$14,y:<y_0001,E_end
	jsr	E_rst
A_equf	clr	b
	move	b,y:<y_0001
	rts
E_end	movep	x:x_0011,x:<<x_ffff
	stop
E_rst	move	#<$20,r7
	move	#<0,y0
	rep	#p_0010
	move	y0,y:(r7)+
	rts
E_ask	move	x:<x_0022,r7
	clr	b
	move	b,x:<x_0010
	move	#$800,y1
	do	#$fff,E_spec
	move	x:(r7),b
	abs	b
	move	x:x_0010,b	b,y0
	macr	y1,y0,b
	move	b,x:<x_0010
E_spec	movep	b,x:<<x_ffeb
	clr	b	(r7)+
	move	(r7)+
	move	r7,b1
	move	#>$60,y1
	cmp	y1,b
	jeq	E_upd
	move	r7,x:<x_0022
	jmp	<A_equf
E_upd	move	#<$40,r7
	move	r7,x:<x_0022
	jmp	<A_equf
E_adj	clr	b	#$1f00,y1
	move	y:<y_0001,b1
	and	y1,b
	rep	#p_0008
	asr	b
	move	b1,n7
	move	#$2c4,r7
	move	#>$f,b1
	movem	p:(r7+n7),y0
	move	y:<y_0001,y1
	and	y1,b	#<$20,r7
	move	b1,n7
	nop
	move	y0,y:(r7+n7)
	jmp	<A_equf
E_coef	mpyr	x1,x0,a	x0,x:(r6)-	y0,y:(r0)-n0
	macr	y0,y0,b	y:(r1)-,n7
	mac	y1,y0,a	#<-$d2,n7
	asl	b	x0,x:(r5)+n5	y0,y:(r1)-n1
	asr	a	y:<y_0021,n7
	mpy	x0,x0,b	#<-$a5,n7
	sub	y,a	x0,x:(r2)+	y0,y:(r6)-n6
	macr	y1,x1,b	n7,y:<y_0039
	cmpm		#<$4b,n7
	and	x1,a	x:(r3)-,x0	y0,y:(r5)-n5
	sub	x,b	n6,y:(r3)-
	sbc	y,a	#<-$99,n6
	mac	y1,y0,b	x0,x:(r2)-n2	y1,y:(r7)-n7
	macr	y1,y0,a	n4,y:<y_0025
	macr	x0,x0,a	#<$3a,n5
	tmi	
	and	x1,b	n6,x:(r6)+
	cmpm		#<-$95,n2
	mpyr	x0,y1,a	x1,x:(r0)+n0	y1,y:(r5)-n5
	macr	x1,x0,a	x:(r5)-n5,r5
	and	y1,b	#<-$ae,r5
	movep	y:<<y_ffe4,p:(r5)-
	macr	y0,y0,a	#<$3f,r6
	add	y,b	#<$6b,b1
E_gain	addl	b,a	x1,x:(r4)-	y:(r0)-,b
	add	x,a	x:(r2)-,x1	y:(r6)-,b
	cmp	x1,a	x:(r2)+n2,a	y:(r5)-,y0
	sub	y1,x1,b	x:(r3)-,a	y:(r4)-,y1
	mac	x1,y0,b	x:(r5)-,a	y:(r0)-,a
	and	x0,a	x:(r6)-,a	y:(r1)-,b
	not	b	x:(r4)-,b	y:(r3)-,y0
	mpyr	y1,y0,b	b,x:(r2)-	y:(r6)-,a

	eor	x1,a	x0,x:(r7)+	y:(r3)+,y1
	asl	a	x0,x:(r2)+	y:(r6)+,b
	eor	y1,b	x1,x:(r6)-n6	y:(r3)+,y1
	abs	a	x:(r2)+n2,x1	y:(r5)+,b
	not	a	a,x:(r3)+n3	y:(r5)+,a
	add	y,a	x:(r0)-,b	y:(r7)+,y0
	nop
	tlc	a,b	r3,r3
	movem	,p:<p_0021
	jsclr	#$d,x:(r5)-n5,p_d8ae
	eor	x0,b	b,x1	y:(r2+n2),y0
	tfr	x0,a	x:(r2)-n2,a	b,y0
	adc	y,b	x1,r4
	add	y0,a	#<-$8d,y1
	cmpm	x1,ax1,a	#<$1d,b
	sub	y,a	#<-$80,r7
	mpy	y0,y0,b	a10,l:(r4)-n4
	mpyr	x0,y1,a	ab,l:-(r6)
	mpyr	y1,y0,b	a,x:(r2)-
	eor	y1,a	x:(r7)-,r2
	mac	y1,x1,a	x:<x_0030,n0
	mpyr	y1,y0,b	y:-(r4),n7
H_sw	jset	#1,y:<y_0000,H_off
	move	#$2000,r2
	move	#$800,n2
	movec	#$fff,m2
	move	#<$40,y0
	move	y0,y:<y_0008
	bset	#1,y:<y_0000
	rts
H_off	bclr	#1,y:<y_0000
	rts
A_hall	move	y:<y_0001,b
	rep	#p_0002
	asl	b
	move	b1,n2
	clr	b
	move	b,y:<y_0001
	rts
C_sw	jset	#2,y:<y_0000,C_off
	move	#<0,y0
	move	x0,y0
	move	#$1000,r2
	movec	#$22,m2
	move	#<$22,n2
	move	#$1200,r6
	movec	#$1f4,m6
	move	#$1f3,n6
	move	#$1f3,y1
	do	#$c7,C_init
	move	x0,x:(r2)-n2	y0,y:(r6)-n6
	move	x0,x:(r6)+	y0,y:(r2)+
C_init	move	#<$70,y0
	move	y0,y:<y_0008
	move	#<$40,y0
	move	y0,y:<y_0009
	bset	#2,y:<y_0000
	rts
C_off	bclr	#2,y:<y_0000
	rts
A_cyb	move	y:<y_0001,b
	asr	b
	move	b1,n6
	clr	b
	move	b,y:<y_0001
	rts
F_sw	jset	#3,y:<y_0000,F_off
	clr	b
	move	b,l:(r3)+n3
	move	#$10000,b0
	move	b,l:(r2)+n2
	move	#$800,r3
	movec	#-$ff,m3
	bset	#3,y:<y_0000
	rts
F_off	bclr	#3,y:<y_0000
	rts
A_flng	move	y:<y_0001,b
	rep	#p_0010
	asr	b
	move	#<0,b1
	clr	b	b,l:(r2)+n2
	move	b,y:<y_0001
	rts
Load	clr	b
	move	y:<y_0001,y0
	move	#>$30,y1
	move	#>$e0,b0
	mac	y1,y0,b
	move	b0,r7
	clr	b
	move	#$408000,y1
L_rltm	jsr	L_word
	jeq	L_ldp1
	movem	b1,p:(r7)+
	jmp	<L_rltm
L_ldp1	clr	b
	move	#$370,b0
	move	#>$18,y1
	mac	y1,y0,b
	move	b0,r7
	move	b0,y0
	clr	b
	move	#$408000,y1
L_init	jsr	L_word
	jeq	L_ldp2
	movem	b1,p:(r7)+
	jmp	<L_init
L_ldp2	clr	b
	move	#>$20,b1
	add	y0,b
	move	b1,r7
	clr	b
L_act	jsr	L_word
	jeq	L_ldp3
	movem	b1,p:(r7)+
	jmp	<L_act
L_ldp3	movep	#-$555556,x:<<x_ffeb
	clr	b
	move	b,y:<y_0001
	rts
L_word	jclr	#0,x:<<x_ffe9,L_word
	movep	x:<<x_ffeb,b
	cmp	y1,b
	rts
