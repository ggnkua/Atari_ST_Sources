#ifndef _qed_av_h_
#define _qed_av_h_

/*
 * Kommunikation mit dem AV-Server.
*/
#include "vaproto.h"


extern int	av_shell_id,		/* ID des Desktops */
				av_shell_status;	/* Welche VA_* kann der Desktop */


extern bool	send_avkey			(int ks, int kr);
/*
 * Schickt Tastendruck an AV-Server.
*/

extern void	send_avdrag			(int wh, int m_x, int m_y, int kstate, int data_type);
/*
 * Schickt AV_DRAG_TO_WIN.
*/

extern int check_avobj			(int x, int y);
/*
 * Ermittelt, was an <x,y> auf dem AV-Desktop liegt.
*/

extern void	send_avwinopen		(int handle);
extern void	send_avwinclose	(int handle);
/*
 * Fenster auf bzw. zu.
*/

extern bool	call_help			(char *str);
/*
 * Schickt ein AC_HELP an das angemeldete Hilfe-ACC.
*/

extern bool	call_hyp				(char *data);
/*
 * Schickt data an ST-Guide.
*/

extern void	handle_av			(int msg[]);
/*
 * Verabeitet Messages vom Server.
*/

extern void init_av				(void);
extern void term_av				(void);

#endif
