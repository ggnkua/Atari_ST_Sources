
;
;
;
;
;
; gerbe de point
;
;
;
	;jmp aleatoire
; construit un tableau de 0 a 150
doLinearX2

	move.w #150,d2				; rayon du deplacement
	


	lea adresse128,a0		256 word temporaire
	moveq #127,d7			128 etapes
	moveq #0,d0
.loop
	move.l d0,d1
	mulu d1,d1

	addq #2,d0
	move.w d1,(a0)+		 	 0 to 254*254
	dbf d7,.loop


	; 128 deplacement
	;subq #2,d0
	;mulu d0,d0
	move.l d1,d0
	divu d2,d0		; d2= rayon = 150 pixel
	SWAP D0
	CLR.W D0
	SWAP D0
	lea -256(a0),a0


	lea horizontaltrajet+128*2,a1
	move.w #127,d7
.loop2
	moveq #0,d1
	move.w (a0),d1
	divu d0,d1
	move.w d1,(a0)+
	dbf d7,.loop2



	lea -256(a0),a0	
	; a1 = trajet final

; inverser l'ordre et 150 devient 0 et 0 devient 150
	moveq #127,d7
.reverse
	move.w d2,d1		150
	sub (a0)+,d1
	move.W d1,-(a1)
	dbf d7,.reverse


; dans listesqrt, le tableau de 0 a 150 qui commence rapidement en 0iem element et fini lentement vers la fin a 150
; on va utiliser la table de sinus de 512 valeur pour creer 512 trajectoire avec 128 element de 0 a 150
; positionné a l'angle qu'il faut
	
	lea alltrajet,a2		; 
	lea sin256,a0
	move.w #256-1,d6		; 256 sinus , on ne peut pas faire de quartsin  64 sinus par quartan
	
.loop4
	lea horizontaltrajet,a1
	move.w (a0)+,d1		; sinus
	moveq #127,d7		; 128 etapes
.loop3
	moveq #0,d0
	move.w (a1)+,d0		
	muls d1,d0
	asl.l #1,d0			;*********
	swap d0				;	
						; a verifier !!!!
	add d0,d0			;  
	add d0,d0			;********
	move.w d0,(a2)+
	moveq #0,d0			;obligatoire ?
	dbf d7,.loop3
	dbf d6,.loop4

settrajzozo	
	lea adrtrajet,a0
	lea horizontaltrajet,a1
	move.l #256,d0				; un sinus trajet = 128 word = 256 octet
	move.l #256*64,d1
	; sin = Y
	; cos= sin(angle+64)
	move.w #256-64-1,d7			; pas le meme 256: nombre d'element d'un cercle complet
.cpy1
	move.l a1,(a0)+			; Y
	lea 64*128*2(a1),a2	; d1 deprecated
	move.l a2,(a0)+			; X
	add d0,a1				; add un angle unité
	dbf d7,.cpy1
	; angle = 3/4 du cercle
	; pour les sinus y ca va on est au 3/4 du cercle
	; pour les sinus x on est arrivé a la fin on revient au debut
	lea horizontaltrajet,a2
	move.w #64-1,d7
.cpy2
	move.l a1,(a0)+
	move.l a2,(a0)+
	add.w d0,a1		; un add.w vers an etend le signe du word dn avant d'ajouter
	add.w d0,a2
	dbf d7,.cpy2
	
	

	move.w #64-1,d7
	; ??
	
	rts
posrandom	dc.l toto					raaaaaah j'ai completement loupé cette routine !!! j'arrette
;poscircularbuffer	dc.w 0
fxinitpartie1
	lea adrtrajet,a2
*	lea toto,a3			; liste d'octet aleatoire
	lea circularbuffer1,a4
	move.w #256*8,d5
	lea poscircularbuffer,a5
	move.l posrandom,a3
fxpartie1

	moveq #0,d0
	move.b (a3)+,d0
	lsl #3,d0
	lea (a2,d0),a6		; a6 = couple sinus Y sinus X
	move.l (a6)+,a0
	move.l (a6)+,a1

	add.w (a5),a4	poscircularbuffer
	move.l a0,(a4)+
	move.l a1,(a4)+
	;
	;
	lea 2048-8(a4),a6			; a6 = accu
	move.l a0,(a6)+
	move.l a1,(a6)+
	
	
	moveq #0,d0
	move.b (a3)+,d0
	lsl #3,d0
	lea (a2,d0),a6		; a6 = couple sinus Y sinus X
	move.l (a6)+,a0
	move.l (a6)+,a1

	move.l a0,(a4)+
	move.l a1,(a4)+
	; 256 point 2 point ajouté par vbl
	; *8  512*4 1024*2
	move.l a0,(a6)+
	move.l a1,(a6)+
	
	move.w (a5),d0

	
	add.w #16,d0
	
	cmp.w d5,d0
	blt.s .ok
	sub.w d5,d0
	; ici on a fait aproximativement 2*128 nombre au hazard

	cmp.l #117*256+toto,a3
	blt.s .ok2
	move.l toto,a3
.ok2
	move.l a3,posrandom
	; ouai c'est tordu, on verra si ca marche
.ok
	move.w d0,(a5)


	; nota on traite 2 point en meme temps
	; donc le buffer circulaire = 2* le nombe de point=(256*2+2)*2
	; enfin je crois
	; 4096+ 8 octet
	rts

initpartie2
; code genere

	lea poscircularbuffer,d0
	lea circularbuffer,a2
	lea gravitytab,a3
	lea centertab,a4
	
bloccg1
	move.l (a2)+,a0
	move.l (a2)+,a1
	
	move.w (a0)+,d0
	add (a3)+,d0
	add (a4)+,d0
	move.l d0,a6
	move.w (a6),d1		y*160 ; eventuellement des subpixel
	move.w (a1)+,d2
	add (a4)+,d2
	move.l d2,a6
	move.w (a6)+,d3
	add d1,d3
	move.w (a6),d4
	move.l d3,a6	; oh my elle est hyper lente cette routine
;
;	or.w d4,(a6)+
;	or.w d4,(a6)+
;	or.w d4,(a6)+
;
	nop
	move.w d4,(a5)+
	nop
	
insdot1
	or.w d4,(a6)+		; 111
	or.w d4,(a6)+
	or.w d4,(a6)+
insdot2
	or.w d4,(a6)+		; 110
	or.w d4,(a6)+
insdot3
	or.w d4,(a6)		; 101
	or.w d4,4(a6)
insdot4
	or.w d4,(a6)		; 100
insdot5
	addq #2,a6
	or.w d4,(a6)+		; 011		; 
	or.w d4,(a6)	
insdot6
	or.w d4,2(a6)		; 010
insdot7
	or.w d4,4(a6)		; 001
pencil
	or.w d4,6(a6)
listinsdot:	dc.l insdot1,insdot2,insdot3,insdot4,insdot5,insdot6,insdot7,pencil

insclear1
	move.l d0,(a6)+
	move.w d0,(a6)
insclear2
	move.l d0,(a6)
insclear3
	move.w d0,(a6)
	move.w d0,4(a6)
insclear4
	move.w d0,(a6)
insclear5
	move.l d0,2(a6)
insclear6
	move.w d0,2(a6)
insclear7
	move.w d0,4(a6)
pencilclear
	move.w d0,6(a6)
listcleardot	dc.l insclear1,insclear2,insclear3,insclear4,insclear5
				dc.l insclear6,insclear7,pencilclear
				

effaceprototype
	move.w (a0)+,d1
	move.l d1,a6
	nop					; nop a remplacer par insclear1 a 7
	
fineffaceprototype
	
; a0 = code genere
; a1 = listeinstdot ou listecleardot
; a2 = effaceprototype ou afficheprototype
; d1 = N entre 0 et 6

genere_CODE1
	lea CODE1,a0
	lea listeinstdot,a1

	move.W #37,d7
	move.w #0,d1
	
	move.W #37,d7
	move.w #1,d1

	move.W #37,d7
	move.w #2,d1

	move.W #37,d7
	move.w #3,d1
	
	move.W #36,d7
	move.w #4,d1

	move.W #36,d7
	move.w #5,d1

	move.W #36,d7
	move.w #6,d1

copyinsdotN
	lea afficheprototype,a2
.w1	move.w (a2)+,d0
	cmp.w #$4e73,d0	; nop ?
	beq.s .fini
	move.w d0,(a0)+
	bra.s .w1
.fini
	add d1,d1
	add d1,d1
	move.l (a1,d1),a3
	move.l 4(a1,d1),a4
	lsr #2,d1
.cpy
	move.w (a3)+,d0
	move.w d0,(a0)+
	cmp.l a3,a4
	bne.s .cpy
	move.w (a2)+,(a0)+		; copie le move.w d4,(a5)+
	rts

copyinsclearN
	lea effaceprototype,a2
	
.w1	move.w (a2)+,d0
	cmp.w #$4e73,d0	; nop ?
	beq.s .fini
	move.w d0,(a0)+
	bra.s .w1
.fini
	add d1,d1
	add d1,d1
	move.l (a1,d1),a2
	move.l 4(a1,d1),a3
	lsr #2,d1
.cpy
	move.w (a2)+,d0
	move.w d0,(a0)+
	cmp.l a2,a3
	bne.s .cpy
	rts
	


makegravitytab:

	moveq #2,d0
	lea gravitytab,a0
	move.w #127,d1
	moveq #0,d2
.loop
	add.w #1,d2
	add d2,d0
	move.w d0,(a0)+

	dbf d1,.loop
	lea -256(a0),a0
	divu #300,d0
	moveq #127,d1
.loop2
	moveq #0,d2
	move.w (a0),d2
	divu d0,d2
	add d2,d2
	add d2,d2
	cmp.w #200*4,d2
	blt.s .1
	; si ca depasse 200 ligne pas la peine d'ajouter du buffer au cliping
	move.w #200*4,d2
.1
	move.w d2,(a0)+
	dbf d1,.loop2
	
clipy
	lea convY,a0
	bsr .rout

	moveq #0,d2
	move.w #199,d7
.loopy
	move.w d2,(a0)+
	addq #4,d2
	dbf d7,.loopy
	bsr .rout
	
.clipx
	lea convX,a0
	bsr .rout2
	
	move.l #$00008000,d2
	move.w #19,d7
.loopx
	move.l d2,(a0)+
	lsr.w #1,d2
	bne.s .loopx
	; d2.w=0
	add.l #$00088000,d2		; additionne 8 a offset , met 8000 dans motif  format: L =  W offset,motif
	cmp.l #160*$10000+$8000,d2
	bne.s .loopx
	
	bsr .rout2
	
	
	
	
	rts
.rout
		move.W #150,d7
		move.w #200*4,d2
.loop3
	move.w d2,(a0)+
	dbf d7,.loop3
	rts

.rout2
	move.w #150,d7
	moveq #0,d2			or #0,0(a0)
.loop4
	move.l d2,(a0)+
	dbf d7,.loop4
	rts
	
	
	


	rts
aleatoire
	move.l #17011,d0   prime1
	move.w #30000-1,d7
	lea toto,a0
.loop

	mulu #14627,d0		prime2
	add.l #18233,d0     prime3
	move.w d0,d1
	add.l #$466,d1
	lsr #8,d1
	move.b d1,(a0)+
	dbf d7,.loop
	jmp analyseoccurence
	rts

	BSS
toto	ds.b 30000
	TEXT
analyseoccurence
	lea tab256,a0
	lea toto,a1
	move.w #30000-1,d7
.loop
	moveq #0,d0
	move.b (a1)+,d0
	add.w d0,d0
	addq #1,(a0,d0)
	dbf d7,.loop
	; test concluant sur les occurence de nombre
	rts
tab256	ds.w 256


	BSS
adresse128	ds.w 128		; buffer temporaire


horizontaltrajet	ds.w 128		; trajet de depart qui va etre 
									; decliné en 512 angle * 128 etape *2= 128k ouch  x,y separé
adrtrajet	ds.l 2*256				;tuple (adrY,adrX) de trajet au sein de alltrajet
alltrajet	ds.w 256*128
gravitytab	ds.l 1
convX
convY

	DATA
sinus	incbin 'ssin512.ata'	; signed 512 valeur		fichier a faire


