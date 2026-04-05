/* **[Fonctions Communes]************************ */
/* *  Variables Globales des applications et    * */
/* *  des fonctions Communes                    * */
/* *  08/07/2003 19/08/2014                     * */
/* ********************************************** */

#ifndef __COEUR_VARIABLES__
#define __COEUR_VARIABLES__


#include	"type_gcc.h"
#include	"Coeur_Define.c"


/* -------------------------- */
/* Variables concernant l'AES */
/* -------------------------- */

int16  ap_id=0;         /* numero AES du programme */
int16  buffer_aes[16];  /* buffer pour recevoir les messages AES */

int16  Fcm_timer_eventmulti=0;

int16  h_win            [NB_FENETRE];	/* handle de chaque fenˆtre */
int16  win_iconified    [NB_FENETRE];	/* m‚morise l'‚tat ICONFY   */
int16  win_shaded       [NB_FENETRE];	/* m‚morise l'‚tat SHADED   */
int16  win_rsc          [NB_FENETRE];	/* Index dialogue de chaque fenˆtre   */
int16  win_rsc_iconify  [NB_FENETRE];	/* Index dial iconifi‚ de chaque fenˆtre   */

/*int16  win_pos          [NB_FENETRE][5];*/ /* m‚morise la derniŠre position      */
int16  win_posxywh      [NB_FENETRE][4]; /* position et dimension des fenetres  */


int16  win_mouse_through[NB_FENETRE];	/* si elle a besoin des events souris */

int16  win_iconified_flag=FALSE;
int16  win_all_iconified_flag=FALSE;
int16  win_all_iconified_winindex=FCM_NOINDEX_ALLICONIFIED;


char  pipename[]="U:\\PIPE\\DRAGDROP.XX";


/* --------------------------- */
/* Variables concernant la VDI */
/* --------------------------- */

int16 vdihandle=0;     /* handle VDI du programme */
int16 pxy[16];

GRECT souris;
MFDB  Fcm_mfdb_ecran;  /* MFDB pour l'‚cran physique VDI */










/* Definition du type et du tableau de pointeur de fonction  */
/* pour les appels de fonction de gestion des fenˆtres, d‚fini*/
/* … l'ouverture des fenˆtres.                                */
typedef VOID (*FT_GESTION) ( WORD controlkey, WORD touche, WORD bouton );
FT_GESTION table_ft_gestion_win[NB_FENETRE];


/* Definition des fonctions qui seront appeler pour g‚rer les  */
/* ouverture de fenetre                                        */
typedef VOID (*FT_OUVRE_WIN) ( VOID );
FT_OUVRE_WIN table_ft_ouvre_fenetre[NB_FENETRE];


/* Definition des fonctions qui seront appeler pour g‚rer les  */
/* fermetures de fenetre                                        */
typedef VOID (*FT_FERME_WIN) ( VOID );
FT_FERME_WIN table_ft_ferme_fenetre[NB_FENETRE];


/* Definition du type et du tableau de pointeur de fonction  */
/* pour les appels de fonction redraw, d‚fini … l'ouverture   */
/* des fenˆtres.                                              */
typedef VOID (*FT_REDRAW) ( const GRECT *rd );
FT_REDRAW table_ft_redraw_win[NB_FENETRE];



/* Definition du type et du tableau de pointeur de fonction,     */
/* pour les appels de fonction qui doivent g‚rer le r‚affichage  */
/* d'objet dans les fenetres aprŠs une op‚ration de redraw       */
/* partiel. Cela concerne les fenetres qui affichent des donn‚es */
/* en continu, en cas de redraw partiel, l'affichage deviendra   */
/* incoh‚rent */
typedef VOID (*FT_REFRESH) ( VOID );
FT_REFRESH table_ft_refresh_win[NB_FENETRE];





/* Definition de la fonction qui pourra etre appeler durant   */
/* la gestion de certain evenement bloquant du programme      */
/* Ex: La gestion du clic bouton est bloquante, la boucle AES */
/* n'est plus appeler et donc les tache dans l'event TIMER ne */
/* sont plus ex‚cut‚. Ce pointeur de fonction permettra de    */
/* continuer … ex‚cuter la fontion cible de l'event TIMER     */
/*typedef VOID (*FT_TIMER) ( VOID );
FT_TIMER fcm_ft_task_timer=FCM_FONCTION_NON_DEFINI;*/





/* Variables global concernant la gestion des */
/* arguments au lancement du programme        */
WORD  ARGV_nombre_argument=0;
CHAR* ARGV_pt_argument[ARGV_MAX_ARGUMENT];
ULONG ARGV_adr_buffer=0;




/* ******************************************* */
/* Variables globales fonctions et application */
/* ******************************************* */

/* ------------------------------------------ */
/* Variables Globales utilis‚ par la fonction */
/* get_machine_info()                         */
/* ------------------------------------------ */
struct s_systeme
{
	int16  tos_version;
	int16  tos_langage;
	int16  magic_os;
	int16  mint_os;
	int16  aes_multi;
	int16  aes_version;
	int16  gemdos_version;
	int16  cpu_type;
	int16  noblock;
} systeme;



/* ------------------------------------------ */
/* Variables Globales utilis‚ par la fonction */
/* get_screen_info()                          */
/* ------------------------------------------ */
struct s_screen
{
	uint32 adresse;
	uint32 physbase;
	uint32 color;
	int16  nb_plan;
	int16  width;
	int16  height;
	int16  mode_palette;
	int16  pixel_format;
	int16  pixel_xformat;
	int16  x_desktop;
	int16  y_desktop;
	int16  w_desktop;
	int16  h_desktop;
	int16  eddi_version;
	int16  palette_to_device[256];
} screen;



/*
 * Variables Globales utilis‚ par la fonction
 * init_environnement()
 *
*/
/*  CHAR Fcm_chemin_courant[TAILLE_CHEMIN]="";*/
CHAR Fcm_chemin_config [TAILLE_CHEMIN]="";


CHAR Fcm_chemin_fichier[TAILLE_CHEMIN]="";
CHAR Fcm_fichier[TAILLE_FICHIER]="";


/*CHAR Fcm_chemin_source     [TAILLE_CHEMIN]={""};*/
/*CHAR Fcm_fichier_source    [TAILLE_FICHIER]={""};*/
/*CHAR Fcm_chemin_destination[TAILLE_CHEMIN]={""};*/


/*
 * Variables Globales utilis‚ par la fonction
 * init_form_background()
 *
*/
 /* Variable pour le background des form_alerte() */
/* ULONG adr_buf_formback=NULL;
 ULONG formback_flag=FALSE;
  MFDB mfdb_formback;*/





/* -----------------------------------------------------------
 * Variables Globales utilis‚ par la fonction
 * init_windframe()
 * -----------------------------------------------------------
*/
/* ULONG Fcm_adr_win_frame=0;*/     /* adresse texture windframe */
/* ULONG Fcm_adr_buf_windframe=0;*/ /* adresse Malloc  WindFrame */
/* ULONG Fcm_winframe_flag;*/       /* disponible ou non...      */

/*  MFDB Fcm_mfdb_winframe;*/       /* MFDB de la texture        */

/*WORD Fcm_dialogue_largeur_max;*/
/*WORD Fcm_dialogue_hauteur_max;*/



/* ------------------------------------------------------------
 * Variables Globales utilis‚ par la fonction
 * Fcm_task_timer()
 * ------------------------------------------------------------
*/
 ULONG fcm_task_timer_old=0;/* ancienne valeur du timer afin    */
							/* de pouvoir switcher sur la tache */



/* ------------------------------------------------------------
 * Variables Globales utilis‚ par la fonction
 * log_print()
 * ------------------------------------------------------------
*/

#ifdef LOG_FILE
  CHAR  texte[4096]="";       /* affichage barbare sur l'‚cran */
  CHAR  buf_log[4096]=""; /* pour pour sortie fichier */
#endif


/* Sauvegarde auto des options */
WORD Fcm_save_option_auto;




#endif /* __COEUR_VARIABLES__ */


