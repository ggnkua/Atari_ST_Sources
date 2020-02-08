



.if 0
;---------------------------------------------- Y_to_st1 ----------
; extern void Y_to_st1 ( byte *buf422, byte *screen, int count, int line ) ;
;								a0			a1				d0      d1
; use Y values (4:2:2) to produce dithering in black & white

			.export	Y_to_st1
			
Y_to_st1:	movem	d3-d5,-(sp)		; save regs.
			andi	#7,d1			; y MOD 8
			asl		#3,d1			; (y MOD 8) * 8 [word]

			asr		#3,d0			; 8 pixels / byte
			sub		#1,d0			; pixel counter

Yt1_oloop:	move	#7,d2			; 8 pixels / byte
			clr.b	d4				; start with nothing
			
Yt1_iloop:	lsl.b	#1,d4			; next LSB -> 0
			move	d1,d5			; y MOD 8 [word]
			add.b	d2,d5			; (y MOD 8 ) * 8 + (x MOD 8)
			move.b	dither(pc,d5),d5	; get dither value
			move.b	(a0)+,d3		; get Y ( 0 to 255 )
			lsr.b	#2,d3			; scale 0 to 63
			cmp.b	d5,d3			; compare Y with dither value
			bgt		Yt1_disc		; don't set bit
			
			add.b	#1,d4			; bit set

Yt1_disc:	adda	#1,a0			; discard C
			dbra	d2,Yt1_iloop	; next pixel

			move.b	d4,(a1)+		; Y --> screen++
			dbra	d0,Yt1_oloop	; next pixel
			
			movem	(sp)+,d3-d5		; retrieve regs.
			rts
.endif

;dither table
;index				 0   1   2   3   4   5   6   7		y-
;x-coordinate		 7	 6	 5	 4	 3	 2	 1	 0		coordinate
;---------------------------------------------------------------
dither:		.dc.b	42, 10, 34,  2, 40,  8, 32,  0		;0
			.dc.b	26, 58, 18, 50, 24, 56, 16, 48 		;1
			.dc.b	38,  6, 46, 14, 36,  4, 44, 12		;2
			.dc.b	22, 54, 30, 62, 20, 52, 28, 60		;3
			.dc.b	41,  9, 33,  1, 43, 11, 35,  3		;4
			.dc.b	25, 57, 17, 49, 27, 59, 19, 51		;5
			.dc.b	37,  5, 45, 13, 39,  7, 47, 15 		;6
			.dc.b	21, 53, 29, 61, 23, 55, 31, 63		;7


;---------------------------------------------- Fg_to_st1 ----------
; void Fg_to_st1	( byte *bufFg,  byte *screen, int count, int line ) ;
;							a0			a1				d0      d1
; use fast grey values to produce dithering in black & white

			.export	Fg_to_st1
			
Fg_to_st1:	movem	d3-d5,-(sp)		; save regs.
			andi	#7,d1			; y MOD 8
			asl		#3,d1			; (y MOD 8) * 8 [word]

			asr		#3,d0			; 8 pixels / byte
			sub		#1,d0			; pixel counter

Ft1_oloop:	move	#7,d2			; 8 pixels / byte
			clr.b	d4				; start with nothing
			
Ft1_iloop:	lsl.b	#1,d4			; next LSB -> 0
			move	d1,d5			; y MOD 8 [word]
			add.b	d2,d5			; (y MOD 8 ) * 8 + (x MOD 8)
			move.b	dither(pc,d5),d5; get dither value
			move.b	(a0)+,d3		; get Y ( 0 to 255 )
			lsr.b	#2,d3			; scale 0 to 63
			cmp.b	d5,d3			; compare Y with dither value
			bgt		Ft1_disc		; don't set bit
			
			add.b	#1,d4			; bit set

Ft1_disc:	dbra	d2,Ft1_iloop	; next pixel

			move.b	d4,(a1)+		; Y --> screen++
			dbra	d0,Ft1_oloop	; next pixel
			
			movem	(sp)+,d3-d5		; retrieve regs.
			rts


CONVERT	=	1		; convert intensity to VDI bank 1 pixels

IF CONVERT			;	 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f
intens_to_vdi:	.dc.b	 1,13,15,12,14,11,10, 9, 8, 5, 7, 4, 6, 3, 2, 0
intens_to_phys:	.dc.b	15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

;---------------------------------------------- Y_to_tt4 ----------
; extern void Y_to_tt4 ( byte *buf422, byte *screen, int count, int dummy ) ;
;								a0			a1				d0      d1
; Display Y from 4:2:2 in 16 grey levels

			.export	Y_to_tt4
Y_to_tt4:	movem	d4-d7,-(sp)	; save only .W

			lsr		#4,d0
			sub		#1,d0

			clr		d2
			
 Yt4_oloop:	move	#15,d1		; 16 pixels at once

 Yt4_iloop:	move.b	(a0)+,d2	; get Y	
			add		#1,a0		; forget C

			lsr.b	#4,d2
			move.b	intens_to_phys(pc,d2),d2
			lsl.b	#4,d2

			; distribute 4 Y bits 7..4 per loop, forget Y3..0

			roxl.b	#1,d2		; plane 0 bit : MSB
			roxl	#1,d4
			roxl.b	#1,d2		; plane 1 bit
			roxl	#1,d5
			roxl.b	#1,d2		; plane 2 bit
			roxl	#1,d6
			roxl.b	#1,d2		; plane 3 bit : LSB
			roxl	#1,d7
			
			dbra	d1,Yt4_iloop

			move	d7,(a1)+
			move	d6,(a1)+
			move	d5,(a1)+
			move	d4,(a1)+

			dbra	d0,Yt4_oloop
			
			movem	(sp)+,d4-d7
			rts
ELSE
;---------------------------------------------- Y_to_tt4 ----------
; extern void Y_to_tt4 ( byte *buf422, byte *screen, int count, int dummy ) ;
;								a0			a1				d0      d1
; Display 4:2:2 in 16 grey levels

			.export	Y_to_tt4
Y_to_tt4:	movem	d4-d7,-(sp)	; save only .W

			lsr		#4,d0
			sub		#1,d0


Yt4_oloop:	move	#15,d1		; 16 pixels at once

Yt4_iloop:	move	(a0)+,d2	; get Y:C, forget C

			; distribute 4 Y bits 7..4 per loop, forget Y3..0

			roxl	#1,d2		; plane 0 bit : MSB
			roxl	#1,d4
			roxl	#1,d2		; plane 1 bit
			roxl	#1,d5
			roxl	#1,d2		; plane 2 bit
			roxl	#1,d6
			roxl	#1,d2		; plane 3 bit : LSB
			roxl	#1,d7
			
			dbra	d1,Yt4_iloop
			
			move	d7,(a1)+
			move	d6,(a1)+
			move	d5,(a1)+
			move	d4,(a1)+

			dbra	d0,Yt4_oloop
			
			movem	(sp)+,d4-d7
			rts

ENDIF


;---------------------------------------------- Y_to_fa8 ----------
; extern void Y_to_fa8 ( byte *buf422, byte *screen, int count, int dummy ) ;
;								a0			a1				d0      d1
; Display 4:2:2 in 256-colours for Falcon

;  0  1  2  3  4  5  6  7  8      (byte offset)
;  Y0 C0 Y1 C1 Y2 C2 Y3 C3 Y4 ...

   			.export	Y_to_fa8

Y_to_fa8:	movem.l	d3-d7,-(sp)
			moveq	#9,d2					; used later for roxr
			lsr		#4,d0					; 16 pixels per loop
			subq	#1,d0					; counter

Yf8_oloop:	move.b	6(a0),d4				; xx xx xx Y3
			lsl		#8,d4					; xx xx Y3 00
			move.b	4(a0),d4				; xx xx Y3 Y2
			lsl.l	#8,d4					; xx Y3 Y2 00
			move.b	2(a0),d4				; xx Y3 Y2 Y1
			lsl.l	#8,d4					; Y3 Y2 Y1 00
			move.b	(a0),d4					; Y3 Y2 Y1 Y0

			addq	#8,a0					; point to Y4
			move.b	6(a0),d5				; xx xx xx Y7
			lsl		#8,d5					; xx xx Y7 00
			move.b	4(a0),d5				; xx xx Y7 Y6
			lsl.l	#8,d5					; xx Y7 Y6 00
			move.b	2(a0),d5				; xx Y7 Y6 Y5
			lsl.l	#8,d5					; Y7 Y6 Y5 00
			move.b	(a0),d5					; Y7 Y6 Y5 Y4

			addq	#8,a0					; point to Y8
			move.b	6(a0),d6				;  xx  xx  xx Y11
			lsl		#8,d6					;  xx  xx Y11  00
			move.b	4(a0),d6				;  xx  xx Y11 Y10
			lsl.l	#8,d6					;  xx Y11 Y10  00
			move.b	2(a0),d6				;  xx Y11 Y10  Y9
			lsl.l	#8,d6					; Y11 Y10  Y9  00
			move.b	(a0),d6					; Y11 Y10  Y9  Y8

			addq	#8,a0					; point to Y12
			move.b	6(a0),d7				;  xx  xx  xx Y15
			lsl		#8,d7					;  xx  xx Y15  00
			move.b	4(a0),d7				;  xx  xx Y15 Y14
			lsl.l	#8,d7					;  xx Y15 Y14  00
			move.b	2(a0),d7				;  xx Y15 Y14 Y13
			lsl.l	#8,d7					; Y15 Y14 Y13  00
			move.b	(a0),d7					; Y15 Y14 Y13 Y12

			addq	#8,a0					; point to Y16
			
			moveq	#7,d1					; loop counter
			
Yf8_1loop:	roxr.l	#1,d4					; Y0 bit 0,1,...
			roxl.w	#1,d3

			roxr.l	#1,d5					; Y4 bit 0,1,...
			roxl.w	#1,d3

			roxr.l	#1,d6					; Y8 bit 0,1,...
			roxl.w	#1,d3

			roxr.l	#1,d7					; Y12 bit 0,1,...
			roxl.w	#1,d3

			roxr.l	#8,d4					; Y1 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d4					; Y2 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d4					; Y3 bit 0,1,...
			roxl.w	#1,d3
	
			roxr.l	#8,d5					; Y5 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d5					; Y6 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d5					; Y7 bit 0,1,...
			roxl.w	#1,d3

			roxr.l	#8,d6					; Y9 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d6					; Y10 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d6					; Y11 bit 0,1,...
			roxl.w	#1,d3

			roxr.l	#8,d7					; Y13 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d7					; Y14 bit 0,1,...
			roxl.w	#1,d3
			roxr.l	#8,d7					; Y15 bit 0,1,...
			roxl.w	#1,d3

			move	d3,(a1)+				; write to screen
			
			roxr.l	d2,d4					; rotate by 9 !
			roxr.l	d2,d5
			roxr.l	d2,d6
			roxr.l	d2,d7

			dbra	d1,Yf8_1loop

			dbra	d0,Yf8_oloop

			movem.l	(sp)+,d3-d7
			rts


;---------------------------------------------- Y_to_cx8 ----------
; extern void Y_to_cx8 ( byte *buf422, byte *screen, int count, int dummy ) ;
;								a0			a1				d0     d1
; Display Y from 4:2:2 in 256 grey levels

			.export	Y_to_cx8
Y_to_cx8:	sub		#1,d0

Ycx8_loop:	move.b	(a0)+,(a1)+		; get Y
			add		#1,a0			; forget C
			dbra	d0,Ycx8_loop
			rts


;---------------------------------------------- Y_to_tc ----------
; extern void Y_to_tc ( byte *buf422, byte *screen, int count, int dummy ) ;
;								a0			a1				d0     d1
; Display Y from 4:2:2 in TC grey levels

			.export	Y_to_tc
Y_to_tc:	sub		#1,d0

Ytc_loop:	move.b	(a0)+,d1		; get Y
			move.b	#0,(a1)+		; write overlay
			move.b	d1,(a1)+		; write red
			move.b	d1,(a1)+		; write green
			move.b	d1,(a1)+		; write blue
			add		#1,a0			; forget C
			dbra	d0,Ytc_loop
			rts




;---------------------------------------------- swap_buffer ----------
; extern byte *swap_buffer ( byte *buf422, int count ) ;
;								a0			d0
			.export	swap_buffer
swap_buffer:lsr		#1,d0		; 2 pixels per swap
			sub		#1,d0

 swap_loop:	move.l	(a0),d1
 			swap	d1
 			move.l	d1,(a0)+
			dbra	d0,swap_loop

			rts




;------------------------------------------ add32_clip8 --------------
;	byte *add32_clip8 ( byte *p, int a8, long b32 )
;	a0						a0		d0			d1
; Used in YC --> 4:2:2 conversion
;
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
				
	a16c8_ok:	move.b	d0,(a0)+
				rts


		
;------------------------------------------ conv411 --------------
; extern byte *conv411 ( byte *buf411, byte *bufY )
;								a0				a1
;
;  input :	bit      : 15     8		7  6  5  4  3  2  1  0
;			format   : Y7a .. Y0a	U7 U6 V7 V6 x  x  x  x
;					   Y7b .. Y0b	U5 U4 V5 V4 x  x  x  x
;					   Y7c .. Y0c	U3 U2 V3 V2 x  x  x  x
;					   Y7d .. Y0d	U1 U0 V1 V0 x  x  x  x
;
;  output :		bufY : Ya,Yb,Yc,Yd, U,V
;				d0   : U,V

			.export conv411
conv411:	move	#3,d2
			
 c41_loop:	move.b	(a0)+,(a1)+	;	Y
			move.b	(a0)+,d0	;	C
			lsl.w	#2,d0		;	Un+1,n -> d0[9,8]
			move.b	d0,d1
			lsl.w	#2,d1		;	Vn+1,n -> d1[9,8]

			dbra	d2,c41_loop

			; U in d0[15..8],  V in d1[15..8]
 
			lsr.w	#8,d1		;	shift V
			move.b	d1,d0		; 	push U:V into buffer
			move	d0,(a1)+
			rts



;------------------------------------------ get411Y --------------
; extern int get411Y ( byte *buf411, byte *bufY, int count )
;							a0			a1         d0
;
;  input  :	4:1:1
;  output :	Ya,Yb,Yc,Yd

			.export get411Y

get411Y:	sub		#1,d0
			
gY_loop:	move.w	(a0)+,d1
			move.b	d1,(a1)+

			dbra	d0,gY_loop

			rts
			
