* rockyone							25/12/2015
* modifi‚ 					 		04/12/2016
*								25.12.2017
*			basse et moyenne r‚solution
*
*       Echange de deux plans
*	Copy 1 plan sur 1 ou plusieur plans				   
*	Add  1 plan sur 1 ou plusieur plans		
*		         64     68             70        72
*			 a0     d0	       d1	 d2
*	call plan_2nc( L buffer,plans_source%, plan_but%,limit%)
*	
*
*	a0	source
*	a1	destination
*	d0	Plan source		de 0 … 3   en basse r‚sol
*	d1	0 … 3  pour echange ou 1 bit par plan pour copy et add
*	"	bit 4 pour copy
*       "       bit 5 pour copy et add
*-------------------------------------------------------------------------
		movem.l	d0-d7/a0-a6,-(a7)
		move.l	64(a7),a0
		movem.w	68(a7),d0-d2
		movea.l	a0,a1
		lsl.b	#1,d0		
		adda.w 	d0,a0		; plan source

		move.b	($44c),d0
		move.l	#4000,d3	
		lsl.w	d0,d3		
		subq.b	#1,d3		; for dbra	

		moveq.l	#8,d4		
		lsr.b	d0,d4	
	
		btst.b	#5,d1		; Exchange ?
		beq.s	swap_plan	; yes
		andi.b	#%11111,d1
		btst.b	#4,d1		; add ?
		beq.s	add_plan	; yes
		andi.b	#%1111,d1
*---------------------------------------
* a0 a2 source
* a1 a3 destination
* d1 plan% destination
* d2 number of words to recopy on the screen
* d3 d0 number of words per plan
* d4 number of byte betwween two words
* d5 Word echange
;-------------------------------------------------------------------------
copy_plan:	btst.b	#0,d1		; copy in this plan ?
		beq.s	next_plan	; no
		movea.l	a0,a2		; plan to copy
		movea.l	a1,a3		; destination plan
		move.w	d3,d0
copie:		move.w	(a2),(a3)
		adda.w	d4,a2
		adda.w	d4,a3
		dbra.w	d0,copie
next_plan:	addq.l	#2,a1
		lsr.b	#1,d1
		bne.s	copy_plan
		bra.s	to_screen
;-------------------------------------------------------------------------
add_plan:	subq.b	#2,d4
		andi.b	#%1111,d1
test_add:	btst.b	#0,d1		; add in this plan ?
		beq.s	next_add	; no
		movea.l	a0,a2		; plan to add
		movea.l	a1,a3		; destination plan
		move.w	d3,d0
plan_add:	move.b	(a2)+,d5
		bsr.s  	quartet
		move.b	(a2)+,d5
		bsr.s	quartet
		adda.w	d4,a2
		adda.w	d4,a3
		dbra.w	d0,plan_add
next_add:	addq.l	#2,a1
		lsr.b	#1,d1
		bne.s	test_add
		bra.s	to_screen

quartet:	tst.b	(a3)
		beq.s	zero
		or.b	d5,(a3)+
		rts
zero:		move.b	d5,(a3)+
		rts

;-------------------------------------------------------------------------
swap_plan:	lsl.b	#1,d1
		adda.w 	d1,a1		; destination
echange_plan:	move.w	(a1),d5
		move.w	(a0),(a1)
		move.w	d5,(a0)
		adda.w	d4,a0
		adda.w	d4,a1
		dbra.w	d3,echange_plan
;-------------------------------------------------------------------------
to_screen:	movea.l	64(a7),a0
		movea.l	a0,a2
		adda.w	d2,a2
		movea.l $44e,a1
		
recopy:		move.l (a0)+,(a1)+
		cmpa.l	a0,a2
		bhi.s	recopy
;-------------------------------------------------------------------------
		movem.l (a7)+,d0-d7/a0-a6
		rts
;-------------------------------------------------------------------------
