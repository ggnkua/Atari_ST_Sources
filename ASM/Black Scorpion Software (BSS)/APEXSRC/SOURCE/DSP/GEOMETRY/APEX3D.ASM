;-----------------------------------------------*
; DSP56001 Geometry-engine for Falcon030 (v1.0) *
;-----------------------------------------------*
; (C) Feb 1994 Black Scorpion software (BSS)    *
;-----------------------------------------------*
 nolist
;-----------------------------------------------*
	
PBC		=	$FFE0
HSR		=	$FFE9
HTX		=	$FFEB

;-----------------------------------------------*

lightsource	=	0		; 1=on 0=off
intensity	=	16

maxpoints	=	256

;-----------------------------------------------*

divsize	=	640

;-----------------------------------------------*

dspread		macro	var
_rd	jclr		#0,x:<<HSR,_rd
	movep		x:<<HTX,var
	endm

dspwrite		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	movep		var,x:<<HTX
	endm

	org		p:$0
	jmp		Init

;*----------------------------------------------------------------*
		org	y:0	; 2^k => MOD where MOD=9 : 2^4=16 , k=4
;*----------------------------------------------------------------*
Matrix:
Matrix11:	ds	1
Matrix21:	ds	1
Matrix31:	ds	1
Matrix12:	ds	1
Matrix22:	ds	1
Matrix32:	ds	1
Matrix13:	ds	1
Matrix23:	ds	1
Matrix33:	ds	1
;*----------------------------------------------------------------*
		org	y:16
;*----------------------------------------------------------------*
kx:		ds	1
px:		ds	1
ky:		ds	1
py:		ds	1
kz:		ds	1
pz:		ds	1
rx:		ds	1
ry:		ds	1
rz:		ds	1
;*----------------------------------------------------------------*
		org	y:32
;*----------------------------------------------------------------*
xe1:		ds	1
ye1:		ds	1
;*----------------------------------------------------------------*
		org	x:0
;*----------------------------------------------------------------*
temp:		ds	1
temp1:	ds	1
temp2:	ds	1
temp3:	ds	1
;*----------------------------------------------------------------*
		org	x:4
;*----------------------------------------------------------------*
X_scr:	ds	1
Y_scr:	ds	1
Z_scr:	ds	1
;*----------------------------------------------------------------*
		org	x:8
;*----------------------------------------------------------------*
d7:		ds	1
d6:		ds	1
d5:		ds	1
d4:		ds	1
d3:		ds	1
d2:		ds	1
d1:		ds	1
d0:		ds	1
;*----------------------------------------------------------------*
		org	x:16
;*----------------------------------------------------------------*
xe2:		ds	1
ye2:		ds	1
;*----------------------------------------------------------------*

sides:	dc	4
height:	ds	1
links:	ds	1

X_angle:	dc	0
Y_angle:	dc	0
Z_angle:	dc	0

coords:	dc	12
surfaces:	dc	20

rgb:		ds	1
counter:	ds	1
polycol:	ds	1
focus:	dc	250

clip_x1:	dc	0
clip_y1:	dc	0
clip_x2:	dc	319
clip_y2:	dc	199

Y_Min:	ds	1
Y_Max:	ds	1

polygon:	ds	2*12
clipped:	ds	2*12
clips:	ds	1

x_factor:	ds	1
y_factor:	ds	1

miny:		ds	1
maxy:		ds	1
miny2:	ds	1
maxy2:	ds	1
x_origin:	ds	1
y_origin:	ds	1

l_ebank1	dc	L_EBank1
r_ebank1	dc	R_EBank1

l_ebank2	dc	L_EBank2
r_ebank2	dc	R_EBank2

DivTab:	dc	0
		dc	0.9999999
over		=	2.0
		dup	divsize-1
		dc	1.0/over
over		=	over+1.0
		endm

L_EBank1:	ds	460
R_EBank1:	ds	460

L_EBank2:	ds	460
R_EBank2:	ds	460

X_in:		ds	maxpoints
Y_in:		ds	maxpoints
Z_in:		ds	maxpoints
S_in:

;*----------------------------------------------------------------*

	org		p:$40

;*----------------------------------------------------------------*
;*	Rotate source x,y,z using 9-element matrix			*
;*----------------------------------------------------------------*

;*----------------------------*
transform:
;*----------------------------*	
	move		#>256-1,x0				; sine masks
	move		#>64,x1
;*----------------------------------------------------------------*
;*	Access ROM sinewave and retrieve 24-bit sin/cos values	*
;*----------------------------------------------------------------*
	move		x:X_angle,a
	and		x0,a	#256,r1
	add		x1,a	a,n1
	and		x0,a	r1,r2
	move		a,n4
	move		x:Y_angle,a
	and		x0,a	r1,r3
	add		x1,a	a,n2
	and		x0,a	r1,r4
	move		a,n5
	move		x:Z_angle,a
	and		x0,a	r1,r5
	add		x1,a	a,n3
	and		x0,a	r1,r6
	move		a,n6
;*----------------------------------------------*
;*	Matrix part 1					*
;*----------------------------------------------*
	ori		#4,omr				; enable ROM
	move		y:(r5+n5),x0
	move		y:(r6+n6),y0
	mpyr		x0,y0,a		y:(r5+n5),x0
	move		a,y:Matrix11
;*----------------------------------------------*
	move		y:(r3+n3),y0
	mpyr		-x0,y0,a		y:(r2+n2),x0
	move		a,y:Matrix12
;*----------------------------------------------*
	move		x0,y:Matrix13
;*----------------------------------------------*
;*	Matrix part 2					*
;*----------------------------------------------*
	move		y:(r4+n4),x0
	move		y:(r3+n3),y0
	mpy		x0,y0,a	y:(r1+n1),x0
	move		y:(r2+n2),y0
	mpy		x0,y0,b	y:(r6+n6),x0
	move		b,y0
	macr		x0,y0,a	y:(r4+n4),x0
	move		a,y:Matrix21
;*----------------------------------------------*
	move		y:(r6+n6),y0
	mpy		x0,y0,a	y:(r1+n1),x0
	move		y:(r2+n2),y0
	mpy		x0,y0,b	y:(r3+n3),x0	
	move		b,y0
	macr		-x0,y0,a	y:(r1+n1),x0
	move		a,y:Matrix22
;*----------------------------------------------*
	move		y:(r5+n5),y0
	mpyr		-x0,y0,a	y:(r1+n1),x0
	move		a,y:Matrix23
;*----------------------------------------------*
;*	Matrix part 3					*
;*----------------------------------------------*
	move		y:(r3+n3),y0
	mpy		x0,y0,a	y:(r4+n4),x0
	move		y:(r2+n2),y0
	mpy		x0,y0,b	y:(r6+n6),x0
	move		b,y0
	macr		-x0,y0,a	y:(r1+n1),x0
	move		a,y:Matrix31
;*----------------------------------------------*
	move		y:(r6+n6),y0
	mpy		x0,y0,a	y:(r4+n4),x0
	move		y:(r2+n2),y0
	mpy		x0,y0,b	y:(r3+n3),x0
	move		b,y0
	macr		x0,y0,a	y:(r4+n4),x0		
	move		a,y:Matrix32
;*----------------------------------------------*
	move		y:(r5+n5),y0
	mpy		x0,y0,a
	move		a,y:Matrix33
	bclr		#2,omr				; disable ROM
;*----------------------------------------------*
;*	Set up transformation loop			*
;*----------------------------------------------*
	move		#X_in,r0
	move		#Y_in,r1
	move		#Z_in,r2
	move		#X_out,r4
	move		#Y_out,r5
	move		#Z_out,r6
	move		#X_scr,r3
	move		#>3-1,m3
	move		#Matrix,r7
	move		#>9-1,m7
;*----------------------------------------------*
;*	Transformation loop				*
;*----------------------------------------------*
	move		x:(r3)+,a
	move				x:(r0),x1	y:(r7)+,y0
	do		x:coords,_mlp
	mac		x1,y0,a	x:(r1),x1	y:(r7)+,y0
	mac		x1,y0,a	x:(r2),x1	y:(r7)+,y0
	macr		x1,y0,a	x:(r0),x1	y:(r7)+,y0
	move		x:(r3)+,a	a,y:(r4)+
	mac		x1,y0,a	x:(r1),x1	y:(r7)+,y0
	mac		x1,y0,a	x:(r2),x1	y:(r7)+,y0
	macr		x1,y0,a	x:(r0)+,x1	y:(r7)+,y0
	move		x:(r3)+,a	a,y:(r5)+
	mac		x1,y0,a	x:(r1)+,x1	y:(r7)+,y0
 	mac		x1,y0,a	x:(r2)+,x1	y:(r7)+,y0
	macr		x1,y0,a	x:(r0),x1	y:(r7)+,y0
	move		x:(r3)+,a	a,y:(r6)+
;*----------------------------------------------*
_mlp	move		#-1,m3
	move		#-1,m7
	rts

;*----------------------------------*
perspect:
;*----------------------------*	
	move		#X_out,r0
	move		#Y_out,r1
	move		#Z_out,r2
	move		x:x_factor,a
	move		a,x:0
	move		x:y_factor,a
	move		a,x:1
	do		x:coords,_plp
;*----------------------------*	
	move		x:focus,a
	clr		b		y:(r2)+,x0
	sub		x0,a		#>$FFFFFF,b0
	move		a,y0
	andi		#$FE,ccr
	rep		#24
	div		y0,b
	move		b0,y0
	mpy		x0,y0,a	y:(r0),x0
	move		a0,b
	asr		b		#>$7FFFFF,y1
	and		y1,b
	move		a,x1
	move		b1,y1
	mpy		x1,x0,b
	asr		b
	move		b0,b
	macr		y1,x0,b
	add		x0,b		x:x_origin,x0
	jclr		#1,x:0,_nx
	asl		b	
_nx	add		x0,b		y:(r1),x0
	move		b,y:(r0)+
	move		a0,b
	asr		b		#>$7FFFFF,y1
	and		y1,b
	move		a,x1
	move		b1,y1
	mpy		x1,x0,b
	asr		b
	move		b0,b
	macr		y1,x0,b
	add		x0,b		x:y_origin,x0
	jclr		#1,x:1,_ny
	asl		b	
_ny	neg		b
	add		x0,b
	move		b,y:(r1)+
_plp	rts

tree_up	=	0
tree_left	=	1
tree_rght	=	2
tree_face	=	3
tree_z	=	4

;*----------------------------------*
makelist:
;*----------------------------------*
	move		#>1,n0	; link-skip
	move		#>-1,a
	move		a,x:counter	; polygons
	move		#>6-1,m5
	move		#>2,n5
	move		#py,r5
	move		#S_in,r0	; source polys
	move		#treelist,r6
	do		x:surfaces,_next
;*----------------------------------*
	move		x:(r0)+,a
	move		r0,n6		; store face ptr
	move		x:(r0)+,a	; fetch link-count
	move		a,x:links
	move		r0,r7		; copy ptr
	move		a,n7		; copy count
	move		x:(r0)+,n2
	move		x:(r0)+,n3
	move		x:(r0)+,n1
	lua		(r7)+n7,r0
;*----------------------------------*
	move		#kx,r4	; scalar product matrix
	move		#X_out,r3
	move		#X_out,r2
	move		y:(r3+n3),a
	move		a,y:(r4)+
	move		y:(r2+n2),b	
	sub		b,a		#Y_out,r3
	move		a,y:(r4)+
	move		r3,r2
	move		y:(r3+n3),a
	move		a,y:(r4)+
	move		y:(r2+n2),b
	sub		b,a		#Z_out,r3
	move		a,y:(r4)+
	move		r3,r2
	move		y:(r3+n3),a
	move		a,y:(r4)+
	move		y:(r2+n2),b
	sub		b,a		#X_out,r1
	move		a,y:(r4)+
;*----------------------------------*
	move		#>3-1,m3
	move		r1,r2
	move		y:(r1+n1),a
	move		y:(r2+n2),b
	sub		b,a		#Y_out,r1
	move		a,x:d5
	move		r1,r2
	move		y:(r1+n1),a
	move		y:(r2+n2),b
	sub		b,a		#Z_out,r1
	move		a,x:d6
	move		r1,r2
	move		y:(r1+n1),a
	move		y:(r2+n2),b
	sub		b,a		#d7,r3	
	move		a,x:d7
;*----------------------------------*
	move				x:(r3)+,x0	y:(r5)+n5,y0
	mpy		x0,y0,a	x:(r3)+,x0	y:(r5)+n5,y0
	mac		-x0,y0,a	x:(r3)+,x0
	move		a0,y:(r4)+
	mpy		x0,y0,a	x:(r3)+,x0	y:(r5)+n5,y0
	mac		-x0,y0,a	x:(r3)+,x0
	move		a0,y:(r4)+
	mpy		x0,y0,a	x:(r3)+,x0	y:(r5),y0
	mac		-x0,y0,a	x:focus,b
	move		a0,y:(r4)+
	move		#>-1,m3
;*----------------------------------*
	move		y:kz,a
	sub		b,a		y:-(r4),y0
	move		a,x0
	mpy		x0,y0,a	y:-(r4),y0
	move		y:ky,x0
	mac		x0,y0,a	y:-(r4),y0
	move		y0,b
	move		y:kx,x0
	mac		x0,y0,a	#Z_out,r1	; get z-list
	tst		a		#>1,x1
	jlt		_skip
;*----------------------------------*
	if		lightsource
	rep		#(24-intensity)		; scale down intensity (really based on area)
	asr		b
	move		b,b
	neg		b		#>8,y0
	add		y0,b
	tst		b		#>16-1,y0
	jgt		_nmi
	move		#>1,b
_nmi	cmp		y0,b
	tge		y0,b
	move		b,x:rgb	; get RGB for lightsource
	endif
;*----------------------------------*
	clr		a		#>0,x0	
	do		x:links,_add		
	move		x:(r7)+,n1
	add		x0,a
	move		y:(r1+n1),x0
_add	add		x0,a		#DivTab,r1
	move		x:links,n1
	move		a,x0
	move		x:(r1+n1),y0
	mpy		x0,y0,a	x:counter,b
	add		x1,b		a,x0
	clr		a		b,x:counter
	tst		b
	jeq		_keep
;*----------------------------------*
	move		#>tree_z,n2
	move		#>tree_rght,n3
	move		#>tree_left,n7
	move		#>treelist,b
_loop	move		b,r2
	move		b,r3			; this node in r2/r3/r7
	move		y:(r2+n2),a		; fetch this-z
	cmp		x0,a	b,r7		; check against new-z
	jle		_rght
_left	move		y:(r7+n7),b
	tst		b	r7,a
	jne		_loop
	move		r6,y:(r7+n7)	; keep new node in previous branch
	jmp		_keep
_rght	move		y:(r3+n3),b
	tst		b	r7,a
	jne		_loop
	move		r6,y:(r3+n3)	; keep new node in previous branch
_keep	move		a,y:(r6)+		; keep previous node in new node
	move		b,y:(r6)+		; term left branch
	move		b,y:(r6)+		; term right branch
	move		n6,y:(r6)+		; face ptr
	move		x0,y:(r6)+		; new-z	
;*----------------------------------*
	if		lightsource
	move		n6,r2
	move		x:rgb,y0
	move		y0,x:-(r2)		; if lightsourced, force RGB
	endif
;*----------------------------------*
_skip	nop
_next	move		#-1,m5
	rts

;*----------------------------------*
polyfill:
;*----------------------------------*
	move		x:clip_y2,a
	move		a,x:Y_Min
	move		x:clip_y1,a
	move		a,x:Y_Max
	move		x:sides,a
	asl		a		#>(polygon-2),b
	add		b,a		#>2,n0
	move		a,r0
	move		#DivTab,r6		
	move		x:(r0)+,x0		; fetch x1
	move		x:(r0)+,y0		; fetch y1
	move		#polygon,r0
;*----------------------------------*
	do		x:sides,Edge
;*----------------------------------*
Loop:	move		x:Y_Min,a
	cmp		y0,a		x:(r0)+,x1		; fetch x2
	tge		y0,a
	move		a,x:Y_Min				; store as ymin
	move		x:Y_Max,a
	cmp		y0,a		x:(r0)+,y1		; fetch y2
	tle		y0,a
	move		a,x:Y_Max				; store as ymax

	move		x:miny,a
	cmp		y0,a					; fetch x2
	tge		y0,a
	move		a,x:miny				; store as ymin
	move		x:maxy,a
	cmp		y0,a					; fetch y2
	tle		y0,a
	move		a,x:maxy				; store as ymax

	lua		(r0)-n0,r0				; reset buffer
	move		y1,a
	move				x:r_ebank1,r3
	sub		y0,a		#R_XBank,r1		; A = DY
	jgt		Down					; right edge...
	jeq		Done					; horizontal line?
	neg		a		#L_XBank,r1		; left edge...
	move				x:l_ebank1,r3
	tfr		y0,b		y1,y0			; exchange x1,y1 <=> x2,y2
	tfr		x0,b		x1,x0
	move		b,x1

Up:	move		y0,n1
	move		y0,n3
	move		a,n6					; set up div-index
	lua		(r1)+n1,r7				; get to start of edge
	lua		(r3)+n3,r3				; get to start of edge
	move		x1,b					; B = X2	
	move		a,x:height				; store height
	sub		x0,b	x:(r6+n6),y1		; B = DX (X2-X1)
	move		b,x1					; X1 = width
	mpy		x1,y1,b	x0,a			; DX = DX * (1/DY)
	move		b0,x0
	move		b1,x1
	do		x:height,_hl
	move			x:(r3),b
	cmp		a,b
	tge		a,b
	add		x,a	b,x:(r3)+	a,y:(r7)+
_hl	jmp		Done

Down:	move		y0,n1
	move		y0,n3
	move		a,n6					; set up div-index
	lua		(r1)+n1,r7				; get to start of edge
	lua		(r3)+n3,r3				; get to start of edge
	move		x1,b					; B = X2	
	move		a,x:height				; store height
	sub		x0,b	x:(r6+n6),y1		; B = DX (X2-X1)
	move		b,x1					; X1 = width
	mpy		x1,y1,b	x0,a			; DX = DX * (1/DY)
	move		b0,x0
	move		b1,x1
	do		x:height,_hl
	move			x:(r3),b
	cmp		a,b
	tle		a,b
	add		x,a	b,x:(r3)+	a,y:(r7)+
_hl

Done:	move		x:(r0)+,x0				; fetch x1
	move		x:(r0)+,y0				; fetch y1
;*----------------------------------*
;	Send lines to host		*
;*----------------------------------*
Edge:	move		x:Y_Min,a
	move		x:Y_Max,b
	sub		a,b		a,n5
	jle		_line
	dspwrite	b					; height
	dspwrite	a					; start-y
	dspwrite	x:rgb					; colour
	move		b,x:height
	move		#>L_XBank,r5
	move		#>R_XBank,r7
	move		a,n7
	lua		(r5)+n5,r5
	lua		(r7)+n7,r7
;*----------------------------------*
	do		x:height,_line
	dspwrite	y:(r5)+
	dspwrite	y:(r7)+
_line	rts

save_vertex:
	move		#>1,x1
	add		x1,b		y:(r7)+,a
	move		a,x:(r1)+	y:(r7)+,a
	move		a,x:(r1)+
	rts

;*----------------------------------*
polyclip:	
;*----------------------------------*
	move		#DivTab,r6
	move		#>xe2,r3
	move		#>xe1,r7
	move		#2-1,m3
	move		#2-1,m7
	
polyclip_x1
	clr		b	x:sides,a
	move		b,x:sides
	move		b,x:clips
	tst		a	a,x1
	jeq		_edge
	asl		a	#polygon,r0
	move		#>(polygon-2),b
	add		b,a
	clr		b	a,r1
	move		x:clip_x1,x0
	move		x:(r1)+,a
	move		x:(r1)+,a	a,y:(r7)+
	move				a,y:(r7)+
	move		#clipped,r1
	do		x1,_edge
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		y:xe1,a
	cmp		x0,a
	jmi		_p1_outside
	move		x:xe2,a
	cmp		x0,a
	jmi		_clip_p2
_all_inside
	jsr		save_vertex
	jmp		_next
_p1_outside
	move		x:xe2,a
	cmp		x0,a
	jmi		_next
_clip_p1
	jsr		intersect_x
	jmp		_next
_clip_p2
	jsr		save_vertex
	jsr		intersect_x
_next	move		x:(r3)+,a
	move		x:(r3)+,a	a,y:(r7)+
	move				a,y:(r7)+
_edge	move		b,x:clips

polyclip_y1
	clr		b	x:clips,a
	move		b,x:clips
	move		b,x:sides
	tst		a	a,x1
	jeq		_edge
	asl		a	#clipped,r0
	move		#>(clipped-2),b
	add		b,a
	clr		b	a,r1
	move		x:clip_y1,x0
	move		x:(r1)+,a
	move		x:(r1)+,a	a,y:(r7)+
	move				a,y:(r7)+
	move		#polygon,r1
	do		x1,_edge
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		y:ye1,a
	cmp		x0,a
	jmi		_p1_outside
	move		x:ye2,a
	cmp		x0,a
	jmi		_clip_p2
_all_inside
	jsr		save_vertex
	jmp		_next
_p1_outside
	move		x:ye2,a
	cmp		x0,a
	jmi		_next
_clip_p1
	jsr		intersect_y
	jmp		_next
_clip_p2
	jsr		save_vertex
	jsr		intersect_y
_next	move		x:(r3)+,a
	move		x:(r3)+,a	a,y:(r7)+
	move				a,y:(r7)+
_edge	move		b,x:sides

polyclip_x2	
	clr		b	x:sides,a
	move		b,x:sides
	move		b,x:clips
	tst		a	a,x1
	jeq		_edge
	asl		a	#polygon,r0
	move		#>(polygon-2),b
	add		b,a
	clr		b	a,r1
	move		x:clip_x2,x0
	move		x:(r1)+,a
	move		x:(r1)+,a	a,y:(r7)+
	move				a,y:(r7)+
	move		#clipped,r1
	do		x1,_edge	
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		y:xe1,a
	cmp		x0,a
	jgt		_p1_outside
	move		x:xe2,a
	cmp		x0,a
	jgt		_clip_p2
_all_inside
	jsr		save_vertex
	jmp		_next
_p1_outside
	move		x:xe2,a
	cmp		x0,a
	jgt		_next
_clip_p1
	jsr		intersect_x
	jmp		_next
_clip_p2
	jsr		save_vertex
	jsr		intersect_x
_next	move		x:(r3)+,a
	move		x:(r3)+,a	a,y:(r7)+
	move				a,y:(r7)+
_edge	move		b,x:clips

polyclip_y2	
	clr		b	x:clips,a
	move		b,x:clips
	move		b,x:sides
	tst		a	a,x1
	jeq		_edge
	asl		a	#clipped,r0
	move		#>(clipped-2),b
	add		b,a
	clr		b	a,r1
	move		x:clip_y2,x0
	move		x:(r1)+,a
	move		x:(r1)+,a	a,y:(r7)+
	move				a,y:(r7)+
	move		#polygon,r1
	do		x1,_edge
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		x:(r0)+,a
	move		a,x:(r3)+
	move		y:ye1,a
	cmp		x0,a
	jgt		_p1_outside
	move		x:ye2,a
	cmp		x0,a
	jgt		_clip_p2
_all_inside
	jsr		save_vertex
	jmp		_next
_p1_outside
	move		x:ye2,a
	cmp		x0,a
	jgt		_next
_clip_p1
	jsr		intersect_y
	jmp		_next
_clip_p2
	jsr		save_vertex
	jsr		intersect_y
_next	move		x:(r3)+,a
	move		x:(r3)+,a	a,y:(r7)+
	move				a,y:(r7)+
_edge	move		b,x:sides
	move		#-1,m3
	move		#-1,m7
	rts

;*----------------------------------*
intersect_x
;*----------------------------------*
	move		x0,x:(r1)+
	move		y:xe1,x1
	move		x:xe2,a
	cmp		x1,a	b,x:temp2
	jge		_clip
	tfr		x0,a	x:xe2,x1
	sub		x1,a	y:xe1,b
	move		a,y0
	sub		x1,b	y:ye1,a
	move		b,x1
	move		x:ye2,y1
	sub		y1,a
	move		a,y1
	jsr		intersect
	move		x:ye2,y1
	add		y1,a	x:temp2,b
	add		x1,b	a,x:(r1)+
	rts
_clip	tfr		x0,a	y:xe1,x1
	sub		x1,a	x:xe2,b
	move		a,y0
	sub		x1,b	x:ye2,a
	move		b,x1
	move		y:ye1,y1
	sub		y1,a
	move		a,y1
	jsr		intersect
	move		y:ye1,y1
	add		y1,a	x:temp2,b
	add		x1,b	a,x:(r1)+
	rts

;*----------------------------------*
intersect_y
;*----------------------------------*
	move		y:ye1,x1
	move		x:ye2,a
	cmp		x1,a	b,x:temp2
	jge		_clip
	tfr		x0,a	x:ye2,x1
	sub		x1,a	y:ye1,b
	move		a,y0
	sub		x1,b	y:xe1,a
	move		b,x1
	move		x:xe2,y1
	sub		y1,a
	move		a,y1
	jsr		intersect
	move		x:xe2,y1
	add		y1,a	x:temp2,b
	add		x1,b	a,x:(r1)+
	move		x0,x:(r1)+
	rts
_clip	tfr		x0,a	y:ye1,x1
	sub		x1,a	x:ye2,b
	move		a,y0
	sub		x1,b	x:xe2,a
	move		b,x1
	move		y:xe1,y1
	sub		y1,a
	move		a,y1
	jsr		intersect
	move		y:xe1,y1
	add		y1,a	x:temp2,b
	add		x1,b	a,x:(r1)+
	move		x0,x:(r1)+
	rts

;*----------------------------------*
intersect
;*----------------------------------*
	mpy		y0,y1,a	#>divsize-1,y1
	eor		x1,a		x1,b
	abs		b		a,x:0
	eor		x1,a		b,n6
	abs		a		#>1,x1
	cmp		y1,b		b,y1
	jge		_big
	asr		a		x:(r6+n6),x1
	move		a0,y1
	mpy		x1,y1,a	#>1,x1
	jclr		#23,x:0,_pos
	neg		a
	rts
_big	andi		#$FE,ccr
	rep		#24
	div		y1,a
	move		a0,a
	jclr		#23,x:0,_pos
	neg		a
_pos	rts

;*----------------------------------*
polyloop:
;*----------------------------------*
	jsr		clear_ebuffer
	move		x:miny,a
	move		a,x:miny2
	move		x:maxy,a
	move		a,x:maxy2
	move		x:clip_y2,a
	move		a,x:miny
	move		x:clip_y1,a
	move		a,x:maxy
	move		#>tree_left,n7
	move		#>tree_rght,n5
	move		#>tree_face,n4
	move		x:counter,a
	tst		a	#>tree_up,n0
	jmi		_exit
	clr		a	#>treelist,b	
_next	move		b,r7
	move		b,r5
	move		y:(r7+n7),b		; check left branch
	tst		b	r7,r4
	jne		_left
	move		y:(r4+n4),r6	; get face address
	move		#X_out,r2
	move		r6,r3
	move		x:(r6)+,x0		; get number of sides
	move		x0,x:sides
	move		x:-(r3),x1
	move		x1,x:rgb
	move		#polygon,r1
	move		#Y_out,r3
	do		x0,_edge
	move		x:(r6)+,n2		; xi
	move		n2,n3			; yi
	move		y:(r2+n2),x1
	move		x1,x:(r1)+
	move		y:(r3+n3),x1
	move		x1,x:(r1)+
;*----------------------------------*
_edge	move		r7,x:d7
;*----------------------------------*
	jsr		polyclip
	move		x:sides,a
	move		#>3,x0
	cmp		x0,a
	jlt		_skip
	jsr		polyfill
;*----------------------------------*
_skip	move		#>tree_left,n7
	move		#>tree_rght,n5
	move		#>tree_face,n4
	clr		a	#>tree_up,n0
	move		x:d7,r5
	move		r5,r7
;*----------------------------------*
	move		y:(r5+n5),b		; check right branch
	tst		b	r7,r0
	jne		_rght
	move		y:(r0+n0),b		; retreat to parent
	tst		b
	jne		_next
_exit	move		#>-1,a
	dspwrite	a	
	rts	
_left	move		a,y:(r7+n7)			; kill left branch
	jmp		_next
_rght	move		a,y:(r5+n5)			; kill rght branch
	move		n0,n6
	move		b,r6
	move		y:(r0+n0),x0
	move		x0,y:(r6+n6)
	jmp		_next

clear_ebuffer:
	move		#>-1,m0
	move		#>-1,m1
	move		x:clip_y1,a
	move		x:l_ebank1,b
	add		a,b
	move		b,r0
	move		x:r_ebank1,b
	add		a,b
	move		b,r1
	move		x:clip_y2,b
	sub		a,b	#>1,x1
	add		x1,b
	move		x:clip_x2,x0
	move		x:clip_x1,x1
	do		b,_clr
	move		x0,x:(r0)+
	move		x1,x:(r1)+
_clr	rts

send_ebuffer:
	move		#>-1,m0
	move		#>-1,m1
	move		#>-1,m2
	move		#>-1,m3
	move		x:miny2,a
	dspwrite	a
	move		x:l_ebank1,b
	add		a,b
	move		b,r0
	move		x:r_ebank1,b
	add		a,b
	move		b,r1
	move		x:l_ebank2,b
	add		a,b
	move		b,r2
	move		x:r_ebank2,b
	add		a,b
	move		b,r3
	move		x:maxy2,b
	sub		a,b
	dspwrite	b
	tst		b
	jle		_clr
	do		b,_clr

;	dspwrite	x:(r0)+	;l1
;	dspwrite	x:(r1)+	;r1

	dspwrite	x:(r2)+	;l2
	dspwrite	x:(r0)+	;l1
	dspwrite	x:(r1)+	;r1
	dspwrite	x:(r3)+	;r2

_clr	move		x:l_ebank1,a
	move		x:l_ebank2,b
	move		b,x:l_ebank1
	move		a,x:l_ebank2

	move		x:r_ebank1,a
	move		x:r_ebank2,b
	move		b,x:r_ebank1
	move		a,x:r_ebank2

	rts
	
;*----------------------------------------------------------------*

Init:	dspread	x:clip_x1
	dspread	x:clip_y1
	dspread	x:clip_x2
	dspread	x:clip_y2
	dspread	x:x_origin
	dspread	x:y_origin
	dspread	x:x_factor
	dspread	x:y_factor
	move		x:clip_y2,a
	move		a,x:miny
	move		a,x:miny2
	move		x:clip_y1,a
	move		a,x:maxy
	move		a,x:maxy2
	dspread	x:coords
	move		#X_in,r0
	do		x:coords,_ex
	dspread	x:(r0)+
_ex	move		#Y_in,r0
	do		x:coords,_ey
	dspread	x:(r0)+
_ey	move		#Z_in,r0
	do		x:coords,_ez
	dspread	x:(r0)+
_ez	dspread	x:surfaces
	move		#S_in,r0
	do		x:surfaces,_es
	dspread	x:(r0)+
	dspread	a
	move		a,x:(r0)+
	do		a,_ee
	dspread	x:(r0)+
_ee	nop
_es
	move		#>L_EBank2,a
	move		a,x:l_ebank1
	move		a,x:l_ebank2
	move		#>R_EBank2,a
	move		a,x:r_ebank1
	move		a,x:r_ebank2
	jsr		clear_ebuffer
	move		#>L_EBank1,a
	move		a,x:l_ebank1
	move		#>R_EBank1,a
	move		a,x:r_ebank1
	jsr		clear_ebuffer

;*----------------------------------------------------------------*
;*	main geometry engine loop						*
;*----------------------------------------------------------------*

Main:	dspread	a
	tst		a
	jeq		_draw
	jsr		send_ebuffer
	jmp		Main
_draw	dspread	x:X_angle
	dspread	x:Y_angle
	dspread	x:Z_angle
	dspread	x:X_scr
	dspread	x:Y_scr
	dspread	x:Z_scr
	jsr		transform
	jsr		makelist
	jsr		perspect
	jsr		polyloop
	jmp		Main	

;*----------------------------------------------------------------*
endcode:
;*----------------------------------------------------------------*
var		=	endcode
;*----------------------------------------------------------------*
		org	y:var
;*----------------------------------------------------------------*

L_XBank:	ds	460
R_XBank:	ds	460

X_out:	ds	maxpoints
Y_out:	ds	maxpoints
Z_out:	ds	maxpoints
treelist:
