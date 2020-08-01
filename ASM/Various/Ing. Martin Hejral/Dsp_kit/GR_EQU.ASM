x_ffeb	equ	$ffeb
x_ffec	equ	$ffec
x_ffe1	equ	$ffe1
x_ffee	equ	$ffee
x_ffed	equ	$ffed
x_fffe	equ	$fffe
x_ffff	equ	$ffff
x_ffe0	equ	$ffe0
x_ffe9	equ	$ffe9
x_ffef	equ	$ffef
x_1016	equ	$1016
x_001d	equ	$001d
x_1015	equ	$1015
	org	x:$0000

in_l	dc	$000001
in_r	dc	$000001
out_l	dc	$000001
out_r	dc	$000001
temp	dc	$000001
temp1	dc	$000001
inflag	dc	$000001
outflag	dc	$000001
sync	dc	$000000
	org	p:$0000

	jmp	start
	org	p:$000C

	jsr	datain
	org	p:$0010

	jsr	dataout
	org	p:$0040

start	movep	x:<<x_ffeb,x0
	movec	#0,sp
	movep	#$4100,x:<<x_ffec
	movep	#$1f8,x:<<x_ffe1
	btst	#4,x:<<x_ffee
	movep	#$f800,x:<<x_ffed
	movep	#>0,x:<<x_fffe
	movep	#$3000,x:<<x_ffff
	movep	#>1,x:<<x_ffe0
ints_on	jsr	INIT
	andi	#$fc,mr
main	jclr	#0,x:<sync,main
	jclr	#0,x:<<x_ffe9,Wait1
	movep	x:<<x_ffeb,x1
Wait2	jclr	#0,x:<<x_ffe9,Wait2
	movep	x:<<x_ffeb,x0
	move	#>$14,a
	cmp	x1,a
	jcc	filt
	move	x0,n1
	move	#$1060,r1
	nop
	move	x:(r1+n1),x0
	jmp	set
filt	move	x0,n1
	move	#$1040,r1
	nop
	move	x:(r1+n1),x0
set	move	x1,n1
	move	#$1000,r1
	nop
	move	x0,x:(r1+n1)
Wait1	jsr	LEFT
	jsr	RIGHT
	bclr	#0,x:<sync
	jmp	<main
datain	bset	#0,x:<sync
	move	x0,x:<temp
	move	x1,x:<temp1
	jclr	#0,x:<inflag,do_leftin
do_rightin	movep	x:<<x_ffef,x1
	move	x1,x:<in_r
	bclr	#0,x:<inflag
	move	x:<temp,x0
	move	x:<temp1,x1
	rti
do_leftin	movep	x:<<x_ffef,x0
	move	x0,x:<in_l
	bset	#0,x:<inflag
	move	x:<temp,x0
	move	x:<temp1,x1
	rti
dataout	move	x0,x:<temp
	move	x1,x:<temp1
	jclr	#0,x:<outflag,do_leftout
do_rightout	move	x:<out_r,x1
	movep	x1,x:<<x_ffef
	bclr	#0,x:<outflag
	move	x:<temp,x0
	move	x:<temp1,x1
	rti
do_leftout	move	x:<out_l,x0
	movep	x0,x:<<x_ffef
	bset	#0,x:<outflag
	move	x:<temp,x0
	move	x:<temp1,x1
	rti
LEFT	move	x:<in_l,b
	move	b,y0
	movec	#2,m4
	move	#$100a,r1
	clr	a	x:x_1016,x0
	mpy	y0,x0,b	(r4)+
	move	b1,y:(r5)
	ori	#$08,mr
	do	#$a,LFBAND
	clr	b	x:(r0)+,x0	y:(r4)+,y0
	mac	y0,x0,b	x:(r0)+,x0	y:(r5)+,y0
	mac	y0,x0,b	y:(r5)-,y0
	mac	y0,x0,b	x:(r0)+,x0	y:(r4)+,y0
	macr	y0,x0,b	x:(r1)+,y0
	move	a,x0	y:(r4)+,b
	mac	y0,x0,a	(r4)+n4
LFBAND	andi	#$f7,mr
	movec	#$2b,m4
	move	x:<x_001d,x0
	move	y:(r5)+,y0
	mac	y0,x0,a	x:x_1015,y0
	move	a,x0
	mpy	y0,x0,b
	asl	b	(r4)+n4
	asl	b
LXMIT	move	b,x:<out_l
	rts
RIGHT	move	x:<in_r,b
	move	b,y0
	movec	#2,m6
	move	#$1000,r1
	clr	a	x:x_1016,x0
	mpy	y0,x0,b	(r6)+
	move	b1,y:(r7)
	ori	#$08,mr
	do	#$a,RFBAND
	clr	b	x:(r0)+,x0	y:(r6)+,y0
	mac	y0,x0,b	x:(r0)+,x0	y:(r7)+,y0
	mac	y0,x0,b	y:(r7)-,y0
	mac	y0,x0,b	x:(r0)+,x0	y:(r6)+,y0
	macr	y0,x0,b	x:(r1)+,y0
	move	a,x0	y:(r6)+,b
	mac	y0,x0,a	(r6)+n6
RFBAND	andi	#$f7,mr
	movec	#$2b,m6
	move	x:<x_001d,x0
	move	y:(r7)+,y0
	mac	y0,x0,a	x:x_1015,y0
	move	a,x0
	mpy	y0,x0,b
	asl	b	(r6)+n6
	asl	b
RXMIT	move	b,x:<out_r
	rts
INIT	move	#$7fffff,x0
	move	x0,x:x_1015
	move	#$7fffff,x0
	move	x0,x:x_1016
	move	#<$20,x0
	move	x0,x:x_001d
	clr	a
	move	#$1020,r2
	do	#$a0,XYNCLR
	move	a,y:(r2)+
XYNCLR	clr	a
	move	#$1000,r2
	do	#$15,GNCLR
	move	a,x:(r2)+
GNCLR	clr	a
	move	#$1080,r2
	do	#$15,SWNCLR
	move	a,x:(r2)+
SWNCLR	move	#$1040,r4
	move	#<4,n4
	move	#$1080,r6
	move	#<4,n6
	move	#$1020,r5
	movec	#2,m5
	move	#$1030,r7
	movec	#2,m7
	move	#$1020,r0
	movec	#$1d,m0
	move	#$1000,r3
	movec	#$14,m3
	move	#<-$80,n3
	rts
	org	x:$1020

	dc	$3FCD7F
	dc	$001941
	dc	$7FCD2E
	dc	$3F99A2
	dc	$00332F
	dc	$7F9859
	dc	$3F32E4
	dc	$00668E
	dc	$7F2DAF
	dc	$3E6AD9
	dc	$00CA94
	dc	$7E564D
	dc	$3CE4A9
	dc	$018DAB
	dc	$7C9380
	dc	$3A024C
	dc	$02FEDA
	dc	$78C581
	dc	$34D84E
	dc	$0593D9
	dc	$7022AF
	dc	$2C7AA6
	dc	$09C2AD
	dc	$5B582F
	dc	$214B31
	dc	$0F5A67
	dc	$28A767
	dc	$172AD0
	dc	$146A98
	dc	$C73AD4
	org	x:$1040

	dc	$E66666
	dc	$E81062
	dc	$EA1CAC
	dc	$EB851F
	dc	$ECCCCD
	dc	$EE76C9
	dc	$F16873
	dc	$F2D0E5
	dc	$F43958
	dc	$F5C28F
	dc	$F76C8B
	dc	$F978D5
	dc	$FB020C
	dc	$FC8B44
	dc	$FE147B
	dc	$000000
	dc	$000000
	dc	$03D70A
	dc	$07AE14
	dc	$0B851F
	dc	$0F5C29
	dc	$133333
	dc	$170A3D
	dc	$1AE148
	dc	$200000
	dc	$251EB8
	dc	$2B851F
	dc	$30A3D7
	dc	$3AE148
	dc	$451EB8
	dc	$600000
	dc	$7FDF3B
	org	x:$1060

	dc	$000000
	dc	$000000
	dc	$00068E
	dc	$001062
	dc	$0020C5
	dc	$00624E
	dc	$0147AE
	dc	$01EB85
	dc	$028F5C
	dc	$03D70A
	dc	$051EB8
	dc	$07AE14
	dc	$0A3D71
	dc	$0CCCCD
	dc	$0F5C29
	dc	$133333
	dc	$19999A
	dc	$200000
	dc	$266666
	dc	$2CCCCD
	dc	$333333
	dc	$39999A
	dc	$400000
	dc	$4CCCCD
	dc	$59999A
	dc	$666666
	dc	$733333
	dc	$7FFCB9
	dc	$7FFCB9
	dc	$7FFCB9
	dc	$7FFCB9
	dc	$7FFCB9
