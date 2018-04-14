;rockyone			pour MI-3 & Mi-9		20/02/2017
;removal of resolution tests			                04.04.2018
;
;			open|save  PG1-3
:
;	
; Op%:	 0 Open, 1 compressed backup, 2 uncompressed backup
; 
;
;	        	   a0        a1	    d0
;	open call Pg_os( L source, L but, W Op%  )
;
;	save call Pg_os( L but, L source, W Op%  )
;
;
; Open return always $0 in d0
; Save return file size in low d0  ( Alway 32331 bytes if uncompressed )
;-------------------------------------------------------------------------
;
; +  0   1 word 	r‚solution +10 pour fichier compress‚
; +  2  32 bytes	palette image
; + 34 288 bytes 	9 palette animation
; +322 	 1 byte 	$00	palette actuelle 1 
; +323   1 byte 	couleur start
; +324   1 byte 	couleur end	
; +325   1 byte 	direction animantion 01 or 02
; +326   1 byte		$00	Flag animation	
; +327   1 byte		temps animation
; +328   1 bytes        vitesse animation	
; +329   2 byte         $0
; +331   32000 		bytes image non compres‚	
;....................
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
		
re_save:	movem.l	60(sp),a0-a1
		move.w	68(sp),d0
		
		moveq.l	#31,d6		16 couleur

		tst.b	d0
		bne	save_pic

;.................................................OPEN....................

		movea.l	a0,a6

		move.w	(a0)+,d7
		cmpi.b	#3,d7
		bmi.s	ok_resol
		subi.b	#10,d7			; resol image


ok_resol:	move.w	d7,(a1)+		; copy resol
		bsr.s	copy			; copy palette

		lea.l	297(a0),a0

		cmpi.w	#3,(a6)			; image Compress‚ ?
		bpl.s	depack

		bsr.s	copy		 	; copy image
		bra.s	end_open
;...............................................

depack:		move.b	(a0)+,d1		; taille data compress‚
		lsl.w	#8,d1			;
		move.b	(a0)+,d1		;

		lea.l	0(a0,d1.w),a6		; end_source
			
		moveq.l	#0,d1	
		tst.b	d7
		cmpi.b	#1,d7
		bmi.s	cmd_lword		; Low resolusion
		beq.s	cmd_word		; medium resolution
;...............................................
;						;high resolution 

cmd_byte:	cmp.l	a6,a0			; end source ?
		bpl.s	end_open

		move.b	(a0)+,d1		; repeate n*

copy_byte	move.b	(a0),(a1)+
		subq.b	#1,d1
		bne.s	copy_byte
		addq.l	#1,a0
		beq.s	cmd_byte
;................................................

cmd_word:	cmp.l	a6,a0			; end source ?
		bpl.s	end_open

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
		bpl.s	end_open

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
end_open	moveq.l	#0,d0
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts

copy:		move.b	(a0)+,(a1)+
		dbra.w	d6,copy
		move.l	#31999,d6
		rts

end_save:	suba.l	a6,a1	
		move.l	a1,d0		;R. file size

		cmpi.w	#3,(a6)
		bmi.s	end_prg	 	; uncompressed end

		cmpi.w	#32332,d0	; test file size packed
		bmi.s	ok_size		; <= 32331

		move.w	#2,68(sp)	; uncompresse mode
		bra 	re_save
	
ok_size:	move.l	d0,d1
		subi.w	#333,d1		; write size data image packed
		move.b	d1,332(a6)
		lsr.w	#8,d1
		move.b	d1,331(a6)	
		bra.s 	end_prg

;--------------------------------------- SAVE ----------------------------		
; a1 source format degas pi1-3
; a0 destination
;

save_pic:	exg.l	a0,a1
;		-------------
		movea.l	a1,a6		; for culculate file size	

		move.w	(a0)+,d1	; read source resolution 
		move.w	d1,(a1)+
		
		bsr.s	copy		; copy_pal	

		moveq.l	#8,d3
pals:		lea.l	pal_2(pc),a3
		moveq.l	#7,d2
pal_def:	move.l	(a3)+,(a1)+
		dbra.w	d2,pal_def
		dbra.w	d3,pals

		move.w 	#0,(a1)+	; 322 palette image
;					; 323 first color animation
		move.w	#0301,(a1)+	; 324 end color animation
;					; 325 direction animation
		move.w	#$3e,(a1)+	; 326  flag animation  $00
;					; 327 time animation   $3e
		move.w	#$0a00,(a1)+    ; 328 speed animation  $c4
;					; 329 byte ?           $0
		move.b	#$0,(a1)+	; 330 byte ?           $0


		cmpi.b	#1,d0		; compacter ?
		beq.s	compresse			
	
		bsr.s	copy		; copy image
		bra.s	end_save	

compresse:	addi.w	#$a,(a6)	; flag compression
		addq.l	#2,a1		; place for size data		
		
		movea.l	a0,a2
		lea.l	32000(a0),a5	; end source		
			
		cmpi.b	#1,d1		; save in medium resolution ?
		bmi.s	s_low		; no
		beq.s	s_med		; yes
;.......................................; high

s_high:		cmp.l	a5,a0		; end source ?
		bpl	end_save

		move.w	#254,d0
		move.b	(a0),d1
		addq.l	#1,a2

cmp_high:	cmp.b	(a2),d1
		bne.s	save_high
		
		addq.l	#1,a2

		subq.l	#1,d0
		beq.s	save_high	; 255 copy !

		cmp.l	a5,a2		; end source ?
		bmi.s	cmp_high

save_high:	neg.w	d0
		addi.w	#255,d0
		move.b	d0,(a1)+
		move.b	(a0)+,(a1)+
		movea.l	a2,a0

		bra.s	s_high
;.......................................
s_med:		cmp.l	a5,a0		; end source ?
		bpl	end_save

		move.w	#254,d0
		move.w	(a0),d1
		addq.l	#2,a2

cmp_med		cmp.w	(a2),d1
		bne.s	save_med
		
		addq.l	#2,a2

		subq.l	#1,d0
		beq.s	save_med	; 255 copy !

		cmp.l	a5,a2		; end source ?
		bmi.s	cmp_med

save_med:	neg.w	d0
		addi.w	#255,d0
		move.b	d0,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		movea.l	a2,a0
		bra.s	s_med
;........................................
s_low:		cmp.l	a5,a0		; end source ?
		bpl	end_save

		move.w	#254,d0
		move.l	(a0),d1
		addq.l	#4,a2	

cmp_low		cmp.l	(a2),d1
		bne.s	save_low	; 255 copy !
		
		addq.l	#4,a2

		subq.l	#1,d0
		beq.s	save_low

		cmp.l	a5,a2		; end source ?
		bmi.s	cmp_low

save_low:	neg.w	d0
		addi.w	#255,d0
		move.b	d0,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		move.b	(a0)+,(a1)+
		movea.l	a2,a0
		bra.s	s_low
;.............................................

pal_2: 		dc.w	$0fff,$0f22,$003f,$0000,$0fff,$0f00,$00f0,$0ff0
		dc.w	$000f,$0f0f,$00ff,$0555,$0333,$0f33,$03f3,$0ff3
		end
;-------------------------------------------------------------------------



