;rockyone			for MI-3 only			01/11/2017
;				*************			
;								21.03.218
; Modified to load load the planes of an image without    	24.06.2018
; clearing the screen. If the screen is not in high resolution.
; Modified for MI-9M						07_10_2018
; 
;		open -  save : one  plane  file.PL1-2
:
;PL1-2		+  0    0 to 3 	original plan number 
;		+  1    0 to 2 	image resolution
;		+  2        32 	byte palette of colors
;		+ 34	  4000 	Word  in low  resolution
;			  8000 	Word  in medium resolution
;.........................................................................
;		              60        64     68     70      72
; 	OPEN  CALL plan_os( L Source ,L but, W Op% ,W pal% ,W Ext% )
;
; Source   Image format Pi1-2 
; But 	   Buffer 32034 bytes	
; Op%      0 to load a file
; Pal%     0 to load the pallet 	- Alway 0 for MI-3M -
;          -1 to not load the pallet  	- Only for MI-9M - 
;
; Ext%	   Extensions comparisons: 
;	   0 to clear the destination buffer, otherwise -1
;	   Alway -1 for MI-9M   0 only if resolution change 
;		- Exept for the slideshow - 
:
; Return awlways zero in DO
;.........................................................................
;		              60     64        68     70        72      
; 	SAVE  CALL plan_os( L but, L source, W op%, W unused% W unused% )
;
; Source   Image format PL1-2    Write in the first byte the plan to save 
; But 	   Buffer 8034 OR 16034  bytes
; Op%	   1 to save a file
; Unused%  always zero
:
; Return file size in low D0
;
;--------------------------------------------------------------------------
; used d0-d5/a0-a3 
; 
		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		movem.w	68(sp),d1-d3	

		tst.b	d1			; Open file ?
		beq.s	next			; Yes

		exg.l	a0,a1			; For backup

next:		move.w	(a0),(a1)+
		moveq.l	#0,d4
		move.b	(a0)+,d4		; Plan number
		moveq.l	#0,d5
		move.b	(a0)+,d5		; image resol

		tst.w	d2
		beq.s	copy_pallet
		adda.w	#32,a0
		adda.w	#32,a1
		bra.s	jump_pal
		
copy_pallet:	moveq.l	#7,d2
copy_color:	move.l	(a0)+,(a1)+		; write color
		dbra.w	d2,copy_color

jump_pal:	lea.l	32000(a1),a3		; end but 

		moveq.l	#8,d2			; offset word
		lsr.b	d5,d2			; 8 or 4 bytes

		lsl.b	#1,d4			; offset of the plane !

		tst.b	d1			; Open or save ?
		beq.s	open_plan		; Open
;--------------------------------------------------------------------------	 
;save_plan
	   	adda.w	d4,a0			; first word of plane
save_word:	move.w	(a0),(a1)+
		adda.w	d2,a0			; + offset word
		cmpa.l	a1,a3
		bhi.s	save_word

		move.l	#8000,d0		;Rerturn  file size
		lsl.w	d5,d0			;
		add.w	#34,d0			;
		bra.s	fin
;-------------------------------------------------------------------------
open_plan:	moveq.l	#0,d0			; Open always return 0

		move.b	d0,-34(a1)		; Clear first octet !
		
*		cmpi.b	#2,$44c			; High resolusion ?
*		beq.s	clear_buffer		; yes

		tst.w	d3			; Extensions comparisons: 
		bne.s	equal			; <>

clear_buffer	movea.l	a1,a2			
loop:		move.l	d0,(a2)+		; cls 32000 bytes
		cmpa.l	a2,a3
		bhi.s	loop			; >

equal:		adda.w	d4,a1			; + offset plane
open_word:	move.w	(a0)+,(a1)
		adda.w	d2,a1			; + offset word
		cmpa.l	a1,a3			; End Destination  ?
		bhi.s	open_word		; >
		
;-------------------------------------------------------------------------
fin:		movem.l	(a7)+,d1-d7/a0-a6
		rts
		end
;*************************************************************************