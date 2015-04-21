***************************************************************************
*=========================================================================*
*==						==*
*==  MACROS POUR LA MANIPULATION DE FICHIERS SOUS GEMDOS EN ASSEMBLEUR 	==*
*==						==*
*=========================================================================*
***************************************************************************

;	FCREATE	handle,#attribut,nom
;	FOPEN	handle,#open_mode,nom
;	FCLOSE	handle
;	FREAD	handle,#nombre,buffer
;	FWRITE	handle,#nombre,buffer
;	FSEEK	handle,#seek_mode,#nombre
;	FRENAME	ancien_nom,nouveau_nom
;	FDELETE	nom
;	FATTRIB	nom,#flag,#attribut
;	FDATIME	handle,#flag,buffer_4_octets
;	FGETDTA	adresse
;	FSFIRST	nom,#attribut_recherche
;	FSNEXT
;	DFREE	#lecteur,buffer_16_octets
;	DCREATE	chemin
;	DDELETE	chemin
;	DSETPATH	chemin
;	DGETPATH	#lecteur,buffer_64_octets_au_moins

;	SAVE	nom,adresse,#taille
;	LOAD	nom,adresse,#taille

***************************************************************************

;Les attributs:
;	$00= Lecture/‚criture possibles.
;	$01= Read only, lecture seule possible.
;	$02= Fichier cach‚.
;	$04= Fichier systŠme cach‚.
;	$08= Contient le nom de la disquette.
;	$10= Sous-r‚pertoire.
;	$20= Bit d'archivage, Lecture/‚criture possibles..
	
;Les attributs de recherche:
;	$00= AccŠs normal en lecture/‚criture.
;	$01= AccŠs normal en lecture.
;	$02= Entr‚e cach‚e.
;	$04= Entr‚e systŠme cach‚e.
;	$08= Nom de la disquette.
;	$10= Sous-r‚pertoire.
;	$20= Fichier ferm‚ aprŠs qu'on y ait ‚crit.
	
;Les diff‚rents modes pour FOPEN:
;	$00= Lecture seule.
;	$01= Ecriture seule.
;	$02= Lecture et ‚criture.
	
;Les diff‚rents modes pour FSEEK:
;	$00= Se d‚place … partir du d‚but du fichier.
;	$01= Se d‚place … partir de la position actuelle.
;	$02= Se d‚place … partir de la fin du fichier.
;		($02: seules les valeurs n‚gatives sont autoris‚es)

;Les diff‚rents flags pour FATTRIB:
;	$00= Consulter les attributs du fichier.
;	$01= Fixer les attributs du fichier.

;Les diff‚rents flags pour FDATIME:
;	$00= Fixer la date et l'heure.
;	$01= Consulter la date et l'heure.

***************************************************************************
		
FCREATE:	MACRO
	move.w	\2,-(sp)
	pea	\3
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,\1
	ENDM	

FOPEN:	MACRO
	move.w	\2,-(sp)
	pea	\3
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,\1
	ENDM

FCLOSE:	MACRO
	move.w	\1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM
	
FREAD:	MACRO
	pea	\3
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FWRITE:	MACRO
	pea	\3
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FSEEK:	MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.l	\3,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FRENAME:	MACRO
	pea	\2
	pea	\1
	clr.w	-(sp)
	move.w	#$56,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

FDELETE:	MACRO
	pea	\1
	move.w	#$41,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

FATTRIB:	MACRO
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	pea	\1
	move.w	#$43,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM

FDATIME:	MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	pea	\3
	move.w	#$57,-(sp)
	trap	#1
	lea	10(sp),sp
	ENDM
	
FGETDTA:	MACRO
	move.w	#$2f,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,\1
	ENDM

FSFIRST:	MACRO
	move.w	\2,-(sp)
	pea	\1
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM
	
FSNEXT:	MACRO
	move.w	#$4f,-(sp)
	trap	#1
	addq.l	#2,sp
	ENDM

DFREE:	MACRO
	move.w	\1,-(sp)
	pea	\2
	move.w	#$36,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM
	
DCREATE:	MACRO
	pea	\1
	move.w	#$39,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

DDELETE:	MACRO
	pea	\1
	move.w	#$3a,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM
	
DSETPATH:	MACRO
	pea	\1
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM

DGETPATH:	MACRO
	move.w	\1,-(sp)
	pea	\2
	move.w	#$47,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

***************************************************************************
	
SAVE:	MACRO
	move.l	d7,-(sp)	;d7=handle
	FCREATE	d7,#$00,\1
	FWRITE	d7,\3,\2
	FCLOSE	d7
	move.l	(sp)+,d7
	ENDM

LOAD:	MACRO
	move.l	d7,-(sp)	;d7=handle
	FOPEN	d7,#$00,\1
	FREAD	d7,\3,\2
	FCLOSE	d7
	move.l	(sp)+,d7
	ENDM