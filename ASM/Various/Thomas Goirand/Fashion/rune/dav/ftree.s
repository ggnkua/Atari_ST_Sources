**********************************************************************

		****
		TEXT
		****
		
		; outils de g‚n‚ration d'arborescence
		; de systeme de fichier en m‚moire ...
		
		; parametres:
		; LONG: nombre max d'objets
		
		; sortie:
		; d0=pointeur sur la structure construite.

		********
		
		rsset	8
ma_maxobj		rs.l	1	; nombre max d'objets
ma_drive		rs.w	1	; unit‚ … scanner (A-Z)

		********
		
		; structure d'un "file object" :

		rsreset

fo_next		rs.l	1	; pointeur sur prochain frere
fo_parent		rs.l	1	; pointeur directory pere
fo_child		rs.l	1	; pointeur 1er enfant (directory)

fo_attr		rs.w	1	; attributs systeme
fo_len		rs.l	1	; taille en octets
fo_start		rs.l	1	; adresse premier bloc logique media

fo_date		rs.w	1	; date de creation
fo_time		rs.w	1	; heure de creation

fo_kids		rs.w	1	; nombre d'enfants (directory)

fo_name		rs.b	2	; nom de l'objet (variable)

		********
		
		; zone dta
		
		rsreset
	
dt_name		rs.b	12	file name: filename.typ	00-11
dt_pos		rs.l	1	dir position		12-15
dt_dnd		rs.l	1	pointer to DND		16-19
dt_attr		rs.b	1	attributes of file		20
		
	*  --  below must not change --
	
dt_fattr		rs.b	1	attrib from fcb		21
dt_time		rs.w	1	time field from fcb		22-23
dt_date		rs.w	1	date field from fcb		24-25
dt_fileln		rs.l	1	file length field from fcb	26-29
dt_fname		rs.b	12	file name from fcb		30-41
		
		********
		
**********************************************************************

		********
		
		; variables locales
		
		rsset	-(3*4)
ma_dta		rs.l	1	; pointeur zone dta
ma_addr		rs.l	1	; zone m‚moire de construction
ma_size		rs.l	1	; taille m‚moire de construction
		
		********
make_arbre:
		link	a6,#-(3*4)
		movem.l	d1-d7/a0-a5,-(sp)
		
		
		clr.l	ma_addr(a6)
		
		; localisation de la DTA
		
		gem	fgetdta
		move.l	d0,ma_dta(a6)
		
		; reservation m‚moire (tout sauf 128 K)
		
		move.l	#-1,-(sp)
		gem	malloc
		
		sub.l	#128*1024,d0
		
		move.l	d0,ma_size(a6)
		
		move.l	d0,-(sp)
		gem	malloc
		
		move.l	d0,ma_addr(a6)
		bne	.okram
		
			moveq	#-1,d0
			bra	.exit
		
		****
.okram
		; nettoyage de suret‚
		
		move.l	ma_addr(a6),a0
		move.l	ma_size(a6),d0
.clr		
		clr.l	(a0)+
		clr.l	(a0)+
		
		subq.l	#8,d0
		bgt.s	.clr
		
		****
		
		; drive courant
		
		move.w	ma_drive(a6),d0
		sub.w	#"A",d0
		
		move.w	d0,-(sp)
		gem	dsetdrv
		
		; chemin courant
		
		clr.w	-(sp)
		pea	ma_root(pc)
		gem	dsetpath
		
		****
		
		; cr‚ation d'un objet d‚faut pour la racine
		
		move.l	ma_addr(a6),a5
		
		; nom = path racine
		
		lea	fo_name(a5),a4
		
		*move.w	#"\"<<8,(a4)+
		clr.w	(a4)+
		
		; taille,date,heure -> n.c.
		
		clr.l	fo_len(a5)
		clr.w	fo_date(a5)
		clr.w	fo_time(a5)
		move.w	#$00ff,fo_attr(a5)
		
		; au d‚but,nombre d'enfants = 0
		
		clr.w	fo_kids(a5)
		
		; 1er enfant = objet suivant
		
		move.l	a4,fo_child(a5)
		move.l	a5,fo_parent(a4)
		
		; pas de directory pere !
		
		clr.l	fo_parent(a5)
		
		; et par d‚faut pas de frere
		
		clr.l	fo_next(a5)
		
		****
		
		bsr.s	.scan
		
		****
.eok
		sub.l	ma_addr(a6),a4
		
		move.l	a4,-(sp)
		move.l	ma_addr(a6),-(sp)
		clr.w	-(sp)
		gem	mshrink
		
		move.l	ma_addr(a6),d0
.exit		
		movem.l	(sp)+,d1-d7/a0-a5
		unlk	a6
		rtd	#6

		********

**********************************************************************

		********
		
		; noyau recursif
		; pointeur descripteur directory courant en A5
.scan
		movem.l	a3/a5,-(sp)
		
		; descendre dans le directory
		
		pea	fo_name(a5)
		gem	dsetpath
		
		tst.l	d0
		bne	.bug
		
		move.l	a4,a3
		
		; dump le directory
		
		bsr	.this_level
		
		tst.w	fo_kids(a5)
		bne.s	.loop
		
			clr.l	fo_child(a5)
			bra.s	.dir_end
		
		; traiter les eventuels sub-directory
.loop
		cmp.w	#$0010,fo_attr(a3)
		beq.s	.go_dir
.yop		
		move.l	fo_next(a3),a3
		
		tst.l	a3
		bgt.s	.loop
		bra.s	.dir_end
.go_dir
		move.l	a4,fo_child(a3)
		move.l	a3,a5
		
		bsr.s	.scan
		
		bra.s	.yop
		
		****
.dir_end
		; on remonte au dessus grace … ".."
		
		pea	ma_up(pc)
		gem	dsetpath
.out		
		movem.l	(sp)+,a3/a5
		rts
		
		****
.bug
		clr.w	fo_kids(a5)
		clr.l	fo_child(a5)
		bra.s	.out
		
		****

**********************************************************************

		********
		
		; dumper le repertoire courant
		; en m‚moire point‚e par A4
		; (descripteur repertoire en a5)
.this_level
		move.l	a3,-(sp)
		
		clr.l	fo_next(a4)
		
		tst.l	ma_maxobj(a6)
		beq	.no_more
		
		move.w	#$0037,-(sp)
		pea	ma_mask(pc)
		gem	fsfirst
		
		tst.l	d0
		bne.s	.no_more
		bra.s	.first
		
		****
.suite
		gem	fsnext
		
		tst.l	d0
		bne.s	.no_more
		
		****
.first		
		move.l	ma_dta(a6),a0
		lea	dt_fname(a0),a1
		
;		cmp.l	#"FTRA",dt_fname(a0)
;		bne.s	.okok
;		illegal
;.okok
		
		
		; ‚limination des parasites VFAT
		
		cmp.b	#$0F,dt_fattr(a0)
		beq.s	.suite
		
		; ‚limination des objets "." et ".."
		
		cmp.b	#".",(a1)
		beq.s	.suite
		
		lea	fo_name(a4),a2
.cop_name
		move.b	(a1)+,(a2)+
		bne.s	.cop_name
		
		moveq	#0,d0
		move.b	dt_fattr(a0),d0
		move.w	d0,fo_attr(a4)
		
		move.w	dt_time(a0),fo_time(a4)
		move.w	dt_date(a0),fo_date(a4)
		
		move.l	dt_fileln(a0),fo_len(a4)
		
		clr.l	fo_child(a4)
		clr.l	fo_next(a4)
		clr.w	fo_kids(a4)
		
		move.l	a5,fo_parent(a4)
		
		addq.w	#1,fo_kids(a5)
		
		move.l	a2,fo_next(a4)
		move.l	a4,a3
		move.l	a2,a4
		
		subq.l	#1,ma_maxobj(a6)
		bgt.s	.suite
		
		****
.no_more
		clr.l	fo_next(a3)
		clr.l	fo_next(a4)
		
		move.l	(sp)+,a3
		rts
		
		********
		
**********************************************************************
		
		********
		DATA
		********
		
ma_mask		dc.b	"*.*",0
		even
ma_up		dc.b	"..",0
		even
ma_root		dc.b	"\",0
		even
		
		********
		
**********************************************************************
