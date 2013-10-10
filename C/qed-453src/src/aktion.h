#ifndef _qed_aktion_h_
#define _qed_aktion_h_

extern int		akt_handle;

extern void		start_aktion		(char *str, bool inter, long max);
extern bool		do_aktion			(char *str, long value);
extern void		redraw_aktion		(void);
extern void		end_aktion			(void);

#endif
