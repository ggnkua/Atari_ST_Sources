;rockyone			for MI-3 only			01/11/2017
;				*************
;
;		open -  save : one  plane  file.PL1-2
:
;PL1-2		+  0    0 to 3 	original plan number 
;		+  1    0 to 2 	image resolution
;		+  2        32 	byte palette of colors
;		+ 34	  4000 	Word  in low  resolution
;			  8000 	Word  in medium resolution
;.........................................................................
;
; 		OPEN	CALL plan_os( L Source ,L but, W 0 )
;
; Source   Image format Pi1-2 
; But 	   Buffer 32034 bytes	
;.........................................................................
;
; 		SAVE CALL plan_os( L but, L source, W 1 )
;
; Source   Image format PL1-2    Write in the first byte the plan to save 
; But 	   Buffer 8034 OR 16034  bytes
;.........................................................................
;
; save return in low d0		file size ou  zero
;
;--------------------------------------------------------------------------
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		move.w	68(sp),d1	

		tst.b	d1			; open ?
		beq.s	next			; no

		exg.l	a0,a1

next:		moveq.l	#0,d2
		move.b	(a0)+,d2		; plan number

		moveq.l	#0,d7
		move.b	(a0)+,d7		; image resol

		move.b	d2,(a1)+		; write plan number
		move.b	d7,(a1)+		; write image resol

		moveq.l	#7,d3
copy_color:	move.l	(a0)+,(a1)+		; write palette
		dbra.w	d3,copy_color
;
		lea.l	32000(a1),a3		; end but 

		moveq.l	#8,d4			; offset word
		lsr.b	d7,d4			; 8 or 4 bytes

		lsl.b	#1,d2			; offset plane

		tst.b	d1			; open or save ?
		beq.s	open_plan
;--------------------------------------------------------------------------	 

	   	adda.w	d2,a0			; firs word of plane
save_word:	move.w	(a0),(a1)+
		adda.w	d4,a0			; offset word
		cmpa.l	a1,a3
		bhi.s	save_word

		move.l	#8000,d0		;R. file size
		lsl.w	d7,d0			
		add.w	#34,d0
		bra.s	fin
;-------------------------------------------------------------------------
open_plan:	movea.l	a1,a2
		moveq.l	#0,d0			; not error

clear_buffer:	move.l	d0,(a2)+
		cmpa.l	a2,a3
		bhi.s	clear_buffer

		adda.w	d2,a1			; offset plane
open_word:	move.w	(a0)+,(a1)
		adda.w	d4,a1	
		cmpa.l	a1,a3
		bhi.s	open_word
		
;-------------------------------------------------------------------------
fin:		movem.l	(a7)+,d1-d7/a0-a6
		rts
		end
;*************************************************************************