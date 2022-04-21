/*****************************************************************************/
/*                                                                           */
/* Modul: MYDIAL.H                                                           */
/* Datum: 04/05/91                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __MYDIAL__
#define __MYDIAL__

/****** DEFINES **************************************************************/

/* Type d'objets ‚tendus */
#define DIALMOVER  0x0011
#define DCRBUTTON  0x0012
#define UNDERLINE  0x0013
#define TITLEBOX   0x0014
#define HELPBUT    0x0015
#define CIRCLEBUT  0x0016
#define POPUPSTRG  0x0017
#define KPOPUPSTRG 0x0018
#define SLIDEPART  0x0019
#define LONGINPUT  0x001A
#define UNDOBUT    0x001F

#define FLAGS11    0x0800  /* Pour les objets accessibles avec la touche UNDO */
#define FLAGS15    0x8000  /* objets … lignes de saisie multiples */

/* Flags pour popup_select */
#define  DO_POPUP     0
#define  DO_CYCLE    -2
#define  DO_POPPREV  -1
#define  DO_POPNEXT   1

/* flag d'alignement Alertboxtext */
#define ALCENTER   "\001"
#define ALRIGHT    "\002"

#define  MAXASTRINGS 15    /* Nombre maxi de lignes pour une Alerte (incl. 3 boutons) */
#define  MAXASLENGTH 50    /* Largeur maxi d'une ligne */

/****** TYPES ****************************************************************/

typedef struct
{
  UWORD e_flags;
  UWORD e_bclk;
  UWORD e_bmsk;
  UWORD e_bst;
  UWORD e_m1flags;
  GRECT e_m1;
  UWORD e_m2flags;
  GRECT e_m2;
  WORD FAR *e_mepbuf;
  WORD  e_ltime;
  WORD  e_htime;
  WORD  e_mx;
  WORD  e_my;
  WORD  e_mb;
  WORD  e_ks;
  UWORD e_kr;
  WORD  e_br;
} MYEVENT;

typedef struct
{
   LONG cookie;         /* doit ˆtre 'VSCR' */
   LONG product;        /* identique … XBRA */
   WORD version;        /* Version du protocole VSCR, d'abord 0x100 */
   WORD x, y, w, h;      /* zone visible de l'‚cran */
} INFOVSCR;

typedef struct
{
   OBJECT   *Tree;
   MFDB  Buffer;
   WORD  x, y, w, h;
} DIALINFO;

typedef struct
{
   USERBLK  ublk;
   UWORD    old_type;
} OBBLK;

typedef VOID (*FORMUSREVENT) (MYEVENT *evdata);
typedef VOID (*FORMEVNTFUNC) (WORD *event, MYEVENT *evdata);

typedef WORD (*FORMKEYFUNC) (OBJECT *, WORD, WORD, WORD, WORD, WORD *, UWORD *);

typedef VOID (*FIXOBJFUNC) (OBJECT *tree, WORD obj);


/****** VARIABLES ************************************************************/

extern INFOVSCR *infovscr;


/****** FUNCTIONS ************************************************************/

/* rechercher les donn‚es de la police systŠme et l'installer comme police systŠme pour les programmes */
BOOLEAN get_sysfnt   _((WORD vdi_handle, WORD *font_id, WORD *gl_point, WORD *gl_wchar, WORD *gl_hchar));

/* rechercher Cookie ; si TRUE, alors Cookie trouv‚e */
BOOLEAN getcookie    _((LONG cookie, LONG *p_value));

/* est-ce qu'une cookie VSCR existe et que l'‚cran visible est plus petit que l'‚cran total */
BOOLEAN ask_vscr     _((VOID));


/*****************************************************************************/
/* D‚finir l'indice couleur VDI pour les formulaires 3D                      */
/* back:  Fond            (d‚faut : 8/gris clair)                            */
/* light: Valeurs claires (d‚faut : 0/blanc)                                 */
/* dark:  Valeurs fonc‚es (d‚faut : 9/Gris clair)                            */
VOID     dial_3Dcolors  (WORD back, WORD light, WORD dark);

/* Modifier l'affichage des objets ROOT(racine) en 3D    					 */
/* border: ‚paisseur de l'objet ROOT en points (incluant le p‚rimŠtre)       */
/* perimt: TRUE = dessiner aussi 1 point noir						         */
VOID     dial_3Droot    (BOOLEAN border, BOOLEAN perimt);

/* calculate the caracter of the input field of the cursor position			 */
/* important pour les 3D-EditObjects										 */
WORD dial_charpos     (OBJECT *tree, WORD obj, WORD curspos, WORD wbox);

/* calculate the position of the cursor depending of the caracter of the actual cursor position */
/* important pour les 3D-EditObjects										 */
WORD dial_curspos     (OBJECT *tree, WORD obj, WORD charpos, WORD wbox);

/* Placer le curseur sur un signe pr‚cis d'un objet			                 */
WORD dial_setcpos     (OBJECT *tree, WORD obj, WORD *idx);

/* R‚cup‚rer la position du curseur (champ, position) 						 */
VOID dial_getcpos     (WORD *obj, WORD *idx);

/* Dessiner le curseur d'‚dition en mode OU-Exclusif (= activer/d‚sactiver)  */
VOID dial_drawcursor  (OBJECT *tree, WORD edit_obj, WORD char_idx, WORD whandle);


/*****************************************************************************/

/* rechercher l'objet parent; si ROOT alors NIL (-1) est renvoy‚ */
WORD    parent       _((OBJECT *tree, WORD obj));

/* rechercher ob_spec (mˆme pour les objets USERDEF) */
LONG    get_obspec   _((OBJECT *tree, WORD obj));

/* modifier ob_spec (mˆme pour les objets USERDEF) */
VOID    set_obspec   _((OBJECT *tree, WORD obj, LONG obspec));

/* remplacer evnt_multi kstate et kreturn grace … NKCC en KeyCode normalis‚s */
UWORD   normkey      _((WORD ks, WORD kr));


/*****************************************************************************/

/* insŠre une fonction sp‚ciale qui sera appel‚e par la suite lorsque le type */
/* d'objet ‚tendu d'un Mydial est reconnu.									  */
VOID set_fixobj       _((FIXOBJFUNC fun));

/* indique un pointeur pour une fonction d‚finissable par l'utilisateur */
FIXOBJFUNC get_fixobj _((VOID));

/* montrer USERBLK pour un objet, ensuite ‚changer l'objet dans Userdef */
USERBLK *add_ublock   _((WORD cdecl (*code)(PARMBLK *parmblock), LONG obspec, WORD type));


/*****************************************************************************/

/* identique … form_do: appel du dialogue */
WORD    dial_do      _((DIALINFO *di, WORD edit_obj));

/* d‚placement de dialogue; x,y,w,h d‚finissent les marges maxi (en principe la taille du bureau sans la ligne de menu  */
/* dial_move est aussi utilis‚ par dial_do */
VOID    dial_move    _((DIALINFO *di, WORD x, WORD y, WORD w, WORD h));

/* remplissage de la structure DIALINFO avec des valeurs, m‚moriser le fond */
BOOLEAN dial_start   _((OBJECT *tree, DIALINFO *di));

/* restaurer le fond, lib‚rer la m‚moire */
VOID    dial_end     _((DIALINFO *di));

/* centrer le dialogue ; identique … form_center */
VOID    dial_center  _((OBJECT *tree));

/* montrer le dialogue; identique … objc_draw */
VOID    dial_draw    _((DIALINFO *di));



/*****************************************************************************/

/* chercher la ligne suivante d'un champ … entr‚es multiples 						*/
WORD    find_next    _((OBJECT *tree, WORD obj));

/* chercher la ligne pr‚c‚dente d'un champ … entr‚es multiples 						*/
WORD    find_prev    _((OBJECT *tree, WORD obj));

WORD    get_idx      _((OBJECT *tree, WORD obj, WORD cpos));

/* remplace form_keybd, … appeler avec les routines claviers d‚finies par         	*/
/* l'utilisateur sous set_Keybd avec les paramŠtres identiques 						*/
/* voir form_keybd pour les paramŠtres */
WORD    form_Keybd   _((OBJECT *tree, WORD edit_obj, WORD next_obj, WORD kr, WORD ks, WORD *onext_obj, UWORD *okr));

WORD    form_Button  _((WORD handle, OBJECT *tree, WORD obj, WORD clicks, WORD *nextobj));

/* chercher un raccourci dans un objet Arbre; renvoi l'objet ou NIL               	*/
/* startobj: arbre de d‚part pour la recherche des raccourcis clavier             	*/
/*           Normalement ROOT ( Popups)                                           	*/
/* ks, kr  : valeur de retour de evnt_multi, d‚crivant le raccourci clavier       	*/
WORD    shortcut     _((OBJECT *tree, WORD startobj, WORD ks, WORD kr));

/* Insertion d'une routine de gestion des ‚v‚nements dans dial_do                 	*/
/* dial_do peut maintenant etre test‚ avec de nouveaux ‚v‚nements (ex Timer)      	*/	
/* La routine sera enlev‚e … la fermeture du formulaire 					      	*/
VOID    set_MyEvnt   _((FORMUSREVENT init_func, FORMEVNTFUNC evnt_func));

/* R‚cup‚rer l'adresse de la routine utilisateur de gestion des ‚v‚nements		  	*/
VOID    get_MyEvnt   _((FORMUSREVENT *init_func, FORMEVNTFUNC *evnt_func));

/* insertion de la routine clavier ind‚pendante dans form_Keybd 					*/
/* quand la routine ne peut ‚valuer la touche, il faut lui retourner NIL, 			*/
/* sinon la valeur de retour de form_button ou form_keybd. 							*/
/* a la fin du dialogue, la routine sera enlev‚e 									*/
VOID    set_Keybd    _((FORMKEYFUNC fun));

/* rechercher l'adresse de la routine utilisateur ins‚r‚e */
FORMKEYFUNC get_Keybd _((VOID));

/* objc_edit propre … Mydial                                    */
/* lorsque le dialogue est dans une fenetre, winhndl            */
/* doit connaitre l'identification de cette fenetre, sinon NIL. */
/* Le curseur sera plac‚ dans l'angle droit de la liste         */
/* afin d'‚viter des erreurs de redraw.                         */
WORD     obj_edit    _((OBJECT *ob_edtree, WORD ob_edobject, WORD kstate, WORD ob_edchar, WORD *ob_edidx, WORD ob_edkind, WORD mode, WORD *next_obj, WORD winhndl));

/* Copie d'une chaine dans un objet                                */
/* Cette fonction travaille aussi avec les Userdefs de MyDial      */
/* Les types d'objets suivants sont reconnus:                      */
/* G_BUTTON, G_STRING, G_TITLE, G_CICON, G_ICON, G_BOXCHAR         */
/* G_TEXT, G_BOXTEXT G_FTEXT, G_FBOXTEXT (chaque fois te_ptext)    */
/* Valeur de retour: Un pointeur sur la chaine destination         */
BYTE *objc_setstring _((OBJECT *tree, WORD obj, CONST BYTE *text));

/* Copie du texte d'un objet dans une chaine	                   */
/* Cette fonction travaille aussi avec les Userdefs de MyDial      */
/* Les types d'objets suivants sont reconnus:                      */
/* G_BUTTON, G_STRING, G_TITLE, G_CICON, G_ICON, G_BOXCHAR         */
/* G_TEXT, G_BOXTEXT G_FTEXT, G_FBOXTEXT (jeweils te_ptext)        */
/* Valeur de retour: Un pointeur sur la chaine destination         */
BYTE *objc_getstring _((OBJECT *tree, WORD obj, BYTE *text));

/*****************************************************************************/

/* remplace form_alert, appelle dial_alert avec dial_alert (NULL, string, defbut, 0, ALI_LEFT). */
WORD    do_alert     _((WORD defbut, CONST BYTE *txt));

/* appel ‚tendu de form_alert: */
/* alicon : appliquer l'icone propre; si NULL, l'affichage de l'ic“ne sera utilis‚e en chaŒne */
/* string : chaŒne d'alerte, comme dans form_alert */
/*			quand le texte d'un bouton commence avec un point, il sera consid‚r‚ comme bouton par d‚faut */
/*			s'il commence par un double point, il sera consid‚r‚ comme bouton Undo par d‚faut */
/*			Dans ces deux cas, les valeurs de defbut et undobut seront ignor‚es. */
/* defbut : bouton de sortie par d‚faut */
/* undobut: bouton Undo par d‚faut, sera utilis‚ par la touche UNDO */
/* align  : positionnement du texte d'alerte: ALI_LEFT, ALI_CENTER, ALI_RIGHT, d‚finis dans VDI.H */
/*          Les lignes isol‚es peuvent ˆtre positionn‚es grace … ALCENTER ou ALRIGHT */
WORD    dial_alert   _((OBJECT *alicon, CONST BYTE *string, WORD defbut, WORD undobut, WORD align));

/* renvoi … un num‚ro d'ic“ne le pointeur dans la structure BITBLK */
BITBLK  *get_icon    _((WORD icon));

/* d‚composition de la chaŒne d'alerte en 8 chaŒnes individuelles, 5 lignes de texte et 3 boutons. */
/* renvoie le num‚ro d'ic“ne */
WORD    al_token     _((CONST BYTE *f_alert, BYTE str[8][50], WORD *txtnum, WORD *butnum));

/* Calculer la taille de la boite d'alerte 														  */
/* alicon : appliquer l'icone propre; si NULL, l'affichage de l'ic“ne sera utilis‚e en chaŒne	  */
/* string : chaŒne d'alerte, comme dans form_alert												  */
/* defbut : bouton de sortie par d‚faut															  */
/* undobut: bouton Undo par d‚faut, 															  */
/* tree    : si diff‚rent de NULL, alors il contient, aprŠs l'appel, un pointeur sur l'arbre d'alerte   */
/* firstbut: si diff‚rent de NULL, alors il contient, aprŠs l'appel, le num‚ro du premier bouton  */
/* alert_texte: si diff‚rent de NULL, alors il contient, aprŠs l'appel, tout le texte d'alerte    */
/*              Le tableau a une taille de alert_texte[MAXASTRINGS][MAXASLENGTH]                  */
/* size    : il contient, aprŠs l'appel, la largeur et la hauteur de la boite d'alerte            */
/* al_dat  : si diff‚rent de NULL, alors pointeur sur 8 WORDs contenant les donn‚es de l'alerte   */
WORD alert_data      _((OBJECT *alicon, CONST BYTE *string, WORD defbut, WORD undobut, OBJECT **tree, WORD *firstbut, BYTE alert_texte[][MAXASLENGTH], RECT *size, WORD al_dat[]));

/* dessiner la boite d'alerte */
/* alicon : appliquer l'icone propre; si NULL, l'affichage de l'ic“ne sera utilis‚e en chaŒne	  */
/* alert_texte: contient le texte de l'alerte. sera initialis‚ par alert_data                     */
/* size   : contient largeur et hauteur de l'alerte. si le handle est diff‚rent de NIL, alors     */
/*          size->x et size->y seront ‚valu‚s pour le positionnement de la boite                  */
/* al_dat : pointeur sur 8 WORDs contenant les donn‚es de l'alerte.sera initialis‚ par alert_data */
/* align  : Positionnement du texte d'alerte (voir dial_alert)                                    */
/* clip   : si diff‚rent de NULL, alors la boite sera dessin‚e par dessus ce clipping rectangle   */
VOID alert_draw      _((OBJECT *alicon, BYTE alert_texte[][MAXASLENGTH], RECT *size, WORD al_dat[], WORD align, RECT *clip));

/* Quitter la boite d'alerte */
/* close_alert r‚initialise l'arbre de l'alerte, afin de le remettre … son ‚tat inital		      */
/* Cette fonction ne doit etre utilis‚e qu'en collaboration avec draw_alert                       */
/* al_dat : pointeur sur 8 WORDs contenant les donn‚es de l'alerte.sera initialis‚ par alert_data */
VOID alert_close     _((WORD al_dat[]));

/******************************************************************************/

/* popup_menu: Montrer un menu Popup														*/
/* tree      : Adresse de l'arbre objet dans lequel se trouve le menu Popup					*/
/* obj       : index du Popup																*/
/* x, y      : position du coin Haut-Gauche du Popup (sinon du centre de l'objet, 			*/
/*             lorsque center_obj != NIL)													*/
/* center_obj: contient l'index de l'entr‚e Popup … centrer									*/
/* relative  : TRUE: sera affich‚ … la position souris, x et y								*/
/*             doivent ˆtre … 0.															*/
/* bmsk      : indique le bouton souris qui a ‚t‚ utilis‚ pour quitter le Popup				*/
/*             (1 = gauche, 2 = droite, comme pour l'AES)									*/
/* ok        : TRUE quand le fond peut ˆtre sauv‚, FALSE sinon								*/
/* r‚sultat  : entr‚e choisie ou NIL														*/

WORD    popup_menu   _((OBJECT *tree, WORD obj, WORD x, WORD y, WORD center_obj, BOOLEAN relative, WORD bmsk, BOOLEAN *ok));

/* popup_select: changer dans le dialogue le bouton Popup avec le bouton de Cyclage			*/
/* dialtree  : arbre dialogue																*/
/* btn       : index de l'objet appel‚ par le Popup (types accept‚s: BoxText, Button, String, Userdef-Boxtext ou Userdef-Button) */
/* poptree   : Adresse de l'arbre objet dans lequel se trouve le menu Popup.				*/
/* obj       : Index du Popup																*/
/*			   Les entr‚es isol‚es doivent ˆtre comme des chaŒnes ou ChaŒnes accessibles au clavier (Userdef 19) */
/* docheck   : v‚rifier l'entr‚e Popup (avec Button-text)									*/
/* docycle   : DO_POPUP: montrer le Popup; DO_CYCLE, DO_POPNEXT: montrer l'entr‚e suivante	*/
/*             DO_POPPREV: montrer l'entr‚e pr‚c‚dente										*/
/* ok        : TRUE, quand le fond peut ˆtre sauv‚, FALSE sinon								*/
/* r‚sultat  : entr‚e choisie ou NIL														*/
/* wh        : handle fenetre. Quand wh=NIL, alors pas de redraw pour ce handle */

WORD     popup_select _((WORD wh, OBJECT *dialtree, WORD btn, OBJECT *poptree, WORD obj, BOOLEAN docheck, WORD docycle, BOOLEAN *ok));



/*****************************************************************************/

/* ouvrir le dialogue, appelle Growbox , et dial_start 						 				*/
/* size = NULL est le point de sortie de la Growbox du milieu d'‚cran						*/
/* la valeur de retour d‚finit si le fond peut ˆtre sauv‚ ou non							*/
BOOLEAN open_dial    _((OBJECT *tree, BOOLEAN grow, RECT *size, DIALINFO *dialinfo));

/* Fermer le dialogue, appelle Shrinkbox , et dial_end 										*/
/* size = NULL est le point de destination de la Shrinkbox du milieu de l'‚cran 			*/
BOOLEAN close_dial   _((BOOLEAN shrink, RECT *size, DIALINFO *dialinfo));

/* gestion complŠte du dialogue, appelle open_dial, do_dial et close dial					*/
/* le renvoi indique si le fond peut ˆtre sauv‚.	 										*/
WORD    HndlDial     _((OBJECT *tree, WORD def, BOOLEAN grow_shrink, RECT *size, BOOLEAN *ok));



/*****************************************************************************/

/* Initialisation des objet slider dans un Ressource. Il n'y aura qu'une adaptation */
/* de la position, afin que les objets avec un cortour de 1 point ne viennentpas se */
/* superposer. Les paramŠtres pass‚s sont les indices des objets de l'‚l‚ment Slide */
/* NIL sera renvoy‚ pourles objets non support‚s. En plus, pour chaque objet Slider */
/* il faut aussi supporter les flŠches. Les objets 'slbox' ne sont pas les seuls    */
/* d‚pla‡ables dans tout le domaine des Sliders.									*/
VOID    dial_slinit   (OBJECT *tree, WORD closer, WORD head, WORD edge,
                              WORD vslbox, WORD up, WORD down, WORD hslbox, WORD left, WORD right);

/* inscrit l'objet USERDEF, is_dialog d‚finit si c'est une boŒte de dialogue ou un menu d‚roulant	*/
VOID    dial_fix     _((OBJECT  *tree, BOOLEAN is_dialog));

/* initialisation du Mydial. … effectuer 1 fois au d‚marrage.										*/
/* nkc_init et nkc_set ne seront PAS appel‚e dial_init, il faut le faire … partir du programme principal   */
BOOLEAN dial_init    _((VOID *alc, VOID *fr, WORD *mnum, MFORM **mform, BOOLEAN *gs, BOOLEAN do3D, OBBLK *block, WORD blocklen));

/* Suppression du Mydial. … effectuer une fois … la fin du programme. */
/* nkc_exit n'est PAS appel‚e par dial_exit, il faut le faire … partir du programme principal 		*/
BOOLEAN dial_exit    _((VOID));


/*****************************************************************************/

/* Efface le clipboard GEM */
WORD    scrap_clear  _((VOID));

/* modifie le titre de la table ASCII. surtout pour les traductions.      	*/
/* parce que le ressource Mydial n'est pas ici.								*/
/* l'en-tˆte doit ˆtre une chaŒne. Les Mydials ne modifient que le pointeur */
/* Il faut donc imp‚rativement que la chaŒne soit bien d‚finie au paravent. */
VOID    ascii_head   _((BYTE *header));


/*****************************************************************************/

/* rechercher le raccourci clavier dans un arbre menu	                    */
/* menu  : arbre menu					                                    */
/* mk    : structure d‚crivant la touche press‚e							*/
/* title : le titre du menu de "item"					                    */
/* item  : entr‚e correspondante au raccourci clavier						*/
/* r‚sultat: TRUE = raccourci clavier trouv‚, sinon FALSE     */

BOOLEAN my_menu_key  _((OBJECT *menu, MKINFO *mk, WORD *title, WORD *item));

#endif /* __MYDIAL__ */
