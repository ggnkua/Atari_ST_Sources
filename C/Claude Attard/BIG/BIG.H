/*			BIG.H			>>> Big Is Gem <<<
				Librairie de d‚veloppement sous GEM
				version 1.05 du 16/06/93
*/

#if  !defined( __BIG__ )
#define __BIG__

/* #[ D‚finitions :																								*/
/****** Fichiers annexes ******************************************/

#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

/****** D‚finitions ***********************************************/

	/* D‚finitions diverses */
enum {FALSE, TRUE};
#define NOT !
#define BLANK -1
#define ZERO 0
#define MAX_ALRT 250

	/* D‚finition pour le 15ø bit positionn‚ */
#define BIT15 0x8000

	/* Macros Maximum et Minimum */
#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

	/* D‚finitions pour les UserDefs */
#define B_MOVE 17
#define B_SELEC 18
#define B_GRASTR 19
#define B_FRAME 20
#define B_HELP 21
#define B_EDIT 25
#define B_UNDO 31
#define B_HIERM 41
#define B_FNCP 51

	/* D‚finitions pour les ev‚nements */
#define DLG_DESK (MU_KEYBD | MU_BUTTON | MU_M1 | MU_MESAG | MU_TIMER)
#define DLG_FORM (MU_KEYBD | MU_BUTTON | MU_TIMER)
#define BEV_HIERM 50
#define BEV_FREEPU 51
#define BEV_WFORM 52
#define BEV_WMENU 53
#define	BEV_WHIER 54

	/* D‚finitions pour les attributs de fenˆtres */
#define WATR_ALL 0xFFF
#define WATR_CURR 0xFEF
#define WATR_FORM (NAME|CLOSER|MOVER)

	/* D‚finitions pour les types de fenˆtres */
#define WTYP_NORM 1
#define WTYP_FORM 2
#define WTYP_PICT 3
#define WTYP_MENU 0x8000

	/* D‚finitions pour les flags de fenˆtres */
#define WFFULL	0x0001
#define WFARROW	0x0002
#define WFREDRAW 0x0004
#define WFBOUND 0x0008
#define WLAST	0x0080

	/* D‚fininiton pour les boutons de fenˆtres formulaires */
#define WFCLOSE 0x0001

	/* D‚finitions pour le clavier */
#define HELP 25088
#define UNDO 24832
#define ENTER 7181
#define RETURN 29197
#define BACKSPC 3592
#define DELETE 21375
#define TAB 3849
#define ARDN 20480
#define ARUP 18432
#define ARLF 19200
#define ARRT 19712
#define CT_ARLF 29440
#define CT_ARRT 29696
#define SH_ARDN 20530
#define SH_ARUP 18488
#define SH_ARLF 19252
#define SH_ARRT 19766
#define ESC 283
#define CLR 18176
#define SH_CLR 18231

/****** Variables globales ****************************************/

extern int ap_id;							/* Num‚ro de l'application */

extern char res; 							/* R‚solution courante */
extern int	handle; 					/* Station de travail */
extern int	hc;								/* Taille standard des caractŠres */
extern int	xd, yd, wd, hd; 	/* Position & dimensions bureau */
extern int	buf[8];						/* Buffer d'‚vŠnements */
extern int	mx, my, mk;				/* Position et ‚tat souris */
extern int	edit, pos, object; /* Editable courant, pos. curseur, ob. cliqu‚ */
extern int	kbd, key, clik; 	/* Etat touches sp‚ciales, touches, clics */
extern int	wind;							/* Fenˆtre cliqu‚e */
extern int	n_plane;					/* Nbre de plans de couleurs */
extern int *palette;					/* Pour la sauvegarde de la palette */

extern OBJECT		*adr_menu, *adr_desk;	/* Adresses formulaires r‚serv‚es */

	/* Cr‚ation des types "pointeur sur fonction" */
typedef void (*FNCP)(void);
extern FNCP *fnc;	/* Pointeur sur les pointeurs de fonction li‚s aux objets */

	/* Structures de travail avec les fenˆtres */

typedef struct form {			/* DEFINITION FENETRE FORMULAIRE */
	OBJECT	*w_tree;		/* Adresse arbre */
	int			w_edit;			/* EDITABLE courant */
	int			w_pos;			/* Position du curseur */
	char		*w_bak;			/* Sauvegarde ‚tat formulaire */
} Form;

typedef struct imag {			/* DEFINITION FENETRE IMAGE */
	MFDB		w_blk;			/* Bloc d'informations sur l'image */
	int			*w_pal;			/* Pointeur sur la palette de couleurs */
} Imag;

typedef union cont {			/* DEFINITION DU CONTENU D'UNE FENETRE */
	Form		w_form;			/* Si fenˆtre formulaire */
	Imag		w_img;			/* Si image */
	char		*w_adr;			/* Si texte ou autre adresse donn‚es */
} Cont;

typedef struct window {		/* DEFINITION D'UNE FENETRE */
	int			w_hg;				/* Handle GEM de la fenˆtre (ou -1 ou 0) */
	int			w_type;			/* Type BIG de la fenˆtre */
	int			w_attr;			/* Attributs de fenˆtre (wind_create) */

	int			w_xcurr;		/* Coordonn‚es et */
	int			w_ycurr;		/* dimensions */
	int			w_wcurr;		/* courantes de */
	int			w_hcurr;		/* la fenˆtre active */
	int			w_wmini;		/* Largeur minimum */
	int			w_hmini;		/* Hauteur minimum */

	int			w_wunit;		/* Unit‚ de d‚calage horizontale */
	int			w_hunit;		/* Unit‚ de d‚calage verticale */

	Cont		w_cont;			/* Selon le contenu de la fenˆtre */

	OBJECT	*w_menu;		/* Si fenˆtre avec menu : adresse arbre */

	int			w_flags;		/* Flags Plein pot, Clavier actif, DerniŠre fenˆtre */
	int			w_mouse;		/* Forme de souris dans la fenˆtre */

	FNCP		w_redraw;		/* Pointeur sur routine de redraw */
	FNCP		w_top;			/* Pointeur sur routine de mise en premier plan */
	FNCP		w_close;		/* Pointeur sur routine de fermeture */
	FNCP		w_move;			/* Pointeur sur routine fenˆtre d‚plac‚e */
	FNCP		w_size;			/* Pointeur sur routine fenˆtre redimensionn‚e */
	FNCP		w_full;			/* Pointeur sur routine fenˆtre plein pot */
	FNCP		w_hslid;		/* Pointeur sur routine slider horizontal */
	FNCP		w_vslid;		/* Pointeur sur routine slider vertical */
	FNCP		w_uppage;		/* Pointeur sur routine page vers le haut */
	FNCP		w_dnpage;		/* Pointeur sur routine page vers le bas */
	FNCP		w_lfpage;		/* Pointeur sur routine page vers la gauche */
	FNCP		w_rtpage;		/* Pointeur sur routine page vers la droite */
	FNCP		w_upline;		/* Pointeur sur routine ligne vers le haut */
	FNCP		w_dnline;		/* Pointeur sur routine ligne vers le bas */
	FNCP		w_lfline;		/* Pointeur sur routine ligne vers la gauche */
	FNCP		w_rtline;		/* Pointeur sur routine ligne vers la droite */

	char		*w_title;		/* Pointeur sur titre de la fenˆtre */
	char		*w_infos;		/* Pointeur sur infos de la fenˆtre */

	long		w_wtot;			/* Largeur maxi contenu fenˆtre (en pixels) */
	long		w_htot;			/* Hauteur maxi contenu fenˆtre (en pixels) */
	long		w_lin;			/* 1Šre ligne de la fenˆtre */
	long		w_col;			/* 1Šre colonne de la fenˆtre */
} Window;

extern Window	*win;				/* Pointeur sur la zone des fenˆtres */
/* #] D‚finitions :																								*/
/* #[ Prototypage des fonctions :																	*/
/****** Fonctions d'initialisation ********************************/

int		initial (char *rsc, int menu, int desk,
							 int nb_tree, OBJECT *rs_tree, char *rs_str, int n_wind);
void	userdef (char *rsc, int *nb_form, int nb_tree);
int		cdecl bcoche (PARMBLK *para);
int		cdecl brond (PARMBLK *para);
int		cdecl bcadre (PARMBLK *para);
int		cdecl bmove (PARMBLK *para);
int		cdecl bgrastr (PARMBLK *para);
int		cdecl bmhier (PARMBLK *para);
int		read_res (void);
void	get_palette (void);
void	open_work (void);
void	end (int intgr);

/****** Fonctions de gestion des formulaires **********************/

void	formm_draw (OBJECT *adr, int ed, int flmove, MFDB *img);
void	formm_undraw (OBJECT *adr, MFDB *img);
void	formf_draw (OBJECT *adr, int ed);
void	formf_undraw (OBJECT *adr);
void	create_hierm (OBJECT *adr, int intgr);
int		dialog (int flags, OBJECT *address, int f, int intgr,
							int fl_rb, int form_pu, MFDB *img, int fl_move);
int		dlg_keybd (OBJECT *adresse, int f, int *dedans, int intgr);
int		dlg_mesag (int intgr);
int		dlg_button (OBJECT *adresse, int f, int dedans, MFDB *img, int fl_depl, int intgr);
void	dlg_mouse (void);
int		menu_hierarch (int option, int intgr);
void	pop_up (OBJECT *adr, int object, int intgr);
void	next_option (OBJECT *adr, int object, int form, int intgr);
int		free_popup (int posx, int posy, int form, int intgr);
void	help (OBJECT *adr, int obj, int intgr);
void	move_form (OBJECT *adr, int x, int y, int w, int h, MFDB *img, int fl_depl);
int		exist_edit (OBJECT *adr);
void	get_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
void	put_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
int		scan (OBJECT *adr, int f, int intgr);
int		scan_wmenu (int index, char touc, int intgr);
int		scan_menu (char touc, int intgr);
int		scan_form (char touc, OBJECT *adr);
int		big_alert (int button, int number, char *str, int fl_alrt, int intgr);
char	*get_string (int number, int intgr);
int		m_title (OBJECT *adresse, int option);
int		parent (OBJECT *adr, int object);
void	bak_rsc (OBJECT *tree, char **bak);
void	res_rsc (OBJECT *tree, char **bak);

/****** Fonctions pour les EDITABLEs ******************************/

void	set_text (OBJECT *adr, int object, char *string);
char	*get_text (OBJECT *adr, int object);
void	empty_edit (OBJECT *adr);
int		pos_curs (OBJECT *adr, int ed, int mx, int f, int index, int po);
int		prev (OBJECT *adr, int ob);
int		next (OBJECT *adr, int ob);
void	first (OBJECT *adr, int *editable, int *position);
void	last (OBJECT *adr, int *editable, int *position);
int		next_word (OBJECT *adr, int ob, int posi);
int		prev_word (OBJECT *adr, int ob, int posi);
void	objc_xedit (OBJECT *adr, int ed, int *po, int f, int index);
char	*start_edit (char *pt);

/****** Fonctions diverses ****************************************/

char	*path (char *pat);
int		exist (char *name, int att);
void	set_palette (int index);
long	timer (void);
void	stdkey (unsigned char *k);
char	*trim (char *str);
int		rc_intersect (GRECT *p1, GRECT *p2);
void	set_clip (int clip_flag, GRECT *area);
void	send_mesag (int type, int wi, int x, int y, int w, int h);
int		selector (char *pat, char *ext, char *file, char *title);
void	extension (char *filename, char *ext);

/****** Fonctions pour les fenˆtres *******************************/

void	formw_draw (OBJECT *adr, int index, int title, int infos,
									int wed, int fb, int intgr, int attr);
void	dcl_windows (int nbre);
void	create_wmenu (int tree, int index, int intgr);
int		menu_window (int index, int xm, int ym, int intgr);
int		wind_hierarch (OBJECT *adr, int index, int option, int intgr);
int		open_window (int index, int type, int attr,
									 int x, int y, int w, int h,
									 int wm, int hm, int wu, int hu, int fa, int fb, int fmouse,
									 FNCP redr, FNCP clos,
									 char *title, char *info,
									 long wt, long ht,
									 int fmenu, int menu, int intgr);
int		find_index (int wh);
int		find_window (int mx, int my);
void	zone_work (int index, int *xw, int *yw, int *ww, int *hw);
void	wind_mouse (void);
void	height_vert (int index);
void	height_hori (int index);
void	posi_vert (int index);
void	posi_hori (int index);
void	height_sliders (int index);
void	draw_object (int object, int index);
void	print_line (int f, int index);
void	print_colum (int f, int index);
void	print_page (int index);
void	arrow (void);

void	redraw (void);
void	topped (void);
void	closed (void);
void	fulled (void);
void	uppage (void);
void	dnpage (void);
void	upline (void);
void	dnline (void);
void	lfpage (void);
void	rtpage (void);
void	lfline (void);
void	rtline (void);
void	hslid (void);
void	vslid (void);
void	sized (void);
void	moved (void);

void	full_wform (void);
void	size_wform (void);
/* #] Prototypage des fonctions :																	*/
#endif

