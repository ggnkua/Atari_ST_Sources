/* Macro pour retrouver les textes multi-langages */
#define Messages(a)	Messages[a].ob_spec.free_string

#include <portab.h>
#include <stdio.h>

#define	MIN(a, b)	((a<b) ? a : b)
#define MAX(a, b)	((a>b) ? a : b)

/**************** Taille de la chaŒne recherch‚e *******************/
#define SEARCH_PATTERN_SIZE 40

/************** Taille maximum du raccourcis clavier *****************/
#define SHORTCUT_SIZE 13	/* au max '^Backspace ' */

/******** Nombre maximal de fichiers s‚l‚ctionn‚s par le selecteur ******/
#define MAX_SELECTED_FILES 16

/******************** Nombre maximal de devices ********************/
#define MAX_DEVICES 16

/*************** D‚finitions pour une fenˆtre de texte ****************/
#define TEXTSIZE 10000	/* taille reserv‚e pour stocker les textes */
#define LINENUMBER 200	/* nombre de lignes */

#define SECTEURLINE 22		/* 20 lignes pour un secteur */
#define SECTEURLINESIZE 71	/* 70 caractŠres par ligne */
#define SECTEURSIZE (SECTEURLINE+2)*SECTEURLINESIZE	/* la permiŠre ligne est deux fois plus grande */

/********** Taille maximale d'un titre ou info de fenˆtre **********/
#define MAX_TITLE 60

/********** Type interne d'une entr‚e dans un r‚pertoire sans VFAT ***********/
typedef struct _dir_elt_short
{
	char	name[8+3];		/* nom du fichier + extension	*/
	UBYTE	attribut;		/* attributs du fichier			*/
	UWORD	norealdir;		/* TRUE si c'est un r‚pertoire '.' ou '..' */
	UWORD	time;			/* heure						*/
	UWORD	date;			/* date							*/
	unsigned int first_cluster;	/* premier cluster (ordre MOTOROLA)	*/
	long	size;			/* taille du fichier			*/
	struct _dir_elt_short *dir;	/* arborescence du r‚pertoire	*/
} dir_elt_short;

/********** Type interne d'une entr‚e dans un r‚pertoire en VFAT ***********/
typedef struct _dir_elt_vfat
{
	char	name[8+3];		/* nom du fichier + extension	*/
	UBYTE	attribut;		/* attributs du fichier			*/
	UWORD	norealdir;		/* TRUE si c'est un r‚pertoire '.' ou '..' */
	UWORD	time;			/* heure						*/
	UWORD	date;			/* date							*/
	unsigned int first_cluster;	/* premier cluster (ordre MOTOROLA)	*/
	long	size;			/* taille du fichier			*/
	struct _dir_elt_vfat *dir;	/* arborescence du r‚pertoire	*/
	char	filler[10];		/* r‚serv‚, VFAT				*/
} dir_elt_vfat;

/************ Type r‚el d'une entr‚e dans un r‚pertoire *************/
typedef struct
{
	char	name[8+3];		/* nom du fichier + extension	*/
	UBYTE	attribut;		/* attributs du fichier			*/
	char	filler[10];		/* r‚serv‚, VFAT				*/
	UWORD	time;			/* heure						*/
	UWORD	date;			/* date							*/
	UWORD	first_cluster;	/* premier cluster (format INTEL … la con) */
	long	size;			/* taille du fichier			*/
} real_dir_elt;

/*
	Each window will have a grafport so that it is easy to maintain 
	drawing environments accross windows.
*/
typedef struct _grafport
{
	int		handle;		/*  Virtual workstation handle  					*/
	MFDB	mfdb;		/*  memory definition block for virtual workstation	*/
} grafport;

/************* d‚finition d'un ‚l‚ment de list goto ***************/
typedef struct _goto
{
	long secteur;			/* No de secteur				*/
	int page;				/* page dans le secteur			*/
	unsigned int cluster;	/* No de cluster				*/

	long offset;			/* d‚calage par rapport au d‚but (se calcul avec secteur et curseur_?) */
	signed char curseur_x;	/* position du curseur			*/
	signed char curseur_y;

	char text[31];			/* contient le texte 10 caractŠres avant et 20 aprŠs */

	struct _goto *suivant;	/* pointeur sur l'elt suivant	*/
} t_goto;

/************* d‚finition d'une fenˆtre d'occupation **************/
typedef struct 
{
	int		device;			/* pour quel disque				*/

	boolean	decimal;		/* TRUE si l'affichage de la position se fait en d‚cimal */
	boolean	fichier;		/* fichier associ‚ affich‚ ou non		*/

	char	couleur_fond;	/* couleur du fond de la fenˆtre */
	char	trame_fond;		/* trame " " */

	char	couleur_blocs;	/* couleur des blocs occup‚s */
	char	trame_blocs;	/* trame "  " */

	char	couleur_bad_blocs;	/* couleur des bad blocs */
	char	trame_bad_blocs;	/* trame "  " */

	char	couleur_selected;	/* couleur des bloc du fichier s‚l‚ctionn‚ */
	char	trame_selected;		/* trame "  " */

	char	couleur_fragment;	/* couleur d'un fichier fragment‚ */
	char	trame_fragment;		/* trame "  " */

	char	couleur_end;	/* couleur du marqueur de fin */
	char	trame_end;		/* trame "  " */
} t_occup;

/*********** d‚finition commune d'une fenˆtre de texte *************/
#define _TEXTE \
	char	*Text;			/* Pointe sur le texte					*/ \
	int		TextSize;		/* Taille du bloc de texte				*/ \
	char	**Ligne;		/* Pointe sur un tableau contenant l'adresse de d‚but de chaque ligne */ \
	int		LineNumberMax;	/* Nombre de lignes max					*/ \
	int		CurrentLine;	/* Indice de la premiŠre ligne libre	*/ \
	int		taille_pt; 		/* Taille de la police en point			*/ \
	int		taille_w; 		/* largeur d'un caractŠre externe		*/ \
	int		taille_h; 		/* hauteur d'un caractŠre externe		*/ \
\
	int		LineNumber;		/* Nombre de lignes						*/ \
	int		PrintLine;		/* derniŠre ligne affich‚e en compatage circulaire */ \
\
	int		ligne;			/* derniŠre ligne affich‚e en comptage normal */ \
	int		colonne;		/* Colonne ou commence l'affichage		*/ \
\
	char	couleur_fond;	/* trame du fond de la fenˆtre */ \
	char	trame_fond;		/* trame " " */ \
	char	couleur_texte;	/* couleur du texte */

/*************** d‚finition d'une fenˆtre de texte *****************/
typedef struct 
{
	_TEXTE					/* les champs de texte		*/

	char	*debut;			/* Adresse du bloc libre	*/
	int		reste;			/* Taille du bloc restant	*/
} t_text;

/************* d‚finition de base d'une fenˆtre secteur *************/
#define _SECTEUR \
	char	*secteurBin;	/* pointeur sur le secteur en binaire	*/ \
	signed char curseur_x;	/* position x du curseur				*/ \
	signed char curseur_y;	/* position y du mˆme curseur			*/ \
	char	couleur_curseur;/* couleur du curseur					*/ \
	char	trame_curseur;	/* trame du curseur						*/ \
\
	boolean	ascii;			/* TRUE si on voit le secteur en ASCII	*/ \
\
	boolean	dirty;			/* vaut TRUE si il faut r‚-‚crire le secteur */ \
\
	t_goto	*goto_liste;	/* liste des positions					*/ \
\
	long	max;			/* dernier secteur accessible			*/ \
	long	secteur;		/* num‚ro du secteur					*/ \
\
	int		page;			/* num‚ro de page de 512 octets du secteur */ \
	int		sector_size;	/* taille du secteur en page de 512 octets */ \
\
	boolean	decimal;		/* TRUE si l'affichage de la position se fait en d‚cimal */ \
\
	OBJECT	*slide;			/* Pointeur sur l'arbre du slider */\
\
	int		device;			/* num‚ro de device					*/\
\
	char	nom[FILENAME_MAX];	/* nom du fichier				*/\
	long	size;			/* taille du fichier en octets		*/

/*********** d‚finition d'une fenˆtre de disque (secteur) ***********/
typedef struct 
{
	_TEXTE					/* les champs de texte				*/

	_SECTEUR				/* les champs pour un secteur		*/

	boolean	fichier;		/* fichier associ‚ affich‚ ou non	*/
} t_secteur;

/**** d‚finition d'une fenˆtre de fichier d'un autre File System ****/
typedef struct 
{
	_TEXTE					/* les champs de texte				*/

	_SECTEUR				/* les champs pour un secteur		*/

	int		file_desc;		/* -1 * descripteur de fichier (Fopen)	*/
} t_fichier_fs;

/*********** d‚finition d'une fenˆtre de fichier ***********/
typedef struct 
{
	_TEXTE					/* les champs de texte				*/

	_SECTEUR				/* les champs pour un secteur		*/

	long	*table;			/* tableau contenant les num‚ros des secteurs du fichier (pas les num‚ros des clusters) */
} t_fichier;

/*********** d‚finition d'une fenˆtre de disquette, accŠs direct ***********/
typedef struct 
{
	_TEXTE					/* les champs de texte				*/

	_SECTEUR				/* les champs pour un secteur		*/

	char	lecteur;		/* num‚ro de lecteur				*/

	char	real_secteur;	/* vrai num‚ro du secteur			*/
	char	piste;			/* num‚ro de la piste				*/
	char	face;			/* num‚ro de la face				*/

	char	max_secteur;	/* nombre de secteurs par piste		*/
	char	max_piste;		/* nombre de pistes					*/
	char	max_face;		/* nombre de faces-1 (1 pour 2 faces) */
} t_raw_floppy;

/*********** d‚finition d'une fenˆtre de disque dur, accŠs direct ***********/
typedef struct 
{
	_TEXTE					/* les champs de texte				*/

	_SECTEUR				/* les champs pour un secteur		*/
} t_raw_hard;

/*********** d‚finition d'une fenˆtre de tampon (1 secteur) ***********/
typedef struct 
{
	_TEXTE					/* les champs de texte				*/

	_SECTEUR				/* les champs pour un secteur		*/
} t_tampon;

/* attention, l'ordre est important
 1. fenˆtres sans rien
 2. text
 3. tampon
 4. fenˆtre de secteur
*/
enum { OCCUP, TEXT, TAMPON, SECTEUR, FICHIER, RAW_FLOPPY, RAW_HARD, FICHIER_FS };

/*************** un dialogue ***************/
typedef struct _t_dialog
{
	OBJECT	*tree;			/* l'arbre */
	DIAINFO	*info;			/* structure EnhancedGEM */
	boolean	(*proc)(struct _t_dialog *dialog, int ex);	/* fonction appel‚e lors d'un clic. retourne TRUE si on continue, FALSE si on ferme */
	void	*var;			/* les variables locales */
	struct _windowrec	*thewin;	/* fenˆtre associ‚e */
} t_dialog;

/********************* Window definition ***********************/
typedef struct _windowrec
{
	struct _windowrec	*next;		/* Window link						*/
	WIN					*win;		/* structure de fenˆtre EnhancedGEM	*/
	int					kind_c;		/* The windows type (creation)		*/
	char				title[MAX_TITLE+2];	/* titre de la fenˆtre		*/
	char				info[MAX_TITLE+2];	/* info de la fenˆtre		*/
	int					type;		/* type de la fenˆtre				*/
	int					menu_entry;	/* num‚ro de menu associ‚ … la fenˆtre */
	int					place;		/* donne le num‚ro de profondeur de la fenˆtre. devant = 0 */
	union
	{
		t_text			text;		/* D‚finition des paramŠtres pour g‚rer le texte */
		t_secteur		secteur;	/* ParamŠtres d‚finissant un secteur */
		t_fichier		fichier;	/* idem pour un fichier */
		t_raw_floppy	raw_floppy;	/* idem pour une disquette en accŠs direct */
		t_raw_hard		raw_hard;	/* idem pour un disque dur en accŠs direct */
		t_occup			occup;		/* D‚finition de l'occupation d'un disque */
		t_tampon		tampon;		/* Presse Papier, Clip Board, Tampon... */
		t_fichier_fs	fichier_fs;	/* un fichier mais en utilisant Fopen et compagnie */
	} fonction;
} windowrec;
typedef windowrec *windowptr;

/************** entr‚e dans la liste des positions ***************/
/*
	NO	UTILISATION
	0	la premiŠre entr‚e est la fenˆtre principale,
	1	la deuxiŠme est la fenˆtre tampon,
	2	la troisiŠme est la ou les fenˆtres d'occupation,
	3	les suivantes sont les fenˆtres de secteurs, fichiers...
*/
typedef struct
{
	GRECT		box;		/* coordon‚es par d‚faut de la fenˆtre */
	int			type;		/* type de la fenˆtre */
	windowptr	fenetre;	/* fenˆtre associ‚e si elle existe */
	union
	{
		struct
		{
			char	texte_c;	/* couleur du texte */
			char	texte_pt;	/* taille du texte en point */

			char	curseur_c;	/* couleur du curseur ou des bad blocs*/
			char	curseur_t;	/* trame du curseur ou des bad blocs */

			char	background_c;	/* couleur du fond */
			char	background_t;	/* trame du fond */
		} texte;
		struct
		{
			char	background_c;	/* couleur du fond */
			char	background_t;	/* trame du fond */

			char	blocs_c;		/* couleur des blocs allou‚s */
			char	blocs_t;		/* trame des blocs allou‚s */

			char	bad_blocs_c;	/* couleur des bad blocs */
			char	bad_blocs_t;	/* trame des bad blocs */

			char	fragmented_c;	/* couleur des fichiers fragment‚s */
			char	fragmented_t;	/* trame des fichiers fragment‚s */

			char	selected_c;		/* couleur des fichiers s‚l‚ctionn‚s */
			char	selected_t;		/* trame des fichiers s‚l‚ctionn‚s */

			char	end_marq_c;		/* couleur du marqueur de fin */
			char	end_marq_t;		/* trame du marqueur de fin */
		} occup;
	} fonction;
} t_win_coord;

/************* entr‚e dans le tableau des partitions **************/
typedef struct
{
	long	start;		/* 1er secteur de la partition */
	long	size;		/* taille de la partition en secteur */
	int		devno;		/* 0-7 : ACSI, 8-15 : SCSI, 16-23 : IDE, 24-31 : ZORG, -1 si la partition n'est pas d‚finie */
	BPB		bpb;		/* Bios Param‚ter Bloc pour un accŠs mˆme sans booter */
} t_partition;

/************* description d'un bouton RAW_FLOPPY ***************/
typedef struct
{
	int		faces;		/* nombre de faces */
	int		secteurs;	/* nombre de secteurs */
	int		pistes;		/* nombre de pistes */
	int		device;		/* lecteur */
	char	bouton[7];	/* texte du bouton */
} t_raw_floppy_entry;

/************* description d'un bouton RAW_HARD ***************/
typedef struct
{
	int device;		/* p‚riph‚rique */
	long size;		/* nombre de secteurs */
	char bouton[7];	/* texte du bouton */
} t_raw_hard_entry;

/************* description d'une entr‚e de menu ***************/
typedef struct
{
	char	*text;	/* texte du menu */
	int		itemid;	/* num‚ro de l'entr‚e */
	int		state;	/* ‚tat des touches de contr“le */
	int		key;	/* touche associ‚e */
	int		new_state;	/* nouvel ‚tat */
	int		new_key;	/* nouvelle touche */
} t_menu_entry;

/************* description d'un menu ***************/
typedef struct
{
	t_menu_entry	*menu;	/* entr‚es de menu */
	int				menuid;	/* num‚ro du menu */
	int				nb_entrees;	/* nombre d'entre‚s dans le menu */
	int				size;	/* taille maximale d'une entr‚e */
	int				offset;	/* position du raccourcis */
} t_menu;

/************ dialog dans une fenˆtre **************/
typedef struct _dialog_list
{
	struct _dialog_list *next;
	t_dialog *dialog;
} t_dialog_list;

/**************** Application Global Variables ******************/

#ifdef Extern

windowptr	Firstwindow = NULL;	/* pointeur sur la premiŠre fenˆtre de la liste */
windowptr	Thefrontwin = NULL;	/* pointeur sur la fenˆtre active */
windowptr	Tampon = NULL;		/* pointeur sur la fenˆtre tampon */
char		*Boot = NULL;		/* pointeur sur un bloc contenant un boot */
char		*DeadSector = NULL;	/* idem pour la liste des secteurs d‚fectueux */
OBJECT		*Bureau = NULL;		/* arborescence des icones du bureau */
int			Drive = 0;			/* icone de lecteur ou de partition s‚letionn‚ */
GRECT		Zone;				/* coordon‚es de la fenˆtre active */
int			BlocSize = 10;		/* nombre de secteur saut‚s avec un d‚placement en 'bloc' */
unsigned int *FAT[MAX_DEVICES] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };	/* pointeur sur les FAT des disques */
dir_elt_short	*Arbo[MAX_DEVICES] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };	/* tableau de pointeur sur les arborescences */
dir_elt_short	**Cluster[MAX_DEVICES] =  { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };	/* tableau de pointeur sur les tableaux de pointeurs de fichiers contenus dans les clusters */
boolean		StructureTest[MAX_DEVICES] = { FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL, FAIL };	/* R‚sultat du test de structure */
BPB			Bpb[MAX_DEVICES];	/* tableau de Bios Parameter Bloc */
char		SearchString[SEARCH_PATTERN_SIZE+1] = ""; /* chaŒne … rechercher */
int			SearchLength = 0;	/* longueur de la chaŒne, != strlen(Search_string) si il y des \0 dedans */
boolean		Sens = FALSE;		/* sens de d‚tection du rectangle entr‚e/sortie	*/
boolean		Efface = TRUE;		/* indique si on doit effacer le fond de la fenˆtre avant un update */
t_win_coord	*Windows = NULL;	/* pointeur sur le tableau contenant les coordon‚es des fenˆtres */
int			WinEntrees = 0;		/* nombre d'entr‚es dans ce tableau */
t_partition	Partition[MAX_DEVICES];		/* d‚finition des partitions pour DMA_read() et autre */
boolean		ZorgInf = FALSE;	/* n'utilise pas les infos du systŠme mais celles de ZORG.INF */
boolean		DrawParam = TRUE;	/* doit-on red‚ssiner entiŠrement la boite paraminfo() ? */
char		ZeroChar = 'ú';		/* caractŠre utilis‚ pour afficher les octets nuls */
boolean		Reset = FALSE;		/* passe a TRUE lors d'une manip de la structure */
boolean		ClipBoard = FALSE;	/* TRUE si on utilise le ClipBoard GEM. Peut poser des problŠmes si C: est en panne */
CICONBLK	Ciconblk[MAX_DEVICES];		/* les icones du bureau */
CICON		Cicon[2];			/* les bitmaps des icones (2 bitmaps) */
t_raw_floppy_entry	RawFloppy[6] = {{2, 9, 80, 'A', "Rien"}, {2, 9, 80, 'A', "Rien"}, {2, 9, 80, 'A', "Rien"}, {2, 9, 80, 'A', "Rien"}, {2, 9, 80, 'A', "Rien"}, {2, 9, 80, 'A', "Rien"}};	/* descriptions des boutons RAW_FLOPPY */
t_raw_hard_entry	RawHard[6] = {{0, 1, "Rien"}, {0, 1, "Rien"}, {0, 1, "Rien"}, {0, 1, "Rien"}, {0, 1, "Rien"}, {0, 1, "Rien"}};	/* descriptions des boutons RAW_HARD */
char		AsciiChar = 'A';	/* caractŠre ASCII par d‚faut dans la boŒte */

char		Chemin[PATH_MAX] = "";	/* dernier chemin utilis‚ */
char		Fichier[FILENAME_MAX] = "";	/* nom du dernier fichier choisi */
char		FileNames[MAX_SELECTED_FILES][FILENAME_MAX];	/* tableau de noms de fichiers dans une s‚lection multitple */
/* il y en a MAX_SELECTED (16) */
char		*FselTable[] = { FileNames[0], FileNames[1], FileNames[2], FileNames[3], FileNames[4], FileNames[5], FileNames[6], FileNames[7], FileNames[8], FileNames[9], FileNames[10], FileNames[11], FileNames[12], FileNames[13], FileNames[14], FileNames[15] };

OBJECT		*Messages = NULL;	/* Messages multi-langages */

boolean		MakePause = FALSE;	/* effectue une pause au retour d'un programme ext‚rieur */
boolean		ClearScreen = FALSE; /* efface l'‚cran avant de lancer le programme (.TOS) */
boolean		FlushCache = TRUE;	/* vide les caches... */
boolean		Tos40xBug = TRUE;	/* ‚vite le bug du TOS 4.0x */
boolean		SavePos = TRUE;		/* sauvegarde la position avant une recherche */
int			ScrollTimer = 700;	/* attente avant d'effectivement charger le secteur dans un d‚placement temps r‚el */
boolean		Sound = TRUE;		/* petit bruit lors de la recherche */
boolean		DialogInWindow = FALSE;	/* on met les boŒtes de dialogues dans des fenˆtres */
boolean		ResetFlag = TRUE;	/* on sort avec un reset ? */
boolean		MultiWarning = TRUE;	/* affiche une boŒte d'avertissement en multitache */
boolean		KeepStructure = FALSE;	/* ne garde pas la structure en m‚moire aprŠs un test */

OBJECT		*Menu = NULL;		/* l'arbre du menu */
t_menu		*MenuShortCuts = NULL;	/* raccourcis clavier */
int			NbMenus = 0;		/* nombre de menus */
char		*MenuText = NULL;	/* texte des menus */

char		ConfigFileName[FILENAME_MAX] = "zorg.inf";	/* fichier de configuration */
boolean		SaveConfig = FALSE;	/* doit-on sauvegarder la configuration avant de quitter ? */

t_dialog	Dialog[TEXTES];		/* la description des couples (OBJECT*, DIAINFO) */

int			EventMask = MU_MESAG | MU_KEYBD | MU_M2 | MU_BUTTON2;	/* pour le EventHandler */
int			Timer = 460;
int			MaxClics = 256+2;

t_dialog_list	*WinDials = NULL;	/* liste des dialog dans une fenˆtre */
int			WinDialCount = 0;		/* nombre de dialog ouverts */

POPUP		PopUpUnit, PopUpMode;	/* PopUp menus d'ouverture de disque dur brut */
POPUP		PopUpUnit2, PopUpMode2;	/* PopUp choix de device */

POPUP		PopUpMenu;				/* PopUp menu Menu de configuration des raccourcis clavier */
POPUP		*PopUpEntry;			/* tableau de PopUp menus Entree */
OBJECT		*PopUpMenuTree = NULL;	/* arbre du popup Menu */
OBJECT		**PopUpEntryTree = NULL; /* tableau des arbres des poupup Entree */
char		*PopUpMenuText = NULL;	/* texte Menu */
char		**PopUpEntryText = NULL; /* tableau des textes Entree */

char		HelpString[FILENAME_MAX];	/* Message … faire passer … ST-GUIDE */

boolean		BottomIsMeaningful	= FALSE;	/* On peut cycler les fenˆtres avec un ‚v‚nement */
boolean		ManageVFAT = FALSE;		/* gŠre les noms de fichiers long (VFAT) +45% de consommation RAM */

#else

extern windowptr	Firstwindow;
extern windowptr	Thefrontwin;
extern windowptr	Tampon;
extern char 		*Boot;
extern char 		*DeadSector;
extern OBJECT		*Bureau;
extern int			Drive;
extern GRECT		Zone;
extern int			BlocSize;
extern unsigned int	*FAT[];
extern dir_elt_short	*Arbo[];
extern dir_elt_short	**Cluster[];
extern boolean		StructureTest[];
extern BPB			Bpb[];
extern char			SearchString[];
extern int			SearchLength;
extern boolean		Sens;
extern boolean		Efface;
extern t_win_coord	*Windows;
extern int			WinEntrees;
extern t_partition	Partition[];
extern boolean		ZorgInf;
extern boolean		DrawParam;
extern char			ZeroChar;
extern boolean		Reset;
extern boolean		ClipBoard;
extern CICONBLK		Ciconblk[];
extern CICON		Cicon[];
extern t_raw_floppy_entry	RawFloppy[];
extern t_raw_hard_entry		RawHard[];
extern char			AsciiChar;

extern char			Chemin[];
extern char			Fichier[];
extern char			FileNames[MAX_SELECTED_FILES][];
extern char			*FselTable[];

extern OBJECT		*Messages;

extern boolean		MakePause;
extern boolean		ClearScreen;
extern boolean		FlushCache;
extern boolean		Tos40xBug;
extern boolean		SavePos;
extern int			ScrollTimer;
extern boolean		Sound;
extern boolean		DialogInWindow;
extern boolean		ResetFlag;
extern boolean		MultiWarning;
extern boolean		KeepStructure;

extern OBJECT		*Menu;
extern t_menu		*MenuShortCuts;
extern int			NbMenus;
extern char			*MenuText;

extern char			ConfigFileName[];
extern boolean		SaveConfig;

extern t_dialog		Dialog[];

extern int			EventMask;
extern int			Timer;
extern int			MaxClics;

extern t_dialog_list	*WinDials;
extern int			WinDialCount;

extern POPUP		PopUpUnit, PopUpMode;
extern POPUP		PopUpUnit2, PopUpMode2;

extern POPUP		PopUpMenu;
extern POPUP		*PopUpEntry;
extern OBJECT		*PopUpMenuTree;
extern OBJECT		**PopUpEntryTree;
extern char			*PopUpMenuText;
extern char			**PopUpEntryText;

extern char			HelpString[];

extern boolean		BottomIsMeaningful;
extern boolean		ManageVFAT;

#endif
