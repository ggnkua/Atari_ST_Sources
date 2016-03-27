CHKrange		.equ	1
;	matrix :	dim, scale, offset,
;				[0,0],[0,1],..,[dim-2,dim-1],[dim-1,dim-1]

dimension	.equ	0	; matrix[ix]
scale		.equ	1
offset		.equ	2
modifier	.equ	3
coeff		.equ	4

.macro	muladd	source
		.local	ma_ex
		move	2*matix(a1),d7	; matrix coefficient
		beq		ma_ex
		clr		d5
		move.b	source,d5
		muls	d7,d5
		add		d5,d6
ma_ex:
	matix	.set	matix+1
.endm


;......................................... macro filter ........

.macro	filter	dim
		.local	fil_rgb,fily_loop,filx_loop,fil_return
.if CHKrange
		.local	fil_under,fil_over,fil_cut
.endif

.macro	mulXadd	base
								; y,x
			muladd 	  (base)	; y,0
			muladd	 4(base)	; y,1
			muladd	 8(base)	; y,2
.if dim == 5
			muladd	12(base)	; y,3
			muladd	16(base)	; y,4
.endif
.endm


;......................................... fil_rgb .............
fil_rgb:	clr		d6
			matix	.set	coeff	; start with coefficient [0,0]
								; y,x
			mulXadd	a0			; 0,x
		; a0 auto incremented at the end of the procedure
			mulXadd	a2			; 1,x
			addq	#1,a2
			mulXadd	a3			; 2,x
			addq	#1,a3
.if dim == 5
			mulXadd	a4			; 3,x
			addq	#1,a4
			mulXadd	a5			; 4,x
			addq	#1,a5
.endif

			add		2*offset(a1),d6
			ext.l	d6
			divs	2*scale(a1),d6
.if CHKrange
			bmi		fil_under
			cmp		#255,d6
			bgt		fil_over
			move.b	d6,(a0)+		; ok, store result
			rts

fil_under:	tst		2*modifier(a1)
			beq		fil_cut

			neg.b	d6				; abs ( result )
			move.b	d6,(a0)+		; ok, store result
			rts

fil_cut:	clr.b	(a0)+			; cut negative result
			rts

fil_over:	st		(a0)+
			rts
.else
			move.b	d6,(a0)+		; ok, store result
			rts
.endif

;....................................................................................

used3_regs	.reg	d3-d7/a2-a3
used5_regs	.reg	d3-d7/a2-a5

;	d3 :	dx_count
;	d4 :	bpl - dx * 4 ( end of line to start of next line )
;	d5 : 	source r,g or b value
;	d6 :	sum of mat *
;	d7 :	m[i,j]

; void filterDxD ( long *pixa, byte *matrix, int dx, int dy, int bpl ) ;
;				      a0			a1			d0		d1		d2


				.export	filter&dim&x&dim&
filter&dim&x&dim&:
				movem.l	#used&dim&_regs,-(sp)

				sub 	#dim,d0				; correct border dx,dy - dim
				bmi		fil_return
				sub 	#dim,d1
				bmi		fil_return

				move	d0,d4				; d4 = bpl - dx' * 4
				add		#1,d4
				lsl		#2,d4
				sub		d2,d4
				neg		d4

				move.l	a0,a2	; line[1]
				add		d2,a2
				move.l	a2,a3	; line[2]
				add		d2,a3
.if dim == 5
				move.l	a3,a4	; line[3]
				add		d2,a4
				move.l	a4,a5	; line[4]
				add		d2,a5
.endif

	fily_loop:	move	d0,d3

	filx_loop:	add		#1,a0				; overlay
				add		#1,a2
				add		#1,a3
.if dim == 5
				add		#1,a4
				add		#1,a5
.endif
				bsr		fil_rgb				; R
				bsr		fil_rgb				; G
				bsr		fil_rgb				; B

				dbra	d3,filx_loop

				add		d4,a0			; start of next window line
				add		d4,a2
				add		d4,a3
.if dim == 5
				add		d4,a4
				add		d4,a5
.endif
				dbra	d1,fily_loop

	fil_return:	movem.l	(sp)+,#used&dim&_regs
				rts
.endm


	filter	3	;	filter3x3
	filter	5	;	filter5x5

; void matrix_filter ( long *pixa, int *matrix, int dx, int dy, int bpl ) ;
;					      a0			a1			d0		d1		d2
			.export	matrix_filter
matrix_filter:	cmp	#3,(a1)
				beq	filter3x3

				cmp	#5,(a1)
				beq	filter5x5

				; bad matrix dimension

				rts
