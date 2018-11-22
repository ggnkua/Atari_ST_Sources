;rockyone			pour MI-3			29/09/2016
;modifi‚ open							04.05.2018
;
;			CANVAS 	open CNV CPT FUL
;				save CNV CPT
;
; Source: 	buffer  fichier image
; But		buffer	32034 octets
; Size		Taille du fichier	    0 for save
; Op%		0  save file		
;   		1  open CNV ou CPT
; 		2  open FUL
;		
;		open  call canvas( L Source, L But, W Op%, W Size )
;		save  call canvas( L But, L Source, W Op%  W 0,)
;
;
; Return	low d0		0, not error
;				-2, bad file
;				File size if Op% <>0
;
;				
;		high d0		R‚solution image
;
;------------------------------------------------------------------------- 
;  FORMAT PTC
;--------------
;  +0	16 word palette
;  +32	 1 word resolution
;........................................
;  +34 	 1 word repeat			.      Zone data repeat
;  +36   1 word offset			.
;  +38   X word DATA			.	X * Plan
;  +...					.	--------
;........................................
;  
;  +???	1 word	$ffff 	Fin de data a recopier ( $fff >> repeat = 0 )
;  +    1 word  offset
;  +    X word  data    Copier ces X data si l'offset est plus petit que 
;			la somme des offsets copiŠ
;
;  Fin d'un fichier sans data unique 
;	
;........................................
;  +	X word  data unique        	.   zone data unique
;  +   	...				.
;  Fin d'un fichier avec data unique
;........................................

;--------------------------------------------------------------------------

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a1

		moveq.l	#7,d3		; 16 color to copy
		
		move.w	68(sp),d0
		bne	open_cpt

;.................................................SAVE CPT................
						
		exg.l a0,a1

		lea.l	32000(a1),a3	; Tampon pour data_unique
		movea.l	a3,a5		; a recopier aprŠs dernier
;					; data_repeat

		moveq.l	#0,d0
		move.w	(a0)+,d0	; R‚solution image
	
		bsr	palette
;
		move.w	d0,(a1)+	; R‚solution image
;........................................
;	
		move.l	#4000,d1	; Max_offset
		lsl.w	d0,d1			
		subq.l	#1,d1		; -1 pour dbra

		moveq.l	#4,d2		; Nombre de word a comparer a
		lsr.b	d0,d2		; chaque offset 	4, 2, 1
		move.l	d2,d3		; Nb_word
		subq.l	#1,d3		; Cpt_word -1 pour dbra	3, 1, 0

		moveq.l	#0,d4		; Cpt_word
		moveq.l	#8,d5		; Saut_: Nombre de byte entre 
		lsr.b	d0,d5		; chaque offset		8 ,4 , 2

		moveq.l	#0,d6		; Cpt_offset
		moveq.l	#0,d7		; Cpt_unique
;					; Comptage r‚p‚tition dans (a1)
;........................................

save_loop:	cmp.w	d1,d6		; Max_offset > Cpt_offset 
		bhi.s	end_data	

		move.w	d3,d4		; Reset Cpt_word

		movea.l	a0,a4
		lea.l	0(a0,d5.w),a2

test1:		cmpm.w	(a4)+,(a2)+
		bne.s	unique		; >>> data unique puis loop:
		dbra.w	d4,test1		
;					......... DATA REPEAT.............

		adda.l	d5,a0		; add 1 offset a A0
		move.w	d6,2(a1)	; Offset pour ces data

loop2:		move.w	d3,d4		; Reset Cpt_word
		addq.w	#1,(a1)		; Nombre de r‚p‚tition (-1)
		addq.w	#1,d6		; Ofset pour prochain data_repeat

test2:		cmpm.w	(a4)+,(a2)+
		bne.s	different
		dbra.w	d4,test2	

		adda.l	d5,a0		; add 1 offset a A0 
		cmp.w	d1,d6		; Max_offset > Cpt_offset 
		bne.s	loop2	

different:	bsr.s	data_repeat		
		bra.s	save_loop	

;........................................
data_repeat:  	addq.l	#4,a1
		move.w	d3,d4		; Reset Cpt_word	

copy_2:		move.w	(a0)+,(a1)+	; copy word data repeat
		dbra.w	d4,copy_2

		addq.w	#1,d6		; Offset pour prochain data_repeat
		rts
;........................................

unique:		move.l	d3,d4		; Reset Cpt_word
copy_1:		move.w	(a0)+,(a3)+	; copy words data unique
		dbra.w	d4,copy_1

		addq.w	#1,d7		; Cpt_unique

		addq.w	#1,d6		; Offset pour prochain data_repeat
		bra.s 	save_loop
;........................................

end_data:	move.w	#$ffff,(a1)	; flag dernier data repeat
		move.w	d6,2(a1)
		bsr.s data_repeat

		tst.w	d7		; Cpt_unique  ?
		beq.s	end_save	 

		mulu.w	d2,d7		; * par Nb_word ( 4, 2 ,1 )
		subq.w	#1,d7		; -1 pour dbra
recopie:	move.w (a5)+,(a1)+
		dbra.w	d7,recopie
;.......................................................................

end_save:	move.l	60(sp),a4	;	Attention a0 a1 invers‚ 
		suba.l	a4,a1
		move.l	a1,d0
end_prg:	movem.l (sp)+,d1-d7/a0-a6
		rts
;.........................................
palette:	move.l	(a0)+,(a1)+	
		dbra.w	d3,palette
		rts
;------------------------------------------------------OEN_CPT----------

open_cpt:	cmpi.b	#1,d0		; file ".FULL" ?
		beq.s	not_ful_open
		lea.l 	1424(a0),a0
loop:		cmpi.l	#$000a000a,(a0)+
		bne.s	loop
		adda.w	#28,a0
		
not_ful_open:	move.w	32(a0),d7	; r‚sol image 
		move.w	d7,resol
		moveq.l	#8,d1		;
		lsr.b	d7,d1	 	; 8,4,2 nombre de bytes a copier 
;					; a chaque offset

;......................................find ($FFF) fin des data … r‚pp‚ter...

		addq.l	#4,d1		; + 2 word 
		move.w	70(sp),d2	; taille fichier
		lea.l	34(a0),a4	; premier ordre de r‚p‚tition
		lea.l	0(a0,d2.w),a6	; fin du fichier

		moveq.l	#-2,d0		;R. bad file
find:		cmp.w	#$ffff,(a4)	;  ?
		beq.s	ok
		adda.l	d1,a4
		cmp.l	a4,a6		; Fin du fichier ?
		bhi.s	find		; Non 
		bra.s	end_prg
;........................................

ok:		moveq.l	#0,d0		; R. not error
		move.w	#-1,(a4)
		lea.l	0(a4,d1.w),a6	; a6 Pointe sur les datas unique
;					;    ou sur la fin du fichier.
;					; a4 Pointe sur $ffff  


		subq.b	#4,d1		; reset valeur 8,4,2
;
;........................................return image format degas......
;
		move.w	32(a0),(a1)+	; Ecrire non compress‚ et r‚sol

		bsr.s	palette

		addq.l	#2,a0		; Passer word resol

		move.w	d1,d2		; 8,4,2
		lsr.b	#1,d2		; Nombre de Word a copier …
		subq.b	#1,d2		; chaque offset.  -1 pour dbra
		moveq.l	#0,d3		; d3 = Compteur word

		moveq.l	#0,d4		; Comptage offset
		moveq.l	#0,d5		; Nombre de rep‚tition
*		moveq.l	#0,d6		; Offset
		move.w	#4000,d7	; Nombre total d'offset
		move.w	resol,d0
		lsl.w	d0,d7		;

lire_code:	move.w	(a0)+,d5	; Lire nombre de r‚p‚tition ?
		bpl.s	lire_offset	; Positif ! 

		moveq.l	#0,d5
lire_offset:	move.w	(a0)+,d6

test_offset:	cmp.w	d6,d4		; Offset   Compteur_Offset ?
		bmi.s	data_unique	;	 >
		beq.s	repeat_data	;        =
		bra	end_prg		;        < 
;.......................................

data_unique:	move.w	d2,d3		; reset compteur word
loop_unique:	move.w	(a6)+,(a1)+		 
		dbra.w	d3,loop_unique	; d3 = nombre de plan -1

		addq.w	#1,d4		; compteur offset +1
		bra.s	test_offset
;........................................

repeat_data:	move.w	d2,d3		; reset compteur word
		movea.l	a0,a2
copie:		move.w	(a2)+,(a1)+		 
		dbra.w	d3,copie	; d3 = nombre de plan -1
	
		addq.w	#1,d4		; compteur offset +1
		dbra.w	d5,repeat_data	

		adda.l	d1,a0		; Pointe sur word control suivant

		cmp.w	d7,d4		; Max_Offset > Compteur_Offset
		bmi.s	lire_code	; Non

		bra	 end_prg
;.......................................
resol:	dc.w	0

	end
;--------------------------------------------------------------------------
