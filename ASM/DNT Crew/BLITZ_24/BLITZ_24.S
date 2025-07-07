;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Programme de convertions d'images 24 bits au format RAW ou TGA
;pour STE et STF avec blitter.
;Le fichier image cr‚e par ce convertisseur est .BIM
;Il comporte le bloc de palettes (=(48+7)*199*4 octets) et le bloc images
;(deux ‚crans 64000 octets) soit au total 107780 octets (packing is good
;for you...)
;C'est ‚norme, mais je signale que compact‚ ou non, c'est plus petit que
;l'original...
;
;(C)oderight Nullos//DNT-Crew 1992...
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	OPT	O+,W-	;Optimisations, pas de Warnings

start	move.l	4(sp),a0		;
	lea	stackup,sp		;
	movea.l	$0c(a0),a1		;Text
	adda.l	$14(a0),a1		;    +Data
	adda.l	$1c(a0),a1		;         +Bss
	lea	256(a1),a1		;             +BasePage
	movem.l	a0-a1,-(sp)	;Taille … r‚server, donc
	clr.w	-(sp)		;
	move.w	#$4a,-(sp)		;
	trap	#1		;
	lea	12(sp),sp		;
	bsr	Appl_Init		;Initialise l'AES
	lea	InfoDis1,a0	;Une petite pub...
	bsr	Form_Alert		;hop-l…
	lea	InfoDis2,a0	;
	bsr	Form_Alert		;

	move.l	#scr_buf+256,d0	;Initialise les ‚crans
	clr.b	d0		;
	move.l	d0,ecran		;
	addi.l	#32000,d0		;
	move.l	d0,ecran+4		;
	bsr	Antiparasite_Convert_x;x->palette d‚parasit‚e
	bsr	Precalc_Screen_x	;x->plot
	pea	Test_STE		;d‚tecte STE/STF+blitter
	move.w	#38,-(sp)		;routine superviseur
	trap	#14		;
	addq.l	#6,sp		;
	tst.w	Work_x		;Test correct ?
	beq.s	.Ok_man		;ouaip
	lea	Bliterr,a0		;pas de blitter !
	bsr	Form_Alert		;
	bra	Appl_Exit		;finito
	

.Ok_man	lea	path,a2		;Construit le chemin par d‚faut
	move.w	#$19,-(sp)		;Demande le lecteur courant
	trap	#1		;
	addi.b	#"A",d0		;transform‚ en ASCII
	move.b	d0,(a2)+		;
	move.b	#":",(a2)+		;
	clr.w	-(sp)		;Demande au Gemdos le chemin
	move.l	a2,-(sp)		;d'accŠs du lecteur courant
	move.w	#$47,-(sp)		;
	trap	#1		;
	lea	10(sp),sp		;r‚tablit la pile
.pathend	tst.b	(a2)+		;cherche la fin du chemin
	bne.s	.pathend		;
	subq.l	#1,a2		;corrige le ()+
	move.b	#"\",(a2)+		;Pose le masque juste derriŠre
	move.b	#"*",(a2)+		;*.*=tous les fichiers.
	move.b	#".",(a2)+		;
	move.b	#"*",(a2)+		;
	clr.b	(a2)+		;
	clr.b	name		;pas encore de nom
	move.w	#13,entrelace	;entrelacement par d‚faut

MasterBcl	lea	path,a0		;chemin d'accŠs+*.*
	lea	name,a1		;nom du dernier fichier
	lea	filename,a2	;adresse de retour
	bsr	FileSelect		;go!
	beq	.MB_end		;Si problŠme..
	lea	KelForm,a0		;RAW ou TGA ?
	bsr	Form_Alert		;
	subq.w	#1,d0		;0=RAW 1=TGA 2=BIM
	move.w	d0,imtype		;
	subq.w	#2,d0		;
	beq	.AffichBIM		;Affichage simple ?
	lea	ConvTyp,a0		;Demande des infos..
	bsr	Form_Alert		;
	subq.w	#2,d0		;cf paramŠtres de convertion
	move.w	d0,flickflag	;

.MB_0	lea	ConvNum,a0		;facteur d'entrelacement
	bsr	Form_Alert		;hop
	subq.w	#2,d0		;
	beq.s	.MB_2		;ok,choix effectu‚
	add.w	entrelace,d0	;+ ou -1
	cmpi.w	#100,d0		;Faut pas d‚conner non plus..
	blt.s	*+4		;
	moveq	#99,d0		;
	cmpi.w	#-100,d0		;
	bgt.s	*+4		;
	moveq	#-99,d0		;
	moveq	#"+",d1		;nombre positif
	andi.l	#$0000ffff,d0	;annule bits 16-31
	move.w	d0,entrelace	;yoplaboum
	bpl.s	*+6		;
	moveq	#"-",d1		;ah non, n‚gatif !
	neg.w	d0		;
	lea	_CN_str+3,a0	;sort le nouveau nombre..
	moveq	#1,d2		;deux chiffres.
.MB_1	divu	#10,d0		;hop
	swap	d0		;
	addi.w	#"0",d0		;
	move.b	d0,-(a0)		;
	clr.w	d0		;
	swap	d0		;
	dbf	d2,.MB_1		;
	move.b	d1,-(a0)		;
	bra.s	.MB_0		;

.MB_2	lea	ConvHtz,a0		;Quelle fr‚quence ?
	bsr	Form_Alert		;
	subq.w	#1,d0		;
	add.w	d0,d0		;
	move.b	d0,specsync	;
	bsr	Load_Image		;On procŠde au chargement
	beq	.MB_end		;en cas d'erreur
	move.l	a0,image		;conserve adresse image

	clr.l	-(sp)		;Superviseur
	move.w	#$20,-(sp)		;
	trap	#1		;
	move.l	d0,2(sp)		;
	bsr	InitHard		;Initialisation Hardware
	move.l	#DummyVBL,$70.w	;du ST
	move.l	ecran,d0		;On montre ce qui se
	lsr.w	#8,d0		;passe … l'‚cran
	move.l	d0,$ffff8200.w	;pour patienter...

	movea.l	image,a0		;
	movea.l	ecran,a1		;
	lea	pal_buf,a2		;
	move.w	flickflag,d0	;
	move.w	entrelace,d1	;
	move.w	imtype,d2		;
	bsr	Convert_24Bits	;Convertion proprement dite

.MB_aff	clr.w	flickflag		;indicateur de swap
	stop	#$2300		;synchro vbl
.sync_bcl	stop	#$2300		;
	move.b	specsync,$ffff820a.w	;passage en 50/60 Hz
	movem.l	ecran,d0-d1	;swap ‚cran
	exg.l	d0,d1		;
	movem.l	d0-d1,ecran	;
	lsr.w	#8,d1		;mise … jour de l'adresse
	move.l	d1,$ffff8200.w	;‚cran
	lea	BLIT_base.w,a0	;ParamŠtre le blitter
	move.w	#2,b_dst_xinc(a0)	;couleurs par couleurs,puis
	move.w	#-30,b_dst_yinc(a0)	;retour en d‚but de palette
	move.l	#-1,b_mask1(a0)	;pas de masquage
	move.w	#-1,b_mask3(a0)	;
	move.w	#2,b_src_xinc(a0)	;tout le bloc de palettes
	move.w	#2,b_src_yinc(a0)	;… la fois
	move.b	#2,b_hop(a0)	;aucune op‚rations logique
	move.b	#3,b_op(a0)	;
	clr.b	b_mode(a0)		;pas de d‚calage
	movem.l	palette,a4-a5	;swap des palettes
	exg.l	a4,a5		;
	movem.l	a4-a5,palette	;
	lea	7*199*2(a4),a5	;a4=palettes de bordure
	move.l	a5,b_src_adr(a0)	;a5=palettes centrales
	move.l	#v_color0,b_dst_adr(a0);
	move.w	#16,b_x_count(a0)	;16 couleurs par palettes
	tst.b	specsync		;selon la synchro
	bne.s	*+8		;
	bsr.w	Spec_60Hz		;
	bra.s	*+6		;
	bsr.w	Spec_50Hz		;

	not.w	flickflag		;couple d'images affich‚es?
	bne	.sync_bcl		;non (il faut un nombre
	cmpi.b	#$39,$fffffc02.w	;pair de swapping...)
	bne	.sync_bcl		;Barre espace ?
	bsr	ExitHard		;restituer le ST
	trap	#1		;repasse en utilisateur
	addq.l	#6,sp		;
	
	subq.w	#2,imtype		;image BIM ?
	beq.s	.MB_3		;alors pas besoin de sauver!
	lea	SavePic,a0		;Sauvegarder l'image ?
	bsr	Form_Alert		;
	subq.w	#1,d0		;
	bne.s	.MB_3		;
	lea	path,a0		;chemin d'accŠs+*.*
	lea	name,a1		;nom du dernier fichier
	lea	filename,a2	;adresse de retour
	bsr	FileSelect		;go!
	beq	.MB_2		;Si problŠme..
	bsr	Save_Image		;sinon,let's go
	
.MB_3	move.l	image,-(sp)	;libŠre la m‚moire
	move.w	#$49,-(sp)		;de l'image
	trap	#1		;
	addq.l	#6,sp		;

.MB_end	lea	NextOne,a0		;
	bsr	Form_Alert		;une autre ?
	subq.w	#1,d0		;
	beq	MasterBcl		;
	bra	Appl_Exit		;


.AffichBIM				;Affichage d'un fichier BIM
	lea	ConvHtz,a0		;Quelle fr‚quence ?
	bsr	Form_Alert		;
	subq.w	#1,d0		;
	add.w	d0,d0		;
	move.b	d0,specsync	;
	bsr	Load_Image		;charge le fichier
	beq.s	.MB_end		;en cas de problŠmes
	move.l	a0,image		;
	lea	pal_buf,a1		;recopie les palettes
	move.w	#(48+7)*199-1,d0	;
.AB_0	move.l	(a0)+,(a1)+	;hop!
	dbf	d0,.AB_0		;
	move.l	ecran,a1		;puis les ‚crans
	move.w	#7999,d0		;
.AB_1	move.l	(a0)+,(a1)+	;
	move.l	(a0)+,(a1)+	;
	dbf	d0,.AB_1		;
	clr.l	-(sp)		;Superviseur
	move.w	#$20,-(sp)		;
	trap	#1		;
	move.l	d0,2(sp)		;
	bsr	InitHard		;Initialisation Hardware
	move.l	#DummyVBL,$70.w	;du ST
	bra	.MB_aff		;et maintenant,affiche
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;D‚termine le type de machines
Test_STE	movem.l	d0/a0,-(sp)	;
	lea	$5a0.w,a0		;Cookie jar
	move.l	(a0),d0		;
	beq.s	.TS_blit		;STF, test le blitter
	movea.l	d0,a0		;
.TS_0	move.l	(a0)+,d0		;
	beq.s	.TS_blit		;Fin du cookie-jar ?
	cmpi.l	#"_VDO",d0		;Type de shifter vid‚o ?
	beq.s	.TS_1		;oui
	addq.l	#4,a0		;
	bra.s	.TS_0		;
.TS_1	tst.w	(a0)		;Alors, STF ou STE ?
	beq.s	.TS_blit		;si nul, alors STF
	move.l	#Convert_STE,Convert_rgb;sinon, STE=> table kivabien
.TS_blit	movea.l	$8.w,a0		;Test la pr‚sence du blitter
	movea.l	sp,a1		;sauve la pile
	move.l	#.TS_noblit,$8.w	;erreur de bus d‚tourn‚e
	move.w	#-1,Work_x		;pas de blitter par d‚faut
	tst.b	b_ctrl+BLIT_base.w	;tentative d'accŠs
	clr.w	Work_x		;y'en a un !!
.TS_noblit	move.l	a0,$8.w		;
	movea.l	a1,sp		;
	move.l	(sp)+,d0		;
	movea.l	(sp)+,a0		;
	rts			;
;A ma connaissance, il n'y a pas de moyen de savoir si le blitter est
;pr‚sent sans avoir … tester soi-mˆme. Pour cela, on d‚tourne l'erreur
;de bus ($8.w). Puis on fait une tentative d'accŠs blitter. Si il
;y en a un, tout se passe bien, l'instruction Work_x est ‚x‚cut‚e,
;sinon il y a une erreur de bus, et on se retrouve directement
;sur .TS_noblit . C'est pas trŠs po‚tique, mais ca marche.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; Routines d'affichage des images ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  En entr‚e ...                      ;;;;;
;A0=adresse blitter   A4=couleurs bordure
;Le blitter doit avoir ‚t‚ pr‚par‚ au transfert...
;
;;;;;  Pendant les routines qui suivent.. ;;;;;
;A0=adresse y_count.  D0=nb_pal/ligne=3 (blitter)
;A1=adresse b_ctrl    D1=lancement du blitter
;A2=adresse couleur 0 pour bordure noire     D2=0
;A3=adresse    "    9        "
;A4=couleurs compl‚mentaires de la bordure
;A5=travail sur le transferts de bordure
;D3=Nombre-1 de lignes … afficher
;(ces registres sont initialis‚s plus bas)
;;;;;  Synchronisation ‚cran 50Hz         ;;;;;
Spec_50Hz
	move.b	v_count_l.w,d0
	beq.s	*-4
	neg.b	d0
	ror.l	d0,d0
	moveq	#4,d0
	ror.l	d0,d0
	moveq	#62,d0
	ror.l	d0,d0
;;;;;  Chargement des registres           ;;;;;
	moveq	#$03,d0
	moveq	#$c0,d1
	moveq	#$00,d2
	move.w	#198,d3
	lea	b_ctrl(a0),a1
	lea	b_y_count(a0),a0
	lea	v_color0.w,a2
	lea	v_color9.w,a3
;;;;;  Lancement du transfert de couleurs ;;;;;
.line_bcl	movea.l	a3,a5
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	d0,(a0)
	move.b	d1,(a1)
	move.w	d2,(a2)
	nop
	nop
	dbf	d3,.line_bcl
	bra.s	Spec_End
;;;;;  Synchronisation ‚cran 50Hz         ;;;;;
Spec_60Hz
	move.b	v_count_l.w,d0
	beq.s	*-4
	neg.b	d0
	ror.l	d0,d0
	moveq	#2,d0
	ror.l	d0,d0
	moveq	#62,d0
	ror.l	d0,d0
;;;;;  Chargement des registres           ;;;;;
	moveq	#$03,d0
	moveq	#$c0,d1
	moveq	#$00,d2
	move.w	#198,d3
	lea	b_ctrl(a0),a1
	lea	b_y_count(a0),a0
	lea	v_color0.w,a2
	lea	v_color9.w,a3
;;;;;  Lancement du transfert de couleurs ;;;;;
.line_bcl	movea.l	a3,a5
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	move.w	(a4)+,(a5)+
	move.w	d0,(a0)
	move.b	d1,(a1)
	move.w	d2,(a2)
	nop
	dbf	d3,.line_bcl
Spec_End	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Chargement et d‚compactage du fichier demand‚.
;Renvoie en A0 l'adresse de l'image finale...
Load_Image
	movem.l	d0-d7/a1-a6,-(sp)	;
	clr.w	-(sp)		;on commence par ouvrir
	pea	filename		;le fichier
	move.w	#$3d,-(sp)		;
	trap	#1		;
	addq.l	#8,sp		;
	move.w	d0,d7		;
	bmi	.LI_err2		;
	
	move.w	#2,-(sp)		;Aller en fin de fichier
	move.w	d7,-(sp)		;avec un Seek
	clr.l	-(sp)		;
	move.w	#$42,-(sp)		;
	trap	#1		;
	move.l	d0,d6		;=>taille du fichier !
	clr.w	-(sp)		;Puis revient en tˆte
	move.w	d7,-(sp)		;du fichier
	clr.l	-(sp)		;
	move.w	#$42,-(sp)		;
	trap	#1		;
	lea	20(sp),sp		;

	pea	Work_x(pc)		;on lit les 16 premiers
	moveq	#16,d0		;octets pour reconnaitre
	move.l	d0,-(sp)		;le fichier
	move.w	d7,-(sp)		;
	move.w	#$3f,-(sp)		;
	trap	#1		;
	clr.w	-(sp)		;Puis on revient en
	move.w	d7,-(sp)		;tˆte de fichier...
	clr.l	-(sp)		;
	move.w	#$42,-(sp)		;
	trap	#1		;
	lea	22(sp),sp		;R‚tablit la pile
	cmpi.l	#"ICE!",Work_x	;Compactage Ice ?
	bne.s	.LI_0		;non
	move.l	Work_x+8,d6	;Si, prendre la VRAIE taille
	bra.s	.LI_1		;
.LI_0	cmpi.l	#"ATM5",Work_x	;Compactage Atomik ?	
	bne.s	.LI_1		;
	move.l	Work_x+4,d6	;oui => VRAIE taille

.LI_1	move.l	d6,-(sp)		;On demande la m‚moire kivabien
	move.w	#$48,-(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
	move.l	d0,d5		;
	bgt.s	.LI_2		;Adresse valable ?
.LI_err1	lea	Memerr,a0		;
	bsr	Form_Alert		;Non:pas de m‚moire
	moveq	#0,d0		;
	bra	.LI_end		;
.LI_err2	lea	Filerr,a0		;
	bsr	Form_Alert		;
	moveq	#0,d0		;erreur fichier
	bra	.LI_end		;

.LI_2	move.l	d5,-(sp)		;
	move.l	d6,-(sp)		;Lire le fichier
	move.w	d7,-(sp)		;
	move.w	#$3f,-(sp)		;
	trap	#1		;
	move.w	d7,-(sp)		;et ferme le
	move.w	#$3e,-(sp)		;
	trap	#1		;
	lea	16(sp),sp		;
	movea.l	d5,a0		;
	bsr	ice_decrunch	;tentative de d‚package
	bsr	atm5_decrunch	;ice ou atomik
	moveq	#-1,d0		;tout va bien
.LI_end	movem.l	(sp)+,d0-d7/a1-a6	;
	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sauvegarde de l'image BIM (Blitter-IMage)
Save_Image	movem.l	d0-d7/a0-a6,-(sp)	;
	clr.w	-(sp)		;
	pea	filename		;
	move.w	#$3c,-(sp)		;Create
	trap	#1		;
	addq.l	#8,sp		;
	move.w	d0,d7		;
	bmi.s	.SI_err0		;erreur d'ouverture
	pea	pal_buf		;adresse des palettes
	move.l	#(48+7)*199*4,-(sp)	;taille des palettes
	move.w	d7,-(sp)		;
	move.w	#$40,-(sp)		;hop
	trap	#1		;
	move.l	ecran,-(sp)	;adresses des ‚crans
	move.l	#32000*2,-(sp)	;leur taille
	move.w	d7,-(sp)		;
	move.w	#$40,-(sp)		;voil… qui est fait
	trap	#1		;
	move.w	d7,-(sp)		;et finalement ferme
	move.w	#$3e,-(sp)		;le fichier
	trap	#1		;
	lea	28(sp),sp		;
.SI_end	movem.l	(sp)+,d0-d7/a0-a6	;
	rts
.SI_err0	lea	Filerr,a0
	bsr	Form_Alert
	bra.s	.SI_end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-------------------Convertion images 24 bits format RAW-----------------
; A0=adresse de l'image
; A1=adresse des deux ‚crans n‚cessaires
; A2=adresse des deux jeux de palettes.
; D0= 1:rus‚ / 0:normal / -1:r‚duction du clignotement
; D1= entrelacement (sup‚rieur … 0 !!)
	RSRESET
compt_x	rs.w	1	;compteur de pixels
compt_y	rs.w	1	;de lignes
rez_x	rs.w	1	;r‚solution de l'image 24 bits
rez_y	rs.w	1	;
delta_y	rs.w	1	;taille d'une de ses lignes
flicker	rs.w	1	;type de conversion ?
swap	rs.w	1	;<-pour l'antiflicker

col_1	rs.w	1	;couleur 1 du point
rgb_11	rs.w	1	;pour recherche rus‚e, on
idx_11	rs.w	1	;regarde sa note, l'offset
note11	rs.w	1	;palette, la couleur choisie
off_11	rs.w	1	;et son index (0..15)
rgb_12	rs.w	1	;et ce pour les 2 images
idx_12	rs.w	1	;
note12	rs.w	1	;
off_12	rs.w	1	;

col_2	rs.w	1	;et pareil pour la couleur 2
rgb_21	rs.w	1	;
idx_21	rs.w	1	;
note21	rs.w	1	;
off_21	rs.w	1	;
rgb_22	rs.w	1	;
idx_22	rs.w	1	;
note22	rs.w	1	;
off_22	rs.w	1	;

c24b_size	rs.b	0

Convert_24Bits
	movem.l	d0-a6,-(sp)	;
	tst.w	d1		;Selon l'entrelacement,
	bne.s	*+4		;nul=erreur
	moveq	#1,d1		;donc corrige
	smi	d4		;on avance ou on recule
	ext.w	d4		;-1=n‚gatif 0=positif
	add.w	d4,d4		;-2         0
	addq.w	#1,d4		;-1        +1
	lea	Suite_x(pc),a6	;on va cr‚er la suite des x
	moveq	#0,d0		;selon l'entrelacement
	moveq	#0,d2		;Valeur de d‚part=0
	move.w	#319,d3		;
.C_i0	add.w	d1,d0		;avance selon l'entrelacement
	bpl.s	.C_i1		;arg, n‚gatif ?
	addi.w	#320,d0		;oui, donc modulo 320
	bra.s	.C_i2		;
.C_i1	cmpi.w	#320,d0		;on a d‚pass‚ la ligne ?
	blt.s	.C_i2		;non
	subi.w	#320,d0		;si, modulo 320
.C_i2	move.w	d0,(a6)+		;c'est le prochain x
	cmp.w	d0,d2		;On est revenu au d‚part ?
	bne.s	.C_i4		;
	add.w	d4,d0		;oui, alors avance/recule
	bpl.s	.C_i3		;de 1
	addi.w	#320,d0
.C_i3	move.w	d0,d2		;c'est le nouveau d‚part
.C_i4	dbf	d3,.C_i0		;suivant.

	lea	C24B_dat1(pc),a6	;
	move.w	2(sp),flicker(a6)	;
	clr.w	swap(a6)		;
	tst.w	10(sp)		;RAW ou TGA ???
	beq	.C_raw		;

.C_tga	move.b	13(a0),d0		;Taille de l'image D0=x
	lsl.w	#8,d0		;
	move.b	12(a0),d0		;
	move.b	15(a0),d1		;et D1=y
	lsl.w	#8,d1		;
	move.b	14(a0),d1		;
	move.w	d0,rez_x(a6)	;conserve donc x et y
	move.w	d1,rez_y(a6)	;(largeur et hauteur de
	mulu	#3,d0		;l'image).x*y*3=taille
	mulu	d0,d1		;de l'image
	move.w	d0,delta_y(a6)	;3*x=taille d'une ligne
	moveq	#18,d0		;On saute l'en-tˆte
	add.b	(a0),d0		;du fichier TGA
	adda.w	d0,a0		;
	lea	0(a0,d1.l),a4	;on marque la fin de l'image
	move.l	a0,a5		;et on la traite
.C_t0	move.b	(a5)+,d0		;Maintenant, on va
	lsr.b	#3,d0		;r‚duire les donn‚es
	add.b	d0,d0		;RGB de chaque point
	move.b	(a5),d1		;(3 octets, un par composante)
	lsr.b	#3,d1		;Y'a 256 nuances par
	add.b	d1,d1		;composante=> on r‚duit … 32
	move.b	d1,(a5)+		;pour avoir 2*16.Attention,
	move.b	(a5),d1		;en TGA on a dans l'ordre
	lsr.b	#3,d1		;BRG=>en mˆme temps,on remet
	add.b	d1,d1		;les composantes dans le bon
	move.b	d1,-2(a5)		;ordre.
	move.b	d0,(a5)+		;
	cmpa.l	a4,a5		;
	blt.s	.C_t0		;toute l'image ?
	bra	.C_4
	
.C_raw	moveq	#0,d0		;Initialise x
	moveq	#0,d1		;...et y
.C_r0	moveq	#0,d2		;
	move.b	(a0)+,d2		;CaractŠre suivant
	cmpi.b	#32,d2		;fin de la chaine x ?
	beq.s	.C_r1		;ouaip..
	subi.b	#"0",d2		;convert en chiffre d‚cimal
	mulu	#10,d0		;
	add.w	d2,d0		;et hop
	bra.s	.C_r0		;
.C_r1	moveq	#0,d2		;maintenant, lecture de y
	move.b	(a0)+,d2		;
	cmpi.b	#10,d2		;condition d'arret: chr$(10)
	beq.s	.C_r2		;
	subi.b	#"0",d2		;
	mulu	#10,d1		;
	add.w	d2,d1		;
	bra.s	.C_r1		;
.C_r2	move.w	d0,rez_x(a6)	;conserve donc x et y
	move.w	d1,rez_y(a6)	;(largeur et hauteur de
	mulu	#3,d0		;l'image).x*y*3=taille
	mulu	d0,d1		;de l'image
	move.w	d0,delta_y(a6)	;3*x=taille d'une ligne
	lea	0(a0,d1.l),a4	;
	movea.l	a0,a5		;Exactement la mˆme
.C_r3	REPT	3		;chose que pour le TGA
	move.b	(a5),d0		;mais le format RAW
	lsr.b	#3,d0		;est un RGB, donc pas
	add.b	d0,d0		;besoin de r‚ordonner
	move.b	d0,(a5)+		;les composantes
	ENDR			;
	cmpa.l	a4,a5		;
	blt.s	.C_r3		;sur toute l'image

.C_4	move.l	a1,d1		;maintenant, A1/D1=adresses
	lea	32000(a1),a1	;des 2 ‚crans et A2/D3 celles
	move.l	a2,d2		;des 2 blocs de palettes.
	lea	199*(48+7)*2(a2),a2	;
	move.l	d1,a3		;
	moveq	#0,d6		;
	move.w	#3999,d7		;
.C_5	move.l	d6,(a3)+		;Commence par un cls sur
	move.l	d6,(a3)+		;les deux ‚crans.
	move.l	d6,(a3)+		;
	move.l	d6,(a3)+		;
	dbf	d7,.C_5		;
	lea	160(a1),a1		;Seulement 199 lignes, la
	addi.l	#160,d1		;premiŠre est ignor‚e !..
	move.l	d2,a3		;Puis un cls de la palette
	move.w	#199*2-1,d7	;
.C_6	move.l	d6,(a3)+		;Les lignes de couleurs sont
	move.l	d6,(a3)+		;dans l'ordre: les 7 couleurs
	move.l	d6,(a3)+		;du 68000, et les 48 du blitter
	move.w	d6,(a3)+		;
	move.w	#$f000,(a3)+	;couleur 0 impos‚e !!
	move.w	d6,(a3)+		;(pour la bordure)
	REPT	48/2-1		;
	move.l	d6,(a3)+		;
	ENDR			;
	dbf	d7,.C_6		;ligne de palette suivante
	

	move.w	rez_y(a6),d0	;On commence la conversion
	cmpi.w	#199,d0		;proprement dite.
	bls.s	*+6		;Clipping de la hauteur
	move.w	#199,d0		;de l'‚cran
	move.w	d0,compt_y(a6)	;
	lea	Convert_x(pc),a3	;conversion x->palette
.C_7	lea	Suite_x(pc),a4	;Suite des coordonn‚es
	move.w	#320,compt_x(a6)	;320 points
	move.w	-2(a2),-(sp)	;Sauve emplacement parasite
	move.w	#$1000,-2(a2)	;couleur sp‚ciale parasite
	movea.l	d2,a5		;Et ceci pour les deux blocs
	move.w	-2(a5),-(sp)	;
	move.w	#$1000,-2(a5)	;
	
;Pendant l'algorithme:
;A0=ligne courante de l'image RGB
;A1/D1=adresses ‚crans 1 et 2 (ligne courante)
;A2/D2=adresses blocs de palettes 1 et 2 (ligne courante)
;A3=convertisseur x->palette      A4=suite de valeurs de x
.C_8	move.w	(a4)+,d0		;d0=x courant
	cmp.w	rez_x(a6),d0	;plus grand que la ligne ?
	bge	.C_8end		;oui,alors rien … faire !!
	move.w	d0,d3		;
	add.w	d0,d0		;D0=2*x
	add.w	d0,d3		;D3=3*x
	lea	0(a0,d3.w),a5	;3*x donne l'adresse du
	moveq	#0,d3		;
	moveq	#0,d4		;
	moveq	#0,d5		;
	move.b	(a5)+,d3		;point courant.
	move.b	(a5)+,d4		;on r‚cupŠre sa couleur
	move.b	(a5)+,d5		;(d3,d4,d5)=(R,G,B)
	moveq	#$f0,d6		;Pour distinguer $f000 (noir)
	moveq	#$f0,d7		;de $0000 (libre), la couleur
	movea.l	Convert_rgb(pc),a5	;est $FRGB (=>si RGB=000,ca
	or.b	0(a5,d3.w),d6	;marche).En plus, cela sert
	or.b	1(a5,d3.w),d7	;pour utiliser l'anti-parasite
	lsl.w	#4,d6		;
	lsl.w	#4,d7		;
	or.b	0(a5,d4.w),d6	;D6 contient la valeur STE
	or.b	1(a5,d4.w),d7	;inf‚rieure, et D7 la valeur
	lsl.w	#4,d6		;sup‚rieure (on peut avoir
	lsl.w	#4,d7		;D6=D7 si la couleur du point
	or.b	0(a5,d5.w),d6	;est une vraie couleur STE)
	or.b	1(a5,d5.w),d7	;
	add.w	d0,d0		;x*4
	move.w	d0,d5		;conserve x*4 dans D5
	lsl.w	#3,d0		;x*4*8=x*32
	tst.w	flicker(a6)	;affichage optimis‚ ?
	ble	.C_9		;non, suivant



.C_ruse	move.w	d6,col_1(a6)	;conserve la couleur 1
	move.w	d7,col_2(a6)	;et la couleur 2
	bsr	.C_search		;recherche dans palette 1
	movem.l	d6-d7,rgb_11(a6)	;stocke r‚sultat
	move.w	col_1(a6),d6	;reprend couleur 1
	exg.l	d2,a2		;mais cherche dans palette 2
	bsr	.C_search		;recherche
	movem.l	d6-d7,rgb_12(a6)	;et stocke
	move.w	col_2(a6),d6	;pareil pour couleur 2
	bsr	.C_search		;
	movem.l	d6-d7,rgb_21(a6)	;
	exg.l	d2,a2		;
	move.w	col_2(a6),d6	;
	bsr	.C_search		;
	movem.l	d6-d7,rgb_22(a6)	;
	move.w	note11(a6),d6	;Maintenant, sommation
	add.w	note21(a6),d6	;des notes obtenus pour
	move.w	note12(a6),d7	;chaque essai.
	add.w	note22(a6),d7	;
	move.l	a6,a5		;
	cmp.w	d6,d7		;Quel est le meilleur choix?
	bge.s	.Cr_0		;le premier ?
	move.w	off_11(a5),d7	;Installe la 1ere combinaison
	move.w	rgb_11(a5),0(a2,d7.w)	;de couleurs choisie
	move.w	idx_11(a5),d7	;sur l'‚cran 1
	exg.l	d2,a2		;et sur l'‚cran 2
	move.w	off_21(a5),d6	;(=>palettes 1 et palettes 2)
	move.w	rgb_21(a5),0(a2,d6.w)	;
	move.w	idx_21(a5),d6	;
	exg.l	d2,a2		;
	bra.s	.C_11		;et on se raccorde.
.Cr_0	exg.l	d2,a2
	move.w	off_12(a5),d6	;Installe la 2Šme
	move.w	rgb_12(a5),0(a2,d6.w)	;(donc invers‚e !)
	move.w	idx_12(a5),d6	;
	exg.l	d2,a2		;
	move.w	off_22(a5),d7	;
	move.w	rgb_22(a5),0(a2,d7.w)	;
	move.w	idx_22(a5),d7	;
	bra.s	.C_11



.C_9	beq.s	.C_10		;routine simple ?
	not.w	swap(a6)		;non, alors inverse pour un
	beq.s	*+4		;point sur deux la valeur
	exg	d6,d7		;faible et forte de la couleur
.C_10	bsr	.C_choix		;Choisir la couleur dans les
	exg	d6,d7		;palettes 1 (‚cran 1)
	exg	a2,d2		;puis dans la palette 2
	bsr	.C_choix		;(‚cran 2)..
	exg	a2,d2		;remet A2/D2 comifo

.C_11	lea	Screen_x,a5	;Maintenant, on plot la valeur
	movem.w	0(a5,d5.w),d3-d4	;du point selon le tableau
	lea	0(a1,d3.w),a5	;x->(offset,bitplan)
	lsr.w	#1,d7		;Selon la couleur de l'‚cran 1
	bcc.s	*+4		;on applique la valeur
	or.w	d4,(a5)		;du bitplan l…ouifo
	lsr.w	#1,d7		;
	bcc.s	*+6		;
	or.w	d4,2(a5)		;
	lsr.w	#1,d7		;
	bcc.s	*+8		;
	or.w	d4,4(a5)		;
	tst.w	d7		;
	beq.s	*+6		;
	or.w	d4,6(a5)		;
	movea.l	d1,a5		;Puis maintenant sur l'‚cran 2
	adda.w	d3,a5		;
	lsr.w	#1,d6		;
	bcc.s	*+4		;
	or.w	d4,(a5)		;
	lsr.w	#1,d6		;
	bcc.s	*+6		;
	or.w	d4,2(a5)		;
	lsr.w	#1,d6		;
	bcc.s	*+8		;
	or.w	d4,4(a5)		;
	tst.w	d6		;
	beq.s	*+6		;
	or.w	d4,6(a5)		;
.C_8end	subq.w	#1,compt_x(a6)	;point suivant de la ligne
	bne	.C_8		;
	movea.l	d2,a5		;Restitue l'emplacement qui
	move.w	(sp)+,-2(a5)	;a h‚berg‚ la couleur
	move.w	(sp)+,-2(a2)	;parasite
	lea	160(a1),a1		;Ligne ‚cran suivante
	addi.l	#160,d1		;
	lea	(48+7)*2(a2),a2	;et ligne de palette suivante
	addi.l	#(48+7)*2,d2	;
	adda.w	delta_y(a6),a0	;Ne pas oublier: ligne suivante
	not.w	swap(a6)		;de l'image !!!!
	subq.w	#1,compt_y(a6)	;not.w pour l'anti-flicker
	bne	.C_7		;suivant
	
	movea.l	40(sp),a0		;Maintenant, r‚arrange les
	moveq	#1,d7		;2 blocs de palettes..
.C_12	move.l	a0,a3		;Commence par recopier
	lea	(48+7)*2*199(a0),a0	;les 7 couleurs de
	move.l	a0,a1		;bordure de chaque ligne
	move.w	#198,d6		;dans un buffer
	lea	Work_x+199*7*2,a2	;on le fait de la fin vers
.C_13	lea	-(48+7)*2(a0),a0	;le d‚but
	movem.l	(a0),d0-d3		;r‚cupŠre les 7 couleurs
	swap	d3		;de la ligne
	move.w	d3,-(a2)		;
	movem.l	d0-d2,-(a2)	;et sauve-les
	dbf	d6,.C_13		;ligne suivante
	move.l	a1,a0		;Puis on regroupe les 48
	move.w	#197,d6		;autres couleurs de chaque
	lea	-48*2(a1),a1	;ligne
	lea	-(48+7)*2(a0),a0	;
.C_14	rept	24		;24*2=48
	move.l	-(a0),-(a1)	;
	endr			;
	lea	-7*2(a0),a0	;
	dbf	d6,.C_14		;ligne suivante
	lea	(48+7)*2*199(a3),a0	;Pr‚pare passage ligne suivante
	move.w	#198,d6		;199*7 couleurs de bordure
.C_15	move.l	(a2)+,(a3)+	;… tasser au d‚but du bloc
	move.l	(a2)+,(a3)+	;de palette
	move.l	(a2)+,(a3)+	;
	move.w	(a2)+,(a3)+	;
	dbf	d6,.C_15		;ligne suivante
	dbf	d7,.C_12		;bloc de palette suivant
	move.l	#$0eee0eee,d5	;recoder les couleurs
	move.l	#$01110111,d6	;la facon Atari-ST...
	move.w	#(48+7)*199-1,d7	;En effet le bit faible
	move.l	40(sp),a0		;en notation binaire
.C_16	move.l	(a0),d0		;devient le bit fort
	move.l	d0,d1		;pour les registres STE!!
	and.l	d5,d0		;Il est ignor‚ en STF.
	and.l	d6,d1		;
	lsr.l	#1,d0		;
	lsl.l	#3,d1		;
	or.l	d1,d0		;
	move.l	d0,(a0)+		;
	dbf	d7,.C_16		;
	movem.l	(sp)+,d0-a6	;
	rts			;

;A0-A4 occup‚s
;D0-D2/D5/D7 occup‚s
.C_choix	lea	0(a3,d0.w),a5	;Va chercher la palette du
	move.l	a5,-(sp)		;point. Conserve son adresse
	REPT	15		;Pour chacune des 16 couleurs
	move.w	(a5)+,d3		;teste si celle que l'on veut
	cmp.w	0(a2,d3.w),d6	;est d‚j… utilis‚e.
	beq.s	.Cc_ok0		;si oui, alors fini!
	ENDR
	move.w	(a5)+,d3		;DerniŠre couleur
	cmp.w	0(a2,d3.w),d6	;Alors, elle existe ?
	bne.s	.Cc_new		;Non=>une nouveaut‚ !
.Cc_ok0	sub.l	(sp)+,a5		;couleur d‚j… existente
	move.w	a5,d6		;on se contente de 
	lsr.w	#1,d6		;r‚cup‚rer le registre
	subq.w	#1,d6		;correspondant
	rts			;-1 car on a fait (a5)+

.Cc_new	lea	-14(a5),a5		;commence par la couleur 9
	REPT	7		;pour la bordure.
	move.w	(a5)+,d3		;Maintenant,cherche si une
	tst.w	0(a2,d3.w)		;des couleurs de la palette
	beq.s	.Cc_ok1		;est libre
	ENDR
	lea	-32(a5),a5		;puis test les couleurs 0..8
	REPT	8		;
	move.w	(a5)+,d3		;
	tst.w	0(a2,d3.w)		;
	beq.s	.Cc_ok1		;
	ENDR
	move.w	(a5)+,d3		;DerniŠre tentative
	tst.w	0(a2,d3.w)		;Si y'a pas de couleurs
	bne.s	.Cc_look		;libres, gasp:faut continuer
.Cc_ok1	move.w	d6,0(a2,d3.w)	;Couleur nouvelle, on
	sub.l	(sp)+,a5		;la stocke
	move.w	a5,d6		;calcule le No du registre
	lsr.w	#1,d6		;/2 car mot=2 octets
	subq.w	#1,d6		;-1 car on teste (a5)+
	rts			;

;Algo principal:chercher la couleur la plus proche.
.Cc_look	movem.l	d0-d5/d7/a0,-(sp)	;
	move.w	d6,d5		;D‚compose la couleur voulue
	moveq	#$000f,d7		;en RGB
	and.w	d6,d7		;
	andi.w	#$00f0,d6		;
	clr.b	d5		;Conserve bit 24-31 aussi
	move.w	#$7fff,d4		;‚cart maximal pour commencer
	moveq	#15,d3		;16 couleurs … tester
	lea	-18(a5),a5		;revient au d‚but de la palette
.Cc_0	move.w	(a5)+,d0		;
	move.w	0(a2,d0.w),d0	;
	move.w	d0,d1		;D‚compose la couleur de
	moveq	#$000f,d2		;la palette
	and.w	d0,d2		;
	andi.w	#$00f0,d1		;
	clr.b	d0		;
	sub.w	d7,d2		;Puis regarde les ‚carts de
	bpl.s	*+4		;chaque composante (en valeur
	neg.w	d2		;absolue)
	sub.w	d6,d1		;
	bpl.s	*+4		;
	neg.w	d1		;
	sub.w	d5,d0		;
	bpl.s	*+4		;
	neg.w	d0		;
	lsr.w	#8,d0		;Aligne RGB dans les 4 bits
	lsr.w	#4,d1		;faibles.
	cmp.w	d0,d1		;Cherche le plus grand ‚cart
	ble.s	*+4		;Delta_R<Delta_G ?
	exg	d1,d0		;oui, alors le + grand en D0
	add.w	d0,d1		;Effectue la somme de tous
	add.w	d2,d1		;les Delta_
	cmp.w	d0,d2		;Delta_B>MAX(Delta_R,Delta_G)?
	ble.s	*+4		;...
	move.w	d2,d0		;...
	mulu	d1,d0		;maximum*somme=erreur
	cmp.w	d0,d4		;Si l'erreur commise est plus
	ble.s	*+8		;petite
	move.w	d3,d4		;alors conserve le registre
	swap	d4		;correspondant et l'erreur
	move.w	d0,d4		;dans D4
	dbf	d3,.Cc_0		;couleur suivant
	swap	d4		;
	eori.w	#15,d4		;R‚cupŠre le registre associ‚
	move.w	d4,d6		;… la meileure couleur
	movem.l	(sp)+,d0-d5/d7/a0	;
	addq.l	#4,sp		;
	rts			;

;Algo secondaire:mˆme chose que pr‚c‚demment mais
;sans choix d‚finitif (il est fait par la routine appelante).
.C_search	moveq	#-1,d7		;par d‚faut, note minimale
	lea	0(a3,d0.w),a5	;(-1 dans le mot haut de d7)
	move.l	a5,-(sp)		;
	REPT	15		;
	move.w	(a5)+,d3		;
	cmp.w	0(a2,d3.w),d6	;
	beq.s	.Cs_ok0		;
	ENDR
	move.w	(a5)+,d3		;
	cmp.w	0(a2,d3.w),d6	;
	bne.s	.Cs_new		;
.Cs_ok0	move.w	d3,d7		;couleur d‚j… existente
	suba.l	(sp)+,a5		;
	swap	d6		;conserve la valeur rgb
	move.w	a5,d6		;
	lsr.w	#1,d6		;
	subq.w	#1,d6		;
	rts			;

.Cs_new	moveq	#0,d7		;note nulle:moins favorable.
	lea	-14(a5),a5		;
	REPT	7		;
	move.w	(a5)+,d3		;
	tst.w	0(a2,d3.w)		;
	beq	.Cs_ok0		;routine identique ici
	ENDR
	lea	-32(a5),a5		;
	REPT	9		;
	move.w	(a5)+,d3		;
	tst.w	0(a2,d3.w)		;
	beq	.Cs_ok0		;
	ENDR

.Cs_look	movem.l	d0-d5/a0,-(sp)	;Note … d‚terminer pour
	move.w	d6,d5		;la couleur la plus proche
	moveq	#$000f,d7		;
	and.w	d6,d7		;
	andi.w	#$00f0,d6		;
	clr.b	d5		;
	move.w	#$7fff,d4		;
	moveq	#15,d3		;
	lea	-18(a5),a5		;
	subq.l	#8,sp		;petite place sur la pile
.Cs_0	move.w	(a5)+,d0		;
	move.w	d0,2(sp)		;offset palette et
	move.w	0(a2,d0.w),d0	;...
	move.w	d0,(sp)		;couleur actuelle.
	move.w	d0,d1		;
	moveq	#$000f,d2		;
	and.w	d0,d2		;
	andi.w	#$00f0,d1		;
	clr.b	d0		;
	sub.w	d7,d2		;
	bpl.s	*+4		;
	neg.w	d2		;
	sub.w	d6,d1		;
	bpl.s	*+4		;
	neg.w	d1		;
	sub.w	d5,d0		;
	bpl.s	*+4		;
	neg.w	d0		;
	lsr.w	#8,d0		;
	lsr.w	#4,d1		;
	cmp.w	d0,d1		;
	ble.s	*+4		;
	exg	d1,d0		;
	add.w	d0,d1		;
	add.w	d2,d1		;
	cmp.w	d0,d2		;
	ble.s	*+4		;
	move.w	d2,d0		;
	mulu	d1,d0		;
	cmp.w	d0,d4		;
	ble.s	*+12		;
	move.w	d3,d4		;
	swap	d4		;
	move.w	d0,d4		;
	move.l	(sp),4(sp)		;meilleur couleur actuelle
	dbf	d3,.Cs_0		;couleur suivante

	move.w	4(sp),d6		;la meilleure est choisie
	swap	d4		;
	move.l	d4,d7		;la note donn‚e
	move.w	6(sp),d7		;et l'offset palette
	swap	d6		;
	eori.w	#15,d4		;R‚cupŠre le registre associ‚
	move.w	d4,d6		;… la meileure couleur
	addq.l	#8,sp		;
	movem.l	(sp)+,d0-d5/a0	;
	addq.l	#4,sp		;
	rts			;


	
Convert_STE			;tableau de conversion
	dc.b	$0,$0		;pour STE. Pour chaque
	dc.b	$0,$1		;valeur 5 bits (0..31)
	dc.b	$1,$1		;il y a deux valeurs
	dc.b	$1,$2		;STE 4 bits (0..15)
	dc.b	$2,$2		;cela donne une amplitude
	dc.b	$2,$3		;0..30 (31 est impossible
	dc.b	$3,$3		;… coder).
	dc.b	$3,$4		;Donc on a 31 pseudo teintes
	dc.b	$4,$4		;par composante R,G,B
	dc.b	$4,$5		;Ce qui donne 29791 couleurs
	dc.b	$5,$5
	dc.b	$5,$6
	dc.b	$6,$6
	dc.b	$6,$7
	dc.b	$7,$7
	dc.b	$7,$8
	dc.b	$8,$8
	dc.b	$8,$9
	dc.b	$9,$9
	dc.b	$9,$a
	dc.b	$a,$a
	dc.b	$a,$b
	dc.b	$b,$b
	dc.b	$b,$c
	dc.b	$c,$c
	dc.b	$c,$d
	dc.b	$d,$d
	dc.b	$d,$e
	dc.b	$e,$e
	dc.b	$e,$f
	dc.b	$f,$f
	dc.b	$f,$f

Convert_STF			;Tableau de convertion
	dc.b	$0,$0		;STF. Pareil que pour STE
	dc.b	$0,$0		;mais les composantes
	dc.b	$0,$2		;ne vont que de 2 en 2
	dc.b	$0,$2		;Donc 0,2,...,28
	dc.b	$2,$2		;soit donc 15 valeurs
	dc.b	$2,$2		;Au total 3375 couleurs
	dc.b	$2,$4
	dc.b	$2,$4
	dc.b	$4,$4
	dc.b	$4,$4
	dc.b	$4,$6
	dc.b	$4,$6
	dc.b	$6,$6
	dc.b	$6,$6
	dc.b	$6,$8
	dc.b	$6,$8
	dc.b	$8,$8
	dc.b	$8,$8
	dc.b	$8,$a
	dc.b	$8,$a
	dc.b	$a,$a
	dc.b	$a,$a
	dc.b	$a,$c
	dc.b	$a,$c
	dc.b	$c,$c
	dc.b	$c,$c
	dc.b	$c,$e
	dc.b	$c,$e
	dc.b	$e,$e
	dc.b	$e,$e
	dc.b	$e,$e
	dc.b	$e,$e
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Pr‚calcul classique les plots … effectuer … l'‚cran
;
Precalc_Screen_x
	movem.l	d0-a6,-(sp)
	lea	Screen_x,a0
	moveq	#0,d0
.PSx_0	moveq	#15,d2
	move.w	d0,d1
	and.w	d1,d2
	sub.w	d2,d1
	lsr.w	#1,d1
	move.w	d1,(a0)+
	eori.w	#15,d2
	moveq	#0,d1
	bset	d2,d1
	move.w	d1,(a0)+
	addq.w	#1,d0
	cmpi.w	#320,d0
	bne.s	.PSx_0
	movem.l	(sp)+,d0-a6
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Pr‚calcul les correspondances entre coordonn‚es et palettes de
;couleur. Version non anti-parasit‚e.
;Normal_Convert_x
;	movem.l	d0-a6,-(sp)
;	moveq	#0,d0
;	lea	Convert_x,a0
;.NCx_bcl	move.l	a0,a2		;conserve palette pour + tard
;	moveq	#-32,d3		;palette -1 … 0 (-1=bordure)
;	moveq	#3+9*8,d1		;aligne x sur le champ de palettes
;	add.w	d0,d1		;->d1 indique la position
;	asr.w	#3,d1		;depuis le d‚but du chgt de pal
;	moveq	#48,d2		;4-1=3 palettes (3*16=48)
;	and.w	d1,d2		;entre quelles palettes est-on?
;	add.w	d2,d3		;on conserve le r‚sultat en d3
;	add.w	d2,d3		;(qui est offset, donc *2)
;	addi.w	#14,d3		;d‚calage de 7 couleurs d– …
;				;la bordure
;	sub.w	d2,d1		;quel interm‚diaire de palette?
;	moveq	#15,d4		;On est dans la palette
;.NCx_b0	move.w	d3,(a0)+		;m‚moris‚e en d3 
;	addq.w	#2,d3		;couleur suivante
;	dbf	d4,.NCx_b0		;
;	cmpi.w	#110,d3		;extrŠme de la ligne ?
;	bne.s	.NCx_b2		;non:pour les points >316
;	moveq	#14,d3		;uniquement, la couleur de
;	bra.s	.NCx_b2		;fond redevient noire.
;.NCx_b1	move.w	d3,(a2)+		;La palette suivante entre
;	addq.w	#2,d3		;depuis le registre 0.
;.NCx_b2	dbf	d1,.NCx_b1		;sur la taille interm‚diaire
;	addq.w	#1,d0		;point suivant
;	cmpi.w	#320,d0		;fini ?
;	bne.s	.NCx_bcl
;	movem.l	(sp)+,d0-a6
;	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Pr‚calcul les correspondances entre coordonn‚es et palettes de
;couleur.Version anti-parasite !.
Antiparasite_Convert_x
	movem.l	d0-a6,-(sp)
	moveq	#0,d0
	lea	Convert_x,a0
.ACx_bcl	move.l	a0,a2		;conserve palette pour + tard
	moveq	#-32,d3		;palette -1 … 0 (-1=bordure)
	moveq	#3+9*8,d1		;aligne x sur le champ de palettes
	add.w	d0,d1		;->d1 indique la position
	moveq	#7,d5		;conserve le modulo 7
	and.w	d1,d5		;pour l'antiparasite
	lsr.w	#3,d1		;depuis le d‚but du chgt de pal
	moveq	#48,d2		;4-1=3 palettes (3*16=48)
	and.w	d1,d2		;entre quelles palettes est-on?
	add.w	d2,d3		;on conserve le r‚sultat en d3
	add.w	d2,d3		;(qui est offset, donc *2)
	addi.w	#14,d3		;d‚calage de 7 couleurs d– …
				;la bordure
	sub.w	d2,d1		;quel interm‚diaire de palette?
	moveq	#15,d4		;On est dans la palette
.ACx_b0	move.w	d3,(a0)+		;m‚moris‚e en d3 
	addq.w	#2,d3		;couleur suivante
	dbf	d4,.ACx_b0		;
	cmpi.w	#110,d3		;extrŠme de la ligne ?
	bne.s	.ACx_b2		;non:pour les points >316
	moveq	#14,d3		;uniquement, la couleur de
	bra.s	.ACx_b2		;fond redevient noire.
.ACx_b1	move.w	d3,(a2)+		;La palette suivante entre
	addq.w	#2,d3		;depuis le registre 0.
.ACx_b2	dbf	d1,.ACx_b1		;sur la taille interm‚diaire

	subq.w	#7,d5		;On est sur le pixel parasite?
	bne.s	.ACx_1		;Non,saute skissui
	move.w	#-2,(a2)		;si,enlŠve la couleur limite
.ACx_1	addq.w	#1,d0		;point suivant
	cmpi.w	#320,d0		;fini ?
	bne.s	.ACx_bcl
	movem.l	(sp)+,d0-a6
	rts

	include	"a:\inithard.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;D‚claration de pr‚sence pour l'AES.
Appl_Init	move.l	a0,-(sp)
	lea	_Appl_Init(pc),a0
	bsr	AES
	movea.l	(sp)+,a0
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fin de l'application.
Appl_Exit	lea	_Appl_Exit(pc),a0	;libŠre l'AES
	bsr	AES		;
	clr.w	-(sp)		;retour au bureau
	trap	#1		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Boite d'alerte. A0 doit contenir son texte.
;D0 contient le bouton cliqu‚ … la sortie
Form_Alert	move.l	a0,-(sp)		;
	moveq	#0,d0		;R‚cupŠre bouton par d‚faut
	move.b	(a0)+,d0		;
	move.w	d0,int_in		;passe le … l'AES
	move.l	a0,addr_in		;et l'adresse du message
	lea	_Form_Alert(pc),a0	;fonction Form_Alert
	bsr	AES		;go!
	move.w	int_out,d0		;paramŠtres de sortie
	movea.l	(sp)+,a0		;
	rts			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Selecteur de fichiers. A0 doit contenir le chemin, A1 le nom
;preselectionn‚ (ou nul) et A2 l'adresse de la chaine qui
;contiendra le nom du fichier complet.
;En sortie Z=1 (BEQ) si erreur ou pas de choix
FileSelect	movem.l	a0-a2,-(sp)		;
	move.l	a0,addr_in		;
	move.l	a1,addr_in+4	;
	lea	_FileSelect,a0	;
	bsr	AES		;
	tst.w	int_out		;Erreur ?
	beq.s	.FS_end		;
	tst.w	int_out+2		;Bouton Cancel ?
	beq.s	.FS_end		;

	movea.l	(sp),a0		;r‚cupŠre le chemin
	move.l	a0,a1		;
.FS_0	tst.b	(a0)+		;Cherche la fin
	bne.s	.FS_0		;de la chaine
.FS_1	cmpi.b	#"\",-(a0)		;Cherche l'anti-slash
	beq.s	.FS_2		;de la fin du chemin
	cmpa.l	a0,a1		;On a remont‚ la chaine?
	bne.s	.FS_1		;pas encore...
	
.FS_2	movea.l	a0,a1		;conserve cette adresse
	movea.l	(sp),a0		;on repart du d‚but
.FS_3	cmpa.l	a0,a1		;d‚j… fini ?
	blt.s	.FS_4		;oui
	move.b	(a0)+,(a2)+	;
	bra.s	.FS_3		;next one,plizzz

.FS_4	movea.l	4(sp),a1		;maintenant, copie le nom
.FS_5	move.b	(a1)+,(a2)+	;du fichier … la suite
	bne.s	.FS_5		;pour composer le tout
	andi.w	#%11111011,ccr	;Mettre Z=0:pas d'erreurs

.FS_end	movem.l	(sp)+,a0-a2	;finito. C'est simple,
	rts			;non ?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;En A0: le descripteur de fonction voulu.
AES	movem.l	d0-a6,-(sp)
	lea	control,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+
	move.w	#$c8,d0
	move.l	#AESPB,d1
	trap	#2
	movem.l	(sp)+,d0-a6
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Routine de d‚compactage ICE 2.40 (c)Axe//Superior
;
ice_decrunch:
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4
	move.l	a4,a6
	bsr	.getinfo
	cmpi.l	#'ICE!',d0
	bne	.not_packed
	bsr.s	.getinfo
	lea.l	-8(a0,d0.l),a5
	bsr.s	.getinfo
	move.l	d0,(sp)
	adda.l	d0,a6
	move.l	a6,a1

	moveq	#119,d0
.save:	move.b	-(a1),-(a3)
	dbf	d0,.save
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a5


	bsr	.get_1_bit
	bcc.s	.no_picture
	move.w	#$0f9f,d7
	bsr	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.no_picture
	movem.l	(sp),d0-a3

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0
.rest	move.b	-(a3),-(a5)
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	rts

.getinfo: moveq	#3,d1
.getbytes: lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more: add.l	20(a1),d1
.copy_direkt:	
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:	
	cmpa.l	a4,a6
	bgt.s	.strings
	rts	

.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1
.hole_bit_loop:	
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts	


.strings: lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:	
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_ber
.get_ber:
	bsr.s	.get_d0_bits
.no_ber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2


	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1

.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Routine de d‚compactage Atomik 3.5 (c)Altair//VMAX
;
MODE:	EQU	1
PIC_ALGO:	EQU	1
DEC_SPACE:	EQU	$1000
RESTORE_SPACE: EQU	1
atm5_decrunch:
	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
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
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
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
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc


	SECTION	DATA
InfoDis1	dc.b	1,"[0][       Convertisseur|      d'images TGA&RAW| |(C)oderight Nullos//DNT 1992  | ][ Let's go! ]",0,0
InfoDis2	dc.b	1,"[1][Ce programme reconnait|automatiquement les|fichiers compact‚s avec|le ICE-Packer 2.4 ou|l'Atomik-packer 3.5][ Ok ]",0,0
KelForm	dc.b	0,"[2][Quel est le format|de l'image … traiter ?  ][ RAW | TGA | BIM ]",0,0
ConvTyp	dc.b	1,"[2][Quelle type de conversion|doit-on appliquer ?...  ][ Stable | Simple | Rus‚e ]",0,0
ConvNum	dc.b	2,"[2][ParamŠtre|d'entrelacement...        ][  |"
_CN_str	dc.b	"+13|  ]",0,0
ConvHtz	dc.b	1,"[2][Frequence d'affichage|d‚sir‚e ?....              ][ 60Hz | 50Hz ]",0,0
NextOne	dc.b	1,"[2][Une autre ?..][ Oui | Non ]",0,0
SavePic	dc.b	2,"[2][Voulez vous sauvegarder|l'image obtenue au format|BIM (Blitter-IMage) ?][ Oui | Non ]",0,0
Memerr	dc.b	1,"[3][Pas assez de m‚moire pour|charger ce fichier-image][ Gasp ]",0,0
Filerr	dc.b	1,"[3][Impossible d'ouvrir ce|fichier....][ Gasp ]",0,0
Bliterr	dc.b	1,"[1][Ce programme ne marche|que sur les STE et|les STF avec blitter !!!!][ Dommaaaage ]",0,0
	EVEN

;Descripteurs de fonction GEM : No de fonction,
;                               Nombre de paramŠtres int_in
;                                ""         ""       int_out
;                                ""         ""       addr_in
;                                ""         ""       addr_out
_Appl_Init  dc.w	10,0,1,0,0
_Appl_Exit  dc.w	19,0,1,0,0
_Form_Alert dc.w	52,1,1,1,0
_FileSelect dc.w	90,0,2,2,0


ecran	dc.l	0,0		;Swapping ‚cran
palette	dc.l	pal_buf,pal_buf+199*(48+7)*2 ;et de palettes
Convert_rgb dc.l	Convert_STF	;Convertion STE ou STF
AESPB	dc.l	control,global,int_in,int_out,addr_in,addr_out

	SECTION	BSS
; Tableau pour la routine de conversion d'image.
entrelace	ds.w	1		;choix d'entrelacement
flickflag	ds.w	1		;flicker/error free.
image	ds.l	1		;adresse de l'image RBG
imtype	ds.w	1		;TGA ou RAW ??
specsync	ds.w	1		;50 ou 60Hz

C24B_dat1	ds.b	c24b_size		;Tableau interne routine
Suite_x	ds.w	320		;Suite des x de conversion
Work_x	ds.w	7*199		;R‚arrangement des palettes
Convert_x	ds.w	320*16		;Convertion x->palette
Screen_x	ds.l	320		;Convertion x->plot
pal_buf	ds.w	(48+7)*199*2	;Bloc des palettes.
scr_buf	ds.b	32000*2+256	;buffer d'image.
buff_marg	equ	pal_buf		;Buffer pour Atomik
				;on le prend dans les palettes

filename	ds.b	128		;Nom complet=
path	ds.b	128		;Chemin pour FileSelect
name	ds.b	14		;+nom du fichier

; Tableaux du GEM.
control	ds.w	5
global	ds.w	15
int_in	ds.w	16
int_out	ds.w	7
addr_in	ds.l	2
addr_out	ds.l	1
ap_id	ds.w	1

; Pile du programme.
.stack	ds.b	2048
stackup	equ	*