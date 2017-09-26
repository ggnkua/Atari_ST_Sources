	rsreset
obck_next	rs.l	1	; pointeur sur le chunk suivante
obck_prev	rs.l	1	; pointeur sur le chunk precedente
obck_name	rs.l	1	; nom du chunk sur 4 caracteres
obck_string	rs.l	1	; valeur du chunk
**************************************
*** Macro definitions pour FASHION ***
**************************************
charge_ressource	macro	; mon_de_fichier
	XREF	_RSC_LOAD
	move.l	\1,-(sp)
	bsr	_RSC_LOAD
	endm

***********************************************************************
*** Fonction realisant une copie de ce qui est pointe par l'ob_spec ***
*** et remplace celui-ci par un nouveau                             ***
***********************************************************************
objc_real	macro	; adresse_objet
	XREF	objc_real_rout
	move.l	\1,-(sp)
	jsr	objc_real_rout
	addq.l	#4,sp
	endm

****************************************************************************************
*** Copy un objet et ses fils, le tout deplace a la sourie d'un formulaire a l'autre ***
****************************************************************************************
copy_objet	macro	; adresse_formulaire,index_objet
	XREF	copy_objet_routine
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	bsr	copy_objet_routine
	addq.l	#6,sp
	endm

*****************************************************
*** Routine de detection des attributs d'un objet ***
*****************************************************
get_obj_attrb	macro	;adr_arbre,index
	XREF	get_obj_attrb_rout
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	get_obj_attrb_rout
	addq.l	#6,sp
	endm

**********************************************************************
*** Affiche les attribus de texte et de couleur dans le formulaire ***
**********************************************************************
graf_obj_attrb	macro	; adr_arbre,index
	XREF	graf_obj_attrb_rout
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	jsr	graf_obj_attrb_rout
	addq.l	#6,sp
	endm

*************************************
*** Reinitialise la fenetre color ***
*************************************
reinit_color_window	macro
	XREF	reinit_color_window_rout
	bsr	reinit_color_window_rout
	endm

******************************************************************************************************
*** Efface une liste d'objet dans un arbre. Si un de ces objets a une descendance, elle est efface ***
******************************************************************************************************
erase_list	macro	; adresse_liste_objets,adresse_arbre
	XREF	erase_list_rout
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	jsr	erase_list_rout
	addq.l	#8,sp
	endm

***********************************************************************************************
*** Desalou tout ce qui est utilise par un objet (exp : la tedinfo et ce qu'elle pointe...) ***
***********************************************************************************************
free_obj	macro	; adresse_de_lobjet
	XREF	free_obj_rout
	move.l	\1,-(sp)
	bsr	free_obj_rout
	addq.l	#4,sp
	endm

******************************************
*** Desalou tout les objets d'un arbre ***
******************************************
efface_tree	macro	; adresse_arbre
	XREF	efface_tree_rout
	move.l	\1,-(sp)
	bsr	efface_tree_rout
	addq.l	#4,sp
	endm

*******************************************************************
*** Routine trouvant un chunk dans la partie indirec d'un objet ***
*********************************************************************************
*** Renvois dans a0 l'adresse du debut du chunk demande (0 si erreur )        ***
*** Et dans a1 l'adresse du debut du bloc precedent                           ***
*** le chunk ayan la structure suivante :                                     ***
*** rs.l	1	; pointeur sur chunk suivant (a zero si pas de chunk) ***
*** rs.b	4	; nom du chunk                                        ***
*********************************************************************************
get_indirect	macro	; adresse_arbre,index_objet,nom_chunk
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	ifnd	get_indirect_rout
	XREF	get_indirect_rout
	endc
	jsr	get_indirect_rout
	lea	10(sp),sp
	endm

********************************************************
*** Set chunk permet de donner un valeur a un chunk  ***
*** Si un valeur etait deja presente, alors elle est ***
*** efface, si aucun chunk, alors on cree la partie  ***
*** indirecte de l'objet                             ***
********************************************************
set_indirect	macro	; adresse_arbre,index_objet,nom_chunk,valeur_chunk
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	move.l	\4,-(sp)
	ifnd	set_indirect_rout
	XREF	set_indirect_rout
	endc
	jsr	set_indirect_rout
	lea	14(sp),sp
	endm

***************************************************************
*** del_indirect supprime un chunk de la liste chaine ***
***************************************************************
del_indirect	macro	; adresse_arbre,index_objet,nom_chunk
	move.l	\1,-(sp)
	move.w	\2,-(sp)
	move.l	\3,-(sp)
	ifnd	del_indirect_rout
	XREF	del_indirect_rout
	endc
	jsr	del_indirect_rout
	lea	10(sp),sp
	endm

