* rockyone			pour MI-9			26/12/2015
* Modifi‚							04/12/2016
* Ajout test clavier et souris					15/03/2015
*								21.12.2017
*			MOVE PLAN(S) VERTICALY    one line
*			MOVE PLAN(S) HORYSONTALY  1 word plan
*
*
*		   	   64      68     70   72    74     76    
*		   	   a0	   d0     d1   d2    d3     d1    
*		plan_byt(L buffer, limit, ecr, key , plan , repeat
*	
*	buffer		32000 byte  
*	Limit		size of the visible image
*	ecr		resolution*8
*	key		14 high arrow
*            		22 low arrow
*	plan		%1111 one bit per plane to move
*	 	         4321 plans 
*	repeat		key "*"  active = -1
*-------------------------------------------------------------------------
		movem.l	d0-d7/a0-a6,-(sp)
		dc.w	$a000
		move.w	-596(a0),ex_bt

		movea.l	64(sp),a0
		movem.w	68(sp),d0-d3	

		movea.l	a0,a4
		movea.l	a0,a5
		adda.w	d0,a5

		lea.l	param(pc,d1.w),a6
		movem.w	(a6),d4-d7	

		btst.b	#0,d2
		bne.s	horyzontal

		cmpi.b	#22,d2		; sens bas ?
		beq.s	sens_bas	; yes
		bra.s	start		; sens haut 

horyzontal:	subq.b	#1,d6
		addq.b	#1,d7
		exg.l	d4,d5
		exg.l	d6,d7
		cmpi.b	#17,d2		; sens gauche ?
		beq.s	start		; yes
		adda.w	#32000,a0
		suba.w	d4,a0		; last word plan 1
		bra.s	sens_droit
;-------------------------------------------------------------------------
;		d4,d5,d6,d7
param:	dc.w	160,8,19,198
	dc.w	160,4,39,198
	dc.w	80,2,39,398
ex_bt	dc.w	0
;-------------------------------------------------------------------------
sens_bas:	adda.w	#32000,a0
		suba.w	d5,a0			; last word plan 1
sens_droit:	neg.w	d4
		neg.w	d5
;-------------------------------------------------------------------------
start:		movea.l	a0,a6
plan:		btst.b	#0,d3			; move this plan ?	
		beq.s	next_plan		; no
		
		movea.l	a0,a1			; start of a plan
		move.w	d6,d0			; number of columns-1

colonne:	movea.l	a1,a3
		move.w	(a3),d2			; word last line
		move.w	d7,d1			; number of lines-2

ligne:		movea.l	a3,a2
		adda.w	d4,a3			; +offset line
		move.w	(a3),(a2)
		dbra.w	d1,ligne		; next line 	

		move.w	d2,(a3)			; last word on first line
		adda.w	d5,a1			; + offset word
		dbra.w	d0,colonne		; next column

next_plan:	addq.l	#2,a0			 
		lsr.b	#1,d3			 
		bne.s	plan			; next plan ?

;................................................recopy on screen.........
on_screen:	movea.l	a4,a0			; buffer image
		movea.l	$44e,a1			; screen

wait:		move.b	$ff8209,d0
		bne.s	wait

recopy:		move.l	(a0)+,(a1)+
		cmpa.l	a0,a5			; end aera ?
		bhi.s	recopy
;............................................... end if D0 <> 0........
		dc.w	$a000
		move.w	-596(a0),d3		; current mouse buttons

		move.w	#2,-(sp)		; Com
		move.w	#1,-(sp)		; Bconstat
		trap	#13			; Bios
		addq.l	#4,sp

		move.w	76(sp),d1		; key '*' repeat if >0
		beq.s 	go_stop			; not repeat !

		cmp.w	ex_bt,d3		; bt mouse ?        
		beq.s	ok_repeat		; 0 or 2 ( if 1, '*' = 0 )

go_stop:	moveq.l	#1,d0			; stop repeat
ok_repeat:	move.w	74(sp),d3		; masque_plan%  
		movea.l	a6,a0	
		tst.b	d0
		beq.s	plan
;-------------------------------------------------------------------------
end_prg:	movem.l	(a7)+,d0-d7/a0-a6
		rts
	end
;*************************************************************************				
