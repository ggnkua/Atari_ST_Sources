* rockyone							16/01/2018
*
*								
*			   OPEN HOMWORK  
*		a single image plane in low resolution
*                                                      
*	   	  	            
*	 		HMP_OPEN( L source, L BUT )  
*			---------------------------
*
* Return in low d0	-1 bad resolution
*-------------------------------------------------------------------------
		movem.l	d1-d7/a0-a6,-(sp)
	
		movem.l	60(sp),a0-a1

		move.w	#0,(a1)+		; resol 0
		move.l	#$fff0000,(a1)		; image color
		adda.w	#32,a1		
*		move.w	#0,(a1)+		; color mousse

		movea.l	a1,a2
		moveq.l	#0,d0
		move.l	#7999,d1
cls_but:	move.l	d0,(a2)+
		dbra.w	d1,cls_but
		
		lea.l	160*192-8(a1),a3
	
all_line	lea.l	160(a1),a2
		addq.l	#8,a1
line		move.w	(a0)+,(a1)
		addq.l	#8,a1
		cmpa.l	a1,a2
		bhi.s	line
		cmpa.l	a1,a3
		bhi.s	all_line
;-------------------------------------------------------------------------
end_prg:	movem.l	(sp)+,d1-d7/a0-a6
		rts
		end
;*************************************************************************
