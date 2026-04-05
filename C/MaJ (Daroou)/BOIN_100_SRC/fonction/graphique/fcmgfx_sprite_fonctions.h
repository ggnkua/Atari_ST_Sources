/* **[Fonction Graphique Sprite]****** */
/* *                                 * */
/* * 15/02/2024   MaJ    15/02/2024  * */
/* *********************************** */

/* a ameliorer un jour ;) */


/* ------------------------------------------------- */
/* Fonctions Graphique necessaire pour l'utilisation */
/* de sprite dans l'application                      */
/* ------------------------------------------------- */
#ifndef		__FCMGFX_SPRITE_FONCTIONS_H__
 #define	__FCMGFX_SPRITE_FONCTIONS_H__


#include	"../ldg/tga_sa_ldg.h"

#include "fcmgfx_sprite_prototypes.h"
#include "fcmgfx_sprite_defines.h"

#include "fcm_make_sprite.h"

#include "Fcm_create_surface.h"





#include "Fcm_charge_tga.c"
#include "Fcm_libere_tga.c"

#include "Fcm_create_surface.c"
#include "Fcm_free_surface.c"

#include "Fcm_make_mask.c"

#include "Fcm_make_sprite_opaque.c"
#include "Fcm_make_sprite_transparent.c"

#include "Fcm_make_sprite_transparent_mono.c"
#include "Fcm_make_sprite_opaque_mono.c"



#endif  /*   __FCMGFX_SPRITE_FONCTIONS_H__   */

