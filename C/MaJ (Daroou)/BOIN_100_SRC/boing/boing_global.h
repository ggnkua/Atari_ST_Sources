/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 24/09/2023 * */
/* ***************************** */


#define FPS (25)
#define FPS_TIMER_NEXT_FRAME (8)   /* (200/FPS) */



/* version minimal de la LDG TGA_SA */
#define GLOBAL_TGA_SA_VERSION_NEEDED (0x0013)


/* barre info de boing */
uint32 global_charge_build_screen;
uint32 global_time_build_one_frame;


/* set_palette() define */
/* modification de la palette pour les reso 16 (et 256 ?) couleurs */
int16  global_utilise_palette=FALSE;
int16  global_palette_save=FALSE; /* flag pour la restauration de la palette */

#define PALETTE_NB_COULEUR (16)
int16  global_palette[PALETTE_NB_COULEUR][3];
#define PALETTE_SAVE     (1) /* save system palette */
#define PALETTE_INSTALL  (2) /* install app palette */
#define PALETTE_RESTORE  (3) /* restore system palette */


/* fenetre options */
int16  global_max_fps;
int16  global_force_mode_mono;

int16  global_affichage_mode; 
#define AFFICHAGE_MODE_MONO    (1)
#define AFFICHAGE_MODE_COULEUR (2)




/* ------------------------------------------------------------------------- */
/* Audio                                                                     */
/* ------------------------------------------------------------------------- */

/* Variable indiquant s'il y a une erreur sur la présence des fichiers Audio */
/* (init_boing -> check_fichier) TRUE si ok ou FALSE si un des fichiers est  */
/* absent */
int16  global_flag_audio_ok;

/* Contient la derniere erreur isssu de l'audio ou 0 si rien a signaler */
int16  global_flag_audio_error;

/* Son, actif (FALSE) ou mute (TRUE) */
int16  global_mute_sound;

/* adresse des buffers Malloc pour les sons */
uint32 global_adr_buffer_boing_gauche;
uint32 global_adr_buffer_boing_droite;
uint32 global_adr_buffer_boing_sol;

/* Structure sur les infos des sons */
s_MUSIQUE_PLAY  global_son_gauche;
s_MUSIQUE_PLAY  global_son_droite;
s_MUSIQUE_PLAY  global_son_sol;



/* -------------------------------------------- */
/* -                                          - */
/* -             Section Vid‚o                - */
/* -                                          - */
/* -------------------------------------------- */
#define SCREEN_WIDTH  (235)
#define SCREEN_HEIGHT (156)


#define VRT_MASQUE_MODE   (MD_TRANS)    /* 2 */
#define VRT_SPRITE_MODE   (MD_XOR)      /* 3 */
#define VRT_COPY_MODE     (MD_REPLACE)  /* 1 */
#define VRT_ERASE_MODE    (MD_ERASE)    /* 4 */

#define VRO_SPRITE_MODE   (S_OR_D)      /* 7 */
#define VRO_COPY_MODE     (S_ONLY)      /* 3 */


#define FCM_LISTE_RESTAURE_FOND_MAX (4)
#define FCM_LISTE_REFRESH_ECRAN_MAX (4)


/* -------------------------- */
/* memorisation format pixel  */
/* -------------------------- */
uint16 global_pixel_8bits       = POP_PIXEL_AUTO;
uint16 global_pixel_16bits      = POP_PIXEL_AUTO;
uint16 global_pixel_24bits      = POP_PIXEL_AUTO;
uint16 global_pixel_32bits      = POP_PIXEL_AUTO;
uint16 global_pixel_label_actif = POP_PIXEL_AUTO;
int16  global_save_pixel_xformat;


/* couleur des masques pour l'affichage des sprites */
/* init dans init_boing.c */
int16  couleur_mask_vrt[2];
int16  couleur_vrt_copy[2];
int16  couleur_ombre[2];


/* animation en pause (TRUE) ou non (FALSE) */
int16 global_animation_pause=FALSE;


/* memorise l'handle v_opnbm() pour le framebuffer */
int16  global_handleoffscreen_framebuffer=0;
/* etat checkbox VDI offscreen pour le framebuffer */
int16  global_use_VDI_offscreen_for_framebuffer=FALSE;


/* handle VDI pour les vrx_cpyfm() vers l'ecran       */
/* -------------------------------------------------- */
/* vaut l'handle VDI de l'application                 */
int16  global_vdihandle_ecran;


/* handle VDI pour les vrx_cpyfm() vers le framebuffer */
/* --------------------------------------------------- */
/* vaut soit l'handle VDI de l'application             */
/* soit l'handle v_opnbm() si disponible               */
int16  global_vdihandle_framebuffer;


/* D‚placement Y de la BALL   */
/* init dans init_animation.c */
int16   boing_ball_y[48]; 

#define BOING_BALL_Y_END    (41)  /* fin du cycle */
#define BOING_BALL_Y_BOING  (21)  /* idx quand la balle touche le sol (150) */

#define BALL_PAS_X        (2)
#define BALL_POS_X_MIN    (0)
#define BALL_POS_X_MAX    (SCREEN_WIDTH - BALL_POS_X_MIN - BOING_BALL_W)
#define BALL_LEFT         (1)
#define BALL_RIGHT        (2)



/* -------------------------------------------- */
/* -                                          - */
/* -             Section Animation            - */
/* -                                          - */
/* -------------------------------------------- */
#define NB_BOING_BALL  (7)
#define BOING_BALL_W   (70)
#define BOING_BALL_H   (60)
#define BOING_OMBRE_W  (47)
#define BOING_OMBRE_H  (60)

#define BOING_OMBRE_DECALAGE_X (BOING_BALL_W/2)
#define BOING_OMBRE_DECALAGE_Y (-2)



int16  idx_boing_ball=0;



GRECT  boing_ball_xywh;
GRECT  boing_ball_xywh_old;
int16  pxy_boing_ball[8];


SURFACE surface_boing_ball[NB_BOING_BALL];
SURFACE surface_boing_ball_mask[NB_BOING_BALL];
MFDB    mfdb_boing_ball[NB_BOING_BALL];
MFDB    mfdb_boing_ball_mask[NB_BOING_BALL];



GRECT  boing_ombre_xywh;
GRECT  boing_ombre_xywh_old;
int16  pxy_boing_ombre[8];


SURFACE surface_boing_ombre_mask;
MFDB    mfdb_boing_ombre_mask;



SURFACE surface_framebuffer;
MFDB    mfdb_framebuffer;

SURFACE surface_fond_ecran;
MFDB    mfdb_fond_ecran;



/* initialis‚ dans redraw_fenetre_boing() */
/* ne sert que sous MagiC                 */
int16 view_iconified_x;	 /* pos x pour mode iconifi‚ */
int16 view_iconified_cx; /* pos x center (clic droit) */
int16 view_iconified_y;
int16 view_iconified_cy;



/* pointeur de fonction pour les modes d'affichage mono ou couleur */
int32 (*init_surface)   ( void ) = NULL;
void  (*build_screen)   ( void ) = NULL;

