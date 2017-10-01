; ***************************************************************
;
;                          - G H O S T - 
;
;      Vertical moving scrolltext (C) BLACK RAINBOW 11/92
;
;           Code: -FANTOMAS-          Gfx: -TROLL-
;
; ***************************************************************

           opt o+

; ---------------------------------------------------------------
; Initialisations
; ---------------------------------------------------------------

; ----------------
; Mode superviseur
; ----------------

           clr.l 	-(sp)
           move.w 	#$20,-(sp)
           trap 	#1
           addq.l 	#6,sp
           move.l 	d0,oldssp

; -------
; Clavier
; -------

           move.b 	$484.w,key
           clr.b 	$484.w

; ------
; Souris
; ------
 
           pea stop_mouse
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; -------------
; Sauve palette
; -------------

           move.l 	#$ffff8240,a0
           lea 		oldpal,a1
           movem.l 	(a0)+,d0-d7
           movem.l 	d0-d7,(a1)

; --- Installe nouvelle palette ---

           pea 	palette
           move.w 	#6,-(sp)
           trap 	#14
           addq.l 	#6,sp
		            
; --- Sauve resolution ---

           move.w 	#4,-(sp)
           trap 	#14
           addq.l 	#2,sp 
           move.w 	d0,oldrez

; --- Sauve adresse ecran ---

           move.w 	#2,-(sp)
           trap 	#14
           addq.l	#2,sp
           move.l 	d0,oldscreen

; --- Cree deux ecrans --- 

           move.l 	#$60000,screen1
           move.l 	#$67d00,screen2

; --- Fond de plan ---

        lea 	fond,a0
        move.l 	screen1,a1
	bsr 	depack

	move.l	screen1,a0
	move.l	screen2,a1
	move.w 	#7999,d0
one_more	move.l	(a0)+,(a1)+
	dbra	d0,one_more

; --- Change resolution et ecrans ---

           clr.w 	-(sp)
           move.l 	#-1,-(sp)
           move.l 	#-1,-(sp)
           move.w 	#5,-(sp)
           trap 	#14
           add.l 	#12,sp


; --- Init musique ---

	moveq	#1,d0
      	jsr	music
           
; ************************
;
; INITIALISATIONS DIVERSES
;  
; ************************

; --- Init texte ---

	move.l	#txt-1,txt_ptr
	move.w	#7,nb_lignes
	move.w	#128-16,car_ptr

;

	move.l	#rasters_0,adr_rast0
	move.l	#rasters_1,adr_rast1

; --- Init mvmnt ---
	
	move.l	#fdp_lst,lst_ptr
	move.l	#guide_5,fdp_ptr
	move.l	#guide_5+8640,fin_fdp

; --- Init timers et synchro ---

           move.b 	$fffffa07.w,save_iera
           move.b 	$fffffa09.w,save_ierb
           move.b 	$fffffa13.w,save_imra
           move.b 	$fffffa11.w,save_isrb
           move.b 	$fffffa17.w,save_vect
           move.l 	$70.w,save_vbl
           move.l 	$120.w,save_hbl
           move.l 	$118.w,save_118

           and.b 	#0,$fffffa07.w
           and.b 	#$40,$fffffa09.w
           bclr 	#3,$fffffa17.w
           or.b 	#1,$fffffa07.w
           or.b 	#1,$fffffa13.w
           move.l 	#vbl,$70.w           
           move.l 	#newkey,$118.w
          

; ***************** 
;
; BOUCLE PRINCIPALE
;
; *****************


loop       cmp.b #$39,$fffffc02.w
           bne.s loop

; ****************
;
; FIN DU PROGRAMME
;
; ****************


; --- Restore timers ---

           clr.b $ffffa1b
           move.b save_iera,$fffffa07.w
           move.b save_ierb,$fffffa09.w
           move.b save_imra,$fffffa13.w
           move.b save_isrb,$fffffa11.w
           move.b save_vect,$fffffa17.w
           move.l save_vbl,$70.w
           move.l save_hbl,$120.w
           move.l save_118,$118.w
           
; --- Chip sonore ---


          move.b #8,$ffff8800.w
           move.b #0,$ffff8802.w
           move.b #9,$ffff8800.w
           move.b #0,$ffff8802.w
           move.b #$a,$ffff8800.w
           move.b #0,$ffff8802.w

; --- Ancienne resolution et ecrans ---
        
           move.w oldrez,-(sp)
           move.l oldscreen,-(sp)
           move.l oldscreen,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; --- Ancienne palette ---
          
           lea oldpal,a0
           move.l #$ffff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; --- Retablit la souris ---
 
           pea go_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; --- Retablit le clavier ---

           move.b key,$484.w

; --- Retour en mode USER ---

           move.l oldssp,-(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp

; --- Retour au DOS ---

           clr.w -(sp)
           trap #1


; *********
;
; PROGRAMME
;
; *********



vbl     clr.b 	$fffffa1b.w           ; disable TIMER B
	;move.w 	#$777,$ffff8240.w

; ---------------------------------------------------------------
; Palette
; ---------------------------------------------------------------

	clr.l	$ffff8242.w
	clr.l	$ffff8246.w
	clr.l	$ffff824a.w
	clr.l	$ffff824e.w

	move.b 	#1,$fffffa21.w ; number of counts, every scan line
	move.l	#hbl,$120.w

; ---------------------------------------------------------------
; Joue music
; ---------------------------------------------------------------

	move.l	a3,-(sp)
	jsr	music+8
	move.l	(sp)+,a3
	
	moveq 	#0,d0
	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	asr.w	#1,d0
	mulu	#$100,d0
	move.w 	d0,$ffff825e.w


; ---------------------------------------------------------------
; Teste si huit lignes OK
; ---------------------------------------------------------------

	addq.w	#1,nb_lignes	; Ligne = ligne + 1
	cmp.w	#8,nb_lignes	; 8 lignes ?
	bne.s	aff_ligne	; Non, on continue
	clr.w	nb_lignes	; Oui, nb_lignes = 0
	add.w	#16,car_ptr	; Et on change
	cmp.w	#128,car_ptr	; Fin du caractere ?
	bne.s	aff_ligne	; Non, on continue

; -----------------
; Caractere suivant
; -----------------

	moveq	#0,d0		; d0.l = 0
	move.l	txt_ptr,a0	; pointeur txt dans a0
	addq.l	#1,a0		; pointeur + 1
	move.b	(a0),d0		; valeur dans d0
	cmp.b	#255,d0		; = 255 ?
	bne.s	pas_fini	; Non, on continue
	move.l	#txt,a0		; Oui, debut du txt
	move.b	(a0),d0		; Valeur dans d0
pas_fini	move.l	a0,txt_ptr		; Sauve pointeur
	asl.w	#7,d0		; valeur * 128 = adr 
	lea 	fonte,a0		
	add.w	d0,a0
	move.l	a0,adr_car
	clr.w	car_ptr

; ----------------------------------
; Affiche une ligne en bas du buffer
; ----------------------------------

aff_ligne	move.l 	adr_car,a0
	add.w	car_ptr,a0
	move.l	adr_rast0,a1
	move.l	adr_rast1,a2
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,(a1)
	movem.l	d0-d3,(a2)

; ------------------------------------------
; Scrolle le buffer d'une ligne vers le haut
; ------------------------------------------

	add.l	#16,adr_rast0
	add.l	#16,adr_rast1
	cmp.l	#rasters_1,adr_rast0
	bne.s	timer
	move.l	#rasters_0,adr_rast0
	move.l	#rasters_1,adr_rast1

; ---------------
; Demarre TIMER B
; ---------------

timer	move.l	adr_rast0,a3
	move.w	#198,conte
        move.b 	#8,$fffffa1b.w

; ---------------------------------------------------------------
; Scroll du fond de plan d'une ligne vers le bas
; ---------------------------------------------------------------

	move.l	screen2,a1
	move.l	screen1,a2
	lea	104+198*160(a1),a1
	lea 	104+199*160(a2),a2
i	set	0
	rept 	199
	movem.l	i(a1),d0-d7/a0/a4-a6
	movem.l	d0-d7/a0/a4-a6,i(a2)
i	set 	i-160
	endr

; ---------------------------------------------------------------
; tests sur le pointeur de fond de plan
; ---------------------------------------------------------------

	move.l	fdp_ptr,a1	; Pointeur sur fdp
	lea	48(a1),a1	; fdp + 48
	move.l	a1,fdp_ptr	; Sauve pointeur
	cmp.l	fin_fdp,a1	; fini ?
	bne.s	ajout		; Non, on continue

; ---------------------------------------------------------------
; Choix du fond de plan dans la liste fdp_lst
; ---------------------------------------------------------------

	move.l	lst_ptr,a0	; Pointeur liste
	lea	8(a0),a0	; + 8 octets
	cmp.l	#fdp_ptr,a0	; fini ?
	bne.s	eh_non		; eh_non !
	move.l	#fdp_lst,a0	; debut liste -> a0
eh_non	move.l	a0,lst_ptr	; Sauve pointeur lst
	move.l	(a0),fdp_ptr	; (a0) -> dbut guide
	move.l	4(a0),fin_fdp	; 4(a0) -> fin guide

; ---------------------------------------------------------------
; Ajoute une ligne en haut sur le fond de plan
; ---------------------------------------------------------------

ajout	move.l	fdp_ptr,a1
	move.l	screen1,a2
	lea 	104(a2),a2
	movem.l	(a1),d0-d7/a0/a4-a6
	movem.l	d0-d7/a0/a4-a6,(a2)

;
; ***************************************************************
; SWAPPING DES DEUX ECRANS (LOGIC & PHYSIC)
; ***************************************************************
;

           move.l screen1,d0
           move.l screen2,screen1
           move.l d0,screen2

           lsr.l #8,d0
           move.w #$8200,a0
           movep.w d0,1(a0)

	   clr.w 	$ffff8240.w
           rte

; --------------------------------------------------------------
;
;                RASTERS & NO LOW BORDER (TIMER B)
;
; --------------------------------------------------------------

; -------
; Rasters
; -------

hbl	move.l 	(a3)+,$ffff8242.w	; 42-44
        move.l 	(a3)+,$ffff8246.w	; 46-48
        move.l 	(a3)+,$ffff824a.w	; 4a-4c
        move.l 	(a3)+,$ffff824e.w	; 4e-50
 	subq.w	#1,conte
	bne.s	fin_hbl
	clr.b	$fffffa1b.w             ; disable TIMER B
	;move.l	#border,$120.w
	;move.b	#8,$fffffa1b.w		; Set TIMER B to event count mode
	rte
fin_hbl	;clr.b	$fffffa1b.w             ; disable TIMER B
	rte

; -------------- 
; No down border
; --------------

border  clr.b	$fffffa1b.w
	movem.l 	d0/a0,-(sp)
	movea.w 	#$fa21,a0
	move.b 	#200,(a0)
	move.b 	#8,$fffffa1b.w
	move.b 	(a0),d0
wait2	cmp.b 	(a0),d0
	beq.s 	wait2
	clr.b 	$ffff820a.w
	rept 	28
 	nop
	endr
	move.b 	#2,$ffff820a.w
	movem.l 	(sp)+,d0/a0
	rte			
		
; -------
; Clavier
; -------

newkey     move.w #$2500,sr
           bclr #6,$fffffa11.w
           rte

; ***************************************************************
;
; ROUTINE DE DECOMPACTAGE ATOMIK 3.3 (C) ALTAIR
;
; ***************************************************************

;decrunch source code of ATOMIK by ALTAIR	;je tiens a preciser
;A0=packed code		;que j'ai entierement
;A1=depack adr.		;ecris ce compacteur
;call it by bsr.		;environnement compris.
			;pic_algo=1 ; lenght=$18e
PIC_ALGO:	equ	1	;pic_algo=0 ; lenght=$148
	opt	o+,x+
depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATOM",(a0)+
	bne	no_crunched
	move.l	a1,a5
	add.l	(a0)+,a5
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus:	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch:	moveq	#6,d6
take_lenght:	add.b	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:	moveq	#1,d6
	bsr.s	get_bit2
tablus2:	move.b	0(a4,d5.w),-(a5)	
	bra.s	make_jnk
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	lea	decrun_table(pc),a4
cont:	moveq	#2,d6
	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk:	moveq	#11,d6
	moveq	#11,d5
take_jnk:	add.b	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	bsr.s	decod_picture
	endc
no_crunched:	movem.l	(a7)+,d0-a6
 	rts
empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table:	dc.b	$60,$20,$10,$8
	ifne	PIC_ALGO
decod_picture:	move	-(a0),d7
	clr	(a0)
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc

; ***************************************************************
;
; VARIABLES ET DONNEES
;
; ***************************************************************

; -----------------------
; Buffer pour les rasters
; -----------------------

adr_rast0	ds.l	1
adr_rast1	ds.l	1
rasters_0  ds.w 	200*8	; 200 lignes de 8 rasters
rasters_1  ds.w 	200*8	; 200 lignes de 8 rasters

; ---------------------------------------------------------------
; Donnees pour le fond de plan 
; ---------------------------------------------------------------
;
; Guide_1: Ondulation
; Guide_2: Rotation
; Guide_3: A l'envers
; Guide_4: A l'endroit -> A l'envers
; Guide_5: A l'endroit
; Guide_6: A l'envers -> A l'endroit


fdp_lst	dc.l	guide_5,guide_5+8640
	dc.l	guide_4,guide_4+8640
	dc.l	guide_3,guide_3+8640
	dc.l	guide_6,guide_6+8640
	dc.l	guide_5,guide_5+8640
	dc.l	guide_1,guide_1+8640
	dc.l	guide_1,guide_1+8640
	dc.l	guide_1,guide_1+8640
	dc.l	guide_5,guide_5+8640
	dc.l	guide_5,guide_5+8640
	dc.l	guide_2,guide_2+8640
	dc.l	guide_2,guide_2+8640
	dc.l	guide_5,guide_5+8640
	dc.l	guide_7,guide_7+8640
	dc.l	guide_5,guide_5+8640
	dc.l	guide_7,guide_7+8640
	dc.l	guide_5,guide_5+8640

fdp_ptr	ds.l	1
lst_ptr	ds.l	1
fin_fdp	ds.l	1

;
;	
;

txt_ptr	ds.l	1
adr_car	ds.l	1
nb_lignes	ds.w	1
car_ptr	ds.w	1

txt	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	dc.b 	17,18,19,20,21,255
	even

; ---------------------------------------------------------------
; Lettre A
; ---------------------------------------------------------------

fonte	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$701,$000,$000,$000,$000,$000,$000,$771
	dc.w	$702,$000,$000,$000,$000,$000,$000,$772
	dc.w	$703,$713,$723,$733,$743,$753,$763,$773
	dc.w	$704,$000,$000,$000,$000,$000,$000,$774
	dc.w	$705,$000,$000,$000,$000,$000,$000,$775
	dc.w	$706,$000,$000,$000,$000,$000,$000,$776
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre B
; ---------------------------------------------------------------

	dc.w	$770,$670,$570,$470,$370,$270,$000,$000
	dc.w	$771,$000,$000,$000,$000,$271,$000,$000
	dc.w	$772,$000,$000,$000,$000,$272,$000,$000
	dc.w	$773,$673,$573,$473,$373,$273,$173,$073
	dc.w	$774,$000,$000,$000,$000,$000,$000,$074
	dc.w	$775,$000,$000,$000,$000,$000,$000,$075
	dc.w	$776,$676,$576,$476,$376,$276,$176,$076
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre C
; ---------------------------------------------------------------

	dc.w	$077,$067,$057,$047,$037,$027,$017,$007
	dc.w	$177,$000,$000,$000,$000,$000,$000,$000
	dc.w	$277,$000,$000,$000,$000,$000,$000,$000
	dc.w	$377,$000,$000,$000,$000,$000,$000,$000
	dc.w	$477,$000,$000,$000,$000,$000,$000,$000
	dc.w	$577,$000,$000,$000,$000,$000,$000,$000
	dc.w	$677,$676,$675,$674,$673,$672,$671,$670
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre D
; ---------------------------------------------------------------

	dc.w	$707,$717,$727,$737,$747,$757,$767,$000
	dc.w	$706,$000,$000,$000,$000,$000,$000,$776
	dc.w	$705,$000,$000,$000,$000,$000,$000,$775
	dc.w	$704,$000,$000,$000,$000,$000,$000,$774
	dc.w	$703,$000,$000,$000,$000,$000,$000,$773
	dc.w	$702,$000,$000,$000,$000,$000,$000,$772
	dc.w	$701,$711,$721,$731,$741,$751,$761,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre E
; ---------------------------------------------------------------

	dc.w	$007,$107,$207,$307,$407,$507,$607,$707
	dc.w	$017,$000,$000,$000,$000,$000,$000,$000
	dc.w	$027,$000,$000,$000,$000,$000,$000,$000
	dc.w	$037,$047,$057,$067,$000,$000,$000,$000
	dc.w	$047,$000,$000,$000,$000,$000,$000,$000
	dc.w	$057,$000,$000,$000,$000,$000,$000,$000
	dc.w	$067,$167,$267,$367,$467,$567,$667,$767
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre F
; ---------------------------------------------------------------

	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$711,$000,$000,$000,$000,$000,$000,$000
	dc.w	$722,$000,$000,$000,$000,$000,$000,$000
	dc.w	$733,$743,$753,$763,$000,$000,$000,$000
	dc.w	$744,$000,$000,$000,$000,$000,$000,$000
	dc.w	$755,$000,$000,$000,$000,$000,$000,$000
	dc.w	$766,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre G
; ---------------------------------------------------------------

	dc.w	$770,$670,$570,$470,$370,$270,$000,$000
	dc.w	$771,$000,$000,$000,$000,$271,$000,$000
	dc.w	$772,$000,$000,$000,$000,$000,$000,$000
	dc.w	$773,$000,$000,$000,$000,$000,$173,$073
	dc.w	$774,$000,$000,$000,$000,$000,$000,$074
	dc.w	$775,$000,$000,$000,$000,$000,$000,$075
	dc.w	$776,$676,$576,$476,$376,$276,$176,$076
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre H
; ---------------------------------------------------------------

	dc.w	$700,$000,$000,$000,$000,$000,$000,$770
	dc.w	$701,$000,$000,$000,$000,$000,$000,$771
	dc.w	$702,$000,$000,$000,$000,$000,$000,$772
	dc.w	$703,$713,$723,$733,$743,$753,$763,$773
	dc.w	$704,$000,$000,$000,$000,$000,$000,$774
	dc.w	$705,$000,$000,$000,$000,$000,$000,$775
	dc.w	$706,$000,$000,$000,$000,$000,$000,$776
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre I
; ---------------------------------------------------------------

	dc.w	$077,$067,$057,$047,$037,$027,$017,$007
	dc.w	$000,$000,$000,$147,$137,$000,$000,$000
	dc.w	$000,$000,$000,$247,$237,$000,$000,$000
	dc.w	$000,$000,$000,$347,$337,$000,$000,$000
	dc.w	$000,$000,$000,$447,$437,$000,$000,$000
	dc.w	$000,$000,$000,$547,$537,$000,$000,$000
	dc.w	$677,$667,$657,$647,$637,$627,$617,$607
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre J
; ---------------------------------------------------------------

	dc.w	$000,$000,$000,$000,$000,$057,$067,$077
	dc.w	$000,$000,$000,$000,$000,$000,$000,$177
	dc.w	$000,$000,$000,$000,$000,$000,$000,$277
	dc.w	$637,$000,$000,$000,$000,$000,$000,$377
	dc.w	$627,$000,$000,$000,$000,$000,$000,$477
	dc.w	$617,$000,$000,$000,$000,$000,$000,$577
	dc.w	$607,$617,$627,$637,$647,$657,$667,$677
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre K
; ---------------------------------------------------------------

	dc.w	$700,$000,$000,$000,$740,$750,$760,$770
	dc.w	$711,$000,$000,$741,$000,$000,$000,$000
	dc.w	$722,$000,$742,$000,$000,$000,$000,$000
	dc.w	$733,$743,$000,$000,$000,$000,$000,$000
	dc.w	$744,$000,$754,$000,$000,$000,$000,$000
	dc.w	$755,$000,$000,$764,$000,$000,$000,$000
	dc.w	$766,$000,$000,$000,$774,$775,$776,$777
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre L
; ---------------------------------------------------------------

	dc.w	$707,$000,$000,$000,$000,$000,$000,$000
	dc.w	$706,$000,$000,$000,$000,$000,$000,$000
	dc.w	$705,$000,$000,$000,$000,$000,$000,$000
	dc.w	$704,$000,$000,$000,$000,$000,$000,$000
	dc.w	$703,$000,$000,$000,$000,$000,$000,$000
	dc.w	$702,$000,$000,$000,$000,$000,$000,$000
	dc.w	$701,$711,$721,$731,$741,$751,$761,$771
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre M 
; ---------------------------------------------------------------

	dc.w	$770,$670,$000,$000,$000,$000,$170,$070
	dc.w	$771,$000,$571,$000,$000,$271,$000,$071
	dc.w	$772,$000,$000,$472,$372,$000,$000,$072
	dc.w	$773,$000,$000,$000,$000,$000,$000,$073
	dc.w	$774,$000,$000,$000,$000,$000,$000,$074
	dc.w	$775,$000,$000,$000,$000,$000,$000,$075
	dc.w	$776,$000,$000,$000,$000,$000,$000,$076
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre N 
; ---------------------------------------------------------------

	dc.w	$007,$000,$000,$000,$000,$000,$000,$077
	dc.w	$107,$117,$000,$000,$000,$000,$000,$177
	dc.w	$207,$000,$227,$000,$000,$000,$000,$277
	dc.w	$307,$000,$000,$337,$000,$000,$000,$377
	dc.w	$407,$000,$000,$000,$447,$000,$000,$477
	dc.w	$507,$000,$000,$000,$000,$557,$000,$577
	dc.w	$607,$000,$000,$000,$000,$000,$667,$677
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre O
; ---------------------------------------------------------------

	dc.w	$770,$670,$570,$470,$370,$270,$170,$070
	dc.w	$771,$000,$000,$000,$000,$000,$000,$071
	dc.w	$772,$000,$000,$000,$000,$000,$000,$072
	dc.w	$773,$000,$000,$000,$000,$000,$000,$073
	dc.w	$774,$000,$000,$000,$000,$000,$000,$074
	dc.w	$775,$000,$000,$000,$000,$000,$000,$075
	dc.w	$776,$676,$576,$476,$376,$276,$176,$076
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre P
; ---------------------------------------------------------------

	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$701,$000,$000,$000,$000,$000,$000,$771
	dc.w	$702,$000,$000,$000,$000,$000,$000,$772
	dc.w	$703,$713,$723,$733,$743,$753,$763,$773
	dc.w	$704,$000,$000,$000,$000,$000,$000,$000
	dc.w	$705,$000,$000,$000,$000,$000,$000,$000
	dc.w	$706,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre Q
; ---------------------------------------------------------------

	dc.w	$077,$067,$057,$047,$037,$027,$017,$007
	dc.w	$177,$000,$000,$000,$000,$000,$000,$116
	dc.w	$277,$000,$000,$000,$000,$000,$000,$225
	dc.w	$377,$000,$000,$000,$000,$000,$000,$334
	dc.w	$477,$000,$000,$000,$000,$472,$000,$443
	dc.w	$577,$000,$000,$000,$000,$000,$562,$552
	dc.w	$677,$676,$675,$674,$673,$672,$671,$670
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre R
; ---------------------------------------------------------------

	dc.w	$770,$670,$570,$470,$370,$270,$000,$000
	dc.w	$771,$000,$000,$000,$000,$271,$000,$000
	dc.w	$772,$000,$000,$000,$000,$272,$000,$000
	dc.w	$773,$673,$573,$473,$373,$273,$173,$073
	dc.w	$774,$000,$000,$000,$000,$000,$000,$074
	dc.w	$775,$000,$000,$000,$000,$000,$000,$075
	dc.w	$776,$000,$000,$000,$000,$000,$000,$076
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre S
; ---------------------------------------------------------------

	dc.w	$007,$107,$207,$307,$407,$507,$607,$707
	dc.w	$017,$000,$000,$000,$000,$000,$000,$000
	dc.w	$027,$000,$000,$000,$000,$000,$000,$000
	dc.w	$037,$137,$237,$337,$437,$537,$637,$737
	dc.w	$000,$000,$000,$000,$000,$000,$000,$747
	dc.w	$000,$000,$000,$000,$000,$000,$000,$757
	dc.w	$067,$167,$267,$367,$467,$567,$667,$767
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre T
; ---------------------------------------------------------------

	dc.w	$700,$710,$720,$730,$740,$750,$760,$770
	dc.w	$000,$000,$000,$731,$741,$000,$000,$000
	dc.w	$000,$000,$000,$732,$742,$000,$000,$000
	dc.w	$000,$000,$000,$733,$743,$000,$000,$000
	dc.w	$000,$000,$000,$734,$744,$000,$000,$000
	dc.w	$000,$000,$000,$735,$745,$000,$000,$000
	dc.w	$000,$000,$000,$736,$746,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre U
; ---------------------------------------------------------------

	dc.w	$770,$000,$000,$000,$000,$000,$000,$070
	dc.w	$771,$000,$000,$000,$000,$000,$000,$071
	dc.w	$772,$000,$000,$000,$000,$000,$000,$072
	dc.w	$773,$000,$000,$000,$000,$000,$000,$073
	dc.w	$774,$000,$000,$000,$000,$000,$000,$074
	dc.w	$775,$000,$000,$000,$000,$000,$000,$075
	dc.w	$776,$676,$576,$476,$376,$276,$176,$076
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; ---------------------------------------------------------------
; Lettre V
; ---------------------------------------------------------------

	dc.w	$607,$000,$000,$000,$000,$000,$000,$067
	dc.w	$507,$000,$000,$000,$000,$000,$000,$057
	dc.w	$407,$000,$000,$000,$000,$000,$000,$047
	dc.w	$307,$000,$000,$000,$000,$000,$000,$037
	dc.w	$000,$207,$000,$000,$000,$000,$027,$000
	dc.w	$000,$000,$107,$000,$000,$017,$000,$000
	dc.w	$000,$000,$000,$007,$007,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

; -------------------
; Palette de couleurs
; -------------------

palette	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w 	$000,$730,$600,$770,$765,$666,$444,$222

; ------------------
; Variables diverses
; ------------------

stop_mouse dc.b $12
go_mouse   dc.b $8

save_hbl   ds.l 1
save_118   ds.l 1
save_vbl   ds.l 1
oldscreen  ds.l 1
screen1    ds.l 1
screen2    ds.l 1
oldssp     ds.l 1

conte 	ds.w	1
oldrez     ds.w 1
oldpal     ds.w 16

save_vect  ds.b 1
save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
save_isrb  ds.b 1
key        ds.b 1
           even

guide_1	incbin "GUIDE_1.DAT"		; Ondulation
guide_2	incbin "GUIDE_2.DAT"		; Rotation
guide_3	incbin "GUIDE_3.DAT"		; A l'envers
guide_4	incbin "GUIDE_4.DAT"
guide_5	incbin "GUIDE_5.DAT"		; A l'endroit
guide_6	incbin "GUIDE_6.DAT"
guide_7	incbin "GUIDE_7.DAT"		; Dans des spheres

music      incbin "GHOST.SND"
fond	incbin "GHOST.PI1"