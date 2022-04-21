/*****************************************************************************/
/*                                                                           */
/* Modul: GFA_MYDIAL.C                                                       */
/* Date : 10/11/92                                                           */
/*                                                                           */
/*****************************************************************************/


#include <import.h>

#include <nkcc.h>

#include <mglobal.h>
#include <mydial.h>

#include <export.h>


WORD phys_handle, vdi_handle;

/* Ce module est une interface pour les routines Mydial, si bien que les modif. */
/* de ces mydials il n'y aura que ce module Ö recompiler...                     */

/* Variables d'accäs:															*/

EXTERN WORD function_number;

EXTERN WORD wort1;
EXTERN WORD wort2;
EXTERN WORD wort3;
EXTERN WORD wort4;
EXTERN WORD wort5;
EXTERN WORD wort6;
EXTERN WORD wort7;
EXTERN WORD wort8;

EXTERN LONG long1;
EXTERN LONG long2;
EXTERN LONG long3;
EXTERN LONG long4;
EXTERN LONG long5;



/* fonctions d'appel globales des routines Mydial par numÇro de fonction */

GLOBAL LONG gfa_call_function(VOID)
{
	switch(function_number)
	{
	case 1:

		/* rechercher les donnÇes de la fonte systäme et l'installer pour le programme */
		/* get_sysfnt(WORD vdi_handle, WORD *font_id, WORD *gl_point, WORD *gl_wchar, WORD *gl_hchar); */

		return((LONG) get_sysfnt(wort1, (WORD *) long1, (WORD *) long2, (WORD *) long3, (WORD *) long4));

	case 2:

		/* chercher le Cookie ; si TRUE alors le cookie a ÇtÇ trouvÇ */
		/* GLOBAL BOOLEAN getcookie    _((LONG cookie, LONG *p_value)); */

		return((LONG) getcookie    (long1,(LONG *) long2));

	case 3:

		/* chercher l'objet parent; si ROOT alors NIL (-1) est retournÇ */
		/* GLOBAL WORD    parent       _((OBJECT *tree, WORD obj)); */

		return((LONG) parent ((OBJECT *) long1, wort1));

	case 4:

		/* rechercher ob_spec (aussi pour les objets USERDEF) */
		/* GLOBAL LONG    get_obspec   _((OBJECT *tree, WORD obj)); */

		return((LONG) get_obspec ((OBJECT *) long1, wort1));

	case 5:

		/* modifier ob_spec (aussi pour les objets USERDEF) */
		/* GLOBAL VOID    set_obspec   _((OBJECT *tree, WORD obj, LONG obspec)); */

		set_obspec ((OBJECT *) long1, wort1, long2);
		return(0);

	case 6:

		/* modifier evnt_multi kstate et kreturn avec les keycode normalisÇ de NKCC */
		/* GLOBAL UWORD   normkey      _((WORD ks, WORD kr)); */

		return((LONG) normkey (wort1, wort2));

	case 7:

		/* correspondant Ö form_do: appelle le Dialogue */
		/* GLOBAL WORD    dial_do      _((DIALINFO *di, WORD edit_obj)); */

		return ((LONG) dial_do ((DIALINFO *) long1, wort1));

	case 8:

		/* dÇplacer un dialogue; x,y,w,h dÇfinissent les limites rectangulaires (en principe le bureau sans la ligne de menu */
		/* dial_move sera aussi appelÇ par dial_do */
		/* GLOBAL VOID    dial_move    _((DIALINFO *di, WORD x, WORD y, WORD w, WORD h)); */

		dial_move ((DIALINFO *) long1, wort1, wort2, wort3, wort4);
		return(0);

	case 9:

		/* remplir la structure DIALINFO avec des valeurs, sauver le fond */
		/* GLOBAL BOOLEAN dial_start   _((OBJECT *tree, DIALINFO *di)); */

		return((LONG) dial_start ((OBJECT *) long1, (DIALINFO *) long2));

	case 10:

		/* restaurer le fond, libÇrer la mÇmoire */
		/* GLOBAL VOID    dial_end     _((DIALINFO *di)); */

		dial_end ((DIALINFO *) long1);
		return(0);

	case 11:

		/* centrer le dialogue; correspondant Ö form_center */
		/* GLOBAL VOID    dial_center  _((OBJECT *tree)); */

		dial_center ((OBJECT *) long1);
		return(0);

	case 12:

		/* afficher le Dialogue ; correspondant Ö objc_draw */
		/* GLOBAL VOID    dial_draw    _((DIALINFO *di)); */

		dial_draw ((DIALINFO *) long1);
		return(0);

	case 13:

		/* chercher la ligne suivante dans un champ Ö entrÇes multiples */
		/* GLOBAL WORD    find_next    _((OBJECT *tree, WORD obj)); */

		return((LONG) find_next ((OBJECT *) long1, wort1));

	case 14:

		/* chercher la ligne suivante dans un champ Ö entrÇes multiples */
		/* GLOBAL WORD    find_prev    _((OBJECT *tree, WORD obj)); */

		return((LONG) find_prev ((OBJECT *) long1, wort1));

	case 15:

		/* GLOBAL WORD    get_idx      _((OBJECT *tree, WORD obj, WORD cpos)); */

		return((LONG) get_idx  ((OBJECT *) long1, wort1, wort2));

	case 16:

		/* remplace form_keybd, appelle aussi set_Keybd (routines clavier utilisateur) avec les memes paramätres */
		/* voir form_keybd pour les paramätres */
		/* GLOBAL WORD    form_Keybd   _((OBJECT *tree, WORD edit_obj, WORD next_obj, WORD kr, WORD ks, WORD *onext_obj, UWORD *okr)); */

		return((LONG) form_Keybd ((OBJECT *) long1, wort1, wort2, wort3, wort4,(WORD *) long2,(UWORD *) long3));

	case 17:

		/* chercher le raccourci clavier dans l'arbre objet; retourne l'objet ou NIL  */
		/* startobj: arbre de dÇpart pour la recherche des raccourcis clavier         */
		/*           Normalement ROOT ( Popups)                                       */
		/* ks, kr  : rÇponse de evnt_multi, dÇcrivant le raccourci clavier            */
		/* GLOBAL WORD    shortcut     _((OBJECT *tree, WORD startobj, WORD ks, WORD kr)); */

		return((LONG) shortcut ((OBJECT *) long1, wort1, wort2, wort3));

	case 18:

		/* insertion de la routine clavier indÇpendante dans form_Keybd */
		/* quand la routine ne peut Çvaluer la touche, il faut lui retourner NIL, */
		/* sinon la valeur de retour de form_button ou form_keybd. */
		/* a la fin du dialogue, la routine sera enlevÇe */
		/* GLOBAL VOID    set_Keybd    _((FORMKEYFUNC fun)); */

		set_Keybd ((FORMKEYFUNC) long1);
		return(0);

	case 19:

		/* rechercher l'adresse de la routine utilisateur insÇrÇe */
		/* GLOBAL FORMKEYFUNC get_Keybd _((VOID)); */

		return((LONG) get_Keybd ());

	case 20:

		/* objc_edit propre Ö Mydial                                    */
		/* lorsque le dialogue est dans une fenetre, winhndl            */
		/* doit connaitre l'identification de cette fenetre, sinon NIL. */
		/* Le curseur sera placÇ dans l'angle droit de la liste         */
		/* afin d'Çviter des erreurs de redraw.                         */
		/* GLOBAL WORD		obj_edit		_((OBJECT *ob_edtree, WORD ob_edobject, WORD kstate, WORD ob_edchar, WORD *ob_edidx, WORD ob_edkind, WORD mode, WORD *next_obj, WORD winhndl)); */

		return ((LONG) obj_edit	((OBJECT *) long1, wort1, wort2, wort3,(WORD *) long2, wort4, wort5,(WORD *) long3, wort6));

	case 21:

		/* remplace form_alert, appelle dial_alert avec dial_alert (NULL, string, defbut, 0, ALI_LEFT). */
		/* GLOBAL WORD    do_alert     _((WORD defbut, CONST BYTE *txt)); */

		return((LONG) do_alert (wort1, (CONST BYTE *) long1));

	case 22:

		/* appel Çtendu de form_alert: */
		/* alicon : appliquer l'icone propre; si NULL, l'affichage de l'icìne sera utilisÇe en chaåne */
		/* string : chaåne d'alerte, comme dans form_alert */
		/*			quand le texte d'un bouton commence avec un point, il sera considÇrÇ comme bouton par dÇfaut */
		/*			s'il commence par un double point, il sera considÇrÇ comme bouton Undo par dÇfaut */
		/*			Dans ces deux cas, les valeurs de defbut et undobut seront ignorÇes. */
		/* defbut : bouton de sortie par dÇfaut */
		/* undobut: bouton Undo par dÇfaut, sera utilisÇ par la touche UNDO */
		/* align  : positionnement du texte d'alerte: ALI_LEFT, ALI_CENTER, ALI_RIGHT, dÇfinis dans VDI.H */
		/*          Les lignes isolÇes peuvent àtre positionnÇes grace Ö ALCENTER ou ALRIGHT */
		/* GLOBAL WORD    dial_alert   _((BITBLK *alicon, CONST BYTE *string, WORD defbut, WORD undobut, WORD align)); */

		return((LONG) dial_alert ((BITBLK *) long1, (CONST BYTE *) long2, wort1, wort2, wort3));

	case 23:
                /* Donne le pointeur sur la structure BITBLK d'un numÈro d'icÙne*/
		/* GLOBAL BITBLK  *get_icon    _((WORD icon)); */

		return((LONG) get_icon (wort1));

	case 24:

		/* Zerlegt Alertstring in 8 einzelne Strings, 5 Textzeilen und 3 Buttons */
		/* Gibt Iconnummer zurÅck */
		/* GLOBAL WORD    al_token     _((CONST BYTE *f_alert, BYTE str[8][50], WORD *txtnum, WORD *butnum)); */

		return((LONG) al_token ((CONST BYTE *) long1 ,(VOID *) long2 ,(WORD *) long3 ,(WORD *) long4 ));

	case 25:
		/* popup_menu: PopupmenÅ anzeigen															*/
		/* tree      : Adresse des Objektbaums, in dem sich das PopupmenÅ befindet		*/
		/* obj       : index des Popups																*/
		/* x, y      : Position der linken oberen Popup-Ecke (bzw.des Objektzentrums, */
		/*             wenn center_obj != NIL)														*/
		/* center_obj: enthÑlt den Index des zu zentrierenden Popup-Eintrags.			*/
		/* relative  : TRUE: Popup wird an der Mausposition gezeichnet, x und y			*/
		/*             sollten dann 0 sein.															*/
		/* bmsk      : gibt den Mausbutton an, mit dem das Popup verlassen wird			*/
		/*             (1 = links, 2 = rechts, wie beim AES)									*/
		/* ok        : TRUE, wenn Hintergund gesichert werden konnte, FALSE sonst		*/
		/* Ergebnis  : ausgewÑhlter Eintrag oder NIL												*/
		/* GLOBAL WORD    popup_menu   _((OBJECT *tree, WORD obj, WORD x, WORD y, WORD center_obj, BOOLEAN relative, WORD bmsk, BOOLEAN *ok)); */

		return((LONG) popup_menu ((OBJECT *) long1, wort1, wort2, wort3, wort4, (BOOLEAN) wort5, wort6, (BOOLEAN *) long2));

	case 26:

		/* popup_select: changer dans le dialogue le bouton Popup avec le bouton de Cyclage			*/
		/* dialtree  : arbre dialogue																*/
		/* btn       : index de l'objet appelÇ par le Popup (types acceptÇs: BoxText, Button, String, Userdef-Boxtext ou Userdef-Button) */
		/* poptree   : Adresse de l'arbre objet dans lequel se trouve le menu Popup.				*/
		/* obj       : Index du Popup																*/
		/*			   Les entrÇes isolÇes doivent àtre comme des chaånes ou Chaånes accessibles au clavier (Userdef 19) */
		/* docheck   : vÇrifier l'entrÇe Popup (avec Button-text)									*/
		/* docycle   : DO_POPUP: montrer le Popup; DO_CYCLE, DO_POPNEXT: montrer l'entrÇe suivante	*/
		/*             DO_POPPREV: montrer l'entrÇe prÇcÇdente										*/
		/* ok        : TRUE, quand le fond peut àtre sauvÇ, FALSE sinon								*/
		/* rÇsultat  : entrÇe choisie ou NIL												*/
		/* GLOBAL WORD	   popup_select _((OBJECT *dialtree, WORD btn, OBJECT *poptree, WORD obj, BOOLEAN docheck, WORD docycle, BOOLEAN *ok)); */

		return((LONG) popup_select ((OBJECT *) long1, wort1, (OBJECT *) long2, wort2, (BOOLEAN) wort3, wort4, (BOOLEAN *) long3));

	case 27:

		/* ouvrir le dialogue, appelle Growbox , et dial_start 						 				*/
		/* size = NULL est le point de sortie de la Growbox du milieu d'Çcran						*/
		/* la valeur de retour dÇfinit si le fond peut àtre sauvÇ ou non							*/
		/* GLOBAL BOOLEAN open_dial    _((OBJECT *tree, BOOLEAN grow, RECT *size, DIALINFO *dialinfo)); */

		return((LONG) open_dial ((OBJECT *) long1, (BOOLEAN) wort1, (RECT *) long2, (DIALINFO *) long3));

	case 28:

		/* Fermer le dialogue, appelle Shrinkbox , et dial_end 										*/
		/* size = NULL est le point de destination de la Shrinkbox du milieu de l'Çcran 			*/
		/* GLOBAL BOOLEAN close_dial   _((BOOLEAN shrink, RECT *size, DIALINFO *dialinfo)); */

		return((LONG) close_dial ((BOOLEAN) wort1, (RECT *) long1, (DIALINFO *) long2));

	case 29:

		/* gestion compläte du dialogue, appelle open_dial, do_dial et close dial					*/
		/* le renvoi indique si le fond peut àtre sauvÇ.	 										*/
		/* GLOBAL WORD    HndlDial     _((OBJECT *tree, WORD def, BOOLEAN grow_shrink, RECT *size, BOOLEAN *ok)); */

		return((LONG) HndlDial ((OBJECT *) long1, wort1, (BOOLEAN) wort2, (RECT *) long2, (BOOLEAN *) long3));

	case 30:

		/* inscrit l'objet USERDEF, is_dialog dÇfinit si c'est une boåte de dialogue ou un menu dÇroulant	*/
		/* GLOBAL VOID    dial_fix     _((OBJECT  *tree, BOOLEAN is_dialog)); */

		dial_fix ((OBJECT *) long1, (BOOLEAN) wort1);
		return(0);

	case 31:

		/* initialisation du Mydial. Ö effectuer 1 fois au dÇmarrage.										*/
		/* nkc_init et nkc_set ne seront PAS appelÇe dial_init, il faut le faire Ö partir du programme principal   */
		/* GLOBAL BOOLEAN dial_init    _((VOID *alc, VOID *fr, WORD *mnum, MFORM **mform, BOOLEAN *gs)); */

		return((LONG) dial_init (Malloc , Mfree, (WORD *) long3, (MFORM **) long4, (BOOLEAN *) long5));

	case 32:

		/* Suppression du Mydial. Ö effectuer une fois Ö la fin du programme. */
		/* nkc_exit n'est PAS appelÇe par dial_exit, il faut le faire Ö partir du programme principal 		*/
		/* GLOBAL BOOLEAN dial_exit    _((VOID)); */

		return((LONG) dial_exit ());

	case 33:

		/* Efface le clipboard GEM */
		/* GLOBAL WORD    scrap_clear _((VOID)); */

		return((LONG) scrap_clear ());

	case 34:

		/* modifie le titre de la table ASCII. surtout pour les traductions.      	*/
		/* parce que le ressource Mydial n'est pas ici.								*/
		/* l'en-tàte doit àtre une chaåne. Les Mydials ne modifient que le pointeur */
		/* Il faut donc impÇrativement que la chaåne soit bien dÇfinie au paravent. */
		/* GLOBAL VOID    ascii_head _((BYTE *header)); */

		ascii_head ((BYTE *) long1);
		return(0);

	case 35:

		/* rechercher le raccourci clavier dans un arbre menu	                    */
		/* menu  : arbre menu					                                    */
		/* mk    : structure dÇcrivant la touche pressÇe							*/
		/* title : le titre du menu de "item"					                    */
		/* item  : entrÇe correspondante au raccourci clavier						*/
		/* rÇsultat: TRUE = raccourci clavier trouvÇ, sinon FALSE     */
		/* GLOBAL BOOLEAN my_menu_key  _((OBJECT *menu, MKINFO *mk, WORD *title, WORD *item)); */

		return((LONG) my_menu_key ((OBJECT *) long1, (MKINFO *) long2, (WORD *) long3, (WORD *) long4));

	case 128:

	  	/* NKCC est initialisÇ */

		nkc_init (NKI_NO200HZ, 0);                     /* Initialisiere NKCC */
		nkc_set (0);
		return (TRUE);

	case 129:

		nkc_exit ();      /* NKCC terminÇ    */
		return (TRUE);

	}
	return(-42);
}
