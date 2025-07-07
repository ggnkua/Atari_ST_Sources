;Routine assembleur 68000 du tri Radix Sort.
;
;Cette routine est donn‚e en exemple de l'article Guerre de triage
;du DNT-Paper 6. Elle est adapt‚e aux nombres SIGNES, pour r entre 2
;et 4, pour une taille d'un ‚l‚ment du tableau de 4 octets, et pour
;un tableau de taille quelconque (donc index sur 32 bits).
;
;Avec elle, ainsi que les explications donn‚es dans l'article, vous
;devriez normalement ˆtre capables de vous faire votre propre routine
;RadixSort pour tous les cas possibles.
;
;Je pr‚cise qu'elle n'est pas optimis‚e … fond: le but du jeu est
;d'avoir une routine globale que l'on adapte … chaque cas pr‚cis
;(tableaux de moins de 32768 ‚l‚ments, etc...).
;
;Dernier d‚tail: j'ai sacrifi‚ … la lisibilit‚, en utilisant des
;macros. Elles rendent le source moins agr‚ables, mais permettent
;de modifier facilement les paramŠtres du tri.
;
;
;(C)oderight NulloS/DNT-Crew 1993.
;
	include	hard_sys.s		;
	include	tos_030.s		;
Taille	equ	250000		;Nombre d'‚l‚ments

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
	moveq	#4,d1		;El‚ment du tableau = 4 octets
	lea	tableau+3,a0	;->adresse du poids faible = +3
	lea	resultat,a1	;
	move.l	_hz_200.w,d7	;
	bsr.s	RadixSort		;Vroom
	sub.l	_hz_200.w,d7	;
	neg.l	d7		;->TEMPS EN 1/200 SECONDE

	lea	tableau,a0		;
	move.l	(a0,d1.l),d0	;
	moveq	#0,d3		;Compte le nombre de lectures
verifie	addq.l	#1,d3		;..une de plus !
	move.l	d0,d2		;
	move.l	(a1,d1.l),d1	;suivant !
	bmi.s	fini		;
	move.l	(a0,d1.l),d0	;Lire la donn‚e
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
	move.b	(a0,d1.l),d2	;  j=tableau[i]
	IFEQ	'\4'-'stop'	;
	eori.b	#$80,d2		;si octet r-1, EOR &80;
	ENDC			;
	lsl.w	#2,d2		;/*passage en offset*/
	move.l	(a4,d1.l),d3	;  l=resultat[i];
	move.l	(a2,d2.l),(a4,d1.l)	;  resultat[i]=m=t2[j];
	IFEQ	'\4'-'stop'	;/*Si dernier passage*/
	bpl.s	*+6		;  if (m==-1)
	move.l	d1,(a5,d2.l)	;    queue[j]=i;
	ENDC			;
	move.l	d1,(a2,d2.l)	;  t2[j]=i;
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
	move.l	d1,(a4,d2.l)	;resultat[        ]=t2[j]
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
	move.l	d1,(a4,d2.l)	;resultat[        ]=t2[j]
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
	lsl.l	#2,d3		;n*4=passage en offset m‚moire
	lea	tete1(pc),a2	;
rs_pass0	moveq	#0,d0		;
	move.b	(a0),d0		;  j=tableau[i] AND &FF
	lsl.w	#2,d0		;/*passage en offset*/
	move.l	(a2,d0.l),(a1)+	;resultat[i]=tete1[j];
	move.l	d2,(a2,d0.l)	;tete1[j]=i;
	addq.l	#4,d2		;for (..........; i++)
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
tete1	dcb.l	256,0		;Ne pas les oublier...
tete2	dcb.l	256,0		;
queue	dcb.l	256,0		;

	section	bss
tableau	ds.l	Taille
resultat	ds.l	Taille
stack	ds.b	1024