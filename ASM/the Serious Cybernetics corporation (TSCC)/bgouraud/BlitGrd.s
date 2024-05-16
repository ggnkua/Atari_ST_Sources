;===========================
;=
;=  Blitter accelerated
;= Goraud triangles
;= 
;= by ray//.tSCc.  	2k3
;=
;===========================

;----------------------------------------------------------
		output .app
		opt  d-,o+,ow-
		opt  p=68030
		comment HEAD=%011 ; Fasload & Fastram = on

x_res		= 320		; Screen width in bytes
y_res		= 200

method		= 1		; 0=cpu, 1=blitter
transparent	= 0		; Map transparent?
				; (blitter only)

;----------------------------------------------------------
		include	'inc\Init.s'
;----------------------------------------------------------	

; Generate gradient

main		malloc	2*64<<8		; Reserve blitter source
		move.l	d0,_3d.gradient	; in ST RAM

		movea.l	d0,a0
		adda.l	#2*64<<8,a0

		move.w	#64<<8-1,d0

.grad		bfextu	d0{16:8},d1
		move.w	d1,d2
		move.w	d1,d3		; g
		
		mulu.w	#10<<16/28,d1
		swap.w	d1		; /2.8
		addq.w	#5,d1		; r
		
		mulu.w	#10<<16/32,d2
		swap.w	d2		; /3.2
		addi.w	#10,d2		; b
		
		bfins	d1,d2{16:5}	; Reorder shades
		bfins	d3,d2{16+5:6}
		move.w	d2,-(a0)
		dbra	d0,.grad


; Preinitialise blitter

	ifne	method	
		lea.l	$ffff8a22.w,a0
		clr.w	(a0)+
				; _SrcYinc = 0
		addq.l	#4,a0
		moveq.l	#-1,d0
		move.l	d0,(a0)+	; _EndMask1-3 = $ffff
		move.w	d0,(a0)+
		
		move.l	#$20000,(a0)+	; _DstXinc = 2
					; _DstYinc = 0
		addq.l	#8,a0
		move.w	#$0203,(a0)+	; _HOP & _LOP = Source only
		move.b	#%1<<7,1(a0)	; Force Extra Source read
	endc
	
;----------------------------------------------------------

.rand	macro	dest,modulo		; Generate a random
		move.l	seed(pc),d7	; number
		rol.l	d7,d7
		addq.l	#5,d7
		move.l	d7,seed

		andi.l	#$ffff,d7	; d7 mod \1
		divu.w	\1,d7
		swap.w	d7
		move.w	d7,\2
	endm


.mainloop
	ifne	transparent&method
		moveq.l	#-1,d0
		move.l	d0,$ffff8a28.w
		move.w	d0,$ffff8a2c.w
	endc

		.rand	#x_res-1,d0	; Generate random
		.rand	#x_res-1,d1	; vertex coordinates
		.rand	#x_res-1,d2	; and colors
		swap.w	d0
		swap.w	d1
		swap.w	d2
		.rand	#y_res-1,d0
		.rand	#y_res-1,d1
		.rand	#y_res-1,d2
		.rand	#63<<8,a0
		.rand	#63<<8,a1
		.rand	#63<<8,a2
	
		bsr.w	_3d.GouraudShadeTriangle
		
	ifne	transparent&method
		move.l	#63<<(16+5)|63<<5,d0
		move.l	d0,$ffff8a28.w
		move.w	d0,$ffff8a2c.w
	endc
	
		.rand	#x_res-1,d0	; Generate random
		.rand	#x_res-1,d1	; vertex coordinates
		.rand	#x_res-1,d2	; and colors
		swap.w	d0
		swap.w	d1
		swap.w	d2
		.rand	#y_res-1,d0
		.rand	#y_res-1,d1
		.rand	#y_res-1,d2
		.rand	#63<<8,a0
		.rand	#63<<8,a1
		.rand	#63<<8,a2
	
		bsr.w	_3d.GouraudShadeTriangle


		addq.l	#2,Time.triangles; Count triangles
		
		cmpi.b  #$39,$fffffc02.w ; Wait for space key
		bne.w   .mainloop


		bsr.w	Time.tris_per_sec; Measure performance

		
.w1		cmpi.b	#$39,$fffffc02.w
		beq.s	.w1
		
.w2		cmpi.b	#$39,$fffffc02.w
		bne.s	.w2
		
;----------------------------------------------------------
		include	'inc\restore.s'
;----------------------------------------------------------

seed		ds.l	1	; Pseudo random seed

;----------------------------------------------------------
; Subs
;----------------------------------------------------------

		include	'inc\Gouraud.s'	; Triangle filler
		include	'inc\Timing.s'	; Tris/sec. Timer
		end