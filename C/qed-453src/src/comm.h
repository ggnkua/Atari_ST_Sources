#ifndef _qed_comm_h_
#define _qed_comm_h_

/*
 * comm.h : Diverses zur Kommunikation.
*/
extern char		*global_str1,
					*global_str2;
extern int		msgbuff[8]; 			/* Buffer, den send_msg verschickt */

extern bool		send_msg			(int id);
/*
 * Verschickt den globalen Messagebuffer.
 * msgbuff[1] und msgbuff[2] werden gesetzt (gl_apid bzw. 0)
*/

extern void 	send_clip_change	(void);
/*
 * Shell und andere Prozesse Åber geÑndertes Klemmbrett informieren.
*/

extern void		send_dhst			(char *filename);
/*
 * SMU 7.01 Document-History.
*/

extern void 	init_comm		(void);
/* Meldet alle protokolle an. */

extern void		term_comm		(void);
/* Melde alle Protokolle ab */

#endif
