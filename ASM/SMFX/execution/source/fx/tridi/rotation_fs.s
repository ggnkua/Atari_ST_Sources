; Rz =	|	cos A	-sin A	0		|
;		|	sin A	cos A	0		|
;		|	0		0		1		|
;
;
; Ry =	|	cos B	0		sin B 	|
;		|	0		1		0		|
;		|	-sin B	0		cos B	|
;
; Rx =	|	1		0		0		|
;		|	0		cos C	-sin C	|
;		|	0		sin C	cos C	|
;
;	V = |	x	|
;		|	y	|
;		|	z	|
;
;	x' = Rz * V	=	x * cos A	- y * sin A
;	y' = Rz * V =	x * sin A	+ y * cos A
;	z' = z
;
;	V'= |	x'	|	
;		|	y'	|
;		|	z	|
;
;	x''= Ry * V' =	x' * cos B	+ z	* sin B
;	y''= y'
;	z''= Ry * V' =	x' *-sin B	+ z * cos B
;
;	V''=|	x''	|
;		|	y''	|
;		|	z''	|
;
;	x'''=x''
;	y'''=Rx * V''= 

colorvisible 					equ TRUE				; only advance color when a face is visible, instead of advancing color every face; FALSE = each face has fixed color

symmetricalObject				equ 0

usemul							equ	FALSE				; use codepath with multiplication table
sintable_size_tridi				equ	512*2				; 512 entries of wordsize
PERSPECTIVE						equ 1190				; yes, distance for perspective


	SECTION BSS
sourceVerticesPointer			ds.l	1
rotation_perspectivePointer		ds.l	1
_zx								ds.l	1
_zy								ds.l	1
_zz								ds.l	1
_yz								ds.l	1

currentVertices					ds.w	300
;projectedVertices				ds.w	100


_sinA		equr d1
_cosA		equr d2
_sinB		equr d3
_cosB		equr d4
_sinC		equr d5
_cosC		equr d6

	SECTION TEXT
_sinBsinC	dc.w	0
_cosAcosC	dc.l	0
_sinAcosC	dc.l	0

; todo:
;	- save and restore `multiple uses' of multiplication, to avoid recalculation every time
calculateRotatedProjectionExpLogMatrix
    move.w	_currentStepX,d2
    move.w	_currentStepY,d4
    move.w	_currentStepZ,d6

.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		_sintable,a0
	lea		_sintable+(sintable_size_tridi/4),a1

	move.w	(a0,d2.w),d1					; _sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; _cosA						16

	move.w	(a0,d4.w),d3					; _sinB	;around y axis		16
	move.w	(a1,d4.w),d4					; _cosB						16

	move.w	(a0,d6.w),d5					; _sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; _cosC						16

	move.l	explog_logpointer,d0		;20	

; xx = cos(A) * cos(B)
	move.w	_cosA,d7
	muls	_cosB,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),oxx+2
;xy = [sin(A)cos(B)]		
	move.w	_sinA,d7
	muls	_cosB,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),oxy+2
;xz = [sin(B)]
	move.w	_sinB,d0
	asr.w	#7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),oxz+2
;yz = [-cos(B)sin(C)]
	move.w	_cosB,d7
	neg.w	d7
	muls	_sinC,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),oyz+2
; zz = [cos(B)cos(C)]
	move.w	_cosB,d7
	muls	_cosC,d7
;	move.l	d7,_zz
	swap	d7
	move.w	d7,_zz
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),ozz+2
;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
	move.w	_sinA,d4
	muls	_cosC,d4	
	move.l	d4,a0			; save for zy
	move.w	_cosA,d7
	muls	_sinB,d7
	swap	d7
	add.w	d7,d7
	muls	_sinC,d7
	add.l	d7,d4	
	swap	d4
	asr.w	#6,d4
	move.w	d4,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),oyx+2
;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
	move.w	_cosA,d7
	muls	_cosC,d7
	move.l	d7,a1			; save for zx
	neg.l	d7
	move.w	_sinA,d4
	muls	_sinB,d4
	swap	d4
	add.w	d4,d4
	muls	_sinC,d4
	add.l	d4,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),oyy+2
;zx = [sin(A)sin(C) - cos(A)sin(B)cos(C)]
	move.w	_sinA,d7
	muls	_sinC,d7
	move.l	a1,d4
	swap	d4
	add.l	d4,d4
	muls	_sinB,d4
	sub.l	d4,d7
;	move.l	d7,_zx
	swap	d7
	move.w	d7,_zx
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),ozx+2
;zy = [-cos(A)sin(C) - sin(A)sin(B)cos(C)]
	move.w	_cosA,d4
	neg.w	d4
	muls	_sinC,d4
	move.l	a0,d1
	swap	d1
	add.w	d1,d1
	muls	_sinB,d1
	sub.l	d1,d4
;	move.l	d4,_zy
	swap	d4
	move.w	d4,_zy
	asr.w	#6,d4
	move.w	d4,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),ozy+2
.setupComplete		
	rts	

calculateRotatedProjectionExpLog
	;				old				new	
	; a2	xx		000000FE		000000FF
	; a1	xy		00000002		00000003
	; a0	xy		00000003		00000003
	; a3	yx		00000002		00000003
	; a4	yy		FFFFFF01		FFFFFF00
	; a6	yz		FFFFFFFD		FFFFFFFC
	; d7	zx		0000FFFD		728E0003
	; d3	zy		0002FFFC		0002FFFC
	; d4	zz		000000FE		000000FF
	lea		currentVertices,a5					;8	
	lea		projectedVertices,a6				;8

	move.w	number_of_vertices,d5				;20
	subq	#1,d5								;4

	move.l	explog_logpointer,d0		;20	


	move.l	rotation_perspectivePointer,d1				;20

	move.l	explog_expointer,d2						;20
	move.l	d2,d3								;4

	move.w	_vertices_xoff,d4				;12
	move.w	_vertices_yoff,d7				;12
;	add.w	d4,d4
;	add.w	d4,d4

;	add.w	d7,d7
;	add.w	d7,d7
	; vertices x,y
	; d4,d7

	; d0 explog-log
	; d1 perspective
	; d2-d3 explog-exp
	; d4 x_off
	; d5 loopcounter
	; d6 free
	; d7 y_off
	; a0-a2 addresses
	; a3 local
	; a4 _visible vertices
	; a5 source
	; a6 dest

;	d0,d1,d2,d3,d4,d5,d6,d7
;	a0,a1,a2,a3,a4,a5,a6

;	move.w	_vblcounter,d6


orotationLoop

		movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
		;	z
ozx		move.w		1234(a0),d1	;12			; z*zx ... +
ozy		add.w		1234(a1),d1	;12			; z*zy ... +
ozz		add.w		1234(a2),d1	;12			; z*zz
		move.l		d1,a3		;4			; perspective value pointer
		move.w		(a3),d2		;8			; perspective value as log value
		move.w		d2,d3		;4			; duplicate	
								;--> 	52
	
		;	x	
oxx		move.w		1234(a0),d0	;12			; x*xx ... +
oxy		add.w		1234(a1),d0	;12			; x*xy ... +
oxz		add.w		1234(a2),d0	;12			; x*xz 
		move.l		d0,a3		;4			; logpointer
		add.w		(a3),d2		;8			; add to focal length ( x * perspective )
		move.l		d2,a3		;4			; use exptable pointer
	
		move.w		(a3),d2		;8			; exppointer norm value
		add.w		d4,d2		;4			; add object x_offset
		move.w		d2,(a6)+	;8			; store x
								;-->	72
	
		;	y
oyx		move.w		1234(a0),d0	;12			; z*zx ... +
oyy		add.w		1234(a1),d0	;12			; z*zy ... +
oyz		add.w		1234(a2),d0	;12			; z*zz
		move.l		d0,a3		;4			; logpointer
		add.w		(a3),d3		;8			; add to local length ( y * perspective )
		move.l		d3,a3		;4			; use exptable pointer
	
		move.w		(a3),d3		;8			; exppointer norm value
		add.w		d7,d3		;4			; add object y_offset
		move.w		d3,(a6)+	;8			; store y
								;-->	72
	dbra	d5,orotationLoop		;12			; 24 + 52 + 2*72 + 12 = 36 + 212 = 232 for x,y,z rotation with perspective
	rts

onext
		add.w	#6,a5
		add.w	#4,a6
	dbra	d5,orotationLoop
	rts


_a7	dc.w	0
_a8	dc.w	0
_a9	dc.w	0





advanceRotationStep
    move.w  #sintable_size_tridi-1,d7								;8

    movem.w	_stepSpeedX,d0-d2							;32

    add.w	_currentStepX,d0							;16
    and.w	d7,d0										;4
    move.w	d0,_currentStepX							;16

    subq.w	#1,rotationWaiter
    bge		.no3d
    add.w	_currentStepY,d1							;16
    and.w	d7,d1										;4
    move.w	d1,_currentStepY							;16

    add.w	_currentStepZ,d2							;16
    and.w	d7,d2										;4
    move.w	d2,_currentStepZ							;16			--> 3*36 +32 = 140
.no3d
    rts


rotationWaiter	dc.w	404


;_camx	dc.w	0
;_camy	dc.w	0
;_camz	dc.w	0

; todo:
;	for symmetrical objects, make sure we layout it such, that we have each face paired with the other
;	then if we determine the culling of one, we can implicitly determine the culling for the other
;	this halves this time
cullByNormals
	; we have to clear the colors of the lines
;	move.l	currentEorLinesPointer,a0
	lea		eorEdgesLower,a0
	moveq	#0,d0
	move.w	number_of_edges,d1
	add.w	d1,d1
	add.w	d1,d1
	lea		.clearColors+2,a1
	sub.w	d1,a1
	jmp		(a1)

o set (100-1)*6
	REPT 100
		move.w	d0,o(a0)
o set o-6
	ENDR
.clearColors

	; now to set visiblity
;	lea		cubeEorFaces2,a6
;	move.w	#0,d0
;	move.w	#0,d1
	move.w	#-1024*2,d2
	; normal:
	;	|	cosBcosC		cosCsinAsinB - cosAsinC		cosAcosCsinB + sinAsinC
	;	|	cosBsinC		cosAcosC + sinAsinBsinC		cosAsinBsinC - cosCsinA
	;	|	-sinB			cosBsinA					cosAcosB 

	; inverse:
	;	|	cosBcosC					cosBsinC					-sinB
	;	|	cosCsinAsinB - cosAsinC		cosAcosC + sinAsinBsinC		cosBsinA	
	;	|	cosAcosCsinB + sinAsinC		cosAsinBsinC - cosCsinA		cosAcosB 

	; thus now:
	;	x * xx + y * yx + z*zx
	;	x * xy + y * yy + z*zy
	;	x * xz + y * yz + z*zz
;	move.w	a0,d3
;	muls	d0,d3		; but is 0
;	move.w	a3,d4
;	muls	d1,d4		; but is 0
;	add.l	d4,d3		; yes its 0
	move.w	_zx,d6				;16
	muls	d2,d6				;x
;	add.l	d3,d4
	swap	d6					;4
;	move.w	d4,_camx		
;	move.w	d4,d6				;4

;	move.w	a1,d3
;	muls	d0,d3		;	0
;	move.w	a4,d4
;	muls	d1,d4		; 0
;	add.l	d4,d3
	move.w	_zy,d4
	muls	d2,d4	
;	add.l	d3,d4
	swap	d4
;	move.w	d4,_camy
	move.w	d4,a5

;	move.w	a2,d3
;	muls	d0,d3
;	move.w	_yz,d4
;	muls	d1,d4
;	add.l	d4,d3
	move.w	_zz,d3
	muls	d2,d3
;	add.l	d3,d4
	swap	d3
;	move.w	d4,_camz
;	move.w	d4,a6



determineCull	macro
;		move.l	(a0)+,a2			; this can be removed if we replace the pointers int he data structure by the actual vertices data
;	
;		move.w	(a2)+,d0
;		sub.w	d6,d0
;		muls.w	(a0)+,d0
;	
;		move.w	(a2)+,d1
;		sub.w	a5,d1
;		muls.w	(a0)+,d1
;		add.l	d1,d0
;	
;		move.w	(a2)+,d1
;		sub.w	a6,d1
;		muls.w	(a0)+,d1
;		add.l	d1,d0

		move.w	(a0)+,d0			
		move.w	(a0)+,d1
		move.w	(a0)+,d2
		sub.w	d6,d0
		sub.w	a5,d1
		sub.w	d3,d2
		muls	(a0)+,d0
		muls	(a0)+,d1
		muls	(a0)+,d2
		add.l	d1,d0
		add.l	d2,d0
	endm

markVisibleVerticesAndColorEdge macro


		move.w	(a1)+,d0				; indication of how many edges
		add.w	d0,d0		;4													; this can be won by changing the data layout of the object
		jmp		.markVertices\@(pc,d0.w)
	REPT 9	
			move.w	(a1)+,a2			; get edge pointer	(color, proj_vert1, proj_vert2)	;8			;2		4 -> 16
			eor.w	d5,(a2)+			; set color mask, increase							;12			;2		
	ENDR
.markVertices\@
	endm



cullOpt


;	move.w	a6,d3
;	lea		_palettenormals,a6	
	move.l	_paletteNormalPointer2,a6

	; now we have the transformed camera of inverse, then we match this with the normal vectors
	move.l	currentFaceNormalsPointer,a0
	move.l	currentEorFacesPointer,a1
	lea		_colors,a3
	move.w	number_of_faces,d7
;	lsr.w	#1,d7
	subq.w	#1,d7

	; d4 = free
	move.w	_vblcounter,d4


	IFEQ symmetricalObject
.newloop
	

	IFEQ	colorvisible
	ELSE
		move.w	(a3)+,d5
	ENDC
			determineCull
	bgt		.newvisible
.newNotVisible
	sub.w	(a1)+,a1
	dbra	d7,.newloop
	move.w	#-4,(a6)
	rts
.newvisible
	IFEQ	colorvisible
		move.w	(a3)+,d5
	ENDC
		swap	d0
		move.w	d0,(a6)+
			markVisibleVerticesAndColorEdge
	dbra	d7,.newloop
	move.w	#-4,(a6)
	rts			



	ELSE


;;;;; old stuff
.loop
	IFEQ	colorvisible
	ELSE
		move.w	(a3)+,d5
	ENDC
			determineCull
	bgt		.visiblefirst
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.notvisiblefirst
	sub.w	(a1)+,a1

	IFEQ	colorvisible
	ELSE
		move.w	(a3)+,d5
	ENDC
			determineCull
	bgt		.visiblesecond
.notvisibleSecond
	sub.w	(a1)+,a1
	dbra	d7,.loop

	move.w	#-1,(a6)
	rts


.visiblesecond
	IFEQ	colorvisible
		move.w	(a3)+,d5
	ENDC
		swap	d0
		move.w	d0,(a6)+
			markVisibleVerticesAndColorEdge
.markVerticessecond
	dbra	d7,.loop

	move.w	#-1,(a6)
	rts

; if the first face is visible, then the second one is not, we know this, since we order the faces such that a sequent face is in a parallel plane
.visiblefirst
	IFEQ	colorvisible
		move.w	(a3)+,d5
	ENDC
		swap	d0
		move.w	d0,(a6)+
			markVisibleVerticesAndColorEdge
.markVerticesfirst
	; and we know second is done
	IFEQ	colorvisible
	ELSE
		move.w	(a3)+,d5
	ENDC
	sub.w	(a1)+,a1
	add.w	#12,a0

	dbra	d7,.loop

	rts
	ENDC

;;;;;;;;;;; NEW AND IMPROVED
;	d0,d1 	local
;	d2		framecounter
;	d3		free
;	d4		free


_colors
	REPT 50
		dc.w	1<<1
		dc.w	2<<1
		dc.w	3<<1
		dc.w	4<<1
		dc.w	5<<1
		dc.w	6<<1
		dc.w	7<<1
;		dc.w	8<<1
	ENDR


_paletteNormalPointer	dc.l	_palettenormals2
_paletteNormalPointer2	dc.l	_palettenormals

_palettenormals		
	dc.w	-1
	ds.l	16

_palettenormals2
	dc.w	-1
	ds.l	16

_colorsdd
;	incbin		"fx/tridi/3D2.PAL"
;	dc.w	$100,$200,$300,$400,$410,$510,$520,$620,$630,$640,$650,$750,$760,$771,$774,$777 ; golden (more red)

			;0		1	2	3		4	5	6	7	8		9	10	11	12		13	14	15	16	17		18	19	
	dc.w	$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656,$756,$766,$767		;0
	dc.w	$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656,$756,$766		;1
	dc.w	$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656,$756		;2
	dc.w	$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656		;3
	dc.w	$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646		;4
	dc.w	$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546		;5	
	dc.w	$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536		;6	
	dc.w	$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436		;7
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426		;8
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326		;9
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216,$316		;10
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206,$216		;11
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205,$206		;12
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204,$205		;13
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203,$204		;14
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202,$203		;15
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201,$202		;16
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$201		;17
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$200		;18
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100		;19
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;20
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;21


	dc.w $100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656,$756,$766,$767 ;1
	dc.w $100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656,$756,$766,$767 ;2
	dc.w $100,$200,$201,$202,$203,$204,$205,$206,$216,$316,$326,$426,$436,$536,$546,$646,$656,$756,$766,$767 ;3
	dc.w $100,$200,$201,$202,$203,$204,$205,$305,$215,$414,$325,$425,$435,$535,$545,$645,$655,$755,$766,$767 ;4
	dc.w $100,$200,$201,$201,$203,$204,$304,$305,$215,$414,$325,$425,$435,$535,$545,$645,$655,$755,$766,$767 ;5
	dc.w $100,$200,$201,$201,$302,$302,$304,$305,$215,$414,$325,$434,$534,$535,$545,$654,$655,$755,$766,$767 ;6
	dc.w $100,$200,$201,$201,$302,$302,$304,$305,$314,$414,$424,$434,$534,$534,$544,$654,$664,$754,$765,$767 ;7
	dc.w $100,$200,$200,$301,$302,$302,$304,$314,$314,$423,$424,$434,$534,$534,$544,$654,$664,$754,$765,$767 ;8
	dc.w $100,$200,$200,$301,$302,$302,$304,$314,$314,$423,$424,$533,$543,$534,$544,$654,$664,$754,$765,$767 ;9
	dc.w $100,$200,$200,$301,$302,$302,$303,$314,$413,$423,$434,$533,$543,$634,$644,$754,$764,$754,$765,$767 ;10
	dc.w $100,$200,$200,$301,$301,$321,$303,$314,$413,$423,$434,$533,$543,$634,$644,$754,$764,$753,$765,$767 ;11
	dc.w $100,$200,$200,$301,$301,$321,$303,$412,$413,$523,$433,$543,$643,$634,$644,$754,$764,$753,$765,$776 ;12
	dc.w $100,$200,$200,$311,$301,$321,$303,$412,$512,$523,$433,$543,$643,$643,$653,$754,$763,$753,$775,$776 ;13
	dc.w $100,$200,$200,$311,$301,$321,$412,$412,$512,$523,$433,$543,$643,$643,$653,$753,$763,$753,$775,$776 ;14
	dc.w $100,$200,$300,$311,$401,$411,$412,$412,$512,$523,$533,$542,$642,$643,$653,$753,$763,$763,$775,$776 ;15
	dc.w $100,$200,$300,$311,$401,$411,$412,$421,$522,$522,$533,$542,$642,$642,$762,$753,$763,$763,$775,$776 ;16
	dc.w $100,$200,$300,$311,$401,$411,$412,$421,$522,$522,$532,$542,$751,$642,$762,$752,$762,$763,$775,$776 ;17
	dc.w $100,$200,$300,$310,$401,$411,$411,$421,$522,$531,$532,$641,$751,$752,$762,$752,$762,$773,$775,$776 ;18
	dc.w $100,$200,$300,$310,$400,$411,$411,$421,$621,$531,$541,$641,$751,$752,$762,$752,$762,$773,$774,$776 ;19
	dc.w $100,$200,$300,$310,$400,$410,$411,$520,$621,$531,$541,$641,$750,$751,$761,$762,$772,$773,$774,$776 ;20
	dc.w $100,$200,$300,$310,$400,$410,$510,$520,$620,$630,$640,$650,$750,$751,$761,$762,$772,$773,$774,$776 ;21
	dc.w $100,$200,$300,$310,$400,$410,$510,$520,$620,$630,$640,$650,$750,$751,$761,$762,$772,$773,$774,$776 ;22






	dc.w	$100,$200,$300,$310,$400,$410,$510,$520,$620,$630,$640,$650,$750,$751,$761,$762,$772,$773,$774,$776		;0
	dc.w	$000,$100,$200,$300,$300,$400,$500,$420,$520,$530,$540,$550,$650,$651,$661,$662,$662,$663,$664,$666		;1
	dc.w	$000,$000,$100,$200,$200,$300,$400,$320,$420,$430,$440,$450,$550,$551,$561,$562,$662,$662,$663,$664		;2
	dc.w	$000,$000,$000,$100,$200,$200,$300,$220,$320,$330,$340,$350,$450,$451,$461,$462,$562,$662,$662,$663		;3
	dc.w	$000,$000,$000,$000,$100,$100,$200,$210,$310,$320,$330,$340,$440,$441,$451,$461,$462,$562,$662,$662		;4
	dc.w	$000,$000,$000,$000,$000,$100,$200,$200,$300,$310,$320,$330,$340,$341,$441,$451,$461,$462,$562,$662		;5
	dc.w	$000,$000,$000,$000,$000,$000,$100,$200,$200,$210,$220,$230,$330,$331,$341,$441,$451,$461,$462,$562		;6
	dc.w	$000,$000,$000,$000,$000,$000,$000,$100,$200,$200,$210,$220,$230,$231,$331,$341,$441,$451,$461,$462		;7
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$210,$220,$230,$231,$231,$331,$341,$441,$451,$461		;8
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$100,$100,$110,$120,$220,$230,$231,$231,$331,$341,$441,$451		;9
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$100,$110,$120,$220,$230,$231,$231,$341,$441,$451		;10	
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$100,$120,$120,$220,$230,$231,$331,$341,$441		;11
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$020,$120,$120,$220,$230,$231,$331,$341		;12
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$120,$220,$230,$231,$331		;13
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220,$230,$230,$231		;14
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220,$230,$231		;15
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220,$230		;16
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220		;17
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120		;18
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020		;19
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010		;20
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;21








	dc.w	$000,$100,$200,$300,$300,$400,$500,$420,$520,$530,$540,$550,$650,$651,$661,$662,$662,$663,$664,$666		;1		yellow
	dc.w	$000,$000,$100,$200,$200,$300,$400,$320,$420,$430,$440,$450,$550,$551,$561,$562,$662,$662,$663,$664		;2
	dc.w	$000,$000,$000,$100,$200,$200,$300,$220,$320,$330,$340,$350,$450,$451,$461,$462,$562,$662,$662,$663		;3
	dc.w	$000,$000,$000,$000,$100,$100,$200,$210,$310,$320,$330,$340,$440,$441,$451,$461,$462,$562,$662,$662		;4
	dc.w	$000,$000,$000,$000,$000,$100,$200,$200,$300,$310,$320,$330,$340,$341,$441,$451,$461,$462,$562,$662		;5
	dc.w	$000,$000,$000,$000,$000,$000,$100,$200,$200,$210,$220,$230,$330,$331,$341,$441,$451,$461,$462,$562		;6
	dc.w	$000,$000,$000,$000,$000,$000,$000,$100,$200,$200,$210,$220,$230,$231,$331,$341,$441,$451,$461,$462		;7
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$100,$200,$210,$220,$230,$231,$231,$331,$341,$441,$451,$461		;8
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$100,$100,$110,$120,$220,$230,$231,$231,$331,$341,$441,$451		;9
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$100,$110,$120,$220,$230,$231,$231,$341,$441,$451		;10	
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$100,$120,$120,$220,$230,$231,$331,$341,$441		;11
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$100,$020,$120,$120,$220,$230,$231,$331,$341		;12
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$120,$220,$230,$231,$331		;13
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220,$230,$230,$231		;14
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220,$230,$231		;15
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220,$230		;16
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120,$220		;17
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$120		;18
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$020		;19
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$010		;20
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000		;21		black

_colorsddoffset	dc.w	20*21*2
_colorsddoffset2	dc.w	0
_colorsddwaiter	dc.w	70



; originals
;	dc.w	$101,$102,$202,$212,$222,$322,$332,$432,$442,$542,$552,$652,$562,$664,$675,$777 ; lets test this too
;	dc.w	$100,$200,$300,$310,$320,$420,$430,$530,$540,$640,$650,$750,$660,$762,$773,$777 ; golden (more yellow)




; purplol
; 	dc.w	$101	;0
; 	dc.w	$102	;1
; 	dc.w	$202	;2
;	dc.w	$302	;3
;	dc.w	$303	;4
;	dc.w	$304	;5
;	dc.w	$404	;6
;	dc.w	$504	;7
;	dc.w	$505	;8
;	dc.w	$515	;9
;	dc.w	$516	;10
;	dc.w	$616	;11
;	dc.w	$626	;12
;	dc.w	$636	;13
;	dc.w	$736	;14
;	dc.w	$737	;15

_thresholds
;	dc.w	$0010	;0
;	dc.w	$0020	;1
;	dc.w	$0030	;2
;	dc.w	$0040	;3
;	dc.w	$0050	;4
;	dc.w	$0060	;5
;	dc.w	$0070	;6
;	dc.w	$0080	;7
;	dc.w	$0090	;8	
;	dc.w	$00A0	;9
;	dc.w	$00B0	;10
;	dc.w	$00C0	;11
;	dc.w	$00D0	;12
;	dc.w	$00E0	;13
;	dc.w	$00F0	;14		;15 totla

	dc.w	17; 0
	dc.w	34; 1
	dc.w	51; 2
	dc.w	68; 3
	dc.w	84; 4
	dc.w	100; 5
	dc.w	116; 6
	dc.w	130; 7
	dc.w	144; 8
	dc.w	157; 9
	dc.w	170; 10
	dc.w	181; 11
	dc.w	192; 12
	dc.w	201; 13
	dc.w	210; 14
	dc.w	217; 15
	dc.w	223; 16
	dc.w	228; 17
	dc.w	232; 18
	dc.w	235; 19
	dc.w	236; 20






doPalette_tridi
	lea		$ffff8242,a0		; target palette
	move.l	_paletteNormalPointer2,a1
	lea		_colorsdd,a2
	add.w	_colorsddoffset,a2
	add.w	_colorsddoffset2,a2
	lea		_thresholds,a3
.loop
		moveq	#0,d3
		move.l	a3,a4			; reset threshold loop
		move.w	(a1)+,d0		; get current normal
		blt		.end
		REPT 1
			cmp.w	(a4)+,d0
			bgt		*+6
			move.w	(a2),(a0)+
			jmp		.loop
		ENDR
o set 2
		REPT 10
			cmp.w	(a4)+,d0
			bgt		*+8
			move.w	o(a2),(a0)+
			jmp		.loop
o set o+2
		ENDR
		REPT 10
			cmp.w	(a4)+,d0
			bgt		*+10
			move.w	o(a2),(a0)+
			jmp		.loop
o set o+2
		ENDR

.end
	cmp.w	#20*21*2,_colorsddoffset
	beq		.magic
	lea		$ffff8240+2*1,a0
	lea		$ffff8240+8*2,a1
	lea		textRamp,a2
	add.w	textRampOff,a2
	move.w	(a2)+,(a1)+
	REPT 7
		move.w	(a0)+,(a1)+
	ENDR
	jmp		.magicend



.magic
	lea		textRamp,a2
	add.w	textRampOff,a2
	move.w	(a2),d0
	lea		$ffff8240+8*2,a0
	rept 8	
		move.w	d0,(a0)+
	endr
.magicend
	subq.w	#1,textRampWaiter
	bge		.kk
		move.w	#1,textRampWaiter
		subq.w	#2,textRampOff
		bge		.kk
			move.w	#86,textRampOff
			subq.w	#1,fadecounterxx
			bge		.kkkk
				move.w	#800,textRampWaiter
.kkkk
			subq.w	#1,fullscreenfadetimes
			bge		.kk
				add.w	#22*20*2,_colorsddoffset2
				move.w	#3,fullscreenfadetimes
				add.w	#6*2*5,realtimeOff
				cmp.w	#6*2*5*3,realtimeOff
				bne		.kk
					move.w	#6*2*5*2,realtimeOff
.kk

;	cmp.w	#230+192+192+70,tridiframes
	cmp.w	#230+60,tridiframes
	ble		.objectfadeout
	sub.w	#1,_colorsddwaiter
	bge		.skip
		move.w	#2,_colorsddwaiter
		sub.w	#20*2,_colorsddoffset
		bge		.skip
			move.w	#0,_colorsddoffset
.skip	
	rts
.objectfadeout
	sub.w	#1,_colorsddwaiter
	bge		.skip
		move.w	#2,_colorsddwaiter
		add.w	#20*2,_colorsddoffset
		cmp.w	#21*20*2,_colorsddoffset
		ble		.okxx
			move.w	#21*20*2,_colorsddoffset
.okxx
	rts

fadecounterxx	dc.w	13
fullscreenfadetimes	dc.w	4

textRampWaiter	dc.w	0
textRampOff		dc.w	90
textRamp
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
textRamp2
	dc.w	$0
	dc.w	$111
	dc.w	$111
	dc.w	$111
	dc.w	$222
	dc.w	$222
	dc.w	$333
	dc.w	$444
	dc.w	$444
	dc.w	$555
	dc.w	$555
	dc.w	$555
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$777
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$555
	dc.w	$555
	dc.w	$555
	dc.w	$444
	dc.w	$444
	dc.w	$333
	dc.w	$222
	dc.w	$222
	dc.w	$111
	dc.w	$111
	dc.w	$111
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0
	dc.w	$0



setSizeObject
	lea		_sizeTab,a0
	add.w	_sizeCounter,a0
	move.w	(a0),d2
	move.w	d2,_previousSize
	move.w	_resizeStep,d0
	add.w	d0,_sizeCounter
	cmp.w	#512,_sizeCounter
	blt		.cont
		move.w	#0,_sizeCounter
.cont
	move.l	sourceVerticesPointer,a0
	lea		currentVertices,a1
	move.l	explog_logpointer,d6
	move.w	#pivotexp,d0						; base address of low memory

	move.w	d2,d6
	move.l	d6,a2
	move.w	(a2),d1
	add.w	d0,d1

	neg		d2
	move.w	d2,d6
	move.l	d6,a2
	move.w	(a2),d2
	add.w	d0,d2

	;d1 is pos
	;d2 is neg
;p0	dc.w	negsize,negsize,negsize	; (-1,-1,-1)
	move.w 	d2,(a1)+
	move.w	d2,(a1)+
	move.w	d2,(a1)+
;p1	dc.w	possize,negsize,negsize ; ( 1,-1,-1)
	move.w 	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d2,(a1)+
;p2	dc.w	negsize,possize,negsize	; (-1, 1,-1)
	move.w 	d2,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
;p3	dc.w	possize,possize,negsize	; ( 1, 1,-1)
	move.w 	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
;p4	dc.w	negsize,negsize,possize	; (-1,-1, 1)
	move.w 	d2,(a1)+
	move.w	d2,(a1)+
	move.w	d1,(a1)+
;p5	dc.w	possize,negsize,possize ; ( 1,-1, 1)
	move.w 	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d1,(a1)+
;p6	dc.w	negsize,possize,possize	; (-1, 1, 1)
	move.w 	d2,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
;p7	dc.w	possize,possize,possize	; ( 1, 1, 1)
	move.w 	d1,(a1)+
	move.w	d1,(a1)+
	move.w	d1,(a1)+
	rts


; this can be made better by premultiplying the source *2
; this can also be written for each individual object, and make the morph explicit
initObject
	move.l	sourceVerticesPointer,a0
	lea		currentVertices,a1
	move.l	explog_logpointer,d6
	move.w	number_of_vertices,d7
;	subq.w	#1,d7
	move.w	#pivotexp,d0						; base address of low memory

	lea		.jmpMarker,a6

	add.w	d7,d7	;4
	add.w	d7,d7	;4
	move.w	d7,d2	;4
	lsl.w	#3,d7	;12
	add.w	d2,d7	;4

	sub.w	d7,a6
	jmp		(a6)

.loop
	REPT 50
	REPT 3									; for x,y,z
		move.w	(a0)+,d6		;8
		add.w	d6,d6			;4
		move.l	d6,a2			;4
		move.w	(a2),d1			;8
		add.w	d0,d1			;4
		move.w	d1,(a1)+		;8		-> 36*3	
	ENDR
	ENDR
.jmpMarker
;	dbra	d7,.loop
	rts

initObjectMultable
	move.l	sourceVerticesPointer,a0
	lea		currentVertices,a1
	move.w	number_of_vertices,d7
	subq.w	#1,d7
.loop
	REPT 3									; for x,y,z
		move.w	(a0)+,d0
		add.w	d0,d0
		move.w	d0,(a1)+		;8
	ENDR
	dbra	d7,.loop
	rts


initZTable
	move.l	rotation_perspectivePointer,d0
	move.l	d0,a0
	moveq	#0,d1
	move.w	#255-1,d7
	move.l	#PERSPECTIVE<<7,d3
	move.l	#PERSPECTIVE,d5
	moveq	#-4,d6
	move.w	#-2,d0
	move.l	d0,a1
	add.w	#2,a1	;predrecement fix
.loop
		move.l	d1,d4
		add.w	d5,d4		;8
		move.l	d3,d2		;12
		divs.w	d4,d2			;146
		add.w	d2,d2
;		move.w	#0,(a0)+
		move.w	d2,(a0)+
		addq.w	#2,d1

		move.l	d6,d4
		add.w	d5,d4
		move.l	d3,d2
		divs.w	d4,d2
		add.w	d2,d2
;		move.w	#0,(a1)
		move.w	d2,-(a1)
		subq.w	#2,d6

	dbra	d7,.loop
	move.w	#$4e75,initZTable
	rts





fixFaceNormals
	move.l	currentFaceNormalsPointer,a0
	move.w	number_of_faces,d7
	subq.w	#1,d7
.loop
		move.l	(a0),a1
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		add.w	#6,a0
	dbra	d7,.loop
	rts


; this is for eorfilling, specifically, drawing lines
; this part is structured as:
;	dc.w	indication if need to be skipped (<= 0), value determines bitplane to be drawn (11,10,01)
;	dc.w	pointer first vertex
;	dc.w	pointer second vertex
copyCurrentEorEdgesToLower
	move.l	currentEorLinesPointer,a0
	lea		eorEdgesLower,a1
	move.w	number_of_edges,d7					; replace with jumptable
	subq.w	#1,d7
.copy
	REPT 3
		move.w	(a0)+,(a1)+
	ENDR
	dbra	d7,.copy
	move.l	#-2,(a1)+				;-1 termination
	rts


	SECTION DATA
_sizeTab		include 	fx/tridi/resize.s
_sintable		include		fx/tridi/sintable_amp32768_steps512.s


; 8 * 8 = 16
; , shift right 8, 8 left
; 12*12 = 24

	SECTION BSS
_vertices_xoff	ds.w	1
_vertices_yoff	ds.w	1
_stepSpeedX		ds.w	1
_stepSpeedY		ds.w	1
_stepSpeedZ		ds.w	1

_sizeCounter	ds.w	1
_previousSize	ds.w	1
_resizeStep		ds.w	1

_currentStepX	ds.w	1
_currentStepY	ds.w	1
_currentStepZ	ds.w	1