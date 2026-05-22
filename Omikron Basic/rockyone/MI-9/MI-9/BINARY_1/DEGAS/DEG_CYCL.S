;rockyone			pour MI-3 et MI-9		10/04/2016
;modifi‚							08.08.2018
;								10.08.2018
;ajout pour mi-9: test cycle valide				22.08.2018
; 								12.11.2018
; 
;
;			CYCLE COULEURS  : DEGAS
;			-----------------------
;
; * La palette de couleur n'est pas r‚stitu‚e pour voir dans MI-9 ou se 
;   situe l'arret. 
; * Mouse bouton :  force arret et retourne zero
; * Keybord      :  force arret et retourne le code touche in low d0     
;
;............................ Cycles format Degas ........................
; Anime	: 70 bytes 
; 
; +0 	4 word		premiere couleur de chaque cycle
; +8	4 word		derniere couleurs de chaque cycle
; +16	4 word		sens de chaque cycle
; +24	4 word		vbls de chaque cycle en 1/16 de seconde
; 
;....................... Fin Degas
;
; +32	1 word		Dur‚e de l'affichage pour diaporama ( =128-dur‚e )
; +34	1 word		largeur de l'image
; +36	1 word 		hauteur de l'image
;
;...................... Fin Neo
;
;
; ........................... Valeur pour routine d'affichage.............
; Utilis‚ pour la sauvegarde dans d'autres formats.
; Des valeurs pouraient ‚tre sur des bytes, mais je n'ai pas envie de 
; reprendre les routines concern‚es.
;
; +38	4 byte		premier couleur de chaque cycle *2 
; +42	4 byte		inutilis‚
; +46	4 byte		offset derniŠre couleur de chaques cycles
; +50	4 word		-1 egal cycle actif
; +58	1 word          1 to 4  nombre de cycle actif
; +60	4 word		Vbl par cycle   (( 128-Vbl )* 100 )/6 (+1) 
; +68	1 word		Dur‚es de l'affichage pour diaporama (en seconde)
;.........................................................................
;	
; Buf_Pal	160 bytes               Pour stoker les palettes	
;	+0     4*32 bytes 	 	1 palette par cycle
;	+128	 32 bytes		Palette … restituer
;	
; Time%:	1 word			dur‚e de l'affichage * 64
; op%           1 word                  1 test cycle valide uniquement
;                                       0 test et joue cycle
;.........................................................................
;
;			   	  a5       a6		
; 		call deg_cycl( L Anime, L Buf_Pal, Time%, Op% )
;		-----------------------------------------------
;   				  60        64       68    70   
;
; return	Key% in low d0 or zero
;		(anime+58) >0 si cycle actif( 
; 	
;-------------------------------------------------------------------------
;used a0-a6/d0-d7

		movem.l	d1-d7/a0-a6,-(a7)
		movem.l	60(sp),a5-a6

		bsr	init_cycle
		move.w	d4,50(a5)	; 58(a5) Nombre de cycle actif		
		beq	end_prg		; zero !

		
		tst.w	70(sp)		; Test cycle uniquement ?
		bne	end_prg		; oui


;---------------------------  CYCLES DE COULEURS -------------------------
;a5	non modifi‚
;
		move.l	60(sp),a5		; buffer anime
		move.w	68(sp),time		; temps d'affichage
;						
		dc.w	$a000
		move.w	-596(a0),d4		; current mouse button
		
		lea.l	vbls(pc),a3
		lea.l	50(a5),a4		; pointe to flag cycle
		move.l	10(a4),(a3)     	; vbl cycle  1 & 2
		move.l	14(a4),4(a3)		; vbl cycle  3 & 4


start:		move.w	#2,-(sp)		; Device
		move.w	#1,-(sp)		; Bconstat
		trap	#13			; xbios
		add.l	#4,sp
		tst.w	d0			; Key ?
		beq.s	test_mouse		; no

		move.w	#2,-(sp)		; Device
		move.w	#2,-(sp)		; Bconin
		trap	#13			; xbios
		add.l	#4,sp
		
		btst.b	#6,d0			; bare espace = %10000
		beq.s	end_prg
		bclr.b	#5,d0			; key en majuscule
		bra.s	end_prg

test_mouse:	dc.w	$a000
		cmp.w	-596(a0),d4		; clik mouse ?
		bne.s	end_cycle
		
vsync:		moveq.l	#0,d0
		moveq.l	#0,d6			; reset offset cycle
		moveq.l	#0,d3			; reset compteur cycle

		move.w	#$25,-(sp)		; Vsync
		trap	#14			; Xbios
		addq.l	#2,sp

		subq.w	#1,time			
		beq.s	end_cycle

all_cycle:	tst.w	0(a4,d6.w)		; cycle actif ?
		beq.s	next_cycle

		subi.w	#16,0(a3,d6.w)		; vbl cycle -16
		bhi.s	next_cycle		; >0 

		move.w	d3,d7
		move.l	64(sp),a6		; buffer palettes
		bsr.s	rotation_couleur
	
		move.w	10(a4,d6.w),0(a3,d6.w)	; reset vbl cycle

next_cycle:	addq.l	#2,d6
		addq.l	#1,d3	
		cmpi.w	#4,d3
		bne.s	all_cycle
		bra	start
;-------------------------------------------------------------------------
end_cycle:	moveq.l	#0,d0	

end_prg:	movem.l	(sp)+,d1-d7/a0-a6
		rts
;-------------------------------------------------------------------------
time:		dc.w	0
*exit:		dc.w	0
vbls:		dc.w	0,0,0,0

;---------------------- SUB ROUTINE ROTATION DES COULEURS ----------------

;a5  d6 ne sont pas modifiŠ
;----------------------------
;d0		offset premiŠre couleur
;d1		offset derniŠre couleur
;d6		num‚ro du cycle *2
;d7		num‚ro du cycle
;a0 a1		$fff8240
;a5		buffer anime
;a6 a2  	buffer palette
;d0		nombre de couleur -2 rotation
;d1		nombre de couleur -1 recopy
;d7		d7*32

rotation_couleur:
	moveq.l	#0,d0
	moveq.l	#0,d1

	move.b	38(a5,d7.w),d0	; offset premiŠre couleur
	move.b	46(a5,d7.w),d1	; ecart couleur

	movea.l	#$fff8240,a0
	adda.w	d0,a0		; + offset color
	movea.l	a0,a1		; pour tansfer dans palette cycle

	lsl.b	#5,d7		; offset adr. palette du cycle ( d7*32 )
	add.b	d0,d7		; +offset couleur
	lea.l	0(a6,d7.w),a2	; adresse palette du cycle
	movea.l	a2,a6
;...................
	move.w	d1,d2		;
	lsr.b	#1,d2		; monbre de couleur -1
	subq.b	#1,d2		; -1 pour rotation

;........................Affiche une palette de couleur...................
	tst.b	17(a5,d6.w)	; sens rotation ?
	bne.s	sens_d

sens_g:	move.w	2(a2),(a0)+
	addq.l	#2,a2
	dbra.w	d2,sens_g

	suba.w	d1,a2
	bra.s	last_color
;.......................................;
sens_d:	move.w	(a2)+,2(a0)
	addq.l	#2,a0
	dbra.w	d2,sens_d

	suba.w	d1,a0
;...................................
last_color:
	move.w	(a2),(a0)		; Rotation de la couleur restante
	lsr.b	#1,d1
;a1  $fff8240 + offset premiŠre couleur
;a6  Palette du cycle + offest premiŠre couleur
save_new_palette:
	move.w	(a1)+,(a6)+
	dbra.w	d1,save_new_palette
	rts

;----------------------------SUB ROUTINE INIT CYCLES ---------------------
;a5 a6 sont modifi‚s
; a5 est augment‚ de 8
;---------------------
;
;d0	b	compteur init cycle 4-1
;d1	b	offset premiŠre couleur
;d2	b	offset premiŠre … derniŠre couleur
;d3 d6	w	vbls cycle
;d4	wb	nombre de cycle actif 0 … 4
;a5 a4		buffer anime
;a6		buffer palette

init_cycle:
;       Fait dans basic au chargement d'une image
	move.l	#0,50(a5)		; Reset cycles valide
	move.l	#0,54(a5)		;   "    "    "       "
*	move.w	#0,58(a5)		; Efface ex nombre de cycle actif
;        ................................................................	

	lea.l	38(a5),a4
	moveq.l	#0,d4			; Reset nombre de cycle actif
	moveq.l	#3,d0			; test 4 cycles

init:	cmp.w	#1,16(a5)		; Cycle actif ?
	beq.s	next			; non

	move.w	(a5),d1			; PremiŠre couleur d'un cycle
	andi.b	#$f,d1			
	lsl.b	#1,d1			
	move.b	d1,(a4)			

	move.w	8(a5),d2	        ; DerniŠre couleur d'un cycle
	andi.b	#$f,d2			
	lsl.b	#1,d2			
*	move.b	d2,4(a4)  inutilis‚ ***

	sub.b	d1,d2			; Last color > first color ?
	bls.s	next			; non

	move.l	#128,d3			; VBl d'un cycle
	sub.w	24(a5),d3		; 	cycle valide ? >=0
	bmi.s	next			; non
	cmp.w	#129,d3			; 	cycle valide?  <=128
	bpl.s	next			; non

	move.b	d2,8(a4)		; Nombre de couleurs dans le cycle
	move.w	#-1,50(a5)		; Flag cycle actif	

	mulu.w	#100,d3			; Nombre de VBL pour un cycle
	divu.w	#6,d3
	move.l	d3,d6
	swap.w	d6
	cmpi.w	#4,d6
	bmi.s	ok_vbl	
	addq.w	#1,d3

ok_vbl:	move.w	d3,60(a5)		

	addq.w	#1,d4			; Nombre de cycle actif

next:	addq.l	#2,a5
	addq.l 	#1,a4
	dbra.w	d0,init			

*	move.w	d4,50(a5)		; 58(a5)	

;                  ..................................	

	movea.l	#$fff8240,a3		; palette de l'image
	moveq.l	#7,d7
copy_pal:
	move.l	(a3),(a6)+		; une palette par cycle
	move.l	(a3),32-4(a6)
	move.l	(a3),64-4(a6)
	move.l	(a3),96-4(a6)
	move.l	(a3)+,128-4(a6)		; palette de l'image
	dbra.w	d7,copy_pal

	rts
;.....................................
	end
;-------------------------------------------------------------------------