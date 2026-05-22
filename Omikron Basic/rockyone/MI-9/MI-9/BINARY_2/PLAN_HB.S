* rockyone			pour MI-9			13/01/2018
*								
*		MOVE PLAN(S) VERTICALY ( 1 or  5 lines )
*		----------------------------------------
*
*		   	    64      68     70   72   74    76     
*		   	    a0	    d0     d1   d2   d3    d1     
*		plan_byt( L buffer, limit, ecr, key, plan, repeat )
*	
*
*	buffer		>=32804 byte ( address image.PI? +34 )
*	limit		size of the visible image
*	ecr		screen resolution * 8
*	key		14 high arrow  22 low arrow
*			bit 8 = 1 for move one line, 0 for move five lines
*	plan		%1111 one bit per plane to move
*	 	         4321 plans 
*	repeat		key '*'  disabled = 0
*-------------------------------------------------------------------------
		movem.l	d0-d7/a0-a6,-(sp)
		dc.w	$a000
		move.w	-596(a0),ex_bt	; current mouse button

		move.l	64(sp),a0
		movem.w	68(sp),d0-d3	

		movea.l	a0,a4
		lea.l	32408(a0),a3
		lea.l	0(a0,d0.w),a5	; limit pic on the screen	

		lea.l	param(pc,d1.w),a6
		movem.w	(a6)+,d5-d7
		btst.b	#8,d2		; move one line ?
		bne.s	a_line		; yes
		move.w	(a6),d6		; move five line
a_line:		sub.w	d6,d7		
       		cmpi.b	#22,d2		; low direction ?
		beq.s	sens_bas	; yes
		bra.s	start
;-------------------------------------------------------------------------
ex_bt:	dc.w	0

;	        d5 d6 d7  d6
param:	dc.w	8,19,3998,99
	dc.w	4,39,7998,199
	dc.w	2,39,7998,199
;-------------------------------------------------------------------------
sens_bas:	adda.w	#32000,a0
		suba.w	d5,a0		; last word plan 1
		neg.w	d5		; offset word
;-------------------------------------------------------------------------
start:		movea.l a0,a6          	; save address first plan 
plan:        	btst.b 	#0,d3		; move this plan ?
        	beq.s   next_plan	; no

	        movea.l a0,a1
		movea.l	a3,a2      	; buffer backup

		move.w	d6,d1		; 1 or 5 line plan
save_line:	move.w  (a1),(a2)+	
		adda.w	d5,a1		; + or - d5
	        dbra.w  d1,save_line        

		movea.l	a0,a2
		move.l	d7,d0
loop:   	move.w  (a1),(a2)
        	adda.w  d5,a1
        	adda.w  d5,a2
	       	dbra.w  d0,loop

		movea.l	a3,a1		; buffer backup
	        move.w  d6,d1
last_first:    	move.w  (a1)+,(a2)
		adda.w	d5,a2
	        dbra.w  d1,last_first

next_plan:	addq.l  #2,a0
        	lsr.b   #1,d3
        	bne.s   plan
;-------------------------------------------------------------------------
on_screen:	movea.l	a4,a0		; buffer image
		move.l	$44e,a1		; screen

wait:		move.b	$ff8209,d0
		bne.s	wait

recopy:		move.l	(a0)+,(a1)+
		cmpa.l	a0,a5		; end aera ?
		bhi.s	recopy
;............................................... end if D0 <> 0........
		dc.w	$a000
		move.w	-596(a0),d3	;current mouse buttons

		move.w	#2,-(sp)	; Com
		move.w	#1,-(sp)	; Bconstat
		trap	#13		; Bios
		addq.l	#4,sp

		movem.w	76(sp),d1	 
		tst.b	d1		; key '*' active ?
		bne.s	mouse_button	; yes
		moveq.l	#1,d0		; stop repeat

mouse_button:	cmp.w	ex_bt,d3		
		beq.s	end_test	; 0 or 2  ( if 1 '*' = 0 )
;					;	  ( if 2 '*' =-1 ) 
		moveq.l	#1,d0		; stop repeat
			
end_test:	move.w	74(sp),d3	; restore plan mask 
		movea.l	a6,a0		; restore address first plan
		tst.b	d0
		beq.s	plan
;-------------------------------------------------------------------------
end_prg:	movem.l	(a7)+,d0-d7/a0-a6
		rts
		end
;*************************************************************************				
