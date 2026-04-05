
#ifndef ___Fcm_musique_H___
#define ___Fcm_musique_H___


#include "../coeur/type_GCC.h"

typedef struct {
	uint32 adresse_start;
	uint32 adresse_end;
	uint32 adresse_loop_start;
	uint32 adresse_loop_end;
	uint32 adresse_pause;
	int16  status;          /* PLAY / PAUSE / STOP      */
	int16  play_mode;       /* lecture en boucle ou non */
	int16  frequence;
	int16  stereo;
	int16  signe;
	int16  rez_bit;         /* 8bits / 16bits */
} s_MUSIQUE_PLAY;



int32 Fcm_musique_play( s_MUSIQUE_PLAY *musique );
void  Fcm_musique_pause( s_MUSIQUE_PLAY *musique );
void  Fcm_musique_stop( s_MUSIQUE_PLAY *musique );



/* status */
#define FCM_MUSIQUE_STATUS_STOP    (0)
#define FCM_MUSIQUE_STATUS_PLAY    (1)
#define FCM_MUSIQUE_STATUS_PAUSE   (2)

#define FCM_MUSIQUE_PLAYMODE_STOP  (0)
#define FCM_MUSIQUE_PLAYMODE_ONE   (SB_PLA_ENA)
#define FCM_MUSIQUE_PLAYMODE_LOOP  ((SB_PLA_ENA)+(SB_PLA_RPT))

#define FCM_MUSIQUE_MONO           (0)
#define FCM_MUSIQUE_STEREO         (1)

#define FCM_MUSIQUE_UNSIGNED       (0)
#define FCM_MUSIQUE_SIGNED         (1)




#endif  /* ___Fcm_musique_H___ */

