	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB

extract_rgb		macro
	move				#>col,r0
	move				#>col,r4
	move				x:(r0)+,x0
	move						y:(r4)+,y0
	mpy		x0,y0,a	x:(r0)+,x0
	move		a0,y0
	mpy		x0,y0,a	x:(r0)+,x0	y:(r4),y1
	and		y1,a		x:(r0)+,y1
	mpy		x0,y0,a	a,x:red
	and		y1,a		x:(r0)+,x0	y:(r4),y1
	mpy		x0,y0,a	a,x:grn

	and		y1,a
	move		a,x:blu

;	and		y1,a		#>$04,x0
;	add		x0,a
;	move				a,x:blu
;	move		x:red,a
;	add		x0,a	x:grn,b
;	add		x0,b	a,x:red
;	move			b,x:grn

	endm	
	
combine_rgb		macro
	move				x:(r0)+,b	y:(r4),y1
	and		y1,b		x:(r0)+,x0
	move				x:(r0)+,b	b,y0
	mpy		x0,y0,a	x:(r0)+,y1
	and		y1,b		x:(r0)+,x0	y:(r4),y1
	move				x:(r0)+,b	b,y0
	and		y1,b
	mac		x0,y0,a	x:(r0)+,x0	b,y0
	mpy		x0,y0,b	a0,a
	add		b,a
	move		a,y:col
	endm

;-----------------------------------------------------------------------*
	
		org	p:00
		jmp	Init
;		jmp	extract_hsv

;-----------------------------------------------------------------------*
		org	x:2
;-----------------------------------------------------------------------*

mask		ds	1
error		ds	1
matcode	ds	1
val		ds	1
valc		ds	1
adj		dc	(1<<14)
percshft	dc	(1<<14)
maskflag	ds	1

;-----------------------------------------------------------------------*

		org	x:16
		dc	(1<<6)
		dc	(1<<8)
		dc	(1<<13)
		dc	%11111000	;6
		dc	(1<<19)
		org	y:16
col		ds	1
		dc	%11111000	;5

		org	x:24
red		dc	0
		dc	(1<<7)
grn		dc	0
		dc	%11111000	;6
		dc	(1<<2)
blu		dc	0
		dc	(1<<20)
		org	y:24
cmb		dc	%11111000	;5

;-----------------------------------------------------------------------*
		org	x:32
;-----------------------------------------------------------------------*

smin:		ds	1
smax:		ds	1
vmin:		ds	1
vmax:		ds	1
hmask:	ds	1
smask:	ds	1
vmask:	ds	1
hthresh:	ds	1
sthresh:	ds	1
vthresh:	ds	1

nred:		ds	1
ngrn:		ds	1
nblu:		ds	1

hoffset:	ds	1
	
nrgb		ds	1

h		dc	130
s		dc	200
v		dc	120
nh		ds	1
ns		ds	1
nv		ds	1

max		ds	1
min		ds	1
delta		ds	1
i		ds	1
f		ds	1
p		ds	1
q		ds	1
t		ds	1

table		dc	case0
		dc	case1
		dc	case2
		dc	case3
		dc	case4
		dc	case5

type		dc	kH_kS_kB
		dc	kH_kS_rB
		dc	kH_rS_kB
		dc	kH_rS_rB
		dc	rH_kS_kB
		dc	rH_kS_rB
		dc	rH_rS_kB
		dc	rH_rS_rB

;-----------------------------------------------------------------------*
		org	y:32
;-----------------------------------------------------------------------*

matrouts:
	dc		MakeMask
	dc		Matrix
	dc		Lighten
	dc		Darken
	dc		Saturate
	dc		Weaken
	dc		Wash
	dc		Air

;-----------------------------------------------------------------------*
		org	p:64
;-----------------------------------------------------------------------*

extract_hsv:
;	move		#>$FFFF,a
;	move		a,y:col
	extract_rgb

extract_hsv_only:
	clr		a
	move		a,x:error
	move		a,x:mask
	move				x:red,a
	tfr		a,b		x:grn,x0
	cmp		x0,a
	tlt		x0,a
	cmp		x0,b		x:blu,y0
	tgt		x0,b
	cmp		y0,a
	tlt		y0,a
	cmp		y0,b		#>255,y1
	tgt		y0,b				; a=max(r,g,b),b=min(r,g,b)
	move		a,x:max
	move		b,x:min
	cmp		y1,a
	tge		y1,a
	tst		a
	jeq		_blck
	move		a,x:v				; v=a

	sub		b,a		#>128,y0
	move		a,x:delta
	move		a,x0
	mpy		x0,y0,b
	move		b0,b
	move		x:max,a
	jsr		Divs48_Real			; b=(max-min)/max
	move		#>255,y1
	cmp		y1,b
	tge		y1,b
	move		b,x:s				; s=b

	move		x:max,x0
	move		x:red,a
	cmp		x0,a
	jeq		_magenta_cyan		; if max=red, h=(magenta-cyan)
	move		x:grn,a
	cmp		x0,a
	jeq		_yellow_magenta		; if max=grn, h=(yellow_magenta)

_cyan_yellow					; if max=blu, h=(cyan-yellow)
	move		x:red,b
	move		x:grn,a
	sub		a,b		x:delta,a
	jsr		Divs48_Real
	move		#>4,a
	add		a,b
	jmp		_norm	

_magenta_cyan
	move		x:grn,b
	move		x:blu,a
	sub		a,b		x:delta,a
	jsr		Divs48_Real
	tst		b		#>6,a
	jpl		_norm
	add		a,b
	jmp		_norm	

_yellow_magenta
	move		x:blu,b
	move		x:red,a
	sub		a,b		x:delta,a
	jsr		Divs48_Real
	move		#>2,a
	add		a,b

_norm	clr		a
	move		#0.66666,a0
	asl		a
	move		#>42,a1
	jsr		RealMuls
	move		b,x:h
	move		x:min,a
	move		x:max,b
	cmp		a,b		#>1,a
	jne		_col
	move		a,x:h
	move		a,x:error
_col	move		x:h,a
	move		x:hoffset,b
	sub		b,a		#>255,x0
	and		x0,a		x:hthresh,b
	move		a1,a
	cmp		a,b		#>1,x0
	jlt		_skip
	move		x:smin,a
	move		x:smax,b
	move		x:s,x1
	cmp		x1,a
	jgt		_skip
	cmp		x1,b
	jlt		_skip
	move		x:vmin,a
	move		x:vmax,b
	move		x:v,x1
	cmp		x1,a
	jgt		_skip
	cmp		x1,b
	jlt		_skip
	rts
_skip	move		x0,x:mask
	rts

_blck	clr		a	#>1,b
	move		b,x:h
	move		a,x:s
	move		a,x:v
	move		b,x:error
	jmp		_col
	
combine_hsv:
	move		x:h,b
	move		#>255,x0
	and		x0,b		#0,a
	move		#0.66666,a0
	asl		a
	move		#>42,a1
	jsr		Divs48_Real
	move		b1,x:i
	move		b0,x:f
	move		#>256,a
	move		x:s,b
	sub		b,a		x:v,x0
	move		a,y0
	mpy		x0,y0,a	#>64*256,x0
	move		a0,y0
	mpy		x0,y0,a
	move		a,x:p			; v*(256-s)
	move		x:s,b
	clr		a
	move		x:f,a0
	jsr		RealMuls		; (s*f)
	move		#>256,a
	sub		b,a		x:v,x0
	move		a,y0
	mpy		x0,y0,a	#>64*256,x0
	move		a0,y0
	mpy		x0,y0,a
	move		a,x:q			; v*(256-(s*f))
	clr		b		#>1,a
	move		x:f,b0
	sub		b,a
	move		x:s,b
	jsr		RealMuls		; (s*(1.0-f))
	move		#>256,a
	sub		b,a		x:v,x0
	move		a,y0
	mpy		x0,y0,a	#>64*256,x0
	move		a0,y0
	mpy		x0,y0,a
	move		a,x:t			; v*(256-(s*(1.0-f)))
	move		x:i,n0
	move		#table,r0	
	move		#cmb,r4
	move		x:(r0+n0),r1
	move		#cmb,r0
	jmp		(r1)
casex	combine_rgb
	rts
	
case0	move		x:v,a
	move		a,x:red
	move		x:t,a
	move		a,x:grn
	move		x:p,a
	move		a,x:blu
	jmp		casex

case1	move		x:q,a
	move		a,x:red
	move		x:v,a
	move		a,x:grn
	move		x:p,a
	move		a,x:blu
	jmp		casex

case2	move		x:p,a
	move		a,x:red
	move		x:v,a
	move		a,x:grn
	move		x:t,a
	move		a,x:blu
	jmp		casex

case3	move		x:p,a
	move		a,x:red
	move		x:q,a
	move		a,x:grn
	move		x:v,a
	move		a,x:blu
	jmp		casex

case4	move		x:t,a
	move		a,x:red
	move		x:p,a
	move		a,x:grn
	move		x:v,a
	move		a,x:blu
	jmp		casex

case5	move		x:v,a
	move		a,x:red
	move		x:p,a
	move		a,x:grn
	move		x:q,a
	move		a,x:blu
	jmp		casex

;-----------------------------------------------------------------------*

Init:	bclr		#2,omr
	movep		#1,x:PBC			; enable HOST	

_mat	jclr		#0,x:<<HSR,_mat
	movep		x:<<HTX,a
	move		a,x:matcode

_val	jclr		#0,x:<<HSR,_val
	movep		x:<<HTX,a
	move		#>1,x0
	add		x0,a
	move		a,x:val
	
_nh	jclr		#0,x:<<HSR,_nh
	movep		x:<<HTX,a
	move		a,x:h
	move		a,x:nh
_ns	jclr		#0,x:<<HSR,_ns
	movep		x:<<HTX,a
	move		a,x:s
	move		a,x:ns
_nv	jclr		#0,x:<<HSR,_nv
	movep		x:<<HTX,a
	move		a,x:v
	move		a,x:nv
	jsr		combine_hsv
	move		y:cmb,x0
	move		x:red,a
	and		x0,a
	move		a,x:nred
	move		x:grn,a
	and		x0,a
	move		a,x:ngrn
	move		x:blu,a
	and		x0,a
	move		a,x:nblu

_mc	jclr		#0,x:<<HSR,_mc
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	move		x:h,a
	move		a,x:hmask
	move		x:s,a
	move		a,x:smask
	move		x:v,a
	move		a,x:vmask
	
_ht	jclr		#0,x:<<HSR,_ht
	movep		x:<<HTX,a
	tfr		a,b	a,x:hthresh

_st	jclr		#0,x:<<HSR,_st
	movep		x:<<HTX,a
	add		a,b	a,x:sthresh

_vt	jclr		#0,x:<<HSR,_vt
	movep		x:<<HTX,a
	add		a,b	a,x:vthresh

	move		#>255*3,x0
	cmp		x0,b	#>0,b
	jeq		_moff
	move		#>$FFFFFF,b
_moff	move		b,x:maskflag	

	move		x:hthresh,b	
	asr		b		x:hmask,a
	move		b1,b
	sub		b,a
	move		a,x:hoffset

	move		x:sthresh,b
	move		x:smask,a
	sub		b,a		#>0,x0
	tmi		x0,a
	move		a,x:smin
	move		x:smask,a
	add		b,a		#>255,x0
	cmp		x0,a
	tge		x0,a
	move		a,x:smax

	move		x:vthresh,b
	move		x:vmask,a
	sub		b,a		#>0,x0
	tmi		x0,a
	move		a,x:vmin
	move		x:vmask,a
	add		b,a		#>255,x0
	cmp		x0,a
	tge		x0,a
	move		a,x:vmax
	
_code	jclr		#0,x:<<HSR,_code
	movep		x:<<HTX,n0

	move		x:matcode,n1
	move		#>matrouts,r1
	nop
	move		y:(r1+n1),r2
	nop
	jmp		(r2)


;-----------------------------------------------------------------------*

Matrix:
	move		#>type,r0
	nop
	move		x:(r0+n0),r1
	nop
	jmp		(r1)
	
;-----------------------------------------------------------------------*
;	keep HUE, keep SAT, keep BRI							*
;-----------------------------------------------------------------------*

kH_kS_kB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read
	
;-----------------------------------------------------------------------*
;	keep HUE, keep SAT, replace BRI						*
;-----------------------------------------------------------------------*

kH_kS_rB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:nv,a
	move		a,x:v
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	keep HUE, replace SAT, keep BRI						*
;-----------------------------------------------------------------------*

kH_rS_kB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	jset		#0,x:error,_writ
	move		x:ns,a
	move		a,x:s
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	keep HUE, replace SAT, replace BRI						*
;-----------------------------------------------------------------------*

kH_rS_rB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	jset		#0,x:error,_go
	move		x:ns,a
	move		a,x:s
_go	move		x:nv,a
	move		a,x:v
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	replace HUE, keep SAT, keep BRI						*
;-----------------------------------------------------------------------*

rH_kS_kB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:nh,a
	move		a,x:h
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	replace HUE, keep SAT, replace BRI						*
;-----------------------------------------------------------------------*

rH_kS_rB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:nh,a
	move		a,x:h
	move		x:nv,a
	move		a,x:v
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	replace HUE, replace SAT, keep BRI						*
;-----------------------------------------------------------------------*

rH_rS_kB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:nh,a
	move		a,x:h
	move		x:ns,a
	move		a,x:s
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	replace HUE, replace SAT, replace BRI					*
;-----------------------------------------------------------------------*

rH_rS_rB:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:nh,a
	move		a,x:h
	move		x:ns,a
	move		a,x:s
	move		x:nv,a
	move		a,x:v
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

MakeMask:
_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	move		#>0,a
	jset		#0,x:mask,_writ
	move		#>-1,a
_writ	jclr		#1,x:<<HSR,_writ
	movep		a,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

Lighten:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:val,a
	jeq		_writ
	move		a,x1
	move		x:v,y1
	mpy		x1,y1,a
	move		a0,x1
	move		x:percshft,y1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a
	tlt		b,a
	move		x:v,b
	add		a,b		#>255,a
	cmp		a,b
	tgt		a,b
	move		b,x:v
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

Darken:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:val,a
	jeq		_writ
	move		a,x1
	move		x:v,y1
	mpy		x1,y1,a
	move		a0,x1
	move		x:percshft,y1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a
	tlt		b,a
	move		x:v,b
	sub		a,b		#>0,a
	tlt		a,b
	move		b,x:v
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

Saturate:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:error,_writ
	jset		#0,x:mask,_writ
	move		x:val,a
	jeq		_writ
	move		a,x1
	move		x:s,y1
	mpy		x1,y1,a
	move		a0,x1
	move		x:percshft,y1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a
	tlt		b,a
	move		x:s,b
	add		a,b		#>255,a
	cmp		a,b
	tgt		a,b
	move		b,x:s
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

Weaken:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	jsr		extract_hsv
	jset		#0,x:mask,_writ
	move		x:val,a
	jeq		_writ
	move		a,x1
	move		x:s,y1
	mpy		x1,y1,a
	move		a0,x1
	move		x:percshft,y1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a
	tlt		b,a
	move		x:s,b
	sub		a,b		#>0,a
	tlt		a,b
	move		b,x:s
	jsr		combine_hsv
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

Wash:

_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
	extract_rgb
	move		x:red,a
	move		x:nred,b
	sub		a,b		#>cmb,r0
	jeq		_rdon
	abs		b		b,x:0
	move		b,x1
	move		x:val,y1
	mpy		x1,y1,a	x:percshft,y1
	move		a0,x1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a		
	tlt		b,a
	jclr		#23,x:0,_rp
	neg		a
_rp	move		x:red,b
	add		a,b
	move		b,x:red
_rdon	move		x:grn,a
	move		x:ngrn,b
	sub		a,b		#>cmb,r4
	jeq		_gdon
	abs		b		b,x:0
	move		b,x1
	move		x:val,y1
	mpy		x1,y1,a	x:percshft,y1
	move		a0,x1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a		
	tlt		b,a
	jclr		#23,x:0,_gp
	neg		a
_gp	move		x:grn,b
	add		a,b
	move		b,x:grn
_gdon	move		x:blu,a
	move		x:nblu,b
	sub		a,b
	jeq		_bdon
	abs		b		b,x:0
	move		b,x1
	move		x:val,y1
	mpy		x1,y1,a	x:percshft,y1
	move		a0,x1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a		
	tlt		b,a
	jclr		#23,x:0,_bp
	neg		a
_bp	move		x:blu,b
	add		a,b
	move		b,x:blu
_bdon	combine_rgb	
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*

Air:
_read	jclr		#0,x:<<HSR,_read
	movep		x:<<HTX,y:col
_r2	jclr		#0,x:<<HSR,_r2
	movep		x:<<HTX,a
	tst		a	a,x:val
	jeq		_writ
	extract_rgb
	move		x:red,a
	move		x:nred,b
	sub		a,b		#>cmb,r0
	jeq		_rdon
	abs		b		b,x:0
	move		b,x1
	move		x:val,y1
	mpy		x1,y1,a	x:percshft,y1
	move		a0,x1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a		
	tlt		b,a
	jclr		#23,x:0,_rp
	neg		a
_rp	move		x:red,b
	add		a,b
	move		b,x:red
_rdon	move		x:grn,a
	move		x:ngrn,b
	sub		a,b		#>cmb,r4
	jeq		_gdon
	abs		b		b,x:0
	move		b,x1
	move		x:val,y1
	mpy		x1,y1,a	x:percshft,y1
	move		a0,x1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a		
	tlt		b,a
	jclr		#23,x:0,_gp
	neg		a
_gp	move		x:grn,b
	add		a,b
	move		b,x:grn
_gdon	move		x:blu,a
	move		x:nblu,b
	sub		a,b
	jeq		_bdon
	abs		b		b,x:0
	move		b,x1
	move		x:val,y1
	mpy		x1,y1,a	x:percshft,y1
	move		a0,x1
	mpyr		x1,y1,a	#>8,b
	cmp		b,a		
	tlt		b,a
	jclr		#23,x:0,_bp
	neg		a
_bp	move		x:blu,b
	add		a,b
	move		b,x:blu
_bdon	combine_rgb
_writ	jclr		#1,x:<<HSR,_writ
	movep		y:col,x:<<HTX
	jmp		_read

;-----------------------------------------------------------------------*
;	Real-number multiply {24:24}*{24:24}={24:24} (23~24 cycles)		*
;-----------------------------------------------------------------------*
;	a	=	48-Bit multiplier							*
;	b	=	48-Bit multiplicand						*
;	b	=	48-Bit quotient							*
;-----------------------------------------------------------------------*

RealMuls:
	abs		a	a1,y0
	eor		y0,b	a1,x1
	eor		y0,b	b1,x:0
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
	jclr		#23,x:0,_posi
	neg		b
_posi	rts

;-----------------------------------------------------------------------*
;	Floating-point divide (48-Bit/48-Bit > 48-Bit real)			*
;-----------------------------------------------------------------------*
;	a	=	48-Bit divisor  (Int:Frc)					*
;	b	=	48-Bit dividend (Int:Frc)					*
;	b	=	48-Bit quotient (Int:Frc)					*
;-----------------------------------------------------------------------*
Divs48_Real:
;-----------------------------------------------------------------------*
	move		r7,n7
	abs		a	a1,x0
	eor		x0,b	#>0,r3
	eor		x0,b	b1,x:0
	abs		b	#>2,r7
	rep		#9
_Na	norm		r3,a
	norm		r3,a
	jnn		_Na
	rep		#9
_Nb	norm		r7,b
	norm		r7,b
	jnn		_Nb
	move		r7,n3
	asr		b	a,x0
	andi		#$FE,ccr
	rep		#24
	div		x0,b
	clr		a	(r3)-n3
	move		b0,x0
	clr		b	r3,a2
	tst		a	x0,b0
	jlt		_L
	jgt		_R
	jclr		#23,x:0,_e
	neg		b	n7,r7
	rts
_L	neg		a
	rep		a2
	asl		b
	jclr		#23,x:0,_e
	neg		b	n7,r7
	rts
_R	rep		a2
	asr		b
	jclr		#23,x:0,_e
	neg		b
_e	move		n7,r7
	rts
