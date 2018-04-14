;Rockyone			pour MI-3			8/06/2016
;
;modifi‚ le 18/02/2017
;
;		OPEN SAVE SYNTHETIC ART v1	SRT	moyenne resolution
;		---------------------------
;Op%	0 open	
;	1  save
;
;     	 	open	Call Srt_Open( L Source, L destination, Op% )
;     	 	save	Call Srt_Open( L destination, L source, Op% )
;
;return	low d0 		-2 erreur header
;			-1 erreur resol
;	high d0 	resol image 
;-------------------------------------------------------------------------
		movem.l d1-d7/a0-a6,-(a7) 
		movem.l	60(sp),a0-a1
		move.w	68(sp),d3
		beq.s	open_srt

;.......................................SAVE..................
		exg.l	a0,a1
		
		lea.l	2(a0),a2
		lea.l	34(a0),a0

		bsr.s	copy_image
		move.l	#$4a485379,(a1)+	; write id SRT
		move.w	#1,(a1)+		; write resol image
		bsr.s	copy_palette

		move.l	#32038,d0		;R. file size
		bra.s	end_prg

;........................................OPEN..................
open_srt:	lea.l	32000(a0),a2

		move.w	4(a2),d2		;R. resolution de l'image

		moveq.l	#-2,d0			;R. flag erreur header
		cmp.l	#$4a485379,(a2)+	;'JHSy'
		bne.s	end_prg			;
	
		moveq.l	#-1,d0			;R. flag erreur resol
*		cmp.b	#2,$44c			; haute r‚solution ?
*		beq.s	end_prg			;

		cmp.w	#1,(a2)+	        ; test  byte resol image
		bne.s	end_prg			;
	
		moveq.l	#0,d0			;R. pas d'erreur

		move.b	#1,1(a1)		; copie byte resol
		addq.l	#2,a1
		
		bsr.s	copy_palette
		bsr.s 	copy_image

;-------------------------------------------------------------------------

end_prg:	swap	d0
		move.w	d2,d0
		swap	d0
		movem.l (a7)+,d1-d7/a0-a6 
		rts 

copy_palette:	moveq.l	#7,d1			; 16 couleurs
color:		move.l	(a2)+,(a1)+
		dbra.w	d1,color
		rts

copy_image:	move.w	#7999,d1		; copie image
image:		move.l	(a0)+,(a1)+
		dbra.w	d1,image
		rts

		end
