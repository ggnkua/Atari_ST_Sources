***************************************************************************
; rockyone			pour MI-3 MI-9  	        15.11.2018
;      						 
; Open / save ABM et PAC, fusionn‚s dans "PAC_A_OS.S"		17.11.2018
;*************************************************************************
;
;		Open "ABM" files ARABESQUE - high resolution -
;		----------------------------------------------
;		    Uniquement les images < = 640*400
:
;
;Attention:  
;	Comme ce n'‚tait pas utile pour moi, je n'ais pas fait de masque
;	pour le dernier octet des lignes.
;   
;--------------------------------------------------------------------------
;
; Format	ABM   compression horizontal, 2 entetes !
;					      -----------
; +0		'ESO8'	Id ABM
; +4		'9A"	Id format
; +6		?	largeur image en pixel 
; +8		?	hauteur	image en ligne
; +10		1       Nombre de plan		
; +12		?	taille du bloc image    = File zize - 14
; +14		?	id_byte		
; +15		?	id_pac		
; +16		?	spceial byte	
; +17		?	data compress‚	
;
; +0		'ESO8'	Id ABM
; +4		'8B'	Id format
; +6		?	largeur image en pixel 
; +8		?	hauteur image en ligne
; +10		?	taille du premier bloc image	; Total =
; +12		?	taille du second bloc image	;   file size - 18
; +14		?	taille du toisiŠme bloc image	;
; +16		?	taille du quatriŠme bloc image	;.............
; +18		?	id_byte		
; +19		?	id_pac		
; +20		?	sp‚cial byte	
; +21		?	data compress‚	
***************************************************************************
; 
; But :  buffer 32034 bytes
;					  
;		open	Call Pac_Os( L Source, L but )	
;
;
; Return in low D0 	
;	 0  not erreur
;	-2  if not a valid file ABM
;	-4  Size image too big
;
;**************************************************************************
;used d0-d7 / a0-a4

		movem.l	d1-d7/a0-a6,-(a7)
		movem.l	60(sp),a0-a1
		
;..................................................Read header........
		cmpi.l	#"ESO8",(a0)+	; Id ABM
		bne	bad_file

		lea.l	10(a0),a2	; address d' id_byte

		move.w	(a0)+,d3	; File format  ? 
		cmpi.w	#'9a',d3	;
		beq.s	largeur		;
;					;
		cmpi.w	#'8b',d3	;	
		bne	bad_file	;

		addq.l	#4,a2		; adresse d' id_byte

largeur:	moveq.l	#0,d5
		move.w	(a0)+,d5	; largeur image en pixel
		subi.w	#640,d5		; > 640 ?
		bgt	too_big		
		neg.w	d5		
		divu.w	#8,d5		
		bclr.b	#0,d5		; largeur image en octet

		move.w	(a0)+,d7	; hauteur
		subi.w	#400,d7		; > 400 ?
		bgt	too_big		 

		mulu.w	#80,d7		; d7 <=0

;jump nombre de plan et taille du bloc image

read_id:	movea.l	a2,a0
		move.b	(a0)+,d0	; id_byte
		move.b	(a0)+,d1	; id_pac
		move.b	(a0)+,d2	; sp‚cial byte
;...................................................................

		move.w	#2,(a1)+	; write resol
		move.l	#$fff0000,(a1)	;       2 colors 
		lea.l	32(a1),a1	; d‚part image sur BUT

		lea.l	80(a1),a2	; fin d'une ligne ‚can en octet
		movea.l a2,a3		; fin d'une line image en octet
		suba.w	d5,a3		;
		
		lea.l	32000(a1),a4	; fin image sur BUT
		adda.w	d7,a4		; d7 < = 0
 
;--------------------------------------------------------------------------
;			horyzontal depactage
;--------------------------------------------------------------------------
horyzontal:	moveq.l	#0,d5		; clear the repeat counter
		move.b	(a0)+,d4  	; read a byte
		cmp.b	d0,d4     	; compared with a id_byte
		beq.s	l_id_byte	; if equal

		cmp.b	d2,d4		; compared with special_byte
		beq.s	l_special_byte	; if equal

*othrewise:				; copien just once ( d5=0 )
		move.b	d4,(a1)+  	; copy and increments
		cmpa.l	a1,a3
		bne.s	horyzontal
		bra.s	finish_a_line

l_id_byte:	move.b	d1,d4     	; retype Pack_byte
		move.b	(a0)+,d5	; number of repetition
		bra.s	recopy_data  	
 
l_special_byte:	move.b	(a0)+,d4  	; byte copy
		move.b	(a0)+,d5  	; number of repetition

recopy_data:	move.b	d4,(a1)+  	; copy and increments
		cmpa.l	a1,a3
		beq.s	finish_a_line	; return to 'next_data' if d5 >= 0
next_data:	dbra.w	d5,recopy_data

		bra.s	horyzontal

;.......................................
finish_a_line:	cmpa.l	a1,a2
		beq.s	new_line
		move.b	#$0,(a1)+
		bra.s	finish_a_line

new_line:	adda.w	#80,a3
		adda.w	#80,a2

next_line:	tst.w	d5
		bgt.s	next_data	; if >=0

		cmpa.l	a1,a4
		bhi.s	horyzontal

		suba.w	d7,a4		; d7 <= 0
clr_lines:	cmpa.l	a1,a4
		ble.s	end_open	
		move.b	#$0,(a1)+
		bra.s	clr_lines
			
end_open: 	moveq.l	#0,d0		; not_erreur
end_error:	movem.l	(a7)+,d1-d7/a0-a6
		rts

bad_file:	moveq.l	#-2,d0		
		bra.s	end_error
too_big:	moveq.l	#-4,d0
		bra.s	end_error
		END
;--------------------------------------------------------------------------

