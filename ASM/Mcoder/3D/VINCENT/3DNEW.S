****************************************************************************
*					*
*	Routines d'affichage et de calcul d'objets 3d,	*
*		en d‚veloppement.		*
*  #[ Commentaires:				*
*					*
*	(C) V.Penne, J.C.Meyrignac, C.Levastre		*
*					*
*	Am‚liorations :			*
*					*
*	- tri optimaux pour 2,3,4,(5) objets (et meme jusqu'a 8)	*
*	- routines en move.l pour les petits objets		*
*	- affichage 1 plan de l'objet le plus ‚loign‚	*
*	- degager les objets dont le z est trop n‚gatif	*
*	- routines d'addition et suppression d'objets	*
*	- gestion des collisions			*
*					*
*  #] Commentaires:				*
****************************************************************************




;  #[ Equates & starting:
	jmp	start

	dc.b	"3D ROUT (C) Copyright HIGHSPEED 1991, "
	dc.b	"C. Levastre - J.C. Meyrignac - V. Penn‚.",0
	even

	opt	x+,o-

TRUE	=	-1	pour les flags
FALSE	=	0

vbl_count	=	$465	adresse compteur vbl
vbl_gestion	=	$469	flag gestion des objets
AFFCPU	=	FALSE
NBSINUS	=	1024
DISTEC	=	5	= 32 (decalage << 1)

MAXOBJECT	=	64
MAXDECORS	=	64


CLIPSIZE	=	4096
NBLINE	=	200
NBPOINTS	=	256
CIRCLESIZE	=	1024
CIRCLEMARGE	=	CIRCLESIZE-NBLINE
MIX	=	0	; Fenetre de clipping
MIY	=	0
MAX	=	320-1
MAY	=	NBLINE-1
CX	=	320/2

VIEWPOINTDIST	=	512
VIEWPOINTOBS	=	512	;distance entre l'observateur
			;et le view point

VIEWMAXZ	=	1512
VIEWMINZ	=	-1512
VIEWEXTY	=	1500
VIEWEXTX	=	1500


	SECTION	TEXT

*************************************************************
*	Programme principal :		*
*				*
*	- Basse resolution		*
*	- Sauvegarde de la palette		*
*	- Installation nouvelle vbl		*
*				*
*************************************************************

start:
	move.l	4(sp),a3
	move.l	#mystack,sp
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)

	clr	-(sp)		reserve
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	clr.l	-(sp)		superviseur
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,userstack
	move.b	$ffff8260.w,sys_res	resolution

	move	#$25,-(sp)
	trap	#14
	addq	#2,sp
	clr.b	$ffff8260.w

	move.l	$44e.w,d0		adresse ecran
	move.l	d0,sys_screen

	move.l	d0,scr1
	move.l	#screen2,d0		adresse des ecrans
	add.l	#255,d0
	clr.b	d0
	move.l	d0,scr2
	add.l	#32000,d0
	move.l	d0,scr3
	add.l	#32000,d0
	move.l	d0,scr4
	add.l	#32000,d0
	move.l	d0,scr5
	add.l	#32000,d0
	move.l	d0,scr6

	lea	$ffff8240.w,a0
	lea	sys_palette,a1
	jsr	copy8l(pc)		sauve la palette courante

	move.l	a0,a1		installe nouvelle palette
	lea	palette,a0
	jsr	copy8l(pc)

	move.l	$70.w,sys_vbl
	lea	newvbl(pc),a0
	move.l	a0,$70.w

	clr.b	vbl_gestion
	
	lea	8.w,a1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,oldbomb
	move.l	a7,oldstack
	tst.b	(a1)	; Monst?
	beq.s	.nobomb
	lea	fin(pc),a0
	REPT	8
	move.l	a0,(a1)+
	ENDR
.nobomb:
	lea	rte(pc),a0		div 0
	move.l	a0,$14.w


	jsr	main(pc)

fin:
	move	#$2700,sr
	move.l	oldstack,a7
	movem.l	oldbomb,d0-d7
	movem.l	d0-d7,$8.w
	
	move.l	sys_vbl,$70.w
	move	#$2300,sr

	lea	sys_palette,a0
	lea	$ffff8240.w,a1
	jsr	copy8l(pc)		restore la palette courante

	move	#$25,-(a7)
	trap	#14
	addq	#2,a7
	
	move.b	sys_res,$ffff8260.w
	
	move	#-1,-(sp)		resolution d'origine
	move.l	sys_screen,-(sp)	et ecran d'origine
	move.l	sys_screen,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	userstack,-(sp)	mode utilisateur
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
bye
	clr	-(sp)		fin du programme
	move	#$4c,-(sp)
	trap	#1

rte	rte
copy8l	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts

*************************************************************
*	MACRO de swapping des 2 ecrans	*
*************************************************************

Swapper	MACRO
.swapwait
	tst.b	vbl_count
	beq.s	.swapwait
	clr.b	vbl_count
	lea	scr1,a0
	movem.l	(a0)+,d0/d1/d2/d3/d4/d5
	move.l	d0,d6
	movem.l	d1/d2/d3/d4/d5/d6,-(a0)
	lsr	#8,d5
	move.l	d5,$ffff8200.w
	ENDM

;  #] Equates & starting:
;  #[ Main:

*************************************************************
*	Programme principal		*
*************************************************************

main
	move.l	usp,a0		;sauve usp
	move.l	a0,-(sp)

	sf	qrepeat
	jsr	init3d(pc)		;init clipping x et couleurs
	jsr	genfastcls(pc) 	;genere routine effacement
.repeat
	jsr	ffastcls(pc)
;	move	#$700,$ffff8240.w
	jsr	calcmatrix(pc) 	;calcul matrice principale
;	st	plante
	jsr	calcviewpoint(pc)
	movem	viewpoint(pc),d0-d2
	movem	d0-d2,listobject+OBJ_x
	jsr	projobject(pc) 	;mise en table des objets visibles
	clr	plante
;	move	#$007,$ffff8240.w
	jsr	sortobjects(pc)	;tri des objets par z croissant
;	move	#$000,$ffff8240.w
	jsr	affobjects(pc) 	;affichage des objets tri‚s


	addq	#1,compteurimage
	Swapper

	tst.b	qrepeat
	beq.s	.repeat
	move.l	(sp)+,a0
	move.l	a0,usp
	rts
plante
	dc.w	0
	
qrepeat	dc.b	FALSE
	even

;  #] Main:
;  #[ Clavier:
; ----------------- Routine clavier	
test_clav:	
	move.b	$fffffc02.w,d0
	cmp.b	#$4b,d0
	bne.s	.notgauche
	addq	#4,OBS_vroty
	rts
.notgauche:
	
	cmp.b	#$4d,d0
	bne.s	.notdroite
	subq	#4,OBS_vroty
	rts
.notdroite:

	cmp.b	#$48,d0
	bne.s	.notavant
	addq	#8,OBS_v
	rts
.notavant:
	cmp.b	#$50,d0
	bne.s	.notarr
	subq	#8,OBS_v
	rts
.notarr:
	cmp.b	#$39,d0
	bne.s	.nospace
	st	qrepeat
	rts
.nospace:
	rts
;  #] Clavier:
;  #[ Multi objet:

	; #[ Structures des objets:
	
		;#[ Structure d'un objet anim‚:

	RSRESET

OBJ_asm	rs.l	1	routine d'animation
OBJ_buffer	rs.b	16
OBJ_x	rs	1	x,y,z pour affichage
OBJ_y	rs	1
OBJ_z	rs	1
OBJ_projx	rs.l	1	px,py,pz
OBJ_projy	rs.l	1
OBJ_projz	rs	1
OBJ_vblrotx	rs	1	rotations en vbl
OBJ_vblroty	rs	1
OBJ_vblrotz	rs	1
OBJ_rotx	rs	1	rotation en affichage
OBJ_roty	rs	1
OBJ_rotz	rs	1
OBJ_vbldata	rs.l	1	adresse data objet
OBJ_vblanim	rs	1	offset d'animation
OBJ_data	rs.l	1	adresse data affichage
OBJ_size	rs	0

		;#] Structure d'un objet anim‚:
		;#[ Structure d'un decors:

	RSRESET
DEC_x	rs	1
DEC_y	rs	1
DEC_z	rs	1
DEC_projx	rs.l	1
DEC_projy	rs.l	1
DEC_projz	rs	1
DEC_data	rs.l	1
DEC_size	rs	0

		;#] Structure d'un decors:

	; #] Structures des objets:
	; #[ Animation en VBL:

		;#[ Vbl:
*************************************************************
*	routine vbl			*
*************************************************************

compteurvbl	dc.w	50
nombreimage	dc.w	0
compteurimage	dc.w	0

vblstop:
	movem.l	(a7)+,d0-a6
	clr	$ffff8240.w
	rte
newvbl:
	movem.l	d0-a6,-(sp)

	IFNE	AFFCPU
	subq	#1,compteurvbl
	bgt.s	pas50vbl
	move	#50,compteurvbl
	move	compteurimage(pc),nombreimage
	clr	compteurimage
pas50vbl

	move.l	scr6,a0
	addq	#2,a0
	move	nombreimage(pc),d0
	add	d0,d0
	add	d0,d0
	jmp	zeroa99(pc,d0.w)
zeroa99
	incbin	'zeroa99.bin'
	ENDC

	tst	plante
	beq.s	suite
	not.l	$ffff8242.w
	not.l	$ffff8246.w
	not.l	$ffff824a.w
	not.l	$ffff824e.w
	not.l	$ffff8252.w
	not.l	$ffff8256.w
suite
	move	#$777,$ffff8240.w
	addq.b	#1,vbl_count		;syncronisation des ‚crans
	not.b	vbl_gestion		;=0 toute les 2 vbls
	bne.s	vblstop		;si 0 alors gestion des objets et du clavier
	
;	movem.l	d0-d7/a0-a6,-(sp)	;sauvegarde de tous les registres
				;1 seule fois quel que soit le nombre
				;d'objets	 
	jsr	test_clav(pc)
	lea	nbobject(pc),a0	;pointe sur d‚but structure objet
	move	(a0)+,d0		;lecture du nombre d'objets
	subq	#1,d0
	blt.s	vblfin		;si 0 objets -> fin
vblnextobj
	move.l	(a0)+,a2		;adresse routine de gestion de l'objet
	jmp	(a2)		;lancement routine de gestion.
vblfin
	movem.l	(sp)+,d0-d7/a0-a6	;restauration des registres
	rte

Nextobject	MACRO
	dbf	d0,vblnextobj		;un autre objet ?
	movem.l	(sp)+,d0-d7/a0-a6
	clr	$ffff8240.w
	rte
	ENDM

; pas de gestion
		;#] Vbl:
		;#[ ani_dummy:
ani_dummy				;exemple de routine de gestion des objets
	lea	OBJ_size-OBJ_buffer(a0),a0	;passe … l'objet suivant
	Nextobject
		;#] ani_dummy:
		;#[ ani_rebond:
; objet avec rebond (hauteur d‚termin‚e par le z initial)

ani_rebond
	move	(a0),d1		;r‚cuperation vz
	subq	#1,d1		;vz=vz-1
	move	OBJ_z-OBJ_buffer(a0),d2	;r‚cup‚ration z
	add	d1,d2		;z=z+dz
	bgt.s	.okzsup0
	move	#20,d1		;inversion du vz
	clr	d2		;z=0
.okzsup0
	move	d2,OBJ_z-OBJ_buffer(a0)	;restocke le z
	move	d1,(a0)
	lea	OBJ_size-OBJ_buffer(a0),a0	;passe … l'objet suivant
	Nextobject
		;#] ani_rebond:
		;#[ ani_rxyz1:
; objet avec rotation X,Y,Z

ani_rxyz1
;	add	#32,OBJ_vblrotx-OBJ_buffer(a0)	;r‚cuperation vz
	add	#32,OBJ_vblroty-OBJ_buffer(a0)
;	add	#32,OBJ_vblrotz-OBJ_buffer(a0)
	lea	OBJ_size-OBJ_buffer(a0),a0	;passe … l'objet suivant
	Nextobject

		;#] ani_rxyz1:
		;#[ ani_rxyz2:
ani_rxyz2
;	add	#32,OBJ_vblrotx-OBJ_buffer(a0)	;r‚cuperation vz
	add	#32,OBJ_vblroty-OBJ_buffer(a0)
	add	#32,OBJ_vblrotz-OBJ_buffer(a0)
	lea	OBJ_size-OBJ_buffer(a0),a0	;passe … l'objet suivant
	Nextobject

		;#] ani_rxyz2:
		;#[ ani_rxyz3:
ani_rxyz3
	add	#32,OBJ_vblrotx-OBJ_buffer(a0)	;r‚cuperation vz
	add	#32,OBJ_vblroty-OBJ_buffer(a0)
	add	#32,OBJ_vblrotz-OBJ_buffer(a0)
	lea	OBJ_size-OBJ_buffer(a0),a0	;passe … l'objet suivant
	Nextobject

		;#] ani_rxyz3:
		;#[ ani_animate (??):
; objet anim‚ cycliquement

ani_animate
	move.l	OBJ_vbldata-OBJ_buffer(a0),a1 ;adresse des datas
	move	OBJ_vblanim-OBJ_buffer(a0),d1 ;offset animation
	addq	#2,d1		;passe anim suivante
	add	d1,a1		;adresse offset anim
	tst	(a1)		;lecture offset anim
	bge.s	.continue
	clr	d1		;retour 1ere anim
.continue
	move	d1,OBJ_vblanim-OBJ_buffer(a0) ;stocke offset anim
	lea	OBJ_size-OBJ_buffer(a0),a0	;passe … l'objet suivant
	Nextobject
		;#] ani_animate (??):

	; #] Animation en VBL:
	; #[ Calcul position des objets:

*************************************************************
*				*
*  calcul de la matrice principale / observateur	*
*				*
*************************************************************


sx	equr	d2
cx	equr	d3
sy	equr	d4
cy	equr	d5
sz	equr	d6
cz	equr	d7


calcmatrix:
	lea	sincos(pc),a0

	move	#NBSINUS*4-1,d1

	move	OBS_rotx(pc),d0
	add	OBS_vrotx(pc),d0
	move	d0,OBS_rotx
	neg	d0
	and	d1,d0
	movem	(a0,d0.w),sx/cx	sin x / cos x

	move	OBS_roty(pc),d0
	add	OBS_vroty(pc),d0
	move	d0,OBS_roty
	neg	d0
	and	d1,d0
	movem	(a0,d0.w),sy/cy	sin y / cos y

	move	OBS_rotz(pc),d0
	add	OBS_vrotz(pc),d0
	move	d0,OBS_rotz
	neg	d0
	and	d1,d0
	movem	(a0,d0.w),sz/cz	sin z / cos z



	lea	mainmatrix(pc),a0



	move	cx,d1
	muls	sz,d1
	move	sx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	cz,d0
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+		12:

	move	sx,d0
	muls	cy,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+		14: sx * cy

	move	cx,d1
	muls	cz,d1
	move	sx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	sz,d0
	sub.l	d0,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a0)+



	move	cy,d0
	muls	cz,d0		
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+		0: cy * cz

	move	sy,(a0)+		2: sy

	move	cy,d0		
	muls	sz,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a0)+		4: - cy * sz

	move	sx,d1
	muls	sz,d1		sx * sz		
	move	cx,d0
	muls	sy,d0		cx * sy
	add.l	d0,d0
	swap	d0		6: (sx * sz) - (cx * sy * cz)
	muls	cz,d0		
	sub.l	d0,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a0)+

	move	cx,d0		8: cx * cy
	muls	cy,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	

	move	sx,d1
	muls	cz,d1
	move	cx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	sz,d0
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+		10:

	rts
mainmatrix
	ds.w	9


;
; calcul du viewpoint en face de l'observateur
;

calcviewpoint
	lea	sincos(pc),a0	
	lea	OBS_rotx(pc),a1
	movem	(a1),d1/d2/d3
	
	clr	d4
	clr	d5
	move	#VIEWPOINTOBS,d6
	
	move.l	(a0,d1.w),d0
	move	d0,d1
	muls	d6,d1
	swap	d0
	move	d5,d7
	muls	d0,d7
	add.l	d7,d1
	muls	d0,d6
	swap	d0
	muls	d0,d5
	sub.l	d6,d5
	neg.l	d5
	move.l	d1,d6
	add.l	d5,d5
	swap	d5
	add.l	d6,d6
	swap	d6

	move.l	(a0,d2.w),d0
	move	d0,d1
	muls	d4,d1
	swap	d0
	move	d6,d7
	muls	d0,d7
	add.l	d7,d1
	muls	d0,d4
	swap	d0
	muls	d0,d6
	sub.l	d4,d6
	move.l	d1,d4
	add.l	d6,d6
	swap	d6
	add.l	d4,d4
	swap	d4

	move.l	(a0,d3.w),d0
	move	d0,d1
	muls	d5,d1
	swap	d0
	move	d4,d7
	muls	d0,d7
	add.l	d7,d1
	muls	d0,d5
	swap	d0
	muls	d0,d4
	sub.l	d5,d4
	neg.l	d4
	move.l	d1,d5
	add.l	d4,d4
	swap	d4
	add.l	d5,d5
	swap	d5
	
	
	movem	d4/d5/d6,viewpoint
	
	rts


*************************************************************
*				*
*  routine de projection des objets		*
*				*
*************************************************************

projobject
	clr	nbvobject
	lea	nbobject(pc),a0
	lea	tadrobj(pc),a1 	;table des adresses
	move	(a0)+,d0		;nb obj actifs
	subq	#1,d0
	bge.s	objrepeat
objinvisible				
	lea	OBJ_size-(OBJ_projx-OBJ_x)(a0),a0
	dbf	d0,objrepeat2
projobjfin
	rts
objrepeat
	lea	OBJ_x(a0),a0
objrepeat2
	lea	viewpoint(pc),a2	;adr viewpoint.xyz
	movem	(a0)+,d4/d5/d6 	;xyz

	move	d4,d1		;xyz
	move	d5,d2
	move	d6,d3

	;calcul / viewpoint

	sub	(a2)+,d4		;calcul approx
	bge.s	.neg1		;distance / viewpoint
	neg	d4		;valeur absolue
.neg1
	sub	(a2)+,d5
	bge.s	.neg2
	neg	d5		;valeur absolue
.neg2
	sub	(a2)+,d6
	bge.s	.neg3
	neg	d6		;valeur absolue
.neg3
	add	d5,d4		;somme dx,dy,dz
	add	d6,d4
	cmp	#VIEWPOINTDIST,d4	;distance trop grande ?
	bgt.s	objinvisible		;objet non visible

	*----------- projection du point central ------------
.projcenter
	movem.l	d0-d7/a2-a6,-(sp)


	sub	(a2)+,d1		x-obsx
	sub	(a2)+,d2		y-obsy
	sub	(a2)+,d3		z-obsz
	
	lea	mainmatrix(pc),a4	matrice princ

	move	d1,d6
	muls	(a4)+,d6		z
	move	d2,d7
	muls	(a4)+,d7
	sub.l	d7,d6
	move	d3,d7
	muls	(a4)+,d7
	add.l	d7,d6
	swap	d6
	neg	d6

;	cmp	#VIEWMINZ,d6		test du z
;	ble.s	.notincone
;	cmp	#VIEWMAXZ,d6
;	bge.s	.notincone

	move	d1,d7		point central de l'objet
	muls	(a4)+,d7		x
	move	d2,d0
	muls	(a4)+,d0
	add.l	d0,d7
	move	d3,d0
	muls	(a4)+,d0
	add.l	d0,d7

;	cmp.l	#VIEWEXTX*2<<16,d7
;	bhs.s	.notincone


	muls	(a4)+,d1		y
	muls	(a4)+,d2
	add.l	d2,d1
	muls	(a4)+,d3
	add.l	d3,d1


	move.l	d7,(a0)+		x projete
	move.l	d1,(a0)+		y projete
	move	d6,(a0)+		z projet‚

	move.l	(a0)+,d4		vbl rx,ry
	move	(a0)+,d5
	move.l	d4,(a0)+
	move	d5,(a0)+

	move.l	(a0)+,a4		adresse data
	add	(a0)+,a4		+ offset anim
	move.l	a4,(a0)+		adresse data

	move.l	a0,a6
	sub.l	#listobject+OBJ_size,a6
	move.w	a6,(a1)+		stocke offset objet
	move	d6,(a1)+		stocke z objet
	movem.l	(sp)+,d0-d7/a2-a6
	addq	#1,nbvobject
	dbf	d0,objrepeat
	rts
.notincone
	movem.l	(sp)+,d0-d7/a2-a6
	lea	OBJ_size-(OBJ_projx-OBJ_x)(a0),a0
	dbf	d0,objrepeat2
	rts


	;coordonn‚es du view point en face de l'observateur

viewpoint	
	dc.w	0	x
	dc.w	0	y
	dc.w	0	z

OBS_x	dc.w	-50
OBS_y	dc.w	-50
OBS_z	dc.w	100 


nbdecors
	dc.w	0
listdecors
	rs.b	MAXDECORS*DEC_size
nbobject
	dc.w	1
listobject
	; #] Calcul position des objets:
	; #[ Liste des objets:
obj1
	dc.l	ani_dummy	routine deplt
	ds.b	16	buffer
	dc.w	0,0,0	x,y,z
	dc.l	0,0
	dc.w	0
	dc.w	4,8,12
	dc.w	4,8,12
	dc.l	disk
	dc.w	0
	dc.l	0

	dc.l	ani_rebond	routine deplt
	ds.b	16	buffer
	dc.w	-200,-200,200	x,y,z
	dc.l	0,0
	dc.w	0
	dc.w	4,8,12
	dc.w	4,8,12
	dc.l	disk
	dc.w	0
	dc.l	0

obj2
	dc.l	ani_dummy	routine deplt
	ds.b	16	buffer
	dc.w	200,-200,0	x,y,z
	dc.l	0,0
	dc.w	0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.l	verre
	dc.w	0
	dc.l	0
obj3
	dc.l	ani_dummy	routine deplt
	ds.b	16	buffer
	dc.w	200,200,0	x,y,z
	dc.l	0,0
	dc.w	0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.l	glp
	dc.w	0
	dc.l	0
obj4
	dc.l	ani_dummy	routine deplt
	ds.b	16	buffer
	dc.w	-200,200,0	x,y,z
	dc.l	0,0
	dc.w	0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.l	ellipses
	dc.w	0
	dc.l	0

obj5
	dc.l	ani_dummy	routine deplt
	ds.b	16	buffer
	dc.w	200,-100,0	x,y,z
	dc.l	0,0
	dc.w	0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.l	disk
	dc.w	0
	dc.l	0

dummy1	rts

	; #] Liste des objets:
	; #[ Triation:
*************************************************************
*				*
*  routine de tri des objets visibles		*
*  quick sort (440 / vbl)			*
*				*
*************************************************************

sortobjects
	lea	nbvobject(pc),a0	;nombre d'objets
	move	(a0)+,d0
	add	d0,d0		;nombre d'objets * 4
	add	d0,d0
	jmp	.brasort(pc,d0.w)
.brasort
	rts			;si 0 element
	rts			;si 1...
	bra	.optsort2		;si 2...
	bra	.optsort3		;si 3...
	bra	.optsort4
	bra	.optsort5
	bra	.optsort6
	bra	.optsort7
	bra	.optsort8
	REPT	MAXOBJECT-8
	bra	.startqsort
	ENDR
.optsort2			
	movem.l	(a0),d0/d1	;tri 2 objets
	cmp	d0,d1
	ble.s	.nsopt2
	move.l	d1,(a0)+
	move.l	d0,(a0)+
.nsopt2
	rts

;------------- tri de 3 elements -------------------

.optsort3
	movem.l	(a0),d0/d1/d2
	cmp	d0,d1	;d0 ? d1
	ble.s	.nsopt3
			;d1 > d0
	cmp	d1,d2	
	ble.s	.nsopt31	
			;d2 > d1 > d0 
	move.l	d2,(a0)
	move.l	d0,8(a0)
	rts
.nsopt31
			;d2 < d1 > d0 
	cmp	d0,d2
	ble.s	.nsopt311
			;d1 > d2 > d0
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d0,(a0)+
	rts
.nsopt311			;d1 > d0 > d2
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	rts
.nsopt3			;d0 > d1
	cmp	d1,d2
	ble.s	.nsopt32	
			;d0 > d1 < d2
	cmp	d0,d2
	ble.s	.nsopt322
			;d2 > d0 > d1
	move.l	d2,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	rts
.nsopt322
			;d0 > d2 > d1
	addq	#4,a0
	move.l	d2,(a0)+
	move.l	d1,(a0)+
.nsopt32			;d0 > d1 > d2 -> pas de tri
	rts


.optsort4:
	movem.l	(a0),d0/d1/d2/d3
	cmp	d0,d2
	ble.s	.t40
	exg	d0,d2
.t40
	cmp	d1,d3
	ble.s	.t41
	exg	d1,d3
.t41
	cmp	d0,d1
	ble.s	.t42
	exg	d0,d1
.t42
	cmp	d2,d3
	ble.s	.t43
	exg	d2,d3
.t43
	cmp	d1,d2
	ble.s	.t44
	exg	d1,d2
.t44
	movem.l	d0/d1/d2/d3,(a0)
	rts

.optsort5:
	movem.l	(a0),d0/d1/d2/d3/d4
	cmp	d0,d4
	ble.s	.t50
	exg	d0,d4
.t50
	cmp	d0,d2
	ble.s	.t51
	exg	d0,d2
.t51
	cmp	d1,d3
	ble.s	.t52
	exg	d1,d3
.t52
	cmp	d2,d4
	ble.s	.t53
	exg	d2,d4
.t53
	cmp	d0,d1
	ble.s	.t54
	exg	d0,d1
.t54
	cmp	d2,d3
	ble.s	.t55
	exg	d2,d3
.t55
	cmp	d1,d4
	ble.s	.t56
	exg	d1,d4
.t56
	cmp	d1,d2
	ble.s	.t57
	exg	d1,d2
.t57
	cmp	d3,d4
	ble.s	.t58
	exg	d3,d4
.t58
	movem.l	d0/d1/d2/d3/d4,(a0)
	rts

.optsort6:
	movem.l	(a0),d0/d1/d2/d3/d4/d5
	cmp	d0,d4
	ble.s	.t60
	exg	d0,d4
.t60
	cmp	d1,d5
	ble.s	.t61
	exg	d1,d5
.t61
	cmp	d0,d2
	ble.s	.t62
	exg	d0,d2
.t62
	cmp	d1,d3
	ble.s	.t63
	exg	d1,d3
.t63
	cmp	d2,d4
	ble.s	.t64
	exg	d2,d4
.t64
	cmp	d3,d5
	ble.s	.t65
	exg	d3,d5
.t65
	cmp	d0,d1
	ble.s	.t66
	exg	d0,d1
.t66
	cmp	d2,d3
	ble.s	.t67
	exg	d2,d3
.t67
	cmp	d4,d5
	ble.s	.t68
	exg	d4,d5
.t68
	cmp	d1,d4
	ble.s	.t69
	exg	d1,d4
.t69
	cmp	d1,d2
	ble.s	.t610
	exg	d1,d2
.t610
	cmp	d3,d4
	ble.s	.t611
	exg	d3,d4
.t611
	movem.l	d0/d1/d2/d3/d4/d5,(a0)
	rts

.optsort7:
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6
	cmp	d0,d4
	ble.s	.t70
	exg	d0,d4
.t70
	cmp	d1,d5
	ble.s	.t71
	exg	d1,d5
.t71
	cmp	d2,d6
	ble.s	.t72
	exg	d2,d6
.t72
	cmp	d0,d2
	ble.s	.t73
	exg	d0,d2
.t73
	cmp	d1,d3
	ble.s	.t74
	exg	d1,d3
.t74
	cmp	d4,d6
	ble.s	.t75
	exg	d4,d6
.t75
	cmp	d2,d4
	ble.s	.t76
	exg	d2,d4
.t76
	cmp	d3,d5
	ble.s	.t77
	exg	d3,d5
.t77
	cmp	d0,d1
	ble.s	.t78
	exg	d0,d1
.t78
	cmp	d2,d3
	ble.s	.t79
	exg	d2,d3
.t79
	cmp	d4,d5
	ble.s	.t710
	exg	d4,d5
.t710
	cmp	d1,d4
	ble.s	.t711
	exg	d1,d4
.t711
	cmp	d3,d6
	ble.s	.t712
	exg	d3,d6
.t712
	cmp	d1,d2
	ble.s	.t713
	exg	d1,d2
.t713
	cmp	d3,d4
	ble.s	.t714
	exg	d3,d4
.t714
	cmp	d5,d6
	ble.s	.t715
	exg	d5,d6
.t715
	movem.l	d0/d1/d2/d3/d4/d5/d6,(a0)
	rts

.optsort8:
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7
	cmp	d0,d4
	ble.s	.t80
	exg	d0,d4
.t80
	cmp	d1,d5
	ble.s	.t81
	exg	d1,d5
.t81
	cmp	d2,d6
	ble.s	.t82
	exg	d2,d6
.t82
	cmp	d3,d7
	ble.s	.t83
	exg	d3,d7
.t83
	cmp	d0,d2
	ble.s	.t84
	exg	d0,d2
.t84
	cmp	d1,d3
	ble.s	.t85
	exg	d1,d3
.t85
	cmp	d4,d6
	ble.s	.t86
	exg	d4,d6
.t86
	cmp	d5,d7
	ble.s	.t87
	exg	d5,d7
.t87
	cmp	d2,d4
	ble.s	.t88
	exg	d2,d4
.t88
	cmp	d3,d5
	ble.s	.t89
	exg	d3,d5
.t89
	cmp	d0,d1
	ble.s	.t810
	exg	d0,d1
.t810
	cmp	d2,d3
	ble.s	.t811
	exg	d2,d3
.t811
	cmp	d4,d5
	ble.s	.t812
	exg	d4,d5
.t812
	cmp	d6,d7
	ble.s	.t813
	exg	d6,d7
.t813
	cmp	d1,d4
	ble.s	.t814
	exg	d1,d4
.t814
	cmp	d3,d6
	ble.s	.t815
	exg	d3,d6
.t815
	cmp	d1,d2
	ble.s	.t816
	exg	d1,d2
.t816
	cmp	d3,d4
	ble.s	.t817
	exg	d3,d4
.t817
	cmp	d5,d6
	ble.s	.t818
	exg	d5,d6
.t818
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7,(a0)
	rts

	

;--------------- quick sort --------------------------

.startqsort
	subq	#4,d0
	move.l	a0,a1
	add	d0,a1
	lea	.quicksort(pc),a6	;adresse quicksort
	moveq	#-4,d7
.quicksort
	move.l	a0,a2		i=l
	move.l	a1,a3		j=r
	move.l	a1,d0
	sub.l	a0,d0
	lsr	#1,d0
	and	d7,d0
	move	2(a0,d0.w),d0		x
.repeat
.while1
	move.l	(a2)+,d1
	cmp	d1,d0
	blt.s	.while1
	subq.l	#4,a2

	move.l	(a3),d2
	cmp	d2,d0
	ble.s	.fwhile2
.while2
	move.l	-(a3),d2
	cmp	d2,d0
	bgt.s	.while2
.fwhile2
	cmp.l	a2,a3		i ? j
	blt.s	.jinfi
	beq.s	.twoegal
	move.l	d1,(a3)
	move.l	d2,(a2)+
	subq	#4,a3
	cmp.l	a2,a3		i ? j
.jinfi
	bgt.s	.repeat

	cmp.l	a0,a3
	ble.s	.nosort1
	pea	(a1)
	pea	(a2)
	move.l	a3,a1
	jsr	(a6)
	move.l	(sp)+,a2
	move.l	(sp)+,a1
.nosort1
	cmp.l	a2,a1
	ble.s	.nosort2
	move.l	a2,a0
	jmp	(a6)
.nosort2
	rts
.twoegal
	addq	#4,a2
	subq	#4,a3
	cmp.l	a0,a3
	ble.s	.enosort1
	pea	(a1)
	pea	(a2)
	move.l	a3,a1
	jsr	(a6)
	move.l	(sp)+,a2
	move.l	(sp)+,a1
.enosort1
	cmp.l	a2,a1
	ble.s	.enosort2
	move.l	a2,a0
	jmp	(a6)
.enosort2
	rts

nbvobject	ds.w	1
tadrobj
	ds.l	MAXOBJECT	

	; #] Triation:
	; #[ Affichage:
*************************************************************
*				*
*  routine d'affichage des objets visibles tries	*
*				*
*************************************************************

affobjects
	lea	nbvobject(pc),a1
	move	(a1)+,d0		nombre d'objets visibles
	subq	#1,d0		
	blt.s	.aofin
.aorep
	move	(a1),d1		lit offset objet ou decors
	blt.s	.affdecors		c'est un decors
	lea	listobject+OBJ_rotx(pc),a3	adresse table des objets
	add	d1,a3		plus offset
	addq	#4,a1

	move	d0,-(sp)

	jsr	calcprojsec(pc)	calcul matrice

	addq	#6,a3

	move.l	(a3),a2		adresse datas objet
	move	(a2)+,d0		lit offset
	add	d0,a2

	movem.l	a0/a1/a3/a4/a5,-(sp)

	lea	OBJ_projx-OBJ_data(a3),a6

	move.l	(a6)+,a0
	move.l	(a6)+,a3
	move	(a6),a5

	jsr	calcobject(pc) 	calcul des points
	movem.l	(sp)+,a0/a1/a3/a4/a5

	move	(a2)+,d0		adresse des routines
	add	d0,a2		d'affichage

	movem.l	d1-d7/a0-a6,-(sp)
	jsr	drawobject(pc)
	movem.l	(sp)+,d1-d7/a0-a6

	move	(sp)+,d0
.aofin
	dbf	d0,.aorep
	rts


.affdecors
	lea	listdecors+DEC_projx(pc),a6	adresse table des decors
	add	d1,a6		plus offset
	addq	#4,a1
	
	move.l	(a6)+,a0		proj x,y,z
	move.l	(a6)+,a3
	move	(a6)+,a5

	movem.l	a0/a1/a3/a4/a5/a6,-(sp)
	jsr	calcobject(pc) 	calcul des points
	movem.l	(sp)+,a0/a1/a3/a4/a5/a6

	move.l	(a6),a2
	add	(a2)+,a2

	movem.l	d1-d7/a0-a6,-(sp)
	jsr	drawobject(pc)
	movem.l	(sp)+,d1-d7/a0-a6

	move	(sp)+,d0
	dbf	d0,.aorep
	rts

	; #] Affichage:

;  #] Multi objet:
;  #[ Draw ONE object:

	; #[ Macros et Equr:

;---------------- passage … la routine suivante -----------------

Fsuiv	MACRO
	move.l	(ptrobject)+,routtypeobj
	jmp	(routtypeobj)
	ENDM



miny	equr	d6      r‚serv‚s dans tous le calcul
maxy	equr	d7

routtypeobj	equr	a0
ptrsegment	equr	a0

projpoints	equr	a1	table des points projetes
ptrobject	equr	a2	pointeur objet

ya	equr	d3
xa	equr	d2	
yb	equr	d5
xb	equr	d4

regdata	equr	d1
regline	equr	a4	numero de ligne max
ptry	equr	a3	pointeur table des y

jmpcalc	equr	a5
retour	equr	a6

ptr1	equr	a3
ptr2	equr	a4
ptr3	equr	a5

drawobject	Fsuiv
enddrawobject	rts
stepface	add	(ptrobject),ptrobject
	Fsuiv
	
	; #] Macros et Equr:

	; #[ Matrix rotation:
*************************************************************
*				*
*  routine de calcul de la matrice d'un objet	*
*				*
*************************************************************

calcprojsec
	lea	sincos(pc),a0
	
	move	#NBSINUS*4-1,d1

	move	(a3)+,d0
	sub	OBS_rotx(pc),d0
	and	d1,d0
	movem	(a0,d0.w),sx/cx

	move	(a3)+,d0
	sub	OBS_roty(pc),d0
	and	d1,d0
	movem	(a0,d0.w),sy/cy

	move	(a3)+,d0
	sub	OBS_rotz(pc),d0
	and	d1,d0
	movem	(a0,d0.w),sz/cz

	lea	matrix(pc),a0


	move	cy,d0
	muls	cz,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+

	move	sy,(a0)+

	move	cy,d0
	muls	sz,d0
	add.l	d0,d0
	swap	d0
	neg	d0
	move	d0,(a0)+

	move	sx,d1
	muls	sz,d1
	move	cx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	cz,d0
	sub.l	d0,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a0)+

	move	cx,d0
	muls	cy,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$10

	move	sx,d1
	muls	cz,d1
	move	cx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	sz,d0
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$14

	move	cx,d1
	muls	sz,d1
	move	sx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	cz,d0
	add.l	d1,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$18

	move	sx,d0
	muls	cy,d0
	add.l	d0,d0
	swap	d0
	move	d0,(a0)+	;$1c

	move	cx,d1
	muls	cz,d1
	move	sx,d0
	muls	sy,d0
	add.l	d0,d0
	swap	d0
	muls	sz,d0
	sub.l	d0,d1
	add.l	d1,d1
	swap	d1
	move	d1,(a0)+
	rts
matrix
	ds.w	9


*************************************************************
*	calcul des points d'un objet		*
*				*
*	a2 pointeur sur l'objets		*
*	a0 dx			*
*	a3 dy			*
*	a5 dz			*		   
*************************************************************

calcobject
	lea	projetes(pc),a1
	lea	matrix(pc),a6

;	add	#250,a5

	move	(a2)+,d5		nombre de points
.bcpt
	move.l	a6,a4		pointeur matrice
	movem	(a2)+,d1/d2/d3

	move	d1,d6
	muls	(a4)+,d6	;x
	move	d2,d7
	muls	(a4)+,d7
	add.l	d7,d6
	move	d3,d7
	muls	(a4)+,d7
	add.l	d7,d6

	move	d1,d7
	muls	(a4)+,d7	;y
	move	d2,d0
	muls	(a4)+,d0
	add.l	d0,d7
	move	d3,d0
	muls	(a4)+,d0
	add.l	d0,d7

	muls	(a4)+,d1	;z
	muls	(a4)+,d2
	sub.l	d2,d1
	muls	(a4)+,d3
	add.l	d3,d1
	swap	d1
	neg	d1

	add.l	a0,d6
	add.l	a3,d7
	add	a5,d1

	asr.l	#8,d7		y
	asr.l	#5,d6		x

	move.l	d7,(a1)+		y
	move.l	d6,(a1)+		x
	move	d1,(a1)+		z

	cmp	#16,d1

	blt.s	.zinf16

	divs	d1,d6
	divs	d1,d7
	add	#NBLINE/2,d7
	move	d7,(a1)+		y
	move	d6,(a1)+		x
.fbcpt
	dbf	d5,.bcpt
	rts
.zinf16
	clr.l	(a1)+
	dbf	d5,.bcpt
	rts

	; #] Matrix rotation:
	; #[ Polygone:
	
*************************************************************
*				*
* routine d'affichage d'objet,		*
*      avec clipping et tramage, 1 plan, 4 plans	*
*				*
*    - calcul des droites dans une table		*
*    - remplissage par movem.l (4 plans)		*
*    - tramage 16 couleurs en movem.l (4 plans)	*
*    - clipping automatique en x		*
*				*
*************************************************************

		;#[ Pente calculating:

;-------------- calcul et clipping d'une ligne verticale ---------------
;
;	ptry
;	xa,ya,xb,yb
;	regline,regdata
;	maxy,miny
;

calcretour2
	dcb.w	NBLINE/2,$26c2
;	REPT	NBLINE/2	ligne verticale
;	move.l	xa,(ptry)+
;	ENDR
retourvert
	jmp	(retour)
vertline
	cmp	regline,ya	clipping
	bls.s	.yasupzero
	bgt.s	retourvert
	moveq	#0,ya
.yasupzero
	cmp	regline,yb
	bls.s	.ybinfmax
	blt.s	retourvert
	move	regline,yb
.ybinfmax
	cmp	maxy,yb	tester maximum
	ble.s	.pasmaximum
	move	yb,maxy
.pasmaximum
	cmp	miny,ya	tester minimum
	bge.s	.pasminimum
	move	ya,miny
.pasminimum
	sub	ya,yb	yb=dy
	add	ya,ya
	add	ya,ptry	debut de table
	move	xa,ya
	swap	xa
	move	ya,xa
	bclr	#0,yb
	beq.s	.vertpair
	move	xa,(ptry)+	
.vertpair
	neg	yb
	jmp	retourvert-2(pc,yb.w)
calcretour
	jmp	(retour)

;-------------- d‚but calcul des points d'une ligne -----------------

calcline:
	move.l	usp,ptry	adresse de la table des x
	cmp	ya,yb	c'est un ligne montante ?
	beq.s	calcretour	ligne horizontale -> fin
	bge.s	.ybsupya
	exg	xa,xb	‚change les points
	exg	ya,yb
	lea	NBLINE*2+CIRCLEMARGE*2(ptry),ptry  c'est une ligne montante
.ybsupya
	sub	xa,xb	dx
	beq.s	vertline	c'est une ligne verticale
	move	yb,regdata	pr‚pare calcul du dy
	sub	ya,regdata	dy

	ext.l	xb	calcul de la pente
	asl.l	#4,xb	dx*16 (et *8)
	divs	regdata,xb	divise par dy

	ext.l	xb	extention du r‚sultat
	cmp	regline,ya	clipping haut
	bls.s	.yasup0
	bgt.s	calcretour	ligne invisible
	muls	xb,ya	clipping
	lsr.l	#4,ya	divise par 16
	sub	ya,xa	addition … xa
	moveq	#0,ya	ya=0
	move	yb,regdata	nombre de ligne=yb
.yasup0
	cmp	regline,yb
	bls.s	.ybinfmax
	blt.s	calcretour
	move	regline,yb	moins de lignes
	move	yb,regdata	
	sub	ya,regdata	calcul dy
.ybinfmax
	cmp	maxy,yb	tester maximum
	ble.s	.pasmaximum
	move	yb,maxy
.pasmaximum
	cmp	miny,ya	tester minimum
	bge.s	.pasminimum
	move	ya,miny
.pasminimum
	add	ya,ya	adresse tableau lignes
	add	ya,ptry
	add	regdata,regdata offset pour le saut
	add	regdata,regdata
	neg	regdata
	swap	xb
	swap	xa
	asr.l	#4,xb
	move	xb,xa
	beq.s	.lineentier	;coef de pente entier
	swap	xa
	swap	xb
	add	#.line3-.line0,regdata
	jmp	.line0(pc,regdata.w)
.line0

;---------- cas d'une ligne … coefficient entier -----------

.lineentier
	swap	xa
	swap	xb
	add	#.line2-.line1,regdata
	jmp	.line1(pc,regdata.w)
.line1
	dcb.l	NBLINE-1,$36c2d444
;	REPT	NBLINE-1	;fill tower
;	move	xa,(ptry)+	;stocke point
;	add	xb,xa	;calcul avec coef entier
;	ENDR
.line2
	move	xa,(ptry)	;plot dernier point
	jmp	(retour)

;-------------- cas d'une droite coeficient fractionnaire ----

	dcb.l	NBLINE-1,$36c2d584
;	REPT	NBLINE-1	;fill tower
;	move	xa,(ptry)+	;stocke point
;	addx.l	xb,xa	;ajout pente
;	ENDR
.line3
	move	xa,(ptry)	;stocke dernier points
	jmp	(retour)
		;#] Pente calculating:

face:	bra.s	faceclip
noface	add	d0,ptrobject
	Fsuiv

		;#[ Face clipp‚e:
faceclip
	lea	projetes+10(pc),projpoints
	move	(ptrobject)+,d1
	move.l	projpoints,ptr1
	adda	d1,ptr1
	move.l	(ptr1),d1
	swap	d1

	moveq	#-1,d0
	lea	segments(pc),ptrsegment
	moveq	#1<<DISTEC,d4
	move	-2(ptr1),d7		;z du premier point
	cmp	d4,d7
	bge.s	facezsup0
facezinf0				;z negatif
	move	(ptrobject)+,d1	;lit nouveau point
	blt	fclipz2
	move.l	ptr1,ptr2		;ancien point
	move.l	projpoints,ptr1		
	add	d1,ptr1			
	move	-2(ptr1),d7		;z nouveau pts
	cmp	d4,d7
	blt.s	facezinf0

	sub	d7,d4		16-za
	move	-2(ptr2),d6		zb
	sub	d7,d6		zb-za

	move.l	-6(ptr1),d2		xa
	move.l	-6(ptr2),d3		xb
	asr.l	#3,d2		xa / 8
	asr.l	#3,d3		xb / 8
	sub	d2,d3		xb-xa

	muls	d4,d3		(16-za)(xb-xa)
	divs	d6,d3		(16-za)(xb-xa)/(zb-za)
	add	d2,d3
	asr	#DISTEC-3,d3
	move	d3,(ptrsegment)+

	move.l	-10(ptr1),d2		ya
	move.l	-10(ptr2),d3		yb
	sub	d2,d3		yb-ya
	muls	d4,d3		(16-za)(yb-ya)
	divs	d6,d3		(16-za)(yb-ya)/(zb-za)
	add	d2,d3
	asr	#DISTEC,d3
	add	#NBLINE/2,d3
	move	d3,(ptrsegment)+

	moveq	#1<<DISTEC,d4

	addq	#2,d0
	move.l	(ptr1),d1
	swap	d1
facezsup0				;z positif
	move.l	d1,(ptrsegment)+	;stocke point
	move	(ptrobject)+,d1	;lit nouveau point
	blt.s	fclipz
	addq	#1,d0			;+ 1 pts
	move.l	ptr1,ptr2		;ancien point
	move.l	projpoints,ptr1		
	add	d1,ptr1			
	move.l	(ptr1),d1
	swap	d1
	move	-2(ptr1),d7		;z nouveau pts
	cmp	d4,d7
	bge.s	facezsup0

	sub	d7,d4		16-za
	move	-2(ptr2),d6		zb
	sub	d7,d6		zb-za

	move.l	-6(ptr1),d2		xa
	move.l	-6(ptr2),d3		xb
	asr.l	#3,d2		xa / 8
	asr.l	#3,d3		xb / 8
	sub	d2,d3		xb-xa

	muls	d4,d3		(16-za)(xb-xa)
	divs	d6,d3		(16-za)(xb-xa)/(zb-za)
	add	d2,d3
	asr	#DISTEC-3,d3
	move	d3,(ptrsegment)+

	move.l	-10(ptr1),d2
	move.l	-10(ptr2),d3		yb
	sub	d2,d3		yb-ya

	muls	d4,d3		(16-za)(yb-ya)
	divs	d6,d3		(16-za)(yb-ya)/(zb-za)
	add	d2,d3
	asr	#DISTEC,d3
	add	#NBLINE/2,d3
	move	d3,(ptrsegment)+
	moveq	#1<<DISTEC,d4
	bra	facezinf0
fclipz2
	move.l	segments(pc),(ptrsegment)+
fclipz
	tst	d0
	bge	calcface
	addq	#2,a2
	Fsuiv
		;#] Face clipp‚e:
		;#[ Face non clipp‚e:
facenoclip
	lea	projetes+10(pc),projpoints
	movem	(ptrobject)+,d1/d2/d3	3 premiers points
	move.l	(projpoints,d1.w),d1	ya/xa
	move.l	(projpoints,d2.w),d2	yb/xb
	move.l	(projpoints,d3.w),d3	yc/xc
	swap	d1
	swap	d2
	swap	d3
	lea	segments+12(pc),ptrsegment
	movem.l	d1/d2/d3,-12(ptrsegment)
	REPT	10
	move	(ptrobject)+,d0
	blt.s	finlitpts
	move.l	(projpoints,d0.w),d0
	swap	d0
	move.l	d0,(ptrsegment)+
	ENDR
finlitpts
	neg	d0
calcface
	subq	#4,ptrsegment
	move	(ptrobject)+,maxy
	swap	maxy
	lea	tableymax(pc),ptry	adresse table des minx maxx
	move.l	ptry,usp
	move	#NBLINE-1,regline	no maximum de ligne
	move	miny,regdata
	clr	maxy		maxy=0
	move	regline,miny		miny=y maximum
	lea	retcalc(pc),retour
	lea	calcline(pc),jmpcalc
line1
	subq	#4,ptrsegment
	movem	(ptrsegment),xa/ya/xb/yb	 ;derniŠre droite
	jmp	(jmpcalc)
retcalc
	dbf	d0,line1

	move.l	ptrobject,-(sp)
	jsr	drawpolygone(pc)
	move.l	(sp)+,ptrobject
	Fsuiv
	
		;#] Face non clipp‚e:

	; #] Polygone:
	; #[ Test visibilit‚:

vx	dc.w	0
vvx	dc.w	0
vy	dc.w	0
vvy	dc.w	0
vz	dc.w	0
vvz	dc.w	0

testv:

	IFEQ	1

	lea	projetes(pc),projpoints
	movem	(ptrobject)+,d0/d1/d2/d3
	move.l	projpoints,ptr1
	adda	d1,ptr1
	move.l	projpoints,ptr2
	adda	d2,ptr2
	move.l	projpoints,ptr3
	adda	d3,ptr3

	move.l	4(ptr1),d2	; X1
	move.l	(ptr1),d3	; Y1
	move.w	8(ptr1),d4	; Z1
	
	move.l	4(ptr2),d5	; X2
	move.l	(ptr2),d6	; Y2
	move.w	8(ptr2),d7	; Z2
	
	sub.l	4(ptr3),d2	; X1-X0
	asr.l	#8,d2
	asr.l	#3,d2
	sub.l	(ptr3),d3	; Y1-Z0
	asr.l	#8,d3
	sub.w	8(ptr3),d4	; Z1-Z0
	sub.l	4(ptr3),d5	; X2-X0
	asr.l	#8,d5
	asr.l	#3,d2
	sub.l	(ptr3),d6	; Y2-Z0
	asr.l	#8,d2
	sub.w	8(ptr3),d7	; Z2-Z0
-----------------------
	movem	d2-d4,vx
;	move.w	d2,vx
;	move.w	d3,vy
;	move.w	d4,vz
	
		; x = vy * zz - vz * yy;
	muls	d7,d3
	muls	d6,d4
	sub.l	d4,d3
	asr.l	#8,d3
	move.l	d3,vvx
	
		; y = vz * xx - vx * zz;
	move.w	vz,d4
	muls	d5,d4
	muls	d7,d2
	sub.l	d2,d4
	asr.l	#8,d4
	move.l	d4,vvy
	
		; z = vx * yy - vy * xx;
	move.w	vx,d2
	move.w	vy,d3
	muls	d6,d2
	muls	d5,d3
	sub.l	d3,d2
	asr.l	#8,d2
	move.l	d2,d4
	move.l	vvx,d2
	move.l	vvy,d3

		; vvx * x0 + vvy * y0 + vvz * z0
	
	move.l	4(ptr3),d0
	asr.l	
	muls	4(a5,d1.w),d2	; x0 * vvx
	muls	(a5,d1.w),d3	; y0 * vvy
	muls	8(a5,d1.w),d4	; z0 * vvz
	add.l	d3,d2
	add.l	d4,d2
	
	

	ELSEIF	

	lea	projetes+10(pc),projpoints
	movem	(ptrobject)+,d0/d1/d2/d3
	move.l	projpoints,ptr1
	move.l	(projpoints,d2.w),d2
	move.l	(projpoints,d3.w),d3
	add	d1,ptr1
	move.l	(ptr1),d1
	move	d2,d6
	sub	d1,d6		xb-xa
	move	d3,d7
	sub	d2,d7		xc-xb
	swap	d1
	swap	d2
	swap	d3
	move	d1,d4
	sub	d2,d4		ya-yb
	move	d3,d5
	sub	d2,d5		yc-yb
	muls	d5,d6
	muls	d4,d7
	add.l	d6,d7
	endc

	bgt.s	.visi
	
	adda	d0,ptrobject
	Fsuiv
.visi:
	Fsuiv



	; #] Test visibilit‚:
	; #[ Beuark: Tres mauvaise routine de droite (4 plans)
; ------------------------------------------------------------------------ ;
;		Routine de droite		;
;	        (Gere le clippping en X et en Y)		;
; ------------------------------------------------------------------------ ;
; Appel:
; d0 : X1
; d1 : Y1
; d2 : X2
; d3 : Y2
; a0 : Adresse ‚cran

; Entr‚e -->
X1	EQUR	d1
Y1	EQUR	d0
X2	EQUR	d3
Y2	EQUR	d2
ADECRAN	EQUR	a0
; Registres temporaire -->
DX	EQUR	d4
DY	EQUR	d5
XX	EQUR	d6
NLOOP	EQUR	d7
LX	EQUR	d1
LY	EQUR	d1
CURDOT	EQUR	d2
ADEC	EQUR	d3

fin_line:
	Fsuiv

draw_line:
	movem	(ptrobject)+,X1/X2
	lea	projetes+10(pc),ADECRAN
	movem	(ADECRAN,X1),Y1/X1
	movem	(ADECRAN,X2),Y2/X2
	asr	#3,X1
	add	#CX,X1
	asr	#3,X2
	add	#CX,X2
	move.l	scr6,ADECRAN

	; #[ Clipping:
	cmp	Y1,Y2
	bge.s	.noswap2
	exg	Y1,Y2
	exg	X1,X2
.noswap2:
	subq	#1,Y1
	addq	#1,Y1
	addq	#1,Y2
	subq	#1,Y2

	move	Y2,DY	; Droite dans ‚cran?
	blt.s	fin_line
	cmpi	#MAY,Y1	;   ""    ""	""  ?
	bgt.s	fin_line
	sub	Y1,DY

	move	X2,DX	; Calcul DX
	sub	X1,DX

	cmpi	#MAY,Y2	; Doit on clipper?
	ble.s	.noclip_bas

	subi	#MAY,Y2
	muls	DX,Y2
	divs	DY,Y2
	sub	Y2,X2
	move	#MAY,Y2
.noclip_bas:

	tst	Y1
	bge.s	.noclip_haut

	muls	DX,Y1
	divs	DY,Y1
	sub	Y1,X1
	clr	Y1
.noclip_haut:

	cmp	X1,X2
	bge.s	.noswap

	exg	X1,X2
	exg	Y1,Y2
.noswap:

	tst	X2	; Droite visible?
	blt.s	fin_line
	cmpi	#MAX,X1
	bgt.s	fin_line

	cmpi	#MAX,X2	; Doit on clipper?
	ble.s	.noclip_droite

	subi	#MAX,X2
	muls	DY,X2
	divs	DX,X2
	sub	X2,Y2
	move	#MAX,X2
.noclip_droite:

	tst	X1
	bge.s	.noclip_gauche

	muls	DY,X1
	divs	DX,X1
	sub	X1,Y1
	clr	X1
.noclip_gauche:
	; #] Clipping:

	move	X2,DX
	sub	X1,DX
	move	Y2,DY
	sub	Y1,DY

	muls	#160,Y2
	adda	Y2,ADECRAN
	move	X2,XX
	andi	#$ff0,XX
	lsr	#1,XX
	adda	XX,ADECRAN
	moveq	#0,XX
	not	X2
	andi	#$f,X2
	bset	X2,XX
	swap	XX
	bset	X2,XX

	move	#-160,ADEC
	tst	DY
	bge.s	.okneg
	neg	DY
	neg	ADEC
.okneg:

	cmp	DX,DY
	blt.s	penteinf1

	tst	DY
	beq	fin_line
	move	DY,LY
	asr	#1,LY
	move	DY,NLOOP
	subq	#1,NLOOP

.loop:
	or.l	XX,(ADECRAN)
	or.l	XX,4(ADECRAN)
	adda	ADEC,ADECRAN
	sub	DX,LY
	bgt.s	.noaddplot
	add	DY,LY
	add.l	XX,XX
	bcc.s	.noaddplot
	subq	#8,ADECRAN
	move.l	#$00010001,XX
.noaddplot:
	dbra	NLOOP,.loop

	Fsuiv

penteinf1:
	moveq	#0,CURDOT
	move	DX,LX
	asr	#1,LX
	move	DX,NLOOP
	subq	#1,NLOOP

.loop:
	or.l	XX,CURDOT
	sub	DY,LX
	bge.s	.ok
	or.l	CURDOT,(ADECRAN)
	or.l	CURDOT,4(ADECRAN)
	adda	ADEC,ADECRAN
	add	DX,LX
	moveq	#0,CURDOT
.ok:
	add.l	XX,XX
	bcs.s	.plot
	dbra	NLOOP,.loop

	or.l	CURDOT,(ADECRAN)
	or.l	CURDOT,4(ADECRAN)

.fin:
	Fsuiv
.plot:
	or.l	CURDOT,(ADECRAN)
	or.l	CURDOT,4(ADECRAN)
	subq	#8,ADECRAN
	moveq	#0,CURDOT
	move.l	#$00010001,XX

	dbra	NLOOP,.loop

	Fsuiv
	; #] Beuark: Tres mauvaise routine de droite (4 plans)
	; #[ Waouh!! Des ellipses!:
noellipse:
	addq	#2,ptrobject
	Fsuiv

PRECISELL	=	3
PRECISPENTE	=	3
PRECISPENTE2	=	0
ellipse:
	lea	projetes(pc),projpoints
	movem	(ptrobject)+,d0-d2
	move.l	projpoints,ptr1
	adda	d0,ptr1
	move.l	projpoints,ptr2
	adda	d1,ptr2
	move.l	projpoints,ptr3
	adda	d2,ptr3

	; test si ellipse derriere ecran
	cmpi	#1<<DISTEC,8(ptr1)
	blt.s	noellipse
	cmpi	#1<<DISTEC,8(ptr2)
	blt.s	noellipse
	cmpi	#1<<DISTEC,8(ptr3)
	blt.s	noellipse

; ~~~~~~~~~~~~~~~~ FORMULES: ~~~~~~~~~~~~~~~ ;
; Hauteur:	Ay = Sqr(Ya*Ya + Yb*Yb)	;
; (Inutilis‚)	Ax = (Xa*Ya + Xb*Yb) / Ay	;
;			;
; Largeur:	Rx = (Xa*Yb - Xb*Ya) / Ay	;
;			;
;	Ay   Ya*Ya + Yb*Yb	;
; Pente	-- = -------------	;
;	Ax   Xa*Ya + Xb*Yb	;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;

	IFEQ	PRECISELL
	move	12(ptr2),d4	;Xa
	move	10(ptr2),d5	;Ya
	move	12(ptr3),d6	;Xb
	move	10(ptr3),d7	;Yb
	sub	12(ptr1),d4
	sub	12(ptr1),d6
	sub	10(ptr1),d5
	sub	10(ptr1),d7
	ELSEIF
	move.l	(ptr1)+,d3
	asl.l	#PRECISELL,d3
	move.l	(ptr1)+,d2
	asl.l	#PRECISELL,d2
	move.l	(ptr2)+,d5
	asl.l	#PRECISELL,d5
	move.l	(ptr2)+,d4
	asl.l	#PRECISELL,d4
	move.l	(ptr3)+,d7
	asl.l	#PRECISELL,d7
	move.l	(ptr3)+,d6
	asl.l	#PRECISELL,d6
	divs	(ptr1),d2
	divs	(ptr1),d3
	divs	(ptr2),d4
	divs	(ptr2),d5
	divs	(ptr3),d6
	divs	(ptr3),d7
	sub	d2,d4
	sub	d2,d6
	sub	d3,d5
	sub	d3,d7
	ENDC
	
	move	d5,d0
	muls	d0,d0
	move	d7,d1
	muls	d1,d1
	add.l	d1,d0	; --> Ya*Ya + Yb*Yb
;	tst	d0
;	cmpi	#64,d0
;	beq.s	noellipse
	
	move	d4,d1
	muls	d5,d1
	move	d6,d2
	muls	d7,d2
	add.l	d1,d2	; --> Xa*Ya + Xb*Yb
	
	muls	d7,d4
	muls	d6,d5
	sub.l	d5,d4	; --> Xa*Yb - Xb*Ya
	
	move.l	d2,d7
	asl.l	#8,d7
	IFNE	FALSE
	cmpi	#1<<PRECISPENTE,d0
	cmpi	#16,d0
	ble.s	.toolittle
	ENDC
	IFNE	PRECISPENTE
	move.l	d0,d6
	asr.l	#PRECISPENTE,d7
	asr.l	#PRECISPENTE,d6
	tst	d6
	beq	noellipse
	divs	d6,d7
	ELSEIF
	tst	d0
	beq	noellipse
	divs	d0,d7
	ENDC
	ext.l	d7
	asl.l	#8-PRECISPENTE*0,d7
	IFNE	FALSE
	bra.s	.oklittle
.toolittle:
	IFGT	PRECISPENTE2
	asl.l	#PRECISPENTE2,d7
	ENDC
	tst	d0
	beq	noellipse
	divs	d0,d7
	ext.l	d7
	IFGT	PRECISPENTE2
	asl.l	#8-PRECISPENTE2,d7
	ELSEIF
	asl.l	#8,d7
	ENDC
.oklittle:
	ENDC
	move.l	d7,a6	; --> Ay/Ax (Pente)
	
	bsr	racine_carre	; --> d2 = Ay (Hauteur)
	tst	d2
	beq	noellipse
	divs	d2,d4	; --> Rx (Largeur)
	tst	d4
	bge.s	.ok
	neg	d4
.ok:
	
	IFNE	PRECISELL
	asr	#PRECISELL,d4
	beq	noellipse
	asr	#PRECISELL,d2
	beq	noellipse
	ENDC
	move	d4,d0	; Largeur
	move	-6(ptrobject),d4
	move	10(projpoints,d4),d5	; Centre y
	move	12(projpoints,d4),d4	; Centre x
	sub	d2,d5
	move	d2,-(a7)
	move	d5,-(a7)
;-------------------- Calcul des points d'une ellipse -----------------
; d0 = rayon x de l'ellipse
; d2 = rayon y de l'ellipse
; d4 = position x du centre de l'ellipse
; d5 = position y du centre
; a6 = pente

	move	d2,d7
	move	d2,d1
	add	d2,d2
	add	d2,d2
	add	d5,d5

	lea	tableymax,a0
	adda	d5,a0
	lea	NBLINE*2+CIRCLEMARGE*2(a0),a3
	move.l	a0,a1
	add	d2,a1

	swap	d4
	clr	d4
	swap	d4
	move.l	d4,d5
	
	muls	d0,d0
	move.l	d0,d3
	asr.l	#4,d3
	muls	d1,d3
	asl.l	#3,d3
	muls	d1,d1
	
	move.l	d3,d2
	add.l	d3,d3
	neg.l	d2
	moveq	#0,d6
	move.l	d0,a4
	move.l	d1,a5
	move.l	a6,d1
	asr.l	#8,d1
	muls	d7,d1
	asr.l	#8,d1
	move.l	d1,d0

	subq	#1,d7

	bra.s	.saute

.loop:
	swap	d0
	sub.l	a6,d0
	swap	d0
	swap	d1
	sub.l	a6,d1
	swap	d1

.saute:
	add.l	d3,d2
	blt.s	.okell

.tst:
	addq	#1,d4
	subq	#1,d5

	add.l	a5,d6
	sub.l	d6,d2
	bge.s	.tst
.okell:
	sub.l	a4,d3

	sub	d0,d4
	move	d4,(a0)+
	add	d0,d4
	add	d1,d4
	move	d4,-(a1)
	sub	d1,d4
	sub	d0,d5
	move	d5,(a3)+
	add	d0,d5
	add	d1,d5
	move	d5,NBLINE*2+CIRCLEMARGE*2(a1)
	sub	d1,d5
	
	dbra	d7,.loop
	
	move	(a7)+,miny
	move	(a7)+,regdata
	
	move	(ptrobject)+,maxy
	swap	maxy
	move	miny,maxy
	add	regdata,maxy
	add	regdata,maxy
	subq	#1,maxy
	
	tst	miny
	bge.s	.okminy
	clr	miny
.okminy:
	cmpi	#NBLINE,maxy
	blt.s	.okmaxy
	move	#NBLINE-1,maxy
.okmaxy:
	
	move.l	ptrobject,-(a7)
	bsr	drawpolygone
	move.l	(a7)+,ptrobject
	
	Fsuiv
	
;-------------Calcul de la racine carr‚ en long ----------
;
; entr‚e:	d0.l
; sortie:	d2.w
; modifi‚s:	d0 … d3
;
racine_carre:
	moveq	#$f,d3
	move.l	#$40000000,d2
	move.l	d0,d1
	clr.w	d1
	swap	d1
.loop:
	swap	d2
	sub.l	d2,d1
	bcc.s	.jmp
	add.l	d2,d1
	swap	d2
	add.w	d2,d2
	add.w	d0,d0
	addx.l	d1,d1
	add.w	d0,d0
	addx.l	d1,d1
	dbf	d3,.loop
	rts
	
.jmp:
	swap	d2
	add.w	d2,d2
	addq.w	#1,d2
	add.w	d0,d0
	addx.l	d1,d1
	add.w	d0,d0
	addx.l	d1,d1
	dbf	d3,.loop
	rts
	; #] Waouh!! Des ellipses!:
	; #[ Affichages lignes horizontales:

		;#[ Appel:
*---------------- affichage des lignes du polygone ------------

drawpolygone
	sub	miny,maxy	nombre de ligne
	ble.s	nopoly
	swap	maxy
	add	maxy,maxy
	bcs	drawoneplane
	bmi	drawtrame16
	bra.s	draw16notrame
	
		;#] Appel:
		;#[ Equr:
reg1	equr	d0
reg2	equr	d1
reg3	equr	d2
reg4	equr	d3
reg5	equr	a3
reg6	equr	a4

x1	equr	d3
offgau	equr	d4
x0	equr	d5
offdro	equr	d6

ptrtable1	equr	a0	pointeur table des minx-maxx
ecran	equr	a1	adresse ecran
ptrtable2	equr	a2

ptrclipx	equr	a5
lecran	equr	a6

	; #] Equr:
		;#[ 4 plans non tram‚s:
*--------------- affichage pattern de ligne gauche ------------

MACRO18	MACRO
	move.l	(ptrclipx)+,x0
	move.l	-(ecran),offgau	;cette routine doit
	eor.l	reg2,offgau		;obligatoirement faire
	and.l	x0,offgau		;18 octets
	eor.l	offgau,(ecran)
	
	move.l	-(ecran),offgau
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	offgau,(ecran)
	ENDM

*---------------- affichage 16 couleurs non trame -------------

nopoly
	rts

draw16notrame:
	lea	tabcolor(pc),ptrtable1
	movem.l	(ptrtable1,maxy.w),reg1/reg2
	lea	tableymax(pc),ptrtable1
	swap	maxy
	add	miny,miny
	add	miny,ptrtable1
	lea	NBLINE*2+CIRCLEMARGE*2(ptrtable1),ptrtable2
	IFNE	FALSE
	move	(ptrtable2),x0
	sub	(ptrtable1),x0
	cmpi	#8,x0
	bgt.s	nopoly
	ENDC
	lea	muls160(pc),ptrclipx
	move.l	scr6,lecran
	addq	#4,lecran
	add	(ptrclipx,miny.w),lecran
	move.l	reg1,reg3
	move.l	reg2,reg4
	move.l	reg1,reg5
	move.l	reg2,reg6
	lea	mlimit,ptrclipx
	move.l	ptrclipx,usp
	bra	dlrep16bra2
	
; cas o— offdro est negatif
	REPT	17
	dbf	maxy,dlrep16bra	|4
	rts			|2
	ds.b	64-6
	ENDR

	dbf	maxy,dlrep16bra	|4
	rts			|2
	ds.b	64-52-6

dlrep16
	MACRO18
dlrep16bra
	lea	160(lecran),lecran
dlrep16bra2
	move.l	lecran,ecran

	moveq	#-8,x0
	and	(ptrtable1)+,x0
	move.l	usp,ptrclipx
	adda	x0,ptrclipx
	move	(ptrclipx)+,offdro
	move.l	(ptrclipx)+,x0
	adda	(ptrclipx)+,ecran

	moveq	#-8,offgau
	and	(ptrtable2)+,offgau
	move.l	usp,ptrclipx
	adda	offgau,ptrclipx
	sub	(ptrclipx)+,offdro

	jmp	onelong(pc,offdro.w)	;appel transfert par movem

; cas o— offdro est nul
onelong:
	move.l	(ptrclipx)+,offgau	|2
	eor.l	x0,offgau		|2
	move.l	-(ecran),x0		|2
	eor.l	reg1,x0		|2
	and.l	offgau,x0		|2
	eor.l	x0,(ecran)+		|2
	move.l	(ecran),offdro 	|2
	eor.l	reg2,offdro		|2
	and.l	offgau,offdro		|2
	eor.l	offdro,(ecran) 	|2

	dbf	maxy,dlrep16bra	|4
	rts			|2
	ds.b	64-26

ffill0:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-24-20
ffill1:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	move.l	reg2,-(ecran)
	move.l	reg1,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-28-20
ffill2:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-28-20
ffill3:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-28-20
ffill4:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-32-20
ffill5:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-32-20
ffill6:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,dlrep16
ffill6bra
	MACRO18
	rts
	ds.b	64-32-20
ffill7:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-18-18-20
ffill8:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-18-18-20
ffill9:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-18-18-20
ffill10:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-22-18-20
ffill11:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-22-18-20
ffill12:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-22-18-20
ffill13:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
;	ds.b	64-26-18-20
ffill14:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,dlrep16
	MACRO18
	rts
	ds.b	64-26-18-20
ffill15:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,dlrep16
finfill15:
	MACRO18
	rts
	ds.b	64-26-18-20
ffill16:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,dlrep16
	bra.s	finfill15
	ds.b	64-30-20
ffill17:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,dlrep16
	bra.s	ffillfin
	ds.b	64-30-20
ffill18:
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)


	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,dlrep16
ffillfin:
	MACRO18
	rts
	; #] 4 plans non tram‚s:
		;#[ 4 plans tram‚s:
;------------------- Polygone 16 couleur trame -------------------

drawtrame16
	lea	tabcolor(pc),ptrtable1
	and	#$0fff,maxy
	movem.l	(ptrtable1,maxy.w),reg1/reg2
	BTST	#0,miny
	BEQ.S	.OK
	ROR	reg1
	SWAP	reg1
	ROR	reg1
	SWAP	reg1
	ROR	reg2
	SWAP	reg2
	ROR	reg2
	SWAP	reg2
.OK:
	lea	tableymax(pc),ptrtable1
	swap	maxy
	add	miny,miny
	add	miny,ptrtable1

	lea	muls160(pc),ptrclipx
	move.l	scr6,lecran
	addq	#4,lecran
	add	(ptrclipx,miny.w),lecran

	move.l	reg1,reg3		;charge reg couleur
	move.l	reg2,reg4
	move.l	reg1,reg5
	move.l	reg2,reg6

	lea	mlimit,ptrclipx
	move.l	ptrclipx,usp

	subq	#1,maxy
	move	maxy,x0
	asr	#1,x0
	sub	x0,maxy

	move	x0,-(sp)
	move.l	ptrtable1,-(sp)
	move.l	lecran,-(sp)
	jsr	t1dlrep16bra2(pc)
	move.l	(sp)+,lecran
	move.l	(sp)+,ptrtable1
	move	(sp)+,maxy
	lea	160(lecran),lecran
	addq	#2,ptrtable1
	ror	reg1
	swap	reg1
	ror	reg1
	swap	reg1
	ror	reg2
	swap	reg2
	ror	reg2
	swap	reg2
	move.l	reg1,reg3
	move.l	reg2,reg4
	move.l	reg1,reg5
	move.l	reg2,reg6
	bra.s	t1dlrep16bra2

; cas o— offdro < 0
	dbf	maxy,t1dlrep16bra
	rts
	ds.b	64-56-6
	
t1dlrep16
	MACRO18
t1dlrep16bra
	lea	320(lecran),lecran	;place ici pour
t1dlrep16bra2
	moveq	#-8,x0
	and	(ptrtable1),x0
	move.l	usp,ptrclipx
	add	x0,ptrclipx

	move	(ptrclipx)+,offdro
	move.l	(ptrclipx)+,x0
	move.l	lecran,ecran
	adda	(ptrclipx)+,ecran

	moveq	#-8,offgau
	and	NBLINE*2+CIRCLEMARGE*2(ptrtable1),offgau
	addq	#4,ptrtable1
	move.l	usp,ptrclipx
	add	offgau,ptrclipx

	sub	(ptrclipx)+,offdro
	jmp	t1onelong(pc,offdro.w)	;appel transfert par movem
; offdro = 0
t1onelong
	move.l	(ptrclipx)+,offgau
	eor.l	x0,offgau
	move.l	(ecran),x0
	eor.l	reg2,x0
	and.l	offgau,x0
	eor.l	x0,(ecran)
	move.l	-(ecran),offdro
	eor.l	reg1,offdro
	and.l	offgau,offdro
	eor.l	offdro,(ecran)

	dbf	maxy,t1dlrep16bra
	rts
	ds.b	64-26
	
t1ffill0
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-24-20
t1ffill1
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	move.l	reg2,-(ecran)
	move.l	reg1,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-28-20
t1ffill2
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-28-20
t1ffill3
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-28-20
t1ffill4
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-32-20
t1ffill5
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-32-20
t1ffill6
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,t1dlrep16
t1ffill6bra
	MACRO18
	rts
	ds.b	64-32-20
t1ffill7
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-18-18-20
t1ffill8
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-18-18-20
t1ffill9
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-18-18-20
t1ffill10
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-22-18-20
t1ffill11
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-22-18-20
t1ffill12
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-22-18-20
t1ffill13
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-26-18-20
t1ffill14
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-26-18-20
t1ffill15
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-26-18-20
t1ffill16
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-30-20
t1ffill17
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4,-(ecran)
	dbf	maxy,t1dlrep16
	MACRO18
	rts
	ds.b	64-30-20
t1ffill18
	move.l	(ecran),offgau 	;masque 2 mots
	eor.l	reg2,offgau
	and.l	x0,offgau
	eor.l	reg2,offgau
	move.l	offgau,(ecran)

	move.l	-(ecran),offgau	;masque 2 mots
	eor.l	reg1,offgau
	and.l	x0,offgau
	eor.l	reg1,offgau
	move.l	offgau,(ecran)

	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	movem.l	reg1/reg2/reg3/reg4/reg5/reg6,-(ecran)
	dbf	maxy,t1dlrep16
t1ffillfin:
	MACRO18
	rts
	; #] 4 plans tram‚s:
		;#[ 1 plan:
;------------- Routine affichage de polygone 1 plan ------------------

drawoneplane:
	bmi	oneplanetrame
	lea	tableymax(pc),ptrtable1	;adresse table
	add	miny,miny
	add	miny,ptrtable1 	;pointe table des x
	lea	NBLINE*2+CIRCLEMARGE*2(ptrtable1),ptrtable2

	lea	muls160(pc),ptrclipx
	move.l	scr6,lecran
	add	(ptrclipx,miny.w),lecran	;pointe ligne ecran
	moveq	#$f,reg2		;decalage plan no
	and	maxy,reg2
	add	reg2,lecran
	swap	maxy		;recupere nombre de lignes

	moveq	#-1,reg1		;pattern $ffff

	lea	mlimit+4,ptrclipx	;table clipping x
dlrep1
	moveq	#-8,x0
	and	(ptrtable1)+,x0
	moveq	#-8,x1
	and	(ptrtable2)+,x1
	
	move.l	(ptrclipx,x0.w),x0
	move.l	(ptrclipx,x1.w),x1

	sub	x0,x1
	bge.s	onelong1

	move.l	lecran,ecran
	add	x0,ecran
	swap	x0
	not	x0
	or	x0,(ecran)
	add	x1,ecran

	asr	#1,x1
	jmp	ffillplan+4(pc,x1.w)

onelong1
	bne.s	lsuiv1

	eor.l	x0,x1		;gain 2 swap
	swap	x1
	or	x1,(lecran,x0.w)
lsuiv1
	lea	160(lecran),lecran
	dbf	maxy,dlrep1
	rts

cpt	set	18*8
	REPT	18
	move	reg1,cpt(ecran)
cpt	set	cpt-8
	ENDR
ffillplan
	swap	x1
	or	x1,(ecran)
	lea	160(lecran),lecran
fdlrep1
	dbf	maxy,dlrep1
	rts

;---------------- Routine polygone trame 1 plan -----------------

oneplanetrame:
	lea	tableymax(pc),ptrtable1	;adresse table
	add	miny,miny
	add	miny,ptrtable1 	;pointe table des x
	lea	NBLINE*2+CIRCLEMARGE*2(ptrtable1),ptrtable2
	lea	muls160(pc),ptrclipx
	move.l	scr6,lecran
	add	(ptrclipx,miny.w),lecran	;pointe ligne ecran
	moveq	#$f,reg2		;decalage plan no
	and	maxy,reg2
	add	reg2,lecran
	swap	maxy		;recupere nombre de lignes

	move.l	#$aaaa5555,reg1
	btst	#1,miny
	beq.s	.tramepair
	swap	reg1
.tramepair
	lea	mlimit+4,ptrclipx	;table clipping x
.edlrep1
	moveq	#-8,x0
	and	(ptrtable1)+,x0
	move.l	(ptrclipx,x0.w),x0

	moveq	#-8,x1
	and	(ptrtable2)+,x1
	move.l	(ptrclipx,x1.w),x1

	sub	x0,x1
	bge.s	.eonelong1

	move.l	lecran,ecran
	add	x0,ecran
	swap	x0
	not	x0
	and	reg1,x0
	or	x0,(ecran)
	add	x1,ecran
	asr	#1,x1
	jmp	.effillplan+4(pc,x1.w)
.eonelong1
	bne.s	.elsuiv1
	eor.l	x0,x1		;gain 2 swap
	swap	x1
	and	reg1,x1
	or	x1,(lecran,x0.w)
.elsuiv1
	swap	reg1
	lea	160(lecran),lecran
	dbf	maxy,.edlrep1
	rts

cpt	set	18*8
	REPT	18
	move	reg1,cpt(ecran)
cpt	set	cpt-8
	ENDR
.effillplan
	swap	x1
	and	reg1,x1
	or	x1,(ecran)
	lea	160(lecran),lecran
.efdlrep1
	swap	reg1
	dbf	maxy,.edlrep1
	rts

;------------- Routine affichage de polygone 1 xor ------------------

drawnotplane:
	lea	tableymax(pc),ptrtable1	;adresse table
	add	miny,miny
	add	miny,ptrtable1 	;pointe table des x
	lea	NBLINE*2+CIRCLEMARGE*2(ptrtable1),ptrtable2

	lea	muls160(pc),ptrclipx
	move.l	scr6,lecran
	add	(ptrclipx,miny.w),lecran	;pointe ligne ecran
	moveq	#$f,reg2		;decalage plan no
	and	maxy,reg2
	add	reg2,lecran
	swap	maxy		;recupere nombre de lignes

	lea	mlimit+4,ptrclipx	;table clipping x
.notdlrep1
	moveq	#-8,x0
	and	(ptrtable1)+,x0
	move.l	(ptrclipx,x0.w),x0
	moveq	#-8,x1
	and	(ptrtable2)+,x1
	move.l	(ptrclipx,x1.w),x1

	sub	x0,x1
	bge.s	.notlong1

	move.l	lecran,ecran
	add	x0,ecran
	swap	x0
	or	x0,(ecran)
	not	(ecran)
	add	x1,ecran
	asr	#1,x1
	jmp	.notffillplan+4(pc,x1.w)
.notlong1
	bne.s	.notlsuiv1
	eor.l	x0,x1		;gain 2 swap
	swap	x1
	or	x1,(lecran,x0.w)
.notlsuiv1
	lea	160(lecran),lecran
	dbf	maxy,.notdlrep1
	rts

cpt	set	18*8
	REPT	18
	not	cpt(ecran)
cpt	set	cpt-8
	ENDR
.notffillplan
	swap	x1
	or	x1,(ecran)
	lea	160(lecran),lecran
.notfdlrep1
	dbf	maxy,.notdlrep1
	rts

		;#] 1 plan:

	; #] Affichages lignes horizontales:

;  #] Draw ONE object:
;  #[ Subrouts:

	; #[ Cls:
;----------------- Effacement de l'ecran 4 plans --------------

ffastcls
	move.l	scr6(pc),a0
	lea	NBLINE*160(a0),a0
	moveq	#0,d0
	moveq	#0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d0,a3
	move.l	d1,a4
	move.l	d0,a5
	move.l	d1,a6
	bra	bfastcls
	; #] Cls:

;  #] Subrouts:
;  #[ Init 3D:

*****************************************************************
*	Initialisation des tables et des objets	    *
*---------------------------------------------------------------*
* ATTENTION : Ces routines sont 'scratch‚es' d‚s que les	    *
* polygones sont affich‚s			    *
*****************************************************************


	ds.b	CIRCLEMARGE*4
tableymax

droutscratch

;-------------- Calcul de la table de clipping ------------------

init3d:
	lea	llimit,a0		;table limites gauches
	move	#CLIPSIZE-1,d0 	;taille limite gauche
.rrlimit
	clr	(a0)+		;offset=0
	move.l	#-1,(a0)+		;remplissage
	clr	(a0)+
	dbf	d0,.rrlimit		;dernier ?

	moveq	#0,d0		;compteur pixel
	clr.l	d1
	move	#$ffff,d1		;masque droit
	moveq	#0,d2
.rclimit
	move	d2,d3
	asl	#3,d3
	move	d3,(a0)+		;stocke offset
	move	d1,(a0)+		;stocke trame1
	move	d1,(a0)+		;2 fois
	move	d2,(a0)+
	lsr.l	#1,d1		;decalage masque
	bne.s	.2
	move	#$ffff,d1		;mise en place masque
	addq	#8,d2		;decalage offset 8
.2
	addq	#1,d0		;un pixel de plus
	cmp	#319,d0		;pixel 319 ?
	ble.s	.rclimit		;non, continuer
	move	#CLIPSIZE-1,d0
.rllimit
	move	#$0098*8,(a0)+
	clr.l	(a0)+		;init limite droite
	move	#$0098,(a0)+
	dbf	d0,.rllimit

;--------- Relocation des objets ------------------------------

relocobjects
	lea	startobject(pc),a0
	lea	endobject(pc),a1
.repreloc
	move.l	(a0),d0
	lea	tabreloc(pc),a3
.repsearch
	move.l	(a3)+,d1
	beq.s	.findabort
	cmp.l	d1,d0
	beq.s	.findsearch
	addq	#4,a3
	bra.s	.repsearch
.findsearch
	move.l	(a3)+,(a0)+
	bra.s	.contreloc
.findabort
	addq	#2,a0
.contreloc
	cmp.l	a1,a0
	blt.s	.repreloc


;--------- Calcul de la table des couleurs --------------------

calccolort:
	moveq	#0,d0
	lea	tabcolor(pc),a0
.calccrep:
cpt	set	0
	REPT	4
	btst	#cpt,d0
	sne	d1
	ext	d1
	and	#$aaaa,d1
	btst	#cpt+4,d0
	sne	d2
	ext	d2
	and	#$5555,d2
	or	d1,d2
	move	d2,(a0)+
cpt	set	cpt+1
	ENDR

	addq	#1,d0
	cmp	#255,d0
	ble.s	.calccrep
	rts

tabreloc:
	dc.l	'TST_',testv
	dc.l	'ELL_',ellipse
	dc.l	'FACE',face
	dc.l	'END_',enddrawobject
	dc.l	'STEP',stepface
	dc.l	'LINE',draw_line
	dc.l	0
genfastcls
	lea	bfastcls,a0
	move.l	#$48e0ff7e,d0
	move	#570,d1
.gfcrep
	move.l	d0,(a0)+		genere les movem
	dbf	d1,.gfcrep
	move.l	#$48e0031e,(a0)+	dernier movem
	move	#$4e75,(a0)		rts
	rts
froutscratch:
	ds.b	NBLINE*4+CIRCLEMARGE*4-(froutscratch-droutscratch)
	even

;  #] Init 3D:
;  #[ Data:
	SECTION	DATA

OBS_vrotx	dc.w	0
OBS_vroty	dc.w	0
OBS_vrotz	dc.w	0


OBS_rotx	dc.w	0
OBS_roty	dc.w	0
OBS_rotz	dc.w	0


OBS_v	dc.w	0

clipobject	dc.w	0

	even

*************************************************************
*	Les objets			*
*************************************************************

startobject

ellipses	incbin	ellipses.3d
verre	incbin	verre.3d
disk	incbin	disk.3d
glp	incbin	rdalle.3d
	
endobject

*------------- Table des offsets ligne --------------------------

	dcb.w	100,-1
muls160
cpt	set	0
	REPT	NBLINE
	dc.w	cpt
cpt	set	cpt+160
	ENDR
	dcb.w	100,-1


sincos	incbin	d:\3d.gam\sincos.bin


*************************************************************
*	La palette de couleurs		*
*************************************************************

palette
	incbin	palette.pal
;  #] Data:
;  #[ Bss:
************************************************************
	SECTION	BSS
************************************************************

projetes2	ds.w	NBPOINTS*7
projetes	ds.w	NBPOINTS*7
	ds.l	NBPOINTS
segments
tabcolor	ds.l	256*2
sys_vbl	ds.l	1	adresse ancienne vbl
sys_res	ds	1	resolution systŠme
sys_palette	ds	16	couleurs du systŠme
sys_screen	ds.l	1	adresse ecran systŠme
scr1:	ds.l	1	adresse ecran visualis‚
scr2:	ds.l	1	adresse ecran a visualiser
scr3:	ds.l	1
scr4:	ds.l	1
scr5:	ds.l	1
scr6:	ds.l	1
bfastcls:	ds.l	4000
screen2	ds.b	96256+32000*2
	even

;------------ Table de clipping en x ---------------------

llimit	ds.l	CLIPSIZE*2
tlimit	ds.l	160*2
mlimit	ds.l	160*2
rlimit	ds.l	CLIPSIZE*2

;------------ Map des objets ----------------------------





;------------ Pile -------------------------------------

oldstack	ds.l	1
oldbomb	ds.l	8
userstack	ds.l	1
endstack	ds.b	8000
mystack
	
;  #] Bss:
	END

