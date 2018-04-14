;rockyone			pour MI-3 & Mi-9		20/02/2017
;
;
;			open  PG1-3
:
;	
;
;	open call	Pg_open( L source, L but )
;	
;
;
; Retun in low d0	 0 pas d'erreur
;			-1 bad r‚solution
;
;	in high d0	r‚solution image
;-------------------------------------------------------------------------
;lile size   32331				12843
;
; +  0   1 word 	r‚solution +10 pour fichier compress‚
; +  2  32 bytes	palette image
; + 34 288 bytes 	9 palette animation
; +322 	 1 byte 	$00	palette actuelle
; +323   1 byte 	$01	limite animation
; +324   1 byte 	$03	limite animation	
; +325   1 byte 	$01	direction animantion
; +326   1 byte		$00	Flag animation	
; +327   1 byte		$479e   temps animation
; +329   2 bytes        $0	vitesse animation	
;
; +331   32000 bytes  non compres‚	
;
;
;+331   taille des donn‚es image compress‚
;+333   premier byte ce commande
;+334   data image :   4 bytes    pour resol 0
;		       2 bytes	             1
;		       1 byte                2
;
; reppeter n fois le data  suivant.....
;------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

;.................................................OPEN....................
		movea.l	a0,a6
		moveq.l	#-1,d0			;R. error resolution	
		move.w	(a0)+,d7
		cmpi.b	#3,d7
		bmi.s	ok_resol
		subi.b	#10,d7			;R resol image

ok_resol:	move.b	d7,d1
		move.b	$44c,d2
		cmpi.b	#2,d2
		bne.s	ok_pic
		cmpi.b	#2,d1
		bne.s	end_prg

ok_pic:		moveq.l	#0,d0			; not error	
	
		move.w	d7,(a1)+		; copy resol
		moveq.l	#31,d6			; 16 couleur
		bsr.s	copy			; copy palette

		lea.l	297(a0),a0

		cmpi.w	#3,(a6)			; image Compress‚ ?
		bpl.s	depack

		move.l	#31999,d6
		bsr.s	copy		 	; copy image
		bra.s	end_prg

;...............................................

depack:		moveq.l	#0,d1
		move.b	(a0)+,d1		; taille data compress‚
		lsl.w	#8,d1			;
		move.b	(a0)+,d1		;

		lea.l	0(a0,d1.w),a6		; end_source
			
		moveq.l	#0,d1	
		tst.b	d7
		cmpi.b	#1,d7
		bmi.s	cmd_lword			; rez 0
		beq.s	cmd_word			; rez 1
;...............................................

cmd_byte:	cmp.l	a6,a0			; end source ?
		bpl.s	end_prg

		move.b	(a0)+,d1		; repeate n*

copy_byte	move.b	(a0),(a1)+
		subq.b	#1,d1
		bne.s	copy_byte
		addq.l	#1,a0
		beq.s	cmd_byte
;................................................

cmd_word:	cmp.l	a6,a0			; end source ?
		bpl.s	end_prg

		movea.l	a1,a4
		move.b	(a0)+,d1		; repeate n*
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		subq.b	#1,d1
		beq.s	cmd_word

copy_word:	move.w	(a4),(a1)+
		subq.b	#1,d1
		bne.s	copy_word
		bra.s	cmd_word
;..............................................

cmd_lword:	cmp.l	a6,a0			; end source ?
		bpl.s	end_prg

		movea.l	a1,a4
		move.b	(a0)+,d1		; repeate n*
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		subq.b	#1,d1
		beq.s	cmd_lword

copy_lword:	move.l	(a4),(a1)+
		subq.b	#1,d1
		bne.s	copy_lword
		bra.s	cmd_lword
		
;........................................................................

end_prg:	swap	d0
		move.w	d7,d0			;R resol pour box_alert
		swap	d0
		movem.l (sp)+,d1-d7/a0-a6
		rts

copy:		move.b	(a0)+,(a1)+
		dbra.w	d6,copy
	
		rts

		end
;-------------------------------------------------------------------------



