#define boolean int

typedef struct
{
	GRECT		box;		/* coordon‚es par d‚faut de la fenˆtre */
	int			type;		/* type de la fenˆtre */
	void		*fenetre;	/* fenˆtre associ‚e si elle existe */
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

typedef struct
{
	int menu;
	int entree;
	int key;
	int state;
} raccourcis_var;

/************* entr‚e dans le tableau des partitions **************/
typedef struct
{
	long	start;		/* 1er secteur de la partition */
	long	size;		/* taille de la partition en secteur */
	int		devno;		/* 0-7 : ACSI, 8-15 : SCSI, 16-23 : IDE, 24-31 : ZORG, -1 si la partition n'est pas d‚finie */
	BPB		bpb;		/* Bios Param‚ter Bloc pour un accŠs mˆme sans booter */
} t_partition;

