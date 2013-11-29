*****************************************
* strucutre des donnees du file browser *
* de RUNE, le bureau de Dolmen          *
* Thomas GOIRAND, septembre 1999, pour  *
* la societe Class4/CENTEK              *
*****************************************

* Limites du file-browser

MAXFILE		equ	1024	; nombre maxi de fichier dans une fenetre de rune
FILENAME_SIZE	equ	256	; taille maxi d'un nom de fichier
PATH_SIZE	equ	1024	; taille maxi d'un chemin

************************************************************
*** Une fenetre contient une structure fb (File Browser) ***
************************************************************
	rsreset
fb_state	rs.w	1	; -> champ de bit representant l'etat de la fenetre
fb_tri		rs.w	1	; -> indication de la methode de tri (le bit 15 a 1 signifi ordre inverse)
fb_nbr		rs.l	1	; -> nombre d'entree de directory represente dans la fenetre
fb_ptr		rs.l	1	; -> pointeurs vers le formulaire G_BOUNDED
fb_path		rs.b	PATH_SIZE	; chemin de la fenetre
fb_txt_ptr	rs.l	1	; -> Pointeur vers la zone contenant le texte affiche + les tedinfos pointants sur les lignes
fb_bound_ptr	rs.l	1	; -> Pointeur vers l'arbre a afficher
fb_fbo		rs.l	MAXFILE	; -> tableau de pointeurs vers structure fbo, suivi d'un 0 pour signaler la fin
				; ! attention, taille variable, donc en fin de structure
sizeof_fb	rs.w	1

******************************
*** Definition de fb_state ***
******************************
* A 0, signifi non, a 1, signifi oui
FB_ICON	equ	0	; affichage en grandes icones (oui/non)
FB_SIZE	equ	1	; affichage de la taille (oui/non)
FB_DATE	equ	2	; affichage de la date (oui/non)
FB_TIME	equ	3	; affichage de l'heure (oui/non)
FB_ATRB	equ	4	; affichage des attribus (oui/non)
FB_UNIX	equ	5	; a 1 -> nom longs UNIX, a 0 -> nom 8+3 dos
******************************
*** Definition de fb_state ***
******************************
FB_TNAME	equ	0	; tri par nom
FB_TSIZE	equ	1	; tri par taille
FB_TDATE	equ	2	; tri par date
FB_TTYPE	equ	3	; tri par type
FB_TNO		equ	4	; pas de tri
	rsreset
fbo_type		rs.w	1	; -> type de l'objet
fbo_fron_icon		rs.w	1	; -> numero de l'icone du fichier
fbo_size		rs.l	1	; -> taille du fichier en octet
fbo_time		rs.w	1	; -> heure du fichier, format GEMDOS (heure:5,minute:6,seconde:5)
fbo_date		rs.w	1	; -> date du fichier, format GEMDOS (year:7,month:4,day:5)
fbo_attrb		rs.b	4	; -> 4 octet contenant les attributs UNIX (si le 1er a -1, alors l'octet suivant
					; contient les attributs au format TOS)
fbo_file_name		rs.b	FILENAME_SIZE	; -> pointeur vers le nom du fichier
						; ! attention, taille variable
sizeof_fbo		rs.w	1

*******************************
*** Definition de fbob_type ***
*******************************
FBOT_FOLD	equ	0	; dossier
FBOT_FILE	equ	1	; fichier
FBOT_PRG	equ	2	; programme
FBOT_LINK	equ	3	; lien symbolique

