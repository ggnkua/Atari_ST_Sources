;
; Affichage de 3D faces pleines
; By DUMBO - XXeme siecle
;

	OPT	p=68030
	FOPT	id=2
	OPT	x+
	OUTPUT	"3DPLEIN.PRG"

	TEXT


; Essai de la routine d'affichage
; d'un polygone

	move.w	#$20,-(sp)		; Bah on passe en superviseur
	trap	#1		; mˆme si ‡a sert … rien pour l'instant
	addq.l	#2,sp
	move.w	#3,-(sp)		; R‚cupŠre adresse ‚cran logik
	trap	#14
	addq.l	#2,sp
	move.l	d0,ecrlog
	lea.l	qsdfgh,a2
	lea.l	xypoly,a1
	move.l	a1,a0
	REPT	6
	move.l	(a2)+,(a1)+
	ENDR
;	bsr	init_polyblitter
	move.w	#4,d0
	move.w	#$07E0,couleur_poly	; Vert au d‚part
	move.w	#$fff,d0		; 4096 affichages
loooop:	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#4,d0
	bsr	polygone
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	addq.w	#1,couleur_poly
	dbra	d0,loooop
	move.w	#7,-(sp)		; On admire puis on maltraite le clavier
	trap	#1
	clr.w	(sp)
	trap	#1		; Zou!! J'suis plus l…...


; Pr‚-calcul de la table sinus-cosinus
; En FP 80 bits
; Angles : de 0 a 512 (2PI) - 1
; utilisation du coprocesseur arithmetik 68881/2

calctabsincos:
	move.w	#511,d0		; d0 = compteur boucle
	clr.l	d1		; d1 = angle
	fmovecr	#0,fp1
	fmove.w	#512,fp0
	fdiv	fp0,fp1
	lea.l	table_sincos,a0	; a0 pointe sur le debut de la table
caltasico_b1:
	fmove.w	d1,fp0
	fmul	fp1,fp0
	fsincos	fp0,fp2:fp3
	fmove	fp2,(a0)+		; Sinus
	fmove	fp3,(a0)+		; Cosinus
	addq.w	#1,d1
	dbra	d0,caltasico_b1



; Calcul de differentes valeurs pour
; un angle donn‚.
; En entr‚e :
;    d0 = angle x (0-511)
;    d1 = angle y (0-511)
;    d2 = angle z (0-511)
;    table_sincos
; Renvoie :
;    9 variables dans valeurs_angle
; Modifie : d0-d3/a0-a1/fp0-fp7

init_angle:
	lea.l	valeurs_angle,a0	; a0 pointe sur le tableau de valeurs
	lea.l	table_sincos,a1	; a1 pointe sur la table de sin/cos
	lsl.w	#1,d0
	move.w	d0,d3
	lsl.w	#2,d0
	add.w	d3,d0		; d0 = d0 * 10
	fmove.x	0(a1,d0.w),fp0	; FP0 = cos ax
	fmove.x 10(a1,d0.w),fp1	; FP1 = sin ax
	lsl.w	#1,d1
	move.w	d1,d3
	lsl.w	#2,d1
	add.w	d3,d1
	fmove.x	0(a1,d1.w),fp2	; FP2 = cos ay
	fmove.x	10(a1,d1.w),fp3	; FP3 = sin ay
	lsl.w	#1,d2
	move.w	d2,d3
	lsl.w	#2,d2
	add.w	d3,d2
	fmove.x	0(a1,d2.w),fp4	; FP4 = cos az
	fmove.x	10(a1,d2.w),fp5	; FP5 = sin az
; A
	fmove.x	fp2,fp6
	fmul.x	fp4,fp6
	fmove.x	fp6,(a0)+
; D
	fmove.x	fp1,fp7
	fmul.x	fp3,fp7
	fmul.x	fp4,fp7
	fmove.x	fp5,fp6
	fmul.x	fp0,fp6
	fsub.x	fp6,fp7
	fmove.x	fp7,(a0)+
; G
	fmove.x	fp0,fp7
	fmul.x	fp3,fp7
	fmul.x	fp4,fp7
	fmove.x	fp5,fp6
	fmul.x	fp1,fp6
	fadd.x	fp6,fp7
	fmove.x	fp7,(a0)+
; B
	fmove.x	fp5,fp6
	fmul.x	fp1,fp6
	fmove.x	fp6,(a0)+
; E
	fmove.x	fp1,fp6
	fmul.x	fp3,fp6
	fmul.x	fp5,fp6
	fmove.x	fp0,fp7
	fmul.x	fp4,fp7
	fadd.x	fp6,fp7
	fmove.x	fp7,(a0)+
; H
	fmove.x	fp0,fp7
	fmul.x	fp3,fp7
	fmul.x	fp5,fp7
	fmove.x	fp1,fp6
	fmul.x	fp4,fp6
	fsub.x	fp6,fp7
	fmove.x	fp7,(a0)+
; C
	fmove.x	fp3,fp6
	fneg.x	fp6
	fmove.x	fp6,(a0)+
; F
	fmove.x	fp2,fp6
	fmul.x	fp1,fp6
	fmove.x	fp6,(a0)+
; I
	fmove.x	fp1,fp6
	fmul.x	fp0,fp6
	fmove.x	fp6,(a0)+
	rts


; Calcul des nouvelles coordonn‚es
; spatiales d'un point
; En entr‚e :
;    a0 = xs
;    a1 = xdep
;    valeurs_angle
; En sortie :
;    FP4,FP5,FP6 nouvelles coordonn‚es du point
; Utilis‚s :
;    FP1-FP3(r‚utilisables)/FP4-FP7/a0-a2

transforme_space:
	lea.l	valeurs_angle,a2
	fmove.x	(a0)+,fp1		; FP1 = xs
	fmove.x	(a0)+,fp2		; FP2 = ys
	fmove.x	(a0)+,fp3		; FP3 = zs
; Calcul de nxs
	fmove.x	fp1,fp4
	fmul.x	(a2)+,fp4
	fmove.x	fp2,fp5
	fmul.x	(a2)+,fp5
	fadd.x	fp5,fp4
	fmove.x	fp3,fp5
	fmul.x	(a2)+,fp5
	fadd.x	fp5,fp4
	fadd.x	(a1)+,fp4		; FP4 = nouvel x spatial
; Calcul de nys
	fmove.x	fp1,fp5
	fmul.x	(a2)+,fp5
	fmove.x	fp2,fp6
	fmul.x	(a2)+,fp6
	fadd.x	fp6,fp5
	fmove.x	fp3,fp6
	fmul.x	(a2)+,fp6
	fadd.x	fp6,fp5
	fadd.x	(a1)+,fp5		; FP5 = nouvel y saptial
; Calcul de nzs
	fmove.x	fp1,fp6
	fmul.x	(a2)+,fp6
	fmove.x	fp2,fp7
	fmul.x	(a2)+,fp7
	fadd.x	fp7,fp6
	fmove.x	fp3,fp7
	fmul.x	(a2)+,fp7
	fadd.x	fp7,fp6
	fadd.x	(a1)+,fp6		; FP6 = nouvel z spatial
	rts


; Transforme des coordonn‚es spatiales
; en coordonn‚es planes
; En entr‚e :
;    FP4, FP5 et FP6 contiennent les coordon‚es spatiales
;    a0 = xpl
;    pfuite
; En sortie :
;    xpl, ypl coordonn‚es planes

space_to_plane:
	fmove.b	#1,fp0
	fmove.x	pfuite,fp7
	fdiv.x	fp7,fp6
	fsub.x	fp6,fp0		; FP0 = focale
	fdiv.x	fp0,fp4
	fdiv.x	fp0,fp5
	fmove.w	fp4,(a0)+
	fmove.w	fp5,(a0)+
	rts


; Affichage d'un polygone
; * Superviseur *
; En entr‚e :
;    d0 = nombre - 1 de pts par polygone
;    a0 = xypoly : tableau des coo. des pts du poly
;    ecrlog, couleur_poly
; En sortie :
; Utilis‚s :
;    d0-d7/a0-a4
;    ymin, ymax, xminmax, xypoly, couleur_poly
;    ligne

polygone:
; Recherche les ordonn‚es min et max du polygone
	move.w	2(a0,d0.w*4),d1	; Init min et max de y : last point
	move.w	d1,d2
	move.w	d0,d4
	subq.w	#1,d4
poly_b1:	move.w	2(a0,d4.w*4),d3	; prend y du point
	cmp.w	d1,d3
	ble.s	poly_s1		; Passe si y <= ymax
	move.w	d3,d1
poly_s1:	cmp.w	d2,d3
	bge.s	poly_s4		; Passe si y => ymin
	move.w	d3,d2
poly_s4:	dbra	d4,poly_b1
	tst.w	d2		; Tests ymin et ymax trop grands
	bge.s	poly_s2
	clr.w	d2
poly_s2:	cmp.w	#199,d1
	ble.s	poly_s3
	move.w	#199,d1
poly_s3:	move.w	d1,ymax
	move.w	d2,ymin
	sub.w	d2,d1
	move.l	#$7FFF8000,d2	; C'est pour l'init. du
	lea.l	xminmax,a1		; tableau xmin et max
poly_b3:	move.l	d2,(a1)+
	dbra	d1,poly_b3
	lea.l	xminmax,a1
poly_b2:	move.w	(a0,d0.w*4),d1
	move.w	2(a0,d0.w*4),d2
	move.w	4(a0,d0.w*4),d3	; D‚termine les coordonn‚es x min et max
	move.w	6(a0,d0.w*4),d4	; pour chaque ligne entre deux points
	bsr	ligne		; du polygone
	dbra	d0,poly_b2
; Affichage
	move.w	ymin,d0		; d0 et d1 ordonn‚es xtrŠmes du polygone
	move.w	ymax,d1
	move.w	#319,d3		; Abscisse maximum
	lea.l	xminmax,a1		; a1 pointe sur la table xminmax
	move.l	ecrlog,a2		; a2 sur la m‚moire ‚cran
	move.w	d0,d4
	ext.l	d4
	mulu.w	#640,d4		; 640 octets par ligne en 65536 couleurs
	add.l	d4,a2		; a2 = adresse de la premiere ligne … afficher
	move.l	#640,d4
	sub.w	d0,d1		; d1 = nombre - 1 de lignes … afficher
; Affichage sans blitter
	move.w	couleur_poly,d5	; d5 contient la couleur d'affichage
	clr.l	d6		; d6 est vid‚ pour les add.l avec des mots
aff_poly_b1:			; Affichage d'une ligne
	move.l	a2,a3		; On garde a2 d‚but de ligne courante
	move.w	(a1)+,d6		; d6 et d7 abscisses d‚but et fin de
	move.w	(a1)+,d7		; la ligne
	cmp.w	d3,d7
	blt.s	afp_s1
	move.w	d3,d7		; d7 = MIN (xmax,d7)
afp_s1:	tst.w	d6
	bge.s	afp_s2
	clr.w	d6		; d6 = MAX (0,d6)
afp_s2:	sub.w	d6,d7		; d7 = longueur de la ligne … afficher
	add.w	d6,d6		; d6 = abscisse d‚but de ligne * 2
	add.l	d6,a3		; a3 = adresse du d‚but de la ligne
afp_b1:	move.w	d5,(a3)+		; Affiche les d7+1 points d'une ligne
	dbra	d7,afp_b1
	add.l	d4,a2		; Ligne suivante
	dbra	d1,aff_poly_b1
	rts
; Affichage avec blitter
; Bah en True Color c'est plus lent...
;	lea.l	couleur_poly,a3
;	lea.l	$ff8a32,a4
;	move.l	a3,-14(a4)
;	move.w	#$c000,d0
;	move.w	#1,d5
;	clr.l	d6
;aff_poly_b1:
;	move.l	a2,a3
;	move.w	(a1)+,d6
;	move.w	(a1)+,d7
;	cmp.w	d3,d7
;	blt.s	afp_s1
;	move.w	d3,d7
;afp_s1:	tst.w	d6
;	bge.s	afp_s2
;	clr.w	d6
;afp_s2:	sub.w	d6,d7
;	addq.w	#1,d7
;	add.w	d6,d6
;	add.l	d6,a3
;	move.l	a3,(a4)
;	move.w	d7,4(a4)
;	move.w	d5,6(a4)
;	move.w	d0,10(a4)		; Lancement du blitter
;	add.l	d4,a2
;	dbra	d1,aff_poly_b1
;	rts


; Recherche des x min et max pour chaque ligne situ‚e entre
; 2 points donn‚s. Proc‚dure normalement appel‚e par polygone
; En entr‚e :
;    d0 : num‚ro du point (x1,y1) dans le polygone
;    d1,d2 : coordonn‚es point 1
;    d3,d4 : coordonn‚es point 2
;    a0 = xypoly
;    a1 = xminmax
;    ymin, ymax
; En sortie :
;    xminmax
; Utilis‚s :
;    d0-d7/a0-a2
;    ymin, xminmax

ligne:
	cmp.w	d1,d3		; Cas particuliers
	beq	l_verti		; x1 = x2 ?
	cmp.w	d2,d4
	beq	l_horiz		; y1 = y2 ?
	move.w	d3,d6		; d6 = x2
	sub.w	d1,d3		; d3 = |x2-x1|
	bpl.s	li_s1
	neg.w	d3
li_s1:	move.l	#4,d5		; d5 est l'incr‚ment pour le d‚placement...
	sub.w	d2,d4		; d4 = |y2-y1|
	bpl.s	li_s2
	neg.w	d4
	neg.l	d5		; d5 = SGN(y2-y1) * 4   ...dans le tableau
li_s2:	move.w	d4,d7		; d7 = |y2-y1|
	exg	d6,d3		; d3 = x2
	sub.w	d1,d3		;    = x2-x1
	swap	d3		;    = (x2-x1)*$10000
	clr.w	d3
	ext.l	d4
	divs.l	d4,d3		; d3 = (x2-x1)*$10000/|y2-y1|
	swap	d1		; d1 = x1*$10000
	clr.w	d1
	sub.w	ymin,d2		; d2 = y1-ymin
	bpl.s	liy_s3
	neg.w	d2		; Si y1-ymin < 0
	cmp.w	#0,d5
	ble	liy_fin		; Sortie si y2-ymin < y1-ymin < 0
	sub.w	d2,d4
	bmi	liy_fin		; Sortie si y1-ymin < y2-ymin < 0
	muls.w	d3,d2
	add.l	d2,d1
	clr.l	d2
	bra.s	liy_s4
liy_s3:	cmp.w	#199,d2		; y1-ymin > 199 ?
	ble.s	liy_s4
	tst.w	d5
	bge	liy_fin		; Sortir si 199 < y1-ymin < y2-ymin
	sub.w	#199,d2
	sub.w	d2,d4
	bmi	liy_fin		; Sortir si 199 < y2-min < y1-min
	muls.w	d3,d2
	add.l	d2,d1
	move.w	#199,d2
liy_s4:	cmp.w	#199,d4
	ble.s	liy_s5
	move.w	#199,d4
liy_s5:	lea.l	(a1,d2.w*4),a2
	cmp.w	d6,d7
	blt	ligne_x		; si |x2-x1| > |y2-y1|

; Trac‚ de ligne suivant y
liy_b1:
	move.l	d1,d6
	swap	d6
	cmp.w	(a2),d6
	bge.s	liy_s1		; Passe si x => xmin
	move.w	d6,(a2)
liy_s1:	cmp.w	2(a2),d6
	ble.s	liy_s2		; Passe si x <= ymax
	move.w	d6,2(a2)
liy_s2:	add.l	d5,a2
	add.l	d3,d1
	dbra	d4,liy_b1
liy_fin:	rts

; Trac‚ d'une ligne suivant x
ligne_x:
	move.l	d1,d6
	swap	d6
lix_b1:	cmp.w	(a2),d6
	bge.s	lix_s1
	move.w	d6,(a2)
lix_s1:	add.l	d3,d1
	move.l	d1,d6
	swap	d6
	cmp.w	2(a2),d6
	ble.s	lix_s2
	move.w	d6,2(a2)
lix_s2:	add.l	d5,a2
	dbra	d4,lix_b1
	rts

l_verti:
	move.w	#4,d5
	sub.w	d2,d4		; d4 = y2 - y1
	bpl.s	lv_s3
	neg.w	d4
	neg.w	d5
lv_s3	sub.w	ymin,d2		; d2 = y1 - ymin
	lsl.w	#2,d2
lv_loop:	cmp.w	(a1,d2.w),d1
	bge.s	lv_s1		; passe si x1 => xmin
	move.w	d1,(a1,d2.w)
lv_s1:	cmp.w	2(a1,d2.w),d1
	ble.s	lv_s2		; passe si x1 <= xmax
	move.w	d1,2(a1,d2.w)
lv_s2:	add.w	d5,d2
	dbra	d4,lv_loop
	rts

l_horiz:
	sub.w	ymin,d2
	lea.l	(a1,d2.w*2),a2
	cmp.w	(a2),d1
	bge.s	lh_s1		; passe si x1 => xmin
	move.w	d1,(a2)
lh_s1:	cmp.w	(a2),d3
	bge.s	lh_s2		; passe si x2 => xmin
	move.w	d3,(a2)
lh_s2:	addq.l	#2,a2
	cmp.w	(a2),d1
	ble.s	lh_s3		; passe si x1 <= xmax
	move.w	d1,(a2)
lh_s3:	cmp.w	(a2),d3
	ble.s	lh_s4		; passe si x2 <= xmax
	move.w	d3,(a2)
lh_s4:	rts



; Initialisation du blitter avant
; l'affichage des polygones
; (En True Color = plus lent)
; Inutilis‚
; * Superviseur *

init_polyblitter:
	clr.w	$ff8a20		; Incr‚ment source hor.
	clr.w	$ff8a22
	move.w	#2,$ff8a2e		; Incr‚ment dest. hor.
	move.w	#$ffff,$ff8a2a	; Masque
	move.w	#$203,$ff8a3a	; Pas de demi-teinte
	rts





	DATA

qsdfgh:	DC.w	160,50,110,50,110,100	; Ca c'est un polygone d'essai
	DC.w	135,150,210,100,160,50

	BSS

table_sincos:	DS.b	10240	; Table de 512 cosinus et de sinus
valeurs_angle:	DS.b	90	; 9 valeurs pour un angle
xs:	DS.b	10		; Coordonn‚es spatiales du point
ys:	DS.b	10
zs:	DS.b	10
xdep:	DS.b	10		; Coordonn‚es de deplacement
ydep:	DS.b	10
zdep:	DS.b	10
pfuite:	DS.b	10		; Point de fuite
xpl:	DS.w	1		; Coordonn‚es planes du point
ypl:	DS.w	1

ecrlog:	DS.l	1		; Adresse de l'‚cran logique
xypoly:	DS.w	128		; 64 (maxi) x et y de chaque point.
; Le premier point devra ˆtre recopi‚ … la fin du polygone. Ce point
; supl‚mentaire n'est pas compt‚ dans nbbpts
ymin:	DS.w	1		; ymin d'un polygone
ymax:	DS.w	1
xminmax:	DS.w	400		; xmin et xmax pour 200 lignes
couleur_poly:	DS.w	1	; Couleur du polygone
