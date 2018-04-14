;rockyone			pour MI-3			10/04/2016
;
;Modified start of the color cycle on the image palette								12.04.2018
;
;	CYCLE COULEURS  : ART DIRECTOR	: ART  ( basse r‚solution )
;	------------------------------------------------------------
;
;Anime		buffer 512 octets
;	+0    8 palette 16 words colors
;	+256  8 bytes   1 byte nombre de vbl pour chaque palette 
;					      0 = pal not display
;     
;	+287  1 byte    numero de la palette de l'image =  0 to 8
;                                                   ( 0 = inutilis‚ )
;       +288 a +512     inutilis‚
; 				
; 			call Art_cycle( L Anime)
;			------------------------
;
;  keybord      : Arret en fin de cycle
;  Mouse	: Force arret     	
;------------------------------------------------------------------------
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	64(sp),a5

	moveq.l	#0,d3
	moveq.l	#0,d6
	lea.l	table(pc),a4
	lea.l	256(a5),a6	; Adr des nombres de vbl par palette
	move.b	287(a5),d6	; Num‚ro de la palette affich‚ 0 a 7
	move.w	d6,d7
	
	lsl.b	#5,d7		; *32
	adda.w	d7,a5		; addresse de la palette a l'‚cran
	move.l	a5,palette

*	d4		        ; Compteur vbl
	move.b	d6,d3		; Compteur palette
	moveq.l	#9,d7		; Stop en fin de cycle  ( d7 = d3 )  
;				; AprŠs clique mouse, d7 = d6
	bra.s	start		; added on 12.04.2018
;........................................................................
;
next_pal:	
;...............................test clavier.......................
;
		move.w	#2,-(sp)
		move.w	#1,-(sp)
		trap 	#13
		addq.l	#4,sp
		tst.w	d0
		beq.s	no_key

		move.b	d6,d7		; Arret fin cycle

no_key:		move.w	68(sp),a0	;varptr(mousebut)+6
		tst.b	1(a0)
		beq.s	no_mouse
		move.b	d3,d7		; Force fin cycle


no_mouse:	cmp.b	d3,d7		; Fin cycle ?
		beq.s	end_prg
;
;..................................................................
;
vsync:		move.w	#37,-(sp)	; Vsync
		trap	#14		; Xbios
		addq.l	#2,sp
		dbra.w	d4,vsync
		lea.l	32(a5),a5	; Adresse Palette suivante
		addq.b	#1,d3		; Conpteur palette +1
		cmpi.b	#8,d3		; Derniere palette du buffer ?
		bne.s	nb_vbl

first_pal:	moveq.l	#0,d3		; Cpt palette sur premiŠre palette
		move.l	64(sp),a5	; Adresse premiŠre palette du buffer
start:
nb_vbl:		moveq.l	#0,d4
		move.b	0(a6,d3.w),d4	; Nombre de VBL pour cette palette
		beq.s	next_pal	; 0 = not display this palettte

		move.b	0(a4,d4.w),d4	; conversion valeur vbl
		bsr.s	pal
		bra.s	next_pal
;................................												
pal:		moveq.l	#7,d5		; 16 couleurs
		movea.l	#$ffff8240,a3
pal_display:	move.l	(a5)+,(a3)+
		dbra.w	d5,pal_display
		lea.l	-32(a5),a5
		rts
;..................................................................
;
end_prg: 	move.l	palette,a5
		bsr.s	pal
		moveq.l	#0,d0
		movem.l	(a7)+,d0-d7/a0-a6
		rts
;..................................................................
		even
;		        0 1 2 3 4 5  6  7  8   9  
table:		dc.b	0,1,3,5,8,16,27,65,126,254
		even
palette:	ds.l	$0

		end
;-------------------------------------------------------------------------
