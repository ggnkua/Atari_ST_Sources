* rockyone			FOR MI-3 ONLY			 04/11/2017
*
*	 	   Effacee ecran et buffer imgage  
*			   
*	  	 call cls_buf( L buffer+34 )
*
* A0	buffer image
* 
*	
*
*-------------------------------------------------------------------------

		movem.l	d0-d7/a0-a6,-(a7)
		move.l	64(sp),a0		; buffer
		lea.l	32000(a0),a2
		move.l $44e,a1			; screen

		moveq.l	#0,d1
cls:		move.l	d1,(a0)+
		move.l	d1,(a1)+
		cmpa.l	a0,a2
		bhi.s	cls	

;.........................................................

		movem.l	(a7)+,d0-d7/a0-a6
		rts
		end
