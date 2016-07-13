	text
*************************************************
*** constantes pour les objets au standar GEM ***
*** pour ZIGO-LIB : un librairie ecrite pour  ***
*** Devpac et ecrite par Thomas GOIRAND       ***
*************************************************
************* Structure de la MFDB **************
* Version plus cool. Faudrait retirer les labels de la vielle version de structure
	rsreset
mfdb_addr	rs.l	1	; adresse du buffer
mfdb_w		rs.w	1	; largeur image en pixels
mfdb_h		rs.w	1	; hauteur image en pixels
mfdb_wordw	rs.w	1	; largeur d'une ligne d'un plan en mot
mfdb_format	rs.w	1	; 0 = format ecran, 1 = format vdi, 2 = ???
mfdb_planes	rs.w	1	; nombre de plan de celui-ci
mfdb_resvd	rs.w	3
mfdb_struc_size	rs.w	1
* Acienne version... un peut naze...
	rsreset
adr_stdr	rs.l	1	; adresse du buffer standard
larg_pixel	rs.w	1	; largeur image en pixels
haut_pixel	rs.w	1	; hauteur image en pixels
larg_mot	rs.w	1	; largeur d'une ligne d'un plan en mot
format		rs.w	1	; indication sur le format des donn‚es 
nbr_plan	rs.w	1	; nombre de plans de l'image
dummy1		rs.w	1
dummy2		rs.w	1
dummy3		rs.w	1
mfdb_size	rs.w	1

************* Structure d'un descripteur de formulaire **************
* David, t'as des idees zarb
	rsreset
_FRM_TREE	rs.l	1
_FRM_HANDLE	rs.l	1

************* Structure d'un objet GEM **************
	text
* definition des bits de la variable FLAGS de la structure des objet GEM *
SELECTABLE	EQU		0
DEFAULT		EQU		1
EXIT		EQU		2
EDITABLE	EQU		3
RBUTTON		EQU		4
LASTOB		EQU		5
TOUCHEXIT	EQU		6
HIDETREE	EQU		7
INDIRECT	EQU		8
FL3DIND		EQU		9
FL3DACT		EQU		10
SUBMENU		EQU		11

* definition des bits de la variable STATES de la structure des objet GEM *
SELECTED	EQU		0
CROSSED		EQU		1
CHECKED		EQU		2
DISABLED	EQU		3
OUTLINED	EQU		4
SHADOWED	EQU		5

* structure des objets GEM *
	rsreset
ob_next		rs.w	1
ob_head		rs.w	1
ob_tail		rs.w	1
ob_type		rs.w	1
ob_flags	rs.w	1
ob_states	rs.w	1
ob_spec		rs.l	1
ob_x		rs.w	1
ob_y		rs.w	1
ob_w		rs.w	1
ob_h		rs.w	1

* structure TED-INFO des objets GEM *
	rsreset
te_ptext		rs.l	1	; pointeur sur le texte
te_ptmplt		rs.l	1	; pointeur sur le masque du texte
te_pvalid		rs.l	1	; pointeur sur la chaine de validation
te_font			rs.w	1	; jeu de caratere
te_fontid		rs.w	0
te_resvd1		rs.w	0
te_junk1		rs.w	1	; innutilise
te_just			rs.w	1	; justification
te_color		rs.w	1	; couleur
te_fontsize		rs.w	0
te_resvd2		rs.w	0
te_junk2		rs.w	1	; inutilise
te_thickness		rs.w	1	; epaisseur du cadre
te_txtlen		rs.w	1	; longueur du texte
te_tmplen		rs.w	1	; longueur du masque
te_struc_size		rs.w	1	; taille de la structure

* Definition des bits de te_just
TE_JUST1	equ	0
TE_JUST2	equ	1
TE_THICKENED	equ	2
TE_LIGHT	equ	3
TE_SKEWED	equ	4
TE_UNDERLINE	equ	5
TE_OUTLINED	equ	6
TE_SHADOWED	equ	7

* valeur OB_TYPE des objets *
G_BOX		equ	20
G_TEXT		equ	21
G_BOXTEXT	equ	22
G_IMAGE		equ	23
G_PROGDEF	equ	24
G_IBOX		equ	25
G_BUTTON	equ	26
G_BOXCHAR	equ	27
G_STRING	equ	28
G_FTEXT		equ	29
G_FBOXTEXT	equ	30
G_ICON		equ	31
G_TITLE		equ	32
G_CICON		equ	33
G_BOUNDING	equ	34
G_BOUNDED	equ	35
G_PIX		equ	36
G_LINE		equ	37
G_CHECK		equ	38

* Definition de la structure d'un ressource sur disk... de la daube, mais on fait avec !
	rsreset
rsh_vrsn	rs.w	1	; numero de version. $C pour "Centek" cool non ?
rsh_object	rs.w	1	; offset vers la structure des OBJETs
rsh_tedinfo	rs.w	1	; offset vers la structure des TEDINFOs
rsh_iconblk	rs.w	1	; offset vers la structure des ICONBLKs
rsh_bitblk	rs.w	1	; offset vers la structure des BITBLKs
rsh_frstr	rs.w	1	; offset vers la structure des STRING POINTERs
rsh_string	rs.w	1	; offset vers la structure des STRING DATAs
rsh_imdata	rs.w	1	; offset vers la structure des IMAGE DATAs
rsh_frimg	rs.w	1	; offset vers la structure des IMAGE POINTERs
rsh_trindex	rs.w	1	; offset vers la structure des TREE POINTERs
rsh_nobs	rs.w	1	; nombre d'objet dans le fichier
rsh_ntrees	rs.w	1	; nombre d'arbre dans le fichier
rsh_nted	rs.w	1	; nombre de TEDINFO dans le fichier
rsh_nib		rs.w	1	; nombre de ICONBLKs dans le fichier
rsh_nbb		rs.w	1	; nombre de BITBLKs dans le fichier
rsh_nstring	rs.w	1	; nombre de free STRINGS dans le fichier
rsh_nimages	rs.w	1	; nombre d'image dans le fichier
rsh_rssize	rs.w	1	; taille de la "vielle" partie du ressource
rsh_struct_size	rs.w	1	; taille de la structure
	text
* Definition de l'extention array des ressources
	rsreset
filesize	rs.l	1	; taille total du fichier sur disk
cicon_offset	rs.l	1	; offset vers les icones couleurs
palette_interf	rs.l	1	; ??? palette interface ???
extended_zone	rs.l	1	; Zone d'extension
zore_end	rs.l	1	; pointeur nul = fin du tableau
ext_array_size	rs.w	1	; taille du tableau d'extention

* Definition d'un BITBLK
	rsreset
bi_pdata	rs.l	1	; pointeur sur les donnes (l'image koi)
bi_wb		rs.w	1	; taille en word d'une ligne de l'image
bi_hl		rs.w	1	; nombre de ligne de l'image
bi_x		rs.w	1	; position en X de l'image
bi_y		rs.w	1	; position en Y
bi_color	rs.w	1	; couleur de l'image
bi_struc_size	rs.w	1

* Definition d'un ICONBLK
	rsreset
ib_pmask	rs.l	1	;  ; pointeur sur le mask
ib_pdata	rs.l	1	; 4; pointeur sur les data
ib_ptext	rs.l	1	; 8; pointeur sur le texte
ib_char		rs.w	1	;12; caractere de l'icone (pour les lecteurs)...
ib_xchar	rs.w	1	;14; 		...position du caractere de l'icone...
ib_ychar	rs.w	1	;16;		...par rapport a celle du graphisme de celui-ci
ib_xicon	rs.w	1	;18; position de l'icone par rapport au coin superieur...
ib_yicon	rs.w	1	;20; ...gauche de l'objet icone
ib_wicon	rs.w	1	;22; largeur de l'icone (multiple de 16)
ib_hicon	rs.w	1	;24; hauteur de l'iconee
ib_xtext	rs.w	1	;26; position du texte de l'icone par rapport au coin superieur...
ib_ytext	rs.w	1	;28; ...gauche de l'objet icone
ib_wtext	rs.w	1	;30; largeur du texte
ib_htext	rs.w	1	;32; hauteur
ib_resvd	rs.w	1	;34;
ib_struc_size_mono	rs.w	1	;36 taille en mono : 36 octets
ib_struc_size_color	rs.w	1

* Definition d'un CICONBLK
	rsreset
num_planes	rs.w	1	; nombre de plan pour la resolution de cette structure
col_data	rs.l	1	; pointeur sur le data (deselectionne)
col_mask	rs.l	1	; pointeur sur le mask (deselectionne)
sel_data	rs.l	1	; pointeur sur le data (selectionne)
sel_mask	rs.l	1	; pointeur sur le mask (selectionne)
cic_next	rs.w	0
next_res	rs.l	1	; pointeur vers resolution suivante
ciconblk_struc_size	rs.w	1

cic_planes	equ	num_planes
cic_pdata	equ	col_data
cic_pmask	equ	col_mask
cic_psdata	equ	sel_data
cic_psmask	equ	sel_mask

* Definition d'un G_BOUNDING
	rsreset
gbo_tree	rs.l	1	; pointeur sur l'arbre affiche
gbo_first	rs.w	1	; 1er objet affiche
gbo_depth	rs.w	1	; profondeur
sizeof_gbo	rs.w	1

* Definition d'un G_BOUNDED
	rsreset
gbd_tree	rs.l	1	; pointeur sur l'arbre englobant
gbd_index	rs.w	1	; index de l'objet g_bounding
gbd_flags	rs.w	1	; bit "0" : a 1 ou 0
sizeof_gbd	rs.w	1

* Definition G_PIX
	rsreset
gpix_path	rs.l	1	; chemin sur disque (si n‚c‚ssaire)
gpix_list	rs.l	1	; tete de la liste chain‚e
gpix_ptr	rs.l	1	; pointeur sur l'objet PIX courant
gpix_x		rs.l	1	; ajustement x relatif … l'objet aes
gpix_y		rs.l	1	; ajustement y relatif … l'objet aes
gpix_flags	rs.l	1	; voir plus bas...
sizeof_gpix	rs.w	1

* Definition des bits du mot flags d'un g_pix
GPIX_DISKLOAD	equ	0	; a 1, l'image est charge du disk
GPIX_MOSAIC	equ	1	; a 1, l'image rempli toute la surface de l'objet en mosaic
GPIX_ALTERN	equ	2	; a 1, le GPIX utilise une image differente si la sourie passe dessus

* Object color index
WHITE	equ	0
BLACK	equ	1
RED	equ	2
GREEN	equ	3
BLUE	equ	4
CYAN	equ	5
YELLOW	equ	6
MAGENTA	equ	7
LGREY	equ	8
DGREY	equ	9
LRED	equ	10
LGREEN	equ	11
LBLUE	equ	12
LCYAN	equ	13
LYELLOW	equ	14
LMAGENTA	equ	15

* Header du format ressource (New ReSsource Header)
		rsreset
nrsh_id		rs.l	2	; "DLMNRSRC"
nrsh_vrsn	rs.l	1	; version , hi/lo … l'endroit
nrsh_hdlen	rs.l	1	; longueur totale de l'en-tete
nrsh_rsced	rs.l	1	; pointeur sur structure sp‚cifique … l'‚diteur de ressource
nrsh_edtype	rs.l	1	; identificateur de l'editeur de ressource (chez moi, c'est "FASH")
nrsh_ntree	rs.l	1	; nombre d'arbres
nrsh_treetbl	rs.l	1	; pointeur sur table de pointeurs d'arbres (rptb)
nrsh_nobj	rs.l	1	; nombre total d'objet dans le ressource
nrsh_objs	rs.l	1	; pointeur vers le premier objet du ressource
nrsh_reloc	rs.l	1	; table de relogement
nrsh_naddr	rs.l	1	; nombre d'adresse contenues dans la table de relogement
nrsh_label	rs.l	1	; pointeur sur la table des labels
sizeof_nrsh	rs.l	1

* Definition de la table de label (Ressource LaBeL)
		rsreset
rlbl_obaddr	rs.l	1	; adresse de l'objet labelis‚
rlbl_obname	rs.l	1	; pointeur sur le label
rlbl_obbbl	rs.l	1	; pointeur sur la bulle d'aide
rlbl_resvd	rs.l	5	; reserve pour une extention future
sizeof_rlbl	rs.l	1

* Definition de la table d'arbre (Ressource Pointer TaBle)
		rsreset
rptb_type	rs.l	1	; identit‚ de l'entit‚
rptb_ptr	rs.l	1	; adresse qui va avec
sizeof_rptb	rs.l	1

* Valeurs du rptb_type
rptt_dial	equ	0	; dialogue
rptt_menu	equ	1	; menu
rptt_alrt	equ	2	; chaine d'alerte
rptt_fstr	equ	3	; free string
rptt_fobj	equ	4	; free obj

* Element image bitmap evolue
		rsreset		
pix_next	rs.l	1	; pointeur sur objet suivant
pix_prev	rs.l	1	; pointeur sur objet pr‚c‚dent
pix_addr	rs.l	1	; addresse donn‚es de la mappe
pix_w		rs.l	1	; largeur en points
pix_h		rs.l	1	; hauteur en points
pix_bpp		rs.w	1	; nombre de bits par point
pix_type	rs.w	1	; type de mappe
pix_delay	rs.l	1	; delay de transition
pix_mask	rs.l	1	; masque
pix_relx	rs.l	1	; x relatif
pix_rely	rs.l	1	; y relatif
pix_palette	rs.l	1	; pointeur d'objet palette li‚
pix_sizeof	rs.l	0

* Objet pallette
		rsreset
pal_map		rs.l	1	; pointeur sur la palette elle-meme
pal_invmap	rs.l	1	; pointeur de palette inverse li‚e
pal_cnum	rs.w	1	; nb de couleurs
pal_sizeof	rs.w	0		

		********

		; description des structures
		; locales du transformeur bitmap...
		
		rsreset
tx_sptr		rs.l	1	; adresse bitmap source
tx_sw		rs.l	1	; largeur source
tx_sh		rs.l	1	; hauteur source
tx_sbpp		rs.w	1	; bits/pixel
tx_sform	rs.w	1	; format source
tx_dptr		rs.l	1	; adresse bitmap cible
tx_dw		rs.l	1	; largeur cible
tx_dh		rs.l	1	; hauteur cible
tx_dbpp		rs.w	1	; bits/pixel
tx_dform	rs.w	1	; format cible
tx_spalob	rs.l	1	; pointeur sur objet palette source
tx_dpalob	rs.l	1	; pointeur sur objet palette destination
tx_wrkspc	rs.l	1	; pointeur sur bloc m‚moire de travail
tx_dit		rs.w	1	; mode de tramage
tx_getnext	rs.l	1	; pointe sur la routine de lecture
tx_putnext	rs.l	1	; pointe sur la routine d'‚criture
tx_sline	rs.l	1	; adresse buffer de 1 ligne en r/v/b 24 bits
tx_dline	rs.l	1	; adresse buffer de 1 ligne en ind‚x‚ (8  bits)
tx_icmap	rs.l	1	; pointeur de palette inverse
tx_magic	rs.l	1	; pointeur de table magique
tx_limit	rs.l	1	; pointeur de table d'‚cr‚tage
tx_snxtlptr	rs.l	1	; pointe sur prochaine ligne source
tx_snxtloff	rs.l	1	; espace entre les d‚buts de 2 lignes source
tx_dnxtlptr	rs.l	1	; pointe sur la prochaine ligne destination
tx_dnxtloff	rs.l	1	; espace entre les d‚buts de 2 lignes cible
tx_xcount	rs.l	1	; compteur horizontal
tx_ycount	rs.l	1	; compteur vertical
tx_scolnum	rs.w	1	; nombre d'index dans la palette source
tx_dcolnum	rs.w	1	; nombre d'index dans la palette destination
tx_ptr1		rs.l	1	; pointeurs … usage multiple
tx_ptr2		rs.l	1
tx_ptr3		rs.l	1
tx_ptr4		rs.l	1
tx_ptr5		rs.l	1
tx_ptr6		rs.l	1
tx_ptr7		rs.l	1
tx_ptr8		rs.l	1
tx_spal		rs.l	1	; pointeur lut source
tx_dpal		rs.l	1	; pointeur lut cible
tx_var1		rs.l	1	; variables suppl‚mentaires
tx_var2		rs.l	1
tx_sbitoff	rs.l	1	; offset de plan source (utilis‚ en vdi)
tx_dbitoff	rs.l	1	; offset de plan cible (utilis‚ en vdi)
tx_status	rs.w	1	; code status:
				; -----------------------
				; | bit |   0   |   1   |
				; -----------------------
				; |  0  | norm  | init  |
				; |  1  | norm  | stop  |
				; -----------------------

tx_proc		rs.l	1	; pointeur sur routine de tramage/remapping
tx_speed	rs.l	1	; facteur vitesse = nombre max de lignes par appel
tx_sizeof	rs	0
