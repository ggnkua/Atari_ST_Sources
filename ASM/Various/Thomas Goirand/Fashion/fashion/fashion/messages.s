**********************************************************************************************
*** En vue d'une internationnalisation du logiciel, TOUS les messages on ete regroupe dans ***
*** ce seul et unique source. Facile a traduire du coup !                                  ***
**********************************************************************************************
* Message du menu deroulant
	XDEF	fenetre_non_toppe,new_rsc_name,Ressoucre_non_trouve,ereurum_batatestum
	XDEF	label_dial_default,label_menu_default
	XDEF	fsel_open_texte,fsel_init_string,commentaire_de_sauvegarde,obtype_inferieur_a_256
	XDEF	fenetre_pas_trouve
* Message du source principal
	XDEF	quitage_fichier_non_trouve
* Routine d'effacement
	XDEF	aucun_objet_selected_4_del,root_selected_4_del
* Routine de copie d'objet
	XDEF	copy_impossible,copy_impossible2,copy_erreur
* Fenetre DRAG
	XDEF	sans_slider_impossible
* Chemin des deux ressources du soft et la gpix
	XDEF	rsc_name,tool_bar_path
	XDEF	temp_gpix_img
* Divers
	XDEF	fsel_select_gpix
	XDEF	default_alert_box
	XDEF	close_ressource_msg
	data
********************************************************************************
* menu.s                                                                       *
********************************************************************************
	even
fenetre_non_toppe		dc.b	"[1][Veuillez placer une fenˆtre|de ressource au|premier plan.][ OK ]",0
new_rsc_name			dc.b	"D:\NOUVEAU.RSC",0
Ressoucre_non_trouve		dc.b	"[1][Le ressource n'a pas ete|trouve en m‚moire.][ Zut ! ]",0
ereurum_batatestum		dc.b	"[1][Le ressource est vide et|ne peut donc etre|sauv‚ ...][ Biensur ]",0
label_dial_default		dc.b	"DIALOGUE",0
label_menu_default		dc.b	"MENU",0
fsel_open_texte			dc.b	"Ouverture d'un RSC...",0
fsel_select_gpix		dc.b	"Selectionnez un fichier image...",0
fsel_init_string		dc.b	"E:\CODE\INTRFACE\*.RSC",0
commentaire_de_sauvegarde	dc.b	"Sauvegarde d'un RSC...",0
obtype_inferieur_a_256		dc.b	"[1][Un OB_TYPE ‚tendu ne peut pas etre|superieur a 255. Veuillez|rentrer une valeur plus petite.][ Fichtre ! ]",0
quitage_fichier_non_trouve	dc.b	"[1][Impossible de charger le|ressource d'objet|utilisateur.][ Quitter ]",0
aucun_objet_selected_4_del	dc.b	"[1][Veuillez selectionner au moins|un objet avant de demander un|effacement.][ OK ]",0
root_selected_4_del		dc.b	"[1][L'objet racine fait partie de|la liste des objets selectionn‚s.|Veuillez le cliquer pour l'enlever de la liste|des objets.][ OK ]",0
copy_impossible			dc.b	"[2][Vous ne pouvez pas|copier    un    ou|plusieurs objet(s)|sur le bureau.][ OK ]",0
copy_impossible2		dc.b	"[2][Vous ne pouvez pas|copier    un    ou|plusieurs objet(s)|dans cette fenˆtre.][ OK ]",0
copy_erreur			dc.b	"[2][Copie impossible :|fenˆtre non trouv‚e.][ Ok ]",0
sans_slider_impossible		dc.b	"[2][L'objet racine est trop grand pour|que la fenetre n'ait plus|d'ascenceurs.][ OK ]",0
fenetre_pas_trouve		dc.b	"[2][Fenˆtre non trouve !][ OK ]",0
default_alert_box		dc.b	"[1][Alert][ OK ]",0
close_ressource_msg		dc.b	"[3][Ceci effacera le ressource|de la memoire !][ Effacer | Annuler ]",0
;dc.b	"[1][][]",0
*--------------------------------------------------------------------------------------------------------------------------*
rsc_name	dc.b	"d:\fashion\fashion\FASHION.RSC",0
		ds.b	1024
temp_gpix_img	dc.b	"d:\fashion\fashion\FASHION.GIF",0
		ds.b	1024
tool_bar_path	dc.b	"d:\fashion\fashion\TOOL_BOX.RSC",0
		ds.b	1024
	even
	text
