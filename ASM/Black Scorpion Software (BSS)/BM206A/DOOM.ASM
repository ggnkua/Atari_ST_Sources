
	nolist

;*======================================================*
;*	DSP Doom core: latest update 23/02/96		*
;*======================================================*
;*	Perform all intensive & mathematical jobs	*
;*======================================================*

PBC			=	$FFE0
HCR			=	$FFE8
HSR			=	$FFE9
HTX			=	$FFEB

;-------------------------------------------------------*

runlink			=	0			; linked run structure
rundata			=	1
runsize			=	2

zmin			=	12			; viewplane z

;-------------------------------------------------------*

	include		"i:\projects\bad_mood\68030\include\dspconst.s"

;-------------------------------------------------------*
	org		y:0
;-------------------------------------------------------*
;	Temp register for floor mapping function	*
;-------------------------------------------------------*

map_data:
map_xi:			ds	1
map_x:			ds	1
map_yi:			ds	1
map_x1:			ds	1
map_v:			ds	1
map_xo:			ds	1
map_uvs:		ds	1
map_sinauvs:		ds	1
map_cosauvs:		ds	1

;-------------------------------------------------------*
	org		x:0
;-------------------------------------------------------*
;	General temp registers				*
;-------------------------------------------------------*

temp1:			ds	1
temp2:			ds	1

;-------------------------------------------------------*
	org		l:2
;-------------------------------------------------------*
;	Wall upper / lower edge accumulators		*
;-------------------------------------------------------*

edge_increments:	
y1_increment:		ds	1	; 24:24
y1_accumulator:		ds	1	; 24:24
y2_increment:		ds	1	; 24:24
y2_accumulator:		ds	1	; 24:24
t_increment:		ds	1	; 24:24
t_accumulator:		ds	1	; 24:24

;-------------------------------------------------------*
;	org		x:8
;-------------------------------------------------------*
;	Upper-edge clipping registers			*
;-------------------------------------------------------*

column_thistop:		ds	1
column_lasttop:		ds	1

;-------------------------------------------------------*
	org		l:10
;-------------------------------------------------------*
;	Multi-purpose (overlapping) registers		*
;-------------------------------------------------------*

vertices:						; vertex array for nodes
vertex1:
ctop_z:			ds	1			; ceiling top-z
cbot_z:			ds	1			; ceiling bot-z
vertex2:
ftop_z:			ds	1			; floor top-z
fbot_z:			ds	1			; floor bot-z
vertex3:
t:			ds	1			; t-factor
ti:			ds	1			; t-factor increment
vertex4:
			ds	1
			ds	1

;-------------------------------------------------------*
	org		x:18
;-------------------------------------------------------*

;=======================================================*
;	X buffers					*
;=======================================================*

;-------------------------------------------------------*
;	Floor left-edge generation stack		*
;-------------------------------------------------------*

flatstack:		ds	256

line_regs:
line_x1:		ds	1
line_y1:		ds	1
line_x2:		ds	1
line_y2:		ds	1

;-------------------------------------------------------*
;	Wall upper-edge clipping array			*
;-------------------------------------------------------*

miny:			ds	320+1

;-------------------------------------------------------*
;	Remaining space used for run storage		*
;-------------------------------------------------------*

runs:

;-------------------------------------------------------*
	org		y:8
;-------------------------------------------------------*
;	Lower-edge clipping registers			*
;-------------------------------------------------------*

column_thisbot:		ds	1
column_lastbot:		ds	1

;-------------------------------------------------------*
	org		y:18
;-------------------------------------------------------*
	
;-------------------------------------------------------*
;	Frequently used constants			*
;-------------------------------------------------------*

x1_msk:			dc	$000FFF			; x2:x1 run separator mask (x1)
x2_msk:			dc	$FFF000			; x2:x1 run separator mask (x2)
column_rout:		dc	perspected_column	; pointer to correct column routine
one:			dc	$000001			; quick-immediate #>1,??
two:			dc	$000002			; quick-immediate #>2,??
viewplane:		dc	zmin			; clipping plane z
pnorm:			dc	1<<((6+7+8+8)-24-1)	; evaluated constant for mapping function

;-------------------------------------------------------*
;	Single-cycle shift constants			*
;-------------------------------------------------------*

rshft19:
lshft5:			dc	(1<<(5-1))
rshft18:
lshft6:			dc	(1<<(6-1))
rshft17:
lshft7:			dc	(1<<(7-1))
rshft16:
lshft8:			dc	(1<<(8-1))
rshft14:
lshft10:		dc	(1<<(10-1))
rshft13:
lshft11:		dc	(1<<(11-1))
rshft12:
lshft12:		dc	(1<<(12-1))
rshft9:
lshft15:		dc	(1<<(15-1))
rshft8:
lshft16:		dc	(1<<(16-1))
rshft7:
lshft17:		dc	(1<<(17-1))
rshft6:
lshft18:		dc	(1<<(18-1))
rshft5:
lshft19:		dc	(1<<(19-1))

;-------------------------------------------------------*
;	Frequently used pointers & addresses		*
;-------------------------------------------------------*

HTX_ptr:		dc	HTX			; host port
flatstack_ptr:		dc	flatstack		; run stack
lastslots_ptr:		dc	lastslots		; linked run last-slot addresses
rundata_ptr:		dc	(runs+rundata)		; run buffer (runs)
runlink_ptr:		dc	(runs+runlink)		; run buffer (links)
x1list_ptr:		dc	x1list			; run x1 merge-list
x2list_ptr:		dc	x2list			; run x2 merge-list
oslist_ptr:		dc	oslist			; run offset list
tlist_ptr:		dc	tlist			; run tracking list

;-------------------------------------------------------*
;	Frequently used variables			*
;-------------------------------------------------------*

index:			ds	1			; floating index for linked runs
columns:		ds	1			; total columns occluded so far
attributes:		ds	1			; wall attributes

window_regs:
width:			ds	1			; variables describing viewport
hwid:			ds	1
height:			ds	1
hhig:			ds	1
r_height:		ds	1
hs_width:		ds	1
vs_width:		ds	1

ceiling_bounds:
ctop:			ds	1			; ceiling bounding box
cbot:			ds	1

floor_bounds:
ftop:			ds	1			; floor bounding box
fbot:			ds	1

noderegs:
node_y2:		ds	1			; node array
node_y1:		ds	1
node_x1:		ds	1
node_x2:		ds	1

node_imin:		ds	1			; node bounding box
node_imax:		ds	1

px:			ds	1			; player information
py:			ds	1
pangle:			ds	1
sina:			ds	1
cosa:			ds	1

map_tnorm:		ds	1			; normalizing constant for mapping

wall_u:			ds	1			; wall mapping description variables
wall_umag:		dc	128
wall_vmag:		dc	128
wall_usize:		dc	128
wall_vsize:		dc	128
wall_uoff:		ds	1
wall_voff:		ds	1

wall_sz:		ds	1			; wall mapping function variables
wall_fsz:		ds	1
wall_dz:		ds	1
wall_fdz:		ds	1

mlum2:			ds	1
mlum3:			ds	1
mlum_limit:		dc	64-1
z:			ds	1

ci1:			ds	1			; wall x-bounds
ci2:			ds	1

wall_z1:		ds	1			; wall z-bounds
wall_z2:		ds	1

cy:			ds	1			; ceiling y-bounds
cj1:			ds	1
cj2:			ds	1
fy:			ds	1			; floor y-bounds
fj1:			ds	1
fj2:			ds	1

run_ptr:		ds	1			; floating run pointer
ceiling_luminance:	ds	1
floor_luminance:	ds	1

hwid_8:			ds	1

;=======================================================*
;	Y buffers					*
;=======================================================*

;-------------------------------------------------------*
;	Wall lower-edge clipping array			*
;-------------------------------------------------------*

maxy:			ds	320+1

;-------------------------------------------------------*
;	DSP host commands				*
;-------------------------------------------------------*

commands:		dc	AddMidWall
			dc	AddUpperWall
			dc	AddLowerWall
			dc	ResizeWindow
			dc	NewScene
			dc	NewSsector
			dc	GetSsector
			dc	NodeInCone
			dc	RotateMap
			dc	LinearCalc
			dc	PerspectCalc
			dc	SetLuminance
			dc	ProjectWall

;-------------------------------------------------------*
;	Octant elimination routines			*
;-------------------------------------------------------*

octs:			dc	oct_2
			dc	oct_3
			dc	oct_4
			dc	oct_5
			dc	oct_6
			dc	oct_7
			dc	oct_0
			dc	oct_1

;-------------------------------------------------------*
;	Synthesized polygon definition for nodes	*
;-------------------------------------------------------*

linedefs:		dc	vertex1,vertex2,vertex3,vertex4,vertex1

;-------------------------------------------------------*
end_iy:
;-------------------------------------------------------*

;-------------------------------------------------------*
;	DSP / Host communication macros			*
;-------------------------------------------------------*

dspread_s		macro
_rd	jclr		#0,x:<<HSR,_rd
	move		x:(r7),n7
	move		n7,a
	jclr		#15,n7,_sk
	add		b,a
_sk:	
	endm

dspread_u		macro	acc
_rd	jclr		#0,x:<<HSR,_rd
	move		x:(r7),n7
	move		n7,acc
	endm

dspread			macro	var
_rd	jclr		#0,x:<<HSR,_rd
	movep		x:<<HTX,var
	endm

dspwrite		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	movep		var,x:<<HTX
	endm

dspwaitread		macro
_rd	jclr		#0,x:<<HSR,_rd
	endm

dspwaitwrite		macro
_wr	jclr		#1,x:<<HSR,_wr
	endm

;-------------------------------------------------------*
;	Wall edge generator				*
;-------------------------------------------------------*

advance_column			macro
	move			l:y1_increment,a
	move			l:y1_accumulator,b
	add		a,b	l:y2_increment,a
	move			b,l:y1_accumulator
	move			l:y2_accumulator,b
	add		a,b	l:t_increment,a
	move			b,l:y2_accumulator
	move			l:t_accumulator,b
	add		a,b	n0,a
	move			y:one,x0
	add		x0,a	b,l:t_accumulator
	move		a,n0
	move		a,n4
	endm

;-------------------------------------------------------*
;	Wall edge top / bottom clipper			*
;-------------------------------------------------------*
;	thisminy	x:(r0+n0)
;	thismaxy	y:(r4+n4)
;	lastminy	x:(r0)
;	lastmaxy	y:(r4)
;	thistop		x:(r3)
;	thisbot		y:(r5)
;	lasttop		x:(r3+n3)
;	lastbot		y:(r5+n5)
;-------------------------------------------------------*

load_column			macro
	move			#0,x0
	move			x:y1_accumulator,a
	cmp		x0,a	y:(r4+n4),x1
	tmi		x0,a
	cmp		x1,a	x:(r0+n0),x0
	tpl		x1,a
	move		a,y0
	move			x:y2_accumulator,a
	cmp		x0,a	y:height,x1
	tmi		x0,a
	cmp		x1,a	(r7)+
	tpl		x1,a
	move		a,y1
	endm

;-------------------------------------------------------*
	org		p:0
;-------------------------------------------------------*
	jmp		start
;-------------------------------------------------------*
	org		p:64
;-------------------------------------------------------*

;-------------------------------------------------------*
;	Complete section of floor or ceiling		*
;-------------------------------------------------------*
end_flat:
;-------------------------------------------------------*
	move		a,n6
	move		b,n2	
	add		a,b	y:(r1)+,x0
	cmp		x0,a	y:(r1)-,x1
	tpl		x0,a
	cmp		x1,b	a,y:(r1)+
	tmi		x1,b
	move			b,y:(r1)
;-------------------------------------------------------*
	move		y:flatstack_ptr,r6
	move		y0,x:temp1		; store old ytop
	lua		(r6)+n6,r1
	move		y:lastslots_ptr,r6
	move		n0,x0
	move		y:lshft12,x1
	mpy		x0,x1,b		(r6)+n6
	move		b0,b			; b = (x2<<12)
	move		y:x2_msk,y0		; x0 = x2:x1 mergemask 
	move		y:two,x0
	move		r7,n6			; store old occlusion-list
	move		y:rundata_ptr,r7	
	move		y:index,a
	do		n2,_vert
	move					y:(r6),n2	; lastindex = lastslot(y)
	and		y0,b	x:(r1)+,x1	a,y:(r6)+	; fetch x1 : lastslot(y) = index
	or		x1,b	a,n7				; rundata = ((x2<<12)|x1)
	move			a1,x:(r2+n2)			; runs(lastslot(y)(next)) = index
	add		x0,a	b1,x:(r7+n7)			; runs(index(data)) = rundata : index+runsize
_vert:	move		a,y:index
	move		n6,r7			; store old occlusion-list
	move		x:temp1,y0		; store old ytop
	rts

;-------------------------------------------------------*
;	Generate & defragment a section of floor	*
;-------------------------------------------------------*
getflatarea:
;-------------------------------------------------------*
	jsr		new_luminance
	move		y:runlink_ptr,r2		; slotlink
	move		y:rundata_ptr,r3		; slotdata
	move		y:two,n1
	move		y:lastslots_ptr,r5	
	move		y:HTX_ptr,r7
;-------------------------------------------------------*
	move				y:(r0),b
	dspwaitwrite
	tfr		b,a		b,x:(r7)	; [zone_start]
	asl		b		a,n5
	move				b,n2
	move				y:(r4),b
	sub		a,b		#0,x0
	tmi		x0,b
	dspwaitwrite
	tst		b		b,x:(r7)	; [zone_lines]
	jeq		_vert
;-------------------------------------------------------*
	lua		(r2)+n2,r1			; firstlink
	lua		(r5)+n5,r5			; lastslot
	move		y:x1list_ptr,r0
	move		y:x2list_ptr,r4
;-------------------------------------------------------*
	do		b,_vert
;-------------------------------------------------------*
_runs:	move				y:(r5)+,n2	; ls=lastslot(y)
	clr		a		x:(r1)+n1,y1	; fs=firstslot(y) : next firstslot-y
	clr		b		a0,x:(r2+n2)	; runs(ls(link)) = 0
	cmp		y1,a		y1,n2		; check for slot terminator
	jeq		_get_runs			; repeat until slots exhausted for this (y)
;-------------------------------------------------------*
	move				x:t,x0
	move				y:two,a
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,x1
	move				y:pnorm,x0
	mpy		x0,x1,a		y:tlist_ptr,r6
	move				a0,y:z
;-------------------------------------------------------*
_slots:
;-------------------------------------------------------*
	move		n2,n3
	move				y:x1_msk,a	; x-mask
	move				x:(r3+n3),x0	; x2x1 rundata
	and		x0,a		y:lshft12,x1
	mpy		x0,x1,a		a1,x0
	cmp		x0,a		a1,x1
	jle		_end_add
;-------------------------------------------------------*
;	Floor defragmentation algorithm			*
;-------------------------------------------------------*
_add_run:
;-------------------------------------------------------*
	move				y:oslist_ptr,r7
	move				x1,n0
	move				x0,n4
	move				x0,y:(r0+n0)	; x1list(x2c) = x1c
	move				x1,y:(r4+n4)	; x2list(x1c) = x2c
	move				y:one,a
	move				x0,n0
	move				x1,n4
	move				y:(r0+n0),y0	; x1l = x1list(x1c)
	cmp		y0,a		y:(r4+n4),y1	; x2r = x2list(x2c)
	jle		_left
	cmp		y1,a
	jle		_rightonly
;-------------------------------------------------------*
_addnormal:
;-------------------------------------------------------*
	move				x0,n7
	move				b1,n6
	add		a,b		b1,y:(r7+n7)	; os(x1) = index
	move				x0,y:(r6+n6)	; track(index) = x1
	jmp		_end_add
;-------------------------------------------------------*
_left:	move				x1,n0
	move				y0,n4
	move				y0,y:(r0+n0)	; x1list(x2c) = x1l
	move				x1,y:(r4+n4)	; x2list(x1l) = x2c
	move				x0,n4
	move				x0,n0
	move				a0,y:(r4+n4)	; x2list(x1c) = 0		
	move				x1,n4
	move				a0,y:(r0+n0)	; x1list(x1c) = 0				
	move				y:(r4+n4),y1	; x2r = x2list(x2c)
	cmp		y1,a		y0,x0		; x1c = x1l
	jgt		_leftonly
;-------------------------------------------------------*
_both:
;-------------------------------------------------------*
	move				x0,n4
	move				y1,n0
	move				y1,y:(r4+n4)	; x2list(x1c) = x2r
	move				x0,y:(r0+n0)	; x1list(x2r) = x1c
	move				x1,n4
	move				x1,n0
	sub		a,b		a0,y:(r4+n4)	; x2list(x2c) = 0
	move				x1,n7
	move				b1,n6
	move				y:(r7+n7),x0	; index of right neigbour
	move				y:(r6+n6),n7	; index of last run
	move				x0,n6
	move				a0,y:(r0+n0)	; x1list(x2c) = 0
	move				n7,y:(r6+n6)	; copy last index over right neighbour
	move				n6,y:(r7+n7)	; update run to point to new index
;-------------------------------------------------------*
_leftonly:
;-------------------------------------------------------*
	jmp		_end_add
;-------------------------------------------------------*
_rightonly:
;-------------------------------------------------------*
	move				x0,n4
	move				y1,n0
	move				y1,y:(r4+n4)	; x2list(x1c) = x2r
	move				x0,y:(r0+n0)	; x1list(x2r) = x1c
	move				x1,n7
	move				x1,n0
	move				x1,n4
	move				a0,y:(r0+n0)	; x1list(x2c) = 0
	move				a0,y:(r4+n4)	; x2list(x2c) = 0
	move				y:(r7+n7),n6	; index of right neighbour
	move				x0,n7
	move				x0,y:(r6+n6)	; point index to new run
	move				n6,y:(r7+n7)
;-------------------------------------------------------*
_end_add:
;-------------------------------------------------------*
	clr		a		x:(r2+n2),y1	; locate next slot for this (y)
	cmp		y1,a		y1,n2
	jne		_slots
	move				y:HTX_ptr,r7
;-------------------------------------------------------*
_get_runs:
;-------------------------------------------------------*
	dspwaitwrite
	tst		b		b,x:(r7)
	jeq		_line
;-------------------------------------------------------*
;	Send luminance back to host			*
;-------------------------------------------------------*
	move				y:z,y0
	tfr		y0,a		#0,x0
	neg		a		y:lshft19,x1
	add		x1,a		y:lshft5,x1
	tmi		x0,a
	move		a,x0
	mpy		x0,x1,a		r1,n5
	move		a0,x0
	mpy		x0,x0,a		y:run_ptr,r1
	move		a,x0
	mpy		x0,x0,a		y:rshft5,x1
	move		a,x0
	mpy		x0,x1,a		y:mlum2,x1
	move		a,x0
	mpy		x0,x1,a		y:mlum3,x0
	add		x0,a		#0,x1
	tmi		x1,a
	move				y:mlum_limit,x1
	cmp		x1,a		y:one,x0
	tpl		x1,a
;-------------------------------------------------------*
	dspwaitwrite
	clr		a		a,x:(r7)	
;-------------------------------------------------------*
;	Send joined runs back to host			*
;-------------------------------------------------------*
	do		b1,_fetch
	move				y:(r6)+,n4	; n4 = x1
	move		n4,a
	move				y:(r4+n4),n0	; n0 = x2 
	move				a0,y:(r4+n4)
	move				a0,y:(r0+n0)
	sub		x0,a		n0,b
	sub		x0,b		y0,y:(r1)+
	dspwaitwrite
	move		b,x:(r7)	a,y:(r1)+
;-------------------------------------------------------*
_fetch:	move				r1,y:run_ptr
	move				n5,r1
;-------------------------------------------------------*
_line:	move				l:ti,a
	move				l:t,b
	add		a,b
	clr		a		b,l:t
;-------------------------------------------------------*
_vert:	rts

;-------------------------------------------------------*
;	Calculate texture index for perspected wall	*
;-------------------------------------------------------*
perspected_column:
;-------------------------------------------------------*
	move				y:HTX_ptr,r1
;-------------------------------------------------------*
;	Write [i] 					*
;-------------------------------------------------------*
	move				y:one,x0
	move		n0,a
	sub		x0,a		y:lshft8,x0
	dspwaitwrite
	mpy		x0,y0,a		a,x:(r1)
;-------------------------------------------------------*
;	Write [y1:y2] / calculate [u] factor		*
;-------------------------------------------------------*
	move		a0,b
	or		y1,b		x:t_accumulator,x0
	move				y:lshft10,a
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,a
	move				y:wall_fsz,x1
	sub		x1,a		y:wall_fdz,x1
	abs		a		y:wall_dz,x0
	dspwaitwrite
	move				b,x:(r1)
;-------------------------------------------------------*
;	Calculate [u] index				*
;-------------------------------------------------------*
	and		#$FE,ccr
	rep		#24
	div		x1,a
	move		a0,x1
;-------------------------------------------------------*
;	Calculate [lum]					*
;-------------------------------------------------------*
	mpy		x0,x1,b		y:wall_z2,x0
	sub		x0,b		y:lshft19,x1
	move		#0,x0
	add		x1,b		y:lshft5,x1
	tmi		x0,b
	move		b,x0
	mpy		x0,x1,b
	move		b0,x0
	mpy		x0,x0,b
	move		b,x0
	mpy		x0,x0,b		y:rshft5,x1
	move		b,x0
	mpy		x0,x1,b		y:mlum2,x1
	move		b,x0
	mpy		x0,x1,b		y:mlum3,x0
	add		x0,b		#0,x1
	tmi		x1,b
	move				y:mlum_limit,x1
	cmp		x1,b		y:lshft6,x0		
	tpl		x1,b
	move		b,x1
	mpy		x0,x1,b		a0,x1
;-------------------------------------------------------*
	dspwaitwrite
	move				b0,x:(r1)	
;-------------------------------------------------------*
	move				y:wall_umag,x0
	mpy		-x0,x1,a	y:wall_u,x0
	sub		x0,a		y:rshft8,x0
	move		a,x1
	mpy		x0,x1,a		y:wall_usize,x0
	and		x0,a		y:wall_vsize,x1
	move		a1,x0
	mpy		x0,x1,a
	asr		a		l:y2_accumulator,b
;-------------------------------------------------------*
;	Write [u]					*
;-------------------------------------------------------*
	dspwaitwrite
	move				a0,x:(r1)
;-------------------------------------------------------*
;	Calculate [dv]					*
;-------------------------------------------------------*
	move				l:y1_accumulator,a
	sub		a,b		y:wall_vmag,a
	rep		#8
	asl		b
	asl		a		b,x1
	and		#$FE,ccr
	rep		#24
	div		x1,a
	dspwaitwrite
	move				a0,x:(r1)
;-------------------------------------------------------*
;	Calculate [v] index				*
;-------------------------------------------------------*
	move				l:y1_accumulator,b
	sub		y0,b		a0,x1
	neg		b		y:one,x0
	add		x0,b
	rep		#8
	asl		b
	clr		b		b,x0
	mpy		x0,x1,a		y:wall_voff,x0
	add		x0,a
	rep		#8-1
	asl		a
	dspwaitwrite
	clr		a		a1,x:(r1)
	rts

;-------------------------------------------------------*
;	Calculate texture index for linear wall		*
;-------------------------------------------------------*
linear_column:
;-------------------------------------------------------*
	move				y:HTX_ptr,r1
;-------------------------------------------------------*
;	Write [i] 					*
;-------------------------------------------------------*
	move				y:one,x0
	move		n0,a
	sub		x0,a		y:lshft8,x0
	dspwaitwrite
	mpy		x0,y0,a		a,x:(r1)
;-------------------------------------------------------*
;	Write [y1:y2] / calculate [u] factor		*
;-------------------------------------------------------*
	move		a0,b
	or		y1,b		x:t_accumulator,a
	dspwaitwrite
	move				b,x:(r1)
	move				y:wall_sz,x1
	sub		x1,a		y:wall_dz,x1	; ez-sz
	abs		a		y:wall_z1,b
;-------------------------------------------------------*
;	Calculate [u] index				*
;-------------------------------------------------------*
	and		#$FE,ccr
	rep		#24
	div		x1,a
	neg		b		y:lshft19,x1
	move		#0,x0
	add		x1,b		y:lshft5,x1
	tmi		x0,b
	move		b,x0
	mpy		x0,x1,b
	move		b0,x0
	mpy		x0,x0,b
	move		b,x0
	mpy		x0,x0,b		y:rshft5,x1
	move		b,x0
	mpy		x0,x1,b		y:mlum2,x1
	move		b,x0
	mpy		x0,x1,b		y:mlum3,x0
	add		x0,b		#0,x1
	tmi		x1,b
	move				y:mlum_limit,x1
	cmp		x1,b		y:lshft6,x0		
	tpl		x1,b
	move		b,x1
	mpy		x0,x1,b		a0,x1
;-------------------------------------------------------*
	dspwaitwrite
	move				b0,x:(r1)	
;-------------------------------------------------------*
	move				y:wall_umag,x0
	mpy		-x0,x1,a	y:wall_u,x0
	sub		x0,a		y:rshft8,x0
	move		a,x1
	mpy		x0,x1,a		y:wall_usize,x0
	and		x0,a		y:wall_vsize,x1
	move		a1,x0
	mpy		x0,x1,a
	asr		a		l:y2_accumulator,b
;-------------------------------------------------------*
;	Write [u]					*
;-------------------------------------------------------*
	dspwaitwrite
	move				a0,x:(r1)
;-------------------------------------------------------*
;	Calculate [dv]					*
;-------------------------------------------------------*
	move				l:y1_accumulator,a
	sub		a,b		y:wall_vmag,a
	rep		#8
	asl		b
	asl		a		b,x1
	and		#$FE,ccr
	rep		#24
	div		x1,a
	dspwaitwrite
	move				a0,x:(r1)
;-------------------------------------------------------*
;	Calculate [v] index				*
;-------------------------------------------------------*
	move				l:y1_accumulator,b
	sub		y0,b		a0,x1
	neg		b		y:one,x0
	add		x0,b
	rep		#8
	asl		b
	clr		b		b,x0
	mpy		x0,x1,a		y:wall_voff,x0
	add		x0,a
	rep		#8-1
	asl		a
	dspwaitwrite
	clr		a		a1,x:(r1)
	rts

;-------------------------------------------------------*
AddMidWall:
;-------------------------------------------------------*
	jsr		init_addwall
;-------------------------------------------------------*
	do		b,midwall_loop
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Advance edge accumulators			*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	load_column
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Generate floor buckets				*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	clip if [thisbot]=>[thismaxy]			*
;-------------------------------------------------------*
	tfr		y1,b	y:(r4+n4),a		; [thisbot] : [thismaxy]
	cmp		a,b
	jpl		_clip_lower
;-------------------------------------------------------*
;	draw if [lastbot]>[thisbot]			*
;-------------------------------------------------------*
	tfr		y1,a	y:(r5+n5),b		; [thisbot] : [lastbot]
	sub		a,b
	jsgt		start_floor			; y1=[thisbot] : y2=[lastbot]
;-------------------------------------------------------*
;	draw if [thismaxy]>[lastmaxy]			*
;-------------------------------------------------------*
	move		y:(r4),a			; [lastmaxy]
	move		y:(r4+n4),b			; [thismaxy]
	sub		a,b
	jsgt		start_floor			; y1=[lastmaxy] : y2=[thismaxy]
;-------------------------------------------------------*
;	draw if [thisbot]>[lastbot]			*
;-------------------------------------------------------*
	tfr		y1,b	y:(r5+n5),a		; [thisbot] : [lastbot]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat			; y1=[thisbot] : y2=[lastbot]
;-------------------------------------------------------*
;	draw if [lastmaxy]>[thismaxy]			*
;-------------------------------------------------------*
	move		y:(r4+n4),a			; [thismaxy]
	move		y:(r4),b			; [lastmaxy]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat			; y1=[thismaxy] : y2=[lastmaxy]
;-------------------------------------------------------*
	jmp		_floor_done
;-------------------------------------------------------*
_clip_lower:
;-------------------------------------------------------*
;	draw if [lastmaxy]>[lastbot]			*
;-------------------------------------------------------*
	move		y:(r5+n5),a			; [lastbot]
	move		y:(r4),b			; [lastmaxy]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat			; y1=[lastbot] : y2=[lastmaxy]
;-------------------------------------------------------*
_floor_done:	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Generate ceiling buckets			*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	clip if [thistop]<=[thisminy]			*
;-------------------------------------------------------*
	tfr		y0,b	x:(r0+n0),a		; [thistop] : [thisminy]
	cmp		a,b
	jle		_clip_upper	
;-------------------------------------------------------*
;	draw if [thistop]>[lasttop]			*
;-------------------------------------------------------*
	tfr		y0,b	x:(r3+n3),a		; [thistop] : [lasttop]
	sub		a,b
	jsgt		start_ceiling			; y1=[lasttop] : y2=[thistop]
;-------------------------------------------------------*
;	draw if [lastminy]>[thisminy]			*
;-------------------------------------------------------*
	move		x:(r0+n0),a			; [thisminy]
	move		x:(r0),b			; [lastminy]
	sub		a,b
	jsgt		start_ceiling			; y1=[thisminy] : y2=[lastminy]
;-------------------------------------------------------*
;	draw if [lasttop]>[thistop]			*
;-------------------------------------------------------*
	tfr		y0,a	x:(r3+n3),b		; [thistop] : [lasttop]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat			; y1=[thistop] : y2=[lasttop]
;-------------------------------------------------------*
;	draw if [thisminy]>[lastminy]			*
;-------------------------------------------------------*
	move		x:(r0),a			; [lastminy]
	move		x:(r0+n0),b			; [thisminy]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat			; y1=[lastminy] : y2=[thisminy]
;-------------------------------------------------------*
	jmp		_ceiling_done
;-------------------------------------------------------*
_clip_upper:
;-------------------------------------------------------*
	move		x:(r0),a			; [lastminy]
	move		x:(r3+n3),b			; [lasttop]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat			; y1=[lastminy] : y2=[lasttop]
;-------------------------------------------------------*
_ceiling_done:	
;-------------------------------------------------------*
;	Rotate column history registers			*
;-------------------------------------------------------*
;	lasttop = thistop / lastbot = thisbot		*
;-------------------------------------------------------*
	move		y0,x:(r3+n3)
	move		y1,y:(r5+n5)
;-------------------------------------------------------*
;	lastmin = thismin / lastmax = thismax		*
;-------------------------------------------------------*
	move		x:(r0+n0),a
	move		y:(r4+n4),b
;-------------------------------------------------------*
;	Check - column is already sealed off		*
;-------------------------------------------------------*
	cmp		a,b	a,x:(r0)	b,y:(r4)
	jle		_skip
;-------------------------------------------------------*
;	Check - column below [maxy] - blocked by roof	*
;-------------------------------------------------------*
	cmp		y0,b
	jle		_update_window
;-------------------------------------------------------*
;	Check - column above [miny] - blocked by floor	*
;-------------------------------------------------------*
	cmp		y1,a
	jpl		_update_window
;-------------------------------------------------------*
;	Clip - top of column cropped by [miny]		*
;-------------------------------------------------------*
	cmp		y0,a
	jle		_ncl1
	move		a,y0
;-------------------------------------------------------*
;	Clip - bottom of column cropped by [maxy]	*
;-------------------------------------------------------*
_ncl1:	cmp		y1,b 
	jpl		_ncl2
	move		b,y1
;-------------------------------------------------------*
;	Check - column cropped to zero length		*
;-------------------------------------------------------*
_ncl2:	tfr		y1,b	y:column_rout,r1
	cmp		y0,b	n0,x0			; [thistop]<>[thisbot]
	jsgt		(r1)
;-------------------------------------------------------*
;	Update vertical clipping bar			*
;-------------------------------------------------------*
_update_window:
;-------------------------------------------------------*
	tfr		y0,a	y1,b
	jset		#0,y:attributes,_trans
	clr		b	y:height,a
	move		a,x:(r0+n0)
	move		b,y:(r4+n4)
_trans:
	cmp		a,b	#1,a1
	jgt		_skip
	move			y:columns,b
	sub		a,b	b0,y:(r7)
	move			b,y:columns		
;-------------------------------------------------------*
;	Advance to next column				*
;-------------------------------------------------------*
_skip:	advance_column
;-------------------------------------------------------*
midwall_loop:
;-------------------------------------------------------*
;	Fill gaps left in floor & ceiling by edges	*
;-------------------------------------------------------*
	move		y:(r5+n5),a			; [lastbot]
	move		y:(r4),b			; [lastmaxy]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat
	move		x:(r0),a			; [lastminy]
	move		x:(r3+n3),b			; [lasttop]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat
;-------------------------------------------------------*
	jmp		end_addwall

;-------------------------------------------------------*
AddUpperWall:
;-------------------------------------------------------*
	jsr		init_addwall
;-------------------------------------------------------*
	do		b,upperwall_loop
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Advance edge accumulators			*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	load_column
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Generate ceiling buckets			*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	clip if [thistop]<=[thisminy]			*
;-------------------------------------------------------*
	tfr		y0,b	x:(r0+n0),a		; [thistop] : [thisminy]
	cmp		a,b
	jle		_clip_upper	
;-------------------------------------------------------*
;	draw if [thistop]>[lasttop]			*
;-------------------------------------------------------*
	tfr		y0,b	x:(r3+n3),a		; [thistop] : [lasttop]
	sub		a,b
	jsgt		start_ceiling			; y1=[lasttop] : y2=[thistop]
;-------------------------------------------------------*
;	draw if [lastminy]>[thisminy]			*
;-------------------------------------------------------*
	move		x:(r0+n0),a			; [thisminy]
	move		x:(r0),b			; [lastminy]
	sub		a,b
	jsgt		start_ceiling			; y1=[thisminy] : y2=[lastminy]
;-------------------------------------------------------*
;	draw if [lasttop]>[thistop]			*
;-------------------------------------------------------*
	tfr		y0,a	x:(r3+n3),b		; [thistop] : [lasttop]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat			; y1=[thistop] : y2=[lasttop]
;-------------------------------------------------------*
;	draw if [thisminy]>[lastminy]			*
;-------------------------------------------------------*
	move		x:(r0),a			; [lastminy]
	move		x:(r0+n0),b			; [thisminy]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat			; y1=[lastminy] : y2=[thisminy]
;-------------------------------------------------------*
	jmp		_ceiling_done
;-------------------------------------------------------*
_clip_upper:
;-------------------------------------------------------*
	move		x:(r0),a			; [lastminy]
	move		x:(r3+n3),b			; [lasttop]
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat			; y1=[lastminy] : y2=[lasttop]
;-------------------------------------------------------*
_ceiling_done:	
;-------------------------------------------------------*
;	Rotate column history registers			*
;-------------------------------------------------------*
;	lasttop = thistop / lastbot = thisbot		*
;-------------------------------------------------------*
	move		y0,x:(r3+n3)
	move		y1,y:(r5+n5)
;-------------------------------------------------------*
;	lastmin = thismin / lastmax = thismax		*
;-------------------------------------------------------*
	move		x:(r0+n0),a
	move		y:(r4+n4),b
;-------------------------------------------------------*
;	Check - column is already sealed off		*
;-------------------------------------------------------*
	cmp		a,b	a,x:(r0)	b,y:(r4)
	jle		_skip
;-------------------------------------------------------*
;	Check - column below [maxy] - blocked by roof	*
;-------------------------------------------------------*
	cmp		y1,a
	jpl		_skip
;-------------------------------------------------------*
;	Check - column above [miny] - blocked by floor	*
;-------------------------------------------------------*
	cmp		y0,b
	jle		_update_window
;-------------------------------------------------------*
;	Clip - top of column cropped by [miny]		*
;-------------------------------------------------------*
	cmp		y0,a
	jle		_ncl1
	move		a,y0
;-------------------------------------------------------*
;	Clip - bottom of column cropped by [maxy]	*
;-------------------------------------------------------*
_ncl1:	cmp		y1,b 
	jpl		_ncl2
	move		b,y1
;-------------------------------------------------------*
;	Check - column cropped to zero length		*
;-------------------------------------------------------*
_ncl2:	tfr		y1,b	y:column_rout,r1
	cmp		y0,b	n0,x0			; [thistop]<>[thisbot]
	jsgt		(r1)
;-------------------------------------------------------*
;	Update vertical clipping bar			*
;-------------------------------------------------------*
_update_window:
;-------------------------------------------------------*
	move			y:(r4+n4),b
	cmp		y1,b	#1,a1
	jgt		_upd
	move			y:columns,b
	sub		a,b	b0,y:(r7)
	move			b,y:columns
_cont:	move			b0,y:(r4+n4)
	move			y:height,y1
_upd:	move			y1,x:(r0+n0)
;-------------------------------------------------------*
;	Advance to next column				*
;-------------------------------------------------------*
_skip:	advance_column
;-------------------------------------------------------*
upperwall_loop:
;-------------------------------------------------------*
;	Fill gaps left in floor & ceiling by edges	*
;-------------------------------------------------------*
	move		x:(r0),a
	move		x:(r3+n3),b
	sub		a,b	#ceiling_bounds,r1
	jsgt		end_flat
;-------------------------------------------------------*
	jmp		end_addwall

;-------------------------------------------------------*
AddLowerWall:
;-------------------------------------------------------*
	jsr		init_addwall
;-------------------------------------------------------*
	do		b,lowerwall_loop
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Advance edge accumulators			*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	load_column
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Generate floor buckets				*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	clip if [thisbot]=>[thismaxy]			*
;-------------------------------------------------------*
	tfr		y1,b	y:(r4+n4),a		; [thisbot] : [thismaxy]
	cmp		a,b
	jpl		_clip_lower
;-------------------------------------------------------*
;	draw if [lastbot]>[thisbot]			*
;-------------------------------------------------------*
	tfr		y1,a	y:(r5+n5),b		; [thisbot] : [lastbot]
	sub		a,b
	jsgt		start_floor			; y1=[thisbot] : y2=[lastbot]
;-------------------------------------------------------*
;	draw if [thismaxy]>[lastmaxy]			*
;-------------------------------------------------------*
	move		y:(r4),a			; [lastmaxy]
	move		y:(r4+n4),b			; [thismaxy]
	sub		a,b
	jsgt		start_floor			; y1=[lastmaxy] : y2=[thismaxy]
;-------------------------------------------------------*
;	draw if [thisbot]>[lastbot]			*
;-------------------------------------------------------*
	tfr		y1,b	y:(r5+n5),a		; [thisbot] : [lastbot]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat			; y1=[thisbot] : y2=[lastbot]
;-------------------------------------------------------*
;	draw if [lastmaxy]>[thismaxy]			*
;-------------------------------------------------------*
	move		y:(r4+n4),a			; [thismaxy]
	move		y:(r4),b			; [lastmaxy]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat			; y1=[thismaxy] : y2=[lastmaxy]
;-------------------------------------------------------*
	jmp		_floor_done
;-------------------------------------------------------*
_clip_lower:
;-------------------------------------------------------*
;	draw if [lastmaxy]>[lastbot]			*
;-------------------------------------------------------*
	move		y:(r5+n5),a			; [lastbot]
	move		y:(r4),b			; [lastmaxy]
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat			; y1=[lastbot] : y2=[lastmaxy]
;-------------------------------------------------------*
_floor_done:	
;-------------------------------------------------------*
;	Rotate column history registers			*
;-------------------------------------------------------*
;	lasttop = thistop / lastbot = thisbot		*
;-------------------------------------------------------*
	move		y0,x:(r3+n3)
	move		y1,y:(r5+n5)
;-------------------------------------------------------*
;	lastmin = thismin / lastmax = thismax		*
;-------------------------------------------------------*
	move		x:(r0+n0),a
	move		y:(r4+n4),b
;-------------------------------------------------------*
;	Check - column is already sealed off		*
;-------------------------------------------------------*
	cmp		a,b	a,x:(r0)	b,y:(r4)
	jle		_skip
;-------------------------------------------------------*
;	Check - column below [maxy] - blocked by roof	*
;-------------------------------------------------------*
	cmp		y0,b
	jle		_skip
;-------------------------------------------------------*
;	Check - column above [miny] - blocked by floor	*
;-------------------------------------------------------*
	cmp		y1,a
	jpl		_update_window
;-------------------------------------------------------*
;	Clip - top of column cropped by [miny]		*
;-------------------------------------------------------*
	cmp		y0,a
	jle		_ncl1
	move		a,y0
;-------------------------------------------------------*
;	Clip - bottom of column cropped by [maxy]	*
;-------------------------------------------------------*
_ncl1:	cmp		y1,b 
	jpl		_ncl2
	move		b,y1
;-------------------------------------------------------*
;	Check - column cropped to zero length		*
;-------------------------------------------------------*
_ncl2:	tfr		y1,b	y:column_rout,r1
	cmp		y0,b	n0,x0			; [thistop]<>[thisbot]
	jsgt		(r1)
;-------------------------------------------------------*
;	Update vertical clipping bar			*
;-------------------------------------------------------*
_update_window:
;-------------------------------------------------------*
	move			x:(r0+n0),b
	cmp		y0,b	#1,a1
	jlt		_upd
	move			y:columns,b
	sub		a,b	b0,y:(r7)
	move			b,y:columns
_cont:	move			y:height,y1
	move			y1,x:(r0+n0)
	move			b0,y0	
_upd:	move			y0,y:(r4+n4)
;-------------------------------------------------------*
;	Advance to next column				*
;-------------------------------------------------------*
_skip:	advance_column
;-------------------------------------------------------*
lowerwall_loop:
;-------------------------------------------------------*
;	Fill gaps left in floor & ceiling by edges	*
;-------------------------------------------------------*
	move		y:(r5+n5),a
	move		y:(r4),b
	sub		a,b	#floor_bounds,r1
	jsgt		end_flat
;-------------------------------------------------------*
	jmp		end_addwall

;-------------------------------------------------------*
end_addwall:
;-------------------------------------------------------*
	move		#-1,a1
	dspwrite	a1
	dspwrite	y:columns
	jmp		command_base

;-------------------------------------------------------*
;	Begin section of floor or ceiling		*
;-------------------------------------------------------*
start_ceiling:
;-------------------------------------------------------*
start_floor:
;-------------------------------------------------------*
	move		y:flatstack_ptr,r1
	move		a,n1
	add		a,b	b1,n2
	lua		(r1)+n1,r1
	rep		n2
	move		n0,x:(r1)+	
	rts

;-------------------------------------------------------*
;	Get ready for wall column generator		*
;-------------------------------------------------------*
init_addwall:
;-------------------------------------------------------*
;	Get wall details				*	
;-------------------------------------------------------*
	move		y:HTX_ptr,r7
	move		#>1<<(8-1),x0
	move		#<$FF,b
;-------------------------------------------------------*
;	Read y-increments & accumulators		*
;-------------------------------------------------------*
	move		#y1_accumulator,r6
	jsr		read_real
	move		#y1_increment,r6
	jsr		read_real
	move		#y2_accumulator,r6
	jsr		read_real
	move		#y2_increment,r6
	jsr		read_real
;-------------------------------------------------------*
	move		#temp1,r6
;-------------------------------------------------------*
;	Read z-increments & accumulators		*
;-------------------------------------------------------*
	jsr		read_real
	move		l:(r6),a
	rep		#8
	asl		a
	move		a,l:t_accumulator
	jsr		read_real
	move		l:(r6),a
	rep		#8
	asl		a
	move		a,l:t_increment
	asr		a
	move		l:t_accumulator,b
	add		a,b
	move		b,l:t_accumulator
	move		#<$FF,b
;-------------------------------------------------------*
;	Read z-bounds					*
;-------------------------------------------------------*
	jsr		read_real
	move		l:(r6),a
	rep		#8
	asl		a
	move		a,y:wall_z1
	jsr	 	read_real
	move		l:(r6),a
	rep		#8
	asl		a
	move		a,y:wall_z2
;-------------------------------------------------------*
;	Read texture buffer width			*
;-------------------------------------------------------*
	dspread		a
	move		y:one,x0
	sub		x0,a
	move		a,y:wall_usize
;-------------------------------------------------------*
;	Read texture buffer height			*
;-------------------------------------------------------*
	dspread		y:wall_vsize
;-------------------------------------------------------*
;	Read wall length				*
;-------------------------------------------------------*
	dspread		y:wall_umag
;-------------------------------------------------------*
;	Read wall clipped portion			*
;-------------------------------------------------------*
	dspread		y:wall_u
;-------------------------------------------------------*
;	Read wall height				*
;-------------------------------------------------------*
	dspread		y:wall_vmag
;-------------------------------------------------------*
;	Read wall initial y-offset			*
;-------------------------------------------------------*
	dspread		y:wall_voff
;-------------------------------------------------------*

;-------------------------------------------------------*
	dspread		y:ci1
;-------------------------------------------------------*
	move		y:wall_z1,a
	move		a,y:wall_sz
	abs		a		a,y:0
	move		a,x0
	move		y:lshft10,a
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,a
	jclr		#23,y:0,_p1
	neg		a
_p1:	move		a,y:wall_fsz
;-------------------------------------------------------*
	dspread		y:ci2
;-------------------------------------------------------*
	move		y:wall_z2,a
	move		y:wall_z1,b
	sub		b,a
	move		a,y:wall_dz
	move		y:wall_z1,a
	abs		a		a,y:0
	move		a,x0
	move		y:lshft10,a
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,b
	jclr		#23,y:0,_p2
	neg		b
_p2:	move		y:wall_z2,a
	abs		a		a,y:0
	move		a,x0
	move		y:lshft10,a
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,a
	jclr		#23,y:0,_p3
	neg		a
_p3:	sub		b,a
	move		a,y:wall_fdz
;-------------------------------------------------------*
;	Read x1 & x2					*
;-------------------------------------------------------*
	dspread		y:attributes
	dspread		y:columns
;-------------------------------------------------------*
	move		#column_thistop,r3
	move		#column_thisbot,r5
	move		#1,n3
	move		#1,n5
;-------------------------------------------------------*
;	Init miny maxy & occlusion lists		*
;-------------------------------------------------------*
	clr		b	#(occlusion_list-1),r1
	move		y:ci1,a
	move		a1,n1
	move		#miny,r0
	lua		(r1)+n1,r7
	move		#maxy,r4
	move		#1,b1
	add		b,a	y:runlink_ptr,r2
	move		a,n0
	move		a,n4
;-------------------------------------------------------*
;	Prefetch loop registers				*
;-------------------------------------------------------*
	move		x:(r0+n0),a
	move				y:(r4+n4),b
	move		a,x:(r0)	b,y:(r4)
	move		a,x:(r3+n3)
	move				b,y:(r5+n5)
;-------------------------------------------------------*
;	Calculate span width				*
;-------------------------------------------------------*
	move		y:ci2,b
	move		y:ci1,a
	sub		a,b		#edge_increments,r1
	rts

;-------------------------------------------------------*
;	Rotate indexes & velocities for floor mapping	*
;-------------------------------------------------------*
RotateMap:
;-------------------------------------------------------*
;	x1					; 24
;	y1					; 24
;	v					; 16.8
;-------------------------------------------------------*
;	tnorm = 320/h				; 8.16
;	xo = (w/2)-x1				; 24
;	uvs = v * tnorm				; 16.8
;	xi = uvs * cos(a)			; 16.8
;	yi = uvs * sin(a)			; 16.8
;	xs = uvs*xo*cos(a) + v*sin(a) - py	; 16.8
;	ys = uvs*xo*sin(a) - v*cos(a) - px	; 16.8
;-------------------------------------------------------*
	move			y:run_ptr,b
	move			#runstarts,r6
	move		r6,a
	sub		a,b	r6,y:run_ptr
	asr		b	#HTX,r0
	jeq		_loop
	move		#map_data,r7
	move		#3-1,m7
	move		#_next,r5
;-------------------------------------------------------*
;	Read untranslated coordinates from host		*	
;-------------------------------------------------------*
	do		b,_loop
;-------------------------------------------------------*
;	Fetch backup copies of flat Z & X1		*
;-------------------------------------------------------*
_next:	move		y:(r6)+,x1
	move		y:(r6)+,a
;-------------------------------------------------------*
;	xo(24) = (w/2)-x1				*
;-------------------------------------------------------*
	move		a,n0
	move				y:hwid,x0
	sub		x0,a		y:lshft7,y0
	move		a,x0
	mpy		x0,y0,a		x1,y:map_v
	move		a0,y1
;-------------------------------------------------------*
;	uvs(16.8) = v * tnorm				*
;-------------------------------------------------------*
	move				y:map_tnorm,x0
	mpy		x0,x1,a		y:cosa,x1
	rep		#(8-1)
	asl		a
	move		a,x0
;-------------------------------------------------------*
;	xi(16.8) = uvs * cos(a)				*
;-------------------------------------------------------*
	mpy		x0,x1,a		x0,y:map_uvs	
	asl		a		y:lshft18,x1
	move				a,y:map_cosauvs
	move		a,y0
	mpy		y0,x1,a		y:sina,x1
;-------------------------------------------------------*
;	yi(16.8) = uvs * sin(a)				*
;-------------------------------------------------------*
	mpy		x0,x1,a		a,y:map_xi
	asl		a		y:lshft18,x1
	move				a,y:map_sinauvs
	move		a,x0
	mpy		-x0,x1,a	y:map_cosauvs,x0
;-------------------------------------------------------*
;	xs(16.8) = uvs*xo*cos(a) + v*sin(a) - py	*
;-------------------------------------------------------*
	mpy		x0,y1,a		a,y:map_yi	; 8.24
	move				y:map_v,x1
	move				y:sina,x0
	mpy		x0,x1,b		y:lshft16,x1
	asl		b
	move		b,x0
	mpy		x0,x1,b		y:py,x0
	add		b,a		y:map_v,x1
	sub		x0,a		y:map_sinauvs,x0
	rep		#8+2
	asl		a
;-------------------------------------------------------*
;	ys(16.8) = uvs*xo*sin(a) - v*cos(a) - px	*
;-------------------------------------------------------*
	mpy		-x0,y1,a	a,y:map_x
	move				y:cosa,x0
	mpy		x0,x1,b		y:lshft16,x1
	asl		b
	move		b,x0
	mac		x0,x1,a		y:px,x0
	add		x0,a		y:(r7)+,b
	rep		#8+2
	asl		a
;-------------------------------------------------------*
;	Write previously derived coordinates to host	*
;-------------------------------------------------------*
	dspwaitwrite
	move		b,x:(r0)	y:(r7)+,b
	dspwaitwrite
	move		b,x:(r0)	y:(r7)+,b
	dspwaitwrite
	move		b,x:(r0)
	dspwaitwrite
	move		a,x:(r0)
	dspwaitwrite
	move		n0,x:(r0)
;-------------------------------------------------------*
_loop:	move		#-1,m7
	jmp		command_base

;-------------------------------------------------------*
;	Calculate & fetch ssector floor & ceiling	*
;-------------------------------------------------------*
GetSsector:
;-------------------------------------------------------*
	move		#<$FF,b
	move		y:HTX_ptr,r7
	dspread_s
	move		a,y:cy
	dspread_s
	move		a,y:fy
;-------------------------------------------------------*
	move				y:lshft8,x0
	move				y:hhig,y0
	mpy		x0,y0,a		y:vs_width,y1
	move				y:cy,x1
	mpy		x0,y1,a		a0,y0
	move				a0,y1
	mpy		x1,y1,a		y:fy,x1
	rep		#(6+2)
	asr		a		a0,b
	add		y0,b		a0,a		; ((w/2) * cy) / cz2 (128)
	add		y0,a		b,y:cj1		; cj1
	mpy		x1,y1,a		a,y:cj2		; cj2
	rep		#(6+2)
	asr		a		a0,b
	add		y0,b		a0,a		; ((w/2) * fy) / fz2 (128)
	add		y0,a		b,y:fj1		; fj1
	move				a,y:fj2		; fj2
;-------------------------------------------------------*
	move				y:lshft8,x0
;-------------------------------------------------------*
	move				y:cj2,b
	move				y:cj1,x1
	sub		x1,b		y:ctop,y0		; (cj2-cj1)
	mpy		x0,y0,a		#>(1<<8)-1,y0
	move		a0,a					; cj3
	add		y0,a		y:cj1,y0
	sub		y0,a		y:lshft15,y0
	move		a,y1					; (cj3-cj1)
	mpy		-y0,y1,a	b,x1			; (cz1-cz2)*(cj3-cj1)
	jsr		divs_x1_a
	move				#>(128<<8),y1
	add		y1,a		y:cbot,y0
	move				a,y:ctop_z
	mpy		x0,y0,a		#>(1<<8)-1,y0
	move		a0,a					; cj3
	add		y0,a		y:cj1,y0
	sub		y0,a		y:lshft15,y0
	move		a,y1
	mpy		-y0,y1,a	#>(128<<8),y1
	jsr		divs_x1_a
	add		y1,a
	move				a,y:cbot_z
;-------------------------------------------------------*
	move				y:fj1,b
	move				y:fj2,x1
	sub		x1,b		y:ftop,y0		; (cj2-cj1)
	mpy		x0,y0,a		#>(1<<8)-1,y0
	move		a0,a					; cj3
	add		y0,a		y:fj1,y0
	sub		y0,a		y:lshft15,y0
	move		a,y1					; (cj3-cj1)
	mpy		y0,y1,a		b,x1			; (cz1-cz2)*(cj3-cj1)<<8
	jsr		divs_x1_a
	move				#>(128<<8),y1
	add		y1,a		y:fbot,y0
	move				a,y:ftop_z
	mpy		x0,y0,a		#>(1<<8)-1,y0
	move		a0,a					; cj3
	add		y0,a		y:fj1,y0
	sub		y0,a		y:lshft15,y0
	move		a,y1
	mpy		y0,y1,a		#>(128<<8),y1
	jsr		divs_x1_a
	add		y1,a
	move				a,y:fbot_z
;-------------------------------------------------------*
;	Initialise gradient & send span	to host		*
;-------------------------------------------------------*
	move				y:ctop,a
	move				y:cbot,b
	sub		a,b		y:one,a
	move		b,x0
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,x0
	move				y:ctop_z,a
	move				y:cbot_z,b
	sub		a,b		a,l:t
	move		b,x1
	mpy		x0,x1,a		#ctop,r0
	move				a,l:ti
	move				#cbot,r4
	move		y:ceiling_luminance,x0
	jsr		getflatarea
;-------------------------------------------------------*
;	Initialise gradient & send span	to host		*
;-------------------------------------------------------*
	move				y:ftop,a
	move				y:fbot,b
	sub		a,b		y:one,a
	move		b,x0
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,x0
	move				y:ftop_z,a
	move				y:fbot_z,b
	sub		a,b		a,l:t
	move		b,x1
	mpy		x0,x1,a		#ftop,r0
	move				a,l:ti
	move				#fbot,r4
	move		y:floor_luminance,x0
	jsr		getflatarea
;-------------------------------------------------------*
	jmp		NewSsector

;-------------------------------------------------------*
;	Determine visibility of BSP node		*
;-------------------------------------------------------*
NodeInCone:
;-------------------------------------------------------*
	move		#noderegs,r0
	move		#<$FF,b
	move		y:HTX_ptr,r7
	move		y:py,y0
	do		#2,_ry
	dspread_s
	sub		y0,a
	move		a,y:(r0)+
_ry:	move		y:px,x0
	do		#2,_rx
	dspread_s
	sub		x0,a
	move		a,y:(r0)+
_rx:

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Octal segment BSP node eliminator		*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
;	Eliminates nodes from 5 out of all 8 octants	*
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
octant_check:
;-------------------------------------------------------*
	move		#project_node,r0
	move		#oct_x,r1
	move				y:pangle,x1
	move				y:rshft13,y1
	mpy		x1,y1,a		#octs,r7
	move		a1,n7
	nop
	move				y:(r7+n7),r7
	nop
	jmp		(r7)
;-------------------------------------------------------*
;	Octant elimination routines		 	*
;-------------------------------------------------------*
oct_0:	move				y:node_y1,a
	tst		a		y:node_x2,b
	jpl		(r1)
	cmp		a,b
	jpl		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_1:	move				y:node_x2,a
	tst		a		y:node_y1,b
	jmi		(r1)
	cmp		b,a
	jpl		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_2:	move				y:node_x2,a
	tst		a		y:node_y2,b
	jmi		(r1)
	neg		b
	cmp		b,a
	jpl		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_3:	move				y:node_y2,a
	tst		a		y:node_x2,b
	jmi		(r1)
	neg		a
	cmp		a,b
	jpl		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_4:	move				y:node_y2,a
	tst		a		y:node_x1,b
	jmi		(r1)
	cmp		a,b
	jmi		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_5:	move				y:node_x1,a
	tst		a		y:node_y2,b
	jpl		(r1)
	cmp		b,a
	jmi		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_6:	move				y:node_x1,a
	tst		a		y:node_y1,b
	jpl		(r1)
	neg		b
	cmp		b,a
	jmi		(r0)
	jmp		(r1)
;-------------------------------------------------------*
oct_7:	move				y:node_y1,a
	tst		a		y:node_x1,b
	jpl		(r1)
	neg		a
	cmp		a,b
	jmi		(r0)
;-------------------------------------------------------*
oct_x:	move		#invisible_code,n0
	dspwaitwrite
	move		n0,x:HTX
	jmp		command_base

;-------------------------------------------------------*
project_node:
;-------------------------------------------------------*
	move		#>$1000,a
	neg		a		a,y:node_imin
	move				a,y:node_imax
;-------------------------------------------------------*
;	Rotate NY & NZ into canonical VZ & VX		*
;-------------------------------------------------------*
;	x = (dx)*sin(a) + (dy)*cos(a)			*
;	z = (dx)*cos(a) - (dy)*sin(a)			*
;-------------------------------------------------------*
	move				y:sina,x1
	move				y:cosa,y1
	move				y:node_x1,x0
	mpy		x0,x1,a		y:node_y1,y0	; dx*sin(a)
	mac		y0,y1,a		#vertices,r0	; + dy*cos(a)
	mpy		x0,y1,b		#1,n3		; dx*cos(a)
	mac		-y0,x1,b	y:node_x2,x0	; - dy*sin(a)
	asl		a		y:node_y1,y0
	asl		b		a,l:(r0)+
	mpy		x0,x1,a		b,l:(r0)+	; dx*sin(a)
	mac		y0,y1,a		#1,n1		; + dy*cos(a)
	mpy		x0,y1,b		#1,n2		; dx*cos(a)
	mac		-y0,x1,b	y:node_x2,x0	; - dy*sin(a)
	asl		a		y:node_y2,y0
	asl		b		a,l:(r0)+
	mpy		x0,x1,a		b,l:(r0)+	; dx*sin(a)
	mac		y0,y1,a				; + dy*cos(a)
	mpy		x0,y1,b				; dx*cos(a)
	mac		-y0,x1,b	y:node_x1,x0	; - dy*sin(a)
	asl		a		y:node_y2,y0
	asl		b		a,l:(r0)+
	mpy		x0,x1,a		b,l:(r0)+	; dx*sin(a)
	mac		y0,y1,a				; + dy*cos(a)
	mpy		x0,y1,b				; dx*cos(a)
	mac		-y0,x1,b			; - dy*sin(a)
	asl		a		
	asl		b		a,l:(r0)+
	move				b,l:(r0)+	; dx*sin(a)
;-------------------------------------------------------*
project_line:
;-------------------------------------------------------*
	move		#_swap,r4
	move		#_abort_line,r5
	move		#_no_isect,r6
	move		#linedefs,r7
;-------------------------------------------------------*
	do		#4,_project_loop
;-------------------------------------------------------*
	move		y:(r7)+,r1
	move		y:(r7),r2
;-------------------------------------------------------*
;	Reorient line					*
;-------------------------------------------------------*
	move				l:(r1+n1),a
	move				l:(r2+n2),b
	cmp		a,b		r1,n0
	jpl		(r4)
	move		r2,r1
	move		n0,r2
;-------------------------------------------------------*
;	z-clip line if it intersects with viewplane	*	
;-------------------------------------------------------*
_swap:	move				y:viewplane,a
	move				l:(r2+n2),b
	cmp		b,a		l:(r1+n1),x
	jpl		(r5)
;-------------------------------------------------------*
	move				r1,r3
	sub		x,a		l:(r1),x	; (cz-z1)
	jle		(r6)
;-------------------------------------------------------*
	move				#temp1,r3
	move				l:(r2),b
	sub		x,b		a1,x0		; (cz-z1)
	move				b1,y0		; (x2-x1)
	mpy		x0,y0,a		l:(r2+n2),b	; (x2-x1)*(cz-z1)
	move				l:(r1+n1),y
	sub		y,b		a,y:0
	abs		a		b1,x0		; (z2-z1)
	and		#$FE,ccr
	rep		#24
	div		x0,a				; ((x2-x1)*(cz-z1))/(z2-z1)
	move		a0,a
	jclr		#23,y:0,_nneg
	neg		a
;-------------------------------------------------------*
_nneg:	move				l:(r1),b
	add		a,b		y:viewplane,a
	move		b,x:(r3)			; x1' = (((x2-x1)*(cz-z1))/(z2-z1))+x1
	move		a,x:(r3+n3)			; z1' = cz
;-------------------------------------------------------*
_no_isect:
;-------------------------------------------------------*
;	Project points into 2D viewspace		*
;-------------------------------------------------------*
	move				y:hs_width,x0
	move				x:(r3),x1	; x1
	move				x:(r2),y1	; x2
	mpy		x0,x1,a		x:(r3+n3),x1	; z1
	mpy		x0,y1,b		x:(r2+n2),y1	; z2
	move				a0,x0		; (x1*hw)*2
	move				y:one,a
	tfr		a,b		b0,y0		; (x2*hw)*2
	and		#$FE,ccr
	rep		#24
	div		x1,a
	move				a0,x1		; 1/(z1*2)
	and		#$FE,ccr
	rep		#24
	div		y1,b
	mpy		-x0,x1,a	b0,y1		; 1/(z2*2)
	asr		a
	mpy		-y0,y1,b	a1,x0		; (x1*hw) / z1 
	asr		b		y:node_imin,a
	move				b1,y0		; (x2*hw) / z2
;-------------------------------------------------------*
;	Adjust bounds					*
;-------------------------------------------------------*
	cmp		x0,a		y:node_imax,b
	tgt		x0,a
	cmp		y0,a
	tgt		y0,a
	cmp		x0,b		a,y:node_imin
	tmi		x0,b
	cmp		y0,b
	tmi		y0,b
	move				b,y:node_imax
;-------------------------------------------------------*
_abort_line:
;-------------------------------------------------------*
	move		#0,y0
;-------------------------------------------------------*
_project_loop:
;-------------------------------------------------------*
;	Inside / outside viewport check			*
;-------------------------------------------------------*
	move				y:one,y1
	move				y:hwid,x0
	move				y:node_imax,b
	add		y1,b		#_end,r1
	add		x0,b		y:node_imin,a
	jmi		(r1)
	sub		y1,a		#_loop,r3
	add		x0,a		y:width,x1
	tmi		y0,a
	cmp		x1,a		#occlusion_list,r2
	jpl		(r1)
	cmp		x1,b		a,n2
	tpl		x1,b
	sub		a,b		(r2)+n2
	jle		(r1)
;-------------------------------------------------------*
;	Occlusion check					*
;-------------------------------------------------------*
	move		y:one,a
_loop:	jset		#0,y:(r2)+,_out
	sub		a,b
	jne		(r3)
;-------------------------------------------------------*
_end:	move		#invisible_code,n1
_out:	dspwaitwrite
	move		n1,x:HTX
	jmp		command_base

;-------------------------------------------------------*
ProjectWall:
;-------------------------------------------------------*
	move		y:HTX_ptr,r7
	move		#<$FF,b
	move		#line_regs,r0
	move		y:lshft8,y1
	move		y:px,x0
	move		y:py,y0
;-------------------------------------------------------*
;	Read line points from host (16.8)		*
;-------------------------------------------------------*
	do		#2,_line
	dspwaitread
	move			x:(r7),n7
	move		n7,a
	jclr		#15,n7,_ns1
	add		b,a
_ns1:	dspwaitread
	sub		x0,a	x:(r7),n7
	move		a1,x1
	mpy		x1,y1,a
	move		a0,x:(r0)+
	move		n7,a
	jclr		#15,n7,_ns2
	add		b,a
_ns2:	sub		y0,a
	move		a1,x1
	mpy		x1,y1,a
	move		a0,x:(r0)+
;-------------------------------------------------------*
;	Rotate NY & NZ into canonical VZ & VX		*
;-------------------------------------------------------*
;	x(16.8) = (dx)*sin(a) + (dy)*cos(a)		*
;	z(16.8) = (dx)*cos(a) - (dy)*sin(a)		*
;-------------------------------------------------------*
_line:	move		#line_regs,r0
	move				y:sina,x1
	move				y:cosa,y1
	move				x:(r0)+,x0
	mpy		x0,x1,a		x:(r0)+,y0	; dx*sin(a)
	mac		y0,y1,a		#2,r1		; + dy*cos(a)
	mpy		x0,y1,b		x:(r0)+,x0	; dx*cos(a)
	mac		-y0,x1,b	x:(r0)+,y0	; - dy*sin(a)
	asl		a		#1,n1
	asl		b		a,x:(r1)
	mpy		x0,x1,a		b,x:(r1+n1)	; dx*sin(a)
	mac		y0,y1,a		b,x:8		; + dy*cos(a)
	mpy		x0,y1,b		#4,r2		; dx*cos(a)
	mac		-y0,x1,b	#1,n2		; - dy*sin(a)
	asl		a
	asl		b		a,x:(r2)
	move				b,x:(r2+n2)
;-------------------------------------------------------*
;	Check z-direction of line			*
;-------------------------------------------------------*
	move				x:(r1+n1),a	; z1
	cmp		a,b		b,x:9		; z1 <=> z2 ?
	jpl		_posi
;-------------------------------------------------------*
;	Reorient line for z-clip test			*
;-------------------------------------------------------*
	move		#4,r1	
	move		#2,r2	
;-------------------------------------------------------*
;	Discard line if it lies behind viewer		*
;-------------------------------------------------------*
_posi:	move				#>(12<<8),a	; zc
	move				x:(r2+n2),b	; z2
	cmp		b,a		x:(r1+n1),x0	; z2 <=> zc ?
	jpl		_end
;-------------------------------------------------------*
;	Ignore line if it lies in front of viewer	*
;-------------------------------------------------------*
	sub		x0,a		x:(r1),x0	; (cz-z1)
	jle		_no_isect
;-------------------------------------------------------*
;	Line intersects with viewplane		 	*
;-------------------------------------------------------*
	move				x:(r2),b	; x2
	sub		x0,b		a1,x0		; (cz-z1)
	move				b1,y0		; (x2-x1)
	mpy		x0,y0,a		x:(r2+n2),b	; (x2-x1)*(cz-z1)
	move				x:(r1+n1),y0
	sub		y0,b		a,y:0
	abs		a		b1,x0		; (z2-z1)
	and		#$FE,ccr
	rep		#24
	div		x0,a				; ((x2-x1)*(cz-z1))/(z2-z1)
	move		a0,a
	jclr		#23,y:0,_xp
	neg		a
;-------------------------------------------------------*
;	Replace p1' with new intersection point		*
;-------------------------------------------------------*
_xp:	move				x:(r1),b
	add		a,b		#>(12<<8),a
	move				b,x:(r1)	; x1' = (((x2-x1)*(cz-z1))/(z2-z1))+x1
	move				a,x:(r1+n1)	; z1' = cz
;-------------------------------------------------------*
_no_isect:
;-------------------------------------------------------*
;	Reorient line back to original configuration	*
;-------------------------------------------------------*
	move		#2,r1	
	move		#4,r2	
;-------------------------------------------------------*
;	Project points into 2D viewspace		*
;-------------------------------------------------------*
	move				y:hs_width,x0
	move				y:lshft8,x1
	mpy		-x0,x1,a	x:(r1),x1	; x1
	move		a0,x0
	move				x:(r2),y1	; x2
	mpy		x0,x1,a		x:(r1+n1),x1	; z1
	mpy		x0,y1,b		x:(r2+n2),y1	; z2
	abs		a		a,x:0
	abs		b		b,y:0
	and		#$FE,ccr
	rep		#24
	div		x1,a
	move		a0,a				; (x1*hw)/z1
	and		#$FE,ccr
	rep		#24
	div		y1,b
	move		b0,b				; (x2*hw)/z2
	jclr		#23,x:0,_x1p
	neg		a
_x1p:	move		a,x1
	jclr		#23,y:0,_x2p
	neg		b
_x2p:	move		b,y1
;-------------------------------------------------------*
;	Inside / outside viewport check			*
;-------------------------------------------------------*
	move				y:rshft8,x0
	mpy		x0,x1,a		a,x:(r1)
	mpy		x0,y1,b		b,x:(r2)
	move				y:hwid,x0
	move		a1,a
	move		b1,b
	add		x0,b		#0,y0
	jmi		_end
	add		x0,a		y:width,x1
	tmi		y0,a
	cmp		x1,a		#occlusion_list,r4
	jpl		_end
	cmp		x1,b		a1,n4
	tpl		x1,b
	sub		a,b		(r4)+n4
	jle		_end
;-------------------------------------------------------*
;	Occlusion check					*
;-------------------------------------------------------*
	move		#_loop,r0
	move		y:one,a
_loop:	jset		#0,y:(r4)+,_out
	sub		a,b
	jne		(r0)
;-------------------------------------------------------*
_end:	move		#0,n4
	dspwaitwrite
	move		n4,x:(r7)
	jmp		command_base
;-------------------------------------------------------*
;	Return (x1,z1)/(x2,z2)/(rz1,rz2) data to host	*
;-------------------------------------------------------*
_out:	dspwaitwrite
	move		a,x:(r7)
	move		y:hwid_8,b
	move				x:(r1),a
	add		b,a		x:(r1+n1),x0
	dspwaitwrite
	move		a,x:(r7)
	dspwaitwrite
	move		x0,x:(r7)
	move				x:(r2),a
	add		b,a		x:(r2+n2),x0
	dspwaitwrite
	move		a,x:(r7)
	dspwaitwrite
	move		x0,x:(r7)
	move		x:8,a
	dspwaitwrite
	move		a,x:(r7)
	move		x:9,a
	dspwaitwrite
	move		a,x:(r7)
	jmp		command_base

;-------------------------------------------------------*
;	Initialise structures for a new ssector		*
;-------------------------------------------------------*
NewSsector:
;-------------------------------------------------------*
	move		y:runlink_ptr,r2
	move		y:two,n2
	move		y:height,x1
	tfr		x1,a		#0,x0
	asl		a		y:lastslots_ptr,r6
	move				a,y:index
	clr		b		n2,a1
	rep		x1
	add		a,b	x0,x:(r2)+n2	b,y:(r6)+
_vert:	move		#0,b1
	move		b1,y:cbot
	move		b1,y:fbot
	move		#256,b1
	move		b1,y:ctop
	move		b1,y:ftop
	jmp		command_base

;-------------------------------------------------------*
;	Initialise structures for a new scene		*
;-------------------------------------------------------*
NewScene:
;-------------------------------------------------------*
	move		#<$FF,b
	move		y:HTX_ptr,r7
	dspread_s	
	move		a,y:px
	dspread_s	
	move		a,y:py
	dspread_u	a
	move		a,y:pangle
	dspread		y:sina
	dspread		y:cosa
	move		#occlusion_list,r7
	move		#(miny+1),r0
	move		#(maxy+1),r4
	move		#1,a0
	move		#0,y0
	move		y:height,y1
	do		y:width,_clr
	move		a0,y:(r7)+
	move		y0,x:(r0)+
	move		y1,y:(r4)+
_clr:	move		#runstarts,r5
	move		r5,y:run_ptr
	jmp		command_base

;-------------------------------------------------------*
;	Resize viewport					*
;-------------------------------------------------------*
ResizeWindow:
;-------------------------------------------------------*
	move		y:HTX_ptr,r7
	move		#window_regs,r0
	do		#2,_lp1
	dspread_u	a
	asr		a		a,y:(r0)+
	move				a,y:(r0)+
_lp1:	do		#3,_lp2
	dspread_u	a
	move				a,y:(r0)+
_lp2:	move		y:hwid,x0
	move		y:lshft8,x1
	mpy		x0,x1,a
	move		a0,y:hwid_8
;-------------------------------------------------------*
	move		y:x1list_ptr,r0
	move		y:x2list_ptr,r4
	clr		b		y:width,a
	move		#2,b1
	add		b,a
	do		a1,_clr
	move		a0,y:(r0)+
	move		a0,y:(r4)+
;-------------------------------------------------------*
;	tnorm(8.16) = ((320/hwid)*vs_width)/r_height	*
;-------------------------------------------------------*
_clr:	move		y:r_height,x0
	move		#>320,a
	rep		#(8-1)
	asr		a
	and		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,x0
	move				y:vs_width,x1
	mpy		x0,x1,a		y:hwid,x1
	and		#$FE,ccr
	rep		#24
	div		x1,a
	move		a0,y:map_tnorm
	jmp		command_base

;-------------------------------------------------------*
;	Select projected curve interpolation		*
;-------------------------------------------------------*
PerspectCalc:
;-------------------------------------------------------*
	move		#perspected_column,r0
	move		r0,y:column_rout
	jmp		command_base

;-------------------------------------------------------*
;	Select (faster) linear interpolation		*
;-------------------------------------------------------*
LinearCalc:
;-------------------------------------------------------*
	move		#linear_column,r0
	move		r0,y:column_rout
	jmp		command_base

;-------------------------------------------------------*
;	Set new ssector luminance			*
;-------------------------------------------------------*
SetLuminance:
;-------------------------------------------------------*
	move		y:HTX_ptr,r7
	dspread_u	x0
	dspread_u	y:ceiling_luminance
	dspread_u	y:floor_luminance
	jsr		new_luminance
	jmp		command_base

;-------------------------------------------------------*
new_luminance:
;-------------------------------------------------------*
	move		#>255,a
	sub		x0,a
	move		a,x1
	mpy		x0,x1,b
	rep		#3+2
	asr		b
	asr		a	b0,y:mlum2
	asr		a
	neg		a
	add		x0,a
	asr		a
	asr		a
	move		a,y:mlum3
	rts

;-------------------------------------------------------*
;	Generic divide routine				*
;-------------------------------------------------------*
divs_x1_a:
;-------------------------------------------------------*
	abs		a		a,y:0
	and		#$FE,ccr
	rep		#24
	div		x1,a
	move		a0,a
	jclr		#23,y:0,_nn
	neg		a
_nn:	rts

;-------------------------------------------------------*
;	Read real number (24.24) from host (16.16)	*
;-------------------------------------------------------*
read_real:
;-------------------------------------------------------*
_rd1	jclr		#0,x:<<HSR,_rd1
	move		x:(r7),n7
	move		n7,x1
	mpy		x1,x0,a
	move		a0,y:(r6)
_rd2	jclr		#0,x:<<HSR,_rd2
	move		x:(r7),n7
	move		n7,a
	jclr		#15,n7,_sk
	add		b,a
_sk:	move		a1,x:(r6)
	rts

;-------------------------------------------------------*
start:
;-------------------------------------------------------*
	bclr		#2,omr
;-------------------------------------------------------*
command_base:
;-------------------------------------------------------*
;	Execute next command				*
;-------------------------------------------------------*
	clr		b	#commands,r7
	dspwaitread	
	move		x:HTX,a2
	move		a2,n7
	nop
	move		y:(r7+n7),r7
	nop
	jmp		(r7)

;-------------------------------------------------------*
;	Mark end of external program space		*
;-------------------------------------------------------*

endcode:
lasty		=	endcode

;-------------------------------------------------------*
	org		y:lasty
;-------------------------------------------------------*
;	External Y-buffers				*
;-------------------------------------------------------*

occlusion_list:		ds	320			; indicates 'sealed' columns

lastslots:		ds	256			; floating slot pointers for last-links

x1list:			ds	320+2			; defrag list #1
x2list:			ds	320+2			; defrag list #2
oslist:			ds	320+2			; defrag list #3
tlist:			ds	32			; defrag tracking list

runstarts:						; run cache

;-------------------------------------------------------*
