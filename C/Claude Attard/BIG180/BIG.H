/*			BIG.H			>>> Big Is Gem <<<
				Librairie de d‚veloppement sous GEM
				Cr‚‚e et d‚velopp‚e par Claude ATTARD
				version 1.80 du 02/11/93
*/
/* certaines modification ont ete apportes par les soins de Marc 
 Abramson le 30/10/1993. Elle sont toute repertori‚es MA_30_10 */

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
	/* D‚finitions pour l'iconification des fenˆtres (AES >= 4.10) */
#if !defined( SMALLER )
#define SMALLER 0x4000
#define WM_ICONIFY 34
#define WM_UNICONIFY 35
#define WM_ALLICONIFY 36
#define WF_ICONIFY 26
#define WF_UNICONIFY 27
#define WF_UNICONIFYXYWH 28
#endif

	/* D‚finition pour la gestion de la 3D */
#define BKGR 0x400

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
#define B_POPUP 22
#define B_LIST 23
#define B_EDIT 25
#define B_UNDER 30
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
#define BEV_TOOL 55

	/* D‚finitions pour les attributs de fenˆtres */
#define WATR_ALL (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER)
#define WATR_CURR (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER)
#define WATR_FORM (NAME|CLOSER|MOVER|SMALLER)

	/* D‚finitions pour les types de fenˆtres */
#define WTYP_NORM 1
#define WTYP_FORM 2
#define WTYP_PICT 3
#define WTYP_TOOL 0x4000
#define WTYP_MENU 0x8000

	/* D‚finitions pour les flags de fenˆtres */
#define WFFULL	0x0001
#define WFARROW	0x0002
#define WFREDRAW 0x0004
#define WFBOUND 0x0008
#define WFLAST	0x0080

	/* D‚fininiton pour les boutons de fenˆtres formulaires */
#define WFCLOSE 0x0001

	/* D‚finitions pour les menus en fenˆtre */
#define WM_BKGR 0
#define WM_BOXMENU 1
#define WM_BOXARROWS 2
#define WM_LFARROW 3
#define WM_RTARROW 4
#define WM_BOXTITLES 5

	/* D‚finitions pour le clavier */
#define HELP 0x6200
#define UNDO 0x6100
#define ENTER 0x1C0D
#define RETURN 0x720D
#define BACKSPC 0x0E08
#define DELETE 0x537F
#define TAB 0x0F09
#define ARDN 0x5000
#define ARUP 0x4800
#define ARLF 0x4B00
#define ARRT 0x4D00
#define CT_ARLF 0x7300
#define CT_ARRT 0x7400
#define SH_ARDN 0x5032
#define SH_ARUP 0x4838
#define SH_ARLF 0x4B34
#define SH_ARRT 0x4D36
#define ESC 0x011B
#define CLR 0x4700
#define SH_CLR 0x4737

/****** Variables globales ****************************************/

extern int ap_id;							/* Num‚ro de l'application */

extern int	buf[8];						/* Buffer d'‚vŠnements */
extern int	mx, my, mk;				/* Position et ‚tat souris */
extern int	edit, pos, object; /* Editable courant, pos. curseur, ob. cliqu‚ */
extern int	kbd, key, clik; 	/* Etat touches sp‚ciales, touches, clics */
extern int	wind;							/* Fenˆtre cliqu‚e */
extern int	intgr;						/* Flag de ressource int‚gr‚ ou non */

typedef int Palette[3];

/* MA_30_10 : compatibilite avec BIG 1.07. Toutes ces informations
 sont dorenavants disponibles dans les variables work_display de structure
 t_display et desc_hard_soft de structure t_ident_hard_soft*/
#ifdef _COMPATIBLE_BIG_107_
	extern char res; 					/* R‚solution courante     */
	extern int	handle; 				/* Station de travail      */
	extern int	hc;						/* Taille standard des caractŠres */
	extern int	xd, yd, wd, hd; 	    /* Position & dimensions bureau   */
	extern int	n_plane;				/* Nbre de plans de couleurs      */
	extern int n_color;					/* Nbre de couleurs affich‚es     */
	extern char multitache;				/* Flag d'environnement multitache */
	extern int vaes;					/* Nø de version AES */
	extern Palette *palette;			/* Pour la sauvegarde de la palette */
#endif

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

typedef union cont {			/* DEFINITION DU CONTENU D'UNE FENETRE */
	Form		w_form;			/* Si fenˆtre formulaire */
	MFDB		w_img;			/* Si image */
	char		*w_adr;			/* Si texte ou autre adresse donn‚es */
} Cont;

typedef struct oldw {			/* DEFINITION DES DONNEES AVANT ICONIFICATION */
	GRECT		w_coord;		/* Anciennes coordonn‚es */
	int			w_att;			/* Anciens attributs */
} Oldw;

typedef struct bigwind {		/* DEFINITION D'UNE FENETRE */
	int			w_hg;				/* Handle GEM de la fenˆtre (ou -1 ou 0) */
	int			w_type;			/* Type BIG de la fenˆtre */
	int			w_attr;			/* Attributs de fenˆtre (wind_create) */

	GRECT		w_curr;			/* Coordonn‚es courantes de la fenˆtre */
	Oldw		w_old;			/* Donn‚es avant ic“nification */
	int			w_wmini;		/* Largeur minimum */
	int			w_hmini;		/* Hauteur minimum */

	int			w_wunit;		/* Unit‚ de d‚calage horizontale */
	int			w_hunit;		/* Unit‚ de d‚calage verticale */

	Cont		w_cont;			/* Selon le contenu de la fenˆtre */
	Palette	*w_pal;			/* Pointeur sur la palette de couleurs */

	OBJECT	*w_bar;			/* Si fenˆtre avec menu ou toolbar: adresse arbre */

	int			w_flags;		/* Flags Plein pot, Clavier actif, DerniŠre fenˆtre */
	int			w_mouse;		/* Forme de souris dans la fenˆtre */
	int			w_icon;			/* Ic“nification : index fenˆtre associ‚e */
	FNCP		w_redicn;		/* Pointeur sur routine de redraw si fenˆtre ic“nifi‚e */

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
} BigWind;

extern BigWind	*win;				/* Pointeur sur la zone des fenˆtres */

	/* Structure des Cookies */
typedef struct
{
	long ident;
	union
	{
		long l;
		int i[2];
		char c[4];
	} datack;
} COOKIE;

/* MA_30_10: identification du hard et du soft, bien utile pour le reste
du programme	*/
/* types construits pour l'identification de la machine	*/
/* -----------------------------------------------------*/
typedef enum 
{
	ST,
	STE,
	TT,
	FALCON_030,
	AUTRE_MACHINE
}	t_machine;	

typedef enum
{
	PG_ST,
	PG_STE,
	PG_TT,
	PG_FALCON_030,
	AUTRE_PG,
}	t_proc_graphique;

typedef enum
{	
	PROC_68000,
	PROC_68030,
	AUTRE_PROCESSEUR,
}	t_cpu;

typedef enum
{
	ST_BASSE = 0,
	ST_MOYENNE = 1,
	ST_HAUTE = 2,
	VGA_16COL = 4,					/* le VGA TT */
	VGA_256COL = 5,					/* le VGA FALCON */
	R_256C_320_480 = 7,			/* le 320*480 16 col TT */
	TRUE_COLOR_320_480 = 8,	/* le 320*480 Falcon sur VGA */
	INCONNU = -1						/* aucune r‚solution normalis‚e */
} t_resolution;

typedef struct
{
	t_machine la_machine;
	t_proc_graphique proc_graphique;
	t_cpu le_cpu;
	int v_aes;
	int v_tos;
	char multitache;
}	t_ident_hard_soft;

/* MA_30_10 : creation de la structure display qui contient
 tout ce qui est necessaires de savoir sur la station de travail */
typedef struct t_display
{
	size_t taille;				/* taille d'un ecran	*/
	size_t taille_ligne;	/* longueur d'une ligne en octet	*/
	int handle;						/* numero de la station de travail virtuelle associ‚e a l'‚cran */
	int	w;		/* largeur de l'ecran	*/
	int h;		/* hauteur de l'ecran	*/
	int hc;		/* taille standard des characteres de la base line a la topline	*/
	t_resolution res;		/* la resolution courante, au demarrage de l'application	*/
	int mode;						/* le mode courant si on est sur falcon 	*/
	char une_palette;		/* 	FALSE: pas de palette	= NEAR TRUE COLOR ou TRUE_COLOR) */
											/* 	TRUE : une palette */
	long	n_color_pal;	/* nombre de couleurs  dans la palette ou dans le systeme */
	long	n_color;			/* nombre de feutres disponibles simultanements	*/
	int n_plane;				/* profondeur de l'ecran, en nb de plan	*/
	Palette	*palette;			/* pointeur vers la sauvegarde des feutres */
	int		nb_bit_coul[3];	/* nombre de bit par couleur */
	int		masque_coul[3];	/* masque pour les couleurs */
	void	*phys;					/* adresse physique de l'‚cran */
	void	*log;						/* adresse logique de l'‚cran */
}	t_display;

/* MA_30_10 : structure pour la sauvegarde des dimensions du bureau	*/
typedef struct t_desktop
{
	int xd, yd, wd, hd;
} t_desktop;

/* MA_30_10 : identification du hard et du soft	*/
extern t_ident_hard_soft desc_hard_soft;

/* MA_30_10: informations sur la station de travail	*/
extern t_display work_display;

/* MA_30_10: info sur le bureau	*/
extern t_desktop bureau;
/* #] D‚finitions :																								*/ 
/* #[ Prototypage des fonctions :																	*/
/****** Fonctions d'initialisation ********************************/
int		initial (char *rsc, int menu, int desk, int nb_tree,
							 OBJECT *rs_tree, char *rs_str, int n_wind, int acc);
void	end (void);

/****** Fonctions de gestion des formulaires **********************/
void	formm_draw (OBJECT *adr, int ed, int flmove, MFDB *img);
void	formm_undraw (OBJECT *adr, MFDB *img);
void	formf_draw (OBJECT *adr, int ed);
void	formf_undraw (OBJECT *adr);
void	create_hierm (OBJECT *adr);
int		dialog (int flags, OBJECT *address, int f,
							int fl_rb, int form_pu, MFDB *img, int fl_move);
int		match (OBJECT *adr, int button);
void	set_popup (OBJECT *adr, int button, int option);
int		free_popup (int posx, int posy, int form);
void	get_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
void	put_bkgr (int of_x, int of_y, int of_w, int of_h, MFDB *img);
int		big_alert (int button, int number, char *str, int fl_alrt);
char	*get_string (int number);
int		parent (OBJECT *adr, int object);
void	bak_rsc (OBJECT *tree, char **bak);
void	res_rsc (OBJECT *tree, char **bak);

/****** Fonctions pour les EDITABLEs ******************************/
void	set_text (OBJECT *adr, int object, char *string);
char	*get_text (OBJECT *adr, int object);

/****** Fonctions diverses ****************************************/
char	*path (char *pat);
long	exist (char *name, int att);
void	set_palette (int index);
long	timer (void);
char	*trim (char *str);
void	send_mesag (int type, int wi, int x, int y, int w, int h);
int		selector (char *pat, char *ext, char *file, char *title);
void	extension (char *filename, char *ext);
COOKIE *first_cookie (void);				/* Le premier cookie */
COOKIE *next_cookie (COOKIE *ck);		/* Cookie suivant */
COOKIE *vq_cookie (long id);				/* Cherche un cookie par id */
COOKIE *vq_cookie_c (char *c);			/* Cherche un cookie par chaŒne */

/****** Fonctions pour les fenˆtres *******************************/
int		formw_draw (OBJECT *adr, int index, int title, int infos,
									int wed, int fb, int attr, FNCP ricn);
int		open_window (int index, int type, int attr,
									 int x, int y, int w, int h,
									 int wm, int hm, int wu, int hu, int fa, int fb, int fmouse,
									 FNCP ricn, FNCP redr, FNCP clos,
									 char *title, char *info,
									 long wt, long ht,
									 int fmenu, int ftool, int bar);
int		find_index (int wh);
int		find_window (int mx, int my);
void	zone_work (int index, int *xw, int *yw, int *ww, int *hw);
void	height_sliders (int index);
void	draw_object (int object, int index);
void	print_page (int index);
void	topped (void);
void	closed (void);
void	fulled (void);
void	sized (void);
void	moved (void);
/* #] Prototypage des fonctions :																	*/ 
#endif

