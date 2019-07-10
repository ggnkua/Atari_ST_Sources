#ifndef _qed_dd_h_
#define _qed_dd_h_

/*
 * Kommunikation Åber Drag&Drop.
*/
/* 
 * Die folgenden Konstanten werden benutzt, wenn von Auûen etwas auf
 * ein Fenster von qed gezogen wird und werden bei Icon_drag als 
 * src_icon Åbergeben.
 */
#define DRAGDROP_FILE	0xD01		/* Ein Dateiname in drag_filename */
#define DRAGDROP_PATH	0xD02		/* Ein Pfad in drag_filename */
#define DRAGDROP_DATA	0xD03		/* Daten in drag_data */

/*
 * Variablen fÅr Drag-Operationen
*/
extern PATH	drag_filename;
extern char	*drag_data;
extern long	drag_data_size;


extern void	handle_dd	(int *msg);
/*
 * Wickelt Empfang ab.
*/

extern void	handle_avdd(int win_handle, int kstate, char *arg);
/*
 * Wickelt D&D ab, wenn glob. Fensterwechsel (VA_DRAGACCWIND) aktiv.
*/

/*
extern void	send_dd	(int wh, MOUSEDATA *mouse, int data_type);
*/

#endif
