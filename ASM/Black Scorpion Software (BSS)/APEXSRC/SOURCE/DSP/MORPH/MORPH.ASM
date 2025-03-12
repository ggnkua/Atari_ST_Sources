;---------------------------------------------*
;   DSP56001 Morph-engine for Falcon030       *
;---------------------------------------------*
; > Initial STOS prototype by Neil Stewart    *
;   based on SIGGRAPH proceedings '92         *
; > 68030 32/64-bit impl. by Douglas Little   *
; > DSP56001 version by Douglas Little        *
;---------------------------------------------*
; (C) Jan 1994 Black Scorpion software        *	
;---------------------------------------------*
 nolist
;---------------------------------------------*

max_lines	=	200

START		=	64

PBC		=	$FFE0
HSR		=	$FFE9
HTX		=	$FFEB

		org	p:0
		jmp	Init

		org	l:0

temp:		ds	1
u_R:		ds	1
v_R:		ds	1
vs_R:		ds	1
ax_R:		ds	1
ay_R:		ds	1
bx_R:		ds	1
by_R:		ds	1
dx_R:		ds	1
dy_R:		ds	1

data:
WeightSum:	ds	1
dsx1:		ds	1
dsy1:		ds	1
dsx2:		ds	1
dsy2:		ds	1

		org	x:16

xx:		dc	32
qx:		ds	1
dx:		ds	1
xxpx:		ds	1
qxpx:		ds	1
sx:		ds	1
tx:		ds	1
txsx:		ds	1
nxx:		ds	1

nxx1:		ds	1
nxx2:		ds	1

vt:		ds	1
ut:		ds	1
l2:		ds	1

opt:		ds	1
Sqr:		ds	1
Distance:	ds	1
LineCount:	dc	2
Weight:	ds	1
MaxWeight:	ds	1

params:
start_x:	ds	1
start_y:	ds	1
width:	ds	1
height:	ds	1

x_count:	ds	1
y_count:	ds	1

inc:		dc	4

		org	y:16

yy:		dc	64
qy:		ds	1
dy:		ds	1
yypy:		ds	1
qypy:		ds	1
sy:		ds	1
ty:		ds	1
tysy:		ds	1
nyy:		ds	1

nyy1:		ds	1
nyy2:		ds	1

		org	x:$300

Src_x:	ds	2*max_lines
Dst_x:	ds	2*max_lines
Gen_x:	ds	2*max_lines		

		org	y:$300

Src_y:	ds	2*max_lines
Dst_y:	ds	2*max_lines
Gen_y:	ds	2*max_lines

PreCalc:	ds	12*max_lines


	org		p:START

;-----------------------------------------------------------------------*
;	Distance formula a=û((x1-x0)ý+(y1-y0)ý)							*
;-----------------------------------------------------------------------*

DistFormA:
	tfr		x1,b
	sub		x0,b
	tfr		y1,a		b,x0
	sub		y0,a
	move		a,y0

DistFormB:
	mpy		x0,x0,b	#<$40,y1
	mac		y0,y0,b	y1,x0
	clr		a		#>$7FFFFF,y0
	cmp		y0,b
	tcc		y0,b
	do		#23,_loop
	mac		-x0,x0,b	b,l:temp	; sq=sq-r^
	tge		x0,a				; upd r if positive
	move		y1,b				; get try bit
	asr		b				; try=try/2
	add		a,b		b,y1		; keep try bit, add a,b
	move		b,x0				; get rt in x0, restore sq
	move		l:temp,b
_loop	rts

;-----------------------------------------------------------------------*
;	Real-number multiply {24:24}*{24:24}={24:24} (26~27 cycles)		*
;-----------------------------------------------------------------------*
;	a	=	48-Bit multiplier							*
;	b	=	48-Bit multiplicand						*
;	b	=	48-Bit quotient							*
;-----------------------------------------------------------------------*

RealMuls:
	abs		a	a1,y0
	eor		y0,b	a1,x1
	eor		y0,b	b1,x:temp
	abs		b	a0,a1
	move		b1,y1
	lsr		a	b0,b1
	lsr		b	a1,x0
	move		b1,y0
	mpy		x0,y0,b
	asl		b
	move		b2,a
	move		b1,a0
	mac		x1,y0,a
	mac		x0,y1,a
	asl		a	a0,b1
	move		a1,a0
	move		a2,a1
	mac		x1,y1,a
	asr		a	b1,b0
	move		a0,b1
	move		a2,b2
	move		#>$7FFFFF,y0
	cmp		y0,b
	tcc		y0,b
	jclr		#23,x:temp,_posi
	neg		b
_posi	rts

;-----------------------------------------------------------------------*
;	Real-number multiply {24:24}*{24:24}={48} (21~22 cycles)		*
;-----------------------------------------------------------------------*
;	a	=	48-Bit multiplier							*
;	b	=	48-Bit multiplicand						*
;	a	=	48-Bit quotient							*
;-----------------------------------------------------------------------*

RealMuls_I:
	abs		a	a1,y0
	eor		y0,b	a1,x1
	eor		y0,b	b1,x:temp
	abs		b	a0,a1
	move		b1,y1
	lsr		a	b0,b1
	lsr		b	a1,x0
	move		b1,y0
	mpy		x0,y0,b
	asl		b
	move		b2,a
	move		b1,a0
	mac		x1,y0,a
	mac		x0,y1,a
	asl		a
	move		a1,a0
	move		a2,a1
	mac		x1,y1,a
	asr		a
	jclr		#23,x:temp,_posi
	neg		a
_posi	rts

;-----------------------------------------------------------------------*
;	Morphogenesis / Fieldwarping routine					*
;-----------------------------------------------------------------------*
Calc_coords:
;-----------------------------------------------------------------------*
	jsr		Init_vars
;-----------------------------------------------------------------------*
;	Start of line-loop								*
;-----------------------------------------------------------------------*
	move		x:LineCount,a
	do		a,Line
;-----------------------------------------------------------------------*
;	Fetch line coords									*
;-----------------------------------------------------------------------*
	move		x:(r2)+,x0	y:(r6)+,y0
	move		x:(r2)+,x1	y:(r6)+,y1
	move		x1,x:qx
	move		y1,y:qy
;-----------------------------------------*
;	Calc line differences			*
;-----------------------------------------*
	tfr		x0,b		x:xx,a
	sub		b,a		y:(r7)+,b	;*
	move		a,x:xxpx
	move		b,x:qxpx
	tfr		y0,b		y:yy,a
	sub		b,a		y:(r7)+,b	;*
	move		a,y:yypy
	move		b,y:qypy
;-----------------------------------------*
;	Calculate UT				*
;-----------------------------------------*
	move		x:xxpx,x0
	move		x:qxpx,y0
	mpy		x0,y0,b	y:yypy,x0
	move		y:qypy,y0
	mac		x0,y0,b	#>0,a
	asr		b		#>$7FFFFF,a0
	abs		b		b2,x:temp
	cmp		a,b
	tge		a,b
	jclr		#7,x:temp,_nn1
	neg		b
_nn1	move		b0,x:ut
;-----------------------------------------*
;	Calculate U#				*
;-----------------------------------------*
	move		x:qxpx,x0
	mpy		x0,x0,a	y:qypy,x0
	mac		x0,x0,a	x:ut,b
	asr		a		b1,b0
	move		b2,b1
	jsr		Divs48_Real
	move		b,l:u_R
;-----------------------------------------*
;	Calculate VT				*
;-----------------------------------------*
	move		x:xxpx,x0	
	move		y:qypy,y0	
	mpy		-x0,y0,a	y:yypy,x0
	move		x:qxpx,y0
	mac		x0,y0,a	#>0,b
	asr		a		#>$7FFFFF,b0
	abs		a		a2,x:temp
	cmp		b,a
	tge		b,a
	jclr		#7,x:temp,_nn2
	neg		a
_nn2	move		a0,x:vt
;-----------------------------------------*
;	Calculate V#				*
;-----------------------------------------*
	move		y:(r7)+,a
	move		y:(r7)+,a0
	move		x:vt,b
	jsr		RealMuls
	move		b,l:v_R
;-----------------------------------------------------------------------*
;	Calculate D										*
;-----------------------------------------------------------------------*
	move		l:u_R,a
	tst		a		#>1,b
	jmi		Uneg
	cmp		b,a
	jgt		Ugt1
;-----------------------------------------------------------------------*
;	If U#>=0 and U#<=1 then D=abs(V#)						*
;-----------------------------------------------------------------------*
	move		l:v_R,a
	abs		a
	jmp		Done
;-----------------------------------------------------------------------*
;	If U#<0 then D=û(xxpx^2+yypy^2)						*
;-----------------------------------------------------------------------*
Uneg	move		x:xxpx,x0
	move		y:yypy,y0
	jsr		DistFormB
	jmp		Done
;-----------------------------------------------------------------------*
;	If U#>1 then D=û((xx-qx)^2+(yy-qy)^2)					*
;-----------------------------------------------------------------------*
Ugt1	move		x:xx,x1
	move		x:qx,x0
	move		y:yy,y1
	move		y:qy,y0
	jsr		DistFormA
;-----------------------------------------*
Done	rnd		a		#>1,b
	add		b,a
	asl		a
	move		a,x0
;-----------------------------------------------------------------------*
;	Calculate pixel weight								*
;-----------------------------------------------------------------------*
	move		#>1,a
	andi		#$FE,ccr
	rep		#24
	div		x0,a
	asl		a
	move		a0,x0
	mpy		x0,x0,b
	move		b,x:Weight
;-----------------------------------------------------------------------*
;	Fetch line points #1								*
;-----------------------------------------------------------------------*
	move		x:(r0)+n0,a	y:(r7)+,b
	move		a,x:sx
	move		b,x:txsx
	move		y:(r4)+n4,a
	move		y:(r7)+,b
	move		a,y:sy
	move		b,y:tysy
;-----------------------------------------*
;	ReCalculate v_R				*
;-----------------------------------------*
	move		l:v_R,a
	move		y:(r7)+,b
	move		y:(r7)+,b0
	jsr		RealMuls
	move		b,l:vs_R
;-----------------------------------------*
;	Calculate AX				*
;-----------------------------------------*
	move		x:txsx,a
	move		l:u_R,b
	jsr		RealMuls
	move		b,l:dx_R
;-----------------------------------------*
;	Calculate BX				*
;-----------------------------------------*
	move		y:tysy,a
	neg		a		l:vs_R,b
	jsr		RealMuls
	move		l:dx_R,a
	add		b,a		x:sx,b
	add		b,a		x:xx,b
	sub		b,a		x:Weight,b
	move		a,l:dx_R
;-----------------------------------------*
;	Calculate DSX1				*
;-----------------------------------------*
	jsr		RealMuls_I
	move		l:dsx1,b
	add		a,b		y:tysy,a
	move		b,l:dsx1	
;-----------------------------------------*
;	Calculate AY				*
;-----------------------------------------*
	move		l:u_R,b
	jsr		RealMuls
	move		b,l:dy_R
;-----------------------------------------*
;	Calculate BY				*
;-----------------------------------------*
	move		x:txsx,a
	move		l:vs_R,b
	jsr		RealMuls
	move		l:dy_R,a
	add		b,a		y:sy,b
	add		b,a		y:yy,b
	sub		b,a		x:Weight,b
	move		a,l:dy_R
;-----------------------------------------*
;	Calculate DSY1				*
;-----------------------------------------*
	jsr		RealMuls_I
	move		l:dsy1,b
	add		a,b
	move		b,l:dsy1	
;-----------------------------------------------------------------------*
;	Fetch line points #2								*
;-----------------------------------------------------------------------*
	move		x:(r1)+n1,a	y:(r7)+,b
	move		a,x:sx
	move		b,x:txsx
	move		y:(r5)+n5,a
	move		y:(r7)+,b
	move		a,y:sy
	move		b,y:tysy
;-----------------------------------------*
;	ReCalculate v_R				*
;-----------------------------------------*
	move		l:v_R,a
	move		y:(r7)+,b
	move		y:(r7)+,b0
	jsr		RealMuls
	move		b,l:vs_R
;-----------------------------------------*
;	Calculate AX				*
;-----------------------------------------*
	move		x:txsx,a
	move		l:u_R,b
	jsr		RealMuls
	move		b,l:dx_R
;-----------------------------------------*
;	Calculate BX				*
;-----------------------------------------*
	move		y:tysy,a
	neg		a		l:vs_R,b
	jsr		RealMuls
	move		l:dx_R,a
	add		b,a		x:sx,b
	add		b,a		x:xx,b
	sub		b,a		x:Weight,b
	move		a,l:dx_R
;-----------------------------------------*
;	Calculate DSX2				*
;-----------------------------------------*
	jsr		RealMuls_I
	move		l:dsx2,b
	add		a,b		y:tysy,a
	move		b,l:dsx2	
;-----------------------------------------*
;	Calculate AY				*
;-----------------------------------------*
	move		l:u_R,b
	jsr		RealMuls
	move		b,l:dy_R
;-----------------------------------------*
;	Calculate BY				*
;-----------------------------------------*
	move		x:txsx,a
	move		l:vs_R,b
	jsr		RealMuls
	move		l:dy_R,a
	add		b,a		y:sy,b
	add		b,a		y:yy,b
	sub		b,a		x:Weight,b
	move		a,l:dy_R
;-----------------------------------------*
;	Calculate DSY2				*
;-----------------------------------------*
	jsr		RealMuls_I
	move		l:dsy2,b
	add		a,b
	clr		a		b,l:dsy2	
;-----------------------------------------------------------------------*
;	Update weightsum									*
;-----------------------------------------------------------------------*
	move		x:Weight,a0
	move		l:WeightSum,b
	add		a,b
	move		b,l:WeightSum
;-----------------------------------------------------------------------*
;	Find x1,y1 from weighted values						*
;-----------------------------------------------------------------------*
Line:	move		l:dsx1,b
	move		l:WeightSum,a
	jsr		Divs48_Real
	move		x:xx,a
	add		b,a		l:dsy1,b
	asr		a
	asr		a
	rnd		a
_wx1	jclr		#1,x:<<HSR,_wx1
	movep		a,x:<<HTX
;-----------------------------------------*
	move		l:WeightSum,a
	jsr		Divs48_Real
	move		y:yy,a
	add		b,a		l:dsx2,b
	asr		a
	asr		a
	rnd		a
_wy1	jclr		#1,x:<<HSR,_wy1
	movep		a,x:<<HTX
;-----------------------------------------------------------------------*
;	Find x2,y2 from weighted values						*
;-----------------------------------------------------------------------*
	move		l:WeightSum,a
	jsr		Divs48_Real
	move		x:xx,a
	add		b,a		l:dsy2,b
	asr		a
	asr		a
	rnd		a
_wx2	jclr		#1,x:<<HSR,_wx2
	movep		a,x:<<HTX
;-----------------------------------------*
	move		l:WeightSum,a
	jsr		Divs48_Real
	move		y:yy,a
	add		b,a
	asr		a
	asr		a
	rnd		a
_wy2	jclr		#1,x:<<HSR,_wy2
	movep		a,x:<<HTX
	rts

;-----------------------------------------------------------------------*
	
Init:	movep		#1,x:PBC			; enable HOST	
	bclr		#2,omr

Main:	jsr		Fetch_lines
	jsr		Fetch_zone
	jsr		Init_fastmaths
	move		x:start_x,a
	move		x:start_y,b
	asl		a
	asl		a
	asl		b
	asl		b
	move		a,x:start_x
	move		b,x:start_y
	move		a,x:xx
	move		b,y:yy
	move		x:height,a
	do		a,_y
	move		x:width,a
	do		a,_x
	jsr		Calc_coords
	move		x:inc,b
	move		x:xx,a
	add		b,a
	move		a,x:xx
_x	move		x:start_x,a
	move		a,x:xx
	move		x:inc,b
	move		y:yy,a
	add		b,a
	move		a,y:yy
_y	jmp		Main

Fetch_lines:
rl:	jclr		#0,x:<<HSR,rl
	movep		x:<<HTX,a
	move		a,x:LineCount
	move		#Src_x,r0
	move		#Src_y,r1
	jsr		Read_linelist
	move		#Dst_x,r0
	move		#Dst_y,r1
	jsr		Read_linelist
	move		#Gen_x,r0
	move		#Gen_y,r1
	jsr		Read_linelist
	rts

Read_linelist:
	move		x:LineCount,a
	move		#>1,b
	do		a,_rs
_rx1	jclr		#0,x:<<HSR,_rx1
	movep		x:<<HTX,a
	asl		a
	asl		a
	move		a,x:(r0)+
_ry1	jclr		#0,x:<<HSR,_ry1
	movep		x:<<HTX,a
	asl		a
	asl		a
	move		a,y:(r1)+
_rx2	jclr		#0,x:<<HSR,_rx2
	movep		x:<<HTX,a
	asl		a
	asl		a
	add		b,a
	move		a,x:(r0)+
_ry2	jclr		#0,x:<<HSR,_ry2
	movep		x:<<HTX,a
	asl		a
	asl		a
	add		b,a
	move		a,y:(r1)+
_rs	rts

Fetch_zone:
	move		#params,r0
	do		#4,_loop
_w	jclr		#0,x:<<HSR,_w
	movep		x:<<HTX,a
	move		a,x:(r0)+
_loop	rts

Init_fastmaths:
	jsr		Init_vars
	move		x:LineCount,a
	do		a,Scan
;-----------------------------------------------------------------------*
;	Fetch line coords									*
;-----------------------------------------------------------------------*
	move		x:(r2)+,x0	y:(r6)+,y0
	move		x:(r2)+,x1	y:(r6)+,y1
;-----------------------------------------------------------------------*
;	PreCalc line differences							*
;-----------------------------------------------------------------------*
	tfr		x0,b		x1,x:qx
	tfr		x1,a		y1,y:qy
	sub		b,a		;*
	tfr		y0,b		a,x:qxpx
	tfr		y1,a		a,y:(r7)+
	sub		b,a		;*
	move		a,y:qypy
	move		a,y:(r7)+

;;-----------------------------------------------------------------------*
;;	PreCalc L2										*
;;-----------------------------------------------------------------------*
;	move		x:qxpx,x0
;	mpy		x0,x0,a	y:qypy,x0
;	mac		x0,x0,a	#0,b
;	asr		a		#>1,b0
;	jsr		Divs48_Real
;	move		b1,y:(r7)+
;	move		b0,y:(r7)+

;-----------------------------------------------------------------------*
;	Calculate V#									*
;-----------------------------------------------------------------------*
	move		x:qxpx,x0
	move		y:qypy,y0
	jsr		DistFormB
	move		#>1,b
	jsr		Divs48_Real
	move		b1,y:(r7)+
	move		b0,y:(r7)+
;-----------------------------------------------------------------------*
;	Fetch line points #1								*
;-----------------------------------------------------------------------*
	move		x:(r0)+,a	y:(r4)+,b
	move		a,x:sx
	move		b,y:sy
	move		x:(r0)+,a	y:(r4)+,b
	move		a,x:tx
	move		b,y:ty
;-----------------------------------------------------------------------*
;	Calculate TXSX:TYSY								*
;-----------------------------------------------------------------------*
	move		x:tx,a
	move		x:sx,b
	sub		b,a		y:sy,b	;*
	move		a,x:txsx
	move		a,y:(r7)+
	move		y:ty,a
	sub		b,a				;*
	move		a,y:tysy
	move		a,y:(r7)+
;-----------------------------------------------------------------------*
;	Calculate SQ									*
;-----------------------------------------------------------------------*
	move		x:txsx,x0
	move		y:tysy,y0
	jsr		DistFormB
	move		#>1,b
	jsr		Divs48_Real
	move		b1,y:(r7)+
	move		b0,y:(r7)+
;-----------------------------------------------------------------------*
;	Fetch line points #2								*
;-----------------------------------------------------------------------*
	move		x:(r1)+,a	y:(r5)+,b
	move		a,x:sx
	move		b,y:sy
	move		x:(r1)+,a	y:(r5)+,b
	move		a,x:tx
	move		b,y:ty
;-----------------------------------------------------------------------*
;	Calculate TXSX:TYSY								*
;-----------------------------------------------------------------------*
	move		x:tx,a
	move		x:sx,b
	sub		b,a		y:sy,b	;*
	move		a,x:txsx
	move		a,y:(r7)+
	move		y:ty,a
	sub		b,a				;*
	move		a,y:tysy
	move		a,y:(r7)+
;-----------------------------------------------------------------------*
;	Calculate SQ									*
;-----------------------------------------------------------------------*
	move		x:txsx,x0
	move		y:tysy,y0
	jsr		DistFormB
	move		#>1,b
	jsr		Divs48_Real
	move		b1,y:(r7)+
	move		b0,y:(r7)+
Scan:	rts

;-----------------------------------------------------------------------*
;	Floating-point divide {24:24}/{24:24}={24:24} (70~90 cycles)	*
;-----------------------------------------------------------------------*
;	a	=	48-Bit divisor							*
;	b	=	48-Bit dividend							*
;	b	=	48-Bit quotient (Int:Frc)					*
;-----------------------------------------------------------------------*
Divs48_Real:
;-----------------------------------------------------------------------*
	move		r7,n7
	abs		a	a1,x0
	eor		x0,b	#0,r3
	eor		x0,b	b1,x:temp
	abs		b	#2,r7
	rep		#11
_nrma	norm		r3,a
	norm		r3,a
	jnn		_nrma
	rep		#11
_nrmb	norm		r7,b
	norm		r7,b
	jnn		_nrmb
	move		r7,n3
	asr		b	a,x0
	andi		#$FE,ccr
	rep		#24
	div		x0,b
	clr		a	(r3)-n3
	move		b0,x0
	clr		b	r3,a2
	tst		a	x0,b0
	jgt		_R
	jeq		_done
_L	neg		a
	rep		a2
	asl		b
	jmp		_done
_R	rep		a2
	asr		b
_done	jclr		#23,x:temp,_e
	neg		b
_e	move		n7,r7
	rts

Init_vars:
	move		#Gen_x,r2
	move		#Gen_y,r6
	move		#Src_x,r0
	move		#Src_y,r4
	move		#Dst_x,r1
	move		#Dst_y,r5
	clr		a		#WeightSum,r7
	move		a,x:MaxWeight
	rep		#5
	move		a,l:(r7)+
	move		#>2,n0
	move		#>2,n1
	move		#>2,n4
	move		#>2,n5
	move		#PreCalc,r7
	rts
