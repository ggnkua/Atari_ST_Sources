/* **[Pupul]******************** */
/* *                           * */
/* * 16/08/2014 MaJ 07/11/2023 * */
/* ***************************** */



#include  "../fonction/coeur/type_gcc.h"
#include  "../fonction/coeur/coeur_define.h"


#include  "../fonction/ldg/tga_sa_ldg.h"

#include  "../fonction/graphique/fcm_create_surface.h"






#define FPS  (25)
#define FPS_TIMER_NEXT_FRAME (8)   /* (200/FPS) */



 /* on utilise le cache d'image pour les sprites */
#define FCM_USE_IMAGE_CACHE (1)


/* pointeur de fonction pour les modes d'affichage mono ou couleur */
int32 (*init_surface)( void )  = NULL;
void  (*build_screen)( void )  = NULL;



/* version minimal de la LDG 'TGA_SA.LDG' */
#define GLOBAL_TGA_SA_VERSION_NEEDED (0x0013)


/* pour eviter de redemmarer en boucle infini, si plus assez de RAM en cas de redemarrage */
int16  global_nb_redemarrage_succesif;


/* variables pour la barre info de fenetre de Nyancat */
uint32 global_charge_build_screen;
uint32 global_charge_build_frame;
int16  global_max_fps;

/* modification de la palette pour les resolution 16 couleurs */
int16  global_utilise_palette=FALSE;
int16  global_palette_save=FALSE; /* flag pour la restauration de la palette (exit_pupul() )*/
#define PALETTE_NB_COULEUR (16)
int16  global_palette[PALETTE_NB_COULEUR][3];
#define PALETTE_SAVE     (1) /* save system palette */
#define PALETTE_INSTALL  (2) /* install app palette */
#define PALETTE_RESTORE  (3) /* restore system palette */

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
/* -             Section Audio                - */
/* -------------------------------------------- */


int16  global_mute_sound; 

/* contient la derniere erreur isssu de l'audio ou 0 si rien a signaler */
int16  flag_audio_error;



int16  global_flag_audio_ok = TRUE;
int16  global_flag_audio_error;



uint32 adr_buffer_MOD = 0;

#define MODLDG_UPDATE_POLLING (POPUP_MAJ_POLL)  /* RSC -> POPUP_MODPOLLING */
#define MODLDG_UPDATE_TIMERA  (POPUP_MAJ_TIMERA)
#define MODLDG_UPDATE_MFPI7   (POPUP_MAJ_MFPI7)
#define MODLDG_UPDATE_GSXB    (POPUP_MAJ_GSXB)

/* Choix de la methode de mise a jour de MOD LDG par defaut */
uint16 global_mod_ldg_update = MODLDG_UPDATE_POLLING;

#define MODLDG_FREQ_12KHZ (POPUP_FREQ_12KHZ)  /* RSC -> POPUP_MOD_FREQ */
#define MODLDG_FREQ_25KHZ (POPUP_FREQ_25KHZ)
#define MODLDG_FREQ_50KHZ (POPUP_FREQ_50KHZ)

/* Choix de la frequence de restitution de MOD LDG par defaut */
uint16 global_mod_ldg_frequence = MODLDG_FREQ_12KHZ;












/* -------------------------------------------- */
/* -             Section Vid‚o                - */
/* -------------------------------------------- */

#define SCREEN_WIDTH  (320)
#define SCREEN_HEIGHT (200+26)



#define VRT_MASQUE_MODE   (MD_TRANS)    /* 2 */
#define VRT_SPRITE_MODE   (MD_XOR)      /* 3 */
#define VRT_COPY_MODE     (MD_REPLACE)  /* 1 */
#define VRT_ERASE_MODE    (MD_ERASE)    /* 4 */

#define VRO_SPRITE_MODE   (S_OR_D)      /* 7 */
#define VRO_COPY_MODE     (S_ONLY)      /* 3 */


/* couleur des masques pour l'affichage des sprites */
int16  couleur_mask_vrt[2];

int16  couleur_vrt_copy[2];







#define SCROLLTEXT_Y  (200)




typedef struct {
	uint16 index_coord;
	uint16 sprite_forme;    /* forme animation actuel */
	uint16 sprite_frame;    /* nombre de frame avant le changement de forme */
	uint16 morph_mode;      /* sens de la transformation  */
	uint16 next_frame;      /* nombre de frame avant la prochaine transformation  */
	uint16 next_forme;      /* forme … prendre (morph Ball, morphDemon) */
} s_animation;

s_animation  animation[7];



typedef struct {
	uint16 logo_state;    /* logo affich‚ ou pas */
	 int16 logo_color;    /* index couleur niveau de gris */
	uint16 logo_frame;    /* nombre de frame avant le changement de couleur */
	uint16 morph_mode;    /* sens de la transformation fadein / fadeout    */
	uint16 next_frame;    /* nombre de frame avant la prochaine apparition */
	uint16 next_forme;    /* forme … prendre, logo renaissance ou Equinox */
} s_animlogo;

s_animlogo   animation_logo;



typedef struct {
	int16 x;
	int16 y;

} s_coord;

#define DEMON_MAX_POINT  (7400)
s_coord demon_xy[DEMON_MAX_POINT];
uint16  demon_xy_nbpoint=DEMON_MAX_POINT;



#define MAX_GRAY_INDEX (32)
#define MAX_GRAY_COLOR (1000)   /* 0-1000 (black-white)*/
int16   gray_index[MAX_GRAY_INDEX];
uint16  gray_nbindex;





/* Parametre pour l'animation des sprites d‚mons */
/* --------------------------------------------- */
#define  FORM_BALL       (1)
#define  FORM_DEMON_IN   (2)
#define  FORM_DEMON_OUT  (3)
#define  BALL_TO_DEMON   (4)
#define  DEMON_TO_BALL   (5)

#define SPRITE_ECART_FRAME      (18)  /* distance en frame entre les sprites */
#define SPRITE_MORPHING_FRAME	(500) /* nb frame avant changement de forme */
#define SPRITE_DECALAGE_FRAME	(6)   /* decalage d'animation entre sprite */
#define SPRITE_SWITCH_ANIME	    (2/*8*/)   /* duree animation demon en frame */



/* Parametre pour l'animation des sprite logos */
/* ------------------------------------------- */

/* Logo state */
#define  LOGO_OFF         (1)
#define  LOGO_EQUINOX     (2)
#define  LOGO_RENAISSANCE (3)

/* Logo Morph Mode */
#define  LOGO_FADEIN   (1)
#define  LOGO_FADEOUT  (2)
#define  LOGO_FADEZERO (3)

#define  LOGO_COLORSPEED (1)       /* vitesse fondu en frame */
#define  LOGO_COLORPAUSE (120)     /* temps d'affichage du logo en frame */
#define  LOGO_ECART_VIEW (200)     /* delai entre chaque apparition en frame */


/* Position logo Equinox */
#define  LOGO_EQUINOX_X     (58)
#define  LOGO_EQUINOX_Y     (144)
#define  LOGO_EQUINOX_W     (202)
#define  LOGO_EQUINOX_H     (23)

/* Position logo Renaissance */
#define  LOGO_RENAISSANCE_X (88)
#define  LOGO_RENAISSANCE_Y (74)
#define  LOGO_RENAISSANCE_W (144)
#define  LOGO_RENAISSANCE_H (99)





/* FrameBuffer */
SURFACE surface_framebuffer;
MFDB    mfdb_framebuffer;


 /* image de fond */
SURFACE surface_fond_ecran;
MFDB    mfdb_fond_ecran;
int16   pxy_fond_ecran[8];


#define SPRITE_DEMON1    (0)
#define SPRITE_DEMON2    (1)
#define SPRITE_DEMON3    (2)
#define SPRITE_MORPH1    (3)
#define SPRITE_MORPH2    (4)
#define SPRITE_BALL1     (5)
#define NB_SPRITE_DEMONS (6)
SURFACE surface_demons_sprite[NB_SPRITE_DEMONS];
SURFACE surface_demons_mask[NB_SPRITE_DEMONS];
MFDB    mfdb_demons_sprite[NB_SPRITE_DEMONS];
MFDB    mfdb_demons_mask[NB_SPRITE_DEMONS];
int16   pxy_demons[8];


SURFACE surface_logo_equinox_mask;
MFDB    mfdb_logo_equinox_mask;
int16   pxy_logo_equinox[8];


SURFACE surface_logo_renaissance_mask;
MFDB    mfdb_logo_renaissance_mask;
int16   pxy_logo_renaissance[8];


#define NB_DAMIER  (18)
SURFACE surface_damier[NB_DAMIER];
MFDB    mfdb_damier[NB_DAMIER];
int16   pxy_damier[8];


SURFACE surface_fonte_texte;
SURFACE surface_fonte_texte_mask;
MFDB    mfdb_fonte_texte;
MFDB    mfdb_fonte_texte_mask;
int16   pxy_texte[8];


SURFACE surface_fond_scrolltext;
MFDB    mfdb_fond_scrolltext;
int16   pxy_fond_scrolltext[8];


SURFACE surface_barre_scrolltext;
MFDB    mfdb_barre_scrolltext;
int16   pxy_barre_scrolltext[8];

int16 scrolltext_posx=0;

int16 logo_couleur[2];

/* initialis‚ dans redraw_fenetre_pupul() */
int16 view_iconified_x;	 /* pos x pour mode iconifi‚ */
int16 view_iconified_cx; /* pos x center (clic droit) */
int16 view_iconified_y;
int16 view_iconified_cy;




char   scrolltext_message[]=
"          RENAISSANCE PRESENTE PUPUL,"
" UNE CONVERSION GEM D'UNE INTRO ATARI ST DU GROUPE EQUINOX"
" (WWW.EQUINOX.PLANET-D.NET)."
" CREDIT: KRUEGER (CODE ATARI ST) SMILEY (GRAPHIXX) JEROEN TEL - FREDERIC HAHN (MUSIXX) PETER HANNING OF MUSHROOM STUDIOS - GRIFF OF ELECTRONIC IMAGES - THOMAS HUTH (MOD REPLAY ROUTINE)."
" REMERCIEMENT SPECIAL: PIERRE TON-THAT "
" REMERCIEMENT: TEAM EMUTOS, ARANYM, HATARI, FIREBEE, FREEMINT, VAMPIRE "
" REMERCIEMENT: "
" DAN ACKERMAN,"
" FREDI ASCHWANDEN,"
" CLAUDE ATTARD,"
" DANIEL AUGSBURGER,"
" PASCAL BARLIER,"
" HARALD BECKER,"
" SVEN - WILFRIED BEHNE,"
" ARNAUD BERCEGEAY,"
" DOMINIQUE BEREZIAT,"
" JOHN BROCHU,"
" ROGER BURROWS,"
" MARTIN BYTTEBIER,"
" CHRISTELLE CANTREL,"
" ALEXANDER CLAUS,"
" COOPER,"
" RODOLF CZUBA,"
" GREGOR DUCHALSKI,"
" MATHIEU DEMANGE,"
" MARTIN ELSASSER,"
" ANDERS ERIKSON,"
" PASCAL FELLERICH,"
" CHRISTIAN FELSCH,"
" MARKUS FICHTENBAUER,"
" DAVID GALVEZ,"
" JEROME GINESTET,"
" STEPHAN GERLE,"
" MARTIN GRIFFITHS,"
" GT TURBO,"
" PETER HANNING,"
" THOMAS HUTH,"
" XAVIER JOUBERT,"
" GERARD KANY,"
" JAN - TOMAS KRIVANEK,"
" ANDREAS KROMKE,"
" MIRO KROPACEK,"
" OLIVIER LANDEMARRE,"
" ALAIN LARRODE,"
" MANFRED LIPPERT,"
" JEAN LUSETTI,"
" PATRICE MANDIN,"
" RAINER MANNIGEL,"
" GODEFROY DE MAUPEOU,"
" JOHN MCLOUD,"
" MEGAMODESTE,"
" OLAF MEISIEK,"
" DIDIER MEQUIGNON,"
" MARKUS FROSCHLE,"
" THOMAS MUCH,"
" CHRISTIAN NIEBER,"
" LONNY PURSELL,"
" LAURENZ PRUSSNER,"
" TOM QUELLENBERG,"
" RAGNAR,"
" ERIC REBOUX,"
" JULIAN RESCHKE,"
" VINCENT RIVIERE,"
" HENK ROBBERS,"
" LARS SCHMIDBAUER,"
" MICHAEL SCHWINGEN,"
" UWE SEIMET,"
" ROLAND SEVIN,"
" PETER SCHNEIDER,"
" SHOGGOTH,"
" ODD SKANCKE,"
" EERO TAMMINEN,"
" TEMPLETON,"
" GUILLAUME TELLO,"
" OTTO THORSTEN,"
" EUER VOLKER,"
" MATHIAS WITTAU,"
" XERUS,"
" CHRISTIAN ZIETZ,"
" A TOUS CEUX QUE J'OUBLI ET QUI PARTAGE LA MEME PASSION...          ";


uint16 size_scrolltext_message=0;


