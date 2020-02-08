;------------------------------------------ add32_clip8 --------------
;	byte *add32_clip8 ( byte *p, int a8, long b32 )
;	a0						a0		d0			d1
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


;------------------------------------------ conv422 --------------
; extern byte *conv422 ( byte *buf422, byte *bufY, ??? )
;							a0				a1
;
;  input :	bit      : 15     8		7     0
;			format   : Y7a .. Y0a	U7 .. U0
;					   Y7b .. Y0b	V7 .. V0
;
;  output :		bufY : Ya,Yb
;				d0   : U
;				d1   : V

;			.export conv422
;conv422:	move.b	(a0)+,(a1)+	;	Ya
;			move.b	(a0)+,d0	;	U
;			move.b	(a0)+,(a1)+	;	Yb
;			move.b	(a0)+,d1	;	V

;			rts


;------------------------------------------ get411Y --------------
; extern int get411Y ( byte *buf411, byte *bufY, int count )
;							a0			a1
;
;  input  :	4:1:1
;  output :	Ya,Yb,Yc,Yd

			.export get411Y
get411Y:	sub		#1,d0
			
 gY_loop:	move.w	(a0)+,d1
			move.b	d1,(a1)+

			dbra	d0,gY_loop

			rts

CONVERT	=	1		; convert intensity to VDI bank 1 pixels

IF CONVERT			;	 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f
intens_to_vdi:	.dc.b	 1,13,15,12,14,11,10, 9, 8, 5, 7, 4, 6, 3, 2, 0
intens_to_phys:	.dc.b	15,14,13,12,11,10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

;---------------------------------------------- Y_to_tt4 ----------
; extern void Y_to_tt4 ( byte *buf411, byte *screen, int count ) ;
;								a0			a1				d0
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
; extern void Y_to_tt4 ( byte *buf411, byte *screen, int count ) ;
;								a0			a1				d0
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


;---------------------------------------------- Y_to_cx8 ----------
; extern void Y_to_cx8 ( byte *buf411, byte *screen, int count ) ;
;								a0			a1				d0
			.export	Y_to_cx8
IF 1
Y_to_cx8:	sub		#1,d0

 Ycx8_loop:	move.b	(a0)+,(a1)+		; get Y
 			add		#1,a0			; forget C
			dbra	d0,Ycx8_loop
ELSE
Y_to_cx8:	lsr		#1,d0
			sub		#1,d0

 Ycx8_loop:	move.b	(a0)+,d1		; get Y
 			add		#1,a0			; forget C
			move.b	(a0)+,d2		; get Y
 			add		#1,a0			; forget C
 			move.b	d2,(a1)+
 			move.b	d1,(a1)+
			dbra	d0,Ycx8_loop
ENDIF
			rts

;---------------------------------------------- swap_buffer ----------
; extern byte *swap_buffer ( byte *buf411, int count ) ;
;								a0			d0
			.export	swap_buffer
swap_buffer:lsr		#1,d0		; 2 pixels per swap
			sub		#1,d0

 swap_loop:	move.l	(a0),d1
 			swap	d1
 			move.l	d1,(a0)+
			dbra	d0,swap_loop

			rts

