/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 18/12/2015 * */
/* ***************************** */


#include   "fonction/coeur/type_gcc.h"
#include   <TGA_SA_LDG.H>
#include   "fonction/graphique/Fcm_create_surface.h"





/* -------------------------------------------- */
/* -                                          - */
/* -              Adresse info                - */
/* -                                          - */
/* -------------------------------------------- */
#define  RSC_VIEW_MODE_VDI       (1)
#define  RSC_VIEW_MODE_ST_RAM    (2)
#define  RSC_VIEW_MODE_TT_RAM    (3)
#define  RSC_VIEW_MODE_CT60_VRAM (4)

int16    rsc_adresse_view_mode=RSC_VIEW_MODE_VDI;



/* -------------------------------------------- */
/* -                                          - */
/* -               info system                - */
/* -                                          - */
/* -------------------------------------------- */
char info_eddi[16];
char info_nvdi[16];
char info_ct60[16];
char info_supv[16];
char info_pci[16];
char info_rez[16];
char info_vram_free[16];
char info_ati_device[16];

int32 gb_vram_free=0;



/* -------------------------------------------- */
/* -                                          - */
/* -              Statistiques                - */
/* -                                          - */
/* -------------------------------------------- */



/*********/
/* Bench */
/*********/
#define  DELAI_VALID_BENCH       (200*4)  /* x secondes */
#define  BENCH_NB_BOUCLE_START   (5)
#define  BENCH_TAILLE_ECRAN      (SCREEN_WIDTH*SCREEN_HEIGHT*(Fcm_screen.nb_plan/8))

uint32 gb_stats_stram_ecran=0;
uint32 gb_stats_ttram_ecran=0;
uint32 gb_stats_vdi_ecran=0;
uint32 gb_stats_ct60_vram_ecran=0;

uint32 gb_stats_stram_stram=0;
uint32 gb_stats_ttram_ttram=0;
uint32 gb_stats_vdi_vdi=0;
uint32 gb_stats_vdi_vdi2=0;
uint32 gb_stats_ecran_ecran=0;
uint32 gb_stats_ct60_ct60_vram=0;


/*********/
/* Stats */
/*********/
uint32 gb_stats_mode_vdi_fps  =0;
uint32 gb_stats_mode_vdi_bp   =0;

uint32 gb_stats_mode_vram_fps =0;
uint32 gb_stats_mode_vram_bp  =0;

uint32 gb_stats_mode_stram_fps=0;
uint32 gb_stats_mode_stram_bp =0;

uint32 gb_stats_mode_ttram_fps=0;
uint32 gb_stats_mode_ttram_bp =0;


/* -------------------------------------------- */
/* -                                          - */
/* -             Section Vid‚o                - */
/* -                                          - */
/* -------------------------------------------- */
#define SCREEN_PLAN   (0)
#define SCREEN_WIDTH  (320)
#define SCREEN_HEIGHT (200)


#define OCTET_PAR_PIXEL  (Fcm_screen.nb_plan/8)


/* pointeur de fonction sur l'‚cran … construire */
void (*pf_build_screen) (void) = NULL;



/* dimension de l'‚cran pour les vr?_cfm() */
int16   pxy_screen[8]={	0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
						0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1  };



/* structure pour le chargement des images */
/* et la cr‚aion des surfaces              */
/* initialis‚ dans init_surface.c          */
s_tga_ldg  image_tga;



/* couleur des masques pour l'affichage des sprites */
int16 mask_couleur[2];


uint32  gb_frame_fps;


int16  offscreenhandle=0;


/*#define OFFSCREEN_NORMAL  (0)
#define OFFSCREEN_VRAM    (1)*/

int16   offscreen_mode=RB_STAT_OFF_VDI;


int16   gb_mode_vdi_actif=TRUE;
int16   gb_mode_vram_actif=TRUE;
int16   gb_mode_ttram_actif=TRUE;
int16   gb_mode_stram_actif=TRUE;
int16   gb_mode_ct60_vram_actif=TRUE;

/* -------------------------------------------- */
/* -                                          - */
/* -             Section Animation            - */
/* -                                          - */
/* -------------------------------------------- */



/* ------------------- */
/* Animation de la BEE */
/* ------------------- */
typedef struct {
	uint16 x;
	uint16 y;

} s_coord;

#define NB_BEE_MAX       (99)
/*#define BEE_DECALAGE     (4)*/
#define BEE_DECALAGE_MAX (99)

#define ANIM_FILE_SIZE   (32432)
#define ANIM_NB_COORD    (ANIM_FILE_SIZE/4)

s_coord bee_xy[ANIM_NB_COORD];

int16  gb_nb_bee=20;
int16  gb_decalage_bee=4/*BEE_DECALAGE*/;

uint16  bee_index_coord[NB_BEE_MAX];






/*   FOND   */
SURFACE surface_fond;
MFDB    mfdb_fond;

int16   pxy_fond[8]={	0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
						0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1  };


MFDB    mfdb_fond_ttram;




/*   BEE   */
#define BEE_WIDTH  (64)
#define BEE_HEIGHT (55)

int16  pxy_bee[8];

SURFACE surface_bee;
SURFACE surface_bee_mask;
MFDB    mfdb_bee;
MFDB    mfdb_bee_mask;




/*   BAR   */
#define NB_BAR  (7)
#define BAR_WIDTH  (320)
#define BAR_HEIGHT (14)


int16   scroll_y=0;

SURFACE surface_bar[NB_BAR];
MFDB    mfdb_bar[NB_BAR];

int16  pxy_bar[8];

int16  bar_index_y[NB_BAR]={0,2,4,6,8,10,12};
int16  bar_sens[NB_BAR]={0,0,0,0,0,0,0};


#define NB_BAR_Y (35)
int16  position_y[NB_BAR_Y]=	{
										10,11,
										12,14,16,19,22,
										26,30,35,40,46,
										52,59,66,74,82,
										91,
										100,108,116,123,130,
										136,142,147,152,155,
										159,162,165,167,169,
										170,171
									};










uint32  octet_par_frame;
uint32  octet_total=0;
uint32  octet_redraw=0;




#define OCTET_MASK_BEE ( (BEE_WIDTH*BEE_HEIGHT)/8 )

#define PIXEL_ECRAN    (SCREEN_WIDTH*SCREEN_HEIGHT)
#define PIXEL_BEE      (BEE_WIDTH*BEE_HEIGHT)
#define PIXEL_ALL_BAR  (BAR_WIDTH*BAR_HEIGHT*NB_BAR)
#define PIXEL_TOTAL    (PIXEL_ECRAN+PIXEL_BEE+PIXEL_ALL_BAR)

#define PIXEL_ONE_BAR  (BAR_WIDTH*BAR_HEIGHT)




/* initialis‚ dans redraw_fenetre_offscreen() */

int16 view_iconified_x;	 /* pos x pour mode iconifi‚ */
int16 view_iconified_cx; /* pos x center (clic droit) */
int16 view_iconified_y;
int16 view_iconified_cy;





/* L'espace de travail pour la construction des frames */
/*SURFACE surface_offscreen;*/
MFDB    mfdb_offscreen;



/* MODE Offscreen VDI (normal) */
MFDB    mfdb_offscreen_vdi;
SURFACE surface_offscreen_vdi;





/* MODE Offscreen ST Ram */
SURFACE surface_offscreen_stram;
MFDB    mfdb_offscreen_stram;

SURFACE surface_fond_stram;
MFDB    mfdb_fond_stram;

SURFACE surface_bar_stram[NB_BAR];
MFDB    mfdb_bar_stram[NB_BAR];

SURFACE surface_bee_stram;
MFDB    mfdb_bee_stram;

SURFACE surface_bee_mask_stram;
MFDB    mfdb_bee_mask_stram;






/* MODE Offscreen TT Ram */
MFDB    mfdb_offscreen_ttram;
SURFACE surface_offscreen_ttram;

SURFACE surface_fond_ttram;
MFDB    mfdb_fond_ttram;

SURFACE surface_bar_ttram[NB_BAR];
MFDB    mfdb_bar_ttram[NB_BAR];

SURFACE surface_bee_ttram;
MFDB    mfdb_bee_ttram;

SURFACE surface_bee_mask_ttram;
MFDB    mfdb_bee_mask_ttram;






/* MODE Offscreen VRAM */
#define SPRITE_OFFSCREEN_WIDTH  (320)
#define SPRITE_OFFSCREEN_HEIGHT (200+200+153)
SURFACE surface_sprite_offscreen;
MFDB    mfdb_sprite_offscreen;


/* MODE Offscreen CT60 VRAM */
uint32   gb_adresse_buffer_ct60_vram=0;

MFDB    mfdb_offscreen_ct60_vram;
MFDB    mfdb_fond_ct60_vram;
MFDB    mfdb_bar_ct60_vram[NB_BAR];
MFDB    mfdb_bee_ct60_vram;
MFDB    mfdb_bee_mask_ct60_vram;


