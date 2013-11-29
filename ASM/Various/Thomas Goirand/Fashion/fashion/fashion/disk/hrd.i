* Header du format header
	rsreset
hrdhd_version		rs.w	1	; 1 pour l'instant
hrdhd_autonaming	rs.b	1	; 1 = autonaming actif, 0 sinon
hrdhd_langflag		rs.b	1	; champ de bit. Voir plus bas
hrdhd_autosnap		rs.b	1	; 0 no character snap, 1 = half, 2 = full
hrdhd_casing		rs.b	1	; case : 0 = mixte, 1 = upper, 2 = lower
hrdhd_autosizing	rs.b	1	; 0 = no autosizing, 1 = autosizing
hrdhd_reserved		rs.b	1	; alignement ?
sizeof_hrdhd		rs.w	1

* Definition des bits du champs language "hrdhd_langflag"
HRD_LNG_C	equ	0
HRD_LNG_PASCAL	equ	1
HRD_LNG_MODULA	equ	2
HRD_LNG_FORTRAN	equ	3
HRD_LNG_ASM	equ	4
HRD_LNG_BASIC	equ	5

* Structure d'un enregistrement de label
		rsreset
hrdrec_type	rs.b	1	; valeur voir plus loin
hrdrec_resvd	rs.b	1	; not used
hrdrec_treeidx	rs.w	1	; number of tree
hrdrec_objidx	rs.w	1	; index de l'objet
hrdrec_name	rs.w	1	; debut du label d'un objet

* Definition du "hrdrec_type"
HRDTYP_FORM	equ	0
HRDTYP_MENU	equ	1
HRDTYP_ALTERT	equ	2	; alert
HRDTYP_FRSTRING	equ	3	; free string
HRDTYP_FRIMG	equ	4	; free image
HRDTYP_OBJ	equ	5	; objet
HRDTYP_EOF	equ	6	; fin de fichier
HRDTYP_PREFIX	equ	7
