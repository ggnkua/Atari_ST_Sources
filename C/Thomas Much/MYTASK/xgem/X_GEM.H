	/* D‚finitions pour la librairie Xgem */

#if !defined (_X_GEM)
#define _X_GEM

#include <tos.h>
#include <mgemx.h>
/*#include <mt_gemx.h>	*/

#ifndef NULL
#define NULL 0
#endif

extern short _app;

	/* toujours pratique: macros maximum et minimum. */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))


	/* ‚vŠnements maisons: */
#define WMN_SELECTED	200
#define IC_CHGSTATE		210
#define IC_MOVED		211
#define IC_DRAGDROP		212
#define IC_DESKCLIC		213
#define IC_WINDCLIC		214
#define MOD_TOPPED		250


	/* pour pouvoir appeller une fonction depuis une structure: */
typedef void (*FNCP)(void);
typedef void (*FNCP1)(short window);
typedef char *(*FNCPB)(short object);
typedef void (*FNCPC)(short *pxy);
typedef void (*FNCPP)(PARMBLK *para, short px, short py, short pw, short ph, short vdi_handle);
typedef void (*FNCPS)(short vdi_handle, short px, short py, short pw, short ph, short mode);


	/* Userdef 'paramŠtrable': */
#define USER_PARAMS struct USER_PARAMS
USER_PARAMS
{
	char *text;
	FNCPP *func;
};

	/* Gestion de modules pour Xgem */
	/* mode de fonctionnement: */
#define MOD_MONO	0
#define MOD_MULTI	1

	/* ‚tat du module: */
#define MOD_INFO	0
#define MOD_OPEN	1
#define MOD_PLAY	2
#define MOD_STOP	3

	/* indique qu'il s'agit bien d'un module pour Xgem: */
#define MOD_MAGIC	0x58474D44L
#define MOD_MAGIC_H	0x5847
#define MOD_MAGIC_L	0x4D44

	/* num‚ro de version du systŠme de modules: */
#define MOD_VERSION	"1.0"

	/* en cas de lancement en programme (quelle dr“le d'id‚e ;-) */
#define MOD_ONLY	"[3][|This module can only|be started from an|Xgem application.][ Quit ]"


	/* pour la gestion des bureaux: */
#define IL_NORMAL		0					/* attribut & flag: une ic“ne normale */
#define IL_SELECTED		1					/* attribut: l'ic“ne est s‚lectionn‚e */
#define IL_RECEIVER		2					/* flag: on peut poser quelque chose sur cette ic“ne (programme) */
#define IL_USER			4					/* flag: un clic sur cette ic“ne retourne directement un message au programme principal */

	/* structure pour l'utilisation d'ic“nes en fenˆtre: */
#define ICON_LIST struct ICON_LIST
ICON_LIST
{
	void *user;								/* pointe sur ce que l'utilisateur veut */
	GRECT size;								/* position et dimensions */
	short flag;								/* flags pour la s‚lection */
	ICON_LIST *pred;						/* pr‚c‚dant */
	ICON_LIST *next;						/* suivant... */
};


#ifndef DD_OK	/* Drag&Drop-Erweiterungen definiert? */

#define	DD_OK			0
#define DD_NAK			1
#define DD_EXT			2
#define DD_LEN			3
#define DD_TRASH		4
#define DD_PRINTER		5
#define DD_CLIPBOARD	6

#define DD_TIMEOUT		3000			/* timeout in milliseconds */

#define DD_NUMEXTS		8
#define DD_EXTSIZE		32
#define DD_NAMEMAX		128				/* max size of a drag&drop item name */

#define DD_HDRMAX		(8+DD_NAMEMAX*2)/* max length of a drag&drop header */

#endif

	/* structure d'information pour le drag et drop du bureau: */
#define DD_INFO struct DD_INFO
DD_INFO
{
	short src;								/* source: -1=bureau / n=fenˆtre */
	short dst;								/* destination (idem source) */
	OBJECT *src_addr;						/* adresse objets sources */
	OBJECT *dst_addr;						/* adresse objets destination */
	short src_list[2048];					/* num‚ro des objets concern‚s */
	short dst_icon;							/* ic“ne de destination */
	short kbd;								/* ‚tat des touches mortes */
	short x;								/* nouvelle position */
	short y;
};


#define XS_BOX	0x1L
#define XS_WIN	0x2L

	/* structure pour l'apparence de l'interface: */
#define STYLER struct STYLER
STYLER
{
	unsigned long ability;					/* ce que peut g‚rer le styler */

		/* modules d'aspect et autres: */
	void *mod_dfunc;						/* adresse du module de dessin du fond */
	FNCPS skin_dfunc;						/* fonction de dessin du fond */
	char res_m[24];							/* r‚serv‚ */

		/* r‚glages pour les boŒtes: */
	short background_dcolor;				/* couleur du fond des boŒtes */
	short box_dcolor;						/* couleur du cadre */
	short elight_dcolor;					/* couleur du bord clair */
	short edark_dcolor;						/* couleur du bord fonc‚ */
	short text_dcolor;						/* couleur du texte */
	char res_d[22];							/* r‚serv‚ */

		/* r‚glages pour les fenˆtres: */

		/* g‚n‚raux: */
	char wversion[8];						/* version du windframe */
	char wuser[32];							/* nom de l'utilisateur */
	short tfont_wtype;						/* type de fonte de la barre de titre (handle de la fonte) */
	short ifont_wtype;						/* type de fonte de la barre d'info (handle de la fonte: gem, 0: mini-fonte xgem) */
	short tfont_wsize;						/* hauteur de la fonte de la barre de titre (en points, 0: taille standard) */
	short ifont_wsize;						/* hauteur de la fonte de la barre d'info (en points, 0: taille standard) */
	OBJECT *wmgx_addr;						/* pointeur sur le rsc pour le windframe sous magic */
	short border_wframe;					/* ‚paisseur du cadre de la fenˆtre (en pixels, 0=6: ‚paisseur standard) */
	char res_w[10];							/* r‚serv‚ */

		/* premier plan: */
	short background_wfcolor;				/* couleur du fond de la fenˆtre */
	short title_wfcolor;					/* couleur du 'bouton' du titre */
	short ttext_wfcolor;					/* couleur du texte du titre */
	short tshadow_wfcolor;					/* ombrage du titre (0: on / 1: off) */
	short ttab_wfform;						/* style du 'bouton' de titre (0: arrondi, 1: invisible, ...) */
	char res_wf[22];						/* r‚serv‚ */

		/* arriŠre plan: */
	short background_wbcolor;				/* couleur du fond de la fenˆtre */
	short title_wbcolor;					/* couleur du 'bouton' du titre */
	short ttext_wbcolor;					/* couleur du texte du titre */
	short tshadow_wbcolor;					/* ombrage du titre (0: on / 1: off) */
	short ttab_wbform;						/* style du 'bouton' de titre (0: arrondi, 1: invisible, ...) */
	char res_wb[22];						/* r‚serv‚ */

	char res_g[60];							/* r‚serv‚ */
};


	/* structure pour les boŒtes de dialogues: */
#define DIAL_INFO struct DIAL_INFO
DIAL_INFO
{
	OBJECT *d_addr;							/* adresse boŒte */
	short d_flyer;							/* num‚ro de l'objet flyer */
	MFDB d_screen;							/* fond de l'‚cran (si la boŒte n'est pas en fenˆtre !) */
	FNCPB d_bubble;							/* fonction pour le choix des bulles */
	short d_modal;							/* la boŒte est en fenˆtre blocante */
	short d_edit;							/* curseur pour champ ‚ditable */
	short d_pos_edit;						/* position du curseur */
	short d_user_color;						/* aspect des boutons et des boŒtes (0: normal/ 1: utilisateur) */
	short d_background;
	short d_box;
	short d_elight;
	short d_edark;
	short d_text;
};


	/* structure des fenˆtres: */
#define WIND_LIST struct WIND_LIST
WIND_LIST
{
	short w_hand;							/* handle de la fenˆtre: -1=pas ouverte */
	short w_attr;							/* attributs */
	char w_full;							/* flag pour l'agrandissement */
	char w_iconify;							/* flag pour l'ic“nification */
	char w_title[128];						/* titre */
	char w_info[128];						/* barre d'infos */

	GRECT w_curr_wind;						/* coordonn‚es de la fenˆtre */
	GRECT w_old_curr;						/* anciennes coordonn‚es (pour fuller, iconifier) */
	GRECT w_work_wind;						/* coordonn‚es de la zone de travail */
	short w_xwz, w_ywz, w_wwz, w_hwz;		/* place requise par les menus et toolbars */

	OBJECT *w_menu_addr;					/* adresse menu */
	DIAL_INFO w_dial;						/* informations sur boŒte de dialogue */
	ICON_LIST w_iconified_list;				/* structure pour l'ic“nification */
	ICON_LIST *w_icon_list;					/* adresse pour g‚rer une liste d'ic“nes */
	FNCP1 w_sel_func;						/* fonction appel‚e lors d'une s‚lection d'ic“nes */
	short w_lw, w_lh;						/* si fenˆtre d'ic“nes largeur et hauteur de d‚calage */

	void *w_user1;							/* pointeur sur le contenu pour l'utilisateur */
	void *w_user2;							/* idem, mais un de plus ;-) */
	long w_nb_col, w_nb_vcol, w_nb_lig, w_nb_vlig;	/* dimensions du contenu (hors menu, toolbar ou dialogue) */
	long w_pos_x, w_pos_y, w_old_pos_x, w_old_pos_y;	/* position du contenu */
	short w_extx, w_exty;					/* flags pour agrandissement illimit‚ au contenu */
	short w_wunit, w_hunit;					/* unit‚es de d‚calage (suivant contenu) */

	GRECT *w_redraw_grect;					/* coordonn‚es aes de la zone … redessiner */
	short *w_redraw_pxy;					/* coordonn‚es vdi de la zone … redessiner */

	FNCP1 w_adapt;							/* fonction … appeler pour changer les dimensions de la toolbar */
	FNCP1 w_redraw;							/* fonction … appeler pour un redraw */
	FNCP1 w_close;							/* fonction … appeler en cas de fermeture */

	char dummy[64];							/* pour que la structure est une taille multiple de 16 (512) */
};

#if sizeof (WIND_LIST) != 512
#error WIND_LIST size incorrect !
#endif


	/* d‚claration liste des ic“nes couleurs: */
typedef struct
{
	USERBLK	ublk;
	unsigned short old_type;
} OBBLK;


typedef struct
{	TEDINFO tedinfo;	/* structure tedinfo normale */	char text[256];		/* le buffer */	short pos_text;		/* position pour le scroll texte */} X_TEDINFO;

#define X_GEM_INFO struct X_GEM_INFO
#define X_GEM_FUNC struct X_GEM_FUNC

	/* un module pour Xgem: */
#ifdef X_MODULE
typedef short (*MOD_PTR)(short mode);

#define MOD_PARAMS struct MOD_PARAMS
MOD_PARAMS
{
	long magic;
	char module_sys[4];
	char caller_sys[4];

	char name[32];
	char description[64];
	char copyright[32];
	char version[4];
	char date[12];

	X_GEM_INFO *x_gem;
	X_GEM_FUNC *x_gem_func;
	void *user;

	OBBLK *ob_blk;
	CICON *c_icon_table;
	USERBLK *adr_usr;

	BASPAG *base_page;
	MOD_PTR exec_module;

	MOD_PARAMS *next;
};
#endif


	/* structure de dialogue (application/gestion interface) */
X_GEM_INFO
{
	char *identifier;						/* identificateur */
	char *version;							/* version de x_gem */
	char *copyright;						/* copyright */
	char *user_reg;							/* utilisateur */

	short ap_id;							/* num‚ro d'application aes */
	short me_id;							/* num‚ro de menu pour les accessoires */
	short handle;							/* handle vdi pour l'utilisateur */
	short sys_handle;						/* handle vdi pour le systŠme */
	AESPB *aes_pb;							/* pointeur sur la structure AESPB de l'AES */
	VDIPB *vdi_pb;							/* pointeur sur la structure VDIPB de la VDI */
	short *work_out;						/* pointeur sur le tableau work_out[] */
	short *extended_inquire;				/* pointeur sur le tableau extended_inquire[] */
	short speedo;							/* Speedo Gdos pr‚sent ? */
	short max_fonts;						/* nombre de fontes pr‚sentes */

	short event;							/* ‚venements aes */
	short event_timer;						/* valeur de l'event_timer */
	short *event_buffer;					/* buffer d'‚venements aes */
	short *object;							/* objet cliqu‚ */
	short mx;								/* position souris x */
	short my;								/* position souris y */
	short mk;								/* bouton souris */
	short nb_clik;							/* nombre de clics */
	short kbd;								/* touches mortes */
	short key;								/* clavier */

	OBBLK *sys_ob_blk;						/* gestion des ic“nes couleurs du systŠme */
	CICON *sys_c_icon_table;
	USERBLK *sys_adr_usr;					/* gestion des userdefs du systŠme */

	OBBLK *ob_blk;							/* gestion des ic“nes couleurs de l'utilisateur */
	CICON *c_icon_table;
	USERBLK *adr_usr;						/* gestion des userdefs de l'utilisateur */

	short small_dial;						/* flag 8/16 pour les boŒtes de dialogues */
	short sys_font_width;					/* largeur de la fonte vdi standard */
	short sys_font_height;					/* hauteur de la fonte vdi standard */
	short sys_font_size;					/* taille de la fonte vdi standard */
	OBJECT **tree;							/* adresse des arbres de l'utilisateur */
	OBJECT *adr_menu;						/* adresse du menu courant */
	OBJECT *adr_desk;						/* adresse du bureau courant */
	GRECT desk_size;						/* dimensions du bureau */
	FNCPC redraw_desk;						/* fonction pour redessiner le bureau */
	DD_INFO *dd;							/* informations sur un drag et drop du bureau */

	short bubble_flag;						/* flag pour les bulles d'aides */
	short bubble_speed;						/* vitesse d'apparition */

	STYLER *styler;							/* aspect des objets */

	short nb_winds;							/* nombre de fenˆtres */
	short top_wind;							/* fenˆtre en avant plan */
	short event_wind;						/* fenˆtre concern‚e par un ‚venement */
	short max_winds;						/* nombre maxi de fenˆtres ouvrables */
	WIND_LIST *wind;						/* pointeur sur tableau des fenˆtres */

#ifdef X_MODULE
	MOD_PARAMS *module;						/* gestion des modules Xgem */
	short nb_module;						/* nombre de modules ouverts */
#endif
	short n_planes;
	unsigned long n_colors;
};


	/* gestion des cookies: */
typedef struct
{
	long ident;
	union
	{
		void *v;
		long l;
		short i[2];
		char c[4];
	} datack;
} X_COOKIE;


	/* prototypage de fonctions appellables depuis l'exterieur: */
X_GEM_INFO *x_gem_init (char *ap_name, WIND_LIST *window, short nb_wind);
void x_gem_exit (void);
void x_rsrc_init (OBJECT **tree, OBJECT *object, short num_tree, short num_obs, short num_cib);
void x_rsrc_free (short num_tree, short num_cib);
short x_rc_intersect (GRECT *p1, GRECT *p2);
	/* ex‚cuter un programme ou ouvrir un fichier: */
#define EXEC_MONO	0
#define EXEC_MULTI	1
#define APPL_MONO	2
#define APPL_MULTI	3
short x_execute_prg (short mode, char *prg, char *par, char *env);
	/* appel du s‚lecteur: */
short x_file_select (short r_mode, char *titre, char *masque, char *def, char *file_name);
	/* gestion du systŠme: */
short x_form_do (DIAL_INFO *dial);
	/* recherche d'un cookie: */
X_COOKIE *vq_cookie (long id);
	/* lecture du timer: */
long x_timer (void);
	/* initialiser un timer: */
void x_timers_init (short t);
	/* v‚rifier si un timer est atteint: */
short x_timers_event (short t, long laps);
	/* lire la valeur d'un timer: */
long x_timers_read (short t);
	/* changer la valeur d'un timer: */
void x_timers_write (short t, long laps);


	/* fonctions pour les modules: */
#ifdef X_MODULE
void x_module_init (void);
void x_aesglobal_module (short *glb);
void x_rsrc_module_init (MOD_PARAMS *module, OBJECT **tree, OBJECT *object, short num_tree, short num_obs, short num_cib);
void x_rsrc_module_exit (MOD_PARAMS *module, OBJECT **tree, short num_tree, short num_cib);
MOD_PARAMS *x_info_module (char *name, void *par);
short x_open_module (char *name, void *par);
void x_play_module (short mode, short number);
void x_close_module (short mode, short number);
#endif

	/* fonctions pour les fenˆtres: */
short x_open_wind (short xs, short ys, short xwz, short ywz, short wwz, short hwz, long nb_col, long nb_lig, long nb_vcol, long nb_vlig, short extx, short exty, short wunit, short hunit, short attr, char *titlew, char *infow, OBJECT *madr, OBJECT *dadr,
 ICON_LIST *iconified, ICON_LIST *iclist, FNCP1 wadapt, FNCP1 wredraw, FNCP1 wclose, FNCP1 wsel);
void x_close_wind (short window);
void x_close_all_winds (void);
short x_find_unused_wind (void);
short x_find_top_wind (void);
#define SET_HSLIDE	0x0001
#define SET_VSLIDE	0x0002
#define SET_HSLSIZE	0x0004
#define SET_VSLSIZE	0x0008
void x_set_slider_wind (short window, short element);
void x_window_fulled (short window);
void x_window_sized (short window);
void x_window_slided (short window);
void x_window_arrowed (short window);
void x_window_iconified (short window);
void x_window_uniconified (short window);
#define DRAW_AES	1
#define DRAW_VDI	2
#define DRAW_ALL	DRAW_AES|DRAW_VDI
void x_redraw_wind (short window, short draw_mode, short object_level, GRECT *rd);
void x_ehance_wind (short window, short modal, short init_edit, FNCPB bubble);

	/* fontions pour les objets: */
short x_parent (OBJECT *adr, short object);
short x_prev (OBJECT *adr, short ob);
short x_next (OBJECT *adr, short ob);
char *x_get_ob_text (OBJECT *adr, short object);
void x_set_ob_text (OBJECT *adr, short object, char *string);
OBJECT *x_add_icon (OBJECT *tree, OBJECT *object);
OBJECT *x_del_icon (OBJECT *tree, short object);
OBJECT *x_copy_tree (OBJECT *tree);
void x_objc_draw (short window, OBJECT *tree, short obj, short depth, GRECT *rd);
void s_objc_draw (OBJECT *tree, short obj, short depth, GRECT *rd);
void x_set_user_params (OBJECT *adr, short obj, USER_PARAMS *usp, FNCPP *fnc);

	/* fonctions pour les boŒtes de dialogues: */
short x_gem_alert (char *alrt, OBJECT *icn);
void x_open_dial (OBJECT *adr, DIAL_INFO *dial, short usr_color, short init_edit, FNCPB bubble);
void x_close_dial (DIAL_INFO *dial, short close_button);
void x_move_form (DIAL_INFO *dial);
void x_init_slider (OBJECT *adr, short b_dec, short b_inc, short b_cur, short b_bar, short direction, short nb_vis_elem, short nb_elem, short pos_elem, short redraw);
short x_use_slider (OBJECT *adr, short obj, short b_dec, short b_inc, short b_cur, short b_bar, short direction, short nb_vis_elem, short nb_elem, short *pos_elem, void (*redraw_func)(short pos), void (*interrupt_func)(void));
void x_disable_slide (OBJECT *adr, short b_dec, short b_inc, short pos, short max_val, short redraw);
void x_stdkey (unsigned char *k);
unsigned long x_inkey (void);
void x_wait_button_off (void);

	/* fonctions pour le bureau: */
#ifdef X_DESK
void x_open_desk (OBJECT *adr, short logo, FNCPC rdesk);
void x_update_desk (void);
void x_close_desk (void);
short x_drag_icon (OBJECT *adr, short object);
void x_execute_drag_icon (DD_INFO *dd);
short x_rubber_select (OBJECT *adr);
short x_find_icon (WIND_LIST *wind, ICON_LIST *ic, short x, short y);
ICON_LIST *x_find_icon_list (ICON_LIST *ic, short pos);
short x_deselect_icons (short src_wind);
void x_redraw_desk (GRECT *rd);
#endif

	/* fontions pour les menus: */
void x_open_menu (OBJECT *adr);
void x_close_menu (OBJECT *adr);
	/* fonctions pour les menus hi‚rarchiques: */
void x_set_menu_hierarch (OBJECT *adr, short object, short tree);
short x_menu_title (OBJECT *adresse, short option);
	/* fontion bulle d'aide: */
short x_show_bubble (char *txt, short mode);
	/* fonctions menus en fenˆtres: */
short x_wind_menu (OBJECT *adr, short ob);
void x_wmenu_tnormal (short window, OBJECT *adr, short title, short flag);
	/* fonction pour les pop-ups: */
short x_pop_up (short x, short y, OBJECT *adr, void *r_adr, short *r_obj);
	/* sauver ou restaurer l'‚cran: */
short x_get_bkgr (GRECT *r, MFDB *img);
void x_put_bkgr (GRECT *r, MFDB *img, short free_flag);

	/* fonction d'insertion de chaŒne: */
void x_string_insert (char *s1, char *s2, short pos, short max_len);
	/* recherche une chaŒne en m‚moire: */
long x_mem_find (char *s1, char *s2, long l1, long l2);
	/* comparaison de noms de fichiers avec jokers: */
short x_strjcmp (char *s1, char *s2);
	/* r‚cupŠre le nom de fichier d'un chemin complet: */
void x_cut_filename (char *s);
	/* r‚cupŠre le directory d'un chemin complet: */
void x_cut_dirname (char *s);
	/* pareil que strchr, mais renvoie chr(0) au lieu de adr(0) ! */
char *x_my_strchr (char *s, short c);
	/* Vire espaces d‚but et fin de chaŒne: */
char *x_trim (char *str);
	/* Rajoute des points de suspension si une chaŒne est trop longue */
char *x_suspend_text (short handle, char *str, short width, short mode);
	/* 'd‚formate' une chaŒne de texte d'un champ ftext: */
void x_unformat_ftext (char *str, char *format, char *valid);
	/* formate une chaŒne de texte d'un champ ftext: */
void x_format_ftext (char *str, char *format);
	/* v‚rifier si une date en chaŒne est correcte: */
short x_verify_date (char *dat);
	/* ajouter des jours … une date gemdos: */
short x_add_date (unsigned short date, short sd);
	/* soustaire des jours … une date gemdos: */
short x_sub_date (unsigned short date, short sd);
	/* indique combien de jours comporte un mois: */
short x_month_len (short month, short year);
	/* transforme une date en chaŒne en date gemdos: */
void x_ascii_to_date (unsigned short *fdate, char *dat);
	/* transforme une date gemdos en chaŒne: */
void x_date_to_ascii (char *dat, unsigned short fdate);
	/* transforme une date en chiffres (ex: 02.04.95) en lettres (ex: vendredi 02 avril 1995) */
short x_expand_date (char *dat2, char *dat1);
	/* v‚rifier si une heure est correcte: */
short x_verify_time (char *tim);
	/* transforme une heure en chaŒne en heure gemdos: */
void x_ascii_to_time (unsigned short *ftime, char *tim);
	/* transforme une heure gemdos en chaŒne: */
void x_time_to_ascii (char *tim, unsigned short ftime);
	/* Chercher la largeur d'une chaine avec une fonte non-proportionelle: */
short x_get_str_width (short handle, char *str);

	/* fonctions de dessin particuliŠres: */
void x_draw_icon (OBJECT *adr, short object, short state, short x, short y, GRECT *rl);
#define MF_NORMAL		0x00
#define MF_BOLD			0x01
#define MF_LIGHT		0x02
#define MF_ITALIC		0x04
#define MF_UNDERLINE	0x08
#define MF_INVERSE		0x10
#define MF_SHADOW		0x20
#define MF_MONOSPACED	0x40
void x_small_font (short xf, short yf, short sf, short colf, char *strf);
short x_small_font_width (short sf, char *strf);
void fx_bar (short px, short py, short pw, short ph, short mode);



	/* ‡a c'est pour les modules: */
#ifdef X_MODULE
X_GEM_FUNC
{
	X_GEM_INFO *(*x_gem_init)(char *ap_name, WIND_LIST *window, short nb_wind);
	void (*x_gem_exit)(void);
	void (*x_rsrc_init)(OBJECT **tree, OBJECT *object, short num_tree, short num_obs, short num_cib);
	void (*x_rsrc_free)(short num_tree, short num_cib);
	short (*x_rc_intersect)(GRECT *p1, GRECT *p2);
	short (*x_execute_prg)(short mode, char *prg, char *par, char *env);
	short (*x_file_select)(short r_mode, char *titre, char *masque, char *def, char *file_name);
	short (*x_form_do)(DIAL_INFO *dial);
	X_COOKIE *(*vq_cookie)(long id);
	long (*x_timer)(void);
	void (*x_timers_init)(short t);
	short (*x_timers_event)(short t, long laps);
	long (*x_timers_read)(short t);
	void (*x_timers_write)(short t, long laps);

	void (*x_aesglobal_module)(short *glb);
	void (*x_rsrc_module_init)(MOD_PARAMS *module, OBJECT **tree, OBJECT *object, short num_tree, short num_obs, short num_cib);
	void (*x_rsrc_module_exit)(MOD_PARAMS *module, OBJECT **tree, short num_tree, short num_cib);
	MOD_PARAMS *(*x_info_module)(char *name, void *par);	
	short (*x_open_module)(char *name, void *par);
	void (*x_play_module)(short mode, short number);
	void (*x_close_module)(short mode, short number);

	short (*x_open_wind)(short xs, short ys, short xwz, short ywz, short wwz, short hwz, long nb_col, long nb_lig, long nb_vcol, long nb_vlig, short extx, short exty, short wunit, short hunit, short attr, char *titlew, char *infow, OBJECT *madr, OBJECT *dadr,
	ICON_LIST *iconified, ICON_LIST *iclist, FNCP1 wadapt, FNCP1 wredraw, FNCP1 wclose, FNCP1 wsel);
	void (*x_close_wind)(short window);
	void (*x_close_all_winds)(void);
	short (*x_find_unused_wind)(void);
	short (*x_find_top_wind)(void);
	void (*x_set_slider_wind)(short window, short element);
	void (*x_window_fulled)(short window);
	void (*x_window_sized)(short window);
	void (*x_window_slided)(short window);
	void (*x_window_arrowed)(short window);
	void (*x_window_iconified)(short window);
	void (*x_window_uniconified)(short window);
	void (*x_redraw_wind)(short window, short draw_mode, short object_level, GRECT *rd);
	void (*x_ehance_wind)(short window, short modal, short init_edit, FNCPB bubble);

	short (*x_parent)(OBJECT *adr, short object);
	short (*x_prev)(OBJECT *adr, short ob);
	short (*x_next)(OBJECT *adr, short ob);
	char *(*x_get_ob_text)(OBJECT *adr, short object);
	void (*x_set_ob_text)(OBJECT *adr, short object, char *string);
	OBJECT *(*x_add_icon)(OBJECT *tree, OBJECT *object);
	OBJECT *(*x_del_icon)(OBJECT *tree, short object);
	OBJECT *(*x_copy_tree)(OBJECT *tree);
	void (*x_objc_draw)(short window, OBJECT *tree, short obj, short depth, GRECT *rd);
	void (*s_objc_draw)(OBJECT *tree, short obj, short depth, GRECT *rd);

	short (*x_gem_alert)(char *alrt, OBJECT *icn);
	void (*x_open_dial)(OBJECT *adr, DIAL_INFO *dial, short usr_color, short init_edit, FNCPB bubble);
	void (*x_close_dial)(DIAL_INFO *dial, short close_button);
	void (*x_move_form)(DIAL_INFO *dial);
	void (*x_init_slider)(OBJECT *adr, short b_dec, short b_inc, short b_cur, short b_bar, short direction, short nb_vis_elem, short nb_elem, short pos_elem, short redraw);
	short (*x_use_slider)(OBJECT *adr, short obj, short b_dec, short b_inc, short b_cur, short b_bar, short direction, short nb_vis_elem, short nb_elem, short *pos_elem, void (*redraw_func)(short pos), void (*interrupt_func)(void));
	void (*x_disable_slide)(OBJECT *adr, short b_dec, short b_inc, short pos, short max_val, short redraw);
	void (*x_stdkey)(unsigned char *k);
	unsigned long (*x_inkey)(void);
	void (*x_wait_button_off)(void);

	void (*x_open_desk)(OBJECT *adr, short logo, FNCPC rdesk);
	void (*x_update_desk)(void);
	void (*x_close_desk)(void);
	short (*x_drag_icon)(OBJECT *adr, short object);
	void (*x_execute_drag_icon)(DD_INFO *dd);
	short (*x_rubber_select)(OBJECT *adr);
	short (*x_find_icon)(WIND_LIST *wind, ICON_LIST *ic, short x, short y);
	ICON_LIST *(*x_find_icon_list)(ICON_LIST *ic, short pos);
	short (*x_deselect_icons)(short src_wind);
	void (*x_redraw_desk)(GRECT *rd);

	void (*x_open_menu)(OBJECT *adr);
	void (*x_close_menu)(OBJECT *adr);
	void (*x_set_menu_hierarch)(OBJECT *adr, short object, short tree);
	short (*x_menu_title)(OBJECT *adresse, short option);
	short (*x_show_bubble)(char *txt, short mode);
	short (*x_wind_menu)(OBJECT *adr, short ob);
	void (*x_wmenu_tnormal)(short window, OBJECT *adr, short title, short flag);
	short (*x_pop_up)(short x, short y, OBJECT *adr, void *r_adr, short *r_obj);
	short (*x_get_bkgr)(GRECT *r, MFDB *img);
	void (*x_put_bkgr)(GRECT *r, MFDB *img, short free_flag);

	void (*x_string_insert)(char *s1, char *s2, short pos, short max_len);
	long (*x_mem_find)(char *s1, char *s2, long l1, long l2);
	short (*x_strjcmp)(char *s1, char *s2);
	void (*x_cut_filename)(char *s);
	void (*x_cut_dirname)(char *s);
	char *(*x_my_strchr)(char *s, short c);
	char *(*x_trim)(char *str);
	char *(*x_suspend_text)(short handle, char *str, short width, short mode);
	void (*x_unformat_ftext)(char *str, char *format, char *valid);
	void (*x_format_ftext)(char *str, char *format);
	short (*x_verify_date)(char *dat);
	short (*x_add_date)(unsigned short date, short sd);
	short (*x_sub_date)(unsigned short date, short sd);
	short (*x_month_len)(short month, short year);
	void (*x_ascii_to_date)(unsigned short *fdate, char *dat);
	void (*x_date_to_ascii)(char *dat, unsigned short fdate);
	short (*x_expand_date)(char *dat2, char *dat1);
	short (*x_verify_time)(char *tim);
	void (*x_ascii_to_time)(unsigned short *ftime, char *tim);
	void (*x_time_to_ascii)(char *tim, unsigned short ftime);
	short (*x_get_str_width)(short handle, char *str);

	void (*x_draw_icon)(OBJECT *adr, short object, short state, short x, short y, GRECT *rl);
	void (*x_small_font)(short xf, short yf, short sf, short colf, char *strf);
	short (*x_small_font_width)(short sf, char *strf);
	void (*fx_bar)(short px, short py, short pw, short ph, short mode);
	void (*x_set_user_params)(OBJECT *adr, short obj, USER_PARAMS *usp, FNCPP *fnc);

	char *(*strcat)(char *dest, const char *src);
	int (*strcmp)(const char *s1, const char *s2);
	char *(*strcpy)(char *dest, const char *src);
	unsigned long (*strlen)(const char *s);
	int (*sprintf)(char *buffer, const char *format, ...);

	void *(*malloc)(unsigned long size);
	void (*free)(void *ptr);
	void *(*realloc)(void *ptr, unsigned long size);
	char *(*strdup)(const char *s);
};
#endif

#endif
