/* **[Fonctions Communes]************************ */
/* *  Variables Globales des applications et    * */
/* *  des fonctions Communes                    * */
/* *  08/07/2003 MaJ 22/02/2024                 * */
/* ********************************************** */


#ifndef __COEUR_VARIABLES_H__
#define __COEUR_VARIABLES_H__


#include	"type_gcc.h"
#include	"coeur_define.h"


/* -------------------------- */
/* Variables concernant l'AES */
/* -------------------------- */

int16  ap_id=0;         /* id AES du programme */
int16  buffer_aes[16];  /* buffer pour recevoir les messages AES */


int16  h_win            [NB_FENETRE];	/* handle de chaque fenˆtre */
int16  win_iconified    [NB_FENETRE];	/* m‚morise l'‚tat ICONFY   */
int16  win_shaded       [NB_FENETRE];	/* m‚morise l'‚tat SHADED   */
int16  win_rsc          [NB_FENETRE];	/* Index dialogue de chaque fenˆtre   */
int16  win_rsc_iconify  [NB_FENETRE];	/* Index dial iconifi‚ de chaque fenˆtre   */
/*int16  win_info         [NB_FENETRE];*/	/* Index pour la barre info de chaque fenˆtre   */
int16  win_widgets      [NB_FENETRE];	/* attribut de chaque fenˆtre */
int16  win_titre        [NB_FENETRE];	/* Index pour le titre de chaque fenˆtre dans le RSC */
int16  win_moved_scalex [NB_FENETRE];	/* indique s'il faut corriger x sur WM_MOVED */



#define FCM_WIN_TITRE_MAXSIZE  (32)
static char fcm_win_titre_texte[NB_FENETRE][FCM_WIN_TITRE_MAXSIZE];  /* buffer pour les titres des fenetres */
char *fcm_win_info_texte[NB_FENETRE];  /* pointeur vers buffer pour la barre info des fenetres */

int16  win_posxywh      [NB_FENETRE][4]; /* position et dimension des fenetres  */

int16  win_mouse_through[NB_FENETRE];	/* si la fenetre a besoin des events souris */

/*int16  win_iconified_flag=FALSE;*/    /*  ???  apparemment non utilisé */
int16  win_all_iconified_flag=FALSE;    /* indique si toutes les fenetres sont iconifiées */
/*int16  win_all_iconified_winindex=FCM_NOINDEX_ALLICONIFIED;*/   /*  ???  apparemment non utilisé */

/*int16  win_index_quit_closewin;*/


/*
 * Buffer pour lire les infos du RSC, nombre de R_TREE, etc...)
 *
 * Un buffer global qui fait perdre 36 octets, mais rien
 * comparé à tout le code qu'il faudrait pour charger l'entete
 * du RSC ailleur (vérif, toussa...) que dans Fcm_charge_rsc()
 * Donc, un buffer global que l'on rempli au moment de charger
 * le RSC.
 */
int16 Fcm_header_rsc[ (sizeof(RSHDR) / sizeof(int16)) ];

#define FCM_RSRC_GADDR_RTREE_MAX    (32)
OBJECT *Fcm_adr_RTREE[FCM_RSRC_GADDR_RTREE_MAX];

#define FCM_RSRC_GADDR_RSTRING_MAX    (16)
char *Fcm_adr_RSTRING[FCM_RSRC_GADDR_RTREE_MAX];



char  pipename[]="U:\\PIPE\\DRAGDROP.XX";


/* --------------------------- */
/* Variables concernant la VDI */
/* --------------------------- */

int16 vdihandle=0;     /* handle VDI du programme */
int16 pxy[16];         /* tableau pour les fonctions VDI */

GRECT souris;
MFDB  Fcm_mfdb_ecran;  /* MFDB pour l'‚cran physique VDI */


GRECT Fcm_zone_bureau; /* zone du bureau pour les fonctions de redraw */



int16 Fcm_init_appli_terminer=FALSE;
int16 Fcm_quitter_application;  /* gestion AP_TERM */



/* Definition du type et du tableau de pointeur de fonction  */
/* pour les appels de fonction de gestion des fenˆtres, d‚fini*/
/* … l'ouverture des fenˆtres.                                */
typedef void (*FT_GESTION) ( int16 controlkey, int16 touche, int16 bouton );
FT_GESTION table_ft_gestion_win[NB_FENETRE];


/* Definition des fonctions qui seront appeler pour g‚rer les  */
/* ouverture de fenetre                                        */
typedef void (*FT_OUVRE_WIN) ( void );
FT_OUVRE_WIN table_ft_ouvre_fenetre[NB_FENETRE];


/* Definition des fonctions qui seront appeler pour g‚rer les  */
/* fermetures de fenetre                                        */
typedef void (*FT_FERME_WIN) ( void );
FT_FERME_WIN table_ft_ferme_fenetre[NB_FENETRE];


/* Definition du type et du tableau de pointeur de fonction  */
/* pour les appels de fonction redraw, d‚fini … l'ouverture   */
/* des fenˆtres.                                              */
typedef void (*FT_REDRAW) ( const GRECT *rd, const int16 index_tab_win );
FT_REDRAW table_ft_redraw_win[NB_FENETRE];


/* Definition du type et du tableau de pointeur de fonction  */
/* pour les appels de fonction widgets et slider.            */
typedef void (*FT_SLIDERS) ( void );
FT_SLIDERS table_ft_gestion_widgets[NB_FENETRE];


typedef void (*FT_SLIDERS) ( void );
FT_SLIDERS table_ft_gestion_sized[NB_FENETRE];



/* Definition du type et du tableau de pointeur de fonction,     */
/* pour les appels de fonction qui doivent g‚rer le r‚affichage  */
/* d'objet dans les fenetres aprŠs une op‚ration de redraw       */
/* partiel. Cela concerne les fenetres qui affichent des donn‚es */
/* en continu, en cas de redraw partiel, l'affichage deviendra   */
/* incoh‚rent */
typedef void (*FT_REFRESH) ( void );
FT_REFRESH table_ft_refresh_win[NB_FENETRE];
/* C'est utilisé uniquement avec l'appli Windupdate, elle avait */
/* besoin de cette fonctionnalitée car les affichages AES       */
/* étaient non bloquant avec l'extension de Windupdate(NO_BLOCK)*/
/* Donc les champs de test n'étaient pas forcément mis à jour   */
/* a l'ecran et si un redraw partiel arrivait, cela créait des  */
/* altération à l'écran, d'où la création de cette fonction...  */
/* Utilisé par aucune autre appli ...                           */




/* Definition de la fonction qui pourra etre appeler durant   */
/* la gestion de certain evenement bloquant du programme      */
/* Ex: La gestion du clic bouton est bloquante, la boucle AES */
/* n'est plus appeler et donc les tache dans l'event TIMER ne */
/* sont plus ex‚cut‚. Ce pointeur de fonction permettra de    */
/* continuer … ex‚cuter la fontion cible de l'event TIMER     */
/*typedef void (*FT_TIMER) ( void );
FT_TIMER fcm_ft_task_timer=FCM_FONCTION_NON_DEFINI;*/



/* Definition de la fonction qui pourra etre appeler durant   */
/* la gestion du changement de langage du rsc                 */

typedef void (*FT_RSC_REINIT) ( void );
FT_RSC_REINIT Fcm_ft_rsc_init=FCM_FONCTION_NON_DEFINI;









/* Variables global concernant la gestion des */
/* arguments au lancement du programme        */
#define ARGV_MAX_ARGUMENT	(128)
int16  ARGV_nombre_argument=0;
char  *ARGV_pt_argument[ARGV_MAX_ARGUMENT];
uint32 ARGV_adr_buffer=0;




/* ******************************************* */
/* Variables globales fonctions et application */
/* ******************************************* */

/* ------------------------------------------ */
/* Variables Globales utilis‚ par la fonction */
/* fcm_get_machine_info()                     */
/* ------------------------------------------ */
struct s_systeme
{
   uint16  tos_version;
	int16  tos_langage;
	int16  aes_langage;
	int16  magic_os;
	int16  mint_os;
	int16  aes_multi;
	int16  aes_version;
	int16  aes_numapps;
	int16  gemdos_version;
	uint16 nvdi_version;
	uint32 pci_version;
	int16  supervidel;
	int16  cpu_type;
	int16  machine_type;
	int16  machine_subtype;
	int16  machine_modele;
	uint16 video_ram_type;
	int32  snd_cookie;
	int16  noblock;
	int16  xbios_sound;
	int16  xbios_sound_mode;
	int16  tsr_ldg_version;
} Fcm_systeme;



/* ------------------------------------------ */
/* Variables Globales utilis‚ par la fonction */
/* fcm_get_screen_info()                      */
/* ------------------------------------------ */
struct s_screen
{
	uint32 adresse;
	uint32 physbase;
	uint32 color;
	int16  raster_scalling;
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
	int16  gr_hwchar;
	int16  gr_hhchar;
	int16  gr_hwbox;
	int16  gr_hhbox;
	int16  eddi_version;
	int16  palette_to_device[256];
} Fcm_screen;



/*
 * Variables Globales utilis‚ par la fonction
 * fcm_init_environnement()
 *
*/
char Fcm_chemin_courant[FCM_TAILLE_CHEMIN]="";
char Fcm_chemin_config [FCM_TAILLE_CHEMIN]="";



/* utiliser uniquement par les fonctions va_start */
/* a virer */
char Fcm_chemin_fichier[FCM_TAILLE_CHEMIN]="";
char Fcm_fichier[FCM_TAILLE_FICHIER]="";








/* ------------------------------------------------------------
 * Variables Globales utilis‚ par la fonction
 * Fcm_task_timer()
 * ------------------------------------------------------------
*/
 /*uint32 fcm_task_timer_old=0;*/ /* ancienne valeur du timer afin    */
							/* de pouvoir switcher sur la tache */



/* ------------------------------------------------------------
 * Variables Globales utilis‚ pour les
 * Pr‚f‚rences de l'application
 * ------------------------------------------------------------
 */

int16 Fcm_rsc_langage_code=PLANG_FRANCAIS;

/* Sauvegarde auto des options */
int16 Fcm_save_option_auto=FALSE;
int16 Fcm_save_winpos=TRUE;
int16 Fcm_quit_closewin=TRUE;



/* si Fcm_disk_full (plus de place sur le disk) passe à TRUE, */
/* plus aucune sauvegarde n'a lieu (cache/log/etc...)         */
int16 Fcm_disk_full=FALSE; /* a modifier utiliser Dfree() pour tester l'espace dispo avant ecriture */



#endif /* __COEUR_VARIABLES_H__ */

