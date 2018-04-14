;rockyone			for MI-9 only			19/11/2017
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
; 		OPEN	CALL plan_os( L Source ,L but, 0, pal, ecr )
;
; Source   Image format Pi1-2	 In the first byte the destination plan
; But 	   Buffer 32034 bytes	
; Ecr      R‚solution ‚cran
; Pal      0 pour copier la palette
;.........................................................................
;
; 		SAVE CALL plan_os( L but, L source, W 1, 0, ecr )
;
; Source   Image format PL1-2    
; But 	   Buffer 8034 OR 16034  Write in the first byte the plan to save 
;.........................................................................
;
; open return in low d0		-1 if bad resol
; save return in low d0		file size
; alway in high do		image resolution
;   
;--------------------------------------------------------------------------
		movem.l	d0-d6/a0-a6,-(a7)
		movem.l	60(a7),a0-a1
		movem.w	68(a7),d1/d5-d6	

		tst.b	d1			; open ?
		beq.s	next			; no
		move.b	(a0),(a1)
		exg.l	a0,a1

next:		moveq.l	#0,d2
		move.b	(a0)+,d2		; plan number

		moveq.l	#-1,d0			;R. bad resol		
		moveq.l	#0,d7
		move.b	(a0)+,d7		;R. image resol
		cmpi.b	#2,$44c			; screen hight resol ?
		beq.s	fin
		cmp.b	d6,d7
		bne.s	fin
;...............................................		
		move.b	d2,(a1)+		; write plan number
		move.b	d7,(a1)+		; write image resol

		tst.b	d5			; copier palette ?
		beq.s	palette

		adda.w	#32,a0
		adda.w	#32,a1
		bra.s	no_pal

palette		moveq.l	#7,d3
copy_color:	move.l	(a0)+,(a1)+		; write palette
		dbra.w	d3,copy_color

no_pal:
		move.l	#4000,d3	 
		lsl.w	d7,d3			; number word

		moveq.l	#8,d4			; offset word
		lsr.b	d7,d4			; 8 or 4 bytes

		lsl.b	#1,d2			; offset plane

		tst.b	d1			; open or save ?
		beq.s	open_plan
;--------------------------------------------------------------------------	 

	   	adda.w	d2,a0			; firs word of plane
save_word:	move.w	(a0),(a1)+
		adda.w	d4,a0			; offset word
		subq.w	#1,d3			; number word -1
		bhi.s	save_word

		move.l	a1,d0
		sub.l	60(sp),d0		;R. file size
		bra.s	fin
;-------------------------------------------------------------------------
open_plan:	movea.l	a1,a2
		adda.w	d2,a1			; first word of plane
open_word:	move.w	(a0)+,(a1)
		adda.l	d4,a1	
		subq.w	#1,d3
		bhi.s	open_word
		moveq.l	#0,d0			; not error
;-------------------------------------------------------------------------
fin:		swap	d0
		move.w	d7,d0
		swap	d0
		movem.l	(a7)+,d1-d7/a0-a6
		rts
		end
;*************************************************************************