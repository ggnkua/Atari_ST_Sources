*rockyone			pour MI-9			25/12/2015
*			
*			    rotation 3  plan  
*						   
*		    Uniquement basse resolution						   
*					
*			a0       a1          d0   d1    d2   d3   d4
*	call op_plan( L source,L destination,key,plans,plan,plan,limit)
*	
*
*	a0 a2 a4 source
*	a1 a3 a5 destination
*	d0	 Key            [7] or [9]           
*	d1	 1 plan		bit 0 Ö 1    plan =%1 1   1   1
*	d2	 2 plan  	bit 1 Ö 2             d3  d2  d1
*	d3	 3 plan		bit 2 Ö 3
*   	d4   	 limit
*	d5	 nombre de word par plan 
*
* plan    1  1   1   1
*            d3  d2  d1  a0
*            d2  d1  d3  a1 sens gauche
*-------------------------------------------------------------------------
	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	64(a7),a0-a1
	movem.w	72(a7),d0-d4
	
	lsl.b	#1,d1
	lsl.b	#1,d2
	lsl.b	#1,d3

	move.l	#1999,d5	; 4000  word par plan
	move.w	#16,d6

	movea.l	a0,a2           
	movea.l	a0,a4  

	adda.w	d1,a0         	; source premier plan a Çchanger
	adda.w	d2,a2		;        deuxiäme
	adda.w	d3,a4		;        troixiäme

	movea.l	a1,a3
	movea.l	a1,a5

	cmpi.b	#55,d0
	beq.s	droit
;..................................SENS GAUCHE
;but a1,a3,a5
	adda.w	d3,a1
	adda.w	d1,a3
	adda.w	d2,a5	    
	bra.s	swap
;..................................SENS DROIT
droit:	adda.w	d2,a1
	adda.w	d3,a3
    	adda.w	d1,a5
;..................................ECHANGE PLAN
swap:	move.w	(a0),(a1)
	move.w	(a2),(a3)
	move.w	(a4),(a5)
                                
	move.w	8(a0),8(a1)
	move.w	8(a2),8(a3)
	move.w	8(a4),8(a5)
	                            
	adda.w	d6,a0		; d6 = 16
	adda.w	d6,a2
	adda.w	d6,a4
                                
	adda.w	d6,a1
	adda.w	d6,a3
	adda.w	d6,a5
	dbra.w	d5,swap
;..................................recopy sur source
	movem.l	64(sp),a0-a1
	move.l	#7999,d1
recopy:	move.l	(a1)+,(a0)+
	dbra.w	d1,recopy
;..................................copy sur Çcran
	move.l	64(sp),a0
	movea.l	a0,a2
	adda.w	d4,a2
	move.l	$44e,a1
on_screen:	
	move.l	(a0)+,(a1)+
	cmpa.l	a0,a2
	bhi.s	on_screen

;.................................. FIN ................
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	end
;.........................................................................