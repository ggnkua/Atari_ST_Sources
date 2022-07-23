GOU3D_PERSP equ	50+256+40

gouPoints3d:
	lea points3d_gou,a5
	lea gouPoints3dOut,a6
	move.l	gouPoints3dCnt,d7
	move.w	#GOU_POS_H,d5
	move.w	#GOU_SCR_V/2,d6
	
	ifeq	GOU_ZBUFF
	move.w	#GOU3D_PERSP,a4	; persp
	endif
	ifne	GOU_ZBUFF
	lea gouPoints3dOutZ,a4
	endif

	;move.w	#0,gouMode3d
	
	cmp.w	#0,gouMode3d
	bne.s	_gou3d1
	bsr 	gouPoint3dZY
	bra.s	_gou3d2	
_gou3d1
	bsr 	gouPoint3dZX
_gou3d2

	;update angles
	move.w	gou3dAngleZ,d0
	addq.b	#GOU_STEP_3D,d0
	bne.s	_gouNotChangeRotMode3d
	not.w	gouMode3d
_gouNotChangeRotMode3d	
	move.w	d0,gou3dAngleZ

	move.w	gou3dAngleY,d0
	addq.b	#GOU_STEP_3D,d0
	move.w	d0,gou3dAngleY
	
	move.w	gou3dAngleX,d0
	addq.b	#GOU_STEP_3D,d0
	move.w	d0,gou3dAngleX

	; test
	;move.w	gou3dAngleY,d0
	;addq.b	#GOU_STEP_3D,d0
	;move.w	d0,gou3dAngleY
	rts

		macro gou3dPerspMarc	
		; move to camera coords system

		ifne	GOU_ZBUFF
		move.w	d\3,(a4)+
		endif
		neg.w	d\3

		; camera (0,0,50)
		ifeq	GOU_ZBUFF
		add.w	a4,d\3
		endif
		ifne	GOU_ZBUFF
		add.w	#GOU3D_PERSP,d\3
		endif
		
		; calc new x and y
		
		ext.l	d\1
		lsl.w	#8,d\1
		divs.w	d\3,d\1

		ext.l	d\2
		lsl.w	#8,d\2
		divs.w	d\3,d\2
		endm

;	a5 points in
;	a6 points out
;	d5 x scr off
;	d6 y scr off
;	d7 count-1
gouPoint3dZY:
		lea		gou_sin3d,a2
		lea		gou_cos3d,a3

		move.w	gou3dAngleZ,d2 ; angle z!
		move.w	(a2,d2.w*2),a0	;	sin z
		move.w	(a3,d2.w*2),a1	;	cos z

		move.w	gou3dAngleY,d2 ; angle y!
		move.w	(a2,d2.w*2),a2	;	sin y
		move.w	(a3,d2.w*2),a3	;	cos y

_gouPoint3dZYLoop
		movem.w	(a5)+,d0-d2

		; x*cos
		move.w	a1,d3	; cos	
		muls.w	d0,d3	; x*cos	d3.l	

		; y*sin
		move.w	a0,d4	; sin
		muls.w	d1,d4	; y*sin	d4.l

		; x'
		sub.l	d4,d3
		add.l	d3,d3
		swap	d3		; x' d3.w

		; x*sin
		move.w	a0,d4
		muls.w	d4,d0	; x*sin	d0.l

		; y*cos
		move.w	a1,d4
		muls.w	d4,d1	; y*cos d1.l

		; y'
		add.l	d0,d1
		add.l	d1,d1
		swap	d1		; y' d1.w

		; x'*cos
		move.w	a3,d0
		muls.w	d3,d0

		; z*sin
		move.w	a2,d4
		muls.w	d2,d4
		
		; x''
		sub.l	d4,d0
		add.l	d0,d0
		swap	d0	;	x'' d0.w
		
		; x'*sin
		move.w	a2,d4
		muls.w	d4,d3
		
		; z*cos
		move.w	a3,d4
		muls.w	d4,d2
		
		; z'
		add.l	d3,d2
		add.l	d2,d2
		swap	d2	;	z'	d2.w

		gou3dPerspMarc 0,1,2

		; scr position
		add.w	d5,d0
		add.w	d6,d1

		movem.w	d0-d1,(a6)
		addq.l	#4,a6
		dbf d7,_gouPoint3dZYLoop
		rts
	
;	a5 points in
;	a6 points out
;	d5 x scr off
;	d6 y scr off
;	d7 count-1
gouPoint3dZX:
		lea		gou_sin3d,a2
		lea		gou_cos3d,a3

		move.w	gou3dAngleZ,d2 ; angle z!
		move.w	(a2,d2.w*2),a0	;	sin z
		move.w	(a3,d2.w*2),a1	;	cos z

		move.w	gou3dAngleX,d2 ; angle x!
		move.w	(a2,d2.w*2),a2	;	sin x
		move.w	(a3,d2.w*2),a3	;	cos x

_gouPoint3dZXLoop
		movem.w	(a5)+,d0-d2

		; x*cos
		move.w	a1,d3	; cos	
		muls.w	d0,d3	; x*cos	d3.l	

		; y*sin
		move.w	a0,d4	; sin
		muls.w	d1,d4	; y*sin	d4.l

		; x'
		sub.l	d4,d3
		add.l	d3,d3
		swap	d3		; x' d3.w

		; x*sin
		move.w	a0,d4
		muls.w	d4,d0	; x*sin	d0.l

		; y*cos
		move.w	a1,d4
		muls.w	d4,d1	; y*cos d1.l

		; y'
		add.l	d0,d1
		add.l	d1,d1
		swap	d1		; y' d1.w

		; y'*cos
		move.w	a3,d4
		muls.w	d1,d4

		; z'*sin
		move.w	a2,d0
		muls.w	d2,d0

		; y''
		sub.l	d0,d4
		add.l	d4,d4
		swap	d4	;	y'' d4.w
		
		; z'*cos
		move.w	a3,d0
		muls.w	d0,d2
		
		; y'*sin
		move.w	a2,d0
		muls.w	d1,d0
		
		; z''
		add.l	d0,d2
		add.l	d2,d2
		swap	d2	;	z''	d2.w

		; x,y,z = d3,d4,d2
		gou3dPerspMarc 3,4,2
		
		; scr position
		add.w	d5,d3
		add.w	d6,d4

		movem.w	d3-d4,(a6)
		addq.l	#4,a6
		dbf d7,_gouPoint3dZXLoop
		rts
