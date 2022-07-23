rotPoints3d:
	lea points3d,a5
	lea points3dOut,a6
	move.l	points3dCnt,d7
	move.w	#ROT_SCR_H/2,d5
	move.w	#ROT_SCR_V/2,d6
	move.w	#50+256+40,a4	; persp

	;move.w	#0,rotMode3d
	
	cmp.w	#0,rotMode3d
	bne.s	_rot3d1
	bsr 	rotPoint3dZY
	bra.s	_rot3d2	
_rot3d1
	bsr 	rotPoint3dZX
_rot3d2

	;update angles
	move.w	rot3dAngleZ,d0
	addq.b	#ROT_STEP_3D,d0
	bne.s	_notChangeRotMode3d
	not.w	rotMode3d
_notChangeRotMode3d	
	move.w	d0,rot3dAngleZ

	move.w	rot3dAngleY,d0
	addq.b	#ROT_STEP_3D,d0
	move.w	d0,rot3dAngleY

	move.w	rot3dAngleX,d0
	addq.b	#ROT_STEP_3D,d0
	move.w	d0,rot3dAngleX

	; test
	;move.w	rot3dAngleZ,d0
	;addq.b	#ROT_STEP_3D,d0
	;move.w	d0,rot3dAngleZ

	rts

		macro rot3dPerspMarc		
		; move to camera coords system
		neg.w	d\3

		; camera (0,0,50)
		add.w	a4,d\3
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
rotPoint3dZY:
		lea		sin3d(pc),a2
		lea		cos3d(pc),a3

		move.w	rot3dAngleZ,d2 ; angle z!
		move.w	(a2,d2.w*2),a0	;	sin z
		move.w	(a3,d2.w*2),a1	;	cos z

		move.w	rot3dAngleY,d2 ; angle y!
		move.w	(a2,d2.w*2),a2	;	sin y
		move.w	(a3,d2.w*2),a3	;	cos y

_rotPoint3dZYLoop
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

		rot3dPerspMarc 0,1,2

		; scr position
		add.w	d5,d0
		add.w	d6,d1

		movem.w	d0-d1,(a6)
		addq.l	#4,a6
		dbf d7,_rotPoint3dZYLoop
		rts
	
;	a5 points in
;	a6 points out
;	d5 x scr off
;	d6 y scr off
;	d7 count-1
rotPoint3dZX:
		lea		sin3d(pc),a2
		lea		cos3d(pc),a3

		move.w	rot3dAngleZ,d2 ; angle z!
		move.w	(a2,d2.w*2),a0	;	sin z
		move.w	(a3,d2.w*2),a1	;	cos z

		move.w	rot3dAngleX,d2 ; angle x!
		move.w	(a2,d2.w*2),a2	;	sin x
		move.w	(a3,d2.w*2),a3	;	cos x

_rotPoint3dZXLoop
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
		rot3dPerspMarc 3,4,2
		
		; scr position
		add.w	d5,d3
		add.w	d6,d4

		movem.w	d3-d4,(a6)
		addq.l	#4,a6
		dbf d7,_rotPoint3dZXLoop
		rts
