
#ifndef ___Fcm_musique_H___
#define ___Fcm_musique_H___


#include "../coeur/type_GCC.h"


/* definition structure pour jouer un son */
#include "s_MUSIQUE_PLAY.h"





int32 Fcm_musique_play( s_MUSIQUE_PLAY *musique );
void  Fcm_musique_pause( s_MUSIQUE_PLAY *musique );
void  Fcm_musique_stop( s_MUSIQUE_PLAY *musique );





#endif  /* ___Fcm_musique_H___ */

