************************************
*
*  void macro IO_ScaleWallColumn(\1.w z,\2.w tile,\3.w tslice)
*
* Draw a vertical line with a scaler, used for wall drawing
*
************************************

IO_ScaleWallColumn	macro
		lea.l	WallArtIndex,a1	; &shape = WallArtIndex[tile]
		ext.w	\2
		add.w	\2,\2
		add.w	\2,\2
		movea.l	-4(a1,\2.w),a1
			
		lsl.w	#6,\3		; Point to appropriate slice
		adda.w	\3,a1
			
		add.w 	\1,\1		; z *= 2

		move.w	pixx(a0),d7
		
		lea.l	ViewBuffer,a2	; *dest
		adda.w	d7,a2
		
		lea.l	ZBuffer,a3	; Store depth
		add.w	d7,d7
		move.w	\1,(a3,d7.w)
	
		add.w	\1,\1
		lea.l	scaler_jumptable,a3 
		movea.l (a3,\1.w),a3
		jsr	(a3)		; Call the scaler
	
		endm



************************************
*
*  void SetupScalers(xsize.w, ysize.w)
*
* Create the compiled scalers
*
************************************

MAXSCALER	= 690 ;390			; Maximum scaler height
MAXDISTANCE	= 5794			; Maximum distance
MINZ		= 10

		section	bss
scaler_jumptable
		ds.l	2*MAXDISTANCE	; Jumptable
scale_jump	ds.l	MAXSCALER+2	; Temporary array
scaleatzptr	ds.w	MAXDISTANCE	; Scale at z coord
ZBuffer		ds.w	MAXX		; ZBuffer

; Compiler templates			

		section text
	opt	o-			; Don't optimize 0(an)
					; templates

wall_scale_code	move.b	0(a1),0(a2)
wall_scale_fast	move.b	(a1)+,0(a2)	; Used if scaler-height = textureheight

wall_scale_multi
		move.b	0(a1),d7	; For multi byte scaling
		move.b	d7,0(a2)

wall_scale_fast_lea
		lea.l	0(a1),a1

wall_rts	rts
	
	opt	o+

		section	data
scaler_malloc	dc.b	"[1][ Malloc(): Could not allocate| scaler space.][ OK ]"
scaler.firstcall
		dc.b	0
		even




		section text
SetupScalers	move.l	scale_jump,d0

		tas.b	scaler.firstcall ; Run this only once
		bne.w	.called
	
		AllocSomeMem	200000,TTRAM	; Allocate about 100kb
		tst.l	d0
		bne.s	.ok	; Catch errors

.err		move.l	#scaler_malloc,error_string
		bra.w	_restore

.ok		addq.l	#1,d0		; Make address even
		bclr.l	#0,d0
		
.called		movea.l	d0,a0
		movea.l	d0,a2
		
		lea.l	scale_jump,a1
						
		move.l	a0,(a1)+ 		; scaler at height 0

		
		move.w	wall_rts(pc),(a0)+	; "rts"
			
		moveq.l	#2,d7		; Keep track of length of the generated
					; code
			
		move.w	xsize(pc),d4	; Length of one chunkyrow (in bytes)
			
		moveq.l	#2,d0	 	; Initial wall height

.setup_scalers
		move.l	a0,(a1)+	; Keep track of jumpaddress

		cmpi.w	#64,d0		   ; Sliceheight = Textureheight?
		beq.w	.setup_fast_scaler ; Yes, compile a fast scaler
		
		move.l  #64<<10,d1
		divu.w  d0,d1		; Texture step in 6.10 fixed
			
		move.w  ysize(pc),d2	; Center slice vetically
		sub.w   d0,d2		; Find top-row
		asr.w   #1,d2
			
		bmi.s   .clip_wall	; Slice needs to be clipped
			
			
		mulu.w  d4,d2		; Offset to top-row
			
		moveq.l	#0,d5		; Texture y-position in 6.10 fp
			
		move.w  d0,d3		; Now interpolate texture-pos along the sliver
					; and build scaler accordingly
			
.clipped	movea.w	#-1,a3		; Set offset to an impossible value
		subq.w  #1,d3		; dbra...	
	
.interpolate_slice
		move.w  d5,d6
		add.w   #1<<9,d6	; Round texture y-pos (+0.5)
		lsr.w   #8,d6
		lsr.w   #2,d6
	
		cmp.w	a3,d6		; Same offset as before ?
		beq.s	.multi_byte	; then use multibyte optimization	
	
		move.w  wall_scale_code(pc),(a0)+ ; "move.b src_ofs(a1),dest_ofs(a2)"
		move.w  d6,(a0)+
		move.w  d2,(a0)+
		
			
		addq.l	#6,d7		; Increment code-length
	
		bra.s	.next_row
			

; Multi fetch optimization
				
.multi_byte	movea.w	-6(a0),a4
		cmpa.w	wall_scale_code(pc),a4 ; Do we need to patch
		bne.s	.no_patch	       ; a pixel fetch ?

		subq.l	#6,a0		; Step backwards
		subq.l	#6,d7
		
		move.w	wall_scale_multi(pc),(a0)+ ; "move.b src_ofs(a1),d7"
		move.w	d6,(a0)+		   ; Source

		move.w	wall_scale_multi+4(pc),(a0)+ ; "move.b d7,dest_ofs(a1)"
		move.w	d2,(a0)			     ; Destination
		sub.w	d4,(a0)+
			
		addq.l	#8,d7
		
.no_patch	move.w	wall_scale_multi+4(pc),(a0)+ ; "move.b d7,dest-ofs(a1)"
		move.w	d2,(a0)+		     ; Destination
		
		addq.l	#4,d7



.next_row	movea.w	d6,a3		; Cache source offset
					; for multi fetch optimization

		add.w   d1,d5		; Texture y += step
		add.w   d4,d2		; Rowoffset += length_of(chunkyrow)
			
		dbra    d3,.interpolate_slice
			

.next_scaler	move.w  wall_rts(pc),(a0)+ ; "rts"

		addq.l	#2,d7
			
		addq.w  #2,d0	 	; One scaler every 2 pixels
		cmpi.w  #MAXSCALER,d0
		ble.w	.setup_scalers
		
*		mshrink	d7,a2		; Release unused space

			
		bra.s   .build_wall_jumptable ; Build wall jumptable
		
		
			
; Compile a clipped scaler

.clip_wall	neg.w   d2		; Texture position
		mulu.w  d1,d2		; in uppermost yrow
		move.l  d2,d5		; New texture y-position in 6.10 fixed

		moveq.l	#0,d2		; Offset to top row

		move.w  ysize(pc),d3	; Shown part of
					; the slice
			
		bra.s   .clipped
	

	
; Compile a fast move.b (a0)+,d0 scaler

.setup_fast_scaler
		move.w  d0,d1
		move.w  ysize(pc),d2
			
		sub.w   d1,d2		; Do we need to clip this slice ?
		asr.w   #1,d2
			
		bmi.s   .clip_fast_scaler
			
		mulu.w  d4,d2		; Offset to top row

			
.fast_scaler_clipped
		subq.w  #1,d1		; dbra...

.fast_scaler_loop
		move.w  wall_scale_fast(pc),(a0)+	; "move.b (a1)+,dest_ofs(a2)"
		move.w  d2,(a0)+			; Row offset
			
		addq.l	#4,d7
		
		add.w   d4,d2 				; Next row
		dbra    d1,.fast_scaler_loop

		bra.s   .next_scaler


; Clip a fast scaler for windowheights < 64

.clip_fast_scaler
		neg.w	d2		; New texture position
					; (texture step = 1 !)

		move.w	wall_scale_fast_lea,(a0)+ ; "lea src_ofs(a1),a1"
		move.w	d2,(a0)+		  ; Start from righteous row
		
		addq.l	#4,d7
			
		moveq.l	#0,d2		; Offset to top row 0
		
		move.w  ysize(pc),d1	; Visible part of the slice
			
		bra.s   .fast_scaler_clipped
			
			
			
; Build wall-jumptable based on reciprocal of the distance
			
.build_wall_jumptable
		move.w	ysize(pc),d0  	 ; Calculate baseheight depending
		mulu.w	#100,d0	;#120,d0 ; on the window's height

		lea	scale_jump,a0
		lea	scaler_jumptable,a1
		lea	scaleatzptr,a2
			
		move.l	(a0),(a1)+	; Pointer to "rts"
		
		moveq.l	#1,d1		; Distance

.wall_jumptable_loop
		move.l	d0,d2
		divu.w	d1,d2		; Reciprocal of distance -> scaleheight
		
		move.w	d2,(a2)+	; Store scale at z coord
			
		cmpi.w	#MAXSCALER,d2	 ; Greater than maximum scaleheight ?
		bls.s	.scale_height_ok ; no, then go on
			
		move.l	(a0),(a1)+	; Otherwise point to 
					; a blank scaler ("rts")

		bra.s	.next_distance
			
.scale_height_ok
		lsr.w	#1,d2		; One scaler every 2 pixels
		lsl.w	#2,d2		; *4 (address alignment)

		move.l	(a0,d2.w),(a1)+	; Jumpaddress

			
.next_distance	addq.w	#1,d1
		cmpi.w	#MAXDISTANCE,d1
		bne.s 	.wall_jumptable_loop
		
.break		rts                                                                                                               