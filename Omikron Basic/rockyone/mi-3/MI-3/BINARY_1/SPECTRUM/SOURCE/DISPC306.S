; rockyone							18/03/2017							
;
; d‚ssasemblage de DISPC306.bin
;
;	    Routine d'affichage image Spectrum pour Omikron
;
;-------------------------------------------------------------------------
      	link	a6,#0 
      	movem.l	a0-a5/d0-d7,-(sp) 
	lea.l	L0006(PC),a5
	move.l	8(a6),0(a5) 		; save adresse buffer palette
	move.l	$4CE.w,4(a5)		; save_Vbl
	lea.l	spectrum(PC),a0		; routine affichage
	move.l	a0,$4CE.w 		; dans VBL
	movem.l	(sp)+,a0-a5/d0-d7 
	unlk	a6			
	rts 
;...............................................

spectrum:	
	tst.w	$43E.w			; lecteur actif ?
      	bne	spc_fin 

	move	sr,-(sp)
	ori.w	#$700,sr
	lea.l	$FF8240.l,a4		; adresse palette
	lea.l	$FF8209.l,a5		; adresse pointeur video bas
	movea.l	a4,a0 
	movea.l	a4,a1 
	movea.l	a4,a2 
	lea.l	blc(PC),a6		; adresse des nop
	movea.l	L0006(PC),a3		; adresse buffer palette
	move.w	#196,d7 
	moveq.l	#0,d0 

wait:	tst.b	(a5)			; attente d‚but ‚cran
	beq.s	wait 

	move.b	(a5),d0 
	adda.l	d0,a6 
	adda.l	L0005(PC),a6
	jmp	(a6)

blc:	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
L0003:	nop 	
	movea.l	a4,a0 			; affichage des couleurs
	movea.l	a4,a1 
	move.l	a4,a2 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	nop 
	dbra.w	d7,L0003

	movea.l	a4,a0 
	movea.l	a4,a1 
	movea.l	a4,a2 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
;....................................... DerniŠre ligne	
	movea.l	a4,a0 
	movea.l	a4,a1 
	movea.l	a4,a2 
	lea.l	-19040(a3),a4 
	nop 
	nop 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a0)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a1)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move.l	(a3)+,(a2)+ 
	move	(sp)+,SR
spc_fin:	rts

;---------------------------------------------------- 

L0005:	ds.l	8 
L0006:	ds.l	12
      	dc.b	$00,$07,$00,$F0 
;-------------------------------------------------------------------------

	end

;-------------------------------------------------------------------------
