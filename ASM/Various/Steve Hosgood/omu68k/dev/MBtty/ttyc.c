/******************************************************************************
 *	TTY handler	Minor minor device switch	T.Barnaby 6/6/85
 ******************************************************************************
 */

# include <sgtty.h>
# include "tty.h"

extern char o_acia(), _pchar(), _gchar(), s_acia(), i_txint();

/* TTY device driver switch */

/* Entries are :-
 *	setfnc()	Sets up minor device initialises interupts etc
 *	wchar()		Ouputs a character to device waits till ready
 *	rchar()		Gets a character from the device when ready
 *	status()	Returns status of device (WRDY, RRDY)
 *	m_mdev		Minor minor device number
 *	type		Interupt driven or polled
 *
 */
struct ttydev ttydevsw[NDEVS] = {
	/* Port A , Interupt driven */
	o_acia, _pchar, _gchar, s_acia, 0, 1,
	/* Port B , Interupt driven */
	o_acia, _pchar, _gchar, s_acia, 1, 1,
};
