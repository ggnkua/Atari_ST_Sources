;rockyone			pour MI-3			26/06/2016
;
;modifi‚ pour MI-9						02/01/2017
;ajout conversion anime_degas vers anime_art
;
;	OPEN_SAVE  ART DIRECTOR	   ART  ( basse r‚solution )
;
;------------------------------------------------------------------------
;
;ART to PI1
;**********
;	a0 Source 	buffer 	32512 octets contenant le fichie.ART
;	a1 Destination	buffer 	32034 octets format PI1
;	a3 Anime	bufer	  512 octets pour y copier anime de art
;	Op% = 0
;		ART_O_S( L Source, L Destination,L Anime,W Op%,0)
;
;Return dans low d0	0 = pas de cycle de couleur
;			3 = cycle de couleur
;			file size 32512
;------------------------------------------------------------------------
;		      
;PI1 to ART
;**********
;	a0 Source	Buffer 	32066 octets contenant le fichier.PI1
;	a1 Destination	Buffer	32512 octets format ART
;	a2 Anime	Buffer    512 octet contenant anime Art
;	Op% = 1
;	Anime%		3 = anime de Art_Director dans Anime
;			1 = anime de Degas dans Source
;		            tester si conversion posible 
;
;		ART_O_S( L Source, L Destination,L Anime,W Op%,Anime%)
;
;Return pour  low d0   La taille du fichier.art  toujours 32512 octets     ;
;	      
;-------------------------------------------------------------------		

	movem.l	d1-d7/a0-a6,-(sp)
	movem.l	60(sp),a0-a2
	movem.w	72(sp),d2-d3

	move.l	#7999,d1	; 32000 bytes image

	tst.b	d2		; open or save ?
	bne.s	save_art

;................................ OPEN..................................
	move.w	#0,(a1)+	; R‚solution image
	movea.l	a1,a3		; Destination : palette art par defaut
	lea.l	32(a1),a1	; D‚but image destination
	bsr.s	copy_image	; a0 to a1+34

;.......................................................Cycle color ?
	moveq.l	#3,d0		;R. cycle art 
	tst.l	256(a0)		; time cycle palette 0 … 3		
	bne.s	anime
	tst.l	260(a0)		; time cycle palette 4 … 7
	bne.s	anime
	moveq.l	#0,d0		;R. pas de cycle
;........................................................

anime:	movea.l	a2,a4
	bsr.s	copy_anime	; a0+32000 to a2

;........................................................palette image ?
	moveq.l	#0,d3
	move.b	287(a4),d3	; num‚ro palette par defaut
	lsl.w	#5,d3		; * 32
	
	adda.l	d3,a4		; adr palette de l'image art

	bsr.s 	copy_pal	; a4 to a3  =  a2+d3 to a1+2
	bra.s	end_prg

;-------------------------------------------------------------------------
;                                   SAVE
;-------------------------------------------------------------------------
save_art:	exg.l	a0,a1
;----------------------------
		move.l	#32512,d0	;R.  Retourne taille file
		lea.l	2(a0),a4	; Pour defaut_pal si pas de cycle
		lea.l	34(a0),a0	; D‚but image source

		bsr.s	copy_image	; a0 to a1
	
		cmpi.b	#3,d3		; Anime Art ?
		bne.s	no_art		; non

		movea.l a2,a0		; move adr pour copy
		movea.l	a1,a2		;  "    "    "    "
		bsr.s	copy_anime	; a0 to a2  =  a2 to a1+32000
		move.l	#32512,d0	; file size
		bra.s	end_prg
;...............................
;a0 pointe sur dŠbut cycle art
;a1 pointe sur premiere palette buffer art
;a4 pointe sur palette degas

no_art:		move.l	a1,a3
		bsr.s	copy_pal	; a4 to a3 copy palette degas 
;					; dans art

		tst.b	d3		; Anime Degas ?
		beq.s	end_prg		; non

		bsr.s	test_cycle	;test cycle degas et cr‚e cycle art


;............................... END...................................

end_prg: 	movem.l   (sp)+,d1-d7/a0-a6
		rts
;......................................................................
copy_image:	move.l	(a0)+,(a1)+
		dbra.w	d1,copy_image
		moveq.l	#127,d1		; 512 bytes animation
		rts
;.......................................
copy_anime:	move.l	(a0)+,(a2)+
		dbra.w	d1,copy_anime
		rts
;.........................................
copy_pal:	moveq.l	#15,d1
copy_new:	move.w	(a4)+,(a3)+
		dbra.w	d1,copy_new
		rts
;.......................................
test_cycle:	moveq.l	#3,d1		; 4 cycle a tester
		moveq.l	#0,d2		; compteur cycle actif
		movea.l	a0,a5		; pointe sur premier cycle degas

;.......recherche cycle actif...........

cycles:		cmpi.w	#1,16(a5)	; 0= gauche, 1=stop,2=droit
		beq.s	not_cycle

		move.w	8(a5),d4	; derniŠre couleur du cycle
		sub.w	(a5),d4		; - premiŠre ....
		beq.s	not_cycle	; couleur identique

		cmpi.w	#8,d4		; 8 couleurs maximum
		bpl.s	not_cycle

		movea.l	a5,a0		; save addresse cycle
		addq.b	#1,d2		; compte cycle valide

not_cycle:	addq.l	#2,a5
		dbra.w	d1,cycles

		cmpi.b	#1,d2		; combien de cycle valide trouv‚
		beq.s	convert_cycle	; 1

		rts			; retour
;.......................................
;
;a0	pointe sur adresse cycle degas valide
;a1	pointe sur premiŠre palette du cycle art
;a3     pointe sur deuxiŠme palette du cycle art

convert_cycle:	lea.l	table(pc),a6	; table convert VBL

		moveq.l	#1,d6
		moveq.l	#7,d5
		move.w	24(a0),d7	; vbl degas

vbl:		cmp.b	(a6)+,d7
		bpl.s	ok_vbl
		addq.b	#1,d6		; vbl art
		dbra.w	d5,vbl

ok_vbl:		move.w	(a0),d3		; premiŠre couleur
		move.w	8(a0),d4	; derniŠre couleur
		sub.w	d3,d4		; nombre de palette a cr‚er
		subq.b	#1,d4		;-1 pour dbra
		lsl.w	#1,d3		; premiŠre couleur *2

		lea.l	256(a1),a2	; pointe sur adresse vbl cycle art
;	
;...............................creation palette
;
		move.w	d4,d2		; nombre de palette a cr‚er

		moveq.l	#0,d7
		move.b	d6,(a2)+	; Vbl palette dŠjas enregistr‚e

loop3:		move.b	d6,(a2)+	; Vbl pour chaque autre palette

		movea.l	a1,a4		; adr palette	
		lea.l	32(a1),a3	; adr prochaine palette

		bsr.s	copy_pal	; recopier la palette preccedante

		lea.l	0(a1,d3.w),a4	; pointe sur  couleur a d‚placer
		lea.l	32(a4),a3	

		move.w	d4,d1		; nombre de couleur a d‚placer

		tst.w	16(a0)	        ; sens du cyle a cr‚er ?
		beq.s	right		; sens gauche

;...............................D‚caler les couleurs concern‚es
left:		addq.l	#2,a3
		bsr.s	copy_new	; d1 =nombre de couleur -1
		move.w	(a4),32(a1,d3.w)
		bra.s	next

right:		move.w	(a4)+,d7
		bsr	copy_new
		move.w	d7,(a3)

next:		lea.l	32(a1),a1	
		dbra.w	d2,loop3
		rts

table:		dc.b	128,126,123,117,107,87,47,1
		end
;-------------------------------------------------------------------------