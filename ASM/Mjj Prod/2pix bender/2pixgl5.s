 

;
;
; 2pix bender
;code by gloky
;

; ceci est un dump de 2pixgl3.s
; il va etre amelior comme suit:
; un troisieme sinus pur la fonction
; une gestion minmax meilleurs (les minmax ne sont plus de 16 en 16 mais de 1 en 1)


		TEXT
fonte198	equ 1
interstice	equ 0	; interstice on ou off 	
nbinterstice	equ 1	; =1 ou plus, n =n*2 pixel d'espace entre 2 lettre si zero, just set interstice=0 
justifyfonte	equ 0	; si =1, analyse la fonte au prealable et shrink le cas echeant exemple, le i prendra moins d'espace
XFONTE equ 2
HAUTEURFONTE equ 24
NBFONTECAR equ 50

*	ifne fonte198-1
*XFONTE equ 1
*HAUTEURFONTEfile equ 14
*HAUTEURFONTE equ 16
*NBFONTECAR equ 40
*	endc

STANDALONE	equ 1

		ifne STANDALONE
		clr.l -(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		endc
pixbender2bitstart:
		jsr init2pix

		ifne STANDALONE
		lea oldpalette,a0
		movem.l $ffff8240.w,d0-d7
		movem.l d0-d7,(a0)
		endc

	
		lea palette,a0
		movem.l (a0),d0/d1
		movem.l d0/d1,$ffff8240.w

		jsr wvbl
		ifne standalone
		move.b #0,$ffff8260.w
		endc
		ifeq standalone
		rts
		endc

main_2pixgl3:
		IFNE STANDALONE
		move.l logscr,d0
		move.l physcr,d1
		move.l d1,logscr
		move.l d0,physcr
		jsr set8200
		ENDC

		not $ffff8240.w
		
		IFNE STANDALONE

		jsr wvbl
		rept 128*20
		nop
		endr
		not.b $ffff8240.w
		rept 128
		nop
		endr
		not.b $ffff8240.w


		ENDC
		NOT $FFFF8240.W
		ifeq STANDALONE
		move.l workscr,d0
		move.l d0,logscr
		endc
		jsr demobitbender
;		ifeq STANDALONE		
;		move.l logscr,d0
;		move.l physcr,d1
;		move.l d1,logscr
;		move.l d0,physcr
;		jsr set8200
;		ENDC
		

		
		ifne STANDALONE
		cmp.b #$39+$80,$fffffc02.w
		beq.s .exitmain
		jmp main_2pixgl3
.exitmain:
		pea exit_2pixgl3
		endc	
		rts
	
	
exit_2pixgl3:	
		ifne standalone
		lea oldpalette,a0
		movem.l (a0)+,d0-d7
		movem.l d0-d7,$ffff8240.w
		endc

		ifne standalone
		move.l $44e.w,d0
		jsr set8200
		jsr wvbl
		move.b #1,$ffff8260.w
		; restaurer palette
		; dezinit mem si necessaire
		; flush keyboard
		; resolution d'avant
		endc
		ifeq STANDALONE
		rts
		endc
		ifne STANDALONE
		clr.w -(sp)
		trap #1
		endc
		ifeq STANDALONE
		jsr dezinitramspace2pix
		*jsr dezinit_mem_2pixgl3
		endc

		ifne STANDALONE
	include "mymem.s"
	*include "mymem.s"
		endc
	BSS
	ifne STANDALONE
oldpalette	ds.l 8
	endc
	DATA
palette	dc.w 0,$441,$415,$455	;$441,$666,$223
	TEXT

init2pix:
	ifne STANDALONE
	jsr initmemall
	endc
	jsr initramspace
	;lea variables,a1

	move.l convY160,a2
	moveq #0,d0
	move.w #160,d1
	move.w #199,d2
.makeconv
	move.w d0,(a2)+
	add d1,d0
	dbf d2,.makeconv


; creation des couleurs de fonte
	lea fontes,a2
	move.l fonteexpend,a1		; adresse buffer qui va contenir la fonte expendÃ©
	lea colorswaptab1_3,a3
	
	move.w #49,d0				; 50 caractere
	
.fontecar:
	move.w d0,-(sp)
	move.w #1,d0
	move.l a2,-(sp)
.row
	move.w #7,d6
	move.l #%10000000000000001000000000000000,d5
	move.w #15,d4		16 bit
	;*lea 16(a1),a3
	move.l a2,-(sp)
.bcl:
	;moveq #15,d7
	move.w #HAUTEURFONTE-1,d7

.loop:
	move.w (a2)+,d2
	move.w (a2)+,d3
	
	add.w #4,a2
	
	and.w d5,d2
	lsr d4,d2
	; d2=0 ou 1
	and.w d5,d3
	lsr d4,d3
	add d3,d3
	add d2,d3		; d3 =xx couleur fonte original
	move.b (a3,d3),d3	; d3=xx couleur 1 et 3 inversÃ©
	lsl #4,d3
	move.b d3,(a1)+
	dbf d7,.loop
	
	lsr.l #1,d5
	subq #1,d4
	moveq #HAUTEURFONTE-1,d7
	lea -4*XFONTE*HAUTEURFONTE(a2),a2
.loop2:
	move.w (a2)+,d2
	move.w (a2)+,d3
	add.w #4,a2	
	and.w d5,d2
	lsr d4,d2
	and.w d5,d3
	lsr d4,d3
	add d3,d3
	add d2,d3
	move.b (a3,d3),d3	; couleur xx 1 et 3 swapÃ©
	lsl #2,d3
	move.b d3,(a1)+
	dbf d7,.loop2
	
	lsr.l #1,d5
	subq #1,d4
	lea -4*XFONTE*HAUTEURFONTE(a2),a2			; XFONTE=1 ou 2
	dbf d6,.bcl
	
	move.l (sp)+,a2
	add.w #4,a2
	dbf d0,.row
	move.l (sp)+,a2
	move.w (sp)+,d0
	;sub.w #8,a2						; 4*(xfonte-1) ?
	lea HAUTEURFONTE*XFONTE*4(a2),a2
	dbf d0,.fontecar
	
	ifne justifyfonte
	move.l fonteexpend,a0
	lea tableaujustif,a1
	move.w #49,d7		; 50 car
.justifyloop:
	move.w #15,d6		; 16 double colone, a changer avec valeur equ
.loopcol
	move.w #HAUTEURFONTE-2,d5
	move.b (a0)+,d0
	moveq #0,d1
.scanonecolone:
	or.b (a0)+,d0
	dbf d5,.scanonecolone
	tst.b d0
	bne.s .endjustifyleft
	addq.w #1,d1
	dbf d6,.loopcol
	; ici on a tout scann et tout est egale a zero
	; on considere qu'il s'agit d'un espace
	move.w #16,(a1)+
	dbf d7,.justifyloop
	jmp .suite	
.endjustifyleft:
	; d1 contient le nombre d'espace au debut du caractere
	cmp.w #2,d1
	bmi.s .nojustifyleft
; d1=2 ou plus:	on decalale la lettre a gauche pour obtenir un espacement de 2
	;sub.w #2,d1
	;si d1=5 par exemple, on decale de 5-2= 3 colonne
	; a0 si zerocol un scan , a0 a ete scann d1+1 fois 
	move.w d1,d2
	addq #1,d2
	mulu #HAUTEURFONTE,d2
	neg.w d2
	lea (a0,d2),a2		; a2 se trouve au debut de la lettre
	move.w d1,d2		; d2=1 <=> 1 espace
	move.w #16-1,d3		; taillex de la fonte
	sub.w d2,d3
.justifyleft:
	move.w #HAUTEURFONTE-1,d4
.deponecol:
	move.b (a0)+,(a2)+
	dbf d4,.deponecol
	dbf d3,.justifyleft
	; now a copier la lettre vers sa gauche mais on a pas effacer le reste a droite

	move.w d1,d2
	mulu #HAUTEURFONTE,d2
	subq #1,d2
	moveq #0,d4
.1	move.b d4,(a2)+
	dbf d2,.1
	; a2 se trouve a la letre suivante
	; et a0 aussi a priori
	; d1 est toujours egale au nombre de colone vide qu'il y'avait avant

	; now on scan la partie droite
	; on sait deja qu'il y'a d1 colone vide a droite puisqu'on a decaler la fonte de d1 colone
	
	move.w d1,d4
	mulu #HAUTEURFONTE,d4
	sub.w d4,a0	; a0 se trouve a la fin du gfx lettre decal


	move.w #16-1,d6	16 double colone
	sub d1,d6	- justifyleft
	moveq #0,d5	; nombre de colone espace a droite
	moveq #0,d4
.scan0	move.w #HAUTEURFONTE-1,d2
.scan2	move.b -(a0),d3
	or.b d3,d4
	dbf d2,.scan2
	tst.b d4		; d4 = 0 -> une colone vide
	bne.s .endjustifydroite
	; colone vide on ajoute 1 a d1
	addq.w #1,d1
	addq.w #1,d5
	dbf d6,.scan0
	nop nop
.endjustifydroite
	; d5 = nombre de colone espace a droite sur la lettre shrink
	; a0 = lettre+colonne numero 16 - d1-1
	;  et aussi la premiere colone pleine
	; la lettre a deja ete shrink comme il faut a gauche
	; il faut juste placer la taille total de la lettre avec interstice
	move.w #16,d0	; la taille de la fonte non schrink
	sub.w d1,d0	; -nombre total de colone espace gauche+droite    
	addq.w #2,d0	; +l'espacement normalis entre 2 lettre
	cmp.w #16,d0	; mais on ne doit pas depass la taille max de la lettre
	blt.s .nomax
	move.w #16,d0
.nomax
	move.w d0,(a1)+

	; on replace a0 a la letre suivante:
	mulu #HAUTEURFONTE,d1
	ext.l d1
	add.w d1,a0
	
	dbf d7,.justifyloop


.suite:
		endc

****	
	
	move.l bandescroll,a0
	move.l a0,d0
	move.l d0,windowscrollvar
	move.l d0,windowscrollconst

	; remplir les  160*2*5*4 octets avec adresse routine vide et 0
	move.l #dummyrout,d0
	moveq.l #0,d1
	move.w #160*2-1,d2
.clearbande:
	move.l d0,(a0)+			; a determiner: l'ordre
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	dbf d2,.clearbande	
	
	;jsr init_ecran		; 	placer un eventuel bitmap sur les 2 ecran
	

	;move.l fonteexpend,a0
	move.l listecgfonte,a2
	move.l zoneramcg,a1
	move.l fonteexpend,a4
	move.w #NBFONTECAR*8*XFONTE-1,d0
.bclcgfonte:
	movem.l d0/a0/a2/a4,-(sp)
	jsr create5cg
	movem.l (sp)+,d0/a0/a2/a4
	lea 5*4(a2),a2
	lea HAUTEURFONTE*2(a4),a4    32 = 16* 2 octet  sauter 2 colonne
	dbf d0,.bclcgfonte
	

	move.l listecgfonte,a2
	move.l asciitofonte,a3


		lea asciicar198,a1

		moveq #0,d0
		move.b (a1)+,d0
		mulu #8*5*4*XFONTE,d0
		move.w #255,d1
.defaultcar
		move.w d0,(a3)+
		dbf d1,.defaultcar
		move.l asciitofonte,a3
		moveq #0,d0
		move.w #8*5*4*XFONTE,d2		; 8*xfonte colone de 5 code genere *4 octet pour representer l'adresse			; *XFONTE ? 
.loopcar:
		moveq #0,d1	
		move.b (a1)+,d1			; a code ascii 'a' ....
		beq.w exitloop
		lsl #1,d1		; numerocar*2
		;en numerocar*2 y'a le compteur ordinal
		move.w d0,(a3,d1.w)		; correspond d0 = le 'compteur de boucle'*d2=8*5*4
		add.w d2,d0
		bra.s .loopcar		
		
asciicar:
		dc.b 29		; 29 = 29iem car de la fonte si caractere pas connu ici c'est l'espace (le 30 iem car de la chaine qui suit est l'espace)
		dc.b 'abcdefghijklmnopqrstuvwxyz:.1 234567890/'
		dc.b 0 = fin 
		even
asciicar198:
		dc.b 48
		dc.b 'abcdefghijklmnopqrstuvwxyz!?:;0123456789"(),-.+'' *'
		even
textescroll:
	dc.b 'abcdefghijklmnopqrstuvwxyz0123456789"(),-.+''* hello, this is a mix of two fx,  circles of dot (18x32 dot:  576 dots) and this scrolltext.   '
	dc.b 'the scroll take two plan, and the dots is on one of the plan take by the scroll '
	dc.b 'that mean there are 2 plan free, so a 320x200 image with  4 color can be displayed ...'
	dc.b 'or maybe 3 plan equal 8 color where the scroll is not displayed, with rastercolors technik.  '
	dc.b ' cliped dot could not be done with this fx because'
	dc.b ' it''s life, it''s the way the generated code is done '
	dc.b ' generated code is basicaly  or.w d0,1234(a0) sorted by shift and add d0,d0  '
	dc.b 'without the bitbender i can display more than 3000 dots with still the bottom border left '
	dc.b 'this have a price: no cliping or with lot of ram (big screen in memory)  '
	dc.b 'and it''s an idea i don''t like    .. this text is boring i know .....    '
	dc.b 'let''s wraaaaaap ........   5 4 3 2 1 tralala             '

	dc.b 0
	


;	dc.b 'and now, a circle of dot fx, with about 3000 dot .... please wait precalcing... ok :)'
;	dcb.b 10,' '
;	dc.b 'this demo take more than one meg, because all fx was mixed in a hurry. '
;	dc.b '   some fx can feat in 512k, other take 1 meg'
;	dc.b ' and now how about sinus dot ? '
;	dc.b 'at this time i wrote this text, i don''t know if you''ll see about 1000 dot or about 1400 dot depending on if i finish my sinus dot with optimisation at time '
;	dc.b ' this demo will probably lack of design and graphic '
;	dc.b 'may be without music i don''t know '
;	dc.b ' life...... '
;	dc.b ' this scroll feature bitwise y disting and 2 plan font (of course, the more there is pixel in font, the less there is machine time free)'
;	dc.b ' ok that''s all for the moment .....' 
;
;



		dc.b 0
		even
ptrtexte	dc.l textescroll
debuttexte:	dc.l textescroll
curfonte:	dc.l 1
windowscrollconst:	ds.l 1				; a remplir = move.l bandescroll,windowscrollconst
windowscrollvar		ds.l 1				; a remplir = bandescroll + deplacement
cptscrollvar		dc.w 0			; compteur 0..160

exitloop:
; la suite de init

		jsr create_fct
;		move.l sin1adr,a0
;		move.w currentT1,d0
;		add d0,d0
;		add d0,d0
;		move.l (a0,d0.w),a0			; adresse 320 valeur
;		move.l sin2adr,a1
;		move.w currentT2,d0
;		add d0,d0
;		add d0,d0
;		move.l (a1,d0.w),a1
;		
;		move.l windowscrollvar,a4		; en fait  bandescroll + le window offset
;		not $ffff8240.w
;		;jsr decodevalue
;		not $ffff8240.w
;	
;	jsr decodevalue

		rts
dummyrout	rts
initscrolltexte:
		clr.w cyclescroll
		rts
		ifne interstice
intermode	dc.w 0
intercount	dc.w nbinterstice
		endc
cyclescroll	dc.w 0
scrolltexte:
		IFNE interstice
	        tst.w intermode
		beq .1 	
		;lea curfonte,a2		; fonte courante+2col			;*****************************************
		move.l windowscrollvar,a0
		move.l #dummyrout,d0		; curfonte: dc.l listecgfonte+tlfnt*car
		
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
	
		lea 5*4*160-20(a0),a1
		move.l d0,(a1)+
		move.l d0,(a1)+
		move.l d0,(a1)+
		move.l d0,(a1)+
		move.l d0,(a1)+
		;lea 5*4(a0),a0
		move.l a0,windowscrollvar

		move.w #-1,cyclescroll
		subq.w #1,intercount
		bne.s .2
		move.w #0,intermode
		*move.w #-1,cyclescroll
		move.w #nbinterstice,intercount
.2		jmp .majmachin
		rts
.1		
		ENDC
		tst.w cyclescroll
		bne.s .autre
.entrerlettre
		move.l ptrtexte,a0
		moveq #0,d0
		move.b (a0)+,d0
		bne.s .ok
		move.l debuttexte,d1
		move.l d1,a0
		move.b (a0)+,d0
.ok:	move.l a0,ptrtexte
		add d0,d0	; d0*2
		move.l asciitofonte,a1
		move.w (a1,d0),d0		; converti en numero car*5*8*4*xfonte
		move.l listecgfonte,a2
		add d0,a2
		move.l a2,curfonte
.autre:
		lea curfonte,a2		; fonte courante+2col			;*****************************************
		move.l windowscrollvar,a0
		move.l (a2),a3		; curfonte: dc.l listecgfonte+tlfnt*car
		movem.l (a3)+,d0-d4
		move.l a3,(a2)
		
		movem.l d0-d4,(a0)
		lea 5*4*160(a0),a1
		movem.l d0-d4,(a1)
		lea 5*4(a0),a0
		move.l a0,windowscrollvar
.majmachin	
		addq.w #1,cptscrollvar
		cmp.w #160,cptscrollvar
		bne.s .ok2
		move.w #0,cptscrollvar
		move.l windowscrollconst,d0
		move.l d0,windowscrollvar
.ok2
		addq.w #1,cyclescroll
		cmp.w #8*XFONTE,cyclescroll
		bne.s .ok3
		ifne interstice
		  move.w #1,intermode
		endc
		move.w #0,cyclescroll
.ok3
		rts
		
set8200:
			lsr.w #8,d0
			move.l d0,$ffff8200.w
			rts
			IFNE STANDALONE
wvbl:
			move.w #$25,-(sp)
			trap #14
			addq.l #2,sp
			rts
			ENDC

oldT1	ds.w 2
oldT2 	ds.w 2
majcurrentT:

		lea oldT1,a0
		lea oldT2,a1
		move.w 2(a0),d0
		move.w d0,(a0)
		move.w 2(a1),d0
		move.w d0,(a1)
		move.w currentT1,d2
		move.w d2,2(a0)
		move.w currentT2,d3
		move.w d3,2(a1)


		move.w alphat1,d0
		move.w alphat2,d1
		;move.w currentT1,d2
		;move.w currentT2,d3
		add d0,d2
		add d1,d3
		move.w #511,d4
		and.w d4,d2
		and.w d4,d3
		move.w d2,currentT1
		move.w d3,currentT2

		;lea oldT1,a0
		;lea oldT2,a1
		;move.w 2(a0),d0
		;move.w d0,(a0)
		;move.w 2(a1),d1
		;move.w d1,(a1)
		;move.w d2,2(a0)
		;move.w d3,2(a1)
		
		rts
		

;            H  L
;            
;           
;          d1 =01 01
;          d2= 01 10
;         d3 =01 11
;          d4 =10 01
;          d5 =10 11
;          d6= 11 01
;          d7= 10 10
;          d0 =11 10
;          d8= 11 11 = d3,d3



; ci apres: probleme bitmap et non couleur  (00 01 correspond a bitmap correspondant plan0 plan1)
				
		
listeopcode:			; classÃ© par couleur premier pix,couleur deuxieme pix c1c1 c2c2 00 00 a 11 11
		dc.l 0
		dc.l $83680000,$83680002,$83a80000,$85680000
		dc.l $8b680000,$89a80000,$8da80000,$85680002
		dc.l $85a80000,$87680002,$87a80000,$8fa80000
		dc.l $81a80000,$8ba80000
		dc.L $7897ffff

;		   d0= 11 10
;          d1 =01 01
;          d2= 01 10
;          d3 =01 11
;          d4 =10 01
;          d5 =10 11
;          d6= 11 01
;          d7= 10 10
;     
;          d8= 11 11 = d3,d3
regvalue:
;			dc.l %11000000000000001100000000000000

			dc.l %11000000000000001000000000000000	; d0 = 11 10
			dc.l %01000000000000000100000000000000	; d1 = 01 01
			dc.l %01000000000000001000000000000000	; d2 = 01 10
			dc.l %01000000000000001100000000000000	; d3 = 01 11
			dc.l %10000000000000000100000000000000	; d4 = 10 01
			dc.l %10000000000000001100000000000000  ; d5 = 10 11
			dc.l %11000000000000000100000000000000	; d6 = 11 01
			dc.l %10000000000000001000000000000000	; d7 = 10 10

regvalue0:
;			dc.l %11000000000000001100000000000000

			dc.l %10000000000000001100000000000000	; d0 = 11 10
			dc.l %01000000000000000100000000000000	; d1 = 01 01
			dc.l %01000000000000001000000000000000	; d2 = 01 10
			dc.l %01000000000000001100000000000000	; d3 = 01 11
			dc.l %10000000000000000100000000000000	; d4 = 10 01
			dc.l %10000000000000001100000000000000  ; d5 = 10 11
			dc.l %11000000000000000100000000000000	; d6 = 11 01
			dc.l %10000000000000001000000000000000	; d7 = 10 10

loadregvalue:
		
		movem.l regvalue,d0-d7
		rts


specialgeneric
		;tst.l d0
		beq .1
		not.l d0
		add d2,d0
		move.l d0,(a1)+
		addq.l #2,d0
		move.l d0,(a1)+
.1		jmp (a6)

create5cg:
	; a1 = ram
	; a2 = list of cg (5 adresse)
	; a4 = fonte+2col			; fonteexpend
	;lea listinstswap13,a3

	move.l a6,-(sp)		; au cas ou

	lea listeopcode,a3
	
	move.l a1,(a2)+
	
	; prepare cg0:
	 lea HAUTEURFONTE(a4),a5			14+2
	moveq #0,d3
	moveq #0,d2
	move.w #160,d5
	move.b (a4)+,d3
	lea _toto1,a6
	move.l (a3,d3.w),d0
	bpl.w specialgeneric				; special0
	add d2,d0
	move.l d0,(a1)+
_toto1
	lea _toto2,a6
	add d5,d2
	
	move.b (a4)+,d3
	move.l (a3,d3.w),d0
	bpl.w specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto2	
	lea _toto3,a6
	add d5,d2
	moveq #HAUTEURFONTE-3,d7
_loop0:
	move.b (a4)+,d3
	add.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto3
	add d5,d2
	
	
	dbf d7,_loop0

	lea _toto4,a6
	move.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
		;	jsr (a6)
_toto4
	lea _toto5,a6
	add d5,d2
	move.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto5
	move.w #$4e75,(a1)+
	
	;***************************************************
	lea _toto6,a6
	move.l a1,(a2)+
	; now le deuxieme code gen: 
	move.l a4,a5
	lea -HAUTEURFONTE(a4),a4
	;lea -16(a5),a5
	move.b (a4)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	move.l d0,(a1)+
	
	;moveq #0,d2
	;jsr (a6)
_toto6
	lea _toto7,a6
	move.w #160,d5
	move.w d5,d2
	moveq #HAUTEURFONTE-2,d7
_loop1:
	move.b (a4)+,d3
	add.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto7
	add d5,d2
	dbf d7,_loop1
	
	lea _toto8,a6
	move.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto8	
	move.w #$4e75,(a1)+
	
	;******************************************************
	lea _toto9,a6
	move.l a1,(a2)+
	; now le troisieme code gen: les 2 colonne au meme niveau
	moveq #0,d2
	move.l a4,a5
	lea -HAUTEURFONTE(a4),a4
	moveq #HAUTEURFONTE-1,d7
_loop2:
	move.b (a4)+,d3
	add.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto9
	add d5,d2
	dbf d7,_loop2
	move.w #$4e75,(a1)+
	

	;******************************************************

	move.l a1,(a2)+
	; now le 4iem la deuxieme colone est au dessus
	lea _toto10,a6
	moveq #0,d2
	move.l a4,a5
	lea -HAUTEURFONTE(a4),a4
	move.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto10
	lea _toto11,a6
	add d5,d2
	moveq #HAUTEURFONTE-2,d7
_loop3:
	move.b (a4)+,d3
	add.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto11
	add d5,d2
	dbf d7,_loop3
	lea _toto12,a6
	move.b (a4)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto12
	move.w #$4e75,(a1)+
	

	;******************************************************

	lea _toto13,a6
	move.l a1,(a2)+
	; now le 5iem code genere: la deuxieme colonne est 2 au dessus
	move.l a4,a5
	lea -HAUTEURFONTE(a4),a4
	moveq #0,d2
	
	move.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	;add d2,d0
	move.l d0,(a1)+
_toto13
	lea _toto14,a6
	add d5,d2
	move.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto14
	lea _toto15,a6
	add d5,d2
	moveq #HAUTEURFONTE-3,d7
_loop4:
	move.b (a4)+,d3
	add.b (a5)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto15
	add d5,d2
	dbf d7,_loop4
	lea _toto16,a6
	move.b (a4)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto16
	lea _toto17,a6
	add d5,d2
	move.b (a4)+,d3
	move.l (a3,d3.w),d0
	bpl specialgeneric
	add d2,d0
	move.l d0,(a1)+
_toto17
	
	move.w #$4e75,(a1)+
	;******************************************************
	
	move.l (sp)+,a6	; au cas ou, bis
	
	rts
	
			dc.w -320,16
			dc.w -160,16

			dc.w 0,0
			dc.w 160,4
tableappel:	dc.w 320,8				; a verifier toussa
			dc.w 320,12
			dc.w 320,16
			
			dc.w 480,0
			dc.w 640,0
			
			
			
	
decodevalue:
; a0 = sinus 1 sous forme de Y*2
; a1 = sinus 2 sous forme de Y*2
; d2 = F,F,F,%1100 and pour int(y/2)*4		*a2 = conversion int(Y/2)*4
; a3 = conversion Y*160
; a4 = adresse buffer contenant adr cg1,cg2,cg3,cg4,cg5 puis cg1,cg2,cg3,cg4,cg5 etc (bandeau des adresses cg)
; a5 = table qui contient le numero de la routine cg, l'offset a rajouter
	
	
	; entrÃ©e: a0,a1,a4: sortie: dans adresse zonememoire1
	; sortie: zonememoire1 contient ensemble adressse a a appeler, adresse ecran+offset repartie en 8 partie: suivant les numero de bit selectionner au moment de l'affichage
	
	lea tableappel,a5
	move.l a5,d5
	move.l convY160,a3
	move.l zonememoire1,a6				; 160*8 octet libre
	
	move.w #%1111111111111100,d2
	move.l logscr,d4
	;addq #2,d4: selection plan 1 et 2 au lieu de 0 et 1
	move.l a4,d7
	moveq #19,d6		; 20 bloque de 16pixel
	moveq #0,d3
.loop0:
	;moveq #7,d7			; 8x2= 16 pixel
							; offset X
	*move.l logscr,d4
.loop1
	rept 8
	move.w (a0)+,d0		; sin1
	add.w (a1)+,d0		; sin2
	move.w (a0)+,d1
	add.w (a1)+,d1
	
	sub.w d1,d0	; sub.w d0,d1		; d1=d1-d0   ; Y2=Y2-Y1: negatif si Y1 > Y2
	and.w d2,d0
	move.l d5,a5
	add d0,a5
	move.w (a5)+,d3  ; s/d1/d0			; d3 = numerocg, offset
	and d2,d1
	lsr #1,d1	;s/d0/d1	; y*4 devient y*2
	add d1,a3
	add.w (a3),d3	y*160 ;s /d0/d1
	sub d1,a3
	move.l d3,d0
	add.l d4,d0
	move.l d7,a4
	add (a5)+,a4				; ecran+8*int(x/16)
	move.l (a4),(a6)+
	move.l d0,(a6)+
	lea 19*8(a6),a6
	add #5*4,d7
	endr
	;dbf d7,.loop1
	lea -8*20*8+8(a6),a6		; ????
	addq.l #8,d4
	dbf d6,.loop0
	 
	rts
	
decodevaluebis:
; a0 = sinus 1 sous forme de Y*2
; a1 = sinus 2 sous forme de Y*2
; d2 = F,F,F,%1100 and pour int(y/2)*4		*a2 = conversion int(Y/2)*4
; a3 = conversion Y*160
; a4 = adresse buffer contenant adr cg1,cg2,cg3,cg4,cg5 puis cg1,cg2,cg3,cg4,cg5 etc (bandeau des adresses cg)
; a5 = table qui contient le numero de la routine cg, l'offset a rajouter
	
	
	; entrÃ©e: a0,a1,a4: sortie: dans adresse zonememoire1
	; sortie: zonememoire1 contient ensemble adressse a a appeler, adresse ecran+offset repartie en 8 partie: suivant les numero de bit selectionner au moment de l'affichage
	
	lea tableappel,a5
	move.l convY160,a3
	move.l zonememoire1,a6				; 160*8 octet libre
	
	move.w #%1111111111111100,d2
	move.l logscr,d4
	;addq #2,d4: selection plan 1 et 2 au lieu de 0 et 1

	moveq #19,d6		; 20 bloque de 16pixel
.loop0:
	moveq #7,d7			; 8x2= 16 pixel
							; offset X
	*move.l logscr,d4
	
.loop1:

	move.w (a0)+,d0		; sin1
	add.w (a1)+,d0		; sin2
	and.w d2,d0
	move.w (a0)+,d1
	add.w (a1)+,d1
	and.w d2,d1
	
	;sub.w d1,d0	; sub.w d0,d1		; d1=d1-d0   ; Y2=Y2-Y1: negatif si Y1 > Y2
	;neg.w d1
	move.l (a5,d1.w),d3  ; s/d1/d0			; d3 = numerocg, offset
	move.l (a4,d3.w),(a6)+		; stoque dans buffer resultat: adresse code genere a appeler
	swap d3				; Y relatif (*160)
	lsr #1,d0	;s/d0/d1	; y*4 devient y*2
	add.w (a3,d0),d3	y*160 ;s /d0/d1
	ext.l d3
	add.l d4,d3			; ecran+8*int(x/16)
	move.l d3,(a6)+
	lea 19*8(a6),a6
	lea 5*4(a4),a4
	
	dbf d7,.loop1
	lea -8*20*8+8(a6),a6		; ????
	addq.l #8,d4
	dbf d6,.loop0
	 
	rts
cpt:	dc.w 0

ultimatecall:
	move.l zonememoire1,a6
	
	movem.l regvalue,d0-d7		; les bits
	move.w #8,cpt
.loop:
	rept 20
	move.l (a6)+,a5		; adresse routine
	move.l (a6)+,a0
	jsr (a5)
	endr
	
	lsr.l #2,d0
	lsr.l #2,d1
	lsr.l #2,d2
	lsr.l #2,d3
	lsr.l #2,d4
	lsr.l #2,d5
	lsr.l #2,d6
	lsr.l #2,d7
	subq #1,cpt
	bne.w .loop

	rts

effacebande:
; d1 = valeur angle sin1 de depart correspondant a la bande  oldT1
; d2 = valeur angle sin2 de depart correspondant a la bande	 oldT2
; d0 = 0 pour le code effacement
; a1 = adresse ecran correspondant a la bande affichÃ©
; a0 utilisÃ© par cg effacement = ecran+offset X

; 
_debug	equ 0
	
	ifne _debug
	move.l blocefface,a4
	move.w 4*120(a4),-(sp)
	move.w #$4e75,4*120(a4)
	move.l #%00100010001000101000100010001000,d0
	move.l logscr,a0
	move.w #19,d7
.debug:
	jsr (a4)
	addq.l #8,a0
	dbf d7,.debug
	move.w (sp)+,4*120(a4)

	endc
	

	;not.w $ffff8240.w


	move.l oldT1,d1
	move.l oldT2,d2

	move.l logscr,a0
	
	move.l sinminmax1,a2
	move.l sinminmax2,a3
	move.w #19,d7	; 17 colonne
	
	move.w alphax1,d4
	move.w alphax2,d5
	asl #4,d4	; *16 
	asl #4,d5
	and.w #511,d4
	and.W #511,d5
	add d4,d4
	add d5,d5
	add d4,d4
	add d5,d5	*4
	move.l blocefface,a4			; lea codeefface,a4
	add d1,d1
	add d1,d1		; d1*4
	add d2,d2
	add d2,d2		; d2*4
	
	moveq #0,d0			; pour voir si ca marche: 1 au lieu de 0
	move.w #511*4,d6
.loop:
	move.l a2,a5
	add d1,a5
	move.l (a5),d3
	move.l a3,a5
	add d2,a5
	add.l (a5),d3
	and.l #%11111111111111001111111111111100,d3
	move.l a4,a5
	add d3,a5
	;move.l a4,a5		; adresse jsr = poid faible = min
	swap d3
	add #(HAUTEURFONTE+1)*4,d3
	move.l a4,a6
	add  d3,a6

;	lea (HAUTEURFONTE+1)*4(a4),a6	; 17 au lieu de 18 devrai marcher mais y'a des ptit point c pas normal			a6 = max+16 instruction
;	sub d3,a4
	move.w (a6),d3
	
	;moveq #0,d0
	move.w #$4e75,(a6)
	jsr (a5)
	
	move.w d3,(a6)			; restaure la ou y'avait le rts
	
	add d4,d1
	add d5,d2
	;move.w #511*4,d6
	and.w d6,d1
	and.w d6,d2
	
	addq.l #8,a0			; changement de colone
	dbf d7,.loop

	;not.w $ffff8240.w
	
	rts
	

demobitbender:
	
		jsr scrolltexte
		
		IFNE standalone
			not $ffff8240.w
		jsr effacebande
		not $ffff8240.w
		endc
		jsr majcurrentT
				
		move.l sin1adr,a0
		move.w currentT1,d0
		add d0,d0
		add d0,d0
		move.l (a0,d0.w),a0			; adresse 320 valeur
		move.l sin2adr,a1
		move.w currentT2,d0
		add d0,d0
		add d0,d0
		move.l (a1,d0.w),a1
		
		move.l windowscrollvar,a4		; en fait  bandescroll + le window offset
		not $ffff8240.w
;auto
		jsr decodevalue
;		add.w #1,timer
;		cmp.w #500,timer
;		bne.s .1
;		move.l #$4e714e71,auto
;		move.w #$4e71,auto+4	
;
;.1
		not $ffff8240.w


		jsr ultimatecall

		rts
timer 	dc.w 0
create_fct:

	move.w #510,alphax1
	move.w #1,alphax2
	
	move.w #1,alphat1
	move.w #100,currentT1
	move.w #511-3,alphat2
	move.w #19,currentT2

	lea oldT1,a0
	move.w #100,(a0)+
	move.w #100,(a0)+
	lea oldT2,a0
	move.w #19,(a0)+
	move.w #19,(a0)+
	


	move.l sinusTemp,a0
	move.w #125,d0
	jsr createSinTab

	move.w alphax1,d0		; pas interne premier sinus
	move.w #320,d1		; nombre de copie de valeur
	move.w #512,d2		; nombre d'element
	move.l ramvaluesin,a2
	move.l sin1adr,a1
	move.l sinusTemp,a0
	jsr createSpecialSin_2pixgl3
	*jsr createSpecialSin ;delta = modifier la manier de calc min max
	move.l a2,-(sp)
	
	move.l sinusTemp,a0
	move.w #90,d0
	jsr createSinTab

	move.l (sp)+,a2
	
	move.w alphax2,d0		; pas interner deuxieme sinus
	move.w #320,d1
	move.w #512,d2
	move.l sin2adr,a1
	move.l sinusTemp,a0
	jsr createSpecialSin_2pixgl3
	*jsr createSpecialSin_2pixgl3delta
	; calcul des minmax de chaque sinus
	;move.w #511,d0
	move.l sin1adr,a0
	move.l sinminmax1,a1

	*bsr .localrout
	*bra.s .suite
	pea .suite
	
.localrout:	
	move.w #511,d0
.bclangle:
	move.l (a0)+,a2
	move.w (a2)+,d2		; min
	move.w d2,d3		; max
	moveq #14,d1
.bcl15:
	move.w (a2)+,d4
	cmp d4,d2
	blt.s .1
	move.w d4,d2
.1
	cmp.w d4,d3
	bgt.s .2
	move.w d4,d3
.2
	dbf d1,.bcl15
	move.w d3,(a1)+		; min		; sera adresse d'appel de routine
	;add.w #16,d3		; non, pas hauteur de la fonte parce que sin1+sin2
	move.w d2,(a1)+		; max		; sera adresse de retour ou on met le rts
	dbf d0,.bclangle
	rts
.suite
	;move.w #511,d0
	move.l sin2adr,a0
	move.l sinminmax2,a1
	bsr .localrout
	
	rts

; pas le meme que dans la sinlib (*2 a la volÃ©)
	ifne standalone
createSinTab
; d0 = constante = rayon
; a0 = buffer qui contiendra rayon/2*sin(angle)+rayon/2
	lea sintabbss,a1
	move.w #511,d1
	;move.w #32768,d3
.loop
	clr.l d2
	move.w (a1)+,d2
					; nombre entre 0 et 65535 positif
	mulu d0,d2
	swap d2
	add d2,d2
	move.w d2,(a0)+
	dbra.w d1,.loop
	rts
	endc
colorswaptab1_3:
	; a faire, determiner meilleurs temps machine
		dc.b 0,1,2,3
		dc.b 0,1,3,2
		dc.b 0,2,1,3
		dc.b 0,3,1,2
		dc.b 0,2,3,1
		dc.b 0,3,2,1
		

			*dc.b 0,2,2,2
			*dc.b 0,1,2,3
			;dc.b 0,3,1,2
			;dc.b 0,3,1,2
			;dc.b 0,3,1,2
createSpecialSin_2pixgl3:
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupÃ© sur buffer resultat


	move.w d2,d3
	lea bufferFlag2,a3
	subq #1,d3
.clrflag
	clr.b (a3)+
	dbra d3,.clrflag
	

	move.w d2,d3	; 512 ou 1024
	subq #1,d3		; 511  ou 1023 pour le and de l'angle

	lea bufferFlag2,a3
	subq #1,d2		; 511 ou 1023 iteration
	moveq #0,d4		; angle
.loop
	tst.b (a3,d4)	; flag a 1 ?
	bne.s .flagA1
.flagA0
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),(a2)
	add d5,d5
	move.l a2,(a1,d5)			; a2 referencer en reftable+angle*4
	addq.l #2,a2
	st (a3,d4)		positione flag(angle) a 1
	add d0,d4		; pas interne
	and d2,d4		; mod 512 ou 1022
	bra.s .loop
.flagA1	; copier d1 fois les valeurs suivante
	move.w d4,d5		; angle courant copier sur d5
	move.w d1,d7
	subq #1,d7
.cpy
	move.w d5,d6
	add d6,d6
	move.w (a0,d6),(a2)+
	add d0,d5	
	and d2,d5
	dbf d7,.cpy
	
	sub d0,d4
	addq #1,d4
	and d2,d4
	tst.b (a3,d4)
	beq.s .flagA0
.fin
	rts
; not used
createSpecialSin_2pixgl3delta:
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupÃ© sur buffer resultat


	move.w d2,d3
	lea bufferFlag2,a3
	subq #1,d3
.clrflag
	clr.b (a3)+
	dbra d3,.clrflag
	

	move.w d2,d3	; 512 ou 1024
	subq #1,d3		; 511  ou 1023 pour le and de l'angle

	lea bufferFlag2,a3
	subq #1,d2		; 511 ou 1023 iteration
	moveq #0,d4		; angle
	move.w d0,d6		
	add d6,d6		= d6 = pas interne *2
.loop
	tst.b (a3,d4)	; flag a 1 ?
	bne.s .flagA1
.flagA0
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),(a2)

	add d5,d5
	move.l a2,(a1,d5)			; a2 referencer en reftable+angle*4

	;addq.l #2,a2
	
	move.w d4,d5
	add d0,d5
	and d2,d5
	add d5,d5
	move.w (a0,d5),d5
	neg.w d5
	add (a2)+,d5
	move.w d5,(a2)+


	st (a3,d4)		positione flag(angle) a 1
	add d6,d4		; 2*pas interne
	and d2,d4		; mod 512 ou 1022
	bra.s .loop
.flagA1	; copier d1 fois les valeurs suivante
	move.w d4,-(sp)
	;move.w d4,d5		; angle courant copier sur d5
	move.w d1,d7
	lsr #1,d7
	subq #1,d7
.cpy
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),(a2)
	add d0,d4	
	and d2,d4
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),d5
	neg.w d5
	add.w (a2)+,d5
	move.w d5,(a2)+
	dbf d7,.cpy
	
	move.w (sp)+,d4
	sub d0,d4
	addq #1,d4
	and d2,d4
	tst.b (a3,d4)
	beq.s .flagA0
.fin
	rts
	
	
	
initramspace:
; la bande de scroll contenant les 5 adresse de code genere:
	lea variables,a1
	move.l #5*4*160*2,d0
	move.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
; la zonememoire1: contenant adress routines et adresse ecran
	move.l #8*20*8,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
; les 2 ecran physique et logique
	ifne standalone
	move.l #64256,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,d0
	add.l #256,d0
	move.b #0,d0
	move.l d0,(a1)+
	add.l #32000,d0
	move.l d0,(a1)+
	endc

	ifeq standalone
	add.l #8,a1
	endc


;  les valeurs couleur %xx0000 et %00xx00 de toute la fonte: 1 octet par pixel,40 caractere 16x16 pixel
	move.l #NBFONTECAR*XFONTE*16*HAUTEURFONTE,d0			40*256
	add.l d0,ramtofree2pix

	jsr getMem
	move.l a0,(a1)+
	
***	
*; la zonememoire2: qui va contenir les 160*5 code genere qui se renouvelle en buffer circulaire
*	move.l #(18+17+16+17+18+4*5)*160*4+20*4,d0
*	jsr getMem
*	move.l a0,(a1)+
*
	
; la zone de variable:
	move.l #256,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
; les 512 adresse dans les sin1 et sin2
	move.l #512*4,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	move.l #512*4,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
; les 512 minmax de sin1 et sin2 
	move.l #512*2*4,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	move.l a0,d0
	add.l #512*4,d0
	move.l d0,(a1)+
	
; convY160
	move.l #200*2,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
	
; la ram pour les valeurs de sinus (taille arbitraire)
	move.l #512*2*10,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+

; listecgfonte:
	move.l #NBFONTECAR*XFONTE*8*5*4,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+

; asciitofonte:
	move.l #256*2,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
; zone des code genere:  zoneramcg

	*move.l #400*1024,d0			; une valeur au pif sufisament grande ici 400ko
	
	*move.l #58652,d0		; pas plus de 60k
	move.l #201376+300000,d0		; 800k de code genere on compte large       201376 = 196,66K avec fonte198 
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
; sinusTemp
	move.l #512*2,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+

; blocefface
	move.l #200*4+2,d0
	add.l d0,ramtofree2pix
	jsr getMem
	move.l a0,(a1)+
	
	; now creer le code gen:
	
	move.l #$21400000,d0		; instruction		<---------- a modif pour move.l d0,0(a0)
	move.w #199,d1
	move.w #160,d2
.bloceffacegen:
	move.l d0,(a0)+
	add.w d2,d0
	dbf d1,.bloceffacegen
	move.w #$4e75,(a0)+
	
	rts

dezinitramspace2pix:
	move ramtofree2pix,d0
	jsr freeMem
	rts
	
	BSS
variables:
bandescroll:	ds.l 1
zonememoire1:	ds.l 1
logscr:		ds.l 1
physcr:		ds.l 1
fonteexpend	ds.l 1
*zonememoire2:	ds.l 1
totovar	ds.l 1	buffer 256 octet
sin1adr	ds.l 1
sin2adr	ds.l 1
sinminmax1 ds.l 1
sinminmax2	ds.l 1
convY160	ds.l 1
ramvaluesin	ds.l 1
listecgfonte	ds.l 1		; pointe vers ds.l 40*8*5 adresse de codegen (40 car*5cg par colone2pix*8(=16 pix))
asciitofonte	ds.l 1		; pointe vers ds.w 256 offset sur listecgfonte = (asciitonumcar)*5*8*4 ou si inexistant cg caractere espace
zoneramcg	ds.l 1
sinusTemp	ds.l 1		; 512*2
blocefface	ds.l 1		; adresse routine liste de move.l d0,Y*160(a0)





; variable normale
currentT1	ds.w 1
currentT2	ds.w 1
alphat1		ds.W 1
alphat2		ds.w 1
alphax1		ds.w 1		; pas interne de sin1 et sin2
alphax2		ds.w 1

ramtofree2pix:	ds.l 1

*ramlistcg	ds.l 1
*ramcg		ds.l 1
*ramscreen1	ds.l 1
*ramscreen2	ds.l 1
*physScr		ds.l 1
*logScr		ds.l 1
*bandeau		ds.l 2*8

*ram			ds.b 500000		; 500k
	
bufferFlag2	ds.b 512


	DATA
	ifne standalone
sintabbss	incbin 'C:\SRC2\2PIX\sin16b.dat'
	endc
fontes
*		ifne fonte198-1
*		incbin 'totofnt.dat'
*		endc
*		ifeq fonte198-1
		incbin 'C:\SRC2\2PIX\fnt198.dat'
*		endc