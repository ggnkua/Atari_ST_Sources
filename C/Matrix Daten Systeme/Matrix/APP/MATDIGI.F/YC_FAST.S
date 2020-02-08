; formats :
;			15 14 13 12 11 10 9  8 . 7  6  5  4  3  2  1  0		X
;	55o5 :	r4 r3 r2 r1 r0 g4 g3 g2. g1 g0 o  b4 b3 b2 b1 b0 -> X
;
;			7  6  5  4  3  2  1  0
;   332 :   r4 r3 r2 g4 g3 g2 b4 b3
;   reg		7l 7h 6l 6h 5l 5h 4l 4h

; shift sreg[srot] -> ( swapped dreg ) 
.macro	shibit	srot,sreg,dreg
		roxr.w	srot,sreg	; get source bit
		swap	dreg		; swap destination register
		roxl.w	#1,dreg		; shift into destination
.endm

; shift sreg[srot] -> dreg, not swapped
.macro	shibitn	srot,sreg,dreg
		roxr.w	srot,sreg	; get source bit
		roxl.w	#1,dreg		; shift into destination
.endm

;------------------------------------------ Move555ToF332Color ---------------------
;   uword *Move555ToF332Color ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1		   d0			d1
					.export Move555ToF332Color
Move555ToF332Color:	movem.l	d1/d3-d7,-(sp)

					sub		#2,d1		; zoom - 2 for dbra
					move	d1,2(sp)	; update zoom on stack
					
					asr		#4,d0		; 16 pixels / loop
					bra		b8tst
					
	b8xloop:		move	#15,d2		; pixel/word counter
	b8ploop:		move.w	(a1),d3		; get 16 bit ntc

					shibit	#4,d3,d4		; b3, skip b0..b2
					shibit	#1,d3,d4		; b4

					shibit	#4,d3,d5		; g2, skip o,g0,g1
					shibit	#1,d3,d5		; g3
					shibit	#1,d3,d6		; g4

					shibit	#3,d3,d6		; r2, skip r0,r1
					shibit	#1,d3,d7		; r3
					shibit	#1,d3,d7		; r4

					move	2(sp),d1	; test zoom & skip
					blt		b8ptst
	b8zloop:		move.w	(a1),d3		; skip 16 bit ntc
					dbra	d1,b8zloop

	b8ptst:			dbra	d2,b8ploop

					move.l	d4,(a0)+	; move 4x32 = 8x16 bit
					move.l	d5,(a0)+
					move.l	d6,(a0)+
					move.l	d7,(a0)+

	b8tst:			dbra	d0,b8xloop
					
	b8exit:			movem.l	(sp)+,d1/d3-d7
					rts

.IF 0
;---------------	s. palette.c	---------
typedef struct
{
	unsigned mask, shift, sign, rndofs ;
} TYCtoF8format ;

TYCtoF8format	yctof8_format[3] =
{
	{	0x0f, 4, 0x00, 0x08 },	// *** 2,2,4 ***
	{	0x30, 2, 0x80, 0x20 },
	{	0xc0, 0, 0x80, 0x20 }
} ;	
.ENDIF



YCformat	.equ	224
				.export yctof8_format
				dc.w	YCformat
yctof8_format:	

.IF YCformat == 224	; UVY : 2,2,4 bits
				dc.w	$0f, 4, $00, $08	;	Y
				dc.w	$30, 2, $80, $20	;	V
				dc.w	$c0, 0, $80, $20	;	U

;		 	  11 10  9  8  7  6  5  4  3  2  1  0
;   4:1:1 :   u7 u6 v7 v6 y7 y6 y5 y4 y3 y2 y1 y0
;   224	      U7 U6 V7 V6 Y7 Y6 Y5 Y4
;   reg		  7l 7h 6l 6h 5l 5h 4l 4h

ShiftOneFycPixel:	shibit	#5,d3,d4		; y4
					shibit	#1,d3,d4		; y5
					shibit	#1,d3,d5		; y6
					shibit	#1,d3,d5		; y7

					move.b	4(sp),d3	; get uv -> d3.lb
					shibit	#1,d3,d6		; v6
					shibit	#1,d3,d6		; v7
					shibit	#1,d3,d7		; u6
					shibit	#1,d3,d7		; u7
					rts
.ENDIF

.IF YCformat == 233	; UVY : 2,3,3 bits
				dc.w	$07, 5, $00, $10	;	Y
				dc.w	$38, 2, $80, $10	;	V = Cr
				dc.w	$c0, 0, $80, $20	;	U = Cb

;		 	  15 14 13 12 11 10  9  8* 7  6  5  4  3  2  1  0
;   4:1:1 :   u7 u6 v7 v6 u5 u4 v5 v4*y7 y6 y5 y4 y3 y2 y1 y0
;	uvy					   -  -     -           -  -  -  -  -
;   224	      U7 U6.V7 V6 V5.Y7 Y6 Y5
;   reg		  7l 7h 6l 6h 5l 5h 4l 4h
;  uv76,uv54,y70
ShiftOneFycPixel:	shibit	#6,d3,d4		; y5
					shibit	#1,d3,d4		; y6
					shibit	#1,d3,d5		; y7

					move.b	4(sp),d3	; get uv -> d3.lb
					shibit	#2,d3,d5		; v5
					shibit	#3,d3,d6		; v6
					shibit	#1,d3,d6		; v7
					shibit	#1,d3,d7		; u6
					shibit	#1,d3,d7		; u7
					rts
.ENDIF


					
;------------------------------------------ MoveYCToFyc224 ---------------------
;   uword *MoveYCToFyc224 ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1		   d0			d1

					.export MoveYCToFyc224
MoveYCToFyc224:		movem.l	d1/d3-d7,-(sp)

.IF 0
					sub		#2,d1		; zoom - 2 for dbra
					move	d1,2(sp)	; update zoom on stack
.ENDIF
					asr		#4,d0		; 16 pixels / loop
					bra		b8ytst
					
	b8yxloop:		move	#3,d2		; 4 * 4 pixel/word counter

	b8yploop:		move.w	(a1),d3		; get u76,v76, y#0
					move	d3,(sp)		; save pixel 0
					move.w	(a1),d1		; get u54,v54, y#1
.IF YCformat == 233	; UVY : 2,3,3 bits
					lsl		#4,d3		; uv76 -> 15..12
					and		#0xf000,d3	; mask y off
					and		#0x0fff,d1	; clear 15..12
					or		d1,d3		; == uv76,uv54,y70 pix#1
					lsr		#8,d3
					move.b	d3,(sp)		; replace xx.uv76 pix #0
.ENDIF
					move	(sp),d3		; pixel #0 y
					bsr		ShiftOneFycPixel
					move	d1,d3		; pixel #1 y
					bsr		ShiftOneFycPixel

					move.w	(a1),d3		; pixel #2
					bsr		ShiftOneFycPixel

					move.w	(a1),d3		; pixel #3
					bsr		ShiftOneFycPixel
										
.IF 0
					move	2(sp),d1	; test zoom & skip
					blt		b8yptst
	b8yzloop:		move.w	(a1),d3		; skip 16 bit ntc
					dbra	d1,b8yzloop
	b8yptst:
.ENDIF
					dbra	d2,b8yploop

					move.l	d4,(a0)+	; move 4x32 = 8x16 bit
					move.l	d5,(a0)+
					move.l	d6,(a0)+
					move.l	d7,(a0)+

	b8ytst:			dbra	d0,b8yxloop
					
	b8yexit:		movem.l	(sp)+,d1/d3-d7
					rts


;			7  6  5  4  3  2  1  0
;   332 :   g7 g6 g5 g4 g3 g2 g1 g0
;   reg		7l 7h 6l 6h 5l 5h 4l 4h

;------------------------------------------ MoveYCToF8Grey ---------------------
;   uword *MoveYCToF8Grey ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1		   d0			d1
					.export MoveYCToF8Grey
MoveYCToF8Grey:		movem.l	d1/d3-d7,-(sp)

					sub		#2,d1		; zoom - 2 for dbra
					move	d1,2(sp)	; update zoom on stack
					
					asr		#4,d0		; 16 pixels / loop
					bra		b8gtst
					
	b8gxloop:		move	#15,d2		; pixel/word counter
	b8gploop:		move.w	(a1),d3		; get 16 bit ntc

					shibit	#1,d3,d4		; g0
					shibit	#1,d3,d4		; g1
					shibit	#1,d3,d5		; g2
					shibit	#1,d3,d5		; g3
					shibit	#1,d3,d6		; g4
					shibit	#1,d3,d6		; g5
					shibit	#1,d3,d7		; g6
					shibit	#1,d3,d7		; g7

					move	2(sp),d1	; test zoom & skip
					blt		b8gptst
	b8gzloop:		move.w	(a1),d3		; skip 16 bit ntc
					dbra	d1,b8gzloop

	b8gptst:		dbra	d2,b8gploop

					move.l	d4,(a0)+	; move 4x32 = 8x16 bit
					move.l	d5,(a0)+
					move.l	d6,(a0)+
					move.l	d7,(a0)+

	b8gtst:			dbra	d0,b8gxloop
					
	b8gexit:		movem.l	(sp)+,d1/d3-d7
					rts


;------------------------------------------ MoveYCToF7Grey ---------------------
;   uword *MoveYCToF7Grey ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1		   d0			d1
					.export MoveYCToF7Grey
MoveYCToF7Grey:		movem.l	d1/d3-d7,-(sp)

					sub		#2,d1		; zoom - 2 for dbra
					move	d1,2(sp)	; update zoom on stack
					
					asr		#4,d0		; 16 pixels / loop
					bra		b7gtst
					
	b7gxloop:		move	#15,d2		; pixel/word counter
	b7gploop:		move.w	(a1),d3		; get 12 bit cy
	
					lsr.b	#1,d3		; map $00..$7e->$40..$bf
					add.b	#$40,d3

					shibit	#1,d3,d4		; g0
					shibit	#1,d3,d4		; g1
					shibit	#1,d3,d5		; g2
					shibit	#1,d3,d5		; g3
					shibit	#1,d3,d6		; g4
					shibit	#1,d3,d6		; g5
					shibit	#1,d3,d7		; g6
					shibit	#1,d3,d7		; g7

					move	2(sp),d1	; test zoom & skip
					blt		b7gptst
	b7gzloop:		move.w	(a1),d3		; skip 16 bit ntc
					dbra	d1,b7gzloop

	b7gptst:		dbra	d2,b7gploop

					move.l	d4,(a0)+	; move 4x32 = 8x16 bit
					move.l	d5,(a0)+
					move.l	d6,(a0)+
					move.l	d7,(a0)+

	b7gtst:			dbra	d0,b7gxloop
					
	b7gexit:		movem.l	(sp)+,d1/d3-d7
					rts

.if 0
;------------------------------------------ MoveYCToF7Grey ---------------------
;   uword *MoveYCToF7Grey ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1		   d0			d1
					.export MoveYCToF7Grey
MoveYCToF7Grey:		movem.l	d1/d3-d7,-(sp)

					sub		#2,d1		; zoom - 2 for dbra
					move	d1,2(sp)	; update zoom on stack
					
					asr		#4,d0		; 16 pixels / loop
					bra		b7gtst
					
	b7gxloop:		move	#15,d2		; pixel/word counter
	b7gploop:		move.w	(a1),d3		; get 16 bit ntc

					shibit	#2,d3,d4	; g1
					shibit	#1,d3,d4	; g2
					shibit	#1,d3,d5	; g3
					shibit	#1,d3,d5	; g4
					shibit	#1,d3,d6	; g5
					shibit	#1,d3,d6	; g6
					shibitn	#1,d3,d7	; g7, no swap
					
					move	2(sp),d1	; test zoom & skip
					blt		b7gptst
	b7gzloop:		move.w	(a1),d3		; skip 16 bit ntc
					dbra	d1,b7gzloop

	b7gptst:		dbra	d2,b7gploop

					move	d7,d3		; d7.h = d7.l
					swap	d7			; d7.l = ~d7.h
					move	d3,d7
					not		d7

					move.l	d4,(a0)+	; move 4x32 = 8x16 bit
					move.l	d5,(a0)+
					move.l	d6,(a0)+
					move.l	d7,(a0)+

	b7gtst:			dbra	d0,b7gxloop
					
	b7gexit:		movem.l	(sp)+,d1/d3-d7
					rts
.endif


;------------------------------------------ Blit555Rect ---------------------
;   void Blit555Rect ( uword *in, uword *out, int w, int h, int incin, int incout ) ;
;				 		a0	  	  a1		d0		d1,		d2             4/12(sp)
					.export Blit555Rect
Blit555Rect:		movem.l	d3/d4,-(sp)	; x counter
					
					subq	#1,d0		; width
					blt		brexit

					subq	#1,d1		; height
					blt		brexit
										; increment in/out, pixels -> bytes
					lsl		#1,d2		; incin
					move	12(sp),d4	; get incout
					lsl		#1,d4		

	bryloop:		move	d0,d3
	brxloop:		move.w	(a0)+,(a1)+
					dbra	d3,brxloop
					
					adda	d2,a0		; set source to start of new line
					adda	d4,a1		; set destination to start of new line
					dbra	d1,bryloop

	brexit:			movem.l	(sp)+,d3/d4
					rts


MOVElong	.equ	0

;------------------------------------------ Move555To555Color ---------------------
;   uword *Move555To555Color ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1		d0			d1
					.export Move555To555Color
Move555To555Color:	cmp		#1,d1
.if MOVElong
					beq		mvcz1
.else
					beq		mvc1test
.endif
					cmp		#2,d1
					ble		mvc2test
					cmp		#3,d1
					ble		mvc3test
					cmp		#4,d1
					ble		mvc4test

					rts
.if MOVElong
mvcz1:
					lsr		#1,d0
					bra		mvc1test
.endif

	;........ zoom == 1 ............

.if MOVElong
	mvc1loop:		move.l	(a1),(a0)+
.else
	mvc1loop:		move	(a1),(a0)+
.endif
	mvc1test:		dbra	d0,mvc1loop
					rts
					
	;........ zoom == 2 ............

	mvc2loop:		move	(a1),(a0)+	; get pixel
					tst		(a1)		; discard 1 pixel
	mvc2test:		dbra	d0,mvc2loop
					rts

	;........ zoom == 3 ............

	mvc3loop:		move	(a1),(a0)+	; get pixel
					tst		(a1)		; discard 2 pixels
					tst		(a1)
	mvc3test:		dbra	d0,mvc3loop
					rts

	;........ zoom == 4 ............

	mvc4loop:		move	(a1),(a0)+	; get pixel
					tst		(a1)		; discard 3 pixels
					tst		(a1)
					tst		(a1)
	mvc4test:		dbra	d0,mvc4loop
					rts


;------------------------------------------ MoveYCTo555Grey ---------------------
;   uword *MoveYCTo555Grey ( uword *out, uword *port, int n, unsigned zoomx )
;				 				   a0	  	  a1	   d0		d1
				.export MoveYCTo555Grey
				.import	GreyTo555Table
MoveYCTo555Grey:movem.l	d3/a2,-(sp)

				lea		GreyTo555Table,a2
				clr		d3
				
				subq	#1,d1
				bgt		mvgztest
				bra		mvg1test

	;........ zoom == 1 ............

	mvg1loop:	move	(a1),d2			; zoom == 1
				move.b	d2,d3			; unsigned extension	
				move	(a2,d3.w*2),(a0)+
	mvg1test:	dbra	d0,mvg1loop
				bra		mvgreturn

	;........ zoom == 2 ............

	mvgzloop:	move	(a1),d2
				move.b	d2,d3			; unsigned extension	
				move	(a2,d3.w*2),(a0)+
				tst		(a1)			; discard pixel
	mvgztest:	dbra	d0,mvgzloop

	mvgreturn:	movem.l	(sp)+,a2/d3
				rts

.macro	_move4b	dn,an
		roxl.l	#8,dn		; move dn[3]
		move.b	dn,(an)+
		roxl.l	#8,dn		; move dn[2]
		move.b	dn,(an)+
		roxl.l	#8,dn		; move dn[1]
		move.b	dn,(an)+
		roxl.l	#8,dn		; move dn[0]
		move.b	dn,(an)+
.endm

	
;------------------------------------------ MoveWordRegisterFiles ---------------------
;   uword *MoveWordRegisterFiles ( uword *out, uword *port, int n )
;				 						a0	  	  		a1	d0
; 'n' * MoveRegisterFile

GRABcntrlReg	.equ	$f70001			; s. mdf_addr.h

.if 0
I2C .EQU	$f78001
SDA	.equ	$01
SCL	.equ	$02
	lea	I2C,a2				

		cmp		#-1,d4
		bne		xxx
		move.b	#SDA,(a2)
		move.b	#0,(a2)	
	xxx:
.endif

		.xdef		GrabShiftEnable,GrabShiftDisable
.macro	StartMove	dn
		.super
		move		sr,dn			; disable irq
		ori			#$0700,sr
		.user
		move.b		GrabShiftEnable,GRABcntrlReg
.endm

.macro	EndMove		dn
		move.b		GrabShiftDisable,GRABcntrlReg
		.super
		move		dn,sr			; enable irq
		.user
.endm

.macro	GetB02	s,d
						; data : b0 b2
		move.b	s,d		; .. .. .. b0
		swap	d		; .. b0 .. ..
		move.b	s,d		; .. b0 .. b2
.endm
				
.macro	OrB13	s,d
						; data : b1 b3
		ror.l	#8,d	; b2 .. b0 ..
		move.b	s,d		; b2 .. b0 b1
		swap	d		; b0 b1 b2 ..
		move.b	s,d		; b0 b1 b2 b3
.endm

				.export MoveByteRegisterFiles
MoveByteRegisterFiles:
				movem.l	d3-d5,-(sp)

				StartMove	d5
				bra		mbrftest
									;	hi	lo	hi-bytes
	mbrfloop:	GetB02	(a1),d1		; 	 0	 2 	b0	b1
				GetB02	(a1),d2		; 	 4	 6	g0	g1
				GetB02	(a1),d3		; 	 8	10	g2	b0
				GetB02	(a1),d4		; 	12	14	b1	b2
				
				movem.l	d1-d4,(a1)	; 8 writes / SClk
									;	hi	lo	lo-bytes
				OrB13	(a1),d1		;	 1	 3 	b0	b1
				OrB13	(a1),d2		;	 5	 7	g0	g1
				OrB13	(a1),d3		;	 9	11	g2	b0
				OrB13	(a1),d4		;	13	15	b1	b2
				
.if 1
				movem.l	d1-d4,(a0)	; 8 w - writes / SClk
				add		#16,a0
.else

.macro	movhig	dn
				swap	dn
				move	dn,(a0)+
				swap	dn
.endm
.macro	movlow	dn
				move	dn,(a0)+
.endm
				

.if 0
				movhig	d2	; b0
				movlow	d3	; b1
				movlow	d1	; g0
				movhig	d3	; g1
				movlow	d4	; g2
				movhig	d1	; r0
				movlow	d2	; r1
				movhig	d4	; r2
.endif
.if 0
				movlow	d3	; b1
				movhig	d2	; b0
				movlow	d4	; g2
				movhig	d3	; g1
				movlow	d1	; g0
				movhig	d4	; r2
				movlow	d2	; r1
				movhig	d1	; r0
.endif
.if 0								; alles rot
				movlow	d2	; r1
				movhig	d4	; r2

				movhig	d1	; r0
				movlow	d2	; r1
				movhig	d4	; r2

				movhig	d1	; r0
				movlow	d2	; r1
				movhig	d4	; r2
.endif
.endif

	mbrftest:	dbra	d0,mbrfloop

				EndMove	d5

				movem.l	(sp)+,d3-d5
				rts


; uword *MoveZXByteRegisterFiles ( uword *out, uword *port, int n, int zx )
;									a0			a1			d0		d1
				.export MoveZXByteRegisterFiles
MoveZXByteRegisterFiles:
				movem.l	d3-d7,-(sp)

				move	d1,d6		; get zoom

				StartMove	d5
				bra		mzbrftest
									;	hi	lo	hi-bytes
	mzbrfloop:	GetB02	(a1),d1		; 	 0	 2 	b0	b1
				GetB02	(a1),d2		; 	 4	 6	g0	g1
				GetB02	(a1),d3		; 	 8	10	g2	b0
				GetB02	(a1),d4		; 	12	14	b1	b2
				
				movem.l	d1-d4,(a1)	; 8 writes / SClk
									;	hi	lo	lo-bytes
				OrB13	(a1),d1		;	 1	 3 	b0	b1
				OrB13	(a1),d2		;	 5	 7	g0	g1
				OrB13	(a1),d3		;	 9	11	g2	b0
				OrB13	(a1),d4		;	13	15	b1	b2
				
				movem.l	d1-d4,(a0)	; 8 w - writes / SClk
				add		#16,a0
	mzbrftest:	dbra	d0,mzbrfloop

				EndMove	d5

				movem.l	(sp)+,d3-d7
				rts




				.export MoveWordRegisterFiles
MoveWordRegisterFiles:
				movem.l	d3-d5,-(sp)

				StartMove	d5
				bra		mwrftest
				
	mwrfloop:	movem.l	(a1),d1-d4
				movem.l	d1-d4,(a0)
				movem.l	d1-d4,(a1)	; add. 8 writes / SClk
				add		#16,a0
	mwrftest:	dbra	d0,mwrfloop

				EndMove	d5

				movem.l	(sp)+,d3-d5
				rts

;------------------------------------------ MoveRegisterFile ---------------------
;   uword *MoveRegisterFile ( uword *out, uword *port )
;				 				a0	  	  		a1
; move 8 x 16 bit = 4 x 3 bit Dx from 'port' to 'out'
				.export MoveRegisterFile
MoveRegisterFile:movem.l	d3-d4,-(sp)

				movem.l		(a1),d0-d4

				StartMove	d4
	.if 0
				movem.l	d0-d3,(a0)
				add		#16,a0
	.else
				_move4b	d0,a0
				_move4b	d1,a0
				_move4b	d2,a0
				_move4b	d3,a0
	.endif
				EndMove	d4

				movem.l	(sp)+,d3-d4
				rts

;------------------------------------------ SkipW ---------------------
;   void SkipW  ( uword *port, int n )
;					   a0	  d0
				.export SkipW
SkipW:			subq	#1,d0
				blt		skwreturn

;				addq	#-ADDskipW,d0
				
				StartMove	d1				
				
	skwloop:	move	d0,(a0)		; write to any location
				dbra	d0,skwloop

				EndMove	d1				
				
	skwreturn:	rts
				
				
;------------------------------------------ Skip ---------------------
;   void Skip  ( uword *port, int n )
;					   a0	  d0
				.export Skip
Skip:			subq	#1,d0
				blt		skreturn
	skloop:		move	(a0),d1
				dbra	d0,skloop
	skreturn:	rts
				
;------------------------------------------ add32_clip8 --------------
;	int add32_clip8 ( int a8, long b32 )
;	 d0					d0			d1
			.export	add32_clip8
								; result ( max. bits )
add32_clip8:	asr.l	#8,d1	;	20->12
				add		d1,d0	;	8+12
				bpl		a16c8_posi

				move	#0,d0	; underflow
				bra		a16c8_ok

	a16c8_posi:	cmp		#255,d0
				ble		a16c8_ok
				
				move	#255,d0	; overflow
				
	a16c8_ok:	rts


;---------------------------------------------------------------------
; uword yuv_to_ntc ( uword y, uword cr, uword cb )
;					  d0		d1			d2			

		.export	yuv_to_ntc
		.import	ntc_table

yuv_to_ntc:							; get cr			d1 = y1Cr
				AND.W	#$00F8,d1	;	    [7..3]		     00Cr
				LSL.W	#2,d1		;	 -> [9..5]			 0cr0
									; cb	[7..3]		d2 = xxCb
				LSR.b	#3,d2		;	 -> [4..0]			 xxcb
				OR.b	d2,d1		; -> cr/cb in d1	d1 = 0crb

				LSL.W	#8,d0		; y -> [15.. 8]
;	???			AND.W	#$FC00,d0	;      [15..10]		d0 = y000
				AND.L	#$FC00,d0	; get y				d0 = y000
				OR.W	d1,d0		;						 ycrb

				LEA.L	ntc_table,A0
				MOVE.W	(a0,d0.w*2),d0

				RTS
				
;---------------------------------------------------------------------
; uword yc_to_ntc ( int y0cb, int y1cr )
;					  d0		d1

		.export	yc_ntc_line
		.import	ntc_table

yc_to_ntc:							; get cr			d1 = y1Cr
				AND.W	#$00F8,d1	;					     00Cr
				LSL.W	#2,d1		;	 -> [9..5]			 0cr0
				MOVE.b	d0,d2		; get cb			d2 = xxCb
				LSR.b	#3,d2		;	 -> [4..0]			 xxcb
				OR.b	d2,d1		; -> cr/cb in d1	d1 = 0crb

				AND.W	#$FC00,d0	; get y0			d0 = y000
				OR.W	d1,d0		;						 ycrb

				LEA.L	ntc_table,A0
				MOVE.W	(a0,d0.w*2),d0

				RTS
				
;---------------------------------------------------------------------
; void yc_ntc_line ( uword *sd, uword *dd, int w )
;							   a0		  a1	 d0

		.export	yc_ntc_line
		.import	ntc_table

yc_ntc_line:	movem.l	D3-d6/A2,-(A7)
				LEA.L	ntc_table,A2

;				illegal

				clr.l	d1			; unsigned ext for (A2,di.l*2)
				clr.l	d2
				
				move	#$FC00,d5	; y  - mask ( 6 bit )
				move	#$00F8,d6	; cr - mask ( 5 bit )

				lsr		#1,d0
				bra		ycnl_entry
				
	ycnl_loop:	MOVE.W	(A0)+,D1	; y0cb
				MOVE.W	(A0)+,D2	; y1cr

				MOVE.W	D2,D3		; get cr			d3 = y1Cr
				AND.W	d6,D3		;					     00Cr
				LSL.W	#2,D3		;	 -> [9..5]			 0cr0
				MOVE.b	D1,D4		; get cb			d4 = xxCb
				LSR.b	#3,D4		;	 -> [4..0]			 xxcb
				OR.b	D4,D3		; -> cr/cb in d3	d3 = 0crb

				AND.W	d5,d1		; get y0			d1 = y000
				OR.W	D3,d1		;						 ycrb
				MOVE.W	(A2,d1.l*2),(A1)+

				AND.W	d5,d2		; get y1			d2 = y100
				OR.W	D3,d2		;						 ycrb
				MOVE.W	(A2,d2.l*2),(A1)+
			
	ycnl_entry:	dbra	d0,ycnl_loop

				movem.l	(A7)+,D3-d6/A2
				RTS


; void yc_gray_line ( uword *sd, uword *dd, int w )
;							   a0		  a1	 d0

		.export	yc_gray_line

yc_gray_line:move	d3,-(a7)

				move	#11,d3
	gycnl_loop:	MOVE.W	(A0)+,D1	; yc

				lsr		d3,d1		; get 5 msbits -> blue
				move	d1,d2		; |........|...bbbbb|
				lsl		#6,d1		; -> green
				or		d1,d2		; |.....ggg|gg.bbbbb|
				lsl		#5,d1		; -> red
				or		d1,d2		; |rrrrrggg|gg.bbbbb|
				
				MOVE.W	d2,(A1)+
				dbra	d0,gycnl_loop

				move	(a7)+,d3
				RTS

