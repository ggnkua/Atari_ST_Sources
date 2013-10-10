*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                            MonTT FalconPATCH 3.6                       *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;
;Si votre version de MonTT n'est pas la 3.01 mais comporte encore
;des problŠmes vid‚o, et que le patch complet ne marche pas, voici
;la marche … suivre:
; o R‚perer les points o— MonTT se sert des registres vid‚os
;   (le plus simple: $8260).
; o Regarder le code qui est autour, pour patch1, patch3 et patch4
;   il y a une comparaison de type cmpi.w #2,xx(a6). Il suffit de
;   remplacer le d‚tecteur de patch (les 4 mots longs de comparaison),
;   par ce que vous trouvez A PARTIR de ce cmpi.w #2,xx(a6).
; o Pour patch2, le point de repŠre est un tst.w xx(a6)  (le xx est
;   le mˆme que ci-dessus). Il est rep‚rable car suivi de prŠs par
;   des adresses vid‚os $820d, $8240, etc...
;
;En esp‚rant un peu, tout ceci ne changera pas beaucoup sur d'‚ventuelles
;versions ant‚rieures de MonTT. En attendant un MonFalcon, bien s–r !!!.
;
;Nullos, DNT-Crew 1993.
;
;PS: comme d'habitude, Tab Settings=11  (tabulation de 11), sinon le
;    source prendra un air apocalyptique...

	include	tos_030.s
	include	hard_sys.s

	section	text
	
	StartUp			;Message de bienvenue
	dc.w	$a00a		;
	pea	message(pc)	;
	Gemdos	Cconws		;

.open	clr.w	-(sp)		;Ouvre le fichier original
	pea	inname(pc)		;de MonTT 3.01
	Gemdos	Fopen		;
	move.w	d0,d7		;
	bmi	openerr		;
	pea	MonTT(pc)		;Puis on le lit
	clr.l	-(sp)		;
	addq.b	#1,(sp)		;
	move.w	d0,-(sp)		;
	Gemdos	Fread		;
	move.l	d0,MonTTsize	;conserve la taille du fichier
	bmi	readerr		;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;

.getkey	Gemdos	Crawcin		;Demande de presser une touche
	subi.b	#'1',d0		;
	bmi.s	.getkey		;
	subq.b	#1,d0		;
	bgt.s	.getkey		;
	beq.s	.2		;
.1	bsr.s	megapatch		;
	bra.s	finito		;
.2	bsr.s	minipatch		;
finito	clr.w	-(sp)		;
	pea	outname		;Maintenant, cr‚er et sauver
	Gemdos	Fcreate		;le fichier patch‚.
	move.w	d0,d7		;
	bmi	createrr		;
	pea	MonTT(pc)		;
	move.l	MonTTsize(pc),-(sp)	;
	move.w	d0,-(sp)		;
	Gemdos	Fwrite		;
	cmp.l	MonTTsize(pc),d0	;
	bne	writerr		;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;
	dc.w	$a009		;
	Gemdos	Pterm0		;

minipatch	lea	debug(pc),a0	;Simple d‚buggage
	move.l	#debugsize,d2	;
bracode	bra	mon_patch		;
	

megapatch	lea	patch1(pc),a0	;Code de comparaison
	move.l	#patch1size,d2	;Taille … patcher
	bsr	mon_patch		;Cherche et remplace
	move.l	a1,-(sp)		;
	moveq	#1,d0		;On ‚crase tout jusqu'au
.m0	move.w	#$4e71,(a1)+	;deuxiŠme bra (le 1er fait
	cmpi.b	#$60,(a1)		;partie du code remplac‚)
	bne.s	.m0		;
	subq.w	#1,d0		;
	bpl.s	.m0		;

	lea	patch2(pc),a0	;
	move.l	#patch2size,d2	;
	bsr	mon_patch		;
	move.l	a1,-(sp)		;

	lea	patch3(pc),a0	;
	move.l	#patch3size,d2	;
	bsr	mon_patch		;
	move.l	a1,-(sp)		;

	lea	patch4(pc),a0	;
	move.l	#patch4size,d2	;
	bsr	mon_patch		;
	move.l	a1,-(sp)		;
	moveq	#2,d0		;Idem: on ‚crase tout le
.m1	move.w	#$4e71,(a1)+	;vieux code devenu inutile,
	cmpi.w	#$6100,(a1)	;en ne conservant que les
	bne.s	.m1		;2 derniers bsr.w (qui servent
	subq.w	#1,d0		;… MonTT pour se recalibrer)
	bpl.s	.m1		;

	lea	patch5(pc),a0	;
	move.l	#patch5size,d2	;
	bsr	mon_patch		;

	lea	patch6(pc),a0	;
	move.l	#patch6size,d2	;
	bsr	mon_patch		;

	move.l	#EndPatch-MonReloc,d0	;Taille du d‚placement
	lea	MonTT+2(pc),a0	;
	lea	MonTT+$1c(pc),a2	;
	move.l	a2,a1		;Zone … d‚placer.
	adda.l	(a0)+,a2		;Chercher le d‚but de la
	adda.l	(a0),a2		;zone symboles&relocation
	adda.l	8(a0),a2		;AprŠs les symbols (y'en a pas,
	move.l	(a2),d1		;mais bon..).
	beq.s	.ok		;Y'a une table de relocation ?
	add.l	d0,(a2)+		;Alors on la reloge (!)
	moveq	#0,d2		;
.m2	add.l	d2,d1		;
	add.l	d0,(a1,d1.l)	;Reloge les offsets aussi.
.m3	move.b	(a2)+,d2		;
	beq.s	.ok		;
	cmpi.b	#1,d2		;
	bne.s	.m2		;
	addi.l	#254,d1		;
	bra.s	.m3		;

.ok	lea	(a2,d0.l),a3	;On se place comifo.
.move	move.b	-(a2),-(a3)	;
	cmpa.l	a2,a1		;
	bne.s	.move		;hoplaboum
	lea	EndPatch(pc),a2	;
	lea	MonReloc(pc),a1	;
.copy	move.b	-(a2),-(a3)	;Maintenant, place le code
	cmpa.l	a1,a2		;et les buffers.
	bne.s	.copy		;
	add.l	d0,-(a0)		;Et augmente la taille...
	add.l	d0,MonTTsize	;

	move.l	(sp)+,a1		;Maintenant, reloge les
	lea	-6(a1,d0.l),a1	;jsr (xxxxxxxx.l,pc) 
	move.l	a3,a2		;(depl. longs n‚cessaires)
	sub.l	a1,a2		;
	lea	Mon2Mon-MonReloc(a2),a2;
	move.l	a2,2(a1)		;

	move.l	(sp)+,a1		;
	lea	-6(a1,d0.l),a1	;
	move.l	a3,a2		;
	sub.l	a1,a2		;
	lea	Mon2User-MonReloc(a2),a2;
	move.l	a2,2(a1)		;

	move.l	(sp)+,a1		;
	lea	-6(a1,d0.l),a1	;
	move.l	a3,a2		;
	sub.l	a1,a2		;
	lea	User2Mon-MonReloc(a2),a2;
	move.l	a2,2(a1)		;

	move.l	(sp)+,a1		;
	lea	-6(a1,d0.l),a1	;
	move.l	a3,a2		;
	sub.l	a1,a2		;
	lea	GetMonMode-MonReloc(a2),a2;
	move.l	a2,2(a1)		;

	rts			;C'est fini !!



mon_patch	lea	MonTT-2(pc),a1	;
.bcl	move.l	a0,a2		;
	addq.l	#2,a1		;
	move.l	a1,a3		;Recherche sur a2 et a3
	cmpm.l	(a3)+,(a2)+	;Comparaison du tag, pour
	bne.s	.bcl		;trouver le bon emplacement
	cmpm.l	(a3)+,(a2)+	;
	bne.s	.bcl		;
	cmp.l	(a3)+,(a2)+	;
	bne.s	.bcl		;
	cmp.l	(a3)+,(a2)+	;
	bne.s	.bcl		;
	move.b	(a2)+,(a1)+	;On a trouv‚: recopie le
	subq.w	#1,d2		;patch directement dans le code
	bne.s	*-4		;
	rts			;

openerr	pea	oe(pc)		;Diff‚rents messages d'erreur
	bra.s	break		;
readerr	pea	re(pc)		;
	bra.s	break		;
createrr	pea	ce(pc)		;
	bra.s	break		;
writerr	pea	we(pc)		;
break	Gemdos	Cconws		;
	Gemdos	Crawcin		;
	dc.w	$a009		;
	Gemdos	Pterm0		;

debug	dc.l	$3d788242,$00820c6e	;chaine … trouver dans le
	dc.l	$0002012c,$66061d78	;fichier
debugbeg	dc.l	$3d788242,$00820c6e	;
	dc.l	$0002012c,$66081d78	;
debugsize	equ	*-debugbeg

patch1	dc.l	$0c6e0002,$012c6606
	dc.l	$10388262,$60041038
patch1beg	jsr	(patch1beg.l,pc)	;->GetMonMode
patch1size	equ	*-patch1beg

patch2	dc.l	$4a6e012c,$67061d78
	dc.l	$820d007b,$1d788201
patch2beg	jmp	(patch2beg.l,pc)	;->User2Mon
patch2size	equ	*-patch2beg

patch3	dc.l	$0c6e0002,$012c6608
	dc.l	$11ee0086,$82626006
patch3beg	jmp	(patch3beg.l,pc)	;->Mon2User
patch3size	equ	*-patch3beg

patch4	dc.l	$1e2e0084,$0c6e0002
	dc.l	$012c6622,$be3c0006
patch4beg	jsr	(patch4beg.l,pc)	;->Mon2Mon
patch4size	equ	*-patch4beg

patch5	dc.l	$00030140,$00c80002
	dc.l	$028000c8,$00010280
patch5beg	dc.l	$00030140,$00c80002	;Agrandissement de la
	dc.l	$02800100		;fenˆtre en 640*256 55Hz
patch5size	equ	*-patch5beg

patch6	dc.l	$d0c03803,$11901000	;Correction pour le mode
	dc.l	$41e8ff60,$51cbfff6	;640*256, l'‚cran fait plus
patch6beg	adda.l	d0,a0		;de 32ko,donc il faut mettre
patch6size	equ	*-patch6beg	;un adda.w en version longue..

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷Routines de gestion du screen timer pour Falcon 030÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
MonReloc	movem.l	d0/a0-a1,-(sp)	;On se place en tˆte du code,
	move.l	16(sp),a0		;donc la page de base n'est
	lea	MonBP(pc),a1	;plus … 256 octets sous le
	move.l	a1,(a1)+		;programme-> on en fait une
	addq.l	#4,a0		;copie juste sous lui.
	moveq	#255/4-1,d0	;
	move.l	(a0)+,(a1)+	;
	dbf	d0,*-2		;-> on devient totalement
	movem.l	(sp)+,d0/a0-a1	;invisible.
	bra.w	MonCode		;
;;;;;;;;;;;
;En entr‚e, D0=7  si capture palette User
;             =0  sinon
;A0=adresse de sauvegarde des paramŠtres du Videl
;A1=------- -- ---------- des couleurs
GetVidel	movem.l	d0-d2/a0-a3,-(sp)	;
;	bsr.s	GetSync		;Attendre Vsync (superflu?)
	lea	VidelOrder(pc),a2	;
	moveq	#6-1,d1		;6 groupes
.gv_bcl	move.w	(a2)+,a3		;Adresse Videl
	move.w	(a2)+,d2		;Nombre de registres
	move.w	(a3)+,(a0)+	;Sauver bˆtement
	dbf	d2,*-2		;
	dbf	d1,.gv_bcl		;
	move.b	v_resol.w,(a0)+	;ffff8260 et ffff8265 … part:
	move.b	v_hscroll.w,(a0)+	;ce sont des octets
	lea	v_color.w,a2	;
	tst.w	d0		;Ecran MonTT
	beq.s	.gv_end		;-->(pas besoin de palette)
	move.l	(a2)+,(a1)+	;
	dbf	d0,*-2		;
	lea	v_color030.w,a2	;
	move.l	(a2)+,(a1)+	;Puis la palette Falcon,
	subq.b	#1,d0		;‡a peut servir
	bcc.s	*-4		;
.gv_end	movem.l	(sp)+,d0-d2/a0-a3	;
	rts			;

VidelOrder
	dc.w	v_HHT,6-1		;6 reg. … partir de ffff8282
	dc.w	v_VFT,6-1		;
	dc.w	v_Wide,2-1		;etc..
	dc.w	v_Mode,1-1		;
	dc.w	v_CO,1-1		;
	dc.w	v_SpShift,1-1	;

GetSync	move.w	sr,-(sp)		;On se sert de la VBL systŠme.
	move.w	#$2300,sr		;ATTENTION: comme d'habitude,si
	move.l	_frclock.w,d1	;vous avez install‚ votre VBL,
.gs_wait	cmp.l	_frclock.w,d1	;il FAUT g‚rer l'incr‚mentation
	beq.s	.gs_wait		;de _frclock=$466, sinon ce
	move.w	(sp)+,sr		;test, ceux de MonTT et ceux du
	rts			;systŠme, vont coincer...

;;;;;;;;;;;
;En entr‚e, D0=7  si restauration palette User
;             =0  sinon
;A0=adresse de sauvegarde des paramŠtres du Videl
;A1=------- -- ---------- des couleurs
;A2=Routine indiquant la r‚solution au format Vsetmode.
SetVidel	movem.l	d0-d2/a0-a3,-(sp)	;
	bsr.s	GetSync		;Synchro VBL (indispensable!)
	lea	VidelOrder(pc),a2	;
	moveq	#5-1,d1		;Idem, mais laisser ffff8266
.sv_bcl	move.w	(a2)+,a3		;
	move.w	(a2)+,d2		;
	move.w	(a0)+,(a3)+	;
	dbf	d2,*-2		;
	dbf	d1,.sv_bcl		;
	move.w	(a2)+,a3		;R‚cupŠre fffff8266
	clr.w	(a3)		;EFFACER D'ABORD
	move.w	(a0)+,d1		;
	beq.s	.sv_1_2_4		;Vraiment nul ?
.sv_8_16	move.w	d1,(a3)		;Non, alors fixer
	bra.s	.sv_next		;
.sv_1_2_4	move.w	#-1,-(sp)		;Il faut r‚cup‚rer la
	jsr	([22.w,sp])	;valeur...
	addq.l	#2,sp		;
	moveq	#7,d1		;
	and.w	d0,d1		;Isole le nb de couleurs
	subq.w	#3,d1		;
	bge.s	.sv_next		;¨BUG?:8266=0 -> nb_coul<256 !!
	addq.w	#2,d1		;
	bgt.s	.sv_4		;
	beq.s	.sv_2		;
.sv_1	move.b	#2,$60-$66(a3)	;Ecran monochrome, ici...
	bra.s	.sv_next		;(mono en VGA/RGB -> 8266<>0)
.sv_2	move.b	#1,$60-$66(a3)	;
	andi.w	#$90,d0		;Si 2 bitplans, alors refixer
	cmpi.w	#$90,d0		;v_Mode, OR 1 si VGA&Comp.STE
	seq	d0		;
	andi.w	#1,d0		;
	or.w	-6(a0),d0		;
	move.w	d0,$c2-$66(a3)	;
	bra.s	.sv_next		;
.sv_4	tst.b	d0		;WARNING: le mode 16 couleurs
	bpl.s	.sv_next		;est totalement chiatique
	clr.b	$60-$66(a3)	;Si Comp.STE, annuler $8260,
	lsr.w	#5,d0		;et refixer v_Mode OR 1 si
	bcc.s	.sv_next		;c'est du VGA.
	ori.w	#1,$c2-$66(a3)	;
	;S‚curit‚: refixer Wide&Wrap, parfois effac‚ (en rgb 1280 p.ex)
.sv_next	move.l	-10(a0),$0e-$66(a3)	;
	move.b	1(a0),-(a3)	;Finalement, le d‚calage,

	lea	v_color.w,a2	;
	move.l	(sp),d0		;Selon MonTT ou User,
	beq.s	.sv_mon		;remet la palette.
.sv_user	move.l	(a1)+,(a2)+	;
	dbf	d0,*-2		;
	lea	v_color030.w,a2	;
	move.l	(a1)+,(a2)+	;
	subq.b	#1,d0		;
	bcc.s	*-4		;
.sv_end	movem.l	(sp)+,d0-d2/a0-a3	;
	rts			;
.sv_mon	move.l	(a1)+,(a2)		;
	move.l	(a1)+,v_color030.w	;
	move.l	(a1)+,v_color030+4.w	;
	bra.s	.sv_end		;
;;;;;;;;;;;
;D‚termine les modes possibles et autoris‚s pour MonTT...
GetMonMode	movem.l	d0-d2/a0-a2,-(sp)	;
	lea	UserVidel(pc),a0	;Prend les paramŠtres de
	lea	UserColor(pc),a1	;l'‚cran d'arriv‚e
	moveq	#7,d0		;
	bsr	GetVidel		;

	Xbios	mon_type		;
	cmpi.w	#3,d0		;TV ?
	bne.s	*+4		;
	moveq	#1,d0		;Oui, idem RGB
	mulu	#20*2,d0		;
	lea	.preset(pc,d0.w),a0	;R‚cupŠre les paramŠtres
	move.w	(a0)+,d0		;du Videl, selon le type
	move.b	d0,$84(a6)		;de moniteur of course.
	lea	MonMode(pc),a1	;
	move.w	(a0)+,(a1)		;
	lea	MonVidel(pc),a1	;
	move.l	a0,(a1)		;
	
	move.w	#$7fff,-(sp)	;
	trap	#14		;Demande l'adresse de
	addq.l	#2,sp		;la table des routines.
	lea	InVsetmode(pc),a1	;
	move.l	88*4(a0),a2	;
	move.l	a2,(a1)		;Sauve l'adresse VsetMode.
	movem.l	(sp)+,d0-d2/a0-a2	;
	rts			;

;ATTENTION: NE TOUCHEZ EN AUCUN CAS A CES DONNEES AU HASARD, VOUS RISQUEZ
;DE GRILLER L'ELECTRONIQUE DE VOTRE MONITEUR !!!!.
.preset	dc.w	2,$0088		;640*400 1 bitplan, ‚cran monochrome
	dc.w	$001a,$0000,$0000,$020f,$000c,$0014
	dc.w	$03e9,$0000,$0000,$0043,$0363,$03e7
	dc.w	$0000,$0028,$0008,$0080,$0000,$0200

	dc.w	1,_640x|_4c|_ste	;640*256 2 bitplans 55Hz, ‚cran RGB/TV
	dc.w	$003e,$0032,$0009,$023f,$001c,$0034
	dc.w	$0241,$0235,$002f,$0034,$0232,$023b
	dc.w	$0000,$0050,$0004,$0081,$0000,$0100

	dc.w	4,_640x|_16c|_vga	;640*480 4 bitplans, ‚cran VGA
	dc.w	$00c6,$008d,$0015,$02a3,$007c,$0096
	dc.w	$0419,$03ff,$003f,$003f,$03ff,$0415
	dc.w	$0000,$00a0,$0008,$0186,$0000,$0000
;;;;;;;;;;;
User2Mon	movem.l	d0-d1/a0-a2,-(sp)	;
	move.l	v_base.w,d0	;
	lsl.w	#8,d0		;
	move.b	v_base_l.w,d0	;
	lsl.l	#8,d0		;
	lsr.l	#8,d0		;
	move.l	d0,$78(a6)		;
	cmp.l	$70(a6),d0		;C'est l'‚cran MonTT ???
	beq.s	.fini		;
;Petite remarque: lorsque l'on trace un programme, MonTT effectue un saut
;dans cette routine, mˆme s'il ne tient pas … faire un swap ‚cran. J'avoue
;ne pas bien avoir saisi l'astuce... car … ma connaissance, on ne peut pas
;tracer un programme … partir de l'‚cran User... All“ la terre ?

	move.l	d0,$74(a6)		;On est bien sur User
	lea	UserVidel(pc),a0	;
	lea	UserColor(pc),a1	;->Conserve les infos de
	moveq	#7,d0		;r‚solution.
	bsr	GetVidel		;

	movea.l	MonVidel(pc),a0	;
	lea	MonColor(pc),a1	;Maintenant, remet le
	lea	LameMon(pc),a2	;Videl pour MonTT.
	moveq	#0,d0		;
	bsr	SetVidel		;
	move.l	$70(a6),d0		;et fini de r‚-installer
	move.b	d0,$ffff820d.w	;ses paramŠtres.
	lsr.w	#8,d0		;
	move.l	d0,$ffff8200.w	;
.fini	movem.l	(sp)+,d0-d1/a0-a2	;
	rts			;

;;;;;;;;;;;
Mon2User	movem.l	d0/a0-a2,-(sp)	;
	lea	UserVidel(pc),a0	;Remet nos paramŠtres
	lea	UserColor(pc),a1	;
	movea.l	InVsetmode(pc),a2	;
	moveq	#7,d0		;
	bsr	SetVidel		;
	move.l	$74(a6),d0		;
	move.b	d0,$ffff820d.w	;
	lsr.w	#8,d0		;
	move.l	d0,$ffff8200.w	;R.A.S
	movem.l	(sp)+,d0/a0-a2	;
	rts			;

;;;;;;;;;;;
Mon2Mon	movem.l	d0/a0-a2,-(sp)	;
	lea	MonColor+12(pc),a1	;
	move.l	-(a1),d0		;
	move.l	-(a1),4(a1)	;Inverse les couleurs de
	move.l	d0,(a1)		;l'‚cran du debugger, tant
	move.l	-(a1),d0		;qu'on y est.
	swap	d0		;
	move.l	d0,(a1)		;
	movea.l	MonVidel(pc),a0	;Re-installe MonTT par la
	lea	LameMon(pc),a2	;force.
	moveq	#0,d0		;
	bsr	SetVidel		;
	move.l	$70(a6),d0		;
	move.b	d0,$ffff820d.w	;
	lsr.w	#8,d0		;
	move.l	d0,$ffff8200.w	;
	movem.l	(sp)+,d0/a0-a2	;
	moveq	#0,d7		;Si on oublie ‡a, y'a comme
	move.b	$84(a6),d7		;un malaise...
	rts			;

;;;;;;;;;;;
LameMon	move.w	MonMode(pc),d0	;Le systŠme n'est pas au
	rts			;courant...

InVsetmode	ds.l	1		;Tout ‡a pour nous...
MonMode	ds.w	1		;
MonVidel	ds.l	1		;
MonColor	dc.w	$0000		;Couleur de fond	\
	dc.w	$0EEE		;------- de 1er plan	/STE
	dc.l	$00000000		;
	dc.l	$ECEC00EC		;Idem, mais en VGA
	;Rappel: sur STE c'est xxxx RRRR GGGG BBBB            (sur un mot)
	;     sur Falcon RRRRRRxx GGGGGGxx xxxxxxxx BBBBBBxx (sur un mot-long)
	;D‚merdez vous pour cr‚er votre palette favorite.
UserVidel	ds.w	6+6+2+1+1+1+1	;
UserColor	ds.w	16		;
hello	dc.b	"Ceci est une version de MonTT patch‚ pour le Falcon 030 grƒce …",$d,$a
	dc.b	"MONPATCH 3.6, programm‚ par NulloS/DNT-Crew le 04/11/1993.",$d,$a
	dc.b	$d,$a
	dc.b	"Je vous remercie d'avoir utilis‚ ce programme de patch, qui vous a",$d,$a
	dc.b	"donc permis de transformer un MonTT explosant votre moniteur … la",$d,$a
	dc.b	"moindre occasion, en un superbe d‚bugger tournant dans toutes les",$d,$a
	dc.b	"r‚solutions possibles et imaginables, mˆme celles cr‚‚es … l'aide",$d,$a
	dc.b	"de FalconScreen (du style 832*440 en 65Hz !).",$d,$a
	dc.b	$d,$a
	dc.b	"Bref, je suis g‚nial !!",$d,$a
	dc.b	$d,$a
	dc.b	"En fait, je me tape ce texte minable parce que j'ai 1ko … rajouter",$d,$a
	dc.b	"en fin du code de MonTT, et que c'est plus smart que de remplir avec",$d,$a
	dc.b	"de bˆtes $00... J'en profite donc pour vous dire que ce patch m'a demand‚",$d,$a
	dc.b	"pas moins de 1 semaine de recherche, pour les 2 premiŠres versions, et",$d,$a
	dc.b	"autant pour la version 3.6 (haaa, les joies du Videl: salooooooope !).",$d,$a
	dc.b	"Donc plein de travail, mais ‡a en valait la peine.",$d,$a
	dc.b	$d,$a
	dc.b	"En plus maintenant, dans la version 3, ce n'est pas 1ko, mais carr‚ment",$d,$a
	dc.b	"1,25ko, c'est l'inflation permanente... Enfin bon, cela reste assez",$d,$a
	dc.b	"raisonnable. Putain, vivement un vrai d‚bugger Falcon, sans risques de",$d,$a
	dc.b	"plantage d–s au c“t‚ bidouille du patch",$d,$a
	dc.b	$d,$a
	dc.b	"Allez, j'arrive au bout. Bon d‚buggage, et que vive le Falcon !!",0
	dcb.b	1024+256-(*-hello),$88
MonBP	equ	hello+1024
MonCode	equ	*

EndPatch	equ	*		;Fin du m‚gapatch
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	section	data
message	dc.b	27,"E+-----------------------------------------+",$d,$a
	dc.b	    "|          MonTT-FalconPatch 3.6          |",$d,$a
	dc.b	    "+-----------------------------------------+",$d,$a
	dc.b	    "    ®(C)oderight NulloS//DNT-Crew 1993¯",$d,$a
	dc.b	$a,$a,"Votre choix: 1) Patch complet sp‚cial Falcon030",$d,$a
	dc.b	      "             2) D‚buggage simple de MonTT",$d,$a
	dc.b	">?",$d,$a,0
oe	dc.b	"Impossible d'ouvrir le fichier "
inname	dc.b	"mon_ori.prg",0
ce	dc.b	"Impossible de cr‚er le fichier "
outname	dc.b	"mon_f030.prg",0
re	dc.b	"Erreur de lecture !",$d,$a,0
we	dc.b	"Erreur d'‚criture: disque plein ?",$d,$a,0
	even
	section	bss
MonTTsize	ds.l	1
MonTT	ds.b	80000
stack	ds.w	256

