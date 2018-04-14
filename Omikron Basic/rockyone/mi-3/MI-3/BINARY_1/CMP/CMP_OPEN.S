;rockyone			pour MI-3  MI-9		 	  07/08/2017
;
;			Public Painter Monochrome v1.1 CMP
;
;			call cmp_open (L source, L but) 
;
;+0  $0    ou valeur de remplacement :  octet de control de lecture
;
;+1  $0    image sans  palette de couleur
;+1  $22   image avec palette de couleur
;+1  >$22  image format differant de 640*400
;+2  $0 ou ‚gal a l'octet de control si le byte suivant et >$2
;
;+3   $2 = byte de r‚solution 
;+3  >$2   l'image source comverti en CMP avait une r‚solution inf‚rieur 
;+3   $0   chercher le byte de r‚solution
;
;+?        Palette si byte 1(a0) = $22 ( la palette peut ‚tre cod‚ )
;+?	   Image compress‚
;  
;    CMD = octet de control 0(a0)  
;        CMD, byte Repeat, Data to Repeat,byte nul (inutile),CMD...
;        CMD, byte Repeat, Data to Repeat,byte literal...
;	 byte(s) Literal, CMD...
;-------------------------------------------------------------------------
;utilis‚; d0-d2/d7, a0-a2

	        movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1
		lea.l	34(a1),a2

		move.w	#2,(a1)+	; marque resolution
		moveq.l	#0,d2
		move.b	(a0)+,d7	; octet control de lecture

		moveq.l	#-4,d0		;R. image trop grande
		cmpi.b	#$22,(a0)+
		bhi.s	end_prg		; >
		bne.s	no_pal
;.......................................
resol:		addq.l	#1,a0           ; start 3(0)
find:		move.b	(a0)+,d1	
		beq.s	resol		; cherche byte resolution
		subi.b	#2,d1
		beq.s	color		; =  byte literaly
		bmi.s	saut		; <
		move.b	d1,-(a0)	; byte de repetition
		subq.l	#1,a0		
		bra.s	to_repeat
		bra.s	color
saut:		addq.l	#1,a0
;........................................
color:		cmp.b	(a0),d7		; octet de control ?
		bne.s	copy_color

to_repeat:	bsr.s	repeat_code
		bra.s	end_pal

copy_color:	move.b	(a0)+,(a1)+
end_pal:	cmpa.l	a2,a1		; end_pal ?
		bmi.s	color		; >0
		bra.s	depack
;........................................
no_pal:		move.l	#$FFF0000,(a1)	; creat 2 color
		movea.l	a2,a1

depack		moveq.l	#0,d0		;R. not error
		lea.l	32000(a1),a2	; end pic
		
recup_code:	cmp.b	(a0),d7		; octet de control ?
		bne.s	literaly	; <>
		bsr.s	repeat_code	; =
		bra.s	end_pic

literaly: 	move.b	(a0)+,(a1)+	
		cmp.b	(a0),d7		; octet de control ?
		bne.s	literaly	

end_pic:	cmpa.l	a2,a1		; end pic ?	
		bmi.s	recup_code	; >0
;........................................

end_prg:  	movem.l	(sp)+,d1-d7/a0-a6
		rts
;.........................................
repeat_code:	addq.l	#1,a0
		moveq.l	#0,d1
		move.b	(a0)+,d1
		move.b	(a0)+,d2
recopy:		move.b	d2,(a1)+
		dbra.w	d1,recopy
		rts
;........................................

		end
;*************************************************************************