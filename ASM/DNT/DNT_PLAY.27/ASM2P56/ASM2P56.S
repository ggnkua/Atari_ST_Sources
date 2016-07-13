*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*           Petit utilitaire 'tout-en-un' pour l'assembleur DSP           *
*                    (C)oderight Nullos / DNT-Crew 1994                   *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Ce programme est … adapter … chaque configuration, au travers des divers *
*chemin d'accŠs aux deux programmes (ASM56000, CLD2LOD) n‚cessaire …      *
*l'assemblage complet d'un programme DSP, ainsi qu'… votre (vos) chemin(s)*
*utilis‚s par d‚faut par la commande include de l'assembleur.             *
*Rendez vous … la fin de ce source pour cette adaptation!..               *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Pour appeler ce programme, il suffit de lui indiquer le nom de votre     *
*source (‚ventuellement avec son chemin) ou de tirer l'ic“ne de ce source *
*sur l'ic“ne de ASM2P56.TTP                                               *
*Vous pouvez aussi l'installer en tant que Tools avec Devpac 3, en le     *
*param‚trant Run as TOS, Pause on return, Command Line : Prompt et        *
*Directory : Current, sans oublier d'indiquer o— il se trouve sur votre   *
*disque dur, et en lui donnant un nom (pourquoi pas Make P56 ?). Il suffit*
*de presser Control en choisissant un Tools pour pouvoir le param‚trer.   *
*'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'*
*Comme d'habitude, un tab setting = 11 serait judicieux pour ce source... *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	include	tos_030.s
	output	.ttp

	StartUp	512		;
	lea	p_cmdcnt(a0),a0	;Commence par scruter la ligne
	moveq	#0,d0		;de commande pour extraire le
	move.b	(a0)+,d0		;nom du fichier ASM pass‚ en paramŠtre.
	beq	usage		;
	lea	(a0,d0.w),a1	;
	clr.b	(a1)		;
	moveq	#4-1,d0		;
lookext	cmpi.b	#'.',-(a1)		;Cherche l'extension
	beq.s	getext		;
	cmpa.l	a0,a1		;On a cherch‚ partout ?
	dble	d0,lookext		;
	bra.s	noext		;Ben oui: y'en a pas !
getext	lea	asmext+1(pc),a2	;Si, alors on la r‚cupŠre,
	clr.b	(a1)+		;et on isole le nom du fichier.
	move.b	(a1)+,(a2)+	;
	bne.s	*-2		;
noext	move.l	a0,a6		;

	pea	present(pc)	;
	Gemdos	Cconws		;
	lea	asmcmd(pc),a0	;On prend la ligne de commande
	lea	cmdtext(pc),a1	;de ASM56000.TTP, … laquelle on
	bsr.s	stradd		;ajoute le nom du fichier,
	move.l	a6,a0		;avec son extension 'ASM'
	bsr.s	stradd		;
	lea	asmext(pc),a0	;
	bsr.s	stradd		;

	lea	asmprg(pc),a2	;
	bsr.s	runprg		;Puis on lance le programme.
	bne.s	abort		;Y'a une erreur d'assemblage ?

	pea	nowcld(pc)		;
	Gemdos	Cconws		;Non, alors on continue en
	move.l	a6,a0		;convertissant le fichier CLD
	lea	cmdtext(pc),a1	;fichier LOD.
	bsr.s	stradd		;Tous ont le nom donn‚ en
	lea	cldext(pc),a0	;paramŠtre, seule change
	bsr.s	stradd		;l'extension, bien s–r.
	move.l	a6,a0		;
	bsr.s	stradd		;
	lea	lodext(pc),a0	;
	bsr.s	stradd		;

	lea	cldprg(pc),a2	;Et on ex‚cute CLD2LOD.
	bsr.s	runprg		;
	beq.s	lod2p56		;Erreur ?
	bra.s	abort		;

runprg	lea	cmdline(pc),a0	;
	sub.l	a0,a1		;Appel d'un programme, avec
	move.l	a1,d0		;ligne de commande.
	move.b	d0,(a0)		;
	pea	null(pc)		;
	pea	(a0)		;
	pea	(a2)		;
	clr.w	-(sp)		;
	Gemdos	Pexec		;
	tst.w	d0		;
	rts

loderr	pea	badlod(pc)		;Diff‚rentes erreurs possibles.
	bra.s	outerr		;
createrr	pea	badcreat(pc)	;
	bra.s	outerr		;
stradd	move.b	(a0)+,(a1)+
	bne.s	*-2
	subq.l	#1,a1
	rts
writerr	pea	badwrit(pc)	;
outerr	Gemdos	Cconws		;
abort	move.w	d0,-(sp)		;
	Gemdos	Crawcin		;
good_bye	Gemdos	Pterm		;
	

usage	pea	present(pc)	;Comment ca marche ??
	Gemdos	Cconws		;
	pea	help(pc)		;
	Gemdos	Cconws		;
	moveq	#-1,d0		;
	bra.s	abort		;
	
lod2p56	pea	nowp56(pc)		;Convertir le fichier LOD en fichier P56
	Gemdos	Cconws		;en se servant du Xbios.
	move.l	a6,a0		;
	lea	cmdline(pc),a1	;
	bsr.s	stradd		;Construit le nom du fichier LOD
	lea	lodext(pc),a0	;
	bsr.s	stradd		;
	pea	buffer(pc)		;ParamŠtre 2: adresse du buffer pour le P56
	pea	cmdline(pc)	;ParamŠtre 1: nom du fichier LOD
	Xbios	Dsp_LodToBinary	;Pof, conversion avec le Xbios
	move.l	d0,d6		;
	bmi.s	loderr		;Erreur ??
	add.l	d6,d6		;Taille du fichier= 3*nb_mots_DSP
	add.l	d0,d6		;
	move.l	a6,a0		;
	lea	cmdline(pc),a1	;
	bsr.s	stradd		;Et on sauve le tout.
	lea	p56ext(pc),a0	;
	bsr	stradd		;
	clr.w	-(sp)		;
	pea	cmdline(pc)	;
	Gemdos	Fcreate		;
	move.w	d0,d7		;
	bmi	createrr		;
	pea	buffer(pc)		;
	move.l	d6,-(sp)		;
	move.w	d7,-(sp)		;
	Gemdos	Fwrite		;
	cmp.l	d0,d6		;
	bne	writerr		;
	move.w	d7,-(sp)		;
	Gemdos	Fclose		;
	moveq	#0,d0		;
	bra	good_bye		;

	data
null	dc.b	0,0
asmext	dc.b	'.asm',0
cldext	dc.b	'.cld ',0
lodext	dc.b	'.lod',0
p56ext	dc.b	'.p56',0


;Ici se trouve les trois chemin de fichiers … adapter pour votre propre
;usage. Vous pouvez ajouter d'autre chemin d'inclusion pour l'assembleur
;en rajoutant autant de -Ix:\pathname\ que n‚cessaires dans sa ligne
;de commande... dans une limite de 128 octets en tout pour celle-ci!.
;Cf article correspondant dans le DNT-Paper 7...
;
asmcmd	dc.b	'-A -B -L -Id:\dsptools.mc\sources.dsp\sioeq\ ',0
asmprg	dc.b	'd:\dsptools.mc\asm56000.ttp',0
cldprg	dc.b	'd:\dsptools.mc\cld2lod.ttp',0


present	dc.b	$d,$a,"ASM to LOD & P56 file format 1.2 (C)oderight Nullos//DNT-Crew 94",$d,$a,$d,$a,0
nowcld	dc.b	$d,$a,"Now generating LOD file, using cld2lod.ttp",$d,$a,0
nowp56	dc.b	$d,$a,"Now generating P56 file, using Dsp_LodToBinary=Xbios($6F)",$d,$a,0
help	dc.b	"Usage: asm2p56.ttp [x:][\path\]filename[.ext]",$d,$a,0
badlod	dc.b	$a,$a,"Impossible de charger le fichier *.LOD",$d,$a,0
badcreat	dc.b	$d,$a,"Impossible d'ouvrir le fichier *.P56 destination",$d,$a,0
badwrit	dc.b	$d,$a,"Erreur d'‚criture sur le fichier *.P56",$d,$a,0
	even
	bss
cmdline	ds.b	1
cmdtext	ds.b	127
buffer	ds.b	96*1024
