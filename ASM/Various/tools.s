;====================
;=
;= Fade the screen to a palette
;=
;====================

pal_alloc	dc.b	"[1][ malloc(): not enough space| for palette resource][ OK ]"
		even
		
FadeTo		macro	source:pointer

		movea.l	\1,a0		; Palette
		bsr.w	_FadeTo
		
		endm

		

_FadeTo		malloc	16*(200*34+2)+3	; Reserve space for 16 faded palettes
				
					
		tst.l	d0
		bne.s	.ok		; Catch errors
		
		move.l	#pal_alloc,error_string	; Display error message
		bra.w	_restore		; and exit
		
.ok		addq.l	#1,d0		; Make address even
		bclr.l	#0,d0
		
		movea.l	d0,a1
		movea.l	a1,a4		; Save pointer


		moveq.l	#0,d7		; Current brightness

		
		moveq.l	#16-1,d0	; Fade 16 palettes
		
.fade_loop	movea.l	a0,a2		; Reference palette



		move.w	#200-1,d1	; Process 200 lines
		
.row_loop	move.w	(a2)+,(a1)+	; Copy scanline flag




		moveq.l	#16-1,d2	; Process 16 colors each row
		
.color_loop	move.w	(a2)+,d3	; Get reference color
		move.w	d3,d4
		move.w	d4,d5
		
		lsr.w	#8,d3		; Mask out r,g,b
		lsr.w	#4,d4
		andi.w	#$f,d4
		andi.w	#$00f,d5


	ifeq	0
		lsl.w	#3,d3		; Convert bBBB (STE) -> BBBb (lsb order)
		lsl.w	#3,d4		; and multiply by 4 in order to
		lsl.w	#3,d5		; align by the table record
		
		bclr.l	#3+3,d3		; Shift down least significant bit
		beq.s	.skip_r
		bset.l	#2,d3
		
.skip_r		bclr.l	#3+3,d4
		beq.s	.skip_g
		bset.l	#2,d3
		
.skip_g		bclr.l	#3+3,d5
		beq.s	.skip_b
		bset.l	#2,d3
		
.skip_b
	else
	
		bclr.l	#3,d3
		roxl.w	#3,d3
		bclr.l	#3,d4
		roxl.w	#3,d4
		bclr.l	#3,d5
		roxl.w	#3,d5
	endc
		
		lea	.shades(pc,d7.w),a3 ; Point to current level
					    ; of brightness
		
		
		cmp.w	d7,d3		; test agains Reference color
		blt.s	.r_limit
		
		move.w	(a3),d6	; Set RED level
		bra.s	.test_g
		
.r_limit	move.w	.shades(pc,d3.w),d6 ; Set to max. RED level
.test_g		cmp.w	d7,d4
		blt.s	.g_limit
		
		or.b	2(a3),d6	; Set GREEN level
		bra.s	.test_b		
	
.g_limit	or.b	.shades+2(pc,d4.w),d6 ; Set to max. GREEN level
.test_b		cmp.w	d7,d5
		blt.s	.b_limit
		
		or.b	3(a3),d6	; Set BLUE level
		bra.s	.store
		
.b_limit	or.b	.shades+3(pc,d5.w),d6 ; Set to max. BLUE level

.store		move.w	d6,(a1)+	; Store color

		dbra	d2,.color_loop
			
			
		dbra	d1,.row_loop


		move.w	#-1,(a1)+	; Terminate palette
		addq.w	#4,d7		; Next level of brighness
	
		dbra	d0,.fade_loop

		bra.w	.init

	
.shades		dc.l	$00000000	; Table of faded RGB channels
		dc.l	$08008008	; (STE palette format)
		dc.l	$01001001
		dc.l	$09009009
		dc.l	$02002002
		dc.l	$0a00a00a
		dc.l	$03003003
		dc.l	$0b00b00b
		dc.l	$04004004
		dc.l	$0c00c00c
		dc.l	$05005005
		dc.l	$0d00d00d
		dc.l	$06006006
		dc.l	$0e00e00e
		dc.l	$07007007
		dc.l	$0f00f00f
	

	
.init		move.l	a4,usp		  ; Save first palette
		move.w	#16,firstframe	  ; Fade 16 steps
		move.l	#200*34+2,_in_out ; Fade in
		

; Initialise VBL and HBL interrupt in order to fade in the
; 256 color picture

		move.w	#$2700,sr	; Disable IRQs

		move.l	#FadeVBL,$70.w	; Initialise VBL & HBL vectors
		move.l	#FadeHBL,$120.w
		
		clr.b	$fffffa07.w	; MFP reset
		clr.b	$fffffa09.w
				
		bset.b	#0,$fffffa07.w	; Allow HBL
		
		clr.b	$fffffa1b.w	; Stop HBL (Started from VBL)
			
		move.w	#$2300,sr	; Enable IRQs
		rts
		



;====================
;=
;= Fade the screen to black
;=
;====================

FadeToBlack	macro	source:pointer

		bsr.w	_FadeToBlack
		
		endm

_FadeToBlack	move.w	#$2700,sr

		move.w	#16,firstframe	     ; Fade out 15 times
		move.l	#-(200*34+2),_in_out ; Fade out		
		
		move.w	#$2300,sr
		
		
.fizzleout	tst.w	firstframe	; Wait for fading
		bne.s	.fizzleout
		
		
		move.w	#$2700,sr	; Disable IRQs
		move.l	#idle,$120.w	; Idle timer b
		st.b	_hbl
		move.l	#idle,$70.w	; Idle vbl
		
		
		move.b	#%01010000,$fffffa09.w ; Restore old mfp setting
		move.b	#%01010000,$fffffa15.w
		bset.b	#0,$fffffa07.w
	
		clr.b	$fffffa1b.w	; Stop hbl
		
		move.w	#$2300,sr	; Enable IRQs
		
		move.l	usp,a1		; Release space allocated
		mfree	a1		; for palettes
	
		rts


;====================
;=
;=  Fade a 256 color
;= picture using a vbl
;= and a hbl interrupt
;=
;====================

_in_out		ds.l	1		; Fade in or out ?


FadeVBL		clr.b	$fffffa1b.w	; Stop timer b
		
		move.b	#1,$fffffa21.w	; Make timer b occur every scanline
					; (hbl mode)
		
		movem.l	d0-d7/a0-a2,-(sp)


		move.l	usp,a2		; Current palette
		lea	2(a2),a1	; Skip scanline flag
		
	
		movem.l (a1)+,d0-d7	; Set palette for first scanline
		movem.l	d0-d7,$ffff8240.w
	

		lea	$ffff8209.w,a0	; Wait until top border is finished
		move.b	(a0),d0
.skip_border	cmp.b	(a0),d0
		beq.s	.skip_border

		
		bset.b	#3,$fffffa1b.w	; Reenable timer b
	
		
		
.scanline	lea	$ffff8242.w,a0	; Color register 1
	
		tst.l	(a1)+		; New Palette?		
		beq.s	.skip
		bmi.s	.last_row	; Last row ?
		
	
		move.w	(a1),d0		; Get palette into CPU
		movem.l	2(a1),d1-d7
		
.skip		lea	30(a1),a1	; Point to next palette


		clr.b	_hbl		; Wait for next scanline
		
.wait_hbl	tst.b	_hbl
		beq.s	.wait_hbl
	
		bra.s	.scanline
		
		
	
.last_row	clr.b	$fffffa1b.w	; Stop timer b

		btst.b	#1,3+$466.w	; Lighten/Darken every 4th frame
		beq.s	.smoothen	; to achieve smooth fading
		

		tst.w	firstframe	; Done fading?
		beq.s	.lastframe	; Get out now

		
		subq.w	#1,firstframe	; --framecounter
		beq.s	.lastframe
		
		adda.l	_in_out(pc),a2
		
.smoothen
.lastframe	move.l	a2,usp		; Point to current fade step
		
		movem.l	(sp)+,d0-d7/a0-a2


		subq.l	#1,$466.w
					
		rte
	
	
	
;====================
;=
;=  Change the palette at the beginning of
;= a scanline (must be done as quick as possible)
;=
;====================

		
FadeHBL		move.w	d0,(a0)+
		movem.l	d1-d7,(a0)
	
		st.b	_hbl
		rte

_hbl		ds.w	1
firstframe	ds.w	1		; Times to fade
		