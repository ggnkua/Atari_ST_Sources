; Version 68030 du RadixSort.
;
;Par rapport au 68000, cette version utilise les raffinements du
;020/030 en matiŠre d'adressage, ce qui permet de simplifier
;certaines manips et d'‚conomiser des d‚calages.
;De plus, on peut modifier la taille des ‚l‚ments du tableau
;pour s'adapter aux diff‚rentes tailles de donn‚es (par exemple,
;travailler sur un tableau avec r=8), chose rigoureusement
;impossible en 68000 (il faudrait faire de lourdes modifications
;pour passer de l'un … l'autre).
;
;(C)oderight NulloS/DNT-Crew 1993.
;
	include	hard_sys.s		;
	include	tos_030.s		;
Taille	equ	250000		;Nombre d'‚l‚ments
Tz	equ	4		;Taille d'un ‚l‚ment tableau

	StartUp			;D‚marrage classique
	clr.l	-(sp)		;
	Gemdos	Super		;
	move.l	d0,-(sp)		;

	lea	tableau,a6		;
	move.l	#Taille,d6		;
	move.l	#$31415926,d0	;Remplissage pip“t du
fill	mulu.w	#49891,d0		;tableau. Pour une utilisation
	asr.l	#8,d0		;avec les valeurs cl‚es des
	addq.l	#1,d0		;normale, il faut le remplir
	move.l	d0,(a6)+		;structures que vous triez.
	subq.l	#1,d6		;
	bne.s	fill		;

	move.l	#Taille,d0		;
	moveq	#Tz,d1		;El‚ment du tableau = 4 octets
	lea	tableau+Tz-1,a0	;->adresse du poids faible = +3
	lea	resultat,a1	;
	move.l	_hz_200.w,d7	;
	bsr.s	RadixSort		;Vroom
	sub.l	_hz_200.w,d7	;
	neg.l	d7		;

	lea	tableau,a0		;
	move.l	(a0,d1.l*Tz),d0	;
	moveq	#0,d3		;Compte le nombre de lectures
verifie	addq.l	#1,d3		;..une de plus !
	move.l	d0,d2		;
	move.l	(a1,d1.l*4),d1	;suivant !
	bmi.s	fini		;
	move.l	(a0,d1.l*Tz),d0	;Lire la donn‚e
	cmp.l	d2,d0		;
	bge.s	verifie		;teste la croissance.
bug	bra.s	*		;<-gag!
fini	cmpi.l	#Taille,d3		;
	bne.s	bug		;
	Gemdos	Super		;
	Gemdos	Pterm0		;
;Pour vous, il faudrait bien sur consulter votre table de structures
;au lieu de la table des valeurs (aucun int‚rˆt !).


;Entr‚e: A0=tableau, D0=taille, A1=chainage r‚sultat, D1= largeur de case
;Sortie: ----------, ---------, --------------------, D1= premier maillon
;
;Attention, A0 ne contient pas l'adresse de l'‚l‚ment 0, mais l'adresse
;de l'octet 0 
;
;En entr‚e, D1 contient la taille d'une case du tableau, cad de combien
;d'octets il faut avancer pour passer de l'‚l‚ment [i] … l'‚l‚ment [i+1].
;
RadixPass	MACRO	t1,t2,sens,status	;Grosse macro:boucle principale
	subq.l	#1,a0		;Octet suivant
	moveq	#-1,d0		;
	moveq	#256/4-1,d1	;
	lea	\2(pc),a2		;
init\@	move.l	d0,(a2)+		;for (i=0 ; i<256 ; i++)
	move.l	d0,(a2)+		;	tete2[i]=-1;
	move.l	d0,(a2)+		;
	move.l	d0,(a2)+		;
	dbf	d1,init\@		;Selon le sens de progression
	IFEQ	'\3'-'+'		;de k (cf l'article),
	lea	\1+0(pc),a1	;on construit t2=\1 … partir
	lea	\1+256*4(pc),a3	;de t1=\2, dans le sens
	lea	\2(pc),a2		;croissant (-> arrˆt en +256*4,
for\@	move.l	(a1)+,d1		;lecture incr‚mentale).
				;<=> for (k=0 ; k<256 ; k++)
	ELSE
	lea	\1+256*4(pc),a1	;Sinon dans le sens d‚croissant
	lea	\1+0(pc),a3	;donc depuis +256*4 vers +0
	lea	\2(pc),a2		;
for\@	move.l	-(a1),d1		;...et lecture d‚cr‚mentale.
				;<=> for (k=255 ; k>=0 ; k--)
	ENDC
	bmi.s	while\@		;if ( t1[k]<>-1 )
do\@	moveq	#0,d2		;do { /*i=t1[k] aprŠs ce test*/
	move.b	(a0,d1.l*Tz),d2	;  j=tableau[i]
	IFEQ	'\4'-'stop'	;
	eori.b	#$80,d2		;si octet r-1, EOR &80;
	ENDC			;
	move.l	(a4,d1.l*4),d3	;  l=resultat[i];
	move.l	(a2,d2.l*4),(a4,d1.l*4);  resultat[i]=m=t2[j];
	IFEQ	'\4'-'stop'	;/*Si dernier passage*/
	bpl.s	*+6		;  if (m==-1)
	move.l	d1,(a5,d2.l*4)	;    queue[j]=i;
	ENDC			;
	move.l	d1,(a2,d2.l*4)	;  t2[j]=i;
	move.l	d3,d1		;  i=l;
	bpl.s	do\@		;} while (i<>-1);
while\@	cmpa.l	a3,a1		;/*Test du for, aprŠs le while:*/
	bne.s	for\@		;boucle finie<=>k:valeur finale
	ENDM


RadixEnd	MACRO	t2,sens		;Macro normale:‚tape finale
	IFEQ	'\2'-'+'		;
	lea	\1+0(pc),a1	;Si sens k croissant
	lea	\1+256*4(pc),a3	;alors lecture depuis 
	moveq	#-4,d0		;k=-1
look\@	addq.l	#4,d0		;
	move.l	(a1)+,d7		;while t2[++k]==-1
	bmi.s	look\@		;premier=t2[k]
ifyes\@	move.l	a1,a6		;for (k=premier ; k<256 ; k++)
whil\@	cmpa.l	a1,a3		;/*ici t2[k]<>-1 !!*/
	beq.s	fork\@		;while (j<256)
	move.l	(a1)+,d1		;/*le j++ est planqu‚ ici*/
	bmi.s	whil\@		;if (t2[j]<>-1)
	move.l	(a5,d0.l),d2	;         queue[k]
	move.l	d1,(a4,d2.l*4)	;resultat[        ]=t2[j]
	add.l	a1,d0		;
	sub.l	a6,d0		;k=j-1, suivant !
	bra.s	ifyes\@		;
fork\@
	ELSE
	lea	\1+256*4(pc),a1	;Si sens k d‚croissant
	lea	\1+0(pc),a3	;alors lecture depuis 
	moveq	#256*4,d0		;k=256
look\@	subq.l	#4,d0		;
	move.l	-(a1),d7		;while t2[--k]==-1
	bmi.s	look\@		;premier=t2[k]
ifyes\@	move.l	a1,a6		;for (k=premier ; k>=0 ; k--)
whil\@	cmpa.l	a1,a3		;/*ici t2[k]<>-1 !!*/
	beq.s	fork\@		;while (j>=0)
	move.l	-(a1),d1		;/*le j-- est planqu‚ ici*/
	bmi.s	whil\@		;if (t2[j]<>-1)
	move.l	(a5,d0.l),d2	;         queue[k]
	move.l	d1,(a4,d2.l*4)	;resultat[        ]=t2[j]
	add.l	a1,d0		;
	sub.l	a6,d0		;k=j+1, suivant !
	bra.s	ifyes\@		;
fork\@
	ENDC
	ENDM

RadixSort	movem.l	d0-a6,-(sp)	;La routine proprement dite!.
	lea	tete1(pc),a2	;
	moveq	#-1,d0		;
	moveq	#256/4-1,d2	;for (i=0 ; i<256 ; i++)
rs_init0	move.l	d0,(a2)+		;  tete1[i]=-1;
	move.l	d0,(a2)+		;
	move.l	d0,(a2)+		;D‚boucl‚, cela va plus vite.
	move.l	d0,(a2)+		;
	dbf	d2,rs_init0	;
	moveq	#0,d2		;for (i=0 ;..........)
	move.l	(sp),d3		;
	lea	tete1(pc),a2	;
rs_pass0	moveq	#0,d0		;
	move.b	(a0),d0		;  j=tableau[i] AND &FF
	move.l	(a2,d0.l*Tz),(a1)+	;resultat[i]=tete1[j];
	move.l	d2,(a2,d0.l*4)	;tete1[j]=i;
	addq.l	#1,d2		;for (..........; i++)
	adda.l	d1,a0		;Element suivant
	cmp.l	d2,d3		;
	bne.s	rs_pass0		;for (....; i<n ;....)
	
	movem.l	32(sp),a0/a4	;Installe tableau et resultat
	lea	queue(pc),a5	;ainsi que queue
	RadixPass	tete1,tete2,+,next	;2 ‚tapes principales
	RadixPass	tete2,tete1,-,stop	;
	RadixEnd	tete1,+		;Lier 256 listes en une seule.
	move.l	d7,4(sp)		;Renvoyer 'premier' dans D1
	movem.l	(sp)+,d0-a6	;
	rts			;
;Ceci est un tri r=3 croissant.  Donc on commence par une RadixPass
;croissante (+), puis une RadixPass d‚croissante (-) et terminale (stop).
;Et enfin on termine par une liaison croissante '+'. Modifiez les trois
;+ - + dans les trois appels de macro, en - + -. Vous obtiendrez un tri
;d‚croissant !.
;A ce dernier rajoutez une RadixPass tete1,tete2,-,stop (la pr‚c‚dente
;devenant une simple next) avant la RadixEnd qui devient
;RadixEnd tete2,+ : vous obtiendrez un tri croissant pour r=4...
;Inversez les signes, il devient d‚croissant.. Comprendo ?
;
;Dans le cas le plus d‚lirant, style r=8 tri croissant, alors cela donnera:
;RadixPass tete1,tete2,-,next
;RadixPass tete2,tete1,+,next
;RadixPass tete1,tete2,-,next
;RadixPass tete2,tete1,+,next
;RadixPass tete1,tete2,-,next
;RadixPass tete2,tete1,+,next
;RadixPass tete1,tete2,-,stop
;RadixEnd  tete2,+
;
;Facile, non?
tete1	dcb.l	256,0		;Ne pas les oublier...
tete2	dcb.l	256,0		;
queue	dcb.l	256,0		;

	section	bss
tableau	ds.b	Taille*Tz
resultat	ds.l	Taille
stack	ds.b	1024