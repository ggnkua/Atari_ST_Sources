/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 25/08/2025 * */
/* ***************************** */


#define FPS    (25)
#define FPS_TIMER_NEXT_FRAME (8)   /* (200/FPS) */



 /* version minimal de la LDG 'TGA_SA.LDG' */
#define GLOBAL_TGA_SA_VERSION_NEEDED (0x0013)


/* variables pour la barre info de fenetre Badgers */
uint32 global_charge_build_screen;
uint32 global_time_build_one_frame;


/* set_palette() define */
/* modification de la palette pour les resolution 16 couleurs */
int16  global_utilise_palette = FALSE;
int16  global_palette_save    = FALSE;     /* flag pour la restauration de la palette */

#define PALETTE_NB_COULEUR (16)
int16   global_palette[PALETTE_NB_COULEUR][3];
#define PALETTE_SAVE     (1) /* save system palette */
#define PALETTE_INSTALL  (2) /* install app palette */
#define PALETTE_RESTORE  (3) /* restore system palette */


/* fenetre options */
int16  global_max_fps;
int16  global_force_mode_mono;

int16  global_affichage_mode; 
#define AFFICHAGE_MODE_MONO    (1)
#define AFFICHAGE_MODE_COULEUR (2)



/* animation en pause (TRUE) ou non (FALSE) */
int16 global_animation_pause=FALSE;



/* -------------------------- */
/* memorisation format pixel  */
/* -------------------------- */
/* valeur par défaut si fichier de config absent */
uint16 global_pixel_8bits       = POP_PIXEL_AUTO;
uint16 global_pixel_16bits      = POP_PIXEL_AUTO;
uint16 global_pixel_24bits      = POP_PIXEL_AUTO;
uint16 global_pixel_32bits      = POP_PIXEL_AUTO;
uint16 global_pixel_label_actif = POP_PIXEL_AUTO;
int16  global_save_pixel_xformat;






/* memorise l'handle v_opnbm() pour le framebuffer */
int16  global_handleoffscreen_framebuffer=0;
/* etat checkbox VDI offscreen pour le framebuffer */
int16  global_use_VDI_offscreen_for_framebuffer=FALSE;


/* handle VDI pour les vrx_cpyfm() vers l'ecran       */
/* -------------------------------------------------- */
/* global_vdihandle_ecran=vdihandle (coeur) */
int16  global_vdihandle_ecran;


/* handle VDI pour les vrx_cpyfm() vers le framebuffer  */
/* ---------------------------------------------------- */
/*    global_vdihandle_framebuffer = global_vdihandle_ecran = vdihandle (coeur)     */
/* ou global_vdihandle_framebuffer = global_handleoffscreen_framebuffer (v_opnbm()) */
int16  global_vdihandle_framebuffer;











/* -------------------------------------------- */
/* -                                          - */
/* -             Section Vid‚o                - */
/* -                                          - */
/* -------------------------------------------- */

#define SCREEN_WIDTH  (496)
#define SCREEN_HEIGHT (360)


#define VRT_MASQUE_MODE   (MD_TRANS)    /* 2 */
#define VRT_SPRITE_MODE   (MD_XOR)      /* 3 */
#define VRT_COPY_MODE     (MD_REPLACE)  /* 1 */
#define VRT_ERASE_MODE    (MD_ERASE)    /* 4 */

#define VRO_SPRITE_MODE   (S_OR_D)      /* 7 */
#define VRO_COPY_MODE     (S_ONLY)      /* 3 */


#define FCM_LISTE_RESTAURE_FOND_MAX (10)
#define FCM_LISTE_REFRESH_ECRAN_MAX (10)


/* couleur des masques pour l'affichage des sprites */
int16  couleur_mask_vrt[2];

int16  couleur_vrt_copy[2];


/* pointeur de fonction pour les modes d'affichage mono ou couleur */
int32 (*init_surface)( void )  = NULL;

/* pointeur de fonction sur l'‚cran … construire */
void (*pf_build_screen)       (void) = NULL;

void (*build_screen_badgers)  (void) = NULL;
void (*build_screen_mushroom) (void) = NULL;
void (*build_screen_argh)     (void) = NULL;
void (*build_screen_snake)    (void) = NULL;






/* dimension de l'‚cran pour les vr?_cpyfm() */
int16   pxy_screen[8]={	0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1,
						0,0,SCREEN_WIDTH-1,SCREEN_HEIGHT-1  };



/* Le framebuffer pour la construction des frames */
/* initialis‚ dans init_surface.c                 */
SURFACE surface_framebuffer;
MFDB    mfdb_framebuffer;





/* **************************** */
/* mode iconifi‚                */
/* **************************** */

/* Coordonn‚es de la zone affich‚e  */
int16 view_iconified_x;
int16 view_iconified_cx;
int16 view_iconified_y;
int16 view_iconified_cy;






/* -------------------------------------------- */
/* -                                          - */
/* -             Section Animation            - */
/* -                                          - */
/* -------------------------------------------- */

/* flag indiquant si c'est le debut de l'animation */
/* pour la construction de l'‚cran                 */
int16   build_screen_restart=TRUE;

/* d‚fini dans check_sequence_dma.c */
int16   index_sequence_animation=0;
int16   index_sequence_dma=0;


#define NB_SEQUENCE_ANIMATION (12)

int32   position_sequence_dma[NB_SEQUENCE_ANIMATION];

int32   position_sequence_dma_offset[NB_SEQUENCE_ANIMATION]=
		{
			0,			/* badgers */
			105000,		/* mushroom in  */
			125000,		/* mushroom out */
			145000,		/* badgers */
			250000,		/* mushroom in  */
			270000,		/* mushroom out */
			290000,		/* badgers */
			405000,		/* mushroom in  */
			425000,		/* mushroom out */
			445000,		/* badgers */
			550000,		/* Snake   */
			727000
		};








/* ----------------------------------- */
/*              Prairie                */
/* ----------------------------------- */
SURFACE surface_prairie;
MFDB    mfdb_prairie;



/* ----------------------------------- */
/*               Badgers               */
/* ----------------------------------- */
#define NB_BADGERS      (12)
#define NB_FORME_BAGERS (4)

#define NB_BADGERS_ANIMATION (10)
int16   badgers_animation[NB_BADGERS_ANIMATION]={0,1,2,3,3,3,3,2,1,0};

int16   pxy_badgers[NB_BADGERS][8];
int16   index_badgers[NB_BADGERS];

SURFACE surface_badgers     [NB_BADGERS][NB_FORME_BAGERS];
SURFACE surface_badgers_mask[NB_BADGERS][NB_FORME_BAGERS];
MFDB    mfdb_badgers        [NB_BADGERS][NB_FORME_BAGERS];
MFDB    mfdb_badgers_mask   [NB_BADGERS][NB_FORME_BAGERS];



/* ----------------------------------- */
/*              Mushroom               */
/* ----------------------------------- */
#define NB_MUSHROOM  (2)
#define MUSHROOM_IN  (0)
#define MUSHROOM_OUT (1)

SURFACE surface_mushroom[NB_MUSHROOM];
MFDB    mfdb_mushroom   [NB_MUSHROOM];



/* ----------------------------------- */
/*              Arghhhhh               */
/* ----------------------------------- */
#define NB_ARGH      (7)

SURFACE surface_argh[NB_ARGH];
MFDB    mfdb_argh   [NB_ARGH];



/* ----------------------------------- */
/*              Desert                 */
/* ----------------------------------- */
SURFACE surface_desert;
MFDB    mfdb_desert;



/* ----------------------------------- */
/*              Soleil                 */
/* ----------------------------------- */
#define SOLEIL_X     (273)
#define SOLEIL_Y     (12)
#define SOLEIL_W     (48)
#define SOLEIL_H     (50)

int16  pxy_soleil[8];
GRECT  soleil_xywh;
GRECT  soleil_xywh_old;

SURFACE surface_soleil;
MFDB    mfdb_soleil;



/* ----------------------------------- */
/*              Nuage                */
/* ----------------------------------- */
#define NUAGE_X     (404)
#define NUAGE_Y     (49)
#define NUAGE_W     (144)
#define NUAGE_H     (35)

int16  pxy_nuage[8];
GRECT  nuage_xywh;
GRECT  nuage_xywh_old;

SURFACE surface_nuage;
MFDB    mfdb_nuage;



/* ----------------------------------- */
/*             Horizon1                */
/* ----------------------------------- */
#define HORIZON1_X     (0)
#define HORIZON1_Y     (128-14+14-1)
#define HORIZON1_W     (496)
#define HORIZON1_H     (28)

int16  pxy_horizon1[8];
GRECT  horizon1_xywh;
GRECT  horizon1_xywh_old;

SURFACE surface_horizon1;
MFDB    mfdb_horizon1;



/* ----------------------------------- */
/*             Horizon2                */
/* ----------------------------------- */
#define HORIZON2_X     (0)
#define HORIZON2_Y     (156-8-14-1)
#define HORIZON2_W     (496)
#define HORIZON2_H     (36)

int16  pxy_horizon2[8];
GRECT  horizon2_xywh;
GRECT  horizon2_xywh_old;

SURFACE surface_horizon2;
MFDB    mfdb_horizon2;
SURFACE surface_horizon2_mask;
MFDB    mfdb_horizon2_mask;



/* ----------------------------------- */
/*               Cactus                */
/* ----------------------------------- */
#define CACTUS_X     (78)
#define CACTUS_Y     (HORIZON2_Y+10+12-93)
#define CACTUS_W     (64)
#define CACTUS_H     (93)

int16  pxy_cactus[8];
GRECT  cactus_xywh;
GRECT  cactus_xywh_old;

SURFACE surface_cactus;
MFDB    mfdb_cactus;
SURFACE surface_cactus_mask;
MFDB    mfdb_cactus_mask;



/* ----------------------------------- */
/*               Herbe 1               */
/* ----------------------------------- */
#define HERBE1_X     (57)
#define HERBE1_Y     (SCREEN_HEIGHT-207)
#define HERBE1_W     (48)
#define HERBE1_H     (207)

int16  pxy_herbe1[8];
GRECT  herbe1_xywh;
GRECT  herbe1_xywh_old;

SURFACE surface_herbe1;
MFDB    mfdb_herbe1;
SURFACE surface_herbe1_mask;
MFDB    mfdb_herbe1_mask;



/* ----------------------------------- */
/*               Herbe 2               */
/* ----------------------------------- */
#define HERBE2_X     (341)
#define HERBE2_Y     (SCREEN_HEIGHT-192)
#define HERBE2_W     (48)
#define HERBE2_H     (192)

int16  pxy_herbe2[8];
GRECT  herbe2_xywh;
GRECT  herbe2_xywh_old;

SURFACE surface_herbe2;
MFDB    mfdb_herbe2;
SURFACE surface_herbe2_mask;
MFDB    mfdb_herbe2_mask;



/* ----------------------------------- */
/*                Snake                */
/* ----------------------------------- */
#define NB_SNAKE    (4)
#define SNAKE_X     (-336)
#define SNAKE_Y     (290-224-28)
#define SNAKE_W     (336)
#define SNAKE_H     (229)

int16  pxy_snake[8];
GRECT  snake_xywh;
GRECT  snake_xywh_old;

SURFACE surface_snake     [NB_SNAKE];
MFDB    mfdb_snake        [NB_SNAKE];
SURFACE surface_snake_mask[NB_SNAKE];
MFDB    mfdb_snake_mask   [NB_SNAKE];








/* -------------------------------------------- */
/* -                                          - */
/* -             Section Audio                - */
/* -                                          - */
/* -------------------------------------------- */


int16  global_mute_sound;

/* ----------------------- */
/* Audio, musique badgers  */
/* ----------------------- */
#define FILE_BADGERS_AVR        "BADGERS.AVR"
#define BADGERS_SOUND_SIZE   (727362)

/* Reste a TRUE si l'init de la partie Audio est reussi */
/* chargement AVR, DMA audio compatible ...             */
int16  global_audio_ok = TRUE;

/* adresse du buffer RAM pour le fichier AVR */
uint32 global_adr_buffer_avr=0L;


