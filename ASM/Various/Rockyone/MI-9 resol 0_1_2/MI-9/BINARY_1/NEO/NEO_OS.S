;rockyone			pour M1-3 MI-9			
;modifi‚							11/05/2017
;optimis‚							29.06.2018
;modifi‚							07.07.2018
;
;						Dali SD0
;FORMATS	NEO			CEL	Anivision 	PaintWork
;
;+ 0	w $0000				$ffff	$0
;+ 2	w Resolution
;+ 4	b 32 bytes palette
;+36	b 12 bytes filename
;+48	b $80 = cycle actif		$0	$0
;+49	b PremiŠre et derniŠre couleur	$0	$0
;	  4 bit par couleur
;+50	b $80 = cycle actif		$0	$0
;+51	b Sens du cycle	-128 TO 128	$0	$0
;	  <0 = sens gauche
;+52	w Vbl dur‚e d'animation 		$000a	$0
;+54	w x offset				$0	      'ANivision'
;+56	w y offset				$0
;+58	w largeur					$0
;+60	w hauteur					$0
;
;+124	l 'NEO!'				$0	$0     
;+128	b data image		
;
;
;	open/save	: NEOCHROME		: NEO
;			: Cybert-Paint v2.0	: CEL 
;	open		: Anivision		: PIC 
;			: Paint Work		: NEO
;	-------------------------------------------------------------
;
; Source	: adresse buffer contenant tous le fichier
; Destination	: buffer de 32066 octets minimum
; Anime		: adresse buffer de 40 octet minimum
; Op%		: 0 Open
;		: 1 save N‚o
;		; 2 save CEL
; 
;	  open : ( L Source, L Destination, L Anime, W Op%)
;	  ------------------------------------------------
;
; Return dans anime : 32 word du cycle de couleur au format Degas-Elite
;  		     + 1 word it‚ration
;		     + 1 word largeur
;	             + 1 word hauteur
;
; Return dans	low  d0  1 cycle couleur actif
;		high d0  Alway R‚solution de l'image
;
;	  save:  ( L Destination, L Source, L Anime, W Op%)
; 	  ------------------------------------------------
;
; Return and low d0  file size         
;
;-------------------------------------------------------------------------
;a0 source
;a1 destination
;a2 anime
;a3 $ff8240
;d0 erreur ou cycle
;d3 r‚solution image

		movem.l	d1-d7/a0-a6,-(sp)
		movem.l	60(sp),a0-a2		; source/destination/anime
		move.w	72(sp),d0
		tst.b	d0
		bne	save_neo

;-----------------------------------------------OPEN---------------------
		
* pas pour fichier CEL, ni pour fichier Neo de PAINT-WORKS
*       cmp.l	'NEO!',124(a0)	; test entete"NEO!" ~~ ??? non !
*	beq	ok_neo
*	moveq.l	#-2,d0		; return erreur
*	bra.s	fin_prg
*ok_neo:	

;...............................OPEN......................................

open_neo:	movea.l	a0,a3
		move.w	2(a0),(a1)+		image resolution
		addq.l	#4,a0
		bsr	copy_pal		:a0 to a1
		lea.l	92(a0),a0

;...............................CYCLE DE COULEUR........................

; active les deux lignes suivante si le buffer Anime n'est pas prŠpar‚
*	move.l	#$10001,16(a2)		; Init les quatre cycles sur Stop 
*	move.l	#$10001,20(a2)		; C'est le minumum accept‚ par
*					; Degas-Elite.prg 

		cmpi.b	#$80,48(a3)		; cycle actif ?
		bne.s	not_cycle		; non
		cmpi.b	#$80,50(a3)
		bne.s	not_cycle		; non
;.......................................	

		move.b	49(a3),d1		; premiŠre couleur
		lsr.b	#4,d1			
		move.b	d1,1(a2)	

		move.b	49(a3),9(a2)		; derniŠre couleur
		andi.b	#$f,9(a2)	
;.......................................

		move.b	#0,17(a2)		; direction droite ?
		move.b	51(a3),25(a2)		; -128 to 128
		bmi.s	left			; non si positif

		move.b	#2,17(a2)		; direction gauche
		neg.b	25(a2)			
		subi.b	#128,25(a2)		; vbl
		bra.s	iteration

left:		addi.b	#128,25(a2)		; vbl 
;........................................

iteration:	move.w	52(a3),32(a2)		; time wiever	


not_cycle:

		lea size(pc),a4
		moveq.l	#4,d1
		move.l	58(a3),d2
test_size:	cmp.l	(a4)+,d2
		beq.s	copy_pic
		dbra.w	d1,test_size
;						; CEL................
		move.w	58(a3),d3			; largeur
		move.w	60(a3),d4		; hauteur

		movea.l	a1,a4
		move.l	#7999,d5
		move.l	#0,d0
clean:		move.l	d0,(a4)+
		dbra.w	d5,clean		

		divu.w	#16,d3
		move.w	d3,d5
		swap	d3
		tst.w	d3
		beq.s	ok_w
		addq.b	#1,d5

ok_w:		mulu.w	#4,d5		
new_line:	move.w	d5,d3
		movea.l	a1,a4
copy_line:	move.w	(a0)+,(a4)+
		subq.w	#1,d3
		bne.s	copy_line

		subq.w	#1,d4
		beq.s	end_prg

		lea.l	160(a1),a1
		bra.s	new_line

;.......................................................................
copy_pic:	move.w	#7999,d1
copy:		move.l	(a0)+,(a1)+
		dbra.w	d1,copy

;........................................fin............................

end_prg: 	movem.l	(sp)+,d1-d7/a0-a6
		rts
;-----------------------------------------------------------------------
copy_pal:	moveq.l	#7,d1			; 16 couleurs
color:		move.l	(a0)+,(a1)+	
		dbra.w	d1,color
		rts
;----------------------------------------------------SAVE-----------------
;
; Source        buffer PI1-3
; Destination	buffer de 32128 octets
; Anime		buffer de 40 octets contenant:
;			16 word de cycle de couleur format Degas-Elite
;			+1 word time for wiever 0 to 128
;			+1 worg largeur
;			+1 word hauteur
;			ou rien !
;			
;		call neo_save( L Source, L Destination, L Anime )			
;		-------------------------------------------------
;
; Retourn dans 	low d0	: la taille du fichier a sauvegarder
;		****  high  d0 : -4 si plusieurs cycles actif
;		****  test fait dans le basic
;
;-------------------------------------------------------------------------
save_neo:	movea.l	a2,a4			;For save time wiever and
;						;width and height image 
		exg.l	a0,a1	

		subq.b	#1,d0
		beq.s	save_resol              ; save NEO 
		move.w	#$ffff,(a1)		; header CEL

save_resol:	addq.l	#2,a1
		move.w	(a0)+,(a1)+		; r‚solution image

;.........................................palette..............
		bsr.s	copy_pal

		tst.b	d0		; save Neo ?
		beq.s	s_neo

		move.b	#$a,17(a1)
		adda.l	#12,a1		
		bra.s	size_pic

s_neo:		move.b	#$2e,8(a1)	; '.'
		adda.l	#12,a1
		

;........................................test et sauve cycle............
;destination a1+48
;------------
		movea.l	a2,a3		; Pour image sans cycle actif
;					; ---------------------------
		moveq.l	#3,d4		; Quatre cycles a tester
		moveq.l	#0,d1			

loop_2:		cmpi.b	#1,17(a2)	; sens du cycle 0 gauche, 1 stop
		beq.s	not_valide	;		2 droite

		move.w	(a2),d2		; PreniŠre couleur du cycle
		cmp.w	8(a2),d2	; < dermiŠre couleur du cycle ?
		bpl.s	not_valide	; NON

		addq.b	#1,d1		; Compte les cycles actif
		movea.l	a2,a3		; Stok adresse du cycle a copier
not_valide:	addq.l	#2,a2		; Pointe sur cycle suivant
		dbra.w	d4,loop_2

;.......................................

		cmpi.b	#2,d1		; plus d'un cycle actif ?
		bmi.s	ok_cycle	; no

*		moveq.l	#-4,d0		; return -4 pour alerte
*					; info fait dans basic
		bra.s	snot_cycle	;

ok_cycle:	tst.b	d1		; 0 ou 1 cycle ?
		beq.s	snot_cycle	; 0

		move.b	#$80,(a1)	; flag : valide les couleurs 
;					;     ( A tester au chargement! )
stop_cycle:	move.b	1(a3),d4	; PremiŠre couleur
		lsl.w	#4,d4
		add.b	9(a3),d4	; DerniŠre couleur
		move.b	d4,1(a1)	; Save Start/End color

;........................................direction du cycle de couleur
		move.w	24(a3),d4	; vbl
		tst.b	17(a3)		; direction ?
		beq.s	s_left		;
		neg.w	d4		; + to -
s_left:		addi.w	#128,d4
		move.b	d4,3(a1)	; sauve direction et vitesse
		cmpi.b	#$1,17(a3)	; cycle actif ?
		beq.s	snot_cycle	; non
*		beq.s	iteration	; non

		move.b	#$80,2(a1)	; flag: valide sens et vitesse
;					;       A tester au chargement !
;........................................

snot_cycle:
*iteration:
		move.w	32(a4),4(a1)	; time for wiever
	
*		move.w	#0,10(a1)	; offset x toujours 0
*		move.w	#0,12(a1)	; offset y toujours 0

size_pic:	move.w	34(a4),10(a1)	; largeur
		move.w	36(a4),12(a1)	; hauteur

		lea.l	76(a1),a1

		tst.b	d0		; save Neo ?
		beq.s	header_neo

		addq.l	#4,a1
		bra.s	save_pic

header_neo:	move.l	#'NEO!',(a1)+
save_pic:	move.w	#32128,d0	; NEO & CEL, always 32128 octets
		bra	copy_pic
;..........................................................................

size:		dc.l	$014000c8	; 320*200   (NEO INL CEL)	
		dc.l	$028000c8	; 640*200   (NEO INL)
		dc.l	$02800190	; 640*400   (NEO INL)
		dc.l	$0		;Anivision  (PIC)
		dc.l	$73696f6e	;Paint Work (NEO)

		end
;-------------------------------------------------------------------------
