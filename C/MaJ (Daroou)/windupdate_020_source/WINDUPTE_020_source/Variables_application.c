/* **[WindUpdate]*************** */
/* *                           * */
/* * 20/12/2003 MaJ 29/01/2015 * */
/* ***************************** */


#include	"fonction/coeur/type_gcc.h"
#include	"fonction/coeur/coeur_define.c"



int16 bar_position  = BAR_POSITION_MINI;
int16 bar_largeur   = BAR_LARGEUR_MINI;
int16 bar_direction = BAR_MOVE_LTOR;


int32 redraw_demande                    = 0;
int32 redraw_effectue                   = 0;
int32 redraw_esquive                    = 0;
int32 redraw_effectue_consecutif        = 0;
int32 redraw_esquive_consecutif         = 0;
int32 redraw_effectue_consecutif_record = 0;
int32 redraw_esquive_consecutif_record  = 0;


int32 redraw_mode_flag = 0;  /* Flag pour les consecutifs effectu‚s / esquiv‚s */


int16 redraw_skip_compteur = WU_SKIP_COMPTEUR;	/* temps r‚el ou non   */
int16 mask_windupdate      = 0;					/* mode pour la barre  */
int16 mask_noblock_nombre  = 0;					/* Mode pour les stats */

