/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 25/08/2025 * */
/* ***************************** */


#define FPS  (15)
#define FPS_TIMER_NEXT_FRAME (14)   /* (200/FPS) */



/* version minimal de la LDG 'TGA_SA.LDG' */
#define GLOBAL_TGA_SA_VERSION_NEEDED (0x0013)


/* barre info de Nyancat */
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

/* Son, actif (FALSE) ou mute (TRUE) */
int16  global_mute_sound;

/* adresse du buffer RAM pour nyancat.avr */
uint32 global_adr_buffer_AVR;

#define SOUND_FREQUENCE  (12500)
#define SOUND_BIT_SAMPLE (8)

s_MUSIQUE_PLAY  global_musique;

/* Musique en RAM ? */
int16  global_flag_audio_musique_charger;

/* contient la derniere erreur isssu de l'audio ou 0 si rien a signaler */
int16  global_flag_audio_error;









/* **************************** */
/* mode iconifi‚                */
/* **************************** */

/* Coordonn‚es de la zone affich‚e          */
/* initialis‚ dans redraw_fenetre_nyancat.c */
/* Sous MagiC (milan) les clic sur la fenetre iconifie */
/* sont transmis, le clic droit-glisser permet donc de */
/* modifier la zone visible */
int16 view_iconified_x;
int16 view_iconified_cx;
int16 view_iconified_y;
int16 view_iconified_cy;





/* -------------------------------------------- */
/* -                                          - */
/* -             Section Vid‚o                - */
/* -                                          - */
/* -------------------------------------------- */
#define SCREEN_WIDTH  (320-32)
#define SCREEN_HEIGHT (156)


#define VRT_MASQUE_MODE   (MD_TRANS)    /* 2 */
#define VRT_SPRITE_MODE   (MD_XOR)      /* 3 */
#define VRT_COPY_MODE     (MD_REPLACE)  /* 1 */
#define VRT_ERASE_MODE    (MD_ERASE)    /* 4 */

#define VRO_SPRITE_MODE   (S_OR_D)      /* 7 */
#define VRO_COPY_MODE     (S_ONLY)      /* 3 */


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


/* couleur des masques pour l'affichage des sprites */
int16  couleur_mask_vrt[2];
int16  couleur_vrt_copy[2];
int16  couleur_etoile[2];


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
int16  global_vdihandle_framebuffer = 0;



 /* image de fond */
SURFACE surface_fond_ecran;
MFDB    mfdb_fond_ecran;
int16   pxy_fond[8];

/* FrameBuffer */
SURFACE surface_framebuffer;
MFDB    mfdb_framebuffer;


/* -------------------------------------------- */
/* -                                          - */
/* -             Section Animation            - */
/* -                                          - */
/* -------------------------------------------- */
#define ARCENCIEL_X   (0)
#define ARCENCIEL_Y   (34)
#define ARCENCIEL_W   (118)
#define ARCENCIEL_H   (76)

#define NYANCAT_X   (70)
#define NYANCAT_Y   (ARCENCIEL_Y - 4)
#define NYANCAT_W   (144)
#define NYANCAT_H   (84)



#define NB_STAR     (6)

SURFACE surface_star_mask[NB_STAR];
MFDB    mfdb_star_mask[NB_STAR];



#define ARCENCIEL_UP			(0)
#define ARCENCIEL_DOWN			(1)

SURFACE surface_arcenciel[2];
SURFACE surface_arcenciel_mask[2];
MFDB    mfdb_arcenciel[2];
MFDB    mfdb_arcenciel_mask[2];
int16   pxy_arcenciel[8];


#define NB_NYANCAT  (6)

SURFACE surface_nyancat_sprite[NB_NYANCAT];
SURFACE surface_nyancat_mask[NB_NYANCAT];
MFDB    mfdb_nyancat_sprite[NB_NYANCAT];
MFDB    mfdb_nyancat_mask[NB_NYANCAT];
int16   pxy_nyancat[8];


SURFACE surface_font;
SURFACE surface_mask_font;
MFDB    mfdb_font;
MFDB    mfdb_mask_font;



#define LETTRE_SPEED   (8)  /*  deplacement horizontale, pas de 1, 2, 4 ou 8 */
#define LETTRE_WIDTH   (32)
#define LETTRE_HEIGHT  (31)

int16 pxy_texte[8];

char   scrolltext_message[]="           RENAISSANCE PRESENTE UNE CONVERSION GEM DE NYANCAT (HTTP://KNOWYOURMEME.COM/MEMES/NYAN-CAT-POP-TART-CAT). CREDIT: CHRIS TORRES: POP TART CAT ANIMATION, DANIWELL-P: NYANYANYANYANYANYANYA! VOCALOID SONG, SARAJOON: NYANCAT VIDEO ANIMATION, XERUS/TEMPLETON: ATARI SOUND CONVERSION, DANIEL GULDKRANS: BITMAP FONT.           ";
uint16 size_scrolltext_message;




#define STAR_WIDTH   (32)
#define STAR_HEIGHT  (28)

int16 formstar[6][13]={
	{ 1,2,3,4,5,0,1,2,3,4,5,0 },
	{ 3,4,5,0,1,2,3,4,5,0,1,2 },
	{ 1,2,3,4,5,0,1,2,3,4,5,0 },
	{ 5,0,1,2,3,3,4,5,0,2,3,4 },
	{ 3,0,5,4,3,2,1,0,5,4,3,4 },
	{ 2,3,4,5,0,1,2,3,4,5,0,1 }
};

int16 coord_y[6]={ -10,20,50,80,106,126 };

int16 coord_star[6][13]={
	{174,147,112, 70, 31,  4,-14,999,281,256,220,193},
	{278,256,220,192,174,147,112, 70, 31,  4,-15,999},
	{-10,999,276,250,224,198,179,152,116, 77, 36,  8},
	{ 36, 10,-10,999,999,277,250,224,173,140,105, 66},
	{999,270,246,215,174,139,111, 94, 67, 31, -5,-18},
	{156,120, 81, 39, 12, -5,999,276,254,228,202,184}
};


/* pointeur de fonction pour les modes d'affichage mono ou couleur */
int32 (*init_surface)( void )  = NULL;
void  (*build_screen)( void )  = NULL;

