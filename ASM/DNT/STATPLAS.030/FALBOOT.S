;Ce boot secteur affiche des espŠces de plasma en 65536 couleurs.
;Il fonctionne en 768*480 True-Color (50 ou 60Hz), et sans doute
;en VGA 320*480 (d‚sol‚, je n'ai pas pu tester vu que je n'ai pas
;ce type de moniteur, vu que le code marche aussi en 384*480,
;y'a pas de raison que ‡a plante).
;C'est vraiment trŠs simple, et le Falcon n'est absolument pas exploit‚,
;vu que c'est le 68030 qui se tape tout le boulot. Enfin bon il faut un
;d‚but … tout.
;
;Comme d'habitude, le label TEST permet de g‚n‚rer un programme qui
;se lance depuis le bureau (ou depuis votre assembleur). S'il est
;d‚sactiv‚, le boot est vraiment assembl‚. Il faut alors l'installer
;avec le booter_2.prg (son source est disponible avec le DNT-Paper 3,
;ce dernier vous permettant d'avoir aussi son mini-mode d'emploi ainsi
;que pleins d'autres boot-secteurs)
;Pour assembler ce programme, vous DEVEZ avoir sous la main les deux
;fichiers include ci-dessous, pr‚sents avec ce programme sur le
;DNT-Paper 5...
;
;Voil…, que les Dieux soient avec nous, et longue vie au Falcon!.
;
;(C)Nullos//DNT-Crew 1993

	include	tos_030.s
	include	hard_sys.s

PINGPONG	;Si d‚fini, 10% plus lent et une image jolie sur deux
	;Si pas d‚fini, rapide et une image cool sur trois
TEST	;Essais sous Genst
;DEBUG	;Monst oblige, pas de chg
	IFD	TEST		;
	StartUp			;On fait un malloc plus loin..
	clr.l	-(sp)		;
	Gemdos	Super		;Si d‚bug, alors on
	move.l	d0,-(sp)		;se la joue facile:
	bsr.s	Falboot		;hop!
	Gemdos	Super		;
	Gemdos	Pterm0		;
	ENDC			;
	
Falboot	move.l	cookie_jar.w,d0	;Chercher le type de
	beq.s	.nofalcon		;machine: on peut difficilement
	movea.l	d0,a0		;faire du 768*480 true-color
.scan	move.l	(a0)+,d0		;sur un stf de base...
	beq.s	.nofalcon		;
	cmpi.l	#'_MCH',d0		;
	beq.s	.verify		;
	addq.l	#4,a0		;
	bra.s	.scan		;
.verify	move.w	(a0)+,d0		;
	subq.w	#3,d0		;_MCH=3 ?
	beq.s	Vazyraoul		;Oui, c'est super!
.nofalcon	pea	sorry(pc)		;Ah, dommage...
	Gemdos	Cconws		;
	rts			;

	RSRESET
xcoeff	rs.w	1		;0 si 768, 1 si 320
xmax	rs.w	1		;r‚solution x
old_rez	rs.w	1		;
old_screen	rs.l	1		;No comment
old_cacr	rs.l	1		;
rx	rs.w	1		;
ry	rs.w	1		;Centre des cercles
gx	rs.w	1		;rED, gREEN et bLUE
gy	rs.w	1		;
bx	rs.w	1		;
by	rs.w	1		;
ramp	rs.w	1		;
gamp	rs.w	1		;Amplitude de ces cercles
bamp	rs.w	1		;
varsize	rs.b	0

Buf	equr	a6

Vazyraoul	pea	768*480*2+varsize	;Reserve sagement un bloc
	Gemdos	Malloc		;(sinon boum!)
	move.l	d0,Buf		;Variables locales

	movec	cacr,d0		;Conserve le cache
	move.l	d0,old_cacr(Buf)	;
	move.l	#$3111,d0		;Active le cache
	movec	d0,cacr		;
	move.w	#-1,-(sp)		;
	Xbios	Vsetmode		;Demande rez actuelle
	move.w	d0,old_rez(Buf)	;
	move.l	_v_bas_ad.w,old_screen(Buf)
	lea	present(pc),a5	;
	moveq	#_pal,d1		;Bit 50/60Hz
	and.w	d0,d1		;(on conserve la fr‚quence)
	ori.w	#_640x|_400y|_ovr|_65kc,d1;768*480 True-color
	move.l	#0<<16+767,xcoeff(Buf);Par d‚faut, ratio=0 rez=768
	lsr.w	#5,d0		;
	bcc.s	.rgb		;Moniteur VGA?
.vga	moveq	#_vga|_65kc,d1	;alors 320*480 True Color
	move.l	#1<<16+319,xcoeff(Buf);et r‚solution moiti‚
	move.b	#32+5,midvga(a5)	;
.rgb
	IFND	DEBUG		;Monst n'appr‚cie pas ce qui
	move.w	d1,-(sp)		;suit...
	move.w	#3,-(sp)		;->Active la r‚solution
	pea	varsize(Buf)	;
	move.l	(sp),-(sp)		;
	Xbios	Setscreen030	;vroom
	ENDC			;
	pea	(a5)		;
	Gemdos	Cconws		;
.doozetwist
	lea	rx(Buf),a3		;Commence par tirer les
	move.l	xmax(Buf),d6	;centres
	move.w	#479,d6		;D6=rez_x|rez_y
	moveq	#6-1,d7		;
.choose	add.l	_hz_200.w,d5	;
	mulu	#49713,d5		;Formule style "n'importe quoi"
	move.l	d5,d0		;C'est de l'al‚atoire grossier
	swap	d6		;mais ‡a marche.
	mulu.w	d6,d0		;
	swap	d0		;
	move.w	d0,(a3)+		;
	dbf	d7,.choose		;
	moveq	#2,d0		;
	move.l	#(63<<16+31),d3	;
.amp	lsr.l	#8,d5		;
	moveq	#$7f,d2		;Maintenant, tire les
	and.b	d5,d2		;amplitudes avec le dernier
	mulu	d3,d2		;mot-long obtenu.
	addq.w	#1,d2		;On masque avec $7F pour ‚viter
	move.w	d2,(a3)+		;les grosses amplitudes qui
	dbf	d0,.amp		;sont ennuyeuses.

ecran	equr	a2
rgb_xy	equr	a5
rgb_amp	equr	a4
x	equr	d0
y	equr	d1
x2	equr	d2
y2	equr	d3
red	equr	d4
green	equr	d4
blue	equr	d5
mask	equr	d6
compteur	equr	d7
	
	lea	varsize(Buf),ecran	;Adresse ‚cran
	move.w	#479,y		;Annuler y au d‚but
	IFND	PINGPONG		;
	move.l	#(63<<16+31)*1,mask	;Charger le masque:amplitude RVB
	ELSE			;
	move.l	#(63<<16+31)*2,mask	;
	ENDC
.ybcl	move.w	xmax(Buf),x	;(R=B=0..31 V=0..63)
.xbcl	lea	rx(Buf),rgb_xy	;
	lea	ramp(Buf),rgb_amp	;On boucle dessus, c'est
	moveq	#2,compteur	;plus ‚conomique en place
.calc	move.w	x,x2		;
	sub.w	(rgb_xy)+,x2	;Rayon^2=(x-xc)^2+(y-yc)^2
	move.w	xcoeff(Buf),y2	;768÷2*320 -> corrige le
	asl.w	y2,x2		;ratio x/y pour le VGA
	muls.w	x2,x2		;
	move.w	y,y2		;
	sub.w	(rgb_xy)+,y2	;
	muls.w	y2,y2		;
	add.l	y2,x2		;
	divu.w	(rgb_amp)+,x2	;Puis Rayon^2/(amplitude*mask)
	IFD	PINGPONG		;
	add.w	x2,x2		;
	cmp.w	mask,x2		;0..31 (ou 0..63)
	ble.s	*+6		;     \
	sub.w	mask,x2		;      30..1 = aller-retour
	not.w	x2		;
	and.w	mask,x2		;
	lsr.w	#1,x2		;
	ELSE			;
	and.w	mask,x2		;Aller simple
	ENDC			;
	swap	red		;Rotation des registres pour
	move.w	blue,green		;faire entrer les composantes
	move.w	x2,blue		;
	swap	mask		;
	dbf	compteur,.calc	;composante suivante

	swap	mask		;3+1=4 swap:retour case d‚part
	lsl.l	#5,green		;
	or.w	green,blue		;
	swap	red		;
	lsl.w	#(16-5)-5,red	;Aligne rouge vert et bleu
	or.w	red,blue		;
	move.w	blue,(ecran)+	;Combine et hop, c'est fait
	dbf	x,.xbcl		;Fin de ligne ?
	dbf	y,.ybcl		;
	Gemdos	Crawcin		;
	cmpi.b	#' ',d0		;
	bne	.doozetwist	;Si pas espace, encore
	move.l	old_cacr(Buf),d0	;
	movec	d0,cacr		;Sinon cassos aprŠs
	move.w	old_rez(Buf),-(sp)	;restauration
	move.w	#3,-(sp)		;
	move.l	old_screen(Buf),-(sp)	;+4 car d‚j… -(sp)
	move.l	(sp),-(sp)		;
	Xbios	Setscreen030	;
	move.l	Buf,-(sp)		;
	Gemdos	Mfree		;
	rts			;

sorry	dc.b	"How to see this great boot?",$d,$a
	dc.b	"Buy a Falcon030 !",$d,$a,0
present	dc.b	27,'Y',32+15
midvga	equ	*-present
	dc.b	32+33,"STATIC PLASMA (c)DNT-Crew 1993",0
	IFD	TEST
	EVEN
	section	bss
stack	ds.w	1024
	ENDC