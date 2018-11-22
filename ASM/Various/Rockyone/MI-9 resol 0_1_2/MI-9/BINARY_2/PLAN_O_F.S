*rockyone			pour MI-9 			21/12/2017
*
*
*	   	Restor or erase one or more image plan
*
*		  	low and medium resolution 
*		  	*************************
*
*			      a0        a1    d1     d2
*	  call affiche_plan(L undo, L image, Plan%, limit%)
*
* 	A0  a2	Undo    ecr_undo   for restore
*	A1  a3	image	ecr_buf
*
*	A0	image		   for erase
*	A1	image
*
*	Plan% 	1 bit per plan %1111 
*		       	  plan  4321
*
*	Limit%	screen	 size at the top of the menu
*-------------------------------------------------------------------------

		movem.l	d0-d7/a0-a6,-(a7)
		movem.l	64(sp),a0-a1	
		movem.w	72(sp),d1-d2	

 		move.b	($44c),d4 	
		moveq.l	#8,d6		
		lsr.b	d4,d6			; offset next word

		move.l	#4000,d5
		lsl	d4,d5			; number of word per plan
		subq.l	#1,d5      		; -1 for dbra     

		cmpa.l	a0,a1			; erase plan ?
		beq.s	cls_plan		; yes

;-------------------------------------------------------------------------
planes:		btst.b	#0,d1			; view this plan ?
		beq.s	next_plan		; no 

		movea.l	a0,a2			; start of a plan
		movea.l	a1,a3
		move.w	d5,d4		

word:		move.w 	(a2),(a3)
		add.w	d6,a2			; + offset word 
		add.w	d6,a3			;
		dbra.w	d4,word		


next_plan:	addq.l	#2,a0		
		addq.l	#2,a1

		lsr.b	#1,d1
		bne.s	planes

;-------------------------------------------------------------------------
on_screen:	move.l 	68(sp),a0
		movea.l	a0,a2
		adda.w	d2,a2
		move.l 	$44e,a1
recopy:		move.l	(a0)+,(a1)+
		cmpa.l	a0,a2
		bhi.s	recopy
;-------------------------------------------------------------------------
	 	movem.l	(a7)+,d0-d7/a0-a6
		rts
;-------------------------------------------------------------------------
cls_plan:	btst.b	#0,d1			; erase this plan ?
		beq.s	next_cls

		movea.l	a0,a1
		moveq.l	#0,d3		
		move.w	d5,d4

cls_word:	move.w 	d3,(a1)
		adda.w	d6,a1
		dbra.w	d4,cls_word
		
next_cls:	addq.l	#2,a0
		lsr.b	#1,d1
		bne.s	cls_plan
		bra.s	on_screen
		end
;*************************************************************************
