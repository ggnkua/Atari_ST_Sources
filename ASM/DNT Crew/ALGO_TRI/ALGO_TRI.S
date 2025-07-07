;                 Routines de tris pour le DNT-Paper #3
;                       (C)oderight NulloS//DNT
;
; Les routines ci-dessous sont celles qui ont ‚t‚ utilis‚s pour les tests
;de performance relev‚s et analys‚s dans l'article correspondant du DP3.
;Les originaux ‚taient en Turbo Pascal, mais comme ce langage est pas
;trŠs r‚pandu sur ST (logique !), et que rien ne vaut le 68000, les voici
;en assembleurs.Les algorithmes sont comment‚s dans ce source (assez somai-
;rement, mais faut pas d‚conner non plus: on est pas des bˆtes).
;
; Les routines manipulent des entiers, mais sans grandes modifications elles
;peuvent manipuler des formats autres (octets ou structures complexes).
;A vous de les adapter … vos besoins.Ensuite les tableaux sont ind‚x‚s sous
;la forme 0...n-1 pour un tableau de taille n.Ensuite,n<32768 imp‚rativement,
;sinon les indexs partent au choux (si vous voulez augmenter cette limite,
;il faut utiliser des mots-longs comme index de tableau, il n'y a qu'a changer
;quelques .w en .l dans le source....… vous de jouer...certains sont d‚j… en
; .l … cause de l'utilisation des offsets mots).
;
;Quand je dis "en offset mots", cela veut dire que la valeur n'est plus un
;indice du tableau (qui est ind‚pendant de ce qu'il y a dans le tableau)
;mais un d‚placement m‚moire (qui d‚pend de ce qui est dans le tableau).
;C'est donc offset=indice*taille_element_tableau
;Ici c'est 2 pour des mots, ca serait 4 pour des mots longs (style pointeurs
;de structures..).J'ai gard‚ un adressage de type d(an,dn) pour acc‚der au
;tableau (bien que souvent on aurait pu employer des (an) et (an)+ ),
;pour ne pas trop gener la lecture, et pour pouvoir modifier ces routines
;par la suite sans se prendre la tˆte.
;
; Faites gaffe au QuickSort: j'ai limit‚ au maximum le passage des paramŠtres
;sur la pile pendant la r‚currence, mais pass‚ une certaine taille du tableau
;l'empilement des r‚currences devient tel que la pile explose tout sur son
;passage.La solution est alors de prendre le QuickSort-Seuil et de fixer le
;seuil assez haut (les performances baissent mais ca marche).Ou d'utiliser le
;QuickSort avec recherche de pivot (il d‚g‚nŠre trŠs peu, donc moins de risque
;d'exploser la pile..Et en plus il est (un poil) plus rapide)
;

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)

	lea	tableau(pc),a0
	move.l	#20000,d0
	move.l	#$fff,d1
	bsr.s	genere_tab

	move.l	$4ba.w,d7
	bsr	QuickSort_PSeuil
	sub.l	$4ba.w,d7
	neg.l	d7
	move.l	d7,$200.w
	
	bsr.s	verifie_tableau

	trap	#1
	clr.w	-(sp)
	trap	#1

;;;;;;;;;;;;;;;;;G‚n‚ration d'un tableau de nombre;;;;;;;;;;;;;;;;;;;;;;;
;Appel: A0=tableau , D0=n , D1=ctrl
;n est le nombre d'‚l‚ment du tableau (donc 2*n octets)
;ctrl=....-1 pour ordre inverse
;     .... 0 pour ordre
;     .... X pour RND(X) (X doit ˆtre de la forme (2^p)-1)
;
genere_tab
	movem.l	d0-4/a0-3,-(sp)	;protŠge les registres
	movea.l	a0,a3		;Random (BIOS) modifie les
	move.l	d0,d3		;registres D0-2/A0-2,donc
	move.l	d1,d4		;faut les changer de place
	beq.s	gen_ordre		;
	bmi.s	gen_ordre_inverse	;
gen_rnd	move.w	#17,-(sp)		;Random
	trap	#14		;
	addq.l	#2,sp		;
	and.l	d4,d0		;Modulo
	move.w	d0,(a3)+		;
	subq.l	#1,d3		;suivant
	bne.s	gen_rnd		;
gen_end	movem.l	(sp)+,d0-4/a0-3	;
	rts			;

gen_ordre	move.w	d4,(a3)+		;generation ordre
	addq.w	#1,d4		;simple,non ?
	subq.l	#1,d3		;
	bne.s	gen_ordre		;
	bra.s	gen_end		;

gen_ordre_inverse			;magik !
	move.w	d3,(a3)+		;
	subq.l	#1,d3		;
	bne.s	gen_ordre_inverse	;
	bra.s	gen_end		;

;;;;;;;;;; V‚rifie que le tableau est class‚ dans l'ordre ;;;;;;;;;;;;;;;
;A0=tableau; D0=taille
;L'ordre v‚rifi‚ est celui donn‚ les deux premiŠres valeurs du tableau
;E HEAPSORT DONNE UN ORDRE DECROISSANT...alors que les autres donnent
;un ordre croissant.
verifie_tableau
	movem.l	d0-2/a0,-(sp)	;
	move.w	(a0),d1		;
	move.l	d0,d2		;
	add.l	d2,d2		;
	cmp.w	-2(a0,d2.l),d1	;Prend les 2 extr‚mit‚ du tableau
	blt.s	vft2_start		;=>d‚duit l'ordre obtenu
	bra.s	vft1_start		;
vft1_bcl	move.w	(a0)+,d1		;
	cmp.w	(a0),d1		;
	blt.s	vft_erreur		;
vft1_start	subq.l	#1,d0		;
	bne.s	vft1_bcl		;
	bra.s	vft_ok		;

vft2_bcl	move.w	(a0)+,d1		;
	cmp.w	(a0),d1		;
	bgt.s	vft_erreur		;
vft2_start	subq.l	#1,d0		;
	bne.s	vft2_bcl		;

vft_ok	pea	ok_mess(pc)	;Ca roule,mec
vft_end	move.w	#9,-(sp)		;
	trap	#1		;Cconws
	move.w	#7,(sp)		;Puis Crawcin
	trap	#1		;
	addq.l	#6,sp		;
	movem.l	(sp)+,d0-2/a0	;
	rts			;

vft_erreur	pea	bug_mess(pc)	;damned,problŠme
	bra.s	vft_end		;

ok_mess	dc.b	"Tableau correctement tri‚ !.",$a,$d,$0
bug_mess	dc.b	"Tableau mal tri‚...Y'a comme un bug ?!?",$a,$d,$0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Shell 9531 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse tableau D0=taille tableau

S9_data	dc.w	9,5,3,1,0

Shell_9531
	movem.l	d0-a1,-(sp)	;
	lea	S9_data(pc),a1	;
	move.w	(a1)+,d2		;D2=ecart de d‚part (9)
S9_bcl0	moveq	#0,d1		;1er ‚l‚ment
S9_bcl1	bsr.s	Shell_Insert	;trier sous-tableau
	addq.w	#1,d1		;sous-tableau suivant
	cmp.w	d2,d1		;dernier atteint ?
	blt.s	S9_bcl1		;non
	move.w	(a1)+,d2		;‚cart suivant
	bne.s	S9_bcl0		;
	movem.l	(sp)+,d0-a1	;
	rts			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Shell Insert ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse tableau; D0=taille tableau; D1=d‚but du sous-tableau; D2=‚cart
;L'algorithme est exactement le mˆme que le tri par insertion, seulement on
;tri une tranche du tableau (la tranche est le sous-tableau compos‚ des
;‚l‚ments D1+k*D2)
Shell_Insert
	cmpi.w	#1,d0		;tableau … un ‚l‚ment (!) ?
	bne.s	*+4		;non
	rts			;si !,cassos
	movem.l	d0-7,-(sp)		;
	moveq	#0,d6		;init les bits forts
	moveq	#0,d5		;des registres pour les
	moveq	#0,d3		;d‚placement longs
	move.w	d1,d3		;i=debut
	move.w	d1,d4		;j=debut
	move.w	d2,d7		;
	add.w	d7,d7		;2*ecart (offset pour mots)
	bra.s	SI_start		;d‚but la boucle

SI_bcl0	move.w	d4,d5		;
	add.w	d2,d5		;
	add.w	d5,d5		;
	move.w	0(a0,d5.l),d5	;b=Tab[j+ecart]
SI_bcl1	cmp.w	0(a0,d3.l),d5	;Si b<=Tab[i]
	bgt.s	SI_void		;
	move.w	d3,d6		;alors Tab[i+ecart]=Tab[i]
	add.w	d7,d6		;      Tab[i]=b
	move.w	0(a0,d3.l),0(a0,d6.l)	;
	move.w	d5,0(a0,d3.l)	;
	sub.w	d7,d3		;      i=i-ecart
	bgt.s	SI_bcl1		;
SI_void	add.w	d2,d4		;      j=j+ecart
	move.w	d4,d3		;      i=j
SI_start	add.w	d3,d3		;2*i=offset pour des mots
	move.w	d0,d5		;
	sub.w	d2,d5		;
	cmp.w	d5,d4		;Tant que j<(n-ecart)
	blt.s	SI_bcl0		;
SI_end	movem.l	(sp)+,d0-7		;
	rts			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Shell Suite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse tableau, D0=taille tableau
;
Shell_Suite
	movem.l	d0-d7,-(sp)	;
	move.l	#0,d1		;
	divu	#9,d1		;
	moveq	#1,d2		;calcule les termes de la suite
ShS_calc	move.w	d2,d3		;X[n+1]=3*X[n]+1
	add.w	d2,d2		;
	add.w	d3,d2		;
	addq.w	#1,d2		;
	cmp.w	d1,d2		;On s'arrete pour X[n]>(m/9)
	ble.s	ShS_calc		;C'est l'‚cart de d‚but

ShS_bcl0	moveq	#0,d1		;1er sous-tableau
ShS_bcl1	bsr.s	Shell_Insert	;on le traite
	addq.w	#1,d1		;sous-tableau suivant
	cmp.w	d2,d1		;il existe ?
	blt.s	ShS_bcl1		;oui..
	swap	d2		;
	clr.w	d2		;efface les bits 16-31 pour
	swap	d2		;la division
	divu	#3,d2		;h=h/3
	bne.s	ShS_bcl0		;h>0 ? => continuer
	movem.l	(sp)+,d0-d7	;
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Shell N/2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse tableau; D0=taille tableau
;
Shell_N2	movem.l	d0-d7,-(sp)	;
	move.w	d0,d2		;
	lsr.w	#1,d2		;ecart de d‚part= n/2
SN2_bcl0	moveq	#0,d1		;1er sous-tableau
SN2_bcl1	bsr	Shell_Insert	;on le classe partiellement
	addq.w	#1,d1		;sous-tableau suivant
	cmp.w	d2,d1		;dernier atteint ?
	blt.s	SN2_bcl1		;non
	lsr.w	#1,d2		;si, divise l'‚cart par deux
	bne.s	SN2_bcl0		;si pas encore fini...
	movem.l	(sp)+,d0-d7	;
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;; QuickSort … Seuil ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse tableau; D0=taille tableau
;
QuickSort_Seuil
	movem.l	d0-7,-(sp)		;on lance la r‚currence
	move.w	d0,d1		;du quicksort
	moveq	#0,d0		;en pr‚cisant les deux bornes
	subq.w	#1,d1		;du 1er tableau	
	moveq	#0,d2		;initialise les registres
	moveq	#0,d3		;pour les adressages d(An,Dn.L)
	moveq	#0,d4		;
	bsr.s	Sort_Seuil		;
	movem.l	(sp)+,d0-7		;
	rts

;A0=adresse tableau; D0=Left ;D1=Right
;Il n'y a pas de sauvegardes de registres dans le corps de la routine,
;car lors des 2 appels de r‚currence … la fin, seul le premier impose
;de sauver certains registres.Le dernier est tout … fait … la fin,
;donc il n'y a rien derriŠre !.
Sort_Seuil
	move.w	d1,d2		;regarde si le seuil de rapidit‚
	sub.w	d0,d2		;est atteint.
	cmpi.w	#16,d2		;Alors ?
	ble	Insertion_Partielle	;oui,phase d'insertion normale
	move.w	d0,d4		;x=Tab[(l+r)/2]
	add.w	d1,d4		;
	andi.w	#-2,d4		;((l+r)/2)*2 pour offset mots
	move.w	0(a0,d4.l),d4	;Hop,D4=x
	add.w	d0,d0		;on pr‚multiplie par 2 pour les
	add.w	d1,d1		;offsets de mots
	move.w	d0,d2		;i=l
	move.w	d1,d3		;j=r
SoS_bcl0	cmp.w	0(a0,d2.l),d4	;x>Tab[i] ?
	ble.s	SoS_bcl1		;non,arrˆte d‚placement pivot
	addq.w	#2,d2		;si, d‚place le pivot:i=i+1
	bcc.s	SoS_bcl0		;hop

SoS_bcl1	cmp.w	0(a0,d3.l),d4	;x<Tab[j] ?
	bge.s	SoS_tst2		;non,arrˆte d‚placement pivot	
	subq.w	#2,d3		;si, fait le reculer
	bcc.s	SoS_bcl1		;hop
	
SoS_tst2	cmp.l	d3,d2		;au bout du compte, i<=j ?
	bgt.s	SoS_tst3		;non,‡a marche
	move.w	0(a0,d2.l),d5	:si,il faut faire l'‚change
	move.w	0(a0,d3.l),0(a0,d2.l)	;Tab[i]<=>Tab[j]
	move.w	d5,0(a0,d3.l)	;
	addq.w	#2,d2		;i=i+1    (+2 pour offset mots)
	subq.w	#2,d3		;j=j-1    (-2 ""    ""     "" )
	bra.s	SoS_bcl0		;

SoS_tst3	lsr.w	#1,d0		;repasse les 4 offsets
	lsr.w	#1,d1		;i,j,l,r  en indices
	lsr.w	#1,d2		;
	lsr.w	#1,d3		;
	cmp.w	d3,d0		;l<j ?
	bge.s	SoS_tst4		;non (‚vite les tableaux unit‚)
	move.w	d1,-(sp)		;protŠge les deux indices
	move.w	d2,-(sp)		;i et r pendant la r‚currence
	move.w	d3,d1		;Sort_Seuil(l,j)
	bsr.s	Sort_Seuil		;
	move.w	(sp)+,d0		;reprend les registres en les
	move.w	(sp)+,d1		;redistribuant tout de suite
SoS_tst4	cmp.w	d0,d1		;r>i ?
	ble.s	SoS_end		;non
	bsr.s	Sort_Seuil		;Sort_Seuil(i,r)
SoS_end	rts

;;;;;;;;;;;;;;;;;; QuickSort … Seuil et recherche de pivot ;;;;;;;;;;;;;;;
;A0=adresse tableau; D0=taille tableau
;
QuickSort_PSeuil
	movem.l	d0-7,-(sp)		;on lance la r‚currence
	move.l	d0,d1		;du quicksort
	moveq	#0,d0		;en pr‚cisant les deux bornes
	subq.w	#1,d1		;du 1er tableau	
	moveq	#0,d2		;initialise les registres
	moveq	#0,d3		;pour les adressages d(An,Dn.L)
	moveq	#0,d4		;
	bsr.s	Sort_PSeuil	;
	movem.l	(sp)+,d0-7		;
	rts

;A0=adresse tableau; D0=Left ;D1=Right
;Il n'y a pas de sauvegardes de registres dans le corps de la routine,
;car lors des 2 appels de r‚currence … la fin, seul le premier impose
;de sauver certains registres.Le dernier est tout … fait … la fin,
;donc il n'y a rien derriŠre !.
Sort_PSeuil
	move.w	d1,d2		;regarde si le seuil de rapidit‚
	sub.w	d0,d2		;est atteint.
	cmpi.w	#16,d2		;Alors ?
	ble	Insertion_Partielle	;oui,phase d'insertion normale

	lsr.w	#3,d2		;un huitiŠme de la taille
	add.w	d0,d0		;on pr‚multiplie par 2 pour les
	add.w	d1,d1		;offsets de mots
	add.w	d2,d2		;on prend 8 ‚l‚ments dans le
	moveq	#0,d5		;sous-tableau actuel,
	move.w	d0,d3		;on les additionne sauvagement
	move.w	0(a0,d3.l),d4	;(attention,add avec mots-longs
	ext.l	d4		;=>‚tend le signe
	REPT	7		;… cause des d‚bordements)
	add.w	d2,d3		;
	move.w	0(a0,d3.l),d5	;
	ext.l	d5		;
	add.l	d5,d4		;
	ENDR			;
	asr.l	#3,d4		;et ca donne un pivot m‚dian
	move.w	d0,d2		;i=l
	move.w	d1,d3		;j=r
SoPS_bcl0	cmp.w	0(a0,d2.l),d4	;x>Tab[i] ?
	ble.s	SoPS_bcl1		;non,arrˆte d‚placement gauche
	addq.w	#2,d2		;si, d‚place la gauche:i=i+1
	bcc.s	SoPS_bcl0		;hop

SoPS_bcl1	cmp.w	0(a0,d3.l),d4	;x<Tab[j] ?
	bge.s	SoPS_tst2		;non,arrˆte d‚placement droite	
	subq.w	#2,d3		;si, d‚place la droite:j=j-1
	bcc.s	SoPS_bcl1		;hop
	
SoPS_tst2	cmp.l	d3,d2		;au bout du compte, i<=j ?
	bgt.s	SoPS_tst3		;non,‡a marche
	move.w	0(a0,d2.l),d5	:si,il faut faire l'‚change
	move.w	0(a0,d3.l),0(a0,d2.l)	;Tab[i]<=>Tab[j]
	move.w	d5,0(a0,d3.l)	;
	addq.w	#2,d2		;i=i+1    (+2 pour offset mots)
	subq.w	#2,d3		;j=j-1    (-2 ""    ""     "" )
	bra.s	SoPS_bcl0		;

SoPS_tst3	lsr.w	#1,d0		;repasse les 4 offsets
	lsr.w	#1,d1		;i,j,l,r  en indices
	lsr.w	#1,d2		;
	lsr.w	#1,d3		;
	cmp.w	d3,d0		;l<j ?
	bge.s	SoPS_tst4		;oui
	move.w	d1,-(sp)		;protŠge les deux indices
	move.w	d2,-(sp)		;i et r pendant la r‚currence
	move.w	d3,d1		;Sort_PSeuil(l,j)
	bsr	Sort_PSeuil	;
	move.w	(sp)+,d0		;reprend les registres en les
	move.w	(sp)+,d1		;redistribuant tout de suite
SoPS_tst4	cmp.w	d0,d1		;r>i ?
	ble.s	SoPS_end		;non
	bsr	Sort_PSeuil	;Sort_PSeuil(i,r)
SoPS_end	rts

;;;;;;;;;;;;;;;;;;;;;;;;;; Insertion partielle ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=adresse tableau; D0=a=d‚but partie … trier; D1=b=fin partie … trier
;C'est un bˆte tri par insertion, mais il ne traite qu'un intervalle
;pr‚cis du tableau.
Insertion_Partielle
	movem.l	d0-d4,-(sp)	;
	add.w	d0,d0		;passage en offset de mots
	add.w	d1,d1		;
	moveq	#0,d2		;pr‚pare les registres pour les
	moveq	#0,d3		;adressages d(An,Dn.L)
	move.w	d0,d3		;j=a
	subq.w	#2,d0		;d=d-1
	bra.s	IP_start		;d‚marrer la boucle
IP_bcl0	move.w	2(a0,d3.l),d4	;2 car offset mot.x=Tab[j+1]
IP_bcl1	cmp.w	0(a0,d2.l),d4	;b<=Tab[i] ?
	bgt.s	IP_next		;non,fin de remont‚e
	move.w	0(a0,d2.l),2(a0,d2.l)	;si, continue d'ins‚rer
	move.w	d4,0(a0,d2.l)	;
	subq.w	#2,d2		;i=i-1 :un de plus !
	cmp.w	d2,d0		;i=d-1 ?
	bne.s	IP_bcl1		;oui, insertion continue
IP_next	addq.w	#2,d3		;j=j+1
IP_start	move.w	d3,d2		;i=j
	cmp.w	d3,d1		;j<m ?
	bne.s	IP_bcl0		;oui, continuer classement
	movem.l	(sp)+,d0-4
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HeapSort it‚ratif ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;A0=tableau; D0=taille du tableau
;Je ne donne pas de source pour la version r‚cursive, bicoze c'est pas
;interessant (plus lent, et plus de m‚moire prise par la r‚cursivit‚).
;C'est le seul tri … supporter d'embl‚e plus de 32768 ‚l‚ments par tableau
;
HeapSort	bsr.s	Heap1		;construit l'arbre Heap
	bsr.s	Heap2		;classe le Heap
	rts			;

Heap1	move.l	d1,-(sp)		;
	move.l	d0,d1		;
	lsr.l	#1,d1		;
Heap1_bcl	bsr.s	Descente		;
	subq.l	#1,d1		;
	bne.s	Heap1_bcl		;
	move.l	(sp)+,d1		;
	rts			;

Heap2	movem.l	d0-3,-(sp)		;
	moveq	#1,d1		;
	move.l	d0,d2		;
	add.l	d2,d2		;
Heap2_bcl	move.w	(a0),d3		;
	move.w	-2(a0,d2.l),(a0)	;
	move.w	d3,-2(a0,d2.l)	;
	subq.l	#2,d2		;
	subq.w	#1,d0		;
	bsr.s	Descente		;
	cmpi.l	#2,d0		;
	bne.s	Heap2_bcl		;
	move.w	(a0),d0		;
	move.w	2(a0),(a0)		;
	move.w	d0,2(a0)		;
	movem.l	(sp)+,d0-3		;
	rts			;

Descente	movem.l	d0-4,-(sp)		;D0=n D1=j A0=tableau
	add.l	d1,d1		;D3=divers  D4=planque
	move.w	-2(a0,d1.l),d4	;planque=Tab[j]
	move.l	d1,d2		;(^- l'‚l‚ment … descendre)
	add.l	d2,d2		;D2=l=2*j (<- son fils)
	add.l	d0,d0		;n en offset de mot
D_bcl0	cmp.l	d0,d2		;Tant que l<=n 
	bgt.s	D_fin		;(donc un fils existe)
	beq.s	D_bcl1		;Si l<n
	move.w	-2(a0,d2.l),d3	;alors y'a deux fils
	cmp.w	2-2(a0,d2.l),d3	;  ...
	ble.s	D_bcl1		;  Si Tab[l]>Tab[l+1]
	addq.l	#2,d2		;  alors l=l+1
D_bcl1	move.w	-2(a0,d2.l),d3	;(on a pris le plus petit)
	cmp.w	-2(a0,d1.l),d3	;
	bge.s	D_fin		;Si Tab[j]>Tab[l]
	move.w	d3,-2(a0,d1.l)	;alors Tab[i]=Tab[l]
	move.w	d4,-2(a0,d2.l)	;      Tab[l]=planque
	move.l	d2,d1		;      j=l
	add.l	d2,d2		;      l=2*l
	bcc.s	D_bcl0		;ne pas d‚passer le tableau !
;On a permut‚ l'‚l‚ment j et son fils l.Il devient donc l, et son 1er
;fils est 2*l.On recommence jusqu'… la fin de la descente (cad quand il
;n'y a plus de fils, ou des fils plus grand)
D_fin	movem.l	(sp)+,d0-4		;
	rts			;

	SECTION	BSS
tableau	ds.w	32767