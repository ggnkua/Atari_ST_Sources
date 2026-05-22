;rockyone			pour MI-9			 13/04/2016
;
;		d‚placement horyzontal 1 … 4 plans 	  		      13/12/2017
;
; ource	buffer image
; zone		taille ‚cran non recouverte par le menu
; rez           resol *6
; key%		touche flŠche gauche ou droite
; plane		masque de plan	%1 a %1111
; copy		=1 si menu sur ‚cran
; repaet	touche "*" active
; bt%		bouton souris >0 = repeat
; mouse		adresse des boutons des souris
;
;             64     68    70   72   74      76     78     80 
;             a2     d0    d1   d2   d3      d1     d2    a0
; plan_rol( L Source,zone%,rez%,key%,plane%,repeat,bt%,mouse)
;  --------------------------------------------------------------------
;a2,d7  dispo
;
;a3 source
;a4 screen
;a5 addresse d‚but ou fin de zone
;d0 zone a d‚placer. taille en octet
;d0 nombre de word par plan 
;d1 premier ou dernier byte de la ligne
;d3 masque de plan 
;d4 offset pour premier ou dernier byte de la ligne
;d5 ecart entre deux word
;d6 nombre de word par ligne
;-------------------------------------------------------------------------
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	64(sp),a3
	dc.w	$a000
	move.w	-596(a0),d7		;current mouse buttons

	movem.w	68(sp),d0-d3
	movea.l	a3,a2
	movea.l	a3,a4
	movea.l	a3,a5
	adda.w	d0,a5
	
	lea.l	param(pc,d1.w),a6	
	movem.w	(a6),d4-d6		
	cmpi.b	#19,d2
	beq.s	sens_droit
;........................................................................
;sens_gauche           
	subq.b	#1,d4			; 153-1,157-1,79-1
	neg.w	d4               
	adda.w	#32000,a2	
	suba.w	d5,a2			; last word plan 1 
	movea.l	a2,a6

r_plan:	btst.b	#0,d3			; move this plan ? 
	beq.s	g_plan			; no
	movea.l	a2,a0			
r_line:	lea.l	1(a0),a1		; address last byte of a line
	move.w	d6,d0			; reset number word
	addq.b	#1,d0
	move.b	0(a0,d4.w),d1		; first byte of the line

*	lsl.w	(a0)
*	adda.w	d5,a0			

r_word:	roxl.w	(a0)
	suba.w	d5,a0
	dbra.w	d0,r_word
	lsr.b	#7,d1
	eor.b	d1,(a1)			; first byte eor last byte
	cmpa.l	a4,a0			; end plan ?
	bhi.s	r_line
g_plan:	addq.l	#2,a2			; next plan
	lsr.b	#1,d3			;
	bne.s	r_plan			;
	bsr.s	on_screen
	beq.s	r_plan			; repeat ?
	bra 	end_prg
;-------------------------------------------------------------------------
;                       d3 ,d4,d5
param:		dc.w	153,8,18
		dc.w	157,4,38
		dc.w	79,2,38
;-------------------------------------------------------------------------	
sens_droit       
	adda.w	#32000,a4
	movea.l	a2,a6
plan:	btst.b	#0,d3			; move this plan ?
	beq.s	d_plan
	movea.l	a2,a0
line:	move.w	d6,d0			; reset number word
	addq.b	#1,d0
	movea.l	a0,a1
	move.b	0(a0,d4.w),d1		; last byte of the line
;					; +153 +157 +79
word:	roxr.w	(a0)
	adda.w	d5,a0		
	dbra.w	d0,word
	lsl.b	#7,d1
	eor.b	d1,(a1)			; last byte on first byte
	cmpa.l	a0,a4
	bhi.s	line
d_plan:	addq.l	#2,a2			; point to next plane
	lsr.b	#1,d3
        bne.s	plan
	bsr.s	on_screen
	beq.s	plan
	bra.s	end_prg
;.......................................................................
on_screen:	move.l	a3,a0
		move.l	$44e,a1			; screen

*		move.w	#37,-(sp)		; vsync
*		trap	#14			; Xbios
*		addq.l	#2,sp

*wait:		move.b 	$ff8209,d0
*		bne.s	wait

recopy:		move.l	(a0)+,(a1)+
		cmpa.l	a0,a5
		bhi.s	recopy
;............................................... end si D0 <> 0........
		dc.w	$a000
		move.w	-596(a0),d3		; curent mouse buttons

		move.w	#2,-(sp)		; touche ?
		move.w	#1,-(sp)
		trap	#13			; xbios
		addq.l	#4,sp

		move.w	80(sp),d1		; key '*' active if >0
		beq.s	go_stop			; not repeat

repeat_on:	cmp.b	d3,d7			; buttont mouse ? 
		beq.s	exit_bsr		; always equal ! 

go_stop:	moveq.l	#1,d0			; stot repeat
exit_bsr:	movea.l	a6,a2		; restore adr pic, start  op‚ration
		move.w	78(sp),d3	; restore masque plan
		tst.b 	d0
		rts
;-------------------------------------------------------------------------
end_prg: 	movem.l	(a7)+,d0-d7/a0-a6
		rts
	end
;*************************************************************************
