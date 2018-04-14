; rockyone			pour Mi-3 et MI-9	          18/03/2017							
; add test clavier et souris
;
; d‚ssasemblage de DISPC306.bin
;
;	    Routine d'affichage image Spectrum pour Omikron
;		call spc_play( L buf_palette,mousebut)
;-------------------------------------------------------------------------

		movem.l	d0-d7/a0-a6,-(sp)

		lea.l	L0006(PC),a5
		move.l	64(sp),(a5)	; Save adresse buffer palette

		move.l	$4CE,4(a5)		; Save Vbl_list
		move.b	$ffff820a,syncro
		move.l	$4ce,vbl_list
		move.b	#2,$ffff820a		; 60 Hz
		lea.l	spectrum(PC),a0		; Routine affichage
		move.l	a0,$4CE.w 		; dans VBL

test_key:	move.w	#2,-(sp)		; device
		move.w	#1,-(sp)		; bbonstat
		trap	#13			; bios
		addq.l	#4,sp
		tst.w	d0
		bne.s	end_prg

test_m:		move.w	68(sp),a1		;varptr(mousebut)+6
		tst.b	1(a1)			; Bt mousebut ?
		beq.s	test_key		; no

end_prg:	move.b	syncro,$ffff820a
		move.l	vbl_list,$4ce
		movem.l	(sp)+,d0-d7/a0-a6
		
		rts 
;...............................................

spectrum:	
	tst.w	$43E.w			; lecteur actif ?
      	bne	spc_fin 

	move	sr,-(sp)		; sauve registre d'‚tat
	ori.w	#$700,sr		; arret des interruptions ipl 7
	lea.l	$FF8240.l,a4		; adresse palette
	lea.l	$FF8209.l,a5		; adresse pointeur video bas
	movea.l	a4,a0 
	movea.l	a4,a1 
	movea.l	a4,a2 
	lea.l	blc(PC),a6		; adresse des nop
	movea.l	L0006(PC),a3		; adresse buffer palette
	move.w	#196,d7 		; 197 ligne
	moveq.l	#0,d0 

wait:	tst.b	(a5)			; attente d‚but ‚cran
	beq.s	wait 

	move.b	(a5),d0 
	adda.l	d0,a6 
	adda.l	L0005(PC),a6		; +addresse buffer
	jmp	(a6)

blc:	nop 		;77 nop
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		;10
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop		;20
 	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop		;30
 	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop		;40
 	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		
	nop 		;50
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		;60
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 		;70
	nop 
	nop 
	nop 
	nop 
	nop 
	nop 
;					; 48 couleurs par ligne
color_line:	nop 		;77
		movea.l	a4,a0 			
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
		dbra.w	d7,color_line
;....................................... avent derniŠre ligne
		movea.l	a4,a0 			
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
		move	(sp)+,SR	;restaure le  registre d'‚tat
spc_fin:	rts

;---------------------------------------------------- 

L0005:		dc.l	0 
L0006:		dc.l	0,0
*		dc.l	0
*      		dc.b	$00,$07,$00,$F0 
vbl_list:	dc.l	0
syncro:		dc.b	0
;-------------------------------------------------------------------------

	end

;-------------------------------------------------------------------------
