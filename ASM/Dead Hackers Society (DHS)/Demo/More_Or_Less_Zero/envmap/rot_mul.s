		section	text

; s[i] = (i*i/4)>>SHIFTDOWN
; x = s[a+x0] - s[a-x0] + s[b+y0] - s[b-y0] + s[c+z0] - s[c-z0]
; y = s[d+x0] - s[d-x0] + s[e+y0] - s[e-y0] + s[f+z0] - s[f-z0]
; z = s[g+x0] - s[g-x0] + s[h+y0] - s[h-y0] + s[i+z0] - s[i-z0]


; in   d0      number of vertices
;      a0      source vertices (x,y,z), pre-scaled by 2
;      a1      dest vertices (x,y,z)
;      a2      coeff table (9 words)

;      d1      origin x
;      d2      origin y
;      d3      origin z

XX_	=	 0+0
XY_	=	 0+2
XZ_	=	 0+4
YX_	=	 6+0
YY_	=	 6+2
YZ_	=	 6+4
ZX_	=	12+0
ZY_	=	12+2
ZZ_	=	12+4

X0_	=	0
Y0_	=	2
Z0_	=	4


extratab:	dc.l	0,0,0
copymatrix:	ds.w	3*3

transform_mul6:
                MOVE.W  D0,d7
		subq.l	#1,d7
		
		lea.l	copymatrix,a5
		moveq.l	#9-1,d6
.scale:
		move.w	(a2)+,d0
		asr.w	#1,d0
		move.w	d0,(a5)+
		dbra	d6,.scale

		lea.l	copymatrix,a2
		lea.l	extratab,a4
		move.w	XX_(a2),d0
		muls	XY_(a2),d0
		move.l	d0,(a4)+
		move.w	YX_(a2),d0
		muls	YY_(a2),d0
		move.l	d0,(a4)+
		move.w	ZX_(a2),d0
		muls	ZY_(a2),d0
		move.l	d0,(a4)
		subq.l	#8,a4

.trans:
		movem.w	(a0)+,d4-d6	; x/y/z/yz

		move.w	d5,d1
		add.w	(a2)+,d1
		move.w	d4,d0		; x
		add.w	(a2)+,d0
		muls	d1,d0
		move.w	d6,d1
		muls	(a2)+,d1
		add.l	d1,d0
		sub.l	(a4)+,d0

		move.w	d5,d2
		add.w	(a2)+,d2
		move.w	d4,d1		; y
		add.w	(a2)+,d1
		muls	d2,d1
		move.w	d6,d2
		muls	(a2)+,d2
		add.l	d2,d1
		sub.l	(a4)+,d1

		move.w	d5,d3
		add.w	(a2)+,d3
		move.w	d4,d2		; z
		add.w	(a2)+,d2
		muls	d3,d2
		move.w	d6,d3
		muls	(a2)+,d3
		add.l	d3,d2
		sub.l	(a4),d2

		;asr.l	#7,d2
		;asr.l	#8,d2
		;asr.l	#5,d0
		;asr.l	#8,d0
		;asr.l	#5,d1
		;asr.l	#8,d1
		asr.l	#7,d2
		asr.l	#8,d2
		asr.l	#5,d0
		asr.l	#8,d0
		asr.l	#5,d1 
		asr.l	#8,d1

		movem.w	d0/d1/d2,(a1)
		addq.l	#8,a1

		subq.l	#2*4,a4
		sub.l	#18,a2

                dbra    d7,.trans
                rts

transform_mul6_pro:
                MOVE.W  D0,d7
		subq.l	#1,d7

		;move.l	#800,a3		; project-const
		move.l	project_const,a3

		lea.l	copymatrix,a5
		moveq.l	#9-1,d6
.scale:
		move.w	(a2)+,d0
		asr.w	#1,d0
		move.w	d0,(a5)+
		dbra	d6,.scale

		lea.l	copymatrix,a2
		lea.l	extratab,a4
		move.w	XX_(a2),d0
		muls	XY_(a2),d0
		move.l	d0,(a4)+
		move.w	YX_(a2),d0
		muls	YY_(a2),d0
		move.l	d0,(a4)+
		move.w	ZX_(a2),d0
		muls	ZY_(a2),d0
		move.l	d0,(a4)

		lea	env_inv_table+2*32768,a6
		subq.l	#8,a4
.trans:
		movem.w	(a0)+,d4-d6	; x/y/z/yz

		move.w	d5,d1
		add.w	(a2)+,d1
		move.w	d4,d0		; x
		add.w	(a2)+,d0
		muls	d1,d0
		move.w	d6,d1
		muls	(a2)+,d1
		add.l	d1,d0
		sub.l	(a4)+,d0

		move.w	d5,d2
		add.w	(a2)+,d2
		move.w	d4,d1		; y
		add.w	(a2)+,d1
		muls	d2,d1
		move.w	d6,d2
		muls	(a2)+,d2
		add.l	d2,d1
		sub.l	(a4)+,d1

		move.w	d5,d3
		add.w	(a2)+,d3
		move.w	d4,d2		; z
		add.w	(a2)+,d2
		muls	d3,d2
		move.w	d6,d3
		muls	(a2)+,d3
		add.l	d3,d2
		sub.l	(a4),d2

;		asr.l	#8,d2
;		asr.l	#8,d2
		swap	d2
		asr.l	#8,d0
		asr.l	#8,d1
		asr.l	#1,d0
		asr.l	#1,d1
;		swap	d0
;		swap	d1

		add.l	a3,d2

;		divs	d2,d0
;		divs	d2,d1

;		asr.l	#8,d0
;		asr.l	#8,d1
;		asr.l	#1,d0
;		asr.l	#1,d1

		move.l	d2,d3	;d3 scratch
		add.w	d3,d3
		move.w	(a6,d3.w),d3
		muls	d3,d0
		muls	d3,d1
		swap	d0
		swap	d1
		
;		asr.l	#1,d2

		movem.w	d0/d1/d2,(a1)
		
		addq.l	#8,a1
		subq.l	#2*4,a4
		sub.l	#18,a2
                dbra    d7,.trans
                rts

project_const:	dc.l	0	; set in env.s runtime_init

transform_mul:
                MOVE.W  D0,D7
                SUBQ.W  #1,D7

		move.l	project_const,a3		; project-const
		move.l	a3,d4
;		asr.l	#1,d4
		move.l	d4,a3		;fixa rtt storlek p projconst

.trans:
		movem.w	(a0)+,d4-d6

		move.w	d4,d0		; x
		muls	XX_(a2),d0
		move.w	d5,d1		; y
		muls	XY_(a2),d1
		add.l	d1,d0
		move.w	d6,d1		; z
		muls	XZ_(a2),d1
		add.l	d1,d0		; X1

		move.w	d4,d1		; x
		muls	YX_(a2),d1
		move.w	d5,d2		; y
		muls	YY_(a2),d2
		add.l	d2,d1
		move.w	d6,d2		; z
		muls	YZ_(a2),d2
		add.l	d2,d1

		muls	ZX_(a2),d4
		muls	ZY_(a2),d5
		add.l	d5,d4
		muls	ZZ_(a2),d6
		add.l	d6,d4

		asr.l	#8,d4
		asr.l	#8,d4
		asr.l	#8,d0
		asr.l	#8,d1

		asr.l	#1,d0
		asr.l	#1,d1

		add.l	a3,d4

;		cmp.l	#10,d4
;		bgt.s	.div
;		moveq	#10,d4
;.div:
		divs	d4,d0
		divs	d4,d1
	
		movem.w	d0/d1/d4,(a1)
		addq.l	#8,a1

		dbra    d7,.trans
		rts

		section	text
