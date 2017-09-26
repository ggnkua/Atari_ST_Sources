*********************************************
* strucutre des donnees de la fenetre objet *
*********************************************
* on trouve d'abbord la premiere structure, *
* puis la seconde plusieurs fois suivie     *
* d'un zero (0L) en .L                      *
*********************************************
	rsreset
wd_objc_x		rs.w	1	; -> taille en x d'un icone (en pixel)
wd_objc_y		rs.w	1	; -> taille en y d'un icone (en pixel)
wd_objc_skip		rs.w	1	; -> nombre d'icone qu'il ne faut pas afficher
wd_objc_header_size	rs.w	1
	rsreset
wd_objc_form 		rs.l	1	; -> adresse du formulaire contenant l'icone
wd_objc_icon 		rs.w	1	; -> numero de l'icone a afficher
wd_obcj_string		rs.l	1	; -> pointeur sur la chaine de caractere de l'icone
wd_objc_state		rs.w	1	; -> etat de l'objet (0 = non selectionne/1 = selectionne)
wd_objc_struct_size	rs.w	1

*************************************
* Configuration globale du logiciel *
*************************************
label_size	equ	64		; taille des labels pour EQU
fname_size	equ	1024		; taille maxi d'un nom de fichier
nbr_of_tree	equ	256		; nombre maxi d'arbre editable dans un fichier ressource
nbr_of_objc	equ	1024		; nombre maxi d'objet par formulaire

***************************************
* structure d'un ressource en memoire *
***************************************
* structure racine
	rsreset
mrsc_file_name		rs.b	fname_size		; nom du fichier sur disque
mrsc_wind_name		rs.b	fname_size+20		; nom a afficher en haut de la fenetre
mrsc_gemdos_name	rs.b	8+3+2			; nom en 8+3 caractere du fichier
mrsc_ptr		rs.l	nbr_of_tree		; 256 pointeurs vers structure arbres
mrsc_ptrnbr		rs.l	1			; nombre d'abre pointe par les pointeur mrsc_ptr
mrsc_tree_list		rs.b	wd_objc_struct_size*nbr_of_tree+wd_objc_header_size
							; * de la place pour afficher la liste des arbres
mrsc_size		rs.b	1

***********************************
* structure d'un arbre en memoire *
***********************************
	rsreset
mtree_label		rs.b	label_size		; label de l'arbre
mtree_comment		rs.b	label_size		; commentaire de l'arbre
mtree_type		rs.l	1			; type de l'arbre
mtree_objets		rs.b	nbr_of_objc*24*2	; de la place pour les objets
mtree_size		rs.b	1
