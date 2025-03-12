; rockyone							18/03/2017							
; Ajout color 0 pour ligne 0					31.05.2019
; Modif pour SPU						10.05.2020	
; d‚ssasemblage de DISPC306.bin
;
;	    Routine d'affichage image Spectrum pour Omikron
;
;-------------------------------------------------------------------------
*      	link	a6,#0 
      	movem.l	a0-a6/d0-d7,-(sp) 

	lea.l	L0006(PC),a5
	move.l	64(sp),(a5) 		; Save adresse buffer palette
*	move.l	$4CE.w,4(a5)		; Save_Vbl
	
	move.b	#2,$ffff820a		; 60 Hz
	lea.l	spectrum(PC),a0		; Routine affichage
	move.l	a0,$4CE.w 		; dans VBL
	movem.l	(sp)+,a0-a6/d0-d7 
*	unlk	a6			
	rts 
;...............................................

spectrum:	
;	tst.w	$43E.w			; lecteur actif ?
;      	bne	spc_fin 

	move	sr,-(sp)
	ori.w	#$700,sr

	lea.l	$FF8240.l,a4		; adresse palette
	lea.l	$FF8209.l,a5		; adresse pointeur video bas

	lea.l	blc(PC),a6		; adresse des nop
	movea.l	L0006(PC),a3		; adresse buffer palette
	move.w	#196,d7 
	moveq.l	#0,d0 

	move.w	d0,(a4)			; color 0 line 0

wait:	tst.b	(a5)			; attente d‚but ‚cran
	beq.s	wait 

	move.b	(a5),d0 
	adda.l	d0,a6 
	adda.l	L0005(PC),a6
	jmp	(a6)

blc:	nop 	;1
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 10
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 20
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 30
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 40
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 50
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 60
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 	; 70
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
L0003:	nop 	; 77
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
	move.l	(a3)+,(a2) 

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
*	lea.l	-19040(a3),a4 		; 10.05.2020
*	nop 				; 10.05.2020
	nop 
	nop
	nop
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
	move.w	#0,(a4)			; 10.05.2020

	move	(sp)+,SR
spc_fin:	rts

;---------------------------------------------------- 
	even
L0005:		dc.l	0 
L0006:		dc.l	0
*vbl_list:	dc.l	0
*syncro:		dc.b	0

	end
;-------------------------------------------------------------------------
